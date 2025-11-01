---
type: documentation
category: mdtd
tags:
  - task-execution
  - testing
  - validation
created: 2025-11-01
updated: 2025-11-01
---

# Testing & Validation

Verification approaches to ensure work meets acceptance criteria and functions correctly.

## Testing Philosophy

- Test before marking complete
- Verify all acceptance criteria explicitly
- Test both happy path and edge cases
- Document test results clearly
- Test incrementally during work (don't accumulate untested changes)

---

## Verification Checklist

### 1. Verify All Acceptance Criteria

- [ ] Go through each criterion one by one
- [ ] Test functionality for each
- [ ] Document pass/fail
- [ ] Don't assume - verify

**Example:**
```markdown
## Acceptance Criteria Verification

- [x] Stack deployed and healthy ✓
  - Portainer shows green ✓
  - API returns "healthy" ✓

- [x] Web UI accessible ✓
  - Local: curl returns 200 ✓
  - External: URL loads ✓
```

### 2. Test Edge Cases

Don't just test happy path:

- [ ] Service restart during operation
- [ ] Dependent service unavailable
- [ ] Invalid credentials/inputs
- [ ] Resource constraints (disk full, memory exhausted)
- [ ] Network issues (slow, timeout)
- [ ] Malformed data/config

### 3. Verify Error Handling

- [ ] No silent failures
- [ ] Clear error messages
- [ ] Proper logging
- [ ] No data corruption
- [ ] Recovery possible

### 4. Check Dependent Services

**Verify no negative impact:**

- [ ] Services still running
- [ ] Performance not degraded
- [ ] No error logs
- [ ] Resources not overconsumed
- [ ] Networks functioning

**For critical services:**
- [ ] Emby streaming working
- [ ] Sonarr/Radarr processing
- [ ] Downloads continuing

---

## Testing Strategies

### Manual Testing
**Use for:**
- User-facing functionality
- Visual/UI verification
- Complex workflows
- Integration testing

### Automated Testing
**Use for:**
- Repetitive checks
- API endpoints
- Service health
- Configuration validation

**Common checks:**
```bash
# Health
curl -f http://service:port/health

# API
curl -s http://service:port/api | jq -e '.status == "success"'

# Logs
docker logs service 2>&1 | grep -i "error"

# Resources
docker stats --no-stream service
```

### Testing Agent
**Engage for:**
- Complex validation
- Independent verification
- Systematic checks
- Read-only inspection

---

## Validation Procedures

### Configuration
```bash
# Syntax
docker-compose -f stacks/SERVICE/docker-compose.yml config

# Environment
docker exec SERVICE env | grep KEY

# Volumes
docker inspect SERVICE | jq '.[0].Mounts'

# Network
docker exec SERVICE ping -c 1 dependent-service
```

### Service Health
```bash
# Container status
docker ps | grep SERVICE

# Health check
docker inspect SERVICE | jq '.[0].State.Health.Status'

# Ports
docker exec SERVICE netstat -tlnp | grep PORT
```

### Logs
```bash
# Recent
docker logs --tail 100 SERVICE

# Errors
docker logs SERVICE 2>&1 | grep -i "error"

# Warnings
docker logs SERVICE 2>&1 | grep -i "warn"

# Timeframe
docker logs SERVICE --since 1h
```

---

## Quality Checks

### Security
- [ ] No secrets in logs
- [ ] No secrets in docker-compose.yml
- [ ] .env.example created (no real secrets)
- [ ] Secrets in Vaultwarden
- [ ] Access control appropriate
- [ ] External access secured

### Documentation
- [ ] README.md exists
- [ ] Purpose documented
- [ ] Configuration explained
- [ ] Dependencies noted
- [ ] Troubleshooting included
- [ ] Wiki-links resolve

### Code Quality
- [ ] Follows project patterns
- [ ] Proper formatting
- [ ] Comments where needed
- [ ] No hardcoded values
- [ ] Portainer labels present

---

## Common Pitfalls

❌ **Only testing happy path** - Missed failure scenarios
❌ **Assuming success** - "Should be working" vs "Tested: works ✓"
❌ **Incomplete verification** - Container running but service broken
❌ **No documentation** - Didn't document what was tested

---

## Related

- [[work-execution]] - Best practices during implementation
- [[completion]] - Next step after validation
- [[docs/agents/TESTING]] - Testing Agent capabilities
- [[docs/mdtd/reference/critical-services]] - Extra validation requirements
