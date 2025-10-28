---
type: documentation
tags:
  - decisions
  - adr
  - index
---

# Architectural Decision Records

This document serves as an index to all Architectural Decision Records (ADRs) for the infinity-node infrastructure. Each ADR is now maintained in its own file within `docs/adr/` for better organization and git history tracking.

## About ADRs

Architectural Decision Records (ADRs) document important decisions, their context, and consequences. They help:
- Understand why things are the way they are
- Avoid revisiting settled decisions
- Learn from past choices
- Onboard new collaborators
- Question and update decisions when context changes

## All ADRs

| # | Decision | Status | Date |
|---|----------|--------|------|
| [001](adr/001-use-proxmox-as-hypervisor.md) | Use Proxmox as Hypervisor | Accepted | 2025-10-24 |
| [002](adr/002-use-docker-for-service-containerization.md) | Use Docker for Service Containerization | Accepted | 2025-10-24 |
| [003](adr/003-use-portainer-for-container-management.md) | Use Portainer for Container Management | Accepted | 2025-10-24 |
| [004](adr/004-use-pangolin-for-external-access.md) | Use Pangolin for External Access | Accepted | 2025-10-24 |
| [005](adr/005-use-nfs-for-shared-storage.md) | Use NFS for Shared Storage | Accepted | 2025-10-24 |
| [006](adr/006-separate-vms-by-service-category.md) | Separate VMs by Service Category | Accepted | 2025-10-24 |
| [007](adr/007-dedicated-vm-with-vpn-for-downloads.md) | Dedicated VM with VPN for Downloads | Accepted | 2025-10-24 |
| [008](adr/008-use-git-for-configuration-management.md) | Use Git for Configuration Management | Accepted | 2025-10-24 |
| [009](adr/009-use-obsidian-markdown-for-documentation.md) | Use Obsidian + Markdown for Documentation | Accepted | 2025-10-24 |
| [010](adr/010-use-agent-system-for-claude-code-collaboration.md) | Use Agent System for Claude Code Collaboration | Accepted | 2025-10-24 |
| [011](adr/011-critical-services-list.md) | Critical Services List | Accepted | 2025-10-24 |
| [012](adr/012-script-based-operational-automation.md) | Script-Based Operational Automation | Accepted | 2025-10-26 |

## ADRs by Topic

### Infrastructure & Virtualization
- [[adr/001-use-proxmox-as-hypervisor|ADR-001: Use Proxmox as Hypervisor]]
- [[adr/005-use-nfs-for-shared-storage|ADR-005: Use NFS for Shared Storage]]
- [[adr/006-separate-vms-by-service-category|ADR-006: Separate VMs by Service Category]]

### Containerization & Services
- [[adr/002-use-docker-for-service-containerization|ADR-002: Use Docker for Service Containerization]]
- [[adr/003-use-portainer-for-container-management|ADR-003: Use Portainer for Container Management]]

### Networking & Security
- [[adr/004-use-pangolin-for-external-access|ADR-004: Use Pangolin for External Access]]
- [[adr/007-dedicated-vm-with-vpn-for-downloads|ADR-007: Dedicated VM with VPN for Downloads]]

### Development & Operations
- [[adr/008-use-git-for-configuration-management|ADR-008: Use Git for Configuration Management]]
- [[adr/009-use-obsidian-markdown-for-documentation|ADR-009: Use Obsidian + Markdown for Documentation]]
- [[adr/010-use-agent-system-for-claude-code-collaboration|ADR-010: Use Agent System for Claude Code Collaboration]]
- [[adr/011-critical-services-list|ADR-011: Critical Services List]]
- [[adr/012-script-based-operational-automation|ADR-012: Script-Based Operational Automation]]

## Decision Status Definitions

- **Proposed**: Decision suggested, not yet accepted
- **Accepted**: Decision made and implemented
- **Deprecated**: Decision superseded by new approach but kept for history
- **Superseded**: Replaced by specific newer decision (link to new ADR)

## ADR Template

Use the template in `.obsidian/templates/adr.md` or follow this format:

```markdown
---
type: adr
number: XXX
title: Decision Title
date: YYYY-MM-DD
status: accepted|proposed|deprecated|superseded
deciders:
  - Name
tags:
  - adr
  - relevant-topic
---

# ADR-XXX: Decision Title

**Date:** YYYY-MM-DD
**Status:** Accepted/Proposed/Deprecated/Superseded
**Deciders:** Names

## Context
What problem are we solving?

## Decision
What did we decide?

## Consequences

**Positive:**
- What becomes easier?

**Negative:**
- What becomes harder?

**Neutral:**
- What are the trade-offs?

## Alternatives Considered

1. **Alternative Name**
   - Why not chosen
```

## How to Add a New ADR

1. **Create new file** in `docs/adr/` directory
2. **Name format:** `NNN-lowercase-decision-title.md` (use kebab-case)
3. **Copy template** from `.obsidian/templates/adr.md`
4. **Number sequentially** (next available ADR number)
5. **Fill in all sections** completely with context and rationale
6. **Add frontmatter** with proper metadata (see template above)
7. **Update this index** - add row to table above
8. **Link from related docs** if applicable
9. **Commit to git** with descriptive message

## Future Decisions to Document

These decisions haven't been made yet but should be documented when addressed:

1. **Backup Strategy** - Frequency, retention, storage, testing (see [[tasks/backlog/IN-011-document-backup-strategy|IN-011]])
2. **Monitoring Solution** - Which tool(s), what to monitor, alerting (see [[tasks/backlog/IN-005-setup-monitoring-alerting|IN-005]])
3. **High Availability** - Whether to implement, which services, how
4. **Hardware Transcoding** - GPU passthrough for Emby, which GPU, setup (see [[tasks/backlog/IN-007-optimize-emby-transcoding|IN-007]])
5. **Centralized Logging** - Which solution, retention policy
6. **Update Strategy** - Automated vs manual, critical vs non-critical
7. **Disaster Recovery** - RTO/RPO definitions, procedures (see [[tasks/backlog/IN-008-test-disaster-recovery|IN-008]])

## Related Documentation

- [[CLAUDE|Claude Code Guide]] - Working with Claude Code
- [[ARCHITECTURE|Infrastructure Architecture]] - System architecture overview
- [[agents/README|Agent System]] - Agent roles and responsibilities
- `.obsidian/templates/adr.md` - ADR template file

---

**Note:** Individual ADR files are located in `docs/adr/` directory. This index should be updated whenever new decisions are made or existing decisions change status.
