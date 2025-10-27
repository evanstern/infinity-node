---
type: task
task-id: IN-018
status: pending
priority: 1
category: infrastructure
agent: infrastructure
created: 2025-10-26
updated: 2025-10-26
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

### Phase 1: Immediate Disk Expansion (VM 103)
- [ ] Identify what's consuming disk space on VM 103
- [ ] Clean up unnecessary data if possible
- [ ] Expand VM disk in Proxmox (increase allocation)
- [ ] Extend LVM logical volume
- [ ] Resize filesystem
- [ ] Verify new space is available
- [ ] Document exact steps taken

### Phase 2: Create Disk Expansion Automation
- [ ] Create script: `scripts/infrastructure/expand-vm-disk.sh`
  - Takes VM ID and new size as parameters
  - Automates Proxmox disk resize
  - Automates LVM extension
  - Automates filesystem resize
  - Includes safety checks and confirmations
- [ ] Test script on non-critical VM first
- [ ] Document script usage in `scripts/README.md`

### Phase 3: Enhance Monitoring
- [ ] Integrate `check-vm-disk-space.sh` into cron for proactive monitoring
- [ ] Set up alerts when disk usage exceeds thresholds
- [ ] Create dashboard/report for disk trends

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

## Notes

### Disk Usage Analysis (To Be Filled)

After running `du` commands, document:
- What's consuming the most space?
- Can anything be cleaned up?
- Is Docker using excessive space? (`docker system prune`)

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

---

**Priority Rationale:** Critical priority (1) because:
- VM 103 at 98% capacity - service failures imminent
- Hosts critical infrastructure (Vaultwarden, Paperless, Immich)
- Process has been painful multiple times - automation needed
- Quick fix needed before adding more services
