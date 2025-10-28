# VM Research Findings

**Research Date:** 2025-10-28
**Purpose:** Document existing VM configurations to inform Ansible template creation

## VM Inventory

| VM ID | Name | IP | Hostname | Status |
|-------|------|-----|----------|--------|
| 100 | emby | 192.168.86.172 | ininity-node-emby | Running |
| 101 | downloads | 192.168.86.173 | infinity-node-downloads | Running |
| 102 | arrs | 192.168.86.174 | infinity-node-arr | Running |
| 103 | misc | 192.168.86.249 | infinity-node-misc | Running |

## Configuration Comparison

### Operating System
**All VMs: ✓ Consistent**
- OS: Ubuntu 24.04.1 LTS (Noble)
- All running same OS version

### Users & UIDs
**Mostly Consistent (1 difference)**

| VM | evan UID:GID | inspector UID:GID | Shell |
|----|--------------|-------------------|-------|
| 100 | 1000:1000 | 1001:1001 | bash |
| 101 | 1000:988 ⚠️ | 1001:1001 | bash |
| 102 | 1000:1000 | 1001:1001 | bash |
| 103 | 1000:1000 | 1001:1001 | bash |

**⚠️ Issue Found:** VM 101 has evan with GID 988 instead of 1000
- This could cause permission issues
- Template should use 1000:1000 (standard)

### Shell Configuration
**All VMs: bash (zsh not installed yet)**
- Current: `/bin/bash`
- Target: `/bin/zsh` (to be installed in template)

### Docker
**All VMs: ✓ Consistent**
- Docker: 28.1.1, build 4eba377
- Docker Compose: v2.35.1

### Groups (evan user)
**Mostly Consistent**

| VM | Groups |
|----|--------|
| 100 | evan adm cdrom sudo dip plugdev lxd docker |
| 101 | docker adm cdrom sudo dip plugdev lxd |
| 102 | evan adm cdrom sudo dip plugdev lxd docker |
| 103 | evan adm cdrom sudo dip plugdev lxd docker |

**Note:** Order differs slightly but same groups present
- All have: adm, cdrom, sudo, dip, plugdev, lxd, docker

### NAS Mounts (from /etc/fstab)
**⚠️ DIFFERENCE FOUND: VM 103 has different mounts**

**VMs 100, 101, 102** (3 mounts):
- `//192.168.86.43/media` → `/mnt/video`
- `//192.168.86.43/complete` → `/mnt/complete`
- `//192.168.86.43/music` → `/mnt/music`

**VM 103** (2 mounts only):
- `//192.168.86.43/media` → `/mnt/video`
- `//192.168.86.43/music` → `/mnt/music`
- ❌ Missing: `/mnt/complete` mount

**Mount Details:**
- Protocol: CIFS (Windows/Samba shares)
- NAS IP: 192.168.86.43
- Username: thor
- Password: [REDACTED] (found in plain text in fstab)
- Options: vers=2.0,rw,file_mode=0777,dir_mode=0777,nofail

### Firewall (UFW)
**All VMs: Inactive**
- UFW is installed but not enabled
- Template should enable and configure UFW

### Installed Packages
**Common packages found:**
- git (1:2.43.0-1ubuntu7.3)
- curl (8.5.0-2ubuntu10.6)
- wget (1.21.4-1ubuntu4.1)
- htop (3.3.0-4build1)
- vim (2:9.1.0016-1ubuntu7.9)
- **zsh: NOT INSTALLED** (need to add to template)

### Directory Structure
**Standard structure found:**
- `/home/evan/projects/` - exists
- `/home/evan/.ssh/` - exists
- Standard dotfiles (.bashrc, .bash_history, .profile)

## Key Findings

### ✓ Consistencies (Good for Template)
1. All VMs run Ubuntu 24.04.1 LTS
2. Docker versions identical
3. Same base packages installed
4. Same user structure (evan + inspector)
5. Similar NAS mount configuration (with one exception)
6. All have projects/ directory structure

### ⚠️ Differences (Need to Handle)
1. **VM 101**: evan user has GID 988 (others have 1000)
   - Impact: Potential permission issues
   - Solution: Template uses 1000, migrate VM 101 later

2. **VM 103**: Missing `/mnt/complete` NAS mount
   - Impact: Not all VMs need all mounts
   - Solution: Include all 3 mounts in template, post-clone script can disable

3. **All VMs**: Firewall (UFW) disabled
   - Impact: Security risk
   - Solution: Enable UFW in template

4. **All VMs**: No zsh installed
   - Impact: Need to install in template
   - Solution: Add zsh package, set as default shell

5. **All VMs**: NAS credentials in plain text
   - Impact: Security risk (less critical for local network)
   - Solution: Keep same approach for now, document for future improvement

### 🔒 Security Concerns
1. **NAS Credentials in fstab**: Plain text password
   - Current: username=thor,password=[REDACTED]
   - Recommendation: Keep for now (local network), document as future improvement

2. **Firewall Disabled**: All VMs have UFW inactive
   - Risk: Exposed services
   - Action: Enable in template

3. **SSH Configuration**: Not fully audited yet
   - Action: Extract and review SSH config

## Template Design Decisions

Based on research findings:

### Include in Template:
- ✓ Ubuntu 24.04 LTS (current version when creating)
- ✓ evan user (1000:1000) with zsh
- ✓ inspector user (1001:1001) with bash
- ✓ Docker + Docker Compose
- ✓ Base packages: git, curl, wget, htop, vim, **zsh**
- ✓ All 3 NAS mounts (video, complete, music)
- ✓ UFW enabled with SSH allowed
- ✓ projects/ directory structure
- ✓ evan in docker, sudo groups

### Configure Post-Clone:
- Hostname (unique per VM)
- IP address (static or DHCP)
- Disable NAS mounts if not needed (script flag)
- VM-specific services
- VM-specific firewall rules

### Migration Notes:
- VM 101 will need GID fix during migration (or accept difference)
- VM 103 will gain `/mnt/complete` mount (can be disabled post-clone if not needed)
- All VMs will gain zsh and enabled firewall

## Next Steps

1. ✓ Extract configuration files to save
2. Create Ansible playbook based on findings
3. Build template VM using Ansible
4. Test template clone
5. Plan future VM migration (IN-XXX)
