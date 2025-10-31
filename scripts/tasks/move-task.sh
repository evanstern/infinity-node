#!/usr/bin/env bash
#
# move-task.sh - Atomically move task between lifecycle stages
#
# Usage: ./scripts/tasks/move-task.sh <TASK_ID> <FROM> <TO>
#   FROM/TO: backlog | current | completed
#
# Example: ./scripts/tasks/move-task.sh IN-007 current completed
#
# This script:
# - Finds the task file in the FROM directory
# - Updates the status frontmatter to match TO stage
# - Moves the file to TO directory
# - Verifies no duplicates exist
# - Stages both deletion and addition for git
# - Shows final git status for verification

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Functions
error() {
    echo -e "${RED}❌ Error: $1${NC}" >&2
    exit 1
}

success() {
    echo -e "${GREEN}✓ $1${NC}"
}

warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

info() {
    echo "ℹ️  $1"
}

# Validate arguments
if [ $# -ne 3 ]; then
    error "Usage: $0 <TASK_ID> <FROM> <TO>\n  Example: $0 IN-007 current completed"
fi

TASK_ID="$1"
FROM="$2"
TO="$3"

# Validate FROM/TO values
if [[ ! "$FROM" =~ ^(backlog|current|completed)$ ]]; then
    error "FROM must be: backlog, current, or completed (got: $FROM)"
fi

if [[ ! "$TO" =~ ^(backlog|current|completed)$ ]]; then
    error "TO must be: backlog, current, or completed (got: $TO)"
fi

if [ "$FROM" == "$TO" ]; then
    error "FROM and TO cannot be the same ($FROM)"
fi

# Get workspace root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
cd "$WORKSPACE_ROOT"

info "Moving task $TASK_ID from '$FROM' to '$TO'"

# Find task file in FROM directory
TASK_FILES=(tasks/$FROM/$TASK_ID-*.md)
if [ ${#TASK_FILES[@]} -eq 0 ] || [ ! -f "${TASK_FILES[0]}" ]; then
    error "Task file not found: tasks/$FROM/$TASK_ID-*.md"
fi

if [ ${#TASK_FILES[@]} -gt 1 ]; then
    error "Multiple task files found in tasks/$FROM/:\n$(printf '  %s\n' "${TASK_FILES[@]}")"
fi

TASK_FILE="${TASK_FILES[0]}"
TASK_FILENAME="$(basename "$TASK_FILE")"
info "Found: $TASK_FILE"

# Check for duplicates in other directories
info "Checking for duplicates across all task directories..."
DUPLICATES=()
for dir in backlog current completed; do
    if [ "$dir" != "$FROM" ]; then
        if ls tasks/$dir/$TASK_ID-*.md 2>/dev/null | grep -q .; then
            DUPLICATES+=($(ls tasks/$dir/$TASK_ID-*.md))
        fi
    fi
done

if [ ${#DUPLICATES[@]} -gt 0 ]; then
    error "Duplicate task files found! Clean these up first:\n$(printf '  %s\n' "${DUPLICATES[@]}")"
fi

success "No duplicates found"

# Determine status based on TO directory
case "$TO" in
    backlog)
        NEW_STATUS="backlog"
        ;;
    current)
        NEW_STATUS="in-progress"
        ;;
    completed)
        NEW_STATUS="completed"
        ;;
esac

# Update status in frontmatter and set completed date if moving to completed
info "Updating task status to '$NEW_STATUS'"
TEMP_FILE=$(mktemp)

if [ "$TO" == "completed" ]; then
    # Update status AND set completed date
    COMPLETED_DATE=$(date +%Y-%m-%d)
    awk -v status="$NEW_STATUS" -v date="$COMPLETED_DATE" '
        BEGIN { in_frontmatter=0; updated_status=0; updated_completed=0 }
        /^---$/ { 
            in_frontmatter = !in_frontmatter
            print
            next
        }
        in_frontmatter && /^status:/ {
            print "status: " status
            updated_status=1
            next
        }
        in_frontmatter && /^completed:/ {
            print "completed: " date
            updated_completed=1
            next
        }
        { print }
    ' "$TASK_FILE" > "$TEMP_FILE"
else
    # Just update status
    awk -v status="$NEW_STATUS" '
        BEGIN { in_frontmatter=0; updated=0 }
        /^---$/ { 
            in_frontmatter = !in_frontmatter
            print
            next
        }
        in_frontmatter && /^status:/ {
            print "status: " status
            updated=1
            next
        }
        { print }
    ' "$TASK_FILE" > "$TEMP_FILE"
fi

# Move temp file to destination
DEST_FILE="tasks/$TO/$TASK_FILENAME"
mkdir -p "tasks/$TO"
mv "$TEMP_FILE" "$DEST_FILE"
success "Created: $DEST_FILE"

# Remove original file
rm "$TASK_FILE"
success "Removed: $TASK_FILE"

# Verify no duplicates now exist
info "Final duplicate check..."
FINAL_DUPLICATES=()
FOUND_COUNT=0
for dir in backlog current completed; do
    if ls tasks/$dir/$TASK_ID-*.md 2>/dev/null | grep -q .; then
        FOUND_COUNT=$((FOUND_COUNT + 1))
        FINAL_DUPLICATES+=($(ls tasks/$dir/$TASK_ID-*.md))
    fi
done

if [ $FOUND_COUNT -ne 1 ]; then
    error "Unexpected state! Found $FOUND_COUNT copies of task:\n$(printf '  %s\n' "${FINAL_DUPLICATES[@]}")"
fi

if [ "${FINAL_DUPLICATES[0]}" != "$DEST_FILE" ]; then
    error "Task file not in expected location!\n  Expected: $DEST_FILE\n  Found: ${FINAL_DUPLICATES[0]}"
fi

success "Task file is in correct location: $DEST_FILE"

# Stage changes in git
info "Staging git changes..."
git add "$DEST_FILE" 2>/dev/null || true
git add "tasks/$FROM/" 2>/dev/null || true  # Stage the deletion
success "Changes staged"

# Show final git status
echo ""
info "Git status:"
echo "─────────────────────────────────────────────────"
git status --short | grep -E "$TASK_ID|^[ADM].*tasks/(backlog|current|completed)" || echo "  (no changes)"
echo "─────────────────────────────────────────────────"
echo ""

success "Task $TASK_ID successfully moved from '$FROM' to '$TO'"
echo ""
info "Next steps:"
echo "  1. Review git status above"
echo "  2. Stage any other changes: git add <files>"
echo "  3. Commit: git commit -m 'your message'"

