---
type: stack
service: prowlarr
category: media-automation
vms: [102]
priority: critical
status: running
stack-type: single-container
has-secrets: false
external-access: false
ports: [9696]
backup-priority: high
created: 2025-10-26
updated: 2025-10-26
tags: [stack, vm-102, media-automation, indexers, arr, critical, single-container, no-secrets]
aliases: [Prowlarr, Indexer Manager]
---

# Prowlarr Stack

**Service:** Prowlarr (Indexer Management)
**VM:** 102 (arr) | **Priority:** CRITICAL | **Port:** 9696

Centralized indexer management for all arr services. Manages torrent/usenet indexers and automatically configures them in Radarr, Sonarr, and Lidarr. Critical component - if Prowlarr fails, no arr service can search for content.

**Access:** http://prowlarr.local.infinity-node.com (port-free via Traefik) or http://prowlarr.local.infinity-node.com:9696 (direct)

## Key Role
- Manages all indexer connections (torrent sites, usenet providers)
- Automatically syncs indexers to Radarr, Sonarr, Lidarr
- Provides unified search across all configured indexers
- Handles indexer authentication and rate limiting
- Integrates with FlareSolverr for Cloudflare-protected indexers

## Dependencies
- FlareSolverr (VM 102) - Cloudflare bypass
- Used by: Radarr, Sonarr, Lidarr (all VM 102)
