---
type: task
task-id: IN-002
status: in-progress
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
