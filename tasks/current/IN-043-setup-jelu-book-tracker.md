---
type: task
task-id: IN-043
status: in-progress
started: 2025-01-27
priority: 4
category: docker
agent: docker
created: 2025-01-27
updated: 2025-01-27

# Task classification
complexity: moderate
estimated_duration: 3-4h
critical_services_affected: false
requires_backup: false
requires_downtime: false

# Design tracking
alternatives_considered: true
risk_assessment_done: true
phased_approach: true

tags:
  - task
  - docker
  - vm-103
  - jelu
  - book-tracker
  - backup
  - pangolin
---

# Task: IN-043 - Setup Jelu Book Tracker

> **Quick Summary**: Deploy Jelu self-hosted book tracker on VM-103 with daily database backups and Pangolin external access

## Problem Statement

**What problem are we solving?**
Need a self-hosted book tracking solution to replace or complement Goodreads. Jelu provides a personal book tracker with read/to-read lists, reviews, and import capabilities, ensuring data control and privacy.

**Why now?**
- Want to track reading progress and maintain reading history
- Prefer self-hosted solution over Goodreads for data privacy
- VM-103 has capacity for additional misc services
- Backup infrastructure pattern already established (Vaultwarden)

**Who benefits?**
- **User**: Personal book tracking with data control
- **System**: Consistent service deployment pattern
- **Future users**: Foundation for additional reading-related services

## Solution Design

### Recommended Approach

**Deploy Jelu using Docker Compose on VM-103 following established patterns:**

**Key components:**
1. **Docker Stack**: Create `stacks/jelu/` with docker-compose.yml following existing service patterns
2. **Database Backup**: Create backup script following Vaultwarden pattern (`/home/evan/scripts/backup-jelu.sh`)
3. **Automated Backups**: Configure cron job for daily backups to `/mnt/video/backups/jelu/`
4. **Pangolin Resource**: Configure external access via Pangolin (newt client already running on VM-103)
5. **Portainer Integration**: Deploy via Portainer with Git integration

**Configuration details:**
- **Image**: `wabayang/jelu:latest`
- **Port**: 11111 (default from Jelu docs)
- **Volumes** (local VM storage, backed up to NAS):
  - `/config` → `/home/evan/data/jelu/config`
  - `/database` → `/home/evan/data/jelu/database`
  - `/files/images` → `/home/evan/data/jelu/files/images`
  - `/files/imports` → `/home/evan/data/jelu/files/imports`
- **Backup**: Daily at 2 AM (following Vaultwarden schedule)
- **Backup source**: `/home/evan/data/jelu/database/` (local VM)
- **Backup destination**: `/mnt/video/backups/jelu/` (NAS)
- **Deployment**: Portainer Git stack on VM-103 (GitHub integration)
- **Environment variables**: Configured in Pangolin (not .env file)

**Rationale**: Following established patterns ensures consistency, maintainability, and leverages existing infrastructure. Data stored locally on VM for performance, backed up to NAS for resilience. Using Portainer Git integration maintains single source of truth. Environment variables in Pangolin provide centralized management without .env file drift.

> [!abstract]- 🔀 Alternative Approaches Considered
>
> **Option A: Deploy without backups initially**
> - ✅ Pros: Faster initial deployment
> - ❌ Cons: Risk of data loss, need to add backups later anyway
> - **Decision**: Not chosen - backups are critical and pattern exists
>
> **Option B: Use different backup location**
> - ✅ Pros: Could use local VM storage
> - ❌ Cons: Doesn't follow established pattern, less resilient
> - **Decision**: Not chosen - NAS backup pattern is proven and resilient
>
> **Option C: Manual backup only**
> - ✅ Pros: Simpler, no cron job needed
> - ❌ Cons: Easy to forget, not reliable
> - **Decision**: Not chosen - automated backups are essential for data protection

### Scope Definition

**✅ In Scope:**
- Docker Compose stack creation and deployment
- Daily automated database backups to NAS
- Cron job configuration for backups
- Pangolin resource configuration for external access
- Portainer Git integration setup
- Basic service documentation (README.md)
- Testing and validation

**❌ Explicitly Out of Scope:**
- Goodreads import (can be done manually after deployment)
- Multi-user LDAP configuration (single user initially)
- Custom metadata provider configuration (use defaults)
- ISBN scanning setup (future enhancement)
- Homepage integration (can be added later)

**🎯 MVP (Minimum Viable)**:
Jelu running on VM-103, accessible internally, with daily automated backups and external access via Pangolin. User can add books, track reading status, and import from Goodreads CSV.

## Risk Assessment

### Potential Pitfalls

- ⚠️ **Risk 1: Database corruption during backup** → **Mitigation**: Use SQLite VACUUM INTO (like Vaultwarden backup) or copy with sync, verify integrity before upload

- ⚠️ **Risk 2: Disk space on VM-103** → **Mitigation**: Check disk space before deployment, backups go to NAS (not VM), monitor after deployment

- ⚠️ **Risk 3: Port conflict** → **Mitigation**: Verify port 11111 not in use, check existing services on VM-103

- ⚠️ **Risk 4: Pangolin configuration errors** → **Mitigation**: Follow existing Pangolin resource patterns, test external access after configuration

- ⚠️ **Risk 5: Backup script failures** → **Mitigation**: Include error handling in script, verify cron job runs, check logs regularly

### Dependencies

**Prerequisites (must exist before starting):**
- [x] **VM-103 running** - Already operational
- [x] **Docker/Portainer** - Already installed and running
- [x] **NAS mounts** - `/mnt/video` already mounted
- [x] **Newt client** - Already running on VM-103
- [x] **Backup script pattern** - Vaultwarden backup provides template
- [x] **SSH access** - Already configured

**No blocking dependencies - can start immediately**

### Critical Service Impact

**Services Affected**: None

This is a new service deployment on VM-103 (misc services). No impact on critical services (Emby, downloads, arr). VM-103 already hosts multiple non-critical services.

### Rollback Plan

**Applicable for**: Docker deployment

**How to rollback if this goes wrong:**
1. Stop Jelu container via Portainer
2. Remove stack from Portainer
3. Remove docker-compose.yml from git (if needed)
4. Remove backup script and cron job (if configured)
5. Remove Pangolin resource (if configured)

**Recovery time estimate**: < 5 minutes (simple container removal)

**Backup requirements:**
- No backups needed before deployment (new service)
- After deployment: Database backups will be automated

## Execution Plan

### Phase 0: Discovery/Inventory

**Primary Agent**: `docker`

- [ ] **Verify VM-103 resources** `[agent:infrastructure]`
  - Check disk space availability
  - Verify port 11111 not in use
  - Confirm NAS mount `/mnt/video` accessible

- [ ] **Review backup script pattern** `[agent:docker]`
  - Examine Vaultwarden backup script structure
  - Understand SQLite backup approach
  - Note cron job configuration

- [ ] **Review Pangolin setup** `[agent:security]`
  - Check existing newt client configuration on VM-103
  - Understand Pangolin resource creation process
  - Review existing service external access patterns

### Phase 1: Docker Stack Creation

**Primary Agent**: `docker`

- [ ] **Create stack directory** `[agent:docker]`
  - Create `stacks/jelu/` directory
  - Create `docker-compose.yml` following service patterns
  - Create `.env.example` template (for documentation - actual env vars in Pangolin)

- [ ] **Configure volumes** `[agent:docker]`
  - Set up config volume: `/home/evan/data/jelu/config` (local VM)
  - Set up database volume: `/home/evan/data/jelu/database` (local VM)
  - Set up files volumes: `/home/evan/data/jelu/files/images` and `/home/evan/data/jelu/files/imports` (local VM)
  - Ensure directories exist with correct permissions (evan:evan)
  - Note: Data stored locally, backed up to NAS daily

- [ ] **Configure environment** `[agent:docker]`
  - Set port: 11111
  - Set timezone: TZ environment variable
  - Configure restart policy: unless-stopped

- [ ] **Create README.md** `[agent:documentation]`
  - Document service purpose and features
  - Document volume mounts and paths
  - Document port and access information
  - Document backup procedure

### Phase 2: Backup Script & Automation

**Primary Agent**: `docker`

- [ ] **Create backup script** `[agent:docker]`
  - Create `/home/evan/scripts/backup-jelu.sh` on VM-103
  - Follow Vaultwarden backup script pattern (`/home/evan/scripts/backup-vaultwarden.sh`)
  - Identify database file location (likely `/home/evan/data/jelu/database/db.sqlite3` or similar)
  - Backup source: Database file from local VM storage
  - Backup destination: `/mnt/video/backups/jelu/` (NAS)
  - Use SQLite backup approach (VACUUM INTO or copy+sync)
  - Include integrity verification (SQLite PRAGMA integrity_check)
  - Include error handling and logging
  - Include retention policy (30 days, like Vaultwarden)
  - Make script executable

- [ ] **Configure cron job** `[agent:infrastructure]`
  - Add cron entry for user `evan`
  - Schedule: Daily at 2 AM (same as Vaultwarden)
  - Log to `/var/log/jelu-backup.log`
  - Test cron job execution

- [ ] **Test backup script** `[agent:testing]`
  - Run backup script manually
  - Verify backup file created
  - Verify backup integrity
  - Verify backup location correct

### Phase 3: Deployment

**Primary Agent**: `docker`

- [ ] **Deploy via Portainer** `[agent:docker]`
  - Create Git stack in Portainer on VM-103
  - Point to GitHub repository `stacks/jelu/docker-compose.yml`
  - Configure environment variables in Pangolin (not .env file)
  - Note: `.env.example` serves as documentation reference only
  - Deploy stack via Portainer
  - Verify container starts successfully

- [ ] **Verify service** `[agent:testing]`
  - Check container health
  - Verify service accessible at `http://192.168.86.249:11111`
  - Test basic functionality (add book, view interface)
  - Check logs for errors

### Phase 4: Pangolin Configuration

**Primary Agent**: `security`

- [ ] **Create Pangolin resource** `[agent:security]`
  - Configure resource in Pangolin server
  - Set up subdomain (e.g., `jelu.infinity-node.com`)
  - Configure to point to `http://localhost:11111` on VM-103
  - Test external access

- [ ] **Verify external access** `[agent:testing]`
  - Access service via Pangolin URL
  - Verify authentication works
  - Test functionality via external access

### Phase 5: Validation & Testing

**Primary Agent**: `testing`

- [ ] **Service validation** `[agent:testing]`
  - Container running and healthy
  - Service accessible internally
  - Service accessible externally via Pangolin
  - Basic functionality works (add book, track reading)

- [ ] **Backup validation** `[agent:testing]`
  - Backup script executes successfully
  - Backup file created in correct location
  - Backup integrity verified
  - Cron job scheduled correctly

- [ ] **Integration validation** `[agent:testing]`
  - Portainer shows stack correctly
  - Git integration working
  - Documentation complete

### Phase 6: Documentation

**Primary Agent**: `documentation`

- [ ] **Update VM configuration docs** `[agent:documentation]`
  - Document Jelu deployment in `docs/VM-CONFIGURATION.md`
  - Document backup script location
  - Document cron job configuration

- [ ] **Update architecture docs** `[agent:documentation]`
  - Add Jelu to VM-103 services list
  - Document external access via Pangolin
  - Update service inventory

## Acceptance Criteria

**Done when all of these are true:**
- [ ] Jelu container running on VM-103
- [ ] Service accessible internally at `http://192.168.86.249:11111`
- [ ] Service accessible externally via Pangolin
- [ ] Daily backup script created and tested
- [ ] Cron job configured and verified
- [ ] Backups being created in `/mnt/video/backups/jelu/`
- [ ] Stack deployed via Portainer with Git integration
- [ ] Documentation complete (README.md, VM config, architecture)
- [ ] All execution plan items completed
- [ ] Testing Agent validates (see testing plan below)
- [ ] Changes committed with descriptive message (awaiting user approval)

## Testing Plan

**[[docs/agents/TESTING|Testing Agent]] validates:**
- Container health check passes
- Service responds on internal port
- Service responds via Pangolin external URL
- Backup script executes without errors
- Backup file created with correct naming
- Cron job entry exists and is scheduled correctly
- Database backup integrity verified

**Manual validation:**
1. Access Jelu web interface internally - should load and be functional
2. Add a test book manually - should save successfully
3. Access Jelu via Pangolin URL externally - should load and authenticate
4. Run backup script manually - should create backup file
5. Verify backup file in `/mnt/video/backups/jelu/` - should exist and be recent
6. Check cron job - should be scheduled for 2 AM daily
7. Verify Portainer shows stack - should be listed and running

## Related Documentation

- [[docs/ARCHITECTURE|Infrastructure Architecture]]
- [[docs/VM-CONFIGURATION|VM Configuration]]
- [[docs/agents/DOCKER|Docker Agent]]
- [[docs/agents/SECURITY|Security Agent]]
- [[docs/adr/004-use-pangolin-for-external-access|ADR-004: Pangolin]]
- [[tasks/completed/IN-017-implement-vaultwarden-backup|IN-017: Vaultwarden Backup Pattern]]
- [[stacks/vaultwarden/README|Vaultwarden Stack Reference]]

## Notes

**Priority Rationale**:
Priority 4 (medium) - Valuable improvement for personal use, not urgent. Fits well with existing misc services on VM-103.

**Complexity Rationale**:
Moderate complexity - Standard Docker deployment with established patterns, but includes backup automation and Pangolin configuration. Estimated 3-4 hours including testing and documentation.

**Implementation Notes**:
- Data stored locally on VM (`/home/evan/data/jelu/`), backed up to NAS daily
- Follow Vaultwarden backup script pattern closely for consistency
- Use same backup schedule (2 AM) to avoid conflicts
- Ensure NAS backup directory exists before deployment
- Environment variables configured in Pangolin (not .env file)
- Deploy via Portainer Git integration on VM-103
- Test Pangolin resource before marking complete
- Consider adding to Homepage dashboard in future task

**Follow-up Tasks**:
- Future: Add Jelu to Homepage dashboard
- Future: Configure Goodreads import
- Future: Set up multi-user if needed
- Future: Configure custom metadata providers

---

> [!note]- 📋 Work Log
>
> *Work log will be updated during task execution*

> [!tip]- 💡 Lessons Learned
>
> *Lessons learned will be captured during task execution*
