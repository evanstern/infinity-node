---
type: task
task-id: IN-054
status: in-progress
priority: 5
category: feature
agent: media-stack
created: 2025-12-10
updated: 2025-12-10
started: 2025-12-10
completed:

# Task classification
complexity: simple
estimated_duration: 1h
critical_services_affected: false
requires_backup: false
requires_downtime: false

# Design tracking
alternatives_considered: false
risk_assessment_done: true
phased_approach: true

tags:
  - task
  - lazylibrarian
  - media
  - docker
---

# Task: IN-054 - Setup LazyLibrarian Stack

> **Quick Summary**: Set up LazyLibrarian stack on VM 101 to manage ebook library automation.

## Problem Statement

**What problem are we solving?**
We need an automated solution for managing ebook collections, similar to how *arr services manage video content. LazyLibrarian provides this functionality.

**Why now?**
The user has requested to finish the partial setup of LazyLibrarian.

**Who benefits?**
- **Users**: Automated ebook management and downloading.

## Solution Design

### Recommended Approach

Deploy LazyLibrarian as a Docker container on VM 101 (Downloads), integrated with Traefik for reverse proxy access.

**Key components:**
- **LazyLibrarian Container**: The core application.
- **Traefik Configuration**: Routing rules to expose the service at `lazylibrarian.local.infinity-node.com`.
- **Environment Configuration**: Standard `.env` pattern for secrets and paths.
- **NFS Share**: Mount VM 103's Calibre library on VM 101 for access.

**Rationale**: Placing on VM 101 allows direct access to download clients and VPN tunnel if needed, though standard config routes through download clients anyway. User requested VM 101.

### Scope Definition

**✅ In Scope:**
- Complete `stacks/lazylibrarian/docker-compose.yml`
- Create `stacks/lazylibrarian/.env.example`
- Create `stacks/lazylibrarian/README.md`
- Update `stacks/traefik/vm-101/dynamic.yml`
- Configure NFS export on VM 103
- Configure NFS mount on VM 101

**❌ Explicitly Out of Scope:**
- Setting up download clients (assumed existing)
- Importing existing library (operational task)

**🎯 MVP (Minimum Viable)**:
Working container accessible via URL.

## Risk Assessment

### Potential Pitfalls

- ⚠️ **Risk 1: Port conflict** → **Mitigation**: Verify port 5299 is free (standard LL port).
- ⚠️ **Risk 2: Path permissions** → **Mitigation**: Use PUID/PGID 1000.

### Dependencies

**Prerequisites (must exist before starting):**
- [x] **VM 101** - Hosting environment.
- [x] **Traefik** - Reverse proxy.

### Critical Service Impact

**Services Affected**: None (new service).

### Rollback Plan

**How to rollback if this goes wrong:**
1. Revert `stacks/traefik/vm-101/dynamic.yml`
2. Remove `stacks/lazylibrarian` directory content changes.

**Recovery time estimate**: 5 mins

## Execution Plan

### Phase 1: Stack Configuration

**Primary Agent**: `media-stack`

- [x] **Complete docker-compose.yml** `agent:media-stack`
  - Match project standards
  - Define volumes and ports
- [x] **Create .env.example** `agent:media-stack`
  - Define paths and PUID/PGID
- [x] **Create README.md** `agent:documentation`
  - Document stack configuration

### Phase 2: Networking & Storage

**Primary Agent**: `infrastructure`

- [x] **Update Traefik Config** `agent:infrastructure`
  - Add router and service for LazyLibrarian in `stacks/traefik/vm-101/dynamic.yml`
  - Revert changes to `stacks/traefik/vm-103/dynamic.yml`
- [x] **Setup NFS Export (VM 103)** `agent:infrastructure`
  - Export `/home/evan/calibre-library` to VM 101
- [x] **Setup NFS Mount (VM 101)** `agent:infrastructure`
  - Mount VM 103 export at `/mnt/calibre-library`

### Phase 3: Validation & Testing

**Primary Agent**: `testing`

- [x] **Verify Configs** `agent:testing`
  - Check for linter errors
  - Verify YAML syntax

### Phase 4: Documentation

**Primary Agent**: `documentation`

- [x] **Update Documentation** `agent:documentation`
  - Ensure README is complete and points to VM 101

## Acceptance Criteria

**Done when all of these are true:**
- [x] LazyLibrarian `docker-compose.yml` is valid and complete
- [x] `.env.example` exists
- [x] Traefik configuration includes LazyLibrarian (VM 101)
- [ ] Changes committed

## Notes

**Implementation Notes**:
- Use `lscr.io/linuxserver/lazylibrarian:latest`
- Ensure `traefik-network` is attached.

---

> [!note]- 📋 Work Log
>
> **2025-12-10 - Setup**
> - Created task IN-054.
> - Configured `stacks/lazylibrarian`.
> - Moved target to VM 101 per user request.
> - Updated Traefik routing on VM 101.
