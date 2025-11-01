---
type: documentation
category: mdtd
tags:
  - task-execution
  - agents
  - coordination
created: 2025-11-01
updated: 2025-11-01
---

# Agent Coordination

Guidance for engaging specialized agents and coordinating multi-agent work.

## Quick Reference

| Agent | Domain | When to Engage |
|-------|--------|----------------|
| Security | Secrets, tunnels, VPN | Setting up secrets, external access |
| Docker | Containers, stacks | Creating/deploying services |
| Infrastructure | VMs, Proxmox, networking | VM/network/storage changes |
| Testing | Validation, QA | Verification, health checks |
| Media Stack | Emby, arr, downloads | Critical service changes |
| Documentation | Docs, runbooks | Creating/updating docs |

**Full details:** See `[[docs/agents/README]]`

---

## Agent Selection

### By Task Category

| Category | Primary Agent | Supporting |
|----------|---------------|------------|
| Infrastructure | Infrastructure | Testing |
| Docker | Docker | Security, Testing |
| Security | Security | Testing |
| Media | Media | Docker, Testing |
| Documentation | Documentation | - |
| Testing | Testing | - |

### By Work Type

| Work | Agent(s) Needed |
|------|-----------------|
| New service | Security → Docker → Testing → Documentation |
| VM configuration | Infrastructure → Testing |
| Secret management | Security |
| Stack update | Docker → Testing |
| Tunnel setup | Security → Testing |
| Critical service | Media → Testing |

---

## Coordination Patterns

### Sequential Dependencies

Work must happen in order:

```
Phase 1: Security Agent
  └─ Output: Secrets, .env.example

Phase 2: Docker Agent (needs Phase 1)
  └─ Output: Stack name, URLs

Phase 3: Testing Agent (needs Phase 2)
  └─ Output: Validation report

Phase 4: Documentation Agent (needs Phase 3)
  └─ Output: README, updated docs
```

### Parallel Work

Work can happen simultaneously:

```
Track A: Security Agent - Pangolin tunnel
Track B: Docker Agent - docker-compose.yml
Track C: Documentation Agent - Draft README

↓ Integrate when all complete
```

### Handoff Requirements

**What each agent needs from previous:**

**Security → Docker:**
- Secret names
- .env.example template

**Docker → Testing:**
- Stack name
- Service URLs and ports
- Health endpoints

**Testing → Documentation:**
- Validation results
- Issues found
- Integration points verified

---

## Agent Planning Checklist

For each agent in strategy:

- [ ] **When** - Which phase(s)
- [ ] **What** - What they'll do
- [ ] **Needs** - What they need from previous agents
- [ ] **Delivers** - What they provide to next agents
- [ ] **Constraints** - Any restrictions they must follow

---

## Best Practices

### Clear Deliverables

✅ **Good:**
```markdown
Security Agent delivers:
- Secret name: "service-api-key"
- Location: Vaultwarden → Services/Service/API Key
- .env.example: SERVICE_API_KEY=your_key_here
```

❌ **Bad:**
```markdown
Security Agent: Setup secrets
```

### Explicit Dependencies

✅ **Good:**
```markdown
Docker Agent Phase 2:
- Requires: Secret names from Security Agent
- Cannot proceed until: .env.example available
```

❌ **Bad:**
```markdown
Docker Agent: Deploy (needs secrets)
```

### Handoff Verification

✅ **Good:**
```markdown
Testing Agent validation:
- ✓ Stack deployed (confirmed in Portainer)
- ✓ Container running (docker ps)
- ✓ Health check passes (curl 200)
- ✓ Logs clean (no errors)

Handoff to Documentation: APPROVED
```

❌ **Bad:**
```markdown
Looks good, proceed
```

---

## Coordination Challenges

### Waiting for Dependencies
**Solution:** Document what's needed clearly, verify handoff complete

### Conflicting Approaches
**Solution:** Reference standards (DECISIONS.md), get user decision

### Rollback Across Agents
**Solution:** Each phase documents rollback, undo in reverse order

---

## Related

- [[docs/agents/README]] - Complete agent documentation
- [[docs/agents/SECURITY]], [[docs/agents/DOCKER]], etc. - Individual agents
- [[strategy-development]] - Planning agent involvement
- [[work-execution]] - Engaging agents during work
