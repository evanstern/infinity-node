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
#   ./create-git-stack.sh <portainer-secret-name> <collection-name> <endpoint-id> <stack-name> <compose-path> [--env KEY=VALUE ...] [--env-file path]
#
# Arguments:
#   portainer-secret-name: Name of Portainer API token secret in Vaultwarden
#   collection-name: Vaultwarden collection containing the secret
#   endpoint-id: Portainer endpoint ID (usually 3 for local)
#   stack-name: Name for the new stack (e.g., "homepage", "watchtower")
#   compose-path: Path to compose file in repo (e.g., "stacks/homepage/docker-compose.yml")
#   --env KEY=VALUE: (Optional, repeatable) Environment variable to inject
#   --env-file path: (Optional) Path to .env file with environment variables (legacy positional arg still supported)
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
escape_json() { printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g'; }

# Validate arguments
if [ $# -lt 5 ]; then
    error "Missing required arguments"
    echo "Usage: $0 <portainer-secret-name> <collection-name> <endpoint-id> <stack-name> <compose-path> [--env KEY=VALUE ...] [--env-file path]" >&2
    echo "" >&2
    echo "Examples:" >&2
    echo "  $0 \"portainer-api-token-vm-103\" \"shared\" 3 \"homepage\" \"stacks/homepage/docker-compose.yml\" --env-file stacks/homepage/.env.example" >&2
    echo "  $0 \"portainer-api-token-vm-103\" \"shared\" 3 \"fail2ban-vm100\" \"stacks/fail2ban/docker-compose.yml\" --env TRAEFIK_LOG_PATH=/home/evan/logs/traefik --env EMBY_LOG_PATH=/home/evan/projects/infinity-node/stacks/emby/config/logs" >&2
    exit 1
fi

SECRET_NAME="$1"
COLLECTION_NAME="$2"
ENDPOINT_ID="$3"
STACK_NAME="$4"
COMPOSE_PATH="$5"
shift 5

ENV_FILE=""
LEGACY_ENV_FILE_SET=false
ENV_INLINE=()

while [ $# -gt 0 ]; do
    case "$1" in
        --env-file)
            if [ $# -lt 2 ]; then
                error "Missing path for --env-file"
                exit 1
            fi
            ENV_FILE="$2"
            shift 2
            ;;
        --env)
            if [ $# -lt 2 ]; then
                error "Missing KEY=VALUE for --env"
                exit 1
            fi
            ENV_INLINE+=("$2")
            shift 2
            ;;
        *)
            if ! $LEGACY_ENV_FILE_SET; then
                ENV_FILE="$1"
                LEGACY_ENV_FILE_SET=true
                shift 1
            else
                error "Unknown argument: $1"
                exit 1
            fi
            ;;
    esac
done

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

# Parse environment variables from file / inline args
ENV_LINES=()
if [ -n "$ENV_FILE" ]; then
    if [ ! -f "$ENV_FILE" ]; then
        error "Environment file not found: $ENV_FILE"
        exit 1
    fi
    info "Loading environment variables from $ENV_FILE..."
    while IFS= read -r line || [ -n "$line" ]; do
        ENV_LINES+=("$line")
    done < "$ENV_FILE"
fi

if [ ${#ENV_INLINE[@]} -gt 0 ]; then
    info "Loading ${#ENV_INLINE[@]} inline environment variable(s)..."
    for pair in "${ENV_INLINE[@]}"; do
        ENV_LINES+=("$pair")
    done
fi

ENV_JSON="[]"
if [ ${#ENV_LINES[@]} -gt 0 ]; then
    JSON_ENTRIES=""
    for line in "${ENV_LINES[@]}"; do
        trimmed=$(echo "$line" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
        case "$trimmed" in
            ""|\#*) continue ;;
        esac
        if [[ "$trimmed" != *=* ]]; then
            warn "Skipping invalid env entry (missing =): $trimmed"
            continue
        fi
        KEY=${trimmed%%=*}
        VALUE=${trimmed#*=}
        KEY=$(echo "$KEY" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
        VALUE=$(echo "$VALUE" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
        if [ -z "$KEY" ]; then
            warn "Skipping env entry with empty key"
            continue
        fi
        JSON_ENTRIES+="{\"name\":\"$(escape_json "$KEY")\",\"value\":\"$(escape_json "$VALUE")\"},"
    done
    if [ -n "$JSON_ENTRIES" ]; then
        ENV_JSON="[${JSON_ENTRIES%,}]"
        ENV_COUNT=$(echo "$ENV_JSON" | jq 'length')
        success "Loaded $ENV_COUNT environment variable(s)"
    else
        warn "No valid environment variables were parsed"
    fi
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

# Defensive handling for Portainer non-JSON/bogus HTTP error responses
# Sometimes Portainer returns a raw error page or non-JSON content. Detect and fail gracefully.
if ! echo "$RESPONSE" | jq '.' >/dev/null 2>&1; then
    # Not valid JSON: likely an HTTP error page or raw message
    # Try to extract HTTP status or message, else print whole response
    ERROR_SUMMARY=$(echo "$RESPONSE" | head -n 1 | cut -c -200)
    error "Unexpected non-API error from Portainer (not JSON): $ERROR_SUMMARY"
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
