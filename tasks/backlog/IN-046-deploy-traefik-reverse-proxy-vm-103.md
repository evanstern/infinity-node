---
type: task
task-id: IN-046
status: pending
priority: 3
category: docker
agent: docker
created: 2025-01-XX
updated: 2025-01-XX
started:
completed:

# Task classification
complexity: complex
estimated_duration: 8-12h
critical_services_affected: true
requires_backup: true
requires_downtime: false

# Design tracking
alternatives_considered: true
risk_assessment_done: true
phased_approach: true

tags:
  - task
  - docker
  - networking
  - reverse-proxy
  - traefik
  - vm-100
  - vm-101
  - vm-102
  - vm-103
---

# Task: IN-046 - Deploy Traefik Reverse Proxy Across All VMs

> **Quick Summary**: Deploy Traefik reverse proxy on all VMs (100, 101, 102, 103) to enable port-free service access via DNS names for all stacks (complements IN-034 PiHole DNS setup). Allows `service.local.infinity-node.com` URLs without port numbers across entire infrastructure.

## Problem Statement

**What problem are we solving?**
With IN-034 configuring PiHole DNS, services can be accessed via DNS names like `emby.local.infinity-node.com`, but users still need to specify ports (e.g., `http://emby.local.infinity-node.com:8096`). DNS protocol cannot resolve ports - this is a fundamental limitation. To achieve port-free access (`http://emby.local.infinity-node.com`) across the entire infrastructure, we need reverse proxies on each VM that listen on standard ports (80/443) and route traffic to backend services based on hostname.

**Why now?**
- **Complements IN-034**: DNS setup enables hostname resolution, reverse proxy completes the solution
- **Better UX**: Port-free URLs are cleaner and more user-friendly across all services
- **Standard practice**: Reverse proxies are standard infrastructure for service routing
- **Traefik familiarity**: Already using Traefik in Pangolin, reduces learning curve
- **Complete solution**: Deploying across all VMs provides consistent access pattern for all services

**Who benefits?**
- **Household users**: Cleaner URLs for Emby and other critical services, easier to remember
- **System administrator**: Centralized routing per VM, easier service management
- **Future work**: Enables easier service migration and management across entire infrastructure

## Solution Design

### Recommended Approach

**Deploy Traefik reverse proxy on all VMs (100, 101, 102, 103)** using Docker Compose, configured with:
- **File-based routing**: Use Traefik's file provider for static configuration (simpler than Docker labels initially)
- **Standard ports**: Listen on ports 80 (HTTP) and 443 (HTTPS) on each VM
- **Hostname-based routing**: Route traffic to backend services based on `Host` header
- **Phased deployment**: Start with VM 103 (non-critical), validate approach, then deploy to critical VMs (100, 101, 102)
- **All services**: Route all web-accessible services on each VM through Traefik
- **Docker network**: Use Traefik's Docker network for service discovery per VM

**Key components:**
- **Traefik containers**: One per VM (100, 101, 102, 103)
- **Configuration files**: Static routing rules in `traefik.yml` and `dynamic.yml` per VM
- **Docker networks**: Shared network per VM for Traefik and backend services
- **Service integration**: Update all services on each VM to use Traefik network

**Rationale**: Phased approach starting with VM 103 validates the pattern safely before touching critical services. File-based configuration is simpler to start with and easier to understand. Can migrate to Docker labels later if preferred. Deploying to all VMs provides consistent access pattern across entire infrastructure.

> [!abstract]- 🔀 Alternative Approaches Considered
>
> **Option A: File-Based Configuration** ✅ CHOSEN
> - ✅ Pros: Simple, explicit, easy to understand and debug
> - ✅ Pros: Configuration in version control, clear routing rules
> - ✅ Pros: Works well for static service configuration
> - ❌ Cons: Requires manual updates when services change
> - **Decision**: ✅ CHOSEN - Best for initial deployment and learning
>
> **Option B: Docker Labels (Dynamic)**
> - ✅ Pros: Automatic service discovery, no manual config updates
> - ✅ Pros: Service-specific configuration in docker-compose.yml
> - ❌ Cons: More complex initial setup, harder to debug
> - ❌ Cons: Configuration scattered across compose files
> - **Decision**: Not chosen - Can migrate to this later if preferred
>
> **Option C: Nginx or Caddy**
> - ✅ Pros: Nginx is very mature and widely used
> - ✅ Pros: Caddy has automatic HTTPS
> - ❌ Cons: Traefik already familiar from Pangolin usage
> - ❌ Cons: Traefik has better Docker integration
> - **Decision**: Not chosen - Traefik consistency and Docker integration win

### Scope Definition

**✅ In Scope:**
- **Stack structure**: Create agnostic base template + VM-specific subdirectories (`stacks/traefik/vm-XXX/`)
- Deploy Traefik container on all VMs (100, 101, 102, 103) via Portainer Git integration
- Configure Traefik with file-based routing on each VM
- Set up Docker network for Traefik and services on each VM
- Create routing rules for all web-accessible services on each VM:
  - **VM 100**: Emby, Portainer
  - **VM 101**: Deluge, NZBGet, Portainer
  - **VM 102**: Radarr, Sonarr, Lidarr, Prowlarr, Jellyseerr, Flaresolverr, Huntarr, Portainer
  - **VM 103**: Vaultwarden, Paperless-NGX, Immich, Linkwarden, Navidrome, Audiobookshelf, MyBibliotheca, Homepage, Portainer
- Update all services to use Traefik network (keep direct ports as fallback)
- Test port-free access via DNS names for all services
- Document Traefik configuration, stack structure, and redeployment process
- Create comprehensive documentation for deploying to new VMs or redeploying existing ones

**❌ Explicitly Out of Scope:**
- TLS/HTTPS configuration (can add later)
- Docker label-based configuration (future enhancement)
- Traefik dashboard authentication (can add later)
- Services without web UIs (Watchtower, Newt, VPN containers)

**🎯 MVP (Minimum Viable)**:
Traefik running on all VMs, routing all web-accessible services successfully accessible via `service.local.infinity-node.com` without port numbers. DNS resolution working (from IN-034), reverse proxy routing working across entire infrastructure.

## Risk Assessment

### Potential Pitfalls

- ⚠️ **Risk 1: Port conflicts on VMs** → **Mitigation**: Check port 80/443 availability on each VM before deployment. Ensure no other service uses these ports. Traefik needs exclusive access to 80/443 on each VM. Start with VM 103 to validate, then check critical VMs.

- ⚠️ **Risk 2: Service routing misconfiguration** → **Mitigation**: Test with one service per VM first, validate routing works, then add others. Keep direct port access as fallback during migration. Use phased approach: VM 103 first, then critical VMs.

- ⚠️ **Risk 3: Docker network configuration issues** → **Mitigation**: Use Traefik's default Docker network or create explicit network per VM. Test connectivity between Traefik and backend containers. Validate network isolation between VMs.

- ⚠️ **Risk 4: Breaking critical service access (Emby, downloads, arr)** → **Mitigation**: Deploy Traefik alongside existing services, don't remove direct port access initially. Test thoroughly on VM 103 before touching critical VMs. Deploy during low-usage windows (3-6 AM) for critical VMs. Have immediate rollback ready.

- ⚠️ **Risk 5: Traefik configuration errors** → **Mitigation**: Start with minimal configuration, test incrementally. Review Traefik logs for errors. Validate on VM 103 before deploying to critical VMs. Have rollback plan ready for each VM.

- ⚠️ **Risk 6: VM 101 VPN network mode conflicts** → **Mitigation**: Download clients use `network_mode: service:vpn` which may conflict with Traefik network. Test carefully, may need special configuration or exclude from Traefik routing.

- ⚠️ **Risk 7: VM 100 Emby host network mode** → **Mitigation**: Emby runs in host network mode for performance. May need special Traefik configuration or keep direct access for Emby. Test carefully.

### Dependencies

**Prerequisites (must exist before starting):**
- [x] **IN-034 DNS setup complete** - PiHole DNS configured, DNS records created for all services (blocking: yes)
- [ ] **All VMs accessible** - Can SSH and deploy containers on VMs 100, 101, 102, 103 (blocking: yes)
- [ ] **Ports 80/443 available** - No conflicts on all VMs (blocking: yes)
- [ ] **Docker running on all VMs** - Container runtime available on all VMs (blocking: yes)
- [ ] **DNS records exist** - All service DNS records created in PiHole (from IN-034) (blocking: yes)

**No other blocking dependencies** - Can start once IN-034 DNS is complete and all VM ports verified.

### Critical Service Impact

**Services Affected**: All VMs including CRITICAL services

**Critical Services:**
- **VM 100 (Emby)**: CRITICAL - Primary media streaming, affects household users
- **VM 101 (Downloads)**: CRITICAL - Active downloads must not corrupt
- **VM 102 (arr services)**: CRITICAL - Media automation pipeline must stay active

**Why this is manageable:**
- **Phased approach**: Start with VM 103 (non-critical) to validate pattern
- **No downtime**: Traefik deployed alongside existing services, direct port access remains
- **Low-usage windows**: Deploy to critical VMs during 3-6 AM preferred
- **Immediate rollback**: Can revert changes quickly if issues arise
- **Thorough testing**: Validate on VM 103 before touching critical VMs
- **Backup plan**: All service configs backed up in git before changes

**Household impact**:
- **VM 103**: None (personal use services)
- **VM 100, 101, 102**: Potential brief interruption during deployment (30-60 seconds per VM), but direct port access remains available as fallback

### Rollback Plan

**Applicable for**: Docker/infrastructure change

**How to rollback if this goes wrong:**
1. **Per-VM rollback** (can rollback individual VMs):
   - Stop Traefik container: `docker stop traefik` (or via Portainer on that VM)
   - Remove Traefik stack from Portainer (if deployed via Git)
   - Revert service docker-compose.yml changes (remove Traefik network, restore direct ports)
   - Redeploy affected services via Portainer
   - Verify services accessible via direct IP:PORT
2. **Full infrastructure rollback** (if needed):
   - Repeat per-VM rollback for all VMs (start with critical VMs first)
   - Remove Traefik configuration files
   - Update DNS records if any were changed (unlikely)

**Recovery time estimate**:
- **Per VM**: 5-10 minutes
- **Full rollback**: 20-30 minutes (all 4 VMs)
- **Critical VM priority**: Rollback VM 100, 101, 102 first if issues arise

**Backup requirements:**
- Backup all service docker-compose.yml files before modifying (git handles this)
- Document current port mappings for all services on all VMs
- Screenshot or document current service access URLs
- Backup Traefik configuration files before changes

## Execution Plan

### Phase 0: Discovery & Preparation

**Primary Agent**: `docker`

- [ ] **Verify IN-034 DNS setup complete** `[agent:docker]` `[depends:IN-034]` `[blocking]`
  - Confirm DNS records exist for all services across all VMs
  - Test DNS resolution for sample services from each VM
  - Verify DNS returns correct IPs for each VM

- [ ] **Inventory all VMs services and ports** `[agent:docker]`
  - **VM 100**: Emby (8096), Portainer (9443)
  - **VM 101**: Deluge (8112), NZBGet (6789), Portainer (32768)
  - **VM 102**: Radarr (7878), Sonarr (8989), Lidarr (8686), Prowlarr (9696), Jellyseerr (5055), Flaresolverr (8191), Huntarr (TBD), Portainer (9443)
  - **VM 103**: Vaultwarden (8111), Paperless-NGX (TBD), Immich (TBD), Linkwarden (TBD), Navidrome (TBD), Audiobookshelf (TBD), MyBibliotheca (TBD), Homepage (3001), Portainer (9443)
  - Document all current port mappings
  - Note special network modes (Emby host mode, VM 101 VPN mode)

- [ ] **Check port availability on all VMs** `[agent:docker]` `[risk:1]` `[blocking]`
  - Verify ports 80 and 443 are available on each VM
  - Check for conflicts: `netstat -tuln | grep -E ':(80|443)'` on each VM
  - Document any existing services using these ports
  - Start with VM 103, then check critical VMs

- [ ] **Review Traefik documentation** `[agent:docker]`
  - Review Traefik file provider configuration
  - Understand routing rule syntax
  - Review Docker network configuration
  - Research host network mode compatibility (for Emby)
  - Research VPN network mode compatibility (for VM 101)

### Phase 1: Traefik Stack Structure Design & Base Template

**Primary Agent**: `docker`

- [ ] **Design multi-VM stack structure** `[agent:docker]`
  - **Structure**: `stacks/traefik/vm-XXX/` subdirectories for each VM
  - **Rationale**: Each VM needs its own Portainer stack pointing to its own compose file
  - **Base template**: Create `stacks/traefik/template/` with reusable base configs
  - **VM-specific**: Each `vm-XXX/` directory contains VM-specific compose and routing configs
  - **Documentation**: Clear README explaining structure and deployment process

- [ ] **Create base template directory** `[agent:docker]`
  - Create `stacks/traefik/template/` directory
  - Create `docker-compose.yml.template` - Base Traefik configuration (agnostic)
  - Create `traefik.yml.template` - Static configuration template
  - Create `dynamic.yml.template` - Routing rules template with placeholders
  - Create `README.md` - Documentation explaining structure, deployment, and customization

- [ ] **Design base docker-compose.yml template** `[agent:docker]`
  - Use official Traefik image: `traefik:v3.0`
  - Expose ports 80 and 443 (standard across all VMs)
  - Mount configuration files (VM-specific paths)
  - Mount Docker socket for service discovery
  - Set up restart policy
  - Configure Docker network (VM-specific network name)
  - Use environment variables for VM-specific values
  - Add extensive comments explaining each section

- [ ] **Create base configuration templates** `[agent:docker]`
  - `traefik.yml.template`: File provider, entrypoints, Docker provider, logging
  - `dynamic.yml.template`: Routing rules with placeholders for services
  - Include comments explaining how to customize for each VM
  - Document required vs optional configurations

- [ ] **Create deployment documentation** `[agent:docker]` `[agent:documentation]`
  - Document stack structure and rationale
  - Create deployment guide: How to deploy to new VM
  - Document Portainer Git integration setup per VM
  - Include troubleshooting section
  - Document redeployment process (automated/scripted/manual)

### Phase 2: VM 103 Deployment (Proof of Concept)

**Primary Agent**: `docker`

- [ ] **Create VM 103 Traefik stack** `[agent:docker]`
  - Create `stacks/traefik/vm-103/` directory
  - Copy base templates to VM 103 directory
  - Customize `docker-compose.yml` for VM 103 (network names, paths)
  - Create VM 103-specific `traefik.yml` from template
  - Create VM 103-specific `dynamic.yml` with routing rules for all services:
    - Vaultwarden, Paperless-NGX, Immich, Linkwarden, Navidrome, Audiobookshelf, MyBibliotheca, Homepage, Portainer
  - Create `README.md` documenting VM 103-specific configuration
  - Test configuration syntax: `docker compose -f stacks/traefik/vm-103/docker-compose.yml config`

- [ ] **Deploy Traefik on VM 103 via Portainer** `[agent:docker]` `[risk:5]`
  - Commit VM 103 stack files to git
  - Create Portainer stack pointing to `stacks/traefik/vm-103/docker-compose.yml`
  - Use `create-git-stack.sh` script OR Portainer UI:
    ```bash
    ./scripts/infrastructure/create-git-stack.sh \
      "portainer-api-token-vm-103" \
      "shared" \
      3 \
      "traefik" \
      "stacks/traefik/vm-103/docker-compose.yml"
    ```
  - Verify GitOps integration enabled (5-minute polling)
  - Monitor logs for errors: `docker logs traefik`
  - Verify Traefik starts successfully
  - Check Traefik dashboard (if enabled) accessible

- [ ] **Integrate VM 103 services with Traefik** `[agent:docker]` `[risk:4]`
  - Update all VM 103 service docker-compose.yml files to use Traefik network
  - Keep direct port mappings as fallback
  - Redeploy services via Portainer
  - Verify services still accessible via direct IP:PORT

- [ ] **Test VM 103 routing** `[agent:testing]` `[blocking]`
  - Test port-free access for all VM 103 services
  - Verify DNS resolution working
  - Test service functionality through Traefik
  - Document any issues or special configurations needed

### Phase 3: VM 100 Deployment (Critical - Emby)

**Primary Agent**: `docker`

- [ ] **Create VM 100 Traefik stack** `[agent:docker]` `[risk:7]`
  - Create `stacks/traefik/vm-100/` directory
  - Copy base templates to VM 100 directory
  - Customize `docker-compose.yml` for VM 100
  - Create VM 100-specific `dynamic.yml` with routing rules:
    - Emby, Portainer
  - **Special consideration**: Emby uses host network mode - document approach (may need special config or keep direct access)
  - Create `README.md` documenting VM 100-specific configuration and Emby host mode considerations
  - Test configuration syntax: `docker compose -f stacks/traefik/vm-100/docker-compose.yml config`

- [ ] **Deploy Traefik on VM 100 via Portainer** `[agent:docker]` `[risk:4]` `[risk:7]`
  - Deploy during low-usage window (3-6 AM preferred)
  - Commit VM 100 stack files to git
  - Create Portainer stack pointing to `stacks/traefik/vm-100/docker-compose.yml`
  - Use `create-git-stack.sh` script OR Portainer UI
  - Verify GitOps integration enabled
  - Monitor logs for errors
  - Verify Traefik starts successfully
  - Test Emby routing carefully (host network mode consideration)

- [ ] **Integrate VM 100 services with Traefik** `[agent:docker]` `[risk:4]`
  - Update Emby docker-compose.yml (if compatible with Traefik)
  - Update Portainer docker-compose.yml
  - Keep direct port mappings as fallback
  - Redeploy services via Portainer
  - Verify Emby still accessible and streaming works

- [ ] **Test VM 100 routing** `[agent:testing]` `[blocking]`
  - Test port-free access for Emby and Portainer
  - Verify Emby streaming functionality works through Traefik
  - Test during low-usage period
  - Document any issues

### Phase 4: VM 101 Deployment (Critical - Downloads)

**Primary Agent**: `docker`

- [ ] **Create VM 101 Traefik stack** `[agent:docker]` `[risk:6]`
  - Create `stacks/traefik/vm-101/` directory
  - Copy base templates to VM 101 directory
  - Customize `docker-compose.yml` for VM 101
  - Create VM 101-specific `dynamic.yml` with routing rules:
    - Deluge, NZBGet, Portainer
  - **Special consideration**: Download clients use `network_mode: service:vpn` - document approach (may need special config)
  - Create `README.md` documenting VM 101-specific configuration and VPN network mode considerations
  - Test configuration syntax: `docker compose -f stacks/traefik/vm-101/docker-compose.yml config`

- [ ] **Deploy Traefik on VM 101 via Portainer** `[agent:docker]` `[risk:4]` `[risk:6]`
  - Deploy during low-usage window (3-6 AM preferred)
  - Commit VM 101 stack files to git
  - Create Portainer stack pointing to `stacks/traefik/vm-101/docker-compose.yml`
  - Use `create-git-stack.sh` script OR Portainer UI
  - Verify GitOps integration enabled
  - Monitor logs for errors
  - Verify Traefik starts successfully
  - Test download client routing carefully (VPN network mode consideration)

- [ ] **Integrate VM 101 services with Traefik** `[agent:docker]` `[risk:4]` `[risk:6]`
  - Update Deluge docker-compose.yml (if compatible with Traefik)
  - Update NZBGet docker-compose.yml (if compatible)
  - Update Portainer docker-compose.yml
  - Keep direct port mappings as fallback
  - Redeploy services via Portainer
  - Verify download clients still functional

- [ ] **Test VM 101 routing** `[agent:testing]` `[blocking]`
  - Test port-free access for Deluge, NZBGet, Portainer
  - Verify download functionality works through Traefik
  - Test during low-usage period
  - Document any issues

### Phase 5: VM 102 Deployment (Critical - arr Services)

**Primary Agent**: `docker`

- [ ] **Create VM 102 Traefik stack** `[agent:docker]`
  - Create `stacks/traefik/vm-102/` directory
  - Copy base templates to VM 102 directory
  - Customize `docker-compose.yml` for VM 102
  - Create VM 102-specific `dynamic.yml` with routing rules for all arr services:
    - Radarr, Sonarr, Lidarr, Prowlarr, Jellyseerr, Flaresolverr, Huntarr, Portainer
  - Create `README.md` documenting VM 102-specific configuration
  - Test configuration syntax: `docker compose -f stacks/traefik/vm-102/docker-compose.yml config`

- [ ] **Deploy Traefik on VM 102 via Portainer** `[agent:docker]` `[risk:4]`
  - Deploy during low-usage window (3-6 AM preferred)
  - Commit VM 102 stack files to git
  - Create Portainer stack pointing to `stacks/traefik/vm-102/docker-compose.yml`
  - Use `create-git-stack.sh` script OR Portainer UI
  - Verify GitOps integration enabled
  - Monitor logs for errors
  - Verify Traefik starts successfully

- [ ] **Integrate VM 102 services with Traefik** `[agent:docker]` `[risk:4]`
  - Update all arr service docker-compose.yml files to use Traefik network
  - Keep direct port mappings as fallback
  - Redeploy services via Portainer
  - Verify services still accessible via direct IP:PORT

- [ ] **Test VM 102 routing** `[agent:testing]` `[blocking]`
  - Test port-free access for all arr services
  - Verify service functionality through Traefik
  - Test during low-usage period
  - Document any issues

### Phase 6: Comprehensive Testing & Validation

**Primary Agent**: `testing`

- [ ] **Test DNS resolution for all services** `[agent:testing]` `[blocking]`
  - Test DNS resolution for services on each VM
  - Verify DNS returns correct IPs for each VM
  - Sample tests: `dig emby.local.infinity-node.com`, `dig radarr.local.infinity-node.com`, etc.

- [ ] **Test port-free access for all services** `[agent:testing]` `[blocking]`
  - **VM 100**: Test Emby, Portainer via port-free URLs
  - **VM 101**: Test Deluge, NZBGet, Portainer via port-free URLs
  - **VM 102**: Test all arr services via port-free URLs
  - **VM 103**: Test all supporting services via port-free URLs
  - Verify services load correctly
  - Test login/functionality on each service
  - Test critical functionality (Emby streaming, download clients, arr automation)

- [ ] **Test Traefik routing across all VMs** `[agent:testing]`
  - Check Traefik logs on each VM for routing activity
  - Verify requests appear in Traefik access logs
  - Test with different browsers/devices if possible
  - Verify no cross-VM routing issues

- [ ] **Test fallback access** `[agent:testing]`
  - Verify all services still accessible via direct IP:PORT
  - Confirm both methods work (Traefik and direct) for all services
  - Test critical services (Emby, downloads, arr) via both methods

- [ ] **Test error handling** `[agent:testing]`
  - Stop one backend service on each VM
  - Verify Traefik returns appropriate error
  - Restart service and verify recovery
  - Test on non-critical VM first, then critical VMs

- [ ] **Test critical service functionality** `[agent:testing]` `[blocking]`
  - **Emby**: Stream media, verify transcoding works
  - **Downloads**: Start download, verify VPN still routing correctly
  - **arr services**: Trigger search, verify automation pipeline works
  - Test during low-usage periods

### Phase 7: Documentation

**Primary Agent**: `documentation`

- [ ] **Document Traefik stack structure** `[agent:documentation]`
  - Create `stacks/traefik/README.md` explaining:
    - Multi-VM structure (`vm-XXX/` subdirectories)
    - Base template location and purpose
    - How to customize for new VM
    - Portainer Git integration setup per VM
    - Redeployment process (automated/scripted/manual)
  - Document routing configuration approach
  - Explain VM-specific considerations (host mode, VPN mode)
  - Explain how to add new services to existing VM
  - Include troubleshooting section
  - Document per-VM deployment process

- [ ] **Create deployment automation/scripting** `[agent:docker]` `[optional]`
  - **Option A (Automated)**: Create script to generate VM-specific stack from template
    - `scripts/infrastructure/create-traefik-vm-stack.sh <vm-id>`
    - Generates `stacks/traefik/vm-XXX/` from template
    - Prompts for VM-specific services and ports
    - Validates configuration
  - **Option B (Scripted)**: Document manual process with clear steps
  - **Option C (Documented)**: Comprehensive README with step-by-step guide
  - **Decision**: Start with Option C (documented), add scripting if needed

- [ ] **Update ARCHITECTURE.md** `[agent:documentation]`
  - Add Traefik to all VM services lists (100, 101, 102, 103)
  - Document reverse proxy architecture across all VMs
  - Update network diagram to show Traefik on each VM
  - Note port-free access capability for all services
  - Document special configurations (Emby host mode, VM 101 VPN mode)

- [ ] **Update service READMEs** `[agent:documentation]`
  - Update all service READMEs with Traefik access URLs
  - Note both Traefik and direct access methods
  - Document which services are routed through Traefik
  - Update access URLs in service documentation

- [ ] **Create runbook for Traefik management** `[agent:documentation]`
  - Document process for adding new services to Traefik
  - Include routing rule examples for each VM
  - Document common configuration patterns
  - Document troubleshooting steps per VM
  - Include rollback procedures

## Acceptance Criteria

**Done when all of these are true:**
- [ ] Traefik stack structure created: base template + VM-specific subdirectories
- [ ] Traefik deployed and running on all VMs (100, 101, 102, 103) via Portainer Git integration
- [ ] Traefik accessible on ports 80 and 443 on all VMs
- [ ] Traefik configuration files created and documented (reusable template + VM-specific configs)
- [ ] Each VM has its own Portainer stack pointing to `stacks/traefik/vm-XXX/docker-compose.yml`
- [ ] GitOps integration enabled for all Traefik stacks (5-minute polling)
- [ ] Routing rules configured for all web-accessible services on all VMs
- [ ] All services updated to use Traefik network (where compatible)
- [ ] All services accessible via port-free DNS names (e.g., `http://emby.local.infinity-node.com`, `http://radarr.local.infinity-node.com`)
- [ ] All services still accessible via direct IP:PORT (fallback)
- [ ] DNS resolution working for all services (from IN-034)
- [ ] All services functional through Traefik routing
- [ ] Critical services (Emby, downloads, arr) tested and working through Traefik
- [ ] Traefik stack structure documented in `stacks/traefik/README.md`
- [ ] Redeployment process documented (how to redeploy to existing VM or deploy to new VM)
- [ ] ARCHITECTURE.md updated with Traefik details for all VMs
- [ ] Service READMEs updated with Traefik access URLs
- [ ] Special configurations documented (host mode, VPN mode considerations)
- [ ] All execution plan items completed
- [ ] Testing Agent validates all tests pass (see testing plan below)
- [ ] Changes committed with descriptive message (awaiting user approval)

## Testing Plan

**[[docs/agents/TESTING|Testing Agent]] validates:**
- Traefik container running and healthy
- Traefik accessible on ports 80 and 443
- DNS resolution working for routed services
- Port-free access working for all configured services
- Services functional through Traefik (login, browse, etc.)
- Fallback direct access still works
- Traefik logs show routing activity
- No errors in Traefik or service logs

**Manual validation:**
1. **DNS resolution test** - From local machine:
   ```bash
   # VM 100
   dig emby.local.infinity-node.com  # Should return 192.168.86.172

   # VM 101
   dig deluge.local.infinity-node.com  # Should return 192.168.86.173

   # VM 102
   dig radarr.local.infinity-node.com  # Should return 192.168.86.174
   dig sonarr.local.infinity-node.com  # Should return 192.168.86.174

   # VM 103
   dig audiobookshelf.local.infinity-node.com  # Should return 192.168.86.249
   # Test all services...
   ```

2. **Port-free access test** - In browser (test all services):
   ```bash
   # VM 100
   http://emby.local.infinity-node.com
   http://portainer-100.local.infinity-node.com

   # VM 101
   http://deluge.local.infinity-node.com
   http://nzbget.local.infinity-node.com

   # VM 102
   http://radarr.local.infinity-node.com
   http://sonarr.local.infinity-node.com
   # ... all arr services

   # VM 103
   http://audiobookshelf.local.infinity-node.com
   # ... all supporting services
   # Expected: All services load correctly
   ```

3. **Critical service functionality test**:
   ```bash
   # Emby: Stream media, verify transcoding
   # Downloads: Start download, verify VPN routing
   # arr services: Trigger search, verify automation
   # Expected: All critical functionality works normally
   ```

4. **Fallback access test** (all services):
   ```bash
   # Verify direct IP:PORT still works for all services
   # Expected: Still works as fallback
   ```

5. **Traefik logs test** (all VMs):
   ```bash
   # On each VM:
   docker logs traefik
   # Expected: Shows routing activity, no errors
   ```

## Related Documentation

- [[docs/ARCHITECTURE|Architecture]] - Infrastructure topology (update with Traefik)
- [[docs/agents/DOCKER|Docker Agent]] - Agent handling this work
- [[docs/agents/TESTING|Testing Agent]] - For validation
- [[tasks/backlog/IN-034-configure-pihole-local-dns|IN-034]] - DNS setup prerequisite
- [[stacks/traefik/README|Traefik Stack]] - Service documentation (to be created)

## Notes

**Priority Rationale:**
Priority 3 (medium) because:
- Complements IN-034 DNS setup for complete solution
- Improves user experience with port-free URLs
- Non-critical services (VM 103) - safe to experiment
- Enables future service management improvements
- Not urgent - current port-based access works fine

Not priority 0-2 (critical/high) because:
- Current port-based access works adequately
- Only affects VM 103 non-critical services
- Not blocking other work
- Can be done when convenient

**Complexity Rationale:**
Complex because:
- Deploying across 4 VMs with different service configurations
- Critical services require extra care and testing
- Special network modes (host mode, VPN mode) need careful handling
- Phased approach across multiple VMs increases coordination
- Testing required for all services across all VMs
- Rollback procedures needed per VM
- Documentation needed for all VMs
- Estimated 8-12 hours for complete deployment and validation

Not moderate because involves critical services and multiple VMs.
Not simple because requires careful coordination and testing across entire infrastructure.

**Implementation Notes:**
- **Traefik version**: Use Traefik v3.0 (latest stable)
- **Configuration approach**: Start with file provider, can migrate to Docker labels later
- **Ports**: Traefik needs exclusive access to 80/443 on each VM
- **Docker network**: Use Traefik's network or create shared network per VM
- **Service ports**: Backend services keep their internal ports, Traefik routes to them
- **Phased deployment**: Start with VM 103 (non-critical), validate, then deploy to critical VMs
- **Fallback**: Keep direct port access during migration for safety
- **Special considerations**:
  - **VM 100 Emby**: Host network mode - may need special Traefik config or keep direct access
  - **VM 101 Downloads**: VPN network mode - may need special Traefik config or exclude from routing
  - **VM 102 arr services**: Standard bridge network - should work normally
  - **VM 103 services**: Standard bridge network - should work normally
- **Deployment timing**: Critical VMs (100, 101, 102) during low-usage windows (3-6 AM preferred)

**Follow-up Tasks:**
- Add TLS/HTTPS configuration to Traefik (all VMs)
- Consider Docker label-based configuration for easier management
- Add Traefik dashboard authentication
- Monitor Traefik performance and optimize if needed

---

> [!note]- 📋 Work Log
>
> **Work log entries will be added here as task progresses**

> [!tip]- 💡 Lessons Learned
>
> *Fill this in AS YOU GO during task execution. Not every task needs extensive notes here, but capture important learnings that could affect future work.*
>
> **What Worked Well:**
> - [Patterns/approaches that were successful]
>
> **What Could Be Better:**
> - [What would we do differently next time]
>
> **Key Discoveries:**
> - [Insights affecting other systems]
>
> **Scope Evolution:**
> - [How scope changed from original plan]
>
> **Follow-Up Needed:**
> - [Documentation updates needed]
> - [New tasks to create]
