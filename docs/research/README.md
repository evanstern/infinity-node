---
type: documentation
title: Research Artifacts
tags:
  - meta
  - research
  - documentation
---

# Research Artifacts

This directory contains research artifacts - documentation of investigations, assessments, and analysis conducted to inform decisions, ADRs, and implementation tasks.

## Purpose

Research artifacts serve as:
- **Evidence base** for architectural decisions (ADRs)
- **Reference documentation** for technical capabilities and constraints
- **Historical record** of what was investigated and when
- **Input data** for implementation planning

## Structure

**Flat directory with rich tagging** - all research artifacts live here, searchable by tags and frontmatter.

```
docs/research/
├── README.md (this file)
├── proxmox-hardware-capabilities.md
├── emby-transcoding-baseline.md
└── ... (all research artifacts)
```

## Creating Research Artifacts

### Use the Template

Copy `templates/research-artifact-template.md` or reference it when creating new research.

### Required Frontmatter

```yaml
---
type: research
title: "Brief Descriptive Title"
date: YYYY-MM-DD
status: draft | complete | superseded
related-tasks:
  - IN-XXX
feeds-into:
  - ADR-XXX  # Optional
research-type: [category]
tags:
  - research
  - [relevant tags]
authors:
  - Evan
  - Claude (AI Agent)
---
```

### Research Types

Use one of these standardized `research-type` values:

| Type | Purpose | Examples |
|------|---------|----------|
| `hardware-assessment` | Hardware capabilities, compatibility | GPU passthrough feasibility, CPU features |
| `performance-analysis` | Benchmarks, measurements, profiling | Transcode speeds, resource usage |
| `feasibility-study` | Can we do X? Technical viability | "Can we use technology Y?" |
| `technology-evaluation` | Comparing technologies/tools | Docker vs Podman, different monitoring tools |
| `security-audit` | Security reviews, vulnerability assessments | Service exposure, authentication review |
| `troubleshooting-investigation` | Root cause analysis | Why did service X fail? |
| `architecture-planning` | Infrastructure design research | Network topology, storage architecture |

## Naming Convention

Use descriptive, component-focused names:

**Good**:
- `proxmox-hardware-capabilities.md`
- `emby-transcoding-baseline-2025-10.md`
- `arr-services-resource-usage.md`
- `vpn-provider-comparison.md`

**Avoid**:
- `research-1.md` (not descriptive)
- `thing-we-tested.md` (vague)
- `IMPORTANT-FINDINGS.md` (use tags for importance)

## Tagging Strategy

### Always Include
- `research` (type tag)
- Component/service tags (e.g., `emby`, `proxmox`, `docker`)
- Domain tags (e.g., `hardware`, `performance`, `security`, `networking`)

### Tag Examples

```yaml
tags:
  - research
  - emby
  - transcoding
  - hardware
  - gpu
  - performance
```

This enables queries like:
- "Show me all emby-related research"
- "Find all hardware assessments"
- "What research fed into ADR-013?"

## Status Lifecycle

| Status | Meaning |
|--------|---------|
| `draft` | Research in progress, incomplete |
| `complete` | Research finished, ready to use |
| `superseded` | Outdated, replaced by newer research |

When research becomes outdated:
1. Update `status: superseded`
2. Add note pointing to newer research
3. Don't delete - keep for historical context

## Obsidian Queries

### Find Research for a Task

```dataview
TABLE status, date, research-type
FROM "docs/research"
WHERE contains(related-tasks, "IN-007")
SORT date DESC
```

### Find Research by Type

```dataview
LIST
FROM "docs/research"
WHERE research-type = "hardware-assessment"
AND status = "complete"
SORT date DESC
```

### Find Research Feeding into ADR

```dataview
TABLE related-tasks, date
FROM "docs/research"
WHERE contains(feeds-into, "ADR-013")
```

### Find Superseded Research (Needs Review)

```dataview
LIST date
FROM "docs/research"
WHERE status = "superseded"
SORT date DESC
```

## Best Practices

### When to Create Research Artifacts

Create research when:
- ✅ Investigation informs an ADR or major decision
- ✅ Hardware/software capabilities need documentation
- ✅ Performance baselines are established
- ✅ Feasibility of an approach needs assessment
- ✅ Multiple options are evaluated

Don't create research for:
- ❌ Quick lookups or trivial checks
- ❌ Information already in vendor docs (just link it)
- ❌ Temporary troubleshooting notes (use task notes instead)

### Link to Tasks and ADRs

Always link bidirectionally:
- Research → Task (via `related-tasks`)
- Research → ADR (via `feeds-into`)
- Task → Research (in task documentation)
- ADR → Research (in ADR context section)

### Keep Research Separate from Implementation

Research artifacts document **what was investigated** and **what was found**.

Implementation details go in:
- **Runbooks** (`docs/runbooks/`) - how to do things
- **Architecture docs** (`docs/ARCHITECTURE.md`) - how things are set up
- **Stack READMEs** (`stacks/*/README.md`) - service-specific docs

### Make Research Discoverable

Good research is useless if no one can find it. Always:
1. Use descriptive titles
2. Tag comprehensively
3. Link from related ADRs and tasks
4. Update this README with notable research (optional)

## Notable Research

*Optional: Add links to particularly important or frequently referenced research*

- [[proxmox-hardware-capabilities]] - Hardware assessment for transcoding optimization

---

**See Also**:
- [[templates/research-artifact-template]] - Template for new research
- [[docs/adr/README|ADR Documentation]] - Architectural Decision Records
- [[docs/AI-COLLABORATION]] - Working with AI on research
