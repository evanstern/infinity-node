# Paperless-NGX Stack

**Service:** Paperless-NGX (Document Management System)
**VM:** 103 (misc)
**Priority:** Important - Personal document management
**Access:** https://paperless.infinity-node.com (via Pangolin)

## Overview

Paperless-NGX is a document management system that transforms physical documents into searchable online archives. It uses OCR, automatic tagging, and machine learning for document organization.

## Architecture

Multi-container stack:
- **webserver** - Main Paperless-NGX application
- **db** - PostgreSQL database
- **broker** - Redis message queue
- **gotenberg** - PDF rendering engine
- **tika** - Document parsing and OCR

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

## Access

- **Web UI:** https://paperless.infinity-node.com
- **Local:** http://192.168.86.249:8001

## Network

- **Port 8001:8000** - Web interface

## Related Documentation

- [Paperless-NGX Docs](https://docs.paperless-ngx.com/)
- [SECRET-MANAGEMENT.md](../../docs/SECRET-MANAGEMENT.md)
