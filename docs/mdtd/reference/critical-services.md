---
type: documentation
tags:
  - mdtd
  - reference
  - critical-services
---

# Critical Services Requirements

Extra requirements when working with Emby, downloads, or arr services.

## Critical Services Definition

**Services that affect household users:**

- **Emby** (VM 100 - 192.168.86.203): Primary media streaming
  - **Target**: 99.9% uptime
  - **Impact**: Household media access

- **Downloads** (VM 101 - 192.168.86.208): Download clients with VPN
  - **Target**: Active downloads must not corrupt
  - **Impact**: Media acquisition pipeline

- **Arr Services** (VM 102 - 192.168.86.210): Media automation
  - **Target**: Continuous operation
  - **Impact**: Automated media management

**Why critical?** These services are used daily by household members. Downtime or data corruption directly impacts users.

---

## Required Elements for Critical Service Tasks

### 1. Backup Plan

**Document:**
- What to backup before starting
- Where backups will be stored
- How to verify backup successful
- Backup retention period

**Example:**
```
BACKUP PLAN:
- Backup: /config volume for Emby container
- Location: /mnt/nas/backups/emby-YYYY-MM-DD/
- Verification: Restore to test directory, check configs load
- Retention: Keep for 30 days
```

### 2. Rollback Procedure

**Document:**
- Step-by-step rollback instructions
- Estimated recovery time (target: < 5 minutes)
- How to verify rollback successful
- What state system returns to

**Example:**
```
ROLLBACK PROCEDURE:
1. Stop new Emby container
2. Start old Emby container from backup
3. Verify service accessible at emby.local
4. Check one movie plays successfully
Estimated time: 3 minutes
System returns to: Pre-migration state, all content accessible
```

### 3. Timing Consideration

**Requirements:**
- Prefer low-usage windows: **3-6 AM**
- Coordinate with household if downtime expected
- Plan for maintenance window
- Have monitoring ready

**If downtime needed:**
- Notify household users in advance
- Provide estimated duration
- Have communication plan if extended

### 4. Extra Validation

**Beyond normal testing:**
- **User acceptance testing** - Household member verifies
- **Extended monitoring** - Watch for 24-48 hours post-change
- **Functionality testing** - Test actual use cases (play movie, download completes, etc.)
- **Performance baseline** - Compare before/after metrics

### 5. Frontmatter Flags

**Set in task frontmatter:**
```yaml
critical_services_affected: true
requires_backup: true
requires_downtime: true  # or false
```

---

## Testing Requirements

**Standard testing PLUS:**

- **Functionality testing**
  - Emby: Stream video, navigate library, search works
  - Downloads: Complete download successfully
  - Arr: Import and rename media correctly

- **Performance testing**
  - Response times acceptable
  - No degradation from baseline
  - Resource usage normal

- **Integration testing**
  - Service integrations still work
  - Remote access (Pangolin) still functions
  - Notifications still send

---

## Risk Mitigation for Critical Services

**Standard mitigations:**
- Test on non-critical service first (if possible)
- Have rollback ready and tested
- Monitor closely during and after change
- Keep old version running until validated

**Additional for critical:**
- Notify household before starting
- Have contingency plan if issues found
- Extended monitoring period
- Quick escalation path if problems

---

## Example: Critical Service Task Structure

```markdown
## Critical Service Impact

**Services Affected**: Emby (VM 100)

**Impact**: Primary media streaming service
- Used daily by household
- Cannot have > 30 minutes downtime
- Data loss unacceptable

**Mitigation**:
- Work during 3-6 AM window
- Complete backup before starting
- Rollback ready (< 5 min)
- Extended validation after changes

## Backup Plan

1. Backup /config volume: `docker cp emby:/config /mnt/nas/backups/emby-2024-01-15/`
2. Verify backup: Check configs are readable
3. Retention: Keep for 30 days

## Rollback Plan

1. Stop new Emby container: `docker stop emby`
2. Restore config from backup
3. Start container with restored config
4. Verify: Browse to emby.local, play test video
Recovery time: 5 minutes

## Testing Plan

**Testing Agent validates:**
- Container healthy
- API responding
- Logs clean

**Manual validation:**
1. Login as household user
2. Play video from library (verify streaming works)
3. Search for content (verify library accessible)
4. Check watched status preserved

**Extended monitoring:**
- Monitor for 48 hours post-change
- Check logs daily for errors
- Verify no user complaints
```

---

## When in Doubt

**If you're unsure whether a service is critical:**
- Ask: "Would household users notice if this broke?"
- If yes → Treat as critical
- Better to over-cautious than cause user impact

---

## Related Documentation

- **[[phases/03-risk-assessment]]** - Risk assessment guide
- **[[docs/adr/011-critical-services-list]]** - ADR defining critical services
- **[[docs/ARCHITECTURE]]** - System architecture
