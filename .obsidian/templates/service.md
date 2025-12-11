---
type: service
vm:
ip:
criticality:
container-name:
image:
tags:
  - service
---

# Service: {{title}}

**VM:** [[VM-XXX]]
**IP:** 192.168.1.XXX
**Criticality:** Critical | Important | Normal
**Container:** `container-name`
**Image:** `organization/image:tag`
**Agent:** [[AGENT|Responsible Agent]]

## Purpose

What this service does and why it's needed.

## Configuration

### Docker Compose
Location: `stacks/service-name/docker-compose.yml`

### Environment Variables
See `.env.example` for required variables:
- `VAR_NAME`: Description
- `VAR_NAME2`: Description

### Volumes
- `${CONFIG_PATH}:/config` - Service configuration
- `${DATA_PATH}:/data` - Service data

### Networking
- Port: XXXX
- Network mode: bridge | host
- External access: [[Pangolin]] tunnel | Direct

## Dependencies

**Requires:**
- [[Service 1]] - Reason
- [[Service 2]] - Reason

**Used By:**
- [[Service 3]] - Reason

## Monitoring

### Health Check
```bash
# Command to check service health
curl -f http://localhost:PORT/health
```

### Common Issues
- **Issue 1**: Description and resolution
- **Issue 2**: Description and resolution

## Maintenance

### Backup
What needs to be backed up and how:
- Configuration: Location
- Data: Location

### Updates
Handled by [[Watchtower]] or manual process?

### Restart Procedure
```bash
cd /home/evan/projects/infinity-node/stacks/service-name
docker compose down
docker compose up -d
```

## Access

### Web UI
- Internal: http://192.168.1.XXX:PORT
- External: https://service.infinity-node.com (via [[Pangolin]])

### Credentials
Stored in [[Vaultwarden]] under "Service Name"

## Related Documentation
- [[AGENT|Responsible Agent]]
- [[Runbook - Service Deployment]]
- [[Troubleshooting Guide]]
