---
type: stack
service: komga
category: media
vms: [103]
priority: medium
status: planned
stack-type: single-container
has-secrets: false
external-access: false
ports: [25600]
backup-priority: medium
created: 2025-11-16
updated: 2025-11-16
tags:
  - komga
  - comics
  - vm-103
aliases:
  - Komga
  - Comic Server
  - Comic Reader
---

# Komga Stack

**Service:** Komga (Comic book manager)
**VM:** 103 (misc)
**Priority:** Medium – Enhances the household comic library
**Access:** `http://vm-103.local.infinity-node.com:25600` (direct)
**Image:** `gotson/komga:latest`

## Overview

Komga is a modern comic book server that indexes and serves comic/Manga collections over the LAN. This stack follows the existing VM-103 pattern: configuration lives on the VM disk under `/home/evan/data`, while the actual media library is stored on the Synology NAS and mounted read/write into the container.

## Configuration Summary

| Component | Path / Value | Notes |
| --- | --- | --- |
| Config | `/home/evan/data/komga/config` | Persistent application settings and database |
| Library | `/mnt/video/Komga` → `/data` | Mounted NAS share already used by other media services |
| UID / GID | `1000:1000` | Matches the service account on VM-103 |
| Port | `25600 → 25600` | Direct access for now (future Traefik task planned) |
| Memory limit | `1G` | JVM heap tuned via `KOMGA_JAVA_TOOL_OPTIONS` |

## Secrets

Komga does not require any secrets stored in Vaultwarden for MVP. If SMTP, metadata provider tokens, or other credentials are needed later, add the entries to the `vm-103-misc` collection and document them in `.env.example`.

## Deployment

1. Copy `.env.example` → `.env` and fill in any overrides (timezone, paths, optional java tuning). Keep secrets out of git.
2. Commit the stack files (`docker-compose.yml`, `.env.example`, `README.md`) and push to the repo.
3. In Portainer on VM-103, create or update the Git-integrated stack:
   - Repository: `https://github.com/evanstern/infinity-node`
   - Reference: `main`
   - Compose path: `stacks/komga/docker-compose.yml`
4. Provide the stack with the `.env` variables from step 1 (use Vaultwarden as needed for future secrets).
5. Deploy the stack and ensure the container starts without restarting.
6. Once healthy, document the deployment status and next steps in the task log.

## Initial Setup on VM-103

```bash
# Ensure persistent config directory exists
ssh evan@vm-103 'mkdir -p /home/evan/data/komga/config && chown -R 1000:1000 /home/evan/data/komga'

# Verify NAS share for comics is mounted and writable
ssh evan@vm-103 'stat /mnt/video/Komga'
```

If `/mnt/video/Komga` is not mounted, consult the NAS share documentation (`docs/ARCHITECTURE.md`) or follow existing mounts used by other stacks (e.g., `stacks/kavita`).

## Library Indexing

After deployment:

1. Browse to `http://vm-103.local.infinity-node.com:25600/`.
2. Create the initial Komga admin account (store credentials in Vaultwarden `vm-103-misc/komga-admin`).
3. Under **Libraries**, add the folders reachable from `/data`.
4. Trigger a scan and watch the logs (`docker logs -f komga`) for permission issues.

## Validation & Monitoring

- `docker ps` on VM-103 should show `komga` running.
- Komga web UI returns HTTP `200`.
- Library scan completes without permission errors.
- Monitor `docker logs komga` for startup exceptions (e.g., database upgrade issues).

## Related Documentation

- [[docs/agents/DOCKER|Docker Agent Guidance]]
- [[docs/SECRET-MANAGEMENT|Secrets]] (for future SMTP/credentials)
- [[stacks/README|Stacks Directory Overview]]
- [[tasks/current/IN-055-setup-komga-docker-stack|Task IN-055]]
