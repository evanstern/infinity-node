---
type: task
task-id: IN-012
status: pending
priority: 2
category: infrastructure
agent: infrastructure
created: 2025-10-26
updated: 2025-10-27
tags:
  - task
  - infrastructure
  - networking
  - dns
  - service-discovery
---

# Task: IN-012 - Set Up Local DNS for Service Discovery

## Description

Implement a local DNS server to provide stable, name-based service discovery across the infinity-node infrastructure. This eliminates hardcoded IP addresses and enables seamless service access even when IP addresses change (e.g., during network moves or reconfigurations).

## Context

Currently, many services and automation tools (like Bitwarden CLI for secret retrieval) rely on hardcoded IP addresses (e.g., `192.168.86.249:8111`). This creates fragility:

1. **IP changes break automation** - When moving locations or reconfiguring network, all IP references must be manually updated
2. **Configuration scattered** - IP addresses are in multiple places (CLI configs, scripts, docker-compose files)
3. **Documentation drift** - Docs quickly become outdated when IPs change
4. **Human error risk** - Easy to miss updating an IP reference, causing mysterious failures

**Example problem:**
```bash
# Bitwarden CLI configured with hardcoded IP
bw config server http://192.168.86.249:8111

# When IP changes → CLI breaks, secrets can't be retrieved, deployments fail
```

**Solution with local DNS:**
```bash
# Configure once with domain
bw config server http://vaultwarden.local.infinity-node.com

# IP changes → update DNS once, everything continues working
```

This task was identified during [[setup-vaultwarden-secret-storage]] when discovering that CLI access requires local IPs instead of external domains due to Pangolin authentication.

## Acceptance Criteria

### DNS Server Setup
- [ ] Select DNS solution (dnsmasq, Pi-hole, BIND, CoreDNS, etc.)
- [ ] Document decision in ADR
- [ ] Deploy DNS server (likely on VM 103 or router)
- [ ] Configure DNS server with local zone `local.infinity-node.com`
- [ ] Set up DNS server as highly available (consider backup/failover)
- [ ] Configure DHCP to distribute local DNS to all devices

### DNS Records
- [ ] Create A records for all VMs:
  - `vm-100.local.infinity-node.com` → 192.168.86.172
  - `vm-101.local.infinity-node.com` → 192.168.86.173
  - `vm-102.local.infinity-node.com` → 192.168.86.174
  - `vm-103.local.infinity-node.com` → 192.168.86.249
- [ ] Create service-specific CNAMEs or A records:
  - `vaultwarden.local.infinity-node.com` → VM 103:8111
  - `emby.local.infinity-node.com` → VM 100:8096
  - `portainer.local.infinity-node.com` → Various
  - `radarr.local.infinity-node.com` → VM 102
  - `sonarr.local.infinity-node.com` → VM 102
  - (and all other services)

### Client Configuration
- [ ] Configure local machine to use local DNS
- [ ] Test DNS resolution from local machine
- [ ] Update Bitwarden CLI to use DNS name
- [ ] Update automation scripts to use DNS names
- [ ] Test that services resolve correctly

### Documentation
- [ ] Document DNS architecture in ARCHITECTURE.md
- [ ] Create docs/DNS.md with:
  - DNS server details (IP, access, credentials)
  - How to add new DNS records
  - How to update existing records
  - Troubleshooting DNS issues
  - Migration plan when IPs change
- [ ] Update all service documentation to reference DNS names
- [ ] Create procedure for IP address migration
- [ ] Document DNS backup/restore process

### Migration Planning
- [ ] Create migration checklist for when network changes
- [ ] Document which IPs need updating in DNS
- [ ] Test DNS update process
- [ ] Verify all services work after test IP change

## Dependencies

- Understanding of current network topology
- Access to router or suitable VM for DNS hosting
- Decision on DNS software
- Inventory of all services requiring DNS entries

## Testing Plan

[[docs/agents/TESTING|Testing Agent]] should validate:
- DNS server responds to queries
- All VM hostnames resolve correctly
- All service hostnames resolve correctly
- Local machine can resolve local DNS
- Bitwarden CLI works with DNS name
- No conflicts with external DNS
- Failover works if primary DNS fails
- DNS updates propagate quickly

**Manual validation:**
```bash
# Test VM resolution
dig vm-100.local.infinity-node.com
dig vm-103.local.infinity-node.com

# Test service resolution
dig vaultwarden.local.infinity-node.com
dig emby.local.infinity-node.com

# Test Bitwarden CLI with DNS
bw config server http://vaultwarden.local.infinity-node.com
bw login
bw sync

# Verify all automation still works
```

## Related Documentation

- [[docs/ARCHITECTURE|Architecture]]
- [[docs/DECISIONS|Decisions]] - ADR needed for DNS solution
- [[docs/agents/INFRASTRUCTURE|Infrastructure Agent]]
- [[setup-vaultwarden-secret-storage]] - Original task that identified this need

## Notes

### DNS Solution Options

**1. dnsmasq** ⭐ **RECOMMENDED FOR HOME LAB**
- **Pros:**
  - Lightweight, simple configuration
  - Combined DNS + DHCP server
  - Perfect for small networks
  - Easy to add/update records
  - Can run in Docker container
- **Cons:**
  - Less feature-rich than enterprise solutions
  - No web UI (config file based)
- **Best for:** Home labs, simple setup

**2. Pi-hole**
- **Pros:**
  - Ad-blocking + DNS
  - Beautiful web UI
  - Easy management
  - DHCP server included
  - Active community
- **Cons:**
  - More resource intensive
  - Focused on ad-blocking (extra features we may not need)
- **Best for:** If you also want ad-blocking

**3. CoreDNS**
- **Pros:**
  - Cloud-native, modern
  - Plugin-based architecture
  - Kubernetes-friendly
  - Lightweight
- **Cons:**
  - More complex configuration
  - Less documentation for home use
- **Best for:** Kubernetes environments

**4. BIND9**
- **Pros:**
  - Industry standard
  - Very powerful
  - Well-documented
- **Cons:**
  - Complex configuration
  - Overkill for home lab
  - Steeper learning curve
- **Best for:** Enterprise, complex DNS needs

**5. Router-based DNS**
- **Pros:**
  - No additional infrastructure
  - Already available
  - Central to network
- **Cons:**
  - Limited by router capabilities
  - May not support custom zones
  - Harder to backup/version control
- **Best for:** Very simple setups

### Recommended Approach

**Phase 1: Quick Win (VM 103 + dnsmasq)**
```yaml
# docker-compose.yml for dnsmasq
services:
  dnsmasq:
    image: jpillora/dnsmasq
    ports:
      - "53:53/udp"
      - "53:53/tcp"
      - "8080:8080"  # Web UI
    volumes:
      - ./dnsmasq.conf:/etc/dnsmasq.conf
      - ./hosts:/etc/hosts
    restart: unless-stopped
```

**dnsmasq.conf example:**
```
# Local domain
domain=local.infinity-node.com
local=/local.infinity-node.com/

# VM records
address=/vm-100.local.infinity-node.com/192.168.86.172
address=/vm-101.local.infinity-node.com/192.168.86.173
address=/vm-102.local.infinity-node.com/192.168.86.174
address=/vm-103.local.infinity-node.com/192.168.86.249

# Service records
address=/vaultwarden.local.infinity-node.com/192.168.86.249
address=/emby.local.infinity-node.com/192.168.86.172
# ... etc

# Upstream DNS (forward everything else)
server=8.8.8.8
server=1.1.1.1
```

**Phase 2: High Availability**
- Run secondary DNS on another VM
- Configure clients with both DNS servers
- Automatic failover

### Service Naming Convention

**Format:** `<service>.<vm-name>.local.infinity-node.com` OR `<service>.local.infinity-node.com`

**Examples:**
```
# VM hostnames
vm-100.local.infinity-node.com
vm-101.local.infinity-node.com

# Services (short names)
vaultwarden.local.infinity-node.com  → 192.168.86.249:8111
emby.local.infinity-node.com         → 192.168.86.172:8096
radarr.local.infinity-node.com       → 192.168.86.174:7878

# Services (fully qualified with VM)
vaultwarden.vm-103.local.infinity-node.com
emby.vm-100.local.infinity-node.com
```

### Integration Points

**Bitwarden CLI:**
```bash
bw config server http://vaultwarden.local.infinity-node.com
```

**Docker Compose files:**
```yaml
environment:
  - EMBY_URL=http://emby.local.infinity-node.com:8096
  - RADARR_URL=http://radarr.local.infinity-node.com:7878
```

**Automation scripts:**
```bash
VAULTWARDEN_URL="http://vaultwarden.local.infinity-node.com"
bw config server $VAULTWARDEN_URL
```

### IP Migration Workflow

**When IPs change (e.g., moving to new location):**

1. **Update DNS records** (single place to change)
   ```bash
   # Edit dnsmasq.conf
   vim /path/to/dnsmasq.conf

   # Update IP addresses
   address=/vm-100.local.infinity-node.com/NEW.IP.HERE

   # Restart DNS
   docker restart dnsmasq
   ```

2. **Verify DNS propagation**
   ```bash
   dig vaultwarden.local.infinity-node.com
   ```

3. **All automation continues working** - no code changes needed!

### Security Considerations

- **DNS server access:** Restrict DNS admin interface to local network only
- **DNS spoofing:** Use DNSSEC if needed (probably overkill for home lab)
- **Backup DNS config:** Version control dnsmasq.conf in git
- **Monitor DNS health:** Alert if DNS server goes down

### Success Metrics

- ✅ Zero hardcoded IPs in automation scripts
- ✅ Zero hardcoded IPs in docker-compose files
- ✅ IP migration takes < 5 minutes (update DNS only)
- ✅ All services accessible via DNS names
- ✅ Documentation references DNS names, not IPs

### Priority Rationale

**Priority Update (2025-10-27):**
Priority increased from 3→2 due to:
- Blocks seamless IP address migration (critical when moving locations)
- Improves automation reliability significantly
- Relatively quick to implement with dnsmasq
- High value-to-effort ratio
- Should be completed before any location/network changes

**Original rationale (medium priority):**
- Blocks seamless IP address migration (high impact when moving)
- Improves automation reliability (medium impact)
- Reduces configuration maintenance burden
- Not blocking current work (can use IP workarounds for now)
- Relatively quick to implement with dnsmasq
- High value-to-effort ratio

**Should be completed before:**
- Moving to new location
- Scaling to more services
- Implementing complex automation
