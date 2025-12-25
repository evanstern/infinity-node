# Tailscale stack (Portainer / Docker, host networking)

Deploy one stack per host. Uses an external Portainer secret `ts_authkey` (do not commit keys). Configure host-specific values via environment overrides in Portainer GitOps.

## Files
- `docker-compose.yml` — Tailscale service (host network, privileged), persists state in `/var/lib/tailscale`.
- `.env.example` — Env defaults; copy and override per host in Portainer.

## Required Portainer secret
- `ts_authkey`: Tailscale auth key (reusable, scoped, not an ephemeral single-use if you want unattended redeploys).

## Environment overrides per host (Portainer)
- `TS_HOSTNAME`: e.g., `vm-100`, `vm-101`, …
- `TS_ROUTES`: only on the chosen subnet router (e.g., `192.168.1.0/24`), blank elsewhere.
- `TS_ACCEPT_DNS`: `false` to keep local DNS; set `true` if you want Tailscale DNS/MagicDNS.
- `TS_EXIT_NODE`: `true` only if this host should advertise exit-node.
- `TS_EXTRA_ARGS`: optional extra flags to `tailscale up` (e.g., `--shields-up`).
- `TS_STATE_DIR_HOST`: host path for state (default `/home/evan/config/tailscale`).
- `TS_TUN_DEVICE`: tun device path (default `/dev/net/tun`).

## Deploy steps (per host)
1. In Portainer, create external secret `ts_authkey` with your Tailscale auth key (from Vaultwarden: `infinity-node -> vm-10x-xxx/shared`).
2. Add stack from repo `stacks/tailscale/docker-compose.yml`.
3. Set env overrides for this host (see above) in the stack variables (or via .env uploaded in Portainer).
4. Deploy. First run will `tailscale up` automatically using the secret.
5. In Tailscale admin, approve the device; if this host advertises routes, enable them.

## Notes
- Service runs with `network_mode: host`, `privileged`, `NET_ADMIN`, `SYS_MODULE` for routing/TUN.
- State persists at `/var/lib/tailscale`; re-deploys keep login.
- Only one host should advertise the same subnet routes to avoid conflicts.
- DNS: default `TS_ACCEPT_DNS=false`; enable if you want Tailscale to manage resolvers/MagicDNS.
