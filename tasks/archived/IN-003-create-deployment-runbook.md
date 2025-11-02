---
type: task
task-id: IN-003
status: superseded
priority: 3
category: documentation
agent: documentation
created: 2025-10-24
updated: 2025-11-02
superseded-by: IN-040
superseded-date: 2025-11-02
tags:
  - task
  - documentation
  - runbook
  - deployment
---

# Task: IN-003 - Create Service Deployment Runbook

> [!warning]- ⚠️ Task Superseded
>
> **Status**: This task has been superseded and will not be completed as originally planned.
>
> **Superseded by**: [[tasks/backlog/IN-040-create-service-deployment-documentation|IN-040 - Create Service Deployment Documentation Modules]]
>
> **Reason**: During task creation for IN-003, we realized that a traditional human-oriented runbook isn't the right solution for our use case. Since deployments are primarily AI-assisted and warrant full MDTD task planning, we decided to create modular documentation that integrates with the existing `/create-task` and `/task` commands instead. This approach leverages the proven MDTD system and provides AI-optimized guidance while still being human-readable.
>
> **Date**: 2025-11-02
>
> **Preserved because**: The original task contains valuable thinking about deployment workflow phases and requirements that informed the design of IN-040. It serves as historical context for understanding why we chose the modular documentation approach over a traditional runbook.

## Description

Create a comprehensive runbook documenting the end-to-end process of deploying a new service to the infinity-node infrastructure, including all agent coordination.

## Context

We have documented workflows in [[docs/CLAUDE|CLAUDE.md]] but need a detailed, step-by-step runbook that anyone (human or AI) can follow to deploy a new service consistently and safely.

This will serve as both:
- Reference for deploying new services
- Template for future runbooks
- Training material for understanding the full workflow

## Acceptance Criteria

- [ ] Create docs/runbooks/deployment.md using runbook template
- [ ] Document pre-deployment planning phase
- [ ] Document security setup (secrets, tunnels)
- [ ] Document infrastructure preparation (VM resources)
- [ ] Document Docker stack creation
- [ ] Document deployment execution
- [ ] Document testing and validation
- [ ] Document post-deployment tasks
- [ ] Include agent coordination details
- [ ] Include rollback procedures
- [ ] Include troubleshooting section
- [ ] Link from [[docs/CLAUDE|CLAUDE.md]]

## Dependencies

- Runbook template (already created in .obsidian/templates/)
- Understanding of complete deployment workflow
- Examples from existing services

## Testing Plan

[[docs/agents/TESTING|Testing Agent]] should validate:
- Runbook is complete and accurate
- All steps are clear and actionable
- Links to relevant documentation work
- Example commands are correct

**Practical validation:**
- Use runbook to deploy a test service
- Identify any missing steps or unclear instructions
- Update runbook based on findings

## Related Documentation

- [[docs/CLAUDE|CLAUDE.md]] - Workflows section
- [[docs/agents/README|Agent System]]
- [[docs/agents/SECURITY|Security Agent]]
- [[docs/agents/DOCKER|Docker Agent]]
- [[docs/agents/TESTING|Testing Agent]]

## Notes

**Runbook should cover:**
1. Planning phase
   - Service requirements
   - VM selection
   - Resource assessment
   - Dependency identification

2. Security setup
   - Secret generation
   - .env file creation
   - Vaultwarden storage
   - Pangolin tunnel (if needed)

3. Stack creation
   - docker-compose.yml
   - .env.example
   - README.md
   - healthchecks

4. Deployment
   - Git commit
   - Deploy to VM
   - Container startup
   - Initial configuration

5. Testing
   - Service health
   - Connectivity
   - Integration testing
   - Performance check

6. Documentation
   - Service doc creation
   - Architecture update
   - Task completion

**Include examples:**
- Simple service (single container)
- Complex service (multi-container with database)
- Service requiring tunnel
