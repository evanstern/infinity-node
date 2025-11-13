---
type: task
task-id: IN-049
status: superseded
priority: 4
category: docker
agent: docker
created: 2025-01-27
updated: 2025-01-27
superseded-date: 2025-11-13
superseded-reason: Replacing with Kavita book server instead of Calibre-Web-Automated Book Downloader

# Task classification
complexity: moderate
estimated_duration: 3-4h
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
  - media
  - automation
  - infrastructure
  - superseded
---

> [!warning]- ⚠️ Task Superseded
>
> **Status**: This task has been superseded and will not be completed as originally planned.
>
> **Reason**: Decision made to deploy Kavita as the book server solution instead of Calibre-Web-Automated and its book downloader. This task was dependent on IN-048 (which is also superseded).
>
> **Date**: 2025-11-13
>
> **Preserved because**: This task contains planning around book acquisition automation and infrastructure integration that may be useful for Kavita setup.

# Task: IN-049 - Deploy Calibre-Web-Automated Book Downloader

> **Quick Summary**: Deploy the Calibre-Web-Automated Book Downloader service to enable automated book acquisition, integrating with Calibre-Web-Automated and configuring full infrastructure integration.

## Problem Statement

**What problem are we solving?**
Currently, books must be manually downloaded and added to the Calibre library. The Calibre-Web-Automated Book Downloader automates book acquisition from various sources, streamlining the e-book management workflow and reducing manual effort.

**Why now?**
- Calibre-Web-Automated (IN-048) provides the foundation for this integration
- Automated book acquisition significantly improves workflow efficiency
- Complements CWA's automated ingestion and conversion features
- Enables end-to-end automated e-book management pipeline

**Who benefits?**
- **Evan**: Automated book acquisition, reduced manual work, streamlined workflow
- **Future users**: Seamless book discovery and acquisition experience

## Solution Design

### Recommended Approach

Deploy the Calibre-Web-Automated Book Downloader as a separate service that integrates with Calibre-Web-Automated. Configure it to authenticate with CWA's database and automatically download books to CWA's ingest folder for processing.

**Key components:**
- **Book Downloader Stack**: Docker compose configuration for downloader service
- **CWA Integration**: Configure database path for authentication with CWA
- **Download Configuration**: Set up download sources, formats, retry logic
- **Infrastructure Integration**: Traefik routing, Pi-Hole DNS, Pangolin tunnel
- **Ingest Integration**: Configure downloads to go to CWA ingest folder

**Rationale**:
- Separate service allows independent scaling and management
- Integration with CWA enables seamless workflow (download → ingest → conversion → library)
- Follows existing infrastructure patterns (Traefik, DNS, tunnels)
- Moderate complexity - new service deployment with integration requirements

> [!abstract]- 🔀 Alternative Approaches Considered
>
> **Option A: Manual Download Only**
> - ✅ Pros: Simpler, no additional service
> - ❌ Cons: No automation, manual work required
> - **Decision**: Not chosen - Automation is valuable
>
> **Option B: Integrate Downloader into CWA Container**
> - ✅ Pros: Single container, simpler deployment
> - ❌ Cons: Not how downloader is designed, harder to manage
> - ❌ Cons: Less flexible for updates/maintenance
> - **Decision**: Not chosen - Separate service is cleaner architecture
>
> **Option C: Deploy Without Infrastructure Integration**
> - ✅ Pros: Faster deployment
> - ❌ Cons: Inconsistent access patterns
> - ❌ Cons: No external access capability
> - **Decision**: Not chosen - Full integration ensures consistency

### Scope Definition

**✅ In Scope:**
- Deploy Calibre-Web-Automated Book Downloader stack on VM 103
- Configure integration with Calibre-Web-Automated (database authentication)
- Configure download settings (sources, formats, retry logic)
- Configure download output to CWA ingest folder
- Configure Traefik routing for downloader service
- Add Pi-Hole DNS records for downloader service
- Configure Pangolin tunnel for external access (if needed)
- Document downloader configuration and usage

**❌ Explicitly Out of Scope:**
- Configuring specific download sources (user will configure after deployment)
- Advanced downloader features (basic setup only)
- Downloader-specific authentication (uses CWA database)
- Bulk book downloads (manual configuration after setup)

**🎯 MVP (Minimum Viable)**:
- Downloader service deployed and running
- Integrated with CWA (can authenticate)
- Downloads go to CWA ingest folder
- Accessible via Traefik
- Basic configuration documented

## Risk Assessment

### Potential Pitfalls

- ⚠️ **Risk 1: CWA Integration Issues** → **Mitigation**:
  - Verify CWA database path is correct
  - Test authentication with CWA
  - Verify ingest folder path is accessible
  - Document integration requirements

- ⚠️ **Risk 2: Download Folder Permissions** → **Mitigation**:
  - Ensure downloader has write access to CWA ingest folder
  - Verify PUID/PGID match CWA configuration
  - Test file creation in ingest folder
  - Document permission requirements

- ⚠️ **Risk 3: Downloader Configuration Errors** → **Mitigation**:
  - Follow repository documentation carefully
  - Test with simple download first
  - Verify logs for errors
  - Document configuration options

- ⚠️ **Risk 4: Resource Usage** → **Mitigation**:
  - Set appropriate resource limits
  - Monitor initial downloads for resource usage
  - Adjust limits if needed
  - Document resource requirements

### Dependencies

**Prerequisites (must exist before starting):**
- [ ] **Calibre-Web-Automated deployed** - IN-048 must be complete (blocking: yes)
- [x] **Traefik running on VM 103** - Already configured (blocking: no)
- [x] **Pi-Hole DNS configured** - Already running (blocking: no)
- [x] **Pangolin/Newt on VM 103** - Already configured (blocking: no)
- [x] **NAS mounts available** - NFS mounts configured (blocking: no)

**Has blocking dependencies - blocked by IN-048**

### Critical Service Impact

**Services Affected**: None (new service, no impact on existing services)

**Impact Level**: None - This is a new service deployment with no impact on critical services or existing functionality.

### Rollback Plan

**Applicable for**: Docker service deployment

**How to rollback if this goes wrong:**
1. Stop downloader stack via Portainer
2. Remove downloader stack if needed
3. Remove Traefik routing configuration
4. Remove Pi-Hole DNS records
5. Remove Pangolin tunnel configuration (if added)
6. Verify no impact on CWA or other services

**Recovery time estimate**: 5-10 minutes (stop service, remove configurations)

**Backup requirements:**
- No backup required (new service, no existing data)
- Backup Traefik dynamic.yml before changes
- Export Pi-Hole DNS records before changes

## Execution Plan

### Phase 0: Prerequisites Check

**Primary Agent**: `docker`

- [ ] **Verify IN-048 completion** `[agent:docker]` `[depends:IN-048]`
  - Verify Calibre-Web-Automated is deployed and running
  - Verify CWA database location is known
  - Verify CWA ingest folder location is known
  - Document CWA integration points

### Phase 1: Book Downloader Stack Creation

**Primary Agent**: `docker`

- [ ] **Review downloader repository** `[agent:docker]`
  - Review repository README and documentation
  - Understand configuration requirements
  - Understand CWA integration requirements
  - Document key configuration options

- [ ] **Create downloader docker-compose.yml** `[agent:docker]`
  - Base on repository docker-compose example
  - Configure volume mounts:
    - CWA database path (for authentication)
    - CWA ingest folder (for download output)
    - Downloader config directory
  - Configure environment variables:
    - `CWA_DB_PATH` - Path to CWA app.db
    - Download settings (retry, formats, language)
    - Logging configuration
  - Set resource limits
  - Configure networks (default, traefik-network)
  - Set restart policy

- [ ] **Create downloader .env.example** `[agent:docker]`
  - Document all environment variables
  - Document CWA integration variables
  - Document download configuration options
  - Match existing stack patterns

- [ ] **Create downloader README.md** `[agent:documentation]`
  - Document downloader features
  - Document CWA integration
  - Document configuration options
  - Document usage instructions

### Phase 2: CWA Integration Configuration

**Primary Agent**: `docker`

- [ ] **Configure CWA database path** `[agent:docker]` `[risk:1]`
  - Set `CWA_DB_PATH` environment variable
  - Point to CWA app.db location
  - Verify path is accessible from downloader container
  - Test authentication with CWA

- [ ] **Configure ingest folder integration** `[agent:docker]` `[risk:2]`
  - Mount CWA ingest folder to downloader
  - Configure downloader output to ingest folder
  - Verify write permissions
  - Test file creation in ingest folder

- [ ] **Configure download settings** `[agent:docker]`
  - Set retry attempts
  - Configure supported formats
  - Set preferred language
  - Configure logging level
  - Document configuration options

### Phase 3: Infrastructure Integration

**Primary Agent**: `infrastructure` (with `security` for Pangolin)

- [ ] **Configure Traefik routing** `[agent:infrastructure]`
  - Add downloader router to Traefik dynamic.yml (vm-103)
  - Configure service backend (calibre-web-automated-downloader:PORT)
  - Use hostname: `calibre-downloader.local.infinity-node.com`
  - Test routing
  - Document routing configuration

- [ ] **Add Pi-Hole DNS records** `[agent:infrastructure]`
  - Add DNS record for downloader service
  - Use `calibre-downloader.local.infinity-node.com`
  - Verify DNS resolution
  - Document DNS configuration

- [ ] **Configure Pangolin tunnel (if needed)** `[agent:security]`
  - Assess if external access needed for downloader
  - If needed, create Pangolin tunnel configuration
  - Configure tunnel to point to Traefik route
  - Test external access
  - Document tunnel configuration

### Phase 4: Deployment

**Primary Agent**: `docker`

- [ ] **Deploy downloader stack via Portainer** `[agent:docker]`
  - Create new stack in Portainer (Git-integrated)
  - Configure environment variables
  - Deploy stack
  - Verify containers start successfully
  - Check logs for errors

- [ ] **Verify CWA integration** `[agent:docker]` `[agent:testing]`
  - Verify downloader can authenticate with CWA
  - Verify downloader can write to ingest folder
  - Test downloader web interface (if available)
  - Verify logs show successful CWA connection

### Phase 5: Validation & Testing

**Primary Agent**: `testing`

- [ ] **Validate downloader deployment** `[agent:testing]`
  - Downloader container running and healthy
  - Downloader accessible via Traefik (if web interface)
  - Downloader accessible externally via Pangolin (if configured)
  - CWA integration working (authentication successful)

- [ ] **Validate infrastructure integration** `[agent:testing]`
  - DNS resolution working (Pi-Hole)
  - Traefik routing working (if web interface)
  - Pangolin tunnel working (if configured)
  - No port conflicts

- [ ] **Test download functionality** `[agent:testing]` `[risk:3]`
  - Configure a test download (if possible)
  - Verify download goes to CWA ingest folder
  - Verify CWA processes downloaded book
  - Document test results

### Phase 6: Documentation

**Primary Agent**: `documentation`

- [ ] **Update downloader README.md** `[agent:documentation]`
  - Document deployment process
  - Document CWA integration
  - Document configuration options
  - Document usage instructions

- [ ] **Update architecture documentation** `[agent:documentation]`
  - Update ARCHITECTURE.md with downloader details
  - Update service list
  - Document downloader in network services section

- [ ] **Create integration documentation** `[agent:documentation]`
  - Document CWA integration process
  - Document ingest folder workflow
  - Document troubleshooting steps

- [ ] **Update task notes** `[agent:documentation]`
  - Document lessons learned
  - Document any issues encountered
  - Document recommendations for future work

## Acceptance Criteria

**Done when all of these are true:**
- [ ] Calibre-Web-Automated Book Downloader deployed and running
- [ ] Downloader integrated with CWA (authentication working)
- [ ] Downloader configured to output to CWA ingest folder
- [ ] Downloader accessible via Traefik (if web interface)
- [ ] Downloader accessible externally via Pangolin (if configured)
- [ ] Traefik routing configured and working
- [ ] Pi-Hole DNS records added and working
- [ ] Test download successful (if possible)
- [ ] All execution plan items completed
- [ ] Testing Agent validates (see testing plan below)
- [ ] Changes committed with descriptive message (awaiting user approval)

## Testing Plan

**[[docs/agents/TESTING|Testing Agent]] validates:**
- Downloader container running and healthy
- Downloader web interface responds (if available)
- Traefik routes requests to downloader correctly (if web interface)
- DNS resolution works for downloader hostname
- Pangolin tunnel provides external access (if configured)
- CWA integration working (authentication successful)
- Ingest folder accessible and writable
- No port conflicts with existing services

**Manual validation:**
1. **Container Status**: Verify downloader container is running (`docker ps`)
2. **Logs Check**: Review downloader logs for errors or CWA connection issues
3. **CWA Integration**: Verify downloader can authenticate with CWA (check logs)
4. **Ingest Folder**: Verify downloader can write to CWA ingest folder
5. **Web Interface**: Access downloader web interface via Traefik (if available)
6. **External Access**: Test external access via Pangolin (if configured)
7. **Test Download**: Configure and test a simple download (if possible)
8. **Workflow Test**: Verify downloaded book appears in CWA after processing
9. **Traefik Check**: Verify port-free access works via Traefik (if web interface)
10. **DNS Check**: Verify DNS resolution from multiple devices

## Related Documentation

- [[docs/ARCHITECTURE|Infrastructure Architecture]]
- [[docs/agents/DOCKER|Docker Agent Specification]]
- [[docs/agents/INFRASTRUCTURE|Infrastructure Agent Specification]]
- [[docs/agents/SECURITY|Security Agent Specification]]
- [[docs/runbooks/traefik-management|Traefik Management Runbook]]
- [[docs/runbooks/pihole-dns-management|Pi-Hole DNS Management Runbook]]
- [[tasks/backlog/IN-048-deploy-calibre-web-automated|Task IN-048 - CWA Deployment]]
- [Calibre-Web-Automated Book Downloader Repository](https://github.com/calibrain/calibre-web-automated-book-downloader)
- [Calibre-Web-Automated Repository](https://github.com/crocodilestick/Calibre-Web-Automated)

## Notes

**Priority Rationale**:
Priority 4 (medium-low) - This is a valuable automation feature but depends on IN-048 completion. Lower priority than the main CWA deployment. Enhances workflow but not critical.

**Complexity Rationale**:
Moderate - This involves deploying a new service with integration requirements (CWA), infrastructure setup (Traefik, DNS, tunnels), and configuration. Less complex than IN-048 as it's a new service rather than a migration.

**Implementation Notes**:
- Depends on IN-048 completion (CWA must be deployed first)
- Downloader integrates with CWA via database authentication
- Downloads go to CWA ingest folder for automatic processing
- May or may not have web interface (check repository)
- External access via Pangolin may not be needed (assess use case)
- Configuration will be basic - user can configure sources after deployment

**Follow-up Tasks**:
- Future: Configure specific download sources
- Future: Set up download schedules/automation
- Future: Configure advanced downloader features
- Future: Monitor downloader performance and adjust

---

> [!note]- 📋 Work Log
>
> *Work log will be populated during task execution*

> [!tip]- 💡 Lessons Learned
>
> *Lessons learned will be populated during task execution*
