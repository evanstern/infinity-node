---
type: stack
service: cookcli
category: misc
vms: [103]
priority: low
status: planned
stack-type: single-container
has-secrets: false
external-access: false
ports: [9080]
backup-priority: low
created: 2025-11-19
updated: 2025-11-19
tags:
  - cookcli
  - cooklang
  - recipes
aliases:
  - CookCLI
  - Recipe Server
---

# CookCLI Stack (VM 103)

**Image Reference:** [CookCLI on Docker Hub](https://hub.docker.com/r/inigochoa/cookcli)

## Overview

CookCLI is the official Cooklang command-line toolkit containerized by `inigochoa/cookcli`. Deploying it on VM 103 provides a lightweight recipe workspace that can generate shopping lists, run pantry checks, and serve a minimal web UI while keeping the household server infrastructure consistent with Portainer-managed stacks.

## Configuration Summary

| Component | Value | Notes |
| --- | --- | --- |
| Host recipe store | `/mnt/video/Recipes` | NFS/Mounted directory (matches `.env.example`) mounted into `/app/recipes` for persistent Cooklang sources |
| Exposed port | `9080 → 9080` | Aligns with CookCLI’s web server when using `cook server` |
| UID / GID | `1000:1000` | Matches VM 103 service account `evan` |
| Environment | `production` | Default value exposed via `.env.example` |
| Memory limit | `256M` | Soft limit enforced by Portainer’s deploy settings |
| CPU quota | `0.10` | Sets `COOKCLI_CPUS` so CookCLI stays lightweight on VM-103 |
| Time zone | `America/Toronto` | Override via `.env` to match VM 103 locale |

## Deployment

1. Copy `.env.example` → `.env` on VM 103 and adjust values (especially `COOKCLI_RECIPES_PATH`, `TZ`, and any Vaultwarden-sourced secrets).
2. Create the recipe directory, e.g.:

```bash
ssh evan@vm-103 'mkdir -p /mnt/video/Recipes && chown -R 1000:1000 /mnt/video/Recipes'
```

3. Commit `stacks/cookcli/` to git.
4. Deploy via Portainer:
   - Stack name: `cookcli`
   - Git repository: `https://github.com/evanstern/infinity-node`
   - Compose file: `stacks/cookcli/docker-compose.yml`
   - Environment variables: load from `.env` and update as needed
   - Deploy and ensure the container transitions to `running`

5. Optionally connect to the container console and run `cook version` or `cook server` as needed. Consult the Cooklang Getting Started guide for CLI usage patterns and to understand the `cook server` command shape.

## Validation & Monitoring

- `docker compose config` passes locally before committing changes.
- Portainer shows the `cookcli` container as running (no restart loops).
- Logs (`docker logs cookcli`) show health or `cook server` output when triggered.
- `curl http://vm-103.local.infinity-node.win:9080` (or whichever host port is configured) returns a response once `cook server` is running.
- Recipes created under `/home/evan/data/cookcli/recipes` persist through restarts.

## References

- [[docs/agents/DOCKER|Docker Agent]] – Stack management guidance.
- [[stacks/README|Stacks overview]] – Repository deployment practices.
- [Cooklang Getting Started](https://cooklang.org/docs/getting-started/) – CLI usage and workflow context.
