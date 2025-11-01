---
type: documentation
tags:
  - mdtd
  - reference
  - agents
---

# Agent Selection Reference

Which agent to use for different types of work.

## Agent Capabilities

### Infrastructure Agent
**Responsibilities:**
- Proxmox VM management
- Networking configuration
- Storage setup and allocation
- Resource monitoring
- System-level operations

**Use for:**
- Creating/modifying VMs
- Network configuration
- Storage changes
- Resource allocation

### Docker Agent
**Responsibilities:**
- Container orchestration
- Docker Compose files
- Portainer stack management
- Container networking
- Volume management

**Use for:**
- Creating compose files
- Deploying stacks
- Container troubleshooting
- Docker network setup

### Security Agent
**Responsibilities:**
- Secret management (Vaultwarden)
- Access control
- Pangolin tunnels
- VPN configuration
- Credential handling

**Use for:**
- Storing/retrieving secrets
- Setting up tunnels
- Configuring VPN
- Access control changes

### Media Stack Agent
**Responsibilities:**
- Emby (VM 100)
- Arr services (VM 102)
- Download clients (VM 101)
- Media automation

**CRITICAL SERVICES** - Extra care required

**Use for:**
- Emby configuration
- Arr service setup
- Download client management
- Media pipeline work

### Documentation Agent
**Responsibilities:**
- Documentation writing
- Runbook creation
- ADR documentation
- Knowledge management
- MDTD task management

**Use for:**
- Creating/updating docs
- Writing runbooks
- Creating ADRs
- Task management

### Testing Agent
**Responsibilities:**
- Validation and verification
- Quality assurance
- Read-only testing
- Health checks

**CONSTRAINTS:**
- Read-only access (inspector user)
- Cannot make changes
- Validation only

**Use for:**
- Validating deployments
- Testing functionality
- Health checks
- QA verification

---

## Agent Coordination

**Simple tasks**: Single agent typically sufficient

**Moderate tasks**: 2-3 agents may coordinate
```
Example: Deploy new service
- docker: Create and deploy compose file
- security: Setup secrets in Vaultwarden
- testing: Validate deployment
```

**Complex tasks**: Multiple agents work together
```
Example: Migrate service to new VM
- infrastructure: Create new VM, setup networking
- docker: Migrate container configs
- security: Transfer secrets, update access
- media: Configure service (if critical)
- testing: Validate each phase
- documentation: Document process
```

---

## Primary vs Inline Assignment

**Primary Agent** - Owns the phase:
```
Phase 2: Deployment
PRIMARY AGENT: docker
```

**Inline Assignment** - Specific task:
```
- [ ] Create compose file [agent:docker]
- [ ] Setup secrets [agent:security]
- [ ] Deploy stack [agent:docker]
```

---

## Related Documentation

- **[[phases/05-execution-planning]]** - Execution planning guide
- **[[docs/agents/README]]** - Full agent system documentation
