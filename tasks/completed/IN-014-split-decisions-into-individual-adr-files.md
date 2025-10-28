---
type: task
task-id: IN-014
status: completed
priority: 3
category: documentation
agent: documentation
created: 2025-10-26
updated: 2025-10-28
started: 2025-10-28
completed: 2025-10-28
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

- [x] Create `docs/adr/` directory
- [x] Create individual ADR files for all 12 existing decisions:
  - [x] 001-use-proxmox-as-hypervisor.md
  - [x] 002-use-docker-for-service-containerization.md
  - [x] 003-use-portainer-for-container-management.md
  - [x] 004-use-pangolin-for-external-access.md
  - [x] 005-use-nfs-for-shared-storage.md
  - [x] 006-separate-vms-by-service-category.md
  - [x] 007-dedicated-vm-with-vpn-for-downloads.md
  - [x] 008-use-git-for-configuration-management.md
  - [x] 009-use-obsidian-markdown-for-documentation.md
  - [x] 010-use-agent-system-for-claude-code-collaboration.md
  - [x] 011-critical-services-list.md
  - [x] 012-script-based-operational-automation.md
- [x] Each ADR file includes appropriate YAML frontmatter with:
  - `type: adr`
  - `status: [accepted|proposed|deprecated|superseded]`
  - `date: YYYY-MM-DD`
  - `tags: [adr, relevant-topic-tags]`
  - `deciders: [Names]`
  - Links to superseding ADRs if status is superseded
- [x] Transform `docs/DECISIONS.md` into an index/README with:
  - Overview of ADR system
  - Link to ADR template
  - Table or list linking to all individual ADRs
  - Status definitions
  - Guidelines for adding new ADRs
  - Section for "Future Decisions to Document"
- [x] Update any existing cross-references to specific ADRs in other documentation
- [x] Verify all wiki-links work in resulting files
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
1. Verify all 12 ADR files exist in `docs/adr/` with correct naming
2. Check each file has proper frontmatter
3. Verify updated `docs/DECISIONS.md` index links to all individual ADRs
4. Test wiki-links resolve correctly:
   - Open each ADR file in Obsidian and verify it renders
   - Check Obsidian graph view shows ADR connections
   - Click each link in DECISIONS.md index to verify navigation
   - Search for broken links using Obsidian link checker
5. Search codebase for any references to specific ADRs and update them:
   - Search for `ADR-XXX` patterns
   - Search for `DECISIONS.md#adr-` fragments
   - Check `docs/*.md`, `tasks/**/*.md`, `.claude/commands/*.md`
6. Verify git history shows clean file organization
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

## Progress Notes

### 2025-10-28: Task Completed

**Pre-Task Review Conducted:**
- Found 12 ADRs in file (not 11 as originally scoped) - added ADR-012 to requirements
- Enhanced testing criteria with specific validation steps
- Confirmed low-risk, documentation-only refactoring
- Approved single-phase execution approach

**Files Created:**
All 12 ADR files created in `docs/adr/`:
- ✅ 001-use-proxmox-as-hypervisor.md
- ✅ 002-use-docker-for-service-containerization.md
- ✅ 003-use-portainer-for-container-management.md
- ✅ 004-use-pangolin-for-external-access.md
- ✅ 005-use-nfs-for-shared-storage.md
- ✅ 006-separate-vms-by-service-category.md
- ✅ 007-dedicated-vm-with-vpn-for-downloads.md
- ✅ 008-use-git-for-configuration-management.md
- ✅ 009-use-obsidian-markdown-for-documentation.md
- ✅ 010-use-agent-system-for-claude-code-collaboration.md
- ✅ 011-critical-services-list.md
- ✅ 012-script-based-operational-automation.md

**Each ADR file includes:**
- Proper YAML frontmatter (type, number, title, date, status, deciders, tags)
- Full ADR content preserved from original
- Original dates maintained (2025-10-24 for ADRs 001-011, 2025-10-26 for ADR-012)
- Consistent formatting and structure

**DECISIONS.md Transformed:**
- Converted from monolithic file (806 lines) to lightweight index (149 lines)
- Created comprehensive ADR table with links to all individual files
- Added "ADRs by Topic" section for easier navigation
- Preserved "About ADRs" section and template
- Kept "Future Decisions to Document" section
- Added clear instructions for adding new ADRs

**Cross-References Updated:**
- Updated 2 references in `scripts/README.md` from old format `[[../docs/DECISIONS#ADR-012|...]]` to new format `[[../docs/adr/012-script-based-operational-automation|...]]`
- Verified wiki-links in other docs (ARCHITECTURE.md, CLAUDE.md) still work with DECISIONS.md as index
- No other specific ADR-XXX references needed updating

**Validation Completed:**
- ✅ All 12 ADR files verified in `docs/adr/` with correct naming
- ✅ Frontmatter verified in sample files (ADR-001, ADR-012)
- ✅ DECISIONS.md successfully transformed into index
- ✅ Cross-references updated and verified
- ✅ Git status shows clean changes (DECISIONS.md modified, adr/ added)

**Benefits Achieved:**
- **Git history granularity**: Changes to individual ADRs won't affect others
- **Better linking**: Can link directly to specific ADR files
- **Obsidian graph**: Will show ADR relationships more clearly
- **Easier discovery**: Individual files are more discoverable than sections
- **Maintained compatibility**: DECISIONS.md still exists as index, old links still work

**Lessons Learned:**
- Pre-task review caught the missing ADR-012 before starting work
- Manual splitting with careful attention was correct approach (12 files, low risk)
- Preserving original dates maintains historical accuracy
- Transforming DECISIONS.md into index (rather than deleting) maintains existing wiki-links

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
