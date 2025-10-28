---
type: task
task-id: IN-004
status: pending
priority: 2
category: documentation
agent: documentation
created: 2025-10-24
updated: 2025-10-27
tags:
  - task
  - documentation
  - emby
  - critical
  - media
---

# Task: IN-004 - Document Emby Service Configuration

## Description

Create comprehensive documentation for the Emby media server service using the service template, including configuration, dependencies, troubleshooting, and maintenance procedures.

## Context

Emby is our MOST CRITICAL service - it affects household users and must maintain 99.9% uptime. Complete documentation is essential for:
- Quick troubleshooting
- Configuration reference
- Disaster recovery
- Optimization guidance

Currently, Emby configuration is not fully documented.

## Acceptance Criteria

- [ ] Create docs/services/emby.md using service template
- [ ] Document current configuration (docker-compose)
- [ ] Document environment variables
- [ ] Document volume mappings and storage
- [ ] Document network configuration (host mode)
- [ ] List dependencies (NAS, Pangolin tunnel)
- [ ] Document access methods (internal, external)
- [ ] Create troubleshooting section
- [ ] Document backup requirements
- [ ] Document upgrade procedure
- [ ] Document performance optimization (transcoding)
- [ ] Link from [[docs/ARCHITECTURE|Architecture]]
- [ ] Link from [[README]]

## Dependencies

- Access to VM 100 (emby)
- Current docker-compose.yml
- Understanding of Emby configuration

## Testing Plan

[[docs/agents/TESTING|Testing Agent]] should validate:
- Documentation is accurate and complete
- Configuration details match actual deployment
- Links work correctly
- Troubleshooting steps are valid

## Related Documentation

- [[docs/agents/MEDIA|Media Stack Agent]]
- [[docs/ARCHITECTURE|Architecture]] - VM 100 section
- Template: .obsidian/templates/service.md

## Notes

**Priority Update (2025-10-27):**
Priority increased from 3→2 due to:
- Task description identifies Emby as "MOST CRITICAL service"
- Affects household users (99.9% uptime requirement)
- Critical service documentation should be higher priority
- Essential for quick troubleshooting and disaster recovery
- No comprehensive documentation currently exists

**Key topics to cover:**

**Configuration:**
- Hardware transcoding (currently disabled)
- Library organization
- User access
- Metadata providers

**Performance:**
- Transcoding optimization
- tmpfs for transcoding temp (future enhancement)
- Network streaming
- Resource usage

**Integration:**
- Pangolin tunnel for external access
- *arr services for media import
- NAS for media storage

**Maintenance:**
- Update procedure (via Watchtower)
- Database maintenance
- Cache management
- Log rotation

**Troubleshooting:**
- Playback issues
- Transcoding failures
- Connectivity problems
- Permission errors

**Critical notes:**
- Host network mode required for discovery
- Household users depend on this service
- Downtime affects multiple users
- Test changes during low-usage windows
