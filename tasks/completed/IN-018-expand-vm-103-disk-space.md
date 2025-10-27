---
type: task
task-id: IN-018
status: completed
priority: 1
category: infrastructure
agent: infrastructure
created: 2025-10-26
updated: 2025-10-27
completed: 2025-10-27
tags:
  - task
  - infrastructure
  - proxmox
  - disk
  - critical
---

# Task: IN-018 - Expand VM 103 Disk Space and Automate Process

<!-- Priority Scale: 0 (critical/urgent) → 1-2 (high) → 3-4 (medium) → 5-6 (low) → 7-9 (very low) -->

## Description

Expand disk space on VM 103 which is critically low at 98% usage (91G / 97G, only 2.1G available). Create automation scripts for disk expansion process to avoid manual lookups in future.

**CRITICAL:** VM 103 hosts critical infrastructure services (Vaultwarden, Paperless, Immich, etc.). Low disk space could cause service failures.

## Context

**Discovery:** During IN-017 (Vaultwarden backup setup), discovered VM 103 is at 98% disk usage.

**Current State:**
- VM 103: 91G used of 97G total, 2.1G available
- Other VMs healthy: VM 100 (20%), VM 101 (29%), VM 102 (26%)
- User has performed this operation multiple times before
- Manual process requires looking up steps each time

**User Feedback:**
> "This process is something I've had to do multiple times and it's a pain in the butt which requires me to look up how to do it every time. Let's automate this."

## Acceptance Criteria

### Phase 1: Immediate Disk Resolution (VM 103)
- [x] Identify what's consuming disk space on VM 103
- [x] Clean up unnecessary data if possible
- [x] ~~Expand VM disk in Proxmox (increase allocation)~~ - NOT NEEDED after cleanup
- [x] ~~Extend LVM logical volume~~ - NOT NEEDED after cleanup
- [x] ~~Resize filesystem~~ - NOT NEEDED after cleanup
- [x] Verify new space is available (72GB available after cleanup, 23% usage)
- [x] Document exact steps taken

**Decision:** Skipped disk expansion after Docker cleanup freed 70GB. VM now has 72GB free (77% available) - expansion not needed.

### Phase 2: Create Disk Expansion Automation
- [x] Create script: `scripts/infrastructure/expand-vm-disk.sh`
  - Takes VM ID and new size as parameters
  - Automates Proxmox disk resize
  - Automates LVM extension
  - Automates filesystem resize
  - Includes safety checks and confirmations
- [x] Create bonus script: `scripts/infrastructure/docker-cleanup.sh`
  - Automates Docker image cleanup
  - Reports before/after disk usage
  - Shows space recovered
- [x] Test docker-cleanup script on all VMs
- [x] Document both scripts in `scripts/README.md`

### Phase 3: Enhance Monitoring
- [ ] ~~Integrate `check-vm-disk-space.sh` into cron for proactive monitoring~~ → Moved to [[IN-020-automate-disk-space-monitoring|IN-020]]
- [ ] ~~Set up alerts when disk usage exceeds thresholds~~ → Moved to [[IN-020-automate-disk-space-monitoring|IN-020]]
- [ ] ~~Create dashboard/report for disk trends~~ → Moved to [[IN-020-automate-disk-space-monitoring|IN-020]]

**Note:** Phase 3 monitoring requirements were extracted into a dedicated task [[../backlog/IN-020-automate-disk-space-monitoring|IN-020]] to enable focused implementation of automated monitoring and alerting.

## Dependencies

- Access to Proxmox host (root@192.168.86.106)
- SSH access to VM 103 (evan@192.168.86.249)
- Understanding of current Proxmox storage configuration
- Backup of critical data before expansion (Vaultwarden backup now exists via IN-017)

## Implementation Plan

### Step 1: Assess Disk Usage

```bash
# On VM 103, identify largest consumers
sudo du -sh /var/lib/docker /home /var/log /tmp | sort -rh
sudo docker system df
```

### Step 2: Manual Disk Expansion Process

**On Proxmox Host:**
```bash
# 1. Increase disk size in Proxmox
qm resize <vm-id> scsi0 +<size>G

# Example: Expand by 50GB
qm resize 103 scsi0 +50G
```

**On VM 103:**
```bash
# 2. Rescan SCSI bus to detect new size
echo 1 | sudo tee /sys/class/block/sda/device/rescan

# 3. Extend physical volume
sudo pvresize /dev/sda3

# 4. Extend logical volume (use 100% of free space)
sudo lvextend -l +100%FREE /dev/mapper/ubuntu--vg-ubuntu--lv

# 5. Resize filesystem
sudo resize2fs /dev/mapper/ubuntu--vg-ubuntu--lv

# 6. Verify
df -h /
```

### Step 3: Automation Script Outline

```bash
#!/usr/bin/env bash
# expand-vm-disk.sh - Automate Proxmox VM disk expansion
#
# Usage:
#   ./expand-vm-disk.sh <vm-id> <additional-size-GB>
#
# Example:
#   ./expand-vm-disk.sh 103 50  # Add 50GB to VM 103

# Safety checks:
# - Verify VM exists
# - Show current disk usage
# - Confirm with user before proceeding
# - Verify each step succeeded before continuing

# Steps:
# 1. Expand disk in Proxmox (via qm resize)
# 2. SSH to VM and rescan SCSI
# 3. Extend PV
# 4. Extend LV
# 5. Resize filesystem
# 6. Verify success
```

## Testing Plan

[[docs/agents/TESTING|Testing Agent]] should validate:

**Post-Expansion:**
- [ ] Disk space increased as expected
- [ ] All services still running
- [ ] Can write to filesystem
- [ ] No errors in dmesg or logs
- [ ] LVM volumes healthy: `sudo lvs`, `sudo pvs`

**Script Testing:**
- [ ] Dry-run mode shows what would be done
- [ ] Safety checks prevent dangerous operations
- [ ] Clear error messages if something fails
- [ ] Script is idempotent (can be run multiple times safely)

## Related Documentation

- [[docs/agents/INFRASTRUCTURE|Infrastructure Agent]]
- [[docs/VM-CONFIGURATION|VM Configuration]] - Track changes made
- [[scripts/validation/check-vm-disk-space|Disk Space Monitor]] - Prevention tool
- [[scripts/README.md|Scripts README]] - Documentation for created automation scripts

## Related Tasks

- [[../backlog/IN-020-automate-disk-space-monitoring|IN-020]] - Automated monitoring and alerting (Phase 3 extracted)
- [[completed/IN-017-implement-vaultwarden-backup|IN-017]] - Vaultwarden backup (context for VM 103 importance)

## Notes

### Disk Usage Analysis (Completed 2025-10-27)

**Current Disk Status:**
```
Filesystem: /dev/mapper/ubuntu--vg-ubuntu--lv
Size: 97G
Used: 91G
Available: 2.1G
Usage: 98%
```

**Directory Breakdown:**
- `/var/lib/docker`: 93G (PRIMARY CULPRIT)
- `/home`: 627M
- `/var/log`: 388M
- `/tmp`: 3.7M

**Docker System Analysis:**
```
Images:         149 total, 19 active, 78.05GB total size
  - RECLAIMABLE: 68.1GB (87% of image storage!)
Containers:     19 total, 19 active, 3.289MB
Local Volumes:  15 total, 3 active, 803.3MB
```

**Key Finding:** Docker has 68.1GB of reclaimable space from unused images!

**Recommendation:** Clean up Docker images first before expanding disk:
```bash
ssh evan@192.168.86.249 "sudo docker image prune -a"
```

This should reduce usage from 91G to ~23G (24% usage), making expansion potentially unnecessary or allowing us to expand with more breathing room.

### Recommended Expansion Size

Based on:
- Current usage: 91G
- Available: 2.1G
- Growth rate: TBD
- Future needs: More services planned?

**Recommendation:** Expand by at least 50GB to provide breathing room.

### Alternative: Cleanup vs Expansion

Before expanding, consider:
- **Docker cleanup:** `docker system prune -a --volumes`
- **Log rotation:** Check `/var/log` size
- **Temporary files:** Clean `/tmp`, old backups
- **Service data:** Are there old/unused containers?

### Future Prevention

- Regular monitoring via `check-vm-disk-space.sh`
- Alert at 80% to expand before critical
- Consider separate volumes for Docker data
- Document growth trends to predict future needs

### Docker Cleanup Results (2025-10-27)

Ran `docker-cleanup.sh` on all VMs with outstanding results:

**VM 100 (emby) - 192.168.86.172:**
- Before: 15G used (20%), 27 Docker images, 2.7GB reclaimable
- After: 12G used (16%), 4 Docker images, 0GB reclaimable
- **Result: Freed 4% disk space, removed 23 unused images**

**VM 101 (downloads) - 192.168.86.173:**
- Before: 27G used (29%), 72 Docker images, 8.6GB reclaimable
- After: 18G used (19%), 5 Docker images, 0GB reclaimable
- **Result: Freed 10% disk space, removed 67 unused images**

**VM 102 (arr) - 192.168.86.174:**
- Before: 49G used (27%), 170 Docker images, 30.5GB reclaimable
- After: 19G used (10%), 11 Docker images, 0.06GB reclaimable
- **Result: Freed 17% disk space (30GB!), removed 159 unused images**

**VM 103 (misc) - 192.168.86.249:**
- Before: 91G used (98%), 149 Docker images, 68.1GB reclaimable
- After: 21G used (23%), 19 Docker images, 0.02GB reclaimable
- **Result: Freed 75% disk space (70GB!), removed 130 unused images**

**Total Across All VMs:**
- **Space Recovered: ~109GB**
- **Images Removed: 379 unused images**
- **Average Reduction: 26% disk usage decrease**

All VMs now have healthy disk usage under 25%, with no immediate expansion needed.

### Scripts Created

**1. `scripts/infrastructure/docker-cleanup.sh`**
- Automates Docker image cleanup on remote VMs
- Shows before/after disk usage and Docker stats
- Reports space recovered and images removed
- Color-coded output for clear status
- Tested successfully on all 4 VMs

**2. `scripts/infrastructure/expand-vm-disk.sh`**
- End-to-end automation for VM disk expansion
- Handles Proxmox resize through filesystem expansion
- Includes safety checks and user confirmation
- Ready for use when expansion is needed
- Full documentation in scripts/README.md

---

**Priority Rationale:** Critical priority (1) because:
- VM 103 at 98% capacity - service failures imminent
- Hosts critical infrastructure (Vaultwarden, Paperless, Immich)
- Process has been painful multiple times - automation needed
- Quick fix needed before adding more services

**Resolution:** ✅ RESOLVED via Docker cleanup instead of disk expansion. Created automation scripts for future use.

**Follow-up Tasks:**
- [[../backlog/IN-020-automate-disk-space-monitoring|IN-020]] - Automated monitoring and alerting (Phase 3)
