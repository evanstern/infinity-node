# Traefik Configuration for VM 102 (arr services)

This directory contains the Traefik reverse proxy configuration for VM 102, which hosts critical media automation services.

## Services Routed

- **Radarr** (`radarr.local.infinity-node.win`) - Movie management (CRITICAL)
- **Sonarr** (`sonarr.local.infinity-node.win`) - TV show management (CRITICAL)
- **Lidarr** (`lidarr.local.infinity-node.win`) - Music management (CRITICAL)
- **Prowlarr** (`prowlarr.local.infinity-node.win`) - Indexer management (CRITICAL)
- **Jellyseerr** (`jellyseerr.local.infinity-node.win`) - Request management
- **Flaresolverr** (`flaresolverr.local.infinity-node.win`) - Cloudflare bypass
- **Huntarr** (`huntarr.local.infinity-node.win`) - Unified search interface
- **Portainer** (`portainer-102.local.infinity-node.win`) - Container management

## Port Availability

- Ports 80 and 443 are used by Traefik
- Port 7878 is used by Radarr
- Port 8989 is used by Sonarr
- Port 8686 is used by Lidarr
- Port 9696 is used by Prowlarr
- Port 5055 is used by Jellyseerr
- Port 8191 is used by Flaresolverr
- Port 8080 is used by Huntarr (verify if different)
- Port 9443 is used by Portainer (HTTPS)
- Port 8000 is used by Portainer (HTTP)

## Deployment

1. Commit these files to git
2. Deploy via Portainer:
   ```bash
   ./scripts/infrastructure/create-git-stack.sh \
     --secret "portainer-api-token-vm-102" \
     --stack-name "traefik" \
     --compose-file "stacks/traefik/vm-102/docker-compose.yml"
   ```
3. Verify Traefik starts successfully
4. Test routing for all services

## Testing

After deployment, test each service:

```bash
# Test arr services
curl -H "Host: radarr.local.infinity-node.win" http://vm-102.local.infinity-node.win/
curl -H "Host: sonarr.local.infinity-node.win" http://vm-102.local.infinity-node.win/
curl -H "Host: lidarr.local.infinity-node.win" http://vm-102.local.infinity-node.win/
curl -H "Host: prowlarr.local.infinity-node.win" http://vm-102.local.infinity-node.win/

# Test other services
curl -H "Host: jellyseerr.local.infinity-node.win" http://vm-102.local.infinity-node.win/
curl -H "Host: flaresolverr.local.infinity-node.win" http://vm-102.local.infinity-node.win/
curl -H "Host: huntarr.local.infinity-node.win" http://vm-102.local.infinity-node.win/
curl -H "Host: portainer-102.local.infinity-node.win" http://vm-102.local.infinity-node.win/
```

## Troubleshooting

- **Services not accessible via Traefik**: Verify services are on `traefik-network`. Check with `docker network inspect traefik-network`.
- **Port conflicts**: Ensure ports 80/443 are not in use by other services
- **Container names**: Verify container names match (Portainer may prefix with stack name)
