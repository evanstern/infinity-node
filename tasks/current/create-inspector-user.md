---
type: task
status: pending
priority: high
category: security
agent: security
created: 2025-10-24
updated: 2025-10-24
tags:
  - task
  - security
  - testing
  - ssh
---

# Task: Create Read-Only Inspector User for Testing Agent

## Description

Create a dedicated read-only user account (`inspector`) on all VMs to be used by the [[docs/agents/TESTING|Testing Agent]]. This enforces the Testing Agent's read-only, advisory-only role through system-level permissions.

## Context

The Testing Agent should never be able to modify production systems. Currently, it uses the `evan` user which has full permissions. This is a security risk and violates the agent's design principles.

A dedicated `inspector` user with read-only permissions ensures Testing Agent cannot accidentally (or intentionally) modify system state.

## Acceptance Criteria

### Create Reusable Script
- [ ] Create `scripts/setup-inspector-user.sh`
- [ ] Make script idempotent (safe to re-run)
- [ ] Add usage documentation in script
- [ ] Test script on one VM first

### Deploy to Existing VMs
- [ ] Run script on VM 100 (emby)
- [ ] Run script on VM 101 (downloads)
- [ ] Run script on VM 102 (arr)
- [ ] Run script on VM 103 (misc)

### Validation
- [ ] Verify inspector can run read-only docker commands
- [ ] Verify inspector CANNOT run write commands
- [ ] Test SSH access as inspector from local machine
- [ ] Verify no sudo access for inspector

### Documentation
- [ ] Update [[docs/agents/TESTING|Testing Agent]] documentation
- [ ] Document inspector user in [[docs/ARCHITECTURE|Architecture]]
- [ ] Update [[docs/CLAUDE|CLAUDE.md]] with SSH access info
- [ ] Document script usage for future VMs

## Dependencies

- SSH access to all VMs as evan (current user)
- Understanding of Linux user permissions
- Docker group permissions

## Testing Plan

[[docs/agents/TESTING|Testing Agent]] itself should validate:

**Can do (should succeed):**
- `docker ps`
- `docker inspect <container>`
- `docker logs <container>`
- `cat /path/to/file`
- `ls`, `grep`, `find`
- `systemctl status`

**Cannot do (should fail):**
- `docker stop <container>`
- `docker restart <container>`
- `sudo <anything>`
- Edit any files
- `systemctl start/stop/restart`

## Related Documentation

- [[docs/agents/TESTING|Testing Agent]]
- [[docs/agents/SECURITY|Security Agent]]
- [[docs/ARCHITECTURE|Architecture]]
- [[create-vm-template]] - Script will be reused in VM template

## Notes

### Script Approach (Option 1)

**Benefits:**
- Reusable on future VMs
- Consistent setup across all VMs
- Can be integrated into VM template later
- Idempotent (safe to re-run)
- Documented and version controlled

**Script should:**
- Accept SSH public key as parameter or use default
- Check if user already exists (idempotent)
- Create user with proper settings
- Configure SSH access
- Add to docker group
- Set proper permissions
- Provide clear success/failure output

**Example script structure:**
```bash
#!/bin/bash
# Setup read-only inspector user for Testing Agent
# Usage: ./setup-inspector-user.sh [path-to-public-key]

set -e  # Exit on error

# Configuration
USERNAME="inspector"
PUBKEY_PATH="${1:-$HOME/.ssh/id_rsa.pub}"

# Check if user exists
if id "$USERNAME" &>/dev/null; then
    echo "User $USERNAME already exists"
    # Update anyway (idempotent)
else
    echo "Creating user $USERNAME"
    sudo useradd -m -s /bin/bash "$USERNAME"
fi

# Add to docker group
sudo usermod -aG docker "$USERNAME"

# Setup SSH
sudo mkdir -p /home/$USERNAME/.ssh
sudo cp "$PUBKEY_PATH" /home/$USERNAME/.ssh/authorized_keys
sudo chown -R $USERNAME:$USERNAME /home/$USERNAME/.ssh
sudo chmod 700 /home/$USERNAME/.ssh
sudo chmod 600 /home/$USERNAME/.ssh/authorized_keys

echo "✓ Inspector user setup complete"
```

### Testing Commands

**After setup, verify:**
```bash
# Should succeed (read-only operations)
ssh inspector@VM_IP "docker ps"
ssh inspector@VM_IP "docker logs container-name"
ssh inspector@VM_IP "cat /var/log/syslog | head"
ssh inspector@VM_IP "systemctl status docker"

# Should fail (write operations)
ssh inspector@VM_IP "docker restart container-name"  # Permission denied
ssh inspector@VM_IP "sudo ls"                         # sudo not allowed
ssh inspector@VM_IP "echo test > /tmp/file"          # Works (can write to /tmp)
ssh inspector@VM_IP "rm /etc/hosts"                  # Permission denied
```

### Future Reuse

This script will be:
1. Used immediately on existing VMs (100-103)
2. Integrated into [[create-vm-template]] task
3. Available for any new VMs
4. Reference for other user setup scripts
