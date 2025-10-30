# Portainer Stack Migration Runbook

## Overview

This runbook documents the process for migrating Portainer stacks to the infinity-node monorepo with GitOps enabled.

**Last Updated:** 2025-10-29
**Task Reference:** IN-013

---

## Quick Reference

### Migration Commands

```bash
# Non-Git stack migration (homepage, paperless, linkwarden, utils, arr)
./scripts/infrastructure/migrate-nonGit-stack-to-monorepo.sh \
  "<portainer-secret>" "<collection>" <stack-id> <endpoint-id> \
  "<stack-name>" "stacks/<stack-name>/docker-compose.yml"

# Git stack migration (watchtower, newt, vaultwarden, etc.)
./scripts/infrastructure/migrate-stack-to-monorepo.sh \
  "<portainer-secret>" "<collection>" <stack-id> <endpoint-id> \
  "<stack-name>" main
```

### Health Verification

```bash
./scripts/infrastructure/verify-stack-health.sh \
  "<portainer-secret>" "<collection>" "<stack-name>" <endpoint-id> [timeout]
```

---

## Prerequisites

1. **BW_SESSION configured:**
   ```bash
   export BW_SESSION=$(cat ~/.bw-session)
   ```

2. **Portainer API tokens created** for all VMs (stored in Vaultwarden)

3. **Stack configuration** exists in monorepo under `stacks/<name>/`

---

## Critical Lessons Learned

### ⚠️ Database Stacks Require Volume Backups

**Problem:** Migration recreates containers with fresh volumes, losing all data.

**Solution:** Backup volumes BEFORE migration for stacks with databases:

```bash
# 1. Identify stack volumes
ssh user@vm "ls -la /data/compose/<stack-id>/"

# 2. Create backup (while stack is running)
ssh user@vm "cd /data/compose && tar -czf /backup/stack-<name>-$(date +%Y%m%d).tar.gz <stack-id>/"

# 3. Proceed with migration

# 4. Restore if needed (after migration)
ssh user@vm "cd /data/compose/<new-id>/ && tar -xzf /backup/stack-<name>.tar.gz --strip-components=1"
```

**Affected stacks:**
- paperless-ngx (PostgreSQL)
- linkwarden (PostgreSQL + MeiliSearch)
- vaultwarden (SQLite)
- arr stack (SQLite databases for Radarr/Sonarr/etc.)

### ⚠️ env_file Directives Don't Work with GitOps

**Problem:** Compose files using `env_file: .env` fail to deploy because .env doesn't exist in Git checkout.

**Solution:** Remove `env_file:` directives and add explicit environment variable mappings:

**Before:**
```yaml
services:
  postgres:
    image: postgres:16-alpine
    env_file: .env
```

**After:**
```yaml
services:
  postgres:
    image: postgres:16-alpine
    environment:
      - POSTGRES_PASSWORD=${POSTGRES_PASSWORD}
      - POSTGRES_USER=${POSTGRES_USER}
      - POSTGRES_DB=${POSTGRES_DB}
```

**How to fix:**
1. Check compose file for `env_file:` directives
2. Look at `.env.example` to identify all required variables
3. Add explicit `environment:` mappings with `${VAR}` syntax
4. Use `${VAR:-default}` for optional variables
5. Commit and push changes before migration

### ⚠️ GitOps Update Clears Environment Variables

**Problem:** Using Git update endpoint with empty `Env:[]` wipes all environment variables.

**Solution:** Always include full environment variable array when updating Git stacks:

```bash
# Get current env vars
CURRENT_ENV=$(curl -H "X-API-Key: $TOKEN" "$URL/api/stacks/$ID" | jq -c '.Env')

# Update with env vars preserved
curl -X POST -H "X-API-Key: $TOKEN" "$URL/api/stacks/$ID/git?endpointId=3" \
  -d "{\"Env\": $CURRENT_ENV, \"RepositoryReferenceName\": \"\", ...}"
```

### ⚠️ Container Health Checks Are Essential

**Problem:** Migration script reports success even when containers are crash-looping.

**Solution:** Always verify container health after migration using `verify-stack-health.sh`:

- Polls containers every 5 seconds
- Checks for "running" state
- Validates health check status if configured
- Fails fast if containers are restarting
- 180-second default timeout

---

## Migration Process (Step-by-Step)

### Phase 1: Pre-Migration

1. **Review compose file:**
   ```bash
   cat stacks/<stack-name>/docker-compose.yml
   ```
   - Check for `env_file:` directives → Fix if found
   - Identify volumes and data persistence needs
   - Note any database services

2. **Backup volumes (if database stack):**
   ```bash
   ssh user@vm "cd /data/compose && tar -czf /backup/stack-<name>-$(date +%Y%m%d).tar.gz <stack-id>/"
   ```

3. **Test compose file locally (optional):**
   ```bash
   cd stacks/<stack-name>
   docker-compose config  # Validates syntax
   ```

### Phase 2: Migration

4. **Run migration script:**
   ```bash
   export BW_SESSION=$(cat ~/.bw-session)

   # For non-Git stacks
   ./scripts/infrastructure/migrate-nonGit-stack-to-monorepo.sh \
     "portainer-api-token-vm-<id>" "shared" <stack-id> 3 \
     "<stack-name>" "stacks/<stack-name>/docker-compose.yml"
   ```

5. **Script will:**
   - Stop original stack
   - Create backup stack (stopped)
   - Extract environment variables from backup
   - Delete original stack
   - Create new Git-based stack with extracted env vars
   - Verify container health (180s timeout)
   - Prompt to delete backup

6. **Review output:**
   - ✅ All containers should be "healthy" or "running"
   - ✅ Git URL should be `https://github.com/evanstern/infinity-node`
   - ✅ GitOps interval should be `5m`

### Phase 3: Post-Migration

7. **Functional testing:**
   - Access service via web UI
   - Test critical functionality
   - Check logs for errors

8. **If issues found:**
   - Check container logs:
     ```bash
     ./scripts/infrastructure/query-portainer-stacks.sh --secret ... | jq
     ```
   - Restore from backup if needed:
     ```bash
     # Start backup stack
     curl -X POST -H "X-API-Key: $TOKEN" "$URL/api/stacks/<backup-id>/start?endpointId=3"
     ```

9. **Clean up backup stacks** (after 24-48 hours):
   ```bash
   ./scripts/infrastructure/delete-stack.sh "portainer-api-token-vm-<id>" "shared" <backup-id> 3
   ```

---

## Troubleshooting

### Container Keeps Restarting

**Symptoms:** Container shows `Restarting (1) X seconds ago`

**Common causes:**
1. **Missing environment variables** - Check logs for "required variable" errors
2. **Database password mismatch** - Ensure `POSTGRES_PASSWORD` matches across services
3. **Volume permission issues** - Check volume ownership (should be correct UID/GID)

**Debug:**
```bash
# Get container logs
ssh user@vm "docker logs <container-name> --tail 50"

# Check environment variables in container
ssh user@vm "docker inspect <container-name> | jq '.[0].Config.Env'"
```

### GitOps Not Updating

**Symptoms:** Changes pushed to GitHub not reflected in Portainer

**Causes:**
1. Wrong branch configured (should be empty string or "main")
2. AutoUpdate interval not set (should be "5m")
3. Compose file path incorrect

**Verify:**
```bash
curl -H "X-API-Key: $TOKEN" "$URL/api/stacks/$ID" | jq '{
  GitConfig,
  AutoUpdate
}'
```

**Fix:**
```bash
# Trigger manual update
curl -X POST -H "X-API-Key: $TOKEN" \
  "$URL/api/stacks/$ID/git?endpointId=3" \
  -d '{"Env":[], "RepositoryReferenceName":"", "Prune":false}'
```

### Database Lost After Migration

**Symptoms:** Fresh database, all user data gone

**Cause:** Volumes not persisted or wrong volume path

**Prevention:** Always backup volumes before migrating database stacks

**Recovery (if backup exists):**
```bash
# Stop new stack
./scripts/infrastructure/stop-stack.sh "portainer-api-token-vm-<id>" "shared" <new-stack-id> 3

# Restore volumes
ssh user@vm "cd /data/compose/<new-stack-id> && \
  tar -xzf /backup/stack-<name>.tar.gz --strip-components=1"

# Start stack
curl -X POST -H "X-API-Key: $TOKEN" "$URL/api/stacks/<new-stack-id>/start?endpointId=3"
```

---

## VM-Specific Notes

### VM 100 (Emby)
- **Stacks:** watchtower, newt
- **Risk:** Low (no databases)
- **Special notes:** None

### VM 101 (Downloads)
- **Stacks:** watchtower, downloads
- **Risk:** Low (downloads are transient)
- **Special notes:** None

### VM 102 (Arr)
- **Stacks:** utils, arr (CRITICAL)
- **Risk:** HIGH - arr stack has multiple SQLite databases
- **Special notes:**
  - MUST backup volumes before migration
  - Contains: Radarr, Sonarr, Prowlarr, Bazarr, Recyclarr
  - Downtime affects media downloads

### VM 103 (Misc)
- **Stacks:** homepage, paperless-ngx, linkwarden, vaultwarden, watchtower, newt, audiobookshelf, navidrome
- **Risk:** Medium (multiple databases)
- **Special notes:**
  - vaultwarden is CRITICAL (password vault)
  - Must backup vaultwarden volumes before migration

---

## Stack Priority Order

Based on risk and dependencies:

**Low Risk (Start Here):**
1. ✅ homepage (VM 103) - No database
2. ✅ paperless-ngx (VM 103) - PostgreSQL but low usage
3. ✅ linkwarden (VM 103) - PostgreSQL but low data
4. watchtower (all VMs) - No persistence
5. newt (VMs 100, 103) - No persistence

**Medium Risk:**
6. audiobookshelf (VM 103) - SQLite database
7. navidrome (VM 103) - SQLite database
8. utils (VM 102) - Combined utilities
9. downloads (VM 101) - Minimal persistence

**High Risk (Backup Required):**
10. arr (VM 102) - CRITICAL - Multiple SQLite databases
11. vaultwarden (VM 103) - CRITICAL - Password vault SQLite

---

## Script Reference

### Available Scripts

Located in: `scripts/infrastructure/`

1. **migrate-nonGit-stack-to-monorepo.sh** - Full migration workflow for non-Git stacks
2. **migrate-stack-to-monorepo.sh** - Update Git URL for existing Git-based stacks
3. **stop-stack.sh** - Stop a running stack
4. **backup-stack.sh** - Duplicate a stack (creates `<name>_backup`)
5. **delete-stack.sh** - Permanently delete a stack
6. **create-git-stack.sh** - Create new Git-based stack from monorepo
7. **verify-stack-health.sh** - Poll containers until healthy
8. **query-portainer-stacks.sh** - List stacks with details
9. **enable-gitops-updates.sh** - Enable GitOps on existing Git stack

### Script Dependencies

All scripts require:
- `get-vw-secret.sh` - Retrieve secrets from Vaultwarden
- `BW_SESSION` environment variable
- `curl`, `jq` installed

---

## Future Improvements

### Potential Script Enhancements

1. **Pre-flight validation:**
   - Scan compose file for `env_file:` directives
   - Warn if found and suggest fixes

2. **Automatic volume backup:**
   - Add `--backup-volumes` flag to migration script
   - SSH to VM and create tar.gz before migration

3. **Rollback mechanism:**
   - Keep backup stack ID in temp file
   - Add `--rollback` option to restore from backup

4. **Compose file fixer:**
   - Script to automatically convert `env_file:` to `environment:`
   - Parse .env.example and generate mappings

5. **Migration dry-run:**
   - Add `--dry-run` flag to show what would happen
   - Validate all prerequisites without making changes

---

## Related Documentation

- **Task:** `tasks/current/IN-013-migrate-portainer-to-monorepo.md`
- **Scripts README:** `scripts/README.md`
- **Agent Docs:** `docs/agents/INFRASTRUCTURE.md`
- **Stack Configs:** `stacks/*/README.md`

---

## Success Metrics

**VM 103 (Completed):**
- ✅ 3/3 non-Git stacks migrated
- ✅ 0 production issues
- ✅ All services healthy

**Overall Progress:**
- ✅ Phase 1: GitOps enabled on 9 existing Git stacks
- 🟡 Phase 2: 3/5 non-Git stacks migrated (60%)
- ⏳ Phase 3: 0/9 Git stacks migrated to monorepo (0%)

---

## Contact

For issues or questions about this runbook:
- Review task notes in `IN-013-migrate-portainer-to-monorepo.md`
- Check script source code comments
- Test changes on low-risk stacks first
