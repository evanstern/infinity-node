---
type: documentation
tags:
  - mdtd
  - reference
  - deployment
  - docker
---

# Deployment Checklist Reference

Quick lookups for deployment decisions.

## VM Selection Checklist

### By Service Type

- [ ] **Media service?** → VM 100 (emby)
- [ ] **Download client?** → VM 101 (downloads)
- [ ] **Arr service?** → VM 102 (arr)
- [ ] **Other service?** → VM 103 (misc)

### By Resource Needs

- [ ] **High CPU/transcoding?** → VM 100 (has GPU)
- [ ] **High memory/database?** → VM 103 (most RAM)
- [ ] **VPN required?** → VM 101

---

## Port Allocation Checklist

### Check Before Assigning

- [ ] Port available on target VM
- [ ] Port not in standard exclusion range
- [ ] Port documented in service README
- [ ] Port added to ARCHITECTURE.md

**Ranges:**
- **8000-8999**: Web UIs and APIs (most common)
- **5432-5433**: Postgres
- **3306-3307**: MySQL
- **9000-9999**: Monitoring/admin (Portainer uses 9000/9443)

**Check availability:**
```bash
netstat -tuln | grep <port>
```

---

## Healthcheck Configuration

### HTTP Services
- [ ] Healthcheck endpoint defined
- [ ] Timeout appropriate for service
- [ ] Start period covers startup time
- [ ] Test command validated

```yaml
healthcheck:
  test: ["CMD", "curl", "-f", "http://localhost:8080/health"]
  interval: 30s
  timeout: 10s
  retries: 3
  start_period: 40s
```

### TCP Services
```yaml
healthcheck:
  test: ["CMD-SHELL", "nc -z localhost 5432 || exit 1"]
  interval: 30s
  timeout: 10s
  retries: 3
  start_period: 40s
```

### Command-Based
```yaml
healthcheck:
  test: ["CMD", "pg_isready", "-U", "postgres"]
  interval: 30s
  timeout: 10s
  retries: 3
  start_period: 40s
```

**Timing Guidelines:**
- **interval**: 30s standard, 60s for heavy checks
- **timeout**: 10s standard
- **retries**: 3 standard
- **start_period**: Startup time + buffer (30-60s typical)

---

## Network Configuration

### Mode Selection

- [ ] **Standard isolation needed?** → Bridge (default)
- [ ] **Performance critical?** → Host
- [ ] **Multiple containers communicate?** → Bridge with custom network

**Bridge (default):**
```yaml
networks:
  - app-network
```

**Host:**
```yaml
network_mode: host
```
⚠️ No port mapping, uses host ports directly

---

## Volume Configuration

### Pattern Selection

- [ ] **Simple persistence?** → Named volumes
- [ ] **Shared data with other services?** → Bind mounts (NFS)
- [ ] **Editable configs?** → Local bind mounts

**Named volumes:**
```yaml
volumes:
  - app-data:/data
```

**Bind mounts (NFS):**
```yaml
volumes:
  - /mnt/nas/media:/media:ro
  - /mnt/nas/downloads:/downloads
```

**Local config:**
```yaml
volumes:
  - ./config:/config
```

---

## Environment Variables

### Setup Checklist

- [ ] Use UPPER_SNAKE_CASE naming
- [ ] Group related variables
- [ ] Secrets always from env vars
- [ ] Defaults provided where appropriate
- [ ] All documented in .env.example

**Standard structure:**
```yaml
environment:
  # Service config
  - SERVICE_NAME=${SERVICE_NAME}
  - SERVICE_PORT=${SERVICE_PORT}

  # Database
  - DB_HOST=${DB_HOST}
  - DB_PASSWORD=${DB_PASSWORD}

  # Authentication
  - API_KEY=${API_KEY}
```

**Security Rules:**
- ✅ From environment: `${API_KEY}`
- ❌ Never hardcoded: `api_key=abc123`

---

## Common Stack Patterns

### Single Container

- [ ] Image with specific tag
- [ ] Port mapping defined
- [ ] Data volume configured
- [ ] Restart policy set

```yaml
services:
  app:
    image: app:latest
    ports: ["8080:8080"]
    volumes: ["./data:/data"]
    restart: unless-stopped
```

### App + Database

- [ ] Database dependency specified
- [ ] Health condition used
- [ ] DB connection env vars set
- [ ] Database volume for persistence

```yaml
services:
  app:
    depends_on:
      db:
        condition: service_healthy
    environment:
      - DB_HOST=db

  db:
    image: postgres:15
    volumes: ["db-data:/var/lib/postgresql/data"]
```

### App + Database + Cache

- [ ] All dependencies specified
- [ ] Cache connection configured
- [ ] Persistent volumes for DB
- [ ] Ephemeral cache acceptable

```yaml
services:
  app:
    depends_on: [db, redis]
  db:
    image: postgres:15
  redis:
    image: redis:7-alpine
```

---

## Resource Limits

### When to Set Limits

- [ ] **Known memory leaks?** → Set limits
- [ ] **Experimental service?** → Set limits
- [ ] **Unbounded growth?** → Set limits
- [ ] **Critical service?** → Usually don't limit
- [ ] **Well-behaved?** → Usually don't limit

**Pattern:**
```yaml
deploy:
  resources:
    limits:
      cpus: '2.0'
      memory: 2G
    reservations:
      cpus: '0.5'
      memory: 512M
```

**Guideline:** Set limits at 2x typical usage

---

## Pre-Deployment Decision Tree

```
New Service
├─ [ ] VM Selected
│  ├─ Media? → VM 100
│  ├─ Downloads? → VM 101
│  ├─ Arr? → VM 102
│  └─ Other → VM 103
│
├─ [ ] Port Assigned
│  ├─ Web UI → 8000-8999
│  ├─ Database → Standard port
│  └─ Availability checked
│
├─ [ ] External Access Determined
│  ├─ Yes → Setup Pangolin
│  └─ No → Local only
│
├─ [ ] Dependencies Identified
│  ├─ Database → Multi-container
│  ├─ Cache → Add Redis
│  └─ None → Single container
│
└─ [ ] Secrets Plan
   ├─ Secrets → Vaultwarden
   └─ No secrets → Direct env vars
```

---

## Quick Validation Checklist

### Before Deployment
- [ ] VM has sufficient disk space
- [ ] Port is available
- [ ] Secrets stored in Vaultwarden
- [ ] Stack files in git

### After Deployment
- [ ] Container running
- [ ] Healthcheck passing
- [ ] Service accessible
- [ ] Data persists after restart
- [ ] Documentation updated

---

## Related

- [[patterns/new-service-deployment]] - Full pattern
- [[execution/service-deployment]] - Execution workflow
- [[docs/ARCHITECTURE]] - Infrastructure details
- [[docs/SECRET-MANAGEMENT]] - Secret handling
