# Traefik Configuration for VM 100 (emby)

This directory contains the Traefik reverse proxy configuration for VM 100, which hosts the critical Emby media streaming server.

## Services Routed

- **Emby (LAN)** `emby.local.infinity-node.win` — Media streaming server (CRITICAL)
- **Emby (External)** `emby.infinity-node.com` — Routed through Pangolin forward-auth until cutover; Traefik now applies headers + rate limiting and emits access logs for fail2ban.
- **Portainer** `portainer-100.local.infinity-node.win` — Container management

## Special Considerations

### Emby Host Network Mode

Emby runs with `network_mode: host` for performance reasons. This means:

- Emby is directly accessible on the host's network interface
- Traefik (running in bridge mode) cannot reach Emby via Docker network
- **Solution**: Route to `host.docker.internal:8096` which allows bridge containers to reach host services
- Direct port access (`http://emby.local.infinity-node.win:8096`) remains available as fallback

### Port Availability

- Ports 80 and 443 are used by Traefik
- Port 8096 is used by Emby (host network)
- Port 9443 is used by Portainer (HTTPS)
- Port 8000 is used by Portainer (HTTP)
- `/home/evan/.config/traefik/vm-100/traefik.yml` and `dynamic.yml` are stored on the host and bind-mounted into the container so Portainer can’t replace them with directories.

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
4. Test routing:
   - LAN: `http://emby.local.infinity-node.win`
   - External (still via Pangolin): `curl -H "Host: emby.infinity-node.com" http://<traefik-ip>`
5. Confirm `/home/evan/logs/traefik/access.log` is being written (required for fail2ban on VM-100).
6. Ensure `/home/evan/.config/traefik/vm-100/*.yml` reflects the latest git changes before redeploying (copy from repo if needed).

## Testing

After deployment, test each service:

```bash
# Test Emby routing (LAN)
curl -H "Host: emby.local.infinity-node.win" http://192.168.1.100/

# Test Portainer routing
curl -H "Host: portainer-100.local.infinity-node.win" http://192.168.1.100/

# Quick log tail (expect JSON access events for fail2ban)
docker exec traefik tail -f /var/log/traefik/access.log
```

## Troubleshooting

- **Emby not accessible via Traefik**: Verify `host.docker.internal` resolves correctly. On Linux, this may require Docker 20.10+ and may need to be enabled in Docker daemon config.
- **Port conflicts**: Ensure ports 80/443 are not in use by other services
- **Host network routing**: If `host.docker.internal` doesn't work, can fall back to routing to `172.17.0.1:8096` (default Docker bridge gateway)
