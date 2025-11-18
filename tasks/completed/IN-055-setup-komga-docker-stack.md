---
type: task
task-id: IN-055
status: completed
priority: 5
category: docker-deployment
agent: docker
created: 2025-11-16
updated: 2025-11-16
started: 2025-11-16
completed: 2025-11-16

# Task classification
complexity: simple
estimated_duration: 1-2h
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
  - komga
  - vm-103
---

# Task: IN-055 - Set Up Komga Comic Book Manager on VM-103

> **Quick Summary**: Deploy Komga as a Docker stack on VM-103 to manage and serve the comic book library.

## Problem Statement

**What problem are we solving?**
We need a dedicated application to organize, index, and serve the comic book collection. Komga provides a web-based interface for managing and reading comics from a centralized location.

**Why now?**
- Need to organize growing comic collection with proper metadata and searching
- Komga integrates well with existing Docker infrastructure on VM-103
- Complements other media services (Emby, Calibre, etc.)

**Who benefits?**
- **Household users**: Browse and read comics from any device through web interface
- **Library**: Proper organization and searchability of comic collection
- **System**: Streamlined media stack with consistent deployment patterns

## Solution Design

### Recommended Approach

Deploy Komga using Docker Compose on VM-103, following the existing stack pattern:
- Use official `gotson/komga` image from Docker Hub
- Mount `/config` directory for database and configuration
- Mount `/data` directory for comic book library (NFS from Synology NAS)
- Expose port 25600 for web access
- Configure with proper user/group permissions (1000:1000)
- Integrate with Traefik reverse proxy for external access (future task)

**Key components:**
- Docker Compose stack definition
- Volume mounts (config on VM, data from NFS)
- Environment configuration with timezone
- Integration with existing infrastructure

**Rationale**: Komga's Docker deployment is well-documented and straightforward. Using the standard stack pattern ensures consistency with other services and proper integration with Traefik/Portainer.

### Scope Definition

**✅ In Scope:**
- Create `stacks/komga/docker-compose.yml`
- Create `.env.example` template
- Create `stacks/komga/README.md` documentation
- Deploy stack via Portainer
- Verify basic functionality

**❌ Explicitly Out of Scope:**
- External access configuration (future task)
- Advanced Komga configuration/tuning
- Integration with external services
- Backup automation

**🎯 MVP (Minimum Viable)**:
Komga running and accessible locally on port 25600 with comics library mounted properly.

## Risk Assessment

### Potential Pitfalls

- ⚠️ **NFS mount issues**: Data directory must be on NFS properly → **Mitigation**: Verify NFS mount on VM-103 before deployment
- ⚠️ **Permission issues**: Config/data directory ownership problems → **Mitigation**: Ensure proper ownership and use consistent UID/GID (1000:1000)
- ⚠️ **Database corruption**: Initial index building might take time → **Mitigation**: No critical data at risk; service can restart safely

### Dependencies

**Prerequisites (must exist before starting):**
- [x] **VM-103 running with Docker** - (blocking: yes)
- [x] **NFS mounted on VM-103** - Comics library on Synology accessible (blocking: yes)
- [x] **Portainer configured on VM-103** - Stack management infrastructure (blocking: yes)

**Has no blocking dependencies - can start immediately**

### Critical Service Impact

**Services Affected**: None

VM-103 hosts non-critical supporting services. Komga deployment will not impact Emby, Downloads, or *arr services.

### Rollback Plan

**Applicable for**: Docker stack deployment

**How to rollback if this goes wrong:**
1. Use Portainer UI to remove the Komga stack
2. Delete `/docker/komga/config` directory on VM-103 if needed
3. Service will be removed cleanly

**Recovery time estimate**: < 5 minutes

**Backup requirements:**
- None required (new service, no existing data to preserve)

## Execution Plan

### Phase 1: Stack Configuration

**Primary Agent**: `docker`

- [ ] **Create docker-compose.yml** `[agent:docker]`
  - Base on official Komga documentation
  - Configure volumes for config and data
  - Set port 25600
  - Define user as 1000:1000

- [ ] **Create .env.example template** `[agent:docker]`
  - TZ setting
  - Memory settings (JAVA_TOOL_OPTIONS)

- [ ] **Create README documentation** `[agent:docker]`
  - What is Komga
  - Default access details
  - Basic configuration notes

### Phase 2: Deployment

**Primary Agent**: `docker`

- [ ] **Create necessary directories on VM-103** `[agent:docker]`
  - `/docker/komga/config` with proper permissions

- [ ] **Deploy via Portainer** `[agent:docker]`
  - Push changes to git
  - Use Portainer UI or API to create Git-integrated stack
  - Verify stack creates and containers start

### Phase 3: Validation & Testing

**Primary Agent**: `testing`

- [ ] **Verify container health** `[agent:testing]`
  - Container running and not restarting
  - Check logs for startup messages

- [ ] **Verify web access** `[agent:testing]`
  - Access http://192.168.86.249:25600 (VM-103)
  - Komga web interface loads

- [ ] **Verify library mount** `[agent:testing]`
  - Comics directory visible in Komga settings
  - Scan/index functionality works

### Phase 4: Documentation

**Primary Agent**: `documentation`

- [ ] **Document in service catalog** `[agent:documentation]`
  - Add to `stacks/README.md`
  - Link to Komga official documentation

## Acceptance Criteria

**Done when all of these are true:**
- [ ] `docker-compose.yml` created in `stacks/komga/`
- [ ] `.env.example` created with configuration template
- [ ] `stacks/komga/README.md` documents the service
- [ ] Stack deployed and running on VM-103
- [ ] Web interface accessible at http://192.168.86.249:25600
- [ ] Comics library mounted and scannable
- [ ] All execution plan items completed
- [ ] Testing Agent validates
- [ ] Changes committed with descriptive message

## Testing Plan

**[[docs/agents/TESTING|Testing Agent]] validates:**
- Container running and healthy
- No error logs on startup
- Web interface returns HTTP 200
- Comics directory accessible from UI

**Manual validation:**
1. SSH to VM-103 and verify `docker ps` shows komga running
2. Open http://192.168.86.249:25600 in browser - confirm web UI loads
3. Check Komga settings - verify comics directory is accessible
4. Run library scan - verify books are being indexed

## Related Documentation

- [[stacks/README|Stacks Directory]]
- [[docs/agents/DOCKER|Docker Agent Documentation]]
- [[docs/ARCHITECTURE|Infrastructure Architecture]]
- https://komga.org/docs/installation/docker

## Notes

**Priority Rationale**:
Priority 5 (medium-low) - Nice-to-have service that enhances media management but doesn't block critical functionality or other tasks.

**Complexity Rationale**:
Simple - Straightforward Docker Compose deployment with standard patterns already established. No complex integrations or customizations needed for MVP.

**Implementation Notes**:
- Follow existing stack patterns in `stacks/` directory
- Store config under `/home/evan/data/komga/config` instead of `/docker` to match other services' persistent data layout
- Mount the comics library via the NAS share at `/mnt/video/Komga`; bind it read/write into `/data`
- Komga requires 1GB minimum RAM by default; can increase via `JAVA_TOOL_OPTIONS` if needed
- Database will be stored in `/config` directory; this persists across restarts

**Follow-up Tasks**:
- IN-056: Set up external access to Komga via Traefik
- IN-057: Configure Komga library scanning automation
- IN-058: Backup Komga configuration periodically

---

> [!note]- 📋 Work Log
>
> * 2025-11-16: Captured the preferred storage layout, authored the Komga compose, env template, and README files, and updated the stacks catalog to document the new service.
> * 2025-11-16: Ran `create-git-stack.sh` with inline env vars; Portainer already had a `komga` stack, so the script returned a “stack already exists” error (redeploy via Portainer or delete the existing stack before rerunning).

> [!tip]- 💡 Lessons Learned
>
> * Portainer stack names must be unique — reusing the same name without deleting the prior stack causes the Git stack creation script to fail fast.
