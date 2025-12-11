---
type: stack
service: paperless-ngx
category: productivity
vms: [103]
priority: high
status: running
stack-type: multi-container
has-secrets: true
external-access: true
ports: [8000, 3010]
backup-priority: high
created: 2025-10-26
updated: 2025-11-18
tags:
  - stack
  - vm-103
  - productivity
  - documents
  - multi-container
  - has-secrets
  - external-access
  - ocr
  - postgresql
  - redis
aliases:
  - Paperless-NGX
  - Paperless
  - Document Manager
---

# Paperless-NGX Stack

**Service:** Paperless-NGX (Document Management System)
**VM:** 103 (misc)
**Priority:** Important - Personal document management
**Access:** http://paperless.local.infinity-node.win (port-free via Traefik) or http://paperless.local.infinity-node.win:8000 (direct) or https://paperless.infinity-node.com (external via Pangolin)

## Overview

Paperless-NGX is a document management system that transforms physical documents into searchable online archives. It uses OCR, automatic tagging, and machine learning for document organization.

## Architecture

Multi-container stack:
- **webserver** - Main Paperless-NGX application
- **db** - PostgreSQL database
- **broker** - Redis message queue
- **gotenberg** - PDF rendering engine
- **tika** - Document parsing and OCR
- **paperless-ai** - Semantic search UI (clusterzx/paperless-ai) connected to Paperless via RAG endpoint

## Configuration

### Secrets

| Secret | Vaultwarden Path | Environment Variable | Purpose |
|--------|------------------|---------------------|---------|
| Database Password | `vm-103-misc/paperless-secrets` | `POSTGRES_PASSWORD` | PostgreSQL auth |
| Secret Key | `vm-103-misc/paperless-secrets` | `PAPERLESS_SECRET_KEY` | Django encryption |
| Admin Password | `vm-103-misc/paperless-secrets` | `PAPERLESS_ADMIN_PASSWORD` | Initial admin login |

### Volumes

- `./data` - Application data
- `./media` - Stored documents
- `./export` - Document exports
- `./consume` - Incoming documents (watch folder)
- `./pgdata` - PostgreSQL database
- `./redisdata` - Redis persistence
- `paperless-ai-data` - AI embeddings + cache

### Paperless AI

- **UI Port:** http://vm103:3010 (LAN) — consider Traefik routing later for HTTPS.
- **Image:** `clusterzx/paperless-ai`
- **Env:** `PUID`, `PGID`, and `PAPERLESS_AI_PORT` (default `3010`, configurable in `.env`)
- **Data:** Stored in the `paperless-ai-data` named volume.
- **RAG Endpoint:** Talks to `webserver:8000` internally; no extra secrets required.
- **Vaultwarden:** Add the new env keys to the `paperless-secrets` item (notes section) so operators know to populate them in `.env`.

## Deployment

```bash
# Create .env file
cp .env.example .env

# Retrieve secrets from Vaultwarden
export BW_SESSION=$(bw unlock --raw)
POSTGRES_PASSWORD=$(bw get item "paperless-secrets" | jq -r '.fields[] | select(.name=="postgres_password") | .value')
# ... set other secrets

# Deploy
docker compose up -d

# Create superuser (if needed)
docker compose run --rm webserver createsuperuser
```

> **Redeploy via Portainer:** After updating compose/env files for paperless-ai, use the existing Git-connected stack in Portainer (VM 103) and click **Pull and redeploy** so the new container is created with injected environment variables.

## Access

- **Web UI:** https://paperless.infinity-node.com
- **Local:** http://paperless.local.infinity-node.win:8000
- **Paperless AI UI:** http://vm103:3010 (or via Pangolin tunnel)

## Network

- **Port 8001:8000** - Web interface
- **Port 3010:3010** - Paperless AI semantic search UI

## Related Documentation

- [Paperless-NGX Docs](https://docs.paperless-ngx.com/)
- [SECRET-MANAGEMENT.md](../../docs/SECRET-MANAGEMENT.md)
