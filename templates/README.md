---
type: documentation
tags:
  - templates
  - mdtd
  - task-management
---

# Templates

This directory contains templates for creating consistent documentation and task files across the project.

## Task Template

**File**: `task-template.md`

The task template provides the standardized structure for all MDTD (Markdown Task-Driven Development) tasks in this project.

### When to Use

Use this template when creating new tasks via:
- `/create-task` command in Cursor (automatically uses this template)
- Manual task creation (copy template and fill in sections)

### Template Structure

The template includes:

**Frontmatter**:
- Task metadata (ID, status, priority, category, agent)
- Task classification (complexity, duration, service impact)
- Design tracking flags
- Tags for organization

**Core Sections**:
- **Problem Statement**: What we're solving, why now, who benefits
- **Solution Design**: Chosen approach with alternatives considered
- **Scope Definition**: In scope, out of scope, MVP
- **Risk Assessment**: Potential pitfalls, dependencies, critical service impact, rollback plan
- **Execution Plan**: Phased breakdown with agent assignments
- **Acceptance Criteria**: Specific, testable completion criteria
- **Testing Plan**: Validation steps for Testing Agent and manual testing
- **Related Documentation**: Links to relevant docs
- **Notes**: Priority/complexity rationale, implementation notes, follow-ups

**Tracking Sections**:
- **Work Log**: Progress notes during execution
- **Lessons Learned**: Post-execution reflections

### Design Principles

**Why this structure?**

1. **Think before doing**: Problem statement and alternatives force critical thinking upfront
2. **Risk-aware**: Always consider what could go wrong and how to recover
3. **Scope discipline**: Explicit boundaries prevent scope creep
4. **Agent-oriented**: Clear agent assignments for multi-agent coordination
5. **Testable**: Specific acceptance criteria and testing plans
6. **Recoverable**: Rollback plans for infrastructure/docker/security changes
7. **Traceable**: Work log captures decisions and discoveries
8. **Learnable**: Lessons learned improve future work

### Example Tasks

See these completed tasks as examples:
- `tasks/completed/IN-024-create-cursor-core-configuration.md` - Moderate complexity, documentation work
- `tasks/completed/IN-013-complete-portainer-monorepo-migration.md` - Moderate complexity, infrastructure work

### Customization Notes

**All tasks must include**:
- Problem statement (what and why)
- Solution design (how)
- Risk assessment (what could go wrong)
- Execution plan (step-by-step with agents)
- Acceptance criteria (definition of done)

**Optional/conditional sections**:
- Alternatives (skip for simple tasks)
- Rollback plan (required for infrastructure/docker/security)
- MVP definition (useful for complex tasks)

### Related Documentation

- [[docs/AI-COLLABORATION|AI Collaboration Guide]] - MDTD workflow details
- [[tasks/README|Task Management]] - Task lifecycle and organization
- [[.claude/commands/create-task|Create Task Command]] - Automated task creation

---

## Future Templates

This directory will grow to include:

- **ADR template**: For architectural decision records
- **Runbook template**: For operational procedures
- **Agent template**: For new agent specifications
- **Stack template**: For new Docker stack documentation

For now, only the task template is standardized. Other documents follow less rigid structures.
