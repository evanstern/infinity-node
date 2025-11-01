#!/usr/bin/env bash
#
# get-next-task-id.sh - Get the next available task ID
#
# Returns the next task ID in format IN-NNN (e.g., IN-024, IN-025)
#
# This script:
# - Reads tasks/.task-id-counter if it exists
# - Otherwise scans all task files and finds highest ID
# - Creates counter file if missing
# - Returns next available ID
#
# Usage:
#   ./scripts/tasks/get-next-task-id.sh
#
# Output:
#   IN-NNN (e.g., IN-024)
#
# Exit codes:
#   0 - Success
#   1 - Error

set -euo pipefail

# Get workspace root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
cd "$WORKSPACE_ROOT"

COUNTER_FILE="tasks/.task-id-counter"

# Function to scan all tasks and find highest ID
scan_tasks() {
    # Find all task files, extract ID numbers, sort, get highest
    HIGHEST=$(find tasks/ -name "IN-*.md" 2>/dev/null | \
              sed 's/.*IN-0*//' | \
              sed 's/-.*//' | \
              sort -n | \
              tail -1)

    # If no tasks found, start at 1
    if [ -z "$HIGHEST" ]; then
        echo 1
    else
        echo $((HIGHEST + 1))
    fi
}

# Check if counter file exists
if [ -f "$COUNTER_FILE" ]; then
    # Read current counter
    NEXT_ID=$(cat "$COUNTER_FILE")

    # Validate it's a number
    if ! [[ "$NEXT_ID" =~ ^[0-9]+$ ]]; then
        echo "Error: Counter file contains invalid value: $NEXT_ID" >&2
        echo "Rescanning tasks..." >&2
        NEXT_ID=$(scan_tasks)
        echo "$NEXT_ID" > "$COUNTER_FILE"
    fi
else
    # Counter doesn't exist - scan and create
    NEXT_ID=$(scan_tasks)
    echo "$NEXT_ID" > "$COUNTER_FILE"
fi

# Format as IN-NNN (zero-padded to 3 digits)
printf "IN-%03d\n" "$NEXT_ID"
