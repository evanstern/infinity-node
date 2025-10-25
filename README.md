---
type: documentation
tags:
  - overview
  - root
---

# infinity-node

Infrastructure as Code for the infinity-node self-hosted server environment.

## Overview

This repository manages the complete infrastructure for infinity-node, a Proxmox-based home server running media services, automation, and various self-hosted applications.

### Primary Services
- **Media Server**: Emby for streaming media to household users (CRITICAL)
- **Media Automation**: *arr services (Radarr, Sonarr, Lidarr, Prowlarr) for automated content management (CRITICAL)
- **Downloads**: Torrent and Usenet downloaders with VPN protection (CRITICAL)
- **Supporting Services**: Vaultwarden, Immich, Paperless-NGX, and more

## Quick Start

### For Obsidian Users
1. Open this directory as an Obsidian vault
2. Install recommended plugins: Dataview, Obsidian Git
3. Start with [[docs/agents/README|Agent System]]
4. View [[DASHBOARD|Task Dashboard]]

### For Non-Obsidian Users
- Browse `docs/` for all documentation
- Check `tasks/current/` for active tasks
- See `docs/agents/` for agent specifications
- Review `stacks/` for Docker configurations

## Repository Structure

```
infinity-node/
├── .obsidian/           # Obsidian vault configuration
│   └── templates/       # Templates for tasks, runbooks, ADRs
├── docs/                # Documentation
│   ├── agents/          # Agent specifications
│   ├── runbooks/        # Operational procedures
│   └── services/        # Service documentation
├── tasks/               # MDTD task management
│   ├── current/         # Active tasks
│   ├── backlog/         # Future tasks
│   ├── completed/       # Finished tasks
│   └── DASHBOARD.md     # Task overview
├── stacks/              # Docker compose configurations
│   └── SERVICE_NAME/    # Each service has its own directory
├── scripts/             # Automation scripts
└── README.md            # This file
```

## Core Concepts

### Agent System
We use specialized agents for different infrastructure domains:
- [[docs/agents/TESTING|Testing Agent]]: Read-only QA and validation
- [[docs/agents/DOCKER|Docker Agent]]: Container orchestration
- [[docs/agents/INFRASTRUCTURE|Infrastructure Agent]]: Proxmox/VM management
- [[docs/agents/SECURITY|Security Agent]]: Secrets and authentication
- [[docs/agents/MEDIA|Media Stack Agent]]: Critical media services
- [[docs/agents/DOCUMENTATION|Documentation Agent]]: Knowledge management

See [[docs/agents/README|Agent System Documentation]] for details.

### MDTD (Markdown-Driven Task Development)
Tasks are managed as markdown files with YAML frontmatter:
- Track status, priority, and assigned agent
- Link related tasks and documentation
- Query with Dataview in Obsidian
- Full git history for all changes

See [[tasks/README|MDTD Documentation]] for details.

## Infrastructure

### Proxmox Host
- **Host**: infinity-node
- **IP**: 192.168.86.106
- **Version**: PVE 8.4.1

### Virtual Machines

| VM ID | Name | IP | Purpose | Priority |
|-------|------|-----|---------|----------|
| 100 | emby | 192.168.86.172 | Media server | CRITICAL |
| 101 | downloads | 192.168.86.173 | Download clients + VPN | CRITICAL |
| 102 | infinity-node-arr | 192.168.86.174 | Media automation (*arr) | CRITICAL |
| 103 | misc | 192.168.86.249 | Supporting services | Important |

### Storage
- **local**: 100GB (ISOs, templates, backups)
- **local-lvm**: 1.8TB (VM disks)
- **NAS**: 57TB NFS mount (192.168.86.43 - Synology)

### External Services
- **Pangolin**: 45.55.78.215 - Tunnel server for external access
- **Domain**: infinity-node.com (managed via Cloudflare)

## Critical Services

These services affect multiple household users and must maintain maximum uptime:

- **Emby** (VM 100): Streaming media server
- **Downloads** (VM 101): Torrent/Usenet with VPN
- **arr Services** (VM 102): Radarr, Sonarr, Lidarr, Prowlarr

All other services are important but primarily affect only the system owner.

## Secret Management

**Secrets MUST NOT be committed to this repository.**

- Use `.env` files on VMs (gitignored)
- Store credentials in Vaultwarden
- Templates use `.env.example` files
- See [[docs/agents/SECURITY|Security Agent]] for details

## Getting Started

### Working with Claude Code

1. Read [[docs/CLAUDE|Claude Code Guide]] for best practices
2. Understand the [[docs/agents/README|Agent System]]
3. Check [[DASHBOARD|Task Dashboard]] for current work
4. Follow agent guidelines for your task type

### Deploying a New Service

1. Create task in `tasks/backlog/` using template
2. [[docs/agents/SECURITY|Security Agent]]: Set up secrets
3. [[docs/agents/DOCKER|Docker Agent]]: Create docker-compose
4. [[docs/agents/TESTING|Testing Agent]]: Validate deployment
5. [[docs/agents/DOCUMENTATION|Documentation Agent]]: Document service

### Making Changes

1. Create or update MDTD task
2. Follow agent guidelines for change type
3. Test changes before production deployment
4. Update documentation
5. Mark task complete

## Documentation

- [[docs/CLAUDE|Claude Code Guide]]: How to work with Claude Code
- [[docs/ARCHITECTURE|Architecture]]: Infrastructure architecture
- [[docs/DECISIONS|Decisions]]: Architectural decision records
- [[docs/agents/README|Agent System]]: Specialized agent roles
- [[tasks/README|MDTD System]]: Task management system

## Contributing

This is a personal infrastructure project, but follows best practices:

1. All changes tracked via MDTD tasks
2. Documentation kept current
3. Secrets never committed
4. Critical services treated with care
5. Testing before production deployment

## Tools & Technologies

- **Hypervisor**: Proxmox VE
- **Containers**: Docker + Docker Compose
- **Management**: Portainer
- **Updates**: Watchtower
- **Tunnels**: Pangolin (with newt clients)
- **VPN**: NordVPN (NordLynx)
- **Documentation**: Obsidian (optional)
- **Task Management**: MDTD with Dataview

## License

This is personal infrastructure configuration. Use at your own risk.

## References

- **Proxmox**: https://www.proxmox.com/
- **Portainer**: https://www.portainer.io/
- **Pangolin**: https://github.com/fosrl/pangolin
- **Obsidian**: https://obsidian.md/
- **Dataview**: https://blacksmithgu.github.io/obsidian-dataview/
