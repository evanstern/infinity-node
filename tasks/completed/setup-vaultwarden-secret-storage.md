---
type: task
status: completed
priority: high
category: security
agent: security
created: 2025-10-25
updated: 2025-10-26
completed: 2025-10-26
tags:
  - task
  - security
  - secrets
  - vaultwarden
  - automation
---

# Task: Set Up Vaultwarden Secret Storage Strategy

## Description

Establish organizational structure and processes for storing infrastructure secrets in Vaultwarden. This includes folder organization, naming conventions, API access setup for automation, and documentation of workflows.

This task sets up the foundation for secret management but does NOT include backup strategy (separate task).

## Context

Before importing Docker configurations and migrating secrets, we need a clear strategy for:
1. **Where** to store secrets in Vaultwarden (organizational structure)
2. **How** to name and label secrets for easy retrieval
3. **How** to access secrets programmatically via API (for deployment automation)
4. **What** the workflow is for storing/retrieving secrets

Vaultwarden is already running on VM 103 and will be our source of truth for all infrastructure secrets.

## Acceptance Criteria

### Vaultwarden Organization
- [x] Create folder structure in Vaultwarden for infrastructure secrets
- [x] Define naming convention for secret items
- [x] Create example entries for reference
- [x] Document folder/organization structure

### API Access Setup
- [x] Install Bitwarden CLI (`bw`) on local machine
- [x] Configure API access to Vaultwarden instance
- [x] Test authentication with API key (personal API key with scope: `api`)
- [x] Test retrieving secrets programmatically
- [x] Document API authentication process
- [x] Create example script for retrieving secrets (scripts/deploy-with-secrets.sh)

### Documentation
- [x] Create docs/SECRET-MANAGEMENT.md with:
  - Organizational structure in Vaultwarden
  - Naming conventions
  - How to store new secrets
  - How to retrieve secrets manually
  - How to retrieve secrets via API
  - API authentication setup (including personal API key approach)
- [x] Update ARCHITECTURE.md with Vaultwarden reference
- [x] Update SECURITY agent docs with secret management process
- [x] Create template for documenting secrets in .env.example files (templates/.env.example)

### Workflow Testing
- [x] Store a test secret in Vaultwarden
- [x] Retrieve test secret via web UI
- [x] Retrieve test secret via CLI
- [x] Delete test secret
- [x] Document the complete workflow

## Dependencies

- Access to Vaultwarden web UI on VM 103
- Vaultwarden login credentials
- Local machine for CLI installation/testing
- Understanding of Bitwarden CLI (`bw`)

## Testing Plan

[[docs/agents/TESTING|Testing Agent]] should validate:
- Vaultwarden is accessible and functional
- Folder structure is logical and documented
- API authentication works
- CLI can retrieve secrets programmatically
- Documentation is complete and accurate

**Manual validation:**
```bash
# Install Bitwarden CLI
npm install -g @bitwarden/cli

# Configure for Vaultwarden instance
bw config server https://vaultwarden.url

# Login and test
bw login
bw sync
bw list items

# Test retrieving a specific secret
bw get item "secret-name"
```

## Related Documentation

- [[docs/agents/SECURITY|Security Agent]]
- [[tasks/current/IN-002-migrate-secrets-to-env|IN-002]] - Depends on this task
- [[tasks/current/IN-001-import-existing-docker-configs|IN-001]] - Will use this strategy
- [[tasks/backlog/IN-011-document-backup-strategy|IN-011]] - Includes Vaultwarden backup (separate)

## Notes

### Proposed Folder Structure in Vaultwarden

```
infinity-node/
├── vm-100-emby/
│   ├── emby-secrets
│   ├── pangolin-emby-tunnel
│   └── portainer-admin
├── vm-101-downloads/
│   ├── nordvpn-credentials
│   ├── deluge-password
│   └── nzbget-password
├── vm-102-arr/
│   ├── radarr-api-key
│   ├── sonarr-api-key
│   ├── prowlarr-api-key
│   ├── jellyseerr-secrets
│   └── pangolin-arr-tunnel
├── vm-103-misc/
│   ├── vaultwarden-admin-token
│   ├── paperless-secrets
│   ├── immich-secrets
│   └── pangolin-misc-tunnel
├── shared/
│   ├── watchtower-credentials
│   └── nas-credentials
└── external/
    ├── cloudflare-api-keys
    └── domain-credentials
```

### Naming Conventions

**Format:** `<service-name>-<secret-type>`

Examples:
- `emby-api-key`
- `radarr-api-key`
- `nordvpn-credentials`
- `pangolin-emby-tunnel-secret`

**Custom Fields for Each Item:**
- `service`: Service name (e.g., "emby", "radarr")
- `vm`: VM number (e.g., "100", "101")
- `env_var_name`: Environment variable name for .env file (e.g., "EMBY_API_KEY")
- `notes`: Additional context or usage notes

### Bitwarden CLI for Automation

**Installation:**
```bash
npm install -g @bitwarden/cli
```

**Configuration:**
```bash
# Point to Vaultwarden instance
bw config server https://vault.infinity-node.com  # or local IP

# Login (interactive first time)
bw login

# For automation, use API key
export BW_SESSION="session_token"
```

**Retrieving Secrets:**
```bash
# Get all items in a folder
bw list items --folderid <folder-id>

# Get specific item
bw get item "emby-api-key"

# Get password field
bw get password "emby-api-key"

# Get custom field
bw get item "emby-api-key" | jq -r '.fields[] | select(.name=="env_var_name") | .value'
```

**Example Automation Script:**
```bash
#!/bin/bash
# deploy-stack.sh - Example of retrieving secrets for deployment

STACK_NAME="emby"
VM_FOLDER="vm-100-emby"

# Retrieve secrets and create .env file
bw list items --folderid $(bw get folder "$VM_FOLDER" | jq -r '.id') | \
  jq -r '.[] | "\(.fields[] | select(.name=="env_var_name") | .value)=\(.login.password)"' > .env

# Deploy stack
docker compose up -d
```

### API Access vs Manual Access

**Web UI (Manual):**
- Human access for viewing/editing secrets
- Creating new entries
- Organizing folders
- Auditing access

**CLI/API (Automation):**
- Deployment scripts
- Automated .env file generation
- Backup scripts
- Integration with CI/CD (future)

### Security Considerations

**API Key Storage:**
- Store Bitwarden API key securely (not in git)
- Use session tokens with expiration
- Rotate API keys periodically
- Document API key location

**Access Control:**
- Only authorized users/systems have API access
- Monitor API usage
- Audit logs for secret access

**Secrets in Transit:**
- Always use HTTPS for Vaultwarden access
- Validate TLS certificates
- Never log secrets in plaintext

### Backup Strategy (Separate Task)

**NOTE:** This task does NOT include implementing backups. That's handled by [[document-backup-strategy]].

However, we should document that Vaultwarden needs backup:
- Database file backup (SQLite by default)
- Attachment backup (if used)
- Automated backup to external location
- Test restore procedure

### Post-Setup Workflow

**When adding a new secret:**
1. Add secret to Vaultwarden via web UI
2. Use naming convention: `<service>-<type>`
3. Add custom fields: `vm`, `env_var_name`, `service`
4. Place in appropriate folder
5. Document in service's .env.example file
6. Update service README.md

**When deploying a service:**
1. Retrieve secrets via CLI: `bw get item "secret-name"`
2. Create .env file on VM (manually or via script)
3. Deploy service with docker compose
4. Verify service works
5. Delete temporary credentials if used

**When updating a secret:**
1. Update in Vaultwarden first (source of truth)
2. Update .env file on VM
3. Restart affected service
4. Verify service works

### Integration with Import Task

When we import Docker configs ([[tasks/current/IN-001-import-existing-docker-configs|IN-001]]):
1. Document any secrets found in docker-compose files
2. Store them in Vaultwarden immediately
3. Reference Vaultwarden item in .env.example
4. Remove secret from docker-compose.yml

### Priority Rationale

High priority because:
- Blocks import-existing-docker-configs (we'll find secrets)
- Blocks migrate-secrets-to-env (needs storage destination)
- Foundation for automation strategy
- Critical for security best practices
- Relatively quick to complete
