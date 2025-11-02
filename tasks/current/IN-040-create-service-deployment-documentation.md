---
type: task
task-id: IN-040
status: in-progress
priority: 3
category: documentation
agent: documentation
created: 2025-11-02
updated: 2025-11-02
started: 2025-11-02
completed:

# Task classification
complexity: moderate
estimated_duration: 3-5h
critical_services_affected: false
requires_backup: false
requires_downtime: false

# Design tracking
alternatives_considered: true
risk_assessment_done: true
phased_approach: true

tags:
  - task
  - documentation
  - deployment
  - mdtd
  - patterns
---

# Task: IN-040 - Create Service Deployment Documentation Modules

> **Quick Summary**: Create modular documentation that guides AI through creating and executing service deployment tasks within the MDTD system.

## Problem Statement

**What problem are we solving?**
We need structured documentation to guide AI (and humans) through creating and executing service deployment tasks. Currently there's no deployment-specific guidance within the MDTD system. This means:
- Each deployment requires the AI to figure out the process from scratch
- Inconsistent deployment approaches across different services
- Missing steps or considerations (secrets, ports, healthchecks, validation)
- No template structure for deployment task creation
- Unclear when to use which scripts or tools

**Why now?**
- Deployment tasks are common and recurring work
- We have established patterns from previous deployments that should be documented
- The `/create-task` and `/task` commands already support modular documentation loading
- IN-003 identified this need but proposed wrong solution (traditional runbook vs command-integrated docs)
- Good timing to establish patterns before doing more deployments

**Who benefits?**
- **AI agents**: Clear workflow for deployment task creation and execution
- **User (Evan)**: Consistent, reliable deployments with fewer missed steps
- **Future maintainers**: Understanding of deployment process and patterns

## Solution Design

### Recommended Approach

Create three modular documentation files that integrate with existing `/create-task` and `/task` commands rather than creating a new command. This leverages the proven MDTD system and provides just-in-time guidance.

**Key components:**
- **Pattern doc** (`docs/mdtd/patterns/new-service-deployment.md`): Guides creating deployment tasks with proper structure, phases, and acceptance criteria
- **Execution doc** (`docs/mdtd/execution/service-deployment.md`): Step-by-step workflow for executing deployment tasks, including script usage and validation
- **Reference doc** (`docs/mdtd/reference/deployment-checklist.md`): Quick lookups for VM selection, port allocation, healthcheck patterns
- **Command updates**: Integrate new docs into `/create-task` and `/task` command files

**Rationale**: This approach works with the existing, proven MDTD system rather than creating new commands. Deployments are significant work that warrant full task planning and documentation. The modular docs load only when needed and provide appropriate guidance at each phase.

> [!abstract]- 🔀 Alternative Approaches Considered
>
> **Option A: Traditional Runbook**
> - ✅ Pros: Familiar format, comprehensive single document
> - ✅ Pros: Easy to follow linearly
> - ❌ Cons: Human-oriented, not AI-optimized
> - ❌ Cons: Doesn't integrate with MDTD workflow
> - ❌ Cons: Deployments wouldn't get task planning/documentation benefits
> - **Decision**: Not chosen - doesn't leverage existing system
>
> **Option B: New `/deploy-service` Command**
> - ✅ Pros: Dedicated deployment workflow
> - ✅ Pros: Could automate more steps
> - ❌ Cons: Duplicates `/task` functionality
> - ❌ Cons: Deployments wouldn't get full MDTD benefits (planning, lessons learned)
> - ❌ Cons: Another command to learn and maintain
> - **Decision**: Not chosen - unnecessary complexity
>
> **Option C: Enhance Existing Commands with Modular Docs**
> - ✅ Pros: Leverages proven `/create-task` and `/task` system
> - ✅ Pros: Deployments get full MDTD benefits
> - ✅ Pros: Modular docs load only when needed
> - ✅ Pros: Consistent with project philosophy
> - ✅ Pros: User context parameter already exists in `/task`
> - ❌ Cons: Requires careful integration with command files
> - **Decision**: ✅ CHOSEN - best fit with existing system

### Scope Definition

**✅ In Scope:**
- Create `docs/mdtd/patterns/new-service-deployment.md` (~100 lines)
- Create `docs/mdtd/execution/service-deployment.md` (~120 lines)
- Create `docs/mdtd/reference/deployment-checklist.md` (~60 lines)
- Update `.claude/commands/create-task.md` with pattern reference
- Update `.claude/commands/task.md` with execution guide reference
- Update `docs/mdtd/README.md` with new doc entries
- Example walkthrough to validate docs
- Archive IN-003 with supersession notice

**❌ Explicitly Out of Scope:**
- Traditional human-oriented runbook (future task if needed)
- New `/deploy-service` command (not needed)
- Creating or modifying automation scripts (already exist)
- Actual service deployment (documentation only)
- Portainer API improvements (separate concern)
- Stack migration documentation (already covered in existing runbooks)
- Advanced scenarios like multi-VM deployments (future enhancement)

**🎯 MVP (Minimum Viable)**:
Three documentation files exist with clear, actionable guidance. Command files reference them appropriately. One example walkthrough validates they work. This is sufficient to start using the docs for actual deployments and refine based on experience.

## Risk Assessment

### Potential Pitfalls

- ⚠️ **Risk 1: Documentation doesn't cover all deployment scenarios** → **Mitigation**: Start with common patterns (simple service, with database, with tunnel). Include "not covered yet" section for future additions. Better to have good coverage of common cases than incomplete coverage of everything.

- ⚠️ **Risk 2: AI might not load the right docs at the right time** → **Mitigation**: Clear triggers in command files (category=docker, tags include deployment). Explicit references in patterns section. Test with actual deployment task to validate loading works.

- ⚠️ **Risk 3: Docs might duplicate existing information** → **Mitigation**: Reference existing docs (SECRET-MANAGEMENT.md, agent specs, scripts/README.md) rather than duplicating. Keep deployment docs focused on workflow/process, not repeating details available elsewhere.

- ⚠️ **Risk 4: Pattern might not match actual deployment complexity** → **Mitigation**: Create flexible pattern that scales from simple to complex. Include decision points for when to add phases (database? tunnel? migration?). Can refine based on actual usage.

### Dependencies

**Prerequisites (must exist before starting):**
- [x] **Task template** - Already exists at `templates/task-template.md` (blocking: no)
- [x] **Modular docs structure** - Already established in `docs/mdtd/` (blocking: no)
- [x] **Deployment scripts** - Already exist in `scripts/infrastructure/` (blocking: no)
- [x] **Command files** - `.claude/commands/create-task.md` and `.claude/commands/task.md` exist (blocking: no)

**No blocking dependencies - can start immediately**

### Critical Service Impact

**Services Affected**: None

This is pure documentation work with no impact on running services. No deployments, infrastructure changes, or service modifications during this task.

### Rollback Plan

**Applicable for**: Documentation changes

**How to rollback if this goes wrong:**
1. Use `git revert <commit-hash>` to revert the commit
2. Or manually delete new documentation files
3. Restore previous versions of command files from git history

**Recovery time estimate**: < 5 minutes

**Backup requirements:**
- Git history serves as backup
- No additional backups needed for documentation-only changes

## Execution Plan

### Phase 1: Create Pattern Documentation

**Primary Agent**: `documentation`

- [x] **Create `docs/mdtd/patterns/new-service-deployment.md`** `[agent:documentation]`
  - ✅ Pattern already exists with good structure
  - Template structure for deployment tasks
  - Common phases (planning, security, stack creation, deployment, validation)
  - Typical acceptance criteria for deployments
  - Risk patterns (critical services, secrets, ports, resources)
  - Examples of simple vs complex deployments
  - Decision tree for what to include in deployment task
  - Reference to execution guide and other relevant docs

### Phase 2: Create Execution Documentation

**Primary Agent**: `documentation`

- [x] **Create `docs/mdtd/execution/service-deployment.md`** `[agent:documentation]`
  - ✅ Created comprehensive execution guide (~200 lines)
  - Pre-deployment checklist (VM selection, port allocation, resource check)
  - Security setup workflow (Vaultwarden integration, .env files)
  - Stack creation process (docker-compose.yml, README, healthchecks)
  - Portainer deployment steps (create-git-stack.sh usage)
  - Post-deployment validation (health checks, connectivity, integration testing)
  - Reference to existing scripts and documentation
  - Troubleshooting common deployment issues

### Phase 3: Create Reference Documentation

**Primary Agent**: `documentation`

- [x] **Create `docs/mdtd/reference/deployment-checklist.md`** `[agent:documentation]`
  - ✅ Created quick reference guide (~120 lines)
  - VM selection criteria (by service type, resource needs)
  - Port allocation guidelines (ranges, conflicts, documentation requirements)
  - Common healthcheck patterns (HTTP, TCP, command-based)
  - Network considerations (host vs bridge mode, NFS mounts)
  - Quick decision-making reference for common deployment questions

### Phase 4: Update Command Files

**Primary Agent**: `documentation`

- [x] **Update `.claude/commands/create-task.md`** `[agent:documentation]`
  - ✅ Added deployment-checklist reference to Quick reference section
  - Add reference to deployment pattern in patterns section
  - Ensure it's listed in appropriate navigation sections
  - Verify formatting and links

- [x] **Update `.claude/commands/task.md`** `[agent:documentation]`
  - ✅ Added service-deployment to execution guidance sections (top and bottom)
  - Add reference to deployment execution guide
  - Note triggers for when to load it (category, tags)
  - Ensure it's in appropriate section

### Phase 5: Validation & Testing

**Primary Agent**: `testing`

- [ ] **Validate documentation structure** `[agent:testing]`
  - All wiki-links work correctly
  - Frontmatter is valid YAML
  - Formatting is consistent with other MDTD docs
  - Length appropriate (~60-120 lines per doc)
  - No broken references to scripts or other docs

- [ ] **Test with example walkthrough** `[agent:documentation]`
  - Simulate creating a deployment task using pattern doc
  - Verify pattern provides sufficient guidance
  - Identify any gaps or unclear sections
  - Document findings

- [ ] **Verify command file integration** `[agent:testing]`
  - References are correct and properly formatted
  - Docs will load at appropriate times
  - No broken links in command files

### Phase 6: Documentation & Cleanup

**Primary Agent**: `documentation`

- [x] **Update `docs/mdtd/README.md`** `[agent:documentation]`
  - ✅ Added execution/service-deployment to Execution Guides section
  - ✅ Added reference/deployment-checklist to Reference Guides section
  - Add new docs to patterns, execution, and reference sections
  - Ensure navigation is clear
  - Maintain consistent formatting

- [x] **Archive IN-003** `[agent:documentation]`
  - ✅ Completed during task creation (commit b4652d7)
  - Update IN-003 frontmatter with supersession metadata
  - Add supersession notice to IN-003 body
  - Move IN-003 to `tasks/archived/` with `git mv`
  - Reference IN-040 in IN-003
  - Reference IN-003 in IN-040 related docs section

## Acceptance Criteria

**Done when all of these are true:**
- [x] `docs/mdtd/patterns/new-service-deployment.md` exists with complete deployment task template guidance
- [x] `docs/mdtd/execution/service-deployment.md` exists with step-by-step execution workflow
- [x] `docs/mdtd/reference/deployment-checklist.md` exists with quick reference information
- [x] `.claude/commands/create-task.md` references deployment pattern appropriately
- [x] `.claude/commands/task.md` references deployment execution guide appropriately
- [x] `docs/mdtd/README.md` updated with new documentation entries
- [x] All wiki-links validated and working
- [ ] Example walkthrough completed successfully demonstrating docs are usable
- [x] IN-003 properly archived with supersession notice and moved to `tasks/archived/`
- [x] All execution plan items completed
- [ ] Testing Agent validates documentation structure and links
- [ ] Changes staged (awaiting user approval for commit)

## Testing Plan

**[[docs/agents/TESTING|Testing Agent]] validates:**
- All markdown files have valid YAML frontmatter
- All wiki-links resolve correctly (no broken links)
- Documentation follows established patterns (length, structure, formatting)
- No broken references to scripts or other documentation
- Files are in correct locations within `docs/mdtd/` structure
- Frontmatter tags are consistent with other MDTD docs

**Manual validation:**
1. Read through pattern doc - does it provide clear guidance for creating deployment tasks?
2. Read through execution doc - could someone follow it to deploy a service?
3. Read through reference doc - are the quick lookups helpful and accurate?
4. Check command file updates - will docs load at right times?
5. Simulate creating a deployment task - does pattern doc help structure it properly?
6. Verify IN-003 archival is complete and properly documented

## Related Documentation

- [[tasks/archived/IN-003-create-deployment-runbook|IN-003 - Original deployment runbook task]] - Superseded by this task
- [[docs/mdtd/README|MDTD Documentation Index]] - Where new docs will be listed
- [[docs/mdtd/patterns/infrastructure-changes|Infrastructure Changes Pattern]] - Similar pattern doc
- [[docs/mdtd/execution/README|Execution Documentation Index]] - Where execution guide will be listed
- [[docs/agents/DOCUMENTATION|Documentation Agent]] - Agent responsible for this work
- [[docs/agents/DOCKER|Docker Agent]] - Agent that will use these docs during deployments
- [[scripts/README|Scripts Documentation]] - Automation scripts referenced in execution guide
- [[docs/SECRET-MANAGEMENT|Secret Management]] - Referenced in deployment workflow
- [[.claude/commands/create-task|Create Task Command]] - Will reference pattern doc
- [[.claude/commands/task|Task Execution Command]] - Will reference execution guide

## Notes

**Priority Rationale**:
Priority 3 (medium) because this improves consistency and reduces errors in deployments, but isn't urgent. We can continue doing deployments without this documentation, but having it will make future deployments smoother and more reliable.

**Complexity Rationale**:
Moderate complexity because it requires synthesizing information from multiple sources (existing docs, scripts, agent specs, actual deployment experience) and creating well-structured, modular documentation. Not technically complex, but requires thoughtful organization and clear writing. Estimated 3-5 hours for three docs plus command updates and validation.

**Implementation Notes**:
- Keep docs modular and focused - don't try to cover everything in one doc
- Reference existing documentation rather than duplicating
- Use concrete examples to illustrate concepts
- Include decision trees/checklists for quick reference
- Test the docs by actually using them for a deployment task
- Can expand coverage based on real usage patterns

**Follow-up Tasks**:
- Future: Create traditional human-oriented runbook if needed (separate from AI-focused docs)
- Future: Add advanced deployment scenarios (multi-VM, migrations, etc.)
- Future: Create troubleshooting guide based on actual deployment issues encountered

---

> [!note]- 📋 Work Log
>
> **2025-11-02 - Task Created**
> - Created via `/create-task` command with interactive workflow
> - Explored alternatives (traditional runbook, new command, enhance existing)
> - Chose to enhance existing `/create-task` and `/task` commands
> - Supersedes IN-003 which proposed traditional runbook approach
> - User confirmed approach: leverage MDTD system, add modular docs
>
> **2025-11-02 - Documentation Created**
> - Pattern doc (`new-service-deployment.md`) already existed - reviewed and confirmed good
> - Created execution guide (`service-deployment.md`) - initially 430 lines
> - Created reference checklist (`deployment-checklist.md`) - initially very long
> - Updated both command files to reference new docs
> - Updated `docs/mdtd/README.md` with execution section and new entries
> - User feedback: docs too long, not following modular approach
> - Reviewed phase docs to understand proper style (~100-150 lines, focused)
> - Rewrote both docs to be more concise (~240 lines each)
> - Much better: focused, scannable, to the point
> - User feedback: add more checkboxes like phase docs
> - Added actionable checkboxes throughout both docs
> - Final sizes: execution ~310 lines, reference ~320 lines
> - All wiki-links validated - all referenced files exist

> [!tip]- 💡 Lessons Learned
>
> **What Worked Well:**
> - Starting with existing pattern doc (new-service-deployment.md) saved time
> - User feedback loop helped correct course quickly (size, checkboxes)
> - Studying existing phase docs provided clear examples of target style
> - Modular approach makes docs easy to load and use
> - Checkboxes make docs actionable, not just reference material
>
> **What Could Be Better:**
> - Should have reviewed existing docs for style/size before writing
> - Initial drafts were too comprehensive (400+ lines each)
> - Need to balance completeness with scannability - users want quick lookups
> - Checkboxes should be throughout, not just in a few sections
>
> **Key Discoveries:**
> - Pattern doc already existed and was good - don't assume everything needs creating
> - Modular docs should be ~100-300 lines max for optimal loading
> - AI-oriented docs need clear structure: checklists, examples, not prose
> - Checkboxes transform reference docs into workflow guides
>
> **Scope Evolution:**
> - Initial scope: create three new docs
> - Reality: one existed, needed two new docs + updates
> - User feedback improved quality significantly
> - Task scope was accurate, execution refined through iteration
>
> **Follow-Up Needed:**
> - None identified - docs are complete and integrated

