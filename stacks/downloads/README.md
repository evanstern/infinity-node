---
type: stack
service: downloads
category: downloads
vms: [101]
priority: critical
status: running
stack-type: multi-container
has-secrets: true
external-access: false
ports: [8112, 6881, 6789]
backup-priority: medium
created: 2025-10-26
updated: 2025-10-26
tags:
  - stack
  - vm-101
  - downloads
  - vpn
  - torrent
  - usenet
  - critical
  - multi-container
  - has-secrets
  - nordvpn
  - wireguard
  - kill-switch
  - household-service
aliases:
  - Downloads
  - Download Stack
  - VPN Downloads
---

# Downloads Stack

**Service:** Downloads (VPN + Deluge + NZBGet)
**VM:** 101 (downloads)
**Priority:** CRITICAL - Media acquisition for household users
**Access:**
- Deluge: http://deluge.local.infinity-node.com (port-free via Traefik) or http://deluge.local.infinity-node.com:8112 (direct)
- NZBGet: http://nzbget.local.infinity-node.com (port-free via Traefik) or http://nzbget.local.infinity-node.com:6789 (direct)
**Images:**
- `ghcr.io/bubuntux/nordlynx:latest`
- `ghcr.io/linuxserver/deluge:latest`
- `lscr.io/linuxserver/nzbget:latest`

## Overview

The downloads stack handles all torrent and usenet downloading for the infinity-node infrastructure. It's a CRITICAL service as it provides media acquisition for the arr services (VM 102), which in turn populate the emby media library (VM 100).

**Key Architecture:** All download traffic is routed through a NordVPN WireGuard tunnel (NordLynx), providing privacy and acting as a kill switch - if the VPN connection fails, downloads cannot reach the internet.

## Architecture

Multi-container stack with VPN tunnel:

```
┌──────────────────────────────────────┐
│  nordlynx (VPN Container)            │
│  - NET_ADMIN capabilities            │
│  - WireGuard tunnel to NordVPN       │
│  - Exposes ports to host             │
└──────────────────────────────────────┘
         ▲                    ▲
         │                    │
         │ (network_mode:     │ (network_mode:
         │  container:vpn)    │  container:vpn)
         │                    │
┌────────┴──────────┐  ┌─────┴────────────┐
│  deluge           │  │  nzbget          │
│  (Torrent Client) │  │  (Usenet Client) │
└───────────────────┘  └──────────────────┘
```

**Kill Switch:** If VPN fails, deluge and nzbget lose all network connectivity immediately.

## Key Features

### NordLynx (VPN)
- **WireGuard Protocol:** Modern, fast VPN protocol
- **NordVPN Integration:** Uses NordVPN's WireGuard implementation
- **Kill Switch:** Automatic - containers sharing network lose connectivity if VPN dies
- **Local Network Access:** NET_LOCAL setting allows web UI access from LAN

### Deluge (Torrent Client)
- **BitTorrent Protocol:** P2P file sharing
- **Web UI:** Browser-based management interface
- **Plugin Support:** RSS, labels, notifications
- **Integration:** Works with Sonarr, Radarr, Lidarr via API

### NZBGet (Usenet Client)
- **Usenet Protocol:** Binary newsgroup downloading
- **Web UI:** Browser-based management interface
- **Post-Processing:** Scripts for unpacking, verification
- **Integration:** Works with Sonarr, Radarr, Lidarr via API

## Configuration

### Secrets

**Required secrets stored in Vaultwarden:**

1. **PRIVATE_KEY** - NordVPN WireGuard private key
   - Location: `infinity-node/vm-101-downloads/downloads-credentials`
   - Field: `private_key`
   - How to obtain: NordVPN account dashboard → Manual Setup → NordLynx → Generate key

2. **NZBGET_USER** - NZBGet web UI username
   - Location: `infinity-node/vm-101-downloads/downloads-credentials`
   - Field: `nzbget_user`

3. **NZBGET_PASS** - NZBGet web UI password
   - Location: `infinity-node/vm-101-downloads/downloads-credentials`
   - Field: `nzbget_pass`

**Store in Vaultwarden:**
```bash
export BW_SESSION=$(bw unlock --raw)

./scripts/create-secret.sh "downloads-credentials" "vm-101-downloads" "" \
  '{"service":"downloads","vm":"101","private_key":"YOUR_KEY","nzbget_user":"nzbget","nzbget_pass":"YOUR_PASS"}'
```

**Retrieve from Vaultwarden:**
```bash
export BW_SESSION=$(bw unlock --raw)

PRIVATE_KEY=$(bw get item downloads-credentials | jq -r '.fields[] | select(.name=="private_key") | .value')
NZBGET_USER=$(bw get item downloads-credentials | jq -r '.fields[] | select(.name=="nzbget_user") | .value')
NZBGET_PASS=$(bw get item downloads-credentials | jq -r '.fields[] | select(.name=="nzbget_pass") | .value')
```

### Volumes

**Download Paths:**
- `${INCOMPLETE_PATH}` → `/incomplete` (both) - Active downloads
- `${COMPLETE_PATH}` → `/downloads` (nzbget), `/complete` (deluge) - Completed downloads

**Configuration:**
- `${DELUGE_CONFIG_PATH}` → `/config` - Deluge settings and state
- `${NZBGET_CONFIG_PATH}` → `/config` - NZBGet settings and queue

**Important:** Complete download path must be accessible to arr services on VM 102 for post-processing.

### Environment Variables

**VPN Configuration:**
- `PRIVATE_KEY` - NordVPN WireGuard private key (secret)
- `NET_LOCAL` - Local network CIDR for web UI access (default: `192.168.86.0/24`)

**User/Group:**
- `PUID` - User ID for file ownership (default: `1000`)
- `PGID` - Group ID for file ownership (default: `1000`)

**General:**
- `TZ` - Timezone (default: `America/Toronto`)

**NZBGet:**
- `NZBGET_USER` - Web UI username (secret)
- `NZBGET_PASS` - Web UI password (secret)

**Deluge:**
- `DELUGE_LOGLEVEL` - Logging verbosity (default: `error`)

### Ports

- `8112` - Deluge web UI
- `6881` - BitTorrent port (TCP/UDP)
- `6789` - NZBGet web UI

**Note:** Ports are exposed by the VPN container, but traffic from deluge/nzbget routes through VPN tunnel.

## Deployment

```bash
cd stacks/downloads
cp .env.example .env

# Retrieve secrets from Vaultwarden
export BW_SESSION=$(bw unlock --raw)
# ... (retrieve and populate .env with secrets)

docker compose up -d
```

## Initial Setup

### 1. Get NordVPN WireGuard Key

1. Log in to NordVPN account
2. Navigate to Dashboard → Services → NordLynx
3. Click "Generate new private key"
4. Copy the private key
5. Store in Vaultwarden using `create-secret.sh` script

### 2. Configure NZBGet

1. Access web UI: http://nzbget.local.infinity-node.com:6789
2. Log in with NZBGET_USER/NZBGET_PASS
3. Settings → Paths:
   - MainDir: `/downloads`
   - InterDir: `/incomplete`
4. Settings → News Servers:
   - Add your usenet provider details
5. Save changes

### 3. Configure Deluge

1. Access web UI: http://deluge.local.infinity-node.com:8112
2. Default password: `deluge` (change immediately!)
3. Preferences → Downloads:
   - Download to: `/incomplete`
   - Move completed to: `/complete`
4. Preferences → Network:
   - Listen Ports: 6881
5. Save preferences

### 4. Verify VPN Connection

```bash
# Check VPN container logs
docker logs vpn

# Verify external IP is NordVPN server
docker exec deluge curl -s ifconfig.me
# Should show NordVPN server IP, NOT your home IP

# Verify local network access works
curl http://deluge.local.infinity-node.com:8112
# Should return Deluge web UI
```

## Usage

### Adding Downloads

**Deluge (Torrents):**
- Upload .torrent file via web UI
- Add magnet link via web UI
- API integration from arr services

**NZBGet (Usenet):**
- Upload .nzb file via web UI
- Add via URL in web UI
- API integration from arr services

### Monitoring Downloads

**Deluge:**
- Web UI shows active torrents
- Speed limits, queue management
- Completed torrents move to `/complete`

**NZBGet:**
- Web UI shows download queue
- Post-processing status
- Health check for failed downloads

## VPN Kill Switch

### How It Works

The `network_mode: container:vpn` configuration means deluge and nzbget share the VPN container's network namespace. If the VPN connection drops:

1. VPN container loses external connectivity
2. Deluge and nzbget immediately lose external connectivity
3. No traffic can leak outside the VPN tunnel
4. Downloads pause automatically

### Verification

```bash
# Stop VPN container
docker stop vpn

# Try to access internet from deluge
docker exec deluge curl -s --max-time 5 ifconfig.me
# Should fail with timeout or connection refused

# Restart VPN
docker start vpn

# Check connection restored
docker exec deluge curl -s ifconfig.me
# Should show NordVPN IP again
```

## Monitoring

```bash
# View VPN logs
docker logs -f vpn

# Check VPN status
docker exec vpn curl -s ifconfig.me

# View Deluge logs
docker logs -f deluge

# View NZBGet logs
docker logs -f nzbget

# Check resource usage
docker stats vpn deluge nzbget
```

**Monitor for:**
- VPN connection stability
- Download speeds
- Disk space in INCOMPLETE_PATH and COMPLETE_PATH
- Failed downloads requiring attention

## Backup

**Critical data to backup:**
- `${DELUGE_CONFIG_PATH}` - Deluge settings, torrent state
- `${NZBGET_CONFIG_PATH}` - NZBGet settings, queue

**Downloads:**
- Incomplete downloads can be re-downloaded if lost
- Completed downloads are processed by arr services (backed up separately)

```bash
# Backup configurations
cd stacks/downloads
tar -czf downloads-backup-$(date +%Y%m%d).tar.gz deluge/ nzbget/

# Restore
docker compose down
tar -xzf downloads-backup-YYYYMMDD.tar.gz
docker compose up -d
```

## Troubleshooting

### VPN Not Connecting

**Symptoms:**
- `docker logs vpn` shows connection errors
- Deluge/NZBGet can't reach internet

**Check:**
1. PRIVATE_KEY is correct
2. NordVPN account is active
3. NordVPN didn't rotate the key
4. Network connectivity from host

**Solution:**
- Verify key in NordVPN dashboard
- Regenerate key if needed
- Update in Vaultwarden and .env
- Restart containers

### Can't Access Web UIs

**Symptoms:**
- http://deluge.local.infinity-node.com:8112 times out
- http://nzbget.local.infinity-node.com:6789 times out

**Check:**
1. NET_LOCAL is set correctly
2. VPN container is running
3. Ports are mapped correctly

**Solution:**
```bash
# Check VPN container
docker ps | grep vpn

# Check port mappings
docker port vpn

# Verify NET_LOCAL matches your network
# Should be: 192.168.86.0/24
```

### Slow Download Speeds

**Common Causes:**
- VPN server congestion
- NordVPN throttling
- ISP throttling
- Too many simultaneous downloads

**Solutions:**
- Change NordVPN server (regenerate PRIVATE_KEY)
- Limit active downloads
- Check NordVPN server status
- Verify no bandwidth limits in Deluge/NZBGet

### Downloads Failing

**Deluge (Torrents):**
- Check torrent health (seeders)
- Verify disk space
- Check firewall rules (torrent port)

**NZBGet (Usenet):**
- Verify usenet provider credentials
- Check server status
- Review post-processing scripts
- Check for corrupted downloads

## Performance

**Resource Requirements:**
- **VPN:** ~50 MB RAM, minimal CPU
- **Deluge (idle):** ~100 MB RAM
- **Deluge (active):** ~200 MB RAM, CPU varies with number of torrents
- **NZBGet (idle):** ~50 MB RAM
- **NZBGet (active):** ~100-200 MB RAM, CPU during unpacking

**Network Impact:**
- VPN adds ~5-10ms latency
- Bandwidth limited by VPN server capacity
- WireGuard protocol is very efficient

## Security Considerations

- All download traffic encrypted through VPN
- VPN private key is sensitive - store in Vaultwarden
- Kill switch prevents IP leaks
- NZBGet credentials protect web UI access
- Deluge password should be changed from default
- Local network access controlled by NET_LOCAL setting
- Consider rotating VPN key periodically

## Critical Service Notes

⚠️ **HOUSEHOLD IMPACT:** This service affects media acquisition for the household.

**Change Management:**
- Downloads in progress will be interrupted by restarts
- Coordinate changes with arr services maintenance
- Monitor for several hours after changes
- Have VPN credentials ready for quick recovery

**Downtime Impact:**
- New media cannot be acquired
- arr services cannot download requested content
- Existing downloads pause (resume when service restored)

## Dependencies

- **Downstream Services:** arr services (VM 102) depend on completed downloads
- **Media Library:** emby (VM 100) serves content acquired via this stack
- **Network Storage:** COMPLETE_PATH must be accessible to arr services
- **NordVPN:** Active subscription required for VPN access

## Related Documentation

- [NordLynx Docker Image](https://github.com/bubuntux/nordlynx)
- [Deluge Documentation](https://dev.deluge-torrent.org/wiki/UserGuide)
- [NZBGet Documentation](https://nzbget.com/documentation)
- [NordVPN WireGuard Setup](https://support.nordvpn.com/hc/en-us/articles/19508770879377-Connect-to-NordVPN-using-Linux-Terminal)

## Notes

- NordLynx is NordVPN's implementation of WireGuard
- Kill switch is automatic due to container network sharing
- VPN performance varies by server location
- Consider P2P-optimized NordVPN servers for torrents
- Usenet typically faster than torrents for popular content
- arr services (VM 102) automatically manage downloads via API
- Download completion triggers arr post-processing
- Deployed via Portainer on VM 101
- Critical service - requires [[docs/agents/MEDIA|Media Stack Agent]] for changes
