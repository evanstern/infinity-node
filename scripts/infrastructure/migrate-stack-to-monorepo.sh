#!/bin/bash
#
# migrate-stack-to-monorepo.sh
#
# Purpose: Migrate a Portainer stack to use the infinity-node monorepo
#
# This script configures (or reconfigures) a Portainer stack to use the
# monorepo at https://github.com/evanstern/infinity-node with GitOps enabled.
#
# Usage:
#   ./migrate-stack-to-monorepo.sh <portainer-secret-name> <collection-name> <stack-id> <endpoint-id> <service-name> [branch]
#
# Arguments:
#   portainer-secret-name: Name of Portainer API token secret in Vaultwarden
#   collection-name: Vaultwarden collection containing the secret
#   stack-id: Portainer stack ID (number)
#   endpoint-id: Portainer endpoint ID (usually 3 for local)
#   service-name: Service directory name in stacks/ (e.g., "watchtower", "homepage")
#   branch: (Optional) Git branch (default: "main")
#
# Examples:
#   # Migrate watchtower stack to monorepo
#   ./migrate-stack-to-monorepo.sh "portainer-api-token-vm-103" "shared" 9 3 "watchtower"
#
#   # Migrate homepage with custom branch
#   ./migrate-stack-to-monorepo.sh "portainer-api-token-vm-103" "shared" 3 3 "homepage" "main"
#
# What it does:
#   1. Configures Git repository to: https://github.com/evanstern/infinity-node
#   2. Sets compose path to: stacks/<service-name>/docker-compose.yml
#   3. Enables GitOps updates with 5-minute polling interval
#   4. Preserves existing environment variables
#
# Requirements:
#   - get-vw-secret.sh and query-portainer-stacks.sh scripts
#   - BW_SESSION set: export BW_SESSION=$(cat ~/.bw-session)
#   - curl, jq installed
#   - Stack must exist in Portainer
#   - Monorepo must have stacks/<service-name>/docker-compose.yml
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
    echo "Usage: $0 <portainer-secret-name> <collection-name> <stack-id> <endpoint-id> <service-name> [branch]" >&2
    echo "" >&2
    echo "Examples:" >&2
    echo "  $0 \"portainer-api-token-vm-103\" \"shared\" 9 3 \"watchtower\"" >&2
    echo "  $0 \"portainer-api-token-vm-103\" \"shared\" 3 3 \"homepage\" \"main\"" >&2
    exit 1
fi

SECRET_NAME="$1"
COLLECTION_NAME="$2"
STACK_ID="$3"
ENDPOINT_ID="$4"
SERVICE_NAME="$5"
BRANCH="${6:-main}"

# Monorepo configuration
MONOREPO_URL="https://github.com/evanstern/infinity-node"
COMPOSE_PATH="stacks/$SERVICE_NAME/docker-compose.yml"
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

info "Fetching current stack configuration..."

# Get current stack details
CURRENT_STACK=$(curl -sk -H "X-API-Key: $API_TOKEN" "$PORTAINER_URL/api/stacks/$STACK_ID" 2>/dev/null)

if [ $? -ne 0 ]; then
    error "Failed to fetch stack details"
    exit 3
fi

# Check for API error
if echo "$CURRENT_STACK" | jq -e '.message' > /dev/null 2>&1; then
    ERROR_MSG=$(echo "$CURRENT_STACK" | jq -r '.message')
    error "Portainer API error: $ERROR_MSG"
    exit 3
fi

STACK_NAME=$(echo "$CURRENT_STACK" | jq -r '.Name')
CURRENT_GIT=$(echo "$CURRENT_STACK" | jq -r '.GitConfig.URL // "Not configured"')
CURRENT_ENV=$(echo "$CURRENT_STACK" | jq -c '.Env // []')

info "Stack: $STACK_NAME (ID: $STACK_ID)"
info "Current Git: $CURRENT_GIT"
info "Target: $MONOREPO_URL"
info "Compose path: $COMPOSE_PATH"
info "Branch: $BRANCH"
info "GitOps interval: $GITOPS_INTERVAL"

# Confirm migration
if [ "$CURRENT_GIT" != "Not configured" ] && [ "$CURRENT_GIT" != "null" ]; then
    warn "This stack already has Git configured"
    warn "Current repo: $CURRENT_GIT"
    warn "Will change to: $MONOREPO_URL"
fi

echo ""
info "Migrating stack to monorepo..."

# API payload for Git configuration
PAYLOAD=$(cat <<EOF
{
  "AutoUpdate": {
    "Interval": "$GITOPS_INTERVAL",
    "Webhook": "",
    "ForceUpdate": false,
    "ForcePullImage": false
  },
  "Env": $CURRENT_ENV,
  "RepositoryURL": "$MONOREPO_URL",
  "RepositoryReferenceName": "$BRANCH",
  "FilePathInRepository": "$COMPOSE_PATH",
  "RepositoryAuthentication": false,
  "RepositoryUsername": "",
  "RepositoryPassword": "",
  "Prune": false,
  "TLSSkipVerify": false
}
EOF
)

# Configure Git repository
RESPONSE=$(curl -sk -X POST \
    -H "X-API-Key: $API_TOKEN" \
    -H "Content-Type: application/json" \
    "$PORTAINER_URL/api/stacks/$STACK_ID/git?endpointId=$ENDPOINT_ID" \
    -d "$PAYLOAD" 2>&1)

if [ $? -ne 0 ]; then
    error "Failed to configure Git repository"
    echo "$RESPONSE" >&2
    exit 3
fi

# Check for API error
if echo "$RESPONSE" | jq -e '.message' > /dev/null 2>&1; then
    ERROR_MSG=$(echo "$RESPONSE" | jq -r '.message')
    error "Portainer API error: $ERROR_MSG"
    echo "" >&2
    error "This might mean the compose file doesn't exist at: $COMPOSE_PATH" >&2
    error "Verify the monorepo has: stacks/$SERVICE_NAME/docker-compose.yml" >&2
    exit 3
fi

# Verify success
NEW_GIT=$(echo "$RESPONSE" | jq -r '.GitConfig.URL')
NEW_PATH=$(echo "$RESPONSE" | jq -r '.GitConfig.ConfigFilePath')
NEW_INTERVAL=$(echo "$RESPONSE" | jq -r '.AutoUpdate.Interval')

echo ""
success "Migration successful!"
success "Repository: $NEW_GIT"
success "Compose path: $NEW_PATH"
success "Branch: $BRANCH"
success "GitOps interval: $NEW_INTERVAL"
echo ""
info "Stack will automatically check for updates every $NEW_INTERVAL"

exit 0
