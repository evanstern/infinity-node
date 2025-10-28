---
type: task
task-id: IN-022
status: pending
priority: 3
category: infrastructure
agent: infrastructure
created: 2025-10-28
updated: 2025-10-28
tags:
  - task
  - infrastructure
  - proxmox
  - template
  - automation
  - testing
---

# Task: IN-022 - Test VM Template and Create Post-Clone Automation

## Description

Test the VM template created in IN-010 by cloning it to a new VM, and create automation scripts to handle post-clone customization (hostname, IP configuration, optional NAS mount disabling).

This task validates that the template works as expected and provides the final piece of automation needed for seamless VM deployment.

## Context

IN-010 created a production-ready VM template (VM 9000, `ubuntu-template`), but:
- It hasn't been tested by actually cloning and deploying
- There's no automation for post-clone customization tasks
- We need to verify all configurations carry over correctly

Testing the template will reveal:
- Whether cloning works smoothly
- What manual steps are needed post-clone
- Which customizations should be automated
- Any template improvements needed

## Parent Task

- [[IN-010-create-vm-template]] - VM template creation (completed)

## Acceptance Criteria

### Template Testing
- [ ] Clone template to new test VM
- [ ] Verify VM boots successfully
- [ ] Test SSH access with evan user
- [ ] Verify Docker is installed and functional
- [ ] Verify zsh is default shell for evan
- [ ] Test NAS mounts are configured and working
- [ ] Verify UFW firewall is enabled
- [ ] Check inspector user exists and works
- [ ] Document any issues or missing configurations
- [ ] Delete test VM after successful validation

### Post-Clone Automation Script
- [ ] Create `scripts/infrastructure/customize-vm-clone.sh`
- [ ] Script handles hostname customization
- [ ] Script handles static IP configuration (optional)
- [ ] Script can disable specific NAS mounts (optional)
- [ ] Script regenerates SSH host keys if needed
- [ ] Script updates machine-id if needed
- [ ] Include comprehensive help/usage documentation
- [ ] Test script on cloned VM
- [ ] Update scripts/README.md with script documentation

### Optional Ansible Approach
- [ ] Consider if Ansible playbook would be better than shell script
- [ ] If Ansible: Create playbook for post-clone customization
- [ ] If Ansible: Document usage in ansible/README.md

### Documentation
- [ ] Document actual cloning process (what works, what doesn't)
- [ ] Document manual steps still required
- [ ] Update template documentation with lessons learned
- [ ] Add troubleshooting section for common issues

## Dependencies

- Completed VM template (IN-010) ✅
- Access to Proxmox host
- Available VM ID for test VM

## Testing Plan

[[docs/agents/TESTING|Testing Agent]] should validate:
- All template configurations present in cloned VM
- Customization script works correctly
- No manual intervention needed after script runs
- Network configuration works as expected
- Services can be deployed on cloned VM

**Test Process:**
1. Clone template-vm (9000) to test VM (e.g., VM 901)
2. Boot cloned VM
3. SSH to cloned VM
4. Run comprehensive validation checks
5. Run customization script with various options
6. Verify customizations applied correctly
7. Deploy a simple docker service to verify functionality
8. Document any issues or improvements needed
9. Delete test VM

## Related Documentation

- [[IN-010-create-vm-template]] - Parent task
- [[docs/ARCHITECTURE|Architecture]]
- `ansible/README.md` - Ansible usage
- `config/vm-template/README.md` - Template configuration
- Future: `docs/runbooks/deploy-vm-from-template.md` (IN-023)

## Notes

### Questions to Answer

- Does Proxmox cloud-init work with our template?
- Do SSH host keys regenerate automatically on clone?
- Does machine-id regenerate on clone?
- Are NAS mounts immediately accessible or need manual mount?
- What's the best approach: shell script or Ansible playbook?

### Customization Options Needed

**Required customizations:**
- Hostname (must be unique per VM)

**Optional customizations:**
- Static IP address (or keep DHCP)
- Disable specific NAS mounts
- VM-specific firewall rules
- Resource allocation (handled in Proxmox, not script)

### Script vs Ansible Decision

**Shell Script Pros:**
- Simpler for one-time post-clone setup
- No dependencies beyond bash
- Easier to run manually
- Good for quick customizations

**Ansible Pros:**
- Consistent with template creation approach
- Idempotent (can run multiple times)
- Better structured and maintainable
- Can be integrated into larger automation

**Decision:** Try shell script first. If it becomes complex or we need idempotency, switch to Ansible.

## Priority Notes

Priority 3 (Medium) because:
- Template exists and can be cloned manually
- Manual post-clone steps documented in IN-010
- Not blocking other work

Increase priority if:
- Planning to deploy multiple new VMs soon
- Need to test disaster recovery procedures
- Want to migrate existing VMs to template-based approach

## Future Enhancements

Once this task is complete:
- Integration with Proxmox API for automated cloning
- Cloud-init integration for automatic customization
- Pre-configured VM profiles (media, downloads, arr, etc.)
- Automated testing of template after updates
- CI/CD integration for infrastructure deployment
