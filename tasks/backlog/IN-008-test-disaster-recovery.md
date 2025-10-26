---
type: task
task-id: IN-008
status: pending
priority: 3
category: infrastructure
agent: infrastructure
created: 2025-10-24
updated: 2025-10-26
tags:
  - task
  - infrastructure
  - disaster-recovery
  - testing
  - backup
---

# Task: IN-008 - Test Disaster Recovery Procedures

## Description

Develop and test disaster recovery procedures for critical services to ensure we can recover quickly from various failure scenarios.

## Context

We have no tested disaster recovery procedures. If critical services fail, we don't know:
- How long recovery will take (RTO)
- How much data we'll lose (RPO)
- What the exact steps are
- What gotchas exist

Testing recovery is essential for critical services that affect household users (Emby, downloads, arr).

## Acceptance Criteria

- [ ] Define disaster scenarios to test
- [ ] Document recovery procedures for each scenario
- [ ] Test VM 104 or 105 restoration (non-production)
- [ ] Test critical service restoration
- [ ] Test database restoration
- [ ] Test configuration restoration from git
- [ ] Measure recovery time for each scenario
- [ ] Document any issues encountered
- [ ] Update recovery procedures based on findings
- [ ] Create disaster recovery runbook
- [ ] Define RTO/RPO for each service tier

## Dependencies

- Backup strategy must be defined first
- Test VMs available (104, 105)
- Backups to test with
- Enough time for testing
- Coordination with [[document-backup-strategy]]

## Testing Plan

[[docs/agents/TESTING|Testing Agent]] should validate:
- Recovery procedures are complete and accurate
- Restored services function correctly
- No data loss (or within acceptable limits)
- Recovery time meets requirements
- Procedures are repeatable

## Related Documentation

- [[docs/ARCHITECTURE|Architecture]]
- [[document-backup-strategy]]
- Future: docs/runbooks/disaster-recovery.md
- [[docs/DECISIONS|Decisions]] - Future ADR needed

## Notes

**Disaster Scenarios to Test:**

1. **VM Corruption/Loss**
   - Complete loss of VM disk
   - Recovery from snapshot/backup
   - Expected RTO: < 1 hour

2. **Service Failure**
   - Single service won't start
   - Restore from git + .env backup
   - Expected RTO: < 15 minutes

3. **Database Corruption**
   - Service database corrupted
   - Restore from database backup
   - Expected RTO: < 30 minutes

4. **Configuration Loss**
   - Lost docker-compose or .env
   - Restore from git + Vaultwarden
   - Expected RTO: < 30 minutes

5. **Proxmox Host Failure**
   - Complete host failure
   - Rebuild on new hardware
   - Expected RTO: TBD (likely hours)

6. **NAS Failure**
   - NFS mount unavailable
   - Impact assessment and mitigation
   - Expected RTO: Depends on NAS recovery

**Testing Approach:**

Use VM 104 or 105 for testing:
1. Deploy test service
2. Create test data
3. Backup service
4. Simulate failure
5. Execute recovery procedure
6. Validate results
7. Measure recovery time
8. Document lessons learned

**Critical Services Recovery Priority:**

1. **Emby (VM 100)** - HIGHEST
   - RTO target: < 1 hour
   - RPO target: < 24 hours
   - Users affected: Household

2. **Downloads (VM 101)** - HIGH
   - RTO target: < 2 hours
   - RPO target: Active downloads acceptable loss
   - Impact: Media acquisition delayed

3. **arr Services (VM 102)** - HIGH
   - RTO target: < 2 hours
   - RPO target: < 24 hours
   - Impact: Automation delayed

4. **Supporting Services (VM 103)** - MEDIUM
   - RTO target: < 1 day
   - RPO target: < 1 week
   - Impact: Owner only

**Recovery Runbook Should Include:**

- Step-by-step procedures
- Commands to execute
- Expected outputs
- Troubleshooting tips
- Time estimates
- Prerequisites
- Validation steps

**Questions to Answer:**

- Can we recover without Proxmox web UI?
- Can we recover without NAS access?
- What's the minimum viable recovery?
- Where are single points of failure?
- What manual steps are required?
- What can be automated?

**Post-Testing:**

- Update [[docs/ARCHITECTURE|Architecture]] with findings
- Create ADR documenting RTO/RPO decisions
- Improve backup strategy if needed
- Automate recovery where possible
- Schedule periodic recovery drills
