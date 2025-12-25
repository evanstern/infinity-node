# Tailscale stack (Portainer / Docker, host networking)

Deploy one stack per host. Configure host-specific values via environment overrides in Portainer GitOps. Auth key provided via `TS_AUTHKEY` (or `TS_AUTHKEY_FILE` if you mount it); no secrets committed.

## Files
- `docker-compose.yml` — Tailscale service (host network, privileged), persists state in `/var/lib/tailscale`.
- `.env.example` — Env defaults; copy and override per host in Portainer.

## Environment overrides per host (Portainer)
- `TS_HOSTNAME`: e.g., `vm-100`, `vm-101`, …
- `TS_ROUTES`: only on the chosen subnet router (e.g., `192.168.1.0/24`), blank elsewhere.
- `TS_ACCEPT_DNS`: `false` to keep local DNS; set `true` if you want Tailscale DNS/MagicDNS.
- `TS_EXIT_NODE`: `true` only if this host should advertise exit-node.
- `TS_EXTRA_ARGS`: optional extra flags to `tailscale up` (e.g., `--shields-up`).
- `TS_STATE_DIR_HOST`: host path for state (default `/home/evan/config/tailscale`).
- `TS_TUN_DEVICE`: tun device path (default `/dev/net/tun`).
- `TS_AUTHKEY`: set the auth key inline (preferred for standalone Docker stacks); or `TS_AUTHKEY_FILE` if you mount a file containing the key.

## Deploy steps (per host)
1. Retrieve Tailscale auth key from Vaultwarden (e.g., `ts_authkey` in `shared`). In Portainer, set it as `TS_AUTHKEY` (or mount a file and set `TS_AUTHKEY_FILE`).
2. Add stack from repo `stacks/tailscale/docker-compose.yml`.
3. Set env overrides for this host (see above) in the stack variables (or via .env uploaded in Portainer).
4. Deploy. First run will `tailscale up` automatically using the key.
5. In Tailscale admin, approve the device; if this host advertises routes, enable them.

## Notes
- Service runs with `network_mode: host`, `privileged`, `NET_ADMIN`, `SYS_MODULE` for routing/TUN.
- State persists at `/var/lib/tailscale`; re-deploys keep login.
- Only one host should advertise the same subnet routes to avoid conflicts.
- DNS: default `TS_ACCEPT_DNS=false`; enable if you want Tailscale to manage resolvers/MagicDNS.
