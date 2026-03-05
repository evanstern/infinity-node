# Traefik Stack - VM 104

**VM:** 104
**IP:** vm-104.local.infinity-node.win
**Status:** New
**Priority:** TBD

## Overview

Traefik reverse proxy deployment for VM 104, routing all web-accessible services on this VM.

## Services Routed

This Traefik instance routes the following services:

- **Forgejo** - `forgejo.local.infinity-node.win` → `forgejo:3000`
- **Portainer** - `portainer-104.local.infinity-node.win` → `portainer:9000`

## Configuration Files

- `docker-compose.yml` - Traefik container configuration
- `traefik.yml` - Static Traefik configuration (entrypoints, providers)
- `dynamic.yml` - Dynamic routing rules (routers, services)

## Deployment

### Prerequisites

1. **Create required directories on VM:**
   ```bash
   mkdir -p /home/openclaw/.config/traefik/auth
   mkdir -p /home/openclaw/logs/traefik
   ```

2. **Copy configuration files to VM:**
   ```bash
   scp traefik.yml vm-104:/home/openclaw/.config/traefik/
   scp dynamic.yml vm-104:/home/openclaw/.config/traefik/
   ```

### Initial Deployment

1. **Deploy via Portainer:**
   ```bash
   ./scripts/infrastructure/create-git-stack.sh \
     "portainer-api-token-vm-104" \
     "shared" \
     4 \
     "traefik" \
     "stacks/traefik/vm-104/docker-compose.yml"
   ```

2. **Enable GitOps:**
   - Portainer UI → Stacks → traefik → Settings
   - Enable "Auto update" (5-minute polling)
   - Enable "Force redeploy"

3. **Verify deployment:**
   ```bash
   # Check Traefik logs
   docker logs traefik

   # Test dashboard (direct access - dashboard not routed via Traefik)
   curl http://vm-104.local.infinity-node.win:8080/api/rawdata
   ```

### Updating Routing Rules

1. Edit `dynamic.yml` to add/remove/modify routes
2. Commit changes to git
3. Portainer GitOps will auto-update (or manually redeploy)

## Service Integration

### Adding Services to Traefik Network

After deploying Traefik, update service docker-compose.yml files to use Traefik network:

```yaml
services:
  service-name:
    networks:
      - traefik-network
      - default

networks:
  traefik-network:
    external: true
    name: traefik-network
```

### Adding New Service Route

1. Add router and service to `dynamic.yml`:
   ```yaml
   http:
     routers:
       new-service:
         rule: "Host(`new-service.local.infinity-node.win`)"
         entryPoints:
           - web
         service: new-service

     services:
       new-service:
         loadBalancer:
           servers:
             - url: "http://new-service-container:port"
   ```

2. Commit and push changes
3. Portainer GitOps will auto-update

## Testing

### Test DNS Resolution

```bash
dig forgejo.local.infinity-node.win
# Should return: vm-104.local.infinity-node.win
```

### Test Port-Free Access

```bash
# Test Forgejo
curl -H "Host: forgejo.local.infinity-node.win" http://vm-104.local.infinity-node.win/

# Test Portainer
curl -H "Host: portainer-104.local.infinity-node.win" http://vm-104.local.infinity-node.win/
```

### Test in Browser

Navigate to:
- `http://forgejo.local.infinity-node.win`
- `http://portainer-104.local.infinity-node.win`

## Troubleshooting

### Service Not Routing

1. **Check container name matches:**
   ```bash
   docker ps | grep service-name
   ```

2. **Verify service is on Traefik network:**
   ```bash
   docker network inspect traefik-network
   ```

3. **Check Traefik logs:**
   ```bash
   docker logs traefik
   ```

4. **Verify DNS resolution:**
   ```bash
   dig service-name.local.infinity-node.win
   ```

### Traefik Not Starting

1. **Check configuration syntax:**
   ```bash
   docker compose -f stacks/traefik/vm-104/docker-compose.yml config
   ```

2. **Check port availability:**
   ```bash
   ss -tuln | grep -E ':(80|443)'
   ```

3. **Check Traefik logs:**
   ```bash
   docker logs traefik
   ```

## Related Documentation

- [[stacks/traefik/README|Traefik Stack Overview]]
- [[stacks/traefik/template/README|Base Templates]]
- [[docs/ARCHITECTURE|Infrastructure Architecture]]
- [[config/dns-records.json|DNS Records Configuration]]
