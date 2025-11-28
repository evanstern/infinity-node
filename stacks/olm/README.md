---
type: stack
service: olm
category: networking
vms: []
priority: important
status: planned
stack-type: single-container
has-secrets: true
external-access: false
ports: []
backup-priority: none
created: 2025-11-28
updated: 2025-11-28
tags:
  - stack
  - vpn
  - pangolin
  - remote-access
  - wireguard
aliases:
  - Olm
  - Pangolin Remote Client
---

# Olm Stack

**Service:** Olm (Pangolin remote-access client)
**Runs on:** Any Linux host with Docker + `/dev/net/tun` (typically user laptops or jump boxes)
**Priority:** Important (enables secure user tunnels into Newt-managed sites)

Olm is the user-facing WireGuard client that pairs with Pangolin/Newt. Once authenticated with an `OLM_ID` and `OLM_SECRET`, it establishes a control channel to Pangolin and brings up an on-demand WireGuard tunnel that routes traffic to the selected Newt site. This repository keeps the Docker Compose definition, environment template, and operational notes so every remote workstation can be bootstrapped consistently.

> Upstream docs: [fosrl/olm](https://github.com/fosrl/olm) and [Pangolin documentation](https://docs.pangolin.net)

## Architecture & Requirements

- `network_mode: host` exposes the WireGuard interface directly on the host OS so routes install correctly.
- `/dev/net/tun` must be available and passed through to the container.
- Olm registers against `https://pangolin.infinity-node.com` and expects the Pangolin server plus Gerbil relay to be reachable over the public Internet.
- Every Olm instance uses **unique credentials**; never reuse an ID/secret pair across devices.

## Deployment

1. **Create credentials**
   - Log into Pangolin and register a new Olm client (Security Agent workflow).
   - Store `OLM_ID` and `OLM_SECRET` in Vaultwarden as `olm-config-<host>` with the metadata described in `.env.example`.

2. **Prepare environment file**
   - Copy `.env.example` → `.env` on the target machine.
   - Populate the placeholders by pulling from Vaultwarden:
     ```bash
     export BW_SESSION=$(cat ~/.bw-session)
     OLM_ID=$(scripts/secrets/get-vw-secret.sh "olm-config-remote01" "remote-users" "olm_id")
     OLM_SECRET=$(scripts/secrets/get-vw-secret.sh "olm-config-remote01" "remote-users" "olm_secret")
     ```

3. **Provision stack via Portainer Git workflow** (preferred for always-on endpoints)
   ```bash
   ./scripts/infrastructure/create-git-stack.sh \
     "portainer-api-token-remote-host" "shared" 3 \
     "olm-remote01" "stacks/olm/docker-compose.yml" \
     --env-file stacks/olm/.env
   ```
   For ad-hoc hosts (e.g., laptops) you can run `docker compose up -d` directly after copying the stack.

4. **Validate**
   - `docker ps --filter name=olm` should show the container running.
   - `docker logs -f olm` should report a successful session token request and WireGuard tunnel establishment.
   - `curl -s http://localhost:8080/status` (if HTTP control enabled) should return `connected: true`.

## Environment Variables

| Variable            | Required | Description                                                                 | Source                                  |
|---------------------|---------:|-----------------------------------------------------------------------------|-----------------------------------------|
| `PANGOLIN_ENDPOINT` |    ✅     | URL for Pangolin control plane (Gerbil + Pangolin)                          | Static (`https://pangolin.infinity-node.com`) |
| `OLM_ID`            |    ✅     | Unique client ID issued when registering Olm                                | Vaultwarden `olm-config-<host>`         |
| `OLM_SECRET`        |    ✅     | Secret paired with the Olm ID for authentication                            | Vaultwarden `olm-config-<host>`         |
| `MTU`, `DNS`, etc.  |    ❌     | Optional tuning knobs (see upstream docs)                                   | Add as needed via `.env`                |

## Operations

- **Status checks:** `docker logs olm | tail -n 50` or enable the built-in HTTP server for programmatic status polling.
- **Credential rotation:** issue new ID/secret in Pangolin, update Vaultwarden, redeploy the stack (Git redeploy or `docker compose up -d`).
- **Troubleshooting:** look for `Error connecting` lines in logs (indicates Pangolin reachability issues) or `WireGuard` errors (missing TUN device / host kernel module).

## References

- [[docs/SECRET-MANAGEMENT]] – secret storage standards and Vaultwarden usage.
- [[docs/agents/SECURITY]] – Pangolin/Newt credential management workflow.
- [fosrl/olm README](https://github.com/fosrl/olm) – authoritative CLI + env documentation.
