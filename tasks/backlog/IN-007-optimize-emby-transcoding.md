---
type: task
task-id: IN-007
status: pending
priority: 5
category: media
agent: media
created: 2025-10-24
updated: 2025-10-26
tags:
  - task
  - media
  - emby
  - performance
  - optimization
---

# Task: IN-007 - Optimize Emby Transcoding Performance

## Description

Optimize Emby transcoding performance by configuring tmpfs for transcoding temporary files and exploring hardware transcoding options.

## Context

Emby is a CRITICAL service used by household members. Transcoding performance directly affects user experience during streaming.

Current state:
- CPU-only transcoding
- Transcoding temp directory on regular storage
- No tmpfs configuration

Potential improvements:
- tmpfs for transcoding temp (faster I/O)
- Hardware transcoding (GPU passthrough)

## Acceptance Criteria

- [ ] Research tmpfs setup for transcoding directory
- [ ] Test tmpfs configuration on emby VM
- [ ] Measure performance improvement
- [ ] Research hardware transcoding options (GPU passthrough)
- [ ] Assess hardware transcoding feasibility
- [ ] Document findings and recommendations
- [ ] Implement approved optimizations
- [ ] Test with various media types
- [ ] Validate with household users
- [ ] Update emby service documentation

## Dependencies

- Understanding of Emby transcoding config
- VM 100 resources (RAM for tmpfs)
- Hardware transcoding: GPU availability in Proxmox host
- Testing during low-usage window

## Testing Plan

[[docs/agents/TESTING|Testing Agent]] should validate:
- Emby still functions correctly after changes
- Transcoding works for various formats
- Performance metrics show improvement
- No regressions in quality
- Resource usage is acceptable

[[docs/agents/MEDIA|Media Stack Agent]] should coordinate:
- User testing with household members
- Multiple concurrent stream testing
- Various media format testing

## Related Documentation

- [[docs/agents/MEDIA|Media Stack Agent]]
- [[docs/ARCHITECTURE|Architecture]] - VM 100
- Future: docs/services/emby.md

## Notes

**tmpfs Configuration:**

Benefits:
- Much faster I/O for transcoding temp files
- Reduces wear on storage
- Can significantly improve transcode start time

Considerations:
- Uses RAM (need adequate allocation on VM 100)
- Temp files lost on reboot (this is fine)
- Size depends on concurrent transcodes

Implementation:
```yaml
# In docker-compose.yml
volumes:
  - type: tmpfs
    target: /config/transcoding-temp
    tmpfs:
      size: 4G  # Adjust based on needs
```

**Hardware Transcoding:**

Benefits:
- Much faster transcoding
- Lower CPU usage
- Better quality at same bitrate
- Support more concurrent streams

Options:
1. Intel QuickSync (if Proxmox host has Intel CPU with iGPU)
2. NVIDIA GPU passthrough
3. AMD GPU passthrough

Considerations:
- Proxmox host must have compatible hardware
- GPU passthrough setup complexity
- May require CPU flags (IOMMU)
- Driver installation in VM
- Emby license may be needed for full hw transcode

Research needed:
- Proxmox host hardware capabilities
- GPU passthrough feasibility
- Emby licensing requirements
- Alternative: Intel QuickSync

**Performance Metrics:**

Measure before and after:
- Time to start transcoding
- Concurrent transcode capacity
- CPU usage during transcoding
- User-perceived quality
- Buffering/stalling events

**User Impact:**

This is a CRITICAL service optimization:
- Test during low-usage window (3-6 AM)
- Have rollback plan ready
- Monitor closely after changes
- Get user feedback
- Keep current config backed up

**Priority:**

Low priority currently because:
- Emby works adequately now
- Other tasks are more critical
- Requires careful testing
- Nice to have, not must-have

Revisit priority if:
- Users report transcoding issues
- More concurrent streams needed
- New hardware available
