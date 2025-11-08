---
type: task
task-id: IN-034
status: pending
priority: 2
category: infrastructure
agent: infrastructure
created: 2025-11-01
updated: 2025-11-01
started:
completed:

# Task classification
complexity: moderate
estimated_duration: 3-5h
critical_services_affected: false
requires_backup: true
requires_downtime: false

# Design tracking
alternatives_considered: true
risk_assessment_done: true
phased_approach: true

tags:
  - task
  - infrastructure
  - networking
  - dns
  - pihole
  - service-discovery
---

# Task: IN-034 - Configure Pi-hole for Local DNS Service Discovery

> **Quick Summary**: ✅ Pi-hole already online at 192.168.86.158. Configure router to use it for DNS, set up local domain records, and migrate audiobookshelf as proof-of-concept for DNS-based service discovery.

## Problem Statement

**What problem are we solving?**
The infinity-node infrastructure currently relies on hardcoded IP addresses throughout the system - in Bitwarden CLI configuration, docker-compose files, automation scripts, and documentation. This creates significant fragility:

1. **IP changes break everything** - When moving locations or reconfiguring the network, every hardcoded IP reference must be manually updated across dozens of files
2. **Configuration scattered everywhere** - IP addresses exist in multiple places with no central management
3. **Documentation becomes stale** - Docs quickly fall out of sync when IPs change
4. **High error risk** - Easy to miss updating an IP reference, causing mysterious automation failures

**Example problem:**
```bash
# Current: Bitwarden CLI with hardcoded IP
bw config server http://192.168.86.249:8111

# When IP changes → CLI breaks, secrets retrieval fails, deployments fail
# Must manually update CLI config, scripts, compose files, docs...
```

**What we need:**
A local DNS server (Pi-hole) providing name-based service discovery. Services access each other via DNS names like `vaultwarden.local.infinity-node.com` instead of IPs. When IPs change, update DNS once and everything continues working.

**Why now?**
- **Enables future mobility** - Planning ahead for potential network moves
- **Improves automation reliability** - Reduces failure points in scripts and deployments
- **Quick win available** - Pi-hole already exists, just needs configuration
- **Blocks other work** - Need DNS before migrating more services to automated secret management

**Who benefits?**
- **System administrator (Evan)**: Dramatically reduced maintenance when IPs change, more reliable automation
- **AI agents**: Can use stable DNS names in generated configs without worrying about IP changes
- **Future self**: When moving locations, update DNS instead of hunting down hardcoded IPs

## Solution Design

### Recommended Approach

**Single-phase end-to-end setup** - Power on existing Pi-hole Raspberry Pi, configure network to use it, set up local DNS domain with records for all services, and migrate one low-priority service (audiobookshelf) as proof-of-concept.

**Key components:**
- **Pi-hole Raspberry Pi**: Existing hardware, currently powered off - needs to be brought online and configured
- **Router DNS configuration**: Point network DNS to Pi-hole (with public DNS failover)
- **Local domain**: `local.infinity-node.com` for all infinity-node services
- **DNS records**: A records for all VMs, service-specific records for each container
- **Proof-of-concept migration**: Audiobookshelf (non-critical) updated to use DNS names

**Rationale**: Since Pi-hole hardware already exists and has been used before, completing setup end-to-end in one task provides immediate validation and value. Splitting into smaller tasks would add overhead without reducing risk significantly.

> [!abstract]- 🔀 Alternative Approaches Considered
>
> **Option A: Single-Phase "Get It Working" Approach** ✅ CHOSEN
> - ✅ Pros: Complete end-to-end validation, immediate usefulness, atomic completion
> - ✅ Pros: All related work contextually grouped together
> - ❌ Cons: Slightly larger scope (but manageable)
> - **Decision**: ✅ CHOSEN - Best balance of risk and value delivery
>
> **Option B: Two-Phase "Infrastructure First" Approach**
> - ✅ Pros: Smaller focused tasks, easier to isolate issues
> - ❌ Cons: Task 1 has no real validation, overhead of two tasks
> - ❌ Cons: DNS not actually useful until Task 2 completes
> - **Decision**: Not chosen - Too conservative for moderate complexity with existing hardware
>
> **Option C: "Discovery First" Approach**
> - ✅ Pros: Handles unknown unknowns about Pi-hole state
> - ❌ Cons: Adds extra task for minimal benefit, slows progress
> - **Decision**: Not chosen - Too cautious, likely remember setup well enough

### Scope Definition

**✅ In Scope:**
- ✅ Power on Raspberry Pi and identify its IP address on network (COMPLETE: 192.168.86.158)
- Access Pi-hole web UI and verify it's functional (web UI accessible, needs login verification)
- Configure static IP reservation for Pi-hole in router DHCP
- Configure router to use Pi-hole as primary DNS (with public DNS as secondary failover)
- Set up local domain `local.infinity-node.com` in Pi-hole
- Create DNS A records for all 4 VMs (100, 101, 102, 103)
- Create DNS records for key services (audiobookshelf, vaultwarden, emby, portainer, *arr services)
- Update audiobookshelf docker-compose.yml to use DNS names
- Redeploy audiobookshelf via Portainer with new configuration
- Test audiobookshelf accessible via DNS name
- Document DNS configuration and service migration process

**❌ Explicitly Out of Scope:**
- Migrating any services beyond audiobookshelf (that's IN-035 for broader migration)
- Setting up secondary/redundant DNS server (deferred, may not be needed)
- Configuring DNSSEC or advanced security features (overkill for home lab)
- Setting up Pi-hole ad-blocking features (can configure separately later)
- Updating Bitwarden CLI to use DNS (part of broader IN-035 migration)
- Migrating critical services like Emby (de-risked by starting with non-critical)

**🎯 MVP (Minimum Viable)**:
Audiobookshelf successfully accessible via `audiobookshelf.local.infinity-node.com` instead of hardcoded IP address, with router using Pi-hole for DNS resolution and public DNS as failover. DNS records exist for all VMs and services (even if not actively used yet).

## Risk Assessment

### Potential Pitfalls

- ⚠️ **Risk 1: Pi-hole hardware failure (Pi won't boot)** → **Mitigation**: Test Pi-hole boots and UI accessible before proceeding with router changes. If hardware dead, pivot to VM-based Pi-hole deployment or dnsmasq container.

- ⚠️ **Risk 2: Router DNS configuration causes network outage** → **Mitigation**: Keep backup DNS server configured (8.8.8.8 as secondary). Have physical access to router for immediate rollback. Test DNS resolution before proceeding.

- ⚠️ **Risk 3: DNS records misconfigured breaking service access** → **Mitigation**: Test with non-critical service first (audiobookshelf). Keep IP address access as fallback during migration. Can always revert docker-compose to IPs.

- ⚠️ **Risk 4: Pi-hole IP address changes after DHCP lease expires** → **Mitigation**: Configure static IP reservation in router DHCP settings for Pi-hole's MAC address immediately after identifying it.

- ⚠️ **Risk 5: Pi-hole stops responding, breaks all DNS resolution** → **Mitigation**: Configure router with secondary public DNS (Google 8.8.8.8 or Cloudflare 1.1.1.1) as automatic failover. Network stays functional even if Pi-hole dies.

### Dependencies

**Prerequisites (must exist before starting):**
- [x] **Raspberry Pi with Pi-hole installed** - ✅ Already online and accessible (192.168.86.158)
- [ ] **Router admin access** - Can configure DNS and DHCP settings (blocking: yes)
- [x] **Network access to identify Pi-hole IP** - ✅ IP identified: 192.168.86.158 (raspberrypi.lan)

**No other blocking dependencies** - ✅ Pi-hole is online and IP identified. Can proceed with router configuration and DNS setup.

### Critical Service Impact

**Services Affected**: None (audiobookshelf is non-critical)

**Why this is safe:**
- Audiobookshelf explicitly chosen as low-priority, non-critical service
- Critical services (Emby, downloads, *arr stack) not touched in this task
- Router configured with fallback DNS, so network stays functional if Pi-hole fails
- Can rollback router DNS settings and audiobookshelf config in under 10 minutes
- No downtime required - services continue running during migration

**Household impact**: Minimal to none. Audiobookshelf users might experience brief interruption during stack redeploy (30 seconds), but service is not heavily used.

### Rollback Plan

**Applicable for**: Infrastructure change (network/DNS configuration)

**How to rollback if this goes wrong:**
1. Access router admin interface (have credentials ready)
2. Change DNS settings back to original configuration (document before changing)
3. Save router settings and wait for DHCP clients to refresh (~5 minutes)
4. Revert audiobookshelf docker-compose.yml to use IP address
5. Commit reversion to git
6. Redeploy audiobookshelf stack via Portainer (pull and redeploy)
7. Verify audiobookshelf accessible via IP
8. Power off Pi-hole if causing issues

**Recovery time estimate**: 5-10 minutes for complete rollback

**Backup requirements:**
- Screenshot/document current router DNS configuration before making changes
- Backup audiobookshelf docker-compose.yml before editing (git handles this)
- Document Pi-hole's IP and MAC address for future reference
- Note Pi-hole admin credentials in Vaultwarden

## Execution Plan

### Phase 0: Pre-flight Checks

**Primary Agent**: `infrastructure`

- [x] **Power on Raspberry Pi with Pi-hole** `[agent:infrastructure]` ✅ **COMPLETE**
  - ✅ Pi-hole is already online and accessible on the network
  - ✅ Documented in ARCHITECTURE.md (2025-01-XX)

- [x] **Identify Pi-hole IP address** `[agent:infrastructure]` ✅ **COMPLETE**
  - ✅ IP address identified: **192.168.86.158**
  - ✅ Hostname: raspberrypi.lan
  - ✅ MAC address: dc:a6:32:27:bf:eb (Raspberry Pi Foundation)
  - ✅ Verified via network scan and ARP table
  - ✅ Documented in ARCHITECTURE.md

- [ ] **Verify Pi-hole web UI accessible** `[agent:infrastructure]` `[blocking]`
  - Access `http://192.168.86.158/admin` in browser
  - ✅ Web interface confirmed accessible (redirects to /admin/login)
  - ✅ DNS service verified working (port 53 responding)
  - ✅ Ports 80 (HTTP) and 443 (HTTPS) confirmed open
  - Locate admin password (check Vaultwarden or Pi-hole docs)
  - Verify can login successfully
  - Check Pi-hole version and status dashboard

### Phase 1: Infrastructure Configuration

**Primary Agent**: `infrastructure`

- [ ] **Configure static IP reservation for Pi-hole** `[agent:infrastructure]` `[risk:4]`
  - ✅ Pi-hole's current IP address: **192.168.86.158** (already documented)
  - ✅ Pi-hole's MAC address: **dc:a6:32:27:bf:eb** (already documented)
  - Add DHCP reservation in router for this MAC → IP mapping
  - ✅ Static IP already documented in ARCHITECTURE.md

- [ ] **Backup current router DNS configuration** `[agent:infrastructure]`
  - Screenshot current DNS settings page
  - Document current DNS servers (ISP or public DNS)
  - Save configuration for potential rollback

- [ ] **Configure router to use Pi-hole as primary DNS** `[agent:infrastructure]` `[risk:2]`
  - Set primary DNS server to Pi-hole's static IP
  - Set secondary DNS to 8.8.8.8 or 1.1.1.1 (failover protection)
  - Save router configuration
  - Wait for change to propagate (~1 minute)

- [ ] **Test DNS resolution from local machine** `[agent:infrastructure]` `[blocking]`
  - Clear local DNS cache: `sudo dscacheutil -flushcache` (macOS)
  - Test public domain resolution: `dig google.com`
  - Verify DNS queries appear in Pi-hole dashboard (proves queries going through Pi-hole)
  - Test that internet browsing still works normally

### Phase 2: DNS Records Configuration

**Primary Agent**: `infrastructure`

- [ ] **Configure local domain in Pi-hole** `[agent:infrastructure]`
  - Access Pi-hole admin → Local DNS → DNS Records
  - Set up to respond to `local.infinity-node.com` domain
  - Configure Pi-hole to be authoritative for local domain

- [ ] **Create DNS A records for VMs** `[agent:infrastructure]`
  - `vm-100.local.infinity-node.com` → 192.168.86.172 (emby)
  - `vm-101.local.infinity-node.com` → 192.168.86.173 (downloads)
  - `vm-102.local.infinity-node.com` → 192.168.86.174 (arr)
  - `vm-103.local.infinity-node.com` → 192.168.86.249 (misc)

- [ ] **Create DNS records for services** `[agent:infrastructure]`
  - `audiobookshelf.local.infinity-node.com` → 192.168.86.249 (VM 103)
  - `vaultwarden.local.infinity-node.com` → 192.168.86.249:8111 (VM 103)
  - `emby.local.infinity-node.com` → 192.168.86.172:8096 (VM 100)
  - `portainer-100.local.infinity-node.com` → 192.168.86.172:9000 (VM 100 portainer)
  - `portainer-101.local.infinity-node.com` → 192.168.86.173:9000 (VM 101 portainer)
  - `portainer-102.local.infinity-node.com` → 192.168.86.174:9000 (VM 102 portainer)
  - `portainer-103.local.infinity-node.com` → 192.168.86.249:9000 (VM 103 portainer)
  - `radarr.local.infinity-node.com` → 192.168.86.174:7878 (VM 102)
  - `sonarr.local.infinity-node.com` → 192.168.86.174:8989 (VM 102)
  - `prowlarr.local.infinity-node.com` → 192.168.86.174:9696 (VM 102)
  - `lidarr.local.infinity-node.com` → 192.168.86.174:8686 (VM 102)
  - Add others as discovered during setup
  - Note: Pi-hole DNS only resolves hostnames, not ports - document ports in comments

- [ ] **Test DNS resolution for new records** `[agent:infrastructure]` `[blocking]`
  - `dig vm-100.local.infinity-node.com` - should return 192.168.86.172
  - `dig audiobookshelf.local.infinity-node.com` - should return 192.168.86.249
  - `dig vaultwarden.local.infinity-node.com` - should return 192.168.86.249
  - Verify correct IP addresses returned for each
  - Test from multiple devices if possible (laptop, phone)

### Phase 3: Service Migration (Audiobookshelf)

**Primary Agent**: `docker`

- [ ] **Review audiobookshelf docker-compose.yml** `[agent:docker]`
  - Read current configuration: `stacks/audiobookshelf/docker-compose.yml`
  - Identify any hardcoded IP addresses in environment variables or configs
  - Plan replacements with DNS names

- [ ] **Update audiobookshelf docker-compose.yml** `[agent:docker]`
  - Replace any hardcoded IPs with DNS names (if present)
  - Add comment documenting DNS migration
  - Stage changes: `git add stacks/audiobookshelf/docker-compose.yml`
  - Do NOT commit yet (commits at end only)

- [ ] **Redeploy audiobookshelf via Portainer** `[agent:docker]` `[risk:3]`
  - Access Portainer on VM 103
  - Navigate to audiobookshelf stack
  - Use "Pull and redeploy" to get updated config from git
  - Monitor deployment logs for errors
  - Verify container starts successfully

### Phase 4: Validation & Testing

**Primary Agent**: `testing`

- [ ] **Test audiobookshelf accessible via DNS name** `[agent:testing]` `[blocking]`
  - Access `http://audiobookshelf.local.infinity-node.com:PORT` in browser
  - Verify service loads correctly
  - Test login functionality
  - Browse library to confirm backend connectivity works
  - Check browser uses DNS (not falling back to cached IP)

- [ ] **Verify Pi-hole DNS queries in dashboard** `[agent:testing]`
  - Access Pi-hole admin dashboard
  - Check query log shows DNS queries for local.infinity-node.com domain
  - Verify local domain queries being answered by Pi-hole (not forwarded)
  - Check for any DNS resolution errors or failed queries

- [ ] **Test DNS failover scenario** `[agent:testing]`
  - Power off or disconnect Pi-hole temporarily
  - Verify public DNS still resolves (google.com, github.com, etc.)
  - Confirm internet browsing continues working (via secondary DNS)
  - Power Pi-hole back on
  - Verify local DNS resolution resumes

- [ ] **Test from multiple network clients** `[agent:testing]` `[optional]`
  - Test DNS resolution from laptop
  - Test from phone (if on same WiFi)
  - Verify all clients receiving Pi-hole as DNS from DHCP

### Phase 5: Documentation

**Primary Agent**: `documentation`

- [ ] **Create DNS documentation** `[agent:documentation]`
  - Create `docs/DNS.md` or `docs/runbooks/pihole-dns-management.md`
  - Document Pi-hole IP address, admin credentials location
  - Document local domain structure (`local.infinity-node.com`)
  - List all DNS records created
  - Explain how to add new DNS records (with screenshots if helpful)
  - Document DNS naming convention for services

- [ ] **Update ARCHITECTURE.md** `[agent:documentation]`
  - Add Pi-hole to infrastructure topology
  - Document DNS resolution flow
  - Note Pi-hole as critical infrastructure component

- [ ] **Document service migration process** `[agent:documentation]`
  - Create procedure for migrating services from IPs to DNS names
  - Include steps: update compose, commit, redeploy, test
  - Reference this for IN-035 (broader migration task)

- [ ] **Update audiobookshelf README** `[agent:documentation]`
  - Update `stacks/audiobookshelf/README.md`
  - Note service accessible via DNS name
  - Reference DNS documentation

## Acceptance Criteria

**Done when all of these are true:**
- [x] Pi-hole Raspberry Pi powered on, accessible, and running current version ✅ **COMPLETE** (192.168.86.158)
- [ ] Pi-hole has static IP reservation in router DHCP
- [ ] Router configured with Pi-hole as primary DNS, public DNS as secondary
- [ ] Local domain `local.infinity-node.com` configured and responding in Pi-hole
- [ ] DNS A records created for all 4 VMs (100, 101, 102, 103)
- [ ] DNS records created for key services (audiobookshelf, vaultwarden, emby, portainer, *arr)
- [ ] DNS resolution tested and working for all created records
- [ ] Audiobookshelf docker-compose.yml updated to use DNS names (if applicable)
- [ ] Audiobookshelf redeployed via Portainer and functioning correctly
- [ ] Audiobookshelf accessible via `audiobookshelf.local.infinity-node.com:PORT`
- [ ] DNS failover tested (public DNS works when Pi-hole down)
- [ ] DNS documentation created (DNS.md or runbook)
- [ ] ARCHITECTURE.md updated with Pi-hole topology
- [ ] Service migration process documented for future tasks
- [ ] All execution plan items completed
- [ ] Testing Agent validates all tests pass (see testing plan below)
- [ ] Changes committed with descriptive message (awaiting user approval)

## Testing Plan

**[[docs/agents/TESTING|Testing Agent]] validates:**
- Pi-hole web UI accessible and showing active status
- DNS queries appearing in Pi-hole dashboard
- All VM DNS records resolve to correct IPs
- Service DNS records resolve to correct IPs
- Audiobookshelf accessible via DNS name with full functionality
- Public DNS resolution works (google.com, github.com)
- DNS failover functions correctly (secondary DNS takes over when Pi-hole down)

**Manual validation:**
1. **DNS resolution test** - From local machine, run:
   ```bash
   dig vm-100.local.infinity-node.com
   dig audiobookshelf.local.infinity-node.com
   dig vaultwarden.local.infinity-node.com
   # Expected: All return correct IP addresses
   ```

2. **Service access test** - Access audiobookshelf:
   ```bash
   # In browser: http://audiobookshelf.local.infinity-node.com:PORT
   # Expected: Service loads, can login, browse library
   ```

3. **Pi-hole dashboard test** - Access Pi-hole admin:
   ```bash
   # In browser: http://<pi-ip>/admin
   # Expected: Dashboard shows queries, all systems operational
   ```

4. **Failover test** - Test DNS redundancy:
   ```bash
   # Power off Pi-hole temporarily
   # Test: curl https://google.com
   # Expected: Works via secondary DNS
   # Power Pi-hole back on
   # Test: dig audiobookshelf.local.infinity-node.com
   # Expected: Resolves via Pi-hole again
   ```

5. **Integration test** - Test audiobookshelf end-to-end:
   ```bash
   # Access service via DNS name
   # Login with credentials
   # Browse media library
   # Start playing audiobook
   # Expected: All functionality works normally
   ```

## Related Documentation

- [[docs/ARCHITECTURE|Architecture]] - Infrastructure topology (update with Pi-hole)
- [[docs/agents/INFRASTRUCTURE|Infrastructure Agent]] - Agent handling this work
- [[docs/agents/DOCKER|Docker Agent]] - For service migration steps
- [[docs/agents/TESTING|Testing Agent]] - For validation
- [[tasks/backlog/IN-012-setup-local-dns-service-discovery|Original IN-012 task]] - Superseded by this task
- [[tasks/backlog/IN-035-migrate-services-to-dns|Follow-up IN-035]] - Broader service migration

## Notes

**Priority Rationale:**
Priority 2 (high) because:
- Enables future mobility - critical when moving locations or reconfiguring network
- Improves automation reliability significantly by eliminating hardcoded IPs
- Blocks other infrastructure work that depends on stable service discovery
- Quick win with existing hardware (Pi-hole already installed)
- High value-to-effort ratio (3-5 hours for major infrastructure improvement)
- Should be completed before any network changes or location moves

Not priority 0-1 (critical) because:
- Current IP-based setup works fine if we're not moving
- Not addressing active outage or security issue
- Can continue with hardcoded IPs short-term if needed

**Complexity Rationale:**
Moderate complexity because:
- Pi-hole hardware already exists (reduces unknowns)
- Previous experience with setup (not completely new)
- Some discovery needed (current Pi-hole state, router configuration)
- Coordination across multiple systems (Pi, router, docker stacks)
- Testing and validation required
- Documentation and process creation needed

Not simple because involves network-level changes affecting all devices.
Not complex because not building from scratch, no major unknowns expected.

**Implementation Notes:**
- **Pi-hole ports**: Pi-hole DNS runs on port 53 (TCP/UDP), web UI on port 80
- **DNS records**: Pi-hole only resolves hostnames, not ports - ports specified in application configs
- **MAC address**: Critical to document MAC for static IP reservation
- **Naming convention**: Use pattern `<service>.local.infinity-node.com` for consistency
- **Router specifics**: Router model/interface may vary - document specific steps during work
- **DHCP propagation**: DNS changes may take time to propagate to all network clients (up to DHCP lease time)

**Follow-up Tasks:**
- IN-035: Migrate remaining services to DNS names (Bitwarden CLI, other stacks, scripts)
- Future: Consider secondary Pi-hole for high availability (very optional)
- Future: Explore Pi-hole ad-blocking features (separate from DNS setup)

---

> [!note]- 📋 Work Log
>
> **2025-01-XX - Initial Discovery**
> - ✅ Pi-hole discovered on network at 192.168.86.158 (raspberrypi.lan)
> - ✅ Verified web interface accessible (ports 80, 443) and DNS service (port 53) responding
> - ✅ MAC address identified: dc:a6:32:27:bf:eb (Raspberry Pi Foundation)
> - ✅ Documentation added to ARCHITECTURE.md with complete Pi-hole details
> - ✅ Infrastructure Agent documentation updated with DNS information
> - **Status**: Phase 0 partially complete - Pi-hole online and IP identified, ready to proceed with router configuration

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
