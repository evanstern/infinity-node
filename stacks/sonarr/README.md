---
type: stack
service: sonarr
category: media-automation
vms: [102]
priority: critical
status: running
stack-type: single-container
has-secrets: false
external-access: false
ports: [8989]
backup-priority: high
created: 2025-10-26
updated: 2025-10-26
tags:
  - stack
  - vm-102
  - media-automation
  - tv-shows
  - arr
  - critical
  - single-container
  - no-secrets
  - household-service
aliases:
  - Sonarr
  - TV Automation
---

# Sonarr Stack

**Service:** Sonarr (TV Show Management & Automation)
**VM:** 102 (arr)
**Priority:** CRITICAL - Automates TV show acquisition for household
**Access:** http://sonarr.local.infinity-node.win (port-free via Traefik) or http://sonarr.local.infinity-node.win:8989 (direct)
**Image:** `lscr.io/linuxserver/sonarr:latest`

## Overview

Sonarr automates TV show downloading by monitoring airdates, searching indexers via Prowlarr, and sending downloads to Deluge/NZBGet on VM 101. Handles episode tracking, quality management, and library organization.

## Configuration

### Secrets
None - API key generated in web UI

### Volumes
- `/config` - Database and settings
- `/tv` - TV show library
- `/downloads` - Completed downloads from VM 101

### Dependencies
- **Prowlarr** (VM 102) - Indexer management
- **Downloads** (VM 101) - Download clients
- **Emby** (VM 100) - Serves TV shows to users

## Deployment

```bash
cd stacks/sonarr
cp .env.example .env
docker compose up -d
```

## Initial Setup

1. Access: http://sonarr.local.infinity-node.win (port-free) or http://sonarr.local.infinity-node.win:8989 (direct)
2. Add root folder: `/tv`
3. Connect to Prowlarr for indexers
4. Add download clients (Deluge/NZBGet on VM 101)
5. Configure quality profiles and naming

## Notes

- Critical service - affects household media acquisition
- Monitors show air dates for new episodes
- API key used by Jellyseerr for show requests
- Originally had embedded newt (now separate stack)
