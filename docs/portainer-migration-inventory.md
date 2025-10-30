---
type: documentation
tags:
  - portainer
  - migration
  - inventory
---

# Portainer Stack Migration Inventory

**Task:** IN-013 - Migrate Portainer to Monorepo
**Created:** 2025-10-28
**Status:** In Progress

## Overview

This document tracks the inventory of all Portainer stacks across all VMs, their current configuration, and migration status.

## Stacks in Repository (infinity-node/stacks/)

As of 2025-10-28, we have **19 stacks** in the repository:

1. audiobookshelf
2. downloads
3. emby
4. flaresolverr
5. homepage
6. huntarr
7. immich
8. jellyseerr
9. lidarr
10. linkwarden
11. navidrome
12. newt
13. paperless-ngx
14. portainer
15. prowlarr
16. radarr
17. sonarr
18. vaultwarden
19. watchtower

## VM Inventory

### VM 100 - Emby (192.168.86.172)

**Portainer:** https://192.168.86.172:9443
**API Token:** ✅ Stored in Vaultwarden (shared/portainer-api-token-vm-100)

**Stacks Deployed:** 2 stacks

| Stack | Status | Git Config | Auto-Update | Repo |
|-------|--------|------------|-------------|------|
| watchtower | Active | ✅ Git-based | ❌ Disabled | infinity-node-stack-watchtower |
| newt | Active | ✅ Git-based | ❌ Disabled | infinity-node-stack-newt |

**Migration Status:**
- ✅ All stacks already using Git
- ⚠️ Using separate repos per stack (not monorepo)
- ❌ Auto-update disabled (should enable with 5min polling)
- ❓ Missing expected: emby, portainer

---

### VM 101 - Downloads (192.168.86.173)

**Portainer:** https://192.168.86.173:32768 (non-standard port)
**API Token:** ✅ Stored in Vaultwarden (shared/portainer-api-token-vm-101)

**Stacks Deployed:** 2 stacks

| Stack | Status | Git Config | Auto-Update | Repo |
|-------|--------|------------|-------------|------|
| downloads | Active | ✅ Git-based | ✅ Enabled (12h) | infinity-node-stack-downloads |
| watchtower | Active | ✅ Git-based | ❌ Disabled | infinity-node-stack-watchtower |

**Migration Status:**
- ✅ All stacks already using Git
- ⚠️ Using separate repos per stack (not monorepo)
- ⚠️ Downloads has auto-update enabled (12h) - should change to 5min
- ❓ Missing expected: portainer

---

### VM 102 - Arr Services (192.168.86.174)

**Portainer:** https://192.168.86.174:9443
**API Token:** ✅ Stored in Vaultwarden (shared/portainer-api-token-vm-102)

**Stacks Deployed:** 2 stacks

| Stack | Status | Git Config | Auto-Update | Needs Migration |
|-------|--------|------------|-------------|-----------------|
| utils | Active | ❌ **Not configured** | N/A | ✅ **YES** |
| arr | Active | ❌ **Not configured** | N/A | ✅ **YES** |

**Migration Status:**
- ❌ **NO stacks using Git** - all need migration
- ⚠️ Only 2 stacks found, expected more (radarr, sonarr, lidarr, prowlarr, jellyseerr, etc.)
- 💡 Likely: "arr" is a combined stack with multiple services
- 💡 Likely: "utils" contains watchtower, portainer, flaresolverr, etc.
- 🎯 **Priority for migration** (contains CRITICAL arr services)

---

### VM 103 - Misc Services (192.168.86.249)

**Portainer:** https://192.168.86.249:9443
**API Token:** ✅ Stored in Vaultwarden (shared/portainer-api-token-vm-103)

**Stacks Deployed:** 8 stacks

| Stack | Status | Git Config | Auto-Update | Repo | Needs Migration |
|-------|--------|------------|-------------|------|-----------------|
| homepage | Active | ❌ **Not configured** | N/A | - | ✅ **YES** |
| paperless-ngx | Active | ❌ **Not configured** | N/A | - | ✅ **YES** |
| linkwarden | Active | ❌ **Not configured** | N/A | - | ✅ **YES** |
| vaultwarden | Active | ✅ Git-based | ❌ Disabled | infinity-node-stack-vaultwarden | ⚠️ Enable auto-update |
| watchtower | Active | ✅ Git-based | ❌ Disabled | infinity-node-stack-watchtower | ⚠️ Enable auto-update |
| newt | Active | ✅ Git-based | ❌ Disabled | infinity-node-stack-newt | ⚠️ Enable auto-update |
| audiobookshelf | Active | ✅ Git-based | ❌ Disabled | infinity-node-stack-audiobookshelf | ⚠️ Enable auto-update |
| navidrome | Active | ✅ Git-based | ❌ Disabled | infinity-node-stack-navidrome | ⚠️ Enable auto-update |

**Migration Status:**
- ⚠️ **Mixed state:** 5 stacks using Git, 3 need migration
- **Need Git migration:** homepage, paperless-ngx, linkwarden
- ⚠️ Using separate repos per stack (not monorepo)
- ❌ All auto-update disabled (should enable with 5min polling)
- ❓ Missing expected: immich, portainer

---

## Summary

**Total Stacks Across All VMs:** 14 stacks

**Migration Status:**
- ✅ **Already using Git:** 9 stacks (64%)
- ❌ **Need migration:** 5 stacks (36%)

**Critical Findings:**
1. **Separate repos being used** - Each stack has its own repo (infinity-node-stack-*)
2. **Monorepo exists but not deployed** - We have `stacks/` in infinity-node repo but Portainer isn't using it
3. **Auto-update mostly disabled** - Only 1 stack (downloads) has auto-update enabled
4. **VM 102 needs full migration** - All arr services need Git config (CRITICAL)

**Stacks Needing Migration:**
- **VM 102:** utils, arr (contains CRITICAL services)
- **VM 103:** homepage, paperless-ngx, linkwarden

## Key Decisions Needed

**MAJOR DECISION:** Separate repos vs Monorepo approach

**Option A: Keep separate repos** (infinity-node-stack-*)
- ✅ Already working for 9 stacks
- ✅ Less disruptive
- ❌ Doesn't match monorepo in infinity-node/stacks/
- ❌ More repos to manage

**Option B: Migrate to monorepo** (infinity-node with stacks/ subdirectory)
- ✅ Matches our existing stacks/ structure
- ✅ Single repo to manage
- ✅ Better for GitOps workflows
- ❌ Need to reconfigure 9 working stacks
- ❌ More disruptive migration

**Recommendation:** Need user decision before proceeding with Phase 1.

## Next Steps

**Phase 0: ✅ COMPLETE**
- [x] Created API tokens for all VMs
- [x] Stored tokens in Vaultwarden
- [x] Queried all stacks across all VMs
- [x] Documented current state

**Phase 1: Migration Strategy** (BLOCKED - awaiting decision)
1. **User Decision:** Separate repos vs monorepo approach?
2. Based on decision:
   - **If separate repos:** Create missing stack repos for 5 stacks, configure Portainer
   - **If monorepo:** Reconfigure all 14 stacks to use infinity-node repo
3. Document secret requirements for each stack
4. Plan rollout order by risk level

**Phase 2: Enable Auto-Update**
- Configure 5min polling interval on Git-based stacks
- Enable force redeployment
- Test GitOps workflow

## Notes

**Inventory Completed:** 2025-10-28

**Tools Created:**
- `scripts/infrastructure/query-portainer-stacks.sh` - Query stacks from Portainer API using Vaultwarden credentials
- `scripts/secrets/list-vaultwarden-structure.sh` - List Vaultwarden collection structure
- `scripts/utils/bw-setup-session.sh` - Setup Bitwarden CLI session for Claude Code

**API Tokens:**
- All 4 VMs have Portainer API tokens stored in Vaultwarden (shared collection)
- Tokens include metadata: service, vm, purpose, created date, URL

**Portainer Port Note:**
- VM 101 uses non-standard port 32768 (not 9443)

**Missing Stacks:**
- VM 100: emby, portainer (expected but not found in Portainer)
- VM 103: immich, portainer (expected but not found in Portainer)

These may be deployed outside Portainer or named differently.
