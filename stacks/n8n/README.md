---
type: stack
service: n8n
category: automation
vms: [103]
priority: medium
status: pending
stack-type: multi-container
has-secrets: true
external-access: false
ports: [5678]
backup-priority: high
created: 2025-12-12
updated: 2025-12-12
tags:
  - stack
  - vm-103
  - automation
  - workflow
  - multi-container
  - has-secrets
  - postgresql
  - integrations
  - webhooks
aliases:
  - n8n
  - Workflow Automation
---

# n8n Stack

**Service:** n8n (Workflow Automation)
**VM:** 103 (misc)
**Priority:** Medium - Automation/integration platform
**Access:** https://n8n.local.infinity-node.win (via Traefik)
**Image:** `docker.n8n.io/n8nio/n8n:latest`

## Overview

n8n is a free and source-available workflow automation tool. It allows you to connect different services and automate workflows between them. Similar to Zapier or Make, but self-hosted with full control over your data.

## Key Features

- **Visual Workflow Builder:** Drag-and-drop interface for creating automations
- **400+ Integrations:** Connect to popular services and APIs
- **Code Flexibility:** Add custom JavaScript/Python when needed
- **Webhook Support:** Trigger workflows from external events
- **Scheduling:** Run workflows on schedules (cron)
- **Self-Hosted:** Full data sovereignty
- **Credential Storage:** Secure encrypted storage for API keys

## Architecture

Multi-container stack:
- **n8n:** Main application (workflow engine + UI)
- **postgres:** Database for workflow data, credentials, and execution history

## Configuration

### Secrets

**Required secrets stored in Vaultwarden:**

1. **N8N_ENCRYPTION_KEY** - Encrypts stored credentials
   - Location: `infinity-node/vm-103-misc/n8n-secrets`
   - Field: `encryption_key`
   - Generate: `openssl rand -hex 32`
   - **CRITICAL:** If lost, all stored credentials must be re-entered

2. **POSTGRES_PASSWORD** - PostgreSQL database password
   - Location: `infinity-node/vm-103-misc/n8n-secrets`
   - Field: `postgres_password`
   - Generate: `openssl rand -base64 24 | tr -d '=/+' | head -c 24`

**Store in Vaultwarden:**

```bash
export BW_SESSION=$(cat ~/.bw-session)

# Generate secrets
ENCRYPTION_KEY=$(openssl rand -hex 32)
POSTGRES_PASSWORD=$(openssl rand -base64 24 | tr -d '=/+' | head -c 24)

# Create Vaultwarden entry
./scripts/secrets/create-vw-secret.sh "n8n-secrets" "shared" "" \
  "{\"service\":\"n8n\",\"vm\":\"103\",\"encryption_key\":\"$ENCRYPTION_KEY\",\"postgres_password\":\"$POSTGRES_PASSWORD\"}"
```

**Retrieve from Vaultwarden:**

```bash
export BW_SESSION=$(cat ~/.bw-session)
N8N_ENCRYPTION_KEY=$(./scripts/secrets/get-vw-secret.sh "n8n-secrets" "shared" "encryption_key")
POSTGRES_PASSWORD=$(./scripts/secrets/get-vw-secret.sh "n8n-secrets" "shared" "postgres_password")
```

### Volumes

**Data Storage:**
- `n8n_data` → `/home/node/.n8n` - n8n configuration, custom nodes
- `pgdata` → `/var/lib/postgresql/data` - PostgreSQL database

### Environment Variables

**Core Settings:**
- `TZ` - Timezone (default: `America/Chicago`)
- `N8N_HOST` - Host for UI display (default: `n8n.local.infinity-node.win`)
- `WEBHOOK_URL` - Full webhook URL including protocol
- `N8N_ENCRYPTION_KEY` - Credential encryption key (secret)
- `POSTGRES_PASSWORD` - PostgreSQL password (secret)

**Database Settings:**
- `POSTGRES_USER` - PostgreSQL user (default: `n8n`)
- `POSTGRES_DB` - PostgreSQL database name (default: `n8n`)

**Optional Performance:**
- `N8N_RUNNERS_ENABLED` - Enable task runners (default: `false`)

See `.env.example` for all configuration options.

## Deployment

### Prerequisites

1. **DNS Entry:** Add `n8n.local.infinity-node.win` pointing to VM-103 (192.168.1.103) in Pi-hole
2. **Traefik:** Ensure Traefik is running on VM-103 and `dynamic.yml` includes n8n route
3. **Secrets:** Generate and store secrets in Vaultwarden

### Deploy via Git Stack Script

```bash
# 1. Create .env file on VM-103
ssh evan@192.168.1.103

# Generate secrets (if not already in Vaultwarden)
ENCRYPTION_KEY=$(openssl rand -hex 32)
POSTGRES_PASSWORD=$(openssl rand -base64 24 | tr -d '=/+' | head -c 24)

# Create .env file
cat > /home/evan/stacks/n8n/.env << EOF
TZ=America/Chicago
N8N_HOST=n8n.local.infinity-node.win
WEBHOOK_URL=https://n8n.local.infinity-node.win
N8N_ENCRYPTION_KEY=$ENCRYPTION_KEY
POSTGRES_PASSWORD=$POSTGRES_PASSWORD
POSTGRES_USER=n8n
POSTGRES_DB=n8n
EOF

exit

# 2. Deploy via Portainer Git stack
export BW_SESSION=$(cat ~/.bw-session)

./scripts/infrastructure/create-git-stack.sh \
  "portainer-api-token-vm-103" \
  "shared" \
  3 \
  "n8n" \
  "stacks/n8n/docker-compose.yml" \
  --env-file /home/evan/stacks/n8n/.env
```

### Redeploy After Changes

```bash
export BW_SESSION=$(cat ~/.bw-session)

./scripts/infrastructure/redeploy-git-stack.sh \
  --secret "portainer-api-token-vm-103" \
  --stack-name "n8n"
```

Or via Portainer UI: Stacks → n8n → "Pull and redeploy"

## Initial Setup

1. **Access Web UI:** Navigate to https://n8n.local.infinity-node.win
2. **Create Owner Account:** First user becomes the owner
3. **Explore Templates:** Browse workflow templates for inspiration
4. **Add Credentials:** Store API keys for services you want to connect
5. **Create First Workflow:** Start with a simple automation

## Usage

### Creating Workflows

1. **New Workflow:** Click "New Workflow" button
2. **Add Trigger:** Start with a trigger node (webhook, schedule, etc.)
3. **Add Nodes:** Connect service nodes to process data
4. **Configure:** Set up each node with credentials and parameters
5. **Test:** Run manually to verify
6. **Activate:** Enable workflow for automatic execution

### Common Use Cases

- **Data Sync:** Sync data between services
- **Notifications:** Send alerts based on events
- **Data Processing:** Transform and route data
- **API Integration:** Connect disparate systems
- **Scheduled Tasks:** Run periodic jobs
- **Webhook Handlers:** Process incoming webhooks

### Webhook URLs

Workflows with webhook triggers get URLs like:
```
https://n8n.local.infinity-node.win/webhook/<workflow-id>
```

## Monitoring

```bash
# View n8n logs
ssh evan@192.168.1.103 "docker logs -f n8n"

# View database logs
ssh evan@192.168.1.103 "docker logs -f n8n_postgres"

# Check container health
ssh evan@192.168.1.103 "docker ps --filter name=n8n"

# Check execution history in UI
# Navigate to Executions tab in n8n UI
```

## Backup

**Critical data to backup:**
- `pgdata` volume - All workflow definitions, credentials, execution history
- `n8n_data` volume - Custom nodes, configuration

```bash
# Backup database
ssh evan@192.168.1.103 "docker exec n8n_postgres pg_dump -U n8n n8n > n8n-backup.sql"

# Restore database
ssh evan@192.168.1.103 "docker exec -i n8n_postgres psql -U n8n n8n < n8n-backup.sql"
```

## Troubleshooting

**Cannot access UI:**
- Verify Traefik is running and healthy
- Check DNS resolution for `n8n.local.infinity-node.win`
- Check n8n container logs for errors
- Verify `dynamic.yml` has correct n8n route

**Workflows not executing:**
- Check execution history for errors
- Verify credentials are valid
- Check webhook URLs are accessible
- Review workflow activation status

**Database connection errors:**
- Verify postgres container is healthy
- Check `POSTGRES_PASSWORD` matches between services
- Review postgres logs for connection issues

**Credentials not working after restore:**
- Ensure `N8N_ENCRYPTION_KEY` is the same as original
- Re-enter credentials if key was lost/changed

## Security Considerations

- **Encryption Key:** Back up securely - losing it means re-entering all credentials
- **Credential Storage:** All API keys encrypted at rest
- **Webhook Security:** Consider using webhook authentication
- **Network:** Only accessible on local network via Traefik
- **User Management:** First user is owner with full permissions

## Dependencies

- **PostgreSQL:** Required for data persistence
- **Traefik:** For HTTPS routing via `n8n.local.infinity-node.win`
- **Pi-hole:** DNS resolution for local domain

## Related Documentation

- [Official n8n Docs](https://docs.n8n.io/)
- [n8n Community](https://community.n8n.io/)
- [Workflow Templates](https://n8n.io/workflows/)
- [Integration List](https://n8n.io/integrations/)

## Notes

- Multi-container stack (n8n + postgres)
- PostgreSQL provides durable storage for workflows and execution history
- Encryption key is critical for credential access - back it up
- Web UI runs on port 5678 (exposed via Traefik)
- Webhook URL must match Traefik host for external integrations
- Consider backup automation for postgres volume (future task)
