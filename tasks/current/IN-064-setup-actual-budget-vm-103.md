---
type: task
task-id: IN-064
status: in-progress
priority: 3
category: docker
agent: docker
created: 2026-01-04
updated: 2026-01-04
started: 2026-01-04
completed:

# Task classification
complexity: moderate
estimated_duration: 3-5h
critical_services_affected: false
requires_backup: false
requires_downtime: false

# Design tracking
alternatives_considered: true
risk_assessment_done: true
phased_approach: true

tags:
  - task
  - actual
  - budget
  - vm-103
  - docker
---

# Task: IN-064 - Set up Actual Budget on VM-103

> **Quick Summary**: Deploy Actual Budget on VM-103 via Portainer-managed Docker stack, exposing port 5006, persisting data at `/home/evan/data/actual-budget`, and handling the SimpleFIN setup token via Vaultwarden with a `.env.example` placeholder.

## Problem Statement

**What problem are we solving?**
We need a self-hosted Actual Budget instance to manage household finances and enable SimpleFIN-based bank sync, with configuration aligned to the existing Proxmox/Portainer workflow and documented for repeatable deployment.

**Why now?**
- SimpleFIN account and setup token are ready.
- Centralized budgeting improves visibility alongside existing media/services stack.
- Aligns with current automation standards before further integrations.

**Who benefits?**
- **Household finance users**: Access to budgeting app and SimpleFIN sync.
- **Infrastructure maintainers**: Git/Portainer-managed deployment with clear rollback.

## Solution Design

### Recommended Approach

Create a new `Actual Budget` stack managed via Portainer Git integration. Base the compose on upstream `actualbudget/actual-server:latest`, expose host port `5006`, mount `/home/evan/data/actual-budget` to `/data`, attach to `traefik-network` for local DNS routing, include healthcheck, and add a `.env.example` with a placeholder for the SimpleFIN setup token stored in Vaultwarden. Document deployment steps and validation.

**Key components:**
- Docker image `actualbudget/actual-server:latest` with healthcheck.
- Volume mount `/home/evan/data/actual-budget:/data` for persistent storage.
- Port mapping `5006:5006`.
- Traefik router `actual.local.infinity-node.win` → service `actual:5006`.
- `.env.example` placeholder for `ACTUAL_SIMPLEFIN_TOKEN` (secret in Vaultwarden).

**Rationale**: Follows upstream compose, fits Portainer Git-managed workflow used across stacks, and keeps secrets out of git via Vaultwarden + `.env` on VM-103.

> [!abstract]- 🔀 Alternative Approaches Considered
>
> **Option A: Direct docker run on VM-103**
> - ✅ Pros: Fast to launch
> - ❌ Cons: Drifts from Git/Portainer source of truth; harder to redeploy/rollback
> - **Decision**: Not chosen — prefer Git-managed stacks
>
> **Option B: Deploy from upstream compose without repo integration**
> - ✅ Pros: Minimal edits
> - ❌ Cons: Lacks repo documentation, secret placeholder, and VM-specific paths
> - **Decision**: Not chosen — need repo-aligned config and secret handling
>
> **Option C: Use `edge` tag**
> - ✅ Pros: Latest features
> - ❌ Cons: Higher instability risk for finance data
> - **Decision**: Not chosen — use `latest` for stability

### Scope Definition

**✅ In Scope:**
- Add a new stack definition for Actual Budget with port 5006 and `/home/evan/data/actual-budget` volume.
- Add `.env.example` with SimpleFIN token placeholder and documented secrets flow (Vaultwarden).
- Document deployment, validation, and rollback steps in the task file.

**❌ Explicitly Out of Scope:**
- Migrating existing Actual data (fresh deploy only).
- Network/firewall changes beyond port 5006 exposure on VM-103.
- Automating backups for Actual data (follow-up task if needed).

**🎯 MVP (Minimum Viable)**: Compose + `.env.example` ready in repo, instructions for Vaultwarden secret, and validation steps defined for Portainer deployment.

## Risk Assessment

### Potential Pitfalls

- ⚠️ **Port collision on 5006** → **Mitigation**: Verify availability on VM-103; adjust host port if conflict found.
- ⚠️ **Volume permissions on `/home/evan/data/actual-budget`** → **Mitigation**: Ensure path exists and is writable by container UID/GID; document ownership expectations.
- ⚠️ **Secret handling for SimpleFIN token** → **Mitigation**: Store token in Vaultwarden; only include placeholder in `.env.example`; avoid committing secrets.
- ⚠️ **Drift from Portainer Git stack** → **Mitigation**: Deploy via Portainer pull/redeploy; avoid manual `docker compose up`.

### Dependencies

**Prerequisites (must exist before starting):**
- [ ] Portainer access for VM-103 stack deployment (blocking: yes)
- [ ] Writable path `/home/evan/data/actual-budget` on VM-103 (blocking: yes)

**Has blocking dependencies** - cannot deploy until Portainer access and path readiness confirmed.

### Critical Service Impact

**Services Affected**: None of Emby/Downloads/Arr are impacted. Runs on VM-103 alongside misc services; port isolated to 5006.

### Rollback Plan

**Applicable for**: docker

**How to rollback if this goes wrong:**
1. In Portainer, stop/remove the Actual stack.
2. Revert compose/.env.example changes in git.
3. If container data is bad, restore `/home/evan/data/actual-budget` from backup (if available) or recreate empty dir.

**Recovery time estimate**: ~10-20 minutes (stack removal/redeploy; longer if restoring data).

**Backup requirements:**
- None pre-existing (new deploy). If data accumulates later, add backup strategy for `/home/evan/data/actual-budget`.

## Execution Plan

### Phase 0: Discovery/Inventory

**Primary Agent**: `[agent:docker]`

 - [x] Confirm port 5006 free on VM-103. `[agent:docker]`
 - [x] Verify initial NAS path `/mnt/video/ActualBudget` (not used; caused DB lock). `[agent:docker]`
 - [x] Verify `/home/evan/data/actual-budget` exists and is writable; create if needed (no git). `[agent:docker]`
- [x] Identify Portainer stack naming and repo path convention (e.g., `stacks/actual`). `[agent:docker]`

### Phase 1: Compose & Secrets

**Primary Agent**: `[agent:docker]`

 - [x] Add `stacks/actual/docker-compose.yml` with image `actualbudget/actual-server:latest`, port `5006:5006`, volume mount `/home/evan/data/actual-budget:/data`, and healthcheck. `[agent:docker]`
 - [x] Attach service to `traefik-network` and add Traefik router/service entries. `[agent:docker]`
- [x] Add `stacks/actual/.env.example` with `ACTUAL_SIMPLEFIN_TOKEN=` placeholder; note Vaultwarden entry for real token. `[agent:docker]`
- [x] Document environment options (e.g., HTTPS key/cert, upload limits) referencing upstream docs. `[agent:docker]`

### Phase 2: Validation & Testing

**Primary Agent**: `[agent:testing]`

 - [x] Validate compose via `docker compose config` (Portainer or local check). `[agent:testing]`
 - [ ] After deployment, confirm healthcheck passing and UI reachable on port 5006. `[agent:testing]`
 - [ ] Confirm data persists in `/home/evan/data/actual-budget` after restart. `[agent:testing]`

### Phase 3: Documentation

**Primary Agent**: `[agent:documentation]`

- [x] Record deployment/runbook steps and rollback notes in repo docs or task. `[agent:documentation]`
- [x] Note SimpleFIN token storage location in Vaultwarden entry. `[agent:documentation]`

## Acceptance Criteria

- [ ] Task file reflects approved plan (priority 3, moderate complexity, docker category, agent docker).
- [ ] Compose and `.env.example` paths and values documented (port 5006, `/home/evan/data/actual-budget:/data`).
- [ ] SimpleFIN token handling recorded: Vaultwarden secret + `.env.example` placeholder.
- [ ] Healthcheck and deployment/validation steps documented.
- [ ] Rollback guidance present.
- [ ] Testing steps identified for Testing Agent (port reachability, healthcheck, persistence).
- [ ] Task scripts executed (ID reserved, counter updated, validation passed).

## Testing Plan

**[[docs/agents/TESTING|Testing Agent]] validates:**
- Compose parses cleanly (`docker compose config`).
- Container reports healthy via healthcheck.
- Web UI reachable at `http://<vm-103-ip>:5006/`.
- Data written persists under `/home/evan/data/actual-budget`.

**Manual validation:**
1. Portainer: pull and redeploy Actual stack; observe successful deploy.
2. Access UI on port 5006; create a sample budget to confirm data write.
3. Restart stack; verify data still present and healthcheck passes.

## Related Documentation

- [[docs/AI-COLLABORATION#MDTD|MDTD Overview]]
- [[docs/agents/DOCKER|Docker Agent]]
- https://actualbudget.org/docs/install/docker
- https://actualbudget.org/docs/advanced/bank-sync/simplefin/
- https://github.com/actualbudget/actual/blob/master/packages/sync-server/docker-compose.yml

## Notes

**Priority Rationale**: Medium priority (3) — valuable new service but not impacting critical media stacks.

**Complexity Rationale**: Moderate — straightforward compose but needs secret handling and Portainer alignment.

**Implementation Notes**:
- Use `actualbudget/actual-server:latest` tag for stability.
- Keep secrets out of git; real `.env` lives on VM-103 with Vaultwarden token.
- Avoid manual `docker compose up`; use Portainer Git redeploy.

**Follow-up Tasks**:
- IN-XXX: Add backup/restore runbook for Actual data.
- IN-XXX: Configure reverse proxy/HTTPS if needed later.

---

> [!note]- 📋 Work Log
>
> **2026-01-04 - Task created**
> - Captured deployment plan, scope, risks, and validation steps.
>
> **2026-01-04 - Stack defined & validated**
> - Added `stacks/actual` with compose, `.env.example`, README.
> - Ran `docker compose config` to validate syntax.
>
> **2026-01-04 - Port/path checks**
> - Port 5006 free on VM-103.
> - Initial NAS path created but unsuitable (DB lock); switching to local disk.
>
> **2026-01-04 - Path updated**
> - Updated stack to use `/home/evan/data/actual-budget`.
> - Created `/home/evan/data/actual-budget` (UID/GID 1000, mode 755).
>
> **2026-01-04 - Traefik routing**
> - Attached Actual to `traefik-network`; added router/service `actual.local.infinity-node.win`.
> - GitOps polling confirmed; pending Portainer pull/redeploy to apply.
>
> **YYYY-MM-DD - Deployment**
> - [Fill during execution]
> - [Decisions/changes]
>
> **YYYY-MM-DD - Validation**
> - [Test outcomes]
> - [Issues resolved]
>
> **YYYY-MM-DD - Wrap-up**
> - [Lessons and follow-ups]
>
> [!tip]- 💡 Lessons Learned
>
> *Fill this in AS YOU GO during task execution. Not every task needs extensive notes here, but capture important learnings that could affect future work.*
>
> **What Worked Well:**
> - [Patterns/approaches to reuse]
> - [Tools/techniques that helped]
>
> **What Could Be Better:**
> - [Improvements for next time]
> - [Unexpected challenges]
>
> **Key Discoveries:**
> - [Insights affecting other systems/services]
> - [Docs/ADR updates needed]
>
> **Scope Evolution:**
> - [How scope changed and why]
>
> **Follow-Up Needed:**
> - [Docs to update]
> - [New tasks to create]
*** End Patch
