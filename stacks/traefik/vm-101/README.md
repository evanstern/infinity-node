# Traefik Configuration for VM 101 (downloads)

This directory contains the Traefik reverse proxy configuration for VM 101, which hosts critical download clients with VPN protection.

## Services Routed

- **Deluge** (`deluge.local.infinity-node.win`) - Torrent client (CRITICAL)
- **NZBGet** (`nzbget.local.infinity-node.win`) - Usenet downloader (CRITICAL)
- **Portainer** (`portainer-101.local.infinity-node.win`) - Container management

## Special Considerations

### VPN Network Mode

Download clients (Deluge and NZBGet) use `network_mode: service:vpn` for security:

- All traffic routes through the VPN container (kill switch)
- Deluge and NZBGet share the VPN container's network namespace
- VPN container exposes ports 8112 (Deluge) and 6789 (NZBGet) on the host
- **Solution**: Route to `172.17.0.1:8112` and `172.17.0.1:6789` (Docker bridge gateway) to reach VPN container's exposed ports
- Direct port access (`http://deluge.local.infinity-node.win:8112`, `http://nzbget.local.infinity-node.win:6789`) remains available as fallback

### Port Availability

- Ports 80 and 443 are used by Traefik
- Port 8112 is used by Deluge (via VPN container)
- Port 6789 is used by NZBGet (via VPN container)
- Port 32768 is used by Portainer (HTTPS, non-standard)
- Port 8000 is used by Portainer (HTTP)

## Deployment

### Prerequisites

Since Portainer's GitOps only pulls `docker-compose.yml` from the repository, configuration files (`traefik.yml` and `dynamic.yml`) must be manually placed on VM-101 **before** deploying the stack.

### Step 1: Prepare Configuration Files on VM-101

SSH into VM-101 and create the configuration directory:

```bash
# SSH to VM-101
ssh evan@192.168.1.101

# Create config directory
sudo mkdir -p /opt/traefik/config
sudo chown evan:evan /opt/traefik/config
```

Copy the configuration files to VM-101. From your local machine:

```bash
# Copy traefik.yml
scp stacks/traefik/vm-101/traefik.yml evan@192.168.1.101:/opt/traefik/config/

# Copy dynamic.yml
scp stacks/traefik/vm-101/dynamic.yml evan@192.168.1.101:/opt/traefik/config/
```

Verify files are in place:

```bash
# On VM-101
ls -la /opt/traefik/config/
# Should show: traefik.yml, dynamic.yml
```

### Step 2: Deploy via Portainer GitOps

1. **Access Portainer** on VM-101: <http://portainer-101.local.infinity-node.win:32768>
2. **Navigate to Stacks** → Add stack
3. **Select "Repository"** as the build method
4. **Configure Git settings:**
   - **Repository URL:** `https://github.com/evanstern/infinity-node`
   - **Repository reference:** `main`
   - **Compose file path:** `stacks/traefik/vm-101/docker-compose.yml`
5. **Configure Environment Variables:**
   - Add: `CONFIG_PATH=/opt/traefik/config`
6. **Enable GitOps Updates:**
   - Enable "Auto update" with 5-minute polling
   - Enable "Force redeploy"
7. **Deploy the stack**

### Step 3: Verify Deployment

```bash
# Check Traefik logs
docker logs traefik

# Test dashboard
curl http://192.168.1.101:8080/api/rawdata

# Test service routing
curl -H "Host: deluge.local.infinity-node.win" http://192.168.1.101/
curl -H "Host: nzbget.local.infinity-node.win" http://192.168.1.101/
```

### Updating Configuration

To update `traefik.yml` or `dynamic.yml`:

1. Update files in git repository
2. Copy updated files to VM-101:
   ```bash
   scp stacks/traefik/vm-101/traefik.yml evan@192.168.1.101:/opt/traefik/config/
   scp stacks/traefik/vm-101/dynamic.yml evan@192.168.1.101:/opt/traefik/config/
   ```
3. Restart Traefik container in Portainer (or wait for GitOps auto-update if `watch: true` is enabled in traefik.yml)

## Testing

After deployment, test each service:

```bash
# Test Deluge routing
curl -H "Host: deluge.local.infinity-node.win" http://192.168.1.101/

# Test NZBGet routing
curl -H "Host: nzbget.local.infinity-node.win" http://192.168.1.101/

# Test Portainer routing
curl -H "Host: portainer-101.local.infinity-node.win" http://192.168.1.101/
```

## Troubleshooting

- **Download clients not accessible via Traefik**: Verify VPN container is running and ports 8112/6789 are exposed. Check `docker ps` and `ss -tuln`.
- **Port conflicts**: Ensure ports 80/443 are not in use by other services
- **VPN routing**: If `172.17.0.1` doesn't work, verify Docker bridge gateway IP with `docker network inspect bridge | jq -r '.[0].IPAM.Config[0].Gateway'`
