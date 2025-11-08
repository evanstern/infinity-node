# Traefik Configuration for VM 101 (downloads)

This directory contains the Traefik reverse proxy configuration for VM 101, which hosts critical download clients with VPN protection.

## Services Routed

- **Deluge** (`deluge.local.infinity-node.com`) - Torrent client (CRITICAL)
- **NZBGet** (`nzbget.local.infinity-node.com`) - Usenet downloader (CRITICAL)
- **Portainer** (`portainer-101.local.infinity-node.com`) - Container management

## Special Considerations

### VPN Network Mode

Download clients (Deluge and NZBGet) use `network_mode: service:vpn` for security:

- All traffic routes through the VPN container (kill switch)
- Deluge and NZBGet share the VPN container's network namespace
- VPN container exposes ports 8112 (Deluge) and 6789 (NZBGet) on the host
- **Solution**: Route to `172.17.0.1:8112` and `172.17.0.1:6789` (Docker bridge gateway) to reach VPN container's exposed ports
- Direct port access (`http://192.168.86.173:8112`, `http://192.168.86.173:6789`) remains available as fallback

### Port Availability

- Ports 80 and 443 are used by Traefik
- Port 8112 is used by Deluge (via VPN container)
- Port 6789 is used by NZBGet (via VPN container)
- Port 32768 is used by Portainer (HTTPS, non-standard)
- Port 8000 is used by Portainer (HTTP)

## Deployment

1. Commit these files to git
2. Deploy via Portainer:
   ```bash
   ./scripts/infrastructure/create-git-stack.sh \
     --secret "portainer-api-token-vm-101" \
     --stack-name "traefik" \
     --compose-file "stacks/traefik/vm-101/docker-compose.yml"
   ```
3. Verify Traefik starts successfully
4. Test routing: `http://deluge.local.infinity-node.com`, `http://nzbget.local.infinity-node.com`

## Testing

After deployment, test each service:

```bash
# Test Deluge routing
curl -H "Host: deluge.local.infinity-node.com" http://192.168.86.173/

# Test NZBGet routing
curl -H "Host: nzbget.local.infinity-node.com" http://192.168.86.173/

# Test Portainer routing
curl -H "Host: portainer-101.local.infinity-node.com" http://192.168.86.173/
```

## Troubleshooting

- **Download clients not accessible via Traefik**: Verify VPN container is running and ports 8112/6789 are exposed. Check `docker ps` and `ss -tuln`.
- **Port conflicts**: Ensure ports 80/443 are not in use by other services
- **VPN routing**: If `172.17.0.1` doesn't work, verify Docker bridge gateway IP with `docker network inspect bridge | jq -r '.[0].IPAM.Config[0].Gateway'`

