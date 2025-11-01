---
type: task
task-id: IN-037
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
  - git
  - modularization
---

# Modularize /commit Command Similar to /create-task

## Problem Statement

The `/commit` command currently has all documentation inline (155 lines total), including detailed explanations of conventional commit format, types, scopes, and examples. Following the successful pattern established with `/create-task`, we should modularize this command to:

1. Make the command file lean and focused on workflow
2. Move detailed reference material to separate, loadable docs
3. Improve context efficiency for AI (load only what's needed)
4. Improve maintainability (update docs without touching command)

**Current state:**
- Command file: 155 lines with everything inline
- No modular documentation structure
- All reference material loaded every time

**Desired state:**
- Command file: ~100 lines focused on process/workflow
- Modular docs: Separate files for types, format, examples, quality checks
- References: Clear navigation to load docs as needed

## Solution Design

Apply the same modular pattern that worked well for `/create-task`:

**Command file structure:**
- Quick reference (usage, what it does)
- Critical steps (analysis, quality checks, staging, commit)
- Process flow (concise workflow)
- Essential rules
- Reference to modular docs

**Modular documentation (`docs/git/`):**
- `README.md` - Navigation hub
- `conventional-commits.md` - Format specification and rules
- `commit-types.md` - Types reference (feat, fix, refactor, etc.)
- `scopes.md` - Project-specific scopes
- `quality-checks.md` - What checks to run and why
- `examples.md` - Good commit message examples from this project

**Benefits:**
- Smaller command file loaded every time
- Detailed reference loaded only when needed
- Easier to update commit standards
- Consistent with `/create-task` pattern

## Scope Definition

### ✅ In Scope
1. Analyze current `/commit` command structure
2. Create modular documentation structure under `docs/git/`
3. Extract detailed content into focused modules
4. Update command file with references to modular docs
5. Keep command file lean (~100 lines)
6. Validate workflow still works

### ❌ Out of Scope
- Changing the commit workflow or process
- Adding new quality checks or validations
- Creating helper scripts (no git scripts needed)
- Modifying other git-related commands
- Changing conventional commit standards

### 🎯 MVP
Command file restructured with working references to modular docs that contain all necessary information.

## Risk Assessment

### Identified Risks

1. **Risk:** Breaking existing commit workflow
   - **Likelihood:** Low
   - **Impact:** Medium (would affect all future commits)
   - **Mitigation:** Test thoroughly after restructuring, keep backup of working version

2. **Risk:** Missing important information during extraction
   - **Likelihood:** Low
   - **Impact:** Low (can be added back easily)
   - **Mitigation:** Review all content, validate nothing lost

### Risk Level
**Overall: Low** - Straightforward documentation refactoring with clear pattern to follow

## Execution Plan

### Phase 1: Analysis [agent:documentation]
- [ ] Read current `/commit` command completely
- [ ] Identify sections to extract (types, scopes, format details, examples)
- [ ] Map content to modular doc files
- [ ] Note what stays in command vs what moves

### Phase 2: Create Modular Structure [agent:documentation]
- [ ] Create `docs/git/` directory
- [ ] Create `docs/git/README.md` navigation hub
- [ ] Create `docs/git/conventional-commits.md` with format spec
- [ ] Create `docs/git/commit-types.md` with types reference
- [ ] Create `docs/git/scopes.md` with project scopes
- [ ] Create `docs/git/quality-checks.md` with checks explained
- [ ] Create `docs/git/examples.md` with good examples

### Phase 3: Update Command File [agent:documentation]
- [ ] Restructure command to lean format (~100 lines)
- [ ] Add "Quick Reference" section at top
- [ ] Add critical steps section
- [ ] Add concise process flow
- [ ] Add essential rules
- [ ] Add "Reference Documentation" section with modular doc links
- [ ] Use same pattern as `/create-task` for consistency

### Phase 4: Validation [agent:documentation]
- [ ] Read through updated command file
- [ ] Verify all content accessible via references
- [ ] Check navigation makes sense
- [ ] Confirm workflow still clear
- [ ] Test that all wiki-links work in Obsidian

## Acceptance Criteria

- [ ] Command file is ~100 lines (target, not strict requirement)
- [ ] All detailed reference content moved to modular docs
- [ ] `docs/git/` directory created with 6-7 focused files
- [ ] Command file has clear references to modular docs
- [ ] All original information preserved (nothing lost)
- [ ] Structure follows `/create-task` pattern for consistency
- [ ] Navigation hub (`docs/git/README.md`) provides clear guidance
- [ ] All execution plan items completed

## Testing Plan

**Manual Testing:**
1. Read through restructured command
2. Follow references to modular docs
3. Verify commit workflow still makes sense
4. Check that all needed information is accessible

**Quality Checks:**
- [ ] All wiki-links resolve correctly
- [ ] No duplicate content between command and docs
- [ ] Modular docs are focused and single-purpose
- [ ] Command file remains actionable workflow guide

## Dependencies

**Blockers:**
- None

**Related:**
- IN-036 (Command system improvements) - Established the pattern we're following

## Notes

### Design Decisions
- Following exact pattern from `/create-task` modularization for consistency
- Keeping command focused on workflow, not reference material
- Using `docs/git/` to parallel other doc structures

### Future Enhancements
- Could add pre-commit hooks documentation
- Could add git workflow patterns (branching, rebasing)
- Could add commit message templates

### Work Log
*Updates will be added here as work progresses*
