---
type: task
task-id: IN-044
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
  - mybibliotheca
  - book-tracker
  - backup
  - pangolin
  - secrets
---

# Task: IN-044 - Setup MyBibliotheca Book Tracker

> **Quick Summary**: Deploy MyBibliotheca self-hosted book tracker on VM-103 with daily database backups, secret management, and Pangolin external access

## Problem Statement

**What problem are we solving?**
Need a self-hosted book tracking solution to replace or complement Goodreads. MyBibliotheca provides a comprehensive personal library management system with reading tracking, multi-user support, and advanced features, ensuring complete data control and privacy.

**Why now?**
- Want to track reading progress and maintain reading history
- Prefer self-hosted solution over Goodreads for data privacy
- VM-103 has capacity for additional misc services
- Backup infrastructure pattern already established (Vaultwarden)
- Previous attempt with Jelu didn't meet requirements

**Who benefits?**
- **User**: Personal book tracking with data control, reading analytics, and multi-user support
- **System**: Consistent service deployment pattern
- **Future users**: Foundation for additional reading-related services

## Solution Design

### Recommended Approach

**Deploy MyBibliotheca using Docker Compose on VM-103 following established patterns:**

**Key components:**
1. **Docker Stack**: Create `stacks/mybibliotheca/` with docker-compose.yml following existing service patterns
2. **Environment Variables**: Pull `.env.example` from https://github.com/pickles4evaaaa/mybibliotheca.git as basis for configuration
3. **Secret Management**: Store SECRET_KEY and SECURITY_PASSWORD_SALT in Vaultwarden
4. **Database Backup**: Create backup script following Vaultwarden pattern (`/home/evan/scripts/backup-mybibliotheca.sh`)
5. **Automated Backups**: Configure cron job for daily backups to `/mnt/video/backups/mybibliotheca/`
6. **Pangolin Resource**: Configure external access via Pangolin (newt client already running on VM-103)
7. **Portainer Integration**: Deploy via Portainer with Git integration

**Configuration details:**
- **Image**: `pickles4evaaaa/mybibliotheca:1.1.1`
- **Port**: 5054 (default from MyBibliotheca docs)
- **Volumes** (local VM storage, backed up to NAS):
  - `/app/data` → `/home/evan/data/mybibliotheca/data` (contains SQLite database and config)
- **Backup**: Daily at 2 AM (following Vaultwarden schedule)
- **Backup source**: `/home/evan/data/mybibliotheca/data/` (local VM)
- **Backup destination**: `/mnt/video/backups/mybibliotheca/` (NAS)
- **Deployment**: Portainer Git stack on VM-103 (GitHub integration)
- **Environment variables**: Configured in Portainer (not .env file)
- **Secrets**: SECRET_KEY and SECURITY_PASSWORD_SALT stored in Vaultwarden

**Rationale**: Following established patterns ensures consistency, maintainability, and leverages existing infrastructure. Data stored locally on VM for performance, backed up to NAS for resilience. Using Portainer Git integration maintains single source of truth. Secrets in Vaultwarden provide secure centralized management.

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
> **Option C: Store secrets in .env file**
> - ✅ Pros: Simpler initial setup
> - ❌ Cons: Secrets in git (even if gitignored), harder to rotate
> - **Decision**: Not chosen - Vaultwarden provides better security and management

### Scope Definition

**✅ In Scope:**
- Docker Compose stack creation and deployment
- Secret management in Vaultwarden (SECRET_KEY, SECURITY_PASSWORD_SALT)
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
- Advanced monitoring/alerting (basic health checks only)

**🎯 MVP (Minimum Viable)**:
MyBibliotheca running on VM-103, accessible internally, with daily automated backups and external access via Pangolin. User can add books, track reading status, import from CSV, and manage reading logs.

## Risk Assessment

### Potential Pitfalls

- ⚠️ **Risk 1: Database corruption during backup** → **Mitigation**: Use SQLite VACUUM INTO (like Vaultwarden backup) or copy+sync, verify integrity before upload

- ⚠️ **Risk 2: Disk space on VM-103** → **Mitigation**: Check disk space before deployment, backups go to NAS (not VM), monitor after deployment

- ⚠️ **Risk 3: Port conflict** → **Mitigation**: Verify port 5054 not in use, check existing services on VM-103

- ⚠️ **Risk 4: Secret generation/management** → **Mitigation**: Generate secure random secrets, store in Vaultwarden, document retrieval process

- ⚠️ **Risk 5: Backup script failures** → **Mitigation**: Include error handling in script, verify cron job runs, check logs regularly

- ⚠️ **Risk 6: Pangolin configuration errors** → **Mitigation**: Follow existing Pangolin resource patterns, test external access after configuration

### Dependencies

**Prerequisites (must exist before starting):**
- [x] **VM-103 running** - Already operational
- [x] **Docker/Portainer** - Already installed and running
- [x] **NAS mounts** - `/mnt/video` already mounted
- [x] **Newt client** - Already running on VM-103
- [x] **Backup script pattern** - Vaultwarden backup provides template
- [x] **SSH access** - Already configured
- [x] **Vaultwarden** - Already operational for secret storage

**No blocking dependencies - can start immediately**

### Critical Service Impact

**Services Affected**: None

This is a new service deployment on VM-103 (misc services). No impact on critical services (Emby, downloads, arr). VM-103 already hosts multiple non-critical services.

### Rollback Plan

**Applicable for**: Docker deployment

**How to rollback if this goes wrong:**
1. Stop MyBibliotheca container via Portainer
2. Remove stack from Portainer
3. Remove docker-compose.yml from git (if needed)
4. Remove backup script and cron job (if configured)
5. Remove Pangolin resource (if configured)
6. Remove secrets from Vaultwarden (if desired)

**Recovery time estimate**: < 5 minutes (simple container removal)

**Backup requirements:**
- No backups needed before deployment (new service)
- After deployment: Database backups will be automated

## Execution Plan

### Phase 0: Discovery/Inventory

**Primary Agent**: `docker`

- [x] **Verify VM-103 resources** `[agent:infrastructure]`
  - Check disk space availability ✓ (61G available, 35% used)
  - Verify port 5054 not in use ✓ (available)
  - Confirm NAS mount `/mnt/video` accessible ✓ (accessible)

- [x] **Review backup script pattern** `[agent:docker]`
  - Examine Vaultwarden backup script structure ✓
  - Understand SQLite backup approach ✓ (VACUUM INTO with fallback)
  - Note cron job configuration ✓ (2 AM daily, user evan)

- [x] **Review secret management** `[agent:security]`
  - Understand Vaultwarden secret storage pattern ✓
  - Review secret retrieval process ✓
  - Plan secret generation and storage ✓

- [x] **Review Pangolin setup** `[agent:security]`
  - Check existing newt client configuration on VM-103 ✓ (already running)
  - Understand Pangolin resource creation process ✓ (via Pangolin server)
  - Review existing service external access patterns ✓

### Phase 1: Secret Management

**Primary Agent**: `security`

- [x] **Generate secrets** `[agent:security]`
  - Generate SECRET_KEY (32+ character random string) ✓
  - Generate SECURITY_PASSWORD_SALT (32+ character random string) ✓
  - Use Python secrets module: `secrets.token_urlsafe(32)` ✓

- [x] **Store secrets in Vaultwarden** `[agent:security]`
  - Create secret entry: `mybibliotheca-secrets` in vm-103-misc collection ✓
  - Store SECRET_KEY and SECURITY_PASSWORD_SALT as custom fields ✓
  - Document secret location for retrieval ✓

### Phase 2: Docker Stack Creation

**Primary Agent**: `docker`

- [x] **Create stack directory** `[agent:docker]`
  - Create `stacks/mybibliotheca/` directory ✓
  - Clone or fetch `.env.example` from https://github.com/pickles4evaaaa/mybibliotheca.git ✓
  - Use the official `.env.example` as the basis for our `.env.example` template ✓
  - Create `docker-compose.yml` following service patterns ✓
  - Create `.env.example` template (for documentation - actual env vars in Portainer) ✓
  - Ensure all environment variables from official repo are documented ✓

- [x] **Configure volumes** `[agent:docker]`
  - Set up data volume: `/home/evan/data/mybibliotheca/data` (local VM) ✓
  - Ensure directory exists with correct permissions (evan:evan) ✓
  - Note: Data stored locally, backed up to NAS daily ✓

- [x] **Configure environment** `[agent:docker]`
  - Set port: 5054 ✓
  - Set timezone: TIMEZONE environment variable (America/Toronto) ✓
  - Configure workers: WORKERS (default: 4) ✓
  - Configure restart policy: unless-stopped ✓
  - Reference secrets from Vaultwarden (SECRET_KEY, SECURITY_PASSWORD_SALT) ✓

- [x] **Create README.md** `[agent:documentation]`
  - Document service purpose and features ✓
  - Document volume mounts and paths ✓
  - Document port and access information ✓
  - Document backup procedure ✓
  - Document secret management ✓

### Phase 3: Backup Script & Automation

**Primary Agent**: `docker`

- [x] **Create backup script** `[agent:docker]`
  - Create `/home/evan/scripts/backup-mybibliotheca.sh` on VM-103 ✓
  - Follow Vaultwarden backup script pattern (`/home/evan/scripts/backup-vaultwarden.sh`) ✓
  - Identify database file location (books.db) ✓
  - Backup source: Database file from local VM storage ✓
  - Backup destination: `/mnt/video/backups/mybibliotheca/` (NAS) ✓
  - Use SQLite backup approach (VACUUM INTO or copy+sync) ✓
  - Include integrity verification (SQLite PRAGMA integrity_check) ✓
  - Include error handling and logging ✓
  - Include retention policy (30 days, like Vaultwarden) ✓
  - Make script executable ✓

- [x] **Configure cron job** `[agent:infrastructure]`
  - Add cron entry for user `evan` ✓
  - Schedule: Daily at 2 AM (same as Vaultwarden) ✓
  - Log to `/var/log/mybibliotheca-backup.log` ✓
  - Test cron job execution (will test after deployment)

- [ ] **Test backup script** `[agent:testing]`
  - Run backup script manually (after service deployment)
  - Verify backup file created
  - Verify backup integrity
  - Verify backup location correct

### Phase 4: Deployment

**Primary Agent**: `docker`

- [ ] **Deploy via Portainer** `[agent:docker]`
  - Create Git stack in Portainer on VM-103
  - Point to GitHub repository `stacks/mybibliotheca/docker-compose.yml`
  - Configure environment variables in Portainer (retrieve secrets from Vaultwarden)
  - Note: `.env.example` serves as documentation reference only
  - Deploy stack via Portainer
  - Verify container starts successfully

- [ ] **Verify service** `[agent:testing]`
  - Check container health
  - Verify service accessible at `http://192.168.86.249:5054`
  - Test basic functionality (create admin account, add book, view interface)
  - Check logs for errors

### Phase 5: Pangolin Configuration

**Primary Agent**: `security`

- [ ] **Create Pangolin resource** `[agent:security]`
  - Configure resource in Pangolin server
  - Set up subdomain (e.g., `mybibliotheca.infinity-node.com`)
  - Configure to point to `http://localhost:5054` on VM-103
  - Test external access

- [ ] **Verify external access** `[agent:testing]`
  - Access service via Pangolin URL
  - Verify authentication works
  - Test functionality via external access

### Phase 6: Validation & Testing

**Primary Agent**: `testing`

- [ ] **Service validation** `[agent:testing]`
  - Container running and healthy
  - Service accessible internally
  - Service accessible externally via Pangolin
  - Basic functionality works (add book, track reading, import CSV)

- [ ] **Backup validation** `[agent:testing]`
  - Backup script executes successfully
  - Backup file created in correct location
  - Backup integrity verified
  - Cron job scheduled correctly

- [ ] **Integration validation** `[agent:testing]`
  - Portainer shows stack correctly
  - Git integration working
  - Documentation complete

### Phase 7: Documentation

**Primary Agent**: `documentation`

- [ ] **Update VM configuration docs** `[agent:documentation]`
  - Document MyBibliotheca deployment in `docs/VM-CONFIGURATION.md`
  - Document backup script location
  - Document cron job configuration
  - Document secret management

- [ ] **Update architecture docs** `[agent:documentation]`
  - Add MyBibliotheca to VM-103 services list
  - Document external access via Pangolin
  - Update service inventory

## Acceptance Criteria

**Done when all of these are true:**
- [ ] MyBibliotheca container running on VM-103
- [ ] Service accessible internally at `http://192.168.86.249:5054`
- [ ] Service accessible externally via Pangolin
- [ ] Secrets stored in Vaultwarden (SECRET_KEY, SECURITY_PASSWORD_SALT)
- [ ] Daily backup script created and tested
- [ ] Cron job configured and verified
- [ ] Backups being created in `/mnt/video/backups/mybibliotheca/`
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
- Secrets retrieved from Vaultwarden successfully

**Manual validation:**
1. Access MyBibliotheca web interface internally - should load and show setup page
2. Create admin account - should succeed
3. Add a test book manually - should save successfully
4. Test ISBN lookup - should fetch metadata
5. Access MyBibliotheca via Pangolin URL externally - should load and authenticate
6. Run backup script manually - should create backup file
7. Verify backup file in `/mnt/video/backups/mybibliotheca/` - should exist and be recent
8. Check cron job - should be scheduled for 2 AM daily
9. Verify Portainer shows stack - should be listed and running
10. Verify secrets in Vaultwarden - should be accessible

## Related Documentation

- [[docs/ARCHITECTURE|Infrastructure Architecture]]
- [[docs/VM-CONFIGURATION|VM Configuration]]
- [[docs/agents/DOCKER|Docker Agent]]
- [[docs/agents/SECURITY|Security Agent]]
- [[docs/SECRET-MANAGEMENT|Secret Management]]
- [[docs/adr/004-use-pangolin-for-external-access|ADR-004: Pangolin]]
- [[tasks/completed/IN-017-implement-vaultwarden-backup|IN-017: Vaultwarden Backup Pattern]]
- [[tasks/completed/IN-043-setup-jelu-book-tracker|IN-043: Jelu (cancelled)]]
- [[stacks/vaultwarden/README|Vaultwarden Stack Reference]]
- [MyBibliotheca Documentation](https://mybibliotheca.org/stable/)

## Notes

**Priority Rationale**:
Priority 4 (medium) - Valuable improvement for personal use, not urgent. Fits well with existing misc services on VM-103.

**Complexity Rationale**:
Moderate complexity - Standard Docker deployment with established patterns, but includes secret management, backup automation, and Pangolin configuration. Estimated 3-4 hours including testing and documentation.

**Implementation Notes**:
- **Pull `.env.example` from official repo**: Use https://github.com/pickles4evaaaa/mybibliotheca.git as source of truth for all available environment variables. Clone repo and use `.env.example` as basis for our documentation template.
- Data stored locally on VM (`/home/evan/data/mybibliotheca/data/`), backed up to NAS daily
- Follow Vaultwarden backup script pattern closely for consistency
- Use same backup schedule (2 AM) to avoid conflicts
- Ensure NAS backup directory exists before deployment
- Environment variables configured in Portainer (not .env file)
- Secrets stored in Vaultwarden for secure management
- Deploy via Portainer Git integration on VM-103
- Test Pangolin resource before marking complete
- Consider adding to Homepage dashboard in future task

**Secret Generation:**
```python
import secrets
SECRET_KEY = secrets.token_urlsafe(32)
SECURITY_PASSWORD_SALT = secrets.token_urlsafe(32)
```

**Follow-up Tasks**:
- Future: Add MyBibliotheca to Homepage dashboard
- Future: Configure Goodreads CSV import
- Future: Set up multi-user if needed
- Future: Configure reading analytics and wrap-up images

---

> [!note]- 📋 Work Log
>
> *Work log will be updated during task execution*

> [!tip]- 💡 Lessons Learned
>
> *Lessons learned will be captured during task execution*
