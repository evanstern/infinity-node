# Homepage Stack

**Service:** Homepage (Dashboard)
**VM:** 103 (misc)
**Priority:** Medium - Service dashboard
**Access:** http://192.168.86.249:3001
**Image:** `ghcr.io/gethomepage/homepage:latest`

## Overview

Homepage is a modern, highly customizable application dashboard with integrations for over 100 services. It provides a centralized view of all services running across the infinity-node infrastructure.

## Key Features

- **Service Widgets:** Monitor and control services (Radarr, Sonarr, Plex, etc.)
- **Docker Integration:** Auto-detect and display running containers
- **Custom Bookmarks:** Quick links to frequently used services
- **System Monitoring:** CPU, memory, disk usage
- **Weather Widget:** Display local weather information
- **Search Providers:** Quick web searches from dashboard
- **Highly Customizable:** Configure via YAML files
- **Responsive Design:** Works on desktop and mobile

## Configuration

### Secrets

None - Homepage requires no secrets for basic operation.

**Optional API keys for service widgets:**
- Radarr/Sonarr API keys (if using those widgets)
- Weather API key (if using weather widget)
- Other service API keys based on configured widgets

These can be stored in configuration YAML files or Vaultwarden if preferred.

### Volumes

- `./config/homepage` → `/app/config` - Dashboard configuration (YAML files)
- `/var/run/docker.sock` → `/var/run/docker.sock` (read-only) - Docker container monitoring

### Environment Variables

- `PORT` - External port mapping (default: `3001`)
- `HOMEPAGE_ALLOWED_HOSTS` - Allowed hosts for access (security)
- `PUID`/`PGID` - User/Group IDs for file permissions (default: `1000`)

## Deployment

```bash
cd stacks/homepage
cp .env.example .env
# Edit .env to update HOMEPAGE_ALLOWED_HOSTS if VM IP changed
docker compose up -d
```

## Initial Setup

1. **Access Web UI:** Navigate to http://192.168.86.249:3001
2. **Configuration:** Homepage uses YAML files in `./config/homepage/`
3. **Main Config Files:**
   - `services.yaml` - Service widgets and integrations
   - `widgets.yaml` - Dashboard widgets (weather, search, etc.)
   - `bookmarks.yaml` - Quick links and bookmarks
   - `settings.yaml` - General settings and theme

## Configuration Examples

### Services Widget (services.yaml)

```yaml
- Media:
    - Radarr:
        icon: radarr.png
        href: http://192.168.86.xxx:7878
        description: Movie management
        widget:
          type: radarr
          url: http://192.168.86.xxx:7878
          key: YOUR_API_KEY

    - Sonarr:
        icon: sonarr.png
        href: http://192.168.86.xxx:8989
        description: TV show management
        widget:
          type: sonarr
          url: http://192.168.86.xxx:8989
          key: YOUR_API_KEY
```

### Bookmarks (bookmarks.yaml)

```yaml
- Services:
    - Portainer:
        - href: http://192.168.86.249:9000
          description: Docker management

    - Vaultwarden:
        - href: https://vaultwarden.infinity-node.com
          description: Password manager
```

### Docker Widget

Homepage automatically detects running containers when Docker socket is mounted. Configure in `services.yaml`:

```yaml
- Docker:
    - VM 103:
        widget:
          type: docker
          server: local
```

## Customization

### Themes

Homepage supports multiple themes and custom CSS. Configure in `settings.yaml`:

```yaml
theme: dark
color: slate
```

### Layouts

Customize layout in `settings.yaml`:

```yaml
layout:
  Media:
    style: row
    columns: 3
```

## Monitoring

```bash
# View logs
docker logs -f homepage

# Check configuration
docker exec homepage ls -la /app/config
```

## Backup

```bash
# Backup configuration
tar -czf homepage-backup.tar.gz ./config/homepage/

# Restore
tar -xzf homepage-backup.tar.gz -C ./
```

## Troubleshooting

**Dashboard not loading:**
- Check logs: `docker logs homepage`
- Verify PORT is not in use
- Check HOMEPAGE_ALLOWED_HOSTS matches access IP

**Docker widgets not showing:**
- Verify Docker socket is mounted
- Check socket permissions: `ls -la /var/run/docker.sock`
- Ensure user has docker group access

**Service widgets not updating:**
- Verify API keys are correct
- Check service URLs are accessible from container
- Review widget configuration in services.yaml

## Security Considerations

- **Docker Socket Access:** Homepage has read-only access to Docker socket
- **ALLOWED_HOSTS:** Restricts which hosts can access the dashboard
- **API Keys:** Store service API keys securely (consider Vaultwarden)
- **No Built-in Auth:** Homepage has no authentication (rely on network security or reverse proxy)

## Widget Integration Examples

**Supported Services:**
- **Media:** Plex, Emby, Jellyfin, Radarr, Sonarr, Lidarr
- **Downloads:** SABnzbd, NZBGet, Deluge, qBittorrent, Transmission
- **Monitoring:** Portainer, Glances, Netdata, Prometheus
- **Home Automation:** Home Assistant, Node-RED
- **And 100+ more...**

See [Homepage docs](https://gethomepage.dev/latest/widgets/) for full widget list.

## Dependencies

- **Docker Socket:** Required for Docker widget
- **Service APIs:** Optional, for service-specific widgets

## Related Documentation

- [Official Homepage Docs](https://gethomepage.dev/)
- [Widget Documentation](https://gethomepage.dev/latest/widgets/)
- [GitHub Repository](https://github.com/gethomepage/homepage)
- [Configuration Examples](https://gethomepage.dev/latest/configs/)

## Notes

- Configuration is done via YAML files, not web UI
- Changes to YAML files require container restart to apply
- Docker widget auto-discovers running containers
- Can integrate with 100+ services for live monitoring
- Lightweight and fast - perfect for dashboard/home screen
- Previously configured with old IP (192.168.86.176) - updated to 192.168.86.249
- Consider adding authentication via reverse proxy if exposing externally
