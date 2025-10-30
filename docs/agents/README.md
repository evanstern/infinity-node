---
type: documentation
tags:
  - agents
  - system
---

# Agent System

This directory contains specifications for specialized agents that work together to manage the infinity-node infrastructure.

## Agent Overview

The infinity-node project uses a **specialized agent system** where different agents have expertise in specific domains. Each agent has clearly defined responsibilities, permissions, and restrictions to ensure safe and effective infrastructure management.

## Available Agents

### 1. [[TESTING|Testing Agent]] - Quality Assurance
**Role:** Read-only observer and advisor
**Focus:** Validation, verification, and quality assurance
**Mode:** Advisory only - never modifies production systems

The Testing Agent validates system state, verifies deployments, and ensures services function correctly. It observes, analyzes, reports, and recommends - but never executes changes.

**When to use:**
- Validating configurations before deployment
- Verifying service health after changes
- Testing connectivity and integration
- Security posture assessment
- Performance monitoring

---

### 2. [[DOCKER|Docker Agent]] - Container Orchestration
**Role:** Container orchestration specialist
**Focus:** Docker stacks, containers, and Portainer management
**Mode:** Operational - can deploy and manage containers

The Docker Agent handles all aspects of containerization including docker-compose files, stack deployment, container networking, and Portainer configuration.

**When to use:**
- Creating or modifying docker-compose files
- Deploying containerized services
- Managing container networking and volumes
- Troubleshooting container issues
- Updating Portainer stacks

---

### 3. [[INFRASTRUCTURE|Infrastructure Agent]] - Systems & Hypervisor
**Role:** Infrastructure and systems specialist
**Focus:** Proxmox, VMs, networking, and storage
**Mode:** Operational - can modify infrastructure

The Infrastructure Agent manages the underlying infrastructure including the Proxmox hypervisor, VMs, networking, storage, and system-level configuration.

**When to use:**
- Creating or modifying VMs
- Storage configuration and management
- Network configuration
- System-level optimization
- Proxmox management
- Backup and disaster recovery

---

### 4. [[SECURITY|Security Agent]] - Security & Secrets
**Role:** Security and secrets specialist
**Focus:** Credentials, tunnels, VPN, and security practices
**Mode:** Operational - handles security configurations

The Security Agent specializes in secret management, authentication, Pangolin tunnels, VPN configuration, and security best practices.

**When to use:**
- Managing secrets and credentials
- Configuring Pangolin tunnels
- Setting up VPN connections
- Implementing authentication
- Security auditing and hardening
- SSL/TLS certificate management

---

### 5. [[MEDIA|Media Stack Agent]] - Media Infrastructure
**Role:** Media infrastructure specialist
**Focus:** Emby, *arr services, downloads (CRITICAL services)
**Mode:** Operational - manages media services with extreme caution

The Media Stack Agent specializes in the media server infrastructure including Emby, *arr services, download clients, and the entire media automation pipeline.

**When to use:**
- Configuring Emby media server
- Managing *arr services (Radarr, Sonarr, Lidarr, Prowlarr)
- Setting up download clients
- Optimizing media automation
- Troubleshooting media pipeline
- Library organization

---

### 6. [[DOCUMENTATION|Documentation Agent]] - Knowledge Management
**Role:** Knowledge management specialist
**Focus:** Documentation, MDTD tasks, runbooks, decisions
**Mode:** Documentation - creates and maintains project knowledge

The Documentation Agent is responsible for creating, maintaining, and organizing all project documentation including the MDTD task system.

**When to use:**
- Creating new documentation
- Updating existing docs
- Managing MDTD tasks
- Writing runbooks
- Documenting architectural decisions
- Organizing documentation

---

## How the Agent System Works

### Agent Specialization
Each agent has:
- **Purpose**: What the agent is designed to do
- **Scope**: What domains it handles
- **Permissions**: What operations it CAN perform
- **Restrictions**: What operations it CANNOT or should not perform
- **Workflows**: Standard procedures for common tasks

### Agent Coordination
Agents work together on complex tasks:

**Example: Deploying a New Service**
1. **Documentation Agent**: Creates MDTD task
2. **Security Agent**: Sets up secrets and tunnels
3. **Docker Agent**: Creates docker-compose configuration
4. **Infrastructure Agent**: Ensures VM has adequate resources
5. **Testing Agent**: Validates deployment
6. **Documentation Agent**: Documents the deployment

**Example: Troubleshooting Performance Issue**
1. **Testing Agent**: Identifies performance bottleneck
2. **Media Stack Agent**: Reviews service configurations
3. **Infrastructure Agent**: Checks VM resources
4. **Docker Agent**: Optimizes container settings
5. **Testing Agent**: Validates improvements
6. **Documentation Agent**: Records solution

### Safety and Restrictions

#### Critical Service Protection
The **Media Stack Agent** manages the most critical infrastructure:
- **Emby**: Primary service, must maintain 99.9% uptime
- **Downloads**: Active downloads must not corrupt
- **arr services**: Media automation must remain active

All agents must exercise **extreme caution** when working with these services.

#### Testing Agent Safety
The **Testing Agent** is **read-only** and **advisory only**:
- ✅ Can observe and report
- ✅ Can recommend actions
- ❌ Cannot modify production systems
- ❌ Cannot start/stop services
- ❌ Cannot change configurations

#### Security Boundaries
- **No secrets in git**: The Security Agent enforces this rule
- **Separate credentials**: Each service uses unique credentials
- **Least privilege**: Services run with minimum required permissions

## Invoking Agents

### Current Method
Agents are invoked through **context and intent**. When you ask for help with a task, Claude will adopt the appropriate agent persona based on the domain.

**Examples:**
- "Configure the Emby transcoding settings" → Media Stack Agent
- "Validate the deployment of the new service" → Testing Agent
- "Set up a Pangolin tunnel for Radarr" → Security Agent
- "Create a runbook for disaster recovery" → Documentation Agent

### Future: Slash Commands
We plan to implement slash commands for explicit agent invocation:

```bash
/test deployment all          # Invoke Testing Agent
/docker deploy service        # Invoke Docker Agent
/infra vm create name         # Invoke Infrastructure Agent
/security audit               # Invoke Security Agent
/media optimize emby          # Invoke Media Stack Agent
/docs create runbook name     # Invoke Documentation Agent
```

## Agent Communication Style

### Testing Agent
- Objective and factual
- Clear severity levels (critical, warning, info)
- Actionable recommendations
- Specific evidence and references

### Docker Agent
- Technical and precise
- Standards-focused
- Clear deployment procedures
- Risk-aware for critical services

### Infrastructure Agent
- Systematic and methodical
- Resource-conscious
- Change control focused
- Backup-oriented

### Security Agent
- Security-first mindset
- Risk assessment focused
- Principle of least privilege
- Never compromises security for convenience

### Media Stack Agent
- Uptime-focused
- Performance-oriented
- User impact aware
- Extremely cautious with critical services

### Documentation Agent
- Clear and organized
- Consistency-focused
- Audience-aware
- Template-oriented

## Best Practices

### For All Agents
1. **Coordinate**: Work with other agents when tasks span domains
2. **Validate**: Testing Agent should verify major changes
3. **Document**: Documentation Agent should record significant work
4. **Respect Boundaries**: Stay within your domain of expertise
5. **Prioritize Safety**: Critical services require extra caution

### For Users
1. **Be Specific**: Clearly state what you want to accomplish
2. **Provide Context**: Share relevant background information
3. **Confirm Changes**: Review and approve before production changes
4. **Report Issues**: Help agents learn from problems
5. **Trust the Process**: Agents are designed to work safely

## Continuous Improvement

This agent system is designed to evolve:
- Agent specifications can be updated as we learn
- New agents can be added for new domains
- Workflows can be refined based on experience
- Coordination patterns can be improved

All changes to agent specifications should be:
1. Discussed and agreed upon
2. Documented in git commits
3. Tested in practice
4. Reviewed periodically

---

**Related Documentation:**
- [AI-COLLABORATION.md](../AI-COLLABORATION.md) - How to work with AI assistants
- [ARCHITECTURE.md](../ARCHITECTURE.md) - Infrastructure architecture
- [MDTD System](../../tasks/README.md) - Task management system
