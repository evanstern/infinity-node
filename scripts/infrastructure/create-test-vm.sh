#!/bin/bash
#
# create-test-vm.sh
#
# Purpose: Create a test VM in Proxmox for testing the Ansible template playbook
#
# This script automates VM creation using Ubuntu cloud images and cloud-init.
# Cloud images are pre-installed Ubuntu images that boot quickly (no installation needed).
#
# Usage:
#   ./create-test-vm.sh [OPTIONS] [VM_ID] [VM_NAME] [CORES] [RAM_MB] [DISK_GB]
#
# Options:
#   --yes, -y    Skip confirmation prompt (non-interactive mode)
#
# Examples:
#   ./create-test-vm.sh                           # Use defaults
#   ./create-test-vm.sh --yes                     # Use defaults, no prompt
#   ./create-test-vm.sh 900 test-template         # Custom ID and name
#   ./create-test-vm.sh --yes 900 test-template 2 4096 20  # Full customization, no prompt
#
# Requirements:
#   - Run from your local machine (not Proxmox host)
#   - SSH access to Proxmox host as root
#   - Proxmox host has internet access (to download cloud image)
#

set -e  # Exit on any error

# ============================================================================
# CONFIGURATION
# ============================================================================

# Proxmox host
PROXMOX_HOST="192.168.86.106"
PROXMOX_USER="root"

# Parse flags
SKIP_CONFIRM=false
if [[ "$1" == "--yes" ]] || [[ "$1" == "-y" ]]; then
    SKIP_CONFIRM=true
    shift  # Remove flag from arguments
fi

# VM defaults (can be overridden by arguments)
VM_ID="${1:-900}"
VM_NAME="${2:-test-template}"
VM_CORES="${3:-2}"
VM_RAM="${4:-4096}"  # MB
VM_DISK="${5:-20}"   # GB

# Network
BRIDGE="vmbr0"

# Ubuntu cloud image
UBUNTU_VERSION="24.04"
UBUNTU_CODENAME="noble"
IMAGE_URL="https://cloud-images.ubuntu.com/releases/${UBUNTU_VERSION}/release/ubuntu-${UBUNTU_VERSION}-server-cloudimg-amd64.img"
IMAGE_NAME="ubuntu-${UBUNTU_VERSION}-cloudimg-amd64.img"

# Storage
STORAGE="local-lvm"  # Default Proxmox storage

# Cloud-init settings
# You'll need to provide your SSH public key
SSH_KEY_FILE="${HOME}/.ssh/id_rsa.pub"

# ============================================================================
# FUNCTIONS
# ============================================================================

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*"
}

error() {
    echo "[ERROR] $*" >&2
    exit 1
}

check_prerequisites() {
    log "Checking prerequisites..."

    # Check SSH access to Proxmox
    if ! ssh -o ConnectTimeout=5 "${PROXMOX_USER}@${PROXMOX_HOST}" "echo 'SSH connection OK'" &>/dev/null; then
        error "Cannot SSH to Proxmox host ${PROXMOX_HOST}"
    fi

    # Check if VM ID already exists
    if ssh "${PROXMOX_USER}@${PROXMOX_HOST}" "qm status ${VM_ID}" &>/dev/null; then
        error "VM ID ${VM_ID} already exists on Proxmox host"
    fi

    # Check for SSH public key
    if [ ! -f "${SSH_KEY_FILE}" ]; then
        error "SSH public key not found at ${SSH_KEY_FILE}"
    fi

    log "Prerequisites OK"
}

display_config() {
    log "VM Configuration:"
    echo "  VM ID:         ${VM_ID}"
    echo "  VM Name:       ${VM_NAME}"
    echo "  CPU Cores:     ${VM_CORES}"
    echo "  RAM:           ${VM_RAM} MB"
    echo "  Disk:          ${VM_DISK} GB"
    echo "  Network:       ${BRIDGE}"
    echo "  Proxmox Host:  ${PROXMOX_HOST}"
    echo "  Ubuntu:        ${UBUNTU_VERSION} (${UBUNTU_CODENAME})"
    echo ""
}

download_cloud_image() {
    log "Checking for Ubuntu cloud image on Proxmox..."

    # Check if image already exists on Proxmox
    if ssh "${PROXMOX_USER}@${PROXMOX_HOST}" "[ -f /tmp/${IMAGE_NAME} ]"; then
        log "Cloud image already downloaded"
        return
    fi

    log "Downloading Ubuntu ${UBUNTU_VERSION} cloud image to Proxmox..."
    ssh "${PROXMOX_USER}@${PROXMOX_HOST}" \
        "wget -O /tmp/${IMAGE_NAME} ${IMAGE_URL}" || error "Failed to download cloud image"

    log "Cloud image downloaded successfully"
}

create_vm() {
    log "Creating VM ${VM_ID} (${VM_NAME})..."

    # Read SSH public key
    SSH_PUB_KEY=$(cat "${SSH_KEY_FILE}")

    # Create the VM on Proxmox
    ssh "${PROXMOX_USER}@${PROXMOX_HOST}" bash <<EOF
set -e

# Create VM
qm create ${VM_ID} \
    --name ${VM_NAME} \
    --cores ${VM_CORES} \
    --memory ${VM_RAM} \
    --net0 virtio,bridge=${BRIDGE}

# Import the cloud image as a disk
qm importdisk ${VM_ID} /tmp/${IMAGE_NAME} ${STORAGE}

# Attach the disk to the VM
qm set ${VM_ID} --scsihw virtio-scsi-pci --scsi0 ${STORAGE}:vm-${VM_ID}-disk-0

# Set boot disk
qm set ${VM_ID} --boot c --bootdisk scsi0

# Add cloud-init drive
qm set ${VM_ID} --ide2 ${STORAGE}:cloudinit

# Configure cloud-init
qm set ${VM_ID} --ciuser evan
qm set ${VM_ID} --sshkeys /dev/stdin <<< "${SSH_PUB_KEY}"
qm set ${VM_ID} --ipconfig0 ip=dhcp

# Set serial console (for cloud-init debugging)
qm set ${VM_ID} --serial0 socket --vga serial0

# Resize disk to requested size
qm resize ${VM_ID} scsi0 ${VM_DISK}G

echo "VM ${VM_ID} created successfully"
EOF

    log "VM created successfully"
}

start_vm() {
    log "Starting VM ${VM_ID}..."
    ssh "${PROXMOX_USER}@${PROXMOX_HOST}" "qm start ${VM_ID}"
    log "VM started"
}

wait_for_vm() {
    log "Waiting for VM to boot and cloud-init to complete..."
    log "This may take 1-2 minutes..."

    # Wait for VM to be running
    sleep 10

    log ""
    log "VM is booting. To check status:"
    log "  ssh ${PROXMOX_USER}@${PROXMOX_HOST} 'qm status ${VM_ID}'"
    log ""
    log "To find VM IP address:"
    log "  ssh ${PROXMOX_USER}@${PROXMOX_HOST} 'qm guest cmd ${VM_ID} network-get-interfaces'"
    log "  Or check your router's DHCP leases"
    log ""
    log "Once VM has an IP, you can SSH to it:"
    log "  ssh evan@<VM_IP>"
    log ""
}

# ============================================================================
# MAIN
# ============================================================================

main() {
    log "==================================================================="
    log "Proxmox Test VM Creator"
    log "==================================================================="
    echo ""

    display_config

    if [[ "$SKIP_CONFIRM" == "false" ]]; then
        read -p "Create VM with these settings? (y/n) " -n 1 -r
        echo ""
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log "Cancelled by user"
            exit 0
        fi
    else
        log "Skipping confirmation (--yes flag provided)"
    fi

    check_prerequisites
    download_cloud_image
    create_vm
    start_vm
    wait_for_vm

    log "==================================================================="
    log "VM Creation Complete!"
    log "==================================================================="
    log ""
    log "Next steps:"
    log "1. Wait ~2 minutes for cloud-init to complete"
    log "2. Find the VM's IP address (check Proxmox web UI or router)"
    log "3. Test SSH access: ssh evan@<VM_IP>"
    log "4. Add VM to ansible/inventory/proxmox-vms.yml"
    log "5. Run Ansible playbook against the VM"
    log ""
    log "VM ID: ${VM_ID}"
    log "VM Name: ${VM_NAME}"
    log ""
}

main "$@"
