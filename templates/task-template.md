---
type: task
task-id: IN-XXX
status: pending
priority: 5
category: CATEGORY_HERE
agent: AGENT_HERE
created: YYYY-MM-DD
updated: YYYY-MM-DD
started:
completed:

# Task classification
complexity: simple|moderate|complex
estimated_duration: X-Yh
critical_services_affected: true|false
requires_backup: true|false
requires_downtime: true|false

# Design tracking
alternatives_considered: true|false
risk_assessment_done: true|false
phased_approach: true|false

tags:
  - task
  - TAG1
  - TAG2
---

# Task: IN-XXX - [Task Title Here]

> **Quick Summary**: [One-sentence description of what this task accomplishes]

## Problem Statement

**What problem are we solving?**
[Describe the current situation and what's not working or what's needed. Be specific about the pain points or gaps.]

**Why now?**
- [Reason 1 - urgency, enabling other work, good timing, etc.]
- [Reason 2]
- [Reason 3]

**Who benefits?**
- **[Group 1]**: [How they benefit]
- **[Group 2]**: [How they benefit]
- **[Group 3]**: [How they benefit]

## Solution Design

### Recommended Approach

[Describe the chosen approach in detail. What will be built/changed/configured? How will it work?]

**Key components:**
- Component 1: [Description]
- Component 2: [Description]
- Component 3: [Description]

**Rationale**: [Why this approach over alternatives? What makes it the right choice?]

> [!abstract]- 🔀 Alternative Approaches Considered
>
> **Option A: [Name]**
> - ✅ Pros: [Advantage 1]
> - ✅ Pros: [Advantage 2]
> - ❌ Cons: [Disadvantage 1]
> - ❌ Cons: [Disadvantage 2]
> - **Decision**: Not chosen - [reason]
>
> **Option B: [Name]**
> - ✅ Pros: [Advantage 1]
> - ✅ Pros: [Advantage 2]
> - ❌ Cons: [Disadvantage 1]
> - ❌ Cons: [Disadvantage 2]
> - **Decision**: ✅ CHOSEN - [reason]
>
> **Option C: [Name]**
> - ✅ Pros: [Advantage 1]
> - ❌ Cons: [Disadvantage 1]
> - **Decision**: Not chosen - [reason]

### Scope Definition

**✅ In Scope:**
- [Specific deliverable 1]
- [Specific deliverable 2]
- [Specific deliverable 3]

**❌ Explicitly Out of Scope:**
- [Thing we're NOT doing - maybe future task]
- [Thing we're NOT doing - separate concern]
- [Thing we're NOT doing - would cause scope creep]

**🎯 MVP (Minimum Viable)**:
[What's the smallest version we can call "done"? What's essential vs nice-to-have?]

## Risk Assessment

### Potential Pitfalls

- ⚠️ **Risk 1: [Risk name]** → **Mitigation**: [How we'll prevent or handle this]

- ⚠️ **Risk 2: [Risk name]** → **Mitigation**: [How we'll prevent or handle this]

- ⚠️ **Risk 3: [Risk name]** → **Mitigation**: [How we'll prevent or handle this]

- ⚠️ **Risk 4: [Risk name]** → **Mitigation**: [How we'll prevent or handle this]

### Dependencies

**Prerequisites (must exist before starting):**
- [ ] **[Dependency 1]** - [Description] (blocking: yes|no)
- [ ] **[Dependency 2]** - [Description] (blocking: yes|no)
- [ ] **[Dependency 3]** - [Description] (blocking: yes|no)

**[No blocking dependencies / Has blocking dependencies] - [can start immediately / blocked by X]**

### Critical Service Impact

**Services Affected**: [None / List services]

[If critical services affected:]
- **Emby (VM 100)**: [Impact description]
- **Downloads (VM 101)**: [Impact description]
- **Arr services (VM 102)**: [Impact description]

[If no critical services affected:]
[Describe impact level and why no critical services affected]

### Rollback Plan

**Applicable for**: [Type of work - infrastructure/docker/security/etc.]

**How to rollback if this goes wrong:**
1. [Rollback step 1]
2. [Rollback step 2]
3. [Rollback step 3]

**Recovery time estimate**: [Time estimate]

**Backup requirements:**
- [What needs to be backed up before proceeding]
- [Where backups should be stored]

## Execution Plan

### Phase 0: Discovery/Inventory (if needed)

**Primary Agent**: `[agent-name]`

- [ ] **[Task item 1]** `[agent:name]`
  - [Sub-task or detail]
  - [Sub-task or detail]

- [ ] **[Task item 2]** `[agent:name]` `[depends:IN-XXX]`
  - [Sub-task or detail]

### Phase 1: [Phase Name]

**Primary Agent**: `[agent-name]`

- [ ] **[Task item 1]** `[agent:name]` `[risk:1]`
  - [Sub-task or detail]
  - [Sub-task or detail]

- [ ] **[Task item 2]** `[agent:name]` `[blocking]`
  - [Sub-task or detail]

- [ ] **[Task item 3]** `[agent:name]` `[optional]`
  - [Sub-task or detail]

### Phase 2: [Phase Name]

**Primary Agent**: `[agent-name]`

- [ ] **[Task item 1]** `[agent:name]`
  - [Sub-task or detail]

- [ ] **[Task item 2]** `[agent:name]`
  - [Sub-task or detail]

### Phase 3: Validation & Testing

**Primary Agent**: `testing`

- [ ] **[Test item 1]** `[agent:testing]`
  - [Validation detail]

- [ ] **[Test item 2]** `[agent:testing]`
  - [Validation detail]

### Phase 4: Documentation

**Primary Agent**: `documentation`

- [ ] **[Documentation task]** `[agent:documentation]`
  - [What needs to be documented]

## Acceptance Criteria

**Done when all of these are true:**
- [ ] [Specific, testable criterion 1]
- [ ] [Specific, testable criterion 2]
- [ ] [Specific, testable criterion 3]
- [ ] [Specific, testable criterion 4]
- [ ] All execution plan items completed
- [ ] Testing Agent validates (see testing plan below)
- [ ] Changes committed with descriptive message (awaiting user approval)

## Testing Plan

**[[docs/agents/TESTING|Testing Agent]] validates:**
- [Automated test 1]
- [Automated test 2]
- [Validation check 1]
- [Validation check 2]

**Manual validation:**
1. [Manual test step 1 - what to check and expected result]
2. [Manual test step 2 - what to check and expected result]
3. [Manual test step 3 - what to check and expected result]

## Related Documentation

- [[docs/RELEVANT-DOC|Description]]
- [[docs/agents/AGENT-NAME|Agent Documentation]]
- [[docs/adr/NNN-relevant-decision|ADR Description]]
- [[tasks/backlog/IN-XXX-related-task|Related Task]]

## Notes

**Priority Rationale**:
[Why this priority level? What makes it more/less urgent than other work?]

**Complexity Rationale**:
[Why simple/moderate/complex? What makes it straightforward or challenging?]

**Implementation Notes**:
- [Important consideration 1]
- [Important consideration 2]
- [Important consideration 3]

**Follow-up Tasks**:
- IN-XXX: [Description of related future work]
- IN-XXX: [Description of related future work]

---

> [!note]- 📋 Work Log
>
> **YYYY-MM-DD - [Milestone]**
> - [What was accomplished]
> - [Important decisions made]
> - [Issues encountered and resolved]
>
> **YYYY-MM-DD - [Milestone]**
> - [What was accomplished]
> - [Important decisions made]

> [!tip]- 💡 Lessons Learned
>
> *Fill this in AS YOU GO during task execution. Not every task needs extensive notes here, but capture important learnings that could affect future work.*
>
> **What Worked Well:**
> - [What patterns/approaches were successful that we should reuse?]
> - [What tools/techniques proved valuable?]
>
> **What Could Be Better:**
> - [What would we do differently next time?]
> - [What unexpected challenges did we face?]
> - [What gaps in documentation/tooling did we discover?]
>
> **Key Discoveries:**
> - [Did we learn something that affects other systems/services?]
> - [Are there insights that should be documented elsewhere (runbooks, ADRs)?]
> - [Did we uncover technical debt or improvement opportunities?]
>
> **Scope Evolution:**
> - [How did the scope change from original plan and why?]
> - [Were there surprises that changed our approach?]
>
> **Follow-Up Needed:**
> - [Documentation that should be updated based on this work]
> - [New tasks that should be created]
> - [Process improvements to consider]
