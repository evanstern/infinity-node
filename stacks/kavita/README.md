---
type: stack
service: kavita
category: media
vms: [103]
priority: medium
status: planned
stack-type: single-container
has-secrets: true
external-access: false
ports: [5750]
backup-priority: high
created: 2025-11-15
updated: 2025-11-15
tags:
  - stack
  - vm-103
  - media
  - ebooks
  - comics
  - lsio
aliases:
  - Kavita
  - Comics Reader
  - Ebook Reader
---

# Kavita Stack

**Service:** Kavita (Comics & Ebook Reader)
**VM:** 103 (misc)
**Priority:** Medium – Improves household reading experience
**Access:** `https://kavita.local.infinity-node.com` (Traefik) or `http://vm-103.local.infinity-node.com:5750` (direct/debug)
**Image:** `lscr.io/linuxserver/kavita:latest`

## Overview

Kavita is a self-hosted platform for reading and organizing digital libraries (Comics, Manga, Light Novels, and standard ebooks). This stack follows the LinuxServer.io pattern used across VM-103, keeping configuration on the NAS and routing traffic through Traefik.

## Configuration Summary

| Component | Path/Value | Notes |
| --- | --- | --- |
| Config | `/home/evan/data/kavita/config` | Local VM-103 disk (rsynced to NAS for backups) |
| Library | `/mnt/video/Kavita/library` → `/library` (ro) | Dedicated NAS share to avoid Calibre clutter |
| UID/GID | `1000:1000` | Match VM-103 service accounts |
| Port | `5750 -> 5000` | Host port optional (Traefik handles normal access) |
| Network | `traefik-network` | Required for routing |

## Secrets

Manage secrets per [[docs/SECRET-MANAGEMENT]]:

| Secret | Vaultwarden Location | Notes |
| --- | --- | --- |
| `kavita/admin` | Collection `vm-103-misc` | Store initial admin username/password created during onboarding |
| `kavita/smtp` | Collection `vm-103-misc` | Optional SMTP credentials referenced by `.env` (commented placeholders) |
| `kavita/opds` | Collection `vm-103-misc` | Optional application tokens/API keys if OPDS enabled |

Include reference URLs and notes (Traefik hostname, Portainer stack name) inside the Vaultwarden items.

### Environment Variables

See `.env.example` for full list. Set the following before deployment:

- `PUID` / `PGID` – Service account IDs (typically 1000 on VM-103)
- `TZ` – Timezone
- `CONFIG_PATH` – Persistent config directory on NAS
- `LIBRARY_PATH` – Read-only library root (subfolders for Comics/Manga/Books)
- `PORT` – Host port (if direct access desired)
- Optional SMTP settings: uncomment in `.env` and source secrets from Vaultwarden

### Volumes

- `${CONFIG_PATH}:/config`
- `${LIBRARY_PATH}:/library:ro`

Create storage directories:

```bash
ssh evan@vm-103 'mkdir -p /home/evan/data/kavita/config && chown -R 1000:1000 /home/evan/data/kavita'
mkdir -p /Volumes/media/Kavita/library
```

Keep `/library` read-only. Kavita manages metadata internally under `/config`.

## Deployment

1. Copy `.env.example` → `.env` and adjust values (paths, timezone, optional SMTP).
2. Store any sensitive values (SMTP credentials, admin bootstrap notes) in Vaultwarden collection `vm-103-misc`.
3. Commit stack changes, then deploy via Portainer Git stack (`kavita`) on VM-103.
4. After container is healthy, add Traefik router entry (`kavita.local.infinity-node.com`) in `stacks/traefik/vm-103/dynamic.yml` if not already present.
5. Validate via Traefik URL and document results in the task log.

## Initial Setup

1. Browse to `https://kavita.local.infinity-node.com`.
2. Create the initial admin account (store credentials in Vaultwarden).
3. Configure libraries under **Server Settings → Libraries**, pointing to directories under `/library` (e.g., `/library/Books`, `/library/Comics`).
4. Optionally configure metadata providers and OPDS.
5. Run a full library scan; monitor container logs for file permission errors.

## Backup & Recovery

- **Must backup:** `/home/evan/data/kavita/config`
- Schedule rsync/restic job to copy config to `/mnt/video/Kavita/config` nightly before upgrades or stack changes.
- Rollback procedure: remove/disable stack in Portainer (volumes preserved), revert compose/env changes in git, redeploy previous commit.

## Monitoring & Health

- Healthcheck queries `http://localhost:5000/` every 30s so Portainer/Watchtower reflect status.
- Logs available via `docker logs -f kavita` or Portainer console.
- Add HTTP probes to the Testing Agent checklist (`docs/agents/TESTING.md`) once deployed.

## Security Notes

- Service initially exposed to LAN only through Traefik (`web` entrypoint).
- External/Pangolin exposure handled by follow-up task IN-052.
- Admin credentials and SMTP secrets belong in Vaultwarden; never commit `.env` with real values.

## Related Documentation

- [[docs/agents/MEDIA]]
- [[docs/runbooks/pihole-dns-management]]
- [[docs/SECRET-MANAGEMENT]]
- [[tasks/archived/IN-052-expose-kavita-external-access]]
