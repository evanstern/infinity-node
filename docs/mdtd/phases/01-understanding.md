---
type: documentation
tags:
  - mdtd
  - phase-1
  - understanding
---

# Phase 1: Understanding & Classification

How to gather information, classify, and assess tasks.

## Gathering Information

### The Problem Statement

Answer these three questions:

**1. What problem are we solving?**
- Describe current state
- What's not working or missing?
- What pain points exist?
- Be specific and concrete

**2. Why now?**
- What triggered this?
- Why is this important now?
- What happens if we don't do this?
- What does this enable?

**3. Who benefits?**
- End users? (household members using services)
- Operators? (easier management)
- Future work? (unblocks other tasks)
- System? (improved reliability)

---

## Category Selection

| Category | Use When |
|----------|----------|
| `infrastructure` | VMs, Proxmox, networking, storage, resources |
| `docker` | Containers, compose files, orchestration, Portainer |
| `security` | Secrets, access control, tunnels, VPN, credentials |
| `media` | Emby, arr services, downloads (critical services) |
| `documentation` | Docs, runbooks, ADRs, knowledge management |
| `testing` | Validation, quality assurance, testing infrastructure |

---

## Priority Assignment

Consider three dimensions:

**Urgency**: How soon must this be done?
- 0: Critical/blocking (production down, security issue)
- 1-2: High (important work, affects users, enables other work)
- 3-4: Medium (valuable improvements, maintenance)
- 5-6: Low (nice-to-haves, optimization)
- 7-9: Very low (future considerations, ideas)

**Impact**: Who/what is affected?
- Critical services (Emby, downloads, arr) = higher priority
- Multiple users affected = higher priority
- Enables other work = higher priority

**Value**: What does this provide?
- Unblocks work = higher priority
- Improves reliability = higher priority
- Reduces operational burden = medium priority
- Nice-to-have features = lower priority

---

## Complexity Assessment

**Simple**: Straightforward, well-understood, low risk
- One obvious approach
- Low risk, low impact
- Quick to implement (< 2 hours)
- Examples: Fix typo, add link, update config value

**Moderate**: Some unknowns, needs planning
- 2-3 viable approaches
- Moderate risk or moderate impact
- Reasonable time (2-6 hours)
- Examples: Add feature, setup service, create documentation

**Complex**: Significant unknowns, high impact
- Multiple approaches with trade-offs
- High risk or high impact
- Substantial time (6+ hours)
- Affects critical services
- Requires phased approach
- Examples: Infrastructure migration, system integration

---

## Presenting Assessment

Be clear and concise:

```
Based on your description, this seems MODERATE because:
- Well-understood solution (we've done similar)
- Some design decisions (2-3 valid approaches)
- Moderate risk (affects non-critical services)
- Estimated 3-4 hours

Priority 2 (high) suggests important for household
functionality and enables other work.

Recommended: Brief alternatives review, risk assessment,
standard execution planning (~15 minutes).

Proceed? Or override with "keep it simple"?
```

**User can override:**
- "keep it simple" → Reduce depth
- "explore thoroughly" → Increase depth
- "skip alternatives" → Use default approach
- Specific guidance → Follow user's lead

---

## Related Documentation

- **[[overview]]** - MDTD philosophy
- **[[reference/complexity-assessment]]** - Detailed complexity criteria
- **[[reference/priority-assignment]]** - Priority framework
- **Next**: [[phases/02-solution-design]] - Evaluating alternatives
