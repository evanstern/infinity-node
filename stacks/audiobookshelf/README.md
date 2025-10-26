# Audiobookshelf Stack

**Service:** Audiobookshelf (Audiobook and Podcast Server)
**VM:** 103 (misc)
**Priority:** Medium - Media library management
**Access:** http://192.168.86.249:13378
**Image:** `ghcr.io/advplyr/audiobookshelf:latest`

## Overview

Audiobookshelf is a self-hosted audiobook and podcast server. It provides a modern web interface for organizing, streaming, and managing audiobook and podcast libraries.

## Key Features

- **Audiobook Management:** Organize and stream audiobook collections
- **Podcast Support:** Subscribe to and manage podcast feeds
- **Ebook Library:** Store and read ebooks
- **Progress Tracking:** Track listening/reading progress across devices
- **User Management:** Multi-user support with individual libraries
- **Mobile Apps:** iOS and Android apps available
- **Metadata:** Automatic metadata fetching and cover art
- **Chapter Support:** Navigate by chapters in audiobooks

## Configuration

### Secrets

None - Audiobookshelf manages user authentication internally via web UI.

### Volumes

**Media Libraries:**
- `/mnt/video/Audio/Books` → `/audiobooks` - Audiobook collection
- `/mnt/video/Audio/Podcasts` → `/podcasts` - Podcast downloads
- `/mnt/video/Books` → `/books` - Ebook library

**Data Storage:**
- `./config/audiobookshelf/config` → `/config` - Application configuration
- `./config/audiobookshelf/metadata` → `/metadata` - Metadata cache and cover art

### Environment Variables

- `TZ` - Timezone (default: `America/Toronto`)
- `PORT` - Web interface port (default: `13378`)
- Media and config paths (see `.env.example`)

## Deployment

```bash
cd stacks/audiobookshelf
cp .env.example .env
# Edit .env if needed to adjust paths
docker compose up -d
```

## Initial Setup

1. **Access Web UI:** Navigate to http://192.168.86.249:13378
2. **Create Admin Account:** First user becomes admin
3. **Configure Libraries:**
   - Add audiobook library pointing to `/audiobooks`
   - Add podcast library pointing to `/podcasts`
   - Add ebook library pointing to `/books`
4. **Scan Libraries:** Trigger initial library scan
5. **Configure Metadata:** Set up metadata providers (Google Books, Audible, iTunes)

## Usage

### Add Audiobooks

1. Place audiobook files in `/mnt/video/Audio/Books/`
2. Organize by author/title or use existing structure
3. Trigger library scan in web UI
4. Metadata will be fetched automatically

### Manage Podcasts

1. Add podcast feeds via web UI
2. Configure auto-download settings
3. Episodes downloaded to `/mnt/video/Audio/Podcasts/`

### Mobile Access

- Download Audiobookshelf app (iOS/Android)
- Connect to server: http://192.168.86.249:13378
- Login with web UI credentials
- Sync progress across devices

## Monitoring

```bash
# View logs
docker logs -f audiobookshelf

# Check library stats
# Access web UI → Settings → Statistics
```

## Backup

**Critical data to backup:**
- `./config/audiobookshelf/config/` - User data, library configuration
- `./config/audiobookshelf/metadata/` - Metadata cache and cover art

```bash
# Backup configuration
tar -czf audiobookshelf-backup.tar.gz ./config/audiobookshelf/

# Restore
tar -xzf audiobookshelf-backup.tar.gz -C ./
```

## Troubleshooting

**Library not scanning:**
- Check volume mount permissions
- Verify media path exists: `ls -la /mnt/video/Audio/Books`
- Check logs for permission errors

**Metadata not fetching:**
- Verify internet connectivity
- Check metadata provider settings
- Manual metadata edit available in web UI

**Slow streaming:**
- Check network bandwidth
- Consider enabling transcoding for mobile
- Check Docker resource limits

## Media Organization Tips

**Audiobooks:**
```
/audiobooks/
├── Author Name/
│   └── Book Title/
│       ├── Chapter 01.m4b
│       ├── Chapter 02.m4b
│       └── cover.jpg
```

**Podcasts:**
- Managed automatically by Audiobookshelf
- Episodes auto-downloaded and organized

**Supported Formats:**
- Audio: M4B, M4A, MP3, OGG, OPUS, FLAC, AAC
- Books: EPUB, PDF, MOBI, AZW3, CBR, CBZ

## Security Considerations

- User authentication required for access
- No secrets required for basic operation
- External access via Pangolin tunnel (see newt stack)
- Consider HTTPS if exposing externally
- User passwords stored securely within application

## Dependencies

- **Media Storage:** NFS mount at `/mnt/video/`
- **External Access:** Newt (Pangolin tunnel) for remote access

## Related Documentation

- [Official Audiobookshelf Docs](https://www.audiobookshelf.org/docs)
- [GitHub Repository](https://github.com/advplyr/audiobookshelf)
- [Mobile Apps](https://www.audiobookshelf.org/install)

## Notes

- Web UI runs on port 13378
- Mobile apps provide offline playback
- Supports multiple users with separate libraries and progress
- Metadata can be manually edited if auto-fetch fails
- Originally deployed with newt in same compose file (now separated)
- External access via https://pangolin.infinity-node.com (newt tunnel)
