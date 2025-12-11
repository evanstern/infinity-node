---
type: research
title: "Proxmox Hardware Capabilities - Emby Transcoding"
date: 2025-10-31
status: complete
related-tasks:
  - IN-007
feeds-into:
  - ADR-013
research-type: hardware-assessment
tags:
  - research
  - proxmox
  - emby
  - hardware
  - gpu
  - transcoding
  - nvidia
  - iommu
authors:
  - Evan
  - Claude (AI Agent)
---

# Proxmox Hardware Capabilities - Emby Transcoding Research

**Research Date**: 2025-10-31
**Purpose**: Assess hardware capabilities for Emby transcoding optimization (Task IN-007)
**Proxmox Host**: 192.168.1.81

---

## CPU

**Model**: AMD Ryzen 7 7700
**Architecture**: x86_64 (Zen 4 microarchitecture)
**Cores**: 8 physical cores
**Threads**: 16 (SMT enabled)
**Base Clock**: 3.8 GHz
**Generation**: Ryzen 7000 series (2022)

**Intel QuickSync Support**: ❌ **NOT AVAILABLE**
- QuickSync is Intel-only technology
- Not applicable to AMD CPUs

**Transcoding Capability**:
- Excellent CPU performance for software transcoding
- 8 cores / 16 threads can handle multiple concurrent transcodes
- However, CPU transcoding is resource-intensive compared to hardware acceleration

---

## Graphics Processing Units (GPUs)

### GPU 1: NVIDIA GeForce RTX 4060 Ti (Discrete)

**PCI Address**: `01:00.0`
**Device ID**: `10de:2803` (rev a1)
**Audio Device**: `01:00.1` - NVIDIA AD106M High Definition Audio Controller

**Specifications**:
- **Architecture**: Ada Lovelace (2023)
- **NVENC Generation**: 8th generation encoder
- **Transcoding Capability**: **Excellent**
  - Supports H.264, HEVC (H.265), AV1 encoding
  - Up to 8K resolution support
  - Very efficient power consumption
  - Much faster than CPU transcoding

**IOMMU Status**:
- **IOMMU Group**: 12
- **Isolation**: ✅ **Perfect** (only GPU + audio in group)
- **Other devices in group**: Just the GPU's integrated audio controller
- **Passthrough Feasibility**: ✅ **Technically Feasible**

**Assessment**:
- This is an **ideal GPU for hardware transcoding**
- Modern NVENC encoder (8th gen) is high quality
- Clean IOMMU isolation means passthrough should work
- Would provide **massive performance improvement** over CPU transcoding

### GPU 2: AMD Raphael iGPU (Integrated)

**PCI Address**: `13:00.0`
**Device**: AMD/ATI Raphael integrated graphics
**Source**: Integrated into Ryzen 7 7700 CPU

**IOMMU Status**:
- **IOMMU Group**: 29
- Multiple related devices in groups 29-34 (typical for integrated graphics)
- More complex isolation than discrete GPU

**Transcoding Capability**:
- AMD VCE (Video Coding Engine) hardware encoder
- Supports H.264 and HEVC encoding
- Less powerful than RTX 4060 Ti but still hardware-accelerated
- More complex to pass through due to integration with CPU

**Assessment**:
- **Could work** for hardware transcoding but more complex
- **RTX 4060 Ti is the better choice** (more powerful, cleaner isolation)

---

## IOMMU Support

**Status**: ✅ **Enabled and Working**
**Technology**: AMD-Vi (AMD's implementation of IOMMU)
**Kernel Support**: Active (confirmed via `dmesg`)

**NVIDIA GPU Isolation Details**:
```
IOMMU Group 12:
  01:00.0 VGA compatible controller: NVIDIA GeForce RTX 4060 Ti
  01:00.1 Audio device: NVIDIA AD106M High Definition Audio Controller
```

**Assessment**:
- IOMMU is properly enabled in BIOS and kernel
- NVIDIA GPU is in a clean, isolated IOMMU group
- This is the **ideal scenario** for GPU passthrough
- No additional devices in the group that would complicate passthrough

---

## GPU Passthrough Feasibility Assessment

### Technical Requirements: ✅ All Met

| Requirement | Status | Notes |
|-------------|--------|-------|
| IOMMU Enabled | ✅ Yes | AMD-Vi active |
| GPU in Isolated Group | ✅ Yes | Group 12: GPU + audio only |
| Modern GPU with NVENC | ✅ Yes | RTX 4060 Ti with 8th gen NVENC |
| Proxmox Support | ✅ Yes | Proxmox has excellent GPU passthrough support |

### Historical Context

**Previous Attempts**: User attempted GPU passthrough in the past but encountered issues
- **Specific failure**: Not recalled (was some time ago)
- **Possible causes**:
  - Configuration errors (common with GPU passthrough)
  - Outdated guides or instructions
  - May have been different GPU
  - Lack of experience with Proxmox GPU passthrough

**Current Assessment**: ✅ **Worth Reconsidering**
- Hardware setup is objectively ideal
- Previous failures likely configuration issues, not hardware limitations
- Documentation and guides have improved significantly
- RTX 4060 Ti is well-supported by NVIDIA drivers

---

## Recommendations

### Intel QuickSync: ❌ NOT AVAILABLE
- **Reason**: AMD CPU (QuickSync is Intel-only)
- **Recommendation**: Skip - not an option

### AMD iGPU Passthrough: ⚠️ POSSIBLE BUT COMPLEX
- **Feasibility**: Possible but more complex than discrete GPU
- **Complexity**: High (integrated with CPU, multiple IOMMU groups)
- **Recommendation**: Consider only if NVIDIA passthrough fails

### NVIDIA RTX 4060 Ti Passthrough: ✅ **STRONGLY RECOMMENDED**
- **Feasibility**: Excellent (perfect IOMMU isolation, modern GPU)
- **Expected Benefit**: Massive performance improvement (10-20x faster than CPU)
- **Power Efficiency**: Much lower power consumption than CPU transcoding
- **Quality**: 8th gen NVENC produces high-quality encodes
- **Complexity**: Medium (standard GPU passthrough process)
- **Risk**: Medium (if it fails, rollback to CPU transcoding)
- **Recommendation**: ✅ **Definitely pursue this**

**Why GPU passthrough is worth attempting**:
1. Hardware is perfect (clean IOMMU isolation)
2. RTX 4060 Ti is excellent for transcoding
3. Previous failures likely configuration issues (solvable)
4. Potential benefit is enormous (much faster, lower CPU usage)
5. Can rollback if it doesn't work (VM snapshot exists)

---

## Summary for ADR

**Hardware Capabilities**:
- **CPU**: AMD Ryzen 7 7700 (8C/16T) - good for CPU transcoding but resource-intensive
- **QuickSync**: Not available (AMD CPU)
- **Discrete GPU**: NVIDIA RTX 4060 Ti - **ideal for hardware transcoding**
- **IOMMU**: Enabled with perfect GPU isolation
- **Passthrough Feasibility**: High

**Expected Recommendation**:
1. **tmpfs**: Implement (easy win, low risk)
2. **GPU Passthrough**: ✅ **Strongly recommend attempting** (high potential benefit, good hardware)

**Next Steps**:
- Continue with tmpfs evaluation (Phase 3)
- Research NVIDIA GPU passthrough best practices for Proxmox 8.x
- Create detailed GPU passthrough implementation plan
- Test and measure improvement vs. CPU-only baseline

---

**Research Artifacts**:
- Task: [[tasks/current/IN-007-research-emby-transcoding-optimization|IN-007]]
- Will feed into: [[docs/adr/013-emby-transcoding-optimization|ADR 013]]
