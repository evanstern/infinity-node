# VM Template Configuration Files

This directory contains configuration files extracted from existing VMs and used to build the Proxmox VM template.

## Files

### `.docs/vm-research-findings.md`
Comprehensive research and comparison of all existing VMs (100-103). Documents:
- Current configurations
- Differences between VMs
- Security findings
- Template design decisions

**Use this as reference** when building or updating the template.

> **Note:** Following the `.docs/` pattern for context-specific documentation. This keeps research findings close to the configuration files they document.

### `fstab.example`
Example NAS mount configuration for `/etc/fstab`.
- Shows all NAS mounts used across VMs
- Credentials replaced with Ansible variables
- Includes notes on security and customization

**Used by:** Ansible playbook for NAS mount configuration

### `.zshrc`
Basic zsh configuration for the evan user.
- Minimal, functional setup
- Includes Docker and Git aliases
- History and completion configured
- Users can extend with `.zshrc.local`

**Deployed to:** `/home/evan/.zshrc` in template

## Template Configuration

The VM template is built using Ansible (see `ansible/playbooks/vm-template.yml`).

### What's in the Template:
- Ubuntu 24.04 LTS
- evan user (UID 1000) with zsh shell
- inspector user (UID 1001) with bash shell
- Docker + Docker Compose
- Base packages: git, curl, wget, htop, vim, zsh
- NAS mounts (3 shares to 192.168.1.80)
- UFW firewall (enabled with SSH allowed)
- Standard directory structure

### Post-Clone Customization:
- Hostname (unique per VM)
- IP address (static or DHCP)
- Disable specific NAS mounts if not needed
- VM-specific Docker services
- VM-specific firewall rules

## Credentials Management

**NAS Credentials:**
- Current approach: Plain text in /etc/fstab (local network only)
- Credentials stored in Ansible vault or variables
- Template uses Ansible variable substitution

**⚠️ Security Note:** Credentials are visible in fstab to users with SSH access. This is acceptable for a trusted local network but consider credential files or keyrings for enhanced security.

## Usage

### Building the Template
See: `ansible/playbooks/vm-template.yml` and `docs/runbooks/create-vm-template.md`

### Deploying from Template
See: `docs/runbooks/deploy-vm-from-template.md`

### Updating Existing VMs
Run Ansible playbook against existing VMs to apply configuration changes:
```bash
ansible-playbook -i ansible/inventory/proxmox-vms.yml ansible/playbooks/vm-template.yml --limit vm-100
```

## Related Documentation
- [[tasks/current/IN-010-create-vm-template|Task IN-010]]
- [[docs/ARCHITECTURE|Architecture]]
- `ansible/README.md` - Ansible usage guide
