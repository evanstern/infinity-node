#!/bin/bash
#
# Configure Passwordless Sudo for Evan User
#
# This script configures the 'evan' user to use sudo without a password.
# This is necessary for automation and remote script execution.
#
# Usage:
#   sudo ./setup-evan-nopasswd-sudo.sh
#
# Security Considerations:
#   - Only use on trusted systems (your VMs)
#   - Evan user already has full system access via sudo
#   - This just removes the password requirement
#   - For automation purposes only
#
# Related:
#   - tasks/current/create-inspector-user.md - Requires sudo access
#   - tasks/backlog/create-vm-template.md - Should include this config
#

set -e  # Exit on error

# Colors
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly NC='\033[0m'

# Configuration
readonly USERNAME="evan"
readonly SUDOERS_FILE="/etc/sudoers.d/$USERNAME"

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run with sudo"
   echo "Usage: sudo $0"
   exit 1
fi

log_info "Configuring passwordless sudo for user '$USERNAME'..."

# Create sudoers.d entry
echo "$USERNAME ALL=(ALL) NOPASSWD: ALL" > "$SUDOERS_FILE"

# Set correct permissions (must be 0440)
chmod 0440 "$SUDOERS_FILE"

# Validate sudoers file
if visudo -c -f "$SUDOERS_FILE" &> /dev/null; then
    log_info "Sudoers configuration validated successfully"
else
    log_warn "Sudoers validation failed - removing file"
    rm "$SUDOERS_FILE"
    exit 1
fi

log_info "Passwordless sudo configured for '$USERNAME'"
log_info "File created: $SUDOERS_FILE"

# Test configuration
if sudo -u "$USERNAME" sudo -n true 2>/dev/null; then
    log_info "✓ Configuration test successful"
else
    log_warn "Configuration test failed - may need to logout and login"
fi

cat << EOF

${GREEN}✓ Setup complete${NC}

Configuration:
  User:     $USERNAME
  File:     $SUDOERS_FILE
  Contents: $USERNAME ALL=(ALL) NOPASSWD: ALL

This allows '$USERNAME' to run any command with sudo without a password.

EOF
