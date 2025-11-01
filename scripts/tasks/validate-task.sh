#!/usr/bin/env bash
#
# validate-task.sh - Validate a task file and check for issues
#
# This script validates:
# - Task file exists
# - Task ID is unique (no duplicates)
# - Frontmatter is valid YAML
# - Required frontmatter fields present
# - Task follows naming convention
#
# Usage:
#   ./scripts/tasks/validate-task.sh <TASK_ID>
#   ./scripts/tasks/validate-task.sh IN-024
#
# Exit codes:
#   0 - All validations passed
#   1 - Validation failure(s)

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Functions
error() {
    echo -e "${RED}❌ $1${NC}" >&2
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

# Check arguments
if [ $# -ne 1 ]; then
    error "Usage: $0 <TASK_ID>"
    echo "  Example: $0 IN-024"
    exit 1
fi

TASK_ID="$1"

# Get workspace root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
cd "$WORKSPACE_ROOT"

info "Validating task $TASK_ID..."
echo ""

VALIDATION_FAILED=0

# 1. Check task file exists
info "1. Checking if task file exists..."
TASK_FILES=($(find tasks/ -name "$TASK_ID-*.md" 2>/dev/null))

if [ ${#TASK_FILES[@]} -eq 0 ]; then
    error "Task file not found: tasks/*/$TASK_ID-*.md"
    VALIDATION_FAILED=1
elif [ ${#TASK_FILES[@]} -gt 1 ]; then
    error "Multiple task files found (duplicates!):"
    printf '  %s\n' "${TASK_FILES[@]}"
    VALIDATION_FAILED=1
else
    TASK_FILE="${TASK_FILES[0]}"
    success "Task file found: $TASK_FILE"
fi

echo ""

# If task file doesn't exist uniquely, stop here
if [ $VALIDATION_FAILED -eq 1 ]; then
    exit 1
fi

# 2. Check filename follows convention
info "2. Checking filename convention..."
FILENAME=$(basename "$TASK_FILE")
if [[ "$FILENAME" =~ ^IN-[0-9]{3}-[a-z0-9-]+\.md$ ]]; then
    success "Filename follows convention: $FILENAME"
else
    error "Filename doesn't follow convention: $FILENAME"
    echo "  Expected: IN-NNN-kebab-case-title.md"
    VALIDATION_FAILED=1
fi

echo ""

# 3. Check frontmatter is valid YAML
info "3. Checking frontmatter YAML validity..."

# Extract frontmatter (between first two ---)
FRONTMATTER=$(awk '/^---$/{i++}i==1{print}i==2{exit}' "$TASK_FILE" | sed '1d;$d')

if [ -z "$FRONTMATTER" ]; then
    error "No frontmatter found"
    VALIDATION_FAILED=1
else
    # Try to validate YAML (requires python or ruby)
    if command -v python3 &> /dev/null; then
        echo "$FRONTMATTER" | python3 -c "import sys, yaml; yaml.safe_load(sys.stdin)" 2>/dev/null
        if [ $? -eq 0 ]; then
            success "Frontmatter is valid YAML"
        else
            error "Frontmatter has YAML syntax errors"
            VALIDATION_FAILED=1
        fi
    else
        warning "Cannot validate YAML (python3 not available) - skipping"
    fi
fi

echo ""

# 4. Check required frontmatter fields
info "4. Checking required frontmatter fields..."

REQUIRED_FIELDS=(
    "type: task"
    "task-id: $TASK_ID"
    "status:"
    "priority:"
    "category:"
    "agent:"
    "created:"
    "updated:"
)

MISSING_FIELDS=0
for field in "${REQUIRED_FIELDS[@]}"; do
    if echo "$FRONTMATTER" | grep -q "^${field}"; then
        success "Field present: $field"
    else
        error "Missing required field: $field"
        MISSING_FIELDS=1
        VALIDATION_FAILED=1
    fi
done

if [ $MISSING_FIELDS -eq 0 ]; then
    echo ""
    success "All required fields present"
fi

echo ""

# 5. Check task is in correct directory for status
info "5. Checking task location matches status..."

STATUS=$(echo "$FRONTMATTER" | grep "^status:" | sed 's/status: *//' | tr -d '[:space:]')
TASK_DIR=$(dirname "$TASK_FILE" | xargs basename)

case "$STATUS" in
    backlog|pending)
        EXPECTED_DIR="backlog"
        ;;
    in-progress)
        EXPECTED_DIR="current"
        ;;
    completed)
        EXPECTED_DIR="completed"
        ;;
    *)
        warning "Unknown status: $STATUS"
        EXPECTED_DIR=""
        ;;
esac

if [ -n "$EXPECTED_DIR" ]; then
    if [ "$TASK_DIR" == "$EXPECTED_DIR" ]; then
        success "Task in correct directory: tasks/$TASK_DIR/ (status: $STATUS)"
    else
        error "Task in wrong directory!"
        echo "  Current: tasks/$TASK_DIR/"
        echo "  Expected: tasks/$EXPECTED_DIR/ (for status: $STATUS)"
        echo "  Use: ./scripts/tasks/move-task.sh $TASK_ID $TASK_DIR $EXPECTED_DIR"
        VALIDATION_FAILED=1
    fi
fi

echo ""

# 6. Final summary
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [ $VALIDATION_FAILED -eq 0 ]; then
    success "All validations passed! ✓"
    echo ""
    info "Task $TASK_ID is valid and ready to use"
    exit 0
else
    error "Validation failed! ✗"
    echo ""
    error "Fix the issues above before proceeding"
    exit 1
fi
