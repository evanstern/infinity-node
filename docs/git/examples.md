---
type: documentation
tags:
  - git
  - commits
  - examples
---

# Commit Examples

Real-world commit examples from this project.

## Feature Addition

```
feat(emby): add hardware transcoding support

Configured Emby to use GPU for hardware transcoding. Added device
passthrough in docker-compose.yml and configured transcoding temp
directory on tmpfs.

Addresses optimize-emby-transcoding
```

**Key elements:**
- Type: `feat` (new capability)
- Scope: `emby` (specific service)
- Subject: Clear what was added
- Body: Technical details, what changed
- Footer: Task reference

---

## Bug Fix

```
fix(downloads): resolve VPN connection drops

Modified VPN configuration to use UDP instead of TCP and increased
keepalive timeout. Prevents connection drops during extended downloads.

Addresses IN-018
```

**Key elements:**
- Type: `fix` (correcting behavior)
- Scope: `downloads` (affected service)
- Subject: What was fixed
- Body: How and why
- Footer: Task reference

---

## Configuration Change

```
config(arr): update radarr quality profiles

Modified quality profiles to prefer x265 encodes for space efficiency
while maintaining quality standards.

Addresses arr-quality-optimization
```

**Key elements:**
- Type: `config` (configuration adjustment)
- Scope: `arr` (service category)
- Subject: What was configured
- Body: Rationale
- Footer: Task reference

---

## Documentation Update

```
docs(architecture): add vaultwarden secret storage details

Documented Vaultwarden organizational structure, API access patterns,
and secret management workflows.

Addresses setup-vaultwarden-secret-storage
```

**Key elements:**
- Type: `docs` (documentation only)
- Scope: `architecture` (doc type)
- Subject: What was documented
- Body: Specifics of what was added
- Footer: Task reference

---

## Task Completion

```
chore(tasks): complete inspector user setup task

Moved create-inspector-user task to completed directory. Inspector
user now deployed to all VMs with read-only access for Testing Agent.

Fixes create-inspector-user
```

**Key elements:**
- Type: `chore` (task management)
- Scope: `tasks` (MDTD tasks)
- Subject: Task completed
- Body: Summary of what was accomplished
- Footer: `Fixes` (task complete)

---

## Infrastructure Change

```
infra(vm-100): increase CPU allocation for transcoding

Increased VM 100 CPU cores from 4 to 6 to handle multiple concurrent
transcoding streams. Backed up VM before change.

Addresses emby-performance-optimization
```

**Key elements:**
- Type: `infra` (infrastructure layer)
- Scope: `vm-100` (specific VM)
- Subject: What changed
- Body: Why and backup note
- Footer: Task reference

---

## Security Update

```
security: migrate secrets to vaultwarden

Moved all service secrets from local .env files to centralized
Vaultwarden instance. Updated deployment scripts to pull from
Vaultwarden during stack creation.

Fixes setup-secret-management
```

**Key elements:**
- Type: `security` (security-related)
- No scope: Project-wide change
- Subject: Security improvement
- Body: What changed and how
- Footer: Task completion

---

## Refactoring

```
refactor(scripts): consolidate backup logic

Extracted common backup functions into shared library. Reduced
duplication across backup scripts and standardized error handling.

Addresses script-cleanup
```

**Key elements:**
- Type: `refactor` (structure, not behavior)
- Scope: `scripts` (component type)
- Subject: What was refactored
- Body: How and benefits
- Footer: Task reference

---

## Simple Change (No Body)

```
docs: fix typo in README
```

**When to use simple format:**
- Obvious, trivial changes
- Self-explanatory from subject
- No context needed

---

## Related

- [[conventional-commits]] - Format specification
- [[commit-types]] - Type definitions
- [[scopes]] - Scope conventions
