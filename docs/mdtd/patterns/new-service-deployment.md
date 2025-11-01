---
type: documentation
tags:
  - mdtd
  - pattern
  - deployment
---

# Pattern: New Service Deployment

Standard pattern for deploying a new containerized service.

## Overview

Use this pattern when adding a new service to the infrastructure.

**Typical duration**: 2-4 hours
**Complexity**: Moderate
**Primary agents**: docker, security, testing

---

## Standard Phase Structure

### Phase 0: Preparation *(agent: infrastructure)*

- [ ] Check resource availability on target VM
  - CPU, RAM, disk space adequate?
  - Network ports available?

- [ ] Plan networking requirements
  - Ports needed?
  - DNS name?
  - External access needed?

- [ ] Review security requirements
  - What secrets needed?
  - Access control requirements?
  - Backup needs?

### Phase 1: Configuration *(agent: docker + security)*

- [ ] Create `docker-compose.yml` following project patterns
  - Use environment variables for config
  - Define health checks
  - Configure volumes for persistence
  - Setup restart policy

- [ ] Create `.env.example` template
  - Document all required variables
  - Provide example values (not real secrets!)

- [ ] Setup secrets in Vaultwarden *(agent: security)*
  - Store in appropriate collection
  - Document in `.env.example`

- [ ] Create service README
  - Purpose and functionality
  - Configuration details
  - External access info (if applicable)

### Phase 2: Deployment *(agent: docker)*

- [ ] Create stack in Portainer
  - Use Git integration pointing to monorepo
  - Configure stack name
  - Set environment variables from Vaultwarden

- [ ] Deploy stack via Portainer
  - Pull and deploy from Git
  - Wait for container healthy status

- [ ] Verify container running
  - Check `docker ps` shows healthy
  - Review logs for startup errors
  - Verify volumes created

### Phase 3: Initial Configuration *(agent: varies)*

- [ ] Complete service-specific setup
  - Initial admin user
  - Basic configuration
  - Integration with existing services (if needed)

- [ ] Test core functionality
  - Perform basic operations
  - Verify persistence (restart container, check data remains)

### Phase 4: External Access *(agent: security, if needed)*

- [ ] Setup Pangolin tunnel (if external access needed)
  - Configure tunnel
  - Test external connectivity
  - Document access URL

- [ ] Configure DNS entry (if applicable)
  - Add to Pi-hole or hosts files
  - Test name resolution

### Phase 5: Validation *(agent: testing)*

- [ ] Verify service accessible
  - HTTP endpoint returns expected response
  - Authentication works
  - Core features functional

- [ ] Test restart behavior
  - Stop container
  - Start container
  - Verify service recovers properly

- [ ] Validate persistence
  - Create test data
  - Restart container
  - Verify data persists

- [ ] Check resource usage
  - CPU/RAM within acceptable limits
  - No memory leaks
  - Disk usage reasonable

### Phase 6: Documentation *(agent: documentation)*

- [ ] Update ARCHITECTURE.md
  - Add service to relevant VM section
  - Document purpose and integration

- [ ] Create/update service README
  - Deployment instructions
  - Configuration options
  - Troubleshooting tips

- [ ] Create operational runbook (if needed)
  - Backup procedures
  - Restart procedures
  - Common issues

---

## Common Variations

### Simple Service (no external access)
- Skip Phase 4 (external access)
- Minimal Phase 3 (simple config)

### Critical Service
- Add Phase 0.5: Backup plan
- Extended Phase 5: User acceptance testing
- Add timing consideration (3-6 AM deployment)

### Service with Complex Integration
- Expand Phase 3: Multiple integration points
- Add Phase 3.5: Integration testing
- May need multiple agent coordination

---

## Standard Acceptance Criteria

- [ ] Service deployed and running
- [ ] Container status shows "healthy"
- [ ] Service accessible at documented URL/port
- [ ] Configuration documented in service README
- [ ] Secrets stored in Vaultwarden
- [ ] `.env.example` created in repository
- [ ] Stack configuration committed to git
- [ ] ARCHITECTURE.md updated
- [ ] All execution plan items completed
- [ ] Testing Agent validates
- [ ] Changes committed

---

## Common Risks

⚠️ **Port conflicts**
- Mitigation: Check port availability before deployment

⚠️ **Insufficient resources**
- Mitigation: Verify resources in Phase 0

⚠️ **Configuration errors**
- Mitigation: Use `docker compose config` to validate syntax

⚠️ **Data loss on restart**
- Mitigation: Test persistence in Phase 5

---

## Related Documentation

- **[[phases/05-execution-planning]]** - Execution planning guide
- **[[reference/agent-selection]]** - Agent selection
- **[[patterns/infrastructure-changes]]** - Infrastructure changes
- **[[examples/moderate-task]]** - Full example walkthrough
