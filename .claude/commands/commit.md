# Smart Commit - Intelligent Git Commit Assistant

Analyzes current code changes, runs quality checks, and creates a well-structured commit message, then commits the code.

## Process

### Analysis Phase
1. **Capture Diff**: Run `git --no-pager diff HEAD` to see all changes
2. **Analyze Changes**: Understand what files were modified and what was changed
3. **Categorize**: Determine the type of change (feat, fix, refactor, docs, chore, etc.)
4. **Generate Message**: Create a conventional commit message with proper format

### Quality Check Phase
1. **Docker Compose Syntax**: If docker-compose.yml files changed, validate syntax with `docker compose config`
2. **YAML Frontmatter**: If markdown files with frontmatter changed, verify YAML is valid
3. **No Secrets**: Verify no secrets are being committed (check .env files, API keys, passwords)
4. **Abort on Failures**: Do not proceed to commit until all checks pass

### Commit Phase
1. **Manual Approval Required**: All commits require manual approval
2. **Stage Changes**: Add all changes or specific files
3. **Prepare Commit Message**: Generate a conventional commit message and present it for approval
4. **Require Approval**: Ask for explicit user approval before creating the commit
5. **Create Commit**: Upon approval, create the commit using the approved message
6. **Confirm Success**: Show the commit hash and message

## Commit Message Format

Follows Conventional Commits specification:
```
<type>(<scope>): <subject>

<body>

<footer>
```

**IMPORTANT RULES:**
- NEVER include "Co-Authored-By: Claude" or "Generated with Claude Code"
- NEVER add promotional text or AI references
- Keep messages professional and clean
- Follow the project's existing commit style
- Always require user approval before committing

### Types
- **feat**: New feature or service
- **fix**: Bug fix
- **refactor**: Code change that neither fixes a bug nor adds a feature
- **docs**: Documentation only changes
- **chore**: Maintenance tasks (task management, config updates, etc.)
- **config**: Configuration changes (docker-compose, environment, etc.)
- **infra**: Infrastructure changes (VMs, networks, storage)
- **security**: Security-related changes (secrets, permissions, SSH)

### Scopes (optional)
Examples for this project:
- **vm-100**, **vm-101**, **vm-102**, **vm-103**: Changes specific to a VM
- **emby**, **arr**, **downloads**, **misc**: Service-related changes
- **tasks**: MDTD task updates
- **docs**: Documentation updates
- **scripts**: Shell script changes

## Examples

```
feat(emby): add hardware transcoding support

Configured Emby to use GPU for hardware transcoding. Added device passthrough
in docker-compose.yml and configured transcoding temp directory on tmpfs.
```

```
chore(tasks): complete inspector user setup task

Moved create-inspector-user task to completed directory. Inspector user now
deployed to all VMs with read-only access for Testing Agent.
```

```
config(arr): update radarr quality profiles

Modified quality profiles to prefer x265 encodes for space efficiency while
maintaining quality standards.
```

```
docs(architecture): add vaultwarden secret storage details

Documented Vaultwarden organizational structure, API access patterns, and
secret management workflows.
```
