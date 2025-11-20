---
type: task
task-id: IN-059
status: in-progress
priority: 5
category: docker
agent: docker
created: 2025-11-19
updated: 2025-11-19
started: 2025-11-19
completed:

# Task classification
complexity: simple
estimated_duration: 1h
critical_services_affected: false
requires_backup: false
requires_downtime: false

# Design tracking
alternatives_considered: false
risk_assessment_done: false
phased_approach: false

tags:
  - task
  - docker
  - vm-103
  - cookcli
---

# Task: IN-059 - Stand up CookCLI on VM 103

> **Quick Summary**: Deploy the `inigochoa/cookcli` container on VM 103 so household recipe management can run alongside the other auxiliary services.

## Problem Statement

**What problem are we solving?**
We want a lightweight recipe-management CLI/web interface on VM 103 so the household can organize Cooklang files without bloating the core media services.

**Why now?**
- The infrastructure is already running similar auxiliary services on VM 103, so it is a logical place to host CookCLI.
- CookCLI is described as a simple Dockerized tool, so there is minimal setup overhead.

**Who benefits?**
- **Household**: Gains an easy place to manage and browse Cooklang recipes from the existing infrastructure.

## Solution Design

### Recommended Approach

Bring up the `inigochoa/cookcli` image on VM 103 using an entry in `stacks/` (Docker + Portainer) and supply any minimal configuration that CookCLI expects (ports, volumes, etc.). Material such as the Docker Hub entry and Cooklang getting started guide confirm that CookCLI is primarily just a CLI/web interface that can be containerized with few requirements.

**Key components:**
- Docker stack for CookCLI (a `docker-compose.yml` inside `stacks/cookcli/`).
- `.env.example` listing any configurable values such as exposed port, data volume location, and host path for recipe files.
- README in the stack directory describing how to deploy/consume the service from VM 103.

**Rationale**: Keep the experience aligned with other auxiliary services by treating CookCLI as another Portainer-managed stack. The Docker image is already published and maintained, so we simply configure the compose, point volumes at our NFS storage, and deploy.

### Scope Definition

**✅ In Scope:**
- Add a CookCLI stack under `stacks/`.
- Document required environment variables.
- Deploy via Portainer on VM 103.
- Ensure the container can bind to the desired host port and persist recipe files.

**❌ Explicitly Out of Scope:**
- Integrating CookCLI with other services or automation pipelines.
- Building custom UI or API layers beyond the upstream container.

**🎯 MVP (Minimum Viable):**
Container runs on VM 103, listens on the configured port, and sees an NFS directory with recipe files.

## Risk Assessment

### Potential Pitfalls

- ⚠️ **Risk 1: Port collision** → **Mitigation**: Choose a port that is free on VM 103 and document it in the README.
- ⚠️ **Risk 2: Volume permissions** → **Mitigation**: Match ownership/permissions of the recipe directory to the container’s expectation or fix via init script.

### Dependencies

**Prerequisites (must exist before starting):**
- [x] **VM 103 accessible** – VM is already operating (non-blocking).
- [x] **Portainer stack pipeline in place** – We'll deploy through Portainer (non-blocking).

**No blocking dependencies - can start immediately**

### Critical Service Impact

**Services Affected**: None. This stack will only run on VM 103 alongside other misc services.

### Rollback Plan

**Applicable for**: Docker service deployment

**How to rollback if this goes wrong:**
1. Remove the stack via Portainer or `docker stack rm`.
2. Delete the `stacks/cookcli/` directory or rename it to keep a history copy.
3. Revert the git commit that introduced the stack if needed.

**Recovery time estimate**: 10 minutes

**Backup requirements:**
- Not required (new service with no existing data).

## Execution Plan

### Phase 1: Setup

**Primary Agent**: `docker`

- [x] **Review CookCLI image requirements** `[agent:docker]`
  - Confirm exposed ports, entrypoint, and defaults via Docker Hub/official docs.
  - Identify expected environment variables or volume mounts.

- [x] **Author `docker-compose.yml`** `[agent:docker]`
  - Reference other stacks for formatting.
  - Map a host recipe directory (ideally on NFS) for persistence.
  - Set up restart policies and logging.

- [x] **Create `.env.example`** `[agent:docker]`
  - List any configurable values with descriptions.

- [x] **Add `README.md`** `[agent:docker]`
  - Write deployment, access, and troubleshooting guidance.

### Phase 2: Deployment

**Primary Agent**: `docker`

- [ ] **Deploy stack on VM 103 via Portainer** `[agent:docker]`
  - Commit new stack files.
  - Use Portainer to deploy from git.
  - Confirm container reaches `healthy` status.

- [ ] **Provision `.env` on VM 103** `[agent:docker]`
  - Copy values from vault (if any).
  - Ensure file and parent directories have proper permissions.

### Phase 3: Validation & Testing

**Primary Agent**: `testing`

- [ ] **Smoke test the service** `[agent:testing]`
  - `docker ps` shows `cookcli` running.
  - Access the HTTP/CLI surface to confirm the service responds.

### Phase 4: Documentation

**Primary Agent**: `documentation`

- [ ] **Update stack inventory docs** `[agent:documentation]`
  - Ensure `stacks/README.md` references this service.
  - Link to the Docker Hub page and Cooklang docs for context.

## Acceptance Criteria

**Done when all of these are true:**
- [ ] Stack files for CookCLI are committed and valid.
- [ ] `.env.example` documents every variable needed.
- [ ] Stack deployed on VM 103 with the container running.
- [ ] Basic functionality verified manually.
- [ ] Documentation updated.
- [ ] All execution plan items completed.
- [ ] Changes ready for user review.

## Testing Plan

**Manual validation:**
1. Check `docker ps` on VM 103 for the CookCLI container.
2. Confirm logs show the service came up cleanly.
3. Access CookCLI via its configured port and ensure it responds.
4. Verify persistence by creating a recipe file and seeing it survive a restart.

## Related Documentation

1. [CookCLI Docker Hub](https://hub.docker.com/r/inigochoa/cookcli)
2. [Cooklang Getting Started](https://cooklang.org/docs/getting-started/)

## Notes

**Priority Rationale**: Low-to-medium priority convenience service that should not impact critical services.

**Complexity Rationale**: Simple deployment of a published container.

**Implementation Notes**:
- Keep the stack consistent with existing stacks under `stacks/`.
- Use dedicated host path for recipes so backups can include them easily.

**Follow-up Tasks**:
- IN-XXX: Integrate CookCLI with other automation (future work)

---

> [!note]- 📋 Work Log
>
> **2025-11-19 - Phase 1 (Setup)**
> - Created the `stacks/cookcli/` directory with `docker-compose.yml`, `.env.example`, and `README.md`.
> - Recorded the stack in `stacks/README.md` so Portainer can track the new entry.

> **2025-11-19 - Networking Fix**
> - Added the `traefik-network` attachment to the CookCLI and Paperless-AI services so Traefik can route `recipes.infinity-node.com` and `paperless-ai.local.infinity-node.com`.

> **2025-11-19 - GHCR Automation**
> - Authored `ensure-ghcr-registry.sh`, `set-stack-registry.sh`, and `sync-ghcr-stacks.sh` to automate attaching all GHCR-based stacks to the new Portainer registry credentials (prevents scheduler pull failures).

> [!tip]- 💡 Lessons Learned
>
> *Lessons will be captured during execution*
