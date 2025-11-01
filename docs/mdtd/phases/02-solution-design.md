---
type: documentation
tags:
  - mdtd
  - phase-2
  - solution-design
---

# Phase 2: Solution Design

How to evaluate alternatives and choose the best approach.

## When to Consider Alternatives

**YES - Consider alternatives if:**
- Multiple valid approaches exist
- Significant resource investment
- Affects critical services
- Long-term implications
- Team unfamiliar with solution

**NO - Skip alternatives if:**
- Obvious single approach
- Following established pattern
- Low risk/low impact
- Time-sensitive
- User specified approach

---

## For Simple Tasks

**Skip alternatives** - One obvious approach:

```
SOLUTION:
Create .env file on VM with required variables.
Source from Vaultwarden, deploy using existing pattern.

Straightforward - no alternatives needed.
```

---

## For Moderate Tasks

**Present 2-3 approaches with pros/cons:**

```
APPROACH 1: Built-in solution
✅ No new dependencies
✅ Simple implementation
❌ Limited features
❌ Manual management

APPROACH 2: Dedicated tool
✅ Full-featured
✅ Better UX
❌ Another service to maintain
❌ Learning curve

APPROACH 3: External service
✅ Fully managed
✅ Reliable
❌ External dependency
❌ Recurring cost

RECOMMENDATION: Approach 2 (Dedicated tool)

RATIONALE:
- Aligns with self-hosted philosophy
- Features justify maintenance cost
- One-time learning investment
- Flexibility for future needs
```

**Decision criteria:**
- Alignment with project philosophy (self-hosted, open source)
- Maintenance burden vs benefits
- Flexibility for future needs
- Performance requirements
- Cost (time/money)

---

## For Complex Tasks

**Deep exploration with trade-off analysis:**

```
APPROACH 1: Incremental migration
✅ Lower risk (small batches)
✅ Can validate each step
✅ Easy rollback per service
❌ Takes longer overall
❌ Temporary hybrid state

APPROACH 2: Big-bang migration
✅ Faster overall
✅ Clean cut-over
❌ Higher risk if issues
❌ Difficult rollback

APPROACH 3: Parallel run
✅ Lowest risk (fallback available)
✅ Validation period
❌ Double resources needed
❌ Complex synchronization

RECOMMENDATION: Approach 1 (Incremental)

DETAILED RATIONALE:
Critical services (Emby, arr stack) affected - risk
mitigation is paramount. Incremental approach allows:

- Validating each service before moving next
- Learning from early services informs later ones
- Household impact minimized (one service at a time)
- Clear rollback point at each step

Timing: 2-3 weeks, services migrated during low-usage
windows. Big-bang would be faster but risk of multi-
service outage unacceptable for household services.
```

**Include for complex:**
- Detailed pros/cons per approach
- Risk analysis per approach
- Resource requirements
- Timeline implications
- Why recommendation is best fit for this project

---

## Documenting the Decision

**Record in task:**

1. **Chosen approach** with clear rationale
2. **Why alternatives weren't chosen** (future reference)
3. **Key assumptions** being made
4. **Trade-offs accepted**

This helps future you understand WHY this decision was made.

---

## Related Documentation

- **[[phases/01-understanding]]** - Previous: Classification
- **[[reference/complexity-assessment]]** - Complexity criteria
- **Next**: [[phases/03-risk-assessment]] - Identifying risks
