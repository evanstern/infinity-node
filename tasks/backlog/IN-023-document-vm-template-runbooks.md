---
type: task
task-id: IN-023
status: pending
priority: 3
category: documentation
agent: documentation
created: 2025-10-28
updated: 2025-10-28
tags:
  - task
  - documentation
  - infrastructure
  - proxmox
  - runbook
---

# Task: IN-023 - Document VM Template Runbooks

## Description

Create comprehensive runbook documentation for the VM template system, including template creation, updates, and VM deployment workflows.

These runbooks will serve as the definitive guide for anyone (including future you) working with the VM template infrastructure.

## Context

IN-010 created a complete VM template system with:
- Proxmox VM template (ubuntu-template, VM 9000)
- Ansible playbook for configuration
- VM creation automation scripts
- Comprehensive configuration files

However, the workflows are currently documented in task notes rather than dedicated runbooks. This task creates formal runbooks that will be the go-to reference for template operations.

## Parent Task

- [[IN-010-create-vm-template]] - VM template creation (completed)
- [[IN-022-test-vm-template-and-post-clone-automation]] - Template testing (optional dependency)

## Acceptance Criteria

### Runbook: Create VM Template
- [ ] Create `docs/runbooks/create-vm-template.md`
- [ ] Document prerequisites (Proxmox access, Ubuntu ISO, etc.)
- [ ] Step-by-step template creation process
- [ ] Include Ansible playbook usage
- [ ] Document template cleanup before conversion
- [ ] Include troubleshooting section
- [ ] Add examples and expected output
- [ ] Reference all relevant files and scripts

### Runbook: Update VM Template
- [ ] Create `docs/runbooks/update-vm-template.md`
- [ ] Document when/why to update template
- [ ] Process for applying updates to template
- [ ] How to test template updates
- [ ] Converting updated VM back to template
- [ ] Version tracking considerations
- [ ] Rollback procedures if updates fail

### Runbook: Deploy VM from Template
- [ ] Create `docs/runbooks/deploy-vm-from-template.md`
- [ ] Cloning process in Proxmox
- [ ] Post-clone customization steps
- [ ] Network configuration (DHCP vs static)
- [ ] Service deployment examples
- [ ] Verification checklist
- [ ] Common issues and solutions
- [ ] Reference post-clone automation script (from IN-022)

### Architecture Documentation
- [ ] Update `docs/ARCHITECTURE.md` with VM template section
- [ ] Explain template system design
- [ ] Document Ansible infrastructure
- [ ] Explain `.docs/` pattern establishment
- [ ] Include template in infrastructure diagrams
- [ ] Document relationship to existing VMs

### Cross-References
- [ ] Link runbooks from relevant task files
- [ ] Update config/vm-template/README.md with runbook links
- [ ] Update ansible/README.md with runbook references
- [ ] Update scripts/README.md with runbook references
- [ ] Ensure all wiki-links work in Obsidian

## Dependencies

- Completed VM template (IN-010) ✅
- Completed template testing (IN-022) - preferred but not required

## Testing Plan

[[docs/agents/DOCUMENTATION|Documentation Agent]] should validate:
- Runbooks are clear and complete
- Steps can be followed without prior knowledge
- All commands include examples
- Troubleshooting sections cover common issues
- Cross-references are accurate
- Markdown renders correctly

**Validation Process:**
1. Review runbooks for completeness
2. Check that prerequisites are documented
3. Verify commands are accurate
4. Ensure examples include expected output
5. Test wiki-links in Obsidian
6. Check consistency with other documentation

## Related Documentation

- [[IN-010-create-vm-template]] - Parent task
- [[IN-022-test-vm-template-and-post-clone-automation]] - Testing task
- [[docs/ARCHITECTURE|Architecture]]
- [[docs/DECISIONS|Decisions]]
- `ansible/README.md` - Ansible guide
- `config/vm-template/README.md` - Configuration files

## Notes

### Runbook Structure Template

Each runbook should follow this structure:

```markdown
---
type: runbook
category: infrastructure
tags: [proxmox, vm, template]
---

# Runbook: [Title]

## Overview
Brief description of what this runbook covers and when to use it.

## Prerequisites
- List of requirements before starting
- Access needed
- Tools/software required

## Process
Step-by-step instructions with commands and examples.

### Step 1: [Name]
Description...
```bash
# Commands with explanations
```

Expected output...

### Step 2: [Name]
...

## Verification
How to verify the process succeeded.

## Troubleshooting
Common issues and their solutions.

## Related
Links to related runbooks and documentation.
```

### Content Sources

Information for runbooks can be found in:
- `tasks/completed/IN-010-create-vm-template.md` - Detailed process notes
- `ansible/README.md` - Ansible usage examples
- `ansible/playbooks/vm-template.yml` - Playbook comments
- `config/vm-template/.docs/vm-research-findings.md` - VM research
- `scripts/infrastructure/create-test-vm.sh` - VM creation automation

### Key Topics to Cover

**Create VM Template:**
- Manual vs automated VM creation
- Ubuntu installation (offline to avoid rate limits)
- Network configuration post-install
- Running Ansible playbook
- Template cleanup process
- Converting to Proxmox template

**Update VM Template:**
- When updates are needed (security patches, new tools, etc.)
- Cloning template to regular VM for updates
- Applying Ansible playbook to update
- Testing updated configuration
- Re-converting to template
- Versioning strategy

**Deploy from Template:**
- Cloning in Proxmox web UI
- Boot and SSH access
- Running customization script
- Network setup (DHCP vs static IP)
- Deploying first service
- Verification steps

### Architecture Documentation

Should include:
- Overview of template system
- Diagram showing template → clone → customize → deploy flow
- Ansible infrastructure explanation
- File organization (ansible/, config/, scripts/)
- How template fits with existing VMs
- Future: migration plan for existing VMs

## Priority Notes

Priority 3 (Medium) because:
- Template is usable without formal runbooks
- Current documentation in task notes is sufficient for now
- Not blocking active development

Increase priority if:
- New team members need to use template
- You're about to deploy multiple VMs
- Six months have passed (you'll forget the process)
- Planning to migrate existing VMs

## Future Enhancements

- Video walkthrough of runbook procedures
- Automated testing of runbook commands
- Interactive decision trees for troubleshooting
- Runbook versioning alongside template versions
- Integration with monitoring/alerting docs
