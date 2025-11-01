---
type: task
task-id: IN-036
status: pending
priority: 4
category: media
agent: media
created: 2025-11-01
updated: 2025-11-01
started:
completed:

# Task classification
complexity: complex
estimated_duration: 6-10h
critical_services_affected: true
requires_backup: true
requires_downtime: false

# Design tracking
alternatives_considered: true
risk_assessment_done: true
phased_approach: true

tags:
  - task
  - tdarr
  - transcoding
  - media
  - optimization
  - gpu
  - storage
---

# Task: IN-036 - Setup and Configure Tdarr for Media Optimization

> **Quick Summary**: Deploy Tdarr on VM 100 to automatically reduce media file sizes using GPU-accelerated transcoding, scheduled to run 2-6 AM ET to avoid contention with Emby.

## Problem Statement

**What problem are we solving?**
Media library file sizes are larger than necessary, consuming excessive storage:
- NAS storage at 77% utilization (44TB/57TB used)
- Many large files (movies 20GB+, TV episodes 2GB+) that could be compressed without quality loss
- Manual transcoding is time-consuming and impractical for large library
- Need automated solution that doesn't impact Emby's critical streaming service
- Risk of "over-transcoding" - repeatedly processing files or degrading quality unnecessarily

**Why now?**
- VM 100 already has GPU passthrough configured and working (from IN-032)
- Storage growth rate requires proactive management
- Tdarr can leverage existing GPU investment for efficient batch processing
- Off-hours scheduling capability allows safe co-existence with Emby
- Low-hanging fruit: many large H.264 files could be converted to H.265 with significant savings

**Who benefits?**
- **System owner**: Reduced storage consumption, longer runway before NAS expansion, better storage ROI
- **Infrastructure**: More efficient use of existing GPU hardware, slower storage growth rate
- **Household users**: Indirectly benefit from extended storage capacity without performance impact

## Solution Design

### Recommended Approach

Deploy Tdarr (server + node) on VM 100 with strict scheduling and resource controls to safely co-exist with Emby.

**Architecture:**
- **Single-machine setup**: Tdarr server + node containers in same Docker stack
- **GPU sharing**: Leverage existing RTX 4060 Ti passthrough (temporally isolated from Emby via scheduling)
- **Scheduled operation**: Built-in Tdarr library schedule restricts processing to 2-6 AM US Eastern Time only
- **Resource limits**: Conservative worker allocation with low process priority to protect Emby
- **Smart processing**: Conditional plugins prevent over-transcoding and quality degradation

**Key Components:**
- **Tdarr Server**: Web UI, orchestration, scheduling, MongoDB backend for database
- **Tdarr Node**: Worker processes executing transcode jobs (GPU + CPU workers)
- **Library Schedule**: Built-in time-window restriction (2-6 AM ET only)
- **Plugin Stack**: Conditional transcoding rules for quality preservation and efficiency
- **NFS Mounts**: Access to media library (read source, write transcoded files)

**Processing Strategy:**
- **Phase 1 Target**: Movies ≥20GB, TV episodes ≥2GB (low-hanging fruit)
- **Codec Target**: Convert H.264 → H.265 (HEVC) with high quality preset (CRF 20-23)
- **Quality Priority**: Maintain resolution and visual quality, size reduction is secondary benefit
- **Processing Order**: Largest files first (maximum impact priority)
- **Test-First**: Process 10 largest movies as validation before full library

**Plugin Logic (prevents over-transcoding):**
1. **Skip if already optimized**: Check codec - if H.265/HEVC/AV1, skip (already efficient)
2. **Skip if too small**: Files below threshold not worth processing overhead
3. **Maintain resolution**: 1080p stays 1080p, 4K stays 4K (no downscaling)
4. **High quality encoding**: H.265 with CRF 20-23 (visually lossless to near-lossless)
5. **Health verification**: Verify transcoded file plays correctly before replacing original
6. **Size validation**: Only replace if new file is actually smaller (sanity check)

**Rationale:**
- VM 100 is only VM with GPU access (avoids complex multi-VM GPU passthrough)
- Scheduled operation (2-6 AM) prevents Emby contention during household usage hours
- Off-peak timing minimizes risk to critical service (lowest usage window)
- No CPU core expansion needed (conservative resource limits sufficient)
- Built-in Tdarr scheduling eliminates need for external automation (cron, etc.)
- Test-first approach provides real-world validation before full library processing
- High-quality presets ensure no perceptible quality loss while achieving 30-50% size reduction

> [!abstract]- 🔀 Alternative Approaches Considered
>
> **Option A: VM 102 (arr) with CPU-only transcoding**
> - ✅ Pros: Thematic fit (media processing pipeline), 8 CPU cores available
> - ✅ Pros: Wouldn't compete with Emby for GPU
> - ❌ Cons: No GPU access (10-20x slower than GPU transcoding)
> - ❌ Cons: VM already resource-constrained with multiple *arr services
> - ❌ Cons: Sonarr alone consuming significant CPU during library operations
> - ❌ Cons: Would compete with critical media automation services
> - **Decision**: Not chosen - significantly slower without GPU, unacceptable resource contention risk with critical arr services
>
> **Option B: Dedicated VM 106 for Tdarr**
> - ✅ Pros: Completely isolated resources, zero service contention
> - ✅ Pros: Could size appropriately for workload
> - ❌ Cons: Only 2 unallocated CPU cores on Proxmox host (92% CPU already allocated)
> - ❌ Cons: Would require GPU passthrough configuration (complex, GPU currently bound to VM 100)
> - ❌ Cons: GPU passthrough typically exclusive (can't share across VMs easily)
> - ❌ Cons: Overkill for batch processing that runs 4 hours/day
> - **Decision**: Not chosen - insufficient CPU headroom on host, GPU sharing complexity, unnecessary overhead for limited-time batch processing
>
> **Option C: VM 103 (misc) for non-critical service isolation**
> - ✅ Pros: Lower risk tier (non-critical services VM)
> - ✅ Pros: 6 CPU cores available
> - ❌ Cons: No GPU access currently (would need passthrough setup)
> - ❌ Cons: GPU sharing complexity (currently bound to VM 100)
> - ❌ Cons: Thematically poor fit (media services belong on media VMs)
> - ❌ Cons: CPU-only transcoding would be very slow (defeats purpose)
> - **Decision**: Not chosen - lack of GPU access negates primary benefit, poor thematic fit
>
> **Option D: VM 100 with continuous operation (no scheduling)**
> - ✅ Pros: Fastest library processing (24/7 operation)
> - ✅ Pros: Maximum utilization of GPU investment
> - ❌ Cons: Direct GPU contention with Emby during household usage hours
> - ❌ Cons: Impacts critical streaming service during peak usage (evenings/weekends)
> - ❌ Cons: Resource competition could cause Emby buffering/delays
> - ❌ Cons: Unacceptable risk to 99.9% uptime target for critical service
> - **Decision**: Not chosen - unacceptable risk to critical service, household impact
>
> **Option E: VM 100 with scheduled operation (2-6 AM ET)** ✅ **CHOSEN**
> - ✅ Pros: Leverages existing GPU passthrough (no additional configuration)
> - ✅ Pros: Temporally isolated from Emby usage (2-6 AM = lowest household usage)
> - ✅ Pros: Built-in Tdarr scheduling (no external automation needed)
> - ✅ Pros: Conservative resource limits protect Emby if overlap occurs
> - ✅ Pros: No CPU expansion needed (low priority workers sufficient)
> - ✅ Pros: Test during low-risk window validates safety before full deployment
> - ⚠️ Cons: Slower processing (4 hours/day vs 24/7) - will take weeks/months for full library
> - ⚠️ Cons: Shares VM with critical service (requires careful monitoring)
> - **Decision**: ✅ CHOSEN - Best balance of performance (GPU), safety (scheduling), and simplicity (existing setup). Slower processing acceptable for batch optimization task. Low risk with proper monitoring.

### Scope Definition

**✅ In Scope:**
- Deploy Tdarr server + node stack on VM 100 via Portainer GitOps
- Configure GPU access in docker-compose (similar to Emby configuration)
- Set up MongoDB container for Tdarr database (persistent storage on NAS)
- Configure NFS mounts to media library (read/write access for transcoding)
- Set up Tdarr library schedule for 2-6 AM US Eastern Time only
- Configure resource limits (1 GPU worker, 1 CPU worker, low process priority)
- Create plugin stack with conditional logic to prevent over-transcoding:
  - Skip files already in H.265/HEVC/AV1 codec (already optimized)
  - Skip files below size thresholds (movies <20GB, TV episodes <2GB)
  - Maintain original resolution (no downscaling)
  - Use high quality preset (CRF 20-23 for H.265)
  - Verify file integrity before/after transcoding
  - Only replace if new file is smaller
- Configure library to process largest files first (maximum impact priority)
- Initial test: Process 10 largest movies as validation
- Monitor first week for Emby performance impact
- Document Tdarr configuration, plugin strategies, and operational procedures
- Create stack README with configuration details
- Create `.env.example` for secrets (MongoDB password, etc.)
- Store actual secrets in Vaultwarden

**❌ Explicitly Out of Scope:**
- Expanding VM 100 CPU cores (maintain 2 cores, use resource limits instead)
- Multi-VM Tdarr setup with distributed nodes (unnecessary complexity)
- Processing audiobooks or music libraries (focus on Movies/TV only)
- Real-time transcoding (that's Emby's responsibility)
- Automated quality verification testing (manual spot-checks acceptable)
- Advanced Tdarr features: distributed workers, multiple libraries, API integrations
- Custom FFmpeg compilation or advanced codec features (use Tdarr defaults)
- Downscaling content (4K→1080p, 1080p→720p) - maintain resolution
- Audio track optimization (focus on video codec only for initial implementation)

**🎯 MVP (Minimum Viable):**
- Tdarr deployed and accessible via web UI
- Library successfully scans media directories (builds file database)
- Successfully transcodes 10 test movies during first 2-6 AM window
- GPU acceleration confirmed working (nvidia-smi shows utilization)
- Transcoded files are smaller and play correctly (manual validation)
- Does not impact Emby streaming performance (Testing Agent validation)
- Plugins successfully prevent re-processing already transcoded files
- Schedule properly restricts operation to 2-6 AM ET window

## Risk Assessment

### Potential Pitfalls

- ⚠️ **Risk 1: GPU contention with Emby during scheduled window**
  - **Impact**: Emby buffering/stuttering if someone streams during 2-6 AM
  - **Likelihood**: Low (2-6 AM is lowest usage time historically)
  - **Mitigation**:
    - Start with conservative resource limits (1 GPU worker only)
    - Set low process priority for Tdarr (yields to Emby)
    - Monitor first week closely via `nvidia-smi` during Tdarr operation
    - Adjust schedule if any usage patterns detected (e.g., 3-6 AM instead)
    - Can immediately stop Tdarr via Portainer if issues occur

- ⚠️ **Risk 2: Over-transcoding degrades quality or creates processing loops**
  - **Impact**: Quality degradation, wasted processing, storage not reduced
  - **Likelihood**: Medium without proper plugin configuration
  - **Mitigation**:
    - Strict conditional plugins check codec before processing
    - High quality preset (CRF 20-23) maintains visual fidelity
    - Health check verifies file integrity post-transcode
    - Size validation ensures new file is actually smaller
    - Test on 10 movies first, manual quality review before expanding
    - Tdarr marks processed files to prevent re-processing

- ⚠️ **Risk 3: Tdarr process doesn't stop at 6 AM, impacts morning usage**
  - **Impact**: Emby contention during household wakeup hours (6-8 AM)
  - **Likelihood**: Low (Tdarr schedule should prevent new jobs)
  - **Mitigation**:
    - Tdarr schedule stops queuing new jobs at 6 AM
    - In-progress job may complete (typically 30-60 min per large file)
    - Monitor first week for completion times
    - Consider "hard stop" automation if jobs regularly exceed window
    - Can manually stop via Portainer if needed

- ⚠️ **Risk 4: Media file corruption during transcoding**
  - **Impact**: Loss of media file, must re-download or restore from backup
  - **Likelihood**: Low (Tdarr has built-in safeguards)
  - **Mitigation**:
    - Tdarr health check verifies file integrity before replacing original
    - Keep originals until transcoded file verified playable
    - NAS snapshots available for recovery if needed
    - Test thoroughly on 10 movies before full library
    - Manual spot-check quality on test files
    - Can restore from Synology NAS previous versions feature

- ⚠️ **Risk 5: Unexpected resource consumption affects VM 100 stability**
  - **Impact**: VM 100 becomes unresponsive, Emby service disruption
  - **Likelihood**: Very Low with proper resource limits
  - **Mitigation**:
    - Conservative limits: 1 GPU worker, 1 CPU worker
    - Low process priority (nice value) ensures Emby takes precedence
    - Monitor VM resources closely first week (CPU, RAM, disk I/O)
    - Testing Agent validates Emby responsiveness during Tdarr operation
    - Can immediately stop Tdarr stack if any stability issues
    - VM 100 has 8GB RAM, Tdarr typically uses 1-2GB max

- ⚠️ **Risk 6: Library scan takes longer than expected, delays testing**
  - **Impact**: First transcode test delayed by 1-2 days
  - **Likelihood**: Medium (44TB library is large)
  - **Mitigation**:
    - Library scan runs in background, doesn't block other operations
    - Can start processing largest movies while scan continues
    - First night: scan + process 10 test movies (may not complete scan)
    - Subsequent nights: continue scan + process queued files
    - Acceptable delay for proper database building

### Dependencies

**Prerequisites (must exist before starting):**
- [x] **GPU passthrough on VM 100** - Already configured (IN-032) (blocking: no)
- [x] **NFS media mounts accessible from VM 100** - Already mounted for Emby (blocking: no)
- [x] **nvidia-docker runtime on VM 100** - Already installed for Emby (blocking: no)
- [ ] **Research Tdarr plugin ecosystem** - Understand available plugins and best practices for H.265 conversion (blocking: yes - critical for proper configuration)
- [ ] **Bitwarden session for secrets** - User must provide session token for MongoDB password retrieval (blocking: yes - for deployment)
- [ ] **Backup Emby stack config** - Safety net before adding new workload to VM 100 (blocking: no - can do during task)

**No immediate blocking dependencies** - can start after brief plugin research and obtaining Bitwarden session

### Critical Service Impact

**Services Affected**: Emby (VM 100) - CRITICAL

**Emby (VM 100) Impact Analysis:**
- **Shared GPU**: Both Emby and Tdarr will use NVIDIA RTX 4060 Ti
  - **Temporal isolation**: Tdarr only operates 2-6 AM (lowest Emby usage)
  - **GPU capacity**: RTX 4060 Ti can handle multiple concurrent encodes
  - **Priority**: Tdarr process priority set to low (yields to Emby if contention)
  - **Risk**: LOW - scheduled to avoid typical usage, can handle concurrent loads

- **Shared CPU**: Tdarr limited to 1 CPU worker with low priority
  - **VM 100 allocation**: 2 cores total
  - **Emby typical usage**: <10% during streaming, 60-80% during transcoding
  - **Tdarr limit**: 1 worker, low nice value (yields CPU to Emby)
  - **Risk**: LOW - conservative limits, priority system ensures Emby wins

- **Shared Memory**: Both services use VM 100's 8GB RAM
  - **Emby typical usage**: 1-2GB
  - **Tdarr typical usage**: 1-2GB (server + node + MongoDB)
  - **Available**: 8GB total, 6.2GB typically available
  - **Risk**: LOW - adequate headroom for both services

- **Shared Storage**: Both read from media library, Tdarr also writes
  - **NFS mount**: Same media directories
  - **Emby access**: Read-only streaming
  - **Tdarr access**: Read source, write transcoded file
  - **Risk**: LOW - NFS can handle concurrent access, no file locking conflicts

- **Network**: Minimal impact (local docker bridge communication)
  - **Risk**: VERY LOW - no external network saturation

**Overall Risk Level**: LOW
- Scheduled for lowest usage window (2-6 AM ET)
- Strict resource limits protect Emby priority
- Process priority system ensures Emby always wins contention
- Can be stopped immediately via Portainer if any issues detected
- One week monitoring period validates safety before expanding

**Mitigation Strategy:**
- Deploy during Emby low-usage window (3-6 AM deployment time)
- Monitor Emby performance metrics for first week after Tdarr deployment
- Testing Agent validates Emby responsiveness during and after Tdarr operations
- Ready to stop Tdarr immediately if any performance degradation detected
- User spot-checks streaming quality during first week
- Adjust resource limits or schedule if any issues observed

### Rollback Plan

**Applicable for**: Docker stack deployment on critical service VM

**How to rollback if this goes wrong:**
1. **Immediate stop** (if active processing causing issues):
   ```bash
   # Via Portainer UI: Stacks → tdarr → Stop
   # OR via SSH:
   ssh evan@192.168.86.172
   cd /path/to/tdarr/stack
   docker compose down
   ```
   - Stops all Tdarr containers immediately
   - Releases GPU and CPU resources
   - Emby unaffected (continues running)
   - **Recovery time**: < 1 minute

2. **Restore any corrupted files** (if transcoding caused issues):
   ```bash
   # Via Synology NAS previous versions feature
   # Navigate to file in DSM File Station
   # Right-click → Restore from previous version
   ```
   - Or re-download affected media via *arr services
   - **Recovery time**: Varies (minutes to hours depending on file size)

3. **Remove Tdarr stack completely**:
   ```bash
   # Via Portainer: Stacks → tdarr → Delete
   # Removes containers, networks, volumes
   ```
   - Cleans up all Tdarr resources
   - **Recovery time**: < 5 minutes

4. **Clean up Tdarr config directory**:
   ```bash
   ssh evan@192.168.86.172
   sudo rm -rf /mnt/nas/configs/tdarr
   ```
   - Removes Tdarr database and logs
   - **Recovery time**: < 5 minutes

5. **Git revert docker-compose changes**:
   ```bash
   cd /Users/evanstern/projects/evanstern/infinity-node
   git revert <commit-hash>
   git push
   ```
   - Removes Tdarr stack from repository
   - **Recovery time**: < 5 minutes

6. **Restore Emby config from backup** (if Emby affected):
   ```bash
   # Restore from backup created at task start
   ssh evan@192.168.86.172
   # Stop Emby, restore config, restart
   ```
   - **Recovery time**: < 15 minutes

**Total Recovery Time Estimate**:
- **Emergency stop**: < 1 minute
- **Full rollback**: < 30 minutes
- **With file restoration**: Varies (up to several hours for large files)

**Backup Requirements:**
- **Before deployment**:
  - Backup Emby stack config: `./scripts/infrastructure/backup-stack.sh emby vm-100`
  - Verify NAS snapshots enabled (Synology snapshot replication)
  - Git commit all changes (allows revert)
  - Document current VM 100 resource usage (baseline metrics)

- **Before full library processing** (after successful test):
  - User-initiated NAS snapshot via Synology DSM
  - Captures media library state before bulk transcoding
  - Allows rollback if widespread issues discovered

## Execution Plan

### Phase 0: Research & Preparation

**Primary Agent**: `media`

- [ ] **Research Tdarr plugin ecosystem** `[agent:media]`
  - Identify available plugins for H.264 → H.265 conversion
  - Research community-recommended plugins for quality preservation
  - Understand plugin configuration syntax and options
  - Find plugins for conditional processing (skip if already H.265, size checks)
  - Document recommended plugin stack for high-quality transcoding

- [ ] **Obtain Bitwarden session token** `[agent:media]`
  - User runs: `./scripts/utils/get-bw-session.sh`
  - Provides session token for secret retrieval
  - Retrieve MongoDB password from Vaultwarden (or generate new)

- [ ] **Backup Emby stack configuration** `[agent:infrastructure]`
  - Run: `./scripts/infrastructure/backup-stack.sh emby vm-100`
  - Verify backup created successfully
  - Document current VM 100 resource utilization (baseline)

### Phase 1: Deploy Tdarr Stack

**Primary Agent**: `docker`

- [ ] **Create Tdarr stack directory structure** `[agent:docker]`
  - Create `stacks/tdarr/` directory
  - Create `docker-compose.yml` with server + node + MongoDB
  - Create `.env.example` with required variables
  - Create `README.md` with stack documentation

- [ ] **Configure docker-compose with GPU support** `[agent:docker]` `[risk:1]`
  - Add Tdarr server container (ghcr.io/haveagitgat/tdarr:latest)
  - Add Tdarr node container with GPU access (deploy.resources.reservations.devices)
  - Add MongoDB container for database (mongo:4.4)
  - Configure nvidia runtime and environment variables (similar to Emby)
  - Set resource limits (1 GPU worker, 1 CPU worker)
  - Configure low process priority (nice value)

- [ ] **Configure NFS volume mounts** `[agent:docker]`
  - Mount media library directories (read/write access)
  - Mount Tdarr config directory on NAS (persistent storage)
  - Mount transcode cache directory (tmpfs or NAS location)

- [ ] **Store secrets in Vaultwarden** `[agent:security]`
  - Store MongoDB root password in Vaultwarden (vm-100-emby folder)
  - Store Tdarr server API key (generated on first start)
  - Create `.env` file on VM 100 with secret values

- [ ] **Commit stack to git** `[agent:docker]`
  - Git add docker-compose.yml, README.md, .env.example
  - Commit: "feat: add Tdarr stack for media optimization (IN-036)"
  - Push to origin/main

- [ ] **Deploy via Portainer** `[agent:docker]` `[blocking]`
  - Portainer → Stacks → Add stack from Git repository
  - Configure Git sync for automatic updates
  - Deploy stack (pull images, start containers)
  - Verify all containers running (server, node, MongoDB)

- [ ] **Verify GPU access** `[agent:docker]`
  - SSH to VM 100: `ssh evan@192.168.86.172`
  - Check GPU visible in Tdarr node: `docker exec tdarr_node nvidia-smi`
  - Should show RTX 4060 Ti with driver version

- [ ] **Access Tdarr web UI** `[agent:docker]`
  - Navigate to: `http://192.168.86.172:8265` (default Tdarr port)
  - Complete initial setup wizard
  - Verify UI loads and is responsive

### Phase 2: Configure Scheduling & Resources

**Primary Agent**: `media`

- [ ] **Configure library schedule** `[agent:media]` `[risk:3]`
  - Tdarr UI → Libraries → Schedule settings
  - Set processing window: 2:00 AM - 6:00 AM US Eastern Time
  - Verify timezone set correctly (America/New_York)
  - Enable "Process Library" only during this window
  - Disable processing outside window (strict enforcement)

- [ ] **Configure worker limits** `[agent:media]` `[risk:5]`
  - Tdarr UI → Nodes → Node options
  - Set GPU workers: 1
  - Set CPU workers: 1
  - Enable "Allow GPU workers to do CPU tasks" (flexibility)
  - Set process priority to "Low" or configure nice value

- [ ] **Configure hardware encoding** `[agent:media]`
  - Tdarr UI → Nodes → Hardware encoding
  - Select "NVIDIA NVENC" as encoder type
  - Verify GPU encoder detected and available
  - Test with single file encode to confirm GPU utilization

### Phase 3: Create Smart Transcoding Plugins

**Primary Agent**: `media`

- [ ] **Add library for Movies** `[agent:media]`
  - Tdarr UI → Libraries → Add Library
  - Name: "Movies"
  - Path: `/media/movies` (mounted NFS path)
  - Scan on startup: Enabled
  - Priority: Process largest files first

- [ ] **Create plugin stack for Movies** `[agent:media]` `[risk:2]`
  - Tdarr UI → Libraries → Movies → Transcode options
  - Add plugins in order:
    1. **Check codec**: Skip if already H.265/HEVC/AV1
    2. **Check file size**: Skip if < 20GB
    3. **Check resolution**: Read current resolution (maintain it)
    4. **Transcode to H.265**: FFmpeg with NVENC, CRF 20-23, maintain resolution
    5. **Health check**: Verify output file integrity
    6. **Size validation**: Only keep if new file is smaller
  - Configure high quality preset (CRF 20-23 for H.265)
  - Enable "Replace original" only after health check passes

- [ ] **Add library for TV Shows** `[agent:media]`
  - Tdarr UI → Libraries → Add Library
  - Name: "TV Shows"
  - Path: `/media/tv` (mounted NFS path)
  - Scan on startup: Enabled
  - Priority: Process largest files first

- [ ] **Create plugin stack for TV Shows** `[agent:media]` `[risk:2]`
  - Tdarr UI → Libraries → TV Shows → Transcode options
  - Add plugins in order (similar to Movies, different size threshold):
    1. **Check codec**: Skip if already H.265/HEVC/AV1
    2. **Check file size**: Skip if < 2GB
    3. **Check resolution**: Read current resolution (maintain it)
    4. **Transcode to H.265**: FFmpeg with NVENC, CRF 20-23, maintain resolution
    5. **Health check**: Verify output file integrity
    6. **Size validation**: Only keep if new file is smaller
  - Configure high quality preset (CRF 20-23 for H.265)
  - Enable "Replace original" only after health check passes

- [ ] **Test plugin stack logic** `[agent:media]` `[optional]`
  - Manually trigger transcode on single test file from each library (outside schedule)
  - Verify plugin conditions work correctly:
    - H.265 file → skipped
    - Small file → skipped (Movies <20GB, TV <2GB)
    - Large H.264 file → transcoded
  - Check output quality and file size reduction

### Phase 4: Initial Test (10 Largest Movies)

**Primary Agent**: `media`

- [ ] **Initiate library scans** `[agent:media]`
  - Tdarr UI → Libraries → Movies → Scan
  - Tdarr UI → Libraries → TV Shows → Scan
  - Begin background scan of both directories
  - Monitor scan progress (may take several hours for large libraries)
  - Note: Scans continue in background, don't block processing

- [ ] **Configure test batch for Movies only** `[agent:media]`
  - Tdarr UI → Libraries → Movies → Settings
  - Filter: Set temporary limit to 10 files
  - Sort: By file size descending (largest first)
  - Verify queue shows 10 largest movies ready for processing
  - Leave TV Shows library disabled for now (test Movies first)

- [ ] **Wait for first scheduled window (2-6 AM ET)** `[agent:media]`
  - Tdarr will automatically start processing at 2:00 AM
  - No manual intervention needed (scheduled operation)
  - Monitor overnight or check results in morning

- [ ] **Monitor first transcode session** `[agent:media]` `[optional]`
  - If awake during 2-6 AM window, monitor live:
    - Tdarr UI → Activity → Watch progress
    - SSH: `nvidia-smi dmon -s u` (watch GPU utilization)
    - Check Emby remains responsive (stream test video)
  - Otherwise, review logs in morning

- [ ] **Review morning-after results** `[agent:media]`
  - Tdarr UI → Completed → Review processed files
  - Check file size reduction (e.g., "32GB → 18GB, saved 44%")
  - Note processing speed (e.g., "processed 3 of 10 files in 4 hours")
  - Verify Tdarr stopped at 6:00 AM (no overrun)

- [ ] **Manual quality validation** `[agent:media]` `[risk:4]`
  - Via Emby: Play 2-3 transcoded movies
  - Watch for artifacts, quality degradation, audio sync issues
  - Compare subjective quality to originals (if available)
  - Verify resolution maintained (1080p → 1080p, 4K → 4K)
  - Check file integrity (no corruption, plays completely)

- [ ] **Document test results** `[agent:documentation]`
  - Record size reduction percentages
  - Note processing speed (files per hour)
  - Document any quality issues observed
  - Capture GPU utilization metrics
  - Note Emby performance during/after Tdarr operation

### Phase 5: Monitor & Validate (1 Week)

**Primary Agent**: `testing`

- [ ] **Validate Emby responsiveness** `[agent:testing]`
  - Test Emby streaming during and after Tdarr windows
  - Verify no buffering or performance degradation
  - Check Emby logs for errors during Tdarr operation
  - Validate Emby transcode performance unchanged

- [ ] **Monitor VM 100 resources** `[agent:testing]`
  - Check CPU utilization during Tdarr windows
  - Monitor RAM usage (ensure within 8GB limit)
  - Review docker stats for resource consumption
  - Verify no OOM (out of memory) events

- [ ] **Monitor GPU sharing** `[agent:testing]`
  - During Tdarr window: `nvidia-smi dmon` to watch GPU utilization
  - Check for GPU memory issues or contention
  - Verify both Emby and Tdarr can access GPU (if overlap occurs)
  - Note GPU temperature and power consumption

- [ ] **Verify schedule adherence** `[agent:testing]` `[risk:3]`
  - Check Tdarr logs for start/stop times
  - Confirm processing begins at 2:00 AM ET
  - Confirm processing stops queuing new jobs at 6:00 AM ET
  - Note if any jobs run past 6:00 AM (completion of in-progress)

- [ ] **Check for over-transcoding** `[agent:testing]` `[risk:2]`
  - Verify plugin logic working: H.265 files skipped
  - Check that processed files not re-queued (marked complete)
  - Review Tdarr logs for plugin skip decisions
  - Confirm only files meeting criteria processed

- [ ] **User feedback collection** `[agent:media]`
  - User watches several transcoded movies throughout week
  - Reports any quality issues, artifacts, or problems
  - Confirms acceptable quality vs size tradeoff
  - Approves proceeding to full library or requests adjustments

### Phase 6: Expand to Full Library (After Validation)

**Primary Agent**: `media`

- [ ] **Review test results with user** `[agent:media]`
  - Present test metrics: size savings, processing speed, quality
  - Discuss any adjustments needed (CRF, thresholds, schedule)
  - Obtain user approval to proceed to full library
  - Address any concerns or changes

- [ ] **Adjust configuration based on learnings** `[agent:media]`
  - If quality issues: Increase CRF quality (lower CRF value)
  - If too slow: Consider adding 2nd GPU worker (if safe)
  - If schedule overrun: Adjust end time to 5:30 AM (buffer)
  - Update plugin stacks with any refinements

- [ ] **Remove test file limit on Movies** `[agent:media]` `[blocking]`
  - Tdarr UI → Libraries → Movies → Settings
  - Remove 10-file limit filter
  - Enable full library processing (all movies ≥20GB)
  - Confirm largest-first sorting maintained

- [ ] **Enable TV Shows library processing** `[agent:media]`
  - Tdarr UI → Libraries → TV Shows → Settings
  - Confirm plugin stack configured correctly (≥2GB threshold)
  - Enable processing (both libraries will now process)
  - Confirm largest-first sorting maintained
  - Note: Both libraries will compete for same 4-hour window, so processing will be distributed

- [ ] **Monitor first full week** `[agent:media]`
  - Track daily progress (how many files per night from both libraries)
  - Estimate completion time for full libraries
  - Watch for any issues at scale
  - Monitor how Tdarr prioritizes between two libraries (largest across both)
  - Adjust as needed based on observations

### Phase 7: Documentation

**Primary Agent**: `documentation`

- [ ] **Update stack README** `[agent:documentation]`
  - Document Tdarr configuration details
  - Explain scheduling and resource limits
  - List plugin stack and rationale
  - Include troubleshooting tips
  - Add monitoring commands (nvidia-smi, docker stats)

- [ ] **Document operational procedures** `[agent:documentation]`
  - How to stop/start Tdarr manually
  - How to adjust schedule or resource limits
  - How to add new libraries or change thresholds
  - How to validate GPU access and transcode performance
  - Emergency rollback procedures

- [ ] **Update ARCHITECTURE.md** `[agent:documentation]`
  - Add Tdarr to VM 100 services list
  - Document GPU sharing between Emby and Tdarr
  - Note scheduled operation hours
  - Update resource allocation notes

- [ ] **Create ADR for Tdarr placement decision** `[agent:documentation]` `[optional]`
  - Document why VM 100 chosen over alternatives
  - Explain scheduling rationale (2-6 AM)
  - Capture lessons learned for future similar services

## Acceptance Criteria

**Done when all of these are true:**
- [ ] Tdarr stack deployed on VM 100 and accessible via web UI
- [ ] GPU acceleration working (verified via nvidia-smi during transcode)
- [ ] Library schedule restricts processing to 2-6 AM US Eastern Time only
- [ ] Resource limits configured (1 GPU worker, 1 CPU worker, low priority)
- [ ] Plugin stack successfully prevents over-transcoding:
  - Skips files already in H.265/HEVC/AV1
  - Skips files below size thresholds (movies <20GB, TV <2GB)
  - Maintains original resolution
  - Produces smaller files with acceptable quality
- [ ] Successfully transcoded 10 test movies with 30-50% size reduction
- [ ] Manual quality validation confirms no perceptible quality loss
- [ ] Testing Agent validates Emby performance unaffected during Tdarr operation
- [ ] One week monitoring shows no stability or performance issues
- [ ] Schedule adherence confirmed (starts at 2 AM, stops queuing at 6 AM)
- [ ] User approves quality vs size tradeoff
- [ ] Full library processing enabled (test limit removed)
- [ ] All execution plan items completed
- [ ] Documentation complete (stack README, operational procedures)
- [ ] Changes committed to git with descriptive message (awaiting user approval)

## Testing Plan

**[[docs/agents/TESTING|Testing Agent]] validates:**

**Automated checks:**
- Tdarr containers running and healthy (`docker ps`, health checks)
- GPU accessible to Tdarr node (`docker exec tdarr_node nvidia-smi`)
- Emby container still running and healthy (not affected by deployment)
- VM 100 resource usage within acceptable limits (CPU, RAM, disk)
- No docker errors or restarts during Tdarr operation

**Functional validation:**
- Tdarr web UI accessible and responsive
- Library scan completes successfully
- Transcode jobs execute during scheduled window (2-6 AM)
- Transcode jobs do not execute outside scheduled window
- GPU utilized during transcode (verify via `nvidia-smi dmon`)
- Processed files are smaller than originals
- Processed files play correctly in Emby

**Performance validation:**
- Emby streaming performance unchanged during Tdarr operation
- Emby transcode performance unchanged after Tdarr deployment
- No buffering or stuttering when streaming during Tdarr window (if tested)
- VM 100 remains responsive (SSH, docker commands execute normally)

**Schedule validation:**
- Tdarr starts processing at 2:00 AM ET (check logs)
- Tdarr stops queuing new jobs at 6:00 AM ET (check logs)
- In-progress jobs allowed to complete (acceptable overrun)
- No processing occurs outside 2-6 AM window

**Safety validation:**
- No file corruption detected (file integrity checks pass)
- Plugin logic correctly skips H.265 files (verify via logs)
- Plugin logic correctly skips small files (verify via logs)
- No re-processing of already transcoded files

**Manual validation:**
1. **Deploy Tdarr stack**: Verify containers start successfully, no errors in logs
2. **Access web UI**: Navigate to `http://192.168.86.172:8265`, complete setup wizard
3. **Configure schedule**: Set 2-6 AM ET window, verify timezone correct
4. **Test GPU access**: Run `docker exec tdarr_node nvidia-smi`, verify GPU visible
5. **Initiate library scan**: Add Movies library, start scan, monitor progress
6. **Wait for first window**: Allow Tdarr to process during first 2-6 AM window
7. **Review results**: Check Tdarr UI for completed jobs, file size reductions
8. **Quality check**: Play 2-3 transcoded movies in Emby, verify quality acceptable
9. **Emby performance**: Stream content during Tdarr window (if awake), verify no issues
10. **Monitor week**: Daily checks of Tdarr progress, Emby performance, VM resources
11. **User approval**: User confirms quality acceptable, approves full library
12. **Expand processing**: Remove test limit, enable full library processing

## Related Documentation

- [[docs/ARCHITECTURE|Infrastructure Architecture]] - VM 100 details and resource allocation
- [[docs/adr/013-emby-transcoding-optimization|ADR-013: Emby Transcoding Optimization]] - GPU passthrough decision and rationale
- [[docs/adr/011-critical-services-list|ADR-011: Critical Services List]] - Why Emby is critical
- [[stacks/emby/README|Emby Stack Documentation]] - GPU configuration reference
- [[tasks/completed/IN-032-implement-emby-gpu-passthrough|IN-032]] - GPU passthrough implementation
- [[docs/research/proxmox-nvidia-gpu-passthrough-configuration|GPU Passthrough Research]] - Technical GPU setup details
- [[docs/agents/MEDIA|Media Stack Agent]] - Responsible agent for this task
- [[docs/agents/DOCKER|Docker Agent]] - Docker stack deployment procedures
- [[docs/agents/TESTING|Testing Agent]] - Validation procedures

## Notes

**Priority Rationale**:
Priority 4 (Medium) - Important optimization task but not urgent:
- Storage at 77% gives runway (not critical threshold yet)
- Emby working well, no immediate pressure
- Benefits are long-term (slower storage growth, efficient GPU use)
- Requires careful implementation and monitoring (can't rush)
- Higher priority than documentation tasks, lower than critical service fixes

**Complexity Rationale**:
Complex task due to multiple challenging factors:
- Deploying on critical service VM requires extra caution
- GPU sharing between services (Emby + Tdarr) is delicate
- Scheduling configuration crucial to avoid contention
- Plugin logic must be carefully designed to prevent over-transcoding
- Requires iterative testing and validation (test batch → week monitoring → full library)
- Multi-phase execution with validation gates
- Quality vs compression tradeoff requires judgment and tuning
- Involves Docker, GPU, scheduling, plugins, monitoring - many components

**Implementation Notes**:
- **Timezone**: Ensure Tdarr server container has correct timezone (America/New_York) via TZ environment variable
- **MongoDB version**: Use MongoDB 4.4 (known compatible with Tdarr), not latest (may have compatibility issues)
- **Transcode cache**: Consider tmpfs for Tdarr transcode directory (similar to Emby, reduces disk wear)
- **FFmpeg**: Tdarr includes FFmpeg, but verify NVENC support compiled in (should be by default)
- **Plugin repository**: Tdarr has community plugin repository, research before creating custom plugins
- **Processing speed estimate**: RTX 4060 Ti can transcode ~3-5 large movies per 4-hour window (GPU-dependent)
- **Library completion time**: 44TB library at ~50GB/movie average ≈ 880 movies. At 4 movies/night ≈ 220 nights (7+ months). Acceptable for batch optimization.
- **Alternative schedule**: If 2-6 AM too short, could extend to midnight-6 AM (6 hours), but requires testing Emby impact during midnight-2 AM window.

**Follow-up Tasks**:
- Future: Add TV Shows library after Movies complete (separate task, similar configuration)
- Future: Consider more aggressive compression for lower-priority content (second-pass optimization)
- Future: Explore audio track optimization (remove unnecessary language tracks, optimize audio codecs)
- Future: Investigate 4K → 1080p downscaling for content where 4K not necessary (separate decision/task)
- Future: Integrate Tdarr metrics with monitoring system (when IN-005 completed)

---

> [!note]- 📋 Work Log
>
> **2025-11-01 - Task Created**
> - Task designed in collaboration with user
> - Detailed alternatives analysis conducted
> - Phased approach planned (test → validate → expand)
> - Ready for implementation after plugin research

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
