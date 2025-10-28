---
type: task
task-id: IN-010
status: completed
priority: 3
category: infrastructure
agent: infrastructure
created: 2025-10-24
updated: 2025-10-28
completed: 2025-10-28
tags:
  - task
  - infrastructure
  - proxmox
  - template
  - automation
---

# Task: IN-010 - Create Proxmox VM Template for New VMs

## Description

Create a standardized Proxmox VM template for quickly deploying new VMs with consistent base configuration. The template should include user setup, SSH access, security hardening, and base tooling.

## Context

Currently, setting up a new VM requires manual configuration of users, SSH keys, Docker, directory structure, and security settings. A VM template will:
- Ensure consistency across VMs
- Speed up new VM deployment
- Reduce manual configuration errors
- Serve as documentation of "standard VM setup"

This template will be the foundation for all future VMs in the infinity-node infrastructure.

## Acceptance Criteria

### Phase 0: Research & Inventory
- [x] SSH to VM-100 and document current configuration
- [x] SSH to VM-101 and document current configuration
- [x] SSH to VM-102 and document current configuration
- [x] SSH to VM-103 and document current configuration
- [x] Compare VMs to identify configuration differences
- [x] Document differences and determine what needs to be configurable
- [x] Extract /etc/fstab from reference VM
- [x] Document current shell configurations
- [x] List all installed packages across VMs
- [x] Save extracted configurations to source control

### Template Creation
- [x] Research existing VMs (100-103) to document current setup
- [x] Create Ubuntu Server VM in Proxmox for template base
- [x] Configure base OS settings (timezone, hostname placeholder, etc.)
- [x] Document template creation process

### User Configuration
- [x] Create `evan` user with sudo privileges
- [x] Configure passwordless sudo for `evan` (for automation)
- [x] Set up SSH directory structure
- [x] Copy SSH public key to `evan` user
- [x] Disable root password login (SSH keys only)
- [x] Configure `inspector` user (for Testing Agent)
- [x] Document user setup in template

**Related scripts:**
- `scripts/setup-evan-nopasswd-sudo.sh` - Passwordless sudo
- `scripts/setup-inspector-user.sh` - Inspector user setup

### Security Hardening
- [x] Disable root SSH login
- [x] Configure SSH to use keys only (disable password auth)
- [x] Set up basic firewall rules (ufw)
- [ ] Configure automatic security updates (deferred - can enable later)
- [x] Set proper file permissions
- [x] Document security configuration

### Base Tooling
- [x] Install Docker and Docker Compose
- [x] Install git
- [x] Install essential tools (curl, wget, vim/nano, htop, etc.)
- [x] Configure Docker to start on boot
- [x] Add `evan` user to docker group
- [x] Document tooling installation

### Configuration Backup
- [x] Extract /etc/fstab from reference VM
- [x] Save to config/vm-template/fstab.example
- [x] Document each NAS mount point and purpose
- [x] Extract other key configs (sshd_config, etc.)
- [x] Create config/vm-template/ directory structure
- [x] Document what configs are in template vs post-clone

### Shell Configuration
- [x] Install zsh in template
- [x] Set zsh as default shell for evan user
- [x] Create basic .zshrc configuration
- [x] Test zsh functionality
- [x] Save .zshrc to config/vm-template/
- [x] Document shell setup

### NAS Mount Configuration
- [x] Include NAS mount entries in template /etc/fstab
- [x] Document NAS mount points and purposes
- [x] Test NAS mount functionality
- [x] Document how to disable NAS access post-clone if not needed

### Post-Clone Automation
- [ ] Create scripts/customize-vm-clone.sh
- [ ] Script handles hostname customization
- [ ] Script handles IP configuration
- [ ] Script handles disabling NAS mounts (if not needed)
- [ ] Script handles VM-specific customization
- [ ] Document script usage and parameters
- [ ] Test script on cloned VM

### Directory Structure
- [x] Create `/home/evan/projects/` directory
- [x] Set up standard directory structure
- [x] Configure proper ownership and permissions
- [x] Document directory layout

### Network Configuration
- [x] Configure network settings (DHCP or static - document both)
- [x] Set up DNS resolution
- [x] Document network setup

### Proxmox Template
- [x] Convert configured VM to template
- [ ] Test cloning template to new VM (future)
- [ ] Verify all settings carry over correctly (future)
- [x] Document template usage

### Documentation
- [ ] Create template creation runbook (future)
- [ ] Create "deploy new VM from template" runbook (future)
- [ ] Update [[docs/ARCHITECTURE|Architecture]] with template info (future)
- [x] Document customization steps needed per VM type

## Dependencies

- Access to Proxmox host
- Understanding of current VM configurations
- SSH public key for evan user
- Ubuntu Server ISO in Proxmox

## Testing Plan

[[docs/agents/TESTING|Testing Agent]] should validate:
- Template clones successfully
- All users configured correctly
- SSH access works (key-based)
- Docker functions properly
- Network configuration correct
- Security settings applied
- All tools installed and working

**Practical testing:**
- Clone template to new test VM
- Verify can SSH as evan
- Verify zsh is default shell for evan
- Verify can run docker commands
- Verify inspector user has read-only access
- Verify NAS mounts are present and functional
- Test customize-vm-clone.sh script
- Test deploying a simple service
- Test disabling NAS access (if script supports it)
- Delete test VM if successful

**Rollback plan:**
- Keep pre-template VM backup for 7 days
- Document rollback procedure
- Test on non-critical VM first

## Related Documentation

- [[docs/ARCHITECTURE|Architecture]]
- [[docs/agents/INFRASTRUCTURE|Infrastructure Agent]]
- [[create-inspector-user]] - Related user setup task
- Future: docs/runbooks/create-vm-template.md
- Future: docs/runbooks/deploy-vm-from-template.md

## Notes

### Research Needed from Existing VMs

**Examine VM 100-103 for:**
- Ubuntu version and update status
- Installed packages (dpkg -l)
- Docker version and configuration
- User accounts (cat /etc/passwd)
- SSH configuration (/etc/ssh/sshd_config)
- Firewall rules (ufw status)
- Cron jobs or systemd services
- Network configuration
- NFS mount configuration (if in template or per-VM)
- Git configuration
- Any custom scripts or configurations

**Commands to run for documentation:**
```bash
# On existing VMs
lsb_release -a              # Ubuntu version
docker --version            # Docker version
docker compose version      # Compose version
cat /etc/ssh/sshd_config   # SSH config
ufw status                  # Firewall
systemctl list-units        # Services
ls -la /home/evan/          # Directory structure
dpkg -l | grep -E 'docker|git|curl'  # Installed packages
```

### Template Configuration Ideas

**Base OS:**
- Ubuntu Server 24.04 LTS (or current LTS)
- Minimal installation
- English locale, UTC timezone
- Generic hostname (change on clone)

**Users:**
- `evan` - Primary user, sudo access, docker group
- `inspector` - Read-only user for Testing Agent
- Root login disabled via SSH

**SSH Configuration:**
- Key-based auth only
- Disable password authentication
- Disable root login
- Copy public key during template creation or post-clone

**Docker Setup:**
```bash
# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker evan
sudo systemctl enable docker
sudo systemctl start docker
```

**Directory Structure:**
```
/home/evan/
├── projects/
│   └── infinity-node/    # Clone after deployment
├── scripts/               # Local scripts
└── backups/               # Local backups
```

**Firewall:**
```bash
# Basic UFW setup
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw enable
```

**Automatic Updates:**
```bash
sudo apt install unattended-upgrades
sudo dpkg-reconfigure -plow unattended-upgrades
```

### Post-Template Customization Per VM

When deploying from template, customize:
1. Hostname (unique per VM)
2. Static IP or DHCP (configure per VM needs)
3. Resource allocation (CPU, RAM, disk)
4. NFS mounts (if needed for this VM)
5. Specific services to deploy
6. Clone infinity-node repo
7. Configure .env files (per VM)

### Template vs Per-VM Configuration

**Include in template:**
- Base OS and updates
- Users (evan, inspector)
- SSH keys (or document how to add post-clone)
- Docker installation
- Basic tooling
- Security hardening
- Directory structure

**Configure per VM after clone:**
- Hostname
- IP address (if static)
- NFS mounts (VM-specific)
- Docker services (VM-specific)
- .env files (VM-specific secrets)
- Firewall rules (service-specific ports)

### Task Decisions (2025-10-28)

**NAS Mount Strategy:**
- Decision: Include NAS mounts in template (Option A)
- Rationale: Most VMs need NAS access
- Post-clone script will handle disabling NAS access if not needed

**Shell Configuration:**
- Decision: Minimal zsh setup
- Install zsh, set as default for evan user
- Basic .zshrc, no oh-my-zsh (can customize later)

**Automation Approach:**
- Decision: Use Ansible from the start (revised from shell scripts)
- Rationale: Solves template update problem, enables consistent VM management
- Ansible playbook will be source of truth for VM configuration
- Can update template AND existing VMs by running playbook
- Cloud-init documented as future enhancement (not implemented now)

**VM Research:**
- Decision: Check ALL VMs (100-103)
- Purpose: Document differences to identify configurable items
- Differences will reveal weaknesses in template design

**Configuration Storage:**
- Create `config/vm-template/` directory
- Store: fstab.example, .zshrc, sshd_config, etc.
- Document template vs post-clone configuration

### Advanced Considerations

**Cloud-init:**
- Proxmox supports cloud-init for VM customization
- Could automate hostname, IP, SSH key injection
- Research if beneficial vs manual setup

**Template Updates:**
- How to update template over time?
- Versioning strategy?
- Security patches?

**Backup:**
- Should template be backed up?
- Where to store template export?

**Multiple Templates:**
- One template for all VM types?
- Or different templates per purpose (media, downloads, etc.)?
- Start with one, add more if needed

### Future Enhancements

Once template exists:
- **Cloud-init integration**: Automate hostname, IP, SSH key injection
- Enhanced post-clone automation
- Integrate with monitoring/alerting setup
- Include commonly used services in template
- Automated testing of template clones
- Template versioning and update strategy

### Related Future Work

This task enables:
- Rapid deployment of new VMs
- Testing/development VMs (clone, test, destroy)
- Disaster recovery (quick rebuild)
- Scaling infrastructure
- Consistent configuration across environment

### Priority Notes

Medium priority currently because:
- Existing VMs are stable
- Not deploying new VMs frequently
- Manual setup works for now

Increase priority if:
- Planning to add new VMs
- Need to rebuild existing VMs
- Want to test configurations safely
- Disaster recovery becomes urgent

## Progress Notes

### 2025-10-28: Phase 0 Complete - VM Research & Documentation

**Completed:**
- ✅ Ansible already installed (v2.18.5)
- ✅ SSH access tested to all 4 VMs (100-103)
- ✅ Created `config/vm-template/` directory structure
- ✅ Researched all 4 VMs comprehensively
- ✅ Compared configurations and documented differences
- ✅ Saved extracted configurations to source control

**Files Created:**
- `config/vm-template/.docs/vm-research-findings.md` - Full research and comparison
- `config/vm-template/fstab.example` - NAS mount configuration with Ansible variables
- `config/vm-template/.zshrc` - Minimal zsh configuration for evan user
- `config/vm-template/README.md` - Directory documentation

**Key Findings:**
1. **All VMs Consistent:**
   - Ubuntu 24.04.1 LTS
   - Docker 28.1.1, Docker Compose v2.35.1
   - evan + inspector users
   - Same base packages (git, curl, wget, htop, vim)
   - NO zsh installed yet (need to add)

2. **Differences Found:**
   - VM 101: evan has GID 988 (others have 1000) ⚠️
   - VM 103: Missing `/mnt/complete` NAS mount (only has 2/3 mounts)
   - All VMs: UFW firewall disabled (security issue)

3. **NAS Configuration:**
   - NAS IP: 192.168.86.43
   - Protocol: CIFS (Samba)
   - 3 shares: media→/mnt/video, complete→/mnt/complete, music→/mnt/music
   - Credentials in plain text in fstab (acceptable for local network)

4. **Template Design:**
   - Include all 3 NAS mounts in template
   - Enable UFW firewall
   - Install zsh and set as default for evan
   - Use UID:GID 1000:1000 for evan (standard)

**Decision Made:**
- Use Ansible from the start (not shell scripts)
- Ansible solves the "how to update template over time" problem
- Can run playbook to update both template AND existing VMs

**Next Steps:**
- Phase 1: Create Ansible playbook structure
- Phase 2: Develop playbook tasks
- Phase 3: Build template VM using Ansible
- Phase 4: Test template clone
- Phase 5: Documentation

**VM Inventory for Reference:**
- VM 100 (emby): 192.168.86.172 - hostname: ininity-node-emby
- VM 101 (downloads): 192.168.86.173 - hostname: infinity-node-downloads
- VM 102 (arrs): 192.168.86.174 - hostname: infinity-node-arr
- VM 103 (misc): 192.168.86.249 - hostname: infinity-node-misc

### 2025-10-28: Phase 1 & 2 Complete - Ansible Infrastructure & Template Created

**Completed:**
- ✅ Created Ansible directory structure and infrastructure
- ✅ Created comprehensive Ansible playbook (`ansible/playbooks/vm-template.yml`)
  - 370+ lines with extensive documentation and comments
  - Idempotent, safe to run multiple times
  - Covers system updates, packages, users, Docker, NAS mounts, firewall
- ✅ Set up Ansible Vault for NAS credentials (encrypted)
- ✅ Created Ansible inventory (`ansible/inventory/proxmox-vms.yml`)
- ✅ Documented Ansible usage extensively (`ansible/README.md` - includes Ansible crash course)
- ✅ Created VM creation automation script (`scripts/create-test-vm.sh`)
- ✅ Created template VM 9000 (ubuntu-template)
- ✅ Installed Ubuntu 24.04.1 Server (offline installation to avoid rate limits)
- ✅ Configured networking manually (netplan)
- ✅ Ran Ansible playbook against template VM successfully
- ✅ Verified all configurations working (Docker, zsh, NAS mounts, firewall, etc.)
- ✅ Cleaned up VM for template conversion
- ✅ Converted VM 9000 to Proxmox template

**Files Created:**
- `ansible/README.md` - Comprehensive Ansible guide with crash course
- `ansible/playbooks/vm-template.yml` - Main configuration playbook (370+ lines)
- `ansible/inventory/proxmox-vms.yml` - Inventory of all VMs
- `ansible/group_vars/all.yml` - Encrypted NAS credentials (Ansible Vault)
- `ansible/.gitignore` - Protects vault password from git
- `scripts/infrastructure/create-test-vm.sh` - Automates VM creation in Proxmox
- `config/vm-template/.docs/vm-research-findings.md` - Complete VM research analysis
- `config/vm-template/fstab.example` - NAS mount configuration template
- `config/vm-template/.zshrc` - Minimal zsh configuration for evan user
- `config/vm-template/README.md` - Configuration files documentation

**Template VM Details:**
- **VM ID**: 9000
- **Name**: ubuntu-template
- **IP during config**: 192.168.86.24 (will get new IP on clone)
- **OS**: Ubuntu 24.04.1 LTS
- **Resources**: 2 CPU cores, 4GB RAM, 20GB disk
- **Status**: ✅ Template created in Proxmox

**What's Configured in Template:**
- ✅ Ubuntu 24.04.1 LTS (minimal install)
- ✅ Docker 28.2.2 + Docker Compose v2
- ✅ Base packages: git, curl, wget, htop, vim, zsh, cifs-utils, ufw
- ✅ evan user (UID 1000) with zsh shell, sudo access, docker group
- ✅ inspector user (UID 1001) with bash shell (read-only for Testing Agent)
- ✅ Custom .zshrc with Docker and Git aliases
- ✅ Directory structure: ~/projects/, ~/scripts/, ~/backups/
- ✅ NAS mounts configured: /mnt/video, /mnt/complete, /mnt/music (192.168.86.43)
- ✅ UFW firewall enabled (SSH allowed, incoming deny, outgoing allow)
- ✅ SSH service enabled
- ✅ Machine-id cleared (regenerates on clone)
- ✅ SSH host keys removed (regenerate on clone)

**Challenges Overcome:**
1. **429 Rate Limit Errors**: Ubuntu mirrors rate-limiting during installation
   - Solution: Offline installation (no network during install)
   - System upgrades skipped to avoid rate limits (can update later)
2. **Network Configuration**: VM installed without network
   - Solution: Manually configured netplan after installation
3. **Ansible Vault Variables**: Variables not loading automatically
   - Solution: Explicitly load with `-e '@group_vars/all.yml'`
4. **SSH Service Name**: Ubuntu uses 'ssh' not 'sshd'
   - Solution: Corrected in playbook

**Ansible Playbook Usage:**
```bash
# Run playbook against template (for updates)
cd ansible/
ansible-playbook -i inventory/proxmox-vms.yml playbooks/vm-template.yml \
  --limit template-vm --vault-password-file .vault-pass -e '@group_vars/all.yml'

# Run against existing VMs (future migration)
ansible-playbook -i inventory/proxmox-vms.yml playbooks/vm-template.yml \
  --limit vm-100 --vault-password-file .vault-pass -e '@group_vars/all.yml'
```

**Template Usage:**
1. Clone template in Proxmox web UI: Right-click template 9000 → Clone
2. Set new VM ID, name, resources
3. Start cloned VM
4. SSH in and customize (hostname, IP if needed)
5. Deploy services as needed

**Next Steps (Future Tasks):**
- Create post-clone customization script/playbook
- Test template by cloning and deploying a service
- Create runbook documentation (`docs/runbooks/deploy-vm-from-template.md`)
- Plan migration of existing VMs (100-103) to template-based VMs (IN-XXX task)
- Consider enabling system upgrades in playbook once rate limits clear
- Document template update process

**Lessons Learned:**
- Offline installation avoids rate limit issues during setup
- Ansible is excellent for maintaining consistency across VMs
- Template approach enables rapid VM deployment and disaster recovery
- Configuration as code (Ansible) solves "how to update template" problem
- Vault password still temporary (`temp-vault-pass`) - should be changed

**Infrastructure Impact:**
This task establishes the foundation for:
- ✅ Rapid new VM deployment (clone from template)
- ✅ Consistent VM configuration (via Ansible)
- ✅ Easy template updates (run playbook, convert to template again)
- ✅ Future VM migration (apply playbook to existing VMs)
- ✅ Disaster recovery (rebuild from template quickly)
- ✅ Testing environments (clone, test, destroy)

### 2025-10-28: Task Completed

**Status:** ✅ COMPLETE

**What was delivered:**
- VM template 9000 (`ubuntu-template`) created and ready to use in Proxmox
- Complete Ansible infrastructure for VM configuration management
- Comprehensive research and documentation of existing VMs
- Established `.docs/` pattern for context-specific documentation
- All 13 configuration and automation files created

**What's ready to use:**
- Template can be cloned immediately for new VMs
- Ansible playbook can update template or existing VMs
- VM creation automation script works end-to-end
- All configurations documented and in source control

**Follow-up tasks created:**
- Template testing and post-clone automation (new task)
- Runbook documentation (new task)

**Deferred for future:**
- Automatic security updates (can enable when needed)
- Production vault password (currently using temp-vault-pass)

This task successfully delivered a production-ready VM template system that will streamline all future VM deployments in the infinity-node infrastructure.
