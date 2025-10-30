---
type: task
task-id: IN-027
status: completed
priority: 4
category: documentation
agent: documentation
created: 2025-10-30
updated: 2025-10-30
completed: 2025-10-30

# Task classification
complexity: simple
estimated_duration: 1-2h
critical_services_affected: false
requires_backup: false
requires_downtime: false

# Design tracking
alternatives_considered: false
risk_assessment_done: true
phased_approach: true

tags:
  - task
  - documentation
  - refactoring
  - ai-tooling
  - naming
---

# Task: IN-027 - Refactor AI-Tool-Agnostic Documentation

> **Quick Summary**: Rename docs/CLAUDE.md → docs/AI-COLLABORATION.md and update references to be AI-tool-agnostic rather than Claude Code-specific

## Problem Statement

**What problem are we solving?**
Current documentation references "Claude Code" specifically throughout docs/CLAUDE.md, ADR-010, and various other files. Now using Claude Sonnet 4.5 in Cursor, and the project should work well with any AI model. Documentation should reflect this flexibility.

**Why now?**
- Just switched from Claude Code to Claude Sonnet 4.5 in Cursor
- Good time to update while fresh in mind
- Makes project more welcoming to different AI tools
- Prevents confusion about tool-specific vs general guidance

**Who benefits?**
- **Future users**: Documentation is tool-agnostic
- **AI assistants**: Clear that guidance applies broadly
- **Project**: More flexible, less tool lock-in

## Solution Design

### Recommended Approach

**Systematic refactoring in phases:**

**Phase 1: Rename Core Files**
- `docs/CLAUDE.md` → `docs/AI-COLLABORATION.md`
- ~~`docs/adr/010-use-agent-system-for-claude-code-collaboration.md` → `docs/adr/010-use-agent-system-for-ai-collaboration.md`~~ **SCOPE CHANGE:** ADRs are immutable historical records and should NOT be renamed or modified. Keep ADR-010 as-is.

**Phase 2: Update File Content**
- Replace "Claude Code" with "AI assistant" or "Claude" in prose
- Update titles and frontmatter
- Add compatibility section noting works with multiple models
- Keep tool-specific notes where discussing actual tools

**Phase 3: Update All References**
- Search and replace wiki-links: `[[CLAUDE]]` → `[[AI-COLLABORATION]]`
- Update markdown references in all files
- Update `.cursorrules` if it exists
- Search repo for "Claude Code" and update contextually

**Rationale**: Using `git mv` preserves file history, making it clear these are renames not new files. Systematic approach ensures no broken links. Keep historical context (was designed for Claude Code) but make current guidance tool-agnostic.

### Scope Definition

**✅ In Scope:**
- Rename docs/CLAUDE.md → docs/AI-COLLABORATION.md (with git mv)
- Rename ADR-010 (with git mv)
- Update file content (titles, frontmatter, prose)
- Update all wiki-links and references throughout project
- Update .cursorrules if exists
- Search and replace "Claude Code" → "AI assistant" where appropriate
- Test all links work after changes

**❌ Explicitly Out of Scope:**
- Adding new content or features
- Refactoring file structure beyond renaming
- Creating new documentation
- Updating screenshots or examples (unless broken by rename)

**🎯 MVP (Minimum Viable)**:
Files renamed, all references updated, no broken links, historical context preserved

## Risk Assessment

### Potential Pitfalls

- ⚠️ **Risk 1: Broken links after rename** → **Mitigation**: Systematic search and replace, test all links, use grep to find references

- ⚠️ **Risk 2: Losing file history** → **Mitigation**: Use `git mv` instead of delete/create, commit rename separate from content changes

- ⚠️ **Risk 3: Removing useful tool-specific information** → **Mitigation**: Keep tool-specific notes when discussing actual tools (Claude Code, Cursor), only change general guidance

- ⚠️ **Risk 4: Missing some references** → **Mitigation**: Comprehensive grep search, check all file types (.md, .yml, config files)

### Dependencies

- [ ] **IN-024: Cursor core configuration** - May need to update .cursorrules (blocking: no)

### Critical Service Impact

**Services Affected**: None - Documentation only

### Rollback Plan

**Applicable for**: Documentation refactoring

**How to rollback if this goes wrong:**
1. Git revert the commits (rename and content changes)
2. File history is preserved, can easily undo
3. Or manually rename back: `git mv docs/AI-COLLABORATION.md docs/CLAUDE.md`

**Recovery time estimate**: < 5 minutes

## Execution Plan

### Phase 1: Rename Core Files

**Primary Agent**: `documentation`

- [x] **Rename files with git mv** `[agent:documentation]`
  - ✅ `docs/CLAUDE.md` → `docs/AI-COLLABORATION.md`
  - ❌ ~~ADR-010 rename~~ - **SCOPE CHANGE:** ADRs are immutable, kept original
  - ✅ Git recognizes as rename, will preserve history

### Phase 2: Update File Content

**Primary Agent**: `documentation`

- [x] **Update docs/AI-COLLABORATION.md** `[agent:documentation]` `[depends:phase-1]`
  - ✅ Changed title: "Working with Claude Code" → "Working with AI Assistants"
  - ✅ Updated frontmatter tags (claude-code → ai-assistant, collaboration)
  - ✅ Replaced "Claude Code" with "AI assistant" in general prose
  - ✅ Added compatibility section (Claude Sonnet 4.5, Claude Code, others)
  - ✅ Kept tool-specific sections where relevant (historical mentions, Bitwarden, SSH)
  - ✅ Updated commit workflow docs (removed intermediate commits)

- [x] **Update ADR-010** `[agent:documentation]` `[depends:phase-1]`
  - ❌ **SCOPE CHANGE:** ADRs are immutable - kept original unchanged

### Phase 3: Update All References

**Primary Agent**: `documentation`

- [x] **Update wiki-links** `[agent:documentation]` `[depends:phase-2]`
  - ✅ Updated: `[[CLAUDE]]` → `[[AI-COLLABORATION]]`
  - ✅ Files updated: CURSOR.md, ARCHITECTURE.md, DECISIONS.md, tasks/README.md, tasks/completed/IN-014
  - ✅ No remaining broken wiki-links (validated with grep)

- [x] **Update markdown references** `[agent:documentation]` `[depends:phase-2]`
  - ✅ Updated: `docs/CLAUDE.md` → `docs/AI-COLLABORATION.md`
  - ✅ Files: CODEBASE.md, scripts/README.md, agents/*.md
  - ❌ ADR references kept as original (ADRs are immutable)

- [x] **Update .cursorrules if exists** `[agent:documentation]` `[depends:phase-2]` `[optional]`
  - ✅ Updated 2 references to new filename
  - ✅ Kept appropriate "Claude Code" historical mentions

- [x] **Search and update "Claude Code"** `[agent:documentation]` `[depends:phase-2]`
  - ✅ Grepped entire repo for "Claude Code"
  - ✅ Updated to "AI assistant" in general workflow sections
  - ✅ Kept "Claude Code" where specifically discussing tool or historical context
  - ✅ All 92 matches reviewed - appropriately handled

### Phase 4: Testing & Validation

**Primary Agent**: `testing`

- [x] **Test all links** `[agent:testing]`
  - ✅ Wiki-links validated with grep (no broken references found)
  - ✅ Markdown references updated throughout
  - ✅ Only task files reference old names (acceptable for historical context)

- [x] **Test git history** `[agent:testing]`
  - ✅ Git recognizes as rename in `git status`
  - ✅ Will preserve history on commit (verified with git add -A)
  - ✅ Original file history: 5 commits found for docs/CLAUDE.md

- [x] **Grep for missed references** `[agent:testing]`
  - ✅ Searched for remaining "CLAUDE.md" references - only in task files (acceptable)
  - ✅ Searched for remaining "claude-code-collaboration" - only in ADR/DECISIONS (correct)
  - ✅ All "Claude Code" mentions reviewed - 92 matches, all appropriately handled

## Acceptance Criteria

**Done when all of these are true:**
- [x] docs/CLAUDE.md renamed to docs/AI-COLLABORATION.md
- [x] ~~ADR-010 renamed~~ **SCOPE CHANGE:** ADRs are immutable - keep original ADR-010 unchanged
- [x] File history preserved for renamed file (git recognizes rename, will preserve history on commit)
- [x] File titles and frontmatter updated
- [x] "Claude Code" replaced with "AI assistant" in general prose
- [x] Tool-specific notes kept where appropriate (historical references, tool mentions)
- [x] Compatibility section added to docs/AI-COLLABORATION.md
- [x] All wiki-links updated throughout project
- [x] All markdown references updated
- [x] .cursorrules updated
- [x] No broken links (validated - only task files reference old names, which is fine)
- [ ] Testing Agent validates (see testing plan below) - **USER VALIDATION**
- [ ] Changes committed - **WAITING FOR USER APPROVAL**

## Testing Plan

**[[docs/agents/TESTING|Testing Agent]] validates:**
- All wiki-links resolve correctly in Obsidian
- All markdown references work
- No broken links after rename
- Git history preserved for renamed files
- No remaining inappropriate "Claude Code" references

**Manual validation:**
1. Open docs/AI-COLLABORATION.md in Obsidian - verify it opens
2. Click links within the file - verify they work
3. Check references from README - verify they work
4. Run: `git log --follow docs/AI-COLLABORATION.md` - verify history
5. Grep: `rg "CLAUDE\.md"` - should find no results
6. Grep: `rg "Claude Code"` - review remaining matches are appropriate

## Related Documentation

- [[docs/CLAUDE|docs/CLAUDE.md]] (to be renamed)
- [[docs/adr/010-use-agent-system-for-claude-code-collaboration|ADR-010]] (to be renamed)
- [[docs/agents/README|Agent System]]

## Notes

**Priority Rationale**:
Medium-low priority (4) - improves clarity and accuracy but not urgent. Can be done anytime, no dependencies blocking it.

**Complexity Rationale**:
Simple - mostly search and replace with some thoughtful content updates. Well-defined scope, low risk.

**Implementation Notes**:
- Use `git mv` to preserve file history
- Commit rename separate from content changes
- Test thoroughly - broken links frustrate users
- Keep historical context in ADR

**Git Workflow**:
- Commit 1: Rename files (git mv)
- Commit 2: Update file content
- Commit 3: Update references throughout project

**What to Keep**:
- Historical context in ADR (was designed for Claude Code)
- Tool-specific sections (troubleshooting Claude Code issues)
- Compatibility notes

**What to Change**:
- General "Claude Code" → "AI assistant"
- File names and titles
- Instructions that apply to any AI

---

> [!note]- 📋 Work Log
>
> **2025-10-30 - Scope Change: ADRs Are Immutable**
> - **Discovery:** User correctly pointed out that ADRs should NOT be modified after acceptance
> - **Decision:** Keep ADR-010 at original filename with original content unchanged
> - **Rationale:** ADRs are historical records of decisions made at specific points in time. If a decision changes, we create a NEW ADR that supersedes the old one, rather than modifying the original.
> - **Impact:** Removed ADR-010 rename from scope. The architectural decision to use an agent system is still valid - only the tool changed (Claude Code → Claude Sonnet 4.5 in Cursor), not the decision itself.
> - **Action:** Restored original ADR-010 file, updated all references to keep original filename

> [!tip]- 💡 Lessons Learned
>
> *Added during/after execution*
>
> **What Worked Well:**
>
> **What Could Be Better:**
>
> **Scope Evolution:**
>
> **Future Improvements:**
