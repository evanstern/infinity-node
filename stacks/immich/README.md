---
type: stack
service: immich
category: media
vms: [103]
priority: high
status: running
stack-type: multi-container
has-secrets: true
external-access: true
ports: [2283]
backup-priority: critical
created: 2025-10-26
updated: 2025-10-26
tags:
  - stack
  - vm-103
  - media
  - photos
  - videos
  - ai
  - ml
  - face-recognition
  - object-detection
  - multi-container
  - has-secrets
  - postgresql
  - redis
  - mobile-app
  - external-access
  - raw-support
aliases:
  - Immich
  - Photo Library
---

# Immich Stack

**Service:** Immich (Photo and Video Management)
**VM:** 103 (misc)
**Priority:** High - Personal photo library
**Access:** http://immich.local.infinity-node.com:2283
**Image:** `ghcr.io/immich-app/immich-server:release`

## Overview

Immich is a high-performance self-hosted photo and video management solution. It provides features similar to Google Photos, including automatic backup, face recognition, object detection, and AI-powered search.

## Key Features

- **Automatic Backup:** Mobile apps for iOS/Android
- **Machine Learning:** Face recognition, object detection
- **Smart Search:** Search by faces, objects, locations
- **Photo Albums:** Organize and share photo collections
- **Timeline View:** Chronological photo browsing
- **Map View:** Browse photos by location
- **Video Support:** Upload and transcode videos
- **RAW Photo Support:** Professional photo format support
- **Live Photos:** iOS live photo support
- **Partner Sharing:** Share libraries with family members

## Architecture

Multi-container stack:
- **immich-server:** Main application server
- **immich-machine-learning:** AI/ML models for face/object recognition
- **redis:** Caching and job queuing
- **database (PostgreSQL):** Metadata and vector storage (pgvecto-rs)

## Configuration

### Secrets

**Required secrets stored in Vaultwarden:**

1. **DB_PASSWORD** - PostgreSQL database password
   - Location: `infinity-node/vm-103-misc/immich-secrets`
   - Field: `db_password`
   - Current value: `chem7gallo4tolerant6goofy`

**Store in Vaultwarden:**
```bash
export BW_SESSION=$(bw unlock --raw)

./scripts/create-secret.sh "immich-secrets" "vm-103-misc" "" \
  '{"service":"immich","vm":"103","db_password":"chem7gallo4tolerant6goofy"}'
```

**Retrieve from Vaultwarden:**
```bash
export BW_SESSION=$(bw unlock --raw)
DB_PASSWORD=$(bw get item immich-secrets --field db_password)
```

### Volumes

**Photo Storage:**
- `/mnt/video/Photos/` → `/usr/src/app/upload` - Photo and video uploads

**Data Storage:**
- `./postgres` → `/var/lib/postgresql/data` - PostgreSQL database
- `model-cache` (named volume) - Machine learning models

### Environment Variables

**Configuration:**
- `SERVER_PORT` - Web interface port (default: `2283`)
- `UPLOAD_LOCATION` - Photo storage path
- `DB_DATA_LOCATION` - Database storage path
- `TZ` - Timezone (default: `America/New_York`)
- `IMMICH_VERSION` - Version to use (default: `release`)

**Hardware Acceleration:**
- `TRANSCODING_HARDWARE` - Video transcoding acceleration (default: `cpu`)
  - Options: `cpu`, `nvenc` (NVIDIA), `quicksync` (Intel), `vaapi`, `rkmpp`

**Database:**
- `DB_PASSWORD` - PostgreSQL password (secret)
- `DB_USERNAME` - PostgreSQL user (default: `postgres`)
- `DB_DATABASE_NAME` - Database name (default: `immich`)

## Deployment

```bash
cd stacks/immich
cp .env.example .env

# Retrieve secrets from Vaultwarden
export BW_SESSION=$(bw unlock --raw)
DB_PASSWORD=$(bw get item immich-secrets --field db_password)

# Update .env file with actual DB_PASSWORD
# Or use deployment script

docker compose up -d
```

## Initial Setup

1. **Access Web UI:** Navigate to http://immich.local.infinity-node.com:2283
2. **Create Admin Account:** First user becomes admin
3. **Configure Settings:**
   - Enable machine learning features
   - Configure face recognition
   - Set up email notifications (optional)
4. **Install Mobile App:**
   - iOS: Download from App Store
   - Android: Download from Play Store
5. **Connect App to Server:**
   - Server URL: http://immich.local.infinity-node.com:2283
   - Login with web UI credentials
6. **Enable Auto-Backup:**
   - Configure backup settings in mobile app
   - Photos automatically uploaded in background

## Usage

### Web Interface

- **Timeline:** Browse all photos chronologically
- **Search:** Search by faces, objects, places, dates
- **Albums:** Create and organize photo albums
- **Map:** View photos on map by location
- **Sharing:** Share albums with other users
- **Archive:** Hide photos from timeline

### Mobile App

- **Auto Backup:** Automatic upload of camera photos
- **Background Upload:** Uploads even when app closed
- **Selective Backup:** Choose which albums to backup
- **Download:** Download photos to device
- **Share:** Share photos and albums

## Machine Learning Features

**Face Recognition:**
- Automatic face detection
- Group photos by person
- Name people for smart search

**Object Detection:**
- Identify objects in photos
- Search by object type (e.g., "dog", "car")

**Smart Search:**
- Natural language search
- Combine search criteria
- Search by color, location, date

## Monitoring

```bash
# View server logs
docker logs -f immich_server

# View ML logs
docker logs -f immich_machine_learning

# View database logs
docker logs -f immich_postgres

# Check storage usage
du -sh /mnt/video/Photos/
docker exec immich_postgres psql -U postgres -d immich -c "SELECT pg_size_pretty(pg_database_size('immich'));"
```

## Backup

**Critical data to backup:**
- `/mnt/video/Photos/` - All uploaded photos and videos
- `./postgres/` - Database (metadata, faces, albums, users)
- `model-cache` volume - ML models (can be re-downloaded)

```bash
# Backup database
docker exec immich_postgres pg_dump -U postgres immich > immich-backup.sql

# Backup photos
tar -czf photos-backup.tar.gz /mnt/video/Photos/

# Restore database
docker exec -i immich_postgres psql -U postgres immich < immich-backup.sql
```

## Troubleshooting

**Photos not uploading from mobile:**
- Check network connectivity
- Verify server URL is correct
- Check upload permissions in app
- Review server logs for errors

**Face recognition not working:**
- Ensure immich-machine-learning container is running
- Check ML container logs
- Verify model-cache volume is accessible
- Face detection runs as background job (may take time)

**Database connection errors:**
- Verify DB_PASSWORD is correct
- Check PostgreSQL container is healthy
- Review database logs

**Out of storage:**
- Check available space: `df -h /mnt/video/`
- Clean up old database backups
- Consider moving uploads to larger storage

## Performance

**Hardware Requirements:**
- CPU: Multi-core recommended for ML/transcoding
- RAM: Minimum 4GB, 8GB+ recommended with ML
- Storage: Large capacity for photos (NFS mount)

**Optimization:**
- Enable hardware transcoding if GPU available
- Adjust ML model quality vs. performance
- Configure job concurrency in settings
- Use SSD for database storage (PostgreSQL)

## Security Considerations

- **Database Password:** Stored in Vaultwarden, not committed to git
- **User Authentication:** Required for all access
- **API Keys:** Generated per user for mobile apps
- **File Permissions:** Upload directory should be writable by container
- **External Access:** Consider HTTPS if exposing externally
- **Sharing:** Control sharing permissions per album

## Dependencies

- **Media Storage:** NFS mount at `/mnt/video/Photos/`
- **PostgreSQL:** Specialized vector database (pgvecto-rs)
- **Redis:** Required for job queuing
- **ML Models:** Downloaded automatically on first run

## Related Documentation

- [Official Immich Docs](https://immich.app/docs/overview/introduction)
- [Environment Variables](https://immich.app/docs/install/environment-variables)
- [Hardware Transcoding](https://immich.app/docs/features/hardware-transcoding)
- [Mobile Apps](https://immich.app/docs/features/mobile-app)
- [GitHub Repository](https://github.com/immich-app/immich)

## Notes

- Multi-container stack (server, ML, redis, postgres)
- Machine learning features require significant resources
- Photos stored in `/mnt/video/Photos/` directory
- Database uses pgvecto-rs for vector similarity search (face matching)
- Redis used for background job processing
- Hardware transcoding can significantly improve video performance
- Mobile apps available for iOS and Android
- Active development - updates frequently
- Web UI runs on port 2283
- Consider GPU passthrough for hardware acceleration
- Vector database enables fast similarity search for faces
