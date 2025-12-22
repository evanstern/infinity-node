---
type: stack
service: booklore
category: media
vms: [103]
priority: medium
status: running
stack-type: multi-container
has-secrets: true
external-access: false
ports: [6060]
backup-priority: medium
created: 2025-12-22
updated: 2025-12-22
tags:
  - stack
  - vm-103
  - media
  - books
  - ebooks
  - pdf
  - comics
  - multi-container
  - has-secrets
  - mariadb
  - opds
  - bookdrop
aliases:
  - BookLore
  - Digital Library
  - E-book Manager
---

# BookLore Stack

**Service:** BookLore (Digital Library)
**VM:** 103 (misc)
**Priority:** Medium - Digital book management
**Access:** http://booklore.local.infinity-node.win (port-free via Traefik) or http://192.168.1.103:6060 (direct)
**Image:** `ghcr.io/booklore-app/booklore:latest`

## Overview

BookLore is a self-hosted digital library for hosting, managing, and exploring books. It supports PDFs, eBooks, reading progress tracking, metadata management, and statistics. Features include multi-user support, OPDS feeds, and automatic book imports via BookDrop.

## Key Features

- **Book Management:** Organize PDFs, ePubs, and comics
- **Reading Progress:** Track reading progress across devices
- **Metadata:** Automatic metadata fetching and editing
- **OPDS Support:** Feed for e-reader apps
- **BookDrop:** Automatic import from watched folder
- **Multi-User:** Support for multiple users with separate libraries
- **Statistics:** Reading statistics and analytics
- **Web Reader:** Built-in web reader for books

## Architecture

Multi-container stack:
- **booklore:** Main application (Java/Spring Boot)
- **mariadb:** Database for metadata, users, and settings

## Configuration

### Secrets

**Required secrets stored in Vaultwarden:**

| Field | Location | Description |
|-------|----------|-------------|
| `db_password` | `infinity-node/vm-103-misc/booklore-secrets` | Database password for booklore user |
| `mysql_root_password` | `infinity-node/vm-103-misc/booklore-secrets` | MariaDB root password |

**Retrieve from Vaultwarden:**
```bash
export BW_SESSION=$(bw unlock --raw)
DB_PASSWORD=$(./scripts/secrets/get-vw-secret.sh "booklore-secrets" "vm-103-misc" "db_password")
MYSQL_ROOT_PASSWORD=$(./scripts/secrets/get-vw-secret.sh "booklore-secrets" "vm-103-misc" "mysql_root_password")
```

### Volumes

| Host Path | Container Path | Description |
|-----------|----------------|-------------|
| `/home/evan/data/booklore/data` | `/app/data` | Application data and cache |
| `/home/evan/booklore` | `/books` | Book library storage |
| `/mnt/video/Books/Bookdrop` | `/bookdrop` | Auto-import watched folder (NAS) |
| `/home/evan/data/booklore/mariadb/config` | `/config` | MariaDB configuration and data |

### Environment Variables

**Core Settings:**
- `TZ` - Timezone (default: `America/New_York`)
- `PUID` / `PGID` - User/Group IDs for file permissions (default: `1000`)

**Database Settings (secrets):**
- `DB_PASSWORD` - Database password for booklore user
- `MYSQL_ROOT_PASSWORD` - MariaDB root password

See `.env.example` for all configuration options.

## Deployment

### Via Portainer (Recommended)

1. In Portainer, go to Stacks -> Add stack -> Repository
2. Configure:
   - Name: `booklore`
   - Repository URL: Your git repository
   - Compose path: `stacks/booklore/docker-compose.yml`
3. Add environment variables from Vaultwarden secrets
4. Deploy stack

### Manual Deployment

```bash
cd stacks/booklore

# Retrieve secrets from Vaultwarden
export BW_SESSION=$(bw unlock --raw)
export DB_PASSWORD=$(./scripts/secrets/get-vw-secret.sh "booklore-secrets" "vm-103-misc" "db_password")
export MYSQL_ROOT_PASSWORD=$(./scripts/secrets/get-vw-secret.sh "booklore-secrets" "vm-103-misc" "mysql_root_password")

# Deploy (NOT recommended - use Portainer)
docker compose up -d
```

## Initial Setup

1. **Access Web UI:** Navigate to http://booklore.local.infinity-node.win
2. **Create Admin Account:** First user becomes admin
3. **Configure Libraries:**
   - Add `/books` as library location
   - Enable BookDrop watching for `/bookdrop`
4. **Import Books:** 
   - Upload through web UI
   - Copy files to BookDrop folder for automatic import

## Usage

### Web Interface

- **Library View:** Browse all books with cover images
- **Reading:** Built-in web reader with progress tracking
- **Metadata:** Edit book metadata, covers, and descriptions
- **Collections:** Organize books into collections
- **Search:** Full-text search across library

### BookDrop Auto-Import

1. Copy book files to `/mnt/video/Books/Bookdrop` on the NAS
2. BookLore automatically detects and imports new files
3. Files are processed, metadata is fetched, and books appear in library

### OPDS Feed

Connect e-reader apps (KOReader, Moon+ Reader, etc.) using:
- URL: `http://booklore.local.infinity-node.win/opds`
- Authentication: Your BookLore credentials

## Monitoring

```bash
# View application logs
docker logs -f booklore

# View database logs
docker logs -f booklore_mariadb

# Check container health
docker ps --format 'table {{.Names}}\t{{.Status}}' | grep booklore

# Check storage usage
du -sh /home/evan/data/booklore /home/evan/booklore
```

## Backup

**Critical data to backup:**
- `/home/evan/data/booklore/data` - Application data
- `/home/evan/data/booklore/mariadb/config` - Database files
- `/home/evan/booklore` - Book library (or ensure NAS backup covers this)

```bash
# Backup database
docker exec booklore_mariadb mariadb-dump -u root -p${MYSQL_ROOT_PASSWORD} booklore > booklore-backup.sql

# Backup application data
tar -czf booklore-data-backup.tar.gz /home/evan/data/booklore

# Restore database
docker exec -i booklore_mariadb mariadb -u root -p${MYSQL_ROOT_PASSWORD} booklore < booklore-backup.sql
```

## Troubleshooting

**Books not importing:**
- Check BookDrop folder permissions
- Verify file format is supported (PDF, ePub, etc.)
- Check application logs for errors
- Ensure BookDrop watching is enabled in settings

**Database connection errors:**
- Verify MariaDB container is healthy: `docker ps | grep booklore_mariadb`
- Check database credentials match between containers
- Review MariaDB logs: `docker logs booklore_mariadb`

**Web UI not accessible:**
- Verify container is running and healthy
- Check Traefik routing configuration
- Test direct port access: `curl http://192.168.1.103:6060`
- Review container logs for startup errors

**Slow performance:**
- Large libraries may need time for initial metadata processing
- Check available disk space
- Monitor memory usage

## Performance

**Metadata Processing:**
- CPU-intensive during initial import
- Fetches metadata from online sources
- May take time for large collections

**Storage:**
- Book files can be large (especially PDFs)
- Application data grows with library size
- Consider NAS storage for large libraries

## Security Considerations

- **Database Passwords:** Store in Vaultwarden, not in git
- **User Authentication:** Required for all access
- **File Access:** Container runs as specified UID/GID
- **Internal Access Only:** Not exposed externally by default

## Dependencies

- **MariaDB:** Required for metadata and user storage
- **Traefik:** For port-free local access
- **NAS Mount:** For BookDrop functionality

## Related Documentation

- [BookLore GitHub](https://github.com/booklore-app/BookLore)
- [[docs/SECRET-MANAGEMENT|Secret Management]]
- [[docs/runbooks/pihole-dns-management|Pi-hole DNS Management]]
- [[stacks/traefik/vm-103/README|Traefik (VM-103)]]

## Notes

- Multi-container stack (booklore, mariadb)
- BookDrop enables easy book imports from NAS
- OPDS feed for e-reader app integration
- Web reader with progress tracking
- First user becomes admin
- Consider regular backups of database and app data

