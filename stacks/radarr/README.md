---
type: stack
service: radarr
category: media-automation
vms: [102]
priority: critical
status: running
stack-type: single-container
has-secrets: false
external-access: false
ports: [7878]
backup-priority: high
created: 2025-10-26
updated: 2025-10-26
tags:
  - stack
  - vm-102
  - media-automation
  - movies
  - arr
  - critical
  - single-container
  - no-secrets
  - household-service
aliases:
  - Radarr
  - Movie Automation
---

# Radarr Stack

**Service:** Radarr (Movie Management & Automation)
**VM:** 102 (arr)
**Priority:** CRITICAL - Automates movie acquisition for household
**Access:** http://radarr.local.infinity-node.com:7878
**Image:** `lscr.io/linuxserver/radarr:latest`

## Overview

Radarr automates movie downloading by monitoring release calendars, searching indexers via Prowlarr, and sending downloads to Deluge/NZBGet on VM 101. Part of the arr service ecosystem providing automated media acquisition.

## Configuration

### Secrets
None - API key generated in web UI for service integration

### Volumes
- `${CONFIG_PATH}:/config` - Database and settings
- `${MOVIES_PATH}:/movies` - Movie library (managed by Radarr)
- `${DOWNLOADS_PATH}:/downloads` - Completed downloads from VM 101

### Dependencies
- **Prowlarr** (VM 102) - Indexer management
- **Downloads** (VM 101) - Deluge/NZBGet for actual downloading
- **Emby** (VM 100) - Serves acquired movies to users

## Deployment

```bash
cd stacks/radarr
cp .env.example .env
docker compose up -d
```

## Initial Setup

1. Access: http://radarr.local.infinity-node.com:7878
2. Settings → Media Management:
   - Root folder: `/movies`
   - File naming conventions
   - Import existing movies
3. Settings → Indexers:
   - Add Prowlarr (auto-configures via API)
4. Settings → Download Clients:
   - Add Deluge (VM 101): http://deluge.local.infinity-node.com:8112
   - Add NZBGet (VM 101): http://nzbget.local.infinity-node.com:6789

## Notes

- Critical service - affects household media acquisition
- Monitor disk space in MOVIES_PATH
- Backup database regularly (contains monitored movies)
- API key used by Jellyseerr for movie requests
