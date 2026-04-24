import os, random, re, string
from collections import Counter
from tqdm import tqdm
import pickle

from torch.utils.data import Dataset, DataLoader
from torch.nn.utils.rnn import pad_sequence

from transformers import T5TokenizerFast
import torch

PAD_IDX = 0
TOKENIZER_NAME = "google-t5/t5-small"
TASK_PREFIX = "translate English to SQL: "
BOS_TOKEN = "<extra_id_0>"
# Truncate decoder sequences to match max_new_tokens used in generation.
# p95 SQL length is ~447 tokens; truncating at 300 keeps >95% of training
# signal while halving decoder attention cost (O(n^2)).
MAX_DECODER_LEN = 300
_TOKENIZER = None


def get_t5_tokenizer():
    global _TOKENIZER
    if _TOKENIZER is None:
        _TOKENIZER = T5TokenizerFast.from_pretrained(TOKENIZER_NAME)
    return _TOKENIZER

class T5Dataset(Dataset):

    def __init__(self, data_folder, split):
        '''
        Skeleton for the class for performing data processing for the T5 model.

        Some tips for implementation:
            * You should be using the 'google-t5/t5-small' tokenizer checkpoint to tokenize both
              the encoder and decoder output. 
            * You want to provide the decoder some beginning of sentence token. Any extra-id on the
              T5Tokenizer should serve that purpose (e.g., "<extra_id_0>").
            * Class behavior should be different on the test set.
        '''
        self.split = split
        self.tokenizer = get_t5_tokenizer()
        self.bos_token = BOS_TOKEN
        self.bos_token_id = self.tokenizer.convert_tokens_to_ids(self.bos_token)
        self.data = self.process_data(data_folder, split, self.tokenizer)

    def process_data(self, data_folder, split, tokenizer):
        nl_path = os.path.join(data_folder, f"{split}.nl")
        sql_path = os.path.join(data_folder, f"{split}.sql")

        nl_lines = load_lines(nl_path)
        sql_lines = load_lines(sql_path) if split != "test" else [None] * len(nl_lines)

        data = []
        for nl_line, sql_line in zip(nl_lines, sql_lines):
            prefixed_nl = f"{TASK_PREFIX}{nl_line}"
            encoder_tokens = tokenizer(prefixed_nl, add_special_tokens=True)

            if split == "test":
                decoder_ids = torch.tensor([self.bos_token_id], dtype=torch.long)
                bos_sql_line = self.bos_token
            else:
                bos_sql_line = f"{self.bos_token}{sql_line}"
                decoder_tokens = tokenizer(
                    bos_sql_line,
                    add_special_tokens=True,
                    truncation=True,
                    max_length=MAX_DECODER_LEN,
                )
                decoder_ids = torch.tensor(decoder_tokens["input_ids"], dtype=torch.long)

            data.append(
                {
                    "encoder_ids": torch.tensor(encoder_tokens["input_ids"], dtype=torch.long),
                    "encoder_mask": torch.tensor(encoder_tokens["attention_mask"], dtype=torch.long),
                    "decoder_ids": decoder_ids,
                    "sql_line": bos_sql_line,
                }
            )

        return data
    
    def __len__(self):
        return len(self.data)

    def __getitem__(self, idx):
        data_dict = self.data[idx]

        #sql_line is just a string of the sql command with the special bos token added in the beginning. 
        return data_dict["encoder_ids"], data_dict["encoder_mask"], data_dict["decoder_ids"], \
            data_dict["sql_line"]

def normal_collate_fn(batch):
    '''
    Collation function to perform dynamic padding for training and evaluation with the
    development or validation set.

    Inputs:
        * batch (List[Any]): batch is a list of length batch_size, where each index contains what
                             the dataset __getitem__ function returns.

    Returns: To be compatible with the provided training loop, you should be returning
        * encoder_ids: The input ids of shape BxT to be fed into the T5 encoder.
        * encoder_mask: Mask of shape BxT associated with padding tokens in the encoder input
        * decoder_inputs: Decoder input ids of shape BxT' to be fed into T5 decoder.
        * decoder_targets: The target tokens with which to train the decoder (the tokens following each decoder input)
        * initial_decoder_inputs: The very first input token to the decoder (only to be used in evaluation)
    '''
    encoder_ids, encoder_masks, decoder_ids, _ = zip(*batch)

    padded_encoder_ids = pad_sequence(encoder_ids, batch_first=True, padding_value=PAD_IDX)
    padded_encoder_masks = pad_sequence(encoder_masks, batch_first=True, padding_value=0)

    initial_decoder_inputs = torch.stack([decoder_id[:1] for decoder_id in decoder_ids], dim=0)
    padded_decoder_ids = pad_sequence(decoder_ids, batch_first=True, padding_value=PAD_IDX)
    padded_decoder_inputs = padded_decoder_ids[:, :-1]
    padded_decoder_targets = padded_decoder_ids[:, 1:]

    return (
        padded_encoder_ids,
        padded_encoder_masks,
        padded_decoder_inputs,
        padded_decoder_targets,
        initial_decoder_inputs,
    )

def test_collate_fn(batch):
    '''
    Collation function to perform dynamic padding for inference on the test set.

    Inputs:
        * batch (List[Any]): batch is a list of length batch_size, where each index contains what
                             the dataset __getitem__ function returns.

    Recommended returns: 
        * encoder_ids: The input ids of shape BxT to be fed into the T5 encoder.
        * encoder_mask: Mask of shape BxT associated with padding tokens in the encoder input
        * initial_decoder_inputs: The very first input token to the decoder (only to be used in evaluation)
    '''
    encoder_ids, encoder_masks, decoder_ids, _ = zip(*batch)

    padded_encoder_ids = pad_sequence(encoder_ids, batch_first=True, padding_value=PAD_IDX)
    padded_encoder_masks = pad_sequence(encoder_masks, batch_first=True, padding_value=0)
    initial_decoder_inputs = torch.stack([decoder_id[:1] for decoder_id in decoder_ids], dim=0)

    return padded_encoder_ids, padded_encoder_masks, initial_decoder_inputs
    

def get_dataloader(batch_size, split):
    data_folder = 'data'
    dset = T5Dataset(data_folder, split)
    shuffle = split == "train"
    collate_fn = normal_collate_fn if split != "test" else test_collate_fn

    dataloader = DataLoader(dset, batch_size=batch_size, shuffle=shuffle, collate_fn=collate_fn)
    return dataloader

def load_t5_data(batch_size, test_batch_size):
    train_loader = get_dataloader(batch_size, "train")
    dev_loader = get_dataloader(test_batch_size, "dev")
    test_loader = get_dataloader(test_batch_size, "test")
    
    return train_loader, dev_loader, test_loader


def load_lines(path):
    with open(path, 'r') as f:
        lines = f.readlines()
        lines = [line.strip() for line in lines]
    return lines

def load_prompting_data(data_folder):
    train_x = load_lines(os.path.join(data_folder, "train.nl"))
    train_y = load_lines(os.path.join(data_folder, "train.sql"))
    dev_x = load_lines(os.path.join(data_folder, "dev.nl"))
    dev_y = load_lines(os.path.join(data_folder, "dev.sql"))
    test_x = load_lines(os.path.join(data_folder, "test.nl"))
    return train_x, train_y, dev_x, dev_y, test_x
