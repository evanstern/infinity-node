---
type: stack
service: linkwarden
category: productivity
vms: [103]
priority: medium
status: running
stack-type: multi-container
has-secrets: true
external-access: false
ports: [3000]
backup-priority: high
created: 2025-10-26
updated: 2025-10-26
tags:
  - stack
  - vm-103
  - productivity
  - bookmarks
  - archiving
  - full-text-search
  - multi-container
  - has-secrets
  - postgresql
  - meilisearch
  - browser-extension
  - mobile-app
  - collaboration
  - screenshots
aliases:
  - Linkwarden
  - Bookmark Manager
---

# Linkwarden Stack

**Service:** Linkwarden (Bookmark Manager)
**VM:** 103 (misc)
**Priority:** Medium - Bookmark organization
**Access:** http://192.168.86.249:3000
**Image:** `ghcr.io/linkwarden/linkwarden:latest`

## Overview

Linkwarden is a self-hosted collaborative bookmark manager to collect, organize, and preserve webpages. It features full-text search, automatic screenshots, webpage archiving, and collaboration features.

## Key Features

- **Bookmark Management:** Save and organize web pages
- **Full-Text Search:** Powered by Meilisearch
- **Webpage Archiving:** Save complete copies of web pages
- **Screenshots:** Automatic screenshot capture
- **Collections:** Organize bookmarks into collections
- **Tags:** Tag-based organization
- **Collaboration:** Share collections with other users
- **Browser Extensions:** Chrome, Firefox, Edge support
- **Mobile Apps:** iOS and Android
- **Import/Export:** Import from various bookmark services

## Architecture

Multi-container stack:
- **linkwarden:** Main application (Next.js)
- **postgres:** Database for metadata
- **meilisearch:** Search engine for full-text search

## Configuration

### Secrets

**Required secrets stored in Vaultwarden:**

1. **NEXTAUTH_SECRET** - Session encryption key
   - Location: `infinity-node/vm-103-misc/linkwarden-secrets`
   - Field: `nextauth_secret`
   - Current value: `ukszCWCOFDdgVlm1O3FnaUXT0UaDmwzs`

2. **POSTGRES_PASSWORD** - PostgreSQL database password
   - Location: `infinity-node/vm-103-misc/linkwarden-secrets`
   - Field: `postgres_password`
   - Current value: `4FOw7rroDOPG1mYpJ7Rb295Z`

**Store in Vaultwarden:**
```bash
export BW_SESSION=$(bw unlock --raw)

./scripts/create-secret.sh "linkwarden-secrets" "vm-103-misc" "" \
  '{"service":"linkwarden","vm":"103","nextauth_secret":"ukszCWCOFDdgVlm1O3FnaUXT0UaDmwzs","postgres_password":"4FOw7rroDOPG1mYpJ7Rb295Z"}'
```

**Retrieve from Vaultwarden:**
```bash
export BW_SESSION=$(bw unlock --raw)
NEXTAUTH_SECRET=$(bw get item linkwarden-secrets --field nextauth_secret)
POSTGRES_PASSWORD=$(bw get item linkwarden-secrets --field postgres_password)
```

### Volumes

**Data Storage:**
- `./data` → `/data/data` - Archived webpages, screenshots, uploads
- `./pgdata` → `/var/lib/postgresql/data` - PostgreSQL database
- `./meili_data` → `/meili_data` - Meilisearch index data

### Environment Variables

**Core Settings:**
- `NEXTAUTH_URL` - Authentication URL (default: `http://localhost:3000/api/v1/auth`)
- `NEXTAUTH_SECRET` - Session encryption secret (secret)
- `POSTGRES_PASSWORD` - PostgreSQL password (secret)

**Registration & Auth:**
- `NEXT_PUBLIC_DISABLE_REGISTRATION` - Disable new registrations (default: `false`)
- `NEXT_PUBLIC_CREDENTIALS_ENABLED` - Enable username/password login (default: `true`)

**Optional Advanced Settings:**
- Archive limits, timeouts, buffer sizes
- RSS polling configuration
- AI integration (Ollama)
- AWS S3/Spaces storage
- Email/SMTP configuration
- Proxy settings

See `.env.example` for all configuration options.

## Deployment

```bash
cd stacks/linkwarden
cp .env.example .env

# Retrieve secrets from Vaultwarden
export BW_SESSION=$(bw unlock --raw)
NEXTAUTH_SECRET=$(bw get item linkwarden-secrets --field nextauth_secret)
POSTGRES_PASSWORD=$(bw get item linkwarden-secrets --field postgres_password)

# Update .env file with actual secrets
# Or use deployment script

docker compose up -d
```

## Initial Setup

1. **Access Web UI:** Navigate to http://192.168.86.249:3000
2. **Create Admin Account:** First user becomes admin
3. **Configure Settings:**
   - Set default collection
   - Configure archive settings
   - Set up search preferences
4. **Install Browser Extension (Optional):**
   - Chrome/Edge: Install from Chrome Web Store
   - Firefox: Install from Firefox Add-ons
   - Configure extension with server URL
5. **Install Mobile App (Optional):**
   - iOS/Android: Download from app stores
   - Connect to server

## Usage

### Web Interface

- **Save Bookmark:** Click "New" or use browser extension
- **Collections:** Organize bookmarks into collections
- **Tags:** Add tags for better organization
- **Search:** Full-text search across all bookmarks
- **Archive View:** View archived webpage copy
- **Screenshots:** Automatic screenshot of saved pages
- **Sharing:** Share collections with other users

### Browser Extension

- **Quick Save:** Click extension icon to save current page
- **Tags & Collections:** Add tags and select collection
- **Notes:** Add notes when saving
- **Screenshot:** Automatic screenshot capture

### Collaboration

- **Create Collections:** Organize related bookmarks
- **Share Collections:** Share with other Linkwarden users
- **Permissions:** Set view/edit permissions
- **Activity:** Track collection activity

## Importing Bookmarks

**Supported Import Sources:**
- Browser bookmarks (HTML export)
- Pocket
- Raindrop.io
- Instapaper
- Wallabag
- Generic HTML bookmark file

**Import Process:**
1. Navigate to Settings → Import/Export
2. Select source format
3. Upload file
4. Review and confirm import

## Monitoring

```bash
# View application logs
docker logs -f linkwarden-linkwarden-1

# View database logs
docker logs -f linkwarden-postgres-1

# View search engine logs
docker logs -f linkwarden-meilisearch-1

# Check storage usage
du -sh ./data ./pgdata ./meili_data
```

## Backup

**Critical data to backup:**
- `./data/` - Archived pages, screenshots, uploads
- `./pgdata/` - PostgreSQL database (bookmarks, users, collections)
- `./meili_data/` - Search index (can be rebuilt)

```bash
# Backup database
docker exec linkwarden-postgres-1 pg_dump -U postgres postgres > linkwarden-backup.sql

# Backup all data
tar -czf linkwarden-backup.tar.gz ./data ./pgdata ./meili_data

# Restore database
docker exec -i linkwarden-postgres-1 psql -U postgres postgres < linkwarden-backup.sql
```

## Troubleshooting

**Bookmarks not saving:**
- Check application logs
- Verify browser extension is connected
- Check network connectivity
- Review archive settings

**Search not working:**
- Verify meilisearch container is running
- Check meilisearch logs
- Rebuild search index (Settings → Advanced)

**Webpage archiving failing:**
- Check archive timeout settings
- Verify network access from container
- Review archive buffer limits
- Check disk space

**Screenshots not generating:**
- Verify archive is enabled
- Check timeout settings
- Review browser settings in config

## Performance

**Archive Processing:**
- CPU-intensive for screenshot generation
- Adjust timeout based on page complexity
- Configure max workers for concurrent processing

**Search Performance:**
- Meilisearch provides fast full-text search
- Index rebuilds can take time for large collections
- RAM usage scales with collection size

**Storage:**
- Archived pages can be large
- Configure archive format (PDF vs. HTML)
- Implement storage limits per user

## Security Considerations

- **NextAuth Secret:** Used for session encryption
- **Database Password:** PostgreSQL authentication
- **User Authentication:** Required for all access
- **Collection Sharing:** Control permissions per collection
- **External Access:** Consider HTTPS if exposing externally
- **Registration:** Disable if limiting to specific users

## Advanced Features

**RSS Feeds:**
- Create RSS feeds from collections
- Auto-save from RSS feeds
- Configure polling interval

**AI Integration (Ollama):**
- AI-powered tagging
- Content summarization
- Connect to local Ollama instance

**S3/Spaces Storage:**
- Offload archives to object storage
- Reduce local storage requirements
- Configure AWS S3 or DigitalOcean Spaces

**Email Notifications:**
- Collection activity notifications
- Shared bookmark notifications
- Configure SMTP server

## Dependencies

- **PostgreSQL:** Required for metadata storage
- **Meilisearch:** Required for full-text search
- **Network Access:** For webpage archiving and screenshots

## Related Documentation

- [Official Linkwarden Docs](https://docs.linkwarden.app/)
- [GitHub Repository](https://github.com/linkwarden/linkwarden)
- [Browser Extensions](https://docs.linkwarden.app/getting-started/browser-extension)
- [Self-Hosting Guide](https://docs.linkwarden.app/self-hosting/installation)

## Notes

- Multi-container stack (linkwarden, postgres, meilisearch)
- Full-text search powered by Meilisearch
- Automatic webpage archiving and screenshots
- Browser extensions for quick bookmark saving
- Collaboration features for shared collections
- Can import from various bookmark services
- Web UI runs on port 3000
- PostgreSQL stores all metadata
- Meilisearch enables fast search across bookmarks
- Archives stored locally in ./data directory
- Consider regular backups of archives and database
