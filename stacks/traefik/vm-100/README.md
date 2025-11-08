# Traefik Configuration for VM 100 (emby)

This directory contains the Traefik reverse proxy configuration for VM 100, which hosts the critical Emby media streaming server.

## Services Routed

- **Emby** (`emby.local.infinity-node.com`) - Media streaming server (CRITICAL)
- **Portainer** (`portainer-100.local.infinity-node.com`) - Container management

## Special Considerations

### Emby Host Network Mode

Emby runs with `network_mode: host` for performance reasons. This means:

- Emby is directly accessible on the host's network interface
- Traefik (running in bridge mode) cannot reach Emby via Docker network
- **Solution**: Route to `host.docker.internal:8096` which allows bridge containers to reach host services
- Direct port access (`http://192.168.86.172:8096`) remains available as fallback

### Port Availability

- Ports 80 and 443 are used by Traefik
- Port 8096 is used by Emby (host network)
- Port 9443 is used by Portainer (HTTPS)
- Port 8000 is used by Portainer (HTTP)

## Deployment

1. Commit these files to git
2. Deploy via Portainer:
   ```bash
   ./scripts/infrastructure/create-git-stack.sh \
     --secret "portainer-api-token-vm-100" \
     --stack-name "traefik" \
     --compose-file "stacks/traefik/vm-100/docker-compose.yml"
   ```
3. Verify Traefik starts successfully
4. Test routing: `http://emby.local.infinity-node.com`

## Testing

After deployment, test each service:

```bash
# Test Emby routing
curl -H "Host: emby.local.infinity-node.com" http://192.168.86.172/

# Test Portainer routing
curl -H "Host: portainer-100.local.infinity-node.com" http://192.168.86.172/
```

## Troubleshooting

- **Emby not accessible via Traefik**: Verify `host.docker.internal` resolves correctly. On Linux, this may require Docker 20.10+ and may need to be enabled in Docker daemon config.
- **Port conflicts**: Ensure ports 80/443 are not in use by other services
- **Host network routing**: If `host.docker.internal` doesn't work, can fall back to routing to `172.17.0.1:8096` (default Docker bridge gateway)
