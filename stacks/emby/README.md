---
type: stack
service: emby
category: media
vms: [100]
priority: critical
status: running
stack-type: single-container
has-secrets: false
external-access: true
ports: [8096, 8920]
backup-priority: high
created: 2025-10-26
updated: 2025-10-26
tags:
  - stack
  - vm-100
  - media
  - streaming
  - critical
  - single-container
  - no-secrets
  - external-access
  - dlna
  - transcoding
  - household-service
aliases:
  - Emby
  - Media Server
  - Streaming Server
---

# Emby Stack

**Service:** Emby (Media Server)
**VM:** 100 (emby)
**Priority:** CRITICAL - Primary media streaming for household users
**Access:** http://192.168.86.172:8096
**Image:** `emby/embyserver:latest`

## Overview

Emby is the primary media server for the infinity-node infrastructure, providing streaming access to movies, TV shows, and other media content. This is a CRITICAL service as it directly affects household users' ability to watch media.

## Key Features

- **Media Streaming:** Stream movies, TV shows, music, and photos
- **Multi-Device Support:** Web, mobile apps (iOS/Android), smart TVs, streaming devices
- **Live TV & DVR:** Support for TV tuners and live TV recording (if configured)
- **Transcoding:** On-the-fly media transcoding for device compatibility
- **User Management:** Multiple users with individual libraries and watch history
- **Mobile Sync:** Download media for offline viewing
- **DLNA Support:** Broadcast to DLNA-compatible devices
- **Metadata:** Automatic metadata and artwork fetching
- **Parental Controls:** Content ratings and user restrictions

## Architecture

Single-container stack running in **host network mode** for optimal performance and device discovery.

**Why host network mode:**
- Better streaming performance (no NAT overhead)
- DLNA device discovery and casting
- Simplified port management
- Improved compatibility with client devices

## Configuration

### Secrets

None - Emby manages user authentication internally via web UI.

**Admin Account:**
- Created on first run through web UI
- No secrets stored in environment variables or compose file

### Volumes

**Media Library:**
- `/mnt/video/Video` → `/mnt/movies` - Media content (read-only recommended)

**Data Storage:**
- `${CONFIG_PATH}` → `/config` - Database, metadata, transcoding cache

### Environment Variables

- `TZ` - Timezone (default: `America/Toronto`)
- `CONFIG_PATH` - Path to Emby configuration and data storage
- `MEDIA_PATH` - Path to media library

### Ports

**Host Network Mode (default):**
- `8096` - HTTP web interface
- `8920` - HTTPS web interface (if SSL configured)
- `7359` - UDP for service auto-discovery
- `1900` - UDP for DLNA discovery

## Deployment

```bash
cd stacks/emby
cp .env.example .env
# Edit .env with correct paths for your environment
docker compose up -d
```

## Initial Setup

1. **Access Web UI:** Navigate to http://192.168.86.172:8096
2. **Create Admin Account:** First-time setup wizard
3. **Add Media Libraries:**
   - Click "Add Media Library"
   - Select content type (Movies, TV Shows, Music, etc.)
   - Point to `/mnt/movies` path
   - Configure metadata providers
4. **Configure Users:** Create user accounts for household members
5. **Set Up Devices:** Install Emby apps on client devices
6. **Configure Transcoding:** Set transcoding quality and hardware acceleration

## Hardware Transcoding (Optional)

Emby supports hardware-accelerated transcoding using NVIDIA GPUs to reduce CPU load and improve performance.

**Requirements:**
- NVIDIA GPU in the host
- NVIDIA drivers installed on host
- nvidia-docker runtime configured

**Enable GPU Transcoding:**

1. Uncomment the `deploy` section in docker-compose.yml:
   ```yaml
   deploy:
     resources:
       reservations:
         devices:
           - driver: nvidia
             count: all
             capabilities:
               - gpu
   ```

2. Restart the container:
   ```bash
   docker compose down
   docker compose up -d
   ```

3. Configure in Emby:
   - Settings → Transcoding
   - Enable hardware acceleration
   - Select NVIDIA NVENC encoder

**See:** [[tasks/backlog/IN-007-optimize-emby-transcoding|IN-007]] for optimization task

## Usage

### Web Access

- **Local:** http://192.168.86.172:8096
- **Remote:** Via Newt/Pangolin tunnel (if configured)

### Mobile Apps

- **iOS:** Emby for iPhone/iPad (App Store)
- **Android:** Emby for Android (Google Play)
- **Connection:** http://192.168.86.172:8096 (when on local network)

### TV Apps

- **Roku, Fire TV, Apple TV, Android TV:** Install Emby app
- **Smart TVs:** Samsung, LG (app availability varies)
- **DLNA:** Any DLNA-compatible device can access media

### Content Organization

**Recommended Structure:**
```
/mnt/video/Video/
├── Movies/
│   ├── Movie Title (Year)/
│   │   ├── Movie Title (Year).mkv
│   │   └── Movie Title (Year).nfo (optional metadata)
│   └── ...
├── TV Shows/
│   ├── Show Name/
│   │   ├── Season 01/
│   │   │   ├── Show Name - S01E01.mkv
│   │   │   └── ...
│   │   └── ...
│   └── ...
└── Music/
    └── ...
```

**Naming Conventions:**
- Movies: `Movie Title (Year).ext`
- TV Shows: `Show Name - S01E01.ext`
- Proper naming ensures accurate metadata matching

## Monitoring

```bash
# View logs
docker logs -f emby

# Check resource usage
docker stats emby

# Check running status
docker ps | grep emby
```

**Monitor for:**
- Transcoding queue (many transcodes = high CPU/GPU usage)
- Database integrity
- Disk space (transcoding cache can grow)
- Network bandwidth during peak streaming times

## Backup

**Critical data to backup:**
- `${CONFIG_PATH}/data/library.db` - Emby database (users, watch history, metadata)
- `${CONFIG_PATH}/metadata/` - Downloaded metadata and artwork
- `${CONFIG_PATH}/config/` - Server configuration

**Media library:**
- Media files should have separate backup strategy (large storage requirements)
- Emby database can be recreated, but watch history will be lost

```bash
# Backup Emby configuration
cd stacks/emby
tar -czf emby-backup-$(date +%Y%m%d).tar.gz config/

# Restore
docker compose down
tar -xzf emby-backup-YYYYMMDD.tar.gz
docker compose up -d
```

**Backup Schedule:** High priority - daily incremental, weekly full

## Troubleshooting

### Media Not Showing Up

**Check:**
1. Volume mount: `docker exec emby ls /mnt/movies`
2. File permissions: Emby user needs read access
3. Library scan status in web UI
4. Check logs for scan errors: `docker logs emby`

**Solution:**
- Trigger manual library scan in web UI
- Verify media files are in expected location
- Check file naming conventions

### Streaming Issues / Buffering

**Common Causes:**
- Network bandwidth insufficient
- Transcoding overload (CPU/GPU maxed)
- Disk I/O bottleneck
- Client device incompatibility

**Solutions:**
- Enable hardware transcoding (GPU)
- Reduce transcoding quality settings
- Check network speed to client
- Use direct play when possible (no transcoding)

### Cannot Access Remotely

**Check:**
- Newt tunnel is running: `docker ps | grep newt` (on VM 100)
- Pangolin server status
- External URL configuration in Emby settings
- Firewall rules if not using tunnel

### Transcoding Performance Poor

**Optimization:**
- Enable GPU hardware transcoding
- Configure tmpfs for transcoding temp directory (reduces disk I/O)
- Limit simultaneous transcoding sessions
- Pre-transcode commonly watched content

**See:** [[tasks/backlog/IN-007-optimize-emby-transcoding|IN-007]] for detailed optimization task

## Performance

**Resource Requirements:**
- **Idle:** ~200-300 MB RAM
- **Streaming (Direct Play):** Minimal CPU, ~500 MB RAM per stream
- **Transcoding (CPU):** High CPU usage, 1-2 GB RAM per stream
- **Transcoding (GPU):** Low CPU, GPU memory, ~500 MB RAM per stream

**Optimization Recommendations:**
1. Enable hardware transcoding (see above)
2. Use tmpfs for transcoding temp files (see IN-007)
3. Ensure sufficient RAM for metadata caching
4. Fast storage for media library (SSD for database, HDD for media acceptable)

## Security Considerations

- User authentication required for all access
- No secrets in environment variables
- Admin account created on first run (store credentials securely)
- Consider HTTPS configuration for external access
- Media library mounted with appropriate permissions
- External access via Pangolin tunnel (encrypted, identity-aware)

## Critical Service Notes

⚠️ **HOUSEHOLD IMPACT:** This service directly affects non-technical household users.

**Change Management:**
- Schedule maintenance during low-usage windows (3-6 AM)
- Test changes in non-production if possible
- Have rollback plan ready
- Monitor actively after changes
- Communicate downtime to users if needed

**Downtime Impact:**
- Users cannot stream media
- Watch history updates may be lost during downtime
- Live TV recording may fail (if configured)

## Dependencies

- **Media Storage:** NFS mount at `/mnt/video/Video/`
- **External Access:** Newt (Pangolin tunnel) for remote streaming (if configured)
- **Media Acquisition:** arr services (VM 102) populate the media library
- **Download Services:** downloads (VM 101) fetch media content

## Related Documentation

- [Official Emby Docs](https://emby.media/support/index.html)
- [Emby API Documentation](https://dev.emby.media/)
- [[tasks/backlog/IN-004-document-emby-service|IN-004]] - Detailed service documentation task
- [[tasks/backlog/IN-007-optimize-emby-transcoding|IN-007]] - Transcoding optimization task
- [[docs/agents/MEDIA|Media Stack Agent]] - Critical service management guidelines

## Notes

- Emby is proprietary software with optional Premiere subscription for advanced features
- Network mode 'host' for optimal performance and DLNA support
- Hardware transcoding significantly reduces CPU load for multiple streams
- Database backup is critical - contains all watch history and user data
- Consider Emby Premiere for features like: DVR, cloud sync, hardware transcoding for all codecs
- Alternative: Jellyfin (open-source fork of Emby, free features)
- Deployed via Portainer on VM 100
- Critical service - requires [[docs/agents/MEDIA|Media Stack Agent]] for changes
