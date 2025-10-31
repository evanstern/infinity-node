---
type: documentation
tags:
  - ai-assistant
  - collaboration
  - guide
  - workflow
---

# Working with AI Assistants

This guide explains how to effectively work with AI assistants in the infinity-node project. It's designed for both the human collaborator (Evan) and the AI assistant itself.

## Compatibility

This project works with multiple AI models and tools:
- **Claude Sonnet 4.5** (currently using in Cursor)
- **Claude Code** (previously used)
- Other AI assistants that support the agent system pattern

The workflows and patterns described here are tool-agnostic, though specific tools may be mentioned when discussing their unique features.

## Core Principles

### 1. Collaborative Partnership
- We work **together** as co-workers, not boss/assistant
- Claude can and should advocate for better solutions
- Evan has final say, but discussion is encouraged
- Respectful, lighthearted, casual communication

### 2. Agent-Based Workflow
- The AI assistant adopts specialized agent personas based on task domain
- Each agent has specific permissions and restrictions
- Agents coordinate on complex tasks
- See [[agents/README|Agent System]] for details

### 3. MDTD Task Management
- All significant work tracked via MDTD tasks
- Tasks created before starting work
- Progress updated in real-time
- Completed tasks documented with lessons learned

### 4. Safety First
- **Critical services** (Emby, downloads, arr) require extra caution
- Testing Agent validates changes before production
- Always backup before destructive operations
- When in doubt, ask before proceeding

## Project Structure

### This is an Obsidian Vault
- Repository root is an Obsidian vault
- Use wiki-links: `[[DOCKER]]` instead of `[Docker](DOCKER.md)`
- Frontmatter on all documentation for Dataview queries
- Works without Obsidian but enhanced with it

### Key Directories
```
infinity-node/
├── docs/               # All documentation
│   ├── agents/        # Agent specifications
│   ├── runbooks/      # Operational procedures
│   └── services/      # Service-specific docs
├── tasks/             # MDTD task management
│   ├── current/       # Active work
│   ├── backlog/       # Future work
│   └── completed/     # Finished work
├── stacks/            # Docker configurations
└── scripts/           # Automation scripts
```

## Working with Agents

### Agent Selection

The AI assistant automatically adopts the appropriate agent persona based on task context:

**Examples:**
- "Set up a new Docker stack for X" → [[agents/DOCKER|Docker Agent]]
- "Validate the deployment works" → [[agents/TESTING|Testing Agent]]
- "Configure Pangolin tunnel" → [[agents/SECURITY|Security Agent]]
- "Update the runbook" → [[agents/DOCUMENTATION|Documentation Agent]]
- "Optimize Emby transcoding" → [[agents/MEDIA|Media Stack Agent]]
- "Create a new VM" → [[agents/INFRASTRUCTURE|Infrastructure Agent]]

### Agent Coordination

Complex tasks require multiple agents working together:

**Example: Deploying a New Service**
1. **Documentation Agent**: Create MDTD task
2. **Security Agent**: Set up secrets/tunnels
3. **Infrastructure Agent**: Ensure adequate VM resources
4. **Docker Agent**: Create and deploy docker-compose
5. **Testing Agent**: Validate deployment
6. **Documentation Agent**: Document the service

### Critical Service Protection

The [[agents/MEDIA|Media Stack Agent]] manages services that affect household users:
- **Emby**: Streaming media server
- **Downloads**: Active downloads must not corrupt
- **arr services**: Media automation pipeline

**Special requirements:**
- Test in non-production when possible
- Always backup configurations
- Deploy during low-usage windows (3-6 AM)
- Have rollback plan ready
- Monitor closely after changes
- Coordinate with Testing Agent

## MDTD Workflow

### Creating Tasks

1. **Use Template**
   - **Cursor AI**: Use `/create-task` command (automatically uses template)
   - **Manual**: Copy `templates/task-template.md`
   - See [[templates/README|Template Documentation]] for details

2. **Fill Metadata**
   ```yaml
   status: pending
   priority: 3  # 0 (critical) → 1-2 (high) → 3-4 (medium) → 5-6 (low) → 7-9 (very low)
   category: infrastructure|docker|security|media|documentation
   agent: testing|docker|infrastructure|security|media|documentation
   ```

3. **Define Acceptance Criteria**
   - Clear, testable statements
   - No ambiguity about completion
   - Validated by Testing Agent

4. **Save to Appropriate Directory**
   - `tasks/backlog/` - Not yet started
   - `tasks/current/` - Active work
   - `tasks/completed/` - Finished

### Task Lifecycle

```
backlog/ (pending)
    ↓
current/ (in-progress)
    ↓
current/ (blocked) ← if waiting on dependency
    ↓
current/ (in-progress)
    ↓
completed/ (completed)
```

### Task Execution Workflow

**🚨 CRITICAL: Read this entire workflow before starting any task**

**When Starting a Task:**
1. **FIRST**: Update task status to `in-progress` in frontmatter
2. **THEN**: Use `git mv` to move task file from `backlog/` to `current/`
   - ⚠️ **DO NOT COMMIT YET** - All work commits at end only
3. Begin work on the task phases

**During Task Execution:**
1. **🚨 Check off execution plan items IN REAL-TIME** as phases are completed
   - This is REQUIRED, not optional
   - Update the task file after each phase completes
   - Never skip this step - it tracks progress
2. **Check off acceptance criteria** as items are completed
3. **After each phase completes**: Pause to reflect
   - Add notes to work log about decisions made
   - Document discoveries or issues encountered
   - Suggest changes if new information warrants it
   - Update any affected sections of the task
4. **🚨 Document lessons learned as you go**:
   - Not every task needs extensive lessons, but capture important learnings
   - What worked well that could be reused?
   - What could be improved next time?
   - Did we discover something that affects other systems/services?
   - Are there patterns or insights that should be documented elsewhere?
5. Continue to next phase

**When Task Work is Complete:**
1. **DO NOT immediately mark as complete**
2. **🚨 DO NOT COMMIT ANYTHING** - Wait for approval first
3. **PAUSE** and present work to user for review:
   - Summarize what was accomplished
   - Show what changed
   - Highlight any deviations from original plan
   - Note any remaining acceptance criteria that need user validation
4. **WAIT** for user approval

**After User Approves Task Work - Lessons Learned Review Phase:**
1. **Review the Lessons Learned section** of the task:
   - Is there anything we figured out that affects future work?
   - Did we discover gaps in documentation?
   - Did we learn something that should be captured in runbooks or ADRs?
   - Are there follow-up improvements needed?
2. **Decide on documentation updates**:
   - Does any existing documentation need updating based on what we learned?
   - Should we create new documentation (runbooks, ADRs, etc.)?
   - Note specific doc updates needed in the task
3. **Decide on follow-up tasks**:
   - Should new tasks be created based on discoveries?
   - List specific follow-up tasks in the task notes
   - Don't create the tasks yet - just document what's needed
4. **Present review findings to user**:
   - Summarize lessons learned
   - Propose any documentation updates
   - Propose any follow-up tasks
   - Get approval on what should be done

**After Lessons Learned Review - Finalize Task:**
1. **Update status to `completed`** in frontmatter
2. **Use `git mv`** to move task from `current/` to `completed/`
3. **Stage all changes** with `git add`
4. **🚨 VERIFY no lingering task files**: Run `git status` and check for:
   - Task files in wrong locations (duplicate IN-XXX files)
   - Unstaged deletions (old task file not removed from git)
   - If found, clean up before committing (delete duplicates, stage deletions)
5. **ASK user for permission to commit** all work + task completion together
6. Use conventional commits format

**🚨 CRITICAL COMMIT DISCIPLINE:**
- **NEVER commit without explicit user approval** - Always ask first
- **NEVER commit during task execution** - Only commit at the very end after user approval
- **NO intermediate commits** - All work should be in a single commit (or user will tell you to split)
- **Reason**: User reviews all work before it's committed; intermediate commits break this workflow

### Critical Workflow Requirements

**⚠️ These requirements are NON-NEGOTIABLE and must be followed on every task:**

**1. NO Commits Without Approval**
- **Problem**: AI assistants commit work during task execution without asking
- **Impact**: Breaks review workflow, requires backing out commits, clutters git history
- **Requirement**: Only commit after user explicitly approves all work
- **What to do**: Ask "May I commit these changes?" and wait for approval

**2. Real-Time Execution Plan Updates**
- **Problem**: AI assistants forget to check off execution plan items as phases complete
- **Impact**: Task documentation incomplete, progress unclear, work appears unfinished
- **Requirement**: Check off `- [x]` execution plan items immediately after completing each phase
- **What to do**: After finishing any phase, update the task file to mark that phase complete

**3. Git Move Without Intermediate Commit**
- **Problem**: When moving tasks to `current/`, AI assistants commit immediately
- **Impact**: Extra commits that serve no purpose, breaks single-commit workflow
- **Requirement**: Use `git mv` to move task files but DO NOT commit
- **What to do**: Only commit once at the very end with all completed work

**Why These Matter:**
- Git history stays clean and reviewable
- All work is reviewed before being committed
- Task documentation accurately reflects progress
- User maintains control over what gets committed

### Task IDs and References

**Task ID System (IN-NNN):**
- All tasks have unique IDs in format `IN-NNN` (e.g., IN-001, IN-015)
- Task IDs are sequential and never reused
- Task filenames include the ID: `IN-NNN-task-name.md`
- Task frontmatter includes `task-id: IN-NNN` field

**Benefits:**
- **Easier communication:** Say "work on IN-001" instead of typing full task name
- **Shorter references:** Use IN-NNN in commit messages, documentation, discussions
- **Stable references:** ID stays the same even if task is renamed
- **Quick lookup:** Find task by ID using file glob or search

**How to Reference Tasks:**
- **In conversation:** "Let's work on IN-015" or "IN-002 is blocked by IN-001"
- **In wiki-links:** `[[tasks/current/IN-015-review-architecture-and-strategy-alignment|IN-015]]`
- **In commits:** "Addresses IN-001" or "Fixes IN-015"
- **In documentation:** Reference tasks by ID for brevity

**Priority System:**
- Tasks use numeric priorities (0-9) instead of text labels
- Lower number = higher priority
- Scale: 0 (critical/urgent) → 1-2 (high) → 3-4 (medium) → 5-6 (low) → 7-9 (very low)
- Enables fine-grained prioritization and better sorting

## Tool Usage

### TodoWrite Tool

AI assistants may have built-in todo/task tracking tools for session-based work. This is **separate** from MDTD:

**TodoWrite (Session Tasks):**
- Ephemeral, lives only in current chat session
- Quick task breakdown for immediate work
- Helps AI assistant track progress within a conversation
- NOT persisted to repository

**MDTD (Project Tasks):**
- Persistent markdown files in repository
- Version controlled, searchable
- Tracks project work over time
- Visible to all collaborators

**When to use each:**
- **TodoWrite**: Breaking down current work into steps during a session
- **MDTD**: Tracking significant project tasks that persist

### File Operations

**Preferred Tools:**
- **Read**: For reading files (not `cat`)
- **Edit**: For modifying files (not `sed`)
- **Write**: For creating files (not `echo >`)
- **Glob**: For finding files by pattern (not `find`)
- **Grep**: For searching content (not `grep` command)

**Use Bash For:**
- SSH operations
- Git commands
- Docker commands on VMs
- System commands

**Never Use Bash For:**
- Communicating with user (use direct text)
- Reading/editing files (use tools above)

### SSH Access

The AI assistant has SSH access to:
- **Proxmox**: `root@192.168.86.106`
- **VMs (full access)**: `evan@192.168.86.{172,173,174,249}` (passwordless sudo)
- **VMs (read-only)**: `inspector@192.168.86.{172,173,174,249}` (Testing Agent only)
- **Pangolin**: (to be configured)

**User Roles:**
- `evan`: Full access for deployment, configuration, and management
- `inspector`: Read-only access for Testing Agent validation (policy-enforced)

**SSH Best Practices:**
- Run commands via SSH, don't maintain sessions
- Use absolute paths when possible
- Combine related commands with `&&`
- Handle errors gracefully

### Bitwarden Access

The AI assistant can access secrets from Bitwarden, but requires a session token from the user.

**IMPORTANT:** Never attempt to run `bw` commands without a valid session token.

**Process:**

1. **When I need Bitwarden access**, I will say:
   > "I need to access Bitwarden. Please run: `./scripts/utils/get-bw-session.sh` and provide me with the session token."

2. **You run the script**:
   ```bash
   ./scripts/utils/get-bw-session.sh
   ```
   - Enter your master password when prompted
   - Copy the session token that's displayed

3. **You provide the token**:
   > Here's the BW_SESSION: `<paste the long token string>`

4. **I use the session in commands**:

   **IMPORTANT:** Each Bash tool invocation is a separate shell, so I must prefix EVERY `bw` command with the session token:

   ```bash
   BW_SESSION="<token>" bw list items --search "nas"
   BW_SESSION="<token>" bw get password "nas-admin"
   ```

   **DO NOT** try to use `export BW_SESSION` - it won't persist across tool invocations.

**Session Management:**
- Session tokens expire after ~30 minutes of inactivity
- Token is only valid for the current conversation
- Never commit session tokens to git
- User must provide a new token at the start of each work session

**Security Notes:**
- This approach keeps the master password secure (user controls unlocking)
- Session tokens have limited lifespan
- Tokens are not persisted anywhere
- User can revoke access by logging out: `bw lock`

## Common Workflows

### Pre-Task Review (Before Starting Work)

**IMPORTANT:** Before beginning any non-trivial task, conduct a critical pre-task review to identify potential issues and improve the plan.

**Process:**

1. **Read the Task Completely**
   - Review all sections: description, context, acceptance criteria, dependencies
   - Understand the goal and scope
   - Note any ambiguities or gaps

2. **Critical Analysis - Look For:**
   - **Missing inventory/scope:** Do we know exactly what needs to be done?
   - **Phased approach:** Should this be broken into phases to reduce risk?
   - **Rollback procedures:** Can we recover if something goes wrong?
   - **Testing criteria:** Are tests specific enough to validate success?
   - **Dependencies:** Are all prerequisites truly ready?
   - **Impact on critical services:** Could this affect Emby, downloads, or arr services?
   - **Timing considerations:** Should this be done during low-usage windows?
   - **Secret/security concerns:** Are we exposing or mishandling sensitive data?
   - **Cross-service impacts:** Could this affect other services?
   - **Documentation gaps:** Is the plan clear enough to execute?

3. **Common Weak Points to Check:**
   - No inventory of what will be changed
   - "Audit all" without knowing the scope
   - Single big-bang approach instead of phased
   - No rollback plan
   - Vague testing ("verify it works")
   - Missing backup steps
   - Unclear deployment method
   - No consideration of shared resources/secrets

4. **Propose Improvements**
   - Document specific gaps found
   - Suggest concrete additions (checklists, phases, tests)
   - Propose risk mitigation strategies
   - Clarify ambiguous sections

5. **Update the Task**
   - Add improvements to the task file
   - Get user approval on revised plan
   - Ensure task is now robust before starting work
   - **Be prepared for scope evolution:** Task may become different than originally described based on findings

6. **When to Skip:**
   - Trivial tasks (documentation typo fixes, etc.)
   - Tasks with very clear, limited scope
   - Emergency fixes where speed is critical

**Example Issues Found in Real Tasks:**
- IN-002: Missing secret inventory, no phased approach, vague testing
  - **Outcome:** Pre-task review revealed infrastructure already in desired state
  - **Scope evolved:** "Migration" task became "backup" task - still valuable work
  - **Lesson:** Actual work may differ from description - that's OK!
- IN-015: (Well-structured - good example to follow)

**Benefits:**
- Catches problems before they occur
- Reduces risk of breaking critical services
- Makes execution clearer and more confident
- Documents lessons learned for future tasks
- **Allows scope to evolve appropriately** based on actual findings

### Extracting Scripts During Work

**IMPORTANT:** While working on tasks, actively watch for script opportunities.

**Look for:**
- Commands you run multiple times in a session
- Complex command sequences that could be simplified
- Validation/check patterns that would be useful in future
- Operations that manual execution is error-prone
- Commands that would benefit from error handling/logging

**Process:**
1. **Notice the pattern** - "I've run this 3 times now..."
2. **Propose extraction** - "This would make a good script"
3. **Discuss with user** - Get approval on scope and naming
4. **Create script** - Add to appropriate scripts/ subdirectory
5. **Document** - Update scripts/README.md
6. **Use it immediately** - Validate the script works in current task

**Examples from real work:**
- IN-002: Created `audit-secrets.sh` after manually grepping for secrets
- IN-002: Enhanced `create-secret.sh` to support custom fields
- Future: Extract VM health check from repeated `docker ps` commands

**Don't over-script:**
- Truly one-off commands (task-specific, won't repeat)
- Commands that are simpler than the script would be
- Operations that change frequently (moving target)

**Benefits:**
- Builds script library organically based on real needs
- Scripts are battle-tested (created from actual use)
- Captures institutional knowledge as it's discovered
- Reduces toil over time

### Deploying a New Service

1. **Create Task**
   ```bash
   # In tasks/backlog/
   deploy-service-name.md
   ```

2. **Security Setup** ([[agents/SECURITY|Security Agent]])
   - Create `.env` file on VM
   - Set up Pangolin tunnel if needed
   - Store credentials in Vaultwarden
   - Document required secrets in `.env.example`

3. **Create Stack** ([[agents/DOCKER|Docker Agent]])
   ```bash
   stacks/service-name/
   ├── docker-compose.yml
   ├── .env.example
   └── README.md
   ```

4. **Deploy**
   ```bash
   ssh evan@VM_IP
   cd ~/projects/infinity-node/stacks/service-name
   docker compose up -d
   ```

5. **Validate** ([[agents/TESTING|Testing Agent]])
   - Check container status
   - Test service endpoints
   - Verify logs
   - Test connectivity to dependent services

6. **Document** ([[agents/DOCUMENTATION|Documentation Agent]])
   - Create service doc in `docs/services/`
   - Update relevant runbooks
   - Add to architecture docs
   - Complete MDTD task

### Updating an Existing Service

1. **Review Current State**
   - Read docker-compose.yml
   - Check running configuration
   - Review recent logs
   - Identify dependencies

2. **Plan Changes**
   - Create or update MDTD task
   - Document what will change and why
   - Identify risks
   - Plan rollback if needed

3. **Backup**
   ```bash
   # Backup docker-compose
   cp docker-compose.yml docker-compose.yml.backup

   # For critical services, snapshot VM first
   ```

4. **Implement Changes**
   - Update docker-compose.yml
   - Update .env if needed
   - Validate syntax
   - Test in non-production if possible

5. **Deploy**
   ```bash
   docker compose down
   docker compose up -d
   ```

6. **Validate & Monitor**
   - Check container started
   - Review logs
   - Test functionality
   - Monitor for issues

7. **Document**
   - Update service documentation
   - Update MDTD task with results
   - Record any lessons learned

### Troubleshooting Issues

1. **Gather Information** ([[agents/TESTING|Testing Agent]])
   ```bash
   # Container status
   docker ps -a

   # Logs
   docker logs container-name --tail 100

   # Resource usage
   docker stats --no-stream

   # Network
   docker network inspect network-name
   ```

2. **Identify Root Cause**
   - Review logs for errors
   - Check resource constraints
   - Verify network connectivity
   - Check dependencies

3. **Create Task**
   - Document issue clearly
   - Include error messages
   - Note impact/urgency
   - Set priority appropriately

4. **Implement Fix**
   - Make minimal changes
   - Test thoroughly
   - Validate with Testing Agent

5. **Prevent Recurrence**
   - Update monitoring
   - Improve documentation
   - Add preventive measures
   - Create runbook if needed

### Making Infrastructure Changes

1. **Plan Carefully** ([[agents/INFRASTRUCTURE|Infrastructure Agent]])
   - Assess impact on running services
   - Check resource availability
   - Plan downtime if needed
   - Coordinate with other agents

2. **Critical Service Considerations**
   - Check for active streams (Emby)
   - Check for active downloads
   - Schedule during low-usage window
   - Notify users if needed

3. **Backup First**
   - Snapshot VMs before changes
   - Backup configurations
   - Document current state

4. **Implement Changes**
   - Follow Proxmox best practices
   - Make changes incrementally
   - Validate after each step

5. **Validate** ([[agents/TESTING|Testing Agent]])
   - Verify VMs are running
   - Check service accessibility
   - Verify resource allocation
   - Test dependent services

## Best Practices

### Communication

**Do:**
- Be clear and concise
- Explain reasoning for recommendations
- Ask questions when unclear
- Admit when uncertain
- Suggest alternatives
- Challenge assumptions (respectfully)

**Don't:**
- Use emojis (unless explicitly requested)
- Be overly formal or deferential
- Make assumptions about requirements
- Proceed without confirmation on destructive operations
- Treat user as "boss" - we're co-workers

### Documentation

**Do:**
- Update docs when making changes
- Use wiki-links in Obsidian files
- Add frontmatter to all docs
- Write for future readers
- Include examples
- Document "why" not just "what"
- Follow `.docs/` pattern for context-specific documentation

**Don't:**
- Let docs become stale
- Document secrets (use examples/templates)
- Create unnecessary documentation
- Over-document trivial things

**Documentation Pattern: `.docs/` vs `docs/`:**
- **`docs/`** (project-wide): Architecture, decisions, agents, runbooks that span multiple areas
- **`.docs/`** (context-specific): Documentation that lives alongside the code/config it describes
  - Example: `config/vm-template/.docs/vm-research-findings.md` - research specific to VM configs
  - Example: `ansible/.docs/playbook-design.md` - Ansible-specific implementation notes
  - Example: `services/.docs/architecture.md` - service-specific architecture
- **Benefits**: Documentation stays close to what it documents, scales across entire project
- **Rule**: If docs are only relevant to files in one directory, use `.docs/` in that directory

### Code & Configuration

**Do:**
- Follow established patterns
- Use environment variables
- Add healthchecks
- Set resource limits
- Comment non-obvious choices
- Keep it simple

**Don't:**
- Hardcode values
- Copy-paste without understanding
- Over-engineer solutions
- Skip error handling
- Commit secrets to git

### Testing

**Do:**
- Validate before production deployment
- Test happy path and error cases
- Check dependent services
- Monitor after changes
- Document test results

**Don't:**
- Skip testing for "small" changes
- Test only on critical services
- Assume everything works
- Deploy without validation

### Git & Version Control

**IMPORTANT:**
- **NEVER commit without explicit user approval** - ask first
- **NEVER push to remote repository without explicit user approval** - ask first
- **Do NOT commit during task execution** - only at the end after user approval

**Do:**
- Commit logical units of work
- Write clear commit messages following Conventional Commits format
- Reference MDTD tasks in commits (e.g., "Addresses IN-027", "Fixes IN-015")
- Keep commits focused
- Review changes before committing
- Wait for user approval before committing or pushing

**Don't:**
- Commit secrets
- Make massive commits
- Use vague commit messages
- Commit broken code
- Commit or push without asking user first

## Security Guidelines

### Secrets Management

**NEVER commit secrets to git:**
- Passwords
- API keys
- Private keys
- Tokens
- Connection strings with credentials

**Proper secret storage:**
- `.env` files on VMs (gitignored)
- Vaultwarden for long-term storage
- `.env.example` files for templates
- Documentation uses placeholders

### SSH & Access

**Principles:**
- Key-based authentication only
- Separate users for different purposes
- Least privilege (read-only when possible)
- Audit access logs
- Rotate credentials regularly

**Testing Agent Special Rules:**
- Should use dedicated `inspector` user (to be created)
- Read-only access only
- Cannot modify any system state
- Cannot execute privileged commands

### Tunnel & VPN

**Pangolin tunnels:**
- Use for external service access
- Identity-aware access control
- Document exposed services
- Monitor tunnel health

**VPN (Downloads VM):**
- All download traffic through VPN
- Kill switch must be configured
- Regular leak testing
- Monitor connectivity

## Troubleshooting AI Assistant Issues

### If the AI assistant seems confused:
- Clarify which agent should handle the task
- Reference relevant documentation explicitly
- Break large tasks into smaller ones
- Create MDTD tasks for complex work

### If the AI assistant is too cautious:
- Explicitly approve the action
- Acknowledge the risk level
- Confirm it's acceptable

### If the AI assistant makes mistakes:
- Point out the issue directly
- Explain what should have happened
- The assistant will learn and adjust

### If uncertain about approach:
- The assistant should ask questions
- Discuss options and trade-offs
- Make informed decision together

## Reference Quick Links

- [[CURSOR|Cursor IDE Guide]] - How to use Cursor features effectively
- [[CODEBASE|Codebase Overview]] - Quick reference for AI queries
- [[agents/README|Agent System]]
- [[tasks/README|MDTD System]]
- [[DASHBOARD|Task Dashboard]]
- [[ARCHITECTURE|Infrastructure Architecture]]
- [[DECISIONS|Architectural Decisions]]

## Project Goals Reminder

1. **Document Everything**: About the setup
2. **Maintain Services**: Keep infrastructure reliable
3. **Automate**: Deployment, updates, recovery
4. **Learn**: Improve process over time

## Success Criteria

- Critical services maintain 99.9% uptime
- All infrastructure documented
- Changes tracked via MDTD
- Secrets never in git
- Automation simplifies management
- Knowledge captured for future

---

**Remember:** We're building this together. Question assumptions, suggest improvements, and work as partners to create great infrastructure!
