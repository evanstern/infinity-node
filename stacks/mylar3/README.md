---
type: stack
service: mylar3
category: media
vms: [101]
priority: medium
status: planned
stack-type: single-container
has-secrets: false
external-access: false
ports: [8085]
backup-priority: medium
created: 2025-11-16
updated: 2025-11-16
tags:
  - mylar3
  - downloads
  - comics
  - automation
aliases:
  - Mylar3
  - Comic Automation
  - Comic Metadata
---

# Mylar3 Stack (VM 101)

**Image Reference:** [LinuxServer Mylar3](https://docs.linuxserver.io/images/docker-mylar3/)

## Overview

Mylar3 is a comic-focused metadata manager that orchestrates downloads (NZB/torrent) and keeps series organized alongside the download clients on VM 101. The LinuxServer image provides a consistent environment (PUID/PGID/TZ + `/config`, `/comics`, `/downloads` volumes) so the stack can lean on VM-101 storage conventions while remaining reproducible via Portainer's Git integration.

## Configuration Summary

| Component | Value | Notes |
| --- | --- | --- |
| Config | `/home/evan/data/mylar3/config` | Persistent state (databases, settings, credentials) stored on VM-101 |
| Comics root | `/mnt/video/Comics` | Read/write folder for scraped/completed releases |
| Downloads | `/mnt/downloads` | Shared sink for download clients and ARR services if desired |
| UID / GID | `1000:1000` | Matches service account on VM-101 |
| Port | `8085 → 8090` | Host port 8085 routes to the Mylar3 UI (internal port 8090) |
| Memory limit | `512M` | Enforced by Portainer deploy resources |

## Secrets

None required for the MVP. If indexer/torrent credentials or API tokens are added later, store them in the appropriate Vaultwarden collection for VM-101 downloads and reference them from the deployed `.env` file.

## Deployment

1. Copy `.env.example` → `.env` on the downloads VM and adjust values (timezone, mount points, optional memory limits).
2. Commit `stacks/mylar3/` files to git.
3. In Portainer on VM-101:
   - Create or update the stack pointing to `stacks/mylar3/docker-compose.yml`.
   - Load variables from `.env`.
   - Deploy and ensure the container reaches `starting` → `running`.
4. Once running, log health in the task (see `tasks/current/IN-057-setup-mylar3-docker-stack.md`).

## Initial Setup on VM-101

```bash
ssh evan@vm-101 'mkdir -p /home/evan/data/mylar3/config && mkdir -p /mnt/video/Comics && mkdir -p /mnt/downloads && chown -R 1000:1000 /home/evan/data/mylar3 /mnt/video/Comics /mnt/downloads'
```

Ensure the NAS share for `/mnt/video/Comics` and the downloads share `/mnt/downloads` are mounted before creating the directories. Adjust chown/chmod as necessary for compatibility with the download services.

## Validation & Monitoring

- `docker compose config` (locally) passes before committing.
- Portainer stack shows the `mylar3` container running.
- `http://vm-101.local.infinity-node.win:8085` returns the login/setup UI (HTTP 200).
- Container logs (`docker logs mylar3`) show clean startup and binder for the configured downloads/comics folders.
- Restart container to verify configuration and data persist in the mapped volumes.

## Related Documentation

- [[docs/agents/DOCKER|Docker Agent]] – Portainer/compose guidance
- [[stacks/README|Stacks Directory Overview]]
- [LinuxServer Mylar3 Reference](https://docs.linuxserver.io/images/docker-mylar3/)
