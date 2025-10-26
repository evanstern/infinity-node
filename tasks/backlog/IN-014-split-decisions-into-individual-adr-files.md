---
type: task
task-id: IN-014
status: pending
priority: medium
category: documentation
agent: documentation
created: 2025-10-26
updated: 2025-10-26
tags:
  - task
  - documentation
  - adr
  - refactoring
---

# Task: IN-014 - Split DECISIONS.md into Individual ADR Files

## Description

Refactor the monolithic `docs/DECISIONS.md` file into individual ADR (Architectural Decision Record) files, one per decision. Each ADR should be:
- Placed in a new `docs/adr/` directory
- Named using the convention: `NNN-decision-title-slug.md`
- Contain full ADR content with proper frontmatter
- Cross-referenced from an updated index file

## Context

Currently all architectural decisions are stored in a single `docs/DECISIONS.md` file containing 11 ADRs. This makes it:
- Harder to link to specific decisions
- Difficult to track changes to individual decisions in git history
- Less discoverable in Obsidian graph view
- Harder to reference from other documents

Splitting into individual files aligns with standard ADR practices and improves:
- Git history granularity (changes to one ADR don't affect others)
- Obsidian linking (can link directly to specific ADRs)
- Navigation and discovery
- File organization

## Acceptance Criteria

- [ ] Create `docs/adr/` directory
- [ ] Create individual ADR files for all 11 existing decisions:
  - [ ] 001-use-proxmox-as-hypervisor.md
  - [ ] 002-use-docker-for-service-containerization.md
  - [ ] 003-use-portainer-for-container-management.md
  - [ ] 004-use-pangolin-for-external-access.md
  - [ ] 005-use-nfs-for-shared-storage.md
  - [ ] 006-separate-vms-by-service-category.md
  - [ ] 007-dedicated-vm-with-vpn-for-downloads.md
  - [ ] 008-use-git-for-configuration-management.md
  - [ ] 009-use-obsidian-markdown-for-documentation.md
  - [ ] 010-use-agent-system-for-claude-code-collaboration.md
  - [ ] 011-critical-services-list.md
- [ ] Each ADR file includes appropriate YAML frontmatter with:
  - `type: adr`
  - `status: [accepted|proposed|deprecated|superseded]`
  - `date: YYYY-MM-DD`
  - `tags: [adr, relevant-topic-tags]`
  - `deciders: [Names]`
  - Links to superseding ADRs if status is superseded
- [ ] Transform `docs/DECISIONS.md` into an index/README with:
  - Overview of ADR system
  - Link to ADR template
  - Table or list linking to all individual ADRs
  - Status definitions
  - Guidelines for adding new ADRs
  - Section for "Future Decisions to Document"
- [ ] Update any existing cross-references to specific ADRs in other documentation
- [ ] Verify all wiki-links work in resulting files
- [ ] Git commit with descriptive message following conventional commits format

## File Naming Convention

Use kebab-case slugs derived from decision titles:
```
NNN-lowercase-decision-title-with-hyphens.md
```

Examples:
- `001-use-proxmox-as-hypervisor.md`
- `002-use-docker-for-service-containerization.md`
- `010-use-agent-system-for-claude-code-collaboration.md`

## Proposed Frontmatter Structure

Each ADR file should have frontmatter like:

```yaml
---
type: adr
number: NNN
title: Decision Title
date: YYYY-MM-DD
status: accepted|proposed|deprecated|superseded
superseded-by: [[adr/NNN-new-decision]] # if superseded
deciders:
  - Name
tags:
  - adr
  - relevant-topic
  - another-topic
---
```

## ADR Content Structure

Each file should maintain the existing structure:
```markdown
# ADR-NNN: Decision Title

**Date:** YYYY-MM-DD
**Status:** Accepted/Proposed/Deprecated/Superseded
**Deciders:** Names

## Context
[What problem are we solving?]

## Decision
[What did we decide?]

## Consequences

**Positive:**
- ...

**Negative:**
- ...

**Neutral:**
- ...

## Alternatives Considered

1. **Alternative Name**
   - Pros/cons
   - Why not chosen
```

## Dependencies

None - this is a pure documentation refactoring with no infrastructure dependencies.

## Testing Plan

Validation steps:
1. Verify all 11 ADR files exist in `docs/adr/` with correct naming
2. Check each file has proper frontmatter
3. Verify updated `docs/DECISIONS.md` index links to all individual ADRs
4. Test wiki-links resolve correctly in Obsidian
5. Search codebase for any references to specific ADRs in `DECISIONS.md` and update them
6. Verify git history shows clean file moves/splits
7. Check that ADR template reference is updated if needed

## Related Documentation

- [[DECISIONS|Architectural Decisions]] - File to be refactored
- `.obsidian/templates/adr.md` - ADR template
- [[CLAUDE|Claude Code Guide]] - References DECISIONS.md
- [[agents/README|Agent System]] - Referenced by ADR-010

## Implementation Notes

### Approach Options

**Option 1: Manual Split**
- Read each ADR section
- Create individual files
- Update references

**Option 2: Scripted Split**
- Write script to parse DECISIONS.md
- Auto-generate files
- Manual review and adjustment

**Recommendation:** Manual split with careful attention to:
- Preserving all content
- Ensuring proper formatting
- Adding appropriate frontmatter
- Updating cross-references

### After Splitting

The main `docs/DECISIONS.md` should become a lightweight index file that:
- Explains the ADR system
- Lists all ADRs with status and one-line descriptions
- Provides links to individual ADR files
- Includes guidelines for adding new ADRs
- Maintains "Future Decisions to Document" section

Consider creating a dataview query in Obsidian to auto-generate ADR list:
```dataview
TABLE date, status, deciders
FROM "docs/adr"
WHERE type = "adr"
SORT file.name ASC
```

## Notes

- This task can be done incrementally (e.g., split 3-4 ADRs at a time)
- Obsidian's graph view will show relationships better with individual files
- Git blame will be more useful for tracking decision evolution
- Consider running this during a low-activity period to avoid merge conflicts
- May want to update `.obsidian/templates/adr.md` to match the frontmatter structure

## Future Enhancements

After completing this split:
- Consider adding `category` field to ADR frontmatter (e.g., infrastructure, tooling, process)
- Add Obsidian dataview queries to DECISIONS.md index for dynamic listing
- Create tags taxonomy for ADRs
- Add decision review dates for periodic reassessment
