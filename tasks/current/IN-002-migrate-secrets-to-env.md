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

- [ ] **Create secret inventory:** Grep all docker-compose.yml files to catalog:
  - Hardcoded secrets (passwords, API keys, tokens)
  - Secrets already in .env format
  - Services that should have secrets but don't
  - Cross-service secret dependencies
- [ ] **Verify Vaultwarden readiness:**
  - Vaultwarden is accessible at http://192.168.86.249:8111
  - Vaultwarden has recent backup
  - Bitwarden CLI (`bw`) can authenticate and retrieve secrets
- [ ] **Backup current configurations:**
  - Create .backup copies of all docker-compose.yml files
  - Document current working state
- [ ] **Review secret quality:**
  - Identify weak/default secrets that should be rotated
  - Generate new strong secrets where needed
  - Document shared secrets between services

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

### Pre-Migration (Phase 0)
- [ ] Complete all Pre-Migration Checklist items
- [ ] Secret inventory created and reviewed
- [ ] Vaultwarden verified accessible and backed up
- [ ] All docker-compose.yml files backed up (.backup copies)

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
*To be populated during pre-migration phase*

### Known Issues
- emby/docker-compose.yml has commented-out NEWT_SECRET
- Other services may have similar hardcoded secrets

### Services by VM
- **VM 100:** emby
- **VM 101:** downloads (VPN + Deluge + NZBGet)
- **VM 102:** radarr, sonarr, lidarr, prowlarr, jellyseerr, flaresolverr, huntarr
- **VM 103:** vaultwarden, paperless-ngx, linkwarden, audiobookshelf, navidrome, immich, portainer, watchtower, homepage, newt

### Shared Secrets
*Document any secrets shared across services - to be identified during inventory*

### Secrets Requiring Rotation
*List any weak/default secrets to be replaced during migration*

### Critical Considerations
- Execute critical service migrations (Emby, downloads) during low-usage windows (3-6 AM)
- Notify household before migrating Emby if concerned about brief downtime
- VPN connectivity critical for downloads - thorough testing required
- arr services communicate with each other - coordinate API key updates
- Keep rollback procedure ready at all times
