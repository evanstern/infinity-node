---
type: stack
service: jellyseerr
category: media-automation
vms: [102]
priority: high
status: running
stack-type: single-container
has-secrets: false
external-access: true
ports: [5055]
backup-priority: medium
created: 2025-10-26
updated: 2025-10-26
tags: [stack, vm-102, media-automation, requests, arr, single-container, household-service]
aliases: [Jellyseerr, Media Requests]
---

# Jellyseerr Stack

**Service:** Jellyseerr (Media Request Management)
**VM:** 102 (arr) | **Priority:** High | **Port:** 5055

User-friendly interface for household members to request movies and TV shows. Integrates with Radarr/Sonarr to automatically search and download requested content.

**Access:** http://jellyseerr.local.infinity-node.win (port-free via Traefik) or http://jellyseerr.local.infinity-node.win:5055 (direct)

## Key Features
- Users browse and request content
- Integrates with Emby for user authentication
- Automatically sends requests to Radarr/Sonarr
- Email notifications when content is available

## Dependencies
- Emby (VM 100) - User authentication
- Radarr/Sonarr (VM 102) - Fulfill requests
