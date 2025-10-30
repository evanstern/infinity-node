---
type: task
task-id: IN-029
status: pending
priority: 2
category: documentation
agent: documentation
created: 2025-10-30
updated: 2025-10-30

# Task classification
complexity: simple
estimated_duration: 30min
critical_services_affected: false
requires_backup: false
requires_downtime: false

tags:
  - task
  - documentation
  - workflow
  - process-improvement
---

# Task: IN-029 - Enforce Critical Task Workflow Steps

> **Quick Summary**: Ensure AI assistants follow critical workflow steps consistently: task start process, real-time execution plan updates, and commit discipline

## Problem Statement

**What problem are we solving?**
Multiple recurring issues where AI assistants skip critical documented workflow steps:
1. **IN-026, IN-024**: Didn't commit immediately after moving to current/, causing duplicate files
2. **IN-027**: Didn't check off execution plan items in real-time as phases completed
3. **IN-027**: Created intermediate commits during task execution instead of only at the end

These workflows are documented in `.cursorrules` and `docs/AI-COLLABORATION.md`, but critical steps are being skipped.

**Why now?**
These issues have happened multiple times. Documentation exists and is correct, but AI assistants aren't following it consistently. Need stronger enforcement mechanisms and clearer emphasis.

**Who benefits?**
- **User**: Clean git history, no manual cleanup of duplicate files
- **Claude**: Clear, impossible-to-miss workflow steps
- **Project**: Consistent process adherence

## Solution Design

### Recommended Approach

**Make critical workflow steps self-enforcing through explicit emphasis:**

**Issue 1: Task Start Process (duplicate files)**
- Add explicit "🚨 CRITICAL" markers in `.cursorrules` and `docs/AI-COLLABORATION.md`
- Emphasize the rationale inline: "Git will collapse moves if you skip this"
- Make step formatting unmissable

**Issue 2: Real-time Execution Plan Updates**
- Add prominent reminder in "During Task Execution" section
- Emphasize: "Check off execution plan items AS YOU COMPLETE each phase"
- Link back to task workflow documentation
- Make it clear this is REQUIRED, not optional

**Issue 3: Commit Discipline**
- Emphasize "NEVER commit without explicit user approval"
- Add warnings about intermediate commits breaking workflow
- Make "wait for approval" step unmissable
- Update `.cursorrules` to be explicit about this

**Key insight:** Documentation exists and is correct. Problem is execution/attention, not knowledge. Need visual emphasis and repetition of critical steps.

## Execution Plan

### Phase 1: Update AI-COLLABORATION.md

**Primary Agent**: `documentation`

- [ ] **Update "Task Execution Workflow" section**
  - Add 🚨 markers for critical steps
  - Emphasize "During Task Execution" must include real-time execution plan updates
  - Make commit discipline unmissable: "NEVER commit without explicit user approval"
  - Add inline rationale for each critical step

- [ ] **Add prominent "Critical Workflow Requirements" section**
  - List all three critical issues with emphasis
  - Make it impossible to miss
  - Include consequences of skipping steps

### Phase 2: Update .cursorrules

**Primary Agent**: `documentation`

- [ ] **Strengthen MDTD workflow section**
  - Add 🚨 CRITICAL markers
  - Emphasize: "Check off execution plan items AS YOU COMPLETE THEM"
  - Make commit discipline explicit: "Do NOT commit during task execution"
  - Add inline rationale

- [ ] **Add enforcement reminders**
  - Repeat critical points for emphasis
  - Use formatting to break reading flow (force attention)

### Phase 3: Update docs/CURSOR.md

**Primary Agent**: `documentation`

- [ ] **Document the complete workflow**
  - Explain task start process and why immediate commit matters
  - Document real-time execution plan updates requirement
  - Explain commit discipline and why it matters
  - Show consequences of skipping steps

### Phase 4: Validation

**Primary Agent**: `testing`

- [ ] **Review updated documentation**
  - Verify all three critical issues are addressed
  - Ensure formatting makes steps unmissable
  - Check that rationale is inline where needed
  - Confirm emphasis/markers are effective

- [ ] **Test in practice**
  - Next task start: verify no intermediate commits, proper file handling
  - During task: verify execution plan items checked off in real-time
  - Task completion: verify commit only happens after user approval

## Acceptance Criteria

**Done when all of these are true:**
- [ ] `docs/AI-COLLABORATION.md` updated with 🚨 markers for all three critical issues
- [ ] `.cursorrules` strengthened with explicit checkpoints and commit discipline
- [ ] `docs/CURSOR.md` updated to document complete workflow for users
- [ ] All three recurring issues addressed with inline rationale
- [ ] Documentation reviewed for clarity and effectiveness
- [ ] Changes committed (after user approval)
- [ ] Process tested on next task (IN-030 or later)

## Testing Plan

**Validation:**
- Test on next task start (follow workflow exactly as documented)
- Verify no duplicate files appear in `tasks/current/`
- Confirm git shows clean single move in history

**Success criteria:**
- No untracked files after task completion
- Git history shows two separate commits:
  1. `chore: start task IN-XXX` (move to current)
  2. Completion commit (move to completed with work)

## Related Documentation

- [[.cursorrules|Project Rules]]
- [[AI-COLLABORATION|Working with AI Assistants]]
- [[CURSOR|Cursor IDE Guide]]
- [[tasks/README|MDTD System]]

## Notes

**Root Cause Analysis:**
- Documentation: ✅ Correct and clear
- Visibility: ⚠️ Present but not emphasized enough
- Execution: ❌ AI assistants skipping critical steps repeatedly
- Impact:
  - Duplicate files requiring manual cleanup
  - Incomplete task documentation (execution plan not checked off)
  - Extra commits that need to be backed out

**Why This Happened:**
- AI assistant focused on task execution over process adherence
- Critical steps look like "just another step" not critical checkpoints
- No visual/formatting cues to emphasize importance
- Easy to skip when eager to start actual work or move to next phase

**Recurring Issues:**
1. **IN-024**: Duplicate file from skipping immediate commit
2. **IN-026**: Same issue - didn't commit after move to current/
3. **IN-027**:
   - Created intermediate commits (had to back out 2 commits)
   - Didn't check off execution plan items in real-time
   - Fixed after user intervention

**Solution:**
- Make ALL critical steps visually unmissable with 🚨 markers
- Add inline rationale so context is immediate
- Use checkpoint language that demands acknowledgment
- Format to break the reading flow (forcing attention)
- Repeat critical requirements for emphasis

**Future Improvements:**
- Could create a `/start-task IN-XXX` command that automates steps 1-3
- Could add a git hook that warns if task moves aren't committed separately
- Could create a task management script that enforces the workflow

---

> [!note]- 📋 Work Log
>
> *Added during execution - document decisions, discoveries, issues encountered*

> [!tip]- 💡 Lessons Learned
>
> *Added during/after execution*
>
> **What Worked Well:**
>
> **What Could Be Better:**
>
> **Future Improvements:**
