# Create Task - MDTD Task Creation Assistant

Guides you through creating a new MDTD task with proper structure, critical thinking, and metadata.

## Quick Reference

**Usage**: `/create-task [description] [--simple]`

**What it does**:
- Creates task in `tasks/backlog/` with unique ID
- Adapts depth to complexity (simple/moderate/complex)
- Uses scripts for ID management and validation
- Always asks approval before creating

**Need detailed guidance?** Load docs as needed:
- Overview: `[[docs/mdtd/overview]]` - Philosophy and when to create tasks
- Phases: `[[docs/mdtd/phases/]]` - Detailed phase guides (load specific phase)
- Reference: `[[docs/mdtd/reference/]]` - Quick lookups (complexity, agents, criteria)
- Patterns: `[[docs/mdtd/patterns/]]` - Common task patterns
- Examples: `[[docs/mdtd/examples/]]` - Full task walkthroughs
- Navigation: `[[docs/mdtd/README]]` - Index of all modular docs

---

## 🚨 CRITICAL STEPS - Execute These

### Get Next Task ID
```bash
TASK_ID=$(./scripts/tasks/get-next-task-id.sh)
echo "Creating task: $TASK_ID"
```

### After Creating Task File
```bash
./scripts/tasks/update-task-counter.sh
./scripts/tasks/validate-task.sh $TASK_ID
```

**ALWAYS execute these scripts. They enforce correct ID sequencing and validate task structure.**

---

## Process Flow

### Phase 1: Understanding & Classification

**Gather:**
- Title, problem statement, category, priority (0-9)

**Assess complexity:**
- **Simple**: Well-understood, < 2h, single approach
- **Moderate**: Some design decisions, 2-6h, 2-3 approaches
- **Complex**: Multiple approaches, 6+ hours, high impact

**Present assessment and get approval for depth:**
```
This seems [COMPLEXITY] because [reasons].
Recommend: [simple/moderate/complex] approach.
Proceed? (or say "keep it simple"/"explore thoroughly")
```

---

### Phase 2: Solution Design

**For Simple**: Skip to Phase 3

**For Moderate/Complex**:
1. Present 2-3 approaches with pros/cons
2. Recommend one with rationale
3. Document chosen approach + why alternatives rejected

---

### Phase 3: Risk Assessment

**Check for risks:**
- [ ] Technical risks
- [ ] Impact on critical services (Emby/downloads/arr)
- [ ] Dependencies not ready
- [ ] Timing considerations
- [ ] Security concerns

**For each risk**: Define mitigation

**Critical services check**: If affects Emby/downloads/arr:
- [ ] Backup plan required
- [ ] Rollback procedure required
- [ ] Timing consideration (3-6 AM window)
- [ ] Set `critical_services_affected: true`
- [ ] Set `requires_backup: true`

**Rollback planning**: For infrastructure/docker/security tasks:
- Step-by-step rollback procedure
- Recovery time estimate
- Backup requirements

---

### Phase 4: Scope Definition

**Define boundaries:**

✅ **In Scope**: [Specific deliverable 1], [2], [3]

❌ **Out of Scope**: [Future work], [Separate concern], [Scope creep item]

🎯 **MVP**: What's minimum viable completion?

---

### Phase 5: Execution Planning

**Structure:**
- Phase 0: Discovery (if unknowns exist)
- Phase 1+: Implementation phases
- Validation: Testing Agent
- Documentation: Documentation Agent

**Agent assignments** - Use inline tags:
- `[agent:name]` - who does this
- `[depends:IN-XXX]` - blocking dependency
- `[risk:N]` - relates to risk #N
- `[blocking]` - blocks other work
- `[optional]` - nice-to-have

**Acceptance criteria**: Specific, testable statements

---

### Phase 6: Task Generation

**⚠️ CHECKPOINT - Execute in order:**

- [ ] **Get task ID**: `TASK_ID=$(./scripts/tasks/get-next-task-id.sh)`
- [ ] **Generate filename**: `IN-NNN-task-title-kebab-case.md` (< 60 chars)
- [ ] **Fill template**: Use `templates/task-template.md`
- [ ] **Populate sections**: Problem, solution, risks, scope, execution, acceptance, testing
- [ ] **Set frontmatter**: All required fields (see template)

**Required frontmatter fields:**
```yaml
type: task
task-id: IN-NNN
status: pending
priority: N
category: [infrastructure|docker|security|media|documentation|testing]
agent: [agent-name]
created: YYYY-MM-DD
updated: YYYY-MM-DD
complexity: [simple|moderate|complex]
estimated_duration: X-Yh
critical_services_affected: [true|false]
requires_backup: [true|false]
```

---

### Phase 7: Review & Approval

**Present summary:**
```
Task ID: IN-NNN
File: tasks/backlog/IN-NNN-task-title.md
Priority: [N] - [rationale]
Complexity: [simple/moderate/complex]

PROBLEM: [One paragraph]
SOLUTION: [One paragraph]
RISKS: [Key risks + mitigations]
SCOPE: ✅ IN: [...] | ❌ OUT: [...]
EXECUTION: [Phase summary]

Create this task? (yes/revise [section]/no)
```

**If revisions**: Discuss, update, re-present

**If approved**: Proceed to creation

---

### Phase 8: Post-Creation

**After creating file:**

1. **Update counter**:
   ```bash
   ./scripts/tasks/update-task-counter.sh
   ```

2. **Validate**:
   ```bash
   ./scripts/tasks/validate-task.sh IN-NNN
   ```

3. **Confirm**:
   ```
   ✅ Task IN-NNN created: tasks/backlog/IN-NNN-task-title.md
   Counter updated: Next task will be IN-NNN+1
   ```

4. **Suggest next steps**:
   - High priority (0-2)? → "Add to DASHBOARD.md?"
   - Has dependencies? → "Related to IN-XXX"
   - Ready to start? → "Use `/task IN-NNN`"

---

## Essential Rules

### Critical (NEVER VIOLATE)

1. **ALWAYS use task ID scripts** - Never manually determine IDs
2. **ALWAYS update counter after creating** - Keep counter in sync
3. **ALWAYS validate with script** - Catch issues immediately
4. **ALWAYS ask approval** - Never create without user agreement
5. **NEVER commit** - Task creation doesn't auto-commit

### Process

6. **Match depth to complexity** - Don't over-plan simple tasks
7. **Flag critical services early** - Emby/downloads/arr need extra care
8. **Document mitigations** - Don't just list risks, show how we'll handle them
9. **Be pragmatic** - Better to create and refine than overthink

### Safety

10. **Critical services** (Emby/downloads/arr) require:
    - Backup plan, rollback procedure, timing consideration, extra validation

11. **Infrastructure/docker/security** tasks require:
    - Rollback plan with recovery time estimate

---

## Smart Defaults by Category

| Category | Agent | Common Risks | Testing Focus | Always Include |
|----------|-------|--------------|---------------|----------------|
| **infrastructure** | infrastructure | Downtime, resource constraints | VM status, service availability | Rollback plan, backups |
| **docker** | docker | Container conflicts, volume issues | Health checks, logs, connectivity | Rollback plan |
| **security** | security | Credential exposure, permissions | No secrets exposed, access restricted | Audit trail, validation |
| **media** | media | Downtime, data corruption | Service accessible, no downtime | Backup, rollback, timing |
| **documentation** | documentation | Broken links, outdated info | Links work, content accurate | N/A |
| **testing** | testing | False positives/negatives | Tests execute, reproducible | N/A |

---

## Priority Guide

- **0**: Critical/urgent (production down, security issue)
- **1-2**: High (affects users, enables other work)
- **3-4**: Medium (valuable improvements, maintenance)
- **5-6**: Low (nice-to-haves, optimization)
- **7-9**: Very low (future considerations, ideas)

---

## Complexity Guide

**Simple**:
- Well-understood, routine work
- Single approach, no alternatives needed
- Low risk, low impact, < 2 hours
- Examples: Fix typo, update config value, restart service

**Moderate**:
- Some design decisions needed, 2-3 viable approaches
- Moderate risk or impact, 2-6 hours
- Examples: Add feature, create documentation, setup service

**Complex**:
- Significant unknowns, multiple approaches with trade-offs
- High risk or impact, 6+ hours, affects critical services
- Requires phased approach
- Examples: Infrastructure migration, major refactor, system integration

---

## Quick Example: Simple Task

**User**: `/create-task Fix broken link in docs --simple`

**AI**:
```bash
TASK_ID=$(./scripts/tasks/get-next-task-id.sh)
# Returns: IN-037

Creating simple task IN-037...

Title: "Fix broken link in docs"
Category: documentation
Priority: 6 (low - minor fix)
Complexity: simple

[Creates basic task file from template]

./scripts/tasks/update-task-counter.sh
./scripts/tasks/validate-task.sh IN-037

✅ Task IN-037 created: tasks/backlog/IN-037-fix-broken-link-in-docs.md

Ready to start? Use `/task IN-037`
```

---

## Troubleshooting

**Counter out of sync?**
```bash
# Delete and rescan
rm tasks/.task-id-counter
./scripts/tasks/get-next-task-id.sh  # Will rescan and recreate
```

**Duplicate task IDs?**
```bash
# Find duplicates
find tasks/ -name "IN-NNN-*.md"

# Keep correct one, delete others
rm tasks/wrong-location/IN-NNN-*.md
```

**Validation failed?**
```bash
# Run validation to see issues
./scripts/tasks/validate-task.sh IN-NNN

# Fix issues shown, then revalidate
```

---

## Reference Documentation

**Load modular docs as needed** (don't load everything!):

**By phase** - Load when working on that phase:
- [[docs/mdtd/phases/01-understanding|Phase 1: Understanding]] - Classification & assessment
- [[docs/mdtd/phases/02-solution-design|Phase 2: Solution Design]] - Evaluating alternatives
- [[docs/mdtd/phases/03-risk-assessment|Phase 3: Risk Assessment]] - Risks & mitigation
- [[docs/mdtd/phases/04-scope-definition|Phase 4: Scope]] - Defining boundaries
- [[docs/mdtd/phases/05-execution-planning|Phase 5: Execution]] - Structuring work

**Quick reference** - Load for specific questions:
- [[docs/mdtd/reference/complexity-assessment|Complexity Assessment]] - Simple/moderate/complex criteria
- [[docs/mdtd/reference/priority-assignment|Priority Assignment]] - How to prioritize (0-9)
- [[docs/mdtd/reference/agent-selection|Agent Selection]] - Which agent for what work
- [[docs/mdtd/reference/acceptance-criteria|Acceptance Criteria]] - Writing testable criteria
- [[docs/mdtd/reference/critical-services|Critical Services]] - Requirements for Emby/arr/downloads

**Patterns** - Load when doing similar work:
- [[docs/mdtd/patterns/new-service-deployment|New Service Deployment]] - Deploy containerized service
- [[docs/mdtd/patterns/infrastructure-changes|Infrastructure Changes]] - VM/network/storage changes
- [[docs/mdtd/patterns/troubleshooting|Troubleshooting]] - Investigation & root cause

**Examples** - Load one if helpful:
- [[docs/mdtd/examples/simple-task|Simple Task Example]] - Quick, straightforward work (~15 min)
- [[docs/mdtd/examples/moderate-task|Moderate Task Example]] - Standard feature/improvement
- [[docs/mdtd/examples/complex-task|Complex Task Example]] - Multi-phase, critical services

**Core resources**:
- [[docs/mdtd/README|MDTD Docs Index]] - Navigation hub for all modular docs
- [[docs/mdtd/overview|MDTD Overview]] - Philosophy and when to create tasks
- [[templates/task-template|Task Template]] - Template structure and fields

**Related systems**:
- [[docs/AI-COLLABORATION#MDTD|MDTD System Overview]]
- [[docs/agents/README|Agent System]]
- [[tasks/README|Task Management]]
- [[scripts/README#Task Lifecycle Management|Task Scripts]]
