---
type: documentation
tags:
  - mdtd
  - example
  - simple
---

# Example: Simple Task - Fix Broken Documentation Link

This example demonstrates a simple task walkthrough.

## Task Context

**Scenario**: Link in README.md points to wrong location
**Complexity**: Simple
**Estimated time**: 30 minutes
**Priority**: Low (6)

---

## Phase 1: Understanding & Classification

### Problem Statement

**What**: README.md contains broken link to deployment guide

**Why now**:
- User reported broken link
- Quick fix, should be corrected

**Who benefits**:
- Users reading documentation
- Maintains documentation quality

### Classification

- **Category**: documentation
- **Priority**: 6 (low - minor documentation issue)
- **Complexity**: simple
  - One obvious fix
  - No risk
  - Very quick (< 30 min)

**Assessment**: "This is a straightforward documentation fix. Skip alternatives and detailed planning."

---

## Phase 2: Solution Design

**Single obvious approach**: Update link to correct path

No alternatives needed - straightforward fix.

---

## Phase 3: Risk Assessment

### Minimal Risk Check

⚠️ **Risk: Could break other references**
- Mitigation: Search for all references to this file before changing

No other significant risks for documentation change.

---

## Phase 4: Scope Definition

### In Scope
✅ Fix broken link in README.md
✅ Verify link works
✅ Check for similar broken links in same file

### Out of Scope
❌ Comprehensive documentation audit (separate task if needed)
❌ Restructuring documentation
❌ Content updates

### MVP
🎯 Link works when clicked

---

## Phase 5: Execution Planning

### Phase 1: Fix Link *(agent: documentation)*
- [ ] Identify correct path for deployment guide
- [ ] Update link in README.md
- [ ] Verify link works

### Phase 2: Validation *(agent: testing)*
- [ ] Click link, verify it opens correct page
- [ ] Check for other broken links in file
- [ ] Verify markdown syntax correct

---

## Acceptance Criteria

- [ ] Link in README.md updated to correct path
- [ ] Link opens to correct page when clicked
- [ ] No other broken links found in README.md
- [ ] Changes committed with descriptive message

**Testing**: Manual - click link, verify it works

---

## Execution Notes

### What Actually Happened
- Found link at line 42 pointing to `docs/deployment.md`
- Correct path is `docs/runbooks/deployment-guide.md`
- Updated link
- Checked rest of file - no other broken links
- Total time: 15 minutes

### Lessons Learned
- Simple tasks should stay simple
- No need for extensive planning on obvious fixes
- Quick validation sufficient for low-risk changes

---

## This Example Demonstrates

✅ **Simple complexity assessment**: Obvious fix, no alternatives needed

✅ **Minimal risk assessment**: Quick checklist only

✅ **Focused scope**: Clear single objective

✅ **Straightforward execution**: Single phase, quick validation

✅ **Appropriate effort**: 15 minute task got 5 minute planning

**Key point**: Don't over-plan simple tasks. Match effort to complexity.

---

## Related Documentation

- **[[examples/moderate-task]]** - More complex task example
- **[[examples/complex-task]]** - Multi-phase task example
- **[[reference/complexity-assessment]]** - Complexity criteria
