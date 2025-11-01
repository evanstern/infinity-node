#!/usr/bin/env bash
#
# update-stack-env.sh
#
# Purpose: Update environment variables on a Portainer Git-based stack
#
# This script fetches the current stack configuration, updates specific environment
# variables, and sends the complete updated configuration back to Portainer.
#
# Usage:
#   ./update-stack-env.sh <portainer-secret-name> <collection-name> <stack-id> <endpoint-id> --env "KEY=VALUE" [OPTIONS]
#
# Arguments:
#   portainer-secret-name: Name of Portainer API token secret in Vaultwarden
#   collection-name: Vaultwarden collection containing the secret
#   stack-id: Portainer stack ID (number)
#   endpoint-id: Portainer endpoint ID (usually 3 for local)
#   --env "KEY=VALUE": Environment variable to update (can be specified multiple times)
#
# Options:
#   --dry-run: Show what would be changed without applying
#
# Examples:
#   # Update single environment variable
#   ./update-stack-env.sh "portainer-api-token-vm-102" "shared" 5 3 \
#     --env "TV_PATH=/mnt/video/Video/TV"
#
#   # Update multiple variables
#   ./update-stack-env.sh "portainer-api-token-vm-102" "shared" 5 3 \
#     --env "TV_PATH=/mnt/video/Video/TV" \
#     --env "MEMORY_LIMIT=4G"
#
#   # Dry-run to preview changes
#   ./update-stack-env.sh "portainer-api-token-vm-102" "shared" 5 3 \
#     --env "TV_PATH=/mnt/video/Video/TV" \
#     --dry-run
#
# Requirements:
#   - get-vw-secret.sh script
#   - BW_SESSION set: export BW_SESSION=$(cat ~/.bw-session)
#   - curl, jq installed
#   - Stack must be Git-based
#
# Exit Codes:
#   0 - Success
#   1 - Invalid arguments or prerequisites
#   2 - Failed to retrieve credentials
#   3 - API request failed
#   4 - Environment variable not found in stack
#
# Notes:
#   - Only updates EXISTING environment variables (no creation)
#   - Portainer API requires sending ALL env vars, script handles this automatically
#   - Shows diff of changes before applying
#   - Changes are saved to Portainer but require manual stack restart to take effect
#

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

# Parse arguments
if [ $# -lt 5 ]; then
    error "Missing required arguments"
    echo "Usage: $0 <portainer-secret-name> <collection-name> <stack-id> <endpoint-id> --env \"KEY=VALUE\" [OPTIONS]" >&2
    echo "" >&2
    echo "Examples:" >&2
    echo "  $0 \"portainer-api-token-vm-102\" \"shared\" 5 3 --env \"TV_PATH=/mnt/video/Video/TV\"" >&2
    echo "  $0 \"portainer-api-token-vm-102\" \"shared\" 5 3 --env \"TV_PATH=/mnt/video/Video/TV\" --redeploy" >&2
    exit 1
fi

SECRET_NAME="$1"
COLLECTION_NAME="$2"
STACK_ID="$3"
ENDPOINT_ID="$4"
shift 4

# Parse options (bash 3.2 compatible - use parallel arrays)
ENV_KEYS=()
ENV_VALUES=()
DRY_RUN=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --env)
            if [ -z "${2:-}" ]; then
                error "--env requires a value in KEY=VALUE format"
                exit 1
            fi
            # Parse KEY=VALUE
            if [[ ! "$2" =~ ^[A-Z_][A-Z0-9_]*=.*$ ]]; then
                error "Invalid env format: $2 (expected KEY=VALUE)"
                exit 1
            fi
            KEY="${2%%=*}"
            VALUE="${2#*=}"
            ENV_KEYS+=("$KEY")
            ENV_VALUES+=("$VALUE")
            shift 2
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        *)
            error "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Validate at least one env update specified
if [ ${#ENV_KEYS[@]} -eq 0 ]; then
    error "At least one --env update must be specified"
    exit 1
fi

# Check for required tools
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
if ! API_TOKEN=$("$GET_SECRET_SCRIPT" "$SECRET_NAME" "$COLLECTION_NAME" "password" 2>/dev/null); then
    error "Failed to retrieve API token from Vaultwarden"
    exit 2
fi

# Get Portainer URL
if ! PORTAINER_URL=$("$GET_SECRET_SCRIPT" "$SECRET_NAME" "$COLLECTION_NAME" "url" 2>/dev/null); then
    error "Failed to retrieve Portainer URL from Vaultwarden"
    exit 2
fi

success "Retrieved credentials"

# Fetch current stack configuration
info "Fetching current stack configuration..."

CURRENT_STACK=$(curl -sk -X GET \
    -H "X-API-Key: $API_TOKEN" \
    "$PORTAINER_URL/api/stacks/$STACK_ID" 2>/dev/null)

if [ $? -ne 0 ]; then
    error "Failed to fetch stack configuration"
    exit 3
fi

# Check for API error
if echo "$CURRENT_STACK" | jq -e '.message' > /dev/null 2>&1; then
    ERROR_MSG=$(echo "$CURRENT_STACK" | jq -r '.message')
    error "Portainer API error: $ERROR_MSG"
    exit 3
fi

STACK_NAME=$(echo "$CURRENT_STACK" | jq -r '.Name')
CURRENT_ENV=$(echo "$CURRENT_STACK" | jq -r '.Env // []')

success "Fetched stack '$STACK_NAME' configuration"

# Validate stack is Git-based
if ! echo "$CURRENT_STACK" | jq -e '.GitConfig' > /dev/null 2>&1; then
    error "Stack '$STACK_NAME' is not Git-based. This script only works with Git stacks."
    exit 3
fi

# Display current environment variables
info "Current environment variables:"
echo "$CURRENT_ENV" | jq -r '.[] | "  \(.name) = \(.value)"'
echo ""

# Build updated environment array
info "Applying updates..."

UPDATED_ENV="$CURRENT_ENV"

# Process each env update (using parallel arrays - bash 3.2 compatible)
for i in "${!ENV_KEYS[@]}"; do
    KEY="${ENV_KEYS[$i]}"
    VALUE="${ENV_VALUES[$i]}"

    # Check if variable exists
    CURRENT_VALUE=$(echo "$CURRENT_ENV" | jq -r --arg key "$KEY" '.[] | select(.name==$key) | .value')

    if [ -z "$CURRENT_VALUE" ]; then
        error "Environment variable '$KEY' not found in stack. This script only updates existing variables."
        exit 4
    fi

    # Show change
    if [ "$CURRENT_VALUE" = "$VALUE" ]; then
        warn "$KEY: No change (already set to '$VALUE')"
    else
        info "$KEY: '$CURRENT_VALUE' → '$VALUE'"
    fi

    # Update the value in the array
    UPDATED_ENV=$(echo "$UPDATED_ENV" | jq --arg key "$KEY" --arg val "$VALUE" \
        'map(if .name == $key then .value = $val else . end)')
done

echo ""

# Show final environment for verification
info "Updated environment variables:"
echo "$UPDATED_ENV" | jq -r '.[] | "  \(.name) = \(.value)"'
echo ""

# Dry-run exit
if [ "$DRY_RUN" = true ]; then
    warn "Dry-run mode: No changes applied"
    exit 0
fi

# Get Git configuration for update
REPO_URL=$(echo "$CURRENT_STACK" | jq -r '.GitConfig.URL')
REPO_REF=$(echo "$CURRENT_STACK" | jq -r '.GitConfig.ReferenceName // ""')
COMPOSE_PATH=$(echo "$CURRENT_STACK" | jq -r '.EntryPoint')
REPO_AUTH=$(echo "$CURRENT_STACK" | jq -r '.GitConfig.Authentication // false')

info "Updating stack configuration in Portainer..."

# Get AutoUpdate settings to preserve them
AUTO_UPDATE_INTERVAL=$(echo "$CURRENT_STACK" | jq -r '.AutoUpdate.Interval // "5m"')

# Build update payload (using POST endpoint like enable-gitops-updates.sh)
UPDATE_PAYLOAD=$(jq -n \
    --arg interval "$AUTO_UPDATE_INTERVAL" \
    --arg repo_ref "$REPO_REF" \
    --argjson repo_auth "$REPO_AUTH" \
    --argjson env "$UPDATED_ENV" \
    '{
        "AutoUpdate": {
            "Interval": $interval,
            "Webhook": "",
            "ForceUpdate": false,
            "ForcePullImage": false
        },
        "Env": $env,
        "RepositoryReferenceName": $repo_ref,
        "RepositoryAuthentication": $repo_auth,
        "RepositoryUsername": "",
        "RepositoryPassword": "",
        "Prune": false,
        "TLSSkipVerify": false
    }')

# Update stack (POST to /git with endpointId query param)
UPDATE_RESPONSE=$(curl -sk -X POST \
    -H "X-API-Key: $API_TOKEN" \
    -H "Content-Type: application/json" \
    "$PORTAINER_URL/api/stacks/$STACK_ID/git?endpointId=$ENDPOINT_ID" \
    -d "$UPDATE_PAYLOAD" 2>/dev/null)

if [ $? -ne 0 ]; then
    error "Failed to update stack configuration"
    exit 3
fi

# Check for API error
if echo "$UPDATE_RESPONSE" | jq -e '.message' > /dev/null 2>&1; then
    ERROR_MSG=$(echo "$UPDATE_RESPONSE" | jq -r '.message')
    error "Portainer API error: $ERROR_MSG"
    echo "Full response:" >&2
    echo "$UPDATE_RESPONSE" | jq '.' >&2
    exit 3
fi

success "Stack configuration updated successfully"
info "Configuration saved to Portainer"
warn "Changes will NOT take effect until stack is restarted"
info "Please restart the stack via Portainer UI to apply changes"

echo ""
success "Environment variable update complete!"

exit 0
