#!/bin/bash
#
# verify-stack-health.sh
#
# Purpose: Verify all containers in a Portainer stack are healthy
#
# This script checks that all containers in a stack have started successfully
# and are reporting healthy status (if health checks are configured).
#
# Usage:
#   ./verify-stack-health.sh <portainer-secret-name> <collection-name> <stack-name> <endpoint-id> [timeout]
#
# Arguments:
#   portainer-secret-name: Name of Portainer API token secret in Vaultwarden
#   collection-name: Vaultwarden collection containing the secret
#   stack-name: Name of the stack to check
#   endpoint-id: Portainer endpoint ID (usually 3 for local)
#   timeout: (Optional) Maximum wait time in seconds (default: 120)
#
# Examples:
#   # Verify homepage stack is healthy
#   ./verify-stack-health.sh "portainer-api-token-vm-103" "shared" "homepage" 3
#
#   # Verify with custom 5 minute timeout
#   ./verify-stack-health.sh "portainer-api-token-vm-103" "shared" "paperless-ngx" 3 300
#
# Exit Codes:
#   0 - All containers healthy
#   1 - Invalid arguments or prerequisites
#   2 - Failed to retrieve credentials
#   3 - Containers failed to start or unhealthy
#   4 - Timeout reached

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
    echo "Usage: $0 <portainer-secret-name> <collection-name> <stack-name> <endpoint-id> [timeout]" >&2
    exit 1
fi

SECRET_NAME="$1"
COLLECTION_NAME="$2"
STACK_NAME="$3"
ENDPOINT_ID="$4"
TIMEOUT="${5:-120}"

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

info "Verifying stack: $STACK_NAME"
info "Timeout: ${TIMEOUT}s"

START_TIME=$(date +%s)
CHECK_INTERVAL=5
ALL_HEALTHY=false

while true; do
    CURRENT_TIME=$(date +%s)
    ELAPSED=$((CURRENT_TIME - START_TIME))

    if [ $ELAPSED -ge $TIMEOUT ]; then
        error "Timeout reached after ${TIMEOUT}s"
        exit 4
    fi

    # Get all containers for this stack
    CONTAINERS=$(curl -sk -H "X-API-Key: $API_TOKEN" \
        "$PORTAINER_URL/api/endpoints/$ENDPOINT_ID/docker/containers/json?all=true" 2>/dev/null)

    if [ $? -ne 0 ]; then
        error "Failed to query containers"
        exit 3
    fi

    # Filter containers by stack name (compose project label)
    STACK_CONTAINERS=$(echo "$CONTAINERS" | jq --arg stack "$STACK_NAME" \
        '[.[] | select(.Labels."com.docker.compose.project" == $stack)]')

    CONTAINER_COUNT=$(echo "$STACK_CONTAINERS" | jq 'length')

    if [ "$CONTAINER_COUNT" -eq 0 ]; then
        warn "No containers found for stack $STACK_NAME"
        sleep $CHECK_INTERVAL
        continue
    fi

    info "Found $CONTAINER_COUNT containers (${ELAPSED}s elapsed)"

    # Check each container
    RUNNING_COUNT=0
    HEALTHY_COUNT=0
    UNHEALTHY_COUNT=0
    STARTING_COUNT=0
    FAILED_CONTAINERS=""

    while IFS= read -r container; do
        NAME=$(echo "$container" | jq -r '.Names[0]')
        STATE=$(echo "$container" | jq -r '.State')
        STATUS=$(echo "$container" | jq -r '.Status')

        if [ "$STATE" != "running" ]; then
            FAILED_CONTAINERS="$FAILED_CONTAINERS\n  $NAME: $STATE ($STATUS)"
            continue
        fi

        ((RUNNING_COUNT++))

        # Check health status if available
        if echo "$STATUS" | grep -q "health:"; then
            if echo "$STATUS" | grep -q "(healthy)"; then
                ((HEALTHY_COUNT++))
                info "  $NAME: healthy"
            elif echo "$STATUS" | grep -q "(unhealthy)"; then
                ((UNHEALTHY_COUNT++))
                warn "  $NAME: unhealthy"
                FAILED_CONTAINERS="$FAILED_CONTAINERS\n  $NAME: unhealthy"
            elif echo "$STATUS" | grep -q "(starting)"; then
                ((STARTING_COUNT++))
                info "  $NAME: starting..."
            fi
        else
            # No health check, just verify running
            ((HEALTHY_COUNT++))
            info "  $NAME: running (no health check)"
        fi
    done < <(echo "$STACK_CONTAINERS" | jq -c '.[]')

    # Check if all containers are healthy
    if [ $RUNNING_COUNT -eq $CONTAINER_COUNT ] && [ $UNHEALTHY_COUNT -eq 0 ] && [ $STARTING_COUNT -eq 0 ]; then
        ALL_HEALTHY=true
        break
    fi

    if [ $UNHEALTHY_COUNT -gt 0 ]; then
        error "Some containers are unhealthy:"
        echo -e "$FAILED_CONTAINERS"
        exit 3
    fi

    if [ -n "$FAILED_CONTAINERS" ]; then
        error "Some containers failed to start:"
        echo -e "$FAILED_CONTAINERS"
        exit 3
    fi

    info "Waiting for containers to be ready... ($STARTING_COUNT still starting)"
    sleep $CHECK_INTERVAL
done

echo ""
success "All $CONTAINER_COUNT containers are healthy!"
success "Stack $STACK_NAME is ready"

exit 0
