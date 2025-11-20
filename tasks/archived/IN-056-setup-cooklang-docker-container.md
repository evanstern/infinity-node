---
type: task
task-id: IN-056
status: archived
priority: 5
category: docker
agent: docker
created: 2025-11-16
updated: 2025-11-16
started:
completed:

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
  - vm-103
  - new-service
---

# Task: IN-056 - Set up CookLang Docker Container

> **Quick Summary**: Deploy CookCLI (CookLang recipe management tool) as a Docker container on VM 103

## Problem Statement

**What problem are we solving?**
Need to set up a CookLang recipe management and organization system. CookCLI provides a command-line interface for managing recipes in a structured format.

**Why now?**
- Adding new service to the miscellaneous services VM
- Kitchen/recipe management enhancement

**Who benefits?**
- **Household**: Recipe organization and management system

## Solution Design

### Recommended Approach

Deploy cookcli Docker image (`inigochoa/cookcli`) on VM 103 (misc services VM). This will provide a containerized recipe management interface accessible to household users.

**Key components:**
- CookCLI Docker container from Docker Hub: `inigochoa/cookcli`
- Docker compose configuration in `stacks/cookcli/`
- Environment setup on VM 103

**Rationale**: Using Docker keeps the service isolated, easy to manage, and consistent with the rest of the infrastructure.

### Scope Definition

**✅ In Scope:**
- Create docker-compose.yml for cookcli stack
- Create `.env.example` template with required variables
- Deploy on VM 103 via Portainer
- Create stack documentation (README.md)

**❌ Explicitly Out of Scope:**
- Integration with existing recipe databases
- Custom recipe import scripts
- API endpoint configuration (future enhancement)

**🎯 MVP (Minimum Viable)**:
Container running and accessible via Portainer, basic functionality available

## Risk Assessment

### Potential Pitfalls

- ⚠️ **Risk 1: Missing documentation** → **Mitigation**: Create comprehensive README with setup steps

- ⚠️ **Risk 2: Port conflicts** → **Mitigation**: Check available ports on VM 103 before deployment

- ⚠️ **Risk 3: Data persistence** → **Mitigation**: Use NFS mount for recipe data to survive container restarts

### Dependencies

**Prerequisites (must exist before starting):**
- [x] **VM 103 accessible** - VM is running (non-blocking)
- [x] **Portainer configured** - Stack management system ready (non-blocking)
- [x] **NFS storage available** - For data persistence (non-blocking)

**No blocking dependencies - can start immediately**

### Critical Service Impact

**Services Affected**: None

This is a new, non-critical service. No existing critical services are impacted by deployment.

### Rollback Plan

**Applicable for**: Docker service deployment

**How to rollback if this goes wrong:**
1. Remove stack via Portainer UI or CLI
2. Remove stack directory: `rm -rf stacks/cookcli/`
3. No configuration restoration needed (new service)

**Recovery time estimate**: 5 minutes

**Backup requirements:**
- None (new service with no existing data)

## Execution Plan

### Phase 1: Setup & Configuration

**Primary Agent**: `docker`

- [ ] **Research cookcli requirements** `[agent:docker]`
  - Check Docker Hub documentation
  - Identify required environment variables
  - Determine port requirements

- [ ] **Create docker-compose.yml** `[agent:docker]`
  - Include service definition
  - Configure volumes for data persistence
  - Set up environment variable support

- [ ] **Create .env.example** `[agent:docker]`
  - Document all required environment variables
  - Add helpful comments for configuration

- [ ] **Create README.md** `[agent:docker]`
  - Document service purpose and features
  - Include setup/access instructions
  - Add troubleshooting guide

### Phase 2: Deployment

**Primary Agent**: `docker`

- [ ] **Deploy stack via Portainer** `[agent:docker]`
  - Commit changes to git
  - Use Portainer to deploy new stack
  - Verify container is running

- [ ] **Create .env file on VM 103** `[agent:docker]`
  - Use values from Vaultwarden if needed
  - Ensure proper permissions

### Phase 3: Validation & Testing

**Primary Agent**: `testing`

- [ ] **Verify container health** `[agent:testing]`
  - Check `docker ps` shows running container
  - Check logs for startup errors

- [ ] **Test basic functionality** `[agent:testing]`
  - Access service via configured port/URL
  - Confirm service responds to requests

### Phase 4: Documentation

**Primary Agent**: `documentation`

- [ ] **Update service inventory** `[agent:documentation]`
  - Add to stacks/README.md if needed
  - Update service documentation index

## Acceptance Criteria

**Done when all of these are true:**
- [ ] Docker compose file created and valid
- [ ] .env.example template created with all variables
- [ ] README documentation complete
- [ ] Stack deployed successfully on VM 103
- [ ] Container running and healthy
- [ ] Basic access/functionality confirmed
- [ ] All execution plan items completed
- [ ] Changes committed (awaiting user approval)

## Testing Plan

**Manual validation:**
1. Verify container status: `docker ps` on VM 103 shows cookcli running
2. Check logs: `docker logs` for startup errors
3. Verify accessibility: Can reach the service via configured endpoint
4. Confirm data persistence: Verify volumes are mounted correctly

## Related Documentation

- [[docs/agents/DOCKER|Docker Agent]]
- [[stacks/README|Docker Stacks Overview]]
- [CookCLI Docker Hub](https://hub.docker.com/r/inigochoa/cookcli)

## Notes

**Priority Rationale**:
Medium priority - new convenience service, non-critical

**Complexity Rationale**:
Simple - straightforward Docker deployment, no complex configuration needed

**Implementation Notes**:
- Follow existing stack patterns from other services (e.g., Kavita, Calibre)
- Use NFS for data persistence to match infrastructure approach
- Keep configuration minimal for MVP

**Follow-up Tasks**:
- IN-XXX: Integrate with existing recipe/cookbook system (future)
- IN-XXX: Add API/external access for remote recipe management (future)

---

> [!note]- 📋 Work Log
>
> *Work log entries will be added during execution*

> [!tip]- 💡 Lessons Learned
>
> *Lessons will be captured during execution*
