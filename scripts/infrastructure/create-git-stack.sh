#!/bin/bash
#
# create-git-stack.sh
#
# Purpose: Create a new Portainer stack from a Git repository
#
# This script creates a new Docker Compose stack in Portainer configured to
# pull from a Git repository with GitOps automatic updates enabled.
#
# Usage:
#   ./create-git-stack.sh <portainer-secret-name> <collection-name> <endpoint-id> <stack-name> <compose-path> [env-file]
#
# Arguments:
#   portainer-secret-name: Name of Portainer API token secret in Vaultwarden
#   collection-name: Vaultwarden collection containing the secret
#   endpoint-id: Portainer endpoint ID (usually 3 for local)
#   stack-name: Name for the new stack (e.g., "homepage", "watchtower")
#   compose-path: Path to compose file in repo (e.g., "stacks/homepage/docker-compose.yml")
#   env-file: (Optional) Path to .env file with environment variables
#
# Examples:
#   # Create stack with env vars from file
#   ./create-git-stack.sh "portainer-api-token-vm-103" "shared" 3 "homepage" "stacks/homepage/docker-compose.yml" "stacks/homepage/.env.example"
#
#   # Create stack without env vars
#   ./create-git-stack.sh "portainer-api-token-vm-103" "shared" 3 "watchtower" "stacks/watchtower/docker-compose.yml"
#
# What it does:
#   1. Creates Git-based stack pointing to infinity-node monorepo
#   2. Enables GitOps updates with 5-minute polling interval
#   3. Loads environment variables from .env file if provided
#   4. Returns the new stack ID on success
#
# Requirements:
#   - get-vw-secret.sh script
#   - BW_SESSION set: export BW_SESSION=$(cat ~/.bw-session)
#   - curl, jq installed
#   - Stack name must not already exist in Portainer
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
if [ $# -lt 5 ]; then
    error "Missing required arguments"
    echo "Usage: $0 <portainer-secret-name> <collection-name> <endpoint-id> <stack-name> <compose-path> [env-file]" >&2
    echo "" >&2
    echo "Examples:" >&2
    echo "  $0 \"portainer-api-token-vm-103\" \"shared\" 3 \"homepage\" \"stacks/homepage/docker-compose.yml\" \"stacks/homepage/.env.example\"" >&2
    exit 1
fi

SECRET_NAME="$1"
COLLECTION_NAME="$2"
ENDPOINT_ID="$3"
STACK_NAME="$4"
COMPOSE_PATH="$5"
ENV_FILE="${6:-}"

# Monorepo configuration
MONOREPO_URL="https://github.com/evanstern/infinity-node"
GITOPS_INTERVAL="5m"

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

# Parse environment variables from file if provided
ENV_JSON="[]"
if [ -n "$ENV_FILE" ]; then
    if [ ! -f "$ENV_FILE" ]; then
        error "Environment file not found: $ENV_FILE"
        exit 1
    fi

    info "Loading environment variables from $ENV_FILE..."

    # Parse .env file and convert to JSON array
    ENV_JSON=$(grep -v '^#' "$ENV_FILE" | grep -v '^[[:space:]]*$' | awk -F= '{
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", $1);
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", $2);
        printf "{\"name\":\"%s\",\"value\":\"%s\"},", $1, $2
    }' | sed 's/,$//' | awk 'BEGIN{printf "["} {printf "%s", $0} END{printf "]"}')

    ENV_COUNT=$(echo "$ENV_JSON" | jq 'length')
    success "Loaded $ENV_COUNT environment variables"
fi

info "Creating Git-based stack: $STACK_NAME"
info "Repository: $MONOREPO_URL"
info "Compose path: $COMPOSE_PATH"
info "GitOps interval: $GITOPS_INTERVAL"

# Build API payload
PAYLOAD=$(cat <<EOF
{
  "name": "$STACK_NAME",
  "repositoryURL": "$MONOREPO_URL",
  "repositoryReferenceName": "",
  "composeFile": "$COMPOSE_PATH",
  "repositoryAuthentication": false,
  "env": $ENV_JSON,
  "autoUpdate": {
    "interval": "$GITOPS_INTERVAL"
  }
}
EOF
)

# Create the stack
RESPONSE=$(curl -sk -X POST \
    -H "X-API-Key: $API_TOKEN" \
    -H "Content-Type: application/json" \
    "$PORTAINER_URL/api/stacks/create/standalone/repository?endpointId=$ENDPOINT_ID" \
    -d "$PAYLOAD" 2>&1)

if [ $? -ne 0 ]; then
    error "Failed to create stack"
    echo "$RESPONSE" >&2
    exit 3
fi

# Check for API error
if echo "$RESPONSE" | jq -e '.message' > /dev/null 2>&1; then
    ERROR_MSG=$(echo "$RESPONSE" | jq -r '.message')
    error "Portainer API error: $ERROR_MSG"
    exit 3
fi

# Verify success
STACK_ID=$(echo "$RESPONSE" | jq -r '.Id')
STACK_STATUS=$(echo "$RESPONSE" | jq -r '.Status')
GIT_URL=$(echo "$RESPONSE" | jq -r '.GitConfig.URL')
INTERVAL=$(echo "$RESPONSE" | jq -r '.AutoUpdate.Interval')

echo ""
success "Stack created successfully!"
success "Stack ID: $STACK_ID"
success "Name: $STACK_NAME"
success "Repository: $GIT_URL"
success "Status: $([ "$STACK_STATUS" -eq 1 ] && echo "Active" || echo "Inactive")"
success "GitOps interval: $INTERVAL"

exit 0
