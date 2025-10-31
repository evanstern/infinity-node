---
type: task
task-id: IN-007
status: backlog
priority: 3
category: media
agent: media
created: 2025-10-31
updated: 2025-10-31
started:
completed:

# Task classification
complexity: moderate
estimated_duration: 3-4h
critical_services_affected: true
requires_backup: true
requires_downtime: false

# Design tracking
alternatives_considered: true
risk_assessment_done: true
phased_approach: true

tags:
  - task
  - media
  - emby
  - research
  - performance
  - transcoding
  - optimization
---

# Task: IN-007 - Research Emby Transcoding Optimization Options

> **Quick Summary**: Research and evaluate Emby transcoding optimization options (tmpfs and hardware transcoding) to create data-driven implementation plan with clear recommendations

## Problem Statement

**What problem are we solving?**

Emby transcoding currently uses CPU-only with temporary files on regular storage. We want to optimize transcoding performance but need to research what's actually feasible with our hardware and what improvements we'd actually see.

**Current state:**
- **CPU-only transcoding** - No hardware acceleration
- **Regular storage for temp files** - Not using tmpfs/RAM disk
- **Unknown performance baseline** - No metrics to measure improvement against
- **Unknown hardware capabilities** - Don't know if QuickSync/GPU available
- **Previous GPU passthrough struggles** - User has tried and failed GPU passthrough before

**Why now?**
- Emby works adequately but could be better
- Research is low-risk (just information gathering)
- Enables future optimization decisions
- Good to document what's possible before investing time
- Need to know if hardware transcoding is even feasible given previous failures

**Who benefits?**
- **Household users**: Potentially faster transcode starts, better streaming experience
- **System**: Lower CPU usage, support more concurrent streams
- **Operations**: Clear understanding of what's possible and what's not worth pursuing
- **Future decisions**: Data-driven plan instead of guessing

## Solution Design

### Recommended Approach

**Comprehensive research with baseline measurements and realistic hardware assessment:**

**Research strategy:**
1. **Establish baseline** - Measure current transcoding performance (can't improve what you don't measure)
2. **Hardware audit** - Check what Proxmox host actually has (CPU, GPU, IOMMU)
3. **tmpfs evaluation** - Test impact safely (low-hanging fruit, easy to test)
4. **Hardware transcoding evaluation** - Assess feasibility considering previous GPU passthrough failures
5. **Create implementation plan** - Document findings and prioritized recommendations

**Key principles:**
- **Data-driven**: Establish baseline before recommending anything
- **Realistic**: Acknowledge GPU passthrough complexity and previous failures
- **Safety-first**: Test non-destructively, backup everything, low-usage windows
- **Pragmatic**: Recommend what's actually achievable, not theoretically perfect

**Rationale**:
This is a research task (low risk), so we should be thorough. Getting baseline metrics is crucial - can't know if optimization helps without knowing where you started. Plus, tmpfs is easy to test non-destructively. For hardware transcoding, we need honest assessment given previous GPU passthrough struggles - not worth weeks of trial/error if success is unlikely.

> [!abstract]- 🔀 Alternative Approaches Considered
>
> **Option A: Quick Hardware Check + Decision**
> - ✅ Pros: Fast (1-2 hours), gets answer quickly
> - ✅ Pros: Low risk, just information gathering
> - ❌ Cons: No baseline metrics to measure improvement against
> - ❌ Cons: Might miss nuances (tmpfs being "good enough")
> - **Decision**: Not chosen - need baseline to make informed decision
>
> **Option B: Comprehensive Research with Baseline**
> - ✅ Pros: Establishes performance baseline (know what we're improving)
> - ✅ Pros: Full understanding of hardware capabilities
> - ✅ Pros: Can test tmpfs in isolation (low-risk first step)
> - ✅ Pros: Data-driven decision on hardware transcoding investment
> - ✅ Pros: Realistic assessment given previous GPU failures
> - ❌ Cons: Takes longer (3-4 hours)
> - ❌ Cons: Requires some testing/measurement
> - **Decision**: ✅ CHOSEN - Thoroughness justified for CRITICAL service
>
> **Option C: Phased: tmpfs now, hardware later**
> - ✅ Pros: Quick win with tmpfs (low-hanging fruit)
> - ✅ Pros: Defers complex hardware transcoding research
> - ❌ Cons: Might do hardware transcoding research twice
> - ❌ Cons: Doesn't answer the full question
> - **Decision**: Not chosen - do comprehensive research once

### Scope Definition

**✅ In Scope:**
- Full VM 100 backup before any testing
- Establish current Emby transcoding performance baseline
- Audit Proxmox host hardware capabilities (CPU, GPU, IOMMU)
- Test tmpfs impact on transcoding (non-production, safe testing)
- Research Intel QuickSync feasibility (if Intel CPU with iGPU)
- Research GPU passthrough feasibility (considering previous failures)
- Document Emby licensing requirements for hardware transcoding
- Create ADR with findings and clear recommendations
- Create prioritized implementation plan

**❌ Explicitly Out of Scope:**
- Actually implementing tmpfs in production Emby (separate task)
- Actually setting up GPU passthrough (separate task)
- Actually configuring hardware transcoding in Emby (separate task)
- Installing GPU drivers in VM 100 (separate task)
- Purchasing Emby license (implementation phase)
- Long-term performance monitoring (implementation phase)
- User acceptance testing of final implementation (implementation phase)
- Spending weeks fighting GPU passthrough if not feasible

**🎯 MVP (Minimum Viable)**:
- Baseline performance metrics captured
- Proxmox hardware capabilities documented
- Clear go/no-go on tmpfs with reasoning
- Clear go/no-go on hardware transcoding with reasoning
- One-page summary: "Here's what we should do and why"

## Risk Assessment

### Potential Pitfalls

- ⚠️ **Risk 1: Testing disrupts active household streams** → **Mitigation**: Test during low-usage window (3-6 AM), use test media files first, measure/observe only without config changes initially. Monitor for active streams before any testing.

- ⚠️ **Risk 2: tmpfs testing affects Emby stability** → **Mitigation**: Test tmpfs non-destructively first (mount tmpfs and test writes without changing Emby config). Full VM backup before any Emby config changes. Have immediate rollback plan ready.

- ⚠️ **Risk 3: Wasting time on infeasible GPU passthrough** → **Mitigation**: Check Proxmox hardware capabilities FIRST. Review previous GPU passthrough failures. Set realistic time limit - if not working after reasonable effort, document why and move on. Intel QuickSync is easier alternative if available.

- ⚠️ **Risk 4: No clear baseline to measure improvement** → **Mitigation**: Establish baseline metrics BEFORE any changes (transcode time, CPU usage, quality). Use consistent test media files for before/after comparison.

- ⚠️ **Risk 5: Research doesn't lead to actionable plan** → **Mitigation**: Define clear decision criteria upfront (e.g., "tmpfs worthwhile if >20% faster", "hardware transcoding worthwhile if <50% CPU usage"). Force go/no-go decision with reasoning for each option.

### Dependencies

**Prerequisites:**
- [x] **SSH access to Proxmox** - Ready (root@192.168.86.106) (blocking: no)
- [x] **SSH access to VM 100** - Ready (evan@192.168.86.172) (blocking: no)
- [x] **Emby running** - Ready and accessible (blocking: no)
- [x] **Test media files** - Available on NAS (blocking: no)
- [ ] **Low-usage testing window** - Need to schedule (blocking: no, can measure baseline anytime)

**No blocking dependencies** - can start immediately with baseline measurements

### Critical Service Impact

**Services Affected**: Emby (VM 100) - **CRITICAL** service

**Impact level**: LOW for research phase
- Baseline measurements: Read-only observation, no config changes
- Hardware audit: Proxmox host only, doesn't touch Emby
- tmpfs testing: Can test separately before applying to Emby
- This is research - no actual changes to production Emby

**Safety measures:**
- Full VM 100 backup before any testing
- Backup Emby configuration before any tests
- All actual testing during low-usage windows
- Monitor active streams before/during any testing
- Have rollback plan ready (though not needed for pure research)
- Test with non-critical media files first

### Rollback Plan

**Applicable for**: Media service research/testing

**How to rollback if something goes wrong:**
1. **If VM issues**: Restore VM 100 from Proxmox snapshot (created in Phase 0)
2. **If Emby config issues**: Restore Emby config from backup
3. **If tmpfs test issues**: Simply unmount tmpfs, no permanent changes
4. **If active stream disrupted**: Stop test immediately, let stream recover

**Recovery time estimate**: 5-10 minutes (VM restore), <1 minute (config restore)

**Backup requirements:**
- Full VM 100 snapshot in Proxmox (before any testing)
- Emby configuration export and `/config` directory backup
- Document snapshot ID for easy restore

## Execution Plan

### Phase 0: Preparation & Backup

**Primary Agent**: `infrastructure`

- [ ] **Backup VM 100 (Emby)** `[agent:infrastructure]` `[critical]`
  - Create full VM snapshot in Proxmox: `qm snapshot 100 emby-research-backup`
  - Verify snapshot created successfully: `qm listsnapshot 100`
  - Document snapshot name for rollback if needed
  - Estimated time: 10-15 minutes

- [ ] **Backup Emby configuration** `[agent:media]`
  - Export Emby settings via UI (Settings → Advanced → Export)
  - SSH to VM 100 and find config path from emby .env file
  - Tar config: `tar -czf ~/emby-config-backup-$(date +%Y%m%d).tar.gz <config-path>`
  - Copy backup to local machine or NAS
  - Verify backup file size is reasonable
  - Estimated time: 5 minutes

### Phase 1: Establish Performance Baseline

**Primary Agent**: `media`

- [ ] **Document current Emby configuration** `[agent:media]`
  - Navigate to Emby Settings → Transcoding
  - Document: transcoding settings, temp directory location
  - Document: hardware acceleration status (currently disabled)
  - Document: resource limits, thread count
  - Screenshot or note all relevant settings

- [ ] **Select test media files** `[agent:media]`
  - Choose 3-5 test files covering different scenarios:
    - 1080p H.264 (common format)
    - 1080p HEVC/H.265 (more demanding)
    - 4K file (if available, stress test)
    - Different bitrates (high/medium)
  - Document file paths, codecs, resolutions, bitrates

- [ ] **Measure baseline transcoding performance** `[agent:media]`
  - For each test file, manually trigger transcode
  - Measure: time to start transcoding (seconds)
  - Measure: transcode speed (e.g., "2.5x realtime")
  - Monitor: CPU usage during transcode (via `top` on VM 100)
  - Observe: stream quality, any buffering/stuttering
  - Test during low-usage window (3-6 AM preferred)

- [ ] **Document baseline metrics** `[agent:documentation]`
  - Create `docs/research/emby-transcoding-baseline.md` (research artifact, feeds into ADR 014)
  - Include: test file details, transcode times, CPU usage
  - Include: quality assessment, any issues observed
  - Create table/chart for easy before/after comparison
  - Example: "1080p H.264: 8s start, 3.2x speed, 65% CPU"

### Phase 2: Hardware Capabilities Audit

**Primary Agent**: `infrastructure`

- [ ] **Check Proxmox host CPU** `[agent:infrastructure]`
  - SSH to Proxmox: `cat /proc/cpuinfo | grep "model name" | head -1`
  - Identify: Intel vs AMD, generation, model
  - Check for Intel iGPU: `lspci | grep -i vga`
  - Research if CPU supports Intel QuickSync
  - Document: "Intel Core i7-9700K - supports QuickSync" (example)

- [ ] **Check for discrete GPU** `[agent:infrastructure]`
  - Run: `lspci | grep -i 'vga\|3d\|display'`
  - Document: Any discrete GPU model found
  - If GPU present: note make/model (NVIDIA GeForce, AMD Radeon, etc.)
  - If no discrete GPU: document "No discrete GPU found"

- [ ] **Check IOMMU support** `[agent:infrastructure]`
  - Run: `dmesg | grep -i iommu | head -20`
  - Check if IOMMU is enabled: look for "IOMMU enabled" or "DMAR" messages
  - If enabled, check IOMMU groups: `find /sys/kernel/iommu_groups/ -type l`
  - Document: IOMMU status and whether GPU is in isolated group
  - This determines GPU passthrough feasibility

- [ ] **Review previous GPU passthrough attempts** `[agent:infrastructure]`
  - Ask user: "What GPU passthrough did you try before? What failed?"
  - Document previous attempts and failure modes
  - Understand specific blockers (driver issues, IOMMU groups, BIOS settings?)
  - Assess: Is it worth trying again or is this a dead end?

- [ ] **Document hardware findings** `[agent:documentation]`
  - Create `docs/research/proxmox-hardware-capabilities.md` (research artifact, feeds into ADR 014)
  - Summary: CPU (with QuickSync support status)
  - Summary: GPU (if present, with passthrough feasibility)
  - Summary: IOMMU status and groups
  - Summary: Previous GPU passthrough history
  - Clear statement: What's feasible and what's not

### Phase 3: tmpfs Evaluation

**Primary Agent**: `docker`

- [ ] **Calculate tmpfs requirements** `[agent:docker]`
  - Research typical transcode temp file size (check Emby logs/docs)
  - Estimate: 2-4GB per concurrent transcode stream
  - Determine: household concurrent stream needs (2-3 typical?)
  - Calculate recommended tmpfs size: streams × 4GB (e.g., 8-12GB)
  - Check VM 100 RAM: currently 8GB allocated, can we spare 4-8GB for tmpfs?

- [ ] **Test tmpfs non-destructively** `[agent:docker]` `[risk:2]`
  - SSH to VM 100
  - Create test tmpfs: `sudo mount -t tmpfs -o size=4G tmpfs /tmp/transcode-test`
  - Verify mounted: `df -h | grep transcode-test`
  - Copy test video to tmpfs: `cp /path/to/test.mp4 /tmp/transcode-test/`
  - Manually transcode from tmpfs location (use Emby UI to trigger transcode or test with ffmpeg command)
  - Measure: transcode time and CPU usage (compare to baseline)
  - Cleanup: `sudo umount /tmp/transcode-test` (no permanent changes)

- [ ] **Assess tmpfs RAM impact** `[agent:docker]`
  - During tmpfs test, monitor VM memory: `free -h`
  - Ensure enough RAM available for Emby + tmpfs + system
  - Consider: May need to increase VM 100 RAM allocation (8GB → 12GB?)
  - Document: RAM requirements and whether VM RAM increase needed

- [ ] **Document tmpfs findings** `[agent:documentation]`
  - Performance improvement: "X% faster transcode start" or "No noticeable difference"
  - RAM requirements: "Recommend 8GB tmpfs, requires VM RAM increase to 12GB"
  - Implementation complexity: LOW (just docker-compose change)
  - Risk assessment: LOW (uses RAM, temp files lost on reboot = fine)
  - Recommendation: GO or NO-GO with clear reasoning
  - Example: "GO - 30% faster starts, worth 4GB RAM allocation"

### Phase 4: Hardware Transcoding Evaluation

**Primary Agent**: `infrastructure`

- [ ] **Assess Intel QuickSync feasibility** `[agent:infrastructure]`
  - IF Intel CPU with iGPU found in Phase 2:
    - Check Proxmox has `/dev/dri/renderD128`: `ls -la /dev/dri/`
    - Research: How to pass `/dev/dri` to VM 100 (much simpler than full GPU passthrough)
    - Complexity: MEDIUM (device passthrough, driver install in VM)
    - Expected success: HIGH (if device exists, usually works)
    - Document: Step-by-step plan for implementation
  - IF no Intel iGPU or incompatible CPU:
    - Document: "QuickSync not available, skip to GPU assessment"

- [ ] **Assess GPU passthrough feasibility** `[agent:infrastructure]`
  - IF discrete GPU present:
    - Review: What was tried before and why it failed
    - Check: Is GPU in isolated IOMMU group? (required for passthrough)
    - Research: Known issues with specific GPU model + Proxmox
    - Estimate: Time investment if we retry (days? weeks of troubleshooting?)
    - Honest assessment: Given previous failures, is this worth pursuing?
    - Consider: Complexity (HIGH), success probability (LOW-MEDIUM), time investment (HIGH)
  - IF no GPU OR previous attempts completely failed:
    - Document: "GPU passthrough not feasible" with clear reasoning
    - Note: Why previous attempts failed and why retry unlikely to succeed

- [ ] **Research Emby licensing** `[agent:media]`
  - Check current Emby installation: Is Emby Premiere already active?
  - Research: Does hardware transcoding require Emby Premiere? (yes, usually)
  - Document: Licensing cost if purchase needed (~$120 lifetime)
  - Cost-benefit: Is license + setup effort worth the improvement?
  - Note: Check if household already has Premiere from previous purchase

- [ ] **Document hardware transcoding findings** `[agent:documentation]`
  - Create section in ADR for hardware transcoding evaluation
  - **Intel QuickSync**: feasibility (yes/no), complexity (medium), expected improvement (high)
  - **GPU passthrough**: feasibility (yes/no), complexity (high), success probability, time investment
  - **Licensing**: requirements and costs
  - **Recommendation**: GO/NO-GO for each option with clear reasoning
  - Example: "QuickSync: GO - worth trying. GPU: NO-GO - previous failures, too much effort for uncertain payoff"

### Phase 5: Create Implementation Plan

**Primary Agent**: `documentation`

- [ ] **Create ADR 014** `[agent:documentation]`
  - File: `docs/adr/014-emby-transcoding-optimization.md`
  - **Context**: Current transcoding performance (baseline metrics)
  - **Problem**: CPU-only, no tmpfs, want to optimize
  - **Options evaluated**:
    - Option 1: tmpfs (findings, recommendation)
    - Option 2: Intel QuickSync (findings, recommendation)
    - Option 3: GPU passthrough (findings, recommendation)
  - **Decision**: What we're recommending and why
  - **Consequences**: Expected improvements, effort required, risks

- [ ] **Create prioritized implementation plan** `[agent:documentation]`
  - Rank optimizations by: ease × benefit × success probability
  - Likely recommended order:
    1. **tmpfs** (if GO): Easy, low-risk, measurable improvement
    2. **Intel QuickSync** (if GO and feasible): Medium effort, high payoff
    3. **GPU passthrough** (if GO): High effort, uncertain payoff (probably skip)
  - For each GO recommendation:
    - Implementation complexity score (1-10)
    - Expected performance improvement (quantified if possible)
    - Prerequisites needed (RAM increase? drivers? license?)
    - Estimated time to implement (hours/days)
    - Risk level (low/medium/high)
    - Dependencies (must do X before Y)

- [ ] **Create implementation task outline** `[agent:documentation]` `[optional]`
  - Based on approved recommendations, outline next task(s)
  - May need separate tasks: "Implement tmpfs" + "Setup QuickSync"
  - Or single task: "Implement recommended transcoding optimizations"
  - Include links back to this research task (IN-007) and ADR 014
  - Don't create actual task files yet - wait for user approval

### Phase 6: Validation & Review

**Primary Agent**: `testing`

- [ ] **Review research completeness** `[agent:testing]`
  - ✅ All baseline metrics captured and documented
  - ✅ All hardware capabilities checked and documented
  - ✅ tmpfs evaluated with test results
  - ✅ Hardware transcoding options evaluated realistically
  - ✅ Emby licensing researched
  - ✅ Clear recommendations with reasoning for each option
  - ✅ ADR 014 is complete and well-structured
  - ✅ Implementation plan is actionable and prioritized

- [ ] **Verify safety** `[agent:testing]`
  - VM backup exists and is verified
  - Emby config backup exists
  - No production Emby changes made (this was research only)
  - All testing was non-destructive
  - Ready to proceed to implementation with confidence

- [ ] **Present findings to user** `[agent:documentation]`
  - Executive summary: "Here's what we found"
  - Baseline: "Current performance is X"
  - Hardware: "We have Y capabilities"
  - Recommendations:
    - tmpfs: GO/NO-GO (reasoning)
    - QuickSync: GO/NO-GO (reasoning)
    - GPU: GO/NO-GO (reasoning)
  - Next steps: "If approved, create implementation task for X"
  - Get user feedback and approval on recommendations

## Acceptance Criteria

**Done when all of these are true:**
- [ ] VM 100 backup snapshot created and verified
- [ ] Emby configuration backed up
- [ ] Baseline transcoding performance documented with specific metrics
- [ ] Test media files selected and documented
- [ ] Transcode times, CPU usage, quality documented for baseline
- [ ] Proxmox host CPU identified (Intel/AMD, QuickSync support)
- [ ] GPU presence and model documented (if any)
- [ ] IOMMU support status documented
- [ ] Previous GPU passthrough attempts reviewed and documented
- [ ] Hardware capabilities report complete
- [ ] tmpfs RAM requirements calculated
- [ ] tmpfs tested non-destructively with performance metrics
- [ ] tmpfs recommendation clear (GO/NO-GO with reasoning)
- [ ] Intel QuickSync feasibility assessed
- [ ] GPU passthrough feasibility assessed (considering previous failures)
- [ ] Emby licensing requirements documented with costs
- [ ] ADR 014 created with all findings
- [ ] Implementation plan created with prioritized recommendations
- [ ] Each recommendation includes: complexity, improvement, time, risk
- [ ] All execution plan items completed
- [ ] Testing Agent validates research completeness
- [ ] User approves recommendations
- [ ] Changes committed (awaiting user approval)

## Testing Plan

**[[docs/agents/TESTING|Testing Agent]] validates:**
- All baseline metrics are quantified (not just "seems fast")
- Hardware audit is complete (CPU, GPU, IOMMU all checked)
- tmpfs test was actually conducted (not just theoretical)
- Recommendations have clear reasoning (not just "probably good")
- ADR follows standard format and is well-written
- Implementation plan is actionable (someone could execute it)
- No production Emby config was changed during research

**Manual validation:**
1. **Review baseline metrics** - Do they make sense? Are they sufficient to compare against?
2. **Review hardware findings** - Is anything missing? Do we understand capabilities?
3. **Review recommendations** - Are they realistic given previous GPU failures?
4. **Review implementation plan** - Could someone execute this without more research?

## Related Documentation

- [[docs/ARCHITECTURE|Infrastructure Architecture]] - VM 100 (Emby)
- [[docs/agents/MEDIA|Media Stack Agent]] - Critical service management
- [[docs/agents/INFRASTRUCTURE|Infrastructure Agent]] - Hardware and VM management
- [[tasks/backlog/IN-007-optimize-emby-transcoding.md.old|Original IN-007 task]] - What we started with
- Future: [[docs/adr/014-emby-transcoding-optimization|ADR 014]] - Research findings

## Notes

**Priority Rationale**:
Medium priority (3) because Emby works adequately now (not urgent) BUT this is research/planning which is low-risk and enables future optimization. Worth doing to understand what's possible before committing to implementation effort.

**Complexity Rationale**:
Moderate complexity because research approach is well-understood (baseline → audit → evaluate options) but there are some unknowns (what hardware do we have? what's feasible?). Also affects CRITICAL service so need careful approach even for research. Not simple (multiple options to evaluate, previous GPU failures add complexity) but not complex (not building anything new, just researching).

**Implementation Notes**:
- This is pure research - no production changes to Emby
- Output is ADR + implementation plan, not working transcoding optimization
- Be realistic about GPU passthrough given previous failures
- tmpfs is probably the easiest win if VM RAM can be increased
- Intel QuickSync (if available) is middle-ground: better than CPU, easier than GPU
- Focus on actionable recommendations, not theoretical perfect solutions

**GPU Passthrough History**:
User has previously tried and struggled with GPU passthrough in Proxmox. Don't waste weeks fighting this if it's not working. Be honest in assessment: if previous attempts failed and nothing has changed, recommend skipping it. Focus on what's achievable (tmpfs, maybe QuickSync).

**Expected Outcomes**:
- Likely: tmpfs is recommended (easy, measurable benefit)
- Maybe: Intel QuickSync is feasible and recommended (if Intel CPU with iGPU)
- Unlikely: GPU passthrough is recommended (given previous failures and complexity)

**Follow-up Tasks** (after user approval):
- IN-0XX: Implement tmpfs for Emby transcoding (if recommended)
- IN-0XX: Implement Intel QuickSync hardware transcoding (if feasible and recommended)
- Probably NOT: GPU passthrough (unless research shows it's actually doable now)

---

> [!note]- 📋 Work Log
>
> *Progress notes will be added during execution*

> [!tip]- 💡 Lessons Learned
>
> *Added during/after execution*
>
> **What Worked Well:**
>
> **What Could Be Better:**
>
> **Scope Evolution:**
>
> **Future Improvements:**
