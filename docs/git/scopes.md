---
type: documentation
tags:
  - git
  - commits
  - scopes
---

# Commit Scopes

Project-specific scope conventions.

## What is a Scope?

Optional context about which part of project changed.

Format: `type(scope): subject`

## VM Scopes

- `vm-100` - Emby media server
- `vm-101` - Downloads (qBittorrent, VPN)
- `vm-102` - *arr services
- `vm-103` - Misc services

```
infra(vm-100): increase CPU allocation
config(vm-101): update VPN killswitch
```

## Service Scopes

**Categories:**
- `emby` - Media server
- `arr` - All *arr services
- `downloads` - Download clients
- `misc` - Miscellaneous services

**Individual services:**
- `sonarr`, `radarr`, `lidarr` - Media automation
- `prowlarr` - Indexer management
- `jellyseerr` - Media requests
- `vaultwarden` - Secrets
- `immich` - Photos
- `portainer` - Containers

```
feat(emby): add hardware transcoding
config(arr): update quality profiles
fix(prowlarr): resolve timeouts
```

## Component Scopes

- `tasks` - MDTD tasks
- `docs` - Documentation
- `scripts` - Automation
- `stacks` - Docker compose
- `ansible` - Playbooks

```
chore(tasks): complete setup task
docs(architecture): clarify topology
refactor(scripts): consolidate backup
```

## When to Use Scope

### ✅ Use when:
- Specific to one VM/service/component
- Multiple similar areas exist
- Adds meaningful context
- Filtering by area would help

### ❌ Skip when:
- Affects multiple areas equally
- Type and subject already clear
- Too generic to be useful
- Project-wide change

## Scope Examples

**With scope** (specific):
```
config(emby): increase thread count
fix(prowlarr): resolve auth
docs(architecture): add GPU details
```

**Without scope** (general):
```
config: update all restart policies
fix: resolve network connectivity
docs: update README structure
```

## Related

- [[conventional-commits]] - Format specification
- [[commit-types]] - Type definitions
- [[examples]] - Scope usage examples
