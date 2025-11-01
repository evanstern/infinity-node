---
type: research
title: "Proxmox 8.x NVIDIA RTX 4060 Ti GPU Passthrough Configuration"
date: 2025-11-01
status: complete
related-tasks:
  - IN-032
feeds-into:
  - ADR-013
research-type: hardware-assessment
tags:
  - research
  - proxmox
  - nvidia
  - gpu
  - passthrough
  - vfio
  - emby
  - transcoding
  - configuration
authors:
  - Evan
  - Claude (AI Agent)
---

# Proxmox 8.x NVIDIA RTX 4060 Ti GPU Passthrough Configuration

**Research Date**: 2025-11-01
**Purpose**: Document GPU passthrough configuration best practices for implementing IN-032
**Proxmox Version**: 8.4.1 (kernel 6.8.12-10-pve)
**Target GPU**: NVIDIA GeForce RTX 4060 Ti (Ada Lovelace, 8th gen NVENC)

---

## Executive Summary

**Goal**: Pass through NVIDIA RTX 4060 Ti to VM 100 (Emby) for hardware-accelerated transcoding

**Current Status**:
- ✅ IOMMU already enabled (AMD-Vi active)
- ✅ GPU in perfect isolation (IOMMU Group 12: GPU + audio only)
- ✅ Hardware is ideal for passthrough
- ⏳ Host configuration needed (vfio-pci binding, driver blacklisting)
- ⏳ VM configuration needed (PCI passthrough, Q35 machine type, OVMF BIOS)
- ⏳ Guest OS setup needed (NVIDIA drivers, Docker nvidia runtime)

**Expected Outcome**: 10-20x transcoding performance improvement, 90%+ CPU reduction

---

## Hardware Verification

### Current GPU Configuration

**NVIDIA GeForce RTX 4060 Ti**:
- **PCI Address**: `01:00.0` (VGA controller)
- **Audio Device**: `01:00.1` (HDMI/DP audio)
- **Vendor:Device IDs**:
  - GPU: `10de:2803` (NVIDIA AD106)
  - Audio: `10de:22bd` (AD106M Audio)
- **Architecture**: Ada Lovelace (2023)
- **NVENC**: 8th generation encoder

**IOMMU Configuration**:
```
IOMMU Group 12:
  01:00.0 VGA compatible controller [0300]: NVIDIA Corporation AD106 [GeForce RTX 4060 Ti] [10de:2803] (rev a1)
  01:00.1 Audio device [0403]: NVIDIA Corporation AD106M High Definition Audio Controller [10de:22bd] (rev a1)
```

**Assessment**: ✅ **Perfect for passthrough**
- Only 2 devices in IOMMU group (GPU + its audio)
- No other PCIe devices sharing the group
- Clean isolation prevents passthrough complications

### IOMMU Status

**Verified via**: `dmesg | grep -i iommu`

```
iommu: Default domain type: Translated
iommu: DMA domain TLB invalidation policy: lazy mode
pci 0000:00:00.2: AMD-Vi: IOMMU performance counters supported
```

**Status**: ✅ IOMMU already enabled in kernel
- AMD-Vi (AMD's IOMMU implementation) is active
- No additional kernel parameters needed
- IOMMU groups are properly assigned

---

## Proxmox Host Configuration Requirements

### Phase 1: Load VFIO Modules

**Required Modules** (add to `/etc/modules`):
```
vfio
vfio_iommu_type1
vfio_pci
vfio_virqfd
```

**Purpose**: Load VFIO (Virtual Function I/O) drivers for device passthrough

**Apply**:
```bash
update-initramfs -u
reboot
```

### Phase 2: Blacklist NVIDIA Drivers on Host

**Create**: `/etc/modprobe.d/blacklist-nvidia.conf`
```
blacklist nouveau
blacklist nvidia
blacklist nvidiafb
blacklist nvidia_drm
```

**Purpose**: Prevent Proxmox host from loading NVIDIA drivers (reserves GPU for guest)

**Apply**:
```bash
update-initramfs -u
reboot
```

### Phase 3: Bind GPU to vfio-pci Driver

**Create**: `/etc/modprobe.d/vfio.conf`
```
options vfio-pci ids=10de:2803,10de:22bd
```

**Purpose**: Bind both GPU and audio device to vfio-pci at boot

**Apply**:
```bash
update-initramfs -u
reboot
```

**Verification**:
```bash
lspci -k | grep -A 3 NVIDIA
```

Should show:
```
01:00.0 VGA compatible controller: NVIDIA ...
        Kernel driver in use: vfio-pci
01:00.1 Audio device: NVIDIA ...
        Kernel driver in use: vfio-pci
```

---

## VM Configuration Requirements

### Machine Type: Q35

**Current VM 100 machine type**: Need to verify

**Required**: `q35` (modern PCIe-based chipset)

**Why**:
- i440fx (older chipset) can cause Code 43 errors with NVIDIA GPUs
- Q35 provides proper PCIe topology
- Required for OVMF BIOS support

**Configure**:
```bash
qm set 100 -machine q35
```

### BIOS: OVMF (UEFI)

**Required**: OVMF UEFI BIOS (not SeaBIOS)

**Why**:
- Modern UEFI BIOS required for GPU passthrough
- Helps avoid NVIDIA Code 43 errors
- Provides better hardware initialization

**Configure**:
```bash
qm set 100 -bios ovmf
```

**Note**: May require adding EFI disk if not already present:
```bash
qm set 100 -efidisk0 local-lvm:1,format=raw,efitype=4m,pre-enrolled-keys=1
```

### PCI Passthrough Configuration

**Add GPU to VM**:
```bash
qm set 100 -hostpci0 01:00,pcie=1,rombar=0
```

**Parameter Explanation**:
- `01:00` - PCI address (passes both .0 GPU and .1 audio)
- `pcie=1` - Present as PCIe device (not legacy PCI)
- `rombar=0` - Disable ROM BAR (helps avoid Code 43)

**Verification**:
```bash
qm config 100 | grep hostpci
```

Should show:
```
hostpci0: 0000:01:00,pcie=1,rombar=0
```

---

## Guest OS Configuration (VM 100)

### Install NVIDIA Drivers

**Method 1: Ubuntu Drivers (Recommended)**
```bash
sudo apt update
sudo apt install -y ubuntu-drivers-common
sudo ubuntu-drivers devices
sudo ubuntu-drivers autoinstall
sudo reboot
```

**Method 2: Specific Driver Version**
```bash
sudo apt install nvidia-driver-535
sudo reboot
```

**Verification**:
```bash
nvidia-smi
```

Should display GPU info, driver version, CUDA version.

### Install Docker nvidia-container-toolkit

**Add NVIDIA Docker Repository**:
```bash
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
curl -s -L https://nvidia.github.io/libnvidia-container/gpgkey | sudo apt-key add -
curl -s -L https://nvidia.github.io/libnvidia-container/$distribution/libnvidia-container.list | \
  sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
```

**Install Toolkit**:
```bash
sudo apt update
sudo apt install -y nvidia-container-toolkit
sudo nvidia-ctk runtime configure --runtime=docker
sudo systemctl restart docker
```

**Verification**:
```bash
docker run --rm --gpus all nvidia/cuda:11.8.0-base-ubuntu22.04 nvidia-smi
```

Should show same GPU info as host `nvidia-smi`.

---

## Emby Container Configuration

### Docker Compose GPU Configuration

**Add to `stacks/emby/docker-compose.yml`**:

**Method 1: Compose v2 Deploy Syntax (Preferred)**
```yaml
services:
  emby:
    image: emby/embyserver:latest
    # ... existing config ...
    deploy:
      resources:
        reservations:
          devices:
            - driver: nvidia
              count: all
              capabilities:
                - gpu
```

**Method 2: Legacy Runtime Syntax**
```yaml
services:
  emby:
    image: emby/embyserver:latest
    # ... existing config ...
    runtime: nvidia
    environment:
      - NVIDIA_VISIBLE_DEVICES=all
      - NVIDIA_DRIVER_CAPABILITIES=all
```

**Validation**:
```bash
cd stacks/emby
docker compose config
```

Should parse without errors.

**Deployment**:
- Commit changes to git
- Deploy via Portainer: Stacks → emby → "Pull and redeploy"
- OR use script: `./scripts/infrastructure/redeploy-git-stack.sh --secret portainer-api-token-vm-100 --stack-name emby`

**Container Verification**:
```bash
docker exec emby nvidia-smi
```

Should show GPU accessible from within container.

---

## Emby Application Configuration

### Enable Hardware Acceleration

**Steps**:
1. Access Emby web UI: http://192.168.86.172:8096
2. Navigate to: **Settings → Transcoding**
3. Enable: **"Enable hardware acceleration when available"**
4. Select: **"NVIDIA NVENC"** from dropdown
5. Optional: Configure quality presets (typically default is fine)
6. **Save**

### Verify GPU Transcoding

**Test Method**:
1. Play media requiring transcoding (different codec, resolution, or bitrate)
2. Open Emby transcode dashboard
3. Look for **"HW"** badge indicating hardware transcoding
4. Monitor GPU usage: `nvidia-smi dmon` on VM 100
5. Verify Emby process using GPU encoder

**Expected GPU Usage**:
- Encoder: 10-30% (NVENC)
- Decoder: 10-30% (NVDEC)
- Memory: 500MB - 1GB per stream
- Power: 20-40W typical

---

## Common Issues and Solutions

### Issue: Code 43 Error (GPU Not Working in VM)

**Symptoms**:
- GPU visible in VM (`lspci` shows it)
- NVIDIA drivers install but fail to initialize
- `nvidia-smi` shows "NVIDIA-SMI has failed because it couldn't communicate with the NVIDIA driver"
- Device Manager (Windows) shows Code 43

**Solutions**:
1. ✅ Use Q35 machine type (not i440fx)
2. ✅ Use OVMF BIOS (not SeaBIOS)
3. ✅ Add `rombar=0` to PCI passthrough config
4. Try adding to VM config file (`/etc/pve/qemu-server/100.conf`):
   ```
   args: -cpu host,kvm=off,hv_vendor_id=proxmox
   ```
5. Verify GPU ROM is accessible (sometimes needs extraction)

### Issue: VM Won't Boot After GPU Passthrough

**Symptoms**:
- VM fails to start after adding GPU
- Black screen or no display
- VM process terminates immediately

**Solutions**:
1. Check Proxmox logs: `/var/log/pve/tasks/`
2. Try without `rombar=0` first (some GPUs need ROM)
3. Verify OVMF BIOS and EFI disk are configured
4. Check IOMMU is enabled: `dmesg | grep -i iommu`
5. Rollback to VM snapshot if needed

### Issue: GPU Visible but Docker Can't Access

**Symptoms**:
- `nvidia-smi` works on VM
- `docker run --gpus all` fails

**Solutions**:
1. Reinstall nvidia-container-toolkit
2. Check Docker daemon config: `/etc/docker/daemon.json`
3. Verify Docker service restarted after toolkit install
4. Check NVIDIA runtime: `docker info | grep -i runtime`
5. Test with simple CUDA container first

### Issue: Emby Not Using GPU

**Symptoms**:
- GPU visible in container (`docker exec emby nvidia-smi`)
- Emby transcoding still using CPU (no HW badge)

**Solutions**:
1. Verify hardware acceleration enabled in Emby settings
2. Select correct encoder (NVIDIA NVENC)
3. Check transcode format requires encoding (not direct play)
4. Some codecs may fallback to software
5. Check Emby logs for GPU initialization errors

---

## Performance Expectations

### CPU-Only Baseline (Current)

From IN-031 (tmpfs implementation):
- **1080p H.264 → H.264**: 2-3x realtime, 60-80% CPU
- **4K HEVC → H.264**: 0.8-1.5x realtime, 80-90% CPU
- **Transcode Start**: 3-5 seconds (with tmpfs)

### GPU Expected Performance

With NVIDIA RTX 4060 Ti NVENC:
- **1080p H.264 → H.264**: 20-30x realtime, <10% CPU
- **4K HEVC → H.264**: 8-15x realtime, <10% CPU
- **Transcode Start**: 1-2 seconds
- **Concurrent Streams**: 5-8 streams without degradation
- **Power Consumption**: 20-40W (vs 100-150W CPU)

**Expected Improvement**: 10-20x faster, 90%+ less CPU usage

---

## Rollback Plan

### If GPU Passthrough Fails

**Method 1: VM Snapshot Rollback (Fastest)**
```bash
# Stop VM
qm stop 100

# Rollback to pre-GPU snapshot
qm rollback 100 emby-gpu-backup

# Start VM
qm start 100
```

**Recovery Time**: ~5 minutes
**Result**: Back to CPU transcoding + tmpfs

**Method 2: Remove GPU from VM Config**
```bash
# Stop VM
qm stop 100

# Remove GPU passthrough
qm set 100 --delete hostpci0

# Start VM
qm start 100
```

**Recovery Time**: ~3 minutes
**Result**: VM boots without GPU (keeps driver/Docker changes)

---

## Testing Checklist

### Phase 1: Host Configuration
- [ ] vfio modules loaded: `lsmod | grep vfio`
- [ ] NVIDIA drivers blacklisted on host
- [ ] GPU bound to vfio-pci: `lspci -k | grep -A 3 NVIDIA`
- [ ] Verify driver is vfio-pci (not nvidia or nouveau)

### Phase 2: VM Boot
- [ ] VM 100 stops cleanly
- [ ] VM 100 starts with GPU attached
- [ ] No errors in Proxmox task log
- [ ] VM accessible via SSH

### Phase 3: Guest OS
- [ ] GPU visible in VM: `lspci | grep NVIDIA`
- [ ] NVIDIA drivers installed
- [ ] `nvidia-smi` command works
- [ ] Shows correct GPU model and driver version

### Phase 4: Docker
- [ ] nvidia-container-toolkit installed
- [ ] `docker run --gpus all nvidia/cuda nvidia-smi` works
- [ ] Emby container has GPU access: `docker exec emby nvidia-smi`

### Phase 5: Emby Transcoding
- [ ] Hardware acceleration enabled in Emby settings
- [ ] Test transcode shows "HW" badge
- [ ] GPU usage visible during transcode
- [ ] Transcode quality is acceptable
- [ ] Multiple concurrent transcodes work

---

## Best Practices

### Before Implementation

1. **Create VM snapshot**: `qm snapshot 100 emby-gpu-backup`
2. **Document current performance**: Baseline measurements
3. **Choose low-usage window**: 3-6 AM preferred
4. **Have rollback plan ready**: Test rollback procedure
5. **Inform household**: Brief downtime expected

### During Implementation

1. **One step at a time**: Verify each phase before proceeding
2. **Check logs frequently**: `/var/log/pve/`, `dmesg`, `docker logs`
3. **Don't skip reboots**: Many changes require reboot
4. **Test at each phase**: Verify GPU visible, drivers load, etc.

### After Implementation

1. **Measure improvement**: Compare to baseline
2. **Stress test**: Multiple concurrent transcodes
3. **Monitor stability**: First 24-48 hours
4. **Update documentation**: Actual performance, any issues
5. **Update ADR 013**: Mark as "accepted" with results

---

## References

### Official Documentation

- [Proxmox PCI Passthrough](https://pve.proxmox.com/wiki/PCI_Passthrough)
- [NVIDIA Container Toolkit Docs](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/)
- [Emby Hardware Acceleration Guide](https://support.emby.media/support/solutions/articles/44001159092)

### Related Tasks

- [[tasks/completed/IN-007-research-emby-transcoding-optimization|IN-007]] - Initial transcoding research
- [[tasks/completed/IN-031-implement-emby-tmpfs-transcode-cache|IN-031]] - Tmpfs baseline
- [[tasks/current/IN-032-implement-emby-gpu-passthrough|IN-032]] - GPU passthrough implementation

### Related Documentation

- [[docs/research/proxmox-hardware-capabilities|Hardware Capabilities]] - GPU assessment
- [[docs/adr/013-emby-transcoding-optimization|ADR 013]] - Transcoding optimization decision
- [[stacks/emby/README|Emby Stack Documentation]] - Service configuration

---

## Key Takeaways

**Hardware Status**: ✅ Ideal
- RTX 4060 Ti with 8th gen NVENC
- Perfect IOMMU isolation (Group 12)
- IOMMU already enabled

**Configuration Complexity**: Medium
- Well-documented process
- Multiple configuration steps
- Requires host reboot
- VM reconfiguration needed

**Risk Level**: Medium
- Critical service (Emby)
- VM snapshot provides safety net
- Rollback time: ~5 minutes
- Previous attempts failed (configuration issues, not hardware)

**Expected Benefit**: Very High
- 10-20x performance improvement
- 90%+ CPU reduction
- Much lower power consumption
- Support for many more concurrent streams

**Recommendation**: ✅ **Proceed with Implementation**
- Hardware is perfect
- Benefits are massive
- Risk is manageable (snapshot rollback available)
- Configuration steps are well-documented
