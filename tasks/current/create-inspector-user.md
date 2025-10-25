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

- [ ] Create `inspector` user on VM 100 (emby)
- [ ] Create `inspector` user on VM 101 (downloads)
- [ ] Create `inspector` user on VM 102 (arr)
- [ ] Create `inspector` user on VM 103 (misc)
- [ ] Add SSH public key to inspector's authorized_keys
- [ ] Grant read-only docker socket access (group membership)
- [ ] Verify inspector can run read-only docker commands
- [ ] Verify inspector CANNOT run write commands
- [ ] Update [[docs/agents/TESTING|Testing Agent]] documentation
- [ ] Test SSH access as inspector from local machine

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

## Notes

**User creation commands (per VM):**
```bash
# Create user
sudo useradd -m -s /bin/bash inspector

# Add to docker group (read-only socket access)
sudo usermod -aG docker inspector

# No sudo access
# No password (key-only auth)

# Copy SSH public key
sudo mkdir -p /home/inspector/.ssh
sudo cp ~/.ssh/authorized_keys /home/inspector/.ssh/
sudo chown -R inspector:inspector /home/inspector/.ssh
sudo chmod 700 /home/inspector/.ssh
sudo chmod 600 /home/inspector/.ssh/authorized_keys
```

**Post-creation:**
- Document inspector user in [[docs/ARCHITECTURE|Architecture]]
- Update [[docs/CLAUDE|CLAUDE.md]] with SSH access info
- Test from local machine
