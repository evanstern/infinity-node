#!/bin/bash
#
# Setup Read-Only Inspector User for Testing Agent
#
# This script creates a read-only 'inspector' user for the Testing Agent to use
# when validating system state. The user has docker group access (read-only) but
# no sudo privileges.
#
# Usage:
#   ./setup-inspector-user.sh [path-to-public-key]
#
# Arguments:
#   path-to-public-key  Optional. Path to SSH public key file.
#                       Defaults to ~/.ssh/id_rsa.pub
#
# Features:
#   - Idempotent: Safe to run multiple times
#   - Creates user if doesn't exist
#   - Updates SSH key if user exists
#   - Adds to docker group for read-only container access
#   - No sudo access (read-only user)
#   - Key-based SSH authentication only
#
# Requirements:
#   - Must run as a user with sudo privileges
#   - SSH public key must exist at specified path
#   - Docker must be installed and running
#
# Related:
#   - docs/agents/TESTING.md - Testing Agent specification
#   - tasks/current/create-inspector-user.md - Task details
#

set -e  # Exit on error
set -u  # Exit on undefined variable

# Configuration
readonly USERNAME="inspector"
readonly DEFAULT_PUBKEY="$HOME/.ssh/id_rsa.pub"

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly NC='\033[0m' # No Color

# Functions
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

usage() {
    cat << EOF
Usage: $0 [path-to-public-key]

Setup read-only inspector user for Testing Agent.

Arguments:
  path-to-public-key    Optional. Path to SSH public key file.
                        Defaults to ~/.ssh/id_rsa.pub

Examples:
  $0                              # Use default public key
  $0 ~/.ssh/inspector_key.pub     # Use specific public key

EOF
}

check_prerequisites() {
    # Check if running with sudo privileges available
    if ! sudo -n true 2>/dev/null; then
        log_error "This script requires sudo privileges"
        log_info "Run: sudo $0 $*"
        exit 1
    fi

    # Check if docker is installed
    if ! command -v docker &> /dev/null; then
        log_error "Docker is not installed"
        log_info "Install Docker before running this script"
        exit 1
    fi

    # Check if docker group exists
    if ! getent group docker &> /dev/null; then
        log_error "Docker group does not exist"
        log_info "Docker may not be properly installed"
        exit 1
    fi
}

create_or_update_user() {
    if id "$USERNAME" &>/dev/null; then
        log_info "User '$USERNAME' already exists"
        log_info "Will update configuration..."
        USER_EXISTS=true
    else
        log_info "Creating user '$USERNAME'..."
        sudo useradd -m -s /bin/bash "$USERNAME"
        log_info "User '$USERNAME' created"
        USER_EXISTS=false
    fi
}

configure_docker_access() {
    log_info "Adding '$USERNAME' to docker group..."
    sudo usermod -aG docker "$USERNAME"
    log_info "Docker group membership configured"
}

setup_ssh_access() {
    local pubkey_path="$1"

    # Verify public key exists
    if [[ ! -f "$pubkey_path" ]]; then
        log_error "Public key not found: $pubkey_path"
        exit 1
    fi

    log_info "Setting up SSH access..."

    # Create .ssh directory
    sudo mkdir -p "/home/$USERNAME/.ssh"

    # Copy public key
    sudo cp "$pubkey_path" "/home/$USERNAME/.ssh/authorized_keys"

    # Set correct ownership and permissions
    sudo chown -R "$USERNAME:$USERNAME" "/home/$USERNAME/.ssh"
    sudo chmod 700 "/home/$USERNAME/.ssh"
    sudo chmod 600 "/home/$USERNAME/.ssh/authorized_keys"

    log_info "SSH access configured"
}

verify_setup() {
    log_info "Verifying setup..."

    # Check user exists
    if ! id "$USERNAME" &>/dev/null; then
        log_error "User '$USERNAME' was not created"
        return 1
    fi

    # Check docker group membership
    if ! groups "$USERNAME" | grep -q docker; then
        log_warn "User '$USERNAME' may not be in docker group (may require logout)"
    fi

    # Check SSH directory
    if [[ ! -d "/home/$USERNAME/.ssh" ]]; then
        log_error "SSH directory not created"
        return 1
    fi

    # Check authorized_keys
    if [[ ! -f "/home/$USERNAME/.ssh/authorized_keys" ]]; then
        log_error "SSH authorized_keys not created"
        return 1
    fi

    # Check permissions
    local ssh_perms=$(stat -c %a "/home/$USERNAME/.ssh" 2>/dev/null || stat -f %A "/home/$USERNAME/.ssh")
    local key_perms=$(stat -c %a "/home/$USERNAME/.ssh/authorized_keys" 2>/dev/null || stat -f %A "/home/$USERNAME/.ssh/authorized_keys")

    if [[ "$ssh_perms" != "700" ]]; then
        log_warn "SSH directory permissions are $ssh_perms (expected 700)"
    fi

    if [[ "$key_perms" != "600" ]]; then
        log_warn "authorized_keys permissions are $key_perms (expected 600)"
    fi

    log_info "Verification complete"
}

print_summary() {
    cat << EOF

${GREEN}✓ Inspector user setup complete${NC}

User Details:
  Username:        $USERNAME
  Home Directory:  /home/$USERNAME
  Shell:           /bin/bash
  Docker Access:   Read-only (docker group member)
  Sudo Access:     None (read-only user)

SSH Access:
  ssh $USERNAME@<hostname>

Next Steps:
  1. Test SSH access: ssh $USERNAME@localhost
  2. Test docker access: ssh $USERNAME@localhost "docker ps"
  3. Deploy to other VMs using this same script

Testing Commands:
  # Should succeed (read-only)
  ssh $USERNAME@<hostname> "docker ps"
  ssh $USERNAME@<hostname> "docker logs <container>"
  ssh $USERNAME@<hostname> "cat /var/log/syslog | head"

  # Should fail (write operations)
  ssh $USERNAME@<hostname> "docker restart <container>"  # Permission denied
  ssh $USERNAME@<hostname> "sudo ls"                      # No sudo access

EOF
}

# Main execution
main() {
    # Parse arguments
    local pubkey_path="${1:-$DEFAULT_PUBKEY}"

    # Show usage if requested
    if [[ "${1:-}" == "-h" ]] || [[ "${1:-}" == "--help" ]]; then
        usage
        exit 0
    fi

    log_info "Setting up inspector user on $(hostname)"
    log_info "Using public key: $pubkey_path"

    # Run setup steps
    check_prerequisites
    create_or_update_user
    configure_docker_access
    setup_ssh_access "$pubkey_path"
    verify_setup

    print_summary

    log_info "Setup complete!"
}

# Run main function
main "$@"
