---
type: documentation
tags:
  - mdtd
  - phase-4
  - scope
---

# Phase 4: Scope Definition

How to define clear boundaries and prevent scope creep.

## Defining Boundaries

### In Scope - Be Specific

✅ **What we're definitely doing:**
- Create Uptime Kuma stack on VM 103
- Configure monitors for Emby, Sonarr, Radarr, Lidarr
- Setup email alerting via existing SMTP
- Document in runbook

**Make it concrete and actionable.**

### Out of Scope - Prevent Creep

❌ **What we're explicitly NOT doing:**
- Historical performance metrics (future: IN-XXX)
- Log aggregation (separate concern)
- Advanced analytics (not needed now)
- Monitoring non-critical services (keep focused)

**Identify related work that could sneak in.**

### MVP Definition

🎯 **Minimum viable completion:**
- Uptime Kuma running and accessible
- Critical services monitored (HTTP checks)
- Alerts delivering successfully
- Basic runbook documented

**Nice-to-have (can add later):**
- Docker container monitoring
- Response time tracking
- Custom dashboards
- SSL certificate monitoring

**What's the smallest version we can call "done"?**

---

## Scope Evolution

**Scope can change during execution** - this is OK!

### When Scope Changes

Document in task when scope evolves:

1. **Update scope section** - Add/remove items
2. **Update execution plan** - Adjust phases
3. **Update acceptance criteria** - Reflect changes
4. **Document in work log** - Explain why scope changed

### Acceptable Scope Evolution

✅ Discovery reveals more work needed
✅ Technical constraint requires different approach
✅ Related improvement discovered while working
✅ Dependency found during execution

### When to Split Into New Task

Consider splitting if:
- Discovered work is substantial (> 2 hours)
- Discovered work has different priority
- Discovered work could be done independently
- Current task is getting too large (scope doubling)

**Create follow-up task, link tasks together.**

---

## Scope Definition Depth

**Simple tasks:**
- Brief in/out list
- 5 minutes

**Moderate tasks:**
- Clear boundaries
- MVP defined
- 10 minutes

**Complex tasks:**
- Detailed scope
- Explicit exclusions
- MVP vs nice-to-have breakdown
- 15-20 minutes

---

## Related Documentation

- **[[phases/03-risk-assessment]]** - Previous: Risk mitigation
- **Next**: [[phases/05-execution-planning]] - Structuring work
