---
type: stack
service: traefik
category: infrastructure
vms: [100, 101, 102, 103]
priority: high
status: in-progress
stack-type: multi-vm
has-secrets: false
external-access: false
ports: [80, 443]
backup-priority: low
created: 2025-01-XX
updated: 2025-01-XX
tags:
  - stack
  - vm-100
  - vm-101
  - vm-102
  - vm-103
  - infrastructure
  - reverse-proxy
  - networking
aliases:
  - Traefik
  - Reverse Proxy
---

# Traefik Reverse Proxy Stack

**Service:** Traefik (Reverse Proxy)
**VMs:** 100, 101, 102, 103 (all VMs)
**Priority:** High - Enables port-free service access
**Access:** http://traefik.local.infinity-node.com:8080 (dashboard, per VM)
**Image:** `traefik:v3.0`

## Overview

Traefik is a modern reverse proxy and load balancer that enables port-free access to services via DNS names. Deployed on all VMs (100, 101, 102, 103), Traefik listens on ports 80 and 443 and routes traffic to backend services based on hostname.

**Key Benefits:**
- **Port-free URLs**: Access services via `http://service-name.local.infinity-node.com` instead of `http://192.168.86.XXX:PORT`
- **Centralized routing**: Single entry point per VM for all web services
- **Service discovery**: Automatic routing based on DNS names
- **Future-ready**: Foundation for TLS/HTTPS, authentication, and advanced routing

## Architecture

### Multi-VM Structure

Each VM has its own Traefik instance with VM-specific configuration:

```
stacks/traefik/
├── template/              # Base templates (reusable)
│   ├── docker-compose.yml.template
│   ├── traefik.yml.template
│   ├── dynamic.yml.template
│   └── README.md
├── vm-100/                # VM 100 (emby) - CRITICAL
│   ├── docker-compose.yml
│   ├── traefik.yml
│   ├── dynamic.yml
│   └── README.md
├── vm-101/                # VM 101 (downloads) - CRITICAL
├── vm-102/                # VM 102 (arr) - CRITICAL
├── vm-103/                # VM 103 (misc) - Important
└── README.md              # This file
```

### Why Separate Instances Per VM?

- **Network isolation**: Each VM's Traefik only routes to services on that VM
- **Independent configuration**: VM-specific routing rules and settings
- **Portainer integration**: Each VM has its own Portainer stack
- **Failure isolation**: Issues on one VM don't affect others

## Configuration

### Static Configuration (`traefik.yml`)

Defines entrypoints, providers, and global settings:
- **Entrypoints**: Ports 80 (HTTP) and 443 (HTTPS, reserved for future)
- **File Provider**: Reads routing rules from `dynamic.yml`
- **Docker Provider**: Optional, for future Docker label-based routing
- **API Dashboard**: Enabled on port 8080 (insecure for now)

### Dynamic Configuration (`dynamic.yml`)

Contains routing rules that change frequently:
- **Routers**: Match requests based on hostname
- **Services**: Backend containers to route to
- **Middlewares**: Request/response transformations (optional)

### Example Routing Rule

```yaml
http:
  routers:
    vaultwarden:
      rule: "Host(`vaultwarden.local.infinity-node.com`)"
      entryPoints:
        - web
      service: vaultwarden

  services:
    vaultwarden:
      loadBalancer:
        servers:
          - url: "http://vaultwarden:80"
```

## Service Routing

### VM 100 (emby) - CRITICAL

**Services:**
- Emby (8096) - ⚠️ **Host network mode** - May need special handling
- Tdarr (8265)
- Portainer (9443)

**Special Considerations:**
- Emby uses `network_mode: host` - Traefik cannot route to host network containers directly
- Options: Keep direct access for Emby, or route via host IP (more complex)

### VM 101 (downloads) - CRITICAL

**Services:**
- Deluge (8112) - Via VPN container
- NZBGet (6789) - Via VPN container
- Portainer (32768)

**Special Considerations:**
- Download clients use `network_mode: container:vpn`
- Traefik routes to VPN container ports (8112, 6789)
- VPN container exposes these ports to host

### VM 102 (arr) - CRITICAL

**Services:**
- Radarr (7878)
- Sonarr (8989)
- Lidarr (8686)
- Prowlarr (9696)
- Jellyseerr (5055)
- Flaresolverr (8191)
- Huntarr (9705)
- Portainer (9443)

**Standard Configuration:**
- All services use standard bridge network
- Standard Traefik routing works normally

### VM 103 (misc) - Important

**Services:**
- Vaultwarden (8111)
- Paperless-NGX (8000)
- Immich (2283)
- Linkwarden (3000)
- Navidrome (4533)
- Audiobookshelf (80 internal)
- MyBibliotheca (5054)
- Calibre (8265/8266/8267)
- Homepage (3001)
- Portainer (9443)

**Standard Configuration:**
- All services use standard bridge network
- Standard Traefik routing works normally

## Deployment

### Prerequisites

- ✅ DNS records configured (IN-034 complete)
- ✅ Ports 80/443 available on target VM
- ✅ Docker running on target VM
- ✅ Portainer accessible on target VM

### Deployment Steps

1. **Create VM-specific stack:**
   ```bash
   # Copy templates
   cp stacks/traefik/template/* stacks/traefik/vm-XXX/

   # Rename files
   cd stacks/traefik/vm-XXX/
   mv docker-compose.yml.template docker-compose.yml
   mv traefik.yml.template traefik.yml
   mv dynamic.yml.template dynamic.yml
   ```

2. **Customize `dynamic.yml`:**
   - Add routers for each service on this VM
   - Add services pointing to backend containers
   - Use DNS names from `config/dns-records.json`

3. **Deploy via Portainer:**
   ```bash
   ./scripts/infrastructure/create-git-stack.sh \
     "portainer-api-token-vm-XXX" \
     "shared" \
     <portainer-endpoint-id> \
     "traefik" \
     "stacks/traefik/vm-XXX/docker-compose.yml"
   ```

4. **Enable GitOps:**
   - Portainer UI → Stacks → traefik → Settings
   - Enable "Auto update" with 5-minute polling
   - Enable "Force redeploy"

5. **Verify deployment:**
   ```bash
   # Check Traefik logs
   docker logs traefik

   # Test dashboard
   curl http://<vm-ip>:8080/api/rawdata

   # Test service routing
   curl -H "Host: service-name.local.infinity-node.com" http://<vm-ip>/
   ```

## Service Integration

### Adding Services to Traefik Network

After deploying Traefik, update service docker-compose.yml files to use Traefik network:

```yaml
services:
  service-name:
    networks:
      - traefik-network
      - default  # Keep default for other connections

networks:
  traefik-network:
    external: true
    name: traefik-network
```

### Adding Routing Rules

Add service to `dynamic.yml`:

```yaml
http:
  routers:
    service-name:
      rule: "Host(`service-name.local.infinity-node.com`)"
      entryPoints:
        - web
      service: service-name

  services:
    service-name:
      loadBalancer:
        servers:
          - url: "http://service-name:port"
```

Then redeploy Traefik stack via Portainer (GitOps will auto-update).

## Access URLs

### Traefik Dashboard

- **VM 100**: http://192.168.86.172:8080 (direct access - dashboard not routed via Traefik)
- **VM 101**: http://192.168.86.173:8080 (direct access - dashboard not routed via Traefik)
- **VM 102**: http://192.168.86.174:8080 (direct access - dashboard not routed via Traefik)
- **VM 103**: http://192.168.86.249:8080 (direct access - dashboard not routed via Traefik)

### Service Access (Port-Free)

Once configured, services accessible via:
- `http://service-name.local.infinity-node.com`

Examples:
- `http://vaultwarden.local.infinity-node.com`
- `http://radarr.local.infinity-node.com`
- `http://emby.local.infinity-node.com` (if configured)

## Troubleshooting

### Traefik Not Starting

1. **Check logs:**
   ```bash
   docker logs traefik
   ```

2. **Verify configuration syntax:**
   ```bash
   docker compose -f stacks/traefik/vm-XXX/docker-compose.yml config
   ```

3. **Check port availability:**
   ```bash
   ss -tuln | grep -E ':(80|443)'
   ```

### Services Not Routing

1. **Check Traefik dashboard:**
   - Navigate to http://<vm-ip>:8080
   - Check "HTTP" → "Routers" and "Services"

2. **Verify DNS resolution:**
   ```bash
   dig service-name.local.infinity-node.com
   ```

3. **Check service container name:**
   - Container name in `dynamic.yml` must match actual container name
   - Use `docker ps` to verify container names

4. **Verify network connectivity:**
   ```bash
   docker network inspect traefik-network
   ```

### Network Mode Issues

**Host Network Mode (Emby):**
- Traefik cannot route to host network containers
- Options: Keep direct access, or route via host IP

**VPN Container Network Mode (VM 101):**
- Route to VPN container name, not download client container
- Use VPN container's exposed ports

## Future Enhancements

- **TLS/HTTPS**: Add Let's Encrypt certificates for secure access
- **Authentication**: Add Traefik dashboard authentication
- **Docker Labels**: Migrate to Docker label-based routing for easier management
- **Monitoring**: Add Prometheus metrics export
- **Load Balancing**: Configure multiple backend instances if needed

## Related Documentation

- [[docs/ARCHITECTURE|Infrastructure Architecture]]
- [[config/dns-records.json|DNS Records Configuration]]
- [[docs/agents/DOCKER|Docker Agent]]
- [[tasks/current/IN-046-deploy-traefik-reverse-proxy-vm-103|Task IN-046]]

## Notes

- **Initial Deployment**: Starting with VM 103 (non-critical) as proof of concept
- **Critical VMs**: VM 100, 101, 102 deployed after VM 103 validation
- **TLS Out of Scope**: HTTPS configuration deferred to future task
- **Dashboard Auth**: Authentication deferred to future task
- **File Provider**: Using file-based configuration initially, can migrate to Docker labels later
