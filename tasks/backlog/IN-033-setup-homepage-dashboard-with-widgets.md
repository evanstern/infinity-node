---
type: task
task-id: IN-033
status: pending
priority: 5
category: docker
agent: docker
created: 2025-11-01
updated: 2025-11-01
started:
completed:

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
  - homepage
  - dashboard
  - configuration
  - monitoring
---

# Task: IN-033 - Setup Homepage Dashboard with Service Widgets

> **Quick Summary**: Configure Homepage dashboard with service widgets for all 19 infinity-node stacks, organized by VM and criticality, with rotating prismatic autumn wallpapers as background.

## Problem Statement

**What problem are we solving?**
Homepage is currently deployed on VM 103 but has minimal/no configuration. We need a comprehensive dashboard that provides:
- Centralized view of all infrastructure services
- Live status and statistics for critical services (Emby, *arr stack, downloads)
- Quick access links to all 19 deployed stacks
- Beautiful, organized interface with custom wallpapers
- Easy monitoring without accessing individual service UIs

Currently, accessing services requires remembering IPs/ports or bookmarks. There's no unified view of service health or activity.

**Why now?**
- Homepage container is already deployed and ready for configuration
- Good foundation for future monitoring/alerting work
- Quality of life improvement for daily operations
- Prismatic autumn wallpapers available and would look great with dark theme

**Who benefits?**
- **System Administrator (Evan)**: Centralized dashboard for monitoring all services, quick access to any service, visual status overview
- **Future users**: Easy service discovery and access
- **Infrastructure monitoring**: Foundation for observability improvements

## Solution Design

### Recommended Approach

**Manual YAML Configuration** - Create comprehensive YAML configuration files for Homepage, organized by VM and service criticality, with full widgets for supported services.

**Key components:**

**1. Configuration Files** (stored in `stacks/homepage/config/`):
- `settings.yaml` - Dark theme, layout configuration, background settings
- `services.yaml` - All 19 services organized by VM with widgets/links
- `widgets.yaml` - Docker integration widget for VM 103 containers
- `bookmarks.yaml` - Quick links to infrastructure (Portainer instances, Proxmox, NAS)
- `custom.css` (if needed) - Custom styling for background rotation

**2. Background Setup**:
- Copy 7 prismatic autumn desktop wallpapers to `config/images/backgrounds/`
- Configure random/rotating selection from wallpaper pack
- Dark theme to complement warm autumn colors

**3. Service Organization**:
- **VM 100 - Media Streaming (Critical)**: Emby with widget
- **VM 101 - Downloads (Critical)**: Deluge/NZBGet (links or widgets)
- **VM 102 - Media Automation (Critical)**: Radarr, Sonarr, Lidarr, Prowlarr, Jellyseerr with widgets; FlareSolverr, Huntarr as links
- **VM 103 - Supporting Services**: Vaultwarden, Paperless-NGX, Immich, Linkwarden, Navidrome, Audiobookshelf, Portainer, Watchtower (widgets where supported, links otherwise)

**4. Widget Integration**:
- Retrieve API keys from service web UIs during configuration
- Configure widget endpoints with proper IPs and ports
- Full stats display for services that support it (queue depth, disk usage, active streams, etc.)

**Rationale**: This approach provides full control over organization and layout, follows Homepage best practices, keeps configuration in git (infrastructure as code), and is easier to document and maintain than auto-discovery alternatives. The one-time API key retrieval is manageable for ~10 services.

> [!abstract]- 🔀 Alternative Approaches Considered
>
> **Option A: Docker Labels Auto-Discovery**
> - ✅ Pros: Less manual YAML configuration, services auto-appear
> - ✅ Pros: Self-documenting in docker-compose files
> - ❌ Cons: Need to modify all 19 existing stack compose files
> - ❌ Cons: Less control over organization and layout
> - ❌ Cons: Still need API keys for widgets anyway
> - **Decision**: Not chosen - too invasive to existing stacks, less organized
>
> **Option B: Manual YAML Configuration**
> - ✅ Pros: Full control over organization and layout
> - ✅ Pros: Clean separation (config vs stack definitions)
> - ✅ Pros: Better documentation and maintainability
> - ✅ Pros: Follows Homepage best practices
> - ❌ Cons: One-time API key retrieval needed
> - ❌ Cons: Manual configuration for each service
> - **Decision**: ✅ CHOSEN - Best balance of control and maintainability
>
> **Option C: Hybrid Approach**
> - ✅ Pros: YAML for critical services with widgets, auto-discovery for simple links
> - ✅ Pros: Flexible approach
> - ❌ Cons: Two configuration systems to maintain
> - ❌ Cons: More complex setup and troubleshooting
> - **Decision**: Not chosen - unnecessary complexity for 19 services

### Scope Definition

**✅ In Scope:**
- Create all configuration files (settings, services, widgets, bookmarks)
- Copy 7 prismatic autumn wallpapers to config directory
- Configure random/rotating background selection
- All 19 service stacks documented in services.yaml
- Widgets for services that support them (research and configure)
- Simple links for services without widget support
- Organization by VM (100, 101, 102, 103) and criticality
- Dark theme configuration
- Docker widget for VM 103 local containers
- Infrastructure bookmarks (Portainer all VMs, Proxmox, NAS)
- Testing and validation of all links and widgets
- Update README.md with configuration documentation

**❌ Explicitly Out of Scope:**
- Custom Homepage widget/plugin development
- Modifying existing stack docker-compose files
- Setting up authentication or reverse proxy for Homepage
- Creating mobile-specific layouts
- Integration with external monitoring services (Prometheus, Grafana)
- Automated API key retrieval from Vaultwarden
- System resource monitoring beyond basic Docker widget
- Alert notifications from Homepage

**🎯 MVP (Minimum Viable)**:
At minimum: All 19 services listed with clickable links, organized by VM, dark theme applied, basic layout working. Nice-to-have: Full widgets for all supported services, perfect background rotation (can use single wallpaper if rotation is complex). Required: All services accessible, organized view, professional appearance.

## Risk Assessment

### Potential Pitfalls

- ⚠️ **Risk 1: API Keys Exposure** → **Mitigation**: Store config files in `stacks/homepage/config/` directory (gitignored, not committed). Alternatively use environment variable references in YAML if Homepage supports it. Document API key locations in Vaultwarden for reference. Verify .gitignore coverage before any commits.

- ⚠️ **Risk 2: Service Widget Compatibility** → **Mitigation**: Research Homepage widget support for each service type during Phase 0. Maintain flexibility - use simple links for services without widget support. Document which services have widgets vs links in README.

- ⚠️ **Risk 3: Wallpaper File Size Bloat** → **Mitigation**: Store wallpapers in gitignored config directory, not in git repository. Document wallpaper placement in README. Consider optimizing/compressing images if they're excessively large (>2MB each).

- ⚠️ **Risk 4: Configuration Complexity** → **Mitigation**: Create well-organized, commented YAML files. Document structure clearly in README. Start simple and iterate - can add more widgets/features after initial deployment. Keep configuration DRY where possible.

- ⚠️ **Risk 5: Volume Mount Configuration** → **Mitigation**: Test volume mount early (Phase 0). Verify config directory is writable and persists. Create test file to confirm mount works before investing time in configuration.

### Dependencies

**Prerequisites (must exist before starting):**
- [x] **Homepage container deployed on VM 103** - Already running (blocking: no)
- [x] **Docker socket mounted in Homepage container** - For Docker widget (blocking: no)
- [x] **Portainer Git integration configured** - For deployment (blocking: no)
- [ ] **Prismatic autumn wallpapers accessible** - In ~/Downloads/wallpaper pack - prismatic autumn (blocking: no)
- [ ] **API keys from service web UIs** - Will retrieve during execution (blocking: no)

**No blocking dependencies** - can start immediately. All prerequisites either exist or will be gathered during execution.

### Critical Service Impact

**Services Affected**: None - Homepage is a non-critical supporting service on VM 103

This task poses no risk to critical services:
- Homepage is purely informational/navigational dashboard
- Configuration errors won't affect actual services
- Can iterate freely without downtime concerns
- Worst case: Homepage doesn't load, just access services directly
- Safe to test and refine without backup/rollback procedures

### Rollback Plan

**Applicable for**: Docker configuration changes

**How to rollback if this goes wrong:**
1. SSH to VM 103: `ssh evan@192.168.86.249`
2. Remove configuration files: `rm -rf /path/to/config/*` (preserves empty directory)
3. Restart Homepage container via Portainer or: `docker restart homepage`
4. Homepage returns to default/unconfigured state

**Recovery time estimate**: < 5 minutes

**Backup requirements:**
- No backup needed - starting fresh, no existing configuration to preserve
- If iterating on working config: copy `config/` directory before major changes
- Configuration files should be small (<100KB total), easy to backup manually

## Execution Plan

### Phase 0: Discovery & Preparation

**Primary Agent**: `docker`

- [ ] **Research Homepage widget support for each service type** `[agent:docker]`
  - Check Homepage docs/GitHub for supported widgets
  - Identify which of our 19 services have native widgets: Emby, Radarr, Sonarr, Lidarr, Prowlarr, Jellyseerr, Immich, Paperless-NGX, Deluge, NZBGet, etc.
  - Document findings for Phase 3 planning
  - Identify API key requirements for each widget type

- [ ] **Verify current Homepage volume mount configuration** `[agent:docker]` `[risk:5]`
  - Check `stacks/homepage/docker-compose.yml` volume mount
  - SSH to VM 103 and verify config directory exists and is writable
  - Create test file to confirm mount persistence
  - Document actual config path on VM 103

### Phase 1: Setup Infrastructure

**Primary Agent**: `docker`

- [ ] **Copy prismatic autumn wallpapers to config directory** `[agent:docker]` `[risk:3]`
  - Create directory: `stacks/homepage/config/images/backgrounds/`
  - Copy 7 desktop 16x9 wallpapers from `~/Downloads/wallpaper pack - prismatic autumn/desktop 16x9/`
  - Use scp or similar to transfer to VM 103
  - Verify files are readable by Homepage container

- [ ] **Verify directory structure and permissions** `[agent:docker]`
  - Ensure Homepage container can read config files
  - Create any needed subdirectories
  - Check file ownership matches PUID/PGID from compose file

- [ ] **Update .env.example if needed** `[agent:docker]`
  - Document any new environment variables
  - Note that config files are gitignored

### Phase 2: Core Configuration

**Primary Agent**: `docker`

- [ ] **Create settings.yaml with theme and layout** `[agent:docker]`
  - Dark theme configuration (e.g., theme: dark, color: slate)
  - Layout preferences (columns, spacing, responsive settings)
  - Background configuration pointing to wallpaper directory
  - Random or rotating background selection
  - Title: "Infinity-Node Infrastructure"

- [ ] **Create bookmarks.yaml with infrastructure links** `[agent:docker]`
  - Portainer instances for all 4 VMs:
    - VM 100: https://192.168.86.172:9443
    - VM 101: https://192.168.86.173:32768 (non-standard port!)
    - VM 102: https://192.168.86.174:9443
    - VM 103: https://192.168.86.249:9443
  - Proxmox: https://192.168.86.106:8006
  - NAS: http://192.168.86.43:5000
  - Optional: Vaultwarden, Pangolin server

### Phase 3: Service Configuration

**Primary Agent**: `docker`

- [ ] **Create services.yaml with all services organized by VM** `[agent:docker]` `[risk:2]`
  - **VM 100 Section - Media Streaming (Critical)**:
    - Emby: http://192.168.86.172:8096 with widget (if supported)
  - **VM 101 Section - Downloads (Critical)**:
    - Deluge: http://192.168.86.173:8112 (widget or link)
    - NZBGet: http://192.168.86.173:6789 (widget or link)
  - **VM 102 Section - Media Automation (Critical)**:
    - Radarr: http://192.168.86.174:7878 with widget
    - Sonarr: http://192.168.86.174:8989 with widget
    - Lidarr: http://192.168.86.174:8686 with widget
    - Prowlarr: http://192.168.86.174:9696 with widget
    - Jellyseerr: http://192.168.86.174:5055 with widget
    - FlareSolverr: http://192.168.86.174:8191 (link only)
    - Huntarr: (determine port) (link only)
  - **VM 103 Section - Supporting Services**:
    - Vaultwarden: http://192.168.86.249:8111 (link)
    - Paperless-NGX: (determine port) with widget if supported
    - Immich: (determine port) with widget if supported
    - Linkwarden: (determine port) (link)
    - Navidrome: (determine port) (link)
    - Audiobookshelf: (determine port) (link)
    - Homepage: http://192.168.86.249:3001 (meta!)
    - Portainer: http://192.168.86.249:9443 (link)
    - Watchtower: (no web UI, can omit or note as background service)
  - Use icons from Homepage's built-in icon set
  - Add descriptions for each service

### Phase 4: Widget Configuration

**Primary Agent**: `docker`

- [ ] **Create widgets.yaml with Docker and system widgets** `[agent:docker]`
  - Docker widget for local VM 103 containers
  - Optional: System resources widget (CPU, RAM, disk for VM 103)
  - Configure widget layout and positioning

- [ ] **Retrieve and configure API keys for service widgets** `[agent:docker]` `[risk:1]`
  - Access each service's web UI
  - Generate or retrieve API keys:
    - Emby: Settings → API Keys
    - Radarr/Sonarr/Lidarr/Prowlarr: Settings → General → API Key
    - Jellyseerr: Settings → General → API Key
    - Immich: User Settings → API Keys (if widget supported)
    - Paperless-NGX: (check if widget available)
  - Configure widget sections in services.yaml with:
    - type: [service-type]
    - url: http://[ip]:[port]
    - key: [api-key]
  - Document API key locations for future reference

### Phase 5: Deployment & Testing

**Primary Agent**: `docker` (deployment), `testing` (validation)

- [ ] **Deploy configuration and restart Homepage container** `[agent:docker]`
  - Ensure all config files are in place on VM 103
  - Restart via Portainer UI or: `docker restart homepage`
  - Wait for container to be healthy

- [ ] **Verify configuration loads without errors** `[agent:docker]`
  - Check container logs: `docker logs homepage`
  - Look for YAML parsing errors or missing files
  - Fix any configuration issues

- [ ] **Test all service links work** `[agent:testing]`
  - Click through each service link
  - Verify correct URL and service loads
  - Note any broken links or incorrect ports

- [ ] **Verify widgets display live data** `[agent:testing]` `[risk:2]`
  - Check each configured widget shows real data
  - Verify stats update (may need to wait for refresh interval)
  - Compare widget data to actual service UI for accuracy

- [ ] **Verify wallpapers display correctly** `[agent:testing]` `[risk:3]`
  - Confirm background image loads
  - Test background rotation/randomization (refresh page multiple times)
  - Verify images look good with dark theme and text is readable

- [ ] **Test Docker widget shows VM 103 containers** `[agent:testing]`
  - Verify Docker widget displays
  - Confirm container list matches `docker ps` output
  - Check container status indicators

### Phase 6: Documentation

**Primary Agent**: `documentation`

- [ ] **Update stacks/homepage/README.md** `[agent:documentation]`
  - Document new configuration structure and file purposes
  - Add "Configuration Files" section explaining each YAML file
  - Document how to retrieve API keys for widgets (service-by-service guide)
  - Add "Adding New Services" guide with example YAML snippets
  - Document wallpaper setup and how to change backgrounds
  - Add troubleshooting section:
    - Configuration not loading
    - Widgets not showing data
    - Background images not displaying
    - Links not working
  - Include example config snippets for common service types
  - Note that config files are gitignored (not committed)

- [ ] **Document widget setup process** `[agent:documentation]`
  - Create table of which services have widgets vs links
  - Document API key locations for each service
  - Note any widget-specific configuration tips

## Acceptance Criteria

**Done when all of these are true:**
- [ ] All configuration files created (settings.yaml, services.yaml, widgets.yaml, bookmarks.yaml)
- [ ] All 19 service stacks visible in dashboard, organized by VM
- [ ] Services grouped by criticality (Critical vs Supporting)
- [ ] At least 5 services have working widgets showing live data (Emby, Radarr, Sonarr, Lidarr, Prowlarr minimum)
- [ ] All service links navigate to correct URLs (100% success rate)
- [ ] Prismatic autumn wallpapers display as background
- [ ] Background rotation/randomization works (or single wallpaper displays correctly)
- [ ] Dark theme applied and looks professional
- [ ] Docker widget shows VM 103 containers
- [ ] Infrastructure bookmarks work (Portainer, Proxmox, NAS)
- [ ] Text is readable over background images
- [ ] README.md updated with complete configuration documentation
- [ ] All execution plan items completed
- [ ] Testing Agent validates all links and widgets work
- [ ] No secrets committed to git (config directory is gitignored)

## Testing Plan

**[[docs/agents/TESTING|Testing Agent]] validates:**
- All 19 service links return HTTP 200 or load successfully
- Widget data accuracy (compare to actual service UIs)
- Docker widget shows correct container list
- Background images load without errors
- No console errors in browser
- Configuration files are valid YAML (no syntax errors)

**Manual validation:**
1. **Visual inspection**: Dashboard looks professional, organized, readable text over backgrounds
2. **Widget functionality**: Click through each widget, verify live data displays and updates
3. **Link verification**: Click each service link, confirm correct service loads
4. **Responsive check**: Verify layout works at different browser widths
5. **Bookmark check**: Test each infrastructure bookmark navigates correctly
6. **Background rotation**: Refresh page 5+ times, verify different wallpapers appear (if rotation configured)
7. **Theme check**: Confirm dark theme applied, good contrast, no light theme elements

## Related Documentation

- [[stacks/homepage/README|Homepage Stack Documentation]]
- [[docs/ARCHITECTURE|Infrastructure Architecture]] - Service IPs and ports
- [[docs/agents/DOCKER|Docker Agent]] - Container management best practices
- [[docs/agents/TESTING|Testing Agent]] - Validation procedures
- [Homepage Official Docs](https://gethomepage.dev/)
- [Homepage Widgets Guide](https://gethomepage.dev/latest/widgets/)

## Notes

**Priority Rationale**:
Priority 5 (Low-Medium) is appropriate because this is a quality-of-life improvement that enhances daily operations but isn't urgent or blocking other work. It's valuable for convenience and monitoring, but the infrastructure functions fine without it. Non-critical service on VM 103 means low risk. Could be higher priority if we had external users needing service discovery, but currently this is primarily for system administrator benefit.

**Complexity Rationale**:
Moderate complexity because: (1) Well-understood solution (Homepage is documented, community support), (2) Some unknowns remain (widget compatibility, exact API key locations), (3) Design decisions needed (organization, which widgets to use), (4) Reasonable scope (19 services, multiple config files, testing needed), (5) Not trivial (estimated 3-4 hours), but (6) Not complex (no infrastructure changes, no critical service impact, clear rollback). Perfect fit for moderate category.

**Implementation Notes**:
- Homepage supports environment variable substitution in YAML if needed for any dynamic values
- Can iterate on configuration without downtime - just restart container
- Consider starting with fewer widgets and adding more incrementally
- Wallpaper file sizes: Optimize if >2MB each to avoid bloating config volume
- API keys are service-specific and don't need to be stored in Vaultwarden unless doing automated deployments
- Docker widget requires `/var/run/docker.sock` mount (already configured in compose file)
- Non-standard Portainer port on VM 101 (32768) - don't forget in bookmarks
- Homepage has no built-in authentication - rely on network security or add reverse proxy later

**Follow-up Tasks**:
- Consider: Add authentication via reverse proxy for Homepage
- Consider: Create custom widgets for services without native support
- Consider: Integrate with future monitoring/alerting system
- Consider: Add system resource monitoring dashboards per VM
- Consider: Mobile-specific layout optimization

---

> [!note]- 📋 Work Log
>
> **YYYY-MM-DD - [Milestone]**
> - [What was accomplished]
> - [Important decisions made]
> - [Issues encountered and resolved]

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
