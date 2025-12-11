#!/bin/bash
#
# query-portainer-stacks.sh
#
# Purpose: Query Portainer stacks from a VM
#
# This script queries the Portainer API to list all stacks deployed on a VM.
# Supports two modes: direct (provide token/URL) or Vaultwarden (retrieve from VW).
#
# Usage:
#   # Direct mode (provide token and URL)
#   ./query-portainer-stacks.sh --token "ptr_xxx" --url "http://vm-100.local.infinity-node.win:9000" [--json]
#
#   # Vaultwarden mode (retrieve from VW)
#   ./query-portainer-stacks.sh --secret "portainer-api-token-vm-100" --collection "shared" [--json]
#
# Examples:
#   # Direct mode
#   ./query-portainer-stacks.sh --token "ptr_ABC123" --url "http://vm-100.local.infinity-node.win:9000"
#
#   # Vaultwarden mode
#   ./query-portainer-stacks.sh --secret "portainer-api-token-vm-100" --collection "shared"
#
#   # JSON output
#   ./query-portainer-stacks.sh --secret "portainer-api-token-vm-103" --collection "shared" --json
#
# Requirements:
#   - curl installed
#   - jq installed
#   - For Vaultwarden mode: get-vw-secret.sh script and BW_SESSION set
#
# Exit Codes:
#   0 - Success
#   1 - Missing prerequisites or invalid arguments
#   2 - Vaultwarden retrieval failed
#   3 - Portainer API request failed

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
error() { echo -e "${RED}ERROR: $1${NC}" >&2; }
success() { echo -e "${GREEN}✓ $1${NC}"; }
info() { echo -e "${BLUE}→ $1${NC}"; }
warn() { echo -e "${YELLOW}⚠ $1${NC}"; }

# Parse arguments
MODE=""
API_TOKEN=""
PORTAINER_URL=""
SECRET_NAME=""
COLLECTION_NAME=""
JSON_OUTPUT=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --token)
            MODE="direct"
            API_TOKEN="$2"
            shift 2
            ;;
        --url)
            PORTAINER_URL="$2"
            shift 2
            ;;
        --secret)
            MODE="vaultwarden"
            SECRET_NAME="$2"
            shift 2
            ;;
        --collection)
            COLLECTION_NAME="$2"
            shift 2
            ;;
        --json)
            JSON_OUTPUT=true
            shift
            ;;
        *)
            error "Unknown argument: $1"
            exit 1
            ;;
    esac
done

# Validate mode
if [ -z "$MODE" ]; then
    error "Must specify either --token/--url (direct mode) or --secret/--collection (Vaultwarden mode)"
    echo "" >&2
    echo "Usage:" >&2
    echo "  Direct mode:      $0 --token TOKEN --url URL [--json]" >&2
    echo "  Vaultwarden mode: $0 --secret SECRET_NAME --collection COLLECTION_NAME [--json]" >&2
    exit 1
fi

# Validate arguments based on mode
if [ "$MODE" = "direct" ]; then
    if [ -z "$API_TOKEN" ] || [ -z "$PORTAINER_URL" ]; then
        error "Direct mode requires both --token and --url"
        exit 1
    fi
elif [ "$MODE" = "vaultwarden" ]; then
    if [ -z "$SECRET_NAME" ] || [ -z "$COLLECTION_NAME" ]; then
        error "Vaultwarden mode requires both --secret and --collection"
        exit 1
    fi
fi

# Check prerequisites
if ! command -v jq &> /dev/null; then
    error "jq not found. Install with: brew install jq"
    exit 1
fi

if ! command -v curl &> /dev/null; then
    error "curl not found"
    exit 1
fi

# Vaultwarden mode: retrieve credentials
if [ "$MODE" = "vaultwarden" ]; then
    # Check for get-vw-secret.sh script
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    GET_SECRET_SCRIPT="$SCRIPT_DIR/../secrets/get-vw-secret.sh"

    if [ ! -f "$GET_SECRET_SCRIPT" ]; then
        error "get-vw-secret.sh not found at: $GET_SECRET_SCRIPT"
        exit 1
    fi

    if [ "$JSON_OUTPUT" = false ]; then
        info "Retrieving credentials from Vaultwarden..."
    fi

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

    if [ "$JSON_OUTPUT" = false ]; then
        success "Retrieved credentials from Vaultwarden"
    fi
fi

# Query Portainer API
if [ "$JSON_OUTPUT" = false ]; then
    info "Querying Portainer at $PORTAINER_URL..."
fi

STACKS=$(curl -sk -H "X-API-Key: $API_TOKEN" "$PORTAINER_URL/api/stacks" 2>/dev/null)

if [ $? -ne 0 ] || [ -z "$STACKS" ]; then
    error "Failed to query Portainer API at $PORTAINER_URL"
    exit 3
fi

# Check for API error
if echo "$STACKS" | jq -e '.message' > /dev/null 2>&1; then
    ERROR_MSG=$(echo "$STACKS" | jq -r '.message')
    error "Portainer API error: $ERROR_MSG"
    exit 3
fi

# Output results
if [ "$JSON_OUTPUT" = true ]; then
    # JSON output - raw stack data
    echo "$STACKS" | jq '.'
else
    # Human-readable output
    success "Successfully queried Portainer"
    echo ""

    STACK_COUNT=$(echo "$STACKS" | jq 'length')

    if [ "$STACK_COUNT" -eq 0 ]; then
        warn "No stacks found"
        exit 0
    fi

    echo -e "${GREEN}Found $STACK_COUNT stack(s):${NC}"
    echo ""

    # Display each stack
    echo "$STACKS" | jq -r '.[] |
        "  \(.Name) (ID: \(.Id))" +
        "\n    Type: \(if .Type == 2 then "Docker Compose" elif .Type == 1 then "Swarm" else "Unknown" end)" +
        "\n    Status: \(if .Status == 1 then "Active" elif .Status == 2 then "Inactive" else "Unknown" end)" +
        (if .GitConfig then
            "\n    Git: \(.GitConfig.URL)" +
            "\n    Branch: \(.GitConfig.ReferenceName)" +
            "\n    Path: \(.GitConfig.ConfigFilePath)" +
            "\n    Auto-update: \(if .AutoUpdate then "Enabled (\(.AutoUpdate.Interval))" else "Disabled" end)"
        else
            "\n    Git: Not configured"
        end) +
        "\n"'
fi

exit 0
