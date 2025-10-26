---
type: documentation
tags:
  - decisions
  - adr
---

# Architectural Decision Records

This document tracks significant architectural and technical decisions made for the infinity-node infrastructure.

## About ADRs

Architectural Decision Records (ADRs) document important decisions, their context, and consequences. They help:
- Understand why things are the way they are
- Avoid revisiting settled decisions
- Learn from past choices
- Onboard new collaborators
- Question and update decisions when context changes

## ADR Template

Use the template in `.obsidian/templates/adr.md` or follow this format:

```markdown
# ADR-XXX: Decision Title

**Date:** YYYY-MM-DD
**Status:** Proposed | Accepted | Deprecated | Superseded
**Deciders:** Names

## Context
What problem are we solving?

## Decision
What did we decide?

## Consequences
What becomes easier/harder?

## Alternatives Considered
What else did we consider?
```

---

## ADR-001: Use Proxmox as Hypervisor

**Date:** 2025-10-24 (retroactive documentation)
**Status:** Accepted
**Deciders:** Evan

### Context
Need a hypervisor for running multiple VMs on a single physical server. Requirements:
- Mature and stable
- Web-based management
- Good community support
- Support for various storage types
- Free/open source

### Decision
Use Proxmox VE as the hypervisor platform.

### Consequences

**Positive:**
- Excellent web UI for management
- Strong community and documentation
- Built-in backup capabilities
- Supports various storage backends (local, NFS, etc.)
- Free and open source
- Easy VM creation and management
- Built-in console access

**Negative:**
- Learning curve for Proxmox-specific concepts
- Some features only in paid "enterprise" version
- Updates can occasionally require attention

**Neutral:**
- Debian-based (familiar to some, not to others)
- Uses its own clustering approach

### Alternatives Considered

1. **ESXi (VMware)**
   - More enterprise-focused
   - Free version very limited
   - VMware's future uncertain after Broadcom acquisition

2. **Hyper-V**
   - Windows-based
   - Good integration with Windows ecosystem
   - Less familiar for Linux-focused workloads

3. **KVM/libvirt directly**
   - More flexible
   - No web UI without additional tools
   - More manual management

---

## ADR-002: Use Docker for Service Containerization

**Date:** 2025-10-24 (retroactive documentation)
**Status:** Accepted
**Deciders:** Evan

### Context
Need to run multiple services efficiently with:
- Isolation between services
- Easy updates and rollbacks
- Reproducible deployments
- Resource management
- Port management

### Decision
Use Docker with docker-compose for all services.

### Consequences

**Positive:**
- Huge ecosystem of pre-built images
- Easy to update services
- Isolation between services
- Reproducible deployments
- Good documentation and community
- docker-compose makes multi-container apps easy

**Negative:**
- Another layer of complexity
- Networking can be tricky
- Storage/volume management requires understanding
- Security requires attention (container escape risks)
- Resource overhead vs bare metal

**Neutral:**
- Requires learning Docker concepts
- Alternative to VMs for isolation

### Alternatives Considered

1. **Kubernetes**
   - Over-engineered for single-host setup
   - Much steeper learning curve
   - Better for multi-host clusters

2. **LXC Containers**
   - Proxmox has good LXC support
   - Less ecosystem than Docker
   - Different isolation model

3. **Bare metal services**
   - No isolation
   - Harder to manage dependencies
   - Harder to update/rollback
   - Port conflicts

---

## ADR-003: Use Portainer for Container Management

**Date:** 2025-10-24 (retroactive documentation)
**Status:** Accepted
**Deciders:** Evan

### Context
Need a web UI for managing Docker containers and stacks across multiple VMs. Requirements:
- Visual container management
- Stack deployment
- Log viewing
- Works on each VM independently

### Decision
Deploy Portainer CE on each VM for local container management.

### Consequences

**Positive:**
- Excellent web UI
- Easy stack deployment
- Log viewing and debugging
- Resource monitoring
- Template support
- Free version sufficient

**Negative:**
- Instance per VM (not centralized)
- Additional container on each VM
- Learning curve for Portainer-specific features

**Neutral:**
- Could use Portainer Agent + central server model
- Alternative to command-line docker management

### Alternatives Considered

1. **Portainer Business (centralized)**
   - Paid version
   - Central management of multiple environments
   - Overkill for home lab

2. **CLI only**
   - No UI overhead
   - Steeper learning curve
   - Harder to troubleshoot visually

3. **Other UIs** (Yacht, Cockpit, etc.)
   - Less mature
   - Smaller communities
   - Fewer features

---

## ADR-004: Use Pangolin for External Access

**Date:** 2025-10-24 (retroactive documentation)
**Status:** Accepted
**Deciders:** Evan

### Context
Need secure external access to services without:
- Opening ports on home router
- Exposing services directly to internet
- Complex VPN setup for each user
- Dynamic DNS management

### Decision
Use Pangolin (self-hosted) for tunnel-based external access.

### Consequences

**Positive:**
- No port forwarding required
- Identity-aware access control
- Self-hosted (control and privacy)
- Supports multiple services/sites
- TLS termination handled
- Works through restrictive firewalls

**Negative:**
- Requires external server (Digital Ocean)
- Additional cost for external server
- Another service to maintain
- Newt client on each VM that needs external access

**Neutral:**
- Similar to Cloudflare Tunnel but self-hosted
- Requires domain and DNS management

### Alternatives Considered

1. **Cloudflare Tunnel**
   - Easier setup
   - Less control
   - Privacy concerns (traffic through Cloudflare)
   - Vendor lock-in

2. **VPN (WireGuard/OpenVPN)**
   - More traditional approach
   - Each user needs VPN config
   - More complex for family members
   - Better for full network access

3. **Reverse Proxy + Port Forward**
   - Simpler architecture
   - Exposes home IP
   - Port forwarding complexity
   - Security concerns

4. **Tailscale**
   - Very easy to use
   - Service-dependent
   - Less control over infrastructure

---

## ADR-005: Use NFS for Shared Storage

**Date:** 2025-10-24 (retroactive documentation)
**Status:** Accepted
**Deciders:** Evan

### Context
Need shared storage accessible from:
- Proxmox (for VM disks)
- Multiple VMs (for media library)
- Services (for configs and data)

Synology NAS already available on network.

### Decision
Use NFS from Synology NAS for shared storage across infrastructure.

### Consequences

**Positive:**
- Centralized storage management
- Large capacity (57TB)
- Synology handles RAID/redundancy
- Easy to expand
- Accessible from all VMs
- NAS handles backups

**Negative:**
- Network latency vs local storage
- Single point of failure
- NFS performance lower than local disk
- Network dependency

**Neutral:**
- NFS vs SMB/CIFS (chose NFS for Linux VMs)
- Could use iSCSI for better performance

### Alternatives Considered

1. **Local storage only**
   - Better performance
   - No central management
   - Harder to backup
   - Limited by single host capacity

2. **Ceph/Distributed storage**
   - Over-engineered for single host
   - Requires multiple nodes
   - More complex

3. **SMB/CIFS**
   - Alternative network protocol
   - NFS generally better for Linux
   - More overhead

---

## ADR-006: Separate VMs by Service Category

**Date:** 2025-10-24 (retroactive documentation)
**Status:** Accepted
**Deciders:** Evan

### Context
Multiple services needed. Choices:
- All services on one VM
- One VM per service
- Group services logically

### Decision
Group services into VMs by category/purpose:
- VM 100: Media server (Emby)
- VM 101: Download clients with VPN
- VM 102: Media automation (*arr)
- VM 103: Supporting services

### Consequences

**Positive:**
- Logical grouping
- Resource allocation per category
- Isolation between categories
- Can restart/maintain VMs independently
- VPN only affects download VM
- Blast radius contained

**Negative:**
- More VMs to manage
- More resource overhead (4 OS instances)
- Network between VMs for communication
- SSH into correct VM needed

**Neutral:**
- Balance between isolation and complexity
- Could be more or less granular

### Alternatives Considered

1. **Single mega VM**
   - Simpler management
   - Single point of failure
   - Resource contention
   - VPN would affect everything

2. **One VM per service**
   - Maximum isolation
   - Too many VMs to manage
   - Excessive resource overhead

3. **Different grouping**
   - Many ways to group services
   - Current grouping works well

---

## ADR-007: Dedicated VM with VPN for Downloads

**Date:** 2025-10-24 (retroactive documentation)
**Status:** Accepted
**Deciders:** Evan

### Context
Download clients (torrents/usenet) should use VPN for:
- Privacy
- Avoiding ISP throttling
- Protecting home IP

Other services should NOT use VPN to:
- Avoid latency for streaming
- Allow direct access for management
- Prevent VPN failures from affecting everything

### Decision
Dedicated VM (101) for download clients with VPN container routing all traffic.

### Consequences

**Positive:**
- Download traffic protected by VPN
- Other services unaffected by VPN
- Kill switch prevents leaks
- Can troubleshoot VPN without affecting critical services
- VPN failure only affects downloads

**Negative:**
- Dedicated VM for relatively few services
- VPN adds latency to downloads
- More complex network setup

**Neutral:**
- Could use VPN at router level (affects everything)
- Could use split-tunnel VPN (more complex)

### Alternatives Considered

1. **VPN on router**
   - All traffic routed through VPN
   - Affects streaming and management
   - Single point of failure

2. **Per-container VPN**
   - Each download client manages own VPN
   - More complex
   - Redundant VPN connections

3. **No VPN**
   - Simpler
   - Privacy concerns
   - ISP may throttle

---

## ADR-008: Use Git for Configuration Management

**Date:** 2025-10-24 (retroactive documentation)
**Status:** Accepted
**Deciders:** Evan

### Context
Need version control for:
- Docker compose files
- Documentation
- Scripts
- Configuration (non-secret)

### Decision
Use Git (GitHub) for all infrastructure configurations.

### Consequences

**Positive:**
- Version history for all changes
- Can review changes over time
- Easy to rollback
- Collaborate with others (Claude Code)
- Backup of configurations
- Can track why changes were made

**Negative:**
- Must be careful about secrets
- Requires git discipline
- Another system to learn/use

**Neutral:**
- Could use different VCS
- Git is standard for this use case

### Alternatives Considered

1. **No version control**
   - Simpler
   - No history
   - Hard to track changes
   - No backup

2. **Different VCS** (SVN, Mercurial)
   - Git is standard
   - Better ecosystem

### Validation

**2025-10-26:** Decision validated through completion of [[tasks/completed/IN-001-import-existing-docker-configs|IN-001]]. Successfully imported 24 service stacks with docker-compose configurations, documentation, and .env.example templates. All configurations now version controlled in Git with comprehensive READMEs. Strategy proven effective for infrastructure-as-code approach.

---

## ADR-009: Use Obsidian + Markdown for Documentation

**Date:** 2025-10-24
**Status:** Accepted
**Deciders:** Evan + Claude Code

### Context
Need documentation system that:
- Works with Claude Code effectively
- Handles task management (MDTD)
- Visualizes relationships
- Stored in git
- No lock-in

### Decision
Use Obsidian as optional interface for Markdown-based documentation with:
- Wiki-links for cross-referencing
- YAML frontmatter for metadata
- Dataview plugin for queries
- Works without Obsidian (just markdown)

### Consequences

**Positive:**
- Powerful graph view of relationships
- Dataview queries for task management
- Wiki-links make navigation easy
- Claude Code can read/write easily
- No lock-in (just markdown)
- Works offline
- Git-friendly

**Negative:**
- Obsidian-specific features not portable
- Requires plugin setup
- Learning curve for Obsidian

**Neutral:**
- Could use other tools on same markdown
- Obsidian is optional, not required

### Alternatives Considered

1. **Plain Markdown**
   - Works everywhere
   - No visualization
   - Manual link management

2. **Wiki (Docusaurus, GitBook, etc.)**
   - Better for publishing
   - More complex setup
   - Less flexible for notes

3. **Notion/similar**
   - Not markdown-based
   - Vendor lock-in
   - Not Claude Code friendly

---

## ADR-010: Use Agent System for Claude Code Collaboration

**Date:** 2025-10-24
**Status:** Accepted
**Deciders:** Evan + Claude Code

### Context
Working with Claude Code on complex infrastructure requires:
- Clear responsibilities
- Safety boundaries
- Specialized knowledge
- Coordination on complex tasks

### Decision
Implement specialized agent system where Claude Code adopts different personas:
- Testing Agent (read-only, advisory)
- Docker Agent (container management)
- Infrastructure Agent (Proxmox/VMs)
- Security Agent (secrets, auth)
- Media Stack Agent (critical services)
- Documentation Agent (knowledge management)

### Consequences

**Positive:**
- Clear boundaries and permissions
- Specialized context per domain
- Safety through restrictions
- Better coordination on complex tasks
- Explicit about what can/cannot be done

**Negative:**
- More conceptual overhead
- Requires understanding agent system
- Context switching between agents

**Neutral:**
- Novel approach for AI collaboration
- Will learn and evolve over time

### Alternatives Considered

1. **No agent system**
   - Simpler conceptually
   - Less clear boundaries
   - Harder to coordinate
   - More risk of mistakes

2. **Different agent breakdown**
   - Many ways to divide responsibilities
   - Current breakdown matches infrastructure

---

## ADR-011: Critical Services List

**Date:** 2025-10-24
**Status:** Accepted
**Deciders:** Evan + Claude Code

### Context
Not all services have equal importance. Some affect household members, others only system owner.

### Decision
Define three services as CRITICAL (affecting household users):
- Emby (VM 100): Media streaming
- Downloads (VM 101): Media acquisition
- *arr services (VM 102): Media automation

All other services are important but primarily affect system owner only.

### Consequences

**Positive:**
- Clear prioritization
- Extra caution for critical services
- Can make faster changes to non-critical
- Focus maintenance on what matters most

**Negative:**
- Less attention to "non-critical" services
- Must maintain list over time

**Neutral:**
- Could expand critical list
- Priority may shift over time

### Alternatives Considered

1. **All services equal priority**
   - Simpler
   - Slower to make changes
   - Inefficient

2. **More granular tiers**
   - More complex
   - Current approach sufficient

---

## ADR-012: Script-Based Operational Automation

**Date:** 2025-10-26
**Status:** Accepted
**Deciders:** Evan + Claude Code

### Context

Infrastructure operations are currently performed manually or with ad-hoc scripts. As we grow:
- Need reproducible operations (secret audits, deployments, health checks)
- Want to reduce human error in repetitive tasks
- Building toward Goal #3 (Automate deployment, updates, recovery)
- Need composable building blocks for larger workflows
- Want executable documentation (runbooks)

### Decision

Establish a structured approach to operational automation:

**1. Organized Script Library**
- Scripts organized by function: `secrets/`, `deployment/`, `setup/`, `validation/`, `backup/`
- Clear naming convention: `verb-noun.sh`
- Consistent structure with help text and exit codes

**2. Script Development Standards**
- Header documentation with purpose, usage, examples
- Error handling (`set -euo pipefail`)
- Descriptive variables and clear logic
- Color-coded output for clarity
- Exit codes: 0 (success), 1 (error), 2 (invalid input)

**3. Documentation Requirements**
- `scripts/README.md` inventory of all scripts
- Use cases and examples
- Dependencies and prerequisites
- Related documentation links

**4. When to Create Scripts**
- ✅ Operations run multiple times
- ✅ Validation and health checks
- ✅ Common tasks needing consistency
- ✅ Building blocks for larger automation
- ❌ One-off tasks or trivial commands

### Consequences

**Positive:**
- Reproducible operations every time
- Reduced human error
- Building blocks for larger automation
- Executable documentation
- Knowledge captured in code
- Easier onboarding (examples to follow)
- Foundation for runbooks (IN-003)
- Progress toward automation goal

**Negative:**
- Scripts require maintenance
- Need to keep documentation updated
- Learning curve for script standards
- Can accumulate clutter if not disciplined

**Neutral:**
- Balance between automation and flexibility
- Need judgment on when to script vs manual
- Scripts evolve with infrastructure

### Implementation

**Initial Scripts Organized:**
- **Secret management:** `audit-secrets.sh`, `create-secret.sh`, `update-secret.sh`, `delete-secret.sh`
- **Deployment:** `deploy-with-secrets.sh`
- **Setup:** `setup-evan-nopasswd-sudo.sh`, `setup-inspector-user.sh`

**First Use Case:** Secret inventory for IN-002 (secret migration)

**Future Automation:**
- Service health checks
- Backup operations
- Deployment runbooks
- Validation and testing
- Resource monitoring

### Alternatives Considered

1. **No structured automation**
   - Simpler initially
   - More error-prone
   - Harder to scale
   - Knowledge in heads, not code

2. **Configuration management tools (Ansible, etc.)**
   - Over-engineered for single host
   - Steeper learning curve
   - More complexity to maintain
   - Shell scripts sufficient for our scale

3. **Different organization** (flat scripts/ directory)
   - Works initially
   - Becomes cluttered quickly
   - Harder to find relevant scripts
   - No clear categorization

---

## Future Decisions to Document

These decisions haven't been made yet but should be documented when addressed:

1. **Backup Strategy** - Frequency, retention, storage, testing (see [[tasks/backlog/IN-011-document-backup-strategy|IN-011]])
2. **Monitoring Solution** - Which tool(s), what to monitor, alerting (see [[tasks/backlog/IN-005-setup-monitoring-alerting|IN-005]])
3. **High Availability** - Whether to implement, which services, how
4. **Hardware Transcoding** - GPU passthrough for Emby, which GPU, setup (see [[tasks/backlog/IN-007-optimize-emby-transcoding|IN-007]])
5. **Centralized Logging** - Which solution, retention policy
6. **Update Strategy** - Automated vs manual, critical vs non-critical
7. **Disaster Recovery** - RTO/RPO definitions, procedures (see [[tasks/backlog/IN-008-test-disaster-recovery|IN-008]])
8. **Secret Backup and Rotation** - Vaultwarden backup procedures, secret rotation strategy (Vaultwarden chosen, .env migration pending in [[tasks/current/IN-002-migrate-secrets-to-env|IN-002]])

---

## Decision Status Definitions

- **Proposed**: Decision suggested, not yet accepted
- **Accepted**: Decision made and implemented
- **Deprecated**: Decision superseded by new approach but kept for history
- **Superseded**: Replaced by specific newer decision (link to new ADR)

## How to Add a Decision

1. Copy template from `.obsidian/templates/adr.md`
2. Number sequentially (ADR-XXX)
3. Fill in all sections completely
4. Link from this index
5. Commit to git

## Related Documentation

- [[CLAUDE|Claude Code Guide]]
- [[ARCHITECTURE|Infrastructure Architecture]]
- [[agents/README|Agent System]]

---

**Note:** This document should be updated whenever significant architectural decisions are made or changed.
