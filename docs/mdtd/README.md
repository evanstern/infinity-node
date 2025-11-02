---
type: documentation
tags:
  - mdtd
  - tasks
  - index
---

# MDTD Task Management Documentation

This directory contains focused, modular documentation for the MDTD (Markdown Task-Driven Development) system.

## Quick Start

- **Creating tasks**: Use `/create-task` command (see [[.claude/commands/create-task]])
- **Working on tasks**: Use `/task IN-NNN` command (see [[.claude/commands/task]])
- **Task template**: See [[templates/task-template]]

## Documentation Structure

Documentation is organized into focused modules (60-120 lines each) for just-in-time loading.

### Overview

- **[[overview]]** - MDTD philosophy and when to create tasks (~100 lines)

### Phase Guides

Load these when working on specific phases:

- **[[phases/01-understanding]]** - Gathering info, classification, complexity (~100 lines)
- **[[phases/02-solution-design]]** - Evaluating alternatives, decision frameworks (~120 lines)
- **[[phases/03-risk-assessment]]** - Identifying risks, mitigation strategies (~100 lines)
- **[[phases/04-scope-definition]]** - Defining boundaries, MVP, scope evolution (~80 lines)
- **[[phases/05-execution-planning]]** - Phasing, agent assignments, acceptance criteria (~100 lines)

### Execution Guides

Load these during task execution:

- **[[execution/pre-task-review]]** - Critical analysis before starting (~100 lines)
- **[[execution/strategy-development]]** - Planning and risk identification (~100 lines)
- **[[execution/work-execution]]** - Best practices during implementation (~100 lines)
- **[[execution/testing-validation]]** - Verification approaches (~80 lines)
- **[[execution/completion]]** - Finalization and handoff (~100 lines)
- **[[execution/agent-coordination]]** - Multi-agent coordination (~100 lines)
- **[[execution/service-deployment]]** - Service deployment workflow (~310 lines)

### Reference Guides

Load these for specific questions:

- **[[reference/complexity-assessment]]** - Simple vs moderate vs complex (~60 lines)
- **[[reference/priority-assignment]]** - How to prioritize tasks (~60 lines)
- **[[reference/agent-selection]]** - Which agent for what work (~80 lines)
- **[[reference/acceptance-criteria]]** - Writing testable criteria (~70 lines)
- **[[reference/critical-services]]** - Requirements for Emby/arr/downloads (~80 lines)
- **[[reference/deployment-checklist]]** - Quick deployment decisions (VM, ports, patterns) (~320 lines)

### Common Patterns

Load these when doing similar work:

- **[[patterns/new-service-deployment]]** - Deploying a new containerized service (~100 lines)
- **[[patterns/infrastructure-changes]]** - VM, networking, storage changes (~100 lines)
- **[[patterns/troubleshooting]]** - Investigation and root cause analysis (~100 lines)

### Examples

Load one example when needed:

- **[[examples/simple-task]]** - Quick, straightforward work (~150 lines)
- **[[examples/moderate-task]]** - Standard feature/improvement (~250 lines)
- **[[examples/complex-task]]** - Multi-phase, high-risk work (~300 lines)

## Usage Pattern

**The command files load automatically. Load these docs only when you need specific guidance.**

### For AI Agents

**Simple task**: Just use the command, don't load guides
```
/create-task Fix broken link
[Command handles everything]
```

**Moderate task needing alternatives**:
```
/create-task Add monitoring
[When reaching Phase 2, load: phases/02-solution-design]
```

**Complex task with critical services**:
```
/create-task Migrate Emby storage
[Load: reference/critical-services + patterns/infrastructure-changes]
```

**Specific question during work**:
```
"How do I write good acceptance criteria?"
[Load: reference/acceptance-criteria]
```

## File Sizes

All modules kept focused for optimal context loading:

- Command files: ~300-400 lines (always loaded)
- Phase guides: ~80-120 lines (load when on that phase)
- Reference docs: ~60-80 lines (load for specific questions)
- Patterns: ~100 lines (load for similar work)
- Examples: ~150-300 lines (load one if helpful)

## Related Documentation

- [[tasks/README]] - Task lifecycle and organization
- [[docs/AI-COLLABORATION]] - Overall AI collaboration guide
- [[docs/agents/README]] - Agent system documentation
- [[templates/task-template]] - Task file structure
