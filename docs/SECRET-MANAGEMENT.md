# Secret Management

**Status:** Active
**Owner:** Security Agent
**Last Updated:** 2025-10-26

## Overview

This document describes how secrets are managed in the infinity-node infrastructure. Vaultwarden serves as the source of truth for all infrastructure secrets, with the Bitwarden CLI providing programmatic access for automation.

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Secret Storage Flow                       │
└─────────────────────────────────────────────────────────────┘

   Manual Access              Automation Access
        │                            │
        ▼                            ▼
  ┌──────────┐              ┌──────────────┐
  │ Web UI   │              │ Bitwarden    │
  │ (HTTPS)  │              │ CLI (HTTP)   │
  └────┬─────┘              └──────┬───────┘
       │                           │
       │  ┌────────────────────────┘
       │  │
       ▼  ▼
  ┌────────────────┐
  │  Vaultwarden   │  ← Source of Truth
  │   VM 103       │
  │  Port 8111     │
  └────────────────┘
```

## Vaultwarden Instance

**Location:** VM 103 (192.168.86.249)
**Local Access:** http://192.168.86.249:8111
**External Access:** https://vaultwarden.infinity-node.com (via Pangolin tunnel)
**Docker Container:** `vaultwarden`

### Access Methods

**Web UI (Manual):**
- URL: https://vaultwarden.infinity-node.com
- Use: Human access for viewing/editing secrets
- Auth: Username/password + 2FA (if configured)

**CLI/API (Automation):**
- URL: http://192.168.86.249:8111
- Use: Automated secret retrieval for deployments
- Auth: Username/password, then session token
- **Note:** Must use local IP (not domain) due to Pangolin authentication

## Folder Structure

Secrets are organized by VM and service category:

```
infinity-node/
├── vm-100-emby/           # Media server secrets
│   ├── emby-secrets
│   ├── pangolin-emby-tunnel
│   └── portainer-admin
├── vm-101-downloads/      # Download client secrets
│   ├── nordvpn-credentials
│   ├── deluge-password
│   └── nzbget-password
├── vm-102-arr/            # Media automation secrets
│   ├── radarr-api-key
│   ├── sonarr-api-key
│   ├── prowlarr-api-key
│   ├── jellyseerr-secrets
│   └── pangolin-arr-tunnel
├── vm-103-misc/           # Supporting services secrets
│   ├── vaultwarden-admin-token
│   ├── paperless-secrets
│   ├── immich-secrets
│   └── pangolin-misc-tunnel
├── shared/                # Cross-VM secrets
│   ├── watchtower-credentials
│   └── nas-credentials
└── external/              # External service secrets
    ├── cloudflare-api-keys
    └── domain-credentials
```

## Naming Conventions

### Secret Item Names

**Format:** `<service-name>-<secret-type>`

**Examples:**
- `emby-api-key`
- `radarr-api-key`
- `nordvpn-credentials`
- `pangolin-emby-tunnel-secret`
- `newt-config-misc` (for config files)

### Item Types

**Login Items** (most common):
- Single-line secrets (passwords, API keys, tokens)
- Use the "Password" field for the secret value
- Use custom fields for metadata

**Secure Notes** (for multi-line content):
- Configuration files (e.g., `newt-config-emby`, `noip_duc.env`)
- Multi-line secrets or structured data
- Preserves formatting, line breaks, and special characters
- **Lesson from IN-002:** Secure notes are ideal for config files like Pangolin tunnel configs

**Example use cases:**
- ✅ API key → Login item
- ✅ Database password → Login item
- ✅ Pangolin tunnel config file → Secure note
- ✅ SSH config snippet → Secure note
- ✅ Certificate/key pairs → Secure note

### Custom Fields

Each secret item should include these custom fields:

- **`service`**: Service name (e.g., "emby", "radarr")
- **`vm`**: VM number (e.g., "100", "101") or "shared"
- **`env_var_name`**: Environment variable name for .env file (e.g., "EMBY_API_KEY")
- **`notes`**: Additional context or usage notes

**Example login item:**

```
Item Type: Login
Item Name: emby-api-key
Username: (not used for API keys)
Password: abc123xyz789secretkey
Custom Fields:
  - service: emby
  - vm: 100
  - env_var_name: EMBY_API_KEY
  - notes: API key for Emby media server integration
```

**Example secure note:**

```
Item Type: Secure Note
Item Name: newt-config-emby
Notes: (Contains full config file)
ENDPOINT https://pangolin.infinity-node.com
ID uy0wxbeuigh3zas
SECRET KEY gaelyx2bmc8x3bpymf30umc7vrkqvrybrdedp5fps8uqrkgt
Custom Fields:
  - service: newt
  - vm: 100
  - file_path: /etc/newt/config
```

## Bitwarden CLI Setup

### Installation

**macOS (Homebrew):**
```bash
brew install bitwarden-cli
```

**npm (alternative):**
```bash
npm install -g @bitwarden/cli
```

### Configuration

**⚠️ IMPORTANT:** Must use local IP address, not domain (see [Limitations](#limitations))

```bash
# Configure for local Vaultwarden instance
bw config server http://192.168.86.249:8111

# Verify configuration
bw status
```

### Authentication

**⭐ Recommended: API Key Authentication (Semi-Automated)**

This approach allows non-interactive login, making deployment scripts much easier.

**1. Generate Personal API Key in Vaultwarden:**
- Log into https://vaultwarden.infinity-node.com
- Go to **Settings → Security → Keys**
- Click **"View API Key"**
- Copy the **client_id** and **client_secret**
- **Note:** This is a **personal API key** (scope: `api`), not an organization key

**2. Store API Key Credentials in Shell Config:**
```bash
# Add to ~/.zshrc or ~/.bashrc
export BW_CLIENTID="user.xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
export BW_CLIENTSECRET="xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

# Reload shell
source ~/.zshrc
```

**3. Login with API Key (Non-Interactive):**
```bash
# Login using API key (no password prompt!)
bw login --apikey

# Verify login
bw status
# Should show: "status": "locked"
```

**4. Unlock Vault (Requires Master Password):**
```bash
# Unlock vault (one-time password prompt)
export BW_SESSION=$(bw unlock --raw)

# Verify unlocked
bw status
# Should show: "status": "unlocked"
```

**5. Use in Scripts:**
```bash
#!/bin/bash
# Your deployment script

# Login if not already authenticated
bw login --apikey

# Check if vault is unlocked
if ! bw status | jq -e '.status == "unlocked"' > /dev/null; then
  echo "Unlocking vault..."
  export BW_SESSION=$(bw unlock --raw)
fi

# Now retrieve secrets
SECRET=$(bw get password "service-api-key")
```

**Session management:**
```bash
# Session token stays valid for the duration of your terminal session

# Check session status
bw status

# Lock vault when done (optional)
bw lock

# Next time: just unlock, no need to login again
export BW_SESSION=$(bw unlock --raw)
```

**Alternative: Interactive Login (Not Recommended)**

If you don't want to use API keys, you can login interactively:

```bash
# Login with username/password (interactive)
bw login

# Unlock vault
bw unlock
```

**Note:** API key authentication is preferred because it eliminates the interactive login step, making scripts much more convenient.

### Retrieving Secrets

**List all items:**
```bash
bw list items
```

**List items in a folder:**
```bash
# First, get folder ID
bw list folders | jq '.[] | select(.name=="vm-100-emby") | .id'

# Then list items in that folder
bw list items --folderid <folder-id>
```

**Get specific secret:**
```bash
# Get entire item (returns JSON)
bw get item "emby-api-key"

# Get just the password field
bw get password "emby-api-key"

# Get custom field value
bw get item "emby-api-key" | jq -r '.fields[] | select(.name=="env_var_name") | .value'
```

**Search for secrets:**
```bash
# Search by name
bw list items --search "emby"

# Search in folder
bw list items --folderid <folder-id> --search "api"
```

## Workflows

### Adding a New Secret

**Via Web UI (Recommended):**

1. Log into https://vaultwarden.infinity-node.com
2. Click "New Item" or "Add Login"
3. Fill in details:
   - **Name:** Use naming convention `<service>-<secret-type>`
   - **Password:** The actual secret value
   - **Folder:** Select appropriate folder (e.g., "vm-100-emby")
4. Add custom fields:
   - Click "Add custom field"
   - Add: `service`, `vm`, `env_var_name`, `notes`
5. Save the item
6. Document in service's `.env.example` file
7. Update service README.md with reference

**Via CLI:**
```bash
# Create item JSON
cat > new-secret.json <<EOF
{
  "organizationId": null,
  "folderId": null,
  "type": 1,
  "name": "radarr-api-key",
  "notes": "API key for Radarr media automation",
  "favorite": false,
  "fields": [
    {"name": "service", "value": "radarr", "type": 0},
    {"name": "vm", "value": "102", "type": 0},
    {"name": "env_var_name", "value": "RADARR_API_KEY", "type": 0}
  ],
  "login": {
    "username": "",
    "password": "your_secret_here",
    "totp": null
  }
}
EOF

# Create the item
bw create item < new-secret.json

# Sync to update
bw sync
```

### Retrieving Secrets for Deployment

**Manual deployment:**
```bash
# 1. Unlock vault
export BW_SESSION=$(bw unlock --raw)

# 2. Retrieve secret
SECRET=$(bw get password "emby-api-key")

# 3. SSH to VM and create .env file
ssh evan@192.168.86.172 "echo 'EMBY_API_KEY=$SECRET' >> /path/to/.env"

# 4. Deploy service
ssh evan@192.168.86.172 "cd /path/to/stack && docker compose up -d"
```

**Automated deployment script:**
```bash
#!/bin/bash
# deploy-with-secrets.sh

set -euo pipefail

STACK_NAME="emby"
VM_IP="192.168.86.172"
STACK_PATH="/home/evan/projects/infinity-node/stacks/emby"

# Ensure vault is unlocked
if ! bw status | jq -e '.status == "unlocked"' > /dev/null; then
  echo "Vault is locked. Unlocking..."
  export BW_SESSION=$(bw unlock --raw)
fi

# Retrieve secrets
echo "Retrieving secrets from Vaultwarden..."
EMBY_API_KEY=$(bw get password "emby-api-key")

# Create .env file on VM
echo "Creating .env file on VM..."
ssh evan@$VM_IP "cat > $STACK_PATH/.env" <<EOF
EMBY_API_KEY=$EMBY_API_KEY
EOF

# Deploy stack
echo "Deploying stack..."
ssh evan@$VM_IP "cd $STACK_PATH && docker compose up -d"

echo "Deployment complete!"
```

### Updating a Secret

**Workflow:**
1. Update secret in Vaultwarden first (source of truth)
2. Retrieve updated secret via CLI or manually
3. Update `.env` file on target VM
4. Restart affected service
5. Verify service works with new secret

**Example:**
```bash
# 1. Update in Vaultwarden web UI (or via CLI)
# (Manual step in web UI)

# 2. Sync local vault
bw sync

# 3. Retrieve updated secret
NEW_SECRET=$(bw get password "emby-api-key")

# 4. Update on VM
ssh evan@192.168.86.172 "sed -i 's/^EMBY_API_KEY=.*/EMBY_API_KEY=$NEW_SECRET/' /path/to/.env"

# 5. Restart service
ssh evan@192.168.86.172 "cd /path/to/stack && docker compose restart"
```

### Rotating Secrets

**Best practices:**
- Rotate secrets periodically (every 90-180 days for API keys)
- Rotate immediately if compromised
- Test new secret before removing old one
- Update Vaultwarden as soon as rotation is complete
- Document rotation in service notes

## Security Best Practices

### Secret Storage

**DO:**
- ✅ Store ALL secrets in Vaultwarden (source of truth)
- ✅ Use strong, unique passwords for each secret
- ✅ Enable 2FA on Vaultwarden account
- ✅ Use custom fields to document secret metadata
- ✅ Organize secrets into folders by VM/service
- ✅ Add notes explaining what each secret is for
- ✅ Document secrets in `.env.example` files (NOT actual values)

**DON'T:**
- ❌ Commit secrets to git
- ❌ Store secrets in plaintext files
- ❌ Share secrets via unencrypted channels
- ❌ Reuse passwords across services
- ❌ Leave secrets in shell history
- ❌ Log secrets in plaintext

### API Access

**Session tokens:**
- Session tokens expire - re-unlock as needed
- Store `BW_SESSION` in environment, not files
- Never commit session tokens to git
- Lock vault when not in use: `bw lock`

**API key storage:**
- Bitwarden supports API keys (not configured yet)
- When configured, store API key securely (not in git)
- Rotate API keys periodically
- Monitor API usage for suspicious activity

### Secrets in Transit

- ✅ Use HTTPS for web UI access (via Pangolin)
- ✅ Use SSH for transferring secrets to VMs
- ✅ Clear shell history after running commands with secrets
- ❌ Never send secrets via unencrypted channels (email, Slack, etc.)

### Access Control

**Current setup:**
- Single user (personal vault)
- No organization/team features

**Future considerations:**
- Organizations for team access (if needed)
- Collections for granular permissions
- Emergency access configuration
- Audit logs review

## Troubleshooting

### CLI Not Working

**Issue:** `bw login` fails or returns empty response

**Solution:**
```bash
# 1. Verify server configuration
bw config server

# 2. Should be: http://192.168.86.249:8111
# If not, reconfigure:
bw config server http://192.168.86.249:8111

# 3. Verify Vaultwarden is accessible
curl -I http://192.168.86.249:8111

# 4. Try login again
bw login
```

**Issue:** "You are not logged in" even after `bw login`

**Solution:**
- Check `bw status` - should show `"status": "locked"` after successful login
- Run `bw unlock` to unlock vault
- Export session token: `export BW_SESSION="..."`

### Session Expired

**Issue:** Commands fail with "session invalid"

**Solution:**
```bash
# Re-unlock vault
bw unlock

# Export new session token
export BW_SESSION="new_token_here"

# Verify
bw status
```

### Secret Not Found

**Issue:** `bw get item "secret-name"` returns nothing

**Solution:**
```bash
# 1. Sync vault
bw sync

# 2. List all items to verify name
bw list items | jq '.[] | .name'

# 3. Check spelling/case sensitivity
# Item names are case-sensitive!

# 4. Search for partial match
bw list items --search "partial-name"
```

## Limitations

### Current Limitations

**1. Local IP Required for CLI**
- **Issue:** CLI must use `http://192.168.86.249:8111` instead of domain
- **Reason:** Pangolin tunnel adds authentication layer that blocks CLI
- **Impact:** IP changes will break CLI configuration
- **Workaround:** Update `bw config server` when IPs change
- **Long-term solution:** [[tasks/backlog/IN-012-setup-local-dns-service-discovery|IN-012: Local DNS server]]

**2. Vault Unlock Requires Master Password**
- **Issue:** While login can be automated with API keys, unlocking the vault still requires interactive master password entry
- **Reason:** Vault is end-to-end encrypted with master password (security feature)
- **Impact:** Cannot fully automate secret retrieval without human interaction
- **Workaround:** Semi-automated approach - human unlocks vault, scripts run automatically
- **Status:** Acceptable for most deployment workflows (human-initiated deployments)

**3. Manual Folder Management**
- **Issue:** Folders must be created manually via web UI
- **Impact:** Can't fully automate Vaultwarden setup from scratch
- **Workaround:** Create folders once during initial setup, use CLI for managing items

**4. Organization API Keys Not Supported**
- **Issue:** Organization API keys exist in UI but only work with Directory Connector
- **Impact:** Cannot use organization API keys for general CLI automation
- **Workaround:** ✅ **SOLVED** - Use personal API keys instead (scope: `api`)
- **Note:** Personal API keys work with both personal vault folders AND organization collections!

### Planned Improvements

See [[tasks/backlog/IN-012-setup-local-dns-service-discovery|IN-012: Setup Local DNS]] for:
- Stable DNS names instead of IPs
- Seamless IP address migration
- CLI can use domain names

## Templates

### .env.example Template

```bash
# Service Name Configuration
# Generated: YYYY-MM-DD

# API Keys (stored in Vaultwarden: vm-XXX-service/service-api-key)
SERVICE_API_KEY=your_api_key_here

# Database Credentials (stored in Vaultwarden: vm-XXX-service/service-db-credentials)
DB_USERNAME=service_user
DB_PASSWORD=your_password_here

# External Service Credentials (stored in Vaultwarden: external/service-credentials)
EXTERNAL_API_KEY=your_external_key_here

# Non-secret configuration (OK to commit)
SERVICE_PORT=8080
SERVICE_HOSTNAME=service.local.infinity-node.com
```

### Secret Documentation in README

```markdown
## Secrets

This service requires the following secrets stored in Vaultwarden:

| Secret | Vaultwarden Path | Environment Variable | Purpose |
|--------|------------------|---------------------|---------|
| API Key | `vm-100-emby/emby-api-key` | `EMBY_API_KEY` | Emby API authentication |
| Admin Password | `vm-100-emby/emby-admin` | `EMBY_ADMIN_PASSWORD` | Admin panel access |

### Retrieving Secrets

\`\`\`bash
# Unlock vault
export BW_SESSION=$(bw unlock --raw)

# Retrieve secrets
EMBY_API_KEY=$(bw get password "emby-api-key")
EMBY_ADMIN_PASSWORD=$(bw get password "emby-admin")

# Create .env file
cat > .env <<EOF
EMBY_API_KEY=$EMBY_API_KEY
EMBY_ADMIN_PASSWORD=$EMBY_ADMIN_PASSWORD
EOF
\`\`\`
```

## References

- [[docs/ARCHITECTURE|Architecture]] - Infrastructure overview
- [[docs/agents/SECURITY|Security Agent]] - Security responsibilities
- [[tasks/completed/setup-vaultwarden-secret-storage|Setup Task]] - This implementation (completed)
- [[tasks/backlog/IN-012-setup-local-dns-service-discovery|IN-012]] - IP address limitation fix
- [Bitwarden CLI Documentation](https://bitwarden.com/help/cli/)
- [Vaultwarden Wiki](https://github.com/dani-garcia/vaultwarden/wiki)
