---
type: documentation
tags:
  - mdtd
  - pattern
  - infrastructure
---

# Pattern: Infrastructure Changes

Standard pattern for VM, networking, or storage changes.

## Overview

Use this pattern when modifying infrastructure that affects multiple services.

**Typical duration**: 4-8 hours (can span multiple days for phased work)
**Complexity**: Moderate to Complex
**Primary agents**: infrastructure, testing

---

## Standard Phase Structure

### Phase 0: Impact Assessment *(agent: infrastructure)*

- [ ] **Inventory affected services**
  - Which VMs will be impacted?
  - Which services run on those VMs?
  - Any critical services affected?

- [ ] **Document current state**
  - Current configuration
  - Current performance baseline
  - Current resource utilization

- [ ] **Identify dependencies**
  - Service dependencies
  - Network dependencies
  - Storage dependencies
  - Cross-VM dependencies

- [ ] **Assess risk level**
  - Impact if change fails
  - Rollback complexity
  - Downtime requirements

### Phase 1: Planning *(agent: infrastructure)*

- [ ] **Design the change**
  - Target configuration
  - Migration/transition approach
  - Resource requirements

- [ ] **Create detailed procedure**
  - Step-by-step instructions
  - Expected outcomes at each step
  - Verification points

- [ ] **Plan timing**
  - Low-usage window (3-6 AM for critical)
  - Phased approach if needed
  - Coordination requirements

### Phase 2: Backup *(agent: infrastructure)*

- [ ] **Backup affected VMs**
  - Proxmox snapshots
  - Configuration backups
  - Data backups (if applicable)

- [ ] **Backup configurations**
  - Network configs
  - Storage configs
  - Service configs

- [ ] **Document current state**
  - Screenshots of working state
  - Configuration files
  - Performance metrics (baseline)

- [ ] **Test backup restoration**
  - Verify backups are valid
  - Document restore procedure
  - Estimate restore time

### Phase 3: Rollback Preparation *(agent: infrastructure)*

- [ ] **Document rollback procedure**
  - Step-by-step rollback steps
  - Order of operations
  - Expected duration

- [ ] **Create rollback scripts** (if applicable)
  - Automate rollback where possible
  - Test scripts before change

- [ ] **Define rollback triggers**
  - What conditions require rollback?
  - Who decides to rollback?
  - How quickly can we rollback?

### Phase 4: Implementation *(agent: infrastructure)*

**If non-critical services:**
- [ ] Start with least critical service/VM
- [ ] Apply change
- [ ] Verify successful
- [ ] Monitor for issues
- [ ] Proceed to next if successful

**If critical services:**
- [ ] Work during low-usage window
- [ ] Apply change in phases
- [ ] Verify each phase before continuing
- [ ] Have rollback ready at each step

**Standard implementation steps:**
- [ ] Make configuration changes
- [ ] Apply changes
- [ ] Verify changes applied correctly
- [ ] Check for immediate issues
- [ ] Verify services still operational

### Phase 5: Verification *(agent: testing, infrastructure)*

- [ ] **Immediate verification**
  - Services started successfully
  - No errors in logs
  - Basic functionality works

- [ ] **Functional testing**
  - Test key workflows
  - Verify integrations
  - Check cross-service communication

- [ ] **Performance validation**
  - Compare to baseline metrics
  - Check resource utilization
  - Verify no degradation

- [ ] **Extended monitoring**
  - Monitor for 24-48 hours
  - Watch for delayed issues
  - Track user feedback

### Phase 6: Cleanup *(agent: infrastructure)*

- [ ] **Remove old configurations** (if applicable)
  - Archive old configs
  - Remove obsolete settings
  - Clean up temporary files

- [ ] **Update documentation**
  - ARCHITECTURE.md reflects new state
  - Runbooks updated
  - Configuration docs current

- [ ] **Archive backups**
  - Keep backups for 30 days
  - Document backup location
  - Set reminder to review/remove

### Phase 7: Documentation *(agent: documentation)*

- [ ] **Create/update runbook**
  - Change procedure
  - Verification steps
  - Troubleshooting guide

- [ ] **Update ARCHITECTURE.md**
  - Reflect new configuration
  - Document changes and rationale

- [ ] **Document lessons learned**
  - What worked well
  - What could be better
  - Recommendations for future changes

---

## Critical Service Variations

**When affecting Emby, downloads, or arr services:**

**Additional requirements:**
- Extended backup procedures
- User notification before change
- Rollback time must be < 5 minutes
- Extended monitoring period (72 hours)
- User acceptance testing

**See:** [[reference/critical-services]]

---

## Common Infrastructure Changes

### VM Resource Changes (CPU/RAM)
- Backup VM first
- Apply during low-usage
- Verify resource allocation
- Monitor performance

### Network Configuration Changes
- Document current routing
- Apply changes carefully (can lose access!)
- Have console/IPMI access ready
- Test connectivity after each change

### Storage Changes
- Verify sufficient capacity
- Backup before moving data
- Validate checksums after transfer
- Keep old storage accessible during transition

### VM Migration (Physical Host)
- Backup before migration
- Migrate during low-usage
- Verify services start on new host
- Monitor performance on new host

---

## Standard Acceptance Criteria

- [ ] Infrastructure change applied successfully
- [ ] All affected services operational
- [ ] Performance meets or exceeds baseline
- [ ] No errors in logs for 24 hours
- [ ] Rollback procedure documented and tested
- [ ] ARCHITECTURE.md updated
- [ ] Change procedure documented in runbook
- [ ] Backups archived with 30-day retention
- [ ] Extended monitoring complete (24-48 hours)
- [ ] All execution plan items completed
- [ ] Testing Agent validates
- [ ] Changes committed

---

## Common Risks

⚠️ **Loss of access**
- Mitigation: Have console/IPMI access, test carefully

⚠️ **Service dependencies break**
- Mitigation: Document dependencies in Phase 0, verify after change

⚠️ **Performance degradation**
- Mitigation: Baseline before, validate after, rollback if needed

⚠️ **Configuration drift**
- Mitigation: Document changes, update automation

⚠️ **Unexpected downtime extends**
- Mitigation: Buffer in timing, low-usage windows, rollback ready

---

## Related Documentation

- **[[patterns/new-service-deployment]]** - Service deployment pattern
- **[[patterns/troubleshooting]]** - Troubleshooting pattern
- **[[reference/critical-services]]** - Critical service requirements
- **[[examples/complex-task]]** - Complex infrastructure example
