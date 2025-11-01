---
type: documentation
tags:
  - mdtd
  - system
---

# Markdown-Driven Task Development (MDTD) System

This directory contains the **MDTD** system for managing tasks, projects, and work across the infinity-node infrastructure.

## Overview

The MDTD system uses simple markdown files with YAML frontmatter to track tasks. This approach:
- ✅ **Git-friendly**: Every task is version controlled
- ✅ **Obsidian-enhanced**: Powerful queries and visualizations with Dataview
- ✅ **Claude Code compatible**: Easy for AI to read, create, and modify
- ✅ **No lock-in**: Just markdown files, works with any tool
- ✅ **Searchable**: Full-text search across all tasks

## Directory Structure

```
tasks/
├── README.md           # This file
├── current/            # Active tasks (in-progress or pending)
├── backlog/            # Future tasks (not started)
├── completed/          # Finished tasks (archived)
└── DASHBOARD.md        # Task overview (Dataview queries)
```

## Task Structure

Each task is a markdown file following this format:

```markdown
---
type: task
status: pending
priority: medium
category: infrastructure
agent: docker
created: 2025-10-24
updated: 2025-10-24
tags:
  - task
  - docker
  - critical
---

# Task: Deploy New Service Stack

## Description
Clear description of what needs to be done...

## Context
Background information, why this task is needed...

## Acceptance Criteria
- [ ] Specific, testable criterion 1
- [ ] Specific, testable criterion 2
- [ ] Specific, testable criterion 3

## Dependencies
- [[Link to dependent tasks]]
- Required resources or information

## Testing Plan
How this will be validated by [[TESTING|Testing Agent]]...

## Related Documentation
- [[Link to relevant docs]]
- Related decisions

## Notes
- Implementation notes
- Issues encountered
- Lessons learned
```

## Task Lifecycle

### 1. Creation
New tasks start in `tasks/backlog/` with status `pending`:
- Created from template (`.obsidian/templates/task.md`)
- Given descriptive filename: `task-short-name.md`
- All metadata fields populated
- Acceptance criteria clearly defined

### 2. Activation
When work begins, task moves to `tasks/current/` and status changes to `in-progress`:
- Only one task per person should be in-progress at a time
- Task is assigned to appropriate agent
- Dependencies are verified
- Testing plan is reviewed

### 3. Completion
When acceptance criteria are met, status changes to `completed`:
- All checkboxes checked
- Testing completed and validated
- Documentation updated
- Task moved to `tasks/completed/`

### 4. Archiving
Periodically, old completed tasks are archived:
- Important lessons extracted
- Moved to dated subdirectories
- Searchable for future reference

**Special case - Superseded tasks:**
Tasks that are replaced by new tasks (e.g., significant redesign, different approach) should be archived to `tasks/archived/` with status `superseded`. See [[ARCHIVAL-PROCESS|Task Archival Process]] for details.

## Task Metadata

### Status
- `pending`: Not yet started
- `in-progress`: Currently being worked on
- `blocked`: Waiting on dependency or decision
- `completed`: All criteria met
- `superseded`: Task replaced by newer task (archived, not completed)

### Priority
- `critical`: Must be done immediately (outage, security issue)
- `high`: Important, schedule soon
- `medium`: Normal priority
- `low`: Nice to have, when time permits

### Category
- `infrastructure`: VM, Proxmox, networking, storage
- `docker`: Container management and deployment
- `security`: Secrets, auth, tunnels, VPN
- `media`: Emby, *arr services, downloads
- `documentation`: Docs, runbooks, decisions
- `maintenance`: Routine maintenance tasks
- `troubleshooting`: Investigating/fixing issues

### Agent
Which specialized agent handles this task:
- `testing`: [[TESTING|Testing Agent]]
- `docker`: [[DOCKER|Docker Agent]]
- `infrastructure`: [[INFRASTRUCTURE|Infrastructure Agent]]
- `security`: [[SECURITY|Security Agent]]
- `media`: [[MEDIA|Media Stack Agent]]
- `documentation`: [[DOCUMENTATION|Documentation Agent]]

## Using Obsidian

### Creating a Task
1. Use Command Palette (CMD+P): "Templates: Insert template"
2. Choose "task" template
3. Fill in metadata and content
4. Save to appropriate directory

### Viewing Tasks

#### Dashboard
See [[DASHBOARD|Task Dashboard]] for overview of all tasks.

#### Dataview Queries
In any note, insert these queries:

**All Current Tasks:**
````markdown
```dataview
TABLE status, priority, agent, updated as "Last Updated"
FROM "tasks/current"
SORT priority DESC, updated DESC
```
````

**My In-Progress Tasks:**
````markdown
```dataview
TABLE priority, category, updated as "Last Updated"
FROM "tasks/current"
WHERE status = "in-progress"
SORT priority DESC
```
````

**Tasks by Agent:**
````markdown
```dataview
TABLE status, priority, updated as "Last Updated"
FROM "tasks/current"
WHERE agent = "docker"
SORT priority DESC
```
````

**Critical Priority Tasks:**
````markdown
```dataview
TABLE status, category, agent, updated as "Last Updated"
FROM "tasks/current"
WHERE priority = "critical"
SORT updated DESC
```
````

**Recently Completed:**
````markdown
```dataview
TABLE priority, category, agent, updated as "Completed"
FROM "tasks/completed"
SORT updated DESC
LIMIT 10
```
````

### Task Graph
Use Obsidian's Graph View to visualize:
- Task dependencies
- Related documentation
- Agent assignments
- Service relationships

### Search
Full-text search across all tasks:
- By keyword: "emby transcoding"
- By tag: `#critical`
- By agent: `agent:docker`
- By status: `status:pending`

## Without Obsidian

The MDTD system works perfectly fine without Obsidian:

### Creating Tasks
- Copy template from `.obsidian/templates/task.md`
- Fill in frontmatter manually
- Save to appropriate directory

### Finding Tasks
```bash
# List current tasks
ls tasks/current/

# Search for keyword
grep -r "emby" tasks/

# Find tasks by status
grep -r "status: in-progress" tasks/current/

# Find tasks by agent
grep -r "agent: docker" tasks/
```

### Managing Tasks
- Edit markdown files directly
- Move between directories manually
- Update status in frontmatter

## Best Practices

### Task Naming
- Use descriptive filenames: `deploy-emby-stack.md`
- Lowercase with hyphens
- Include key context in name

### Writing Tasks
- **Clear description**: Anyone should understand what needs to be done
- **Specific criteria**: No ambiguity about completion
- **Testable**: [[TESTING|Testing Agent]] can validate
- **Context**: Explain why, not just what

### Task Granularity
- One task = one logical unit of work
- Should be completable in reasonable timeframe
- Break large work into multiple tasks
- Link related tasks

### Dependencies
- Link dependent tasks with wiki-links
- Block tasks that can't proceed without dependencies
- Document why dependency exists

### Documentation
- Link to relevant agent docs
- Reference affected services
- Note related decisions
- Update docs when task completes

### Testing
- Every task should have testing plan
- Coordinate with [[TESTING|Testing Agent]]
- Document test results
- Verify acceptance criteria

## Example Workflows

### Deploying New Service

1. **Create Task**: `tasks/backlog/deploy-service-name.md`
   - Status: `pending`
   - Agent: `docker`
   - Dependencies: Security setup, infrastructure resources

2. **Security Setup**: Separate task for secrets/tunnels
   - Agent: `security`
   - Must complete before deployment

3. **Deployment**: Move to `current/`, status → `in-progress`
   - Agent: `docker`
   - Follow deployment runbook
   - Update documentation

4. **Testing**: Coordinate with testing agent
   - Validate deployment
   - Check connectivity
   - Verify functionality

5. **Completion**: Status → `completed`, move to `completed/`
   - All criteria met
   - Documentation updated
   - Lessons learned recorded

### Troubleshooting Issue

1. **Create Task**: `tasks/current/fix-service-issue.md`
   - Status: `in-progress` (urgent)
   - Priority: `critical` or `high`
   - Agent: Appropriate for service type

2. **Investigation**: Document findings in task
   - Root cause analysis
   - Related services affected
   - Potential solutions

3. **Resolution**: Implement fix
   - Test thoroughly
   - Verify no side effects
   - Monitor after fix

4. **Prevention**: Create follow-up tasks
   - Monitoring improvements
   - Documentation updates
   - Preventive measures

5. **Completion**: Close task, extract lessons
   - Document resolution
   - Update runbooks
   - Share learnings

## Task Dashboard

See [[DASHBOARD|Task Dashboard]] for live overview using Dataview queries.

## Related Documentation
- [[AI-COLLABORATION|AI Collaboration Guide]] - How AI assistants work with MDTD
- [[agents/README|Agent System]] - Specialized agent roles
- [[DOCUMENTATION|Documentation Agent]] - Managing documentation
