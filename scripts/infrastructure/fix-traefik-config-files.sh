#!/bin/bash
#
# fix-traefik-config-files.sh
#
# Purpose: Fix Traefik config files that Portainer incorrectly clones as directories
#
# Portainer's Git clone sometimes creates traefik.yml and dynamic.yml as directories
# instead of files. This script fixes that by replacing directories with the correct files.
#
# Usage:
#   ./fix-traefik-config-files.sh <vm-ip> [stack-id]
#
# Arguments:
#   vm-ip: IP address of the VM (e.g., 192.168.1.101)
#   stack-id: Optional Portainer stack ID. If not provided, will find Traefik stack automatically
#
# Examples:
#   ./fix-traefik-config-files.sh 192.168.1.101
#   ./fix-traefik-config-files.sh 192.168.1.103 53
#
# What it does:
#   1. Finds Traefik stack directory in Portainer's compose directory
#   2. Checks if traefik.yml and dynamic.yml are directories
#   3. Replaces them with correct files from git repository
#   4. Restarts Traefik stack via Portainer API (if credentials available)
#
# Requirements:
#   - SSH access to VM
#   - sudo access on VM
#   - git installed on VM (for cloning fresh copy)
#
# Exit Codes:
#   0 - Success
#   1 - Invalid arguments
#   2 - Could not find Traefik stack
#   3 - Failed to fix files

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
if [ $# -lt 1 ]; then
    error "Missing required arguments"
    echo "Usage: $0 <vm-ip> [stack-id]" >&2
    echo "" >&2
    echo "Examples:" >&2
    echo "  $0 192.168.1.101" >&2
    echo "  $0 192.168.1.103 53" >&2
    exit 1
fi

VM_IP="$1"
STACK_ID="${2:-}"

MONOREPO_URL="https://github.com/evanstern/infinity-node"

info "Connecting to VM $VM_IP..."

# Find Traefik stack directory
if [ -z "$STACK_ID" ]; then
    info "Finding Traefik stack..."
    # Try to find stack directory by searching compose directories
    STACK_DIR=$(ssh evan@$VM_IP "find /data/compose -type d -path '*/stacks/traefik/vm-*' 2>/dev/null | head -1" || echo "")
    if [ -z "$STACK_DIR" ]; then
        # Try finding by container name
        STACK_DIR=$(ssh evan@$VM_IP "docker inspect traefik 2>/dev/null | jq -r '.[0].Mounts[] | select(.Destination | contains(\"traefik\")) | .Source' | head -1 | xargs dirname 2>/dev/null || echo ''" || echo "")
    fi
    if [ -z "$STACK_DIR" ]; then
        # Try to get stack ID from Portainer API
        SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
        GET_SECRET_SCRIPT="$SCRIPT_DIR/../secrets/get-vw-secret.sh"
        if [ -f "$GET_SECRET_SCRIPT" ] && [ -f ~/.bw-session ]; then
            export BW_SESSION=$(cat ~/.bw-session)
            SECRET_NAME="portainer-api-token-vm-$VM_NUM"
            if TOKEN=$("$GET_SECRET_SCRIPT" "$SECRET_NAME" "shared" 2>/dev/null) && \
               URL=$("$GET_SECRET_SCRIPT" "$SECRET_NAME" "shared" "url" 2>/dev/null); then
                STACK_ID=$(curl -sk -H "X-API-Key: $TOKEN" "$URL/api/stacks" 2>/dev/null | jq -r ".[] | select(.Name == \"traefik\") | .Id" 2>/dev/null | head -1 || echo "")
                if [ -n "$STACK_ID" ] && [ "$STACK_ID" != "null" ]; then
                    STACK_DIR="/data/compose/$STACK_ID/stacks/traefik"
                fi
            fi
        fi
    fi
else
    STACK_DIR="/data/compose/$STACK_ID/stacks/traefik"
fi

if [ -z "$STACK_DIR" ]; then
    error "Could not find Traefik stack directory"
    error "Stack may not exist yet. Create the stack first, then run this script."
    exit 2
fi

info "Found stack directory: $STACK_DIR"

# Determine VM number from stack path or directory structure
VM_NUM=$(echo "$STACK_DIR" | grep -oE 'vm-[0-9]+' | grep -oE '[0-9]+' || echo "")
if [ -z "$VM_NUM" ]; then
    # Try to infer from IP
    case "$VM_IP" in
        192.168.1.100) VM_NUM="100" ;;
        192.168.1.101) VM_NUM="101" ;;
        192.168.1.102) VM_NUM="102" ;;
        192.168.1.103) VM_NUM="103" ;;
        *) error "Could not determine VM number"; exit 2 ;;
    esac
fi

CONFIG_DIR="$STACK_DIR/vm-$VM_NUM"
info "Config directory: $CONFIG_DIR"

# Check if files are directories
info "Checking config files..."
TRAEFIK_YML_TYPE=$(ssh evan@$VM_IP "file $CONFIG_DIR/traefik.yml 2>/dev/null | grep -oE '(directory|ASCII text)' || echo 'missing'")
DYNAMIC_YML_TYPE=$(ssh evan@$VM_IP "file $CONFIG_DIR/dynamic.yml 2>/dev/null | grep -oE '(directory|ASCII text)' || echo 'missing'")

# Also check if docker-compose.yml exists
DOCKER_COMPOSE_EXISTS=$(ssh evan@$VM_IP "[ -f \"$STACK_DIR/vm-$VM_NUM/docker-compose.yml\" ] && echo 'yes' || echo 'no'")

if [[ "$TRAEFIK_YML_TYPE" == "ASCII text" && "$DYNAMIC_YML_TYPE" == "ASCII text" && "$DOCKER_COMPOSE_EXISTS" == "yes" ]]; then
    success "Config files are already correct"
    exit 0
fi

if [[ "$TRAEFIK_YML_TYPE" == "missing" || "$DYNAMIC_YML_TYPE" == "missing" ]]; then
    warn "Some config files are missing"
fi

info "Fixing config files..."

# Clone fresh copy and copy files
ssh evan@$VM_IP "sudo rm -rf /tmp/infinity-node-fresh && \
cd /tmp && \
git clone --depth 1 $MONOREPO_URL infinity-node-fresh 2>&1 | tail -2 && \
sudo rm -rf $CONFIG_DIR/traefik.yml $CONFIG_DIR/dynamic.yml && \
sudo cp infinity-node-fresh/stacks/traefik/vm-$VM_NUM/traefik.yml $CONFIG_DIR/traefik.yml && \
sudo cp infinity-node-fresh/stacks/traefik/vm-$VM_NUM/dynamic.yml $CONFIG_DIR/dynamic.yml && \
sudo cp infinity-node-fresh/stacks/traefik/vm-$VM_NUM/docker-compose.yml $STACK_DIR/vm-$VM_NUM/docker-compose.yml && \
sudo chmod 644 $CONFIG_DIR/*.yml $STACK_DIR/vm-$VM_NUM/docker-compose.yml && \
rm -rf infinity-node-fresh && \
echo 'Files fixed'"

# Verify files are correct
TRAEFIK_YML_TYPE=$(ssh evan@$VM_IP "file $CONFIG_DIR/traefik.yml 2>/dev/null | grep -oE '(directory|ASCII text)' || echo 'missing'")
DYNAMIC_YML_TYPE=$(ssh evan@$VM_IP "file $CONFIG_DIR/dynamic.yml 2>/dev/null | grep -oE '(directory|ASCII text)' || echo 'missing'")

if [[ "$TRAEFIK_YML_TYPE" == "ASCII text" && "$DYNAMIC_YML_TYPE" == "ASCII text" ]]; then
    success "Config files fixed successfully"

    # Try to restart Traefik stack if Portainer credentials are available
    info "Restarting Traefik stack..."
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    GET_SECRET_SCRIPT="$SCRIPT_DIR/../secrets/get-vw-secret.sh"

    if [ -f "$GET_SECRET_SCRIPT" ] && [ -f ~/.bw-session ]; then
        export BW_SESSION=$(cat ~/.bw-session)
        SECRET_NAME="portainer-api-token-vm-$VM_NUM"

        if TOKEN=$("$GET_SECRET_SCRIPT" "$SECRET_NAME" "shared" 2>/dev/null) && \
           URL=$("$GET_SECRET_SCRIPT" "$SECRET_NAME" "shared" "url" 2>/dev/null); then
            if [ -z "$STACK_ID" ]; then
                STACK_ID=$(curl -sk -H "X-API-Key: $TOKEN" "$URL/api/stacks" 2>/dev/null | jq -r ".[] | select(.Name == \"traefik\") | .Id" || echo "")
            fi

            if [ -n "$STACK_ID" ]; then
                curl -sk -X POST -H "X-API-Key: $TOKEN" "$URL/api/stacks/$STACK_ID/stop?endpointId=3" >/dev/null 2>&1
                sleep 2
                curl -sk -X POST -H "X-API-Key: $TOKEN" "$URL/api/stacks/$STACK_ID/start?endpointId=3" >/dev/null 2>&1
                success "Traefik stack restarted"
            else
                warn "Could not find Traefik stack ID, please restart manually"
            fi
        else
            warn "Could not retrieve Portainer credentials, please restart Traefik manually"
        fi
    else
        warn "Portainer credentials not available, please restart Traefik manually:"
        echo "  ssh evan@$VM_IP 'docker restart traefik'"
    fi

    exit 0
else
    error "Failed to fix config files"
    echo "traefik.yml: $TRAEFIK_YML_TYPE"
    echo "dynamic.yml: $DYNAMIC_YML_TYPE"
    exit 3
fi
