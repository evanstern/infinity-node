---
type: documentation
tags:
  - architecture
  - infrastructure
  - network
---

# Infrastructure Architecture

This document details the complete architecture of the infinity-node infrastructure.

## Overview

infinity-node is a Proxmox-based home server environment running containerized services across multiple VMs. The infrastructure prioritizes reliability for critical media services while maintaining flexibility for experimentation with supporting services.

## Network Topology

### Local Network
- **Network**: 192.168.86.0/24
- **Gateway**: 192.168.86.1 (assumed router)
- **DNS**: TBD

### Key Hosts

| Host | IP | Purpose | Access |
|------|-----|---------|--------|
| Proxmox | 192.168.86.106 | Hypervisor | SSH (root), Web (8006) |
| NAS | 192.168.86.43 | Synology Storage | Web (5000), NFS |
| VM 100 (emby) | 192.168.86.172 | Media server | SSH (evan) |
| VM 101 (downloads) | 192.168.86.173 | Download clients | SSH (evan) |
| VM 102 (arr) | 192.168.86.174 | Media automation | SSH (evan) |
| VM 103 (misc) | 192.168.86.249 | Supporting services | SSH (evan) |

### External Services
- **Pangolin Server**: 45.55.78.215 (Digital Ocean)
- **Domain**: infinity-node.com (Cloudflare DNS)

### Network Diagram

```
Internet
    ↓
Router (192.168.86.1)
    ↓
192.168.86.0/24 Network
    ├── Proxmox (106)
    │   ├── VM 100 - emby (172)
    │   ├── VM 101 - downloads (173) ← VPN tunnel
    │   ├── VM 102 - arr (174)
    │   └── VM 103 - misc (249)
    ├── NAS (43) ← NFS mounts
    └── [Other devices]

External Access:
    Pangolin Server (45.55.78.215)
    ├── Tunnel → VM 100 (emby)
    ├── Tunnel → VM 102 (arr)
    └── Tunnel → VM 103 (misc)
```

## Hypervisor

### Proxmox VE

**Host:** infinity-node
**IP:** 192.168.86.106
**Version:** PVE 8.4.1 (running kernel 6.8.12-10-pve)
**Access:**
- SSH: `ssh root@192.168.86.106`
- Web UI: https://192.168.86.106:8006

### Storage Configuration

| Storage | Type | Size | Usage | Path/Details |
|---------|------|------|-------|--------------|
| local | Directory | 100GB | ISOs, templates, backups | /var/lib/vz |
| local-lvm | LVM-thin | 1.8TB | VM disks (local) | /dev/pve/data |
| NAS | NFS | 57TB | VM disks (shared), media | 192.168.86.43:/volume1/infinity-node |

**Storage Notes:**
- NAS provides shared storage for most VM disks
- VM 101 has 4TB physical disk passed through
- Critical VMs use both local-lvm and NAS storage

## Virtual Machines

### VM 100: emby (CRITICAL)

**Purpose:** Media streaming server
**Priority:** CRITICAL - Affects household users
**Hostname:** ininity-node-emby (note typo in actual hostname)
**IP:** 192.168.86.172

**Resources:**
- CPU: 2 cores (x86-64-v2-AES)
- RAM: 8GB (4GB balloon)
- Disk 1: 82GB (local-lvm)
- Disk 2: 32GB (NAS)
- Network: virtio, bridge vmbr0

**Services:**
- Emby Server (emby/embyserver:latest)
- Pangolin client (newt)
- Portainer CE
- Watchtower

**Storage Mounts:**
- Config: NAS mount
- Media: NAS mount (read-only access to media library)

**Notes:**
- Runs in host network mode for performance
- Hardware transcoding capable (currently CPU-only)
- Primary service - maintain 99.9% uptime

---

### VM 101: downloads (CRITICAL)

**Purpose:** Download clients with VPN protection
**Priority:** CRITICAL - Active downloads must not corrupt
**Hostname:** infinity-node-downloads
**IP:** 192.168.86.173

**Resources:**
- CPU: 8 cores (x86-64-v2-AES)
- RAM: 16GB (8GB balloon)
- Disk 1: 100GB (NAS) - OS and configs
- Disk 2: 4TB (physical passthrough) - Download cache
- Network: virtio, bridge vmbr0

**Services:**
- NordVPN (bubuntux/nordlynx) - VPN tunnel
- Deluge (linuxserver/deluge) - Torrent client
- NZBGet (linuxserver/nzbget) - Usenet downloader
- Portainer CE
- Watchtower

**Network Architecture:**
- VPN container has NET_ADMIN capability
- Download clients use `network_mode: service:vpn`
- All download traffic routes through VPN
- Kill switch configured to prevent leaks

**Storage:**
- 4TB physical disk for active downloads
- Downloads move to NAS after completion
- NAS mount for completed media

**Notes:**
- VPN must remain active - monitored for health
- Download clients fail closed if VPN drops
- Critical for media acquisition pipeline

---

### VM 102: infinity-node-arr (CRITICAL)

**Purpose:** Media automation and management
**Priority:** CRITICAL - Media pipeline must remain active
**Hostname:** infinity-node-arr
**IP:** 192.168.86.174

**Resources:**
- CPU: 8 cores (x86-64-v2-AES)
- RAM: 32GB (8GB balloon) - Highest allocation
- Disk: 200GB (NAS)
- Network: virtio, bridge vmbr0

**Services:**
- Radarr (linuxserver/radarr) - Movie management
- Sonarr (linuxserver/sonarr) - TV management
- Lidarr (linuxserver/lidarr) - Music management
- Prowlarr (linuxserver/prowlarr) - Indexer aggregation
- Jellyseerr (fallenbagel/jellyseerr) - Request management
- Flaresolverr (flaresolverr/flaresolverr) - Cloudflare bypass
- Huntarr (huntarr/huntarr) - *arr activity tracker
- Pangolin client (newt)
- Portainer CE
- Watchtower

**Integration Points:**
- Connects to Prowlarr for indexer management
- Sends downloads to VM 101 (download clients)
- Monitors NAS for completed downloads
- Imports and organizes media on NAS
- Notifies Emby (VM 100) to scan new media

**Storage:**
- NAS mount for media library access
- Config stored on NAS
- Requires write access to media directories

**Notes:**
- Heart of the media automation pipeline
- Highest RAM allocation for database performance
- Multiple services coordinate here

---

### VM 103: misc (Important)

**Purpose:** Supporting and experimental services
**Priority:** Important - Primarily affects system owner
**Hostname:** infinity-node-misc
**IP:** 192.168.86.249

**Resources:**
- CPU: 6 cores (x86-64-v2-AES)
- RAM: 16GB (8GB balloon)
- Disk: 100GB (NAS)
- Network: virtio, bridge vmbr0

**Services:**

**Password Management:**
- Vaultwarden (vaultwarden/server) - Password manager

**Document Management:**
- Paperless-NGX (paperless-ngx) + PostgreSQL + Redis
- Gotenberg (PDF processing)
- Tika (document parsing)

**Photo Management:**
- Immich (immich-app) - Photos + ML
- PostgreSQL (pgvecto-rs)
- Redis

**Bookmark Management:**
- Linkwarden + PostgreSQL + Meilisearch

**Media:**
- Navidrome - Music streaming
- Audiobookshelf - Audiobook management

**Other:**
- Homepage (gethomepage/homepage) - Dashboard
- Pangolin client (newt)
- Portainer CE
- Watchtower

**Notes:**
- Most services here are personal use only
- Acceptable downtime for maintenance
- Good VM for experimentation

---

### VM 104: nextcloud (Stopped)

**Status:** Not currently active
**Future:** May be reactivated or replaced

---

### VM 105: debian (Stopped)

**Status:** Not currently active
**Purpose:** General purpose template/testing

## Storage Architecture

### NFS Mount from Synology NAS

**NAS Details:**
- **Model:** Synology (specific model TBD)
- **IP:** 192.168.86.43
- **Web UI:** http://192.168.86.43:5000
- **Capacity:** 57TB total

**Mount Point:** 192.168.86.43:/volume1/infinity-node

**Usage:**
- VM disk images (qcow2 on NFS)
- Media library (movies, TV, music)
- Service configurations
- Completed downloads

**Mounted On:**
- Proxmox (as storage pool "NAS")
- VMs mount subdirectories via docker volumes

### Media Library Structure

```
/volume1/infinity-node/
├── media/
│   ├── movies/          ← Radarr manages
│   ├── tv/              ← Sonarr manages
│   ├── music/           ← Lidarr manages
│   └── audiobooks/      ← Manual management
├── downloads/           ← Download staging
│   ├── complete/        ← *arr import from here
│   └── incomplete/      ← Active downloads
└── configs/             ← Service configurations
    ├── emby/
    ├── radarr/
    ├── sonarr/
    └── ...
```

### Backup Strategy

**Current State:** TBD - Needs documentation

**Considerations:**
- NAS has its own backup strategy
- VM snapshots on Proxmox
- Docker configs in git
- Database backups needed
- .env files need secure backup

## Service Architecture

### Standard Stack Pattern

Every VM follows this pattern:

```yaml
Standard Services (on every VM):
  - portainer        # Container management UI
  - watchtower       # Automatic image updates

  Optional:
  - newt             # Pangolin tunnel client (VMs 100, 102, 103)
```

### Service Communication

#### Media Acquisition Flow

```
User Request (Jellyseerr)
    ↓
*arr Service (VM 102: Radarr/Sonarr/Lidarr)
    ↓ (via Prowlarr)
Indexer Search
    ↓
Download Client (VM 101: Deluge/NZBGet)
    ↓ (through VPN)
Download File → 4TB disk
    ↓ (completion hook)
*arr Service Imports → NAS
    ↓
Emby Scans New Media (VM 100)
    ↓
User Streams Media
```

#### Key Integration Points

1. **Prowlarr → *arr services**
   - Centralizes indexer management
   - Syncs indexers to Radarr/Sonarr/Lidarr
   - Handles Cloudflare challenges via Flaresolverr

2. ***arr → Download clients**
   - API communication over network
   - Category/label-based organization
   - Post-processing scripts

3. **Download clients → NAS**
   - Completed downloads move to NAS
   - *arr services monitor completion directory
   - Import and rename on NAS

4. ***arr → Emby**
   - Webhooks notify Emby of new media
   - Emby scans and updates library
   - Metadata and artwork retrieved

## External Access

### Pangolin Tunnels

**Server:** 45.55.78.215 (Digital Ocean)
**Endpoint:** https://pangolin.infinity-node.com

**Newt Clients:**
- VM 100 (emby): Exposes Emby for external streaming
- VM 102 (arr): Exposes *arr services for remote management
- VM 103 (misc): Exposes various services

**Benefits:**
- No port forwarding required
- Identity-aware access control
- Cloudflare integration
- TLS termination

**Configuration:**
- Each newt client has unique ID and secret
- Secrets stored in `.env` files (not in git)
- Tunnel health monitored

### Domain Management

**Domain:** infinity-node.com
**DNS:** Cloudflare
**Access:** TBD - Credentials in Vaultwarden

**Subdomains:**
- `pangolin.infinity-node.com` - Pangolin server
- Additional subdomains per service (TBD)

## Security Architecture

### Authentication Layers

1. **Network Level**
   - Services not directly exposed to internet
   - Pangolin tunnels for external access

2. **Application Level**
   - Each service has its own authentication
   - Credentials stored in Vaultwarden
   - Some services support SSO via Pangolin

3. **VPN Protection**
   - Download traffic protected by NordVPN
   - Kill switch prevents leaks
   - DNS leak protection

### SSH Access

**Key-based authentication only:**
- Proxmox: `root@192.168.86.106`
- VMs: `evan@<VM_IP>` (full access, passwordless sudo)
- VMs: `inspector@<VM_IP>` (read-only, for Testing Agent)

**User Details:**
- `evan`: Full system access with passwordless sudo (for automation)
- `inspector`: Docker group access (policy-based read-only), no sudo
  - Created via `scripts/setup-inspector-user.sh`
  - Used by [[agents/TESTING|Testing Agent]] for validation

### Secret Management

**Current:**
- `.env` files on each VM (gitignored)
- Vaultwarden for long-term storage
- Some secrets in docker-compose (being migrated)

**Target:**
- All secrets in `.env` files
- `.env.example` templates in git
- Vaultwarden as source of truth
- Encrypted backup of .env files

## Monitoring & Management

### Container Management

**Portainer:**
- Instance on each VM
- Web UI for container management
- Stack deployment
- Log viewing

**Watchtower:**
- Automatic image updates
- Checks for updates daily
- Updates non-critical services automatically
- Critical services updated manually

### Service Health

**Current:**
- Manual checks
- Container healthchecks where configured
- Emby has built-in health monitoring

**Future:**
- Centralized monitoring (TBD)
- Alerting for critical services
- Uptime tracking
- Resource usage trending

## Performance Considerations

### Resource Allocation

**CPU:**
- Total: ~24 cores available on Proxmox host
- Allocated: 22 cores across VMs
- Headroom: Minimal - consider before adding services

**RAM:**
- Total: TBD (need to check Proxmox)
- Allocated: 58GB across VMs (with balloon)
- Highest usage: VM 102 (arr) with 32GB

**Disk I/O:**
- NFS adds latency vs local storage
- VM 101 has local 4TB disk for performance
- Consider for database-heavy services

### Network Bandwidth

**Internal:**
- 1Gbps between Proxmox and NAS (assumed)
- Sufficient for media streaming
- Monitor during multiple concurrent transcodes

**External:**
- Depends on ISP connection
- VPN may reduce bandwidth
- Monitor during peak usage

### Transcoding

**Emby Transcoding:**
- Currently CPU-only
- Can enable hardware transcoding (GPU passthrough)
- Temp directory should use tmpfs for performance
- Consider dedicated transcoding VM if needed

## Disaster Recovery

### Current State

**Documented:**
- Infrastructure architecture (this document)
- Docker configurations (in stacks/)
- Service relationships

**Needs Work:**
- Backup procedures
- Recovery procedures
- Runbooks for common scenarios
- RTO/RPO definitions

### Critical Services Recovery Priority

1. **Emby** (VM 100) - Restore media streaming
2. **Downloads** (VM 101) - Resume acquisition
3. **arr Services** (VM 102) - Restore automation
4. **Supporting Services** (VM 103) - Nice to have

### Dependencies

**External:**
- Internet connection
- NAS availability
- Pangolin server availability
- VPN provider availability

**Internal:**
- Proxmox host health
- NFS mount stability
- VM disk integrity
- Docker daemon

## Capacity Planning

### Current Utilization

**Storage:**
- NAS: ~77% utilized (44TB / 57TB)
- local-lvm: ~4% utilized
- Growth rate: TBD - needs monitoring

**Compute:**
- CPU allocation high (~92%)
- RAM allocation: TBD
- Consider resource limits before adding VMs/services

### Growth Considerations

**Storage:**
- NAS is primary concern
- Monitor media library growth
- Plan expansion or cleanup strategy

**Compute:**
- Near CPU allocation limit
- May need to:
  - Upgrade Proxmox host hardware
  - Optimize resource allocation
  - Consolidate services

**Services:**
- Current VM layout works well
- Consider service placement carefully
- Test in VM 103 before promoting to critical VMs

## Known Issues & Technical Debt

1. **Emby VM hostname has typo:** "ininity-node-emby"
2. **Secret management incomplete:** Some secrets still in docker-compose files
3. **No centralized monitoring:** Manual health checks
4. **Backup strategy undefined:** Needs documentation and automation
5. **No disaster recovery testing:** Recovery procedures untested
6. **Resource monitoring needed:** Capacity planning requires data
7. **Inspector user not created:** Testing Agent needs read-only access
8. **Documentation incomplete:** Service-specific docs needed

## Future Enhancements

1. **Monitoring & Alerting**
   - Centralized logging
   - Metrics collection
   - Alerting for critical services
   - Uptime tracking

2. **Automation**
   - Automated deployment scripts
   - Update orchestration
   - Backup automation
   - Health check automation

3. **High Availability**
   - Consider HA for critical services
   - Failover testing
   - Redundancy planning

4. **Performance**
   - Hardware transcoding for Emby
   - SSD cache for NAS
   - Network optimization
   - Resource usage optimization

5. **Security**
   - Intrusion detection
   - Log analysis
   - Regular security audits
   - Automated patching

## Related Documentation

- [[CLAUDE|Claude Code Guide]]
- [[agents/README|Agent System]]
- [[agents/INFRASTRUCTURE|Infrastructure Agent]]
- [[agents/DOCKER|Docker Agent]]
- [[agents/MEDIA|Media Stack Agent]]
- [[DECISIONS|Architectural Decisions]]

## Change Log

| Date | Change | Author |
|------|--------|--------|
| 2025-10-24 | Initial architecture documentation | Claude Code + Evan |

---

**Note:** This document should be updated whenever significant infrastructure changes are made.
