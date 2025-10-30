---
type: task
task-id: IN-011
status: pending
priority: 1
category: infrastructure
agent: infrastructure
created: 2025-10-24
updated: 2025-10-30

# Task classification
complexity: complex
estimated_duration: 12-16h
critical_services_affected: true  # Emby, downloads, arr recovery depends on this
requires_backup: false
requires_downtime: false

# Design tracking
alternatives_considered: true   # Multiple backup approaches and storage options
risk_assessment_done: true      # RTO/RPO analysis needed
phased_approach: true           # Phase 1: Strategy/Design, Phase 2: Implementation, Phase 3: Testing

tags:
  - task
  - infrastructure
  - backup
  - disaster-recovery
  - proxmox
  - critical-services
---

# Task: IN-011 - Document and Implement Backup Strategy

> **Quick Summary**: Establish comprehensive backup strategy and implementation for VMs, service databases, and configurations to enable disaster recovery with defined RTO/RPO targets.

<!-- Priority Scale: 0 (critical/urgent) → 1-2 (high) → 3-4 (medium) → 5-6 (low) → 7-9 (very low) -->
<!-- Complexity: simple (straightforward) | moderate (some unknowns) | complex (significant design/unknowns) -->

## Problem Statement

**What problem are we solving?**
The infinity-node infrastructure has no comprehensive backup strategy or documentation. While Vaultwarden backups exist (IN-017), we lack backups for VMs, service databases (Emby, *arr services, Immich, Paperless), and critical .env files. Without this, a hardware failure or data corruption could result in significant downtime and data loss affecting household users.

**Why now?**
- **Risk exposure**: Critical services (Emby, downloads, arr) have no recovery path if VMs fail
- **Growing complexity**: More services = more data to protect (Immich photos, Paperless documents)
- **Foundation work**: Backup strategy enables other tasks (IN-008 disaster recovery testing)
- **Recent work**: Vaultwarden backup (IN-017) provides template pattern to extend

**Who benefits?**
- **Household users**: Minimize downtime if critical services fail
- **System administrator**: Clear recovery procedures reduce stress during incidents
- **Future maintenance**: Enables confident system changes with rollback capability

## Solution Design

### Recommended Approach

**Three-tier backup strategy:**

1. **VM-level backups via Proxmox**
   - Weekly full VM snapshots to NAS storage
   - Covers entire VM state (OS, configs, data)
   - Quick recovery for catastrophic VM failures

2. **Service database backups** (application-level)
   - Daily automated database exports for each service
   - Stored to NAS with retention policy (7 daily, 4 weekly, 12 monthly)
   - Pattern based on Vaultwarden backup (IN-017) approach
   - Services: Emby, Sonarr, Radarr, Prowlarr, Immich, Paperless-NGX

3. **.env file backups** (critical secrets)
   - Daily encrypted backups of all .env files across VMs
   - Coordinate with IN-016 (backup UI-managed secrets)
   - Essential for service restoration

**Documentation deliverables:**
- Comprehensive backup runbook in `docs/runbooks/backup-restore.md`
- Define RTO (Recovery Time Objective) and RPO (Recovery Point Objective) per service tier
- Update architecture documentation with backup infrastructure
- Create backup automation scripts following Vaultwarden pattern

**Rationale**: Multi-tier approach provides defense in depth - VM snapshots for complete failures, database backups for data corruption, .env backups for secrets recovery. Using NAS storage leverages existing infrastructure. Building on Vaultwarden backup pattern ensures consistency.

> [!abstract]- 🔀 Alternative Approaches Considered
>
> **Option A: Proxmox Backup Server (PBS)**
> - ✅ Pros: Professional-grade, deduplication, incremental backups, purpose-built
> - ❌ Cons: Requires dedicated VM/storage, additional complexity, learning curve
> - **Decision**: Not chosen because current NAS storage is sufficient for now; PBS could be future enhancement
>
> **Option B: VM backups only (no application-level backups)**
> - ✅ Pros: Simpler, fewer moving parts, one backup system
> - ❌ Cons: Larger backup size, slower recovery, no granular restore
> - **Decision**: Not chosen because application-level backups enable faster recovery for database corruption without full VM restore
>
> **Option C: Off-site backup via cloud storage (B2, S3, etc.)**
> - ✅ Pros: Disaster recovery for fire/theft, geographic redundancy
> - ❌ Cons: Cost, bandwidth usage, encryption complexity, slower restores
> - **Decision**: Out of scope for initial implementation; consider in future enhancement after local backups working

### Scope Definition

**✅ In Scope:**
- Proxmox VM backup strategy and documentation
- Service database backup implementation (Emby, *arr, Immich, Paperless)
- .env file backup automation
- Backup retention policies
- Backup storage location specification (NAS)
- RTO/RPO definition per service tier
- Comprehensive backup/restore runbook
- Test backup creation and verification
- Architecture documentation updates

**❌ Explicitly Out of Scope:**
- Vaultwarden backup (already complete - IN-017)
- NAS-level backup strategy (handled by Synology)
- Off-site/cloud backup (future enhancement)
- Automated restore procedures (future enhancement)
- Full disaster recovery testing (separate task - IN-008)
- Backup monitoring/alerting (future enhancement)

**🎯 MVP (Minimum Viable)**:
- Documented backup strategy with RTO/RPO targets
- Working VM backup process (manual acceptable)
- Database backup scripts for critical services (Emby, Sonarr, Radarr)
- .env backup script
- Basic restore procedure documented
- One successful test backup and restore

## Risk Assessment

### Potential Pitfalls
- ⚠️ **Backup storage fills NAS**: VM snapshots could consume significant space → **Mitigation**: Calculate storage requirements first, implement retention policy, monitor usage
- ⚠️ **Backup during high-usage breaks service**: Large database exports could impact performance → **Mitigation**: Schedule backups 2-4 AM low-usage window
- ⚠️ **Backup verification forgotten**: Backups exist but are corrupted/incomplete → **Mitigation**: Include verification step in all backup scripts (checksum, test restore)
- ⚠️ **Script failures go unnoticed**: Backup fails silently → **Mitigation**: Log all backup operations, consider future alerting (out of scope but noted)
- ⚠️ **Incomplete service coverage**: Miss backing up critical service → **Mitigation**: Inventory all services before designing backup strategy

### Dependencies
- [x] **Vaultwarden backup pattern (IN-017)**: Template for database backup approach (blocking: no - completed)
- [ ] **NAS storage availability**: Sufficient space for VM snapshots and database backups (blocking: yes)
- [ ] **Proxmox backup capabilities**: Understanding of snapshot features and limitations (blocking: yes)
- [ ] **Service database access**: Know how to export each service's database (blocking: yes)

### Critical Service Impact
**Services Affected**: Emby, Downloads, Arr services, Immich, Paperless (backup operations only)

> [!warning]- ⚠️ Critical Service Handling
>
> **Timing**: Implement backup scripts during low-usage window (3-4 AM recommended for testing)
> **Backup Plan**: Not applicable - this task creates backups, doesn't modify services
> **Rollback Procedure**: If backup scripts cause issues, simply disable via cron/systemd
> **Monitoring**: Watch service performance after first backups run; check logs for errors

### Rollback Plan
**Applicable for**: Backup script installation only

**How to rollback if backup scripts cause issues:**
1. Disable cron jobs or systemd timers for backup scripts
2. Remove backup scripts from VMs if needed
3. Service operations unchanged - only backup processes affected

**Recovery time estimate**: < 5 minutes (disable cron/timer)

## Execution Plan

### Phase 0: Discovery & Strategy Design
**Primary Agent**: `infrastructure` + `documentation`

- [ ] **Inventory all services and their databases** `[agent:infrastructure]`
- [ ] **Calculate storage requirements for VM snapshots** `[agent:infrastructure]`
- [ ] **Verify NAS storage availability** `[agent:infrastructure]` `[blocking]`
- [ ] **Research Proxmox backup capabilities and best practices** `[agent:infrastructure]`
- [ ] **Define RTO/RPO targets per service tier** `[agent:documentation]`
  - Critical services (Emby, downloads, arr): RTO 1-2 hours, RPO 24 hours
  - Important services (Immich, Paperless): RTO 4-8 hours, RPO 24 hours
  - Supporting services: RTO 24 hours, RPO 48 hours
- [ ] **Design retention policies** `[agent:documentation]`
- [ ] **Create backup runbook structure** `[agent:documentation]`

### Phase 1: VM-Level Backup Implementation
**Primary Agent**: `infrastructure`

- [ ] **Document Proxmox VM snapshot process** `[agent:infrastructure]` `[depends:verify-nas-storage]`
- [ ] **Create VM snapshot automation** `[agent:infrastructure]` `[optional]`
- [ ] **Configure VM snapshot retention** `[agent:infrastructure]`
- [ ] **Test VM snapshot creation** `[agent:infrastructure]`
- [ ] **Test VM restore from snapshot** `[agent:infrastructure]` `[risk:1]`

### Phase 2: Service Database Backup Implementation
**Primary Agent**: `infrastructure` + `docker`

- [ ] **Create database backup script for Emby** `[agent:docker]` `[depends:inventory]`
- [ ] **Create database backup script for Sonarr** `[agent:docker]`
- [ ] **Create database backup script for Radarr** `[agent:docker]`
- [ ] **Create database backup script for Prowlarr** `[agent:docker]`
- [ ] **Create database backup script for Immich** `[agent:docker]`
- [ ] **Create database backup script for Paperless-NGX** `[agent:docker]`
- [ ] **Implement backup verification in scripts** `[agent:docker]` `[risk:3]`
- [ ] **Configure retention policy (7/4/12)** `[agent:docker]`
- [ ] **Deploy scripts and schedule via cron/systemd** `[agent:infrastructure]`

### Phase 3: .env File Backup Implementation
**Primary Agent**: `security` + `infrastructure`

- [ ] **Create encrypted .env backup script** `[agent:security]` `[blocking]`
- [ ] **Inventory all .env locations across VMs** `[agent:infrastructure]`
- [ ] **Test .env backup and restore** `[agent:security]` `[risk:4]`
- [ ] **Schedule .env backup automation** `[agent:infrastructure]`
- [ ] **Coordinate with IN-016 for UI-managed secrets** `[agent:security]` `[optional]`

### Phase 4: Validation & Testing
**Primary Agent**: `testing`

- [ ] **Verify all backup scripts execute successfully** `[agent:testing]`
- [ ] **Verify backups are complete and not corrupted** `[agent:testing]` `[risk:3]`
- [ ] **Test database restore procedure** `[agent:testing]` `[risk:1]`
- [ ] **Verify backup storage space usage** `[agent:testing]` `[risk:1]`
- [ ] **Validate retention policy works correctly** `[agent:testing]`
- [ ] **Document any issues or improvements** `[agent:testing]`

### Phase 5: Documentation
**Primary Agent**: `documentation`

- [ ] **Complete backup/restore runbook** `[agent:documentation]`
- [ ] **Update Architecture documentation** `[agent:documentation]`
- [ ] **Document RTO/RPO commitments** `[agent:documentation]`
- [ ] **Document backup verification procedures** `[agent:documentation]`
- [ ] **Create ADR for backup strategy decisions** `[agent:documentation]` `[optional]`

## Acceptance Criteria

**Done when all of these are true:**
- [ ] RTO/RPO targets defined for all service tiers
- [ ] VM backup process documented and tested
- [ ] Database backup scripts deployed for all critical services (Emby, *arr)
- [ ] Database backup scripts deployed for important services (Immich, Paperless)
- [ ] .env file backup automation working
- [ ] Retention policies implemented (7 daily, 4 weekly, 12 monthly)
- [ ] At least one successful backup created for each service
- [ ] At least one successful restore tested (non-production)
- [ ] Backup storage requirements calculated and space available
- [ ] Comprehensive backup/restore runbook created at `docs/runbooks/backup-restore.md`
- [ ] Architecture documentation updated with backup infrastructure
- [ ] All execution plan items completed
- [ ] Testing Agent validates all backup operations
- [ ] No backup operations negatively impact service performance

## Testing Plan

**[[docs/agents/TESTING|Testing Agent]] validates:**
- All backup scripts execute without errors
- Backups are created in expected locations with correct permissions
- Backup files are complete and not corrupted (checksum validation)
- Retention policy correctly removes old backups
- Restore procedure successfully recovers data (test on non-production VM)
- RTO/RPO targets are achievable with current backup strategy
- Backup operations during low-usage window don't impact service performance
- Backup storage space consumption is within NAS capacity

**Manual validation:**
- User can access restored Emby library after test restore
- User can verify backup files exist on NAS
- Backup runbook is clear and actionable for future recovery

## Related Documentation
- [[tasks/completed/IN-017-implement-vaultwarden-backup|IN-017]] - Vaultwarden backup (completed, provides template)
- [[tasks/backlog/IN-016-backup-ui-managed-secrets|IN-016]] - UI-managed secrets backup (related)
- [[tasks/backlog/IN-008-test-disaster-recovery|IN-008]] - Disaster recovery testing (depends on this)
- [[docs/ARCHITECTURE|Architecture]] - Will be updated with backup infrastructure
- [[docs/SECRET-MANAGEMENT|Secret Management]] - .env file backup relates to secrets
- Future: `docs/runbooks/backup-restore.md` - Primary deliverable
- Future: ADR for backup strategy decisions

## Notes

**Priority Rationale**: Priority 1 (high) because critical services (Emby, downloads, arr) have no recovery path without backups. Risk of significant downtime and data loss affects household users. Foundation work that enables disaster recovery testing and confident system changes.

**Complexity Rationale**: Complex because:
- Multiple technologies (Proxmox, Docker, databases, encryption)
- Significant unknowns (service database export methods, storage requirements, RTO/RPO analysis)
- Design decisions (retention policies, backup strategies, automation approaches)
- Coordination across multiple VMs and services
- Testing and verification requirements

**Implementation Notes**:
- Build on Vaultwarden backup pattern (IN-017) for consistency
- Schedule all backups during 2-4 AM low-usage window
- Implement logging in all backup scripts for troubleshooting
- Consider future enhancements: monitoring, alerting, automated restores, off-site backups
- NAS backup of NAS data handled separately by Synology (out of scope)

**Historical Context**:
- Vaultwarden backup completed 2025-10-27 via IN-017
- Provides template: daily backups, 7/4/12 retention, encryption, verification
- Script location: `scripts/backup-vaultwarden.sh`

**Storage Considerations**:
- NAS location: 192.168.86.43 (57TB total capacity)
- VM snapshots will be largest consumer - calculate requirements first
- Database backups relatively small (< 10GB estimated total)
- .env files minimal (< 100MB total)
