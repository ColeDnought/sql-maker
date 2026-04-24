import os
import argparse
import random
from tqdm import tqdm

import torch
from transformers import AutoTokenizer, Gemma3ForCausalLM
from transformers import BitsAndBytesConfig

from utils import set_random_seeds, compute_metrics, save_queries_and_records, compute_records
from prompting_utils import read_schema, extract_sql_query, save_logs
from load_data import load_prompting_data

DEVICE = torch.device('cuda') if torch.cuda.is_available() else torch.device('cpu')

MAX_NEW_TOKENS = 300

SCHEMA_PATH = 'data/flight_database.schema'

# System prompt content — kept concise to leave room for few-shot examples
SYSTEM_PROMPT = (
    "You are a SQL expert. Given a natural language question and a database schema, "
    "generate a valid SQLite query that answers the question. "
    "Output ONLY the SQL query, wrapped in ```sql ... ``` tags. "
    "Do not include any explanation."
)


def get_args():
    parser = argparse.ArgumentParser(
        description='Text-to-SQL experiments with prompting.')

    parser.add_argument('-s', '--shot', type=int, default=0,
                        help='Number of examples for k-shot learning (0 for zero-shot)')
    parser.add_argument('-m', '--model', type=str, default='gemma-1b',
                        help='Model to use for prompting')
    parser.add_argument('-q', '--quantization', action='store_true',
                        help='Use a quantized version of the model (e.g. 4bits)')
    parser.add_argument('--selection', type=str, default='random',
                        choices=['random', 'first'],
                        help='Strategy for selecting few-shot examples')
    parser.add_argument('--seed', type=int, default=42,
                        help='Random seed to help reproducibility')
    parser.add_argument('--experiment_name', type=str, default='experiment',
                        help="How should we name this experiment?")
    parser.add_argument('--dev_only', action='store_true',
                        help='Only run on dev set, skip test set')
    parser.add_argument('--batch_size', type=int, default=4,
                        help='Batch size for LLM inference (left-pads shorter prompts)')
    args = parser.parse_args()
    return args


def build_schema_context():
    '''Return a compact schema string for inclusion in prompts.'''
    return read_schema(SCHEMA_PATH)


def select_examples(train_x, train_y, k, strategy='random', seed=42, exclude_idx=None):
    '''
    Select k few-shot examples from training data.

    strategy: 'random' picks k random examples; 'first' picks the first k.
    exclude_idx: index to skip (prevents leaking the current query if it appears in train).
    '''
    indices = [i for i in range(len(train_x)) if i != exclude_idx]
    if strategy == 'random':
        rng = random.Random(seed)
        chosen = rng.sample(indices, min(k, len(indices)))
    else:  # 'first'
        chosen = indices[:k]
    return [(train_x[i], train_y[i]) for i in chosen]


def create_prompt(sentence, k, train_x=None, train_y=None, strategy='random', seed=42):
    '''
    Build a zero- or few-shot prompt for a single NL sentence.

    The schema is always included. For few-shot (k>0), k training examples
    are prepended as demonstrations.
    '''
    schema_ctx = build_schema_context()

    parts = [schema_ctx, ""]

    if k > 0 and train_x is not None and train_y is not None:
        examples = select_examples(train_x, train_y, k, strategy=strategy, seed=seed)
        parts.append("Here are some examples of natural language questions and their SQL queries:\n")
        for ex_nl, ex_sql in examples:
            parts.append(f"Question: {ex_nl}")
            parts.append(f"SQL:\n```sql\n{ex_sql}\n```\n")

    parts.append(f"Now generate the SQL query for the following question.")
    parts.append(f"Question: {sentence}")
    parts.append("SQL:")

    return "\n".join(parts)


def exp_kshot(tokenizer, model, inputs, k, train_x=None, train_y=None,
              strategy='random', seed=42, batch_size=4):
    '''
    Run k-shot prompting for all inputs, return raw outputs and extracted SQL.
    Uses left-padded batched inference for throughput.
    '''
    raw_outputs = []
    extracted_queries = []

    # Gemma tokenizer should use left-padding for batched causal generation
    orig_padding_side = tokenizer.padding_side
    tokenizer.padding_side = 'left'

    # Build all messages upfront so we can batch them
    all_messages = []
    for i, sentence in enumerate(inputs):
        prompt = create_prompt(sentence, k, train_x=train_x, train_y=train_y,
                               strategy=strategy, seed=seed + i)
        all_messages.append([
            {"role": "system", "content": SYSTEM_PROMPT},
            {"role": "user", "content": prompt},
        ])

    for batch_start in tqdm(range(0, len(all_messages), batch_size),
                            total=(len(all_messages) + batch_size - 1) // batch_size):
        batch_msgs = all_messages[batch_start: batch_start + batch_size]

        # Tokenize each message in the batch, then pad together
        encoded_batch = [
            tokenizer.apply_chat_template(
                msgs,
                add_generation_prompt=True,
                tokenize=True,
                return_dict=True,
                return_tensors="pt",
            )
            for msgs in batch_msgs
        ]

        # Left-pad to same length
        max_len = max(e['input_ids'].shape[1] for e in encoded_batch)
        input_ids_list = []
        attention_mask_list = []
        prompt_lengths = []
        for e in encoded_batch:
            pad_len = max_len - e['input_ids'].shape[1]
            pad_id = tokenizer.pad_token_id if tokenizer.pad_token_id is not None else 0
            padded_ids = torch.cat([
                torch.full((1, pad_len), pad_id, dtype=torch.long),
                e['input_ids'],
            ], dim=1)
            padded_mask = torch.cat([
                torch.zeros(1, pad_len, dtype=torch.long),
                e['attention_mask'],
            ], dim=1)
            input_ids_list.append(padded_ids)
            attention_mask_list.append(padded_mask)
            prompt_lengths.append(max_len)

        input_ids = torch.cat(input_ids_list, dim=0).to(model.device)
        attention_mask = torch.cat(attention_mask_list, dim=0).to(model.device)

        with torch.inference_mode():
            outputs = model.generate(
                input_ids=input_ids,
                attention_mask=attention_mask,
                max_new_tokens=MAX_NEW_TOKENS,
                do_sample=False,
                pad_token_id=tokenizer.pad_token_id if tokenizer.pad_token_id is not None else 0,
            )

        for j, (out, prompt_len) in enumerate(zip(outputs, prompt_lengths)):
            new_token_ids = out[prompt_len:]
            response = tokenizer.decode(new_token_ids, skip_special_tokens=True)
            raw_outputs.append(response)
            extracted_queries.append(extract_sql_query(response))

    tokenizer.padding_side = orig_padding_side
    return raw_outputs, extracted_queries


def eval_outputs(extracted_queries, eval_y, gt_sql_path, model_sql_path,
                 gt_record_path, model_record_path):
    '''
    Save extracted queries to disk, execute them, and compute all three metrics.
    Returns sql_em, record_em, record_f1, model_error_msgs, error_rate.
    Only computes non-loss metrics (no model loss here).
    '''
    os.makedirs(os.path.dirname(model_sql_path), exist_ok=True)
    os.makedirs(os.path.dirname(model_record_path), exist_ok=True)

    save_queries_and_records(extracted_queries, model_sql_path, model_record_path)

    sql_em, record_em, record_f1, model_error_msgs = compute_metrics(
        gt_sql_path,
        model_sql_path,
        gt_record_path,
        model_record_path,
    )
    error_rate = sum(1 for e in model_error_msgs if e) / max(len(model_error_msgs), 1)

    return sql_em, record_em, record_f1, model_error_msgs, error_rate


def initialize_model_and_tokenizer(model_name, to_quantize=False):
    '''
    Load Gemma model and tokenizer. Supports 1b, 4b, 12b variants.
    '''
    model_map = {
        'gemma-1b':  'google/gemma-3-1b-it',
        'gemma-4b':  'google/gemma-3-4b-it',
        'gemma-12b': 'google/gemma-3-12b-it',
    }

    if model_name not in model_map:
        raise NotImplementedError(f"Model {model_name} not supported. Choose from: {list(model_map)}")

    model_id = model_map[model_name]
    tokenizer = AutoTokenizer.from_pretrained(model_id)

    if to_quantize:
        nf4_config = BitsAndBytesConfig(
            load_in_4bit=True,
            bnb_4bit_quant_type="nf4",
        )
        model = Gemma3ForCausalLM.from_pretrained(
            model_id,
            torch_dtype=torch.bfloat16,
            quantization_config=nf4_config,
        )
    else:
        model = Gemma3ForCausalLM.from_pretrained(
            model_id,
            torch_dtype=torch.bfloat16,
        ).to(DEVICE)

    model.eval()
    return tokenizer, model


def main():
    args = get_args()
    shot = args.shot
    model_name = args.model
    to_quantize = args.quantization
    experiment_name = args.experiment_name
    strategy = args.selection

    set_random_seeds(args.seed)

    data_folder = 'data'
    train_x, train_y, dev_x, dev_y, test_x = load_prompting_data(data_folder)

    tokenizer, model = initialize_model_and_tokenizer(model_name, to_quantize)

    splits = ['dev'] if args.dev_only else ['dev', 'test']

    for eval_split in splits:
        eval_x = dev_x if eval_split == 'dev' else test_x

        print(f"\n=== Running {shot}-shot on {eval_split} set ({len(eval_x)} examples) ===")
        raw_outputs, extracted_queries = exp_kshot(
            tokenizer, model, eval_x, shot,
            train_x=train_x, train_y=train_y,
            strategy=strategy, seed=args.seed,
            batch_size=args.batch_size,
        )

        gt_sql_path = os.path.join(f'data/{eval_split}.sql')
        gt_record_path = os.path.join(f'records/ground_truth_{eval_split}.pkl')
        model_sql_path = os.path.join(f'results/gemma_{experiment_name}_{eval_split}.sql')
        model_record_path = os.path.join(f'records/gemma_{experiment_name}_{eval_split}.pkl')

        if eval_split == 'dev':
            sql_em, record_em, record_f1, model_error_msgs, error_rate = eval_outputs(
                extracted_queries, dev_y,
                gt_sql_path, model_sql_path,
                gt_record_path, model_record_path,
            )
            print(f"  SQL EM: {sql_em:.4f}  Record EM: {record_em:.4f}  Record F1: {record_f1:.4f}")
            print(f"  Error rate: {error_rate*100:.2f}%")

            log_path = os.path.join(f'results/gemma_{experiment_name}_{eval_split}.log')
            save_logs(log_path, sql_em, record_em, record_f1, model_error_msgs)
        else:
            # No labels for test — just save queries
            os.makedirs('results', exist_ok=True)
            os.makedirs('records', exist_ok=True)
            save_queries_and_records(extracted_queries, model_sql_path, model_record_path)
            print(f"  Test outputs saved to {model_sql_path}")


if __name__ == "__main__":
    main()
