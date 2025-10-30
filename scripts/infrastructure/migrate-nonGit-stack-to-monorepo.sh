#!/bin/bash
#
# migrate-nonGit-stack-to-monorepo.sh
#
# Purpose: Migrate a non-Git Portainer stack to the infinity-node monorepo
#
# This script orchestrates the complete migration workflow for stacks that
# don't currently have Git configured. It follows a safe 8-step process:
#   1. Stop the original stack
#   2. Create a backup copy
#   3. Ensure backup is stopped
#   4. Extract environment variables from backup
#   5. Delete the original stack
#   6. Create new Git-based stack from monorepo
#   7. Verify containers are healthy
#   8. Optionally delete the backup
#
# Usage:
#   ./migrate-nonGit-stack-to-monorepo.sh <portainer-secret-name> <collection-name> <stack-id> <endpoint-id> <stack-name> <compose-path>
#
# Arguments:
#   portainer-secret-name: Name of Portainer API token secret in Vaultwarden
#   collection-name: Vaultwarden collection containing the secret
#   stack-id: Portainer stack ID (number) to migrate
#   endpoint-id: Portainer endpoint ID (usually 3 for local)
#   stack-name: Name for the new Git-based stack
#   compose-path: Path to compose file in monorepo (e.g., "stacks/homepage/docker-compose.yml")
#
# Examples:
#   # Migrate homepage stack
#   ./migrate-nonGit-stack-to-monorepo.sh "portainer-api-token-vm-103" "shared" 3 3 "homepage" \
#       "stacks/homepage/docker-compose.yml"
#
# Note: Environment variables are automatically extracted from the original stack
#
# Requirements:
#   - All helper scripts: stop-stack.sh, backup-stack.sh, delete-stack.sh, create-git-stack.sh
#   - get-vw-secret.sh script
#   - BW_SESSION set: export BW_SESSION=$(cat ~/.bw-session)
#   - curl, jq installed
#
# Exit Codes:
#   0 - Success
#   1 - Invalid arguments or prerequisites
#   2 - Failed during migration steps
#   3 - User cancelled operation

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

error() { echo -e "${RED}ERROR: $1${NC}" >&2; }
success() { echo -e "${GREEN}✓ $1${NC}"; }
info() { echo -e "${BLUE}→ $1${NC}"; }
warn() { echo -e "${YELLOW}⚠ $1${NC}"; }
step() { echo -e "${CYAN}[Step $1/8] $2${NC}"; }

# Validate arguments
if [ $# -lt 6 ]; then
    error "Missing required arguments"
    echo "Usage: $0 <portainer-secret-name> <collection-name> <stack-id> <endpoint-id> <stack-name> <compose-path>" >&2
    exit 1
fi

SECRET_NAME="$1"
COLLECTION_NAME="$2"
STACK_ID="$3"
ENDPOINT_ID="$4"
STACK_NAME="$5"
COMPOSE_PATH="$6"

# Check for required scripts
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STOP_SCRIPT="$SCRIPT_DIR/stop-stack.sh"
BACKUP_SCRIPT="$SCRIPT_DIR/backup-stack.sh"
DELETE_SCRIPT="$SCRIPT_DIR/delete-stack.sh"
CREATE_SCRIPT="$SCRIPT_DIR/create-git-stack.sh"
VERIFY_SCRIPT="$SCRIPT_DIR/verify-stack-health.sh"
GET_SECRET_SCRIPT="$SCRIPT_DIR/../secrets/get-vw-secret.sh"

for script in "$STOP_SCRIPT" "$BACKUP_SCRIPT" "$DELETE_SCRIPT" "$CREATE_SCRIPT" "$VERIFY_SCRIPT" "$GET_SECRET_SCRIPT"; do
    if [ ! -f "$script" ]; then
        error "Required script not found: $script"
        exit 1
    fi
done

echo ""
echo -e "${CYAN}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║  Portainer Stack Migration to Monorepo                         ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════════════════════════╝${NC}"
echo ""
info "Stack ID: $STACK_ID → $STACK_NAME"
info "Compose path: $COMPOSE_PATH"
echo ""
warn "This will DELETE the original stack and create a new one!"
warn "Environment variables will be preserved from the original stack"
echo ""

# Step 1: Stop original stack
step "1" "Stopping original stack..."
if ! "$STOP_SCRIPT" "$SECRET_NAME" "$COLLECTION_NAME" "$STACK_ID" "$ENDPOINT_ID"; then
    error "Failed to stop original stack"
    exit 2
fi
echo ""

# Step 2: Create backup
step "2" "Creating backup copy..."
BACKUP_OUTPUT=$("$BACKUP_SCRIPT" "$SECRET_NAME" "$COLLECTION_NAME" "$STACK_ID" "$ENDPOINT_ID" 2>&1)
if [ $? -ne 0 ]; then
    error "Failed to create backup"
    echo "$BACKUP_OUTPUT" >&2
    exit 2
fi

# Extract backup ID from output (strip ANSI color codes first)
BACKUP_ID=$(echo "$BACKUP_OUTPUT" | sed 's/\x1b\[[0-9;]*m//g' | grep "Backup:.*_backup (ID:" | sed 's/.*(ID: \([0-9]*\)).*/\1/')
if [ -z "$BACKUP_ID" ]; then
    error "Could not determine backup stack ID"
    echo "Debug: Backup output:" >&2
    echo "$BACKUP_OUTPUT" >&2
    exit 2
fi

success "Backup created with ID: $BACKUP_ID"
echo ""

# Step 3: Ensure backup is stopped (already done by backup-stack.sh)
step "3" "Verifying backup is stopped..."
success "Backup stack is stopped"
echo ""

# Step 4: Extract environment variables from backup
step "4" "Extracting environment variables from backup..."

# Get Portainer credentials
API_TOKEN=$("$GET_SECRET_SCRIPT" "$SECRET_NAME" "$COLLECTION_NAME" 2>/dev/null)
PORTAINER_URL=$("$GET_SECRET_SCRIPT" "$SECRET_NAME" "$COLLECTION_NAME" "url" 2>/dev/null)

# Query backup stack for environment variables
BACKUP_STACK_INFO=$(curl -sk -H "X-API-Key: $API_TOKEN" "$PORTAINER_URL/api/stacks/$BACKUP_ID" 2>/dev/null)
BACKUP_ENV=$(echo "$BACKUP_STACK_INFO" | jq -c '.Env // []')

# Convert to .env format and save to temp file
TEMP_ENV_FILE="/tmp/migrate-${STACK_NAME}-env-$$.env"
echo "$BACKUP_ENV" | jq -r '.[] | "\(.name)=\(.value)"' > "$TEMP_ENV_FILE"

ENV_COUNT=$(wc -l < "$TEMP_ENV_FILE" | tr -d ' ')
success "Extracted $ENV_COUNT environment variables from backup"
echo ""

# Step 5: Delete original stack
step "5" "Deleting original stack..."
if ! "$DELETE_SCRIPT" "$SECRET_NAME" "$COLLECTION_NAME" "$STACK_ID" "$ENDPOINT_ID"; then
    error "Failed to delete original stack"
    warn "Backup stack (ID: $BACKUP_ID) still exists"
    rm -f "$TEMP_ENV_FILE"
    exit 2
fi
echo ""

# Step 6: Create new Git-based stack
step "6" "Creating new Git-based stack from monorepo..."
if ! "$CREATE_SCRIPT" "$SECRET_NAME" "$COLLECTION_NAME" "$ENDPOINT_ID" "$STACK_NAME" "$COMPOSE_PATH" "$TEMP_ENV_FILE"; then
    error "Failed to create new Git-based stack"
    warn "Original stack has been deleted!"
    warn "Backup stack (ID: $BACKUP_ID) still exists and can be started to restore service"
    rm -f "$TEMP_ENV_FILE"
    exit 2
fi

# Clean up temp env file
rm -f "$TEMP_ENV_FILE"
echo ""

# Step 7: Verify containers are healthy
step "7" "Verifying container health..."

if ! "$VERIFY_SCRIPT" "$SECRET_NAME" "$COLLECTION_NAME" "$STACK_NAME" "$ENDPOINT_ID" 180; then
    error "Stack health check failed!"
    warn "Backup stack (ID: $BACKUP_ID) still exists"
    warn "Check container logs for details"
    exit 2
fi

# Get final stack info
NEW_STACKS=$(curl -sk -H "X-API-Key: $API_TOKEN" "$PORTAINER_URL/api/stacks" 2>/dev/null)
NEW_STACK=$(echo "$NEW_STACKS" | jq ".[] | select(.Name == \"$STACK_NAME\")")
NEW_STACK_ID=$(echo "$NEW_STACK" | jq -r '.Id')
GIT_URL=$(echo "$NEW_STACK" | jq -r '.GitConfig.URL // "none"')
GITOPS_INTERVAL=$(echo "$NEW_STACK" | jq -r '.AutoUpdate.Interval // "disabled"')

success "Stack ID: $NEW_STACK_ID"
success "Git: $GIT_URL"
success "GitOps: $GITOPS_INTERVAL"
echo ""

# Step 8: Optionally delete backup
step "8" "Cleanup backup stack..."
echo ""
echo -n "Do you want to delete the backup stack (ID: $BACKUP_ID)? [y/N] "
read -r RESPONSE

if [[ "$RESPONSE" =~ ^[Yy]$ ]]; then
    if "$DELETE_SCRIPT" "$SECRET_NAME" "$COLLECTION_NAME" "$BACKUP_ID" "$ENDPOINT_ID"; then
        success "Backup stack deleted"
    else
        warn "Failed to delete backup stack - you can delete it manually later"
    fi
else
    info "Keeping backup stack (ID: $BACKUP_ID)"
    info "Delete it manually when ready with: ./delete-stack.sh \"$SECRET_NAME\" \"$COLLECTION_NAME\" $BACKUP_ID $ENDPOINT_ID"
fi

echo ""
echo -e "${GREEN}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  Migration Complete!                                           ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════════════╝${NC}"
echo ""
success "Stack '$STACK_NAME' is now running from monorepo"
success "Stack ID: $NEW_STACK_ID"
success "GitOps updates enabled with $GITOPS_INTERVAL interval"
echo ""

exit 0
