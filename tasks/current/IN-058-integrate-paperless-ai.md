---
type: task
task-id: IN-058
status: in-progress
priority: 3
category: docker
agent: docker
created: 2025-11-18
updated: 2025-11-18
started: 2025-11-18
completed:

# Task classification
complexity: moderate
estimated_duration: 2-3h
critical_services_affected: false
requires_backup: false
requires_downtime: false

# Design tracking
alternatives_considered: true
risk_assessment_done: true
phased_approach: true

tags:
  - task
  - paperless
  - docker
---

# Task: IN-058 - Integrate paperless-ai sidecar into Paperless-NGX stack

> **Quick Summary**: Extend the existing `paperless-ngx` stack with the upstream `clusterzx/paperless-ai` container so AI-powered document search is available via port `3010`.

## Problem Statement

**What problem are we solving?**
The current Paperless-NGX deployment only offers native search. Users want the paperless-ai sidecar (RAG-based semantic search) that the upstream project now recommends. Without it, knowledge retrieval remains limited and we miss out on the vendor-supported AI UX.

**Why now?**
- Feature parity with upstream paperless installations that already bundle paperless-ai.
- Avoid diverging manual setups later; integrating now keeps Portainer GitOps as the single source of truth.
- Requests from household users for better search justify prioritizing this improvement.

**Who benefits?**
- **Household users**: gain semantic document querying UI.
- **Operations**: standardize stack, reducing drift between prod and documentation.
- **Future automation**: RAG endpoint unlocks future workflows (auto-tagging, digital assistants).

## Solution Design

### Recommended Approach

Add a new `paperless-ai` service to `stacks/paperless-ngx/docker-compose.yml` based on the upstream compose, parameterized through `.env` variables. Bind the UI to host port `3010`, connect it to the existing stack network so it can reach `webserver:8000`, and persist its data via a named volume. Update `.env.example` with the new variables (PAPERLESS_AI_PORT, PAPERLESS_AI_DATA_PATH if needed, PUID/PGID) and document redeploy considerations in the stack README if required.

**Key components:**
- Component 1: `paperless-ai` service using `clusterzx/paperless-ai` image with hardened security options.
- Component 2: Environment variables for port (default 3010), UID/GID alignment, and RAG endpoint pointing at the local Paperless webserver.
- Component 3: Data volume mount for AI embeddings/cache plus Portainer-friendly network/depends_on wiring.

**Rationale**: Embedding the AI container directly in the existing stack keeps GitOps simple, ensures versioned deploys through Portainer, and allows easy coordination with Paperless via the internal Docker network without exposing additional secrets.

> [!abstract]- 🔀 Alternative Approaches Considered
>
> **Option A: Separate stack on VM 103**
> - ✅ Pros: Isolates lifecycle, easier to restart independently.
> - ❌ Cons: Duplicates env handling, requires another Portainer stack and README.
> - **Decision**: Not chosen - increases operational overhead for a tightly coupled component.
>
> **Option B: Skip AI integration**
> - ✅ Pros: No extra resources used.
> - ❌ Cons: Does not deliver requested functionality.
> - **Decision**: Not chosen - fails task goals.
>
> **Option C: Proxy AI via Traefik instead of direct port**
> - ✅ Pros: Enables HTTPS + DNS fronting.
> - ❌ Cons: Adds certificate + middleware work not yet scoped.
> - **Decision**: Defer - can be future enhancement once basic service works.

### Scope Definition

**✅ In Scope:**
- Update compose file with the paperless-ai service, networks, and volume.
- Extend `.env.example` with new variables and documentation comments.
- Verify port `3010` availability and plan for redeploy via Portainer.

**❌ Explicitly Out of Scope:**
- Configuring Traefik routing / HTTPS for paperless-ai.
- Production redeploy via Portainer (will require separate approval step).
- Tuning AI model parameters beyond defaults.

**🎯 MVP (Minimum Viable)**:
Compose + env example updated so Portainer can redeploy and bring up paperless-ai listening on host port `3010` and talking to Paperless via `RAG_SERVICE_URL=http://webserver:8000`.

## Risk Assessment

### Potential Pitfalls

- ⚠️ **Port collision on 3010** → **Mitigation**: Search codebase/infra for existing use, adjust if conflict found before deploy.
- ⚠️ **Resource contention on VM 103** → **Mitigation**: Review container footprint; keep restart policy `unless-stopped`; monitor after deployment.
- ⚠️ **Security exposure of AI endpoint** → **Mitigation**: Bind only on LAN port, drop capabilities, consider future Traefik auth.
- ⚠️ **Drift between env example and production secrets** → **Mitigation**: Document new variables and add to Vaultwarden item.

### Dependencies

**Prerequisites (must exist before starting):**
- [x] **Confirm port 3010 availability** - repo grep shows no existing usage; confirm again during deploy window (blocking: yes)
- [ ] **Vaultwarden entry updated for new env fields** - add placeholders after compose change (blocking: no)
- [ ] **Paperless stack documentation reference** - ensure README mentions AI addon (blocking: no)

**Has blocking dependencies** - cannot deploy until port availability confirmed, but compose updates can proceed in parallel while verifying.

### Critical Service Impact

**Services Affected**: Paperless-NGX (non-critical but important)

No listed CRITICAL services (Emby/Downloads/Arr) are touched. Paperless AI runs alongside existing Paperless components on VM 103; any issues are contained to document search functionality.

### Rollback Plan

**Applicable for**: Docker stack update via Portainer Git integration.

**How to rollback if this goes wrong:**
1. Revert compose and env example changes in git (or checkout previous commit).
2. Redeploy stack via Portainer to remove paperless-ai container.
3. Remove leftover named volume if needed after confirming no data required.

**Recovery time estimate**: ~10 minutes (Git revert + redeploy).

**Backup requirements:**
- None beyond existing Paperless backups; paperless-ai stores derived data only.

## Execution Plan

### Phase 0: Discovery & Validation

**Primary Agent**: `docker`

- [x] **Inventory current paperless stack configuration** `[agent:docker]`
  - Reviewed existing services, networks, and volumes in `stacks/paperless-ngx/docker-compose.yml`.
- [x] **Validate host port availability for 3010** `[agent:docker]`
  - `grep -R \"3010\"` across repo returned only task references, so port appears unused.

### Phase 1: Compose & Env Updates

**Primary Agent**: `docker`

- [x] **Add paperless-ai service to docker-compose** `[agent:docker]`
  - Added `clusterzx/paperless-ai` container with env, port `3010`, security opts, and data volume.
- [x] **Extend .env.example with AI variables** `[agent:docker]`
  - Documented `PUID`, `PGID`, and `PAPERLESS_AI_PORT` defaults.
- [x] **Define new volume(s) and network hookups** `[agent:docker]`
  - Declared `paperless-ai-data` named volume for embeddings/cache.

### Phase 2: Documentation & Deployment Prep

**Primary Agent**: `documentation`

- [x] **Update stack README / notes** `[agent:documentation]`
  - Added architecture entry, Paperless AI section, and access details (port 3010).
- [x] **Record redeploy + Vaultwarden updates needed** `[agent:documentation]`
  - README now highlights Portainer redeploy flow and Vaultwarden note for new env keys.

### Phase 3: Validation & Testing

**Primary Agent**: `testing`

- [x] **Compose config lint/check** `[agent:testing]`
  - Ran `docker compose --env-file stacks/paperless-ngx/.env.example -f stacks/paperless-ngx/docker-compose.yml config`.
- [ ] **Post-deploy port check** `[agent:testing]`
  - Pending Portainer redeploy; confirm service listens on 3010 afterward.

### Phase 4: Documentation Finalization

**Primary Agent**: `documentation`

- [x] **Ensure task file work log + lessons updated** `[agent:documentation]`
  - Work log entries captured for each phase; lessons learned filled in for AI integration notes.

## Acceptance Criteria

**Done when all of these are true:**
- [x] `paperless-ai` service defined in compose with correct env + security settings.
- [x] `.env.example` documents PAPERLESS_AI_* variables and UID/GID expectations.
- [x] Port 3010 confirmed unused elsewhere (or alternate chosen/documented).
- [x] Stack README references AI addon + port.
- [ ] Execution plan items checked off with notes.
- [x] Testing agent plan ready for `docker compose config` and runtime verification.
- [ ] Changes awaiting user review prior to commit.

## Testing Plan

**[[docs/agents/TESTING|Testing Agent]] validates:**
- `docker compose -f stacks/paperless-ngx/docker-compose.yml config` succeeds locally.
- After redeploy, `curl http://<vm103>:3010/health` (or UI) responds 200.

**Manual validation:**
1. Redeploy stack via Portainer (Pull & redeploy) once approved.
2. Visit `http://vm103:3010` (or via Pangolin) confirm AI UI loads.
3. Trigger AI search against known document, ensure requests reach Paperless via RAG endpoint.

## Related Documentation

- [[docs/agents/DOCKER|Docker Agent responsibilities]]
- [[stacks/README|Stacks overview]]
- [[docs/AI-COLLABORATION|AI collaboration workflow]]
- [[docs/SECRET-MANAGEMENT|Secret management guidance]]

## Notes

**Priority Rationale**:
Delivers requested functionality for document workflows without touching CRITICAL services; moderate urgency due to user demand.

**Complexity Rationale**:
Moderate—compose edits are straightforward but must honor agent workflow, env documentation, and future Portainer redeploy steps.

**Implementation Notes**:
- Prefer `3010` host port; adjust if conflicts found.
- Keep `cap_drop` / `security_opt` aligned with upstream reference.
- Ensure `RAG_SERVICE_URL` uses service name (`webserver`) on default network.

**Follow-up Tasks**:
- IN-0XX: Add Traefik route + auth for paperless-ai (if needed).
- IN-0XX: Evaluate GPU-backed inference for AI if upstream adds support.

---

> [!note]- 📋 Work Log
>
> **2025-11-18 - Task initialized**
> - Created IN-058 task with scope, plan, and risks.
> - Captured AI integration requirements and acceptance criteria.
>
> **2025-11-18 - Compose & env updates**
> - Added paperless-ai service, env vars, and volume to `stacks/paperless-ngx`.
> - Updated `.env.example` with PUID/PGID and default AI port 3010.
>
> **2025-11-18 - Documentation updates**
> - Refreshed stack README with AI architecture, ports, and redeploy guidance.
> - Noted Vaultwarden entry update for new env placeholders.
>
> **2025-11-18 - Validation**
> - `docker compose config` dry run succeeded using `.env.example`.
> - Pending: runtime verification after Portainer redeploy.
>
> **YYYY-MM-DD - [Milestone]**
> - (to be updated)
>
> **YYYY-MM-DD - [Milestone]**
> - (to be updated)

> [!tip]- 💡 Lessons Learned
>
> **What Worked Well:**
> - Upstream compose (`clusterzx/paperless-ai`) mapped cleanly into our stack with minimal adjustments.
> - Running `docker compose config` against `.env.example` is an easy sanity check before Portainer redeploys.
>
> **What Could Be Better:**
> - Need a follow-up to wrap the AI UI behind Traefik instead of exposing a raw port.
>
> **Key Discoveries:**
> - paperless-ai data is derived embeddings only, so a lightweight named volume is sufficient and no new secrets are required.
>
> **Scope Evolution:**
> - Stayed within original scope; deferred HTTPS/Traefik integration for a future task.
>
> **Follow-Up Needed:**
> - Create a Traefik routing task for `paperless-ai`.
> - Update Vaultwarden entry once final `.env` values are chosen during deployment.
