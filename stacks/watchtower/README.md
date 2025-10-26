---
type: stack
service: watchtower
category: infrastructure
vms: [100, 101, 102, 103]
priority: important
status: running
stack-type: single-container
has-secrets: false
external-access: false
ports: []
backup-priority: low
created: 2025-10-26
updated: 2025-10-26
tags:
  - stack
  - vm-100
  - vm-101
  - vm-102
  - vm-103
  - infrastructure
  - automation
  - single-container
  - no-secrets
  - container-updates
aliases:
  - Watchtower
  - Auto-Updater
---

# Watchtower Stack

**Service:** Watchtower (Automatic Docker Container Updater)
**VM:** 103 (misc) - Also deployed on VM 100, 101, 102
**Priority:** Important - Keeps all containers up to date
**Image:** `containrrr/watchtower`

## Overview

Watchtower automatically monitors running Docker containers and updates them when new images are available. It's deployed on each VM to keep all services current with the latest releases.

## Key Features

- **Automatic Updates:** Checks for new images and updates containers automatically
- **Scheduled Updates:** Runs on configurable cron schedule (default: daily at midnight)
- **Rolling Restarts:** Updates containers one at a time to minimize downtime
- **Cleanup:** Removes old images after successful updates
- **Lifecycle Hooks:** Supports pre/post update hooks
- **Notifications:** Optional email notifications about updates
- **Selective Updates:** Can filter by container labels

## Configuration

### Secrets

None - Watchtower requires no secrets for basic operation.

**Optional Secrets (if using email notifications):**
- Email credentials stored in Vaultwarden (if configured)

### Volumes

- `/var/run/docker.sock` - Docker API access (required to manage containers)

### Environment Variables

**Core Settings:**
- `SCHEDULE` - Cron format schedule (default: `0 0 * * *` = daily at midnight)
- `CLEANUP` - Remove old images after update (default: `true`)
- `ROLLING_RESTART` - Restart one container at a time (default: `true`)

**Update Behavior:**
- `MONITOR_ONLY` - Only check for updates, don't apply (default: `false`)
- `INCLUDE_STOPPED` - Update stopped containers (default: `false`)
- `REMOVE_VOLUMES` - Remove volumes when cleaning (default: `false`)

**Advanced:**
- `LABEL_ENABLE` - Only update containers with specific label
- Email notification settings (optional)
- Private registry authentication (optional)

See `.env.example` for all configuration options.

## Deployment

```bash
cd stacks/watchtower
cp .env.example .env
# Edit .env with desired schedule and options
docker compose up -d
```

## Usage

### Monitor Logs

```bash
docker logs -f watchtower
```

### Trigger Manual Update

```bash
# Force immediate update check
docker restart watchtower
```

### Exclude Specific Containers

Add label to containers you don't want auto-updated:

```yaml
services:
  myservice:
    labels:
      - "com.centurylinklabs.watchtower.enable=false"
```

Then enable label filtering in `.env`:
```
LABEL_ENABLE=true
```

## Update Schedule Examples

```bash
# Every day at 3 AM
SCHEDULE=0 3 * * *

# Every Sunday at 2 AM
SCHEDULE=0 2 * * 0

# Every 6 hours
SCHEDULE=0 */6 * * *

# Twice daily (6 AM and 6 PM)
SCHEDULE=0 6,18 * * *
```

## Monitoring

Watch watchtower logs to see update activity:

```bash
docker logs watchtower --follow
```

Expected log output:
- Container scan results
- Image pull notifications
- Container restart messages
- Cleanup actions

## Best Practices

1. **Start with Monitor Mode:** Set `MONITOR_ONLY=true` initially to see what would be updated
2. **Enable Cleanup:** Set `CLEANUP=true` to prevent disk space issues from old images
3. **Use Rolling Restarts:** Keep `ROLLING_RESTART=true` to minimize downtime
4. **Schedule Off-Peak:** Run updates during low-traffic hours (e.g., 3 AM)
5. **Exclude Critical Services:** Use labels to exclude services that need manual update testing
6. **Monitor Logs:** Regularly check logs for update failures

## Troubleshooting

**Container not updating:**
- Check if container has watchtower.enable=false label
- Verify container is running (watchtower only updates running containers by default)
- Check if image uses :latest tag or specific version tag

**Updates happening too frequently:**
- Adjust `SCHEDULE` to less frequent interval
- Consider `MONITOR_ONLY=true` if only want notifications

**Disk filling up:**
- Ensure `CLEANUP=true` is set
- Manually prune old images: `docker image prune -a`

## Security Considerations

- Watchtower requires access to Docker socket (high privilege)
- Only monitors images from same registry as original
- Does not validate image signatures (consider manual updates for critical services)
- Email credentials (if used) should be app-specific passwords, not main account passwords

## Dependencies

None - Watchtower is self-contained and operates independently.

## Related Documentation

- [Official Watchtower Docs](https://containrrr.dev/watchtower/)
- [Cron Expression Guide](https://crontab.guru/)
- [Docker Hub: Watchtower](https://hub.docker.com/r/containrrr/watchtower)

## Notes

- Deployed on all VMs (100, 101, 102, 103) for consistency
- Does not update itself (restart watchtower container to get latest)
- Compatible with Portainer's auto-update feature
- Consider disabling for production services requiring change control
