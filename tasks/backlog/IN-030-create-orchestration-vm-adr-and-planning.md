---
type: task
task-id: IN-030
status: pending
priority: 3
category: infrastructure
agent: infrastructure
created: 2025-10-30
updated: 2025-10-30
started:
completed:

# Task classification
complexity: moderate
estimated_duration: 3-4h
critical_services_affected: false
requires_backup: false
requires_downtime: false

# Design tracking
alternatives_considered: true
risk_assessment_done: true
phased_approach: true

tags:
  - task
  - infrastructure
  - architecture
  - adr
  - planning
  - monitoring
  - orchestration
---

# Task: IN-030 - Create Orchestration VM ADR and Planning

> **Quick Summary**: Document architectural decision to add VM 104 (orchestration) for cross-VM monitoring and coordination, and plan implementation tasks

## Problem Statement

**What problem are we solving?**

Currently we have 4 VMs running services (VM 100-103), but no centralized place for:
- **Cross-VM monitoring and health checks** - Need to SSH into individual VMs to check status
- **Coordinated cron job management** - Automation tasks scattered or run ad-hoc
- **Centralized metrics/logs database** - No historical data about infrastructure health
- **Orchestration tasks** - Work requiring coordination across multiple VMs done manually
- **Natural home for sysops work** - No dedicated place for infrastructure management

**Current pain points:**
- Disk space checks require manual SSH to each VM
- Portainer stack queries done per-VM, no aggregation
- No monitoring history (can't see trends over time)
- Cross-VM work requires jumping between machines
- No alerting when issues arise
- Future monitoring work has no clear home

**Why now?**
- Infrastructure is stable (4 VMs, 22 stacks, all working well)
- Good time to add operational tooling before scaling further
- Recent work (Portainer migration) shows value of centralized coordination
- Have existing scripts (disk space, Portainer queries) that could benefit from central orchestration
- Planning to add monitoring system (existing task should be revisited with this context)

**Who benefits?**
- **Operations**: Single place to check health of all VMs, automated monitoring
- **Maintenance**: Proactive issue detection, historical data for troubleshooting
- **Future scaling**: Easy to add new VMs to monitoring, foundation for growth
- **Reliability**: Catch issues before they become critical

## Solution Design

### Recommended Approach

**Create dedicated VM 104 (orchestration) for infrastructure monitoring and coordination:**

**VM Specifications:**
- **Name**: `orchestration`
- **VM ID**: 104
- **Resources**: Light (2 cores, 4GB RAM, 40GB disk)
- **Purpose**: Cross-VM monitoring, coordination, metrics database, dashboards
- **OS**: Ubuntu 22.04 LTS (matching other VMs)

**Architecture Principles:**
1. **Resilience**: Services must run independently of orchestration VM
2. **Separation**: Service-specific crons stay on service VMs (e.g., vaultwarden backup on VM 103)
3. **Centralization**: Cross-VM monitoring, coordination, and aggregation on orchestration VM
4. **Scalability**: Easy to add new VMs to monitoring as infrastructure grows

**What SHOULD go on orchestration VM:**
- ✅ Cross-VM monitoring (check all VMs for disk space, health, connectivity)
- ✅ Monitoring database (store metrics, logs, events from all VMs)
- ✅ Dashboards (Grafana or similar for visualization)
- ✅ Alerting system (notifications when issues detected)
- ✅ Cross-VM coordination (tasks requiring orchestration across multiple VMs)
- ✅ Backup verification (check backups exist on NAS from all VMs)
- ✅ Inventory/reporting (query all Portainer instances, generate reports)

**What should STAY on local VMs:**
- ❌ Service-specific crons (vaultwarden backup on VM 103, not orchestration)
- ❌ Critical operations (don't create dependency on orchestration for service uptime)
- ❌ Service configurations (keep with the service)

**Initial MVP Scope:**
- Provision VM 104 in Proxmox
- Configure SSH access (evan/inspector users)
- Install basic monitoring tools
- Set up cron for disk space checks across all VMs
- Set up cron for Portainer stack inventory
- Basic dashboard or reporting output

**Rationale**:
Dedicated VM keeps concerns separated - service VMs focus on their services, orchestration VM handles infrastructure management. If orchestration VM has issues, services continue running unaffected. This scales well as we add more VMs. Clear purpose makes it easy to know where operational tooling lives.

> [!abstract]- 🔀 Alternative Approaches Considered
>
> **Option A: Use Existing VM 103 (Misc)**
> - ✅ Pros: No new VM to create/maintain, VM 103 already has infrastructure services
> - ✅ Pros: Already has SSH access configured, Vaultwarden for secrets
> - ❌ Cons: VM 103 already running 8 stacks - adding more load
> - ❌ Cons: Less clear separation (misc services + orchestration mixed)
> - ❌ Cons: If VM 103 has issues, affects both services AND monitoring
> - **Decision**: Not chosen - prefer clear separation, VM 103 already has enough responsibility
>
> **Option B: Dedicated Orchestration VM (VM 104)**
> - ✅ Pros: Single place for all cross-VM automation and monitoring
> - ✅ Pros: Clear separation of concerns (service VMs do their job, orchestration manages all)
> - ✅ Pros: Natural home for monitoring database, alerting, dashboards
> - ✅ Pros: Future-proof - easy to scale as VMs are added
> - ✅ Pros: Keeps service VMs focused on primary roles
> - ✅ Pros: Light resource requirements (2 cores, 4GB RAM sufficient)
> - ❌ Cons: One more VM to maintain
> - ❌ Cons: Network dependency (needs connectivity to all VMs)
> - ❌ Cons: Single point of failure for automation (mitigated by keeping critical tasks local)
> - **Decision**: ✅ CHOSEN - Benefits outweigh costs, proper separation of concerns
>
> **Option C: Hybrid (Each VM + Central Monitoring)**
> - ✅ Pros: Each VM manages own cron jobs (resilient)
> - ✅ Pros: Orchestration VM only for monitoring aggregation
> - ✅ Pros: Services survive even if orchestration down
> - ❌ Cons: More complex setup
> - ❌ Cons: Cron management scattered across VMs
> - ❌ Cons: Less clear where to put cross-VM coordination tasks
> - **Decision**: Not chosen - Option B already incorporates this (critical crons stay local)

### Scope Definition

**✅ In Scope (This Planning Task):**
- Create ADR documenting orchestration VM decision
- Document architecture principles (what goes where, why)
- Document VM specifications and resource requirements
- Plan implementation subtasks (list them, don't create them yet)
- Define success criteria for overall orchestration VM project
- Archive existing monitoring task (prepare for replacement)

**❌ Explicitly Out of Scope (This Planning Task):**
- Actually provisioning VM 104 (separate implementation task)
- Installing/configuring monitoring tools (separate implementation task)
- Setting up dashboards (separate implementation task)
- Configuring cron jobs (separate implementation task)
- Creating monitoring database (separate implementation task)

**🎯 MVP (Minimum Viable)**:
ADR written and committed, clear list of implementation subtasks identified, existing monitoring task archived, team aligned on approach

## Risk Assessment

### Potential Pitfalls

- ⚠️ **Risk 1: Creating single point of failure for critical operations** → **Mitigation**: Keep all service-specific critical tasks on local VMs (e.g., vaultwarden backup, service restarts). Orchestration only handles non-critical coordination and monitoring aggregation. Services run fine even if orchestration VM is down.

- ⚠️ **Risk 2: Unclear boundaries lead to scope creep** → **Mitigation**: Document clear principles in ADR about what goes on orchestration vs stays local. When in doubt: if service-specific and critical, stays local; if cross-VM and monitoring/reporting, goes on orchestration.

- ⚠️ **Risk 3: Over-engineering the solution before understanding needs** → **Mitigation**: Start with MVP (basic health checks, disk space, Portainer inventory). Add features incrementally based on actual usage patterns. Don't build full monitoring stack until we know what we need.

- ⚠️ **Risk 4: Creating maintenance burden with another VM** → **Mitigation**: Keep orchestration VM simple, use existing patterns (Docker stacks, Portainer, NFS), minimal services. Light resource footprint (2 cores, 4GB RAM). Benefits should clearly outweigh maintenance costs.

- ⚠️ **Risk 5: SSH key management complexity** → **Mitigation**: Use existing evan/inspector user patterns. Orchestration VM gets read-only access (inspector) for monitoring, write access (evan) only when needed for specific operations. Follow established SSH security practices.

### Dependencies

**Prerequisites (all ready):**
- [ ] **Proxmox access** - Already have root SSH access (blocking: no)
- [ ] **VM template** - Already exists from previous VM creation (blocking: no)
- [ ] **Existing monitoring task** - Need to review and archive (blocking: no)
- [ ] **Scripts to coordinate** - Already exist (check-vm-disk-space.sh, query-portainer-stacks.sh) (blocking: no)

**No blocking dependencies** - can start immediately

### Critical Service Impact

**Services Affected**: None

This is planning/documentation work only. No service impact. When implementation tasks execute, they also won't affect services - orchestration VM is additive, doesn't change existing VMs.

### Rollback Plan

**Applicable for**: Planning/documentation work

**How to rollback if this goes wrong:**
1. Delete ADR file from git
2. Restore any changes to docs: `git checkout HEAD -- docs/`
3. Un-archive monitoring task if it was archived

**Recovery time estimate**: < 5 minutes

**For implementation tasks (when created):**
- VM provisioning: Delete VM 104 from Proxmox (5 minutes)
- Monitoring setup: Stop/remove monitoring stack (10 minutes)
- No impact on existing services

## Execution Plan

### Phase 1: Research & Review

**Primary Agent**: `infrastructure`

- [ ] **Review existing monitoring task** `[agent:infrastructure]`
  - Find monitoring task in backlog
  - Review what was planned
  - Identify what's still relevant with orchestration VM context
  - Determine if should be archived or updated

- [ ] **Review existing scripts** `[agent:infrastructure]`
  - Confirm check-vm-disk-space.sh location and usage
  - Confirm query-portainer-stacks.sh location and usage
  - Identify other scripts that could benefit from coordination
  - Note any missing functionality

### Phase 2: Create ADR

**Primary Agent**: `documentation`

- [ ] **Create ADR 013** `[agent:documentation]`
  - File: docs/adr/013-dedicated-orchestration-vm.md
  - Document the problem (no centralized monitoring/coordination)
  - Document the decision (dedicated VM 104 for orchestration)
  - Present alternatives considered (VM 103, hybrid approach)
  - Document rationale (separation of concerns, scalability)
  - Define what goes on orchestration vs stays local
  - Document architecture principles
  - Include VM specifications
  - Note future work enabled by this decision

### Phase 3: Plan Implementation Tasks

**Primary Agent**: `documentation`

- [ ] **Identify and document subtasks** `[agent:documentation]`
  - List out implementation tasks needed (don't create task files yet)
  - Suggested tasks:
    1. Provision VM 104 (orchestration) in Proxmox
    2. Configure orchestration VM (users, SSH, base setup)
    3. Set up monitoring system (revisit existing monitoring task)
    4. Implement health check automation (disk space, connectivity)
    5. Set up Portainer inventory automation
    6. Create dashboard for infrastructure visibility
    7. (Future) Implement monitoring database
    8. (Future) Set up alerting system
  - Document dependencies between tasks
  - Suggest execution order
  - Note which are MVP vs future enhancements

- [ ] **Archive existing monitoring task** `[agent:documentation]`
  - Move task to archived or update to reference this new context
  - Note in that task file that IN-030 supersedes/replaces it
  - Ensure no work is lost

### Phase 4: Documentation Updates

**Primary Agent**: `documentation`

- [ ] **Update ARCHITECTURE.md** `[agent:documentation]`
  - Add VM 104 to infrastructure topology
  - Document orchestration VM purpose
  - Note resource allocation

- [ ] **Update relevant runbooks** `[agent:documentation]` `[optional]`
  - If any runbooks need updates about where monitoring lives
  - Can be done during implementation instead

### Phase 5: Validation & Review

**Primary Agent**: `testing`

- [ ] **Validate ADR completeness** `[agent:testing]`
  - ADR addresses the problem clearly
  - Alternatives are well-documented
  - Decision rationale is sound
  - Architecture principles are clear
  - No critical considerations missed

- [ ] **Validate task plan completeness** `[agent:testing]`
  - Implementation tasks cover full scope
  - Dependencies are identified
  - Execution order makes sense
  - MVP vs future work is clear

### Phase 6: Approval & Commit

**Primary Agent**: `documentation`

- [ ] **Present work for user approval** `[agent:documentation]`
  - Show ADR
  - Show list of planned implementation tasks
  - Show documentation updates
  - Wait for user feedback

- [ ] **Commit changes** `[agent:documentation]`
  - After user approval only
  - Commit ADR, doc updates, task completion together
  - Reference task IN-030 in commit message

## Acceptance Criteria

**Done when all of these are true:**
- [ ] ADR 013 created at docs/adr/013-dedicated-orchestration-vm.md
- [ ] ADR documents problem, decision, alternatives, rationale, principles
- [ ] ADR includes VM specifications and resource requirements
- [ ] Clear list of implementation subtasks identified and documented
- [ ] Dependencies and execution order for subtasks noted
- [ ] MVP vs future work clearly distinguished
- [ ] Existing monitoring task reviewed and archived/updated appropriately
- [ ] ARCHITECTURE.md updated with VM 104 information
- [ ] All execution plan items completed
- [ ] Testing Agent validates (see testing plan below)
- [ ] Changes committed with descriptive message (awaiting user approval)

## Testing Plan

**[[docs/agents/TESTING|Testing Agent]] validates:**
- ADR file is well-structured and complete
- ADR covers all standard sections (problem, decision, alternatives, consequences)
- Architecture principles are clearly stated
- Implementation task list is comprehensive
- No critical considerations overlooked
- Documentation links work correctly
- Markdown formatting is correct

**Manual validation:**
1. Read ADR - Does it clearly explain the decision and rationale?
2. Review task list - Are all implementation steps covered?
3. Check principles - Is it clear what goes where and why?
4. Consider risks - Are there any pitfalls not addressed?

## Related Documentation

- [[docs/ARCHITECTURE|Infrastructure Architecture]] - Will be updated with VM 104
- [[docs/adr/006-separate-vms-by-service-category|ADR-006: Separate VMs by Category]]
- [[docs/adr/012-script-based-operational-automation|ADR-012: Script-Based Automation]]
- [[scripts/README|Available Scripts]] - Scripts to coordinate from orchestration VM
- [[tasks/DASHBOARD|Task Dashboard]] - Where implementation tasks will be tracked

## Notes

**Priority Rationale**:
Medium priority (3) because this is a valuable infrastructure improvement that enables better monitoring and operational visibility, but it's not urgent. Current setup works fine, this is enhancement work. Good foundation for future scaling and reliability improvements.

**Complexity Rationale**:
Moderate complexity because the concept is well-understood (dedicated VM for monitoring/orchestration) and the technical implementation is straightforward (provision VM, install tools). The complexity is in thoughtful planning - documenting clear principles about what goes where, planning out the implementation phases, and ensuring we don't create accidental single points of failure.

**Implementation Notes**:
- Start with MVP - basic health checks and Portainer inventory
- Iterate based on actual needs discovered during usage
- Keep orchestration VM lightweight (2 cores, 4GB RAM sufficient)
- Follow existing patterns (Docker, Portainer, SSH access)
- Don't create dependencies for critical service operations
- Think of orchestration VM as "optional enhancement" not "critical infrastructure"

**Follow-up Tasks** (to be created after this planning task):
- IN-XXX: Provision VM 104 (orchestration) in Proxmox
- IN-XXX: Configure orchestration VM (SSH, users, base setup)
- IN-XXX: Set up monitoring system (replace existing monitoring task)
- IN-XXX: Implement automated health checks
- IN-XXX: Implement automated Portainer inventory
- IN-XXX: Create infrastructure dashboard

**Existing Monitoring Task**:
There's an existing monitoring task in backlog that should be reviewed. With the orchestration VM context, that task should either be:
1. Archived with reference to IN-030
2. Updated to reflect orchestration VM as the home for monitoring
3. Replaced by new monitoring task created as part of IN-030 subtasks

Decision to be made during Phase 1 of this task.

---

> [!note]- 📋 Work Log
>
> *Progress notes will be added during execution*

> [!tip]- 💡 Lessons Learned
>
> *Added during/after execution*
>
> **What Worked Well:**
>
> **What Could Be Better:**
>
> **Scope Evolution:**
>
> **Future Improvements:**
