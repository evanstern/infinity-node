---
type: documentation
tags:
  - mdtd
  - reference
  - acceptance-criteria
---

# Writing Good Acceptance Criteria

How to create specific, testable completion criteria.

## The Problem with Vague Criteria

❌ **Bad examples:**
- Service is working
- Everything deployed
- Docs updated
- Tests pass
- No errors

**Why bad?**
- Not specific enough to verify
- Open to interpretation
- No clear success condition
- Can't tell when actually "done"

---

## Make Criteria Specific and Testable

✅ **Good examples:**
- Uptime Kuma accessible at https://monitor.local:3001
- All 4 critical services (Emby, Sonarr, Radarr, Lidarr) showing "UP" status in dashboard
- Test alert delivered to configured email within 2 minutes
- Runbook created at `docs/runbooks/uptime-kuma-setup.md` with deployment steps
- `docker ps` shows container status "healthy" for uptime-kuma

**Why good?**
- Specific URL/path/value
- Quantifiable (4 services, 2 minutes)
- Clear success condition
- Easy to verify

---

## Criteria Checklist

Good acceptance criteria should be:

**Specific** - No ambiguity about what "done" means
- ✅ "Service accessible at https://service.local"
- ❌ "Service works"

**Testable** - Can verify objectively
- ✅ "Returns 200 OK when queried"
- ❌ "Service is fast"

**Measurable** - Has clear metrics
- ✅ "Alert delivered within 2 minutes"
- ❌ "Alerts are timely"

**Complete** - Covers all aspects
- Include functionality AND documentation AND testing

---

## Standard Criteria

**Always include these:**

- [ ] All execution plan items completed
- [ ] Testing Agent validates (see testing plan)
- [ ] Changes committed with descriptive message (awaiting user approval)

---

## Criteria by Category

### Infrastructure Tasks
- [ ] VM accessible via SSH at IP address
- [ ] Disk space allocation verified: X GB available
- [ ] Network connectivity confirmed from other VMs
- [ ] Resource allocation documented in ARCHITECTURE.md

### Docker Tasks
- [ ] Container status shows "healthy" in `docker ps`
- [ ] Logs show no errors for past 5 minutes
- [ ] Service accessible at documented URL/port
- [ ] Stack configuration committed to git

### Security Tasks
- [ ] No secrets visible in git log
- [ ] All credentials stored in Vaultwarden collection "X"
- [ ] Access restricted to specified users only
- [ ] Audit trail documented in work log

### Media Tasks (Critical)
- [ ] Service accessible to household users
- [ ] No downtime during deployment
- [ ] Existing content/configuration preserved
- [ ] User acceptance testing completed

### Documentation Tasks
- [ ] All links verified working
- [ ] Frontmatter metadata complete
- [ ] Cross-references use wiki-link format
- [ ] Reviewed for accuracy

---

## Testing Plan Integration

Acceptance criteria should reference testing plan:

```
## Acceptance Criteria
- [ ] Testing Agent validates (see below)
- [ ] Manual validation completed

## Testing Plan
**Testing Agent validates:**
- Container running and healthy
- HTTP endpoint returns 200 OK
- Configuration file syntax valid

**Manual validation:**
1. Login to service at https://service.local
2. Verify dashboard loads in < 2 seconds
3. Create test item, verify it persists after restart
```

---

## Examples by Complexity

### Simple Task
```
## Acceptance Criteria
- [ ] Link updated in README.md line 42
- [ ] Link opens to correct page
- [ ] No broken links in file (validated)
- [ ] Changes committed
```

### Moderate Task
```
## Acceptance Criteria
- [ ] Uptime Kuma stack deployed on VM 103
- [ ] Accessible at https://monitor.local:3001
- [ ] 4 critical services monitored (Emby, Sonarr, Radarr, Lidarr)
- [ ] Test alert delivered to email within 2 minutes
- [ ] Runbook created at docs/runbooks/uptime-kuma.md
- [ ] All execution plan items completed
- [ ] Testing Agent validates
- [ ] Changes committed
```

### Complex Task
```
## Acceptance Criteria
- [ ] All 15 services migrated to new storage backend
- [ ] No data loss verified for each service
- [ ] Performance equal or better than baseline
- [ ] Old storage cleaned up and deallocated
- [ ] Rollback procedure tested and documented
- [ ] ARCHITECTURE.md updated with new topology
- [ ] Migration runbook created
- [ ] All execution plan items completed
- [ ] Testing Agent validates each service
- [ ] Changes committed with detailed message
```

---

## Common Mistakes

❌ **Too vague**: "Service works properly"
✅ **Specific**: "Service returns 200 OK at /health endpoint"

❌ **Too loose**: "Documentation improved"
✅ **Specific**: "Runbook created at docs/runbooks/service-deployment.md with 5 sections: Setup, Config, Deploy, Validate, Troubleshoot"

❌ **Unmeasurable**: "Fast enough"
✅ **Measurable**: "Page load time < 2 seconds (tested with curl)"

❌ **Missing validation**: "Deployed"
✅ **Includes validation**: "Deployed and Testing Agent confirms healthy status"

---

## Related Documentation

- **[[phases/05-execution-planning]]** - Execution planning guide
- **[[templates/task-template]]** - Task template structure
