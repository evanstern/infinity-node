---
type: documentation
tags:
  - mdtd
  - phase-3
  - risk-assessment
---

# Phase 3: Risk Assessment

How to identify risks and define mitigation strategies.

## Identifying Risks

### Technical Risks
- What could break?
- What assumptions might be wrong?
- What edge cases exist?
- What external dependencies could fail?

### Operational Risks
- Impact on running services?
- Timing considerations needed?
- Resource constraints?
- Human error potential?

### Security Risks
- Credential exposure possible?
- Access control issues?
- Data exposure risk?
- Compliance concerns?

### Dependency Risks
- What must exist first?
- What might not be ready?
- What other work could conflict?
- What external services are needed?

---

## Risk Mitigation Strategies

**For each identified risk, document mitigation:**

```
⚠️ RISK: Service downtime during migration
   MITIGATION:
   - Migrate during low-usage window (3-6 AM)
   - Keep old service running until validated
   - Have rollback procedure ready (< 5 min)
   - Test migration on non-critical service first

⚠️ RISK: Configuration errors break functionality
   MITIGATION:
   - Validate config files before applying
   - Use docker compose config to check syntax
   - Test in isolated environment first
   - Keep backup of working configs

⚠️ RISK: Insufficient disk space for new data
   MITIGATION:
   - Check disk space before starting
   - Monitor during operation
   - Have cleanup procedure ready
   - Know how to expand disk if needed
```

**Mitigation framework:**
- **Prevention**: How to avoid the risk
- **Detection**: How to notice it quickly
- **Response**: What to do if it happens
- **Recovery**: How to fix and restore

---

## Critical Services Requirements

**If task affects Emby (VM 100), downloads (VM 101), or arr services (VM 102):**

### Required Elements

✅ **Backup plan documented**
- What to backup before starting
- Where backups stored
- How to restore if needed

✅ **Rollback procedure with time estimate**
- Step-by-step rollback steps
- Estimated recovery time (< 5 min target)
- How to verify rollback successful

✅ **Timing consideration**
- Preferred: 3-6 AM (low usage)
- Coordinate with household if downtime needed
- Plan for maintenance window

✅ **Extra validation steps**
- More thorough testing than usual
- User acceptance testing
- Monitor closely after changes

✅ **Frontmatter flags**
- `critical_services_affected: true`
- `requires_backup: true`
- `requires_downtime: true` (if applicable)

**See detailed requirements:** [[reference/critical-services]]

---

## Risk Assessment Depth

**Minimal (simple tasks):**
- Quick checklist of obvious risks
- Standard mitigations
- 5-10 minutes

**Moderate (moderate tasks):**
- Systematic risk review
- Specific mitigations per risk
- Rollback plan if applicable
- 10-15 minutes

**Extensive (complex tasks):**
- Comprehensive risk analysis
- Detailed mitigation strategies
- Multiple rollback scenarios
- Impact analysis
- 20-30 minutes

---

## Related Documentation

- **[[phases/02-solution-design]]** - Previous: Evaluating alternatives
- **[[reference/critical-services]]** - Critical services requirements
- **Next**: [[phases/04-scope-definition]] - Defining boundaries
