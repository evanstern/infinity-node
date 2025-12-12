import json
import subprocess
import os

def load_duplicates(filepath):
    with open(filepath, 'r') as f:
        return json.load(f)

def delete_item(item_id):
    # We use 'bw delete item <id>'
    # We need to make sure BW_SESSION is in env if running from python subprocess,
    # but usually we assume the shell environment has it or we pass it.
    # The agent runs this, so the agent will ensure BW_SESSION is set.

    cmd = ["bw", "delete", "item", item_id]
    try:
        subprocess.run(cmd, check=True, capture_output=True, text=True)
        return True
    except subprocess.CalledProcessError as e:
        print(f"Error deleting {item_id}: {e.stderr}")
        return False

def process_deletions(duplicates):
    deleted_count = 0
    errors = 0

    for group in duplicates:
        items = group.get('items', [])
        for item in items:
            if item.get('action') == 'delete':
                print(f"Deleting item: {item.get('name')} (ID: {item.get('id')})")
                if delete_item(item.get('id')):
                    deleted_count += 1
                else:
                    errors += 1

    return deleted_count, errors

if __name__ == "__main__":
    filepath = "potential_duplicates.json"
    if not os.path.exists(filepath):
        print(f"File {filepath} not found.")
        exit(1)

    dupes = load_duplicates(filepath)
    deleted, errors = process_deletions(dupes)

    print(f"Operation complete. Deleted {deleted} items. Errors: {errors}.")
