---
type: documentation
tags:
  - mdtd
  - example
  - moderate
---

# Example: Moderate Task - Add Monitoring for Critical Services

This example demonstrates a moderate task walkthrough.

## Task Context

**Scenario**: Need monitoring for Emby, downloads, and arr services
**Complexity**: Moderate
**Estimated time**: 3-4 hours
**Priority**: High (2)

---

## Phase 1: Understanding & Classification

### Problem Statement

**What**: No visibility into critical service health. Recent VM disk issue went undetected.

**Why now**:
- Recent outage could have been prevented with monitoring
- Critical services need proactive alerting
- Household relies on these services daily

**Who benefits**:
- Operators (proactive alerts)
- Household users (less downtime)
- System (better reliability)

### Classification

- **Category**: infrastructure (monitoring setup)
- **Priority**: 2 (high - critical services need visibility)
- **Complexity**: moderate
  - Well-understood solution (monitoring tools exist)
  - Some design decisions (which tool, what to monitor)
  - Moderate risk (new service deployment)
  - 3-4 hours estimated

---

## Phase 2: Solution Design

### Approaches Considered

**Approach 1: Built-in Docker healthchecks + simple script**
- ✅ No new dependencies
- ✅ Quick to implement
- ❌ Basic features only
- ❌ Manual checking required

**Approach 2: Uptime Kuma (containerized)**
- ✅ Full-featured monitoring
- ✅ Web dashboard
- ✅ Multiple alert channels
- ✅ Self-hosted
- ❌ Another service to maintain

**Approach 3: External service (UptimeRobot)**
- ✅ Fully managed
- ✅ Reliable
- ❌ External dependency
- ❌ Recurring cost
- ❌ Limited internal monitoring

### Recommendation: Approach 2 (Uptime Kuma)

**Rationale**:
- Aligns with self-hosted philosophy
- Features justify maintenance cost (low)
- Provides dashboard for quick status checks
- Supports multiple alert types (email, webhooks)
- One-time setup, minimal ongoing maintenance

---

## Phase 3: Risk Assessment

### Risks Identified

⚠️ **Risk 1: False alarms from too-sensitive thresholds**
- Mitigation: Start with conservative thresholds, tune over 1 week

⚠️ **Risk 2: Monitoring service itself goes down**
- Mitigation: External healthcheck on Uptime Kuma (future task), keep simple

⚠️ **Risk 3: Resource impact on VM 103**
- Mitigation: Check resources before deploy, monitor after deployment

### Critical Services: No

Monitoring service itself is not critical. If it fails, core services still operate.

---

## Phase 4: Scope Definition

### In Scope
✅ Deploy Uptime Kuma on VM 103
✅ Monitor critical services (HTTP checks):
   - Emby web interface
   - Sonarr, Radarr, Lidarr, Prowlarr
✅ Setup email alerting via existing SMTP
✅ Create basic operational runbook

### Out of Scope
❌ Historical performance metrics (future enhancement)
❌ Log aggregation (separate concern)
❌ Advanced analytics (not needed yet)
❌ Monitoring non-critical services (keep focused)

### MVP
🎯 Minimum viable:
- Uptime Kuma running and accessible
- 5 critical services monitored (HTTP checks)
- Email alerts configured and tested
- Basic runbook for adding monitors

Nice-to-have (later):
- Docker container monitoring
- Response time tracking
- Custom dashboards
- SSL certificate monitoring

---

## Phase 5: Execution Planning

### Phase 1: Deployment *(agent: docker)*
- [ ] Create docker-compose.yml for Uptime Kuma
- [ ] Setup volume for persistence
- [ ] Deploy stack via Portainer
- [ ] Verify accessible at monitor.local

### Phase 2: Configuration *(agent: infrastructure)*
- [ ] Complete initial setup (admin user)
- [ ] Add HTTP monitors for services:
  - Emby: http://emby.local
  - Sonarr: http://sonarr.local
  - Radarr: http://radarr.local
  - Lidarr: http://lidarr.local
  - Prowlarr: http://prowlarr.local
- [ ] Set check intervals (5 minutes)
- [ ] Set retry counts (3 retries)

### Phase 3: Alerting *(agent: infrastructure)*
- [ ] Configure SMTP notification
- [ ] Create notification profile
- [ ] Test alert delivery (take service down, verify alert)
- [ ] Set notification frequency (don't spam)

### Phase 4: Validation *(agent: testing)*
- [ ] Verify all monitors showing correct status
- [ ] Test failure detection (stop test service)
- [ ] Verify alert delivery within 5 minutes
- [ ] Test restart behavior of Uptime Kuma
- [ ] Confirm persistence after restart

### Phase 5: Documentation *(agent: documentation)*
- [ ] Create operational runbook
- [ ] Document in ARCHITECTURE.md
- [ ] Update service README

---

## Acceptance Criteria

- [ ] Uptime Kuma deployed and accessible at http://monitor.local:3001
- [ ] All 5 critical services monitored with HTTP checks
- [ ] Monitors showing correct status (UP/DOWN)
- [ ] Test alert delivered to configured email within 5 minutes
- [ ] Service survives restart (data persists)
- [ ] Runbook created at docs/runbooks/uptime-kuma.md
- [ ] ARCHITECTURE.md updated with monitoring info
- [ ] All execution plan items completed
- [ ] Testing Agent validates
- [ ] Changes committed

---

## Execution Notes

### What Worked Well
- Uptime Kuma deployment straightforward
- HTTP monitoring simple to configure
- Email alerting worked first try

### Challenges
- Initial thresholds too sensitive (many false alarms first day)
- Tuned to 3 retries over 15 minutes - much better
- Had to adjust check intervals to avoid overwhelming services

### Lessons Learned
- Start with conservative thresholds, tune based on actual behavior
- Document threshold rationale (why 3 retries, why 5 min intervals)
- Consider alert fatigue - better under-alert than over-alert initially

---

## This Example Demonstrates

✅ **Moderate complexity assessment**: Some design decisions, multiple approaches

✅ **Alternative evaluation**: Presented 3 options with clear recommendation

✅ **Practical risk assessment**: Identified real risks with specific mitigations

✅ **Clear scope boundaries**: Explicit in/out scope prevents feature creep

✅ **Agent assignments**: Appropriate agents per phase

✅ **Specific acceptance criteria**: Testable, measurable success conditions

✅ **Real execution notes**: Captured what actually happened, lessons learned

---

## Related Documentation

- **[[examples/simple-task]]** - Simpler task example
- **[[examples/complex-task]]** - More complex task example
- **[[patterns/new-service-deployment]]** - Service deployment pattern
