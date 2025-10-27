---
type: task
task-id: IN-017
status: pending
priority: 1
category: security
agent: security
created: 2025-10-26
updated: 2025-10-26
tags:
  - task
  - security
  - backup
  - vaultwarden
  - critical
---

# Task: IN-017 - Implement Automated Vaultwarden Backup

<!-- Priority Scale: 0 (critical/urgent) → 1-2 (high) → 3-4 (medium) → 5-6 (low) → 7-9 (very low) -->

## Description

Implement automated backup solution for Vaultwarden database to prevent catastrophic loss of all infrastructure secrets. Currently NO automated backup exists - if database corrupts or is accidentally deleted, we lose ALL secrets for ALL infrastructure.

**CRITICAL:** This must be completed before proceeding with IN-002 Phase 2+ (critical services migration).

## Context

**Discovery:** During IN-002 Phase 0 pre-migration checks, we verified Vaultwarden is healthy but discovered it has NO automated backup.

**Current State:**
- Vaultwarden database: `/home/evan/data/vw-data/db.sqlite3` (1.2MB)
- Location: VM 103 (192.168.86.249)
- Last modified: Active (Oct 26 14:30)
- Backup strategy: NONE ❌

**Risk Assessment:**
- **Likelihood:** Database corruption, accidental deletion, hardware failure, ransomware
- **Impact:** CATASTROPHIC - lose ALL infrastructure secrets
  - Cannot access any service
  - Cannot deploy anything
  - Weeks of manual reconfiguration
  - Possible permanent loss of data
- **Current Mitigation:** NONE

**Urgency:** HIGH - Blocking IN-002 Phase 2+ work

## Backup Strategy Options

### Option 1: Simple Local Backup (Quick Fix)

**Approach:**
- Daily cron job on VM 103
- SQLite backup to NAS
- Keep 30 days of backups
- Simple, fast to implement

**Implementation:**
```bash
# /home/evan/scripts/backup-vaultwarden.sh
#!/bin/bash
BACKUP_DIR="/mnt/nas/backups/vaultwarden"
DATE=$(date +%Y%m%d-%H%M%S)
sqlite3 /home/evan/data/vw-data/db.sqlite3 ".backup $BACKUP_DIR/vw-backup-$DATE.sqlite3"
find $BACKUP_DIR -name "vw-backup-*.sqlite3" -mtime +30 -delete
```

**Pros:**
- Fast to implement (< 1 hour)
- No external dependencies
- Automated
- Versioned backups

**Cons:**
- Single point of failure (NAS)
- No offsite backup
- NAS failure = lose backups and live data

**IMPORTANT QUESTION:** Does NAS currently store the live Vaultwarden data?
- If yes: Backup must go elsewhere (NAS failure = lose everything)
- If no: Local NAS backup is acceptable as first step

### Option 2: Offsite Backup (Better)

**Approach:**
- Local backup to NAS (fast recovery)
- Encrypted backup to cloud storage (disaster recovery)
- Use rclone or similar

**Implementation:**
```bash
# Local backup first
sqlite3 /home/evan/data/vw-data/db.sqlite3 ".backup /tmp/vw-backup.sqlite3"

# Encrypt and upload to cloud
gpg --encrypt --recipient you@email.com /tmp/vw-backup.sqlite3
rclone copy /tmp/vw-backup.sqlite3.gpg remote:vaultwarden-backups/
```

**Pros:**
- Offsite protection
- Encrypted at rest
- Disaster recovery capable
- Independent of NAS

**Cons:**
- More complex setup
- Requires cloud storage account
- Costs $ (minimal - few MB/month)
- Need GPG key management

**Cloud Options:**
- AWS S3 (cheap for small data)
- Backblaze B2 (very cheap)
- Google Drive (if you have account)
- Dropbox

### Option 3: Vaultwarden Built-In Backup (Best Long-Term)

**Approach:**
- Use Vaultwarden's backup feature if available
- Or: Docker volume backup solutions
- Comprehensive backup of all data

**Need to research:**
- Does Vaultwarden container have built-in backup?
- Can we mount backup location via docker volume?
- Best practices from Vaultwarden docs

## Acceptance Criteria

### Phase 1: Quick Fix (URGENT - Before IN-002 Phase 2)
- [ ] Determine if NAS holds live Vaultwarden data (critical decision point)
- [ ] If NAS holds live data: Implement offsite backup (Option 2)
- [ ] If NAS doesn't hold live data: Implement local backup (Option 1)
- [ ] Create backup script (`scripts/backup/backup-vaultwarden.sh`)
- [ ] Test backup creation
- [ ] Schedule daily automated backups (cron)
- [ ] Verify backups are being created daily
- [ ] Document backup location and retention policy

### Phase 2: Backup Verification
- [ ] Test restore procedure from backup
- [ ] Document restore steps
- [ ] Verify restored database works
- [ ] Calculate RTO (Recovery Time Objective)
- [ ] Calculate RPO (Recovery Point Objective - currently 24 hours with daily backup)

### Phase 3: Monitoring & Alerting
- [ ] Monitor backup success/failure
- [ ] Alert if backup fails
- [ ] Alert if backup size changes dramatically (possible corruption)
- [ ] Dashboard showing last successful backup time

### Phase 4: Improvement (Post-Quick Fix)
- [ ] Implement offsite backup if not already done
- [ ] Reduce RPO if needed (more frequent backups)
- [ ] Encrypt backups if going offsite
- [ ] Test restore regularly (monthly drill)
- [ ] Document backup in IN-011 (overall backup strategy)

## Dependencies

- Access to VM 103
- Determine current Vaultwarden data location
- Choose backup destination (NAS vs. offsite)
- **BLOCKS:** IN-002 Phase 2+ (must complete before migrating critical services)

## Testing Plan

[[docs/agents/TESTING|Testing Agent]] should validate:

**Backup Creation:**
- [ ] Script executes successfully
- [ ] Backup file created in correct location
- [ ] Backup file size reasonable (~ same as source DB)
- [ ] Backup file is valid SQLite database
- [ ] Cron job triggers on schedule
- [ ] Old backups cleaned up per retention policy

**Restore Testing:**
- [ ] Stop Vaultwarden container
- [ ] Restore database from backup
- [ ] Start Vaultwarden container
- [ ] Can login via Web UI
- [ ] Can retrieve existing secrets via CLI
- [ ] No data loss detected

**Failure Scenarios:**
- [ ] What if backup destination unavailable? (graceful failure, alert)
- [ ] What if database locked during backup? (handle correctly)
- [ ] What if backup filesystem full? (alert, don't delete old backups)

## Related Documentation

- [[docs/agents/SECURITY|Security Agent]]
- [[docs/SECRET-MANAGEMENT|Secret Management]]
- [[tasks/current/IN-002-migrate-secrets-to-env|IN-002]] - Blocks Phase 2+
- [[tasks/backlog/IN-011-document-backup-strategy|IN-011]] - Overall backup strategy

## Notes

### Critical Questions to Answer FIRST

**Q1: Where is Vaultwarden data currently stored?**
```bash
# Check docker volume
docker inspect vaultwarden | grep -A 10 "Mounts"

# Check if NAS
df -h /home/evan/data/vw-data
mount | grep vw-data
```

**Expected Answer:**
- If `/home/evan/data` is local disk: Local backup to NAS is OK
- If `/home/evan/data` is NFS mount to NAS: MUST backup elsewhere

**Q2: How much data are we backing up?**
- Current: 1.2MB database
- Negligible storage cost
- Can backup frequently without issue

**Q3: What's acceptable data loss?**
- 24 hours? (daily backup)
- 1 hour? (hourly backup)
- Real-time? (continuous replication - overkill?)

**Recommendation:** Daily backup acceptable for Phase 1, can improve later

### Implementation Decision Tree

```
START
  |
  ├─> Is NAS holding live Vaultwarden data?
  |     ├─> YES → Use offsite backup (Option 2)
  |     |         - Setup cloud storage
  |     |         - Encrypt backups
  |     |         - Cost: ~$1/month
  |     |
  |     └─> NO → Use local NAS backup (Option 1)
  |               - Fast to implement
  |               - Good enough for Phase 1
  |               - Add offsite in Phase 4
  |
  └─> Done: Unblock IN-002 Phase 2
```

### Backup Script Outline

```bash
#!/usr/bin/env bash
# backup-vaultwarden.sh

set -euo pipefail

# Configuration
SOURCE_DB="/home/evan/data/vw-data/db.sqlite3"
BACKUP_DIR="/path/to/backups"  # TBD based on Q1
DATE=$(date +%Y%m%d-%H%M%S)
BACKUP_FILE="$BACKUP_DIR/vw-backup-$DATE.sqlite3"
RETENTION_DAYS=30

# Verify source exists
if [ ! -f "$SOURCE_DB" ]; then
    echo "ERROR: Source database not found"
    exit 1
fi

# Create backup using SQLite's backup command (ensures consistency)
sqlite3 "$SOURCE_DB" ".backup '$BACKUP_FILE'"

# Verify backup
if [ ! -f "$BACKUP_FILE" ]; then
    echo "ERROR: Backup failed"
    exit 1
fi

# Check backup is valid SQLite DB
if ! sqlite3 "$BACKUP_FILE" "PRAGMA integrity_check;" | grep -q "ok"; then
    echo "ERROR: Backup integrity check failed"
    exit 1
fi

# Cleanup old backups
find "$BACKUP_DIR" -name "vw-backup-*.sqlite3" -mtime +$RETENTION_DAYS -delete

echo "SUCCESS: Backup created at $BACKUP_FILE"
```

### Offsite Backup Addition (if needed)

```bash
# After creating local backup, encrypt and upload
if [ "$OFFSITE_ENABLED" = "true" ]; then
    gpg --encrypt --recipient "$GPG_KEY" "$BACKUP_FILE"
    rclone copy "$BACKUP_FILE.gpg" "remote:vaultwarden-backups/"
    rm "$BACKUP_FILE.gpg"  # Clean up encrypted copy
fi
```

---

**Priority Rationale:** Critical priority (1) because:
- No backup = catastrophic single point of failure
- Blocks IN-002 Phase 2+ work (can't risk critical services without backup)
- Quick fix available (< 1 day to implement)
- Must be done before adding more secrets to Vaultwarden
