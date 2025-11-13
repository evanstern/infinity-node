---
type: task
task-id: IN-048
status: superseded
priority: 3
category: docker
agent: docker
created: 2025-01-27
updated: 2025-01-27
superseded-date: 2025-11-13
superseded-reason: Replacing with Kavita book server instead of Calibre-Web-Automated

# Task classification
complexity: complex
estimated_duration: 6-8h
critical_services_affected: false
requires_backup: true
requires_downtime: true

# Design tracking
alternatives_considered: true
risk_assessment_done: true
phased_approach: true

tags:
  - task
  - docker
  - media
  - migration
  - infrastructure
  - superseded
---

> [!warning]- ⚠️ Task Superseded
>
> **Status**: This task has been superseded and will not be completed as originally planned.
>
> **Reason**: Decision made to deploy Kavita as the book server solution instead of Calibre-Web-Automated. Kavita provides similar functionality with a different approach to book management.
>
> **Date**: 2025-11-13
>
> **Preserved because**: This task contains significant research and planning around Calibre-Web-Automated deployment, infrastructure integration patterns, and migration considerations that may be valuable for future reference.

# Task: IN-048 - Deploy Calibre-Web-Automated

> **Quick Summary**: Migrate from Calibre-Web to Calibre-Web-Automated (CWA), preserving existing library, configuration, and plugins, with NAS database support investigation and full infrastructure integration.

## Problem Statement

**What problem are we solving?**
Currently using standard Calibre-Web which lacks automation features. Calibre-Web-Automated provides automated book ingestion, format conversion, and enhanced features that would significantly improve the e-book management workflow. We need to migrate from the existing Calibre-Web setup while preserving all existing data, configuration, and plugins.

**Why now?**
- Calibre-Web-Automated offers significant automation improvements (automatic ingestion, conversion, etc.)
- Opportunity to consolidate and improve e-book management workflow
- Can leverage existing Calibre library and configuration
- Enables future integration with automated book downloader (IN-049)

**Who benefits?**
- **Evan**: Automated book management, better conversion capabilities, improved workflow
- **Future users**: Enhanced e-book library experience with automation

## Solution Design

### Recommended Approach

Deploy Calibre-Web-Automated as a replacement for Calibre-Web, migrating existing configuration, library, and plugins. Investigate and implement NAS-based database storage (though unsupported, many users have success). Configure full infrastructure integration (Traefik, Pi-Hole, Pangolin) and stop the existing Calibre-Web stack.

**Key components:**
- **Calibre-Web-Automated Stack**: New docker-compose.yml based on CWA image
- **Database Investigation**: Test NAS database support (SQLite on NFS) with monitoring
- **Migration Path**: Backup existing setup, migrate config/library/plugins to CWA format
- **Infrastructure Integration**: Traefik routing, Pi-Hole DNS, Pangolin tunnel
- **Service Decommission**: Stop Calibre-Web stack (and potentially Calibre if not needed)

**Rationale**:
- CWA is a drop-in replacement that can use existing Calibre-Web configuration
- NAS database support is worth investigating given infrastructure benefits (centralized storage)
- Full infrastructure integration ensures consistent access patterns
- Phased approach allows testing and validation before full migration

> [!abstract]- 🔀 Alternative Approaches Considered
>
> **Option A: Keep Calibre-Web, Add CWA Alongside**
> - ✅ Pros: No migration risk, can test CWA independently
> - ✅ Pros: Easy rollback
> - ❌ Cons: Duplicate services, resource waste
> - ❌ Cons: Two separate libraries to manage
> - **Decision**: Not chosen - Migration is cleaner and CWA is designed as replacement
>
> **Option B: Local Database Only (No NAS)**
> - ✅ Pros: Supported configuration, lower risk
> - ✅ Pros: Better SQLite performance
> - ❌ Cons: Database on VM disk (limited space, not centralized)
> - ❌ Cons: Doesn't leverage NAS infrastructure
> - **Decision**: Not chosen - NAS investigation is worth the effort, can fallback if issues
>
> **Option C: Full Migration Without Backup**
> - ✅ Pros: Faster execution
> - ❌ Cons: High risk of data loss
> - ❌ Cons: No recovery path
> - **Decision**: Not chosen - Backup is mandatory for any migration

### Scope Definition

**✅ In Scope:**
- Deploy Calibre-Web-Automated stack on VM 103
- Investigate and attempt NAS database configuration (with fallback plan)
- Backup existing Calibre-Web configuration, library, and plugins
- Migrate existing Calibre-Web config/library/plugins to CWA
- Configure Traefik routing for CWA
- Add Pi-Hole DNS records for CWA
- Configure Pangolin tunnel for external access
- Stop Calibre-Web Portainer stack
- Document migration process and findings

**❌ Explicitly Out of Scope:**
- Removing Calibre-Web stack completely (future task)
- Removing Calibre server completely (future task, may still be needed)
- Automated book downloader setup (IN-049 - separate task)
- Bulk book import/migration (use existing library)
- Plugin configuration changes (migrate as-is)

**🎯 MVP (Minimum Viable)**:
- CWA deployed and accessible locally
- Existing library accessible in CWA
- Basic configuration migrated
- Traefik routing working
- Calibre-Web stack stopped

## Risk Assessment

### Potential Pitfalls

- ⚠️ **Risk 1: NAS Database Corruption** → **Mitigation**:
  - Test NAS database support thoroughly before committing
  - Monitor database integrity closely after deployment
  - Have rollback plan to local database if issues occur
  - Document any performance or locking issues
  - Regular backups of database on NAS

- ⚠️ **Risk 2: Configuration Migration Issues** → **Mitigation**:
  - Complete backup before any changes
  - Test configuration migration in isolated environment if possible
  - Verify all settings carry over correctly
  - Document any settings that don't migrate

- ⚠️ **Risk 3: Plugin Compatibility** → **Mitigation**:
  - Backup all plugins before migration
  - Verify plugin paths and configuration files migrate correctly
  - Test plugin functionality after migration
  - Document any incompatible plugins

- ⚠️ **Risk 4: Library Path/Structure Mismatch** → **Mitigation**:
  - Verify library structure matches CWA expectations
  - Test with small subset before full migration
  - Ensure metadata.db location is correct
  - Document any path adjustments needed

- ⚠️ **Risk 5: Traefik/Pangolin Configuration Errors** → **Mitigation**:
  - Follow existing Traefik patterns from other services
  - Test routing before stopping Calibre-Web
  - Verify Pangolin tunnel configuration matches other services
  - Have rollback plan for infrastructure changes

### Dependencies

**Prerequisites (must exist before starting):**
- [x] **Calibre-Web currently deployed** - Exists on VM 103 (blocking: no)
- [x] **Traefik running on VM 103** - Already configured (blocking: no)
- [x] **Pi-Hole DNS configured** - Already running (blocking: no)
- [x] **Pangolin/Newt on VM 103** - Already configured (blocking: no)
- [x] **NAS mounts available** - NFS mounts configured (blocking: no)

**No blocking dependencies - can start immediately**

### Critical Service Impact

**Services Affected**: Calibre-Web (supporting service, not critical)

**Impact Level**: Low - Calibre-Web is a supporting service, not critical like Emby/downloads/arr services. Migration will cause temporary downtime for Calibre-Web access, but no impact on critical media services.

### Rollback Plan

**Applicable for**: Docker service migration, infrastructure changes

**How to rollback if this goes wrong:**
1. Stop Calibre-Web-Automated stack via Portainer
2. Restore Calibre-Web stack from Portainer (if deleted, redeploy from git)
3. Restore configuration/library from backup if needed:
   ```bash
   # Restore Calibre-Web config
   tar xzf calibre-web-config-backup-YYYYMMDD.tar.gz -C /mnt/nas/configs/

   # Restore library if needed
   tar xzf calibre-library-backup-YYYYMMDD.tar.gz -C /mnt/nas/configs/calibre/
   ```
4. Restore Traefik dynamic.yml if routing changed
5. Restore Pi-Hole DNS records if changed
6. Verify Calibre-Web accessible and functional

**Recovery time estimate**: 15-30 minutes (restore from backup, restart services)

**Backup requirements:**
- Full backup of `/mnt/nas/configs/calibre-web` (Calibre-Web configuration)
- Full backup of `/mnt/nas/configs/calibre/library` (Calibre library including metadata.db)
- Backup of Calibre plugins directory if exists
- Backup of Traefik dynamic.yml before changes
- Export Pi-Hole DNS records before changes

## Execution Plan

### Phase 0: Discovery & Backup

**Primary Agent**: `docker` (with `infrastructure` support)

- [ ] **Inventory existing Calibre-Web setup** `[agent:docker]`
  - Document current Calibre-Web configuration location
  - Document current library location and structure
  - Document current plugins location and list
  - Document current Traefik routing configuration
  - Document current Pi-Hole DNS records
  - Document current environment variables

- [ ] **Create comprehensive backups** `[agent:docker]` `[risk:2]`
  - Backup Calibre-Web config: `/mnt/nas/configs/calibre-web`
  - Backup Calibre library: `/mnt/nas/configs/calibre/library`
  - Backup Calibre plugins if exists: `/mnt/nas/configs/calibre/.config/calibre/plugins`
  - Backup customize.py.json if exists
  - Backup Traefik dynamic.yml (vm-103)
  - Export Pi-Hole DNS records for calibre-web
  - Verify backups are complete and accessible

- [ ] **Investigate NAS database support** `[agent:docker]` `[agent:infrastructure]`
  - Research CWA documentation on NAS database support
  - Review community experiences with SQLite on NFS
  - Document findings and recommendations
  - Create test plan for NAS database configuration

### Phase 1: Calibre-Web-Automated Stack Creation

**Primary Agent**: `docker`

- [ ] **Create CWA docker-compose.yml** `[agent:docker]`
  - Base on CWA repository docker-compose example
  - Configure volume mounts:
    - `/config` → Calibre-Web config (migrated)
    - `/calibre-library` → Existing Calibre library
    - `/cwa-book-ingest` → New ingest folder
    - `/app/calibre-web-automated/gmail.json` → Optional Gmail config
  - Configure environment variables (PUID, PGID, TZ, etc.)
  - Set resource limits
  - Configure networks (default, traefik-network)
  - Set restart policy

- [ ] **Create CWA .env.example** `[agent:docker]`
  - Document all environment variables
  - Include NAS database path configuration
  - Include plugin path configuration
  - Match existing Calibre-Web patterns

- [ ] **Create CWA README.md** `[agent:documentation]`
  - Document CWA-specific features
  - Document migration from Calibre-Web
  - Document NAS database configuration (if successful)
  - Document ingest folder usage
  - Document plugin migration process

### Phase 2: Configuration Migration

**Primary Agent**: `docker`

- [ ] **Migrate Calibre-Web configuration** `[agent:docker]` `[risk:2]`
  - Copy Calibre-Web config to CWA config location
  - Verify app.db exists and is accessible
  - Test configuration compatibility
  - Document any configuration adjustments needed

- [ ] **Migrate Calibre plugins** `[agent:docker]` `[risk:3]`
  - Copy plugins directory to CWA expected location
  - Copy customize.py.json if exists
  - Verify plugin paths in configuration
  - Document plugin migration process

- [ ] **Configure library path** `[agent:docker]` `[risk:4]`
  - Verify library path matches existing Calibre library
  - Ensure metadata.db is accessible
  - Test library access from container
  - Document library configuration

- [ ] **Configure NAS database (if attempting)** `[agent:docker]` `[agent:infrastructure]` `[risk:1]`
  - Configure database path to NAS location
  - Test database creation and access
  - Monitor for locking issues
  - Document performance characteristics
  - Have fallback plan ready if issues occur

### Phase 3: Infrastructure Integration

**Primary Agent**: `infrastructure` (with `security` for Pangolin)

- [ ] **Configure Traefik routing** `[agent:infrastructure]`
  - Add CWA router to Traefik dynamic.yml (vm-103)
  - Configure service backend (calibre-web-automated:8083)
  - Use hostname: `calibre-web-automated.local.infinity-node.com` or `calibre-web.local.infinity-node.com`
  - Test routing before stopping Calibre-Web
  - Document routing configuration

- [ ] **Add Pi-Hole DNS records** `[agent:infrastructure]`
  - Add DNS record for CWA service
  - Use existing calibre-web.local.infinity-node.com or new name
  - Verify DNS resolution
  - Document DNS configuration

- [ ] **Configure Pangolin tunnel** `[agent:security]`
  - Create Pangolin tunnel configuration for CWA
  - Configure tunnel to point to Traefik route
  - Test external access
  - Document tunnel configuration

### Phase 4: Deployment & Migration

**Primary Agent**: `docker`

- [ ] **Deploy CWA stack via Portainer** `[agent:docker]`
  - Create new stack in Portainer (Git-integrated)
  - Configure environment variables
  - Deploy stack
  - Verify containers start successfully
  - Check logs for errors

- [ ] **Verify CWA functionality** `[agent:docker]` `[agent:testing]`
  - Access CWA web interface
  - Verify library is accessible
  - Verify users/settings migrated
  - Test book reading/download
  - Verify plugins working
  - Test ingest folder functionality

- [ ] **Stop Calibre-Web stack** `[agent:docker]`
  - Stop Calibre-Web stack via Portainer
  - Verify CWA still functional
  - Document Calibre-Web stack status (stopped, not deleted)

- [ ] **Assess Calibre server need** `[agent:docker]`
  - Review if Calibre server still needed
  - If not needed, stop Calibre stack
  - Document decision and rationale

### Phase 5: Validation & Testing

**Primary Agent**: `testing`

- [ ] **Validate CWA deployment** `[agent:testing]`
  - CWA web interface accessible locally
  - CWA accessible via Traefik (port-free)
  - CWA accessible externally via Pangolin
  - Library accessible and books visible
  - Users can log in with existing credentials
  - Settings preserved

- [ ] **Validate infrastructure integration** `[agent:testing]`
  - DNS resolution working (Pi-Hole)
  - Traefik routing working
  - Pangolin tunnel working
  - No port conflicts

- [ ] **Validate database (if NAS)** `[agent:testing]` `[risk:1]`
  - Database accessible and functional
  - No locking issues observed
  - Performance acceptable
  - Document any issues or concerns

- [ ] **Test CWA-specific features** `[agent:testing]`
  - Book ingest folder functionality
  - Automatic conversion (if configured)
  - CWA settings panel accessible
  - Document feature testing results

### Phase 6: Documentation

**Primary Agent**: `documentation`

- [ ] **Update CWA README.md** `[agent:documentation]`
  - Document deployment process
  - Document migration from Calibre-Web
  - Document NAS database configuration (if successful)
  - Document plugin migration
  - Document infrastructure integration

- [ ] **Update architecture documentation** `[agent:documentation]`
  - Update ARCHITECTURE.md with CWA details
  - Update service list
  - Document CWA in network services section

- [ ] **Create migration runbook** `[agent:documentation]`
  - Document migration process for future reference
  - Document rollback procedure
  - Document troubleshooting steps
  - Document NAS database considerations

- [ ] **Update task notes** `[agent:documentation]`
  - Document lessons learned
  - Document any issues encountered
  - Document recommendations for future work

## Acceptance Criteria

**Done when all of these are true:**
- [ ] Calibre-Web-Automated deployed and accessible locally
- [ ] Calibre-Web-Automated accessible via Traefik (port-free)
- [ ] Calibre-Web-Automated accessible externally via Pangolin
- [ ] Existing library accessible in CWA
- [ ] Existing users/settings migrated successfully
- [ ] Plugins migrated and working (if applicable)
- [ ] NAS database configured and working (if attempted) OR local database configured as fallback
- [ ] Traefik routing configured and working
- [ ] Pi-Hole DNS records added and working
- [ ] Pangolin tunnel configured and working
- [ ] Calibre-Web stack stopped
- [ ] Comprehensive backups created and verified
- [ ] All execution plan items completed
- [ ] Testing Agent validates (see testing plan below)
- [ ] Changes committed with descriptive message (awaiting user approval)

## Testing Plan

**[[docs/agents/TESTING|Testing Agent]] validates:**
- CWA container running and healthy
- CWA web interface responds on port 8083
- Traefik routes requests to CWA correctly
- DNS resolution works for CWA hostname
- Pangolin tunnel provides external access
- Library accessible and books visible
- Database accessible (NAS or local)
- No port conflicts with existing services

**Manual validation:**
1. **Local Access**: Navigate to `http://calibre-web-automated.local.infinity-node.com` (or configured hostname) - should load CWA interface
2. **External Access**: Navigate to external Pangolin URL - should load CWA interface
3. **Library Access**: Log in and verify books from existing library are visible
4. **User Access**: Test logging in with existing Calibre-Web credentials
5. **Ingest Test**: Drop a test book in ingest folder, verify automatic processing
6. **Database Check**: Verify database location and check for any locking issues (if NAS)
7. **Plugin Check**: Verify plugins are accessible and functional (if migrated)
8. **Traefik Check**: Verify port-free access works via Traefik
9. **DNS Check**: Verify DNS resolution from multiple devices
10. **Backup Verification**: Verify backups are complete and accessible

## Related Documentation

- [[docs/ARCHITECTURE|Infrastructure Architecture]]
- [[docs/agents/DOCKER|Docker Agent Specification]]
- [[docs/agents/INFRASTRUCTURE|Infrastructure Agent Specification]]
- [[docs/agents/SECURITY|Security Agent Specification]]
- [[docs/runbooks/traefik-management|Traefik Management Runbook]]
- [[docs/runbooks/pihole-dns-management|Pi-Hole DNS Management Runbook]]
- [[stacks/calibre/README|Calibre Stack Documentation]]
- [[tasks/completed/IN-041-deploy-calibre-ebook-server|Task IN-041 - Calibre Deployment]]
- [Calibre-Web-Automated Repository](https://github.com/crocodilestick/Calibre-Web-Automated)
- [Calibre-Web-Automated Documentation](https://github.com/crocodilestick/Calibre-Web-Automated#readme)

## Notes

**Priority Rationale**:
Priority 3 (medium) - This is a valuable improvement to e-book management but not urgent. It enables automation features and sets up foundation for automated book downloader (IN-049). Low impact on critical services.

**Complexity Rationale**:
Complex - This involves service migration, database investigation (NAS support), infrastructure integration (Traefik, DNS, tunnels), backup/restore procedures, and multiple agents. Requires careful planning and phased execution.

**Implementation Notes**:
- NAS database support is "unsupported" but many users have success - worth investigating
- CWA can use existing Calibre-Web configuration directly (drop-in replacement)
- Migration should preserve all existing data and configuration
- Calibre server may still be needed for some operations - assess before stopping
- Ingest folder (`/cwa-book-ingest`) will delete files after processing - document this
- Plugin migration requires copying both plugins directory and customize.py.json

**Follow-up Tasks**:
- IN-049: Deploy Calibre-Web-Automated Book Downloader (depends on this task)
- Future: Remove Calibre-Web stack completely (after CWA proven stable)
- Future: Remove Calibre server if no longer needed
- Future: Configure automated backups for CWA database/library

---

> [!note]- 📋 Work Log
>
> *Work log will be populated during task execution*

> [!tip]- 💡 Lessons Learned
>
> *Lessons learned will be populated during task execution*
