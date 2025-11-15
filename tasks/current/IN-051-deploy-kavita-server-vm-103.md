---
type: task
task-id: IN-051
status: in-progress
priority: 4
category: media
agent: media
created: 2025-11-13
updated: 2025-11-15
started: 2025-11-15
completed:

# Task classification
complexity: moderate
estimated_duration: 4-6h
critical_services_affected: false
requires_backup: true
requires_downtime: false

# Design tracking
alternatives_considered: true
risk_assessment_done: true
phased_approach: true

tags:
  - task
  - media
  - vm-103
  - kavita
---

# Task: IN-051 - Deploy Kavita server on VM-103

> **Quick Summary**: Stand up the LinuxServer.io Kavita container on VM-103 with Portainer-managed compose, Traefik routing, backups, and documentation so household users gain a managed comics/ebook platform. ([source](https://wiki.kavitareader.com/installation/docker/lsio/))

## Problem Statement

**What problem are we solving?**
VM-103 currently lacks a self-hosted reader for comics and ebooks. Household collections live on the NAS but are not exposed through a unified service, leaving users to rely on manual file transfers. A Kavita deployment would provide a polished reading experience, OPDS support, and integration with the existing media stack while staying inside our GitOps model.

**Why now?**
- VM-103 recently received additional hardening (Fail2ban), making it safer to host new apps.
- Demand for a centralized reader has increased alongside the Paperless/PDF workflow.
- Aligns with Q4 objective to document and automate every home media service.

**Who benefits?**
- **Household users**: Can browse and read digital libraries from any device with consistent metadata.
- **Media Stack Agent**: Gains another standardized LSIO deployment pattern with backups and runbook coverage.
- **Documentation Agent**: Captures repeatable instructions for future book/comic services.

## Solution Design

### Recommended Approach

Deploy Kavita using the LinuxServer.io image (`lscr.io/linuxserver/kavita:latest`) inside a new Portainer-managed stack on VM-103. Configuration and metadata will persist under the NAS-backed `/mnt/video/Kavita/config` path (Synology share), while media libraries mount read-only from dedicated NAS directories (e.g., `/mnt/video/Kavita/library`). Traefik will provide internal routing (e.g., `https://kavita.local.evanstern.name`) with optional Pangolin exposure later. Secrets (admin credentials, optional SMTP) live in Vaultwarden and hydrate via the stack `.env`. Documentation will cover deployment, backup expectations, and operational procedures.

**Key components:**
- Component 1: `stacks/kavita/docker-compose.yml` referencing the LSIO image with healthcheck, `PUID/PGID`, timezone, and persistent `/config` + `/library` mounts.
- Component 2: `.env.example` plus Vaultwarden entries for admin credentials, SMTP, and optional Kavita+ tokens.
- Component 3: Service README/runbook updates detailing Traefik labels, DNS expectations, backup targets, and rollback instructions.

**Rationale**: The LSIO container tracks stable releases, aligns with existing stacks, and uses `/config` for persistence as documented by Kavita, minimizing surprises during upgrades. Portainer GitOps keeps deployment reproducible and auditable.

> [!abstract]- 🔀 Alternative Approaches Considered
>
> **Option A: Official Kavita DockerHub image**
> - ✅ Pros: Access to nightlies; upstream support.
> - ✅ Pros: Identical configuration to LSIO aside from mount paths.
> - ❌ Cons: Different config directory (`/kavita/config`) complicates parity with other LSIO stacks.
> - ❌ Cons: Nightly builds introduce instability for household users.
> - **Decision**: Not chosen - stable LSIO image better fits reliability goals.
>
> **Option B: Native install on VM-103**
> - ✅ Pros: Eliminates container overhead; direct systemd integration.
> - ❌ Cons: Breaks GitOps workflow, harder to back up and redeploy.
> - ❌ Cons: Pollutes host with dependencies and manual updates.
> - **Decision**: Not chosen - containers remain standard for services.
>
> **Option C: LinuxServer.io container (chosen)**
> - ✅ Pros: Stable release cadence, identical pattern to other stacks, easy Portainer integration.
> - ✅ Pros: Matches documentation, defaults to `/config` and port 5000, simplifying setup.
> - ❌ Cons: Lacks nightly builds; requires Traefik integration work.
> - **Decision**: ✅ CHOSEN - best balance of stability, maintainability, and documentation.

### Scope Definition

**✅ In Scope:**
- Compose stack, `.env.example`, and README for Kavita under `stacks/kavita/`.
- Vaultwarden secret entries plus documented backup targets for `/config`.
- Traefik routing + DNS notes, Portainer deployment, validation, and runbook updates.

**❌ Explicitly Out of Scope:**
- Migrating existing libraries into Kavita (manual import handled after deployment).
- Pangolin/Internet exposure and Auth hardening (will follow once internal testing completes).
- Mobile client onboarding guides or OPDS integrations.

**🎯 MVP (Minimum Viable)**: Kavita stack deployed via Portainer, accessible on the LAN through Traefik with persistent storage, admin credentials managed via Vaultwarden, and operational docs/rollback steps captured.

## Risk Assessment

### Potential Pitfalls

- ⚠️ **Risk 1: Port conflict on VM-103 (5000)** → **Mitigation**: Inventory running services/Traefik routes before deployment; adjust container-only binding or Traefik service port if conflict detected.

- ⚠️ **Risk 2: Storage throughput issues for large libraries** → **Mitigation**: Mount libraries from NAS over NFS with proven paths, monitor during validation, and document performance expectations/alerts.

- ⚠️ **Risk 3: Configuration loss or corruption** → **Mitigation**: Persist `/config` on NAS, add restic/Synology backup inclusion, and document manual snapshot instructions before upgrades.

- ⚠️ **Risk 4: Traefik misconfiguration exposing service unintentionally** → **Mitigation**: Start with LAN-only router/middleware, verify DNS entries, and hold off on Pangolin/public routes until security review.

### Dependencies

**Prerequisites (must exist before starting):**
- [ ] **Confirm NAS paths and permissions for `/config` and `/library`** (blocking: yes)
- [ ] **Traefik routing slot / DNS entry reserved (`kavita.local.evanstern.name`)** (blocking: yes)
- [ ] **Vaultwarden collection ready for Kavita secrets** (blocking: no)

**Has blocking dependencies** - need storage/DNS confirmation before stack deployment.

### Critical Service Impact

**Services Affected**: None of the critical trio (Emby/downloads/arr) are impacted. Kavita is additive on VM-103, so downtime risk is low. Ensure Traefik changes do not interfere with existing routers.

### Rollback Plan

**Applicable for**: docker/media deployment

**How to rollback if this goes wrong:**
1. Disable/remove the Kavita stack in Portainer (retains volumes).
2. Revert `stacks/kavita/` changes in git or redeploy previous commit via Portainer.
3. Validate Traefik routing table to ensure the Kavita entry is gone and no ports remain bound.

**Recovery time estimate**: 30 minutes (including Portainer cleanup and Traefik refresh).

**Backup requirements:**
- Include `/mnt/video/Kavita/config` (or equivalent) in NAS/restic jobs prior to upgrades.
- Snapshot Vaultwarden entries (export secure note) if credentials change during task.

## Execution Plan

### Phase 0: Discovery & Inventory

**Primary Agent**: `infrastructure`

- [ ] **Verify VM-103 resources and port availability** `[agent:infrastructure]`
  - CPU/RAM/storage headroom check, confirm port 5000 unused.
  - Capture `df`/`ss` outputs for documentation.

- [ ] **Confirm storage + DNS prerequisites** `[agent:infrastructure]` `[blocking]`
  - Validate NAS mount paths and permissions for `/config` and `/library`.
  - Reserve DNS entry (`kavita.local.evanstern.name`) and note TTL.

### Phase 1: Stack Definition

**Primary Agent**: `docker`

- [ ] **Author compose + env template** `[agent:docker]` `[risk:1]`
  - Create `stacks/kavita/docker-compose.yml` with LSIO image, healthcheck, Traefik labels.
  - Create `.env.example` documenting required variables (PUID/PGID/TZ, secrets).

- [ ] **Write service README/runbook stub** `[agent:documentation]`
  - Describe purpose, deployment flow, backup expectations, and Traefik/DNS info.

### Phase 2: Secrets & Deployment Prep

**Primary Agent**: `security`

- [ ] **Store secrets in Vaultwarden + note backup paths** `[agent:security]` `[risk:3]`
  - Admin credentials, SMTP, Kavita+ tokens stored with references.
  - Document backup inclusion list for `/config`.

- [ ] **Plan rollback + monitoring hooks** `[agent:media]`
  - Define Portainer rollback steps, log locations, and metrics to watch (CPU, disk).

### Phase 3: Deployment & Validation

**Primary Agent**: `docker`

- [ ] **Deploy stack via Portainer Git integration** `[agent:docker]` `[risk:2]`
  - Trigger pull/redeploy, ensure container healthy, capture logs.

- [ ] **Initial Kavita configuration + smoke tests** `[agent:media]` `[risk:4]`
  - Create admin account, add sample library, test read/performance, verify Traefik route, restart container to confirm persistence.

### Phase 3: Validation & Testing

**Primary Agent**: `testing`

- [ ] **Service health verification** `[agent:testing]`
  - Confirm HTTP 200 on internal route, login works, libraries visible.

- [ ] **Persistence & restart test** `[agent:testing]`
  - Restart stack; ensure data (users/settings) intact and logs clean.

### Phase 4: Documentation

**Primary Agent**: `documentation`

- [ ] **Update architecture/runbooks** `[agent:documentation]`
  - Add Kavita to `ARCHITECTURE.md`, update `stacks/README.md`, create/expand service-specific runbook, document lessons learned.

## Acceptance Criteria

**Done when all of these are true:**
- [ ] `stacks/kavita/docker-compose.yml`, `.env.example`, and README exist with reviewed content.
- [ ] Vaultwarden entries created, `.env.example` references them, and backup plan documented.
- [ ] Portainer stack deployed on VM-103, container healthy, Traefik route serves Kavita.
- [ ] Restart/persistence tests pass; log health recorded.
- [ ] Documentation (architecture, runbook, lessons) updated and linked.
- [ ] All execution plan items completed
- [ ] Testing Agent validates (see testing plan below)
- [ ] Changes committed with descriptive message (awaiting user approval)

## Testing Plan

**[[docs/agents/TESTING|Testing Agent]] validates:**
- Portainer shows Kavita stack `healthy` status for container.
- Traefik route responds with HTTP 200 and valid TLS on LAN hostname.
- Restart test: stop/start stack, ensure users/libraries persist.
- Storage monitoring: confirm no abnormal CPU/RAM/disk spikes during scan/import.

**Manual validation:**
1. Log into Kavita via Traefik URL, create admin user, and confirm ability to add a library path.
2. Upload or rescan sample media, confirm reading works in browser.
3. Check backup target directory exists on NAS and is included in restic/Synology schedules.

## Related Documentation

- [[docs/agents/MEDIA|Media Stack Agent]]
- [[docs/mdtd/patterns/new-service-deployment|New Service Deployment Pattern]]
- [[docs/ARCHITECTURE|Architecture Overview]]
- [[docs/runbooks/navidrome-external-access-security|Navidrome External Access Runbook]] (reference pattern for Traefik/Pangolin)

## Notes

**Priority Rationale**: Medium priority because Kavita improves user experience and documents another service, but it does not impact critical uptime.

**Complexity Rationale**: Moderate—requires new stack authoring, Portainer deployment, Traefik integration, and documentation, but relies on well-known LSIO patterns.

**Implementation Notes**:
- Mirror UID/GID from other VM-103 stacks (likely 1000) for consistent file ownership.
- Keep Traefik router internal-only until Pangolin/Fail2ban posture reviewed.
- Use healthcheck (curl on port 5000) to ensure Portainer reflects status accurately.

**Follow-up Tasks**:
- IN-0XX: Evaluate Pangolin or external exposure for Kavita once internal validation completes.
- IN-0XX: Automate Kavita library ingestion (watchers/scheduled scans).

---

> [!note]- 📋 Work Log
>
> **2025-11-13 - Task Created**
> - Captured requirements, risks, and execution plan for Kavita deployment on VM-103.
> - Logged dependencies (storage/DNS) that must be satisfied pre-deployment.
>
> **2025-11-15 - Pre-task review & dependency check**
> - Followed [[docs/mdtd/execution/pre-task-review]] checklist; confirmed the problem, scope, and acceptance criteria remain valid and aligned with Solution Design.
> - Cross-referenced [[docs/ARCHITECTURE]] to inventory VM-103 resources (6 vCPU, 16GB RAM, NAS-backed disk) and verified no existing Kavita stack or Traefik router under `stacks/` or `stacks/traefik/vm-103/dynamic.yml`.
> - Documented dependency approach: plan NAS-backed `/mnt/video/Kavita/config` for persistence, mount NAS libraries read-only, and reserve `kavita.local.infinity-node.com` via Pi-hole before Traefik updates.
>
> **2025-11-15 - Dependency audit & planning**
> - Confirmed again that `stacks/` has no `kavita` directory and `traefik` dynamic config on VM-103 lacks a `kavita` router, so no current port/hostname conflicts.
> - Aligned storage plan with existing VM-103 patterns (e.g., Audiobookshelf/Navidrome) and earmarked NAS-backed `/mnt/video/Kavita/config` for persistence plus read-only library mounts from NAS shares.
> - Reviewed [[docs/runbooks/pihole-dns-management]] to outline steps for reserving `kavita.local.infinity-node.com`; pending execution once stack ready so DNS + Traefik updates can be applied together.
>
> **2025-11-15 - Stack scaffolding**
> - Created `stacks/kavita/docker-compose.yml` using LSIO image, `/config` + `/library` mounts, external `traefik-network`, curl-based healthcheck, and host port placeholder (5750) to avoid 5000 conflicts while still allowing direct debug access.
> - Authored `.env.example` with UID/GID/TZ defaults, NAS config path, library mount guidance, and commented SMTP placeholders referencing Vaultwarden workflow.
> - Drafted `stacks/kavita/README.md` documenting purpose, deployment, backup requirements, and coordination points (Traefik, Portainer, Pi-hole DNS); set stack metadata to `status: planned`.
> - Updated `stacks/traefik/vm-103/dynamic.yml` to add `kavita.local.infinity-node.com` router/service pointing to container port 5000, preparing for LAN access once stack deploys.
>
> **2025-11-15 - Secrets & backup alignment**
> - Added README "Secrets" section detailing Vaultwarden entries (`kavita/admin`, `kavita/smtp`, optional `kavita/opds`) under collection `vm-103-misc`, referencing [[docs/SECRET-MANAGEMENT]] workflow.
> - Noted `.env.example` placeholders for SMTP settings plus instructions to keep actual credentials only in Vaultwarden/.env (gitignored).
> - Reiterated backup requirement for `/mnt/video/Kavita/config` in README and acceptance criteria; flagged restic/Synology inclusion as pre-deployment checkpoint.
>
> **2025-11-15 - NAS prep & deployment attempt**
> - Created dedicated NAS directories `/Volumes/media/Kavita/config` and `/Volumes/media/Kavita/library` (mounted as `/mnt/video/Kavita/...` on VM-103) to isolate Kavita data from Calibre artifacts while keeping storage on Synology.
> - Updated `.env.example` + README configuration table to reference the new NAS paths and documented creating the directories up front.
> - Ran `./scripts/infrastructure/create-git-stack.sh "portainer-api-token-vm-103" "shared" 3 "kavita" ...` but Portainer rejected the stack because `stacks/kavita/` does not yet exist in the upstream Git repo. Need to stage/commit/push before redeploying via GitOps; deferred deployment until code review completes.
>
> **2025-11-15 - Documentation updates**
> - Added Kavita to `docs/ARCHITECTURE.md` (VM-103 media section) and `stacks/README.md` (directory + import plan) to capture the new service footprint.
> - Ensured README/`.env.example` instructions reference the NAS-based storage layout and created directories.
>
> **2025-11-15 - Deployment attempt & rollback**
> - Pushed stack files, deployed Portainer Git stack (ID 60) with NAS-backed `/config`; Kavita failed migrations with SQLite `database is locked` errors due to CIFS locking.
> - Investigated logs and confirmed `/mnt/video/Kavita/config/kavita.db` remained empty; decided to relocate `/config` to local disk.
> - User removed failed stack in Portainer to prep for redeploy.
>
> **2025-11-15 - Config path pivot**
> - Created `/home/evan/data/kavita/config` on VM-103, updated `.env.example` and README to use local path (with rsync-to-NAS backup requirement) while keeping `/library` on NAS.
> - Ready to redeploy stack with new environment values.
>

> [!tip]- 💡 Lessons Learned
>
> *Fill this in AS YOU GO during task execution. Not every task needs extensive notes here, but capture important learnings that could affect future work.*
>
> **What Worked Well:**
> -
>
> **What Could Be Better:**
> -
>
> **Key Discoveries:**
> -
>
> **Scope Evolution:**
> -
>
> **Follow-Up Needed:**
> -
