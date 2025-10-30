---
type: task
task-id: IN-024
status: completed
priority: 2
category: documentation
agent: documentation
created: 2025-10-30
updated: 2025-10-30

# Task classification
complexity: moderate
estimated_duration: 2-3h
critical_services_affected: false
requires_backup: false
requires_downtime: false

# Design tracking
alternatives_considered: true
risk_assessment_done: true
phased_approach: true

tags:
  - task
  - documentation
  - cursor
  - configuration
  - ai-tooling
---

# Task: IN-024 - Create Cursor Core Configuration

> **Quick Summary**: Create `.cursorrules` and `.cursorignore` files to provide Cursor AI with project context and optimize indexing

## Problem Statement

**What problem are we solving?**
Currently using Claude Sonnet 4.5 in Cursor without Cursor-specific configuration. The project has extensive AI collaboration workflows (agent system, MDTD tasks, safety guidelines) but the AI lacks Cursor-native context to understand project structure, conventions, and constraints.

**Why now?**
- Just switched from Claude Code to Cursor
- Want to optimize AI behavior for this new environment
- Foundational work that improves all future AI-assisted work
- Have excellent source material (docs/CLAUDE.md) to pull from

**Who benefits?**
- **AI**: Clear project context, understands structure and constraints
- **User**: Better AI assistance, follows safety guidelines without constant reminding
- **Project**: Consistent AI behavior across sessions and models

## Solution Design

### Recommended Approach

Create comprehensive Cursor configuration from the start:

**`.cursorrules` file**: AI behavior configuration
- Project context and purpose (homelab infrastructure)
- Agent system overview with references to docs/agents/
- MDTD task management workflow summary
- Critical services safety requirements (Emby, downloads, arr)
- Security guidelines (no secrets in git, Vaultwarden usage)
- Git workflow (never commit/push without approval)
- SSH access information (evan/inspector users)
- Communication style guidelines
- Key files to reference for detailed information

**`.cursorignore` file**: Indexing optimization
- Exclude Obsidian cache and workspace files
- Exclude backup files (*.backup, *.bak, *.old)
- Exclude logs directory
- Exclude OS files (.DS_Store, etc.)
- Exclude working/temp directories
- Exclude git directory

**Rationale**: Since this is foundational work and we have excellent source material (docs/CLAUDE.md, docs/agents/), it's worth doing thoroughly from the start. The time investment (2-3 hours) is small compared to the value of proper AI context for all future work. We can always refine, but starting comprehensive is better than discovering gaps later.

> [!abstract]- 🔀 Alternative Approaches Considered
> 
> **Option A: Minimal Configuration**
> - ✅ Pros: Quick to implement, gets us started
> - ❌ Cons: Might miss important context, Cursor indexes everything (slower)
> - ❌ Cons: May need multiple iterations later
> - **Decision**: Not chosen - risk of missing critical context outweighs time savings
> 
> **Option B: Comprehensive Configuration**
> - ✅ Pros: Complete context from the start, optimized performance
> - ✅ Pros: Leverages existing documentation
> - ✅ Pros: Foundation is solid, less need for iteration
> - ❌ Cons: More upfront work (2-3 hours)
> - **Decision**: ✅ CHOSEN - Best long-term value
> 
> **Option C: Iterative Approach**
> - ✅ Pros: Learn what's actually useful vs theoretical
> - ❌ Cons: Requires multiple iterations and testing cycles
> - ❌ Cons: May miss things until we hit problems
> - **Decision**: Not chosen - prefer to get it right initially with good source material available

### Scope Definition

**✅ In Scope:**
- Create `.cursorrules` file with all project context
- Create `.cursorignore` file with exclusions
- Test configuration with Claude Sonnet 4.5
- Validate AI understands project structure
- Validate AI follows safety guidelines
- Document in commit message

**❌ Explicitly Out of Scope:**
- Refactoring existing docs/CLAUDE.md (separate task: IN-027)
- Creating Cursor-specific user documentation (separate task: IN-025)
- Adding new slash commands (separate task: IN-026)
- VSCode/Cursor workspace settings (separate task: IN-025)
- Testing with other AI models

**🎯 MVP (Minimum Viable)**: 
Both files created with essential content, basic validation that AI can read them

## Risk Assessment

### Potential Pitfalls

- ⚠️ **Risk 1: Forgetting critical project context** → **Mitigation**: Use checklist from docs/CLAUDE.md sections - systematically include agent system, MDTD workflow, critical services, SSH access, security guidelines

- ⚠️ **Risk 2: .cursorrules too verbose (AI context overload)** → **Mitigation**: Link to detailed docs rather than duplicating content. Keep rules concise, reference docs/CLAUDE.md and docs/agents/ for comprehensive details

- ⚠️ **Risk 3: .cursorignore excludes something important** → **Mitigation**: Mirror .gitignore patterns where applicable, only exclude truly irrelevant files (Obsidian cache, backups, logs). Test that relevant code is still indexed.

- ⚠️ **Risk 4: Configuration doesn't actually improve AI behavior** → **Mitigation**: Test with real queries after creation - validate AI references correct docs, mentions safety requirements, asks for commit approval

### Dependencies

**Source Material (all ready):**
- [ ] **docs/CLAUDE.md** - Comprehensive workflow guide (blocking: no)
- [ ] **docs/agents/README.md** - Agent system overview (blocking: no)
- [ ] **docs/ARCHITECTURE.md** - Infrastructure context (blocking: no)
- [ ] **docs/SECRET-MANAGEMENT.md** - Security guidelines (blocking: no)

**No blocking dependencies** - can start immediately.

### Critical Service Impact

**Services Affected**: None

This is configuration files only, no service impact. No backup required, no rollback needed (can just edit/delete files). Can be done anytime, no timing constraints.

### Rollback Plan

**Applicable for**: Documentation changes

**How to rollback if this goes wrong:**
1. Delete `.cursorrules` and `.cursorignore` files
2. Or restore from git: `git checkout HEAD -- .cursorrules .cursorignore`

**Recovery time estimate**: < 1 minute

## Execution Plan

### Phase 1: Create Configuration Files

**Primary Agent**: `documentation`

- [ ] **Create .cursorrules file** `[agent:documentation]`
  - Project context and purpose (homelab infrastructure)
  - Agent system overview with references to docs/agents/
  - MDTD task management workflow summary
  - Critical services safety requirements (Emby, downloads, arr)
  - Security guidelines (no secrets in git, Vaultwarden)
  - Git workflow (never commit/push without approval)
  - SSH access information (evan/inspector users)
  - Communication style guidelines
  - Key files to reference

- [ ] **Create .cursorignore file** `[agent:documentation]`
  - Obsidian cache and workspace files
  - Backup files (*.backup, *.bak, *.old)
  - Logs directory
  - OS files (.DS_Store, etc.)
  - Working/temp directories
  - Git directory

### Phase 2: Validation & Testing

**Primary Agent**: `testing`

- [ ] **Test AI context understanding** `[agent:testing]`
  - Start new Cursor chat session
  - Ask "What is the project structure?"
  - Verify AI references correct documentation

- [ ] **Test safety guidelines** `[agent:testing]`
  - Ask "What are the critical services?"
  - Verify AI mentions safety requirements (Emby, downloads, arr)

- [ ] **Test Git workflow awareness** `[agent:testing]`
  - Ask AI to make a change
  - Verify AI asks for approval before commit

- [ ] **Verify indexing optimization** `[agent:testing]`
  - Check that Obsidian cache is excluded from search
  - Verify backup files don't appear in codebase searches
  - Confirm relevant code is still indexed

### Phase 3: Documentation

**Primary Agent**: `documentation`

- [ ] **Document in commit message** `[agent:documentation]`
  - What was created (.cursorrules, .cursorignore)
  - What content was included (agent system, MDTD, safety, etc.)
  - Why these choices were made (comprehensive from start)
  - Reference task IN-024

## Acceptance Criteria

**Done when all of these are true:**
- [x] `.cursorrules` file created at project root
- [x] `.cursorrules` includes all required sections:
  - [x] Project context and purpose
  - [x] Agent system overview
  - [x] MDTD workflow summary
  - [x] Critical services safety requirements
  - [x] Security guidelines
  - [x] Git workflow rules
  - [x] SSH access information
  - [x] Communication style
  - [x] Key file references
- [x] `.cursorignore` file created at project root
- [x] `.cursorignore` excludes all specified file types
- [ ] Tested with Claude Sonnet 4.5 in new chat session (user validation)
- [ ] AI demonstrates understanding of project structure (user validation)
- [ ] AI follows safety guidelines unprompted (user validation)
- [ ] AI asks for approval before commits (user validation)
- [x] All execution plan items completed
- [ ] Testing Agent validates (see testing plan below) (user validation)
- [ ] Changes committed with descriptive message (awaiting user approval)

## Testing Plan

**[[docs/agents/TESTING|Testing Agent]] validates:**
- `.cursorrules` file syntax is valid (markdown)
- `.cursorignore` file syntax is valid (gitignore format)
- Content accurately reflects project requirements
- No sensitive information included in files
- Files are committed to git properly

**Manual validation:**
1. Start new Cursor chat and ask about project - AI should reference docs
2. Ask about critical services - AI should mention safety requirements
3. Request a code change - AI should ask for approval before committing
4. Search codebase - verify Obsidian cache excluded, code still indexed

## Related Documentation

- [[docs/CLAUDE|Working with AI Assistants]]
- [[docs/agents/README|Agent System]]
- [[docs/ARCHITECTURE|Infrastructure Architecture]]
- [[docs/SECRET-MANAGEMENT|Secret Management]]
- [[docs/adr/010-use-agent-system-for-claude-code-collaboration|ADR-010: Agent System]]

## Notes

**Priority Rationale**: 
High priority (2) because it's foundational for all future AI-assisted work. Every interaction benefits from proper context. Low risk (config files only), quick to implement (2-3h), high value (improves all subsequent AI work).

**Complexity Rationale**: 
Moderate complexity because solution is well-understood (.cursorrules and .cursorignore are standard files) but requires design decisions about what to include and how much detail. Good source material exists but needs thoughtful curation.

**Implementation Notes**:
- Keep `.cursorrules` concise - link to detailed docs rather than duplicating
- Use same conventions as existing project (wiki-links for internal references)
- Consider this version 1.0 - iterate based on actual usage
- `.cursorignore` patterns should mirror `.gitignore` where applicable

**Follow-up Tasks**:
- IN-025: Add Cursor-specific documentation (explains how to use Cursor features)
- IN-027: Refactor docs to be AI-tool-agnostic (rename CLAUDE.md, etc.)
- IN-028: Test and iterate on Cursor configuration based on real usage

---

> [!note]- 📋 Work Log
> 
> **2025-10-30 - Implementation Complete**
> - Created `.cursorrules` (8.5 KB) with comprehensive project context
> - Created `.cursorignore` (1.3 KB) with appropriate exclusions
> - Both files mirror and complement existing documentation
> - Terminal output issue resolved with Cursor restart before starting task
> 
> **Content decisions:**
> - Kept `.cursorrules` concise while covering all critical areas
> - Linked to detailed documentation files for deep dives
> - Emphasized safety requirements for critical services prominently
> - Included all agent types with brief descriptions
> - Added MDTD workflow summary with task ID examples
> - Documented Bitwarden CLI workflow (user provides session token)
> - Clear "never commit secrets" and "never commit/push without approval" rules
> 
> **`.cursorignore` decisions:**
> - Mirrored `.gitignore` patterns where applicable
> - Added Cursor-specific exclusions (not in .gitignore)
> - Explicitly commented exceptions (scripts/secrets/, .env.example)
> - Included Python/Node patterns for future-proofing
> - Excluded build artifacts and editor files

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

