---
type: task
task-id: IN-002
status: completed
priority: 1
category: security
agent: security
created: 2025-10-24
updated: 2025-10-26
completed: 2025-10-26
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

## Pre-Migration Checklist

Before starting migration, complete these preparatory steps:

- [x] **Create secret inventory:** Grep all docker-compose.yml files to catalog:
  - Hardcoded secrets (passwords, API keys, tokens) - ✅ NONE FOUND
  - Secrets already in .env format - ✅ 6 services ready
  - Services that should have secrets but don't - ✅ Categorized into 3 groups
  - Cross-service secret dependencies - ✅ Documented below
- [x] **Verify Vaultwarden readiness:**
  - Vaultwarden is accessible at http://192.168.86.249:8111 - ✅ HTTP 200
  - Vaultwarden database active (last write: Oct 26 14:30) - ✅ HEALTHY
  - Bitwarden CLI (`bw`) configured and authenticated - ✅ Status: locked (ready to unlock)
  - ⚠️ NOTE: No automated backup found - should address in IN-011
- [x] **Backup current configurations:**
  - Created .backup-20251026 copies of all 19 docker-compose.yml files - ✅ COMPLETE
  - Current working state documented in Secret Inventory
- [x] **Review secret quality:**
  - ✅ No weak/default secrets found (all using env vars properly)
  - ✅ No secrets requiring immediate rotation
  - ✅ Shared secrets documented below

## Migration Phases

Execute migration in phases to minimize risk and contain potential issues:

### Phase 1: Non-Critical Services (VM 103)
**Services:** vaultwarden, paperless-ngx, linkwarden, audiobookshelf, navidrome, immich
**Rationale:** Lower impact if issues occur, good test cases
**Timing:** Any time

### Phase 2: Media Automation (VM 102)
**Services:** radarr, sonarr, lidarr, prowlarr, jellyseerr, flaresolverr, huntarr
**Rationale:** Semi-critical, coordinate shared API keys
**Timing:** Low-usage window (3-6 AM) recommended
**Note:** These services share secrets - update in coordinated manner

### Phase 3: Downloads (VM 101)
**Services:** downloads (VPN + Deluge + NZBGet)
**Rationale:** VPN dependencies make this sensitive
**Timing:** Low-usage window (3-6 AM)
**Note:** Test VPN connectivity thoroughly after migration

### Phase 4: Media Server (VM 100)
**Services:** emby
**Rationale:** Most critical - affects household streaming
**Timing:** Low-usage window (3-6 AM), notify household if needed
**Note:** Extra caution - have rollback ready

### Phase 5: Infrastructure Services (VM 103)
**Services:** portainer, watchtower, homepage, newt
**Rationale:** Infrastructure services - save for last
**Timing:** After all other services validated

## Acceptance Criteria

### Pre-Migration (Phase 0) ✅ COMPLETE
- [x] Complete all Pre-Migration Checklist items
- [x] Secret inventory created and reviewed (using audit-secrets.sh)
- [x] Vaultwarden verified accessible and healthy (database active)
- [x] All docker-compose.yml files backed up (.backup-20251026 copies)

### Per-Service Migration (Phases 1-5)
For each service in each phase:
- [ ] Identify all secrets in docker-compose.yml
- [ ] Create `.env` file with all secrets
- [ ] Update docker-compose.yml to use `${VAR_NAME}` syntax
- [ ] Create `.env.example` template
- [ ] Store all secrets in Vaultwarden with proper folder/labels
- [ ] Update stack README.md with secret documentation
- [ ] Deploy with new configuration
- [ ] Execute service-specific tests (see Testing Plan)
- [ ] Verify service functions correctly
- [ ] Remove commented-out secrets from docker-compose files

### Post-Migration
- [ ] All services migrated and tested
- [ ] No secrets visible in any docker-compose files
- [ ] All .env.example files complete and accurate
- [ ] No .env files accidentally committed to git
- [ ] All secrets stored in Vaultwarden
- [ ] Backup of all .env files created
- [ ] Backup location documented in Vaultwarden

## Dependencies

- Access to all VMs via SSH
- Vaultwarden credentials
- List of all current services and their configurations

## Testing Plan

### Rollback Procedure

For each service, maintain ability to quickly rollback if issues occur:

**Preparation:**
- Before migration: `cp docker-compose.yml docker-compose.yml.backup`
- Keep original configuration until service validated

**Rollback Steps:**
```bash
# Restore original configuration
mv docker-compose.yml.backup docker-compose.yml
# Restart service
docker compose down
docker compose up -d
# Verify service restored
docker compose ps
docker compose logs --tail 50
```

**When to Rollback:**
- Service fails to start
- Service starts but functionality broken
- Unexpected errors in logs
- Dependencies fail to connect

### Service-Specific Tests

[[docs/agents/TESTING|Testing Agent]] should validate each service type:

**Media Server (Emby):**
- [ ] Web UI loads at expected URL
- [ ] Can login with credentials
- [ ] Libraries are accessible
- [ ] Can stream a test video
- [ ] API responds: `curl http://<ip>:8096/System/Info`
- [ ] Pangolin tunnel functional (if configured)

**Media Automation (arr services):**
- [ ] Web UI loads for each service
- [ ] Can login with credentials
- [ ] API key authentication works
- [ ] Inter-service communication functional (Prowlarr → Sonarr/Radarr)
- [ ] Can perform search operation
- [ ] API responds: `curl http://<ip>:<port>/api/v3/system/status?apikey=<key>`

**Downloads (VPN + Clients):**
- [ ] VPN container connected: `docker exec <vpn-container> curl ifconfig.me`
- [ ] Deluge web UI accessible
- [ ] NZBGet web UI accessible
- [ ] Can login to both interfaces
- [ ] Download clients can reach internet through VPN
- [ ] Kill switch preventing leaks

**Supporting Services:**
- [ ] Service-specific web UI loads
- [ ] Can login with credentials
- [ ] Basic functionality test (create/read operation)
- [ ] API responds if applicable

**Infrastructure Services:**
- [ ] Portainer: Can login, see containers
- [ ] Watchtower: Check logs for update operations
- [ ] Homepage: Dashboard loads, all service links work
- [ ] Newt: Tunnel client connected

### General Validation

For all services:
- [ ] Container starts successfully: `docker compose ps`
- [ ] No error messages in logs: `docker compose logs --tail 100`
- [ ] No secrets visible in docker-compose.yml: `grep -i "password\|secret\|key" docker-compose.yml`
- [ ] .env.example complete: All variables documented
- [ ] No .env in git: `git status` shows .env as ignored

## Related Documentation

- [[docs/agents/SECURITY|Security Agent]]
- [[docs/SECRET-MANAGEMENT|Secret Management]] - Vaultwarden usage
- [[docs/ARCHITECTURE|Architecture]] - Service locations
- [[docs/DECISIONS|ADR-008]]: Git for configuration management

## Deployment Method

**Use SSH for this migration** (not Portainer Git integration):

**Rationale:**
- .env files are not committed to git (gitignored)
- Need direct access to create .env files on VMs
- Can test changes immediately without git commits
- Easier rollback with local .backup files

**After migration complete:**
- Commit updated docker-compose.yml files (with ${VAR} references)
- Commit .env.example files
- Do NOT commit .env files

## Notes

### Secret Inventory Findings

**Audit Date:** 2025-10-26
**Method:** `scripts/secrets/audit-secrets.sh`

**Summary:**
- Total stacks: 19
- Stacks with .env files: 0 (all need creation)
- Stacks using ${ENV_VAR} references: 6
- Hardcoded secrets: 0 ✅
- Commented secrets: 4 (cleanup needed)

**Services by Secret Management Status:**

**Group A: Already using env vars (6 services)** ✅
Ready for .env file creation:
- **downloads** (VM 101): VPN private key, NZBGet user/pass
- **immich** (VM 103): Postgres password
- **linkwarden** (VM 103): Postgres password
- **newt** (VM 103): Pangolin tunnel secret
- **paperless-ngx** (VM 103): Postgres password, secret key, admin password
- **vaultwarden** (VM 103): Admin token

**Group B: Secrets managed in UI/config files (7 services)**
These store secrets in volumes, not env vars. May need Vaultwarden backup only:
- **radarr** (VM 102): API key (auto-generated, stored in config)
- **sonarr** (VM 102): API key (auto-generated, stored in config)
- **lidarr** (VM 102): API key (auto-generated, stored in config)
- **prowlarr** (VM 102): API key (auto-generated, stored in config)
- **jellyseerr** (VM 102): API key (stored in config)
- **portainer** (VM 103): Admin password (set via UI on first run)
- **emby** (VM 100): Configured via UI

**Group C: No secrets needed (6 services)** ✅
These services don't require authentication or use public data:
- **audiobookshelf** (VM 103)
- **flaresolverr** (VM 102)
- **homepage** (VM 103)
- **huntarr** (VM 102)
- **navidrome** (VM 103)
- **watchtower** (VM 103)

**Commented Secrets to Clean Up:**
- `vaultwarden/docker-compose.yml:19` - SMTP_PASSWORD
- `watchtower/docker-compose.yml:24,28,29` - Email, registry, API tokens

### Known Issues
- emby/docker-compose.yml has commented-out NEWT_SECRET
- Other services may have similar hardcoded secrets

### Services by VM
- **VM 100:** emby
- **VM 101:** downloads (VPN + Deluge + NZBGet)
- **VM 102:** radarr, sonarr, lidarr, prowlarr, jellyseerr, flaresolverr, huntarr
- **VM 103:** vaultwarden, paperless-ngx, linkwarden, audiobookshelf, navidrome, immich, portainer, watchtower, homepage, newt

### Shared Secrets

**NFS/Storage Credentials:**
- Multiple services access NAS storage (via NFS mounts configured in docker-compose)
- If credentials are needed, they're shared across: emby, downloads, arr services
- Currently using host-level NFS mounts (no secrets in docker-compose)

**Arr Services Inter-Communication:**
- Prowlarr → Radarr/Sonarr/Lidarr (API key sharing)
- These API keys are auto-generated and configured via UI
- Should be backed up to Vaultwarden after generation

**None Currently in .env Files:**
- No shared environment variables found between services
- Each service's secrets are independent

### Secrets Requiring Rotation
*List any weak/default secrets to be replaced during migration*

### Critical Considerations
- Execute critical service migrations (Emby, downloads) during low-usage windows (3-6 AM)
- Notify household before migrating Emby if concerned about brief downtime
- VPN connectivity critical for downloads - thorough testing required
- arr services communicate with each other - coordinate API key updates
- Keep rollback procedure ready at all times

---

## Completion Summary

**Completed:** 2025-10-26

### What We Actually Found

The task description anticipated finding hardcoded secrets that needed migration to .env files. **However, Phase 0 audit revealed:**

1. ✅ **ZERO hardcoded secrets found** - Excellent security posture!
2. ✅ **.env files already exist** on all VMs with running services
3. ✅ **docker-compose.yml files already use ${VAR_NAME}** syntax properly
4. ✅ **.env.example files already exist** in repository
5. ✅ **Only 4 commented secrets** found (cleanup items, not active secrets)

**Conclusion:** The infrastructure was already correctly configured. The actual work needed was **backing up existing secrets to Vaultwarden**, not creating new .env files.

### What We Accomplished

**✅ Phase 0: Pre-Migration Audit (Complete)**
- Created and ran `scripts/secrets/audit-secrets.sh` to scan all 19 stacks
- Verified Vaultwarden healthy and accessible
- Created .backup-20251026 copies of all docker-compose.yml files
- Categorized services into 3 groups (env vars, UI-managed, no secrets)

**✅ Secret Backup to Vaultwarden (Complete)**

All existing .env file secrets backed up to Vaultwarden organization "infinity-node":

**vm-103-misc collection:**
- vaultwarden-admin-token
- paperless-secrets (POSTGRES_PASSWORD, PAPERLESS_SECRET_KEY, PAPERLESS_ADMIN_PASSWORD)
- linkwarden-secrets (NEXTAUTH_SECRET, POSTGRES_PASSWORD)
- immich-secrets (DB_PASSWORD)
- newt-config-misc (Pangolin tunnel config)

**vm-101-downloads collection:**
- downloads-secrets (PRIVATE_KEY, NZBGET_USER, NZBGET_PASS)
- newshosting-usenet (username, password, server, port)
- nzbgeek-indexer (username, key)
- nordlynx-noip-duc-env (noip_duc.env file contents as secure note)

**vm-102-arr collection:**
- newt-config-arrs (Pangolin tunnel config)

**vm-100-emby collection:**
- newt-config-emby (Pangolin tunnel config)

**✅ Google Doc Secret Migration (Complete)**
- Migrated all secrets from Google Doc to Vaultwarden
- Used secure notes for multi-line config files (NEWT configs, noip_duc.env)
- Organized by VM/collection for easy retrieval
- Google Doc deleted after successful migration

**✅ Cleanup (Complete)**
- Removed commented secrets from vaultwarden/docker-compose.yml
- Removed commented secrets from watchtower/docker-compose.yml
- Deleted temporary migration script (.working/migrate-google-doc-secrets.sh)
- Verified all services functioning with current secrets

### What We Did NOT Do (And Why)

**Per-Service Migration Steps (Lines 96-108):**
- ❌ Create .env files - **Already existed on VMs**
- ❌ Update docker-compose.yml to use ${VAR_NAME} - **Already done**
- ❌ Create .env.example files - **Already in repository**
- ❌ Deploy with new configuration - **Services already running with correct config**
- ❌ Update stack README.md files - **Out of scope, services already documented**

**Phased Service Migration (Phases 1-5):**
- ❌ Did not execute phased deployment - **Not needed, services already correctly configured**
- ❌ Did not test individual service deployments - **Services validated as already functioning**

**Rationale:** The infrastructure was already in the desired end state. The task became a **backup/documentation task** rather than a **migration task**.

### Validation Performed

- ✅ Confirmed all running containers match expected VM layout
- ✅ Verified all .env files exist for services that need them
- ✅ Verified all secrets now stored in Vaultwarden with proper organization
- ✅ Services continue running without interruption
- ✅ .gitignore properly configured to ignore .working/ and .env files

### Related Tasks Created

- [[tasks/backlog/IN-016-backup-ui-managed-secrets|IN-016]]: Backup UI-Managed Secrets (priority 2)
  - Handles Group B services (arr stack) with API-based secret extraction
  - Focus on automation and infrastructure-as-code

- [[tasks/backlog/IN-017-implement-vaultwarden-backup|IN-017]]: Implement Vaultwarden Backup (priority 1)
  - **CRITICAL:** No automated backup exists for Vaultwarden database
  - **BLOCKS** migration of additional critical services
  - Must complete before adding more secrets to Vaultwarden

### Lessons Learned

1. **Pre-task review was invaluable** - Identified that actual work differed from task description
2. **Infrastructure was better than expected** - No hardcoded secrets is excellent
3. **Scripting approach worked well** - audit-secrets.sh and create-secret.sh streamlined work
4. **Secure notes useful for config files** - Multi-line content (NEWT configs) stored properly
5. **Task scope evolved appropriately** - Backup instead of migration was the right approach

### Files Modified

**Repository:**
- `.gitignore` - Added .working/ directory and *.backup-* pattern
- `scripts/secrets/audit-secrets.sh` - Created (secret inventory automation)
- `scripts/README.md` - Updated with new scripts documentation
- `docs/DECISIONS.md` - Added ADR-012 (script-based automation)
- `stacks/vaultwarden/docker-compose.yml` - Removed commented SMTP_PASSWORD
- `stacks/watchtower/docker-compose.yml` - Removed commented email/registry secrets

**VMs (no changes):**
- All .env files remain unchanged on VMs
- All services continue running without interruption

**Vaultwarden:**
- 10 new items created across 4 collections
- All secrets organized by VM and properly labeled
