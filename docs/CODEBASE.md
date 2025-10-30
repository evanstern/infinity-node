---
type: documentation
tags:
  - reference
  - structure
  - quick-guide
---

# infinity-node Codebase Quick Reference

> **Purpose:** Quick reference for AI assistants queried via `@Codebase`. Optimized for fast comprehension.

## Project Overview

**What:** Proxmox-based home server infrastructure running containerized services
**Goal:** Reliable media services + supporting apps, fully documented and automated
**Stack:** Proxmox → VMs → Docker → Services

## Directory Structure

```
infinity-node/
├── docs/                          # All documentation
│   ├── agents/                    # Agent system specifications
│   │   ├── README.md             # Agent overview
│   │   ├── TESTING.md            # Read-only validation agent
│   │   ├── DOCKER.md             # Container orchestration
│   │   ├── INFRASTRUCTURE.md     # Proxmox, VMs, storage
│   │   ├── SECURITY.md           # Secrets, tunnels, VPN
│   │   ├── MEDIA.md              # Critical media services
│   │   └── DOCUMENTATION.md      # Knowledge management
│   ├── adr/                       # Architectural Decision Records
│   ├── runbooks/                  # Operational procedures
│   ├── CLAUDE.md                  # AI collaboration guide
│   ├── CURSOR.md                  # Cursor IDE usage guide
│   ├── CODEBASE.md                # This file
│   ├── ARCHITECTURE.md            # Infrastructure architecture
│   ├── DECISIONS.md               # Key architectural decisions
│   ├── SECRET-MANAGEMENT.md       # Secret management practices
│   └── VM-CONFIGURATION.md        # VM setup documentation
│
├── tasks/                         # MDTD task management
│   ├── current/                   # Active tasks (in-progress)
│   ├── backlog/                   # Pending tasks
│   ├── completed/                 # Finished tasks
│   ├── DASHBOARD.md               # Task overview
│   └── README.md                  # MDTD system explanation
│
├── stacks/                        # Docker compose configurations
│   ├── emby/                      # Media server (CRITICAL)
│   ├── downloads/                 # Download clients (CRITICAL)
│   ├── radarr/                    # Movie automation (CRITICAL)
│   ├── sonarr/                    # TV automation (CRITICAL)
│   ├── lidarr/                    # Music automation (CRITICAL)
│   ├── prowlarr/                  # Indexer management (CRITICAL)
│   ├── vaultwarden/               # Password manager
│   ├── paperless-ngx/             # Document management
│   ├── immich/                    # Photo management
│   └── [others]/                  # Supporting services
│   │
│   └── [each stack contains]
│       ├── docker-compose.yml     # Service definition
│       ├── .env.example           # Secret template
│       └── README.md              # Service documentation
│
├── scripts/                       # Automation scripts
│   ├── backup/                    # Backup automation
│   ├── deployment/                # Deployment scripts
│   ├── infrastructure/            # Stack management
│   ├── secrets/                   # Secret management scripts
│   ├── setup/                     # Initial setup scripts
│   ├── utils/                     # Utility scripts
│   ├── validation/                # Health checks
│   └── README.md                  # Script documentation
│
├── ansible/                       # Configuration management
│   ├── playbooks/                 # Ansible playbooks
│   ├── roles/                     # Ansible roles
│   └── inventory/                 # VM inventory
│
├── config/                        # Configuration templates
│   └── vm-template/               # VM setup configs
│
├── .obsidian/                     # Obsidian vault configuration
│   └── templates/                 # Document templates
│
├── .cursorrules                   # Cursor AI configuration
├── .cursorignore                  # Cursor indexing exclusions
├── .gitignore                     # Git exclusions
└── README.md                      # Project README
```

## Critical Services (99.9% uptime target)

**VM 100 (emby)** - `192.168.86.172`
- Emby media server - Primary household service
- Portainer CE - Container management
- Watchtower - Auto-updates
- Pangolin tunnel (newt) - External access

**VM 101 (downloads)** - `192.168.86.173`
- Downloads stack (NordVPN + Deluge + NZBGet)
- ALL traffic through VPN with kill switch
- 4TB passthrough disk for active downloads

**VM 102 (arr)** - `192.168.86.174`
- Radarr (movies), Sonarr (TV), Lidarr (music)
- Prowlarr (indexer aggregation)
- Jellyseerr (request management)
- Flaresolverr (Cloudflare bypass)
- Pangolin tunnel (newt)

**VM 103 (misc)** - `192.168.86.249`
- Vaultwarden (password manager - source of truth for secrets)
- Paperless-NGX (documents)
- Immich (photos)
- Linkwarden (bookmarks)
- Supporting services
- Pangolin tunnel (newt)

## Key Conventions

### Agent System
Six specialized agents handle different domains:
- **Testing Agent** → Read-only validation (uses `inspector` user)
- **Docker Agent** → Container orchestration
- **Infrastructure Agent** → Proxmox, VMs, networking
- **Security Agent** → Secrets, tunnels, security
- **Media Stack Agent** → Critical media services (extra careful!)
- **Documentation Agent** → Knowledge management, MDTD tasks

See: `docs/agents/README.md`

### MDTD Task Management
- **Task IDs:** Format `IN-NNN` (e.g., IN-001, IN-024)
- **Lifecycle:** `backlog/` → `current/` (in-progress) → `completed/`
- **Workflow:**
  1. Start: Update status to `in-progress`, move to `current/`
  2. During: Check off criteria real-time, pause after each phase
  3. Complete: Present for review → wait for approval → mark complete
- **Files:** Markdown with frontmatter metadata

See: `docs/CLAUDE.md` sections on MDTD

### Secret Management
- **Source of Truth:** Vaultwarden on VM 103 (192.168.86.249:8111)
- **NEVER commit:** Passwords, API keys, tokens, `.env` files
- **Always commit:** `.env.example` templates (no real secrets)
- **Access:** Bitwarden CLI requires user-provided session token
- **Storage:** `.env` files on VMs (gitignored)

See: `docs/SECRET-MANAGEMENT.md`

### Git Workflow
- **NEVER commit without user approval**
- **NEVER push without user approval**
- Use conventional commit format
- Reference task IDs in commits: "Addresses IN-024"
- Use `git mv` to move files (avoids duplicates)

### SSH Access
- **Proxmox:** `root@192.168.86.106`
- **VMs (full):** `evan@<VM_IP>` (passwordless sudo for automation)
- **VMs (read-only):** `inspector@<VM_IP>` (Testing Agent only)

### Documentation
- **Wiki-links:** Use `[[DOCKER]]` not `[Docker](DOCKER.md)` (Obsidian vault)
- **Frontmatter:** All docs have YAML frontmatter for Dataview
- **Location:**
  - `docs/` - Project-wide documentation
  - `.docs/` - Context-specific documentation alongside code

## Common Operations

### Working on Tasks
```bash
/task IN-XXX          # Load and begin task
# AI automatically:
# - Updates status to in-progress
# - Moves from backlog/ to current/
# - Begins work, checking off criteria
# - Pauses after each phase to document
# - Presents for review before marking complete
```

### Deploying Services
```bash
# 1. Security: Create .env on VM (from Vaultwarden)
# 2. Docker: Create stack in stacks/service-name/
# 3. Deploy: SSH to VM, docker compose up -d
# 4. Testing: Validate with Testing Agent
# 5. Document: Update docs, complete task
```

### Managing Secrets
```bash
# Retrieve from Vaultwarden:
BW_SESSION="<token>" bw get password "service-secret"

# Never commit actual secrets
# Always use .env.example templates
```

### Finding Information
- **Architecture:** `docs/ARCHITECTURE.md`
- **Agents:** `docs/agents/README.md`
- **Tasks:** `tasks/DASHBOARD.md`
- **Decisions:** `docs/DECISIONS.md`
- **Secrets:** `docs/SECRET-MANAGEMENT.md`
- **Cursor usage:** `docs/CURSOR.md`
- **AI collaboration:** `docs/CLAUDE.md`

## Safety Rules

### Critical Services
- **Test first** when possible
- **Backup** configurations before changes
- **Deploy** during low-usage windows (3-6 AM)
- **Rollback plan** always ready
- **Monitor** closely after changes
- **Coordinate** with Testing Agent

### Security
- No secrets in git
- All secrets in Vaultwarden
- `.env` files gitignored
- Session tokens never committed
- SSH key-based auth only

### Git
- Always ask approval before commit
- Always ask approval before push
- Logical units of work
- Reference task IDs
- Use conventional commits

## Quick Reference

### VM IPs
- Proxmox: 192.168.86.106
- VM 100 (emby): 192.168.86.172
- VM 101 (downloads): 192.168.86.173
- VM 102 (arr): 192.168.86.174
- VM 103 (misc): 192.168.86.249
- NAS: 192.168.86.43

### Portainer Access
- VM 100: https://192.168.86.172:9443
- VM 101: https://192.168.86.173:32768 (non-standard port!)
- VM 102: https://192.168.86.174:9443
- VM 103: https://192.168.86.249:9443

### Storage
- NAS: 57TB Synology at 192.168.86.43
- Mount: `192.168.86.43:/volume1/infinity-node`
- Media: `/volume1/infinity-node/media/`
- Downloads: `/volume1/infinity-node/downloads/`
- Configs: `/volume1/infinity-node/configs/`

## When Things Go Wrong

### Container Issues
```bash
ssh evan@<VM_IP>
docker ps -a                    # Check status
docker logs <container> --tail 100
docker compose restart <service>
```

### Secret Issues
- Check Vaultwarden: http://192.168.86.249:8111 (local) or https://vaultwarden.infinity-node.com
- Verify `.env` file exists on VM
- Check `.env` format matches `.env.example`

### Task Issues
- Check current tasks: `ls tasks/current/`
- Review task file for acceptance criteria
- Check work log for progress notes

---

**For detailed information, see:**
- Full documentation in `docs/` directory
- Task management in `tasks/` directory
- Specific agent guides in `docs/agents/`
