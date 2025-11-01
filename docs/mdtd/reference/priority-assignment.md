---
type: documentation
tags:
  - mdtd
  - reference
  - priority
---

# Priority Assignment Reference

How to assign priority levels to tasks.

## Priority Scale (0-9)

### 0: Critical/Urgent
**Use when:**
- Production system down
- Security incident
- Data loss risk
- Blocking all other work

**Examples:**
- Emby completely unavailable
- Security breach detected
- Data corruption in progress

**Action**: Drop everything, fix immediately

---

### 1-2: High Priority
**Use when:**
- Affects household users
- Enables important work
- Prevents future problems
- Time-sensitive opportunity

**Examples:**
- Critical service degraded (slow but working)
- Setup monitoring for critical services
- Migrate before storage fills up
- Foundation for upcoming features

**Action**: Schedule soon, within days

---

### 3-4: Medium Priority
**Use when:**
- Valuable improvements
- Maintenance work
- Nice-to-have features
- Moderate impact

**Examples:**
- Add new non-critical service
- Refactor for maintainability
- Documentation improvements
- Performance optimization

**Action**: Schedule when convenient, within weeks

---

### 5-6: Low Priority
**Use when:**
- Minor improvements
- Optimization
- Nice-to-haves
- Low impact

**Examples:**
- Fix typo in documentation
- Add convenience feature
- Minor UI tweaks
- Code cleanup

**Action**: Backlog, do when time permits

---

### 7-9: Very Low Priority
**Use when:**
- Future considerations
- Ideas to explore
- Experimental work
- Very low value

**Examples:**
- Investigate new technology
- Explore alternative approach
- Future enhancement ideas
- Research tasks

**Action**: Backlog, may never do

---

## Priority Dimensions

Consider three factors:

### Urgency
- How soon must this be done?
- What's the deadline or time constraint?
- What happens if we delay?

### Impact
- Who is affected?
- How many users/systems impacted?
- What's the blast radius?

### Value
- What does this enable?
- What does this prevent?
- What's the long-term benefit?

---

## Priority Matrix

| Urgency | Impact | Value | → Priority |
|---------|--------|-------|-----------|
| High | High | High | 0-1 |
| High | High | Medium | 1-2 |
| High | Medium | Any | 2-3 |
| Medium | High | High | 2-3 |
| Medium | Medium | Medium | 3-4 |
| Low | High | Medium | 4-5 |
| Low | Medium | Low | 5-6 |
| Any | Low | Low | 6-9 |

---

## Special Considerations

### Critical Services
Tasks affecting Emby, downloads, or arr services:
- Increase priority by 1-2 levels
- Never below priority 3

### Blocking Work
Tasks that unblock multiple other tasks:
- Increase priority by 1 level
- Document what's being unblocked

### Technical Debt
Balance with feature work:
- Don't let everything be low priority
- Some maintenance is high priority

---

## Examples

### Priority 0 (Critical)
- Emby server crashed, household can't watch media
- Security vulnerability actively being exploited
- Storage system failing, data loss imminent

### Priority 1 (Very High)
- Emby slow/degraded, users complaining
- Setup monitoring to prevent future outages
- Migrate critical service before planned maintenance

### Priority 2 (High)
- Add new critical service (expands capabilities)
- Fix bug affecting some users sometimes
- Setup backup for important data

### Priority 3 (Medium-High)
- Add new non-critical service
- Improve deployment process
- Create comprehensive documentation

### Priority 4 (Medium)
- Refactor for maintainability
- Performance optimization (working but slow)
- Update to latest version (no urgency)

### Priority 5 (Medium-Low)
- Add convenience feature
- Improve logging
- Documentation polish

### Priority 6 (Low)
- Fix typo
- Code cleanup
- Minor UI improvements

### Priority 7-9 (Very Low)
- Investigate new technology
- Explore alternative tools
- Research future possibilities

---

## When in Doubt

**Overestimate priority** if uncertain:
- Better to do important work early
- Can always lower priority later
- Missing critical work is worse than doing low-priority work early

**But be honest**:
- Not everything is priority 0
- Most work is priority 3-4
- Reserve 0-1 for actual critical work

---

## Related Documentation

- **[[phases/01-understanding]]** - Classification process
- **[[reference/complexity-assessment]]** - Complexity criteria
