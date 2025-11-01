---
type: documentation
category: mdtd
tags:
  - task-execution
  - pre-task-review
  - risk-assessment
created: 2025-11-01
updated: 2025-11-01
---

# Pre-Task Review

Critical analysis checklist before starting work to identify gaps and risks.

## When to Use

**Always review for:**
- Complex or high-risk tasks
- Tasks affecting critical services
- Infrastructure/docker/security changes
- Tasks with unclear scope

**Skip for:**
- Trivial tasks (typo fixes)
- Very clear, limited scope
- Emergency fixes

---

## Review Checklist

### 1. Read Task Completely

- [ ] Read entire task: description, context, acceptance criteria
- [ ] Review linked documentation and related tasks
- [ ] Understand goal, scope, and expected outcomes

### 2. Validate Task Still Relevant

Tasks can become outdated. Verify:

- [ ] **Problem still exists?**
  - Has it been solved another way?
  - Is situation still the same?

- [ ] **Assumptions still valid?**
  - Infrastructure/services changed?
  - Technologies/versions changed?
  - Our patterns evolved?

- [ ] **Referenced systems accurate?**
  - Services still exist?
  - IPs/URLs still correct?
  - Linked tasks still relevant?

- [ ] **Related work completed?**
  - Check for overlapping completed tasks
  - Review recent commits

**If outdated:** Document changes, propose update/close, get user input

### 3. Check for Gaps

- [ ] **Scope/Inventory**
  - Do we know exactly what to change?
  - All affected services identified?
  - Scope well-defined?

- [ ] **Phased Approach**
  - Should this be incremental?
  - Logical breakpoints for testing?
  - Reduces risk if phased?

- [ ] **Rollback**
  - Can we recover if it fails?
  - Backups identified?
  - Recovery time estimate?

- [ ] **Testing**
  - Acceptance criteria testable?
  - Do we know what "working" looks like?
  - Edge cases identified?

- [ ] **Dependencies**
  - Prerequisites ready?
  - Required tools/services available?
  - Have necessary access/credentials?

- [ ] **Impact on Critical Services**
  - Affects Emby/downloads/arr?
  - Could cause downtime?
  - Shared resources involved?

- [ ] **Timing**
  - Need low-usage window (3-6 AM)?
  - Downtime communicated?

- [ ] **Security**
  - Secrets handled properly?
  - Following SECRET-MANAGEMENT.md?
  - Access control appropriate?

- [ ] **Cross-Service Impact**
  - Shared volumes/networks?
  - DNS/networking ripple effects?
  - Resource contention?

- [ ] **Documentation**
  - Steps specific and actionable?
  - Deployment method clear?
  - Requirements unambiguous?

### 4. Watch for Red Flags

❌ No inventory ("audit all services")
❌ Big-bang approach (change everything at once)
❌ Vague testing ("verify it works")
❌ No rollback plan
❌ Unclear deployment method
❌ No consideration of shared resources

---

## Document Findings

```markdown
## Pre-Task Review - IN-XXX

**Reviewed:** YYYY-MM-DD

### Issues Found

1. **[Category] - [Issue]**
   - Risk: Low/Medium/High
   - Problem: [Description]
   - Recommendation: [Concrete fix]

### Recommendations

- [ ] [Specific action 1]
- [ ] [Specific action 2]

### Overall Risk

**Risk Level:** Low/Medium/High
**Mitigation:** [Brief strategy]

### Proposed Task Updates

[List sections to add/update]
```

---

## Present to User

**Good presentation:**
```
After reviewing IN-012 (Setup DNS), found these issues:

1. **Scope - Missing Inventory** (Medium risk)
   → Add Phase 0: Inventory all services needing DNS

2. **Safety - No Rollback** (High risk)
   → Add rollback: /etc/hosts backup + restore procedure

3. **Testing - Vague Criteria** (Low risk)
   → Specify: "nslookup service.local resolves to correct IP"

Should I update the task with these improvements?
```

---

## Next Steps

**If issues found:**
1. Present findings to user
2. Get approval to update task
3. Update task file
4. Proceed to strategy development

**If task is solid:**
1. Inform user review passed
2. Proceed to strategy development

---

## Related

- [[strategy-development]] - Next step after review
- [[docs/mdtd/phases/03-risk-assessment]] - Detailed risk guidance
- [[docs/mdtd/reference/critical-services]] - Critical service requirements
