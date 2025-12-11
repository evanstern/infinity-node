---
type: stack
service: portainer
category: infrastructure
vms: [100, 101, 102, 103]
priority: important
status: running
stack-type: single-container
has-secrets: false
external-access: false
ports: [8000, 9000, 9443]
backup-priority: medium
created: 2025-10-26
updated: 2025-10-26
tags:
  - stack
  - vm-100
  - vm-101
  - vm-102
  - vm-103
  - infrastructure
  - docker-management
  - single-container
  - no-secrets
  - web-ui
aliases:
  - Portainer
  - Docker UI
---

# Portainer Stack

**Service:** Portainer CE (Docker Management UI)
**VM:** 100, 101, 102, 103 (all VMs)
**Priority:** Important - Primary management interface
**Access:**
- VM 100: http://portainer-100.local.infinity-node.win (port-free via Traefik) or http://portainer-100.local.infinity-node.win:9000 (direct)
- VM 101: http://portainer-101.local.infinity-node.win (port-free via Traefik) or http://portainer-101.local.infinity-node.win:32768 (direct, non-standard port)
- VM 102: http://portainer-102.local.infinity-node.win (port-free via Traefik) or http://portainer-102.local.infinity-node.win:9000 (direct)
- VM 103: http://portainer-103.local.infinity-node.win (port-free via Traefik) or http://portainer-103.local.infinity-node.win:9000 (direct)

## Overview

Portainer provides a web-based UI for managing Docker containers, images, volumes, and networks. Deployed on each VM for local Docker management.

## Configuration

### Secrets

None - Portainer manages authentication internally.

### Volumes

- `/var/run/docker.sock` - Docker API access
- `./data` - Portainer persistent data

## Deployment

```bash
docker compose up -d
```

## Access

- **Port 8000** - HTTP API
- **Port 9000** - Main web UI
- **Port 9443** - HTTPS (if SSL configured)

## Related Documentation

- [Portainer Docs](https://docs.portainer.io/)
