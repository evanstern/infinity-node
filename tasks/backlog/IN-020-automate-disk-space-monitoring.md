---
type: task
task-id: IN-020
status: pending
priority: 4
category: monitoring
agent: infrastructure
created: 2025-10-27
updated: 2025-10-27
tags:
  - task
  - monitoring
  - infrastructure
  - automation
  - disk-space
---

# Task: IN-020 - Automate VM Disk Space Monitoring and Alerting

<!-- Priority Scale: 0 (critical/urgent) → 1-2 (high) → 3-4 (medium) → 5-6 (low) → 7-9 (very low) -->

## Description

Set up automated disk space monitoring across all VMs with proactive alerts to prevent disk-full situations before they become critical. This task implements Phase 3 from IN-018, establishing ongoing monitoring to prevent future disk space crises.

## Context

**Origin:** Phase 3 of [[../completed/IN-018-expand-vm-103-disk-space|IN-018]]

**Current State:**
- `check-vm-disk-space.sh` script exists and works well
- Script must be run manually
- No automated monitoring or alerting in place
- Recent cleanup recovered 109GB across 4 VMs by removing 379 unused Docker images
- All VMs now healthy (<25% usage) but need proactive monitoring

**Why This Matters:**
- VM 103 reached 98% capacity before we noticed it
- Could have caused service failures (Vaultwarden, Paperless, Immich)
- Proactive monitoring prevents emergencies
- Regular checks can identify gradual growth trends

## Acceptance Criteria

### Phase 1: Automated Monitoring
- [ ] Set up cron job on management machine to run `check-vm-disk-space.sh` daily
- [ ] Configure email/notification for threshold warnings
- [ ] Test alert delivery when threshold is exceeded
- [ ] Document monitoring setup in infrastructure docs

### Phase 2: Alerting Strategy
- [ ] Define alert thresholds:
  - Warning: 70% disk usage (gives time to plan)
  - Critical: 85% disk usage (action needed soon)
  - Emergency: 95% disk usage (immediate action)
- [ ] Set up alert routing (email, Slack, etc.)
- [ ] Create runbook for responding to disk alerts
- [ ] Test alert system with simulated conditions

### Phase 3: Trend Analysis & Reporting
- [ ] Create script to track disk usage over time
- [ ] Store historical disk usage data
- [ ] Generate weekly/monthly disk usage reports
- [ ] Identify VMs with growing disk usage trends
- [ ] Predict when VMs will need expansion based on trends

## Implementation Plan

### Step 1: Basic Cron Monitoring

On management machine or designated monitoring VM:

```bash
# Add to crontab
# Run disk space check daily at 8 AM
0 8 * * * /path/to/scripts/validation/check-vm-disk-space.sh --threshold 70 | mail -s "VM Disk Space Report" admin@example.com
```

### Step 2: Enhanced Alert Script

Create `scripts/monitoring/disk-space-alert.sh`:
- Wraps `check-vm-disk-space.sh`
- Sends alerts based on severity
- Only alerts when thresholds are exceeded (not daily OK messages)
- Includes links to cleanup and expansion scripts

### Step 3: Historical Tracking

Create `scripts/monitoring/track-disk-usage.sh`:
- Runs daily via cron
- Stores disk usage data to CSV/JSON
- Enables trend analysis
- Can generate charts/graphs

Example data structure:
```csv
date,vm_id,vm_name,used_gb,total_gb,percent_used
2025-10-27,100,emby,12,79,16
2025-10-27,101,downloads,18,97,19
...
```

### Step 4: Reporting Dashboard

Create `scripts/monitoring/generate-disk-report.sh`:
- Reads historical data
- Generates summary reports
- Identifies growth trends
- Recommends proactive actions

## Alert Runbook

When disk space alert is received:

**70% Warning:**
1. Review alert details
2. Identify largest consumers on affected VM
3. Check for reclaimable Docker images: `docker-cleanup.sh`
4. Plan expansion if cleanup won't be sufficient
5. Schedule maintenance window if needed

**85% Critical:**
1. Immediate review of disk usage
2. Run `docker-cleanup.sh` on affected VM
3. Remove unnecessary data if possible
4. Prepare for disk expansion
5. Monitor closely until resolved

**95% Emergency:**
1. Immediate action required
2. Run `docker-cleanup.sh` immediately
3. Remove logs, temp files, old backups
4. Expand disk if cleanup insufficient
5. Use `expand-vm-disk.sh` for automated expansion
6. Verify services remain operational

## Tools & Dependencies

**Existing:**
- `scripts/validation/check-vm-disk-space.sh` - Core monitoring script
- `scripts/infrastructure/docker-cleanup.sh` - Cleanup tool
- `scripts/infrastructure/expand-vm-disk.sh` - Expansion tool

**To Create:**
- `scripts/monitoring/disk-space-alert.sh` - Alert wrapper
- `scripts/monitoring/track-disk-usage.sh` - Historical tracking
- `scripts/monitoring/generate-disk-report.sh` - Reporting

**System Requirements:**
- Cron for scheduling
- Mail/notification system (email, Slack webhook, etc.)
- Storage for historical data (CSV files or simple database)

## Testing Plan

**Test Alert Thresholds:**
1. Temporarily lower thresholds to trigger alerts
2. Verify alert delivery (email/notification)
3. Confirm alert includes actionable information
4. Test with multiple VMs exceeding thresholds

**Test Historical Tracking:**
1. Run tracking script multiple times over several days
2. Verify data is stored correctly
3. Ensure no duplicate entries
4. Test report generation from historical data

**Test Response Procedures:**
1. Follow runbook for warning scenario
2. Verify cleanup script reduces usage
3. Test expansion script (on non-critical VM)
4. Document any gaps in procedures

## Related Tasks & Documentation

- [[../completed/IN-018-expand-vm-103-disk-space|IN-018]] - Origin task, disk cleanup & automation
- [[../../scripts/README.md|Scripts README]] - Documentation for monitoring scripts
- [[../../docs/agents/INFRASTRUCTURE|Infrastructure Agent]] - Infrastructure management
- [[IN-005-setup-monitoring-alerting|IN-005]] - Broader monitoring setup (may overlap)

## Future Enhancements

**Potential Additions:**
- Integration with monitoring platform (Prometheus, Grafana, etc.)
- Predictive alerts based on growth rate
- Automated cleanup when safe (e.g., prune images monthly)
- Integration with Proxmox API for storage metrics
- Mobile app notifications for critical alerts
- Slack/Discord bot for interactive alerts

## Success Metrics

**After Implementation:**
- Zero surprise disk-full situations
- Disk issues identified at warning level (70%), not critical (95%+)
- Response time to disk alerts < 24 hours
- All VMs remain below 80% usage through proactive management
- Historical data enables capacity planning

---

**Priority Rationale:** Medium priority (4) because:
- Not urgent - all VMs currently healthy after cleanup
- Important - prevents future crises like IN-018
- Foundational - enables proactive infrastructure management
- Can be implemented gradually (cron first, enhancements later)
- Lower priority than active issues but higher than nice-to-haves
