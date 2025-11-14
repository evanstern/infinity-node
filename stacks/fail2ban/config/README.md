# Fail2ban Configuration for Navidrome (VM-103)

---
type: documentation
tags:
  - security
  - fail2ban
  - vm-103
created: 2025-11-13
updated: 2025-11-13
---

## Overview

This directory contains the Git-managed jails, filters, and sample logs used by the LinuxServer.io `fail2ban` container to protect Navidrome (and related ingress) on VM-103. When Portainer redeploys the stack, these files are available directly inside the cloned repository and mounted into the container.

## Layout

```
stacks/fail2ban/config/
├── README.md
├── jail.d/                    # Jail definitions
│   ├── navidrome.conf
│   └── emby.conf
├── filter.d/                  # Custom filters referenced by the jails
│   ├── navidrome-auth.conf
│   ├── navidrome-traefik.conf
│   ├── emby-auth.conf
│   └── emby-traefik.conf
└── samples/                   # Example log lines used for regex tuning
    ├── navidrome-auth.txt
    ├── traefik-access-navidrome.jsonl
    ├── emby-auth.txt
    └── traefik-access-emby.jsonl
```

## Log Sources & Mounts

| Source    | Container Path                        | Host Path (VM-103)                          | Notes                                                |
|-----------|---------------------------------------|---------------------------------------------|------------------------------------------------------|
| Traefik   | `/remotelogs/traefik/access.log`      | `/home/evan/logs/traefik/access.log`        | JSON access log; 401 responses indicate failed auth. |
| Navidrome | `/remotelogs/navidrome/navidrome.log` | `/home/evan/data/navidrome/logs/navidrome.log` | Generated via `stdbuf … | tee -a /data/logs/navidrome.log`. |

Ensure these host directories exist before redeploying stacks (Navidrome creates its log directory automatically; Traefik’s directory may need manual creation). When deploying on VM-100 for Emby, mount `/home/evan/projects/infinity-node/stacks/emby/config/logs` into `/remotelogs/emby` via the `EMBY_LOG_PATH` variable (or keep `/home/evan/.config/fail2ban/unused` elsewhere).

## Filters

- **`navidrome-traefik.conf`**: flags `DownstreamStatus: 401` entries for the Navidrome router in the Traefik access log.
- **`navidrome-auth.conf`**: flags `auth failed login` lines emitted by Navidrome.

Sample logs in `samples/` match the failregex patterns and can be used with `fail2ban-regex` for validation.

## Jails

`jail.d/navidrome.conf` enables two jails:

| Jail                | Log Path                             | Ports          | Action/Chain                        |
|---------------------|--------------------------------------|----------------|-------------------------------------|
| `navidrome-traefik` | `/remotelogs/traefik/access.log`     | 80, 443, 4533  | `iptables-multiport` → `DOCKER-USER` |
| `navidrome-auth`    | `/remotelogs/navidrome/navidrome.log`| 4533           | `iptables-multiport` → `DOCKER-USER` |

`jail.d/emby.conf` mirrors the same pattern for VM-100:

| Jail             | Log Path                               | Ports              | Action/Chain                        |
|------------------|----------------------------------------|--------------------|-------------------------------------|
| `emby-traefik`   | `/remotelogs/traefik/access.log`       | 80, 443, 8096, 8920| `iptables-multiport` → `DOCKER-USER`|
| `emby-auth`      | `/remotelogs/emby/embyserver*.txt`     | 8096, 8920         | `iptables-multiport` on `INPUT` + `DOCKER-USER` |

Defaults: `maxretry = 5`, `findtime = 600` seconds, `bantime = 3600` seconds. Adjust within the jail file if different thresholds are required.

## Validation Checklist

1. **Regex sanity check:**
   ```bash
   docker exec fail2ban fail2ban-regex /remotelogs/traefik/access.log /config/filter.d/navidrome-traefik.conf
   docker exec fail2ban fail2ban-regex /remotelogs/navidrome/navidrome.log /config/filter.d/navidrome-auth.conf
   ```
2. **Controlled login failures:** Attempt multiple bad logins (via Traefik and direct port if exposed) and confirm bans:
   ```bash
   docker exec fail2ban fail2ban-client status navidrome-traefik
   docker exec fail2ban fail2ban-client status navidrome-auth
   ```
3. **Unban procedure:**
   ```bash
   docker exec fail2ban fail2ban-client set navidrome-traefik unbanip <IP>
   ```
4. **Whitelisting:** Add trusted CIDRs to `ignoreip` (create `/config/jail.local`) if home networks should never be banned.

## Future Enhancements

- Integrate alerting when bans occur (e.g., via fail2ban actions).
- Extend jails to additional services on VM-103 as exposure increases.
- Add log-rotation for `/home/evan/data/navidrome/logs/navidrome.log` if growth becomes a concern.
