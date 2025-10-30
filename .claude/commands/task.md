# Task Execution - Complete Task Workflow

Execute a MDTD task from start to finish with comprehensive planning, review, and documentation.

## Usage

```
/task IN-XXX [optional context]
```

**Arguments:**
- `IN-XXX` (required): The task ID (e.g., IN-001, IN-015)
- `[optional context]` (optional): Any additional context, clarification, or extra information relevant to the task

**Examples:**
```
/task IN-005
/task IN-012 focus on docker DNS integration first
/task IN-004 prioritize the deployment guide section
/task IN-015 user reported issues with the arr stack specifically
```

**Using the optional context:**
- Use this to provide clarification or emphasis on specific aspects
- Highlight priority areas within the task scope
- Provide additional information discovered after task creation
- Pass along user feedback or specific concerns
- This context should inform your approach but doesn't override the task itself

## Process Overview

This command guides you through the complete lifecycle of executing a MDTD task, from initial review through completion and documentation.

## Phase 1: Pre-Task Review

**IMPORTANT:** Conduct a thorough critical review of the task before beginning work.

1. **Locate and Read Task**
   - Find task file by ID: `tasks/*/IN-XXX-*.md`
   - Read the entire task: description, context, acceptance criteria, dependencies
   - Understand the goal, scope, and expected outcomes

2. **Critical Analysis**

   Look for potential issues and gaps:

   - **Missing inventory/scope**: Do we know exactly what needs to be done?
   - **Phased approach**: Should this be broken into phases to reduce risk?
   - **Rollback procedures**: Can we recover if something goes wrong?
   - **Testing criteria**: Are tests specific enough to validate success?
   - **Dependencies**: Are all prerequisites truly ready?
   - **Impact on critical services**: Could this affect Emby, downloads, or arr services?
   - **Timing considerations**: Should this be done during low-usage windows (3-6 AM)?
   - **Secret/security concerns**: Are we exposing or mishandling sensitive data?
   - **Cross-service impacts**: Could this affect other services?
   - **Documentation gaps**: Is the plan clear enough to execute?

3. **Check for Common Weak Points**
   - No inventory of what will be changed
   - "Audit all" without knowing the scope
   - Single big-bang approach instead of phased
   - No rollback plan
   - Vague testing ("verify it works")
   - Missing backup steps
   - Unclear deployment method
   - No consideration of shared resources/secrets

4. **Document Findings**
   - List specific gaps or concerns found
   - Assess risk level of each issue
   - Propose concrete improvements (checklists, phases, specific tests)
   - Suggest risk mitigation strategies

5. **Present Review to User**
   - Share findings clearly and concisely
   - Recommend specific changes to the task
   - Get user approval before proceeding
   - Be prepared for scope to evolve based on findings

**Skip pre-task review only if:**
- Task is trivial (typo fixes, etc.)
- Task has very clear, limited scope
- Emergency fix where speed is critical

## Phase 2: Task Refinement

**If pre-task review identified issues:**

1. **Collaborate with User**
   - Discuss proposed improvements
   - Clarify ambiguities
   - Adjust scope if needed
   - Get agreement on approach

2. **Update Task File**
   - Add missing sections (inventory, rollback plan, etc.)
   - Enhance testing criteria to be specific
   - Break into phases if appropriate
   - Clarify deployment procedures
   - Update acceptance criteria
   - Add risk mitigation steps

3. **Get Final Approval**
   - Confirm task is now robust enough to execute
   - Ensure user agrees with refined plan
   - Document that scope may evolve during work (this is OK!)

## Phase 3: Strategy Development

**Take extra time for thoughtful planning:**

1. **Analyze Implementation Options**
   - Consider multiple approaches
   - Document pros and cons of each
   - Keep solutions simple
   - Stay within task scope

2. **Identify Edge Cases**
   - What could go wrong?
   - What unusual conditions might exist?
   - What dependencies might fail?
   - What timing issues could occur?

3. **Evaluate Pitfalls**
   - Technical challenges
   - Risk to existing services
   - Performance implications
   - Security concerns
   - Maintainability issues

4. **Plan Solutions**
   - For critical pitfalls: propose solutions (keep simple)
   - For non-critical issues: suggest follow-up tasks
   - Document trade-offs
   - Prioritize what must be addressed now vs. later

5. **Consult with Agents and Plan Agent Usage**
   - Identify which specialized agents are relevant to this task
   - Consult agent documentation to understand their capabilities and constraints
   - Decide which agents should be engaged during execution:
     - Security Agent for secrets, tunnels, access control
     - Docker Agent for container configurations
     - Infrastructure Agent for VM/Proxmox changes
     - Testing Agent for validation and verification
     - Media Stack Agent for critical services (Emby, downloads, arr)
     - Documentation Agent for docs and runbooks
   - Document agent assignments in strategy
   - Note any agent coordination requirements
   - Consider agent-specific constraints (e.g., Testing Agent read-only access)

6. **Present Strategy**
   - Share analysis with user
   - Explain recommended approach
   - Discuss alternative options if relevant
   - Get user approval on strategy

6. **New Requirements During Planning**
   - If new requirements emerge: discuss with user
   - Update task file to reflect new requirements
   - Consider if new task should be created instead
   - Keep scope manageable

## Phase 4: Begin Execution

**Once strategy is approved:**

1. **Mark Task as In Progress**
   - Update task frontmatter: `status: in-progress`
   - Update `started` timestamp

2. **Move Task to Current Folder**
   - Move from `tasks/backlog/` to `tasks/current/`
   - Maintain filename (includes task ID)

3. **Update Task References**
   - Search for references to old task path
   - Update wiki-links in other documents
   - Check DASHBOARD.md and related tasks

4. **Use TodoWrite Tool**
   - Break down work into session tasks
   - Track progress during implementation
   - Mark items as completed as you go

## Phase 5: Execute Work

**While working:**

1. **Follow the Strategy**
   - Implement according to approved plan
   - Work through phases in order
   - Test incrementally

2. **Task is Source of Truth**
   - Do NOT make changes outside task scope
   - If new work is needed: stop and discuss
   - Either update task requirements or create new task
   - Never diverge silently from documented plan

3. **Engage Agents**
   - Use appropriate specialized agents as needed:
     - Docker Agent for container work
     - Security Agent for secrets/tunnels
     - Infrastructure Agent for VM changes
     - Testing Agent for validation
     - Documentation Agent for docs
   - Use Task tool with appropriate subagent_type
   - Coordinate multiple agents for complex work

4. **Update Task Continuously**
   - Check off acceptance criteria as completed
   - Update progress notes in real-time
   - Document decisions made and rationale
   - Note lessons learned (what worked, what didn't)
   - Update information if task details change
   - Record any issues encountered

5. **Watch for Script Opportunities**
   - Notice repeated command patterns
   - Identify operations that could be scripted
   - Propose script extraction to user
   - Create scripts if approved
   - Use new scripts immediately to validate

## Phase 6: Testing & Validation

**Before considering task complete:**

1. **Verify All Acceptance Criteria**
   - Check each criterion explicitly
   - Test functionality thoroughly
   - Validate with appropriate agent if needed

2. **Test Edge Cases**
   - Test failure scenarios
   - Verify error handling
   - Check dependent services

3. **Run Automated Tests**
   - If applicable, run test suite
   - Verify no regressions

4. **Manual Validation**
   - Test user-facing functionality
   - Verify expected behavior
   - Check logs for errors

## Phase 7: Completion

**When work is finished and tested:**

1. **Final Task Update**
   - Ensure all acceptance criteria checked off
   - Complete all progress notes
   - Document final outcomes
   - Add comprehensive lessons learned section
   - Update `completed` timestamp

2. **Update Status**
   - Set frontmatter: `status: completed`

3. **Move to Completed**
   - Move task from `tasks/current/` to `tasks/completed/`

4. **Update References**
   - Update wiki-links in other documents
   - Update DASHBOARD.md

5. **Ask About Commit**
   - Present summary of changes made
   - **ASK USER**: "Would you like me to commit these changes?"
   - **NEVER commit without explicit approval**
   - If approved, use `/commit` command

## Important Rules

### Scope Management
- **Task is the source of truth** - do not deviate
- If new work is needed, update task or create new task
- Discuss scope changes with user before making them
- Document all changes in task file

### Safety
- Always backup before destructive operations
- Test incrementally, not all at once
- For critical services: extra caution, consider timing
- Have rollback plan ready

### Documentation
- Update task file continuously, not at the end
- Document "why" decisions were made
- Capture lessons learned as you discover them
- Keep notes detailed enough for future reference

### Commits
- **ALWAYS ask before committing**
- Never commit without explicit user approval
- Use `/commit` command when approved
- Include task reference in commit message

### Flexibility
- Scope may evolve during work - this is OK
- Discovery may change the nature of the task
- Communicate findings and adjust accordingly
- Update task to reflect actual work performed

## Examples

### Good Pre-Task Review Finding
```
After reviewing IN-012 (Setup Local DNS), I found these issues:

1. No inventory of services that need DNS entries
2. No rollback plan if DNS resolution breaks
3. Testing criteria is vague ("verify DNS works")
4. Missing consideration of docker container name resolution

Recommendations:
- Add Phase 0: Inventory all services needing DNS
- Add rollback: keep /etc/hosts backup and restore procedure
- Specify test: "nslookup service.local must resolve to correct IP"
- Document docker DNS integration requirements

Should I update the task with these improvements?
```

### Good Strategy Discussion
```
For IN-004 (Document Emby), I see two approaches:

Option A: Single comprehensive document
Pros: Everything in one place, easier to find
Cons: Large file, harder to maintain, might duplicate arch docs

Option B: Focused service doc + arch references
Pros: Follows existing pattern, avoids duplication, easier to update
Cons: Information split across files

I recommend Option B because it matches our existing docs pattern
and makes maintenance easier. We'll create docs/services/emby.md
with service-specific info and link to ARCHITECTURE.md for
infrastructure details.

Does this approach work for you?
```

### Good Progress Update in Task
```markdown
## Progress Notes

### 2024-01-15 14:30 - Initial Audit
Completed inventory of all services. Found 15 services requiring DNS entries.
Documented in checklist below.

### 2024-01-15 15:45 - DNS Server Setup
Installed and configured dnsmasq on VM-100. Chose dnsmasq over bind for
simplicity - we only need basic A records, not full DNS features.

### 2024-01-15 16:20 - Docker Integration Issue
Discovered docker containers can't resolve .local domains. Need to configure
docker daemon.json to use our DNS server. Adding this to requirements.

**Lesson learned**: Should have checked docker DNS integration in pre-task review.
```

## Reference

- Pre-Task Review details: [[docs/CLAUDE#Pre-Task Review]]
- Task Management: [[tasks/README|MDTD System]]
- Agent System: [[docs/agents/README]]
