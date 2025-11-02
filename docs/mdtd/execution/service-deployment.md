---
type: documentation
category: mdtd
tags:
  - task-execution
  - deployment
  - docker
  - services
created: 2025-11-02
updated: 2025-11-02
---

# Service Deployment Execution

Step-by-step workflow for deploying containerized services.

## When to Use This

Load when executing tasks with:
- Category: `docker` or `infrastructure`
- Tags: `deployment`, `service`, `stack`

**Pattern**: [[patterns/new-service-deployment]] (task creation)
**This doc**: Task execution workflow

---

## Pre-Deployment Quick Check

- [ ] Target VM selected and documented
- [ ] Port available and documented
- [ ] Disk space sufficient (`df -h`)
- [ ] Secrets identified

---

## Phase 1: Create Stack Files

### docker-compose.yml Checklist

- [ ] Specific image tag (not `latest`)
- [ ] All config via environment variables
- [ ] Healthcheck defined
- [ ] Restart policy set (`unless-stopped`)
- [ ] Volumes for data persistence
- [ ] Ports documented

```yaml
version: '3.8'
services:
  service-name:
    image: vendor/image:tag  # Specific tag, not latest
    container_name: service-name
    environment:
      - VAR=${VAR}  # All config from env vars
    volumes:
      - ./data:/data
    ports:
      - "8080:8080"
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8080/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
```

### .env.example Checklist

- [ ] All required variables documented
- [ ] Secrets marked `<from-vaultwarden>`
- [ ] Example values provided (non-secret)
- [ ] Comments explain purpose

```bash
# Service Configuration
SERVICE_PORT=8080
SERVICE_NAME=example

# Secrets
API_KEY=<from-vaultwarden>
DB_PASSWORD=<from-vaultwarden>
```

### Service README Checklist

- [ ] Purpose/description
- [ ] Port and VM documented
- [ ] External access noted
- [ ] Vaultwarden collection specified

```markdown
# Service Name

Purpose: Brief description

## Configuration
- Port: 8080
- VM: 103 (misc)
- External access: No

## Secrets
Collection: `vm-103-misc`
```

---

## Phase 2: Security Setup

### Store Secrets in Vaultwarden

- [ ] BW_SESSION obtained
- [ ] Secrets created in correct collection
- [ ] Custom fields added for metadata
- [ ] `.env.example` updated with field names

```bash
# Get session
export BW_SESSION=$(cat ~/.bw-session)

# Create secret
./scripts/secrets/create-secret.sh \
  "service-name-secrets" \
  "vm-XXX-category" \
  "password123" \
  '{"service":"service-name"}'
```

**Collections:**
- `vm-100-emby`, `vm-101-downloads`, `vm-102-arr`, `vm-103-misc`
- `shared` - Cross-VM credentials
- `external` - External service credentials

**See:** [[docs/SECRET-MANAGEMENT]] for details

---

## Phase 3: Deploy via Portainer

### Deployment Checklist

- [ ] Stack files committed to git
- [ ] Environment variables prepared
- [ ] Portainer API token available
- [ ] Stack deployed successfully
- [ ] Container shows "healthy" status

**Using script:**

```bash
./scripts/infrastructure/create-git-stack.sh \
  --name "service-name" \
  --compose-file "stacks/service-name/docker-compose.yml" \
  --vm-ip "192.168.86.XXX" \
  --portainer-secret "portainer-api-token-vm-XXX" \
  --env-file "path/to/.env"
```

**Manual via UI:**
1. Portainer → Stacks → Add Stack → Git Repository
2. Repository: `https://github.com/user/infinity-node`
3. Compose path: `stacks/service-name/docker-compose.yml`
4. Add environment variables from Vaultwarden
5. Deploy

### Verify Deployment

- [ ] Container running (`docker ps`)
- [ ] Logs show no errors (`docker logs`)
- [ ] Healthcheck passing (if defined)

```bash
ssh evan@192.168.86.XXX
docker ps | grep service-name
docker logs service-name
```

---

## Phase 4: Initial Configuration

- [ ] Service accessible at URL
- [ ] Setup wizard completed (if applicable)
- [ ] Admin user created
- [ ] Admin password stored in Vaultwarden
- [ ] Integrations configured
- [ ] Basic functionality tested

---

## Phase 5: Validation

### Container Health

- [ ] Container status "healthy" or "running"
- [ ] No errors in logs
- [ ] Resource usage acceptable

```bash
docker ps | grep service-name  # Should show "healthy"
docker logs service-name  # Check for errors
docker stats service-name --no-stream  # Resource usage
```

### Functional Testing

- [ ] Service accessible at documented URL
- [ ] Authentication works
- [ ] Core features functional
- [ ] Integrations working (if applicable)

### Persistence Test

- [ ] Test data created
- [ ] Container restarted
- [ ] Data persists after restart

```bash
# Create test data
docker restart service-name
# Wait 30s, verify data persists
```

---

## Phase 6: Documentation

### Final Documentation

- [ ] ARCHITECTURE.md updated with service
- [ ] Stack configuration committed
- [ ] Service README complete
- [ ] Access URLs documented

**Update ARCHITECTURE.md:**
```markdown
### VM XXX (category)
- **service-name** (port XXXX): Description
```

**Commit stack:**
```bash
git add stacks/service-name/
# Use /commit command
```

---

## Common Patterns

**Simple service** - Single container, no dependencies
**Service + Database** - Multi-container with postgres/mysql
**External access** - Add Pangolin tunnel setup

---

## Troubleshooting Quick Reference

### Container won't start
- [ ] Check logs: `docker logs service-name`
- [ ] Verify port not in use: `netstat -tuln | grep PORT`
- [ ] Check environment variables are set
- [ ] Verify volume permissions

**Common issues:**
- Port conflict
- Missing env vars
- Volume permission issues

### Healthcheck failing
- [ ] Verify healthcheck command: `docker inspect service-name | grep -A 10 Health`
- [ ] Test manually: `docker exec service-name curl http://localhost:PORT/health`
- [ ] Check start_period is sufficient

**Common issues:**
- Wrong endpoint
- Service not ready
- Timeout too short

### Not accessible
- [ ] Verify port mapping: `docker port service-name`
- [ ] Check firewall: `sudo ufw status`
- [ ] Test from VM: `curl http://localhost:PORT`

**Common issues:**
- Wrong ports
- Firewall blocking
- Localhost-only binding

---

## Script Reference

- `scripts/infrastructure/create-git-stack.sh` - Deploy stack
- `scripts/secrets/create-secret.sh` - Store secret
- `scripts/validation/check-vm-disk-space.sh` - Check space

**See:** [[scripts/README]] for all scripts

---

## Related

- [[patterns/new-service-deployment]] - Pattern for task creation
- [[reference/deployment-checklist]] - Quick decisions (VM, ports)
- [[docs/SECRET-MANAGEMENT]] - Secret workflow
- [[docs/agents/DOCKER]] - Docker Agent
- [[docs/ARCHITECTURE]] - Infrastructure overview
