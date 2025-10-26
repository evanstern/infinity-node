---
type: documentation
tags:
  - claude-code
  - guide
  - workflow
---

# Working with Claude Code

This guide explains how to effectively work with Claude Code in the infinity-node project. It's designed for both the human collaborator (Evan) and Claude Code itself.

## Core Principles

### 1. Collaborative Partnership
- We work **together** as co-workers, not boss/assistant
- Claude can and should advocate for better solutions
- Evan has final say, but discussion is encouraged
- Respectful, lighthearted, casual communication

### 2. Agent-Based Workflow
- Claude adopts specialized agent personas based on task domain
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

Claude Code automatically adopts the appropriate agent persona based on task context:

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
   - Obsidian: CMD+P → "Templates: Insert template" → "task"
   - Manual: Copy `.obsidian/templates/task.md`

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

### Task Updates

- **Start work**: Move to `current/`, set status to `in-progress`
- **Check off criteria**: As each is completed
- **Add notes**: Document issues, solutions, learnings
- **Complete**: Set status to `completed`, move to `completed/`

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

Claude Code has a built-in TodoWrite tool for session-based task tracking. This is **separate** from MDTD:

**TodoWrite (Session Tasks):**
- Ephemeral, lives only in current chat session
- Quick task breakdown for immediate work
- Helps Claude track progress within a conversation
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

Claude Code has SSH access to:
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

## Common Workflows

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

**Don't:**
- Let docs become stale
- Document secrets (use examples/templates)
- Create unnecessary documentation
- Over-document trivial things

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
- **ALWAYS use `/commit` command** for creating commits (follows conventional commit format)
- **NEVER commit without explicit user approval** - ask first
- **NEVER push to remote repository without explicit user approval** - ask first

**Do:**
- Use `/commit` slash command for all commits
- Commit logical units of work
- Write clear commit messages following Conventional Commits format
- Reference MDTD tasks in commits (use "Fixes task-name" or "Addresses task-name")
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

## Troubleshooting Claude Code Issues

### If Claude Code seems confused:
- Clarify which agent should handle the task
- Reference relevant documentation explicitly
- Break large tasks into smaller ones
- Create MDTD tasks for complex work

### If Claude Code is too cautious:
- Explicitly approve the action
- Acknowledge the risk level
- Confirm it's acceptable

### If Claude Code makes mistakes:
- Point out the issue directly
- Explain what should have happened
- Claude will learn and adjust

### If uncertain about approach:
- Claude should ask questions
- Discuss options and trade-offs
- Make informed decision together

## Reference Quick Links

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
