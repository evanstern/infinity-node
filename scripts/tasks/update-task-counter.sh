#!/usr/bin/env bash
#
# update-task-counter.sh - Increment the task ID counter
#
# This script increments the counter in tasks/.task-id-counter
# Should be called AFTER successfully creating a new task.
#
# Usage:
#   ./scripts/tasks/update-task-counter.sh
#
# Exit codes:
#   0 - Success
#   1 - Error (counter file missing or invalid)

set -euo pipefail

# Get workspace root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
cd "$WORKSPACE_ROOT"

COUNTER_FILE="tasks/.task-id-counter"

# Check if counter file exists
if [ ! -f "$COUNTER_FILE" ]; then
    echo "Error: Counter file not found: $COUNTER_FILE" >&2
    echo "Run get-next-task-id.sh first to initialize the counter." >&2
    exit 1
fi

# Read current value
CURRENT_ID=$(cat "$COUNTER_FILE")

# Validate it's a number
if ! [[ "$CURRENT_ID" =~ ^[0-9]+$ ]]; then
    echo "Error: Counter file contains invalid value: $CURRENT_ID" >&2
    exit 1
fi

# Increment
NEXT_ID=$((CURRENT_ID + 1))

# Write back
echo "$NEXT_ID" > "$COUNTER_FILE"

# Confirm
echo "✓ Task counter updated: $CURRENT_ID → $NEXT_ID"
echo "✓ Next task will be IN-$(printf "%03d" "$NEXT_ID")"
