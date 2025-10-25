---
type: task
status: pending
priority: medium
category: security
agent: security
created: 2025-10-24
updated: 2025-10-24
tags:
  - task
  - security
  - secrets
  - audit
---

# Task: Audit Current Secret Storage

## Description

Perform comprehensive audit of all secret storage across the infrastructure to identify where secrets are stored, how they're protected, and create a complete inventory.

## Context

Before implementing a complete secret management solution, we need to understand the current state:
- What secrets exist?
- Where are they stored?
- How are they protected?
- Which ones are at risk?
- What needs migration?

This audit informs the secret migration and backup strategy tasks.

## Acceptance Criteria

- [ ] Inventory all secrets across all VMs
- [ ] Document current storage locations
- [ ] Identify secrets in docker-compose files
- [ ] Identify secrets in .env files
- [ ] Check for secrets in git history
- [ ] Assess protection level for each secret
- [ ] Prioritize secrets by criticality
- [ ] Create secret inventory document
- [ ] Identify secrets needing rotation
- [ ] Create remediation plan

## Dependencies

- SSH access to all VMs
- Access to Vaultwarden
- Git history access
- Understanding of all services

## Testing Plan

[[docs/agents/TESTING|Testing Agent]] should validate:
- Audit is thorough and complete
- No secrets exposed in public locations
- Inventory document is accurate
- Remediation plan addresses all risks

## Related Documentation

- [[docs/agents/SECURITY|Security Agent]]
- [[docs/ARCHITECTURE|Architecture]]
- Related task: [[migrate-secrets-to-env]]

## Notes

**Audit checklist:**

**Docker Compose Files:**
- Check all stacks/*/docker-compose.yml
- Look for hardcoded passwords, keys, tokens
- Check commented-out sections (may contain secrets)

**Environment Files:**
- Find all .env files
- Verify they're gitignored
- Check file permissions (should be 600)
- Identify owner/group

**Git Repository:**
- Search git history for potential secrets
- Check if any secrets were committed accidentally
- Identify if rotation needed

**Vaultwarden:**
- Inventory what's already in Vaultwarden
- Check for duplicate entries
- Verify organization/labeling

**VM Filesystem:**
- Check for config files with embedded secrets
- Look in service config directories
- Check backup files

**Pangolin:**
- NEWT_ID and NEWT_SECRET locations
- Pangolin server credentials

**VPN:**
- NordVPN credentials
- Private keys

**NAS:**
- NFS mount credentials (if any)
- Synology admin credentials

**Services:**
- Portainer passwords
- Emby admin password
- *arr service API keys
- Database passwords
- Webhook tokens

**Priority levels:**
- Critical: VPN keys, root passwords, Vaultwarden master
- High: Service admin passwords, API keys
- Medium: Webhook tokens, read-only API keys
- Low: Notification tokens

**Audit output:**
- Create secret-inventory.md (do NOT commit to git!)
- Store in Vaultwarden as secure note
- Use for migration planning
