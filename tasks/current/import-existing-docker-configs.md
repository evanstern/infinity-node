---
type: task
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

# Task: Import Existing Docker Configurations from VMs

**✅ UNBLOCKED:** [[setup-vaultwarden-secret-storage]] completed - ready to import configs.

**Current Phase:** Importing VM 103 (misc) stacks first, then VM 100, 102, 101.

**Architecture Decision:** Hybrid approach - Git as source of truth, Portainer as management interface:
- Git repository contains all docker-compose.yml configurations (version controlled)
- Vaultwarden stores all secrets (retrieved during deployment)
- Portainer manages deployments via Git integration (pulls from repo)
- Enables: disaster recovery, automated deployment, Infrastructure as Code
- Future task: Configure Portainer Git integration on each VM

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
- [ ] Create stacks/ directory in repository root
- [ ] Create subdirectory for each major service stack
- [ ] Follow consistent naming convention (lowercase, hyphenated)
- [ ] Document directory structure in stacks/README.md

### Import Configurations from VMs

**VM 100 (emby):**
- [ ] Import emby stack (docker-compose.yml)
- [ ] Import portainer stack
- [ ] Import watchtower stack
- [ ] Import pangolin/newt stack
- [ ] Document all services

**VM 101 (downloads):**
- [ ] Import downloads stack (VPN + Deluge + NZBGet)
- [ ] Import portainer stack
- [ ] Import watchtower stack
- [ ] Document all services and network dependencies

**VM 102 (arr):**
- [ ] Import arr stack (Radarr, Sonarr, Lidarr, Prowlarr)
- [ ] Import jellyseerr stack
- [ ] Import flaresolverr stack
- [ ] Import huntarr stack
- [ ] Import portainer stack
- [ ] Import watchtower stack
- [ ] Import pangolin/newt stack
- [ ] Document all services and integrations

**VM 103 (misc):**
- [ ] Import vaultwarden stack
- [ ] Import paperless-ngx stack
- [ ] Import immich stack
- [ ] Import linkwarden stack
- [ ] Import navidrome stack
- [ ] Import audiobookshelf stack
- [ ] Import homepage stack
- [ ] Import portainer stack
- [ ] Import watchtower stack
- [ ] Import pangolin/newt stack
- [ ] Document all services

### Environment Files
- [ ] Create .env.example for each stack
- [ ] Document required environment variables
- [ ] DO NOT commit actual .env files with secrets
- [ ] Add .env to .gitignore if not already present

### Documentation
- [ ] Create README.md for each stack explaining:
  - Purpose of the service
  - Configuration options
  - Volume mounts
  - Network dependencies
  - Access URLs
  - Integration points
- [ ] Create stacks/README.md with overview
- [ ] Update ARCHITECTURE.md with stack references
- [ ] Document which VM each stack runs on

### Validation
- [ ] Verify all docker-compose.yml files are valid syntax
- [ ] Ensure no secrets are committed to git
- [ ] Test that imported configs match running services
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
- [[migrate-secrets-to-env]] - Blocks this task
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
