---
type: documentation
tags:
  - scripts
  - automation
  - operational
---

# Infrastructure Automation Scripts

This directory contains operational automation scripts for managing the infinity-node infrastructure. Scripts are organized by function and designed to be composable building blocks for larger automation workflows.

## Philosophy

Per [[../docs/adr/012-script-based-operational-automation|ADR-012: Script-Based Operational Automation]], we maintain scripts for:
- ✅ **Reproducible operations** - Run the same way every time
- ✅ **Common tasks** - Operations performed multiple times
- ✅ **Validation & health checks** - Verify system state
- ✅ **Building blocks** - Compose into larger workflows
- ✅ **Runbook foundation** - Executable documentation

**Proven Value** (from [[../tasks/completed/IN-002-migrate-secrets-to-env|IN-002]]):
- `audit-secrets.sh` streamlined secret inventory across 19 stacks
- `create-secret.sh` enabled efficient Vaultwarden backup workflow
- Scripting approach reduced errors and made process repeatable
- Scripts serve as documentation of actual procedures used

**Continuous Improvement Approach:**

Watch for script opportunities **while working on tasks**:
- Running the same command multiple times? → Script candidate
- Complex command sequence? → Simplify with script
- Manual operation prone to errors? → Add error handling via script
- Useful validation pattern? → Extract for reuse

**Process:** Notice → Propose → Discuss → Create → Document → Use

**When to create a script:**
- Operation will be run multiple times
- Need consistent, reproducible execution
- Want to reduce human error
- Building toward larger automation
- **Pattern emerged during task work** (organic discovery)

**When NOT to create a script:**
- One-off tasks
- Trivial single commands
- Operations that change frequently
- Would be more complex than just running the command

## Directory Structure

```
scripts/
├── README.md                          # This file
├── secrets/                           # Secret management
│   ├── audit-secrets.sh              # Scan for hardcoded secrets
│   ├── create-secret.sh              # Store secret in Vaultwarden
│   ├── update-secret.sh              # Update existing secret
│   └── delete-secret.sh              # Remove secret from Vaultwarden
├── deployment/                        # Deployment automation
│   └── deploy-with-secrets.sh        # Deploy stack with secret injection
├── setup/                             # Initial setup scripts
│   ├── setup-evan-nopasswd-sudo.sh   # Configure evan user
│   └── setup-inspector-user.sh       # Create read-only testing user
├── infrastructure/                    # VM and infrastructure management
│   ├── create-test-vm.sh             # Automate Proxmox VM creation
│   ├── docker-cleanup.sh             # Clean unused Docker images
│   └── expand-vm-disk.sh             # Expand Proxmox VM disk
├── validation/                        # Health checks
│   └── check-vm-disk-space.sh        # Monitor VM disk usage
└── backup/                            # Backup operations
    └── backup-vaultwarden.sh         # Backup Vaultwarden to NAS
```

## Script Inventory

### Secret Management (`secrets/`)

#### `audit-secrets.sh`
**Purpose:** Scan all docker-compose files for secrets, identify hardcoded values
**Usage:** `./audit-secrets.sh [--verbose] [-o text|json|markdown]`
**Exit Codes:** 0 (clean), 1 (hardcoded secrets found), 2 (invalid args)

**Example:**
```bash
# Basic audit
./scripts/secrets/audit-secrets.sh

# Detailed output
./scripts/secrets/audit-secrets.sh --verbose

# Markdown report for documentation
./scripts/secrets/audit-secrets.sh -o markdown > docs/secret-audit-report.md
```

**Use Cases:**
- Pre-migration secret inventory (IN-002)
- Regular security audits
- Verify no secrets before git commit
- CI/CD secret scanning

#### `create-secret.sh`
**Purpose:** Create and store a secret in Vaultwarden
**Usage:** `./create-secret.sh <name> <value> <folder> [notes]`
**Dependencies:** Bitwarden CLI (`bw`), authenticated session

**Example:**
```bash
# Store an API key
./scripts/secrets/create-secret.sh \
  "radarr-api-key" \
  "abc123..." \
  "vm-102-arr" \
  "API key for Radarr media automation"
```

**Use Cases:**
- Migrating secrets to Vaultwarden
- Creating new service secrets
- Rotating existing credentials

#### `update-secret.sh`
**Purpose:** Update an existing secret in Vaultwarden
**Usage:** `./update-secret.sh <name> <new-value>`
**Dependencies:** Bitwarden CLI (`bw`), authenticated session

**Example:**
```bash
# Update API key after rotation
./scripts/secrets/update-secret.sh "radarr-api-key" "newkey456..."
```

**Use Cases:**
- Secret rotation
- Fixing incorrect values
- Post-compromise credential updates

#### `delete-secret.sh`
**Purpose:** Remove a secret from Vaultwarden
**Usage:** `./delete-secret.sh <name>`
**Dependencies:** Bitwarden CLI (`bw`), authenticated session

**Example:**
```bash
# Remove decommissioned service secret
./scripts/secrets/delete-secret.sh "old-service-password"
```

**Use Cases:**
- Cleanup after service removal
- Removing test/temporary secrets
- Housekeeping old credentials

### Deployment (`deployment/`)

#### `deploy-with-secrets.sh`
**Purpose:** Deploy a docker stack with automatic secret injection from Vaultwarden
**Usage:** `./deploy-with-secrets.sh <stack-name> <vm-ip>`
**Dependencies:** Bitwarden CLI, SSH access to VM

**Example:**
```bash
# Deploy radarr to VM 102
./scripts/deployment/deploy-with-secrets.sh radarr 192.168.86.174
```

**Use Cases:**
- Automated stack deployment
- CI/CD deployments
- Consistent secret injection
- Reducing manual steps

### Validation (`validation/`)

#### `check-vm-disk-space.sh`
**Purpose:** Monitor disk space across all infinity-node VMs
**Usage:** `./check-vm-disk-space.sh [--threshold PERCENT]`
**Exit Codes:** 0 (all VMs OK), 1 (warnings), 2 (critical)

**Example:**
```bash
# Check all VMs with default 80% warning threshold
./scripts/validation/check-vm-disk-space.sh

# Use custom threshold
./scripts/validation/check-vm-disk-space.sh --threshold 70
```

**Use Cases:**
- Proactive disk space monitoring
- Prevent service failures from full disks
- Identify VMs needing expansion
- Cron job for automated monitoring
- Pre-deployment capacity checks

**Features:**
- Checks all 4 VMs automatically via SSH
- Color-coded status (OK/WARNING/CRITICAL)
- Shows top disk consumers when above threshold
- Returns exit codes suitable for cron/monitoring integration

### Backup (`backup/`)

#### `backup-vaultwarden.sh`
**Purpose:** Automated Vaultwarden SQLite database backup to NAS via SCP
**Usage:** `./backup-vaultwarden.sh`
**Exit Codes:** 0 (success), 1 (source not found), 2 (backup failed), 3 (integrity check failed), 4 (NAS transfer failed), 5 (missing tools/credentials)
**Location:** Deployed to VM 103 at `/home/evan/scripts/backup-vaultwarden.sh`
**Dependencies:** `sqlite3`, `scp`, `expect`, password file at `~/.nas-backup-password` (chmod 600)

**Setup:**
```bash
# On VM 103, create password file (run once)
echo 'nas-backup-password' > ~/.nas-backup-password
chmod 600 ~/.nas-backup-password
```

**Example:**
```bash
# Manual backup execution
/home/evan/scripts/backup-vaultwarden.sh

# Scheduled via cron (daily at 2 AM) - already configured on VM 103
0 2 * * * /home/evan/scripts/backup-vaultwarden.sh >> /var/log/vaultwarden-backup.log 2>&1
```

**Use Cases:**
- Daily automated backups of critical Vaultwarden secrets
- Disaster recovery preparation
- Pre-maintenance backups
- Verification of backup integrity

**Features:**
- **Database consistency:** Uses SQLite VACUUM INTO (handles locks), falls back to cp+sync if needed
- **Integrity verification:** SQLite PRAGMA integrity_check before upload
- **Network transfer:** SCP with password authentication via expect
- **Synology compatibility:** Handles Synology SFTP/SCP chroot to /volume1/
- **Retention policy:** Automatically deletes backups older than 30 days
- **Detailed logging:** Color-coded output for status tracking
- **Error handling:** Proper exit codes for monitoring integration

**Implementation Details:**
- Backs up `/home/evan/data/vw-data/db.sqlite3` on VM 103
- Transfers to `backup@192.168.86.43:/volume1/backups/vaultwarden/`
- Note: Synology NAS requires paths relative to `/volume1/` for SCP (chroot)
- backup user must be in `administrators` group for SSH/SCP access
- Password stored securely in `~/.nas-backup-password` on VM 103

**Related Tasks:**
- [[../../tasks/completed/IN-017-implement-vaultwarden-backup|IN-017]] - Implementation
- [[../../tasks/backlog/IN-019-automate-synology-user-management|IN-019]] - Future automation

### Setup (`setup/`)

#### `setup-evan-nopasswd-sudo.sh`
**Purpose:** Configure `evan` user with passwordless sudo on VMs
**Usage:** `./setup-evan-nopasswd-sudo.sh <vm-ip>`
**Dependencies:** SSH access (as root or with sudo)

**Example:**
```bash
# Configure on VM 103
./scripts/setup/setup-evan-nopasswd-sudo.sh 192.168.86.249
```

**Use Cases:**
- Initial VM setup
- User configuration after VM creation
- Restoring user permissions

#### `setup-inspector-user.sh`
**Purpose:** Create read-only `inspector` user for Testing Agent
**Usage:** `./setup-inspector-user.sh <vm-ip>`
**Dependencies:** SSH access (as root or with sudo)

**Example:**
```bash
# Create inspector user on all VMs
for vm in 172 173 174 249; do
  ./scripts/setup/setup-inspector-user.sh "192.168.86.$vm"
done
```

**Use Cases:**
- Testing Agent setup (see [[../docs/agents/TESTING|Testing Agent]])
- Policy-enforced read-only access
- Safe validation without modification risk

### Infrastructure (`infrastructure/`)

#### `create-test-vm.sh`
**Purpose:** Automate creation of Proxmox VMs using Ubuntu cloud images
**Usage:** `./create-test-vm.sh [OPTIONS] [VM_ID] [VM_NAME] [CORES] [RAM_MB] [DISK_GB]`
**Options:** `--yes` or `-y` to skip confirmation prompt
**Exit Codes:** 0 (success), 1 (error during creation)
**Default Values:** VM ID 900, name "test-template", 2 cores, 4GB RAM, 20GB disk

**Example:**
```bash
# Create VM with defaults (interactive)
./scripts/infrastructure/create-test-vm.sh

# Create VM with custom settings, skip confirmation
./scripts/infrastructure/create-test-vm.sh --yes 9000 ubuntu-template 2 4096 20

# Create VM with specific ID and name
./scripts/infrastructure/create-test-vm.sh 105 new-service
```

**Use Cases:**
- Rapidly create test VMs for development
- Build VM templates from scratch
- Automate VM provisioning workflows
- Create consistent base VMs for Ansible configuration

**Features:**
- **Cloud-init Integration:** Uses Ubuntu cloud images for fast deployment
- **Automated Download:** Fetches Ubuntu 24.04 cloud image to Proxmox
- **SSH Key Injection:** Configures SSH access using your public key
- **Network Configuration:** Sets up DHCP networking automatically
- **Safety Checks:** Verifies prerequisites and prevents duplicate VM IDs
- **Detailed Output:** Shows configuration before creation and provides post-creation instructions

**Process Automated:**
```bash
# Previously manual steps (now automated):
# 1. Download Ubuntu cloud image
# 2. Create VM with qm create
# 3. Import disk image
# 4. Attach disk and configure boot
# 5. Add cloud-init drive
# 6. Configure user and SSH keys
# 7. Start VM
```

**Requirements:**
- SSH access to Proxmox host (192.168.86.106 by default)
- SSH public key at `~/.ssh/id_rsa.pub`
- Internet access on Proxmox (to download cloud image)
- Proxmox storage named `local-lvm`

**Related Tasks:**
- [[../../tasks/backlog/IN-010-create-vm-template|IN-010]] - VM template creation

#### `docker-cleanup.sh`
**Purpose:** Clean up unused Docker images on remote VMs and report disk space recovered
**Usage:** `./docker-cleanup.sh <vm-host> [ssh-user]`
**Exit Codes:** 0 (success), 1 (connectivity error)
**Default SSH User:** `evan`

**Example:**
```bash
# Clean Docker images on VM 103
./scripts/infrastructure/docker-cleanup.sh 192.168.86.249

# With explicit SSH user
./scripts/infrastructure/docker-cleanup.sh 192.168.86.249 evan
```

**Use Cases:**
- Free up disk space on VMs with low storage
- Regular maintenance to remove unused images
- Pre-expansion cleanup to avoid unnecessary disk expansion
- Part of routine infrastructure housekeeping

**Features:**
- **Before/After Reporting:** Shows disk usage and Docker stats before and after cleanup
- **Color-coded Output:** Clear status indicators (success, warning, error)
- **Detailed Summary:** Reports exact space freed and images removed
- **Safe Operation:** Only removes unused images, keeps active container images
- **No-op Handling:** Gracefully handles VMs with no images to clean

**Example Output:**
```
VM 102 (infinity-node-arr) - 192.168.86.174
Before: 49G used (27% full), 170 Docker images, 30.46GB reclaimable
After:  19G used (10% full), 11 Docker images, 0GB reclaimable
Result: Freed 17% disk space, removed 159 unused images
```

**Related Tasks:**
- [[../../tasks/backlog/IN-018-expand-vm-103-disk-space|IN-018]] - Docker cleanup before disk expansion

#### `expand-vm-disk.sh`
**Purpose:** Automate Proxmox VM disk expansion including LVM and filesystem resize
**Usage:** `./expand-vm-disk.sh <vm-id> <additional-size-GB> [proxmox-host] [ssh-user]`
**Exit Codes:** 0 (success), 1 (error during expansion)
**Default Proxmox Host:** `192.168.86.106`
**Default Proxmox User:** `root`
**VM SSH User:** `evan`

**Example:**
```bash
# Expand VM 103 by 50GB
./scripts/infrastructure/expand-vm-disk.sh 103 50

# With explicit Proxmox host
./scripts/infrastructure/expand-vm-disk.sh 103 50 192.168.86.106 root
```

**Use Cases:**
- Expand VM disks when storage is running low
- Add capacity for new services or data growth
- Automate previously manual multi-step process
- Consistent, repeatable disk expansion

**Features:**
- **End-to-End Automation:** Handles all steps from Proxmox to filesystem
- **Safety Checks:** Verifies VM exists, shows current state, requires confirmation
- **Multi-Step Process:**
  1. Verify connectivity to Proxmox and VM
  2. Show current disk status
  3. Request user confirmation
  4. Expand disk in Proxmox (qm resize)
  5. Rescan SCSI bus on VM
  6. Extend physical volume (pvresize)
  7. Extend logical volume (lvextend)
  8. Resize filesystem (resize2fs)
  9. Verify expansion succeeded
- **Error Handling:** Stops on any failure, provides clear error messages
- **Detailed Output:** Color-coded progress through each step
- **Verification:** Shows final disk status and checks for errors

**Process Automated:**
```bash
# Previously manual steps (now automated):
# On Proxmox: qm resize <vm-id> scsi0 +<size>G
# On VM:      echo 1 | sudo tee /sys/class/block/sda/device/rescan
#             sudo pvresize /dev/sda3
#             sudo lvextend -l +100%FREE /dev/mapper/ubuntu--vg-ubuntu--lv
#             sudo resize2fs /dev/mapper/ubuntu--vg-ubuntu--lv
#             df -h /
```

**Requirements:**
- Ubuntu VMs with LVM (ubuntu-vg/ubuntu-lv)
- SCSI disk at /dev/sda3
- SSH access to Proxmox host
- SSH access to target VM
- qemu-guest-agent on VM (for IP detection)

**Related Tasks:**
- [[../../tasks/backlog/IN-018-expand-vm-103-disk-space|IN-018]] - Automation requirement
- User feedback: "This process is something I've had to do multiple times and it's a pain in the butt which requires me to look up how to do it every time. Let's automate this."

## Documentation Pattern: `.docs/` for Context-Specific Documentation

We follow a `.docs/` pattern for keeping documentation close to the code/config it describes:

**Pattern:** Create a `.docs/` subdirectory in any directory that needs context-specific documentation.

**Examples:**
- `config/vm-template/.docs/vm-research-findings.md` - Research about VM configurations
- `ansible/.docs/playbook-design.md` - Ansible-specific design decisions
- `services/.docs/architecture.md` - Service architecture explanations

**When to use `.docs/`:**
- Documentation specific to files in that directory
- Research findings for configurations
- Context that would clutter main docs
- Implementation notes for specific modules

**When NOT to use `.docs/` (use `docs/` instead):**
- Project-wide documentation (ARCHITECTURE.md, CLAUDE.md)
- Cross-cutting concerns (SECRET-MANAGEMENT.md)
- Runbooks that span multiple areas
- Agent definitions

**Benefits:**
- Keeps documentation close to what it documents
- Scalable pattern across the entire project
- Clear separation: `docs/` = project-wide, `.docs/` = context-specific
- Easy to find relevant docs when working in a specific area

## Best Practices

### Script Development

**Structure:**
- Clear help/usage documentation in header
- Descriptive variable names
- Error handling (`set -euo pipefail`)
- Exit codes (0=success, 1=error, 2=invalid input)
- Color-coded output for clarity

**Documentation:**
- Purpose and use cases
- Required dependencies
- Example usage
- Exit codes explained

**Testing:**
- Test with invalid inputs
- Test on non-critical services first
- Verify error handling
- Document expected behavior

### Usage Guidelines

**Before running scripts:**
1. Read the script header documentation
2. Understand what it will do
3. Check dependencies are installed
4. Test on non-critical services first

**Security:**
- Never hardcode secrets in scripts
- Use environment variables or secret managers
- Audit scripts before committing
- Review scripts from external sources

**Maintenance:**
- Keep scripts up to date with infrastructure changes
- Document changes in git commits
- Remove obsolete scripts
- Update this README when adding scripts

## Future Scripts

Scripts planned but not yet implemented:

**Validation:**
- `check-service-health.sh` - Verify all services running
- `verify-no-secrets-in-git.sh` - Pre-commit secret scan
- `test-vaultwarden-access.sh` - Verify Vaultwarden connectivity

**Backup:**
- `backup-docker-configs.sh` - Backup all docker-compose files
- `backup-env-files.sh` - Secure backup of .env files

**Deployment:**
- `rollback-stack.sh` - Rollback to previous stack version
- `deploy-all-stacks.sh` - Deploy/update all stacks
- `restart-stack.sh` - Graceful stack restart

**Monitoring:**
- `check-critical-services.sh` - Verify Emby, downloads, arr
- `report-resource-usage.sh` - VM resource utilization
- `check-vpn-status.sh` - Verify VPN connectivity

See [[../tasks/backlog/IN-003-create-deployment-runbook|IN-003]] for runbook automation plans.

## Related Documentation

- [[../docs/CLAUDE|Claude Code Guide]] - Working with Claude Code
- [[../docs/agents/DOCKER|Docker Agent]] - Docker operations
- [[../docs/agents/SECURITY|Security Agent]] - Secret management
- [[../docs/adr/012-script-based-operational-automation|ADR-012]] - Script-based automation decision
- [[../docs/SECRET-MANAGEMENT|Secret Management]] - Vaultwarden workflows

## Contributing

When adding new scripts:

1. **Choose appropriate directory** based on function
2. **Follow naming convention**: `verb-noun.sh` (e.g., `check-service-health.sh`)
3. **Include header documentation** with usage and examples
4. **Make executable**: `chmod +x script-name.sh`
5. **Update this README** with inventory entry
6. **Test thoroughly** before committing
7. **Reference in ADRs** if establishing new patterns

---

**Note:** All scripts assume execution from repository root or with proper path handling. Scripts use absolute paths where possible to avoid directory context issues.
