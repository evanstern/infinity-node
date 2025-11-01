---
type: documentation
tags:
  - mdtd
  - reference
  - complexity
---

# Complexity Assessment Reference

Detailed criteria for classifying tasks as simple, moderate, or complex.

## Simple Tasks

**Characteristics:**
- Well-understood, routine work
- Single obvious approach
- Low risk, low impact
- Quick to implement (< 2 hours)
- No unknowns or surprises expected

**Examples:**
- Fix typo in documentation
- Add link to README
- Restart a service
- Update single config value
- Create `.env` file from template

**Task creation time:** 5-10 minutes
**Exploration needed:** None - skip alternatives

---

## Moderate Tasks

**Characteristics:**
- Some design decisions needed
- 2-3 viable approaches
- Moderate risk OR moderate impact
- Reasonable implementation time (2-6 hours)
- Some unknowns, but manageable

**Examples:**
- Add new feature to existing service
- Setup new containerized service
- Refactor configuration structure
- Create comprehensive documentation
- Implement monitoring for service

**Task creation time:** 10-20 minutes
**Exploration needed:** Brief alternatives review, risk assessment

---

## Complex Tasks

**Characteristics:**
- Significant unknowns or large design space
- Multiple approaches with significant trade-offs
- High risk OR high impact
- Substantial implementation time (6+ hours)
- Affects critical services
- Requires phased approach
- Multiple systems/services involved

**Examples:**
- Infrastructure migration (move VMs, change storage)
- Major system refactor
- New system integration (multiple services)
- Architecture changes
- Critical service replacement

**Task creation time:** 30-60 minutes
**Exploration needed:** Full exploration, detailed risk analysis, phased planning

---

## Assessment Factors

Consider these dimensions:

### Unknowns
- How much do we know about the solution?
- Have we done this before?
- Are there hidden complexities?

### Approaches
- One obvious way → Simple
- 2-3 valid ways → Moderate
- Many ways with trade-offs → Complex

### Risk
- What could go wrong?
- Impact if things break?
- Affects critical services? → Increases complexity

### Scope
- How much work is involved?
- How many files/services affected?
- Single system or multiple?

### Dependencies
- How many moving parts?
- External dependencies?
- Coordination needed?

---

## When in Doubt

**Lean toward higher complexity** - better to over-plan than under-plan.

You can always simplify during execution, but missed risks in planning are harder to recover from.

---

## Related Documentation

- **[[phases/01-understanding]]** - Classification process
- **[[overview]]** - MDTD philosophy
