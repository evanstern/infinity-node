---
type: task
task-id: IN-019
status: pending
priority: 6
category: automation
agent: infrastructure
created: 2025-10-26
updated: 2025-10-26
tags:
  - task
  - automation
  - synology
  - infrastructure
---

# Task: IN-019 - Automate Synology User Management via SSH

<!-- Priority Scale: 0 (critical/urgent) → 1-2 (high) → 3-4 (medium) → 5-6 (low) → 7-9 (very low) -->

## Description

Automate creation and management of users on Synology NAS via SSH/CLI, eliminating the need for manual web UI interaction. This will enable scripted user provisioning for backup users, service accounts, and other automated access needs.

## Context

**Discovery:** During IN-017 backup setup, attempted to create a `backup` user on Synology NAS via SSH but encountered challenges with `expect`/`sudo` automation. Currently requires manual user creation via DSM web UI.

**Current State:**
- User creation must be done via web UI (http://192.168.86.43:5000)
- SSH access to NAS works with `evan` user (administrators group)
- Synology uses `synouser` command for user management
- `sudo` over SSH with expect scripts proved difficult

**Goal:**
- Scriptable user creation, modification, and deletion
- Set permissions and SSH key auth programmatically
- Part of broader VM/infrastructure automation strategy

## Acceptance Criteria

### Phase 1: Research
- [ ] Research Synology DSM API options (REST API, CLI tools)
- [ ] Evaluate `synouser` command capabilities and limitations
- [ ] Test sudo password handling approaches (`-S` flag, askpass helpers)
- [ ] Investigate if Synology has native automation tools
- [ ] Document recommended approach

### Phase 2: User Creation Script
- [ ] Create `scripts/synology/create-user.sh`
  - Takes username, description, groups as parameters
  - Handles password generation/storage
  - Sets up home directory and permissions
  - Enables SSH access
  - Returns success/failure status
- [ ] Test script on non-critical user first

### Phase 3: SSH Key Management
- [ ] Create `scripts/synology/add-ssh-key.sh`
  - Takes username and public key as parameters
  - Creates `.ssh/authorized_keys` if needed
  - Sets correct permissions (700 for .ssh, 600 for authorized_keys)
  - Validates key format

### Phase 4: Permission Management
- [ ] Create `scripts/synology/set-folder-permissions.sh`
  - Takes username, folder path, permissions as parameters
  - Grants access to specified shared folders
  - Sets read/write/execute permissions

### Phase 5: User Deletion
- [ ] Create `scripts/synology/delete-user.sh`
  - Takes username as parameter
  - Removes user from system
  - Optionally archives user's files
  - Safety checks (confirm deletion, prevent deleting admin users)

## Dependencies

- SSH access to Synology NAS (192.168.86.43)
- Admin credentials in Vaultwarden (`synology-credentials`)
- Understanding of `synouser` command
- Possibly: Synology DSM API documentation

## Implementation Approaches

### Option 1: Fix expect/sudo Automation
**Approach:** Get expect scripts working reliably with sudo over SSH
```bash
# Use -S flag to read password from stdin
echo 'password' | sudo -S synouser --add username "desc" "" 0
```
**Pros:** Uses native tools, no additional dependencies
**Cons:** Fragile, security concerns with password in command

### Option 2: Synology DSM API
**Approach:** Use Synology's REST API for user management
**Research needed:** Does API support user creation? Authentication?
**Pros:** Designed for automation, more robust
**Cons:** May require additional auth setup, learning curve

### Option 3: Ansible/Salt/Chef
**Approach:** Use configuration management tool
**Pros:** Industry standard, well-tested
**Cons:** Overkill for single NAS, additional complexity

### Option 4: SSH Key + sudo NOPASSWD
**Approach:** Configure `evan` user with NOPASSWD sudo for specific commands
```
evan ALL=(ALL) NOPASSWD: /usr/syno/sbin/synouser
```
**Pros:** Secure, scriptable, no password passing
**Cons:** Requires one-time manual sudoers configuration

**Recommended:** Option 4 (NOPASSWD sudo for specific commands) - secure and scriptable

## Testing Plan

[[docs/agents/TESTING|Testing Agent]] should validate:

**User Creation:**
- [ ] User created successfully
- [ ] User can login via SSH
- [ ] User has correct group memberships
- [ ] Home directory created with correct permissions

**SSH Key Auth:**
- [ ] Public key added to authorized_keys
- [ ] Passwordless SSH login works
- [ ] Correct permissions on .ssh directory

**Permissions:**
- [ ] User can access intended shared folders
- [ ] User cannot access restricted folders
- [ ] Read/write permissions work as expected

**Deletion:**
- [ ] User removed from system
- [ ] User cannot login after deletion
- [ ] Safety checks prevent accidental admin deletion

## Related Documentation

- [[docs/agents/INFRASTRUCTURE|Infrastructure Agent]]
- [[tasks/completed/IN-017-implement-vaultwarden-backup|IN-017]] - Where this issue was discovered
- [[docs/VM-CONFIGURATION|VM Configuration]] - VM automation context

## Notes

### Current Manual Process

For reference, manual user creation via DSM web UI:
1. Access http://192.168.86.43:5000
2. Control Panel → User & Group → Create
3. Set username, password, description
4. Assign groups
5. Set shared folder permissions
6. SSH keys: Must be added via file system access

### Commands Tested

```bash
# User creation (requires sudo)
synouser --add username "description" "" 0

# Add to group
synouser --setpw username password  # Set password

# SSH key setup
mkdir -p /var/services/homes/username/.ssh
echo "ssh-key-here" > /var/services/homes/username/.ssh/authorized_keys
chmod 700 /var/services/homes/username/.ssh
chmod 600 /var/services/homes/username/.ssh/authorized_keys
chown username:users /var/services/homes/username/.ssh -R
```

### Sudo Configuration for Automation

If going with Option 4, add to `/etc/sudoers` (via `visudo`):
```
# Allow evan to run user management commands without password
evan ALL=(ALL) NOPASSWD: /usr/syno/sbin/synouser
evan ALL=(ALL) NOPASSWD: /bin/mkdir -p /var/services/homes/*/\.ssh
evan ALL=(ALL) NOPASSWD: /bin/chmod
evan ALL=(ALL) NOPASSWD: /bin/chown
```

Test with:
```bash
ssh evan@192.168.86.43 "sudo synouser --help"
```

---

**Priority Rationale:** Low priority (6) because:
- Manual process works (not blocking)
- Only affects initial setup (infrequent operation)
- Nice-to-have automation, not critical path
- Can be implemented when building broader automation framework
