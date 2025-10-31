---
type: task
task-id: IN-031
status: pending
priority: 4
category: media
agent: docker
created: 2025-10-31
updated: 2025-10-31
started:
completed:

# Task classification
complexity: simple
estimated_duration: 1h
critical_services_affected: true
requires_backup: true
requires_downtime: false

# Design tracking
alternatives_considered: true
risk_assessment_done: true
phased_approach: true

tags:
  - task
  - emby
  - transcoding
  - performance
  - docker
  - tmpfs
---

# Task: IN-031 - Implement Emby tmpfs Transcode Cache

> **Quick Summary**: Add tmpfs (RAM-based) mount for Emby's transcode directory to improve transcode start times by 10-20% and eliminate SSD wear.

## Problem Statement

**What problem are we solving?**
Emby currently stores temporary transcode files on NVMe SSD storage. While fast, this creates unnecessary SSD wear and isn't as fast as RAM. tmpfs provides:
- Faster access for transcode temp files (RAM speed vs SSD speed)
- Eliminated SSD wear for temporary files
- 10-20% improvement in transcode start times

**Why now?**
- Research (IN-007) confirmed tmpfs is a quick win with low risk
- VM 100 has 6.4GB available RAM (plenty for tmpfs)
- Easy implementation before tackling GPU passthrough
- Sets performance baseline for GPU passthrough comparison

**Who benefits?**
- **Household users**: Faster transcode start times, quicker playback
- **Infrastructure**: Reduced SSD wear, longer storage lifespan
- **Future optimization**: Clean baseline for measuring GPU passthrough improvement

## Solution Design

**Chosen Approach:**
Add a 4GB tmpfs mount to Emby's docker-compose for the `/transcode` directory.

**Why tmpfs?**
- ✅ RAM-speed access (faster than NVMe)
- ✅ No SSD wear on temporary files
- ✅ Easy to implement (docker-compose only)
- ✅ Automatic cleanup on restart
- ✅ No risk (files are temporary anyway)

**Implementation:**
```yaml
services:
  embyserver:
    volumes:
      - ${CONFIG_PATH}:/config
      - ${MEDIA_PATH}:/mnt/movies
    tmpfs:
      - /transcode:size=4G,mode=1777
```

**Configuration in Emby:**
Update Emby settings to use `/transcode` as transcode directory.

## Alternatives Considered

### Alternative 1: Larger tmpfs (8GB)
- **Pros**: More headroom for multiple concurrent transcodes
- **Cons**: More RAM usage, not needed based on current usage (2.1MB)
- **Decision**: Start with 4GB, can increase if needed

### Alternative 2: Keep on NVMe (no change)
- **Pros**: No changes, no risk
- **Cons**: Misses easy performance win, continued SSD wear
- **Decision**: Rejected - tmpfs benefit is free and easy

### Alternative 3: Separate tmpfs partition on host
- **Pros**: Shared across containers
- **Cons**: More complex, not needed for single service
- **Decision**: Rejected - docker tmpfs is simpler

## Scope Definition

**In Scope:**
- ✅ Capture baseline performance measurements
- ✅ Add tmpfs mount to Emby docker-compose
- ✅ Update Emby transcode path configuration
- ✅ Test transcode with tmpfs
- ✅ Measure improvement vs baseline
- ✅ Validate 10-20% improvement achieved
- ✅ Document changes

**Out of Scope:**
- ❌ GPU passthrough (separate task: IN-032)
- ❌ Emby UI/UX changes
- ❌ tmpfs for other services
- ❌ VM RAM increases (6.4GB available is sufficient)

**MVP Definition:**
tmpfs working for Emby transcodes with measurable improvement over baseline.

## Risk Assessment

**Potential Risks:**

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| RAM exhaustion during large transcodes | High | Low | 4GB limit prevents runaway usage |
| Transcode failures if tmpfs fills | Medium | Low | Monitor during testing, can increase size |
| Loss of transcode on restart | Low | N/A | Expected behavior (temp files) |
| Performance worse than NVMe | Low | Very Low | Baseline measurements prove benefit |

**Dependencies:**
- Emby must be configured to use `/transcode` path
- Docker supports tmpfs mounts (standard feature)

**Critical Service Impact:**
- ⚠️ **Emby is critical** (household media streaming)
- Changes are non-destructive (can revert immediately)
- No downtime required (rolling restart)

**Rollback Plan:**
1. Stop Emby container
2. Remove tmpfs mount from docker-compose
3. Restart Emby (reverts to NVMe storage)
4. Total rollback time: < 2 minutes

## Execution Plan

### Phase 0: Capture Baseline Performance

**Primary Agent**: `media`

- [ ] **Select test media** `[agent:media]`
  - Choose 3 test files: 1080p H.264, 4K HEVC, 1080p with subtitles
  - Document: file names, codecs, sizes
  - These will be used for before/after comparison

- [ ] **Measure current performance** `[agent:media]`
  - For each test file, trigger transcode via Emby UI
  - Measure: Time to start playing (transcode start time)
  - Measure: CPU usage during transcode (via `top`)
  - Document: All measurements in task notes
  - Example: "1080p H.264: 8s start, 65% CPU, 2.4x speed"

- [ ] **Document baseline** `[agent:documentation]`
  - Create table with all baseline measurements
  - Note current transcode path: `/config/transcoding-temp`
  - This is our comparison point for tmpfs improvement

### Phase 1: Backup and Preparation

**Primary Agent**: `infrastructure`

- [ ] **Backup VM 100** `[agent:infrastructure]` `[critical]`
  - VM already has snapshot from IN-007: `emby-research-backup`
  - Verify snapshot still exists: `ssh root@192.168.86.106 "qm listsnapshot 100"`
  - If needed, create fresh snapshot: `qm snapshot 100 emby-tmpfs-backup`
  - Document snapshot name for rollback

- [ ] **Backup Emby configuration** `[agent:media]`
  - SSH to VM 100: `ssh evan@192.168.86.172`
  - Backup config: `tar -czf ~/emby-config-backup-$(date +%Y%m%d-%H%M).tar.gz /home/evan/projects/infinity-node/stacks/emby/config`
  - Verify backup created: `ls -lh ~/emby-config-backup-*.tar.gz | tail -1`
  - Document backup location

### Phase 2: Implement tmpfs Mount

**Primary Agent**: `docker`

- [ ] **Update docker-compose.yml** `[agent:docker]`
  - Edit `stacks/emby/docker-compose.yml`
  - Add tmpfs mount:
    ```yaml
    tmpfs:
      - /transcode:size=4G,mode=1777
    ```
  - Validate syntax: `docker-compose -f stacks/emby/docker-compose.yml config`
  - Document changes

- [ ] **Update Emby configuration** `[agent:media]`
  - Access Emby web UI: Settings → Transcoding
  - Set transcode path to: `/transcode`
  - Save configuration
  - Document setting location for future reference

- [ ] **Deploy updated stack via Portainer** `[agent:docker]`
  - Commit docker-compose changes to git
  - Use Portainer API to redeploy from Git:
    ```bash
    ./scripts/infrastructure/redeploy-git-stack.sh \
      --secret "portainer-api-token-vm-100" \
      --stack-name "emby"
    ```
  - OR use Portainer UI: Stacks → emby → "Pull and redeploy"
  - Verify container started: `docker ps | grep emby`
  - Check logs: `docker logs emby --tail 50`

### Phase 3: Validation and Testing

**Primary Agent**: `media`

- [ ] **Verify tmpfs mount** `[agent:docker]`
  - Check mount inside container: `docker exec emby df -h | grep transcode`
  - Should show: tmpfs 4.0G mount
  - Verify write permissions: `docker exec emby touch /transcode/test && docker exec emby rm /transcode/test`
  - Confirm Emby sees the path (check Emby settings)

- [ ] **Test transcodes with tmpfs** `[agent:media]`
  - Use same 3 test files from baseline
  - Trigger transcode for each file
  - Measure: Time to start playing
  - Measure: CPU usage during transcode
  - Observe: Any errors or issues

- [ ] **Measure improvement** `[agent:media]`
  - Compare tmpfs measurements to baseline
  - Calculate improvement percentage for each test file
  - Expected: 10-20% faster start times
  - Document all measurements in task notes

- [ ] **Stress test** `[agent:testing]` `[optional]`
  - Start 2-3 concurrent transcodes
  - Monitor tmpfs usage: `docker exec emby df -h | grep transcode`
  - Verify no RAM exhaustion on VM: `ssh evan@192.168.86.172 free -h`
  - Confirm all transcodes complete successfully

### Phase 4: Documentation

**Primary Agent**: `documentation`

- [ ] **Update stack documentation** `[agent:documentation]`
  - Update `stacks/emby/README.md` with tmpfs configuration
  - Document: Why tmpfs is used, size chosen, expected benefit
  - Add rollback instructions
  - Link to IN-031 and ADR 013

- [ ] **Document performance improvement** `[agent:documentation]`
  - Create comparison table (baseline vs tmpfs)
  - Calculate actual improvement achieved
  - Add to task work log
  - This becomes baseline for GPU passthrough (IN-032)

## Acceptance Criteria

**Done when all of these are true:**
- [ ] Baseline performance measurements captured for 3 test files
- [ ] VM 100 backup/snapshot verified
- [ ] Emby configuration backed up
- [ ] tmpfs mount added to docker-compose.yml
- [ ] Emby configured to use `/transcode` path
- [ ] Emby container running with tmpfs mount
- [ ] tmpfs mount verified inside container (4GB, writable)
- [ ] Test transcodes complete successfully with tmpfs
- [ ] Improvement measured (10-20% faster start times)
- [ ] Documentation updated (stack README, task notes)
- [ ] Changes committed to git

## Testing Plan

**[[docs/agents/TESTING|Testing Agent]] validates:**
- tmpfs mount exists and has correct size/permissions
- Emby can write to /transcode directory
- Transcodes complete without errors
- Performance improvement is measurable and documented
- Rollback procedure is documented and tested (if time permits)

**Manual validation:**
1. **Verify tmpfs mount**: `docker exec emby df -h | grep transcode`
2. **Test transcode**: Play any media that requires transcoding
3. **Monitor RAM usage**: `free -h` on VM 100 during transcode
4. **Check Emby logs**: No errors related to transcode directory
5. **Validate improvement**: Compare measurements to baseline

## Related Documentation

- [[tasks/completed/IN-007-research-emby-transcoding-optimization|IN-007]] - Research that led to this task
- [[docs/adr/013-emby-transcoding-optimization|ADR 013]] - Decision context
- [[docs/research/proxmox-hardware-capabilities|Hardware Capabilities]] - VM 100 RAM availability
- [[docs/ARCHITECTURE|Architecture]] - VM 100 (Emby) infrastructure
- [[stacks/emby/README|Emby Stack Documentation]] - Service configuration

## Notes

**Priority Rationale:**
Priority 4 (medium-high) because:
- Quick win with measurable benefit
- Low risk, easy rollback
- Enables GPU passthrough baseline comparison
- Critical service (Emby) but non-destructive change

**Implementation Notes:**
- VM 100 has 6.4GB available RAM - 4GB tmpfs is safe
- Current transcode usage is only 2.1MB - 4GB is plenty
- tmpfs files lost on restart is expected (they're temporary)
- If 4GB proves insufficient, can increase to 6GB easily

**Follow-up Tasks:**
- [ ] IN-032: Implement GPU passthrough (uses tmpfs baseline)
- [ ] Consider tmpfs for other transcoding services if benefit proven

---

## Work Log

> [!note]- 📋 Work Log
>
> *Progress notes added during execution*

---

## Lessons Learned

> [!tip]- 💡 Lessons Learned
>
> *Added during/after execution*

> **What Worked Well:**

> **What Could Be Better:**

> **Scope Evolution:**
