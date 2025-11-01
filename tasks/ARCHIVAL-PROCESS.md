---
type: documentation
tags:
  - mdtd
  - process
  - archival
---

# Task Archival Process

This document describes how to archive MDTD tasks, particularly when tasks are superseded by newer approaches or no longer relevant.

## Overview

There are two types of task archival in the MDTD system:

1. **Completed tasks** → Move to `tasks/completed/` with status `completed`
2. **Superseded tasks** → Move to `tasks/archived/` with status `superseded`

## Superseded Tasks

### When to Supersede a Task

A task should be marked as superseded (rather than completed) when:

- **Significant redesign**: Task approach fundamentally changed before starting work
- **Better solution discovered**: New information reveals a superior approach
- **Requirements changed**: Original problem no longer needs solving in that way
- **Replaced by new task**: Explicitly replaced by one or more new tasks with different IDs

### Superseded vs Completed vs Deleted

**Use `superseded` when:**
- Task never started (still in `backlog/`)
- Task approach replaced by different approach
- Historical context valuable for understanding evolution
- Want to preserve research/planning done in original task

**Use `completed` when:**
- Task was executed and all acceptance criteria met
- Work was successful

**Delete task when:**
- Task was duplicate
- Task was mistake/invalid from start
- No historical value in preserving

## Archival Process

### For Superseded Tasks

**Steps:**

1. **Create replacement task(s)** first using `/create-task`
   - New task should reference the superseded task
   - Include note about why approach changed

2. **Update superseded task metadata**:
   ```yaml
   status: superseded
   superseded-by: IN-XXX  # ID of replacement task(s)
   superseded-date: YYYY-MM-DD
   ```

3. **Add supersession note to task body**:
   Add this section before or after the main content:
   ```markdown
   > [!warning]- ⚠️ Task Superseded
   >
   > **Status**: This task has been superseded and will not be completed as originally planned.
   >
   > **Superseded by**: [[tasks/backlog/IN-XXX-new-task|IN-XXX - New Task Title]]
   >
   > **Reason**: [Brief explanation of why approach changed]
   >
   > **Date**: YYYY-MM-DD
   >
   > **Preserved because**: [Why keeping this task for historical reference]
   ```

4. **Create archived directory if needed**:
   ```bash
   mkdir -p tasks/archived
   ```

5. **Move task to archived**:
   ```bash
   git mv tasks/backlog/IN-XXX-old-task.md tasks/archived/
   ```

6. **Update replacement task** to reference archived task:
   ```markdown
   ## Related Documentation
   - [[tasks/archived/IN-XXX-old-task|Original IN-XXX task]] - Superseded by this task
   ```

7. **Stage changes** (don't commit yet):
   ```bash
   git add tasks/archived/IN-XXX-old-task.md
   git add tasks/backlog/IN-YYY-new-task.md
   ```

8. **Ask user for commit approval**

### For Completed Tasks (Normal)

**Steps:**

1. **Complete all acceptance criteria** in the task

2. **Update task metadata**:
   ```yaml
   status: completed
   completed: YYYY-MM-DD
   ```

3. **Fill in lessons learned** section (if applicable)

4. **Move task to completed**:
   ```bash
   git mv tasks/current/IN-XXX-task.md tasks/completed/
   ```

5. **Stage changes** and ask user for commit approval

### For Old Completed Tasks (Periodic Archival)

Over time, `tasks/completed/` can grow large. Periodically archive old completed tasks:

1. **Create date-based subdirectory**:
   ```bash
   mkdir -p tasks/completed/2025-Q4
   ```

2. **Move old completed tasks**:
   ```bash
   git mv tasks/completed/IN-XXX-old-task.md tasks/completed/2025-Q4/
   ```

3. **Keep recent tasks** (last 3-6 months) in root of `completed/`

4. **Extract lessons learned** into docs before archiving if valuable

## Directory Structure

```
tasks/
├── backlog/              # Future work (status: pending)
├── current/              # Active work (status: in-progress)
├── completed/            # Recent completed tasks
│   └── 2025-Q4/         # Older completed tasks (periodic archival)
└── archived/             # Superseded/deprecated tasks
```

## Task Status Values

- `pending` - Not yet started (in backlog/ or current/)
- `in-progress` - Currently being worked on (in current/)
- `blocked` - Waiting on dependency (in current/)
- `completed` - Successfully finished (in completed/)
- `superseded` - Replaced by different approach (in archived/)

## Examples

### Example: Superseded Task

**Original task**: IN-012 - Set up local DNS (generic approach, explored multiple options)

**Replacement task**: IN-034 - Configure Pi-hole for local DNS (specific to existing hardware)

**Why superseded**: Original task explored multiple DNS solutions. User has existing Pi-hole hardware, so specific implementation task created. Original task preserved for research on DNS options.

**Process**:
1. Created IN-034 with Pi-hole-specific approach
2. Updated IN-012 frontmatter with `status: superseded` and `superseded-by: IN-034`
3. Added supersession note to IN-012 body
4. Moved IN-012 to `tasks/archived/`
5. IN-034 references IN-012 for historical context

### Example: Completed Task

**Task**: IN-032 - Implement Emby GPU passthrough

**Process**:
1. Completed all acceptance criteria
2. Updated frontmatter: `status: completed`, `completed: 2025-10-29`
3. Filled in lessons learned section
4. Moved to `tasks/completed/IN-032-implement-emby-gpu-passthrough.md`
5. Created ADR documenting GPU transcoding decision

## Best Practices

### When Superseding Tasks

- **Be generous with supersession**: If approach significantly changed, create new task rather than heavily modifying existing
- **Preserve research**: Original task often contains valuable research/analysis
- **Clear references**: Both tasks should reference each other
- **Explain why**: Document reason for supersession clearly
- **Do it promptly**: Don't let superseded tasks linger in backlog

### When to Keep vs Delete

**Keep (supersede) when:**
- Significant research/analysis done
- Multiple alternatives explored
- Approach changed after discovery/discussion
- Historical context valuable

**Delete when:**
- Duplicate of another task
- Created in error
- No work or research done
- No historical value

### Communication

When superseding a task:
- Update any documentation that references old task
- Update DASHBOARD.md if task was pinned/highlighted
- Communicate with team if others were tracking the task

## Related Documentation

- [[tasks/README|MDTD System Overview]]
- [[docs/AI-COLLABORATION|AI Collaboration Guide]]
- [[docs/agents/DOCUMENTATION|Documentation Agent]]

## Changelog

- **2025-11-01**: Created archival process documentation as part of IN-034/IN-035 creation

