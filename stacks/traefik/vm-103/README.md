# Traefik Stack - VM 103 (misc)

**VM:** 103 (misc)
**IP:** 192.168.86.249
**Status:** In Progress
**Priority:** Important (non-critical services)

## Overview

Traefik reverse proxy deployment for VM 103, routing all web-accessible services on this VM.

## Services Routed

This Traefik instance routes the following services:

- **Vaultwarden** - `vaultwarden.local.infinity-node.com` → `vaultwarden:80`
- **Paperless-NGX** - `paperless.local.infinity-node.com` → `paperless_webserver:8000`
- **Immich** - `immich.local.infinity-node.com` → `immich_server:2283`
- **Linkwarden** - `linkwarden.local.infinity-node.com` → `linkwarden:3000`
- **Navidrome** - `navidrome.local.infinity-node.com` → `navidrome:4533`
- **Audiobookshelf** - `audiobookshelf.local.infinity-node.com` → `audiobookshelf:80`
- **MyBibliotheca** - `mybibliotheca.local.infinity-node.com` → `mybibliotheca:5054`
- **Calibre** - `calibre.local.infinity-node.com` → `calibre:8080`
- **Calibre-Web** - `calibre-web.local.infinity-node.com` → `calibre-web:8083`
- **Homepage** - `homepage.local.infinity-node.com` → `homepage:3000`
- **Portainer** - `portainer-103.local.infinity-node.com` → `portainer:9000`
- **CookCLI** - `recipes.infinity-node.com` → `cookcli:9080`

## Configuration Files

- `docker-compose.yml` - Traefik container configuration
- `traefik.yml` - Static Traefik configuration (entrypoints, providers)
- `dynamic.yml` - Dynamic routing rules (routers, services)

## Deployment

### Initial Deployment

1. **Deploy via Portainer:**
   ```bash
   ./scripts/infrastructure/create-git-stack.sh \
     "portainer-api-token-vm-103" \
     "shared" \
     3 \
     "traefik" \
     "stacks/traefik/vm-103/docker-compose.yml"
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
   curl http://192.168.86.249:8080/api/rawdata
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
         rule: "Host(`new-service.local.infinity-node.com`)"
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
dig vaultwarden.local.infinity-node.com
# Should return: 192.168.86.249
```

### Test Port-Free Access

```bash
# Test Vaultwarden
curl -H "Host: vaultwarden.local.infinity-node.com" http://192.168.86.249/

# Test Homepage
curl -H "Host: homepage.local.infinity-node.com" http://192.168.86.249/
```

### Test in Browser

Navigate to:
- `http://vaultwarden.local.infinity-node.com`
- `http://homepage.local.infinity-node.com`
- `http://portainer-103.local.infinity-node.com`

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
   dig service-name.local.infinity-node.com
   ```

### Traefik Not Starting

1. **Check configuration syntax:**
   ```bash
   docker compose -f stacks/traefik/vm-103/docker-compose.yml config
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
