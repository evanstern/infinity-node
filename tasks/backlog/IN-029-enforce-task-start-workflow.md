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

# Task: IN-029 - Enforce Task Start Workflow

> **Quick Summary**: Ensure Claude follows the 3-step task start workflow consistently to prevent duplicate file issues

## Problem Statement

**What problem are we solving?**
IN-026 created a duplicate file issue because Claude didn't follow the documented workflow step 3: "COMMIT immediately after moving to current/". The workflow is documented in `.cursorrules` and `docs/CLAUDE.md`, but Claude skipped the immediate commit step, causing git to collapse moves.

**Why now?**
This is the second time this has happened (also occurred in IN-024). We fixed the documentation after IN-024, but the issue recurred, indicating we need stronger enforcement mechanisms.

**Who benefits?**
- **User**: Clean git history, no manual cleanup of duplicate files
- **Claude**: Clear, impossible-to-miss workflow steps
- **Project**: Consistent process adherence

## Solution Design

### Recommended Approach

**Make the workflow self-enforcing through explicit checkpoints:**

1. **Add explicit "checkpoint" language** in `.cursorrules` that Claude must acknowledge
2. **Create a simple checklist format** that's harder to skip
3. **Update docs/CURSOR.md** to document this for users
4. **Consider adding emphasis/formatting** to make step 3 unmissable

**Key insight:** Documentation exists and is correct. Problem is execution/attention, not knowledge.

## Execution Plan

### Phase 1: Strengthen Documentation

**Primary Agent**: `documentation`

- [ ] **Update .cursorrules with explicit checkpoints**
  - Add "🚨 CRITICAL CHECKPOINT" markers
  - Reformat step 3 to be unmissable
  - Add rationale inline: "Git will collapse moves if you skip this"

- [ ] **Update docs/CLAUDE.md similarly**
  - Make step 3 visually distinct
  - Add inline warning about consequences
  - Emphasize the IMMEDIATE part

- [ ] **Update docs/CURSOR.md**
  - Document the workflow for users to understand
  - Explain why the immediate commit matters
  - Show the consequences of skipping it

### Phase 2: Validation

**Primary Agent**: `testing`

- [ ] **Review updated documentation**
  - Verify checkpoints are clear
  - Ensure formatting is effective
  - Check that rationale is inline where needed

- [ ] **Test in practice**
  - Next time starting a task, verify workflow is followed
  - Confirm no duplicate files created

## Acceptance Criteria

**Done when all of these are true:**
- [ ] `.cursorrules` updated with checkpoint markers for step 3
- [ ] `docs/CLAUDE.md` updated with emphasis on immediate commit
- [ ] `docs/CURSOR.md` updated to document workflow for users
- [ ] Documentation reviewed for clarity and effectiveness
- [ ] Changes committed
- [ ] Process tested on next task start (IN-030 or later)

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
- [[docs/CLAUDE|Working with AI Assistants]]
- [[docs/CURSOR|Cursor IDE Guide]]
- [[tasks/README|MDTD System]]

## Notes

**Root Cause Analysis:**
- Documentation: ✅ Correct and clear
- Visibility: ⚠️ Present but not emphasized enough
- Execution: ❌ Claude skipped step 3
- Impact: Duplicate file requiring manual cleanup

**Why This Happened:**
- Claude focused on task execution over process adherence
- Step 3 looks like "just another step" not a critical checkpoint
- No visual/formatting cues to emphasize importance
- Easy to skip when eager to start actual work

**Solution:**
- Make step 3 visually unmissable
- Add inline rationale so context is immediate
- Use checkpoint language that demands acknowledgment
- Format to break the reading flow (forcing attention)

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
