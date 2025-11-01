---
type: documentation
tags:
  - mdtd
  - philosophy
  - overview
---

# MDTD Overview - Philosophy & When to Create Tasks

Quick reference for understanding the MDTD (Markdown Task-Driven Development) system.

## Philosophy

### Why Invest Time in Task Creation?

**Good task creation = better execution**

Time invested upfront:
- ✅ Fewer surprises during execution
- ✅ Better solutions (considered alternatives)
- ✅ Smoother execution (planned for risks)
- ✅ Less rework (clear scope)
- ✅ Faster completion (clear plan)

### Pragmatic Balance

Match effort to task size:
- **Simple tasks**: 5-10 minutes to create
- **Moderate tasks**: 10-20 minutes to create
- **Complex tasks**: 30-60 minutes to create

**Rule of thumb**: Task creation should be ~10-20% of estimated execution time.

### Refinement is Expected

Tasks are **starting points**, not contracts.

- Create task: Define initial approach
- Pre-task review: Critically analyze and refine
- Execution: Scope can evolve (document changes)

**This is by design** - create first, refine before execution.

---

## When to Create Tasks

### Always Create a Task For:

✅ **Work taking > 1 hour**
- Needs planning and tracking
- May span multiple sessions
- Requires documentation

✅ **Work affecting critical services**
- Emby, downloads, arr services
- Requires backup/rollback planning
- Needs careful execution tracking

✅ **Work enabling other work**
- Unblocks multiple tasks
- Creates infrastructure for future use
- Worth documenting approach

✅ **Exploratory/research work**
- Document findings for future reference
- Track what was investigated
- Capture lessons learned

### Don't Create Tasks For:

❌ **Trivial one-off operations**
- Quick terminal commands
- Simple file edits
- Reading documentation

❌ **Emergencies requiring immediate action**
- Production down
- Security incident
- Create task AFTER fixing to document what happened

❌ **Already-documented routine operations**
- Following existing runbook
- Standard deployment procedure
- Unless you're improving the process

---

## The MDTD Workflow

```
Create Task → Pre-Task Review → Execute → Document → Complete
    ↓              ↓               ↓          ↓          ↓
  Backlog      Refine Plan     Current    Work Log   Completed
               Add Detail      Folder     Updates     Folder
```

### Task Lifecycle

1. **Creation** (`/create-task`): Initial design and planning
2. **Review** (`/task IN-NNN`): Critical analysis before starting
3. **Execution**: Work through phases, document progress
4. **Completion**: Mark complete, capture lessons learned

### Files Live in State Folders

```
tasks/
├── backlog/      Status: pending/backlog
├── current/      Status: in-progress
└── completed/    Status: completed
```

---

## Related Documentation

**Commands:**
- [[.claude/commands/create-task]] - Task creation command
- [[.claude/commands/task]] - Task execution command

**Phase Guides:**
- [[phases/01-understanding]] - Classification and assessment
- [[phases/02-solution-design]] - Evaluating alternatives
- [[phases/03-risk-assessment]] - Risk identification
- [[phases/04-scope-definition]] - Defining boundaries
- [[phases/05-execution-planning]] - Structuring work

**System Documentation:**
- [[docs/AI-COLLABORATION#MDTD]] - Full MDTD system description
- [[tasks/README]] - Task management details
