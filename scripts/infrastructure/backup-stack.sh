#!/bin/bash
#
# backup-stack.sh
#
# Purpose: Create a backup copy of a Portainer stack
#
# This script creates a backup of an existing stack by duplicating it with a
# "_backup" suffix. The backup stack is created in a stopped state.
#
# Usage:
#   ./backup-stack.sh <portainer-secret-name> <collection-name> <stack-id> <endpoint-id>
#
# Arguments:
#   portainer-secret-name: Name of Portainer API token secret in Vaultwarden
#   collection-name: Vaultwarden collection containing the secret
#   stack-id: Portainer stack ID (number) of stack to backup
#   endpoint-id: Portainer endpoint ID (usually 3 for local)
#
# Examples:
#   # Backup homepage stack before migration
#   ./backup-stack.sh "portainer-api-token-vm-103" "shared" 3 3
#
# What it does:
#   1. Retrieves the current stack configuration
#   2. Extracts docker-compose.yml content
#   3. Creates new stack with "_backup" suffix
#   4. Immediately stops the backup stack
#   5. Returns the backup stack ID
#
# Requirements:
#   - get-vw-secret.sh script
#   - BW_SESSION set: export BW_SESSION=$(cat ~/.bw-session)
#   - curl, jq installed
#
# Exit Codes:
#   0 - Success
#   1 - Invalid arguments or prerequisites
#   2 - Failed to retrieve credentials
#   3 - API request failed

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

error() { echo -e "${RED}ERROR: $1${NC}" >&2; }
success() { echo -e "${GREEN}✓ $1${NC}"; }
info() { echo -e "${BLUE}→ $1${NC}"; }
warn() { echo -e "${YELLOW}⚠ $1${NC}"; }

# Validate arguments
if [ $# -lt 4 ]; then
    error "Missing required arguments"
    echo "Usage: $0 <portainer-secret-name> <collection-name> <stack-id> <endpoint-id>" >&2
    exit 1
fi

SECRET_NAME="$1"
COLLECTION_NAME="$2"
STACK_ID="$3"
ENDPOINT_ID="$4"

# Check for required scripts
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GET_SECRET_SCRIPT="$SCRIPT_DIR/../secrets/get-vw-secret.sh"

if [ ! -f "$GET_SECRET_SCRIPT" ]; then
    error "get-vw-secret.sh not found at: $GET_SECRET_SCRIPT"
    exit 1
fi

if ! command -v curl &> /dev/null; then
    error "curl not found"
    exit 1
fi

if ! command -v jq &> /dev/null; then
    error "jq not found"
    exit 1
fi

info "Retrieving Portainer credentials from Vaultwarden..."

# Get API token
if ! API_TOKEN=$("$GET_SECRET_SCRIPT" "$SECRET_NAME" "$COLLECTION_NAME" 2>/dev/null); then
    error "Failed to retrieve API token from Vaultwarden"
    exit 2
fi

# Get Portainer URL
if ! PORTAINER_URL=$("$GET_SECRET_SCRIPT" "$SECRET_NAME" "$COLLECTION_NAME" "url" 2>/dev/null); then
    error "Failed to retrieve Portainer URL from Vaultwarden"
    exit 2
fi

success "Retrieved credentials"

info "Fetching stack configuration..."

# Get current stack details
STACK_INFO=$(curl -sk -H "X-API-Key: $API_TOKEN" "$PORTAINER_URL/api/stacks/$STACK_ID" 2>/dev/null)

if [ $? -ne 0 ]; then
    error "Failed to fetch stack details"
    exit 3
fi

# Check for API error
if echo "$STACK_INFO" | jq -e '.message' > /dev/null 2>&1; then
    ERROR_MSG=$(echo "$STACK_INFO" | jq -r '.message')
    error "Portainer API error: $ERROR_MSG"
    exit 3
fi

STACK_NAME=$(echo "$STACK_INFO" | jq -r '.Name')
STACK_ENV=$(echo "$STACK_INFO" | jq -c '.Env // []')
BACKUP_NAME="${STACK_NAME}_backup"

info "Original stack: $STACK_NAME (ID: $STACK_ID)"
info "Backup name: $BACKUP_NAME"

# Check if backup already exists and delete it
ALL_STACKS=$(curl -sk -H "X-API-Key: $API_TOKEN" "$PORTAINER_URL/api/stacks" 2>/dev/null)
EXISTING_BACKUP=$(echo "$ALL_STACKS" | jq ".[] | select(.Name == \"$BACKUP_NAME\")")

if [ -n "$EXISTING_BACKUP" ]; then
    EXISTING_ID=$(echo "$EXISTING_BACKUP" | jq -r '.Id')
    warn "Backup stack already exists (ID: $EXISTING_ID), deleting..."
    curl -sk -X DELETE -H "X-API-Key: $API_TOKEN" \
        "$PORTAINER_URL/api/stacks/$EXISTING_ID?endpointId=$ENDPOINT_ID" > /dev/null 2>&1
    success "Old backup deleted"
fi

# Get stack file content
info "Retrieving stack compose file..."
STACK_FILE=$(curl -sk -H "X-API-Key: $API_TOKEN" \
    "$PORTAINER_URL/api/stacks/$STACK_ID/file" 2>/dev/null)

if [ $? -ne 0 ]; then
    error "Failed to retrieve stack file"
    exit 3
fi

COMPOSE_CONTENT=$(echo "$STACK_FILE" | jq -r '.StackFileContent')

if [ -z "$COMPOSE_CONTENT" ] || [ "$COMPOSE_CONTENT" = "null" ]; then
    error "Could not retrieve compose file content"
    exit 3
fi

info "Creating backup stack..."

# Build API payload for backup stack
PAYLOAD=$(jq -n \
    --arg name "$BACKUP_NAME" \
    --arg content "$COMPOSE_CONTENT" \
    --argjson env "$STACK_ENV" \
    '{
        Name: $name,
        StackFileContent: $content,
        Env: $env
    }')

# Create backup stack
RESPONSE=$(curl -sk -X POST \
    -H "X-API-Key: $API_TOKEN" \
    -H "Content-Type: application/json" \
    "$PORTAINER_URL/api/stacks/create/standalone/string?endpointId=$ENDPOINT_ID" \
    -d "$PAYLOAD" 2>&1)

if [ $? -ne 0 ]; then
    error "Failed to create backup stack"
    echo "$RESPONSE" >&2
    exit 3
fi

# Check for API error
if echo "$RESPONSE" | jq -e '.message' > /dev/null 2>&1; then
    ERROR_MSG=$(echo "$RESPONSE" | jq -r '.message')
    error "Portainer API error: $ERROR_MSG"
    exit 3
fi

BACKUP_ID=$(echo "$RESPONSE" | jq -r '.Id')

success "Backup stack created (ID: $BACKUP_ID)"

# Stop the backup stack immediately
info "Stopping backup stack..."
STOP_RESPONSE=$(curl -sk -X POST \
    -H "X-API-Key: $API_TOKEN" \
    "$PORTAINER_URL/api/stacks/$BACKUP_ID/stop?endpointId=$ENDPOINT_ID" 2>&1)

if [ $? -eq 0 ] && ! echo "$STOP_RESPONSE" | jq -e '.message' > /dev/null 2>&1; then
    success "Backup stack stopped"
else
    warn "Backup created but could not be stopped automatically"
fi

echo ""
success "Backup complete!"
success "Original: $STACK_NAME (ID: $STACK_ID)"
success "Backup: $BACKUP_NAME (ID: $BACKUP_ID)"

exit 0
