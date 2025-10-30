---
type: task
task-id: IN-NNN
status: pending
priority: 3
category: infrastructure|docker|security|media|documentation|testing
agent: infrastructure|docker|security|media|documentation|testing
created: {{date}}
updated: {{date}}

# Task classification
complexity: simple|moderate|complex
estimated_duration: 2-4h
critical_services_affected: false  # true if affects Emby/downloads/arr
requires_backup: false
requires_downtime: false

# Design tracking
alternatives_considered: false  # true if multiple approaches explored
risk_assessment_done: false     # true if risks formally assessed
phased_approach: false          # true if broken into phases

tags:
  - task
  - [category-tag]
  - [additional-tags]
---

# Task: IN-NNN - {{title}}

> **Quick Summary**: [One sentence - what we're doing and why]

<!-- Priority Scale: 0 (critical/urgent) → 1-2 (high) → 3-4 (medium) → 5-6 (low) → 7-9 (very low) -->
<!-- Complexity: simple (straightforward) | moderate (some unknowns) | complex (significant design/unknowns) -->

## Problem Statement

**What problem are we solving?**
[Clear description of the problem or opportunity]

**Why now?**
[Urgency, timing, dependencies, or opportunity that makes this relevant now]

**Who benefits?**
[User experience, system reliability, maintainability, etc.]

## Solution Design

### Recommended Approach
[Description of the chosen solution - narrative form, explain what we'll do]

**Rationale**: [Why this approach? What makes it the right choice?]

> [!abstract]- 🔀 Alternative Approaches Considered
> 
> **Option A: [Name]**
> - ✅ Pros: [advantages]
> - ❌ Cons: [disadvantages]  
> - **Decision**: Not chosen because [reason]
> 
> **Option B: [Name]**
> - ✅ Pros: [advantages]
> - ❌ Cons: [disadvantages]
> - **Decision**: Not chosen because [reason]

### Scope Definition

**✅ In Scope:**
- Item 1
- Item 2
- Item 3

**❌ Explicitly Out of Scope:**
- Future item 1 (consider for separate task)
- Future item 2

**🎯 MVP (Minimum Viable)**: [What's the absolute minimum to call this "done"?]

## Risk Assessment

### Potential Pitfalls
- ⚠️ **[Risk 1]**: Description → **Mitigation**: How we'll handle it
- ⚠️ **[Risk 2]**: Description → **Mitigation**: How we'll handle it

### Dependencies
- [ ] **[Prerequisite 1]**: Description (blocking: yes/no)
- [ ] **[Prerequisite 2]**: Description (blocking: yes/no)

### Critical Service Impact
**Services Affected**: None | Emby | Downloads | Arr services | [Other]

> [!warning]- ⚠️ Critical Service Handling (if applicable)
> 
> **Timing**: [When to do this - low usage window 3-6 AM?]  
> **Backup Plan**: [What to backup first]  
> **Rollback Procedure**: [How to undo if things go wrong]  
> **Monitoring**: [What to watch during/after change]

### Rollback Plan
**Applicable for**: Infrastructure, Docker, Security changes on VMs/servers

**How to rollback if this goes wrong:**
1. Step 1
2. Step 2

**Recovery time estimate**: [how long to rollback]

## Execution Plan

### Phase 0: Discovery & Inventory
**Primary Agent**: `testing` or `documentation`

- [ ] **[Discovery task 1]** `[agent:testing]`
- [ ] **[Discovery task 2]** `[agent:documentation]`

### Phase 1: [Implementation Phase Name]
**Primary Agent**: `docker|infrastructure|security|media`

- [ ] **[Task 1]** `[agent:docker]` `[depends:discovery-task-1]`
- [ ] **[Task 2]** `[agent:security]`
- [ ] **[Task 3]** `[agent:docker]` `[depends:task-1]` `[risk:1]`

### Phase 2: Validation & Testing
**Primary Agent**: `testing`

- [ ] **[Test 1]** `[agent:testing]`
- [ ] **[Test 2]** `[agent:testing]`
- [ ] **[Integration test]** `[agent:testing]`

### Phase 3: Documentation
**Primary Agent**: `documentation`

- [ ] **[Doc update 1]** `[agent:documentation]`
- [ ] **[Doc update 2]** `[agent:documentation]`

## Acceptance Criteria

**Done when all of these are true:**
- [ ] Specific, testable criterion 1
- [ ] Specific, testable criterion 2
- [ ] Specific, testable criterion 3
- [ ] All execution plan items completed
- [ ] Testing Agent validates (see testing plan below)
- [ ] Documentation updated

## Testing Plan

**[[docs/agents/TESTING|Testing Agent]] validates:**
- Specific test 1
- Specific test 2
- No errors in logs
- Performance meets expectations
- [Category-specific validation]

**Manual validation:**
- User-facing test 1
- User-facing test 2

## Related Documentation
- [[docs/relevant-doc-1]]
- [[docs/relevant-doc-2]]
- [[tasks/related-task]]

## Notes

**Priority Rationale**: [Why this priority level? Urgency, risk, value, opportunity?]

**Complexity Rationale**: [Why simple/moderate/complex? Unknowns, design decisions, scope?]

**Implementation Notes**: [Key technical details, gotchas, reminders]

---

## Inline Tag Reference

**Supported tags for execution plan items:**
- `[agent:name]` - Which agent performs this task (testing, docker, infrastructure, security, media, documentation)
- `[depends:task-id]` - This task depends on another task ID being completed first
- `[risk:N]` - This task relates to risk #N from Risk Assessment section
- `[blocking]` - This task blocks other work if not completed
- `[optional]` - This task is optional/nice-to-have

**Examples:**
- `[agent:docker] [depends:task-1]` - Docker agent does this after task-1
- `[agent:testing] [risk:2]` - Testing agent validates risk mitigation #2
- `[agent:infrastructure] [blocking]` - Infra work that blocks other tasks

---

> [!note]- 📋 Work Log
> 
> *Added during execution - document decisions, discoveries, issues encountered*
> 
> ### [YYYY-MM-DD HH:MM] - [Phase/Activity]
> [Notes, decisions, discoveries made during work]
> 
> ### [YYYY-MM-DD HH:MM] - [Phase/Activity]
> [More notes]

> [!tip]- 💡 Lessons Learned
> 
> *Added during/after execution*
> 
> **What Worked Well:**
> - Item 1
> - Item 2
> 
> **What Could Be Better:**
> - Item 1
> - Item 2
> 
> **Scope Evolution:**
> [Did the task change during work? What changed and why?]
> 
> **Future Improvements:**
> - Suggestion 1
> - Suggestion 2
