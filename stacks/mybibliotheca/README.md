---
type: stack
service: mybibliotheca
category: productivity
vms: [103]
priority: medium
status: running
stack-type: single-container
has-secrets: true
external-access: true
ports: [5054]
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
  - has-secrets
  - external-access
aliases:
  - MyBibliotheca
  - Book Tracker
---

# MyBibliotheca Stack

**Service:** MyBibliotheca (Self-hosted Book Tracker)
**VM:** 103 (misc)
**Priority:** Medium - Personal book tracking
**Access:** http://192.168.86.249:5054
**Image:** `pickles4evaaaa/mybibliotheca:1.1.1`

## Overview

MyBibliotheca is a comprehensive self-hosted personal library management system and reading tracker built with Flask and SQLAlchemy. It serves as an open-source alternative to Goodreads, StoryGraph, and similar services, offering complete control over your reading data with multi-user support and advanced privacy controls.

## Key Features

- **Book Management:** Add books via ISBN lookup with automatic metadata fetching
- **Reading Tracking:** Track reading progress with percentage tracking, daily logs, and reading streaks
- **Library Organization:** Full-text search, advanced filtering, category and publisher management
- **Multi-User Support:** Secure user authentication with isolated data per user
- **Reading Analytics:** Monthly wrap-up image generation, reading statistics
- **Import/Export:** Bulk import via CSV files, export your data
- **Privacy Controls:** Granular privacy controls for sharing reading activity
- **Community Features:** Optional sharing and social features

## Configuration

### Secrets

**Stored in Vaultwarden:** `vm-103-misc/mybibliotheca-secrets`

| Secret | Vaultwarden Location | Environment Variable | Purpose |
|--------|---------------------|---------------------|---------|
| SECRET_KEY | `vm-103-misc/mybibliotheca-secrets` (custom field) | `SECRET_KEY` | Flask session encryption key |
| SECURITY_PASSWORD_SALT | `vm-103-misc/mybibliotheca-secrets` (custom field) | `SECURITY_PASSWORD_SALT` | Password hashing salt |

**Retrieving secrets:**
```bash
export BW_SESSION=$(cat ~/.bw-session)
SECRET_KEY=$(bw get item "mybibliotheca-secrets" | jq -r '.fields[] | select(.name=="SECRET_KEY") | .value')
SECURITY_PASSWORD_SALT=$(bw get item "mybibliotheca-secrets" | jq -r '.fields[] | select(.name=="SECURITY_PASSWORD_SALT") | .value')
```

### Volumes

**Data Storage (local VM, backed up to NAS daily):**
- `/home/evan/data/mybibliotheca/data` → `/app/data` - SQLite database, configuration, and application data

**Note:** All data stored locally on VM for performance. Daily backups to NAS at `/mnt/video/backups/mybibliotheca/`.

### Environment Variables

**Configured in Portainer (not .env file):**

**Required:**
- `SECRET_KEY` - Flask session encryption key (from Vaultwarden)
- `SECURITY_PASSWORD_SALT` - Password hashing salt (from Vaultwarden)

**Application Settings:**
- `PORT` - External port mapping (default: `5054`)
- `TIMEZONE` - Timezone (default: `America/Toronto`)
- `WORKERS` - Number of worker processes (default: `4`)
- `READING_STREAK_OFFSET` - Reading streak offset days (default: `0`)

**Optional:**
- `FORCE_HTTPS` - Force HTTPS (default: `false`)
- `SECURE_COOKIES` - Use secure cookies (default: `false`)
- `LOG_LEVEL` - Logging level (default: `INFO`)

See `.env.example` for complete list (pulled from official repo).

### Ports

- `5054` - Web interface (default MyBibliotheca port)

## Deployment

**Deployed via Portainer Git Integration:**

1. **Stack Configuration:**
   - Repository: `https://github.com/evanstern/infinity-node`
   - Compose path: `stacks/mybibliotheca/docker-compose.yml`
   - Environment variables: Configured in Portainer (retrieve secrets from Vaultwarden)

2. **Initial Setup:**
   ```bash
   # Create local directories on VM-103
   ssh evan@192.168.86.249
   mkdir -p /home/evan/data/mybibliotheca/data
   chown -R evan:evan /home/evan/data/mybibliotheca
   ```

3. **Deploy via Portainer:**
   - Access Portainer on VM-103
   - Create Git stack pointing to `stacks/mybibliotheca/docker-compose.yml`
   - Configure environment variables in Portainer:
     - Retrieve `SECRET_KEY` and `SECURITY_PASSWORD_SALT` from Vaultwarden
     - Set `PORT`, `TIMEZONE`, `WORKERS`, `DATA_PATH`
   - Deploy stack

## Initial Setup

1. **Access Web UI:** Navigate to http://192.168.86.249:5054
2. **Create Admin Account:** First user becomes admin
3. **Add Books:**
   - Import from CSV (Goodreads export)
   - Add via ISBN lookup
   - Manual entry
4. **Configure Settings:** Set up reading preferences, privacy controls
5. **Start Tracking:** Begin logging reading activity

## Usage

### Import from Goodreads

1. Export your Goodreads library as CSV
2. Upload CSV file via MyBibliotheca import interface
3. Books will be imported with metadata

### Add Books via ISBN

1. Click "Add Book" in web UI
2. Enter ISBN or search by title/author
3. Metadata fetched automatically from Google Books API
4. Add to library

### Track Reading Progress

1. Mark book as "Currently Reading"
2. Log daily reading sessions with page counts
3. Track reading streak
4. Mark as "Finished" when complete
5. Add review and rating

### Reading Analytics

1. View reading statistics dashboard
2. Generate monthly wrap-up images
3. Track reading streaks
4. View reading history and trends

## Backup

**Automated Daily Backups:**

- **Backup Script:** `/home/evan/scripts/backup-mybibliotheca.sh`
- **Schedule:** Daily at 2 AM (cron job)
- **Source:** `/home/evan/data/mybibliotheca/data/` (local VM)
- **Destination:** `/mnt/video/backups/mybibliotheca/` (NAS)
- **Retention:** 30 days
- **Logs:** `/var/log/mybibliotheca-backup.log`

**Manual Backup:**
```bash
# Run backup script manually
/home/evan/scripts/backup-mybibliotheca.sh

# Verify backup
ls -lh /mnt/video/backups/mybibliotheca/
```

**Restore:**
```bash
# Stop MyBibliotheca container
docker stop mybibliotheca

# Restore database from backup
cp /mnt/video/backups/mybibliotheca/mybibliotheca-backup-YYYYMMDD-HHMMSS.db \
   /home/evan/data/mybibliotheca/data/books.db

# Start container
docker start mybibliotheca
```

## External Access

**Pangolin Tunnel:**
- **Subdomain:** `mybibliotheca.infinity-node.com` (configured in Pangolin)
- **Internal URL:** `http://localhost:5054` on VM-103
- **Access:** https://mybibliotheca.infinity-node.com

## Database

**SQLite Database:**
- **Location:** `/home/evan/data/mybibliotheca/data/books.db`
- **Backup:** Daily automated backups to NAS
- **Schema:** Managed by SQLAlchemy migrations

## Monitoring

```bash
# View logs
docker logs -f mybibliotheca

# Check container status
docker ps | grep mybibliotheca

# Check disk usage
du -sh /home/evan/data/mybibliotheca/
```

## Troubleshooting

**Service not accessible:**
- Check container is running: `docker ps | grep mybibliotheca`
- Check port 5054 not in use: `ss -tuln | grep 5054`
- Check logs: `docker logs mybibliotheca`

**Database issues:**
- Verify database file exists: `ls -lh /home/evan/data/mybibliotheca/data/books.db`
- Check file permissions: `ls -la /home/evan/data/mybibliotheca/data/`
- Verify backup script runs: `tail /var/log/mybibliotheca-backup.log`

**Import failures:**
- Check import file format (CSV)
- Verify file permissions on import directory
- Check logs for specific error messages

**Authentication issues:**
- Verify secrets are correctly set in Portainer
- Check SECRET_KEY and SECURITY_PASSWORD_SALT from Vaultwarden
- Review logs for authentication errors

## Related Documentation

- [[docs/ARCHITECTURE|Infrastructure Architecture]]
- [[docs/VM-CONFIGURATION|VM Configuration]]
- [[docs/SECRET-MANAGEMENT|Secret Management]]
- [[docs/adr/004-use-pangolin-for-external-access|ADR-004: Pangolin]]
- [[tasks/completed/IN-017-implement-vaultwarden-backup|IN-017: Vaultwarden Backup Pattern]]
- [MyBibliotheca Documentation](https://mybibliotheca.org/stable/)
- [MyBibliotheca GitHub](https://github.com/pickles4evaaaa/mybibliotheca)

## Related Services

- **[[stacks/calibre/README|Calibre]]** - Ebook library management (same VM)
- **[[stacks/audiobookshelf/README|Audiobookshelf]]** - Audiobook server (same VM)
