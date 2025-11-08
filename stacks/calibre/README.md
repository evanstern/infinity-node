# Calibre E-book Server and Calibre-Web

**Status**: ✅ Active
**VM**: 103 (misc) - `vm-103.local.infinity-node.com`
**Category**: Media - E-book Management
**Criticality**: Low (supporting service)

## Overview

Calibre is a comprehensive e-book management system deployed as a two-container stack:

- **Calibre Server**: Full-featured e-book library management with desktop GUI (VNC-based)
- **Calibre-Web**: Modern, lightweight web interface for browsing and reading books

This dual-container approach provides the power of Calibre's library management with the convenience of a user-friendly web interface.

### Key Features

- **Library Management**: Organize and catalog e-book collection with metadata
- **Format Support**: EPUB, PDF, MOBI, AZW3, and many other formats
- **Metadata Fetching**: Automatic metadata from Google Books, Amazon, and other sources
- **Web Reading**: Built-in web reader for EPUB and other formats
- **Format Conversion**: Convert between e-book formats
- **Mobile-Friendly**: Responsive web interface for phones and tablets
- **OPDS Support**: Connect e-readers and reading apps via OPDS feeds
- **Multi-User**: User authentication and personal reading progress tracking

## Architecture

### Two-Container Design

```
┌─────────────────────────────────────────────────┐
│                   VM 103                        │
│                                                 │
│  ┌─────────────┐           ┌────────────────┐  │
│  │   Calibre   │           │  Calibre-Web   │  │
│  │   Server    │           │                │  │
│  │             │           │                │  │
│  │  Port 8265  │           │   Port 8267    │  │
│  │  (GUI)      │           │   (Web UI)     │  │
│  │  Port 8266  │◄─────────►│                │  │
│  │  (Server)   │           │                │  │
│  └──────┬──────┘           └───────┬────────┘  │
│         │                          │            │
│         │    ┌──────────────┐      │            │
│         └───►│    Shared    │◄─────┘            │
│              │   Calibre    │                   │
│              │   Library    │                   │
│              └──────────────┘                   │
│                                                 │
│  Read-Only Sources:                            │
│  /mnt/video/Books (existing collection)        │
│  /mnt/video/Kindle (for future conversion)     │
└─────────────────────────────────────────────────┘
```

### When to Use Each Interface

**Use Calibre Server (VNC GUI) for:**
- Initial library setup and configuration
- Bulk importing books
- Format conversions
- Comprehensive metadata editing
- Plugin management
- Database maintenance
- Complex organizational tasks

**Use Calibre-Web for:**
- Daily book browsing and reading
- Mobile access
- Quick searches
- Reading progress tracking
- User account management
- Downloading books
- Casual book management

## Deployment

### Prerequisites

- VM 103 running and accessible
- NFS mounts configured:
  - `/mnt/video/Books` - Existing book collection
  - `/mnt/video/Kindle` - Kindle backups (future use)
  - `/mnt/nas/configs/calibre` - Calibre configuration
  - `/mnt/nas/configs/calibre-web` - Calibre-Web configuration
- Portainer configured on VM 103

### Initial Deployment

**1. Commit stack to repository**
```bash
git add stacks/calibre/
git commit -m "feat(stacks): add calibre e-book server stack"
git push
```

**2. Deploy via Portainer UI**
- Navigate to: Stacks → Add Stack → Git Repository
- **Repository**: `https://github.com/yourusername/infinity-node`
- **Reference**: `main`
- **Compose path**: `stacks/calibre/docker-compose.yml`
- **Enable GitOps**: ✅ Automatic updates (5 minutes)

**3. Add Environment Variables in Portainer**

Add each variable from `.env.example`:

```
TZ=America/New_York
PUID=1000
PGID=1000
CALIBRE_GUI_PORT=8265
CALIBRE_SERVER_PORT=8266
CALIBRE_WEB_PORT=8267
CONFIG_PATH=/mnt/nas/configs/calibre
CALIBRE_WEB_CONFIG_PATH=/mnt/nas/configs/calibre-web
LIBRARY_PATH=/mnt/nas/configs/calibre/library
BOOKS_PATH=/mnt/video/Books
KINDLE_PATH=/mnt/video/Kindle
CALIBRE_PASSWORD=
CALIBRE_CLI_ARGS=
CALIBRE_WEB_DOCKER_MODS=linuxserver/mods:universal-calibre
CALIBRE_MEMORY_LIMIT=2G
CALIBRE_WEB_MEMORY_LIMIT=1G
```

**4. Deploy Stack**
- Click "Deploy the stack"
- Wait for containers to start

**5. Verify Health**
```bash
ssh evan@vm-103.local.infinity-node.com
docker ps | grep calibre
docker logs calibre
docker logs calibre-web
```

## Initial Setup

### Step 1: Access Calibre Server GUI

1. Open browser to: `http://calibre.local.infinity-node.com:8265`
2. VNC interface will load (may take a moment on first start)
3. Calibre desktop application appears in browser

### Step 2: Create Calibre Library

1. Calibre will prompt for library location on first run
2. **IMPORTANT**: Set library location to `/library` (mounted volume)
3. Complete the welcome wizard
4. Go to **Preferences** → **Adding Books**
5. **Set to "Copy to library"** (not "Move") - preserves originals

### Step 3: Configure Metadata Sources

1. Go to **Preferences** → **Metadata download**
2. Enable recommended sources:
   - Google Books (usually best)
   - Amazon
   - Open Library
3. Set preferred metadata fields (Title, Author, Cover, etc.)

### Step 4: Test Import

Import 5-10 books to test:
1. Click **Add books** button
2. Navigate to `/books` (mounted `/mnt/video/Books`)
3. Select a few test books
4. Click **Open** to import
5. Verify books appear in library
6. Check that originals remain at `/books`
7. Review metadata quality

### Step 5: Configure Calibre-Web

1. Open browser to: `http://calibre.local.infinity-node.com:8267`
2. **First-time setup wizard:**
   - Database location: `/library/metadata.db`
   - Create admin account (username/password)
3. **Configure settings:**
   - Timezone: America/New_York
   - Enable EPUB reader
   - Configure user registration (if desired)
4. Verify test books appear in Calibre-Web interface

### Step 6: Bulk Import

Once testing successful:
1. Return to Calibre Server GUI
2. **Add books** → Select all from `/books`
3. Start import (may take time for large collections)
4. Monitor progress in Calibre
5. Can run in background - close browser, import continues

### Step 7: Verify Import

1. Check import statistics in Calibre
2. Browse books in Calibre-Web
3. Test reading interface with EPUB
4. Review books with missing metadata

## Usage Guide

### Adding New Books

**Via Calibre Server:**
1. Access Calibre GUI at port 8265
2. Click **Add books**
3. Select files to import
4. Calibre copies books to library and fetches metadata

**Via Calibre-Web:**
1. Access Calibre-Web at port 8267
2. Click **Upload** (if enabled)
3. Select file to upload
4. Book added to library

### Reading Books

1. Access Calibre-Web at port 8267
2. Browse or search for book
3. Click book cover
4. Click **Read in browser** (EPUB) or **Download**
5. Reading progress automatically saved

### Editing Metadata

**Calibre Server (recommended):**
1. Select book in library
2. Click **Edit metadata** button
3. Modify fields, download cover, etc.
4. Save changes

**Calibre-Web (basic editing):**
1. Click book → **Edit metadata**
2. Modify available fields
3. Save changes

### Format Conversion

**Calibre Server only:**
1. Select book
2. Click **Convert books**
3. Choose output format
4. Configure conversion options
5. Start conversion
6. Converted format added to book entry

### Handling Duplicates

Calibre detects potential duplicates during import:
1. Review duplicate candidates
2. Choose to:
   - Skip duplicate
   - Add as duplicate (if different edition)
   - Merge metadata
3. Calibre prevents exact file duplicates

### User Management (Calibre-Web)

1. Admin → **User Management**
2. Create new users
3. Set permissions per user:
   - Download books
   - Upload books
   - Edit metadata
   - Delete books
4. Users have individual reading progress

## Maintenance

### Backup

**What to backup:**
- `/mnt/nas/configs/calibre/library` - Calibre library (database + books)
- `/mnt/nas/configs/calibre-web` - Calibre-Web configuration

**How to backup:**
```bash
ssh evan@vm-103.local.infinity-node.com
docker stop calibre calibre-web

# Backup Calibre library
tar czf calibre-library-backup-$(date +%Y%m%d).tar.gz \
  /mnt/nas/configs/calibre/library

# Backup Calibre-Web config
tar czf calibre-web-config-backup-$(date +%Y%m%d).tar.gz \
  /mnt/nas/configs/calibre-web

docker start calibre calibre-web
```

### Updates

**Automatic (via Watchtower):**
- LinuxServer.io images updated automatically
- Watchtower pulls new images and recreates containers

**Manual:**
```bash
ssh evan@vm-103.local.infinity-node.com
docker compose -f /path/to/docker-compose.yml pull
docker compose -f /path/to/docker-compose.yml up -d
```

**Via Portainer:**
- Stacks → calibre → "Pull and redeploy"

### Database Maintenance

**Check library integrity:**
1. Open Calibre Server GUI
2. Preferences → **Check library**
3. Calibre scans for issues and offers repairs

**Rebuild metadata:**
If metadata database corrupted:
1. Stop Calibre-Web container
2. In Calibre: Right-click book → **Metadata** → **Download metadata**
3. Calibre rebuilds metadata
4. Restart Calibre-Web

### Resource Monitoring

```bash
# Check container resource usage
docker stats calibre calibre-web

# Check logs for errors
docker logs calibre --tail 100
docker logs calibre-web --tail 100

# Check disk usage
du -sh /mnt/nas/configs/calibre/library
```

## Troubleshooting

### Calibre GUI Not Loading

**Symptoms:** VNC interface doesn't appear at port 8265

**Solutions:**
```bash
# Check container running
docker ps | grep calibre

# Check logs for errors
docker logs calibre

# Restart container
docker restart calibre

# Wait 30-60 seconds for VNC to initialize
# Browser refresh after waiting
```

### Calibre-Web Can't Find Database

**Symptoms:** "Database not found" error in Calibre-Web

**Solutions:**
1. Verify library created in Calibre first
2. Check database path in Calibre-Web: `/library/metadata.db`
3. Verify both containers share same `LIBRARY_PATH` volume
4. Check file permissions:
```bash
ssh evan@vm-103.local.infinity-node.com
ls -la /mnt/nas/configs/calibre/library/metadata.db
# Should be owned by PUID:PGID (1000:1000)
```

### Books Not Appearing in Calibre-Web

**Symptoms:** Books visible in Calibre but not Calibre-Web

**Solutions:**
1. Refresh Calibre-Web browser
2. Check that books actually imported (not in "Jobs" queue)
3. Restart Calibre-Web:
```bash
docker restart calibre-web
```
4. Verify no database lock:
```bash
ssh evan@vm-103.local.infinity-node.com
ls -la /mnt/nas/configs/calibre/library/*.lock
# Delete any .lock files if present (with containers stopped)
```

### Permission Errors on NFS

**Symptoms:** "Permission denied" when importing books

**Solutions:**
1. Verify PUID/PGID set to 1000:1000
2. Check NFS mount permissions:
```bash
ssh evan@vm-103.local.infinity-node.com
ls -la /mnt/video/Books
ls -la /mnt/nas/configs/calibre
```
3. Ensure NFS mounted with correct options (see VM configuration)
4. Test write access:
```bash
touch /mnt/nas/configs/calibre/test-write
rm /mnt/nas/configs/calibre/test-write
```

### Metadata Not Downloading

**Symptoms:** Books imported with minimal metadata

**Solutions:**
1. Check internet connectivity from container:
```bash
docker exec calibre ping -c 3 google.com
```
2. Verify metadata sources enabled (Preferences → Metadata download)
3. Try manual metadata download:
   - Select book → Right-click → Download metadata
4. Check logs for metadata errors:
```bash
docker logs calibre | grep -i metadata
```

### Container Restart Issues

**Symptoms:** Containers don't survive restart

**Solutions:**
1. Check restart policy in docker-compose.yml (should be `unless-stopped`)
2. Verify Portainer shows "always restart" or "unless-stopped"
3. Check container logs for startup errors
4. Verify NFS mounts available before containers start

### High Memory Usage

**Symptoms:** Calibre using excessive RAM

**Solutions:**
1. Review memory limits in docker-compose.yml
2. Adjust limits via Portainer environment variables:
   - `CALIBRE_MEMORY_LIMIT=2G` (increase if needed)
   - `CALIBRE_WEB_MEMORY_LIMIT=1G`
3. Calibre GUI can be memory-intensive during bulk operations
4. Close Calibre GUI browser tab when not actively using
5. Calibre-Web is lightweight - should rarely need more than 1GB

### Slow Performance

**Symptoms:** Slow book browsing or importing

**Possible causes:**
1. **NFS I/O**: Large library on NFS can be slow
2. **Metadata downloads**: Fetching metadata takes time
3. **Large collection**: Many thousands of books

**Solutions:**
1. Be patient during initial import (can take hours)
2. Import in batches if needed
3. For persistent issues, consider moving database to local storage:
   - Keep books on NFS: `/mnt/nas/configs/calibre/library`
   - Move `metadata.db` to local VM storage
   - Symlink from library directory
4. Disable automatic metadata download for bulk imports
5. Monitor NFS performance: `nfsstat -m`

## Configuration Details

### Port Reference

| Service | Port | Purpose | URL |
|---------|------|---------|-----|
| Calibre GUI | 8265 | VNC desktop interface | http://calibre.local.infinity-node.com:8265 |
| Calibre Server | 8266 | Internal server (content) | http://calibre.local.infinity-node.com:8266 |
| Calibre-Web | 8267 | Web reading interface | http://calibre.local.infinity-node.com:8267 |

### Volume Mounts

| Container Path | Host Path | Purpose | Mode |
|---------------|-----------|---------|------|
| /config | /mnt/nas/configs/calibre | Calibre server config | rw |
| /config | /mnt/nas/configs/calibre-web | Calibre-Web config | rw |
| /library | /mnt/nas/configs/calibre/library | Shared Calibre library | rw |
| /books | /mnt/video/Books | Source books for import | ro |
| /kindle | /mnt/video/Kindle | Kindle backups (future) | ro |

### Environment Variables

See `.env.example` for full list with descriptions.

**Required:**
- `TZ` - Timezone
- `PUID` / `PGID` - User/group IDs
- `*_PORT` - Port assignments
- `*_PATH` - Volume paths

**Optional:**
- `CALIBRE_PASSWORD` - VNC password protection
- `CALIBRE_CLI_ARGS` - Advanced Calibre arguments
- `CALIBRE_WEB_DOCKER_MODS` - Calibre tools in Calibre-Web

### Resource Limits

Default limits (adjust via environment variables):
- **Calibre**: 2GB RAM (GUI is memory-intensive)
- **Calibre-Web**: 1GB RAM (lightweight)

## Security Considerations

### Access Control

**Calibre Server:**
- Exposed only on local network (192.168.86.0/24)
- Optional: Set `CALIBRE_PASSWORD` for VNC protection
- Not recommended for external access (VNC is not secure)

**Calibre-Web:**
- User authentication required
- Admin creates user accounts
- Can be exposed externally via Pangolin tunnel (future)

### External Access

**Current:** Local network only

**Future (out of scope for IN-041):**
- Add Pangolin tunnel for secure external access to Calibre-Web
- Do NOT expose Calibre Server GUI externally
- Use Calibre-Web for all external access
- See task IN-042 for external access configuration

## Related Services

- **[[stacks/audiobookshelf/README|Audiobookshelf]]** - Audiobook and podcast server (same VM)
- **[[stacks/navidrome/README|Navidrome]]** - Music streaming server (same VM)
- **[[stacks/emby/README|Emby]]** - Video streaming (VM 100)

## Related Documentation

- [[docs/ARCHITECTURE|Infrastructure Architecture]]
- [[docs/agents/DOCKER|Docker Agent Specification]]
- [[tasks/completed/IN-041-deploy-calibre-ebook-server|Task IN-041]]
- [Calibre Manual](https://manual.calibre-ebook.com/)
- [Calibre-Web Wiki](https://github.com/janeczku/calibre-web/wiki)
- [LinuxServer.io Calibre Image](https://docs.linuxserver.io/images/docker-calibre/)
- [LinuxServer.io Calibre-Web Image](https://docs.linuxserver.io/images/docker-calibre-web/)

## Future Enhancements

Potential improvements (create tasks as needed):
- **Kindle Conversion** (IN-042): Convert Kindle backups to open formats
- **External Access**: Add Pangolin tunnel for remote reading
- **OPDS Configuration**: Connect e-readers and reading apps
- **Advanced Plugins**: Explore Calibre plugin ecosystem
- **Automated Backups**: Scheduled library backups
- **Metadata Standardization**: Comprehensive metadata cleanup
- **Custom Collections**: Organize books by custom categories

## Notes

**Deployment Date**: 2025-11-02
**Deployed By**: Docker Agent (Task IN-041)
**Initial Import**: 88 books from `/mnt/video/Books`
**Kindle Backups**: Available at `/mnt/video/Kindle` (not yet processed)
