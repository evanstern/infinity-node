# LazyLibrarian Stack

LazyLibrarian is a program to follow authors and adjust metadata for eBooks. It monitors your favorite authors and notifies you when new books are available. It can also search for and download books automatically.

## Configuration

This stack is designed to run on **VM 101** (Downloads).

### Environment Variables

See `.env.example` for the complete list of variables.

| Variable | Description | Default |
|----------|-------------|---------|
| `TZ` | Timezone | `America/New_York` |
| `PUID`/`PGID` | User/Group IDs | `1000` |
| `CONFIG_PATH` | Path to config directory | `/home/evan/.config/lazylibrarian` |
| `DOWNLOADS_PATH` | Path to downloads | `/mnt/video/Downloads` |
| `BOOKS_PATH` | Path to book library | `/mnt/calibre-library` |
| `LAZYLIBRARIAN_PORT`| External port | `5299` |

### Volumes

- `/config`: Stores database and configuration. Should be on local VM storage for SQLite performance.
- `/downloads`: Source of downloads (usually mapped to a shared download folder).
- `/books`: Destination for organized library (NFS mount from VM 103).

### Networking

- Internal Port: `5299`
- External Access: `http://lazylibrarian.local.infinity-node.com` (via Traefik)
- Network: `traefik-network`

## Deployment

1. **Configure Secrets**:
   Copy `.env.example` to `.env` on the host machine at `/opt/stacks/lazylibrarian/.env` (or equivalent).

2. **Deploy via Portainer**:
   - Go to Portainer -> Stacks -> lazylibrarian
   - Click "Pull and redeploy" if updating, or "Add stack" -> "Repository" if new.

## Integration

LazyLibrarian integrates with:
- **Download Clients**: SABnzbd, Transmission, etc. (on this VM)
- **Calibre**: Can interact with Calibre database (optional).

## Storage Architecture

This stack accesses the Calibre library which resides on VM 103.
- **VM 103**: Exports `/home/evan/calibre-library` via NFS.
- **VM 101**: Mounts this export at `/mnt/calibre-library`.
