---
type: task
task-id: IN-057
status: in-progress
priority: 4
category: docker
agent: docker
created: 2025-11-16
updated: 2025-11-16
started: 2025-11-16
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
  - vm-101
  - downloads-stack
  - new-service
---

# Task: IN-057 - Set up Mylar3 Docker Stack on VM 101 (downloads VM)

> **Quick Summary**: Deploy `linuxserver/mylar3` as a Docker stack on the downloads VM (VM 101) so comic metadata/download automation runs beside the download clients.

## Problem Statement

**What problem are we solving?**
- Mylar3 provides dedicated automation for comic/site metadata and download coordination, but it is not yet standing up alongside the download clients on VM 101.

**Why now?**
- Adds a focused automation tool next to the download clients so comic downloads share the same host.
- VM 101 is already hosting the download clients, making it the logical place for Mylar3.

**Who benefits?**
- **Household**: better comic and book media automation tied to download clients.
- **Media Stack Operator**: aligned download pipeline with a dedicated comic automation front end.

## Solution Design

### Recommended Approach

Deploy the `linuxserver/mylar3` container (per https://hub.docker.com/r/linuxserver/mylar3) inside `stacks/mylar3/` so the downloads VM can run comic automation with existing tooling.

**Key components:**
- Docker Compose configuration for Mylar3 with volumes for config, comics, and downloads.
- Environment template (`.env.example`) documenting overrides and download-specific paths.
- README that explains deployment and integration points for the downloads VM.

**Rationale**: Hosting Mylar3 on VM 101 keeps the download automation tools together and shares existing NAS mount points already used by the download clients.

### Scope Definition

**✅ In Scope:**
- Create `stacks/mylar3/docker-compose.yml`.
- Create `.env.example` with required variables.
- Document deployment and access steps in `stacks/mylar3/README.md`.
- Deploy via Portainer on VM 101, referencing the downloads-stack network and volumes.

**❌ Explicitly Out of Scope:**
- Importing existing comic libraries or migrating data from other systems.
- Writing custom scrapers or driver scripts beyond what LinuxServer image provides.

**🎯 MVP:**
Mylar3 container running on VM 101, accessible on a dedicated port, persisting configuration, and documented.

## Risk Assessment

### Potential Pitfalls
- ⚠️ **Port conflicts with existing download services** → **Mitigation**: pick an unused port (e.g., 8085) and verify no conflict.
- ⚠️ **Data persistence misconfiguration** → **Mitigation**: use documented volumes with proper permissions.
- ⚠️ **Resource contention on VM 101** → **Mitigation**: monitor after deployment and tune resource limits.

### Dependencies

- [x] **VM 101 reachable** - Already running and hosting download clients.

### Critical Service Impact

**Services Affected**: Download services on VM 101 share the host; stack must fit without disrupting them.

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

- [x] **Review LinuxServer Mylar3 requirements** `[agent:docker]`
  - Confirm required env vars and ports from https://hub.docker.com/r/linuxserver/mylar3
- [x] **Create docker-compose.yml** `[agent:docker]`
  - Define service, ports, volumes, restart policy, updates settings
- [x] **Draft `.env.example`** `[agent:docker]`
  - Document optional overrides (e.g., `PUID`, `PGID`, `TZ`, `MYLAR_CONFIG`)
- [x] **Write README.md** `[agent:documentation]`
  - Explain purpose, access URL, and restart/deploy steps

### Phase 2: Deployment

**Primary Agent**: `docker`

- [ ] **Deploy via Portainer on VM 101** `[agent:docker]`
  - Pull latest image, configure env/volumes, set ports
- [ ] **Provision `.env` on VM 101** `[agent:docker]`
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

- [ ] **Update downloads stack inventory** `[agent:documentation]`
  - Mention Mylar3 in `stacks/README.md` and relevant index

## Acceptance Criteria

**Done when:**
- [ ] `stacks/mylar3/docker-compose.yml` exists and passes validation.
- [ ] `.env.example` captures all Mylar3 env options.
- [ ] README explains deployment and access.
- [ ] Stack deployed and running on VM 101 via Portainer.
- [ ] Service reachable on configured port and responding.
- [ ] Execution plan checklist fully completed.
- [ ] All changes documented for review.

## Testing Plan

**Manual validation:**
1. `docker ps` on VM 101 shows Mylar3 container.
2. `docker logs` show successful startup.
3. Access UI on configured port (e.g., `http://vm-101:8085`).
4. Restart container and confirm config persists in volume.

## Related Documentation

- [[docs/agents/DOCKER|Docker Agent]]
- [[stacks/README|Docker Stacks Overview]]
- [LinuxServer Mylar3 Docker Hub](https://hub.docker.com/r/linuxserver/mylar3)

## Notes

**Priority Rationale**:
Download services are critical, so priority remains moderate-high (4).

**Complexity Rationale**:
Simple Docker stack addition leveraging existing patterns.

**Implementation Notes**:
- Mirror other VM 101 services for env structure and permitted mount points.
- Consider exposing port 8085 and document it.
- Use `PUID/PGID` consistent with service account on VM 101.

**Follow-up Tasks**:
- IN-0XX: Automate Mylar3 config import/export (future).

---

> [!note]- 📋 Work Log
>
> *Work log entries will be added during execution*

> [!tip]- 💡 Lessons Learned
>
> *Lessons will be captured during execution*
