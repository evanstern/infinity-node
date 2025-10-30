# Create Task - MDTD Task Creation Assistant

Guides you through creating a new MDTD task with proper structure, critical thinking, and metadata.

## Usage

```
/create-task [brief description]
```

**Quick options:**
- `/create-task [description] --simple` - Skip exploration, create basic task quickly
- `/create-task [description]` - Normal flow with appropriate depth based on complexity

**Examples:**
```
/create-task Add Cursor configuration
/create-task Fix broken service --simple
/create-task Setup monitoring for critical services
```

## Philosophy

**Good task creation = better execution**

We invest time upfront to:
- Understand the problem clearly
- Consider alternatives (for non-trivial work)
- Identify risks before they bite us
- Define scope boundaries
- Plan execution with right agents

**But we stay pragmatic:**
- Simple tasks get simple treatment
- You can override: "keep it simple" or "skip alternatives"
- Better to create and refine than overthink

## Process Flow

### Phase 1: Understanding & Classification

**Gather Initial Information:**
1. **Title**: What are we calling this task?
2. **Problem**: What problem are we solving? Why now?
3. **Category**: infrastructure|docker|security|media|documentation|testing
4. **Priority** (0-9): How urgent/important/valuable is this?
   - 0: Critical/urgent (production down, security issue)
   - 1-2: High (important work, affects users, enables other work)
   - 3-4: Medium (valuable improvements, maintenance)
   - 5-6: Low (nice-to-haves, optimization)
   - 7-9: Very low (future considerations, ideas)

**Assess Complexity:**
AI analyzes the task and estimates:
- **Simple**: Straightforward, well-understood, low risk
- **Moderate**: Some unknowns, needs planning, moderate risk
- **Complex**: Significant unknowns, multiple approaches possible, high impact

**Present Assessment:**
```
Based on your description, this seems [simple/moderate/complex] because [reason].

Priority [N] suggests [urgency/value assessment].

Recommended approach:
- Simple: Quick creation, minimal exploration
- Moderate: Brief alternatives review, risk assessment
- Complex: Full design exploration, detailed planning

Override? Say "keep it simple" or "let's explore this thoroughly"
```

### Phase 2: Solution Design (Moderate/Complex Only)

**For Simple Tasks**: Skip to Phase 4 (Risk & Scope)

**For Moderate/Complex Tasks**: Explore the solution space

**Prompt for alternatives:**
```
Let's think through possible approaches...

I can see a few ways to do this:
1. [Approach A]: [brief description]
2. [Approach B]: [brief description]
3. [Approach C]: [brief description]

My recommendation: [Approach X] because [rationale]

Thoughts? Or should I explore these in more detail?
```

**User can:**
- Accept recommendation
- Choose different approach
- Ask for more detail on options
- Add approaches I didn't consider

**Document chosen approach with rationale**

### Phase 3: Risk Assessment & Dependencies

**Identify Risks:**
Ask about or suggest potential pitfalls:
- What could go wrong technically?
- Impact on critical services? (Emby/downloads/arr)
- Dependencies that might not be ready?
- Timing considerations?
- Security concerns?

**For each risk, define mitigation**

**Check Prerequisites:**
- What needs to exist first?
- Are those prerequisites blocking or optional?
- Any related tasks that should be completed first?

**Critical Service Check:**
If task affects Emby, downloads, or arr services:
- Requires backup plan
- Requires rollback procedure
- Requires timing consideration (low-usage window)
- Requires extra validation

**For Infrastructure/Docker/Security tasks:**
- Always include rollback plan section
- Consider backup requirements
- Estimate rollback time

### Phase 4: Scope Definition

**Define Boundaries:**

**✅ In Scope** - What we're definitely doing:
- List specific items
- Be clear and concrete

**❌ Out of Scope** - What we're explicitly NOT doing:
- Future enhancements
- Related but separate work
- Things that could cause scope creep

**🎯 MVP** - Minimum viable completion:
- What's the smallest version we can call "done"?
- What's required vs nice-to-have?

### Phase 5: Execution Planning

**Break into phases if needed:**
- Phase 0: Discovery/Inventory (if unknowns exist)
- Phase 1+: Implementation phases
- Validation phase (Testing Agent)
- Documentation phase

**For each task item:**
- Assign agent: `[agent:name]`
- Mark dependencies: `[depends:task-id]`
- Note risks: `[risk:N]`
- Flag blocking items: `[blocking]`

**Generate Acceptance Criteria:**
- Specific, testable statements
- Include "all execution plan items completed"
- Include "Testing Agent validates"

### Phase 6: Task Generation

**Determine Task ID:**
1. Read next ID from `tasks/.task-id-counter` (or scan if file missing)
2. Use format: IN-NNN (zero-padded to 3 digits)
3. Example: Counter shows 25 → use IN-025

**Generate Filename:**
Format: `IN-NNN-task-title-kebab-case.md`
- Use task ID (IN-NNN)
- Convert title to kebab-case
- Keep reasonably short (< 60 chars)
- Use descriptive keywords

**Fill Template:**
Use the template from `.obsidian/templates/task.md`, populating:

- Frontmatter with all metadata
- Problem Statement section
- Solution Design (with alternatives if explored)
- Scope Definition
- Risk Assessment with mitigations
- Rollback Plan (if infra/docker/security)
- Execution Plan with phases and agent assignments
- Acceptance Criteria
- Testing Plan
- Related Documentation
- Notes section

### Phase 7: Review & Approval

**Present Complete Task:**
```
I've designed this task:

---
Task ID: IN-NNN
File: tasks/backlog/IN-NNN-task-title.md
Priority: [N] - [rationale]
Complexity: [simple/moderate/complex]
Estimated Duration: [X]h
Critical Services: [yes/no]
---

[Show key sections: Problem, Solution, Risks, Scope, Execution Plan]

Create this task?
- "yes" - create as shown
- "revise [section]" - let's adjust something
- "no" - cancel
```

**If revisions requested:**
- Discuss changes
- Update relevant sections
- Re-present for approval

**If approved:**
- Create file in `tasks/backlog/`
- Confirm creation with task ID

### Phase 8: Post-Creation

**After successful creation:**

1. **Confirm creation:**
   ```
   ✅ Task IN-NNN created: tasks/backlog/IN-NNN-task-title.md
   ```

2. **Suggest next steps:**
   - If priority 0-2: "High priority - add to DASHBOARD.md?"
   - If dependencies exist: "Related to IN-XXX, IN-YYY"
   - "Ready to start? Use `/task IN-NNN`"

3. **Update tracking:**
   - Update "Next available" ID in this command file
   - Mention if this enables other blocked tasks

## Smart Defaults by Category

Use these as starting points when creating tasks:

**Infrastructure:**
- Primary Agent: `infrastructure`
- Common risks: Downtime, resource constraints, network issues
- Testing: VM status, service availability, resource allocation
- Always include: Rollback plan, backup requirements
- Tags: infrastructure, proxmox, vm

**Docker:**
- Primary Agent: `docker`
- Common risks: Container conflicts, volume issues, network problems
- Testing: Container running, health checks, logs clean, connectivity
- Always include: Rollback plan (especially for critical services)
- Tags: docker, containers, compose

**Security:**
- Primary Agent: `security`
- Common risks: Credential exposure, permission issues, access problems
- Testing: No secrets exposed, permissions correct, access restricted
- Always include: Audit trail, secret storage validation
- Tags: security, secrets, access-control

**Media:**
- Primary Agent: `media`
- Common risks: Service downtime, data corruption, performance degradation
- Critical service: ALWAYS include backup, rollback, timing considerations
- Testing: Service accessible, no downtime, performance acceptable, user impact
- Tags: media, critical-service

**Documentation:**
- Primary Agent: `documentation`
- Common risks: Broken links, outdated info, missing context
- Testing: Links work, content accurate, formatting correct
- Tags: documentation, docs

**Testing:**
- Primary Agent: `testing`
- Common risks: False positives/negatives, incomplete coverage
- Testing: Tests execute successfully, results documented, reproducible
- Tags: testing, qa, validation

## Examples

### Example 1: Simple Task (--simple flag)

**User:** `/create-task Fix broken homepage link --simple`

**AI:**
```
Creating simple task...

Title: "Fix broken homepage link"
Category: documentation
Priority: 6 (low - minor fix)
Complexity: simple

Skipping exploration - creating basic task.

Task IN-024 created: tasks/backlog/IN-024-fix-broken-homepage-link.md

Ready to start? Use `/task IN-024`
```

### Example 2: Moderate Task (Normal Flow)

**User:** `/create-task Add Cursor configuration files`

**AI:**
```
Let me understand this task...

What problem are we solving?
> Need Cursor-specific config to optimize AI behavior

Why now?
> Just switched from Claude Code to Cursor, want better AI context

Who benefits?
> Both user (better AI assistance) and AI (clear project understanding)

Category: documentation
Priority: 2 (high - foundational for future work)

Assessing complexity... This seems MODERATE because:
- Well-understood solution (.cursorrules and .cursorignore)
- Minimal risk (config files only)
- Some design decisions (what to include)

Recommend: Brief alternatives review, standard planning

Proceed with moderate depth? Or say "keep it simple"
```

**User:** "Yes, proceed"

**AI:**
```
Solution approaches:

1. Minimal config: Just .cursorrules with basics
   ✅ Quick to implement, gets us started
   ❌ Might miss important context

2. Comprehensive config: Both files, full project context
   ✅ Better AI understanding, optimized indexing
   ❌ More upfront work

3. Iterative: Start minimal, expand based on usage
   ✅ Learn what's actually useful
   ❌ Multiple iterations needed

Recommendation: Option 2 (Comprehensive) because foundational work
worth doing right, and we have good source material (docs/CLAUDE.md).

Agree?
```

**User:** "Sounds good"

**AI:** *(continues through risk assessment, scope definition, execution planning)*

```
I've designed this task:

---
Task ID: IN-024
File: tasks/backlog/IN-024-add-cursor-configuration.md
Priority: 2 - Foundational for all future AI work
Complexity: moderate
Estimated Duration: 2-3h
Critical Services: No
---

Problem: Need Cursor config to provide AI context about project

Solution: Create .cursorrules (AI behavior) and .cursorignore (indexing)
- Pull content from existing docs/CLAUDE.md
- Include agent system, MDTD workflow, safety guidelines
- Exclude irrelevant files from indexing

Risks:
- ⚠️ Forgetting critical info → Mitigation: Review checklist from CLAUDE.md
- ⚠️ Too verbose → Mitigation: Link to docs vs duplicating

Scope:
✅ IN: .cursorrules, .cursorignore, testing
❌ OUT: Refactoring docs, adding new features

Execution Plan:
Phase 1: Implementation (agent:documentation)
  - Create .cursorrules with project context
  - Create .cursorignore with exclusions
  
Phase 2: Validation (agent:testing)
  - Test with Claude Sonnet 4.5
  - Verify AI follows guidelines

Create this task? (yes/revise/no)
```

### Example 3: Complex Task with Override

**User:** `/create-task Migrate all services to new storage backend`

**AI:**
```
This seems COMPLEX because:
- Affects all services (high impact)
- Multiple approaches possible (NFS, Ceph, local, hybrid)
- Critical services involved (Emby, downloads)
- Significant unknowns (performance, compatibility)

Recommend: Full exploration - alternatives, phased approach, detailed risk assessment

This will take 10-15 minutes to design properly.

Proceed? Or override with "keep it simple"?
```

**User:** "Let's do it properly"

**AI:** *(Deep exploration of alternatives, detailed risk analysis, phased execution plan)*

## Rules & Guidelines

### Core Rules

1. **Always ask for approval** before creating the task file
2. **Never commit** the task file without explicit user permission  
3. **Validate task ID** is unique and sequential
4. **Respect user overrides**:
   - `--simple` flag: Skip exploration, create quickly
   - "keep it simple": Use less depth than recommended
   - "explore thoroughly": Use more depth than initial assessment

### Task Quality

5. **Match depth to complexity**:
   - Simple: Minimal exploration, standard template
   - Moderate: Brief alternatives, risk assessment
   - Complex: Full exploration, detailed planning

6. **Flag critical services** early if task affects Emby/downloads/arr:
   - Requires backup plan
   - Requires rollback procedure
   - Requires timing consideration
   - Extra validation needed

7. **Be pragmatic**:
   - Better to create and refine than overthink
   - Simple tasks shouldn't be onerous
   - Complex tasks deserve thoughtful design
   - User can always refine during pre-task review (before execution)

### Conversation Flow

8. **Be conversational but efficient**:
   - Ask clarifying questions
   - Present options clearly
   - Don't repeat information
   - Summarize before approval

9. **Collaborate on design**:
   - Present 2-3 alternatives for moderate/complex tasks
   - Recommend one with rationale
   - Accept user input and adjust
   - Document the chosen approach

10. **Use smart defaults**:
    - Suggest category/agent based on description
    - Recommend priority based on urgency/impact
    - Pre-fill testing criteria by category
    - Suggest relevant documentation links

### Risk & Safety

11. **Always consider**:
    - Impact on critical services
    - Dependencies that might not be ready
    - Rollback plan for infrastructure/docker/security
    - Timing for disruptive changes

12. **Document mitigations**:
    - For each identified risk, provide mitigation
    - Don't just list risks - show how we'll handle them
    - Consider "what could go wrong" proactively

### Scope Management

13. **Define boundaries clearly**:
    - Explicit "in scope" list
    - Explicit "out of scope" list  
    - MVP definition for complex tasks
    - Prevents scope creep during execution

### Agent Assignment

14. **Assign agents thoughtfully**:
    - Use primary agent for phase
    - Use inline `[agent:name]` for specific tasks
    - Note when agent collaboration needed
    - Testing Agent for all validation phases

15. **Use inline tags consistently**:
    - `[agent:name]` - who does this
    - `[depends:task-id]` - blocking dependency
    - `[risk:N]` - relates to risk #N
    - `[blocking]` - blocks other work
    - `[optional]` - nice-to-have

### Post-Creation

16. **After creating task**:
    - Confirm creation with task ID and path
    - Increment and update `tasks/.task-id-counter`
    - Suggest next steps (DASHBOARD, related tasks)
    - Ask if user wants to start: `/task IN-NNN`

## Task ID Management

**Automated Counter System:**

The task ID is managed via `tasks/.task-id-counter` (gitignored, local state only).

**Process:**
1. **If counter file exists**: Read number, use it, increment and save
2. **If counter file missing**: Scan all tasks, find highest, create counter with next number

**Implementation:**
```bash
# Get next task ID
if [ -f tasks/.task-id-counter ]; then
  # File exists - read current counter
  TASK_ID=$(cat tasks/.task-id-counter)
else
  # File doesn't exist - scan and find highest
  HIGHEST=$(find tasks/ -name "IN-*.md" | \
    sed 's/.*IN-//' | sed 's/-.*//' | \
    sort -n | tail -1)
  TASK_ID=$((HIGHEST + 1))
fi

# Use TASK_ID for new task (format: IN-024, IN-025, etc.)

# After successful task creation, increment and save
NEXT_ID=$((TASK_ID + 1))
echo $NEXT_ID > tasks/.task-id-counter
```

**Recovery:**
If counter gets out of sync (manual task creation, etc.), simply delete `tasks/.task-id-counter` and it will rescan on next task creation.

**Benefits:**
- ✅ No need to commit command file every time
- ✅ Self-healing (delete to rescan)
- ✅ Simple text file, easy to inspect/edit
- ✅ Fast (no scanning once file exists)

## Complexity Decision Guide

**When to recommend each complexity level:**

**Simple:**
- Well-understood, routine work
- Single approach, no alternatives needed
- Low risk, low impact
- Quick to implement (< 2 hours)
- Examples: Fix typo, add link, restart service

**Moderate:**
- Some design decisions needed
- 2-3 viable approaches
- Moderate risk or moderate impact
- Reasonable implementation time (2-6 hours)
- Examples: Add feature, update config, create documentation

**Complex:**
- Significant unknowns or design space
- Multiple approaches with trade-offs
- High risk or high impact
- Substantial implementation time (6+ hours)
- Affects critical services
- Requires phased approach
- Examples: Infrastructure migration, major refactor, new system integration

