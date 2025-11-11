---
type: task
task-id: IN-047
status: in-progress
started: 2025-01-27
priority: 3
category: infrastructure
agent: docker
created: 2025-01-27
updated: 2025-01-27

# Task classification
complexity: moderate
estimated_duration: 4-6h
critical_services_affected: true
requires_backup: true
requires_downtime: false

# Design tracking
alternatives_considered: false
risk_assessment_done: true
phased_approach: true

tags:
  - task
  - infrastructure
  - docker
  - configuration
  - dns
  - arr-stack
  - critical-services
---

# Task: IN-047 - Audit Service Configs for Local URLs

> **Quick Summary**: Audit and update all service configuration files to ensure inter-service references use local DNS URLs (`service.local.infinity-node.com`) instead of hardcoded IP addresses, with particular focus on arr stack services on VM-102.

## Problem Statement

**What problem are we solving?**
After IN-034 established Pi-hole DNS infrastructure and IN-035 migrated docker-compose files and scripts to DNS names, we still have configuration files that reference other services via hardcoded IP addresses. This creates maintenance burden and potential failures if IPs change. Key areas:

- **Homepage configuration** (`stacks/homepage/config/homepage/services.yaml`): Widget URLs use hardcoded IPs (192.168.86.172, 192.168.86.174, etc.)
- **Homepage bookmarks** (`stacks/homepage/config/homepage/bookmarks.yaml`): Portainer and Proxmox links use IPs
- **Service configuration files** (on VMs, in `/config` volumes): arr services (Radarr, Sonarr, Lidarr) likely have configs referencing:
  - Download clients (Deluge/NZBGet on VM-101) via IP
  - Prowlarr (indexer management) via IP
  - Emby (webhooks/notifications) via IP
  - Flaresolverr (Cloudflare bypass) via IP
- **Jellyseerr configuration**: May reference Radarr/Sonarr/Emby via IP

**Why now?**
- DNS infrastructure is stable and proven (IN-034, IN-035)
- Configuration drift creates technical debt
- Critical arr services on VM-102 are particularly important - if they lose connectivity due to IP changes, media automation breaks
- Better to audit and fix proactively before IPs change
- Completes the DNS migration work started in IN-035

**Who benefits?**
- **System administrator (Evan)**: Single source of truth (DNS) for service locations
- **Critical services**: More resilient to network changes
- **Media automation**: arr services won't break if IPs change
- **Future maintenance**: Easier to update when network topology changes

## Solution Design

### Recommended Approach

**Phased audit and update** - Start with git-tracked configs (homepage), then audit VM-based configs, update systematically, and validate connectivity.

**Key components:**
1. **Git-tracked configs**: Update homepage YAML files to use DNS names
2. **VM-based configs**: Audit service configuration files on VMs (especially VM-102 arr services)
3. **Service-by-service updates**: Update each service's config to use local URLs
4. **Validation**: Test inter-service connectivity after each update

**Update pattern:**
- Replace `http://192.168.86.XXX:PORT` with `http://service-name.local.infinity-node.com:PORT`
- Replace `https://192.168.86.XXX:PORT` with `https://service-name.local.infinity-node.com:PORT` (if applicable)
- Keep port numbers (services still need ports for direct access)

**Focus areas:**
1. **Homepage** (VM-103): Widget URLs and bookmarks
2. **arr services** (VM-102): Download client URLs, Prowlarr URL, Emby webhook URLs, Flaresolverr URL
3. **Jellyseerr** (VM-102): Radarr/Sonarr/Emby URLs
4. **Other services**: Any remaining inter-service references

### Scope Definition

**✅ In Scope:**
- Update `stacks/homepage/config/homepage/services.yaml` widget URLs to use DNS names
- Update `stacks/homepage/config/homepage/bookmarks.yaml` to use DNS names
- Audit Radarr configuration (download clients, Prowlarr, Emby webhooks)
- Audit Sonarr configuration (download clients, Prowlarr, Emby webhooks)
- Audit Lidarr configuration (download clients, Prowlarr, Emby webhooks)
- Audit Prowlarr configuration (Flaresolverr URL, arr service sync URLs)
- Audit Jellyseerr configuration (Radarr/Sonarr/Emby URLs)
- Update all found IP references to use local DNS URLs
- Test connectivity after each service update
- Document any configuration locations for future reference

**❌ Explicitly Out of Scope:**
- Traefik dynamic.yml files (already use container names, which is correct)
- Docker compose files (already migrated in IN-035)
- External access URLs (Pangolin domains are correct)
- Documentation-only references (can be updated separately)
- Services that don't reference other services

**🎯 MVP (Minimum Viable)**:
All service configuration files that control inter-service communication use local DNS URLs. Services can communicate reliably even if IP addresses change.

## Risk Assessment

### Potential Pitfalls

- ⚠️ **Risk 1: Breaking critical service connectivity** → **Mitigation**:
  - Backup service configs before changes
  - Test connectivity immediately after each update
  - Update one service at a time, validate before proceeding
  - Have rollback plan (restore config backup)

- ⚠️ **Risk 2: Missing configuration files** → **Mitigation**:
  - Audit all services systematically
  - Check both git-tracked and VM-based configs
  - Document all config locations found
  - Use grep/search to find IP references

- ⚠️ **Risk 3: Service restart required** → **Mitigation**:
  - Some services may need restart to pick up config changes
  - Plan updates during low-usage windows (3-6 AM preferred)
  - Coordinate with Testing Agent for validation
  - Test in non-critical services first

- ⚠️ **Risk 4: DNS resolution issues** → **Mitigation**:
  - Verify DNS resolution works before making changes
  - Test with `dig` or `nslookup` on VMs
  - Ensure Pi-hole DNS is working (IN-034 validated this)
  - Have IP addresses as fallback if DNS fails temporarily

### Dependencies

**Prerequisites (must exist before starting):**
- [x] **Pi-hole DNS infrastructure** - IN-034 completed (blocking: yes)
- [x] **DNS records created** - All service DNS records exist (blocking: yes)
- [x] **Docker compose migration** - IN-035 completed (blocking: no, but helpful context)

**No blocking dependencies - can start immediately**

### Critical Service Impact

**Services Affected**: arr stack (VM-102), Homepage (VM-103)

- **Emby (VM 100)**: No direct impact (may receive webhook updates, but webhooks are configured in arr services)
- **Downloads (VM 101)**: No direct impact (arr services connect to download clients, but configs are in arr services)
- **Arr services (VM 102)**: **HIGH IMPACT** - Configuration changes affect:
  - Radarr: Download client connectivity, Prowlarr sync, Emby webhooks
  - Sonarr: Download client connectivity, Prowlarr sync, Emby webhooks
  - Lidarr: Download client connectivity, Prowlarr sync, Emby webhooks
  - Prowlarr: Flaresolverr connectivity, arr service sync
  - Jellyseerr: Radarr/Sonarr/Emby connectivity

**Impact level**: Medium-High - Changes to critical services, but low risk if done carefully with testing

### Rollback Plan

**Applicable for**: Infrastructure/docker configuration changes

**How to rollback if this goes wrong:**
1. **For git-tracked configs**: Revert changes via git (`git checkout -- stacks/homepage/config/homepage/*.yaml`)
2. **For VM-based configs**: Restore from backup (backup configs before changes)
3. **For service configs**: Restore service configuration files from backup
4. **Redeploy stacks**: If using Portainer GitOps, changes auto-revert on git revert
5. **Restart services**: May need to restart services to pick up reverted configs

**Recovery time estimate**: 15-30 minutes per service (backup restore + service restart)

**Backup requirements:**
- Backup homepage config files before changes
- Backup arr service config directories before changes (Radarr, Sonarr, Lidarr, Prowlarr, Jellyseerr)
- Store backups in known location for quick restore
- Document backup locations

## Execution Plan

### Phase 0: Discovery & Inventory

**Primary Agent**: `docker`

- [x] **Audit git-tracked configs** `[agent:docker]`
  - Search for IP addresses in `stacks/homepage/config/`
  - Document all found IP references
  - Create list of files to update
  - **Found**: 8 IPs in services.yaml, 6 IPs in bookmarks.yaml

- [ ] **Audit VM-102 arr service configs** `[agent:docker]` `[agent:media]`
  - SSH to VM-102
  - Check Radarr config directory for IP references
  - Check Sonarr config directory for IP references
  - Check Lidarr config directory for IP references
  - Check Prowlarr config directory for IP references
  - Check Jellyseerr config directory for IP references
  - Document all config file locations and IP references found

- [ ] **Create backup plan** `[agent:docker]`
  - Identify all config files to backup
  - Create backup script or document backup procedure
  - Test backup restore procedure

### Phase 1: Update Homepage Configuration

**Primary Agent**: `docker`

- [x] **Backup homepage configs** `[agent:docker]`
  - Backup `stacks/homepage/config/homepage/services.yaml`
  - Backup `stacks/homepage/config/homepage/bookmarks.yaml`
  - **Backups created**: `.backup` files created

- [x] **Update services.yaml widget URLs** `[agent:docker]`
  - Replace `http://192.168.86.172:8096` → `http://emby.local.infinity-node.com:8096`
  - Replace `http://192.168.86.174:7878` → `http://radarr.local.infinity-node.com:7878`
  - Replace `http://192.168.86.174:8989` → `http://sonarr.local.infinity-node.com:8989`
  - Replace `http://192.168.86.174:8686` → `http://lidarr.local.infinity-node.com:8686`
  - Replace `http://192.168.86.174:9696` → `http://prowlarr.local.infinity-node.com:9696`
  - Replace `http://192.168.86.174:5055` → `http://jellyseerr.local.infinity-node.com:5055`
  - Replace `https://192.168.86.249:9443` → `https://portainer-103.local.infinity-node.com:9443`
  - Note: Traefik dashboard uses direct IP access (not routed via Traefik), keep as IP or verify DNS record exists

- [x] **Update bookmarks.yaml** `[agent:docker]`
  - Replace Portainer IPs with DNS names (all 4 VMs updated)
  - Replace NAS IP with `thor.local.infinity-node.com:5000` (DNS record exists)
  - Keep Proxmox IP (no DNS record exists)
  - **All bookmarks updated**: NAS, Portainer-100, Portainer-101, Portainer-102, Portainer-103

- [x] **Validate homepage config** `[agent:testing]`
  - Check YAML syntax
  - Verify DNS names resolve correctly
  - Test homepage loads without errors

### Phase 2: Update arr Services Configuration (VM-102)

**Primary Agent**: `docker` + `media`

- [ ] **Backup arr service configs** `[agent:docker]`
  - Backup Radarr config directory
  - Backup Sonarr config directory
  - Backup Lidarr config directory
  - Backup Prowlarr config directory
  - Backup Jellyseerr config directory

- [ ] **Update Radarr configuration** `[agent:media]` `[risk:1]`
  - Update download client URLs (Deluge, NZBGet) to use DNS names
  - Update Prowlarr URL to use DNS name
  - Update Emby webhook URL to use DNS name
  - Restart Radarr container
  - Test connectivity: Verify can connect to download clients, Prowlarr, Emby

- [ ] **Update Sonarr configuration** `[agent:media]` `[risk:1]`
  - Update download client URLs (Deluge, NZBGet) to use DNS names
  - Update Prowlarr URL to use DNS name
  - Update Emby webhook URL to use DNS name
  - Restart Sonarr container
  - Test connectivity: Verify can connect to download clients, Prowlarr, Emby

- [ ] **Update Lidarr configuration** `[agent:media]` `[risk:1]`
  - Update download client URLs (Deluge, NZBGet) to use DNS names
  - Update Prowlarr URL to use DNS name
  - Update Emby webhook URL to use DNS name
  - Restart Lidarr container
  - Test connectivity: Verify can connect to download clients, Prowlarr, Emby

- [ ] **Update Prowlarr configuration** `[agent:media]` `[risk:1]`
  - Update Flaresolverr URL to use DNS name
  - Update arr service sync URLs (Radarr, Sonarr, Lidarr) to use DNS names
  - Restart Prowlarr container
  - Test connectivity: Verify can connect to Flaresolverr, arr services

- [ ] **Update Jellyseerr configuration** `[agent:media]` `[risk:1]`
  - Update Radarr URL to use DNS name
  - Update Sonarr URL to use DNS name
  - Update Emby URL to use DNS name
  - Restart Jellyseerr container
  - Test connectivity: Verify can connect to Radarr, Sonarr, Emby

### Phase 3: Validation & Testing

**Primary Agent**: `testing`

- [ ] **Test homepage widgets** `[agent:testing]`
  - Verify all widgets load correctly
  - Verify API connections work with DNS URLs
  - Check for errors in homepage logs

- [ ] **Test arr service connectivity** `[agent:testing]`
  - Test Radarr → Download clients (Deluge, NZBGet)
  - Test Radarr → Prowlarr
  - Test Radarr → Emby webhook
  - Test Sonarr → Download clients (Deluge, NZBGet)
  - Test Sonarr → Prowlarr
  - Test Sonarr → Emby webhook
  - Test Lidarr → Download clients (Deluge, NZBGet)
  - Test Lidarr → Prowlarr
  - Test Lidarr → Emby webhook
  - Test Prowlarr → Flaresolverr
  - Test Prowlarr → arr services sync
  - Test Jellyseerr → Radarr/Sonarr/Emby

- [ ] **Test media automation flow** `[agent:testing]`
  - Trigger test download request via Jellyseerr
  - Verify request reaches Radarr/Sonarr
  - Verify Prowlarr search works
  - Verify download client receives download
  - Verify webhook to Emby works (if applicable)

- [ ] **Monitor for errors** `[agent:testing]`
  - Check service logs for DNS resolution errors
  - Check service logs for connection failures
  - Monitor for 24 hours after changes

### Phase 4: Documentation

**Primary Agent**: `documentation`

- [ ] **Document config file locations** `[agent:documentation]`
  - Document where each service stores its configuration
  - Document which configs reference other services
  - Add to relevant service README files

- [ ] **Update service documentation** `[agent:documentation]`
  - Update arr service READMEs with DNS URL examples
  - Update homepage README with DNS URL examples
  - Document the audit process for future reference

- [ ] **Create runbook entry** `[agent:documentation]`
  - Add section to relevant runbook about updating service URLs
  - Document the pattern: always use DNS names, not IPs

## Acceptance Criteria

**Done when all of these are true:**
- [ ] All git-tracked config files use DNS names instead of IPs
- [ ] All arr service configs (Radarr, Sonarr, Lidarr, Prowlarr, Jellyseerr) use DNS names
- [ ] Homepage widgets work correctly with DNS URLs
- [ ] All inter-service connectivity tested and working
- [ ] No IP addresses found in service configuration files (except where DNS not available)
- [ ] Config file locations documented
- [ ] All execution plan items completed
- [ ] Testing Agent validates (see testing plan below)
- [ ] Changes committed with descriptive message (awaiting user approval)

## Testing Plan

**[[docs/agents/TESTING|Testing Agent]] validates:**
- Homepage loads without errors
- Homepage widgets connect to services via DNS URLs
- Radarr can connect to download clients via DNS
- Radarr can connect to Prowlarr via DNS
- Sonarr can connect to download clients via DNS
- Sonarr can connect to Prowlarr via DNS
- Lidarr can connect to download clients via DNS
- Lidarr can connect to Prowlarr via DNS
- Prowlarr can connect to Flaresolverr via DNS
- Prowlarr can sync to arr services via DNS
- Jellyseerr can connect to Radarr/Sonarr/Emby via DNS
- No DNS resolution errors in service logs
- Media automation flow works end-to-end

**Manual validation:**
1. Access homepage, verify all widgets load and show data
2. Access Radarr, verify download clients show as connected
3. Access Sonarr, verify download clients show as connected
4. Access Prowlarr, verify arr services show as synced
5. Trigger test download request via Jellyseerr, verify it processes
6. Check service logs for any connection errors
7. Verify Emby receives webhook notifications (if configured)

## Related Documentation

- [[docs/ARCHITECTURE|Infrastructure Architecture]] - Service communication patterns
- [[docs/agents/DOCKER|Docker Agent]] - Container configuration management
- [[docs/agents/MEDIA|Media Stack Agent]] - arr service management
- [[docs/runbooks/traefik-management|Traefik Management Runbook]] - DNS and routing
- [[tasks/completed/IN-034-setup-local-dns-service-discovery|IN-034]] - DNS infrastructure setup
- [[tasks/completed/IN-035-migrate-services-to-dns-names|IN-035]] - Docker compose DNS migration

## Notes

**Priority Rationale**:
Priority 3 (medium) - Important for maintainability and resilience, but not urgent. Critical services are working fine with IPs currently. However, completing this DNS migration prevents future issues when IPs change.

**Complexity Rationale**:
Moderate complexity because:
- Multiple services to audit and update
- Some configs in git (easy), some on VMs (requires SSH access)
- Critical services affected (arr stack) - requires careful testing
- Need to understand each service's configuration structure
- Validation required after each change

**Implementation Notes**:
- arr services store configs in `/config` volumes on NAS
- Config files are typically JSON or XML format
- Some services may require restart to pick up config changes
- DNS names should include port numbers for direct access
- Traefik routing uses container names (already correct, don't change)

**Follow-up Tasks**:
- Consider creating script to audit configs for IP references
- Consider adding validation to prevent IP references in future configs
- Document common config file locations in service READMEs

---

> [!note]- 📋 Work Log
>
> **2025-01-27 - Phase 0 & 1 Complete**
- Audited git-tracked configs: Found 8 IPs in services.yaml, 6 IPs in bookmarks.yaml
- Created backups of homepage config files
- Updated all homepage widget URLs to use DNS names (Emby, Radarr, Sonarr, Lidarr, Prowlarr, Jellyseerr, Portainer-103, Watchtower)
- Updated all homepage bookmarks to use DNS names (NAS: thor.local.infinity-node.com, all Portainer instances)
- Kept Proxmox IP (no DNS record exists)
- Updated Watchtower URL to use vm-103.local.infinity-node.com:8080 (Traefik dashboard)

**2025-01-27 - Phase 2 Started**
- Audited VM-102 arr service configs
- Found Jellyseerr settings.json contains IPs for Radarr and Sonarr (192.168.86.174)
- Updated Jellyseerr settings.json: Radarr → radarr.local.infinity-node.com, Sonarr → sonarr.local.infinity-node.com
- Restarted Jellyseerr container
- **Note**: arr services (Radarr, Sonarr, Lidarr, Prowlarr) store URLs in SQLite databases (not config files)
- sqlite3 not available on host or in containers
- **Remaining work**: arr services need manual updates via web UI:
  - Radarr/Sonarr/Lidarr: Settings → Download Clients (Deluge, NZBGet URLs)
  - Radarr/Sonarr/Lidarr: Settings → Indexers (Prowlarr URL)
  - Radarr/Sonarr/Lidarr: Settings → Notifications (Emby webhook URLs)
  - Prowlarr: Settings → Apps (arr service sync URLs)
  - Prowlarr: Settings → Indexers (Flaresolverr URL)

> [!tip]- 💡 Lessons Learned
>
> *Lessons learned will be captured during task execution*
