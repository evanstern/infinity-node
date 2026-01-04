# Actual Budget (VM-103)

Self-hosted Actual Budget server deployed via Portainer Git stack.

## Service details
- Image: `actualbudget/actual-server:latest`
- Host port: `5006` (configurable via `ACTUAL_PORT`)
- Data path: `/home/evan/data/actual-budget` (host) mounted to `/data`
- Healthcheck: `node src/scripts/health-check.js`

## Secrets
- SimpleFIN setup token: store in Vaultwarden (`vm-103-misc` collection). Not committed; reference only in `.env.example` placeholder.
- HTTPS keys/certs (if used): store paths in `.env` on VM-103; do not commit certs.

## Deployment (Portainer Git)
- Repository: `https://github.com/evanstern/infinity-node`
- Reference: `main`
- Compose path: `stacks/actual/docker-compose.yml`
- Env file: create `.env` on VM-103 from `.env.example` and fill secrets/paths from Vaultwarden.
- Host data dir: ensure `/home/evan/data/actual-budget` exists and is writable by UID/GID 1000.
- Use Portainer “Pull and redeploy” after changes.

## Validation
- `docker compose config` (from `stacks/actual`) to verify syntax.
- After deploy: confirm UI at `http://<vm-103-ip>:5006`, healthcheck healthy, and data persists under `/home/evan/data/actual-budget`.
