---
type: task
task-id: IN-061
status: completed
priority: 3
category: docker
agent: docker
created: 2025-12-12
updated: 2025-12-12
started: 2025-12-12
completed: 2025-12-12

# Task classification
complexity: moderate
estimated_duration: 2-4h
critical_services_affected: false
requires_backup: false
requires_downtime: false

# Design tracking
alternatives_considered: true
risk_assessment_done: true
phased_approach: true

tags:
  - task
  - docker
  - n8n
---

# Task: IN-061 - Set up n8n stack with PostgreSQL on VM-103

> **Quick Summary**: Deploy n8n on VM-103 via docker-compose with PostgreSQL persistence, Traefik host `n8n.local.infinity-node.win`, and git-driven deployment using `scripts/infrastructure/create-git-stack.sh`.

## Problem Statement

**What problem are we solving?**
VM-103 does not yet host n8n, leaving automation/workflow orchestration unavailable. We need a reproducible stack definition (compose + docs + env template) aligned with existing Git+Portainer flow.

**Why now?**
- Requested deployment of n8n with PostgreSQL backend.
- Need host routing through Traefik at `n8n.local.infinity-node.win`.
- Want consistent git-managed stack using the existing creation script.

**Who benefits?**
- **Ops/Automation**: Gains workflow engine for integrations.
- **Infra team**: Standardized, repeatable deployment via git + Portainer.
- **Future services**: Can reuse patterns for other app + DB stacks.

## Solution Design

### Recommended Approach

Create a docker-compose stack for VM-103 defining n8n + PostgreSQL with persistent volumes, join Traefik’s shared `traefik-network`, and add a router/service entry in `stacks/traefik/vm-103/dynamic.yml` for `n8n.local.infinity-node.win`. Use `.env.example` for templating. Document deployment through `scripts/infrastructure/create-git-stack.sh` and Portainer Git stack.

**Key components:**
- Compose file: n8n service (no Traefik labels; only joins `traefik-network`), appropriate env vars, healthcheck, runners enabled; PostgreSQL service with volume and sane defaults.
- `.env.example`: timezone, base URL, Postgres creds/DB, encryption key placeholder, Traefik host, stack name.
- README: how to configure env, run `create-git-stack.sh`, and redeploy via Portainer.

**Rationale**: Uses Postgres for durability and concurrency; aligns with existing Traefik/Portainer patterns; keeps secrets out of git via env file.

> [!abstract]- Alt 1: Alternative Approaches Considered
>
> **Option A: SQLite-backed n8n**
> - ✅ Pros: Simpler, single container.
> - ❌ Cons: Concurrency limits, harder scaling/backup.
> - **Decision**: Not chosen — requirement is Postgres and better durability.
>
> **Option B: Postgres-backed n8n (chosen)**
> - ✅ Pros: Durable DB, better for concurrent executions.
> - ❌ Cons: Additional container to manage.
> - **Decision**: ✅ CHOSEN — meets requirements and scales better.

### Scope Definition

**✅ In Scope:**
- `docker-compose.yml` for n8n + Postgres with `traefik-network` join (no labels).
- Traefik dynamic entry (`stacks/traefik/vm-103/dynamic.yml`) for `n8n.local.infinity-node.win`.
- `.env.example` capturing all required env vars/secrets placeholders.
- README with deployment steps using `scripts/infrastructure/create-git-stack.sh` and Traefik expectations.

**❌ Explicitly Out of Scope:**
- Pi-hole DNS updates (user will handle).
- SSO/OIDC setup for n8n.
- Backup/monitoring automation for Postgres (future task).

**🎯 MVP (Minimum Viable)**:
n8n reachable at `https://n8n.local.infinity-node.win` via Traefik, persists data in Postgres volume, stack deployable via git stack script.

## Risk Assessment

### Potential Pitfalls

- ⚠️ **Traefik misrouting/host mismatch** → **Mitigation**: Use existing Traefik network/entrypoint names and host rule `n8n.local.infinity-node.win`; configure in `dynamic.yml`, not labels.
- ⚠️ **DB persistence misconfigured** → **Mitigation**: Define named volume for Postgres data; ensure env vars for DB creds/DB name are templated.
- ⚠️ **Secret exposure** → **Mitigation**: Keep real values in VM `.env`; only placeholders in `.env.example`; remind to store secrets in Vaultwarden.
- ⚠️ **Resource contention on VM-103** → **Mitigation**: Keep resource requests modest; note need to monitor after deploy.

### Dependencies

**Prerequisites (must exist before starting):**
- [x] **Traefik network `traefik-network` on VM-103** (blocking: yes) — confirmed exists via `docker network ls`.
- [x] **Traefik dynamic route entry to add in `stacks/traefik/vm-103/dynamic.yml`** (blocking: yes for exposure).
- [ ] **Pi-hole DNS entry for `n8n.local.infinity-node.win`** (blocking: no for authoring, yes for access) — user will handle.
- [x] **Portainer Git stack workflow via `create-git-stack.sh`** (blocking: no, script exists).

**Has blocking dependencies** - ingress network confirmation and dynamic route addition.

### Critical Service Impact

**Services Affected**: None of Emby/downloads/arr. New service on VM-103; low impact to critical media pipeline.

### Rollback Plan

**Applicable for**: docker/stack deployment

**How to rollback if this goes wrong:**
1. In Portainer, take stack offline/remove (or via `create-git-stack.sh` remove flag if available).
2. If needed, remove Traefik route by deleting stack to release router/service definitions.
3. Optionally delete Postgres volume if a clean re-init is required (after confirming no needed data).

**Recovery time estimate**: ~10-20 minutes to remove stack and clean up.

**Backup requirements:**
- New deployment; no pre-existing data. Once live, Postgres volume should be backed up in future tasks.

## Execution Plan

### Phase 0: Discovery/Inventory

**Primary Agent**: `docker`

- [x] **Confirm Traefik network name `traefik-network` and entrypoints on VM-103** `[agent:docker]` `[blocking]`
  - Confirmed via `docker network ls` - network exists (`0ce8e8e9ef8a traefik-network`).
- [x] **Check stack naming convention for `create-git-stack.sh`** `[agent:docker]`
  - Verified: secret `portainer-api-token-vm-103`, collection `shared`, endpoint `3`, stack name `n8n`, compose path `stacks/n8n/docker-compose.yml`.

### Phase 1: Compose & Env

**Primary Agent**: `docker`

- [x] **Author `docker-compose.yml` for n8n + Postgres** `[agent:docker]`
  - Created with n8n + postgres:16-alpine services.
  - n8n joins `traefik-network` (no labels), postgres on default only.
  - Healthchecks, named volumes (`pgdata`, `n8n_data`), proper env vars.
- [x] **Create `.env.example`** `[agent:docker]`
  - Includes all required vars with Vaultwarden instructions.
- [x] **Add `README.md`** `[agent:documentation]`
  - Comprehensive documentation with deployment steps, troubleshooting, backup instructions.
- [x] **Add Traefik router/service entry in `stacks/traefik/vm-103/dynamic.yml`** `[agent:docker]`
  - Router: `n8n.local.infinity-node.win` → entrypoint `web` → service `n8n`
  - Service: `http://n8n:5678`

### Phase 2: Validation (compose/ingress)

**Primary Agent**: `docker`

- [x] **Run compose config lint (`docker compose config`)** `[agent:docker]`
  - Passed successfully - all env vars resolve correctly.
- [x] **Cross-check Traefik dynamic route** `[agent:docker]`
  - Host rule matches, entrypoint `web`, service URL `http://n8n:5678` matches container port.

### Phase 3: Testing Review

**Primary Agent**: `testing`

- [x] **Dry-run stack review** `[agent:testing]`
  - Env template complete; compose references all defined vars properly.
- [x] **Ingress readiness check** `[agent:testing]`
  - Host rule `n8n.local.infinity-node.win`, service port 5678 - all aligned.

### Phase 4: Documentation

**Primary Agent**: `documentation`

- [x] **Finalize README clarity** `[agent:documentation]`
  - Includes deployment, secrets, troubleshooting, backup sections.

## Acceptance Criteria

**Done when all of these are true:**
- [x] `tasks/current/IN-061-setup-n8n-postgres-stack.md` updated with execution tracking.
- [x] `docker-compose.yml` defines n8n + Postgres, joins `traefik-network`, and includes volumes for persistence.
- [x] `stacks/traefik/vm-103/dynamic.yml` has router/service for `n8n.local.infinity-node.win` pointing to the n8n service port.
- [x] `.env.example` includes required variables (no real secrets) and matches compose references: `TZ`, `N8N_HOST`, `N8N_ENCRYPTION_KEY`, Postgres creds/db, base URL, optional runners.
- [x] `README.md` documents configuration, deployment via `create-git-stack.sh`, and Traefik/DNS expectations.
- [x] Compose passes `docker compose config` locally.
- [x] Testing Agent validation: compose lint passed, env template complete, Traefik routing verified.
- [x] Changes ready for review (no secrets); commit will happen only after approval.

## Testing Plan

**[[docs/agents/TESTING|Testing Agent]] validates:**
- Compose lint: `docker compose config` succeeds.
- Service wiring: n8n service depends_on Postgres and correct ports.
- Traefik routing: `dynamic.yml` host rule and entrypoints align with VM-103 network; service URL matches container port.
- Env template completeness: no undefined variables in compose (`TZ`, `N8N_HOST`, `N8N_ENCRYPTION_KEY`, Postgres vars, base URL).

**Manual validation:**
1. After deploy, visit `https://n8n.local.infinity-node.win` (ensure Pi-hole/DNS updated) and confirm n8n UI loads.
2. Confirm new Postgres volume created and container healthy.
3. Create a test workflow and save to verify DB persistence.

## Related Documentation

- [[stacks/README|Stack conventions]]
- [[scripts/README|Scripts overview]]
- [[docs/agents/DOCKER|Docker Agent]]
- External: n8n Docker install/compose docs (for reference)

## Notes

**Priority Rationale**:
Medium priority (3): new capability, not blocking critical media services but useful for automation.

**Complexity Rationale**:
Moderate: multi-container stack, Traefik routing, env templating; patterns exist to follow.

**Implementation Notes**:
- Keep real secrets in VM `.env` and Vaultwarden; never commit them.
- Align Traefik dynamic route with VM-103 conventions (host rule + `traefik-network`).
- Use consistent stack name in README and env template for `create-git-stack.sh`.

**Follow-up Tasks**:
- IN-XXX: Add backup/monitoring for n8n Postgres volume.
- IN-XXX: Add SSO/OIDC for n8n.

---

> [!note]- Work Log
>
> **2025-12-12 - Task opened**
> - Created task plan and scope for n8n stack deployment.
>
> **2025-12-12 - Stack files created**
> - Confirmed `traefik-network` exists on VM-103 via SSH.
> - Created `stacks/n8n/docker-compose.yml` following linkwarden/immich patterns.
> - Created `stacks/n8n/.env.example` with Vaultwarden integration instructions.
> - Created comprehensive `stacks/n8n/README.md` with deployment, troubleshooting, backup sections.
> - Added router and service entries to `stacks/traefik/vm-103/dynamic.yml`.
> - Validated compose config passes with test env vars.

> [!tip]- Lessons Learned
>
> **What Worked Well:**
> - Linkwarden stack provided excellent template for postgres + app pattern.
> - Pre-task review of existing stacks (linkwarden, immich, homepage) made authoring straightforward.
> - VM-103 dynamic.yml pattern is consistent and easy to extend.
>
> **What Could Be Better:**
> - n8n has specific env var naming (`DB_POSTGRESDB_*` vs generic `DB_*`) - required checking docs.
>
> **Key Discoveries:**
> - n8n uses `docker.n8n.io/n8nio/n8n:latest` as official image (not Docker Hub).
> - n8n healthcheck endpoint is `/healthz` (not root).
> - Encryption key is critical for credential storage - must back up securely.
>
> **Follow-Up Needed:**
> - User needs to add Pi-hole DNS entry for `n8n.local.infinity-node.win` → 192.168.1.103.
> - Future task: backup automation for n8n postgres volume.
> - Future task: SSO/OIDC integration if desired.
