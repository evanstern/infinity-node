---
type: task
task-id: IN-057
status: pending
priority: 4
category: docker
agent: docker
created: 2025-11-16
updated: 2025-11-16
started:
completed:

# Task classification
complexity: simple
estimated_duration: 2-3h
critical_services_affected: true
requires_backup: false
requires_downtime: false

# Design tracking
alternatives_considered: false
risk_assessment_done: false
phased_approach: false

tags:
  - task
  - docker
  - vm-102
  - arr-stack
  - new-service
---

# Task: IN-057 - Set up Mylar3 Docker Stack on VM 102

> **Quick Summary**: Deploy `linuxserver/mylar3` as a Docker stack on the ARR automation VM (VM 102) to serve book/comic metadata and download automation next to the rest of the ARR services.

## Problem Statement

**What problem are we solving?**
Mylar3 provides dedicated automation for comic/site metadata and download coordination, but it is not yet standing up alongside the ARR services on VM 102.

**Why now?**
- Extends the ARR automation stack with a focused tool that keeps metadata and downloads organized.
- VM 102 is already dedicated to ARR services, so adding Mylar3 keeps automation consolidated.

**Who benefits?**
- **Household**: better comic and book media automation.
- **Media Stack Operator**: one-stop ARR automation stack.

## Solution Design

### Recommended Approach

Deploy the `linuxserver/mylar3` container (per https://hub.docker.com/r/linuxserver/mylar3) inside a new stack directory under `stacks/mylar3/`.

**Key components:**
- Docker Compose configuration for Mylar3 with volumes for config and downloads (NFS-backed if needed).
- Environment template (`.env.example`) documenting any overridable settings.
- README that covers purpose, access, and connection details to the existing ARR stack.

**Rationale**: Keeping this container within the ARR VM keeps related automation together and leverages Portainer + Gitflows already used for other stacks.

### Scope Definition

**✅ In Scope:**
- Create `stacks/mylar3/docker-compose.yml`.
- Create `.env.example` with required variables.
- Document deployment and access steps in `stacks/mylar3/README.md`.
- Deploy via Portainer on VM 102, referencing the ARR stack network and volumes.

**❌ Explicitly Out of Scope:**
- Importing existing comic libraries or migrating data from other systems.
- Writing custom scrapers or driver scripts beyond what LinuxServer image provides.

**🎯 MVP:**
Mylar3 container running on VM 102, accessible on a dedicated port, persisting configuration, and documented.

## Risk Assessment

### Potential Pitfalls
- ⚠️ **Port conflicts with existing ARR services** → **Mitigation**: pick an unused port (e.g., 8085) and verify no conflict.
- ⚠️ **Data persistence misconfiguration** → **Mitigation**: use documented volumes with proper permissions (NFS if necessary).
- ⚠️ **Resource contention on VM 102** → **Mitigation**: monitor after deployment; adjust restart policies and limits.

### Dependencies

**Prerequisites:**
- [x] **VM 102 reachable** - Already running and hosting ARR services.
- [x] **Portainer ready** - Stack deployments controlled via Portainer.
- [ ] **NFS storage available** - For downloads/metadata persistence if needed.

### Critical Service Impact

**Services Affected**: ARR automation services share VM 102; new stack must not disrupt them.

### Rollback Plan

**Applicable for**: new Docker stack.

**How to rollback if this goes wrong:**
1. Remove stack from Portainer.
2. `rm -rf stacks/mylar3/`.
3. No existing data to restore beyond clearing volumes if created.

**Recovery time estimate**: 5 minutes.

## Execution Plan

### Phase 1: Research & Configuration

**Primary Agent**: `docker`

- [ ] **Review LinuxServer Mylar3 requirements** `[agent:docker]`
  - Confirm required env vars and ports from https://hub.docker.com/r/linuxserver/mylar3
- [ ] **Create docker-compose.yml** `[agent:docker]`
  - Define service, ports, volumes, restart policy, updates settings
- [ ] **Draft `.env.example`** `[agent:docker]`
  - Document optional overrides (e.g., `PUID`, `PGID`, `TZ`, `MYLAR_CONFIG`)
- [ ] **Write README.md** `[agent:documentation]`
  - Explain purpose, access URL, and restart/deploy steps

### Phase 2: Deployment

**Primary Agent**: `docker`

- [ ] **Deploy via Portainer on VM 102** `[agent:docker]`
  - Pull latest image, configure env/volumes, set ports
- [ ] **Provision `.env` on VM 102** `[agent:docker]`
  - Use `linuxserver/mylar3` examples, adjust IDs, timezone

### Phase 3: Validation

**Primary Agent**: `testing`

- [ ] **Check container health** `[agent:testing]`
  - `docker ps` shows running service
- [ ] **Test basic UI/API** `[agent:testing]`
  - Verify UI loads via assigned port
- [ ] **Confirm persistence** `[agent:testing]`
  - Ensure config directories survive restart

### Phase 4: Documentation

**Primary Agent**: `documentation`

- [ ] **Update ARR stack inventory** `[agent:documentation]`
  - Mention Mylar3 in `stacks/README.md` or relevant index

## Acceptance Criteria

**Done when:**
- [ ] `stacks/mylar3/docker-compose.yml` exists and passes validation.
- [ ] `.env.example` captures all Mylar3 env options.
- [ ] README explains deployment and access.
- [ ] Stack deployed and running on VM 102 via Portainer.
- [ ] Service reachable on configured port and responding.
- [ ] Execution plan checklist fully completed.
- [ ] All changes documented for review.

## Testing Plan

**Manual validation:**
1. `docker ps` on VM 102 shows Mylar3 container.
2. `docker logs` show successful startup.
3. Access UI on configured port (e.g., `http://vm-102:8085`).
4. Restart container and confirm config persists in volume.

## Related Documentation

- [[docs/agents/DOCKER|Docker Agent]]
- [[stacks/README|Docker Stacks Overview]]
- [LinuxServer Mylar3 Docker Hub](https://hub.docker.com/r/linuxserver/mylar3)

## Notes

**Priority Rationale**:
Arr automation stack is critical, so priority is moderate-high (4).

**Complexity Rationale**:
Simple Docker stack addition leveraging existing patterns.

**Implementation Notes**:
- Mirror other ARR-adjacent stacks (e.g., Komga) for env structure.
- Consider exposing port 8085 and document it.
- Use `PUID/PGID` consistent with other services on VM 102.

**Follow-up Tasks**:
- IN-0XX: Automate Mylar3 config import/export (future).

---

> [!note]- 📋 Work Log
>
> *Work log entries will be added during execution*

> [!tip]- 💡 Lessons Learned
>
> *Lessons will be captured during execution*
