---
type: documentation
tags:
  - mdtd
  - pattern
  - troubleshooting
---

# Pattern: Troubleshooting & Investigation

Standard pattern for investigating and resolving issues.

## Overview

Use this pattern when diagnosing problems or performing root cause analysis.

**Typical duration**: 2-8 hours (varies widely)
**Complexity**: Moderate to Complex
**Primary agents**: varies by issue type, testing

---

## Standard Phase Structure

### Phase 0: Problem Reproduction *(agent: testing, varies)*

- [ ] **Document symptoms**
  - What's not working?
  - When did it start?
  - Frequency (always, intermittent, specific conditions)?
  - User-reported vs observed?

- [ ] **Gather initial information**
  - Error messages
  - Log snippets
  - Screenshots if applicable
  - Affected services/systems

- [ ] **Reproduce the issue**
  - Can you trigger it reliably?
  - What are the exact steps?
  - Does it happen in all environments?
  - Can you reproduce on test system?

- [ ] **Establish baseline**
  - What's the expected behavior?
  - When did it last work correctly?
  - What changed since then?

### Phase 1: Information Gathering *(agent: varies)*

- [ ] **Review logs**
  - Application logs
  - System logs
  - Container logs
  - Recent changes/deployments

- [ ] **Check configurations**
  - Service configuration
  - Environment variables
  - Network configuration
  - Resource allocation

- [ ] **Examine state**
  - Service status
  - Resource usage (CPU, RAM, disk)
  - Network connectivity
  - Dependencies operational?

- [ ] **Review recent changes**
  - Recent deployments
  - Configuration changes
  - System updates
  - Network/infrastructure changes

### Phase 2: Hypothesis Formation *(agent: varies)*

- [ ] **Analyze gathered data**
  - Patterns in logs/errors
  - Correlation with changes
  - Resource constraints?
  - Configuration mismatches?

- [ ] **Form hypotheses**
  - List possible root causes
  - Order by likelihood
  - Note what evidence supports each

- [ ] **Plan tests**
  - How to test each hypothesis?
  - Can test without impact?
  - Need test environment?

### Phase 3: Investigation & Testing *(agent: varies)*

- [ ] **Test hypotheses systematically**
  - Start with most likely
  - One hypothesis at a time
  - Document results
  - Eliminate ruled-out causes

- [ ] **Collect additional data** as needed
  - More detailed logging
  - Performance metrics
  - Network traces
  - Comparative testing

- [ ] **Narrow down root cause**
  - What evidence confirms/refutes each hypothesis?
  - Can you isolate the cause?
  - Is it reproducible?

### Phase 4: Root Cause Analysis *(agent: varies)*

- [ ] **Identify root cause**
  - Not just symptoms, but underlying cause
  - Why did it fail?
  - Why didn't we catch it earlier?

- [ ] **Document findings**
  - Root cause identified
  - Evidence supporting conclusion
  - How it manifested
  - Contributing factors

- [ ] **Assess scope**
  - Is this affecting other systems?
  - Could this happen elsewhere?
  - How long has this been an issue?

### Phase 5: Fix Implementation *(agent: varies)*

- [ ] **Design fix**
  - Specific changes needed
  - Potential side effects
  - Testing approach

- [ ] **Apply fix**
  - Make changes
  - Document what was changed
  - Keep rollback option available

- [ ] **Verify fix**
  - Issue resolved?
  - No new issues introduced?
  - Reproducible success?

- [ ] **Monitor post-fix**
  - Watch for recurrence
  - Check for related issues
  - Extended observation period

### Phase 6: Prevention *(agent: varies)*

- [ ] **Identify preventive measures**
  - How to prevent recurrence?
  - What monitoring could catch this earlier?
  - What tests could have caught this?

- [ ] **Implement prevention**
  - Add monitoring/alerting
  - Add validation checks
  - Update deployment procedures
  - Improve documentation

- [ ] **Consider similar issues**
  - Could this affect other services?
  - Need to check elsewhere?
  - Update related systems?

### Phase 7: Documentation *(agent: documentation)*

- [ ] **Document troubleshooting process**
  - Symptoms observed
  - Investigation steps taken
  - Root cause identified
  - Fix applied

- [ ] **Create/update runbook**
  - Add to troubleshooting guide
  - Document resolution steps
  - Include prevention measures

- [ ] **Update relevant docs**
  - Known issues section
  - Operational procedures
  - Configuration best practices

- [ ] **Capture lessons learned**
  - What worked in investigation?
  - What tools were helpful?
  - What would you do differently?

---

## Issue-Specific Variations

### Performance Issues
**Focus on:**
- Resource utilization (CPU, RAM, disk I/O, network)
- Slow query identification
- Bottleneck analysis
- Baseline comparisons

### Connectivity Issues
**Focus on:**
- Network path tracing
- DNS resolution
- Firewall rules
- Service bindings

### Data Issues
**Focus on:**
- Data validation
- Corruption detection
- Backup/restore testing
- Consistency checks

### Configuration Issues
**Focus on:**
- Configuration comparison
- Syntax validation
- Environment differences
- Missing variables

---

## Standard Acceptance Criteria

- [ ] Issue reproduced and documented
- [ ] Root cause identified with evidence
- [ ] Fix applied and verified
- [ ] Issue no longer reproducible
- [ ] Monitoring in place to detect recurrence
- [ ] Troubleshooting documented in runbook
- [ ] Prevention measures implemented
- [ ] Related systems checked (if applicable)
- [ ] Extended monitoring complete (24-48 hours)
- [ ] All execution plan items completed
- [ ] Testing Agent validates resolution
- [ ] Changes committed

---

## Troubleshooting Tools

### Log Analysis
- `docker logs <container>` - Container logs
- `journalctl` - System logs
- `tail -f` - Follow logs in real-time
- `grep` - Search for patterns

### System Inspection
- `docker ps` - Container status
- `docker inspect` - Container details
- `htop` / `top` - Resource usage
- `df -h` - Disk usage
- `netstat` / `ss` - Network connections

### Network Debugging
- `ping` - Connectivity test
- `traceroute` - Path tracing
- `nslookup` / `dig` - DNS resolution
- `curl` / `wget` - HTTP testing
- `nc` (netcat) - Port testing

### Service-Specific
- `docker compose config` - Validate compose syntax
- Portainer UI - Container management
- Service-specific health endpoints

---

## Common Pitfalls

❌ **Jumping to solutions without diagnosis**
- Take time to understand the problem
- Form hypotheses before trying fixes

❌ **Making multiple changes at once**
- Change one thing at a time
- Verify result before next change

❌ **Not documenting findings**
- Future you (or someone else) will need this
- Document as you go

❌ **Skipping prevention phase**
- Fixing once isn't enough
- Prevent recurrence

---

## Related Documentation

- **[[patterns/new-service-deployment]]** - Service deployment pattern
- **[[patterns/infrastructure-changes]]** - Infrastructure change pattern
- **[[reference/agent-selection]]** - Which agent for what work
