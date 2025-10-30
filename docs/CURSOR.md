---
type: documentation
tags:
  - cursor
  - ide
  - workflow
  - user-guide
---

# Working with Cursor

This guide explains how to use Cursor 2.0 effectively with the infinity-node project.

## Overview

Cursor is an AI-powered code editor built on VS Code that integrates Claude and other AI models directly into your development workflow. This project is configured with `.cursorrules` and `.cursorignore` to provide optimal AI context.

## Core Features

### 1. Chat (Cmd+L)

**When to use:** Questions, planning, exploration, discussions

**Best for:**
- Understanding code or infrastructure
- Asking "how does X work?"
- Planning approaches before implementation
- Reviewing and discussing changes
- Getting explanations

**Context management:**
- Use `@Files` to add specific files
- Use `@Folders` to add directory context
- Use `@Code` to reference specific functions/classes
- Use `@Docs` to search documentation
- Use `@Web` to search the internet
- Use `@Codebase` for project-wide context (uses docs/CODEBASE.md)

**Example workflow:**
```
User: @Codebase what's the architecture of the media stack?
AI: [References ARCHITECTURE.md and relevant stack files]

User: @Files stacks/emby/docker-compose.yml
     How can I enable hardware transcoding?
AI: [Provides guidance based on file context]
```

### 2. Composer (Cmd+I)

**When to use:** Making changes, implementing features, refactoring

**Best for:**
- Creating new files
- Implementing features across multiple files
- Refactoring code
- Making coordinated changes
- Writing new documentation

**How it works:**
- Opens a full-screen AI interface
- Can read and edit multiple files simultaneously
- Provides diff view of proposed changes
- You review and accept/reject changes

**Context management:**
- Automatically includes open files
- Use `@Files` to add more context
- Use `@Folders` for directory-wide changes
- Composer has broader context window than Chat

**Example workflow:**
```
User: [Opens Composer with Cmd+I]
      Create a new stack for Plex media server following
      the pattern in @Folders stacks/emby/

AI: [Proposes new stack with docker-compose.yml,
     README.md, .env.example following project patterns]

User: [Reviews diffs, accepts changes]
```

### 3. Inline Edit (Cmd+K)

**When to use:** Quick edits in the current file

**Best for:**
- Small, focused changes to current file
- Refactoring a specific function
- Adding comments or documentation
- Quick fixes

**How it works:**
- Triggered within the editor
- Select code or place cursor
- AI suggests changes inline
- Accept or reject immediately

**Example:**
1. Select a function
2. Press Cmd+K
3. Type: "Add error handling and logging"
4. AI modifies the function inline

### 4. Terminal (Cmd+K in Terminal)

**When to use:** Executing commands, shell interactions

**Best for:**
- Writing complex commands
- Explaining command output
- Troubleshooting terminal errors
- Building command pipelines

## Context Management with @ Syntax

### @Codebase - Project Overview
Queries the entire codebase to find relevant context. Cursor uses `docs/CODEBASE.md` as a quick reference.

**Use when:**
- "Where is X implemented?"
- "How does Y work?"
- General project questions

**Example:**
```
@Codebase where do we store secrets?
→ References docs/SECRET-MANAGEMENT.md and shows Vaultwarden setup
```

### @Files - Specific Files
Add specific files to the conversation context.

**Use when:**
- Discussing specific configurations
- Making changes to known files
- Comparing multiple files

**Example:**
```
@Files stacks/emby/docker-compose.yml stacks/radarr/docker-compose.yml
Compare these two stack configurations
```

### @Folders - Directory Context
Add entire folders to context (Cursor will sample intelligently).

**Use when:**
- Working within a specific area
- Understanding directory structure
- Making coordinated changes across files

**Example:**
```
@Folders stacks/arr/
Help me understand the arr services configuration
```

### @Code - Specific Symbols
Reference specific functions, classes, or code symbols.

**Use when:**
- Discussing implementation details
- Refactoring specific functions
- Understanding particular code

**Example:**
```
@Code deploy_stack
How does this function handle errors?
```

### @Docs - Documentation Search
Search and reference documentation.

**Use when:**
- Looking up project conventions
- Understanding architectural decisions
- Finding runbooks or guides

**Example:**
```
@Docs agent system
Explain the agent system workflow
```

### @Web - Internet Search
Search the internet for information (uses Exa AI).

**Use when:**
- Looking up external service documentation
- Researching best practices
- Finding solutions to errors

**Example:**
```
@Web docker compose healthcheck best practices
```

## Slash Commands

Cursor supports custom slash commands that streamline common workflows. The infinity-node project uses several specialized commands for task management and workflow automation.

**Available Commands:**
- **`/task IN-NNN`** - Start or resume work on an MDTD task
- **`/create-task [description]`** - Create a new MDTD task with guided workflow
- **`/commit`** - Generate conventional commit message for staged changes
- **`/edit`** - Switch to edit mode
- **`/help`** - Show all available commands

### /task - Work on MDTD Tasks
```
/task IN-024
```
Loads and begins work on the specified task, following MDTD workflow.

**What it does:**
- Reads the task file and understands requirements
- Updates task status to `in-progress`
- Uses `git mv` to move task from `backlog/` to `current/`
- 🚨 **Does NOT commit** - all commits happen at end only
- Works through execution plan phases
- 🚨 **Checks off execution plan items IN REAL-TIME** as each phase completes (REQUIRED)
- Checks off acceptance criteria in real-time
- Pauses after each phase for reflection and documentation
- Presents completed work for review before marking complete
- 🚨 **Waits for user approval before committing anything**

**When to use:**
- Starting work on any existing MDTD task
- Resuming work on a task in progress

**Critical Workflow Rules:**
1. **NO commits during execution** - Only commit at end after user approval
2. **Real-time execution plan updates** - Check off `- [x]` items as phases complete
3. **Git moves without commits** - Task moves don't need intermediate commits

### /create-task - Create New MDTD Tasks

```
/create-task [brief description]
/create-task [description] --simple
```

Interactive command that guides you through creating a new MDTD task with proper structure, critical thinking, and metadata.

**Philosophy:**
- **Good task creation = better execution** - Invest time upfront to understand problems, consider alternatives, identify risks, and plan execution
- **Pragmatic approach** - Simple tasks get simple treatment; complex tasks get thorough analysis
- **Flexible depth** - Can override with `--simple` flag or by saying "keep it simple" or "explore thoroughly"

**Quick Options:**
- **Normal flow** - Appropriate depth based on task complexity (recommended)
- **`--simple` flag** - Skip exploration, create basic task quickly (for trivial work)

**Examples:**
```
/create-task Add Cursor configuration
/create-task Fix broken service --simple
/create-task Setup monitoring for critical services
```

**8-Phase Workflow:**

**Phase 1: Understanding & Classification**
- Gather initial information (title, problem, category, priority)
- AI assesses complexity (simple/moderate/complex)
- Present assessment and recommended approach
- User can override depth if needed

**Phase 2: Solution Design** (Moderate/Complex only)
- Explore 2-3 possible approaches
- Recommend one with rationale
- User chooses or suggests alternatives
- Document chosen approach
- Simple tasks skip to Phase 3

**Phase 3: Risk Assessment & Dependencies**
- Identify potential pitfalls
- Define mitigations for each risk
- Check prerequisites and dependencies
- Special attention if critical services affected
- Include rollback plan for infrastructure/docker/security

**Phase 4: Scope Definition**
- Define what's in scope (specific, actionable items)
- Explicitly list what's out of scope (prevent scope creep)
- Identify MVP (minimum viable completion)

**Phase 5: Execution Planning**
- Break work into phases if needed
- Assign agents to each task
- Mark dependencies and blocking items
- Generate specific, testable acceptance criteria

**Phase 6: Task Generation**
- Determine next task ID (from `.task-id-counter` or by scanning)
- Generate filename in format: `IN-NNN-task-title-kebab-case.md`
- Fill complete task template with all gathered information

**Phase 7: Review & Approval**
- Present complete task design
- User can approve, request revisions, or cancel
- Iterate on revisions if needed
- Create file in `tasks/backlog/` when approved

**Phase 8: Post-Creation**
- Confirm creation with task ID
- Update `.task-id-counter`
- Suggest next steps (add to DASHBOARD, related tasks)
- Optionally start work immediately with `/task IN-NNN`

**Complexity Levels:**

- **Simple** (< 2h): Well-understood, routine work with single approach, low risk
  - Example: Fix typo, add link, restart service
  - Process: Skip alternatives exploration, use standard template

- **Moderate** (2-6h): Some design decisions, 2-3 viable approaches, moderate risk/impact
  - Example: Add feature, update config, create documentation
  - Process: Brief alternatives review, standard risk assessment

- **Complex** (6+ hours): Significant unknowns, multiple approaches with trade-offs, high risk/impact
  - Example: Infrastructure migration, major refactor, critical service changes
  - Process: Full exploration, detailed planning, phased approach

**Smart Defaults by Category:**

The command uses intelligent defaults based on task category:

- **Infrastructure**: Agent=infrastructure, always include rollback plan
- **Docker**: Agent=docker, focus on container/volume/network risks
- **Security**: Agent=security, audit trail and secret validation required
- **Media**: Agent=media, backup/rollback/timing required (critical services)
- **Documentation**: Agent=documentation, test links and accuracy
- **Testing**: Agent=testing, reproducible tests and coverage

**Task ID Management:**

Tasks use sequential IDs in format `IN-NNN` (e.g., IN-001, IN-024):
- IDs managed via `tasks/.task-id-counter` (gitignored local state)
- Counter auto-increments after each task creation
- If counter missing, system scans tasks and rebuilds it
- Self-healing: delete counter file to force rescan

**Critical Service Considerations:**

If task affects Emby, downloads, or arr services, the command automatically:
- Flags it as critical service
- Requires backup plan
- Requires rollback procedure
- Requires timing consideration (low-usage window)
- Adds extra validation steps

**Overriding Depth:**

You can adjust the exploration depth at any point:
- Say **"keep it simple"** - Use less depth than AI recommends
- Say **"explore thoroughly"** - Use more depth for careful planning
- Use **`--simple` flag** - Skip straight to basic task creation

**When to Use:**
- Creating any new work item that's non-trivial
- Planning significant changes or new features
- Before starting complex or risky work
- To capture and structure ideas for future work

**When NOT to Use:**
- Truly trivial fixes (typos, etc.) - just do them
- Emergency fixes where speed is critical
- Work that's already well-documented in a task

### /commit - Create Conventional Commits

```
/commit
```

Analyzes staged changes and creates a conventional commit message following the project's commit format.

**When to use:**
- After completing a logical unit of work
- Required for all commits (never commit without using this)

### Other Common Commands

- `/edit` - Switch to edit mode
- `/help` - Show available commands

## Best Practices for Work Sessions

### Starting a Session

1. **Load relevant context:**
   ```
   @Codebase what was I last working on?
   @Files tasks/current/IN-XXX-task-name.md
   ```

2. **Review task if continuing work:**
   ```
   /task IN-XXX
   ```

3. **Check system state if relevant:**
   ```
   Show me recent commits
   What files have changed?
   ```

### During Work

1. **Be specific with context:**
   - Add files/folders explicitly rather than assuming
   - Reference specific sections: "in the MDTD section of docs/AI-COLLABORATION.md"

2. **Pause and reflect:**
   - After each phase, review changes
   - Update task progress in real-time
   - Document decisions in work log

3. **Use the right tool:**
   - Chat: Questions and planning
   - Composer: Implementation
   - Inline: Quick fixes

### Ending a Session

1. **Document progress:**
   - Update task acceptance criteria
   - Add notes to work log
   - Commit logical units of work

2. **Prepare for next session:**
   - Note where you left off in task
   - Document any blockers or questions
   - Stage changes if not ready to commit

## Workflow with MDTD Tasks

### Task Execution Pattern

1. **Start task:**
   ```
   /task IN-XXX
   ```

2. **AI updates status and moves task:**
   - Updates frontmatter to `status: in-progress`
   - Uses `git mv` to move from `tasks/backlog/` to `tasks/current/`
   - 🚨 **Does NOT commit** - commits only at end

3. **Work through phases:**
   - 🚨 AI checks off execution plan items IN REAL-TIME as each phase completes
   - AI checks off acceptance criteria as completed
   - After each phase: pause, reflect, document
   - Update work log with decisions/discoveries
   - 🚨 **No commits during execution**

4. **Complete task:**
   - AI presents work for review (doesn't mark complete yet)
   - 🚨 **AI does NOT commit** - waits for approval
   - You review and approve
   - AI marks complete, moves to `tasks/completed/`
   - AI **asks permission** to commit all work together

### Example Task Session

```
User: /task IN-026

AI: [Reads task, updates status to in-progress, git mv to current/]
    🚨 Not committing yet - will commit at end only

    Starting work on IN-026: Create deployment automation scripts

    Phase 1: Create backup script
    [Implements script]

    ✓ Checked off execution plan: Phase 1 complete
    ✓ Checked off acceptance criteria: backup-stack.sh created

    Pausing after Phase 1:
    - Created backup-stack.sh with error handling
    - Decided to use timestamp-based backup names
    - Discovered need for disk space check (adding to script)

    Continue to Phase 2?

User: Yes, continue

AI: Phase 2: Create deploy script
    [Implements script]

    ✓ Checked off execution plan: Phase 2 complete
    ✓ Checked off acceptance criteria: deploy-stack.sh created

    Work complete! Ready for review:
    - Created backup-stack.sh and deploy-stack.sh
    - Added error handling and logging
    - Documented usage in scripts/README.md
    - All acceptance criteria met
    - All execution plan phases checked off

    🚨 NOT committing yet - waiting for your approval

User: Yes, looks good!

AI: [Updates status to completed, git mv to completed/]
    May I commit these changes?

    Proposed commit:
    feat(scripts): add deployment automation scripts (Addresses IN-026)

User: Yes, commit it

AI: [Commits all work together]
    ✓ Changes committed
```

## Configuration Files

### .cursorrules
Located at project root, provides AI context:
- Project overview and infrastructure
- Agent system and MDTD workflow
- Critical services and safety requirements
- Security guidelines and git workflow
- Communication style preferences

**You don't need to reference this manually** - Cursor automatically uses it.

### .cursorignore
Located at project root, excludes files from indexing:
- Obsidian workspace files
- Backup files and logs
- Secrets (.env files)
- Git directory

**Improves performance** by not indexing irrelevant files.

### docs/CODEBASE.md
Quick reference for AI assistants about project structure. Used by `@Codebase` queries.

## Tips & Tricks

### Efficient Context Loading

**Too broad (slow):**
```
@Folders /
Tell me about the project
```

**Better:**
```
@Codebase what's the project structure?
```

### Composer vs Chat Decision

**Use Chat when:**
- Asking questions
- Planning approach
- Reviewing changes
- Discussing options

**Use Composer when:**
- Ready to implement
- Changes span multiple files
- Creating new files
- Refactoring code

### Keyboard Shortcuts

- `Cmd+L` - Open Chat
- `Cmd+I` - Open Composer
- `Cmd+K` - Inline Edit (in editor)
- `Cmd+K` - Command assistance (in terminal)
- `Cmd+Shift+P` - Command Palette
- `Cmd+P` - Quick file open

## Troubleshooting

### AI Doesn't Have Context

**Problem:** AI answers without relevant project context

**Solution:**
- Use `@Codebase` for project-wide queries
- Add specific files with `@Files`
- Reference documentation with `@Docs`
- Check that `.cursorrules` is at project root

### AI Is Too Cautious

**Problem:** AI asks too many questions or won't proceed

**Solution:**
- Explicitly approve: "Yes, proceed with this approach"
- Reference `.cursorrules`: "Per project guidelines, this is acceptable"
- Be more specific in your request

### Changes Not Applying

**Problem:** Composer or inline edit doesn't work

**Solution:**
- Check file isn't read-only
- Ensure file is saved
- Try closing and reopening file
- Restart Cursor if needed

## Related Documentation

- [[AI-COLLABORATION|Working with AI Assistants]] - AI collaboration workflows
- [[agents/README|Agent System]] - Specialized agent personas
- [[CODEBASE|Project Structure]] - Quick reference for AI queries
- [[ARCHITECTURE|Infrastructure Architecture]] - System overview
- [[tasks/README|MDTD System]] - Task management

---

**Remember:** Cursor is most effective when you:
1. Provide clear context with @ syntax
2. Use the right tool for the job (Chat vs Composer vs Inline)
3. Work iteratively with review/approval cycles
4. Document progress as you go
