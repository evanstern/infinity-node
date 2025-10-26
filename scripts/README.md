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

Per [[../docs/DECISIONS#ADR-012|ADR-012: Script-Based Operational Automation]], we maintain scripts for:
- ✅ **Reproducible operations** - Run the same way every time
- ✅ **Common tasks** - Operations performed multiple times
- ✅ **Validation & health checks** - Verify system state
- ✅ **Building blocks** - Compose into larger workflows
- ✅ **Runbook foundation** - Executable documentation

**When to create a script:**
- Operation will be run multiple times
- Need consistent, reproducible execution
- Want to reduce human error
- Building toward larger automation

**When NOT to create a script:**
- One-off tasks
- Trivial single commands
- Operations that change frequently

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
├── validation/                        # Health checks (to be populated)
└── backup/                            # Backup operations (to be populated)
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
- `backup-vaultwarden.sh` - Backup Vaultwarden database

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
- [[../docs/DECISIONS#ADR-012|ADR-012]] - Script-based automation decision
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
