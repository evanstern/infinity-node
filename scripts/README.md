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
├── utils/                             # Utility scripts
│   └── bw-setup-session.sh           # Setup Bitwarden CLI session
├── tasks/                             # Task lifecycle management
│   ├── get-next-task-id.sh           # Get next available task ID
│   ├── update-task-counter.sh        # Increment task ID counter
│   ├── validate-task.sh              # Validate task file correctness
│   └── move-task.sh                  # Move task between lifecycle stages
├── secrets/                           # Secret management
│   ├── audit-secrets.sh              # Scan for hardcoded secrets
│   ├── create-secret.sh              # Store secret in Vaultwarden
│   ├── list-vaultwarden-structure.sh # List Vaultwarden collections
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

### Task Lifecycle Management (`tasks/`)

Task management scripts that support the MDTD workflow and `/create-task` slash command.

#### `get-next-task-id.sh`
**Purpose:** Get the next available task ID for task creation
**Usage:** `./scripts/tasks/get-next-task-id.sh`
**Output:** Next task ID in format `IN-NNN` (e.g., `IN-037`)

**What it does:**
1. Reads `tasks/.task-id-counter` if it exists
2. Otherwise scans all task files and finds highest ID
3. Creates/updates counter file
4. Returns next available ID in zero-padded format

**Use case:** Called by `/create-task` command to get sequential task IDs

**Recovery:** If counter gets out of sync, delete `tasks/.task-id-counter` to force rescan

#### `update-task-counter.sh`
**Purpose:** Increment the task ID counter after creating a task
**Usage:** `./scripts/tasks/update-task-counter.sh`

**What it does:**
1. Reads current value from `tasks/.task-id-counter`
2. Validates it's a number
3. Increments by 1
4. Writes new value back to counter file
5. Displays confirmation message

**Use case:** Called by `/create-task` command AFTER successfully creating task file

**Note:** Must be called after each task creation to keep counter in sync

#### `validate-task.sh`
**Purpose:** Validate a task file for correctness and consistency
**Usage:** `./scripts/tasks/validate-task.sh <TASK_ID>`
**Example:** `./scripts/tasks/validate-task.sh IN-024`

**What it does:**
1. Checks task file exists
2. Verifies task ID is unique (no duplicates)
3. Validates frontmatter is valid YAML
4. Checks required frontmatter fields present
5. Verifies filename follows naming convention (IN-NNN-kebab-case.md)
6. Checks task location matches status (backlog/current/completed)
7. Provides actionable error messages if validation fails

**Use case:** Quality assurance after task creation or when debugging task issues

**Exit codes:**
- `0` - All validations passed
- `1` - One or more validations failed

#### `move-task.sh`
**Purpose:** Atomically move task between lifecycle stages (backlog → current → completed)
**Usage:** `./scripts/tasks/move-task.sh <TASK_ID> <FROM> <TO>`
**Arguments:**
- `TASK_ID`: Task identifier (e.g., IN-007)
- `FROM`: Source directory (backlog, current, or completed)
- `TO`: Destination directory (backlog, current, or completed)

**What it does:**
1. Finds task file in FROM directory
2. Updates status frontmatter to match TO stage
3. Sets completed date if moving to completed
4. Moves file to TO directory
5. Verifies no duplicates exist across all task directories
6. Stages both deletion and addition in git
7. Shows final git status for review

**Exit Codes:**
- 0 (success)
- 1 (error: file not found, duplicates detected, invalid arguments)

**Example:**
```bash
# Move task from current to completed
./scripts/tasks/move-task.sh IN-007 current completed

# Move task from backlog to current
./scripts/tasks/move-task.sh IN-024 backlog current
```

**Use Cases:**
- Mark tasks as complete without manual file operations
- Prevent duplicate task files across directories
- Ensure consistent status frontmatter updates
- Atomic task lifecycle transitions

**Why this exists:**
Manual task file moves with `git mv` are error-prone and often leave duplicate files in multiple directories. This script handles the entire operation atomically with verification.

### Utilities (`utils/`)

#### `bw-setup-session.sh`
**Purpose:** Setup Bitwarden CLI session for Claude Code access
**Usage:** `./utils/bw-setup-session.sh`
**Dependencies:** Bitwarden CLI (`bw`), unlocked vault
**Exit Codes:** 0 (success), 1 (BW_SESSION not set in shell)

**Example:**
```bash
# First, unlock Bitwarden in your shell
export BW_SESSION=$(bw unlock --raw)

# Then run setup script
./scripts/utils/bw-setup-session.sh
```

**Use Cases:**
- Enable Claude Code to access Vaultwarden secrets
- Set up session at start of work session
- Avoid repeatedly providing session token

**Features:**
- Checks if BW_SESSION is set in user's current shell
- Saves session token to `~/.bw-session` (chmod 600)
- Claude Code can then read session with `export BW_SESSION=$(cat ~/.bw-session)`
- Session persists until `bw lock` or session expires

**Security Notes:**
- Session file is chmod 600 (user read/write only)
- Token has limited lifespan (~30 minutes of inactivity)
- Delete session file with `rm ~/.bw-session` to revoke access
- User controls unlocking (keeps master password secure)

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

#### `get-vw-secret.sh`
**Purpose:** Retrieve a secret value from Vaultwarden (generic utility)
**Usage:** `./get-vw-secret.sh <secret-name> <collection-name> [field-name]`
**Dependencies:** Bitwarden CLI (`bw`), authenticated session, `jq`
**Exit Codes:** 0 (success), 1 (prerequisites), 2 (not found), 3 (field not found)

**Example:**
```bash
# Get password (default)
TOKEN=$(./scripts/secrets/get-vw-secret.sh "portainer-api-token-vm-100" "shared")

# Get custom field
URL=$(./scripts/secrets/get-vw-secret.sh "portainer-api-token-vm-100" "shared" "url")

# Use in a script
DB_PASS=$(./scripts/secrets/get-vw-secret.sh "paperless-secrets" "vm-103-misc" "postgres_password")
```

**Use Cases:**
- Generic secret retrieval for any automation
- Building block for other scripts (see query-portainer-stacks.sh)
- Retrieving API tokens, passwords, or custom fields
- CI/CD pipelines needing secret access

**Features:**
- **Generic design:** Works with any secret in any collection
- **Field support:** Retrieve password or any custom field by name
- **Clean output:** Returns just the value (no newline) for easy piping
- **Error handling:** Clear error messages for debugging
- **Collection-aware:** Works with infinity-node organization structure

**Related:**
- Used by `query-portainer-stacks.sh` for automatic credential retrieval
- Complements `create-secret.sh` for full secret lifecycle

#### `create-secret.sh`
**Purpose:** Create and store a secret in Vaultwarden (organization or personal vault)
**Usage:** `./create-secret.sh [--personal] <item-name> <collection-name> <password> [custom-fields-json]`
**Dependencies:** Bitwarden CLI (`bw`), authenticated session, `jq`
**Exit Codes:** 0 (success), 1 (error)

**Example:**
```bash
# Organization secret (default) - stores in infinity-node org
./scripts/secrets/create-secret.sh \
  "portainer-api-token-vm-103" \
  "shared" \
  "ptr_ABC123..." \
  '{"service":"portainer","vm":"103","purpose":"API automation"}'

# Organization secret with metadata fields
./scripts/secrets/create-secret.sh \
  "radarr-api-key" \
  "vm-102-arr" \
  "abc123..." \
  '{"service":"radarr","env_var_name":"RADARR_API_KEY"}'

# Personal vault secret
./scripts/secrets/create-secret.sh --personal \
  "personal-key" \
  "my-folder" \
  "secret123"
```

**Use Cases:**
- Migrating secrets to Vaultwarden
- Creating new service secrets with metadata
- Storing infrastructure credentials (API tokens, passwords)
- Rotating existing credentials

**Features:**
- **Organization support:** Creates secrets in `infinity-node` organization by default
- **Personal vault:** Use `--personal` flag for personal folders
- **Custom fields:** Add metadata via JSON (service, vm, purpose, url, etc.)
- **Collection-based:** Organizes by collection (vm-100-emby, shared, external, etc.)
- **Validation:** Prevents duplicates, validates prerequisites
- **Auto-sync:** Syncs vault after creation

#### `list-vaultwarden-structure.sh`
**Purpose:** Display Vaultwarden organization collection structure and item counts
**Usage:** `./list-vaultwarden-structure.sh`
**Dependencies:** Bitwarden CLI (`bw`), authenticated session, `jq`
**Exit Codes:** 0 (success), 1 (organization not found or BW_SESSION not set)

**Example:**
```bash
# First ensure BW_SESSION is available
export BW_SESSION=$(cat ~/.bw-session)

# List all collections and their secrets
./scripts/secrets/list-vaultwarden-structure.sh
```

**Output:**
```
=== Vaultwarden Collection Structure ===

Organization: infinity-node
Organization ID: d3777135-ea0c-4589-aa05-00b06b19ca65

Collections:
  shared
    Collection ID: 747f7e21-5569-420b-b465-fba39c1673f2
    Items: 1
    Secrets:
      - portainer-api-token-vm-103

  vm-103-misc
    Collection ID: 928e99cc-3a75-4c64-a23d-0f13625bb461
    Items: 5
    Secrets:
      - immich-secrets
      - linkwarden-secrets
      ...

=== Summary ===
Total Collections: 7
Total Items in Organization: 13
```

**Use Cases:**
- Understand secret organization before storing new secrets
- Verify secrets are in correct collections
- Audit secret inventory across infrastructure
- Document current Vaultwarden structure
- Choose appropriate collection for new secrets

**Features:**
- **Collection listing:** Shows all collections in infinity-node org
- **Item counts:** Reports number of secrets in each collection
- **Secret names:** Lists all secret names per collection
- **Summary statistics:** Total collections and items
- **Auto-sync:** Syncs with Vaultwarden before listing
- **Color-coded:** Clear visual output

**Related:**
- Use with `create-secret.sh` to choose appropriate collection
- See [[../../docs/agents/SECURITY|Security Agent]] for collection organization

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

#### `query-portainer-stacks.sh`
**Purpose:** Query Portainer stacks from a VM (dual-mode: direct or Vaultwarden)
**Usage:**
- Direct mode: `./query-portainer-stacks.sh --token TOKEN --url URL [--json]`
- Vaultwarden mode: `./query-portainer-stacks.sh --secret SECRET_NAME --collection COLLECTION_NAME [--json]`
**Dependencies:** `curl`, `jq`, and for Vaultwarden mode: `get-vw-secret.sh` and `BW_SESSION`
**Exit Codes:** 0 (success), 1 (invalid args), 2 (VW retrieval failed), 3 (API failed)

**Example:**
```bash
# Direct mode (provide token and URL manually)
./scripts/infrastructure/query-portainer-stacks.sh \
  --token "ptr_ABC123..." \
  --url "https://192.168.86.172:9443"

# Vaultwarden mode (auto-retrieve credentials)
./scripts/infrastructure/query-portainer-stacks.sh \
  --secret "portainer-api-token-vm-100" \
  --collection "shared"

# JSON output for scripting
./scripts/infrastructure/query-portainer-stacks.sh \
  --secret "portainer-api-token-vm-103" \
  --collection "shared" \
  --json
```

**Use Cases:**
- Inventory all deployed stacks on a VM
- Verify Git configuration and auto-update settings
- Migration validation (check stacks before/after)
- Monitoring and reporting on stack status
- Automated audits of Portainer deployments

**Features:**
- **Dual-mode design:** Direct (manual credentials) or Vaultwarden (automatic retrieval)
- **Composable:** Uses `get-vw-secret.sh` in Vaultwarden mode
- **Detailed output:** Shows stack status, Git config, auto-update settings
- **JSON output:** Optional machine-readable format for scripting
- **Color-coded:** Clear visual output for human readability

**Output Information:**
- Stack name and ID
- Type (Docker Compose, Swarm)
- Status (Active, Inactive)
- Git repository URL (if configured)
- Git branch and compose file path
- Auto-update status and interval

**Related:**
- Created during IN-013 (Portainer migration inventory)
- Uses `get-vw-secret.sh` for credential retrieval
- See `docs/portainer-migration-inventory.md` for usage example

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
- Project-wide documentation (ARCHITECTURE.md, AI-COLLABORATION.md)
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
