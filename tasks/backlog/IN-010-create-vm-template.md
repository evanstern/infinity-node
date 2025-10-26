---
type: task
task-id: IN-010
status: pending
priority: 3
category: infrastructure
agent: infrastructure
created: 2025-10-24
updated: 2025-10-26
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

### Template Creation
- [ ] Research existing VMs (100-103) to document current setup
- [ ] Create Ubuntu Server VM in Proxmox for template base
- [ ] Configure base OS settings (timezone, hostname placeholder, etc.)
- [ ] Document template creation process

### User Configuration
- [ ] Create `evan` user with sudo privileges
- [ ] Configure passwordless sudo for `evan` (for automation)
- [ ] Set up SSH directory structure
- [ ] Copy SSH public key to `evan` user
- [ ] Disable root password login (SSH keys only)
- [ ] Configure `inspector` user (for Testing Agent)
- [ ] Document user setup in template

**Related scripts:**
- `scripts/setup-evan-nopasswd-sudo.sh` - Passwordless sudo
- `scripts/setup-inspector-user.sh` - Inspector user setup

### Security Hardening
- [ ] Disable root SSH login
- [ ] Configure SSH to use keys only (disable password auth)
- [ ] Set up basic firewall rules (ufw)
- [ ] Configure automatic security updates
- [ ] Set proper file permissions
- [ ] Document security configuration

### Base Tooling
- [ ] Install Docker and Docker Compose
- [ ] Install git
- [ ] Install essential tools (curl, wget, vim/nano, htop, etc.)
- [ ] Configure Docker to start on boot
- [ ] Add `evan` user to docker group
- [ ] Document tooling installation

### Directory Structure
- [ ] Create `/home/evan/projects/` directory
- [ ] Set up standard directory structure
- [ ] Configure proper ownership and permissions
- [ ] Document directory layout

### Network Configuration
- [ ] Configure network settings (DHCP or static - document both)
- [ ] Set up DNS resolution
- [ ] Document network setup

### Proxmox Template
- [ ] Convert configured VM to template
- [ ] Test cloning template to new VM
- [ ] Verify all settings carry over correctly
- [ ] Document template usage

### Documentation
- [ ] Create template creation runbook
- [ ] Create "deploy new VM from template" runbook
- [ ] Update [[docs/ARCHITECTURE|Architecture]] with template info
- [ ] Document customization steps needed per VM type

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
- Verify can run docker commands
- Verify inspector user has read-only access
- Test deploying a simple service
- Delete test VM if successful

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
- Create automation script for post-clone customization
- Integrate with monitoring/alerting setup
- Pre-configure for NFS mounts
- Include commonly used services in template
- Automated testing of template clones

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
