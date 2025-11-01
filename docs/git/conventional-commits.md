---
type: documentation
tags:
  - git
  - commits
  - format
---

# Conventional Commits Format

Message format specification following Conventional Commits standard.

## Format Structure

```
<type>(<scope>): <subject>

<body>

<footer>
```

## Components Checklist

- [ ] **Type** (required) - Change category (`feat`, `fix`, `docs`, etc.)
- [ ] **Scope** (optional) - Context (`emby`, `vm-100`, `tasks`, etc.)
- [ ] **Subject** (required) - Brief description
- [ ] **Body** (optional) - Detailed explanation
- [ ] **Footer** (optional) - Task references, breaking changes

## Subject Line Rules

**Format:**
- Imperative mood ("add" not "added")
- Lowercase start (unless proper noun)
- No period at end
- Maximum 50 characters

**Examples:**
```
✅ add hardware transcoding support
✅ fix VPN connection drops
✅ update quality profiles
❌ Added GPU transcoding
❌ Fix bug.
```

## Body Guidelines

**When to include:**
- Non-obvious changes needing context
- Configuration affecting behavior
- Structural refactoring

**What to include:**
- Motivation for change
- How it differs from before
- Side effects or considerations

**Keep lines ≤ 72 characters**

## Footer Patterns

**Task references:**
```
Fixes IN-024-setup-inspector-user
```
```
Addresses arr-quality-optimization
```

**Breaking changes:**
```
BREAKING CHANGE: API endpoint format changed
Clients need to update URLs.
```

## Critical Rules

### ⚠️ NEVER Include
- AI attribution ("Co-Authored-By: Claude")
- Tool references ("Generated with Claude Code")
- Emojis or promotional text

### ✅ ALWAYS Include
- Task reference when related to MDTD task
- User approval before committing
- Professional, clean language

## Quick Reference

**Load detailed docs:**
- [[commit-types]] - Type definitions
- [[scopes]] - Scope conventions
- [[examples]] - Real examples
