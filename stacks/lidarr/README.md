---
type: stack
service: lidarr
category: media-automation
vms: [102]
priority: medium
status: running
stack-type: single-container
has-secrets: false
external-access: false
ports: [8686]
backup-priority: medium
created: 2025-10-26
updated: 2025-10-26
tags: [stack, vm-102, media-automation, music, arr, single-container, no-secrets]
aliases: [Lidarr, Music Automation]
---

# Lidarr Stack

**Service:** Lidarr (Music Management & Automation)
**VM:** 102 (arr) | **Priority:** Medium | **Port:** 8686

Automates music downloading via Prowlarr and download clients (VM 101). Manages music library organization and quality.

**Access:** http://lidarr.local.infinity-node.com (port-free via Traefik) or http://lidarr.local.infinity-node.com:8686 (direct)

## Dependencies
- Prowlarr (indexers) | Downloads (VM 101) | Navidrome (VM 103)
