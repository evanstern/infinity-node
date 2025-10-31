---
type: task
task-id: IN-032
status: backlog
priority: 2
category: media
agent: infrastructure
created: 2025-10-31
updated: 2025-10-31
started:
completed:

# Task classification
complexity: complex
estimated_duration: 3-5h
critical_services_affected: true
requires_backup: true
requires_downtime: true

# Design tracking
alternatives_considered: true
risk_assessment_done: true
phased_approach: true

tags:
  - task
  - emby
  - transcoding
  - performance
  - gpu
  - nvidia
  - proxmox
  - hardware-acceleration
---

# Task: IN-032 - Implement NVIDIA GPU Passthrough for Emby

> **Quick Summary**: Pass through NVIDIA RTX 4060 Ti to VM 100 for hardware-accelerated transcoding, achieving 10-20x faster transcoding with 90%+ less CPU usage.

## Problem Statement

**What problem are we solving?**
Emby currently uses CPU-only transcoding which is:
- Slow (1-3x playback speed for 4K content)
- Resource-intensive (60-80% CPU usage)
- Power-hungry (high CPU usage = high power consumption)
- Impacts other services on the same Proxmox host

Hardware-accelerated transcoding via NVIDIA NVENC provides:
- **10-20x faster transcoding** (real-time 4K transcoding easily)
- **90%+ reduction in CPU usage** (offloaded to GPU)
- **Much lower power consumption** (NVENC is very efficient)
- **Better multi-stream support** (handle multiple concurrent transcodes)
- **Improved user experience** (instant playback, no buffering)

**Why now?**
- Research (IN-007) confirmed hardware is ideal (RTX 4060 Ti with perfect IOMMU isolation)
- Emby Premiere already available (no licensing barrier)
- Previous GPU passthrough attempts failed due to configuration issues (not hardware)
- tmpfs baseline (IN-031) established for before/after comparison
- High-value optimization (massive performance improvement)

**Who benefits?**
- **Household users**: Instant playback, no transcode delays, better streaming quality
- **Infrastructure**: 90%+ less CPU load, lower power bills, less heat
- **Future scalability**: Can handle many more concurrent streams

## Solution Design

**Chosen Approach:**
Configure PCI passthrough for NVIDIA RTX 4060 Ti to VM 100, install drivers, configure Docker nvidia runtime, enable hardware transcoding in Emby.

**Why GPU Passthrough?**
- ✅ Hardware is perfect (RTX 4060 Ti, IOMMU Group 12, clean isolation)
- ✅ 8th gen NVENC (excellent quality and efficiency)
- ✅ 10-20x performance improvement
- ✅ Emby Premiere already available
- ✅ Well-documented process for Proxmox + NVIDIA
- ✅ Can rollback via VM snapshot if issues occur

**Implementation Path:**
1. Research best practices for Proxmox 8.x + NVIDIA RTX 4000 series
2. Configure Proxmox host for GPU passthrough (vfio-pci)
3. Pass through PCI devices to VM 100 (01:00.0 GPU + 01:00.1 audio)
4. Install NVIDIA drivers in VM 100
5. Configure Docker nvidia-container-toolkit
6. Update Emby docker-compose for GPU access
7. Configure Emby to use NVENC
8. Test and validate 10-20x improvement

## Alternatives Considered

### Alternative 1: Intel QuickSync
- **Pros**: Lower complexity than full GPU passthrough
- **Cons**: ❌ Not available (AMD CPU, QuickSync is Intel-only)
- **Decision**: Not an option with current hardware

### Alternative 2: AMD iGPU Passthrough (Raphael)
- **Pros**: Keep RTX 4060 Ti available for other uses
- **Cons**: Complex IOMMU setup, less powerful, worse Linux driver support
- **Decision**: Rejected - RTX 4060 Ti is much better and easier

### Alternative 3: CPU-only (no change)
- **Pros**: No risk, no effort
- **Cons**: Misses massive performance improvement, continued high CPU usage
- **Decision**: Rejected - hardware is perfect, benefit is huge

### Alternative 4: Remote transcoding server
- **Pros**: Dedicated hardware for transcoding
- **Cons**: Additional hardware cost, network complexity, over-engineered
- **Decision**: Rejected - local GPU is available and ideal

## Scope Definition

**In Scope:**
- ✅ Capture baseline performance (with tmpfs)
- ✅ Research Proxmox 8.x + NVIDIA RTX 4000 best practices
- ✅ Configure Proxmox for GPU passthrough
- ✅ Pass through GPU to VM 100
- ✅ Install NVIDIA drivers in VM
- ✅ Configure Docker nvidia runtime
- ✅ Update Emby for GPU transcoding
- ✅ Test and validate 10-20x improvement
- ✅ Stress test multiple concurrent transcodes
- ✅ Document configuration

**Out of Scope:**
- ❌ Dual GPU setup (only need one)
- ❌ GPU for other VMs
- ❌ AMD iGPU configuration
- ❌ Emby UI customization
- ❌ AV1 encoding tuning (can do later if needed)

**MVP Definition:**
GPU visible in VM, Emby using NVENC for transcoding, measurable 10-20x improvement over CPU baseline.

## Risk Assessment

**Potential Risks:**

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| VM won't boot after GPU passthrough | High | Low | VM snapshot for rollback |
| NVIDIA drivers don't install/work | High | Low | Well-documented process, can rollback |
| GPU passthrough breaks on Proxmox updates | Medium | Medium | Document configuration, test before updating |
| Code 43 error (common NVIDIA issue) | Medium | Low | Research workarounds, vfio config tweaks |
| Emby doesn't detect GPU | Medium | Low | nvidia-docker misconfiguration, fixable |
| GPU passthrough works but transcoding quality poor | Low | Very Low | NVENC quality is excellent |
| Can't use GPU for host console | Low | N/A | Expected (AMD iGPU available for console) |

**Dependencies:**
- Proxmox supports PCI passthrough (yes)
- NVIDIA drivers available for Ubuntu (yes)
- Docker nvidia-container-toolkit available (yes)
- Emby Premiere license (confirmed available)
- tmpfs baseline measurements from IN-031

**Critical Service Impact:**
- ⚠️ **Emby is CRITICAL** (household media streaming, 99.9% uptime target)
- VM shutdown required (downtime during implementation)
- Test during low-usage window (3-6 AM preferred)
- Have rollback plan ready
- Monitor closely after changes

**Rollback Plan:**
1. Shut down VM 100
2. Rollback to VM snapshot: `qm rollback 100 emby-gpu-backup`
3. Start VM 100 (back to CPU transcoding + tmpfs)
4. Total rollback time: ~5 minutes
5. Alternative: Remove GPU from VM config, restart (keeps driver changes)

## Execution Plan

### Phase 0: Research and Preparation

**Primary Agent**: `infrastructure`

- [ ] **Research GPU passthrough for Proxmox 8.x + NVIDIA RTX 4000** `[agent:infrastructure]`
  - Search for: "Proxmox 8 NVIDIA RTX 4060 Ti passthrough"
  - Find: Latest best practices, common issues, workarounds
  - Document: Key configuration steps, known gotchas
  - Look for: Code 43 fixes, vfio configuration examples
  - Time: 30-45 minutes of research

- [ ] **Capture baseline performance (with tmpfs)** `[agent:media]`
  - Use same test files from IN-031
  - Measure: Transcode start time, processing speed, CPU usage
  - This is our comparison point for GPU improvement
  - Document all measurements

- [ ] **Create fresh VM snapshot** `[agent:infrastructure]` `[critical]`
  - SSH to Proxmox: `ssh root@192.168.86.106`
  - Create snapshot: `qm snapshot 100 emby-gpu-backup`
  - Verify: `qm listsnapshot 100`
  - Document snapshot name and timestamp
  - This is our rollback point

### Phase 1: Configure Proxmox Host for GPU Passthrough

**Primary Agent**: `infrastructure`

- [ ] **Enable IOMMU in kernel (if not already)** `[agent:infrastructure]`
  - Check if enabled: `dmesg | grep -i iommu`
  - If needed, edit `/etc/default/grub`:
    - AMD: Add `amd_iommu=on iommu=pt` to `GRUB_CMDLINE_LINUX_DEFAULT`
  - Update grub: `update-grub`
  - Reboot Proxmox host if changes made
  - Verify IOMMU active after reboot

- [ ] **Load vfio-pci modules** `[agent:infrastructure]`
  - Edit `/etc/modules`:
    ```
    vfio
    vfio_iommu_type1
    vfio_pci
    vfio_virqfd
    ```
  - Update initramfs: `update-initramfs -u`
  - Reboot if changes made

- [ ] **Blacklist NVIDIA drivers on host** `[agent:infrastructure]`
  - Create `/etc/modprobe.d/blacklist-nvidia.conf`:
    ```
    blacklist nouveau
    blacklist nvidia
    blacklist nvidiafb
    blacklist nvidia_drm
    ```
  - Update initramfs: `update-initramfs -u`
  - Reboot if changes made

- [ ] **Bind GPU to vfio-pci** `[agent:infrastructure]`
  - Get GPU IDs: `lspci -nn | grep NVIDIA`
  - Note vendor:device IDs (e.g., 10de:2803 for GPU, 10de:22bd for audio)
  - Edit `/etc/modprobe.d/vfio.conf`:
    ```
    options vfio-pci ids=10de:2803,10de:22bd
    ```
  - Update initramfs: `update-initramfs -u`
  - Reboot Proxmox host
  - Verify GPU bound to vfio-pci: `lspci -k | grep -A 3 NVIDIA`

### Phase 2: Pass Through GPU to VM 100

**Primary Agent**: `infrastructure`

- [ ] **Add PCI devices to VM 100** `[agent:infrastructure]`
  - Stop VM 100: `qm stop 100`
  - Add GPU: `qm set 100 -hostpci0 01:00,pcie=1,rombar=0`
  - This passes both 01:00.0 (GPU) and 01:00.1 (audio)
  - Verify VM config: `qm config 100 | grep hostpci`
  - Document exact configuration

- [ ] **Configure VM for GPU passthrough** `[agent:infrastructure]`
  - Set machine type: `qm set 100 -machine q35`
  - Set BIOS to OVMF (if not already): `qm set 100 -bios ovmf`
  - Add EFI disk if needed
  - These settings help avoid Code 43 errors

- [ ] **Start VM 100 and verify GPU visible** `[agent:infrastructure]`
  - Start VM: `qm start 100`
  - SSH to VM: `ssh evan@192.168.86.172`
  - Check GPU visible: `lspci | grep NVIDIA`
  - Should show: VGA controller and Audio device
  - If VM won't boot, check Proxmox logs, may need adjustments

### Phase 3: Install NVIDIA Drivers in VM

**Primary Agent**: `infrastructure`

- [ ] **Install NVIDIA drivers** `[agent:infrastructure]`
  - SSH to VM 100: `ssh evan@192.168.86.172`
  - Add NVIDIA repository:
    ```bash
    sudo apt update
    sudo apt install -y ubuntu-drivers-common
    sudo ubuntu-drivers devices
    ```
  - Install recommended driver:
    ```bash
    sudo ubuntu-drivers autoinstall
    # OR manually: sudo apt install nvidia-driver-535
    ```
  - Reboot VM: `sudo reboot`

- [ ] **Verify NVIDIA driver loaded** `[agent:infrastructure]`
  - SSH back to VM 100
  - Check driver: `nvidia-smi`
  - Should show: GPU name, driver version, CUDA version
  - If not working, check: `dmesg | grep nvidia` for errors

### Phase 4: Configure Docker nvidia Runtime

**Primary Agent**: `docker`

- [ ] **Install nvidia-container-toolkit** `[agent:docker]`
  - SSH to VM 100
  - Add NVIDIA Docker repository:
    ```bash
    distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
    curl -s -L https://nvidia.github.io/libnvidia-container/gpgkey | sudo apt-key add -
    curl -s -L https://nvidia.github.io/libnvidia-container/$distribution/libnvidia-container.list | \
      sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
    ```
  - Install toolkit:
    ```bash
    sudo apt update
    sudo apt install -y nvidia-container-toolkit
    ```
  - Configure Docker: `sudo nvidia-ctk runtime configure --runtime=docker`
  - Restart Docker: `sudo systemctl restart docker`

- [ ] **Verify Docker can access GPU** `[agent:docker]`
  - Test GPU access:
    ```bash
    docker run --rm --gpus all nvidia/cuda:11.8.0-base-ubuntu22.04 nvidia-smi
    ```
  - Should show same GPU info as host `nvidia-smi`
  - If fails, check Docker daemon logs

### Phase 5: Update Emby for GPU Transcoding

**Primary Agent**: `docker`

- [ ] **Update Emby docker-compose** `[agent:docker]`
  - Edit `stacks/emby/docker-compose.yml`
  - Uncomment/add GPU configuration:
    ```yaml
    deploy:
      resources:
        reservations:
          devices:
            - driver: nvidia
              count: all
              capabilities:
                - gpu
    ```
  - Alternatively use older runtime syntax:
    ```yaml
    runtime: nvidia
    environment:
      - NVIDIA_VISIBLE_DEVICES=all
      - NVIDIA_DRIVER_CAPABILITIES=all
    ```
  - Validate syntax: `docker-compose config`

- [ ] **Deploy updated Emby stack** `[agent:docker]`
  - Pull latest image: `cd stacks/emby && docker-compose pull`
  - Recreate with GPU: `docker-compose up -d`
  - Check logs: `docker logs emby --tail 50`
  - Verify no GPU-related errors

- [ ] **Verify GPU visible in Emby container** `[agent:docker]`
  - Check GPU inside container:
    ```bash
    docker exec emby nvidia-smi
    ```
  - Should show GPU accessible from within container
  - If not working, check docker-compose GPU configuration

### Phase 6: Configure Emby to Use NVENC

**Primary Agent**: `media`

- [ ] **Enable hardware acceleration in Emby** `[agent:media]`
  - Access Emby web UI
  - Navigate to: Settings → Transcoding
  - Enable: "Enable hardware acceleration when available"
  - Select: NVIDIA NVENC
  - Set quality presets as desired
  - Save configuration

- [ ] **Test GPU transcoding** `[agent:media]`
  - Play test media that requires transcoding
  - Check Emby transcode dashboard
  - Should show: "HW" badge for hardware transcoding
  - Monitor GPU usage: `nvidia-smi` on VM 100
  - Should show Emby process using GPU

### Phase 7: Validation and Performance Testing

**Primary Agent**: `media`

- [ ] **Measure GPU transcode performance** `[agent:media]`
  - Use same 3 test files from baseline
  - Trigger transcode for each
  - Measure: Transcode start time, processing speed
  - Measure: CPU usage (should be <10%)
  - Measure: GPU usage (via `nvidia-smi`)
  - Document all measurements

- [ ] **Compare to baseline** `[agent:media]`
  - Calculate improvement vs CPU-only baseline
  - Calculate improvement vs tmpfs baseline
  - Expected: 10-20x faster processing
  - Expected: 90%+ less CPU usage
  - Validate: Quality is acceptable

- [ ] **Stress test multiple streams** `[agent:testing]`
  - Start 3-4 concurrent transcodes
  - Monitor GPU usage: `nvidia-smi dmon`
  - Monitor VM resources: `top`, `free -h`
  - Verify all transcodes complete successfully
  - Ensure no stuttering or quality issues

- [ ] **Validate different codecs** `[agent:testing]`
  - Test H.264 transcoding (most common)
  - Test HEVC/H.265 transcoding
  - Test 4K content
  - Test HDR to SDR tone mapping (if applicable)
  - Verify quality matches expectations

### Phase 8: Documentation and Cleanup

**Primary Agent**: `documentation`

- [ ] **Document GPU configuration** `[agent:documentation]`
  - Update `stacks/emby/README.md`:
    - GPU passthrough configuration
    - NVIDIA driver version
    - Docker nvidia runtime setup
    - Emby GPU settings
  - Document rollback procedure
  - Link to IN-032, ADR 013, IN-007

- [ ] **Create runbook for GPU passthrough** `[agent:documentation]` `[optional]`
  - Consider creating: `docs/runbooks/gpu-passthrough-nvidia.md`
  - Detailed steps for future reference
  - Troubleshooting common issues
  - Update procedures for driver/Proxmox upgrades

- [ ] **Document performance improvement** `[agent:documentation]`
  - Create comparison table:
    - CPU-only vs tmpfs vs GPU
  - Calculate ROI (time saved, power saved)
  - Add to task work log
  - Update ADR 013 status to "accepted"

## Acceptance Criteria

**Done when all of these are true:**
- [ ] Baseline performance (with tmpfs) captured
- [ ] Fresh VM snapshot created and verified
- [ ] GPU passthrough research completed (best practices documented)
- [ ] Proxmox configured for GPU passthrough (IOMMU, vfio-pci)
- [ ] GPU passed through to VM 100 (visible in VM)
- [ ] NVIDIA drivers installed in VM (`nvidia-smi` works)
- [ ] Docker nvidia runtime configured and working
- [ ] Emby docker-compose updated for GPU access
- [ ] Emby configured to use NVENC
- [ ] GPU transcoding working (HW badge in Emby)
- [ ] Performance measured: 10-20x improvement achieved
- [ ] CPU usage reduced by 90%+
- [ ] Multiple concurrent transcodes tested successfully
- [ ] Documentation updated (stack README, runbook)
- [ ] Changes committed to git
- [ ] ADR 013 status updated to "accepted"

## Testing Plan

**[[docs/agents/TESTING|Testing Agent]] validates:**
- GPU visible in VM: `lspci | grep NVIDIA`
- NVIDIA driver loaded: `nvidia-smi`
- Docker can access GPU: `docker run --rm --gpus all nvidia/cuda nvidia-smi`
- Emby container has GPU access: `docker exec emby nvidia-smi`
- Transcoding uses GPU (not CPU)
- Performance improvement is measurable and significant
- Multiple concurrent transcodes work without issues

**Manual validation:**
1. **GPU visible**: `ssh evan@192.168.86.172 "nvidia-smi"`
2. **Emby shows HW transcoding**: Check transcode dashboard
3. **CPU usage low**: `top` during transcode shows <10% CPU
4. **GPU usage high**: `nvidia-smi dmon` shows Emby using GPU
5. **Quality acceptable**: Watch transcoded content, no artifacts
6. **Multiple streams**: Start 3+ transcodes, all work smoothly

## Related Documentation

- [[tasks/completed/IN-007-research-emby-transcoding-optimization|IN-007]] - Research that led to this task
- [[tasks/backlog/IN-031-implement-emby-tmpfs-transcode-cache|IN-031]] - Prerequisite (tmpfs baseline)
- [[docs/adr/013-emby-transcoding-optimization|ADR 013]] - Decision context
- [[docs/research/proxmox-hardware-capabilities|Hardware Capabilities]] - GPU assessment
- [[docs/ARCHITECTURE|Architecture]] - VM 100 (Emby) infrastructure
- [[stacks/emby/README|Emby Stack Documentation]] - Service configuration

**External References:**
- [Proxmox PCI Passthrough](https://pve.proxmox.com/wiki/PCI_Passthrough)
- [NVIDIA Container Toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/)
- [Emby Hardware Acceleration](https://support.emby.media/support/solutions/articles/44001159092)

## Notes

**Priority Rationale:**
Priority 2 (high) because:
- Massive performance improvement (10-20x)
- Significant CPU and power savings
- Critical service optimization
- Research shows high success probability
- Depends on IN-031 completion

**Complexity Rationale:**
Complex because:
- Multi-system configuration (Proxmox, VM, Docker, Emby)
- GPU passthrough has many steps and potential issues
- Requires careful testing and validation
- Critical service with household impact
- Rollback plan essential

**Implementation Notes:**
- Schedule for low-usage window (3-6 AM)
- Previous GPU passthrough attempts failed (configuration issues)
- Hardware is perfect - IOMMU Group 12 isolation is ideal
- RTX 4060 Ti has excellent NVENC (8th gen)
- Emby Premiere confirmed available (no license purchase needed)
- VM snapshot provides safety net for rollback

**Known Challenges:**
- Code 43 error: Common with NVIDIA passthrough, usually fixable with machine type + BIOS settings
- Driver conflicts: Need to blacklist NVIDIA drivers on host
- Docker nvidia runtime: Sometimes tricky to configure correctly
- Emby configuration: Must explicitly enable hardware acceleration

**Follow-up Tasks:**
- [ ] Monitor GPU passthrough stability over time
- [ ] Consider AV1 encoding once client support improves
- [ ] Document GPU driver update procedure
- [ ] Create monitoring for GPU temperature/usage

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

