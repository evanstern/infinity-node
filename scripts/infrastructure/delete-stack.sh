#!/bin/bash
#
# delete-stack.sh
#
# Purpose: Delete a Portainer stack
#
# This script permanently deletes a Docker Compose stack from Portainer.
# WARNING: This action cannot be undone. Consider backing up the stack first.
#
# Usage:
#   ./delete-stack.sh <portainer-secret-name> <collection-name> <stack-id> <endpoint-id>
#
# Arguments:
#   portainer-secret-name: Name of Portainer API token secret in Vaultwarden
#   collection-name: Vaultwarden collection containing the secret
#   stack-id: Portainer stack ID (number)
#   endpoint-id: Portainer endpoint ID (usually 3 for local)
#
# Examples:
#   # Delete a backup stack
#   ./delete-stack.sh "portainer-api-token-vm-103" "shared" 13 3
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

# Get stack info before deleting
info "Fetching stack information..."
STACK_INFO=$(curl -sk -H "X-API-Key: $API_TOKEN" "$PORTAINER_URL/api/stacks/$STACK_ID" 2>/dev/null)

if echo "$STACK_INFO" | jq -e '.message' > /dev/null 2>&1; then
    ERROR_MSG=$(echo "$STACK_INFO" | jq -r '.message')
    error "Stack not found or API error: $ERROR_MSG"
    exit 3
fi

STACK_NAME=$(echo "$STACK_INFO" | jq -r '.Name')

warn "About to delete stack: $STACK_NAME (ID: $STACK_ID)"
warn "This action cannot be undone!"

info "Deleting stack..."

# Delete the stack
RESPONSE=$(curl -sk -X DELETE \
    -H "X-API-Key: $API_TOKEN" \
    "$PORTAINER_URL/api/stacks/$STACK_ID?endpointId=$ENDPOINT_ID" 2>&1)

if [ $? -ne 0 ]; then
    error "Failed to delete stack"
    echo "$RESPONSE" >&2
    exit 3
fi

# Check if response has error (DELETE returns empty body on success)
if [ -n "$RESPONSE" ] && echo "$RESPONSE" | jq -e '.message' > /dev/null 2>&1; then
    ERROR_MSG=$(echo "$RESPONSE" | jq -r '.message')
    error "Portainer API error: $ERROR_MSG"
    exit 3
fi

success "Stack '$STACK_NAME' deleted successfully"

exit 0
