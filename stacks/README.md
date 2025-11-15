# Infinity-Node Docker Stacks

This directory contains all Docker Compose configurations for services running across the infinity-node infrastructure.

## Overview

All stacks are version controlled in git and deployed via Portainer's Git integration. Secrets are stored in Vaultwarden and injected via `.env` files during deployment.

## Architecture

```
Git Repository (Source of Truth)
  ↓
Vaultwarden (Secrets)
  ↓
Portainer (Management & Deployment)
  ↓
Docker Containers (Runtime)
```

## Directory Structure

```
stacks/
├── vaultwarden/          # VM 103 - Password manager
├── paperless-ngx/        # VM 103 - Document management
├── kavita/               # VM 103 - Comics & ebook reader
├── portainer/            # All VMs - Docker management UI
└── README.md            # This file
```

## Current Import Status

**Phase 1: VM 103 Priority Stacks** ✅
- [x] vaultwarden
- [x] paperless-ngx
- [x] portainer

**Phase 2: Remaining VM 103 Stacks** (Pending)
- [ ] immich
- [ ] linkwarden
- [ ] audiobookshelf
- [ ] kavita
- [ ] homepage
- [ ] navidrome
- [ ] watchtower
- [ ] Other misc services

**Phase 3: Other VMs** (Pending)
- [ ] VM 100 (emby) stacks
- [ ] VM 102 (arr) stacks
- [ ] VM 101 (downloads) stacks

## Stack Structure

Each stack directory contains:
- **docker-compose.yml** - Service configuration
- **.env.example** - Environment variable template with Vaultwarden references
- **README.md** - Service documentation

## Deployment Workflow

### Option A: Via Portainer Git Integration (Recommended)

Portainer can automatically deploy and update stacks from this Git repository. This is the recommended approach for production operations.

**Initial Configuration:**

1. **Access Portainer** on your VM (e.g., http://portainer-103.local.infinity-node.com or http://portainer-103.local.infinity-node.com:9000)
2. **Navigate to Stacks** → Add stack
3. **Select "Repository"** as the build method
4. **Configure Git settings:**
   - **Repository URL:** `https://github.com/evanstern/infinity-node`
   - **Repository reference:** `main` (or specific branch/tag)
   - **Compose file path:** `stacks/<service-name>/docker-compose.yml`
   - **Authentication:** Configure if using private repo
5. **Configure Environment Variables:**
   - Add required environment variables from `.env.example`
   - Retrieve secret values from Vaultwarden using scripts:
     ```bash
     export BW_SESSION=$(bw unlock --raw)
     bw get item <secret-name>
     ```
6. **Enable GitOps Updates (Optional):**
   - **Polling:** Auto-check for updates on interval (e.g., every 5 minutes)
   - **Webhook:** Generate webhook URL for on-demand deployments
   - **Force redeployment:** Ensure Git is always source of truth
7. **Deploy the stack**

**Example Configuration:**
```
Stack name:         vaultwarden
Repository URL:     https://github.com/evanstern/infinity-node
Reference:          main
Compose path:       stacks/vaultwarden/docker-compose.yml
GitOps polling:     Enabled (5 minute interval)
Force redeploy:     Enabled
```

**Automated via API:**

See [tasks/current/migrate-portainer-to-monorepo.md](../tasks/current/migrate-portainer-to-monorepo.md) for scripted migration from individual repos to this monorepo.

**Benefits:**
- Automatic updates when Git changes
- Infrastructure as Code
- Easy rollbacks via Git history
- Centralized management
- Disaster recovery ready

### Option B: Via Script (Recommended for Automation/DR)

```bash
# Deploy with secrets from Vaultwarden
./scripts/deploy-with-secrets.sh <service> <vm-ip> <stack-path>

# Example:
./scripts/deploy-with-secrets.sh vaultwarden vm-103.local.infinity-node.com /home/evan/projects/infinity-node/stacks/vaultwarden
```

### Option C: Manual Deployment

```bash
cd stacks/<service-name>

# Create .env from template
cp .env.example .env

# Retrieve secrets from Vaultwarden
export BW_SESSION=$(bw unlock --raw)
SECRET=$(bw get password "secret-name")

# Edit .env with actual values
vim .env

# Deploy
docker compose up -d
```

## Secret Management

All secrets are stored in Vaultwarden under organized folders:

```
infinity-node/
├── vm-100-emby/
├── vm-101-downloads/
├── vm-102-arr/
├── vm-103-misc/
│   ├── vaultwarden-admin-token
│   ├── paperless-secrets
│   └── ...
├── shared/
└── external/
```

**See:** [docs/SECRET-MANAGEMENT.md](../docs/SECRET-MANAGEMENT.md)

## Adding a New Stack

1. Create directory: `stacks/<service-name>/`
2. Add `docker-compose.yml`
3. Create `.env.example` with Vaultwarden references
4. Document in `README.md`
5. Store secrets in Vaultwarden
6. Commit to git
7. Deploy via Portainer or script

## Validation

Before committing changes:

```bash
# Validate docker-compose syntax
cd stacks/<service-name>
docker compose config

# Check for secrets
git diff | grep -iE "(password|secret|token|key).*="

# Ensure .env files are gitignored
git check-ignore .env
```

## Related Documentation

- [ARCHITECTURE.md](../docs/ARCHITECTURE.md) - Infrastructure overview
- [SECRET-MANAGEMENT.md](../docs/SECRET-MANAGEMENT.md) - Secret management guide
- [DOCKER Agent](../docs/agents/DOCKER.md) - Docker best practices
- [Task: Import Existing Docker Configs](../tasks/current/import-existing-docker-configs.md)

## Notes

- `.env` files are NEVER committed (gitignored)
- `.env.example` files document required variables with Vaultwarden references
- All secrets reference their Vaultwarden location
- Portainer Git integration planned for automated deployments
- This is Infrastructure as Code - git is source of truth
