---
type: task
task-id: IN-038
status: pending
priority: 6
category: documentation
agent: documentation
created: 2025-11-01
updated: 2025-11-01
complexity: simple
estimated_duration: 2h
critical_services_affected: false
requires_backup: false
requires_downtime: false
alternatives_considered: false
risk_assessment_done: true
phased_approach: false
tags:
  - documentation
  - commands
  - mdtd
  - modularization
---

# Modularize /task Command Similar to /create-task and /commit

## Problem Statement

The `/task` command is currently 370 lines with all execution guidance inline, including detailed instructions for pre-task review, strategy development, testing, and completion. Following the successful pattern established with `/create-task` (and planned for `/commit` in IN-037), we should modularize this command to:

1. Make the command file lean and focused on workflow
2. Move detailed guidance to separate, loadable docs
3. Improve context efficiency for AI (load only what's needed)
4. Improve maintainability (update guidance without touching command)

**Current state:**
- Command file: 370 lines with everything inline
- Detailed guidance for 7 execution phases
- All best practices and examples embedded
- No modular documentation structure

**Desired state:**
- Command file: ~150-200 lines focused on process/workflow
- Modular docs: Separate files for each execution aspect
- References: Clear navigation to load docs as needed
- Consistent with `/create-task` pattern

## Solution Design

Apply the same modular pattern used for `/create-task`:

**Command file structure:**
- Quick reference (usage, what it does)
- Critical steps (read task, mark in-progress, move to current/)
- Process flow (concise 7-phase workflow)
- Essential rules
- Reference to modular docs

**Modular documentation (`docs/mdtd/execution/`):**
- `README.md` - Navigation hub for task execution
- `pre-task-review.md` - Critical analysis checklist and common gaps
- `strategy-development.md` - Planning approaches, edge cases, pitfalls
- `work-execution.md` - Best practices during implementation
- `testing-validation.md` - Testing approaches and verification
- `completion.md` - Completion checklist and procedures
- `agent-coordination.md` - When and how to engage specialized agents

**Benefits:**
- Smaller command file loaded every time
- Detailed guidance loaded only when needed (e.g., when doing pre-task review)
- Easier to update execution best practices
- Consistent with other modularized commands

## Scope Definition

### ✅ In Scope
1. Analyze current `/task` command structure
2. Create modular documentation structure under `docs/mdtd/execution/`
3. Extract detailed guidance into focused modules
4. Update command file with lean workflow + references
5. Keep command file ~150-200 lines
6. Validate workflow remains clear and actionable

### ❌ Out of Scope
- Changing the task execution workflow or phases
- Adding new execution phases or requirements
- Creating helper scripts for task execution
- Modifying TodoWrite integration
- Changing how tasks are moved between folders

### 🎯 MVP
Command file restructured with working references to modular docs that contain all necessary execution guidance.

## Risk Assessment

### Identified Risks

1. **Risk:** Breaking existing task execution workflow
   - **Likelihood:** Low
   - **Impact:** Medium (would affect all task work)
   - **Mitigation:** Follow proven `/create-task` pattern, test workflow after restructuring

2. **Risk:** Removing important execution guidance
   - **Likelihood:** Low
   - **Impact:** Low (can be added back easily)
   - **Mitigation:** Review all content carefully, ensure nothing lost in extraction

### Risk Level
**Overall: Low** - Straightforward documentation refactoring with proven pattern

## Execution Plan

### Phase 1: Analysis [agent:documentation]
- [ ] Read current `/task` command completely
- [ ] Identify sections to extract (pre-task review, strategy, testing, completion)
- [ ] Map content to modular doc files
- [ ] Note what stays in command vs what moves
- [ ] Review `/create-task` pattern for consistency

### Phase 2: Create Modular Structure [agent:documentation]
- [ ] Create `docs/mdtd/execution/` directory
- [ ] Create `docs/mdtd/execution/README.md` navigation hub
- [ ] Create `docs/mdtd/execution/pre-task-review.md` with critical analysis guide
- [ ] Create `docs/mdtd/execution/strategy-development.md` with planning guidance
- [ ] Create `docs/mdtd/execution/work-execution.md` with best practices
- [ ] Create `docs/mdtd/execution/testing-validation.md` with testing approaches
- [ ] Create `docs/mdtd/execution/completion.md` with completion checklist
- [ ] Create `docs/mdtd/execution/agent-coordination.md` with agent engagement guide

### Phase 3: Update Command File [agent:documentation]
- [ ] Restructure command to lean format (~150-200 lines)
- [ ] Add "Quick Reference" section at top
- [ ] Add critical steps section
- [ ] Add concise 7-phase workflow
- [ ] Add essential rules
- [ ] Add "Reference Documentation" section with modular doc links
- [ ] Use same pattern as `/create-task` for consistency

### Phase 4: Validation [agent:documentation]
- [ ] Read through updated command file
- [ ] Verify all content accessible via references
- [ ] Check navigation makes sense
- [ ] Confirm workflow still clear and actionable
- [ ] Test that all wiki-links work in Obsidian
- [ ] Verify consistency with `/create-task` pattern

## Acceptance Criteria

- [ ] Command file is ~150-200 lines (target, flexible)
- [ ] All detailed guidance moved to modular docs
- [ ] `docs/mdtd/execution/` directory created with 7 focused files
- [ ] Command file has clear references to modular docs
- [ ] All original information preserved (nothing lost)
- [ ] Structure follows `/create-task` pattern for consistency
- [ ] Navigation hub (`docs/mdtd/execution/README.md`) provides clear guidance
- [ ] Workflow remains clear and actionable
- [ ] All execution plan items completed

## Testing Plan

**Manual Testing:**
1. Read through restructured command
2. Follow references to modular docs
3. Verify task execution workflow still makes sense
4. Check that all needed guidance is accessible
5. Compare pattern to `/create-task` for consistency

**Quality Checks:**
- [ ] All wiki-links resolve correctly
- [ ] No duplicate content between command and docs
- [ ] Modular docs are focused and single-purpose
- [ ] Command file remains actionable workflow guide
- [ ] 7 execution phases clearly represented

## Dependencies

**Blockers:**
- None

**Related:**
- IN-036 (Command system improvements) - Established the modular pattern
- IN-037 (Modularize /commit) - Same pattern, different command

## Notes

### Design Decisions
- Following exact pattern from `/create-task` for consistency
- Using `docs/mdtd/execution/` to group task execution guidance
- Keeping command focused on workflow, not detailed guidance
- Creating separate module for agent coordination (important topic)

### Future Enhancements
- Could add execution pattern examples (infrastructure vs docker vs docs)
- Could add troubleshooting guide for common execution issues
- Could document lessons learned from completed tasks

### Work Log
*Updates will be added here as work progresses*
