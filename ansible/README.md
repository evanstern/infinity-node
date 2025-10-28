# Ansible Configuration for Infinity Node

This directory contains Ansible playbooks and configuration for managing Proxmox VMs.

## 📚 Ansible Crash Course

### What is Ansible?

Ansible is an **automation tool** that lets you:
- Define infrastructure as code
- Apply configurations consistently across multiple systems
- Update many systems at once
- Ensure systems match a desired state (idempotent)

**Key Concepts:**

1. **Playbook**: A YAML file that describes what you want to happen
   - Think of it as a "recipe" for configuring systems
   - Example: `playbooks/vm-template.yml`

2. **Inventory**: A list of systems (hosts) to manage
   - Groups hosts together (e.g., "proxmox-vms")
   - Can have per-host or per-group variables
   - Example: `inventory/proxmox-vms.yml`

3. **Tasks**: Individual steps in a playbook
   - "Install Docker", "Create user", "Copy file", etc.
   - Ansible has built-in modules for common tasks

4. **Variables**: Values you can reuse and customize
   - NAS IP, usernames, passwords, etc.
   - Stored in `group_vars/` or `host_vars/`
   - Can be encrypted with Ansible Vault

5. **Idempotent**: Running multiple times = same result
   - Ansible checks current state before making changes
   - Safe to run repeatedly
   - "Ensure this user exists" vs "Create this user"

### Why Ansible for This Project?

1. **Template Management**: Playbook defines VM configuration as code
2. **Updates**: Run playbook to update template AND existing VMs
3. **Consistency**: All VMs can be brought to the same state
4. **Documentation**: Playbook IS the documentation
5. **No Agents**: Uses SSH only (nothing to install on VMs)

## 📁 Directory Structure

```
ansible/
├── README.md              # This file - documentation and guide
├── ansible.cfg            # Ansible configuration (optional)
├── playbooks/             # Playbooks (automation recipes)
│   ├── vm-template.yml    # Main playbook for VM template configuration
│   └── post-clone.yml     # Post-clone VM customization (future)
├── inventory/             # Host definitions
│   └── proxmox-vms.yml    # Inventory of all Proxmox VMs
├── group_vars/            # Variables for groups of hosts
│   └── all.yml            # Variables for all hosts
├── host_vars/             # Variables for specific hosts
│   └── (per-host files)   # Host-specific overrides
└── roles/                 # Reusable Ansible roles (future)
    └── (future roles)     # Modular automation components
```

## 🔧 Usage

### Prerequisites

1. **Ansible installed** (already done ✓)
   ```bash
   ansible --version  # Should show 2.18.5+
   ```

2. **SSH access to VMs** (already configured ✓)
   - Can SSH as evan user with your key
   - No password required

### Running Playbooks

**Basic syntax:**
```bash
ansible-playbook -i <inventory> <playbook>
```

**Examples:**

```bash
# Run vm-template playbook against all VMs in inventory
ansible-playbook -i inventory/proxmox-vms.yml playbooks/vm-template.yml

# Run against a specific host
ansible-playbook -i inventory/proxmox-vms.yml playbooks/vm-template.yml --limit vm-100

# Check what would change (dry-run)
ansible-playbook -i inventory/proxmox-vms.yml playbooks/vm-template.yml --check

# See detailed output
ansible-playbook -i inventory/proxmox-vms.yml playbooks/vm-template.yml -v

# Extra verbose (for debugging)
ansible-playbook -i inventory/proxmox-vms.yml playbooks/vm-template.yml -vv
```

### Common Workflows

**1. Build New Template VM**
```bash
# Create fresh Ubuntu VM in Proxmox (manual step, VM ID 9000)
# Add to inventory as 'template-vm'
# Run playbook against it
ansible-playbook -i inventory/proxmox-vms.yml playbooks/vm-template.yml --limit template-vm

# Convert to template in Proxmox (manual step)
# On Proxmox: qm template 9000
```

**2. Update Existing VM**
```bash
# Update a single VM to match template configuration
ansible-playbook -i inventory/proxmox-vms.yml playbooks/vm-template.yml --limit vm-102
```

**3. Update All VMs**
```bash
# Update all VMs in inventory
ansible-playbook -i inventory/proxmox-vms.yml playbooks/vm-template.yml

# Update specific group
ansible-playbook -i inventory/proxmox-vms.yml playbooks/vm-template.yml --limit production
```

**4. Check What Would Change (Dry Run)**
```bash
# See what would change without actually changing it
ansible-playbook -i inventory/proxmox-vms.yml playbooks/vm-template.yml --check --diff
```

## 🔐 Secrets Management

### Ansible Vault

Sensitive data (like NAS credentials) is encrypted using **Ansible Vault**.

**Encrypted file:** `group_vars/all.yml` (contains `vault_nas_username` and `vault_nas_password`)

**Current vault status:**
- ✅ Vault file exists: `group_vars/all.yml` (encrypted)
- Contains: NAS credentials (username and password)
- ⚠️ Using temporary vault password - change before committing!

**Working with vault file:**
```bash
# View encrypted contents
ansible-vault view group_vars/all.yml

# Edit existing encrypted file
ansible-vault edit group_vars/all.yml

# Change vault password (recommended!)
ansible-vault rekey group_vars/all.yml
# Prompts for old password, then new password

# Create new encrypted file (for future secrets)
ansible-vault create group_vars/new-file.yml
```

**Using vaulted playbooks:**
```bash
# Run playbook with vault password prompt
ansible-playbook -i inventory/proxmox-vms.yml playbooks/vm-template.yml --ask-vault-pass

# Or use a password file (store vault password)
echo "your-vault-password" > ~/.ansible-vault-pass
chmod 600 ~/.ansible-vault-pass
ansible-playbook -i inventory/proxmox-vms.yml playbooks/vm-template.yml --vault-password-file ~/.ansible-vault-pass
```

**Best Practice:**
- Don't commit vault password to git
- Add `.ansible-vault-pass` to `.gitignore`
- Store vault password in your password manager (Vaultwarden)

### Future: Bitwarden/Vaultwarden Integration

**Current approach:** Ansible Vault (simpler)

**Future enhancement:** Integrate with Vaultwarden using Bitwarden CLI
- Store NAS credentials in Vaultwarden
- Ansible fetches credentials at runtime
- More centralized secret management
- See: [Ansible Bitwarden Lookup Plugin](https://docs.ansible.com/ansible/latest/collections/community/general/bitwarden_lookup.html)

## 🎯 Playbook Explained: vm-template.yml

The main playbook (`playbooks/vm-template.yml`) defines the desired state of a VM.

**Structure:**
```yaml
---
- name: Configure VM Template              # Playbook name
  hosts: all                               # Which hosts to target
  become: yes                              # Run tasks with sudo

  vars:                                    # Variables
    nas_server: "192.168.86.43"

  tasks:                                   # List of tasks
    - name: Install packages               # Task name
      apt:                                 # Module to use
        name: [git, docker, zsh]           # Module parameters
        state: present                     # Desired state
```

**How Ansible Works:**
1. Connects to host via SSH
2. Checks current state ("Is git installed?")
3. If needed, makes changes ("Install git")
4. Reports what changed (changed/ok/failed)
5. Moves to next task

**Idempotency Example:**
```yaml
- name: Ensure evan user exists
  user:
    name: evan
    state: present
```
- First run: Creates evan user → **changed**
- Second run: User exists, does nothing → **ok**
- Always safe to run multiple times!

## 🧪 Testing Strategy

**Phase 1: Test on Fresh VM**
1. Create test VM (VM ID TBD, minimal resources)
2. Run playbook against test VM
3. Verify configuration
4. Delete test VM or convert to template

**Phase 2: Test Template Clone**
1. Clone template to new test VM
2. Run post-clone customization
3. Verify everything works
4. Delete test clone

**Phase 3: Production Use**
1. Use template for new VMs
2. Eventually: migrate existing VMs (IN-XXX task)

## 📖 Learn More

**Ansible Documentation:**
- [Getting Started Guide](https://docs.ansible.com/ansible/latest/getting_started/index.html)
- [Playbook Intro](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_intro.html)
- [Module Index](https://docs.ansible.com/ansible/latest/collections/index_module.html)

**Useful Modules for This Project:**
- `apt` - Package management
- `user` - User management
- `copy` - Copy files
- `template` - Copy files with variable substitution
- `mount` - Manage mount points (NAS)
- `ufw` - Firewall management
- `docker_*` - Docker management (community collection)

## 🚀 Next Steps

1. ✅ Directory structure created
2. Create inventory file (`inventory/proxmox-vms.yml`)
3. Set up vault file (`group_vars/all.yml`)
4. Write main playbook (`playbooks/vm-template.yml`)
5. Test on fresh VM
6. Build template
7. Document process

---

**Questions?** This is a learning tool - don't hesitate to ask about any Ansible concepts!
