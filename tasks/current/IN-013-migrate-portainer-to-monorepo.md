---
type: task
task-id: IN-013
status: paused
priority: 1
category: infrastructure
agent: docker
created: 2025-10-26
updated: 2025-10-29
started: 2025-10-28
tags:
  - task
  - portainer
  - automation
  - git-integration
  - infrastructure-as-code
---

# Task: IN-013 - Migrate Portainer Stack Configurations to Monorepo

**Goal:** Migrate all Portainer stacks from individual GitHub repos (e.g., `infinity-node-stack-audiobookshelf`) to this monorepo, using Portainer's API to automate the configuration updates.

**Current State:** Services like audiobookshelf are configured with separate Git repos. Each service has its own repo with just a docker-compose.yml file.

**Target State:** All stacks configured to pull from this monorepo at `https://github.com/evanstern/infinity-node` with specific compose file paths (e.g., `stacks/audiobookshelf/docker-compose.yml`).

## Context

Portainer supports Git integration with the following features:
- Point stacks at Git repositories
- Specify compose file path within repo
- GitOps automatic updates (polling or webhook)
- API support for programmatic configuration
- Access tokens for authentication

**Benefits of Monorepo Approach:**
- Single source of truth for all infrastructure
- Version control all stacks together
- Track dependencies between services
- Simplified disaster recovery (one repo to clone)
- Easier to review changes across services
- Eliminate maintenance of multiple small repos

## Prerequisites

1. ✅ Vaultwarden secret storage established
2. ✅ VM 103 priority stacks imported (vaultwarden, paperless-ngx, portainer)
3. ⏳ All stacks imported from VMs into this repo's `stacks/` directory (will complete in Phase 0)
4. ⏳ Portainer API access tokens created for each VM (will create in Phase 1)

**Note:** Prerequisites 3-4 will be completed as part of this task execution.

## VM Details

- **VM 100 (emby):** 192.168.86.172 - Portainer at https://192.168.86.172:9443
- **VM 101 (downloads):** 192.168.86.173 - Portainer at https://192.168.86.173:9443
- **VM 102 (arr):** 192.168.86.174 - Portainer at https://192.168.86.174:9443
- **VM 103 (misc):** 192.168.86.249 - Portainer at https://192.168.86.249:9443

## Phases

### Phase 0: Inventory and Verification (NEW)

**0.1 Inventory Current Stack Deployments**

For each VM, document:
- All currently running stacks
- Current deployment method (Git vs manual upload)
- Current Git repo (if using Git integration)
- Environment variables and secrets used
- Health status

Create comprehensive inventory document: `docs/portainer-migration-inventory.md`

Commands to gather info:
```bash
# For each VM, list stacks
for VM_IP in 192.168.86.172 192.168.86.173 192.168.86.174 192.168.86.249; do
  echo "=== Stacks on $VM_IP ==="
  curl -X GET "http://$VM_IP:9000/api/stacks" \
    -H "X-API-Key: <token-if-available>"
done
```

**0.2 Verify Stacks Exist in Repo**

Check which stacks from inventory exist in `stacks/` directory:
- List all stacks in repo
- Compare against inventory
- Identify gaps (stacks not yet imported)

**0.3 Plan Import Strategy**

For stacks not yet in repo:
- Document where to find current configs
- Identify any VMs we need SSH access to
- Note any special configurations or dependencies

### Phase 1: Preparation

**1.1 Create Portainer API Access Tokens**

For each VM's Portainer instance, create a long-lived API token:

1. Access Portainer via HTTPS: `https://<vm-ip>:9443`
2. Navigate to: Username (top right) → My account → Access tokens
3. Click "Add access token"
4. Provide descriptive name: `automation-infinity-node-monorepo`
5. Re-enter password for verification
6. **Copy token immediately** (one-time view only)
7. Store token in Vaultwarden:
   ```bash
   export BW_SESSION=$(bw unlock --raw)

   ./scripts/create-secret.sh "portainer-api-token-vm-100" "shared" \
     "<token-value>" \
     '{"service":"portainer","vm":"100","purpose":"api-automation"}'

   ./scripts/create-secret.sh "portainer-api-token-vm-101" "shared" \
     "<token-value>" \
     '{"service":"portainer","vm":"101","purpose":"api-automation"}'

   # Repeat for VM 102, 103
   ```

**1.2 Import All Remaining Stacks to Repo**

Based on Phase 0 inventory, import missing stacks into `stacks/` directory.

For each stack to import:
1. SSH to VM and locate docker-compose.yml
2. Copy to `stacks/<service-name>/docker-compose.yml` in repo
3. Create `.env.example` documenting required environment variables
4. Create `README.md` documenting the service
5. Note any secrets that need to be migrated to Vaultwarden
6. Commit to repo

**1.3 Document Secret Management Strategy**

For each stack, document:
- What secrets/env vars are currently used
- Where they're currently stored (Portainer env vars? .env files?)
- Plan for migrating to Vaultwarden if needed
- How secrets will be injected after migration (Portainer env vars)

**1.4 Create Portainer Backup**

Before any migration, backup Portainer configuration:
```bash
# For each VM, backup Portainer data directory
ssh evan@<vm-ip> "sudo tar -czf /home/evan/backups/portainer-backup-$(date +%Y%m%d).tar.gz -C /var/lib/docker/volumes portainer_data"

# Download backup locally for safekeeping
scp evan@<vm-ip>:/home/evan/backups/portainer-backup-*.tar.gz ./backups/
```

This allows complete rollback if needed.

### Phase 2: Create Migration Script

**2.1 Create `scripts/migrate-portainer-stack.sh`**

Script requirements:
- Accept parameters: stack-name, vm-ip, compose-path, env-vars
- Retrieve Portainer API token from Vaultwarden
- Retrieve stack secrets from Vaultwarden
- Use Portainer API to update stack configuration
- Update Git repo URL to monorepo
- Update compose file path
- Configure GitOps polling (5 minute interval)
- Enable force redeployment
- Preserve environment variables
- Redeploy stack after update

**API Endpoints:**
- `GET /api/stacks` - List stacks
- `GET /api/stacks/{id}` - Get stack details
- `PUT /api/stacks/{id}` - Update stack configuration
- `PUT /api/stacks/{id}/git/redeploy` - Trigger redeploy from Git

**Example API Call:**
```bash
# Update stack Git configuration
curl -X PUT "http://192.168.86.249:9000/api/stacks/{id}/git" \
  -H "X-API-Key: ${PORTAINER_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "repositoryURL": "https://github.com/evanstern/infinity-node",
    "repositoryReferenceName": "main",
    "composeFilePathInRepository": "stacks/audiobookshelf/docker-compose.yml",
    "repositoryAuthentication": false,
    "autoUpdate": {
      "interval": "5m",
      "forceUpdate": true
    }
  }'
```

**2.2 Create `scripts/list-portainer-stacks.sh`**

Helper script to inventory all stacks across VMs:
- Query each VM's Portainer API
- List stack name, current repo, status
- Output as markdown table

**2.3 Create `scripts/validate-portainer-migration.sh`**

Validation script to verify migration:
- Check each stack points to monorepo
- Verify compose file paths are correct
- Confirm GitOps is enabled
- Test stack can pull and deploy successfully

### Phase 3: Execute Migration (Risk-Ordered)

**Migration Order:** Start with lowest-risk services, progress to critical services.

**Risk Levels:**
- **Low Risk:** homepage, watchtower, portainer (no user-facing impact)
- **Medium Risk:** audiobookshelf, linkwarden, navidrome, immich, newt/pangolin
- **High Risk (CRITICAL):** emby, downloads, radarr, sonarr, lidarr, prowlarr, jellyseerr

**3.1 Test Migration - Homepage (VM 103)**

**Lowest risk stack for testing:**
1. Run migration script on homepage stack
2. Verify stack configuration updated in Portainer UI
3. Wait 5+ minutes, confirm GitOps pulls from monorepo
4. Trigger manual redeploy, verify it works
5. Validate homepage loads and functions correctly
6. Monitor logs for errors

**If issues occur:** Rollback homepage immediately (see rollback procedure below)

**3.2 Migrate Low-Risk Stacks**

After homepage success, migrate other low-risk stacks:
- [ ] watchtower (VM 103)
- [ ] watchtower (VM 100)
- [ ] watchtower (VM 101)
- [ ] watchtower (VM 102)
- [ ] portainer stack configs (if any exist as separate stacks)

Validate each before moving to next.

**3.3 Migrate Medium-Risk Stacks**

After low-risk success:
- [ ] audiobookshelf (VM 103)
- [ ] linkwarden (VM 103)
- [ ] navidrome (VM 103)
- [ ] immich (VM 103)
- [ ] newt/pangolin (VM 100)

Validate each before moving to next.

**3.4 Migrate High-Risk CRITICAL Stacks**

⚠️ **CRITICAL SERVICES - Extra Caution Required**

**Recommended timing:** Off-hours (3-6 AM) to minimize household impact

**VM 100 - Emby (CRITICAL):**
- [ ] emby - Validate streaming works after migration

**VM 101 - Downloads (CRITICAL):**
- [ ] downloads stack (with VPN) - Verify VPN connection maintained

**VM 102 - Arr Services (CRITICAL):**
- [ ] prowlarr - Test indexer searches work
- [ ] radarr - Verify movie library access
- [ ] sonarr - Verify TV library access
- [ ] lidarr - Verify music library access
- [ ] jellyseerr - Verify request system works

**For each critical service:**
1. Announce downtime window to household if needed
2. Backup Portainer config immediately before
3. Run migration
4. Intensive testing (see enhanced testing criteria below)
5. Monitor for 30+ minutes before proceeding to next

**3.5 Enhanced Testing Criteria**

For each migrated stack, validate:

**Configuration Checks:**
- ✅ Stack points to monorepo (https://github.com/evanstern/infinity-node)
- ✅ Correct compose file path (stacks/<service>/docker-compose.yml)
- ✅ GitOps enabled with 5min polling interval
- ✅ Force redeployment enabled
- ✅ Environment variables preserved correctly
- ✅ Secrets still accessible (no credential errors in logs)

**Functional Checks:**
- ✅ All containers started successfully
- ✅ Container logs show no errors
- ✅ HTTP endpoint responds (if applicable)
- ✅ Service-specific functionality works:
  - Homepage: displays widgets correctly
  - Emby: can browse library and start stream
  - Downloads: VPN connected, can add torrent
  - Arr services: can search indexers, access library
  - Watchtower: checks for updates
- ✅ Dependent services still work (e.g., arr→downloads→emby chain)

**GitOps Checks:**
- ✅ Wait 5+ minutes, verify Portainer polls Git
- ✅ Make trivial change to docker-compose.yml in repo
- ✅ Commit and push
- ✅ Wait 5+ minutes, verify Portainer detects change
- ✅ Verify stack can be redeployed from Git successfully

### Phase 3.6: Rollback Procedure

If any migration fails or causes issues, rollback immediately:

**Option 1: Revert via Portainer UI (Quick)**
1. Go to Portainer UI → Stacks → Click problem stack
2. Click "Editor" tab
3. Change Git repository back to old repo URL
4. Change compose file path back to original
5. Click "Update the stack"
6. Verify service recovers

**Option 2: Revert via API (Scripted)**
```bash
# Revert stack Git config to previous repo
curl -X PUT "http://<vm-ip>:9000/api/stacks/{stack-id}/git" \
  -H "X-API-Key: ${PORTAINER_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "repositoryURL": "https://github.com/evanstern/infinity-node-stack-<old-repo>",
    "repositoryReferenceName": "main",
    "composeFilePathInRepository": "docker-compose.yml"
  }'

# Redeploy from reverted repo
curl -X PUT "http://<vm-ip>:9000/api/stacks/{stack-id}/git/redeploy" \
  -H "X-API-Key: ${PORTAINER_TOKEN}"
```

**Option 3: Full Portainer Restore (Nuclear)**
If Portainer itself is corrupted:
```bash
# Stop Portainer container
ssh evan@<vm-ip> "docker stop portainer"

# Restore backed-up Portainer data
ssh evan@<vm-ip> "sudo tar -xzf /home/evan/backups/portainer-backup-YYYYMMDD.tar.gz -C /var/lib/docker/volumes"

# Start Portainer
ssh evan@<vm-ip> "docker start portainer"
```

**After any rollback:**
- Document what went wrong in task notes
- Analyze root cause before attempting migration again
- Update migration script or procedure as needed

### Phase 4: Cleanup

**4.1 Archive Individual Stack Repos**

For each old repo (e.g., `infinity-node-stack-audiobookshelf`):
1. Add archive notice to README
2. Archive the repository on GitHub
3. Document in migration log

**4.2 Update Documentation**

- [ ] Update `stacks/README.md` with Git integration details
- [ ] Update `docs/ARCHITECTURE.md` with Portainer GitOps workflow
- [ ] Document migration in task progress notes
- [ ] Update any references to old repos in documentation
- [ ] Create ADR if any design decisions were made during migration

**4.3 Setup Monitoring/Alerts (FUTURE WORK)**

⏭️ **Deferred to separate monitoring task** (see [[tasks/backlog/IN-005-setup-monitoring-alerting|IN-005]])

Future considerations:
- Webhook notifications for stack updates
- Health checks for critical stacks
- Alerts for failed deployments
- Portainer Agent for centralized monitoring

## Success Criteria

- [ ] All Portainer stacks point to monorepo
- [ ] GitOps automatic updates enabled on all stacks
- [ ] All services remain running and healthy
- [ ] Environment variables and secrets preserved
- [ ] Old individual repos archived
- [ ] Documentation updated
- [ ] Migration validated and tested

## Technical Details

**Portainer API Documentation:**
- Access: https://docs.portainer.io/api/access
- Stack Management: https://docs.portainer.io/user/docker/stacks/add
- API Reference: https://docs.portainer.io/api/docs

**Repository Details:**
- Current separate repos: `evanstern/infinity-node-stack-<service>`
- Target monorepo: `evanstern/infinity-node`
- Compose paths: `stacks/<service>/docker-compose.yml`

**VMs and IPs:**
- VM 100 (emby): TBD
- VM 101 (downloads): TBD
- VM 102 (arr): TBD
- VM 103 (misc): 192.168.86.249

## Related Documentation

- [stacks/README.md](../../stacks/README.md) - Stack deployment documentation
- [docs/SECRET-MANAGEMENT.md](../../docs/SECRET-MANAGEMENT.md) - Secret management guide
- [docs/ARCHITECTURE.md](../../docs/ARCHITECTURE.md) - Infrastructure overview
- [Portainer API Docs](https://docs.portainer.io/api/docs) - Official API reference

## Notes

- API tokens are long-lived and stored in Vaultwarden for reuse
- Migration can be done incrementally (one stack at a time)
- Rollback: can revert stack config to old repo if issues arise
- GitOps polling interval of 5 minutes balances responsiveness and load
- Force redeployment ensures Git is always source of truth
- Test on non-critical stacks first to validate process
- Consider creating backup of Portainer configuration before migration

## Dependencies

- **Blocks:** None (can start after current import task)
- **Blocked By:**
  - Complete stack imports (in-progress)
  - Portainer API token creation (pending)

## Estimated Effort

- Script development: 4-6 hours
- Testing and validation: 2-3 hours
- Migration execution: 2-4 hours (depending on number of stacks)
- Documentation and cleanup: 1-2 hours

**Total:** ~10-15 hours spread across multiple sessions

## Progress Notes

### 2025-10-28: Phase 0 Complete - Inventory Revealed Major Findings

**Phase 0: Inventory and Verification - ✅ COMPLETE**

**Work Completed:**
1. ✅ Created and tested `scripts/infrastructure/query-portainer-stacks.sh`
2. ✅ Created and tested `scripts/secrets/list-vaultwarden-structure.sh`
3. ✅ Enhanced `scripts/utils/bw-setup-session.sh` for Claude Code BW access
4. ✅ Generated Portainer API tokens for all 4 VMs
5. ✅ Stored all tokens in Vaultwarden (shared collection) with metadata
6. ✅ Queried actual deployed stacks from all VMs
7. ✅ Created comprehensive inventory: `docs/portainer-migration-inventory.md`
8. ✅ Updated Security Agent docs with available scripts
9. ✅ Updated scripts README with new utilities

**Inventory Results - 14 stacks total:**
- VM 100 (Emby): 2 stacks - watchtower, newt
- VM 101 (Downloads): 2 stacks - downloads, watchtower
- VM 102 (Arr): 2 stacks - utils, arr
- VM 103 (Misc): 8 stacks - homepage, paperless-ngx, linkwarden, vaultwarden, watchtower, newt, audiobookshelf, navidrome

**CRITICAL DISCOVERY: Task Premise Was Incorrect**

The task was based on the assumption that stacks need to be migrated FROM separate repos TO the monorepo (`infinity-node/stacks/`).

**Reality discovered:**
- ✅ **9 stacks (64%) already using Git** via separate repos (infinity-node-stack-*)
- ❌ **5 stacks (36%) NOT using Git** - deployed manually via Portainer UI
- ⚠️ **Monorepo (`infinity-node/stacks/`) exists but is NOT deployed anywhere**
- ⚠️ **Auto-update disabled** on almost all stacks (only downloads has it enabled at 12h interval)

**BLOCKED: Major Decision Required**

**The Question:** What is our actual goal?

**Option A: Migrate TO monorepo (original task intent)**
- Reconfigure all 14 stacks to use `evanstern/infinity-node` repo with `stacks/<service>/` paths
- Pros: Single repo, matches existing structure, easier management
- Cons: Disruptive (need to reconfigure 9 working stacks), risks breaking working deployments
- Work: High effort, touch all VMs

**Option B: Keep separate repos + migrate missing 5**
- Keep 9 working stacks as-is (infinity-node-stack-* repos)
- Create 5 new separate repos for non-Git stacks
- Enable auto-update on all stacks
- Pros: Less disruptive, 9 stacks already working
- Cons: More repos to manage (14 total), doesn't use monorepo structure

**Option C: Hybrid approach**
- Gradually migrate to monorepo over time
- Start by enabling auto-update on existing Git stacks
- Migrate non-Git stacks to monorepo first (5 stacks)
- Eventually migrate Git stacks to monorepo (9 stacks)
- Pros: Lowest risk, incremental progress
- Cons: Temporary inconsistency, longer timeline

**Recommendation:** **Need user decision before continuing.**

**Additional Findings:**
- VM 101 Portainer on non-standard port 32768 (not 9443)
- Missing expected stacks: emby (VM 100), immich (VM 103), portainer containers themselves
- Combined stacks on VM 102: "arr" likely contains radarr/sonarr/lidarr/prowlarr/jellyseerr
- Combined stacks on VM 102: "utils" likely contains portainer/watchtower/flaresolverr
- Secret organization clarified: VM collections for service secrets, shared for infrastructure secrets

**Tools Created (Immediately Useful):**
- `query-portainer-stacks.sh` - Reusable for monitoring, validation, future migrations
- `list-vaultwarden-structure.sh` - Helps understand secret organization
- Enhanced `bw-setup-session.sh` - Solves recurring BW_SESSION access problem

**Next Steps:**
1. **User decision:** Which option (A, B, or C)?
2. Update task scope based on decision
3. Proceed with chosen migration strategy

### 2025-10-29: Phases 1-2 Complete - Major Migration Progress

**User Decision:** Selected Option C (Hybrid Approach) - Migrate incrementally starting with non-Git stacks

**Phase 1: GitOps Enablement - ✅ COMPLETE**
- ✅ Enabled GitOps auto-updates on all 9 existing Git-based stacks
- ✅ Configured 5-minute polling interval across all VMs
- ✅ Verified GitOps working on watchtower, newt, vaultwarden, audiobookshelf, navidrome, downloads

**Phase 2: Non-Git Stack Migration - ✅ COMPLETE**

**VM 103 (Misc) - 3 stacks migrated:**
- ✅ homepage → Git-based monorepo
- ✅ paperless-ngx → Git-based monorepo
- ✅ linkwarden → Git-based monorepo
  - **Lesson:** Removed `env_file:` directives, added explicit environment variable mappings
  - **Lesson:** Must pass full Env array when calling Git update endpoint (empty array clears vars)

**VM 102 (Arr) - 9 stacks migrated:**
- ✅ Split combined `utils` stack (ID: 2) into:
  - watchtower → Git-based monorepo
  - newt → Git-based monorepo
- ✅ Split combined `arr` stack (ID: 3) into:
  - radarr → Git-based monorepo
  - sonarr → Git-based monorepo
  - prowlarr → Git-based monorepo
  - lidarr → Git-based monorepo
  - huntarr → Git-based monorepo
  - jellyseerr → Git-based monorepo
  - flaresolverr → Git-based monorepo
  - **Critical Lesson:** When deploying from Git, use **absolute paths** for CONFIG_PATH
  - Changed from `CONFIG_PATH=./config` to `CONFIG_PATH=/home/evan/projects/infinity-node/stacks/{service}/config`
  - **Lesson:** Created 3.8GB backup before migration (services have SQLite databases)
  - **Discovery:** Config directories were already in correct locations, simplifying migration

**VM 101 (Downloads) - No work needed:**
- Both stacks already Git-based (pointing to standalone repos)
- No combined stacks to split

**VM 100 (Emby) - In Progress:**
- ⏳ Discovered Emby running as standalone container (not in Portainer)
- ⏳ Creating 4GB config backup
- ⏳ Preparing to migrate to Portainer Git-based stack

**Scripts Created:**
- ✅ `enable-gitops-updates.sh` - Enable GitOps on existing Git stacks
- ✅ `migrate-stack-to-monorepo.sh` - Update Git URL for Git-based stacks
- ✅ `migrate-nonGit-stack-to-monorepo.sh` - Full migration for non-Git stacks
- ✅ `stop-stack.sh` - Stop stacks via API
- ✅ `backup-stack.sh` - Create backup copies via API
- ✅ `delete-stack.sh` - Delete stacks via API
- ✅ `create-git-stack.sh` - Create new Git-based stacks
- ✅ `verify-stack-health.sh` - Poll containers until healthy

**Documentation Created:**
- ✅ `docs/runbooks/portainer-stack-migration.md` - Comprehensive migration runbook
  - Documents lessons learned (env_file issues, GitOps env clearing, volume backups)
  - Step-by-step migration procedures
  - Troubleshooting guide
  - VM-specific notes and stack priority order

**Results:**
- **12 stacks successfully migrated** to Git-based monorepo deployment
- **All services healthy** and verified by user testing
- **Zero production issues** during migration
- **GitOps enabled** with 5-minute auto-update on all migrated stacks

**Remaining Work:**
- VM 100: Migrate Emby from standalone to Portainer Git stack (in progress)
- Phase 3: Migrate remaining 9-11 Git-based stacks from standalone repos to monorepo
  - VM 103: vaultwarden, watchtower, newt, audiobookshelf, navidrome
  - VM 101: downloads, watchtower
  - VM 100: watchtower, newt

### 2025-10-29: Work Interrupted - Network Access Lost

⚠️ **Task Status:** PAUSED

**Context:** Work was interrupted while in progress on VM 100 (Emby) migration. Lost access to home network due to relocation.

**State at Interruption:**
- VM 100 Emby migration was in progress:
  - Discovered Emby running as standalone container (not in Portainer)
  - Was creating 4GB config backup
  - Was preparing to migrate to Portainer Git-based stack
- Status of backup creation: Unknown (may or may not have completed)
- Status of Emby service: Unknown (likely still running as standalone)

**Required Actions When Resuming:**
1. **Evaluate Current State:**
   - Verify Emby is still running and healthy
   - Check if backup completed (look for backup file on VM 100)
   - Verify no partial migration was applied
   - Confirm all previously migrated stacks (VM 102, VM 103) still healthy

2. **Resume or Restart VM 100 Migration:**
   - If backup completed: Continue with Emby migration to Portainer
   - If backup incomplete: Restart backup process
   - Follow runbook at `docs/runbooks/portainer-stack-migration.md`

3. **Complete Phase 3:**
   - After VM 100 complete, proceed with remaining Git stack migrations
   - Update to use monorepo paths instead of standalone repos

**Notes:**
- All 12 previously migrated stacks should remain stable (GitOps enabled, no manual intervention needed)
- Migration scripts are ready and tested
- Comprehensive runbook available for reference
