---
type: stack
service: fail2ban
category: security
vms: [103]
priority: high
status: running
stack-type: single-container
has-secrets: false
external-access: false
ports: []
backup-priority: medium
created: 2025-11-13
updated: 2025-11-13
tags:
  - stack
  - vm-103
  - security
  - fail2ban
---

# Fail2ban Stack

**Service:** Fail2ban (Intrusion Prevention)
**VM:** 103 (misc)
**Purpose:** Automatically block repeated failed authentication attempts against Navidrome (and other HTTP services) before Navidrome is exposed directly to the internet.

## Overview

This stack deploys the LinuxServer.io `fail2ban` container under Portainer GitOps. Configuration lives in `stacks/fail2ban/config/` inside the repo, so Portainer’s Git redeploy keeps the jail/filter files in sync automatically. Fail2ban consumes Traefik JSON access logs and Navidrome’s mirrored stdout file to detect repeated authentication failures. Bans are applied via `iptables` in the `DOCKER-USER` chain so Docker-managed services inherit the rules.

## Volumes

| Host Path                         | Container Path               | Purpose                                         |
|-----------------------------------|------------------------------|-------------------------------------------------|
| `./config`                        | `/config`                    | Jail/filter/action configuration (Git-managed) |
| `/var/log`                        | `/var/log:ro`                | Access to system logs (fail2ban.log, etc.)      |
| `/home/evan/logs/traefik`         | `/remotelogs/traefik:ro`     | Traefik access logs (JSON)                      |
| `/home/evan/data/navidrome/logs`  | `/remotelogs/navidrome:ro`   | Navidrome auth logs mirrored via `tee` (VM-103) |
| `/home/evan/projects/infinity-node/stacks/emby/config/logs` | `/remotelogs/emby:ro` | Emby server logs (VM-100) |

## Environment Variables

| Variable            | Default            | Description                                |
|---------------------|--------------------|--------------------------------------------|
| `PUID`              | `1000`             | Host user ID for file ownership            |
| `PGID`              | `1000`             | Host group ID                              |
| `TZ`                | `America/Toronto`  | Local timezone                             |
| `TRAEFIK_LOG_PATH`  | `/home/evan/logs/traefik`    | Host directory for Traefik access logs |
| `NAVIDROME_LOG_PATH`| `/home/evan/data/navidrome/logs` | Host directory for Navidrome logs |
| `EMBY_LOG_PATH`     | `/home/evan/.config/fail2ban/unused` | Host directory for Emby logs (override on VM-100) |

Populate these values in `stacks/fail2ban/.env` before deployment (see `.env.example`).

## Deployment

> **Note:** The Navidrome stack has been updated to mirror stdout into `/data/logs/navidrome.log` using `tee`, so this stack can read login failures directly from that file.

1. Ensure host log directories exist on the target VM:
   ```bash
   sudo mkdir -p /home/evan/logs/traefik
   sudo mkdir -p /home/evan/data/navidrome/logs                          # VM-103
   sudo mkdir -p /home/evan/projects/infinity-node/stacks/emby/config/logs # VM-100
   sudo mkdir -p /home/evan/.config/fail2ban/unused
   sudo chown -R evan:evan /home/evan/logs/traefik /home/evan/data/navidrome/logs /home/evan/projects/infinity-node/stacks/emby/config/logs /home/evan/.config/fail2ban
   ```
2. Copy `.env.example` to `.env` and adjust if needed (set `EMBY_LOG_PATH` on VM-100, leave pointing to `/home/evan/.config/fail2ban/unused` elsewhere).
3. Commit configuration changes and trigger Portainer "Pull and redeploy" for stack `fail2ban` (or create a new stack via `create-git-stack.sh` on VM-100 if running multi-instance).

## Validation

- Check container health: `docker ps | grep fail2ban`
- View logs: `docker logs -f fail2ban`
- Verify jails: `docker exec fail2ban fail2ban-client status`
- Confirm bans after simulated failures: `docker exec fail2ban fail2ban-client status navidrome`

## Related Documentation

- [[stacks/fail2ban/config/README|Fail2ban configuration reference]]
- [[docs/runbooks/emby-external-access-security|Emby External Access Security]] (fail2ban procedures)
- https://docs.linuxserver.io/images/docker-fail2ban/
