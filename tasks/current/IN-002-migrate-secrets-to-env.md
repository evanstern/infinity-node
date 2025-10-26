---
type: task
task-id: IN-002
status: pending
priority: 1
category: security
agent: security
created: 2025-10-24
updated: 2025-10-26
tags:
  - task
  - security
  - secrets
  - critical
---

# Task: IN-002 - Migrate Secrets from Docker Compose to .env Files

**✅ UNBLOCKED:** [[tasks/completed/IN-001-import-existing-docker-configs|IN-001]] completed - all Docker configurations imported into repository. Ready to proceed with secret migration.

## Description

Audit all docker-compose.yml files and migrate hardcoded secrets (passwords, API keys, tokens) to `.env` files. This is critical for security - secrets should NEVER be committed to git.

## Context

During infrastructure review, we found some secrets still hardcoded in docker-compose files (e.g., NEWT_SECRET in emby/docker-compose.yml). This violates our security policy and risks accidentally committing secrets to git.

Per [[docs/agents/SECURITY|Security Agent]] guidelines, all secrets must be:
- Stored in `.env` files (gitignored)
- Backed up securely to Vaultwarden
- Documented with `.env.example` templates

## Acceptance Criteria

- [ ] Audit all docker-compose.yml files in `stacks/` for hardcoded secrets
- [ ] Create `.env` file for each stack that needs secrets
- [ ] Update docker-compose.yml to use `${VAR_NAME}` syntax
- [ ] Create `.env.example` template for each stack
- [ ] Store all secrets in Vaultwarden with proper labels
- [ ] Document required variables in each stack's README.md
- [ ] Verify all services still work after migration
- [ ] Remove commented-out secrets from docker-compose files
- [ ] Update `.gitignore` to ensure .env files are excluded (already done)

## Dependencies

- Access to all VMs via SSH
- Vaultwarden credentials
- List of all current services and their configurations

## Testing Plan

[[docs/agents/TESTING|Testing Agent]] should validate:
- All services start successfully with .env-based configs
- No secrets visible in docker-compose files
- .env.example files are complete and accurate
- Services function correctly after migration
- No .env files accidentally committed to git

## Related Documentation

- [[docs/agents/SECURITY|Security Agent]]
- [[docs/ARCHITECTURE|Architecture]] - Service locations
- [[docs/DECISIONS|ADR-008]]: Git for configuration management

## Notes

**Current known issues:**
- emby/docker-compose.yml has commented-out NEWT_SECRET
- Other services may have similar issues

**Stacks to check:**
- All services on all 4 VMs (100, 101, 102, 103)

**Post-migration:**
- Create secure backup of all .env files
- Document backup location in Vaultwarden
- Test restore procedure
