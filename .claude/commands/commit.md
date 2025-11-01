# Smart Commit - Intelligent Git Commit Assistant

Analyzes code changes, runs quality checks, and creates well-structured commits.

## Quick Reference

**Usage**: `/commit`

**What it does**:
- Captures git diff of all changes
- Analyzes and categorizes changes
- Runs pre-commit quality checks
- Generates conventional commit message
- Requires approval before committing

**Need detailed guidance?** Load docs as needed:
- [[docs/git/conventional-commits]] - Message format specification
- [[docs/git/commit-types]] - Type definitions (feat, fix, docs, etc.)
- [[docs/git/scopes]] - Project scope conventions
- [[docs/git/quality-checks]] - Pre-commit validations
- [[docs/git/examples]] - Real commit examples
- [[docs/git/README]] - Navigation hub

---

## 🚨 CRITICAL STEPS - Execute These

### 1. Capture and Analyze Changes
```bash
git --no-pager diff HEAD
```
- Understand what changed
- Determine change type
- Identify affected components

### 2. Run Quality Checks

**Docker Compose syntax** (if any compose files changed):
```bash
docker compose -f path/to/docker-compose.yml config
```

**Checks to perform:**
- [ ] Docker compose syntax valid
- [ ] YAML frontmatter valid (if markdown changed)
- [ ] No secrets in diff
- [ ] No .env files (only .env.example allowed)

**⚠️ ABORT if any check fails** - Fix issues first

### 3. Verify Git Status
```bash
git status
```

**Check for:**
- Duplicate task files (IN-XXX in wrong folders)
- Unstaged deletions (old task files)
- Unexpected changes

**Clean up if found** before proceeding

### 4. Stage Changes
```bash
# Stage all
git add -A

# Or stage specific files
git add path/to/file
```

### 5. Commit with Approval

**Generate commit message following format:**
```
type(scope): subject

body

footer
```

**Present message to user for approval**

**⚠️ REQUIRE EXPLICIT APPROVAL** - Never commit without it

**On approval:**
```bash
git commit -m "type(scope): subject

body

footer"
```

**Confirm success**

---

## Process Flow

### Phase 1: Analysis
1. Run `git --no-pager diff HEAD`
2. Identify changed files
3. Understand nature of changes
4. Determine commit type (feat, fix, docs, etc.)
5. Identify scope (vm, service, component)

### Phase 2: Quality Checks
1. Validate Docker compose syntax (if applicable)
2. Check YAML frontmatter (if applicable)
3. Scan for secrets in diff
4. Verify no .env files being committed
5. Abort if any check fails

### Phase 3: Verification
1. Run `git status`
2. Check for file management issues
3. Clean up if needed
4. Verify all changes intentional

### Phase 4: Staging
1. Stage appropriate files
2. Verify staged changes correct

### Phase 5: Commit
1. Generate commit message
2. Present to user
3. Get explicit approval
4. Create commit
5. Show commit hash and message

---

## Essential Rules

### Critical (NEVER VIOLATE)

1. **ALWAYS require approval** - Never commit without explicit user consent
2. **NEVER include AI attribution** - No "Co-Authored-By: Claude" or similar
3. **ALWAYS run quality checks** - Abort on failures
4. **ALWAYS check git status** - Clean up file issues before committing

### Commit Message Format

5. **Use conventional commits** format - `type(scope): subject`
6. **Include task reference** when related to MDTD task:
   - `Fixes task-name` when completing task
   - `Addresses task-name` when making progress
7. **Use imperative mood** - "add" not "added"
8. **Keep subject ≤ 50 chars** - Be concise
9. **Wrap body at 72 chars** - Readable in any context

### Quality & Safety

10. **No secrets in git** - Never commit credentials, API keys, tokens
11. **Clean git status** - Remove duplicates, stage deletions
12. **Professional tone** - Keep messages clean and focused

---

## Quick Type Reference

- **feat** - New feature or capability
- **fix** - Bug fix
- **refactor** - Code restructuring (no behavior change)
- **docs** - Documentation changes
- **chore** - Maintenance tasks (task management, cleanup)
- **config** - Configuration changes
- **infra** - Infrastructure changes (VMs, network, storage)
- **security** - Security-related changes

**Load [[docs/git/commit-types]] for detailed definitions**

---

## Quick Scope Reference

**VMs**: `vm-100`, `vm-101`, `vm-102`, `vm-103`

**Services**: `emby`, `arr`, `downloads`, `sonarr`, `radarr`, etc.

**Components**: `tasks`, `docs`, `scripts`, `stacks`

**Load [[docs/git/scopes]] for full conventions**

---

## Example Workflow

**User has made changes and runs `/commit`**

**AI:**
```bash
# 1. Capture changes
git --no-pager diff HEAD

# Shows changes to tasks/current/IN-037-modularize-commit-command.md
# and new files in docs/git/

# 2. Run quality checks
# - No compose files changed ✓
# - YAML frontmatter looks valid ✓
# - No secrets detected ✓
# - No .env files ✓

# 3. Check git status
git status

# Shows task moved and new docs created ✓

# 4. Stage changes
git add -A

# 5. Generate message
I propose this commit message:

---
docs(git): modularize commit command documentation

Extracted detailed commit reference material into focused modular docs
under docs/git/. Follows same pattern as /create-task modularization for
consistency and reduced context loading.

Created:
- docs/git/README.md - Navigation hub
- docs/git/conventional-commits.md - Format specification
- docs/git/commit-types.md - Type definitions
- docs/git/scopes.md - Project scopes
- docs/git/quality-checks.md - Pre-commit validations
- docs/git/examples.md - Real examples

Addresses IN-037-modularize-commit-command
---

Approve this commit message?
```

**User approves**

**AI:**
```bash
git commit -m "docs(git): modularize commit command documentation

Extracted detailed commit reference material into focused modular docs
under docs/git/. Follows same pattern as /create-task modularization for
consistency and reduced context loading.

Created:
- docs/git/README.md - Navigation hub
- docs/git/conventional-commits.md - Format specification
- docs/git/commit-types.md - Type definitions
- docs/git/scopes.md - Project scopes
- docs/git/quality-checks.md - Pre-commit validations
- docs/git/examples.md - Real examples

Addresses IN-037-modularize-commit-command"

# Output: [abc1234] docs(git): modularize commit command documentation

✅ Committed successfully: abc1234
```

---

## Reference Documentation

**Load modular docs as needed** (don't load everything!):

**Core format and standards:**
- [[docs/git/conventional-commits]] - Format specification and rules
- [[docs/git/commit-types]] - Detailed type definitions
- [[docs/git/scopes]] - Project-specific scope conventions

**Quality and examples:**
- [[docs/git/quality-checks]] - Pre-commit validation details
- [[docs/git/examples]] - Real commit examples from this project

**Navigation:**
- [[docs/git/README]] - Index of all git documentation

**Related systems:**
- [[docs/AI-COLLABORATION#Git Workflow]] - Git workflow guidelines
- [[docs/CURSOR]] - Repository rules and commit requirements
