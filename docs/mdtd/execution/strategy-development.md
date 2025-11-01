---
type: documentation
category: mdtd
tags:
  - task-execution
  - strategy
  - planning
created: 2025-11-01
updated: 2025-11-01
---

# Strategy Development

Thoughtful planning before implementation to reduce risk and accelerate execution.

## When to Use

**Always plan for:**
- Moderate or complex tasks
- Tasks affecting critical services
- Infrastructure or security changes
- Multi-domain/multi-agent work

**Quick strategy for:**
- Simple tasks (document approach in a few sentences)

---

## Strategy Checklist

### 1. Analyze Implementation Options

- [ ] **Consider 2-3 approaches**
  - Don't just pick first idea
  - Document pros/cons
  - Keep solutions simple

- [ ] **Evaluate by:**
  - Technical feasibility
  - Risk level
  - Time/complexity trade-offs
  - Maintainability
  - Alignment with patterns

### 2. Identify Edge Cases

- [ ] What could go wrong?
- [ ] Unusual conditions?
- [ ] Dependencies might fail?
- [ ] Timing issues?
- [ ] What if credentials wrong?
- [ ] What if service already exists?

### 3. Evaluate Pitfalls

**Check for:**
- [ ] Technical challenges
- [ ] Risk to existing services
- [ ] Performance implications
- [ ] Security concerns
- [ ] Maintainability issues

**Prioritize:**
1. **Critical** - Must fix now (blocks success/high risk)
2. **Important** - Should fix now (reasonable effort)
3. **Nice-to-have** - Marginal benefit
4. **Future** - Valuable but out of scope

### 4. Plan Agent Coordination

**Identify relevant agents:**

| Agent | When to Engage |
|-------|----------------|
| Security | Secrets, tunnels, VPN, access control |
| Docker | Containers, stacks, Portainer |
| Infrastructure | VMs, Proxmox, networking, storage |
| Testing | Validation, verification, health checks |
| Media Stack | Emby, arr services, downloads (CRITICAL) |
| Documentation | Docs, runbooks, knowledge capture |

**For each agent document:**
- [ ] When they're needed (which phase)
- [ ] What they'll do
- [ ] What they need from previous agents
- [ ] What they'll deliver to next agents
- [ ] Any constraints they must follow

**Coordination patterns:**
- **Sequential:** A must complete before B can start
- **Parallel:** A and B can work simultaneously
- **Handoff:** Clear deliverables from A to B

### 5. Handle New Requirements

**If new work emerges during planning:**

- [ ] Assess scope impact (time, risk, complexity)
- [ ] Discuss with user
- [ ] Options: add to task, defer, or create new task
- [ ] Update task if adding
- [ ] Keep scope manageable

---

## Present Strategy

**Good presentation:**
```markdown
## Strategy for IN-XXX

**Approach:** [Chosen option + brief rationale]

**Phases:**
1. [Phase] - [Brief description]
2. [Phase] - [Brief description]

**Agent Assignments:**
- Security Agent: [Phase X] - [What they'll do]
- Docker Agent: [Phase Y] - [What they'll do]
- Testing Agent: [Phase Z] - [What they'll do]

**Key Decisions:**
- [Decision]: [Rationale]

**Risk Mitigation:**
- [Risk]: [How we'll handle it]

**Edge Cases:**
- [Case]: [How we'll handle it]

**Out of Scope:**
- [Item]: [Why deferring]

**Estimated Time:** [Duration]

Proceed?
```

---

## Anti-Patterns

❌ **Over-engineering** - Build comprehensive system vs simple solution
❌ **Analysis paralysis** - Analyzing 96 combinations of approaches
❌ **No concrete plan** - "We'll figure it out as we go"
❌ **Ignoring constraints** - Manual docker-compose vs Portainer API

---

## Related

- [[pre-task-review]] - Critical analysis before planning
- [[work-execution]] - Following strategy during work
- [[agent-coordination]] - Detailed agent engagement patterns
- [[docs/agents/README]] - Agent capabilities
- [[docs/mdtd/phases/02-solution-design]] - Alternative evaluation
