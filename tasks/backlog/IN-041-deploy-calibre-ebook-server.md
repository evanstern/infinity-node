---
type: task
task-id: IN-041
status: pending
priority: 4
category: docker
agent: docker
created: 2025-11-02
updated: 2025-11-02
started:
completed:

# Task classification
complexity: moderate
estimated_duration: 3-5h
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
  - media
  - ebook
  - calibre
  - vm-103
---

# Task: IN-041 - Deploy Calibre E-book Server and Web Interface

> **Quick Summary**: Deploy Calibre and Calibre-Web on VM 103 to manage and serve the existing e-book library, with future consideration for Kindle backup conversion.

## Problem Statement

**What problem are we solving?**
The e-book library at `/mnt/video/Books` on the NAS currently has no dedicated management or serving system. Books are accessed manually via file browser, with no metadata management, organization, or remote reading capabilities. Additionally, there's a Kindle backup at `/mnt/video/Kindle` that contains books in Amazon's proprietary format that could be converted to open formats for long-term preservation.

Current limitations:
- No centralized e-book catalog or metadata
- No web-based reading interface
- Books may not be organized to library standards
- Kindle backups stuck in proprietary format
- No ability to sync reading progress across devices
- Manual file organization required

**Why now?**
- Existing e-book collection at `/mnt/video/Books` is unmanaged
- Kindle backup data exists but is inaccessible
- VM 103 has capacity for additional services
- Calibre-Web provides modern reading experience similar to other media services (Emby, Audiobookshelf)
- Good timing while working on media service improvements (following Tdarr deployment)

**Who benefits?**
- **Household users**: Web-based e-book reading with progress tracking and metadata
- **System owner**: Centralized e-book management and organization
- **Long-term preservation**: Converting Kindle books from proprietary format ensures accessibility

## Solution Design

### Recommended Approach

Deploy **both Calibre and Calibre-Web** as a two-container stack on VM 103:

1. **Calibre Server**: Handles the database and library management (backend)
   - LinuxServer.io's `linuxserver/calibre` image
   - Provides desktop GUI via web browser (VNC-based)
   - Used for bulk operations, conversions, metadata editing
   - Manages the actual Calibre database

2. **Calibre-Web**: Modern web interface for reading and browsing (frontend)
   - LinuxServer.io's `linuxserver/calibre-web` image
   - Clean, user-friendly reading interface
   - Mobile-responsive design
   - Lightweight for daily access
   - Points to Calibre's database directory

**Key components:**
- **Calibre Server**: Database management, bulk imports, conversions, metadata editing
- **Calibre-Web**: Daily reading interface, mobile access, OPDS feeds for e-readers
- **Shared Library**: Both containers share the same Calibre library directory on NAS
- **NFS Mounts**: Access to `/mnt/video/Books` (existing) and `/mnt/video/Kindle` (conversion source)

**Rationale**: Using both services provides the best of both worlds - Calibre's powerful library management capabilities with Calibre-Web's modern, lightweight reading experience. The LinuxServer.io images are well-maintained, support the same PUID/PGID pattern as other stacks, and integrate cleanly with our existing infrastructure.

> [!abstract]- 🔀 Alternative Approaches Considered
>
> **Option A: Calibre-Web Only**
> - ✅ Pros: Simpler deployment, single container, lightweight
> - ✅ Pros: Modern web interface, mobile-friendly
> - ❌ Cons: Limited management capabilities, harder to do bulk operations
> - ❌ Cons: Requires pre-existing Calibre library or manual database creation
> - ❌ Cons: Difficult to handle Kindle conversion and initial organization
> - **Decision**: Not chosen - Need Calibre's full power for initial setup and conversions
>
> **Option B: Calibre Server + Calibre-Web (CHOSEN)**
> - ✅ Pros: Full Calibre power for management and conversions
> - ✅ Pros: Modern web interface for daily reading
> - ✅ Pros: Separate concerns: backend (Calibre) + frontend (Calibre-Web)
> - ✅ Pros: Can use Calibre GUI for complex operations
> - ✅ Pros: Best solution for Kindle conversion and library organization
> - ❌ Cons: Two containers instead of one
> - ❌ Cons: Slightly higher resource usage
> - **Decision**: ✅ CHOSEN - Provides complete solution for both setup and daily use
>
> **Option C: Calibre Server Only**
> - ✅ Pros: Full Calibre capabilities
> - ✅ Pros: Single container
> - ❌ Cons: VNC-based GUI is clunky for daily use
> - ❌ Cons: Not mobile-friendly
> - ❌ Cons: Resource-heavy for simple reading tasks
> - **Decision**: Not chosen - Poor user experience for daily reading
>
> **Option D: Kavita or other E-book Servers**
> - ✅ Pros: Modern, purpose-built web interfaces
> - ❌ Cons: Less mature ecosystem than Calibre
> - ❌ Cons: Weaker metadata management
> - ❌ Cons: Limited conversion capabilities
> - ❌ Cons: No Kindle DRM removal support
> - **Decision**: Not chosen - Calibre is the industry standard for e-book management

### Scope Definition

**✅ In Scope:**
- Deploy Calibre server container on VM 103
- Deploy Calibre-Web container on VM 103
- Configure both containers to share Calibre library directory
- Mount existing `/mnt/video/Books` directory for book storage
- Mount `/mnt/video/Kindle` directory (read-only for future conversion)
- Create Calibre library and import existing books from `/mnt/video/Books`
- Basic organization and metadata fetching for existing books
- Configure Calibre-Web user accounts
- Create stack documentation and deployment guide
- Configure Portainer GitOps deployment

**❌ Explicitly Out of Scope:**
- Kindle DRM removal and conversion (separate task - **IN-042**)
- Comprehensive re-organization of entire existing book library (gradual, as-needed)
- Advanced Calibre plugins and customization
- E-reader device sync configuration (OPDS available but not configured)
- Email delivery configuration (Calibre feature, not required initially)
- Integration with external metadata sources beyond defaults

**🎯 MVP (Minimum Viable)**:
- Both containers running and healthy
- Calibre library initialized and accessible
- Existing books from `/mnt/video/Books` imported into Calibre
- Calibre-Web shows books and allows reading
- Basic user authentication configured
- Accessible via local network (192.168.86.249)
- Documentation complete

**Post-MVP (Nice to Have):**
- External access via Pangolin tunnel
- Kindle conversion workflow (separate task)
- OPDS feed for e-readers
- Advanced metadata cleanup
- Custom categories and collections

## Risk Assessment

### Potential Pitfalls

- ⚠️ **Risk 1: Calibre may reorganize existing books** → **Mitigation**: Configure Calibre to *copy* books into library rather than *move* them, preserving originals. Test with small subset first. Calibre can also work with existing structure without reorganizing.

- ⚠️ **Risk 2: Books may lack metadata (filenames only)** → **Mitigation**: Calibre has excellent metadata fetching from multiple sources (Google Books, Amazon, etc.). Bulk operations available via Calibre server GUI. Accept that some manual cleanup may be needed over time.

- ⚠️ **Risk 3: NFS I/O performance for library database** → **Mitigation**: Store Calibre library on NAS as planned (consistent with other stacks). Library database is SQLite (lightweight). Monitor performance. If issues arise, can move database to local VM storage while keeping books on NAS.

- ⚠️ **Risk 4: Container permission issues with NFS mounts** → **Mitigation**: Use standard PUID=1000/PGID=1000 pattern (consistent with other stacks). Test mount access before importing books. LinuxServer.io images handle permissions well.

- ⚠️ **Risk 5: Calibre and Calibre-Web may conflict accessing same database** → **Mitigation**: This is the documented approach - both tools are designed to share the same library. Calibre-Web runs in read-mostly mode. Avoid simultaneous heavy operations in both interfaces. Document best practices.

- ⚠️ **Risk 6: Large book collection may take time to import** → **Mitigation**: Import can run in background. Start with smaller batches if needed. Use Calibre's bulk import features. Not time-critical - can complete over multiple sessions.

### Dependencies

**Prerequisites (must exist before starting):**
- [x] **VM 103 running and accessible** - (blocking: yes) - Already operational
- [x] **NFS mounts available** (`/mnt/video/Books`, `/mnt/video/Kindle`) - (blocking: yes) - Already mounted on VMs
- [x] **Portainer configured on VM 103** - (blocking: yes) - Already configured
- [x] **Git repository accessible for Portainer GitOps** - (blocking: yes) - Already configured

**No blocking dependencies** - Can start immediately

### Critical Service Impact

**Services Affected**: None

No critical services affected:
- Calibre deployment on VM 103 (misc/supporting services)
- Does not affect Emby (VM 100), downloads (VM 101), or arr services (VM 102)
- Existing book files remain untouched during initial deployment
- Read-only access to Kindle directory (no modifications)
- Low-priority service - acceptable downtime for maintenance

### Rollback Plan

**Applicable for**: Docker stack deployment on VM 103

**How to rollback if this goes wrong:**
1. Stop and remove Calibre stack via Portainer or CLI:
   ```bash
   ssh evan@192.168.86.249
   cd ~/stacks/calibre  # Or Portainer GitOps path
   docker compose down
   ```
2. Remove Calibre library directory if created:
   ```bash
   rm -rf /mnt/nas/configs/calibre/library
   ```
3. Original books at `/mnt/video/Books` remain untouched (read-only or copy mode)
4. Revert git commits if needed:
   ```bash
   git revert <commit-hash>
   ```

**Recovery time estimate**: < 5 minutes

**Backup requirements:**
- Not required - no critical data affected
- Original books at `/mnt/video/Books` remain as backup
- Calibre library can be recreated by re-importing
- If desired, backup `/mnt/video/Books` before starting (optional)

## Execution Plan

### Phase 0: Discovery and Planning

**Primary Agent**: `docker`

- [ ] **Verify NFS mount paths on VM 103** `[agent:infrastructure]`
  - Confirm `/mnt/video/Books` accessible and contains books
  - Confirm `/mnt/video/Kindle` accessible and contains Kindle data
  - Document current directory structure and file counts
  - Check available disk space on NAS for Calibre library

- [ ] **Research Calibre + Calibre-Web configuration** `[agent:docker]`
  - Review LinuxServer.io documentation for both images
  - Identify required environment variables and volumes
  - Understand shared library directory structure
  - Document port assignments (avoid conflicts)

- [ ] **Choose VM 103 port assignments** `[agent:docker]`
  - Calibre server GUI port (default: 8080 → check for conflicts)
  - Calibre server port (default: 8081)
  - Calibre-Web port (default: 8083 → check for conflicts)
  - Document chosen ports in task notes

### Phase 1: Create Calibre Stack Configuration

**Primary Agent**: `docker`

- [ ] **Create stack directory structure** `[agent:docker]`
  - `stacks/calibre/docker-compose.yml`
  - `stacks/calibre/.env.example`
  - `stacks/calibre/README.md`

- [ ] **Write docker-compose.yml** `[agent:docker]` `[risk:1,5]`
  - Define `calibre` service (LinuxServer.io image)
    - Environment: PUID, PGID, TZ
    - Volumes: Config directory, shared library, book sources
    - Ports: GUI port, server port
  - Define `calibre-web` service (LinuxServer.io image)
    - Environment: PUID, PGID, TZ
    - Volumes: Config directory, shared library (read-mostly)
    - Ports: Web UI port
  - Configure Docker network
  - Add restart policies

- [ ] **Create .env.example template** `[agent:docker]`
  - TZ configuration
  - CONFIG_PATH (on NAS)
  - LIBRARY_PATH (shared Calibre library)
  - BOOKS_PATH (`/mnt/video/Books`)
  - KINDLE_PATH (`/mnt/video/Kindle`)
  - Port assignments
  - Document all variables with comments

- [ ] **Create comprehensive README.md** `[agent:documentation]`
  - Service overview and purpose
  - Architecture (two-container approach)
  - Deployment instructions
  - Initial setup guide (creating library, importing books)
  - Usage patterns (when to use Calibre vs Calibre-Web)
  - Configuration details
  - Port reference
  - Troubleshooting common issues

### Phase 2: Deploy Stack via Portainer GitOps

**Primary Agent**: `docker`

- [ ] **Commit stack configuration to git** `[agent:docker]` `[blocking]`
  - Stage files: `docker-compose.yml`, `.env.example`, `README.md`
  - Commit with descriptive message
  - **DO NOT commit yet - wait for user approval**

- [ ] **Prepare environment variables for Portainer** `[agent:docker]`
  - Document required environment variables (based on `.env.example`)
  - Determine paths and port assignments
  - Prepare values for Portainer environment variable UI:
    - `TZ=America/New_York`
    - `CONFIG_PATH=/mnt/nas/configs/calibre`
    - `LIBRARY_PATH=/mnt/nas/configs/calibre/library`
    - `BOOKS_PATH=/mnt/video/Books`
    - `KINDLE_PATH=/mnt/video/Kindle`
    - `CALIBRE_GUI_PORT=8265`
    - `CALIBRE_SERVER_PORT=8266`
    - `CALIBRE_WEB_PORT=8267`
    - `PUID=1000`
    - `PGID=1000`

- [ ] **Deploy via Portainer GitOps** `[agent:docker]` `[depends:git-commit]`
  - Option A: Use `scripts/infrastructure/create-git-stack.sh` (if it supports env vars directly)
  - Option B: Use Portainer UI manually:
    - Stacks → Add Stack → Git Repository
    - Repository URL: Git repo URL
    - Reference: main
    - Compose path: `stacks/calibre/docker-compose.yml`
    - Add environment variables via Portainer UI (one by one from list above)
    - Enable GitOps auto-update (5-minute interval)
  - Deploy and verify containers start successfully

- [ ] **Investigate: Can we update env vars without redeploying?** `[agent:docker]` `[optional]`
  - Test `scripts/infrastructure/update-stack-env.sh` on this stack
  - Document whether env var updates work without full redeploy
  - If works: Update task notes with best practice
  - If doesn't work: Consider creating follow-up task to fix this
  - Note: Current workflow requires manual restart after env var changes

- [ ] **Verify container health** `[agent:docker]` `[risk:4]`
  - Check both containers running: `docker ps | grep calibre`
  - Check logs for errors: `docker logs calibre`, `docker logs calibre-web`
  - Verify NFS mounts accessible inside containers
  - Test network connectivity between containers

### Phase 3: Initial Library Setup

**Primary Agent**: `docker`

- [ ] **Access Calibre Server GUI** `[agent:docker]`
  - Open web browser to `http://192.168.86.249:<CALIBRE_GUI_PORT>`
  - Verify VNC interface loads
  - Complete initial Calibre setup wizard

- [ ] **Create Calibre Library** `[agent:docker]` `[risk:1,2]`
  - Use Calibre GUI to create new library at mounted library path
  - Configure library preferences:
    - **IMPORTANT**: Set to "Copy to library" (not "Move")
    - Configure metadata sources (enable Google Books, Amazon, etc.)
    - Set preferred metadata fields
  - Document library path in notes

- [ ] **Test import with small book sample** `[agent:docker]` `[risk:1,2]`
  - Select 5-10 books from `/mnt/video/Books`
  - Import via Calibre GUI
  - Verify books appear in library
  - Check metadata fetched correctly
  - Confirm original files untouched
  - Review Calibre's organization structure

- [ ] **Configure Calibre-Web** `[agent:docker]` `[risk:5]`
  - Access Calibre-Web at `http://192.168.86.249:<CALIBRE_WEB_PORT>`
  - Complete initial setup:
    - Point to Calibre library database path
    - Create admin user account
    - Configure basic settings (timezone, default view, etc.)
  - Verify test books appear in Calibre-Web interface
  - Test reading interface with sample book

### Phase 4: Bulk Import Existing Books

**Primary Agent**: `docker`

- [ ] **Import remaining books from /mnt/video/Books** `[agent:docker]` `[risk:2,6]`
  - Use Calibre GUI bulk import feature
  - Start import process (may take time depending on collection size)
  - Monitor progress and logs
  - Let run in background if needed (can take hours for large collections)

- [ ] **Verify import results** `[agent:docker]`
  - Check import statistics in Calibre
  - Review books with missing metadata
  - Spot-check random books in Calibre-Web
  - Document any issues or patterns (e.g., common metadata gaps)

- [ ] **Basic organization and cleanup** `[agent:docker]` `[optional]`
  - Fix obvious metadata issues (blank titles, missing authors)
  - Download missing cover images (bulk operation available)
  - Add basic tags/categories if desired
  - Note: Comprehensive cleanup can happen gradually over time

### Phase 5: Validation & Testing

**Primary Agent**: `testing`

- [ ] **Test Calibre Server functionality** `[agent:testing]`
  - Verify GUI accessible via web browser
  - Test book import workflow
  - Test metadata editing
  - Test search functionality
  - Check database integrity

- [ ] **Test Calibre-Web functionality** `[agent:testing]`
  - Verify web UI accessible and responsive
  - Test book browsing and filtering
  - Test reading interface (multiple formats: EPUB, PDF, MOBI)
  - Test mobile responsiveness
  - Verify user authentication working
  - Test download functionality

- [ ] **Validate shared library access** `[agent:testing]` `[risk:5]`
  - Add book via Calibre server
  - Verify appears in Calibre-Web (may need refresh)
  - Edit metadata in Calibre server
  - Verify changes reflected in Calibre-Web
  - Document refresh/sync behavior

- [ ] **Test container restart resilience** `[agent:testing]`
  - Restart both containers
  - Verify library persists
  - Verify books still accessible
  - Check no database corruption

- [ ] **Resource usage monitoring** `[agent:testing]`
  - Monitor CPU usage during operations
  - Monitor memory usage
  - Check NFS I/O patterns
  - Verify no resource constraints on VM 103

### Phase 6: Documentation

**Primary Agent**: `documentation`

- [ ] **Update ARCHITECTURE.md** `[agent:documentation]`
  - Add Calibre to VM 103 services list
  - Document port assignments
  - Note storage mounts and paths

- [ ] **Create usage guide in stack README** `[agent:documentation]`
  - When to use Calibre vs Calibre-Web
  - How to add new books
  - How to edit metadata
  - How to handle duplicates
  - Basic troubleshooting

- [ ] **Document Kindle conversion workflow** `[agent:documentation]`
  - Note that Kindle directory is mounted for future use
  - Reference future task IN-042 for Kindle conversion
  - Document DRM removal considerations (legal implications)

- [ ] **Update task with lessons learned** `[agent:documentation]`
  - Document actual import statistics
  - Note any metadata challenges discovered
  - Record performance observations
  - Suggest follow-up improvements

## Acceptance Criteria

**Done when all of these are true:**
- [ ] Calibre server container running and accessible at `http://192.168.86.249:<PORT>`
- [ ] Calibre-Web container running and accessible at `http://192.168.86.249:<PORT>`
- [ ] Calibre library created and shared between both containers
- [ ] Existing books from `/mnt/video/Books` successfully imported into Calibre
- [ ] Books browsable and readable via Calibre-Web interface
- [ ] User authentication configured in Calibre-Web
- [ ] Metadata fetched for majority of imported books
- [ ] Original book files remain intact at `/mnt/video/Books`
- [ ] `/mnt/video/Kindle` mounted for future conversion work
- [ ] Stack deployed via Portainer GitOps (Git-integrated)
- [ ] Comprehensive README.md documents setup, usage, and troubleshooting
- [ ] ARCHITECTURE.md updated with Calibre service details
- [ ] All execution plan items completed
- [ ] Testing Agent validates functionality (see testing plan below)
- [ ] Changes committed with descriptive message (awaiting user approval)

## Testing Plan

**[[docs/agents/TESTING|Testing Agent]] validates:**
- Container health checks passing
- Web UIs accessible via curl/HTTP requests
- Book import functionality (add test book)
- Database integrity (no corruption)
- NFS mount accessibility
- Resource usage within acceptable limits
- Log files show no critical errors
- Restart resilience (containers survive restart)

**Manual validation:**
1. **Calibre Server GUI access** - Open `http://192.168.86.249:<CALIBRE_GUI_PORT>` and verify VNC interface loads
2. **Calibre-Web access** - Open `http://192.168.86.249:<CALIBRE_WEB_PORT>` and verify book catalog loads
3. **Reading test** - Open a book in Calibre-Web and verify reading interface works (EPUB preferred)
4. **Mobile test** - Access Calibre-Web from mobile device and verify responsive interface
5. **Metadata test** - Check that imported books have correct titles, authors, cover images
6. **Search test** - Search for books by title, author, tag in Calibre-Web
7. **User authentication** - Verify login required for Calibre-Web access

## Related Documentation

- [[docs/ARCHITECTURE|Infrastructure Architecture]]
- [[docs/agents/DOCKER|Docker Agent]]
- [[stacks/audiobookshelf/README|Audiobookshelf Stack]] - Similar media service on VM 103
- [[stacks/navidrome/README|Navidrome Stack]] - Another media service on VM 103
- [Calibre Documentation](https://manual.calibre-ebook.com/)
- [Calibre-Web Documentation](https://github.com/janeczku/calibre-web/wiki)
- [LinuxServer.io Calibre Image](https://docs.linuxserver.io/images/docker-calibre/)
- [LinuxServer.io Calibre-Web Image](https://docs.linuxserver.io/images/docker-calibre-web/)
- [Self-Hosted Cookbook Calibre Guide](https://github.com/tborychowski/self-hosted-cookbook/blob/master/apps/media/calibre.md)

## Notes

**Priority Rationale**:
Priority 4 (medium) because:
- Not urgent - existing books are accessible via file browser
- Valuable improvement to media server ecosystem
- Enables future Kindle conversion work
- Enhances household e-book experience
- Non-critical service on VM 103
- Lower priority than critical services (Emby, downloads, arr)

**Complexity Rationale**:
Moderate complexity because:
- Two-container deployment with shared state
- Requires understanding of Calibre library structure
- Initial import may reveal organizational challenges
- Need to test interaction between Calibre and Calibre-Web
- Some unknowns around existing book metadata quality
- Not complex enough to require discovery phase (well-documented solution)
- Similar to other media service deployments (Audiobookshelf, Navidrome)

**Implementation Notes**:
- **Port Selection**: Check VM 103 existing services to avoid conflicts:
  - Vaultwarden: 8111
  - Paperless-NGX: 8010, 5432, 6379, 3000
  - Immich: Multiple ports (check README)
  - Linkwarden: 3001, 5432, 7700
  - Navidrome: 4533
  - Audiobookshelf: 13378
  - Homepage: 3100
  - Portainer: 9443
  - Suggest: Calibre GUI=8265, Calibre Server=8266, Calibre-Web=8267
- **Library Location**: Store Calibre library at `/mnt/nas/configs/calibre/library` (consistent with other service configs)
- **Book Organization**: Calibre can work with existing structure OR import into its own structure - choose "copy" mode to preserve originals
- **Kindle Conversion**: Out of scope for this task, but setup enables future IN-042 task
- **DRM Considerations**: Kindle DRM removal has legal implications - research carefully before proceeding (future task)
- **Environment Variables**: Use Portainer's environment variable UI (NOT .env files)
  - Environment variables entered in Portainer UI during stack deployment
  - `.env.example` serves as documentation template only
  - Current limitation: Env var updates require stack restart (investigate `update-stack-env.sh` during this task)
- **Deployment Workflow**: Portainer GitOps with environment variables managed in Portainer
  - Git repo contains: `docker-compose.yml`, `.env.example`, `README.md`
  - Portainer UI contains: Actual environment variable values
  - Changes to compose file auto-update via GitOps (5-minute polling)
  - Changes to env vars require manual update in Portainer UI + restart

**Follow-up Tasks**:
- IN-042: Kindle DRM Removal and E-book Conversion (convert `/mnt/video/Kindle` backups)
- Future: Improve Portainer env var update workflow (if `update-stack-env.sh` investigation reveals issues)
- Future: External access via Pangolin tunnel (add to newt configuration)
- Future: OPDS feed configuration for e-readers
- Future: Comprehensive metadata cleanup and standardization
- Future: Advanced Calibre plugin configuration (if needed)

---

> [!note]- 📋 Work Log
>
> **2025-11-02 - Task Created**
> - Task created for Calibre + Calibre-Web deployment
> - Identified existing book library at `/mnt/video/Books`
> - Identified Kindle backup at `/mnt/video/Kindle` for future conversion
> - Scoped task to focus on deployment and initial import
> - Kindle conversion designated as separate follow-up task (IN-042)
> - Chosen two-container approach for flexibility

> [!tip]- 💡 Lessons Learned
>
> *Fill this in AS YOU GO during task execution. Not every task needs extensive notes here, but capture important learnings that could affect future work.*
>
> **What Worked Well:**
> - [What patterns/approaches were successful that we should reuse?]
> - [What tools/techniques proved valuable?]
>
> **What Could Be Better:**
> - [What would we do differently next time?]
> - [What unexpected challenges did we face?]
> - [What gaps in documentation/tooling did we discover?]
>
> **Key Discoveries:**
> - [Did we learn something that affects other systems/services?]
> - [Are there insights that should be documented elsewhere (runbooks, ADRs)?]
> - [Did we uncover technical debt or improvement opportunities?]
>
> **Scope Evolution:**
> - [How did the scope change from original plan and why?]
> - [Were there surprises that changed our approach?]
>
> **Follow-Up Needed:**
> - [Documentation that should be updated based on this work]
> - [New tasks that should be created]
> - [Process improvements to consider]
