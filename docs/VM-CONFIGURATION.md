---
type: documentation
tags:
  - infrastructure
  - vms
  - configuration
---

# VM Configuration Changes

**Purpose:** Track manual changes made to VMs for future VM template/automation work.

**Goal:** Document all manual configurations so VMs can be recreated from scripts/templates.

---

## VM 103 (192.168.86.249) - Misc Services

### Manual Changes Made

**2025-10-26 - IN-017: Vaultwarden Backup Setup**

1. **Installed Packages:**
   ```bash
   sudo apt-get install -y sqlite3
   ```
   - **Why:** Required for Vaultwarden database backups
   - **Used by:** `/home/evan/scripts/backup-vaultwarden.sh`

2. **Created Directories:**
   ```bash
   mkdir -p /home/evan/scripts
   mkdir -p /mnt/video/backups/vaultwarden
   ```
   - **Why:** Backup script location and NAS backup destination
   - **Ownership:** evan:evan

3. **Deployed Scripts:**
   - `/home/evan/scripts/backup-vaultwarden.sh` (executable)
   - **Purpose:** Daily Vaultwarden database backup to NAS

4. **Cron Jobs Added:**
   ```bash
   0 2 * * * /home/evan/scripts/backup-vaultwarden.sh >> /var/log/vaultwarden-backup.log 2>&1
   0 2 * * * /home/evan/scripts/backup-mybibliotheca.sh >> /var/log/mybibliotheca-backup.log 2>&1
   ```
   - **User:** evan
   - **Schedule:** Daily at 2 AM
   - **Purpose:** Automated Vaultwarden and MyBibliotheca backups

### Existing Configuration (Not Changed)

- **SSH Access:** evan user with passwordless sudo (configured earlier)
- **NAS Mounts:**
  - `/mnt/video` → `//192.168.86.43/media`
  - `/mnt/music` → `//192.168.86.43/music`
- **Docker:** Installed and running
- **Services:** vaultwarden, paperless-ngx, linkwarden, immich, audiobookshelf, navidrome, mybibliotheca, portainer, watchtower, homepage, newt

### Known Issues

- **CRITICAL: Disk Space at 98%** (91G / 97G used, 2.1G available)
  - Needs expansion - see [[tasks/backlog/IN-018-expand-vm-103-disk|IN-018]]

---

## VM 100 (192.168.86.172) - Emby

### Manual Changes Made

*(None yet - to be documented)*

### Existing Configuration

- **Disk Usage:** 20% (15G / 79G used, 61G available) ✓ Healthy
- **Services:** emby, newt, portainer, watchtower

---

## VM 101 (192.168.86.173) - Downloads

### Manual Changes Made

*(None yet - to be documented)*

### Existing Configuration

- **Disk Usage:** 29% (27G / 97G used, 66G available) ✓ Healthy
- **Services:** vpn, deluge, nzbget, portainer, watchtower

---

## VM 102 (192.168.86.174) - Arr Services

### Manual Changes Made

*(None yet - to be documented)*

### Existing Configuration

- **Disk Usage:** 26% (49G / 195G used, 139G available) ✓ Healthy
- **Services:** radarr, sonarr, lidarr, prowlarr, jellyseerr, flaresolverr, huntarr, newt, portainer, watchtower

---

## Automation Plan

### VM Template Requirements

When creating VM templates or automation scripts, ensure the following are included:

**All VMs:**
- [ ] evan user with passwordless sudo
- [ ] SSH key authentication configured
- [ ] Docker and docker-compose installed
- [ ] Basic monitoring tools (htop, iotop, etc.)

**VM 103 Specific:**
- [ ] sqlite3 package
- [ ] `/home/evan/scripts` directory
- [ ] NAS mounts configured (`/mnt/video`, `/mnt/music`)
- [ ] Backup script deployed
- [ ] Cron job for backups configured

### Future Automation Tasks

- [[tasks/backlog/IN-XXX-create-vm-provisioning-scripts|Create VM Provisioning Scripts]]
- [[tasks/backlog/IN-XXX-create-vm-templates|Create Proxmox VM Templates]]

---

## Monitoring

**Disk Space Monitoring:**
- Script: `scripts/validation/check-vm-disk-space.sh`
- Run manually: `./scripts/validation/check-vm-disk-space.sh`
- Thresholds: Warning 80%, Critical 95%

**Current Status (2025-10-26):**
- VM 100: 20% ✓
- VM 101: 29% ✓
- VM 102: 26% ✓
- VM 103: 98% ✗ CRITICAL

---

## Notes

- Always update this document when making manual changes to VMs
- Include the task ID that prompted the change
- Document why the change was made (purpose/context)
- Note which scripts or services depend on the change
- Update the "Automation Plan" section with requirements for future templates
