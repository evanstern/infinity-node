---
type: documentation
category: mdtd
tags:
  - task-execution
  - implementation
  - best-practices
created: 2025-11-01
updated: 2025-11-01
---

# Work Execution

Best practices during implementation to stay aligned with scope and maintain quality.

## Core Principles

### Task is Source of Truth
- Do NOT make changes outside task scope
- If new work needed: stop and discuss
- Either update task or create new task
- Never diverge silently

### Follow the Strategy
- Work through phases in order
- Test incrementally
- Document progress continuously

### Update in Real-Time
- Check off acceptance criteria as completed
- Add work log entries after each phase
- Document decisions and rationale
- Note lessons learned as discovered

---

## Execution Checklist

### During Each Phase

- [ ] **Complete phase work**
  - Follow approved strategy
  - Make changes carefully
  - Keep rollback option available

- [ ] **Test incrementally**
  - Verify phase succeeded
  - Don't accumulate untested changes
  - Catch issues early

- [ ] **Document immediately**
  - What was completed
  - Decisions made and why
  - Issues encountered and solutions
  - What's next

### Working with Agents

**Engage appropriate agents:**

- [ ] Security Agent - Secrets, tunnels, VPN
- [ ] Docker Agent - Containers, stacks, Portainer
- [ ] Infrastructure Agent - VMs, Proxmox, networking
- [ ] Testing Agent - Validation, verification
- [ ] Media Stack Agent - Critical services
- [ ] Documentation Agent - Docs, runbooks

**Coordination:**
- Follow agent assignments from strategy
- Provide clear deliverables for handoffs
- Verify handoff complete before proceeding

### Notice Script Opportunities

**Watch for repeated patterns:**
- Same commands with different parameters
- Multi-step procedures done frequently
- Complex operations needing standardization

**When found:**
1. Note pattern in work log
2. Propose script to user
3. Create if approved
4. Use immediately to validate

---

## Work Log Pattern

```markdown
## Work Log

### YYYY-MM-DD HH:MM - Phase N: [Phase Name]

**Completed:**
- [Item 1]
- [Item 2]

**Decisions:**
- [Decision]: [Rationale]

**Issues Encountered:**
- [Issue]: [Resolution]

**Lessons Learned:**
- [Learning that affects future work]

**Next:** Phase N+1 - [Brief description]
```

---

## Scope Management

### Stay Focused

✅ Do work in task scope
❌ Don't expand scope silently

### Handle Discoveries

**Minor addition (< 30 min, low risk):**
- Add to current task if clearly related
- Update acceptance criteria
- Get user confirmation

**Significant addition (> 30 min or unrelated):**
- Stop current work
- Present to user
- Propose: add vs new task
- Create follow-up task if deferring

**Blocker (prevents completion):**
- Document blocker clearly
- Propose resolution
- Update task requirements
- Adjust timeline/phases

---

## Safety Practices

### For All Work
- [ ] Backup before destructive operations
- [ ] Test in isolation when possible
- [ ] Verify before next phase
- [ ] Document rollback steps
- [ ] Monitor after changes

### For Critical Services (Emby/downloads/arr)
- [ ] Backup configurations
- [ ] Document current state
- [ ] Work during low-usage windows (3-6 AM)
- [ ] Test incrementally
- [ ] Keep rollback ready
- [ ] Monitor for 24 hours after

---

## Common Pitfalls

❌ **Scope creep** - "While here, let me also fix X, Y, Z..."
→ Note as future work, complete current task

❌ **Untested accumulation** - Change 5 things, test once
→ Test after each change

❌ **Undocumented decisions** - Make choice, don't note why
→ Document every decision with rationale

❌ **Silent deviations** - Strategy says X, do Y without discussion
→ Explain why strategy won't work, get approval

---

## Related

- [[strategy-development]] - Planning before execution
- [[testing-validation]] - Verification after execution
- [[agent-coordination]] - Working with specialized agents
- [[completion]] - Finishing and handing off work
- [[docs/agents/README]] - Agent capabilities
