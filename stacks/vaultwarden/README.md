---
type: stack
service: vaultwarden
category: security
vms: [103]
priority: critical
status: running
stack-type: single-container
has-secrets: true
external-access: true
ports: [8111]
backup-priority: critical
created: 2025-10-26
updated: 2025-10-26
tags:
  - stack
  - vm-103
  - security
  - password-manager
  - single-container
  - has-secrets
  - external-access
  - bitwarden
aliases:
  - Vaultwarden
  - Password Manager
---

# Vaultwarden Stack

**Service:** Vaultwarden (Bitwarden-compatible password manager)
**VM:** 103 (misc)
**Priority:** Critical - Source of truth for all infrastructure secrets
**Access:** https://vaultwarden.infinity-node.com

## Overview

Vaultwarden is a lightweight, self-hosted implementation of the Bitwarden password manager. It serves as the **source of truth** for all infrastructure secrets in the infinity-node environment.

## Purpose

- **Primary:** Centralized secret storage for all infrastructure credentials
- **Secondary:** Personal password management
- **Integration:** Bitwarden CLI (`bw`) for automated secret retrieval during deployments

## Configuration

### Environment Variables

See `.env.example` for complete configuration options.

**Required:**
- `DOMAIN`: Public URL (https://vaultwarden.infinity-node.com)
- `ADMIN_TOKEN`: Admin panel authentication token
- `PORT`: Host port to expose (8111)
- `DATA_PATH`: Local directory for data storage

**Optional:**
- SMTP settings for email notifications
- Signup restrictions
- Web vault enable/disable

### Secrets

| Secret | Vaultwarden Path | Environment Variable | Purpose |
|--------|------------------|---------------------|---------|
| Admin Token | `vm-103-misc/vaultwarden-admin-token` | `ADMIN_TOKEN` | Admin panel access at /admin |

**Generating a new admin token:**
```bash
openssl rand -base64 32
```

### Volumes

- `./vw-data:/data/` - Persistent storage for:
  - SQLite database (vault data)
  - Attachments
  - Configuration
  - RSA keys

## Deployment

### Initial Setup

1. **Create .env file:**
   ```bash
   cp .env.example .env
   ```

2. **Retrieve secrets from Vaultwarden** (bootstrap problem - set manually first time):
   ```bash
   # First deployment: Set ADMIN_TOKEN manually
   # Subsequent: Retrieve from Vaultwarden
   export BW_SESSION=$(bw unlock --raw)
   ADMIN_TOKEN=$(bw get password "vaultwarden-admin-token")
   ```

3. **Deploy stack:**
   ```bash
   docker compose up -d
   ```

4. **Verify deployment:**
   ```bash
   docker compose logs -f
   curl -I http://localhost:8111
   ```

### Updating

```bash
# Pull latest image
docker compose pull

# Recreate container
docker compose up -d

# Verify
docker compose logs -f
```

## Access

### Web UI

- **Port-free (Traefik):** http://vaultwarden.local.infinity-node.win (recommended)
- **Direct access:** http://vaultwarden.local.infinity-node.win:8111
- **External (Pangolin):** https://vaultwarden.infinity-node.com (via Pangolin tunnel)
- **Admin Panel:** https://vaultwarden.infinity-node.com/admin
  - Requires `ADMIN_TOKEN` from .env

### CLI Access

**Configuration:**
```bash
# Configure Bitwarden CLI
bw config server http://vaultwarden.local.infinity-node.win:8111

# Login with API key
bw login --apikey

# Unlock vault
export BW_SESSION=$(bw unlock --raw)

# List items
bw list items
```

See [docs/SECRET-MANAGEMENT.md](../../docs/SECRET-MANAGEMENT.md) for complete CLI usage.

## Network

### Ports

- **8111:80** - HTTP interface (Vaultwarden web vault + API)

### External Access

- Exposed via **Pangolin tunnel** (newt client on VM 103)
- Domain: `vaultwarden.infinity-node.com`
- Pangolin adds authentication layer
- **Note:** CLI must use local DNS (http://vaultwarden.local.infinity-node.win:8111) due to Pangolin auth

## Dependencies

### Required Services

- None (Vaultwarden is self-contained)

### Dependent Services

- **All services** - Vaultwarden stores secrets for entire infrastructure
- **Bitwarden CLI** - For automated secret retrieval
- **Deployment scripts** - Use Vaultwarden for secret management

## Folder Structure in Vaultwarden

```
infinity-node/
├── vm-100-emby/          # Media server secrets
├── vm-101-downloads/     # Download client secrets
├── vm-102-arr/           # Media automation secrets
├── vm-103-misc/          # Supporting services secrets
│   └── vaultwarden-admin-token  ← This service's secret
├── shared/               # Cross-VM secrets
└── external/             # External service secrets
```

## Backup & Recovery

### Backup

**What to backup:**
- `./vw-data/` directory (contains SQLite database and all data)

**Backup script:**
```bash
# Stop container
docker compose stop

# Backup data directory
tar -czf vaultwarden-backup-$(date +%Y%m%d).tar.gz ./vw-data

# Start container
docker compose start
```

**Best practice:**
- Regular automated backups to NAS
- Offsite backup copy
- Test restore procedure regularly

### Recovery

```bash
# Stop existing container
docker compose down

# Restore data directory
tar -xzf vaultwarden-backup-YYYYMMDD.tar.gz

# Start container
docker compose up -d
```

## Monitoring

### Health Checks

```bash
# Check container status
docker compose ps

# View logs
docker compose logs -f

# Check web interface
curl -I http://localhost:8111
```

### Important Metrics

- **Container uptime** - Critical service
- **Disk usage** - Monitor ./vw-data size
- **API response time** - Should be fast
- **Failed login attempts** - Security monitoring

## Security

### Access Control

- **Admin panel** protected by `ADMIN_TOKEN`
- **Vault** protected by master password
- **2FA** enabled per-user
- **API keys** for automation (personal, not organization)

### Best Practices

- ✅ Use strong `ADMIN_TOKEN` (32+ characters)
- ✅ Restrict /admin access via firewall if possible
- ✅ Enable 2FA for all user accounts
- ✅ Regular backups with offsite copy
- ✅ Monitor failed login attempts
- ✅ Rotate admin token periodically

### Known Limitations

- **Organization API keys** not fully supported (only Directory Connector)
- **Personal API keys** work for CLI automation (scope: `api`)
- **CLI requires local IP** (Pangolin auth blocks domain access)

## Troubleshooting

### Container Won't Start

```bash
# Check logs
docker compose logs

# Common issues:
# - Port 8111 already in use
# - DATA_PATH directory permissions
# - Missing ADMIN_TOKEN in .env
```

### Cannot Access Web UI

```bash
# Check if container is running
docker compose ps

# Check local access
curl -I http://localhost:8111

# Check Pangolin tunnel
# (see newt container logs on VM 103)
```

### CLI Authentication Failed

```bash
# Verify server configuration
bw status

# Should show: http://vaultwarden.local.infinity-node.win:8111
# NOT https://vaultwarden.infinity-node.com

# Reconfigure if needed
bw config server http://vaultwarden.local.infinity-node.win:8111
```

## Related Documentation

- [SECRET-MANAGEMENT.md](../../docs/SECRET-MANAGEMENT.md) - Complete secret management guide
- [SECURITY.md](../../docs/agents/SECURITY.md) - Security agent responsibilities
- [ARCHITECTURE.md](../../docs/ARCHITECTURE.md) - Infrastructure overview

## Notes

- **Bootstrap Problem:** First deployment requires manual `ADMIN_TOKEN` setup, then store in Vaultwarden
- **Source of Truth:** This service stores secrets for all other services
- **Critical Service:** Downtime affects deployment automation but not running services
- **Portainer Integration:** This stack can be managed via Portainer git integration
