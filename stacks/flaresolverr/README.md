---
type: stack
service: flaresolverr
category: media-automation
vms: [102]
priority: important
status: running
stack-type: single-container
has-secrets: false
external-access: false
ports: [8191]
backup-priority: low
created: 2025-10-26
updated: 2025-10-26
tags: [stack, vm-102, media-automation, cloudflare, proxy, arr]
aliases: [FlareSolverr, Cloudflare Bypass]
---

# FlareSolverr Stack

**Service:** FlareSolverr (Cloudflare Challenge Solver)
**VM:** 102 (arr) | **Priority:** Important | **Port:** 8191

Proxy server that solves Cloudflare challenges, allowing Prowlarr to access indexers protected by Cloudflare anti-bot systems.

## Dependencies
- Used by: Prowlarr (VM 102)
