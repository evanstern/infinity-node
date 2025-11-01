---
type: task
task-id: IN-035
status: pending
priority: 3
category: infrastructure
agent: docker
created: 2025-11-01
updated: 2025-11-01
started:
completed:

# Task classification
complexity: moderate
estimated_duration: 4-6h
critical_services_affected: true
requires_backup: true
requires_downtime: false

# Design tracking
alternatives_considered: false
risk_assessment_done: true
phased_approach: true

tags:
  - task
  - infrastructure
  - docker
  - dns
  - service-discovery
  - migration
---

# Task: IN-035 - Migrate Services to DNS Names

> **Quick Summary**: Migrate remaining services from hardcoded IP addresses to DNS names (using Pi-hole local DNS), including Bitwarden CLI, docker-compose files, and automation scripts.

## Problem Statement

**What problem are we solving?**
After IN-034 establishes Pi-hole DNS infrastructure and validates it with audiobookshelf, we need to migrate the rest of the system to use DNS names instead of hardcoded IPs. Currently:

- Bitwarden CLI configured with hardcoded IP (http://192.168.86.249:8111)
- Docker compose files may reference other services via IP
- Automation scripts use hardcoded IPs
- Documentation references hardcoded IPs

**Why now?**
- IN-034 proved DNS works with audiobookshelf
- DNS infrastructure now stable and ready for broader use
- Better to migrate everything at once while context is fresh
- Reduces technical debt before it spreads further

**Who benefits?**
- **System administrator (Evan)**: Single place to update IPs when network changes
- **Automation scripts**: More reliable, less maintenance
- **Documentation**: Stays accurate even when IPs change

## Solution Design

### Recommended Approach

**Phased migration by risk level** - Start with non-critical services, validate each group, then migrate critical services last. This minimizes risk and provides rollback points.

**Key components:**
- **Bitwarden CLI**: Update server URL to use DNS name
- **Docker stacks**: Update compose files to reference services via DNS
- **Automation scripts**: Replace hardcoded IPs with DNS names
- **Documentation**: Update to reference DNS names instead of IPs

**Migration phases:**
1. **Low-risk services** (misc services on VM 103): Homepage, linkwarden, etc.
2. **Medium-risk services** (arr stack on VM 102): Radarr, Sonarr, Prowlarr, Lidarr
3. **Critical services** (Emby, downloads): Highest caution, backup before changes
4. **Infrastructure** (Bitwarden CLI, scripts): Update automation tooling

### Scope Definition

**✅ In Scope:**
- Update Bitwarden CLI configuration to use `vaultwarden.local.infinity-node.com`
- Migrate all non-critical service stacks to DNS names (VM 103 services)
- Migrate arr services to DNS names (VM 102)
- Migrate critical services to DNS names (VM 100, 101) - with extra caution
- Update automation scripts in `scripts/` to use DNS names
- Update documentation to reference DNS names
- Test each service after migration
- Create rollback plan for each phase

**❌ Explicitly Out of Scope:**
- Adding new DNS records (IN-034 created all needed records)
- Changing Pi-hole configuration (infrastructure already set up)
- Migrating services that don't use inter-service communication (if any)
- External access via Pangolin (still uses external domains)

**🎯 MVP (Minimum Viable)**:
All infinity-node services and automation use DNS names instead of IPs. When IPs change, only Pi-hole DNS records need updating.

## Risk Assessment

### Potential Pitfalls

- ⚠️ **Risk 1: Critical service disruption (Emby, downloads)** → **Mitigation**: Migrate critical services last, during low-usage window (3-6 AM), backup configs, test thoroughly, have rollback ready.

- ⚠️ **Risk 2: Inter-service communication breaks** → **Mitigation**: Test each service's functionality after migration, not just accessibility. Verify services can talk to each other (e.g., Sonarr → Prowlarr).

- ⚠️ **Risk 3: Bitwarden CLI breaks, can't retrieve secrets** → **Mitigation**: Test CLI immediately after updating, have IP-based config backed up for quick rollback. Don't commit until validated.

- ⚠️ **Risk 4: Typos in DNS names break services** → **Mitigation**: Use consistent naming pattern, copy/paste DNS names from Pi-hole or docs, test resolution before deploying.

- ⚠️ **Risk 5: Automation scripts fail silently** → **Mitigation**: Test all scripts in `scripts/` directory after updating, verify they can resolve DNS and connect to services.

### Dependencies

**Prerequisites (must exist before starting):**
- [ ] **IN-034 completed** - Pi-hole DNS operational and tested (blocking: yes)
- [ ] **DNS records exist** - All services have entries in Pi-hole (blocking: yes)
- [ ] **Testing Agent ready** - Can validate each migration phase (blocking: no)

**Blocking dependency: IN-034** - Cannot proceed until DNS infrastructure is working.

### Critical Service Impact

**Services Affected**: ALL services, including critical ones

**Critical services:**
- **Emby (VM 100)**: Primary media streaming - migrate carefully during low usage
- **Downloads (VM 101)**: Active downloads must not corrupt - verify no active downloads before migration
- **Arr services (VM 102)**: Media automation pipeline - migrate during low activity period

**Mitigation strategy:**
- Migrate non-critical first to gain confidence
- Backup all critical service configs before touching
- Migrate critical services during 3-6 AM window (low usage)
- Test each critical service thoroughly after migration
- Have rollback plan ready for each critical service
- Coordinate with Media Stack Agent for critical service migrations

### Rollback Plan

**Applicable for**: Docker stack configuration changes

**How to rollback if this goes wrong:**

**Per-service rollback:**
1. `git revert` the commit that updated the service's docker-compose.yml
2. Redeploy service via Portainer (pull and redeploy)
3. Verify service accessible via IP again
4. Test service functionality

**Bitwarden CLI rollback:**
1. Run: `bw config server http://192.168.86.249:8111`
2. Test: `bw login` and `bw sync`
3. Verify secrets retrieval works

**Full rollback (nuclear option):**
1. Revert all git commits made during this task
2. Redeploy all affected stacks via Portainer
3. Reset Bitwarden CLI to IP
4. Verify all services accessible and functional
5. Pi-hole stays running (not causing harm with IPs)

**Recovery time estimate**:
- Single service: 2-5 minutes
- All services: 15-30 minutes

**Backup requirements:**
- All changes in git (automatic backup via version control)
- Document Bitwarden CLI original config before changing
- Take Portainer stack backups before critical service migrations

## Execution Plan

### Phase 1: Infrastructure Tools (Low Risk)

**Primary Agent**: `security`

- [ ] **Backup Bitwarden CLI configuration** `[agent:security]`
  - Document current server URL: `bw config server`
  - Save output for rollback reference

- [ ] **Update Bitwarden CLI to use DNS** `[agent:security]` `[risk:3]`
  - Run: `bw config server http://vaultwarden.local.infinity-node.com`
  - Test login: `bw login`
  - Test sync: `bw sync`
  - Test secret retrieval: `bw get item <test-item-id>`

- [ ] **Update automation scripts** `[agent:infrastructure]` `[risk:5]`
  - Scan scripts/ directory for hardcoded IPs
  - Replace with DNS names
  - Test each updated script
  - Commit changes

### Phase 2: Non-Critical Services (VM 103)

**Primary Agent**: `docker`

- [ ] **Identify services needing migration** `[agent:docker]`
  - Review stacks on VM 103: vaultwarden, paperless-ngx, immich, homepage, linkwarden, etc.
  - Check each docker-compose.yml for hardcoded IPs
  - Create migration checklist

- [ ] **Migrate non-critical service stacks** `[agent:docker]`
  - Update each docker-compose.yml with DNS names
  - Commit each update separately for easy rollback
  - Redeploy via Portainer after each update
  - Test service functionality after each migration
  - Document any issues encountered

### Phase 3: Arr Services (VM 102) - Medium Risk

**Primary Agent**: `docker`

- [ ] **Review arr service interdependencies** `[agent:docker]`
  - Map connections: Sonarr/Radarr/Lidarr → Prowlarr → indexers
  - Map connections: Arr services → download clients (VM 101)
  - Identify all inter-service communication

- [ ] **Migrate Prowlarr** `[agent:docker]` (migrate first, others depend on it)
  - Update docker-compose.yml
  - Redeploy via Portainer
  - Test Prowlarr UI accessible
  - Test indexer connections

- [ ] **Migrate Radarr** `[agent:docker]`
  - Update docker-compose.yml (Prowlarr connection)
  - Redeploy via Portainer
  - Test UI accessible
  - Test Prowlarr integration
  - Test can search for movies

- [ ] **Migrate Sonarr** `[agent:docker]`
  - Update docker-compose.yml (Prowlarr connection)
  - Redeploy via Portainer
  - Test UI accessible
  - Test Prowlarr integration
  - Test can search for shows

- [ ] **Migrate Lidarr** `[agent:docker]`
  - Update docker-compose.yml (Prowlarr connection)
  - Redeploy via Portainer
  - Test UI accessible
  - Test Prowlarr integration
  - Test can search for music

### Phase 4: Critical Services - High Risk

**Primary Agent**: `media` (critical services require Media Stack Agent)

**Timing**: Schedule for low-usage window (3-6 AM preferred)

- [ ] **Pre-migration checklist** `[agent:media]` `[blocking]`
  - Verify no active downloads in progress (VM 101)
  - Verify no active Emby transcodes (VM 100)
  - Backup all critical service configs
  - Notify household of potential brief disruption

- [ ] **Migrate downloads stack (VM 101)** `[agent:media]` `[risk:1]`
  - Review qBittorrent, SABnzbd configs for hardcoded IPs
  - Update docker-compose.yml
  - Commit changes
  - Redeploy via Portainer
  - Test UI accessible
  - Verify downloads resume correctly
  - Check arr services can still reach download clients

- [ ] **Migrate Emby (VM 100)** `[agent:media]` `[risk:1]`
  - Review Emby config for hardcoded IPs (likely none, but verify)
  - Update docker-compose.yml if needed
  - Commit changes
  - Redeploy via Portainer
  - Test UI accessible
  - Test media playback works
  - Test transcoding works
  - Monitor for 30 minutes after migration

### Phase 5: Documentation Updates

**Primary Agent**: `documentation`

- [ ] **Update service documentation** `[agent:documentation]`
  - Update each service README in stacks/
  - Replace IP references with DNS names
  - Add note about DNS migration

- [ ] **Update architecture documentation** `[agent:documentation]`
  - Update ARCHITECTURE.md with DNS-based service discovery
  - Update any IP address references
  - Document DNS naming conventions

- [ ] **Update runbooks** `[agent:documentation]`
  - Review runbooks for hardcoded IPs
  - Update to use DNS names
  - Add DNS troubleshooting section if needed

### Phase 6: Validation & Testing

**Primary Agent**: `testing`

- [ ] **Test Bitwarden CLI integration** `[agent:testing]`
  - Run test script using bw CLI
  - Verify secrets can be retrieved
  - Test with actual deployment script

- [ ] **Test inter-service communication** `[agent:testing]` `[blocking]`
  - Arr services → Prowlarr (searches work)
  - Arr services → Download clients (can send downloads)
  - All services → Vaultwarden (if applicable)
  - Verify no broken connections

- [ ] **Test critical service functionality** `[agent:testing]` `[blocking]`
  - Emby: Stream media, test transcoding
  - Downloads: Active download completes successfully
  - Arr services: Can search, find, and send to downloader

- [ ] **Verify DNS resolution across all services** `[agent:testing]`
  - Check Pi-hole dashboard for query volume
  - Verify no DNS resolution errors
  - Check that services using local domain

## Acceptance Criteria

**Done when all of these are true:**
- [ ] Bitwarden CLI configured to use `vaultwarden.local.infinity-node.com` and functioning
- [ ] All automation scripts updated to use DNS names (no hardcoded IPs)
- [ ] All VM 103 services (non-critical) migrated and tested
- [ ] All arr services (VM 102) migrated and inter-service communication tested
- [ ] Downloads stack (VM 101) migrated, downloads function correctly
- [ ] Emby (VM 100) migrated, streaming and transcoding work
- [ ] All service READMEs updated with DNS names
- [ ] ARCHITECTURE.md and runbooks updated with DNS references
- [ ] Inter-service communication verified (arr → prowlarr → downloaders)
- [ ] Critical services monitored for stability after migration
- [ ] All execution plan items completed
- [ ] Testing Agent validates all services functional
- [ ] Changes committed with descriptive messages (awaiting user approval)

## Testing Plan

**[[docs/agents/TESTING|Testing Agent]] validates:**
- Bitwarden CLI can login, sync, retrieve secrets
- All services accessible via DNS names
- Inter-service communication works (arr → prowlarr, arr → downloaders)
- Critical services fully functional (Emby streams, downloads complete)
- No DNS resolution errors in Pi-hole logs
- Automation scripts execute successfully

**Manual validation:**
1. **Bitwarden CLI test**:
   ```bash
   bw config server  # Should show vaultwarden.local.infinity-node.com
   bw login
   bw sync
   bw get item <test-item>  # Should retrieve successfully
   ```

2. **Service accessibility test**:
   ```bash
   # Test each service via DNS name in browser
   # All should load correctly
   ```

3. **Inter-service communication test**:
   ```bash
   # In Sonarr: trigger manual search
   # Expected: Prowlarr returns results, can send to downloader
   ```

4. **Emby functionality test**:
   ```bash
   # Play media file
   # Trigger transcode (incompatible format/resolution)
   # Expected: Smooth playback, transcoding works
   ```

5. **Downloads test**:
   ```bash
   # Send test download from arr service
   # Expected: Appears in download client, completes successfully
   ```

## Related Documentation

- [[docs/ARCHITECTURE|Architecture]] - Update with DNS-based service discovery
- [[docs/DNS|DNS Documentation]] - Reference for DNS names
- [[docs/agents/DOCKER|Docker Agent]] - Agent handling most migrations
- [[docs/agents/MEDIA|Media Stack Agent]] - For critical service migrations
- [[docs/agents/SECURITY|Security Agent]] - For Bitwarden CLI migration
- [[tasks/completed/IN-034-configure-pihole-local-dns|IN-034]] - Prerequisite DNS setup

## Notes

**Priority Rationale:**
Priority 3 (medium) because:
- Builds on IN-034 infrastructure work
- Important for long-term maintainability
- Reduces technical debt significantly
- Not urgent - IP-based access still works
- Can be scheduled for low-usage window to minimize risk

Not higher priority because:
- Not addressing active outage
- Current IP-based setup functional
- Can delay if higher priority work emerges

**Complexity Rationale:**
Moderate complexity because:
- Touches many services across multiple VMs
- Requires careful testing of each migration
- Critical services require extra caution and timing
- Inter-service dependencies must be validated
- Some discovery needed (which services reference IPs?)

Not simple because affects critical services and requires phased approach.
Not complex because straightforward replacements, no major unknowns.

**Implementation Notes:**
- **Migration order matters**: Non-critical → medium-risk → critical
- **Test after each phase**: Don't migrate everything then test
- **Commit granularly**: One commit per service or logical group for easy rollback
- **Timing for critical services**: 3-6 AM preferred for Emby/downloads migration
- **DNS name format**: Use consistent `<service>.local.infinity-node.com` pattern
- **Ports still in configs**: DNS resolves hostname only, ports still specified in configs
- **Keep calm, rollback easy**: Everything in git, can revert quickly if needed

**Follow-up Tasks:**
- Future: Audit for any missed hardcoded IPs (periodic review)
- Future: Consider DNS-based service discovery in docker networks (docker internal DNS)
- Future: Update deployment scripts to use DNS (if any new scripts added)

---

> [!note]- 📋 Work Log
>
> **Work log entries will be added here as task progresses**

> [!tip]- 💡 Lessons Learned
>
> *Fill this in AS YOU GO during task execution. Not every task needs extensive notes here, but capture important learnings that could affect future work.*
>
> **What Worked Well:**
> - [Patterns/approaches that were successful]
>
> **What Could Be Better:**
> - [What would we do differently next time]
>
> **Key Discoveries:**
> - [Insights affecting other systems]
>
> **Scope Evolution:**
> - [How scope changed from original plan]
>
> **Follow-Up Needed:**
> - [Documentation updates needed]
> - [New tasks to create]
