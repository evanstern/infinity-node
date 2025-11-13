---
type: task
task-id: IN-045
status: archived
priority: 2
category: infrastructure
agent: infrastructure
created: 2025-01-15
updated: 2025-01-15

# Task classification
complexity: complex
estimated_duration: 12-16h
critical_services_affected: true
requires_backup: true
requires_downtime: false

# Design tracking
alternatives_considered: true
risk_assessment_done: true
phased_approach: true

tags:
  - task
  - emby
  - security
  - port-forwarding
  - infrastructure
  - external-access
---

# Task: IN-045 - Setup Emby External Access Test VM

> **Quick Summary**: Create a new test VM for Emby with port forwarding, security measures (fail2ban, HTTPS, firewall), and DDNS configuration. Test Emby Connect and TV app compatibility. Once validated, migrate from VM 100 to the new VM.

## Problem Statement

**What problem are we solving?**
Current Emby setup (VM 100) uses Pangolin tunnel for external access, but Pangolin's authentication layer blocks Emby Connect and TV apps (Roku, Apple TV, Firestick) which cannot handle browser-based redirects. We need direct external access via port forwarding to enable Emby Connect and TV app compatibility, but this requires comprehensive security measures to protect the network and NAS.

**Why now?**
- TV apps cannot connect through Pangolin authentication
- Emby Connect cannot verify server through Pangolin
- Need secure external access solution
- Want to test in isolation before affecting production Emby

**Who benefits?**
- **Household users**: Can use Emby on TV apps (Roku, Apple TV, Firestick) from anywhere
- **System owner**: Secure external access with proper security measures
- **Future maintenance**: Documented process for router changes and migrations

## Solution Design

### Recommended Approach

Create a new test VM (VM 105 or next available) specifically for testing Emby with port forwarding and security measures. This allows us to:

1. **Test in isolation** - No impact on current production Emby (VM 100)
2. **Validate security** - Test fail2ban, HTTPS, firewall before production
3. **Test compatibility** - Verify Emby Connect and TV apps work
4. **Document process** - Create runbooks for future router changes
5. **Smooth migration** - Once validated, swap over with minimal downtime

**Key components:**
- **New VM**: Debian-based VM with Emby stack
- **Security stack**: fail2ban, UFW firewall, HTTPS/TLS
- **Network config**: Port forwarding, DDNS, DNS records
- **Monitoring**: Log monitoring, fail2ban status, access auditing
- **Documentation**: Runbooks, quick reference, migration guide

**Rationale**: Testing in a separate VM eliminates risk to production Emby, allows thorough validation of security measures, and provides a clean migration path. This approach follows best practices for infrastructure changes affecting critical services.

> [!abstract]- 🔀 Alternative Approaches Considered
>
> **Option A: Modify VM 100 Directly**
> - ✅ Pros: No new VM needed, faster setup
> - ✅ Pros: Uses existing Emby configuration
> - ❌ Cons: Risk to production service
> - ❌ Cons: Hard to rollback if issues
> - ❌ Cons: No isolation for testing
> - **Decision**: Not chosen - too risky for critical service
>
> **Option B: Test VM (CHOSEN)**
> - ✅ Pros: Zero risk to production
> - ✅ Pros: Can test thoroughly before migration
> - ✅ Pros: Easy rollback (just don't migrate)
> - ✅ Pros: Documents process for future
> - ❌ Cons: Requires new VM resources
> - ❌ Cons: Takes longer (but safer)
> - **Decision**: ✅ CHOSEN - Safety and validation worth the extra time
>
> **Option C: Keep Pangolin, Find Workaround**
> - ✅ Pros: No port forwarding needed
> - ✅ Pros: Keeps current security model
> - ❌ Cons: Path/IP rules didn't work
> - ❌ Cons: Emby Connect still blocked
> - ❌ Cons: TV apps still won't work
> - **Decision**: Not chosen - already tried, doesn't solve problem

### Scope Definition

**✅ In Scope:**
- Create new test VM (VM 105 or next available)
- Deploy Emby stack on test VM
- Configure port forwarding on router (Google Nest WiFi)
- Set up DDNS (Cloudflare DNS updates)
- Obtain and configure SSL certificate (Let's Encrypt)
- Install and configure fail2ban for Emby
- Configure UFW firewall rules
- Test Emby Connect connection
- Test TV apps (Roku, Apple TV, Firestick)
- Create security documentation and runbooks
- Document migration process for future swap

**❌ Explicitly Out of Scope:**
- Migrating from VM 100 to test VM (future task after validation)
- Setting up reverse proxy (may be future enhancement)
- IP allowlisting (optional, can add later)
- Advanced DDoS protection (future consideration)
- Router upgrade (future work)

**🎯 MVP (Minimum Viable)**:
- Test VM created with Emby running
- Port forwarding configured and working
- HTTPS/SSL certificate installed
- fail2ban protecting against brute force
- Emby Connect successfully connects
- At least one TV app (Roku or Apple TV) successfully connects
- Security documentation complete

## Risk Assessment

### Potential Pitfalls

- ⚠️ **Risk 1: Router configuration complexity** → **Mitigation**: Document Google Nest WiFi steps, test port forwarding before proceeding, have router admin access ready

- ⚠️ **Risk 2: DDNS not updating correctly** → **Mitigation**: Test DDNS updates, use Cloudflare API for reliability, verify DNS propagation

- ⚠️ **Risk 3: SSL certificate issues** → **Mitigation**: Use Let's Encrypt with proper DNS validation, test certificate renewal process, document PFX conversion

- ⚠️ **Risk 4: fail2ban blocking legitimate users** → **Mitigation**: Test fail2ban configuration, set reasonable thresholds (5 attempts), monitor logs, have unban procedure ready

- ⚠️ **Risk 5: Security vulnerabilities** → **Mitigation**: Implement all security layers (HTTPS, fail2ban, firewall), regular updates, strong passwords, monitoring

- ⚠️ **Risk 6: Resource constraints on Proxmox** → **Mitigation**: Check available resources before creating VM, allocate appropriately, monitor usage

- ⚠️ **Risk 7: Migration complexity** → **Mitigation**: Document migration process thoroughly, test in test VM first, have rollback plan ready

### Dependencies

**Prerequisites (must exist before starting):**
- [ ] **Router admin access** - Need to configure port forwarding (blocking: yes)
- [ ] **Cloudflare DNS access** - For DDNS updates (blocking: yes)
- [ ] **Domain control** - infinity-node.com domain access (blocking: yes)
- [ ] **Proxmox resources** - Check CPU/RAM/disk available (blocking: yes)
- [ ] **Security documentation** - Runbooks created (blocking: no - can reference as we go)

**Has blocking dependencies** - Need router and DNS access before starting

### Critical Service Impact

**Services Affected**: Emby (indirectly - testing new setup)

**Impact**:
- **Current Emby (VM 100)**: No impact - remains running unchanged
- **Test VM**: New service, isolated from production
- **Future migration**: Will affect Emby when we swap over (future task)

**Mitigation**:
- Testing in isolation - zero impact on production
- Can abandon test VM if issues found
- Production Emby continues running throughout
- Migration only happens after full validation

### Rollback Plan

**Applicable for**: Infrastructure changes, security configuration

**How to rollback if this goes wrong:**
1. **If test VM has issues**: Simply delete test VM, no impact on production
2. **If port forwarding causes problems**: Remove port forwarding rule from router
3. **If security measures block access**: Adjust fail2ban/firewall rules or disable temporarily
4. **If migration needed**: Keep VM 100 running, don't migrate until test VM fully validated

**Recovery time estimate**:
- Test VM deletion: < 5 minutes
- Port forwarding removal: < 2 minutes
- Security rule adjustment: < 5 minutes
- **Total**: < 15 minutes to fully rollback

**Backup requirements:**
- **Before creating test VM**: None required (isolated test)
- **Before future migration**: Full Emby config backup (future task)
- **Test VM config**: Document all configurations for reference

## Execution Plan

### Phase 0: Discovery & Preparation

**Primary Agent**: `infrastructure`

- [ ] **Review VM 100 configuration** `[agent:infrastructure]`
  - Document VM 100 specs: CPU (2 cores), RAM (8GB), disks (82GB local-lvm + 32GB NAS)
  - Note machine type: Q35 (required for GPU passthrough)
  - Note BIOS: SeaBIOS (not OVMF - VM 100 uses legacy BIOS)
  - Document GPU passthrough config: hostpci0 and hostpci1 settings
  - Review network config: virtio, bridge vmbr0
  - Document storage mounts: NAS config and media paths
  - Reference: [[docs/ARCHITECTURE|VM 100 Architecture]], [[docs/runbooks/nvidia-gpu-passthrough-setup|GPU Passthrough Runbook]]

- [ ] **Check Proxmox resources** `[agent:infrastructure]`
  - Verify CPU/RAM/disk available for new VM
  - Determine VM ID (105 or next available)
  - Plan VM specifications (match VM 100: 2 CPU, 8GB RAM, similar disk layout)
  - Check if GPU passthrough needed (test VM may not need GPU initially)

- [ ] **Review security documentation** `[agent:security]`
  - Read [[docs/runbooks/emby-external-access-security|Security Runbook]]
  - Review [[docs/runbooks/emby-port-forwarding-quick-reference|Quick Reference]]
  - Understand fail2ban setup requirements

- [ ] **Gather access credentials** `[agent:security]`
  - Router admin access (Google Nest WiFi)
  - Cloudflare API token for DNS updates
  - Domain management access

### Phase 1: VM Creation & Base Setup

**Primary Agent**: `infrastructure`

- [ ] **Create test VM from VM 100** `[agent:infrastructure]` `[risk:6]`
  - **Option A: Clone VM 100** (recommended if possible)
    - Clone VM 100 to new VM ID (105 or next available)
    - Change hostname to `infinity-node-emby-test`
    - Change IP address to new static IP (e.g., 192.168.86.175)
    - Remove Pangolin/newt service (not needed for test VM)
    - Keep GPU passthrough config if cloning (can remove if not needed)
  - **Option B: Create from template** (if cloning not possible)
    - Use Debian-based VM template
    - Match VM 100 specs: 2 CPU, 8GB RAM (4GB balloon), similar disk layout
    - **Machine type: Q35** (required if GPU passthrough needed later)
    - **BIOS: SeaBIOS** (match VM 100 - don't use OVMF unless needed)
    - Configure network: virtio, bridge vmbr0, static IP
    - Set hostname: `infinity-node-emby-test`
  - **Note**: GPU passthrough not required for initial testing, but can be added later if needed

- [ ] **Configure base system** `[agent:infrastructure]`
  - Update system packages
  - Install Docker and Docker Compose (match VM 100 setup)
  - Configure SSH access (match VM 100: evan user with sudo)
  - Set up user accounts (evan with passwordless sudo for automation)
  - Install nvidia-container-toolkit if GPU passthrough will be used

- [ ] **Configure NFS mounts** `[agent:infrastructure]`
  - Mount NAS for Emby config (match VM 100 paths)
  - Mount NAS for media library (read-only, match VM 100)
  - Test NFS connectivity
  - Verify permissions match VM 100 setup

### Phase 2: Emby Stack Deployment

**Primary Agent**: `docker`

- [ ] **Deploy Emby stack** `[agent:docker]`
  - Copy Emby docker-compose.yml to test VM
  - Configure environment variables
  - Set up volumes (config, media)
  - Deploy via Portainer or docker-compose

- [ ] **Configure Emby** `[agent:media]`
  - Initial Emby setup (admin account)
  - Add media libraries
  - Configure users
  - Test local access

- [ ] **Verify Emby functionality** `[agent:testing]`
  - Test local streaming
  - Verify media library accessible
  - Check transcoding (CPU transcoding OK for testing, GPU can be added later if needed)
  - Verify Emby config matches VM 100 setup (network mode, volumes, etc.)

### Phase 3: Network Configuration

**Primary Agent**: `infrastructure`

- [ ] **Configure router port forwarding** `[agent:infrastructure]` `[risk:1]`
  - Access Google Nest WiFi admin
  - Create port forwarding rule (443 → 192.168.86.X:8096)
  - Test external access to verify forwarding works
  - Document router configuration steps

- [ ] **Set up DDNS** `[agent:infrastructure]` `[risk:2]`
  - Choose DDNS method (Cloudflare API recommended)
  - Create script to update DNS record
  - Test DNS updates
  - Verify `emby-test.infinity-node.com` resolves correctly

- [ ] **Configure DNS records** `[agent:infrastructure]`
  - Create A record: `emby-test.infinity-node.com` → Public IP
  - Or configure DDNS to update automatically
  - Test DNS propagation

### Phase 4: SSL/TLS Configuration

**Primary Agent**: `security`

- [ ] **Obtain SSL certificate** `[agent:security]` `[risk:3]`
  - Install certbot on test VM
  - Obtain Let's Encrypt certificate for `emby-test.infinity-node.com`
  - Use DNS challenge (recommended) or HTTP challenge

- [ ] **Convert certificate to PFX** `[agent:security]`
  - Convert Let's Encrypt cert to PFX format
  - Set secure password
  - Store certificate securely

- [ ] **Configure Emby SSL** `[agent:media]`
  - Set custom SSL certificate path in Emby
  - Configure certificate password
  - Set secure connection mode: "Required for all remote connections"
  - Set external domain: `emby-test.infinity-node.com`
  - Set public HTTPS port: 443

- [ ] **Test HTTPS access** `[agent:testing]`
  - Verify HTTPS works externally
  - Check certificate validity
  - Test SSL Labs or similar

### Phase 5: Security Hardening

**Primary Agent**: `security`

- [ ] **Install fail2ban** `[agent:security]` `[risk:4]`
  - Run `scripts/security/setup-emby-fail2ban.sh`
  - Or manually configure fail2ban for Emby
  - Verify Emby log path is correct
  - Test fail2ban filter

- [ ] **Configure fail2ban** `[agent:security]`
  - Set maxretry: 5
  - Set findtime: 600 seconds
  - Set bantime: 3600 seconds
  - Test fail2ban is working

- [ ] **Configure UFW firewall** `[agent:security]`
  - Allow SSH (22)
  - Allow Emby HTTPS (443) from internet
  - Allow Emby HTTP/HTTPS (8096, 8920) from local network
  - Enable firewall
  - Test firewall rules

- [ ] **Configure Emby security** `[agent:media]`
  - Set strong password requirements
  - Review user accounts
  - Enable login attempt logging
  - Configure remote access settings

### Phase 6: Testing & Validation

**Primary Agent**: `testing`

- [ ] **Test external HTTPS access** `[agent:testing]`
  - Access `https://emby-test.infinity-node.com` from external network
  - Verify SSL certificate is valid
  - Test login functionality

- [ ] **Test Emby Connect** `[agent:testing]`
  - Go to app.emby.media
  - Add server: `emby-test.infinity-node.com` (no port)
  - Verify connection succeeds
  - Test login via Emby Connect

- [ ] **Test TV apps** `[agent:testing]`
  - Test Roku Emby app connection
  - Test Apple TV Emby app connection
  - Test Firestick Emby app connection (if available)
  - Verify streaming works on TV apps

- [ ] **Test fail2ban** `[agent:testing]`
  - Simulate failed login attempts
  - Verify IP gets banned
  - Test unban procedure
  - Verify legitimate access still works

- [ ] **Security validation** `[agent:testing]`
  - Review firewall rules
  - Check fail2ban status
  - Verify HTTPS is required
  - Test log monitoring

### Phase 7: Documentation

**Primary Agent**: `documentation`

- [ ] **Update runbooks** `[agent:documentation]`
  - Verify security runbook is accurate
  - Update quick reference with test VM specifics
  - Document router configuration steps

- [ ] **Create migration guide** `[agent:documentation]`
  - Document process for migrating from VM 100 to test VM
  - Include backup procedures
  - Include rollback procedures
  - Estimate downtime

- [ ] **Document test VM configuration** `[agent:documentation]`
  - VM specifications
  - Network configuration
  - Security settings
  - Known issues or limitations

## Acceptance Criteria

**Done when all of these are true:**
- [ ] Test VM created and running Emby successfully
- [ ] Port forwarding configured and working
- [ ] DDNS updating correctly (or DNS record configured)
- [ ] SSL certificate installed and valid
- [ ] HTTPS access working externally
- [ ] fail2ban installed and protecting Emby
- [ ] UFW firewall configured correctly
- [ ] Emby Connect successfully connects to test server
- [ ] At least one TV app (Roku or Apple TV) successfully connects
- [ ] fail2ban tested and working (bans after failed attempts)
- [ ] Security documentation complete and accurate
- [ ] Migration guide created for future swap
- [ ] All execution plan items completed
- [ ] Testing Agent validates (see testing plan below)
- [ ] Changes committed with descriptive message (awaiting user approval)

## Testing Plan

**[[docs/agents/TESTING|Testing Agent]] validates:**
- Test VM is running and accessible
- Emby container is healthy
- Port forwarding is active (external access works)
- DNS resolves correctly
- SSL certificate is valid
- fail2ban service is active
- Firewall rules are configured
- Emby API responds correctly

**Manual validation:**
1. **External HTTPS Access**: Access `https://emby-test.infinity-node.com` from external network, verify SSL certificate, login works
2. **Emby Connect**: Add server to Emby Connect, verify connection succeeds, test login
3. **TV App (Roku)**: Connect Roku Emby app via Emby Connect, verify streaming works
4. **TV App (Apple TV)**: Connect Apple TV Emby app via Emby Connect, verify streaming works
5. **fail2ban Test**: Attempt 5+ failed logins, verify IP gets banned, test unban
6. **Security Check**: Review logs, verify no unauthorized access, check fail2ban status

**Extended monitoring:**
- Monitor test VM for 24-48 hours
- Check fail2ban logs for attack attempts
- Review Emby access logs
- Verify no performance issues

## Related Documentation

- [[docs/runbooks/emby-external-access-security|Emby External Access Security Runbook]]
- [[docs/runbooks/emby-port-forwarding-quick-reference|Port Forwarding Quick Reference]]
- [[docs/runbooks/emby-security-summary|Security Summary]]
- [[docs/runbooks/nvidia-gpu-passthrough-setup|GPU Passthrough Setup Runbook]]
- [[docs/research/proxmox-nvidia-gpu-passthrough-configuration|GPU Passthrough Research]]
- [[stacks/emby/README|Emby Stack Documentation]]
- [[docs/ARCHITECTURE|Infrastructure Architecture]] (VM 100 specs)
- [[docs/agents/INFRASTRUCTURE|Infrastructure Agent]]
- [[docs/agents/SECURITY|Security Agent]]
- [[docs/agents/MEDIA|Media Stack Agent]]

## Notes

**Priority Rationale**:
Priority 2 (High) - Enables TV app compatibility which is a key user requirement. While not critical (production Emby still works), this significantly improves user experience and is blocking TV app usage.

**Complexity Rationale**:
Complex - Requires VM creation, network configuration, security setup, SSL certificates, multiple testing phases, and documentation. Affects critical service (Emby) even though testing in isolation. Multiple components must work together correctly.

**Implementation Notes**:
- Test VM allows safe testing without affecting production
- Use VM 100 as reference/template for consistent configuration
- Match VM 100 specs (CPU, RAM, disk layout, machine type Q35)
- GPU passthrough not required initially but can be added later
- All security measures must be in place before external access
- Emby Connect and TV app testing is critical validation
- Documentation is essential for future router changes
- Migration to production will be separate task after validation

**Follow-up Tasks**:
- IN-XXX: Migrate Emby from VM 100 to test VM (after validation)
- IN-XXX: Set up automated DDNS updates (if using script-based)
- IN-XXX: Configure SSL certificate auto-renewal
- IN-XXX: Set up monitoring/alerting for fail2ban

---

> [!note]- 📋 Work Log
>
> *Work log will be updated during task execution*

> [!tip]- 💡 Lessons Learned
>
> *Lessons learned will be captured during task execution*
