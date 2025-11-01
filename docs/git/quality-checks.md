---
type: documentation
tags:
  - git
  - commits
  - quality
  - validation
---

# Quality Checks

Pre-commit validations to run before committing.

## Mandatory Checks

### Docker Compose Syntax

**When**: Any `docker-compose.yml` changed

**Command**:
```bash
docker compose -f path/to/docker-compose.yml config
```

**Expected**: Valid YAML output, no errors

**Why**: Catch syntax errors before deployment

---

### YAML Frontmatter

**When**: Markdown files with frontmatter changed

**Check**: YAML between `---` markers is valid

**Common issues**:
- Unquoted strings with special chars
- Incorrect indentation
- Missing required fields

**Why**: Broken frontmatter breaks Obsidian queries

---

### No Secrets

**When**: Every commit

**Check for**:
- `.env` files (should be `.env.example` only)
- API keys, tokens, passwords
- Hardcoded credentials
- Private URLs or IPs (if sensitive)

**Pattern**: Scan diffs for common secret patterns

**Why**: Secrets in git are permanent and exposed

---

### Git Status Clean

**When**: Before committing task work

**Command**:
```bash
git status
```

**Check for**:
- Duplicate task files (`IN-XXX` in wrong locations)
- Unstaged deletions (old task files not removed)
- Unexpected changes

**Action**: Clean up before proceeding

**Why**: Keep git history clean, catch file management issues

---

## Validation Workflow

**Pre-commit checklist:**
- [ ] Docker compose files validated
- [ ] YAML frontmatter valid
- [ ] No secrets in diff
- [ ] Git status clean
- [ ] All changes intentional
- [ ] User approval obtained

## Abort Conditions

**DO NOT commit if:**
- Any quality check fails
- Secrets detected in diff
- Syntax validation errors
- User hasn't approved

**Fix issues first, then retry**

## Related

- [[conventional-commits]] - Commit format
- [[docs/SECRET-MANAGEMENT]] - Secret handling
- `.claude/commands/commit.md` - Commit workflow
