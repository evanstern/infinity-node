---
type: task
task-id: IN-013
status: not-started
priority: high
category: infrastructure
agent: docker
created: 2025-10-26
updated: 2025-10-26
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
3. ⏳ All stacks imported from VMs into this repo's `stacks/` directory
4. ⏳ Portainer API access tokens created for each VM

## Phases

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

Ensure all services from all VMs are imported into `stacks/` directory:
- [ ] Complete VM 103 imports (immich, linkwarden, audiobookshelf, homepage, navidrome, watchtower)
- [ ] Import VM 100 stacks (emby, portainer, watchtower, newt/pangolin)
- [ ] Import VM 102 stacks (radarr, sonarr, lidarr, prowlarr, jellyseerr, etc.)
- [ ] Import VM 101 stacks (downloads with VPN, portainer, watchtower)

**1.3 Document Current Portainer Stack Configurations**

For each VM, inventory existing stacks:
```bash
# List all stacks via API
curl -X GET "http://<vm-ip>:9000/api/stacks" \
  -H "X-API-Key: <token>"
```

Create inventory file: `docs/portainer-stack-inventory.md`

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

### Phase 3: Execute Migration

**3.1 Test Migration on Single Stack**

Choose a low-risk stack (e.g., homepage) and test full migration:
1. Run migration script
2. Verify stack updates configuration
3. Confirm GitOps pulls from monorepo
4. Test redeployment works
5. Validate service continues running

**3.2 Migrate VM 103 Stacks**

Migrate all VM 103 stacks in order of priority:
- [ ] audiobookshelf
- [ ] linkwarden
- [ ] immich
- [ ] homepage
- [ ] navidrome
- [ ] watchtower

**3.3 Migrate Remaining VMs**

After VM 103 success, migrate other VMs:
- [ ] VM 100 stacks
- [ ] VM 102 stacks
- [ ] VM 101 stacks

**3.4 Validation**

For each migrated stack:
- ✅ Points to monorepo
- ✅ Correct compose file path
- ✅ GitOps enabled with 5min polling
- ✅ Force redeployment enabled
- ✅ Service running and healthy
- ✅ Environment variables preserved
- ✅ Secrets working correctly

### Phase 4: Cleanup

**4.1 Archive Individual Stack Repos**

For each old repo (e.g., `infinity-node-stack-audiobookshelf`):
1. Add archive notice to README
2. Archive the repository on GitHub
3. Document in migration log

**4.2 Update Documentation**

- [ ] Update `stacks/README.md` (already done)
- [ ] Update `docs/ARCHITECTURE.md` with Portainer Git integration details
- [ ] Document migration in `docs/CHANGELOG.md` or migration log
- [ ] Update any references to old repos

**4.3 Create Monitoring/Alerts**

Consider setting up:
- Webhook notifications for stack updates
- Health checks for critical stacks
- Alerts for failed deployments

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
