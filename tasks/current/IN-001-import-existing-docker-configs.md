---
type: task
task-id: IN-001
status: in-progress
priority: high
category: docker
agent: docker
created: 2025-10-25
updated: 2025-10-26
tags:
  - task
  - docker
  - infrastructure
  - documentation
---

# Task: IN-001 - Import Existing Docker Configurations from VMs

**✅ UNBLOCKED:** [[setup-vaultwarden-secret-storage]] completed - ready to import configs.

**Current Phase:** VM 103 ✅, VM 100 ✅, and VM 101 ✅ complete. Ready for VM 102.

## Progress Summary

**Phase 1: VM 103 All Stacks** ✅ COMPLETE
- ✅ vaultwarden stack imported (docker-compose.yml, .env.example, README.md)
- ✅ paperless-ngx stack imported (docker-compose.yml, .env.example, README.md)
- ✅ portainer stack imported (docker-compose.yml, .env.example, README.md)
- ✅ watchtower stack imported (multi-VM deployment documented)
- ✅ audiobookshelf stack imported (separated from newt)
- ✅ newt stack imported (Pangolin tunnel client)
- ✅ homepage stack imported (dashboard)
- ✅ navidrome stack imported (music server)
- ✅ immich stack imported (photo management with AI/ML)
- ✅ linkwarden stack imported (bookmark manager)
- ✅ Secrets documented in README files with Vaultwarden references
- ✅ Secret management utilities created (create/update/delete-secret.sh)
- ✅ stacks/README.md created with deployment workflows
- ✅ Portainer Git integration documented
- ✅ Migration task created (migrate-portainer-to-monorepo)
- ✅ Obsidian metadata added to all 10 stack READMEs

**Commits:**
- `3f9b9b5` feat(stacks): import VM 103 priority stacks
- `508c80e` feat(scripts): add secret management utilities for Vaultwarden
- `2b656a9` docs(stacks): add Portainer Git integration guide and migration task
- `752ac2c` feat(stacks): import remaining VM 103 service stacks
- `6e2311e` docs(stacks): add Obsidian metadata frontmatter to all stack READMEs
- `00997d4` feat(tasks): implement task ID labeling system (IN-NNN)

**Phase 2: VM 100 (emby)** ✅ COMPLETE
- ✅ emby stack imported (CRITICAL service - household media streaming)
- ✅ Comprehensive documentation with hardware transcoding setup
- ✅ Obsidian metadata with critical priority designation
- ✅ Change management notes for household-impacting service
- ✅ Updated newt documentation for multi-VM deployment
- ✅ Validated docker-compose syntax

**Commits:**
- `d3c5bce` feat(stacks): import emby stack from VM 100

**Phase 3: VM 101 (downloads)** ✅ COMPLETE
- ✅ downloads stack imported (CRITICAL service - VPN-protected downloads)
- ✅ VPN kill switch architecture documented
- ✅ NordLynx (NordVPN WireGuard) configuration
- ✅ Deluge and NZBGet setup with network_mode: container:vpn
- ✅ Obsidian metadata with critical priority designation
- ✅ Secrets documented for Vaultwarden (PRIVATE_KEY, credentials)
- ✅ Validated docker-compose syntax

**Commits:**
- `a9d919a` feat(stacks): import downloads stack from VM 101

**Next Phase:** Import stacks from VM 102 (arr services - final VM)

**Architecture Decision:** Hybrid approach - Git as source of truth, Portainer as management interface:
- Git repository contains all docker-compose.yml configurations (version controlled)
- Vaultwarden stores all secrets in infinity-node organization collections
- Portainer manages deployments via Git integration (pulls from repo at specific paths)
- Secret management scripts enable automation without hardcoding values
- Enables: disaster recovery, automated deployment, Infrastructure as Code
- Migration path: [[tasks/backlog/migrate-portainer-to-monorepo]] for automated Portainer config updates

## Description

Import all existing Docker Compose configurations from the 4 VMs (100-103) into the repository's stacks/ directory structure. This includes docker-compose.yml files, environment configurations, and documentation for each service stack.

This task establishes the foundation for version control, secret management, infrastructure-as-code practices, and future Portainer Git integration.

## Context

Currently, all Docker services are running on VMs but their configurations are not version controlled in this repository. Before we can:
- Migrate secrets to .env files (migrate-secrets-to-env task)
- Automate deployments
- Track configuration changes
- Document service dependencies

We need to import the existing configurations into the proper structure.

## Acceptance Criteria

### Directory Structure
- [x] Create stacks/ directory in repository root
- [x] Create subdirectory for each major service stack
- [x] Follow consistent naming convention (lowercase, hyphenated)
- [x] Document directory structure in stacks/README.md

### Import Configurations from VMs

**VM 100 (emby):** ✅ COMPLETE
- [x] Import emby stack (docker-compose.yml)
- [x] Portainer documented (multi-VM deployment)
- [x] Watchtower documented (multi-VM deployment)
- [x] Newt documented (separate instance with unique credentials)
- [x] Document all services

**VM 101 (downloads):** ✅ COMPLETE
- [x] Import downloads stack (VPN + Deluge + NZBGet)
- [x] Portainer documented (multi-VM deployment)
- [x] Watchtower documented (multi-VM deployment)
- [x] Document all services and VPN kill switch architecture

**VM 102 (arr):**
- [ ] Import arr stack (Radarr, Sonarr, Lidarr, Prowlarr)
- [ ] Import jellyseerr stack
- [ ] Import flaresolverr stack
- [ ] Import huntarr stack
- [ ] Import portainer stack
- [ ] Import watchtower stack
- [ ] Import pangolin/newt stack
- [ ] Document all services and integrations

**VM 103 (misc):** ✅ COMPLETE
- [x] Import vaultwarden stack
- [x] Import paperless-ngx stack
- [x] Import immich stack
- [x] Import linkwarden stack
- [x] Import navidrome stack
- [x] Import audiobookshelf stack
- [x] Import homepage stack
- [x] Import portainer stack
- [x] Import watchtower stack
- [x] Import newt stack (separated from audiobookshelf)
- [x] Document all services
- [x] Add Obsidian metadata to all stack READMEs

### Environment Files
- [x] Create .env.example for each stack (all VM 103 stacks)
- [x] Document required environment variables with Vaultwarden references
- [x] DO NOT commit actual .env files with secrets (verified via gitignore)
- [x] Add .env to .gitignore if not already present
- [x] Create .env.example for all VM 103 stacks

### Documentation
- [x] Create README.md for each stack explaining:
  - Purpose of the service
  - Configuration options
  - Volume mounts
  - Network dependencies
  - Access URLs
  - Integration points
- [x] Create stacks/README.md with overview and Portainer Git integration guide
- [ ] Update ARCHITECTURE.md with stack references
- [x] Document which VM each stack runs on (in individual README files)

### Validation
- [x] Verify all docker-compose.yml files are valid syntax (all VM 103 stacks validated)
- [x] Ensure no secrets are committed to git (verified - no secrets in commits)
- [x] All VM 103 stacks validated with `docker compose config`
- [ ] Test that imported configs match running services (VM 100, 101, 102)
- [ ] Document any discrepancies found

## Dependencies

- SSH access to all VMs (evan user) ✅
- Understanding of Docker Compose syntax
- Knowledge of which services run on which VMs (documented in ARCHITECTURE.md)
- Access to running containers to compare configurations

## Testing Plan

[[docs/agents/TESTING|Testing Agent]] should validate:
- All docker-compose.yml files have valid syntax (`docker compose config`)
- No secrets present in committed files
- README files exist for each stack
- .env.example files document all required variables
- Imported configs accurately represent running services

**Manual validation:**
```bash
# For each stack
cd stacks/stack-name
docker compose config  # Validates syntax

# Compare with running config on VM
ssh evan@VM_IP "cd path/to/service && docker compose config"
```

## Related Documentation

- [[docs/ARCHITECTURE|Architecture]] - Service locations
- [[docs/agents/DOCKER|Docker Agent]] - Docker best practices
- [[tasks/current/IN-002-migrate-secrets-to-env|IN-002]] - Blocks this task
- [[docs/DECISIONS|Decisions]] - ADR-002 (Docker for Services)

## Notes

### Suggested Stacks Structure

```
stacks/
├── README.md                    # Overview of all stacks
├── emby/                        # VM 100
│   ├── docker-compose.yml
│   ├── .env.example
│   └── README.md
├── downloads/                   # VM 101
│   ├── docker-compose.yml       # VPN + Deluge + NZBGet
│   ├── .env.example
│   └── README.md
├── arr/                         # VM 102
│   ├── docker-compose.yml       # Radarr + Sonarr + Lidarr + Prowlarr
│   ├── .env.example
│   └── README.md
├── jellyseerr/                  # VM 102
│   ├── docker-compose.yml
│   ├── .env.example
│   └── README.md
├── vaultwarden/                 # VM 103
│   ├── docker-compose.yml
│   ├── .env.example
│   └── README.md
├── paperless-ngx/               # VM 103
│   ├── docker-compose.yml
│   ├── .env.example
│   └── README.md
├── immich/                      # VM 103
│   ├── docker-compose.yml
│   ├── .env.example
│   └── README.md
├── shared/                      # Common stacks
│   ├── portainer/
│   │   ├── docker-compose.yml
│   │   └── README.md
│   ├── watchtower/
│   │   ├── docker-compose.yml
│   │   └── README.md
│   └── pangolin/
│       ├── docker-compose.yml
│       ├── .env.example
│       └── README.md
└── ...
```

### Stack Grouping Strategy

**Option 1: By VM** (one stack per VM)
- Pros: Matches deployment reality, easier to deploy whole VM
- Cons: Large compose files, harder to understand individual services

**Option 2: By Service** (one stack per service/group)
- Pros: Clearer separation, easier to understand, reusable
- Cons: More directories, need to document which VM

**Recommendation:** Use Option 2 (by service) because:
- Better for documentation and understanding
- Services can be moved between VMs more easily
- README can specify target VM
- More modular and maintainable

### Finding Existing Configs

On each VM, likely locations:
```bash
# Most likely location
/home/evan/projects/infinity-node/stacks/

# Other possible locations
~/docker/
~/services/
~/stacks/
~/compose/
/opt/docker/

# Find all docker-compose.yml files
find /home/evan -name "docker-compose.yml" -o -name "compose.yml"

# Check running containers for their compose files
docker ps --format "{{.Label \"com.docker.compose.project.config_files\"}}"
```

### Import Process

For each service:
1. SSH to VM and locate docker-compose.yml
2. Copy to local stacks/ directory
3. Create .env.example from .env (if exists)
4. Strip secrets from docker-compose.yml
5. Create README.md documenting the service
6. Validate syntax locally
7. Git commit

### Secrets to Watch For

When creating .env.example files, replace these with placeholders:
- API keys (e.g., `API_KEY=your_api_key_here`)
- Passwords (e.g., `DB_PASSWORD=your_password_here`)
- Tokens (e.g., `AUTH_TOKEN=your_token_here`)
- Pangolin client IDs/secrets
- Database connection strings with credentials

### Post-Import Tasks

After import is complete:
1. Update migrate-secrets-to-env task with actual stacks
2. Create deployment runbooks referencing these stacks
3. Consider automation for deployment
4. Document service dependencies between stacks

### Priority Rationale

High priority because:
- Blocks migrate-secrets-to-env task
- Foundation for version control and IaC
- Critical for disaster recovery
- Needed for documentation tasks
- Required for automation efforts

---

## Session Accomplishments (2025-10-26)

### Infrastructure & Tooling Created
1. **Secret Management Scripts** (3 reusable utilities):
   - `scripts/create-secret.sh` - Create secrets in Vaultwarden (org or personal)
   - `scripts/update-secret.sh` - Update existing secrets
   - `scripts/delete-secret.sh` - Delete secrets with confirmation
   - All scripts default to infinity-node organization
   - Support `--personal` flag for personal vault items

2. **Stack Imports** (VM 103 Priority):
   - `stacks/vaultwarden/` - Password manager with admin token
   - `stacks/paperless-ngx/` - Document management (PostgreSQL + Redis)
   - `stacks/portainer/` - Docker management UI
   - Each includes: docker-compose.yml, .env.example, README.md

3. **Documentation**:
   - `stacks/README.md` - Comprehensive deployment guide with Portainer Git integration
   - Portainer configuration steps with monorepo setup
   - GitOps automatic update documentation
   - Secret retrieval workflows

4. **Migration Planning**:
   - `tasks/backlog/migrate-portainer-to-monorepo.md` - Full automation plan
   - Portainer API research complete
   - Access token creation procedure documented
   - API-based stack configuration update strategy

### Secrets Migrated to Vaultwarden
- ✅ `vaultwarden-admin-token` → infinity-node/vm-103-misc
- ✅ `paperless-secrets` → infinity-node/vm-103-misc (3 custom fields)

### Git Commits
- `3f9b9b5` - feat(stacks): import VM 103 priority stacks
- `508c80e` - feat(scripts): add secret management utilities for Vaultwarden
- `2b656a9` - docs(stacks): add Portainer Git integration guide and migration task

## Next Steps

### Immediate (Continue VM 103)
1. Import remaining VM 103 stacks:
   - immich (photo management)
   - linkwarden (bookmark manager)
   - audiobookshelf (audiobook server)
   - homepage (dashboard)
   - navidrome (music server)
   - watchtower (auto-updater)
   - pangolin/newt (tunnel system)

2. For each stack:
   - SSH to VM 103, locate docker-compose.yml
   - Import to `stacks/<service>/`
   - Create .env.example with Vaultwarden references
   - Document in README.md
   - Store secrets in Vaultwarden using create-secret.sh
   - Validate with `docker compose config`
   - Commit to git

### Medium Term (Other VMs)
1. Import VM 100 (emby) stacks
2. Import VM 102 (arr) stacks
3. Import VM 101 (downloads) stacks

### Long Term (Automation)
1. Create Portainer API tokens for each VM
2. Store tokens in Vaultwarden
3. Build migration scripts (as outlined in migrate-portainer-to-monorepo task)
4. Migrate all Portainer configurations to monorepo
5. Enable GitOps automatic updates
6. Archive old individual repos

## Related Tasks
- [[tasks/current/setup-vaultwarden-secret-storage]] - ✅ COMPLETE (prerequisite)
- [[tasks/backlog/migrate-portainer-to-monorepo]] - READY (follow-up automation)
- Update ARCHITECTURE.md with stack references (pending)
