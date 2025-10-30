#!/bin/bash
#
# enable-gitops-updates.sh
#
# Purpose: Enable GitOps automatic updates on a Portainer stack
#
# This script enables GitOps updates on a stack that already has Git configured.
# It sets the polling interval to check for updates from the Git repository.
#
# Usage:
#   ./enable-gitops-updates.sh <portainer-secret-name> <collection-name> <stack-id> <endpoint-id> [interval]
#
# Arguments:
#   portainer-secret-name: Name of Portainer API token secret in Vaultwarden
#   collection-name: Vaultwarden collection containing the secret
#   stack-id: Portainer stack ID (number)
#   endpoint-id: Portainer endpoint ID (usually 3 for local)
#   interval: (Optional) Update check interval (default: 5m)
#             Examples: 5m, 10m, 1h, 12h
#
# Examples:
#   # Enable with default 5min interval
#   ./enable-gitops-updates.sh "portainer-api-token-vm-103" "shared" 9 3
#
#   # Enable with custom 10min interval
#   ./enable-gitops-updates.sh "portainer-api-token-vm-103" "shared" 9 3 "10m"
#
# Requirements:
#   - get-vw-secret.sh script
#   - BW_SESSION set: export BW_SESSION=$(cat ~/.bw-session)
#   - curl, jq installed
#   - Stack must already have Git configured
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
NC='\033[0m'

error() { echo -e "${RED}ERROR: $1${NC}" >&2; }
success() { echo -e "${GREEN}✓ $1${NC}"; }
info() { echo -e "${BLUE}→ $1${NC}"; }

# Validate arguments
if [ $# -lt 4 ]; then
    error "Missing required arguments"
    echo "Usage: $0 <portainer-secret-name> <collection-name> <stack-id> <endpoint-id> [interval]" >&2
    echo "" >&2
    echo "Examples:" >&2
    echo "  $0 \"portainer-api-token-vm-103\" \"shared\" 9 3" >&2
    echo "  $0 \"portainer-api-token-vm-103\" \"shared\" 9 3 \"10m\"" >&2
    exit 1
fi

SECRET_NAME="$1"
COLLECTION_NAME="$2"
STACK_ID="$3"
ENDPOINT_ID="$4"
INTERVAL="${5:-5m}"

# Check for get-vw-secret.sh
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

info "Enabling GitOps updates on stack $STACK_ID (interval: $INTERVAL)..."

# API payload for enabling GitOps updates
PAYLOAD=$(cat <<EOF
{
  "AutoUpdate": {
    "Interval": "$INTERVAL",
    "Webhook": "",
    "ForceUpdate": false,
    "ForcePullImage": false
  },
  "Env": [],
  "RepositoryReferenceName": "",
  "RepositoryAuthentication": false,
  "RepositoryUsername": "",
  "RepositoryPassword": "",
  "Prune": false,
  "TLSSkipVerify": false
}
EOF
)

# Enable GitOps
RESPONSE=$(curl -sk -X POST \
    -H "X-API-Key: $API_TOKEN" \
    -H "Content-Type: application/json" \
    "$PORTAINER_URL/api/stacks/$STACK_ID/git?endpointId=$ENDPOINT_ID" \
    -d "$PAYLOAD" 2>&1)

if [ $? -ne 0 ]; then
    error "Failed to enable GitOps updates"
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
STACK_NAME=$(echo "$RESPONSE" | jq -r '.Name')
ENABLED_INTERVAL=$(echo "$RESPONSE" | jq -r '.AutoUpdate.Interval')

if [ "$ENABLED_INTERVAL" = "$INTERVAL" ]; then
    success "GitOps updates enabled on stack '$STACK_NAME' (interval: $ENABLED_INTERVAL)"
    exit 0
else
    error "GitOps updates may not have been enabled correctly"
    echo "Expected interval: $INTERVAL" >&2
    echo "Actual interval: $ENABLED_INTERVAL" >&2
    exit 3
fi
