---
type: documentation
tags:
  - mdtd
  - phase-5
  - execution-planning
---

# Phase 5: Execution Planning

How to structure work into phases with proper agent assignments and acceptance criteria.

## Phasing Strategy

### Phase 0: Discovery/Inventory

**Use when:**
- Don't know complete scope
- Need to audit current state
- Exploring solution space
- Gathering requirements

**Example:**
```
Phase 0: Service Inventory
- [ ] List all services needing monitors
- [ ] Document current health check patterns
- [ ] Identify notification channels available
- [ ] Check resource availability on VM 103
```

### Implementation Phases

**Break work by:**
- **Component** - Setup, config, integration, docs
- **Risk level** - Low-risk first, then critical
- **Dependency order** - Prerequisites before dependents
- **Service category** - Group related services

### Validation Phase

**Always include:**
- Testing Agent verification
- Manual validation steps
- Edge case testing
- Integration testing

### Documentation Phase

**Don't forget:**
- Update relevant docs
- Create/update runbooks
- Document decisions made
- Capture lessons learned

---

## Agent Assignments

### Primary Agent Per Phase

```
Phase 1: Setup Infrastructure
PRIMARY AGENT: infrastructure
- [ ] Create VM [agent:infrastructure]
- [ ] Configure networking [agent:infrastructure]
- [ ] Setup storage [agent:infrastructure]

Phase 2: Deploy Services
PRIMARY AGENT: docker
- [ ] Create compose file [agent:docker]
- [ ] Configure secrets [agent:security]
- [ ] Deploy stack [agent:docker]

Phase 3: Validation
PRIMARY AGENT: testing
- [ ] Verify services running [agent:testing]
- [ ] Test functionality [agent:testing]
```

### Agent Selection Guide

| Agent | Responsibilities |
|-------|------------------|
| `infrastructure` | VMs, Proxmox, networking, storage |
| `docker` | Containers, compose, Portainer |
| `security` | Secrets, access control, VPN |
| `media` | Emby, arr services, downloads |
| `documentation` | Docs, runbooks, ADRs |
| `testing` | Validation, verification |

**See full guide:** [[reference/agent-selection]]

### Inline Tags for Tasks

- `[agent:name]` - Specific agent for this task
- `[depends:IN-XXX]` - Blocked by another task
- `[risk:N]` - Relates to risk #N in risk section
- `[blocking]` - Blocks other work
- `[optional]` - Nice-to-have, not required

---

## Writing Acceptance Criteria

### Make Criteria Specific and Testable

❌ **Bad** (vague):
- Service is working
- Everything deployed
- Docs updated

✅ **Good** (specific, testable):
- Uptime Kuma accessible at https://monitor.local:3001
- All 4 critical services showing "UP" status in dashboard
- Test alert delivered to configured email within 2 minutes
- Runbook created at docs/runbooks/uptime-kuma-setup.md with deployment steps

### Always Include

- [ ] All execution plan items completed
- [ ] Testing Agent validates (see testing plan)
- [ ] Changes committed with descriptive message (awaiting user approval)

**See detailed guide:** [[reference/acceptance-criteria]]

---

## Execution Plan Depth

**Simple tasks:**
- Major steps only
- No sub-tasks
- Single phase typically

**Moderate tasks:**
- Multiple phases
- Key tasks per phase
- Agent assignments
- Dependencies noted

**Complex tasks:**
- Granular breakdown
- Sub-tasks for complex steps
- Multiple agent coordination
- Clear dependencies
- Verification checkpoints

---

## Related Documentation

- **[[phases/04-scope-definition]]** - Previous: Defining boundaries
- **[[reference/agent-selection]]** - Agent selection guide
- **[[reference/acceptance-criteria]]** - Writing good criteria
- **[[patterns/new-service-deployment]]** - Common deployment pattern
- **[[patterns/infrastructure-changes]]** - Infrastructure change pattern
