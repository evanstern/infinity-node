---
type: documentation
tags:
  - git
  - commits
  - types
---

# Commit Types

Type definitions and usage guide.

## Type Reference

### feat: New Feature
**When**: Adding new functionality

```
feat(emby): add hardware transcoding
feat: deploy immich photo service
```

---

### fix: Bug Fix
**When**: Correcting incorrect behavior

```
fix(downloads): resolve VPN drops
fix(prowlarr): correct auth issue
```

---

### refactor: Code Restructuring
**When**: Changing structure, not behavior

```
refactor(stacks): reorganize compose files
refactor(scripts): consolidate backup logic
```

---

### docs: Documentation
**When**: Adding/updating documentation

```
docs(architecture): add GPU details
docs: update deployment runbook
```

---

### chore: Maintenance
**When**: Routine housekeeping

```
chore(tasks): complete user setup task
chore: update watchtower config
```

---

### config: Configuration
**When**: Service/app configuration changes

```
config(arr): update quality profiles
config(emby): increase transcoding threads
```

---

### infra: Infrastructure
**When**: VM/network/storage changes

```
infra(vm-100): increase CPU allocation
infra: configure GPU passthrough
```

---

### security: Security Changes
**When**: Security-related modifications

```
security: migrate secrets to vaultwarden
security(downloads): update VPN config
```

---

## Quick Selection Guide

1. New capability? → `feat`
2. Fix broken behavior? → `fix`
3. Restructure without behavior change? → `refactor`
4. Only docs? → `docs`
5. Task management/housekeeping? → `chore`
6. Service config? → `config`
7. Infrastructure layer? → `infra`
8. Security/secrets? → `security`

## Common Confusions

**feat vs config**
- `feat`: New capability that didn't exist
- `config`: Adjusting existing capability

**fix vs config**
- `fix`: Correcting wrong behavior
- `config`: Changing working config to different setting

**chore vs docs**
- `chore`: Task management, maintenance
- `docs`: Documentation updates

**infra vs config**
- `infra`: Infrastructure (VMs, networks, storage)
- `config`: Application/service layer

## Related

- [[conventional-commits]] - Format specification
- [[scopes]] - Scope conventions
- [[examples]] - Usage examples
