#!/bin/bash
#
# deploy-with-secrets.sh - Deploy a service with secrets from Vaultwarden
#
# This script demonstrates how to retrieve secrets from Vaultwarden and deploy
# a service to a remote VM. It uses the Bitwarden CLI with API key authentication
# for semi-automated deployments.
#
# Prerequisites:
# - Bitwarden CLI installed (brew install bitwarden-cli)
# - BW_CLIENTID and BW_CLIENTSECRET set in environment (~/.zshrc)
# - SSH access to target VM
# - Vaultwarden configured: bw config server http://192.168.86.249:8111
#
# Usage:
#   ./deploy-with-secrets.sh <service-name> <vm-ip> <stack-path>
#
# Example:
#   ./deploy-with-secrets.sh emby 192.168.86.172 /home/evan/projects/infinity-node/stacks/emby

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

log_success() {
    echo -e "${GREEN}✓${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

log_error() {
    echo -e "${RED}✗${NC} $1"
}

# Check if required arguments are provided
if [ $# -lt 3 ]; then
    log_error "Usage: $0 <service-name> <vm-ip> <stack-path>"
    log_info "Example: $0 emby 192.168.86.172 /home/evan/projects/infinity-node/stacks/emby"
    exit 1
fi

SERVICE_NAME="$1"
VM_IP="$2"
STACK_PATH="$3"

log_info "Deploying ${SERVICE_NAME} to ${VM_IP}"

# ============================================================================
# 1. Verify Prerequisites
# ============================================================================

log_info "Checking prerequisites..."

# Check if bw is installed
if ! command -v bw &> /dev/null; then
    log_error "Bitwarden CLI not found. Install with: brew install bitwarden-cli"
    exit 1
fi

# Check if API key credentials are set
if [ -z "${BW_CLIENTID:-}" ] || [ -z "${BW_CLIENTSECRET:-}" ]; then
    log_error "BW_CLIENTID and BW_CLIENTSECRET must be set in environment"
    log_info "Add to ~/.zshrc:"
    log_info "  export BW_CLIENTID=\"your_client_id\""
    log_info "  export BW_CLIENTSECRET=\"your_client_secret\""
    exit 1
fi

# Check if Vaultwarden server is configured
BW_SERVER=$(bw config server 2>/dev/null || echo "")
if [ "$BW_SERVER" != "http://192.168.86.249:8111" ]; then
    log_warning "Vaultwarden server not configured correctly"
    log_info "Configuring now..."
    bw config server http://192.168.86.249:8111
    log_success "Vaultwarden server configured"
fi

log_success "Prerequisites verified"

# ============================================================================
# 2. Authenticate with Vaultwarden
# ============================================================================

log_info "Authenticating with Vaultwarden..."

# Check current status
BW_STATUS=$(bw status | jq -r '.status')

# Login with API key if not authenticated
if [ "$BW_STATUS" == "unauthenticated" ]; then
    log_info "Logging in with API key..."
    bw login --apikey
    BW_STATUS=$(bw status | jq -r '.status')
    log_success "Logged in successfully"
fi

# Unlock vault if locked
if [ "$BW_STATUS" == "locked" ]; then
    log_warning "Vault is locked. You will be prompted for your master password."
    export BW_SESSION=$(bw unlock --raw)
    log_success "Vault unlocked"
elif [ "$BW_STATUS" == "unlocked" ]; then
    log_success "Vault already unlocked"
    # Export existing session if available
    if [ -n "${BW_SESSION:-}" ]; then
        export BW_SESSION
    fi
else
    log_error "Unexpected vault status: $BW_STATUS"
    exit 1
fi

# Sync to ensure we have latest data
log_info "Syncing vault..."
bw sync > /dev/null
log_success "Vault synced"

# ============================================================================
# 3. Retrieve Secrets from Vaultwarden
# ============================================================================

log_info "Retrieving secrets for ${SERVICE_NAME}..."

# Example: Retrieve secrets based on service name
# You'll need to customize this based on your actual secret names

# Try to retrieve a test secret (customize as needed)
# SECRET_NAME="${SERVICE_NAME}-api-key"

# Example retrievals (commented out - customize for your service):
# API_KEY=$(bw get password "${SERVICE_NAME}-api-key" 2>/dev/null || echo "")
# DB_PASSWORD=$(bw get password "${SERVICE_NAME}-db-password" 2>/dev/null || echo "")
# ADMIN_TOKEN=$(bw get password "${SERVICE_NAME}-admin-token" 2>/dev/null || echo "")

# For demonstration, let's just list available secrets for the service
log_info "Available secrets matching '${SERVICE_NAME}':"
bw list items --search "${SERVICE_NAME}" | jq -r '.[] | "  - \(.name)"'

# TODO: Add your actual secret retrieval here
# For now, we'll just show how it would work:

log_warning "This is a template script. You need to customize secret retrieval for your service."
log_info "Example: API_KEY=\$(bw get password \"${SERVICE_NAME}-api-key\")"

# Uncomment and customize these lines for your actual secrets:
# if [ -z "$API_KEY" ]; then
#     log_error "Failed to retrieve ${SERVICE_NAME}-api-key"
#     exit 1
# fi
# log_success "Retrieved secrets for ${SERVICE_NAME}"

# ============================================================================
# 4. Create .env File on Remote VM
# ============================================================================

log_info "Creating .env file on ${VM_IP}..."

# SSH to VM and create .env file
# Uncomment and customize this section for your actual deployment:

# ssh evan@${VM_IP} "cat > ${STACK_PATH}/.env" <<EOF
# # Auto-generated by deploy-with-secrets.sh
# # Generated: $(date -u +"%Y-%m-%d %H:%M:%S UTC")
#
# # Service: ${SERVICE_NAME}
# # Secrets retrieved from Vaultwarden
#
# API_KEY=${API_KEY}
# DB_PASSWORD=${DB_PASSWORD}
# ADMIN_TOKEN=${ADMIN_TOKEN}
#
# # Add other environment variables here
# EOF

log_warning "Skipping .env creation (template script)"
log_info "In production, secrets would be written to: ${STACK_PATH}/.env"

# ============================================================================
# 5. Deploy Stack
# ============================================================================

log_info "Deploying ${SERVICE_NAME} stack..."

# Deploy the stack using docker compose
# Uncomment for actual deployment:

# ssh evan@${VM_IP} "cd ${STACK_PATH} && docker compose up -d"
# if [ $? -eq 0 ]; then
#     log_success "${SERVICE_NAME} deployed successfully!"
# else
#     log_error "Deployment failed"
#     exit 1
# fi

log_warning "Skipping actual deployment (template script)"
log_info "In production, would run: ssh evan@${VM_IP} 'cd ${STACK_PATH} && docker compose up -d'"

# ============================================================================
# 6. Verify Deployment
# ============================================================================

log_info "Verifying deployment..."

# Check if container is running
# Uncomment for actual verification:

# CONTAINER_STATUS=$(ssh evan@${VM_IP} "docker ps --filter name=${SERVICE_NAME} --format '{{.Status}}'" || echo "")
# if [ -n "$CONTAINER_STATUS" ]; then
#     log_success "Container is running: ${CONTAINER_STATUS}"
# else
#     log_error "Container not found or not running"
#     exit 1
# fi

log_warning "Skipping deployment verification (template script)"

# ============================================================================
# 7. Cleanup
# ============================================================================

# Lock vault when done (optional, for security)
# Uncomment if you want to lock after deployment:
# bw lock
# log_info "Vault locked"

# ============================================================================
# Summary
# ============================================================================

echo ""
log_success "==================================================="
log_success "Deployment Script Completed (Template Mode)"
log_success "==================================================="
echo ""
log_info "Service: ${SERVICE_NAME}"
log_info "Target VM: ${VM_IP}"
log_info "Stack Path: ${STACK_PATH}"
echo ""
log_warning "This is a template script. To use in production:"
log_info "1. Customize secret retrieval (section 3)"
log_info "2. Uncomment .env creation (section 4)"
log_info "3. Uncomment deployment commands (section 5)"
log_info "4. Uncomment verification (section 6)"
echo ""
log_info "Documentation: docs/SECRET-MANAGEMENT.md"
echo ""

# ============================================================================
# Example Usage for Specific Services
# ============================================================================

# Emby Example:
# ----------------------------
# EMBY_API_KEY=$(bw get password "emby-api-key")
# ssh evan@192.168.86.172 "cat > /home/evan/projects/infinity-node/stacks/emby/.env" <<EOF
# EMBY_API_KEY=${EMBY_API_KEY}
# EOF

# Radarr Example:
# ----------------------------
# RADARR_API_KEY=$(bw get password "radarr-api-key")
# RADARR_DB_PASSWORD=$(bw get password "radarr-db-password")
# ssh evan@192.168.86.174 "cat > /home/evan/projects/infinity-node/stacks/radarr/.env" <<EOF
# RADARR_API_KEY=${RADARR_API_KEY}
# RADARR_DB_PASSWORD=${RADARR_DB_PASSWORD}
# EOF

# NordVPN Example:
# ----------------------------
# NORDVPN_USER=$(bw get item "nordvpn-credentials" | jq -r '.login.username')
# NORDVPN_PASS=$(bw get password "nordvpn-credentials")
# ssh evan@192.168.86.173 "cat > /home/evan/projects/infinity-node/stacks/nordvpn/.env" <<EOF
# NORDVPN_USER=${NORDVPN_USER}
# NORDVPN_PASS=${NORDVPN_PASS}
# EOF
