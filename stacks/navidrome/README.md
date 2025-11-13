---
type: stack
service: navidrome
category: media
vms: [103]
priority: medium
status: running
stack-type: single-container
has-secrets: false
external-access: true
ports: [4533]
backup-priority: medium
created: 2025-10-26
updated: 2025-10-26
tags:
  - stack
  - vm-103
  - media
  - music
  - streaming
  - single-container
  - no-secrets
  - external-access
  - subsonic
  - mobile-app
aliases:
  - Navidrome
  - Music Server
---

# Navidrome Stack

**Service:** Navidrome (Music Streaming Server)
**VM:** 103 (misc)
**Priority:** Medium - Personal music streaming
**Access:** http://navidrome.local.infinity-node.com (port-free via Traefik) or http://navidrome.local.infinity-node.com:4533 (direct)
**Image:** `deluan/navidrome:latest`

## Overview

Navidrome is a modern music server and streamer compatible with Subsonic/Airsonic clients. It provides a web-based interface for streaming your personal music collection and supports various mobile apps.

## Key Features

- **Web Player:** Modern web-based music player
- **Subsonic API:** Compatible with many mobile apps (DSub, Play:Sub, Ultrasonic)
- **Smart Playlists:** Automatic playlist generation
- **Scrobbling:** Last.fm scrobbling support
- **Multi-User:** Multiple users with individual libraries and play history
- **Transcoding:** On-the-fly audio transcoding for streaming
- **Album Art:** Automatic cover art fetching
- **Search:** Fast full-text search
- **Lyrics:** Display synchronized lyrics if available

## Configuration

### Secrets

None - Navidrome manages user authentication internally via web UI.

### Volumes

- `/mnt/video/Music` → `/music` (read-only) - Music library
- `/home/evan/data/navidrome` → `/data` - Database, cache, and application data
- `/home/evan/data/navidrome/logs/navidrome.log` - Combined stdout/stderr log (created automatically)

### Environment Variables

- `ND_MUSICFOLDER` - Path to music library (default: `/music`)
- `ND_DATAFOLDER` - Path to data storage (default: `/data`)
- `ND_CONFIGFILE` - Configuration file path (default: `/data/navidrome.toml`)
- `ND_PORT` - Internal port (default: `4533`)
- `PORT` - External port mapping (default: `4533`)

### Advanced Configuration

Additional settings can be configured in `navidrome.toml` file in the DATA_PATH:

```toml
# Example navidrome.toml
LogLevel = "info"
ScanSchedule = "@every 24h"
SessionTimeout = "24h"
BaseURL = ""

# Last.fm Scrobbling
LastFM.Enabled = true
LastFM.ApiKey = "YOUR_API_KEY"
LastFM.Secret = "YOUR_SECRET"

# Spotify Integration
Spotify.ID = "YOUR_SPOTIFY_ID"
Spotify.Secret = "YOUR_SPOTIFY_SECRET"
```

See [Navidrome Configuration](https://www.navidrome.org/docs/usage/configuration-options/) for all options.

## Deployment

```bash
cd stacks/navidrome
cp .env.example .env
# Edit .env if needed to adjust paths
docker compose up -d
```

## Initial Setup

1. **Access Web UI:** Navigate to http://navidrome.local.infinity-node.com:4533
2. **Create Admin Account:** First user becomes admin
3. **Library Scan:** Automatic scan on first run
4. **Configure Settings:**
   - Set scan schedule
   - Configure transcoding quality
   - Enable Last.fm scrobbling (optional)
   - Set up Spotify integration (optional)

## Usage

### Web Player

- Access at http://navidrome.local.infinity-node.com:4533
- Browse by artist, album, genre, playlist
- Create and manage playlists
- Search for songs, albums, artists
- View play queue and history

### Mobile Apps

**Compatible Apps:**
- **iOS:** play:Sub, iSub
- **Android:** DSub, Ultrasonic, Substreamer
- **Desktop:** Sublime Music, Sonixd

**Connection Settings:**
- Server: http://navidrome.local.infinity-node.com:4533
- Username: Your Navidrome username
- Password: Your Navidrome password

### Scrobbling

Enable Last.fm scrobbling:
1. Get API key from Last.fm
2. Add to `navidrome.toml`:
   ```toml
   [LastFM]
   Enabled = true
   ApiKey = "YOUR_KEY"
   Secret = "YOUR_SECRET"
   ```
3. Link account in Navidrome settings

## Music Library Organization

**Supported Formats:**
- MP3, FLAC, M4A, OGG, OPUS, WMA, WAV

**Recommended Structure:**
```
/mnt/video/Music/
├── Artist Name/
│   ├── Album 1/
│   │   ├── 01 - Track.mp3
│   │   ├── 02 - Track.mp3
│   │   └── cover.jpg
│   └── Album 2/
│       └── ...
```

**Metadata:**
- Navidrome reads ID3 tags from files
- Ensure files have proper tags (artist, album, title, track number)
- Embedded album art recommended
- Navidrome can fetch missing artwork

## Monitoring

```bash
# View logs
docker logs -f navidrome

# Check library stats
# Access web UI → Settings → About

# Trigger manual scan
# Web UI → Settings → Rescan Library
```

## Backup

**Critical data to backup:**
- `/home/evan/data/navidrome/navidrome.db` - User data, playlists, play history

```bash
# Backup database
docker exec navidrome sqlite3 /data/navidrome.db ".backup '/data/backup.db'"
cp /home/evan/data/navidrome/backup.db ./navidrome-backup.db

# Restore
docker stop navidrome
cp ./navidrome-backup.db /home/evan/data/navidrome/navidrome.db
docker start navidrome
```

## Troubleshooting

**Music not showing up:**
- Verify music path is mounted: `docker exec navidrome ls /music`
- Check file permissions
- Trigger manual library scan
- Check logs for scan errors

**Slow streaming:**
- Enable transcoding for mobile
- Check network bandwidth
- Reduce transcoding bitrate in settings

**Album art missing:**
- Ensure cover art embedded in files or named cover.jpg/folder.jpg
- Enable automatic artwork fetching in settings
- Manually upload art in web UI

## Performance

**Library Scan:**
- First scan can take time for large libraries
- Subsequent scans are incremental and faster
- Configure scan schedule in navidrome.toml

**Transcoding:**
- CPU-intensive for high-quality streams
- Configure max transcoding bitrate based on server capacity
- Consider pre-transcoded copies for mobile

## Security Considerations

- User authentication required for all access
- No secrets in environment variables
- Music library mounted read-only
- User passwords hashed in database
- Consider HTTPS if exposing externally
- Last.fm API credentials in config file (if used)

## Dependencies

- **Media Storage:** NFS mount at `/mnt/video/Music/`
- **External Access:** Newt (Pangolin tunnel) for remote streaming

## Related Documentation

- [Official Navidrome Docs](https://www.navidrome.org/docs/)
- [Configuration Options](https://www.navidrome.org/docs/usage/configuration-options/)
- [Subsonic API](http://www.subsonic.org/pages/api.jsp)
- [Compatible Apps](https://www.navidrome.org/docs/overview/#apps)

## Notes

- Subsonic API compatible (works with many music apps)
- Lightweight and fast
- No transcoding overhead until streaming
- Deployed via Portainer (stored in /data/compose/12)
- Music library is read-only for safety
- Web UI runs on port 4533
- Supports multiple audio formats
- Can integrate with Spotify for metadata enhancement
