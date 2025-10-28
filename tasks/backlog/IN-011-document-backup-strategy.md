---
type: task
task-id: IN-011
status: pending
priority: 1
category: infrastructure
agent: infrastructure
created: 2025-10-24
updated: 2025-10-27
tags:
  - task
  - infrastructure
  - backup
  - disaster-recovery
---

# Task: IN-011 - Document and Implement Backup Strategy

## Description

Define and document a comprehensive backup strategy for the infinity-node infrastructure, including what to backup, frequency, retention, storage location, and restore procedures.

## Context

Currently there is no documented backup strategy. While the NAS may have its own backup approach, we need:
- VM snapshots/backups
- Configuration backups (especially .env files)
- Database backups
- Disaster recovery procedures

Critical services (Emby, downloads, arr) require reliable backups to minimize downtime in case of failure.

## Acceptance Criteria

- [ ] Define what needs to be backed up (VMs, configs, databases, etc.)
- [ ] Define backup frequency (daily, weekly, etc.)
- [ ] Define retention policy (how long to keep backups)
- [ ] Identify backup storage location(s)
- [ ] Document backup procedures
- [ ] Document restore procedures
- [ ] Test backup creation
- [ ] Test restore procedure (on non-production)
- [ ] Create backup automation scripts if needed
- [ ] Update [[docs/ARCHITECTURE|Architecture]] with backup info
- [ ] Create backup runbook in docs/runbooks/

## Dependencies

- Understanding of current NAS backup capabilities
- Proxmox backup capabilities
- Storage availability for backups
- Decision on backup automation vs manual

## Testing Plan

[[docs/agents/TESTING|Testing Agent]] should validate:
- Backups are created successfully
- Backups are complete and not corrupted
- Restore procedure works (test on VM 104 or 105)
- RTO/RPO requirements are met
- Backup storage has adequate space

## Related Documentation

- [[docs/ARCHITECTURE|Architecture]]
- [[docs/DECISIONS|Decisions]] - Future ADR needed
- Future: docs/runbooks/backup-restore.md

## Notes

**Progress Update (2025-10-27):**

**Completed Work:**
- ✅ Vaultwarden database backup implemented via [[../completed/IN-017-implement-vaultwarden-backup|IN-017]]
  - Automated daily backups to NAS (nightly at 2 AM)
  - Retention: 7 daily, 4 weekly, 12 monthly backups
  - Encryption and verification in place
  - Script: `scripts/backup-vaultwarden.sh`

**Remaining Scope:**
This task should now focus on:
- VM snapshots/backups (Proxmox-level)
- Service database backups (Emby, *arr, Immich, Paperless)
- .env file backups (critical secrets) - see [[IN-016-backup-ui-managed-secrets|IN-016]]
- Comprehensive backup documentation and runbook
- Testing restore procedures (see [[IN-008-test-disaster-recovery|IN-008]])

**Items to backup:**
- Proxmox VM configurations
- VM disk snapshots
- Docker configurations (already in git)
- .env files (CRITICAL - contain secrets)
- **Vaultwarden database (CRITICAL - source of truth for secrets)**
- Service databases (Emby, *arr, Immich, etc.)
- NAS data (handled by NAS?)

**Considerations:**
- How long can we tolerate downtime? (RTO)
- How much data loss is acceptable? (RPO)
- Off-site backup for disaster recovery?
- Encryption for backup files
- Testing backup integrity

**Future enhancement:**
- Automated backup scripts
- Monitoring backup success/failure
- Alerting on backup failures
