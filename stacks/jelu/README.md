---
type: stack
service: jelu
category: productivity
vms: [103]
priority: medium
status: running
stack-type: single-container
has-secrets: false
external-access: true
ports: [11111]
backup-priority: high
created: 2025-01-27
updated: 2025-01-27
tags:
  - stack
  - vm-103
  - productivity
  - book-tracker
  - reading
  - single-container
  - no-secrets
  - external-access
aliases:
  - Jelu
  - Book Tracker
---

# Jelu Stack

**Service:** Jelu (Self-hosted Book Tracker)
**VM:** 103 (misc)
**Priority:** Medium - Personal book tracking
**Access:** http://192.168.86.249:11111
**Image:** `wabayang/jelu:latest`

## Overview

Jelu is a free, open-source, self-hosted book tracker designed to manage your read, reading, and to-read lists. Acting as a personal Goodreads alternative, it ensures data control and security by housing all data in a single-file database.

## Key Features

- **Track Reading History:** Record read books with dates and reviews
- **To-Read List:** Manage books you want to read
- **Currently Reading:** Track books in progress
- **Import/Export:** Import from Goodreads CSV or ISBN lists, export your data
- **Book Search:** Automatic book import via title, authors, or ISBN
- **Tags & Shelves:** Organize books with tags and custom shelves
- **Author Pages:** View author details and all books by author
- **Reviews:** Write and share reviews
- **Stats:** View reading statistics and history
- **Multi-User:** Support for multiple users (LDAP login, proxy authentication)
- **API:** RESTful API for integration with other tools
- **Embed Code:** Generate embed snippets for blogs/notes

## Configuration

### Secrets

None - Jelu manages user authentication internally via web UI.

### Volumes

**Data Storage (local VM, backed up to NAS daily):**
- `/home/evan/data/jelu/config` → `/config` - Application configuration
- `/home/evan/data/jelu/database` → `/database` - SQLite database (single-file)
- `/home/evan/data/jelu/files/images` → `/files/images` - Book cover images
- `/home/evan/data/jelu/files/imports` → `/files/imports` - Import files

**Note:** All data stored locally on VM for performance. Daily backups to NAS at `/mnt/video/backups/jelu/`.

### Environment Variables

**Configured in Pangolin (not .env file):**
- `PORT` - External port mapping (default: `11111`)
- `TZ` - Timezone (default: `America/Toronto`)
- `CONFIG_PATH` - Local config directory path
- `DATABASE_PATH` - Local database directory path
- `IMAGES_PATH` - Local images directory path
- `IMPORTS_PATH` - Local imports directory path

See `.env.example` for reference (actual values in Pangolin).

### Ports

- `11111` - Web interface (default Jelu port)

## Deployment

**Deployed via Portainer Git Integration:**

1. **Stack Configuration:**
   - Repository: `https://github.com/evanstern/infinity-node`
   - Compose path: `stacks/jelu/docker-compose.yml`
   - Environment variables: Configured in Pangolin

2. **Initial Setup:**
   ```bash
   # Create local directories on VM-103
   ssh evan@192.168.86.249
   mkdir -p /home/evan/data/jelu/{config,database,files/{images,imports}}
   chown -R evan:evan /home/evan/data/jelu
   ```

3. **Deploy via Portainer:**
   - Access Portainer on VM-103
   - Create Git stack pointing to `stacks/jelu/docker-compose.yml`
   - Configure environment variables in Pangolin
   - Deploy stack

## Initial Setup

1. **Access Web UI:** Navigate to http://192.168.86.249:11111
2. **Create Account:** First user becomes admin
3. **Import Books (Optional):**
   - Import from Goodreads CSV export
   - Import from ISBN list (one per line)
   - Manual import via search (title, author, ISBN)
4. **Configure Tags:** Set up tags for organization
5. **Add Books:** Start tracking your reading

## Usage

### Import from Goodreads

1. Export your Goodreads library as CSV
2. Upload CSV file via Jelu import interface
3. Books will be imported with metadata

### Add Books Manually

1. Click "Add Book" in web UI
2. Search by title, author, or ISBN
3. Select from search results
4. Add to appropriate list (to-read, reading, read)

### Track Reading Progress

1. Mark book as "Currently Reading"
2. Update progress as you read
3. Mark as "Finished" when complete
4. Add review and rating

### Organize with Tags

1. Create tags for categories (e.g., "fiction", "non-fiction", "sci-fi")
2. Apply tags to books
3. View books by tag
4. Create custom shelves using tags

## Backup

**Automated Daily Backups:**

- **Backup Script:** `/home/evan/scripts/backup-jelu.sh`
- **Schedule:** Daily at 2 AM (cron job)
- **Source:** `/home/evan/data/jelu/database/` (local VM)
- **Destination:** `/mnt/video/backups/jelu/` (NAS)
- **Retention:** 30 days
- **Logs:** `/var/log/jelu-backup.log`

**Manual Backup:**
```bash
# Run backup script manually
/home/evan/scripts/backup-jelu.sh

# Verify backup
ls -lh /mnt/video/backups/jelu/
```

**Restore:**
```bash
# Stop Jelu container
docker stop jelu

# Restore database from backup
cp /mnt/video/backups/jelu/jelu-backup-YYYYMMDD-HHMMSS.sqlite3 \
   /home/evan/data/jelu/database/db.sqlite3

# Start container
docker start jelu
```

## External Access

**Pangolin Tunnel:**
- **Subdomain:** `jelu.infinity-node.com` (configured in Pangolin)
- **Internal URL:** `http://localhost:11111` on VM-103
- **Access:** https://jelu.infinity-node.com

## API

Jelu provides a RESTful API for programmatic access:

- **Documentation:** Available at `/api/docs` when running
- **Authentication:** API tokens managed via web UI
- **Use Cases:** Integration with automation, mobile apps, other services

## Monitoring

```bash
# View logs
docker logs -f jelu

# Check container status
docker ps | grep jelu

# Check disk usage
du -sh /home/evan/data/jelu/
```

## Troubleshooting

**Service not accessible:**
- Check container is running: `docker ps | grep jelu`
- Check port 11111 not in use: `ss -tuln | grep 11111`
- Check logs: `docker logs jelu`

**Database issues:**
- Verify database file exists: `ls -lh /home/evan/data/jelu/database/`
- Check file permissions: `ls -la /home/evan/data/jelu/database/`
- Verify backup script runs: `tail /var/log/jelu-backup.log`

**Import failures:**
- Check import file format (CSV or ISBN list)
- Verify file permissions on `/home/evan/data/jelu/files/imports/`
- Check logs for specific error messages

## Related Documentation

- [[docs/ARCHITECTURE|Infrastructure Architecture]]
- [[docs/VM-CONFIGURATION|VM Configuration]]
- [[docs/adr/004-use-pangolin-for-external-access|ADR-004: Pangolin]]
- [[tasks/completed/IN-017-implement-vaultwarden-backup|IN-017: Vaultwarden Backup Pattern]]
- [Jelu GitHub](https://github.com/bayang/jelu)

## Related Services

- **[[stacks/calibre/README|Calibre]]** - Ebook library management (same VM)
- **[[stacks/audiobookshelf/README|Audiobookshelf]]** - Audiobook server (same VM)
