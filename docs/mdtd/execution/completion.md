---
type: documentation
category: mdtd
tags:
  - task-execution
  - completion
  - git-workflow
created: 2025-11-01
updated: 2025-11-01
---

# Completion

Task finalization and handoff procedures.

## Completion Checklist

### 1. Final Task Update

- [ ] All acceptance criteria checked off
- [ ] All progress notes completed
- [ ] Final outcomes documented
- [ ] Comprehensive lessons learned added
- [ ] Work log shows clear progression
- [ ] Follow-up tasks noted
- [ ] Timestamps updated

**Lessons learned structure:**
```markdown
## Lessons Learned

### What Went Well
- [Item 1]
- [Item 2]

### What Could Be Improved
- [Item 1]
- [Item 2]

### For Future Tasks
- [Recommendation 1]
- [Recommendation 2]

### Technical Discoveries
- [Discovery 1]
- [Discovery 2]
```

### 2. Update Status

Set in frontmatter:
```yaml
status: completed
completed: YYYY-MM-DD
```

### 3. Move to Completed Folder

Use git mv to preserve history:
```bash
git mv tasks/current/IN-XXX-task.md tasks/completed/IN-XXX-task.md
git add tasks/completed/IN-XXX-task.md
git add [other changed files]
```

### 4. Verify Clean State

**Critical verification:**
```bash
git status
```

**Check for:**

❌ **Lingering task files** - Same task ID in multiple locations
❌ **Unstaged deletions** - Old task file not staged
❌ **Unexpected changes** - Files modified that shouldn't be

**Clean state looks like:**
```bash
$ git status
On branch main
Changes to be committed:
  renamed:  tasks/current/IN-XXX-task.md -> tasks/completed/IN-XXX-task.md
  modified: stacks/service/docker-compose.yml
  new file: docs/service-runbook.md
```

**If duplicates found:**
```bash
# Delete incorrect duplicate, stage deletion
rm tasks/backlog/IN-XXX-task.md
git add tasks/backlog/IN-XXX-task.md
```

### 5. Update References (If Needed)

Usually not needed (Obsidian resolves by filename, not path).

**Only if links break:**
```bash
# Find references
grep -r "IN-XXX" docs/ tasks/

# Update if needed:
# From: [[tasks/current/IN-XXX-task]]
# To: [[tasks/completed/IN-XXX-task]]
```

---

## Ask About Commit

### 6. Present Summary

```markdown
## Task IN-XXX Complete

**Summary:**
[One paragraph of what was accomplished]

**Changes made:**
- [Change 1]
- [Change 2]

**Files changed:**
- tasks/current/IN-XXX-task.md → tasks/completed/IN-XXX-task.md
- [Other files]

**Testing:**
✓ All acceptance criteria met
✓ Edge cases tested
✓ No impact on existing services

**Follow-up tasks:**
- IN-XXX: [Description]

Would you like me to commit these changes?
```

### 7. Wait for Approval

**Critical rules:**
- **ALWAYS ask before committing**
- **NEVER commit without explicit approval**
- Present changes clearly
- Wait for user response

### 8. If Approved: Use /commit

```
/commit "feat: deploy Service X

Addresses IN-XXX

- Deploy Service X stack
- Configure integrations
- Create documentation"
```

---

## What NOT to Do

❌ **Commit without approval** - User didn't review
❌ **Mark complete without testing** - Changes might not work
❌ **Incomplete documentation** - No detail for future reference
❌ **Leave git state messy** - Duplicates and unstaged changes

---

## Special Cases

### Task Partially Complete

If couldn't complete everything:

1. Document what was completed
2. Document what remains
3. Create follow-up task for remainder
4. Update current task to reflect actual scope
5. Mark current task complete (for adjusted scope)

### Task Cancelled

If no longer needed:

1. Update: `status: cancelled`
2. Document why in task
3. Move to completed/ (not deleted - preserves history)
4. Add: `cancelled: YYYY-MM-DD`

### Task Blocked

If can't proceed:

1. Update: `status: blocked`
2. Document blocker clearly
3. Keep in current/
4. Create unblocking task
5. Link tasks

---

## After Commit

Once committed:

1. **Confirm success:**
   ```
   ✅ Changes committed
   Commit: abc1234 "feat: ..."
   ```

2. **Note next steps:**
   - Follow-up tasks ready
   - Any monitoring needed

3. **Task lifecycle complete:**
   ```
   IN-XXX: backlog → current → completed ✓
   ```

---

## Related

- [[testing-validation]] - Before completion
- [[docs/AI-COLLABORATION#Git Workflow]] - Commit guidelines
- [[.claude/commands/commit]] - /commit command
- [[tasks/README]] - MDTD system overview
