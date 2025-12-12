# Utility Scripts

This directory contains utility scripts for various tasks.

## Bitwarden Utilities

### `find_bw_duplicates.py`

Analyzes your Vaultwarden/Bitwarden vault to identify potential duplicate entries.

**Usage:**
1. Ensure you have a valid Bitwarden session (run `bw login` or `export BW_SESSION=...`).
2. Generate an items export: `bw list items > bw_items.json`.
3. Run the script: `python3 find_bw_duplicates.py`.
4. Review the output in `potential_duplicates.json`.

The script identifies duplicates based on:
- Exact Name matches
- Same Username on the same Host

It generates a JSON report where you can mark items for deletion by changing `"action": "keep"` to `"action": "delete"`. It automatically suggests deletions for older items that have identical credentials to the newest item.

### `delete_bw_duplicates.py`

Processes the `potential_duplicates.json` report to delete marked items.

**Usage:**
1. Ensure you have a valid Bitwarden session.
2. Run the script: `python3 delete_bw_duplicates.py`.
3. The script will delete all items marked with `"action": "delete"` in the JSON report.

### `get-bw-session.sh` & `bw-setup-session.sh`

Helper scripts to manage Bitwarden CLI sessions.
- `get-bw-session.sh`: Retrieves a session token, prompting for login if needed.
- `bw-setup-session.sh`: Sets up the environment for Bitwarden CLI.

## Other Utilities

### `organize-music.py`

Script for organizing music library files.
