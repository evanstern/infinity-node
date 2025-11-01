# Task Execution - Complete Task Workflow

Execute a MDTD task from start to finish with comprehensive planning, review, and documentation.

## Quick Reference

**Usage:** `/task IN-XXX [optional context]`

**What it does:**
- Guides through complete task lifecycle
- Ensures critical review before starting
- Maintains scope discipline during work
- Validates thoroughly before completion
- Manages git workflow properly

**Need detailed guidance?** Load docs as needed:
- [[docs/mdtd/execution/README]] - Navigation hub for all execution guidance
- [[docs/mdtd/execution/pre-task-review]] - Critical analysis before starting
- [[docs/mdtd/execution/strategy-development]] - Planning and risk identification
- [[docs/mdtd/execution/work-execution]] - Best practices during implementation
- [[docs/mdtd/execution/testing-validation]] - Verification approaches
- [[docs/mdtd/execution/completion]] - Finalization and handoff
- [[docs/mdtd/execution/agent-coordination]] - Multi-agent coordination

---

## Usage

```
/task IN-XXX [optional context]
```

**Arguments:**
- `IN-XXX` (required): Task ID (e.g., IN-001, IN-015)
- `[optional context]` (optional): Additional context, clarification, or emphasis

**Examples:**
```
/task IN-005
/task IN-012 focus on docker DNS integration first
/task IN-004 prioritize the deployment guide section
/task IN-015 user reported issues with the arr stack specifically
```

---

## 🚨 CRITICAL - Do These First

1. **Read task completely** (`find tasks/ -name "IN-XXX-*.md"`)
2. **Pre-task review** (load [[docs/mdtd/execution/pre-task-review]]) - Check gaps/risks
3. **Develop strategy** (load [[docs/mdtd/execution/strategy-development]]) - Get approval
4. **Update & move task:**
   ```bash
   status: in-progress | started: YYYY-MM-DD
   git mv tasks/backlog/IN-XXX-*.md tasks/current/IN-XXX-*.md
   ```
5. **🚨 DO NOT COMMIT** - Only at end after approval

---

## Process Flow

### Phase 1: Pre-Task Review

**IMPORTANT:** Conduct thorough review before beginning (except for trivial tasks).

**Load:** [[docs/mdtd/execution/pre-task-review]]

**Quick checklist:**
- [ ] Task still relevant? (check if outdated)
- [ ] Scope clear with inventory?
- [ ] Should this be phased?
- [ ] Rollback plan needed?
- [ ] Testing criteria specific?
- [ ] Dependencies ready?
- [ ] Critical services affected?
- [ ] Timing consideration needed?
- [ ] Security handled properly?

**If issues found:**
1. Present findings to user
2. Get approval to update task
3. Update task file
4. Proceed to strategy

---

### Phase 2: Strategy Development

**Take time for thoughtful planning.**

**Load:** [[docs/mdtd/execution/strategy-development]]

**Quick checklist:**
- [ ] Analyzed 2-3 implementation options
- [ ] Identified edge cases
- [ ] Evaluated pitfalls (critical vs future work)
- [ ] Planned agent coordination
- [ ] Documented strategy clearly
- [ ] Got user approval

**Present strategy to user before proceeding.**

---

### Phase 3: Begin Execution

**Once strategy approved:**

1. **Update task & move to current:**
   ```bash
   # Update frontmatter
   status: in-progress
   started: YYYY-MM-DD

   # Move to current folder
   git mv tasks/backlog/IN-XXX-*.md tasks/current/IN-XXX-*.md
   ```

2. **🚨 DO NOT COMMIT** - Only commit at end

3. **Use TodoWrite:**
   - Break work into session tasks
   - Track progress
   - Mark complete as you go

---

### Phase 4: Execute Work

**Load:** [[docs/mdtd/execution/work-execution]]

**Core principles:**
- Task is source of truth (don't deviate)
- Follow approved strategy
- Test incrementally after each phase
- Document continuously, not at end

**Quick checklist:**
- [ ] Working through phases in order
- [ ] Testing after each phase
- [ ] Engaging appropriate agents
- [ ] Updating task continuously (check off items, add work log)
- [ ] Noting lessons learned as discovered
- [ ] Watching for script opportunities

**If new work emerges:**
- Stop and discuss with user
- Update task OR create new task
- Never diverge silently

---

### Phase 5: Testing & Validation

**Load:** [[docs/mdtd/execution/testing-validation]]

**Before marking complete:**

- [ ] Verify ALL acceptance criteria explicitly
- [ ] Test edge cases (not just happy path)
- [ ] Verify error handling
- [ ] Check dependent services (no negative impact)
- [ ] Run automated tests if applicable
- [ ] Manual validation of functionality
- [ ] Testing Agent validation if needed

---

### Phase 6: Completion

**Load:** [[docs/mdtd/execution/completion]]

**When work finished and tested:**

1. **Final task update:**
   - [ ] All acceptance criteria checked off
   - [ ] All progress notes complete
   - [ ] Final outcomes documented
   - [ ] Comprehensive lessons learned section added
   - [ ] Follow-up tasks noted

2. **Update status:**
   ```yaml
   status: completed
   completed: YYYY-MM-DD
   ```

3. **Move to completed:**
   ```bash
   git mv tasks/current/IN-XXX-*.md tasks/completed/IN-XXX-*.md
   git add tasks/completed/IN-XXX-*.md
   git add [other changed files]
   ```

4. **🚨 VERIFY clean state:**
   ```bash
   git status
   ```
   - Check for duplicate task files
   - Check for unstaged deletions
   - Clean up if found

5. **Update references** (if needed - usually not)

6. **Present work to user:**
   - Summary of what was accomplished
   - Files changed
   - Testing results
   - Follow-up tasks created

7. **🚨 ASK USER:** "Would you like me to commit these changes?"
   - **NEVER commit without explicit approval**
   - If approved: use `/commit` command

---

## Important Rules

### Scope Management
- **Task is source of truth** - do not deviate
- If new work needed: update task OR create new task
- Discuss scope changes with user
- Document all changes in task file

### Safety
- Always backup before destructive operations
- Test incrementally, not all at once
- For critical services: extra caution, timing consideration (3-6 AM)
- Have rollback plan ready

### Documentation
- Update task file continuously, not at end
- Document "why" behind decisions
- Capture lessons learned as discovered
- Keep notes detailed for future reference

### Commits
- **ALWAYS ask before committing**
- Never commit without explicit user approval
- Use `/commit` command when approved
- Include task reference in commit message

### Agent Coordination
- Engage appropriate agents for their domains
- Follow agent assignments from strategy
- Provide clear deliverables for handoffs
- See [[docs/mdtd/execution/agent-coordination]] for details

### Flexibility
- Scope may evolve during work - this is OK
- Discovery may change task nature
- Communicate findings and adjust accordingly
- Update task to reflect actual work performed

---

## Reference Documentation

**Load modular docs as needed** (don't load everything!):

**Core execution guidance:**
- [[docs/mdtd/execution/README]] - Navigation hub for all execution docs
- [[docs/mdtd/execution/pre-task-review]] - Critical analysis checklist
- [[docs/mdtd/execution/strategy-development]] - Planning and risk identification
- [[docs/mdtd/execution/work-execution]] - Best practices during work
- [[docs/mdtd/execution/testing-validation]] - Verification approaches
- [[docs/mdtd/execution/completion]] - Finalization procedures
- [[docs/mdtd/execution/agent-coordination]] - Multi-agent coordination

**Related systems:**
- [[docs/mdtd/README]] - MDTD documentation index
- [[docs/mdtd/overview]] - MDTD philosophy
- [[docs/agents/README]] - Agent system overview
- [[tasks/README]] - Task management
- [[docs/AI-COLLABORATION#MDTD]] - MDTD in AI collaboration context
