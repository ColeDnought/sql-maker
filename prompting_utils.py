import os
import re
import json


def read_schema(schema_path):
    '''
    Read the .schema file and return a compact, human-readable description
    suitable for use in LLM prompts.
    '''
    with open(schema_path, 'r') as f:
        schema = json.load(f)

    lines = []
    for table_name, columns in schema['ents'].items():
        col_defs = []
        for col_name, col_info in columns.items():
            col_defs.append(col_name)
        lines.append(f"  {table_name}({', '.join(col_defs)})")

    return "Database schema:\n" + "\n".join(lines)


def extract_sql_query(response):
    '''
    Extract the SQL query from the model's response.
    Handles: ```sql ... ```, ``` ... ```, bare SELECT/..., or fallback.
    '''
    # Strip any leading/trailing whitespace
    response = response.strip()

    # Try to find SQL inside a ```sql ... ``` block
    match = re.search(r'```sql\s*(.*?)```', response, re.DOTALL | re.IGNORECASE)
    if match:
        return match.group(1).strip()

    # Try generic ``` ... ``` block
    match = re.search(r'```\s*(.*?)```', response, re.DOTALL)
    if match:
        candidate = match.group(1).strip()
        # Only accept if it looks like SQL
        if re.match(r'(?i)(SELECT|INSERT|UPDATE|DELETE|WITH)', candidate):
            return candidate

    # Try to find a SELECT statement in the response
    match = re.search(r'(SELECT\s+.*?)(?:\n\n|\Z)', response, re.DOTALL | re.IGNORECASE)
    if match:
        return match.group(1).strip()

    # Try to grab everything after common lead-in phrases
    for pattern in [
        r'(?:SQL query|query):\s*(SELECT.*)',
        r'(?:Answer|Result):\s*(SELECT.*)',
    ]:
        match = re.search(pattern, response, re.DOTALL | re.IGNORECASE)
        if match:
            return match.group(1).strip()

    # Last resort: return the whole response (will likely fail SQL execution)
    return response


def save_logs(output_path, sql_em, record_em, record_f1, error_msgs):
    '''
    Save the logs of the experiment to files.
    '''
    with open(output_path, "w") as f:
        f.write(f"SQL EM: {sql_em}\nRecord EM: {record_em}\nRecord F1: {record_f1}\nModel Error Messages: {error_msgs}\n")
