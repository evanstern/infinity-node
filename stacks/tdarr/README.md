# Tdarr Stack

Automated media optimization service using GPU-accelerated transcoding to reduce file sizes.

## Overview

Tdarr automatically transcodes media files from H.264 to H.265 (HEVC) using GPU acceleration, achieving 30-50% file size reduction with minimal quality loss. Operates on a schedule (2-6 AM ET) to avoid contention with Emby streaming.

**Deployment**: VM 100 (emby) - co-located with Emby for GPU sharing
**Access**: http://tdarr.local.infinity-node.win (port-free via Traefik) or http://tdarr.local.infinity-node.win:8265 (direct)
**Port**: 8265 (Web UI)
**Stack**: Docker Compose via Portainer GitOps
**Critical Service**: No (but affects critical service VM)

## Architecture

### Services

- **tdarr_server**: Web UI and job orchestration
- **tdarr_node**: Worker process with GPU access for transcoding
- **tdarr_mongodb**: MongoDB 4.4 database for Tdarr metadata

### GPU Configuration

Shares NVIDIA RTX 4060 Ti with Emby via temporal isolation:
- **Emby**: Available 24/7, primary user of GPU
- **Tdarr**: Restricted to 2-6 AM ET only (scheduled)
- **Resource limits**: 1 GPU worker, 1 CPU worker, low process priority

### Storage

- **Config**: `/mnt/nas/configs/tdarr` (persistent on NAS)
- **Media libraries**:
  - Movies: `/mnt/video/Movies`
  - TV Shows: `/mnt/video/TV`
- **Transcode cache**: Temporary storage for in-progress transcodes

## Configuration

### Environment Variables

Copy `env.example` to `.env` on VM 100 and configure:

```bash
# Required
TZ=America/New_York
CONFIG_PATH=/mnt/nas/configs/tdarr
MEDIA_PATH_MOVIES=/mnt/video/Movies
MEDIA_PATH_TV=/mnt/video/TV
TRANSCODE_CACHE=/tmp/tdarr  # or /mnt/nas/tdarr/cache
MONGODB_ROOT_PASSWORD=<from-vaultwarden>
```

### Secrets Management

MongoDB root password stored in Vaultwarden:
- **Collection**: `vm-100-emby`
- **Item**: `tdarr-mongodb-root`
- **Field**: `password`

Retrieve with:
```bash
export BW_SESSION=$(cat ~/.bw-session)
./scripts/secrets/get-vw-secret.sh "tdarr-mongodb-root" "vm-100-emby"
```

### Library Schedule

Configured in Tdarr Web UI:
- **Processing window**: 2:00 AM - 6:00 AM US Eastern Time
- **Timezone**: America/New_York
- **Enforcement**: Strict - no processing outside window

### Worker Limits

Configured in Tdarr Web UI (Nodes → MainNode):
- **GPU workers**: 1
- **CPU workers**: 1
- **Process priority**: Low (yields to Emby)
- **Hardware encoding**: NVIDIA NVENC enabled

### Plugin Stack

**Movies Library** (skip if <20GB):
1. **Check codec**: Skip if already H.265/HEVC/AV1
2. **Transcode to H.265**: CQ:V 20-23, maintain resolution, enable B-frames
3. **Health check**: Verify file integrity
4. **Size validation**: Only replace if smaller

**TV Shows Library** (skip if <2GB):
1. **Check codec**: Skip if already H.265/HEVC/AV1
2. **Transcode to H.265**: CQ:V 20-23, maintain resolution, enable B-frames
3. **Health check**: Verify file integrity
4. **Size validation**: Only replace if smaller

**Recommended Plugins**:
- `Tdarr_Plugin_MC93_Migz1FFMPEG`: All-in-one NVENC H.265 with built-in filters
- `Tdarr_Plugin_vdka_Tiered_NVENC_CQV_BASED_CONFIGURABLE`: Resolution-specific quality tiers

## Deployment

### Via Portainer GitOps

1. **Prepare secrets**:
   ```bash
   # Generate MongoDB password
   openssl rand -base64 32

   # Store in Vaultwarden (manual via web UI or CLI)
   # Collection: vm-100-emby
   # Item: tdarr-mongodb-root
   # Field: password
   ```

2. **Create .env on VM 100**:
   ```bash
   ssh evan@vm-100.local.infinity-node.win
   sudo mkdir -p /mnt/nas/configs/tdarr
   cd /path/to/tdarr/stack
   cp env.example .env
   nano .env  # Fill in MongoDB password and paths
   ```

3. **Deploy via Portainer**:
   - Portainer UI → Stacks → Add stack
   - **Name**: `tdarr`
   - **Build method**: Git repository
   - **Repository URL**: `https://github.com/evanstern/infinity-node`
   - **Repository reference**: `refs/heads/main`
   - **Compose path**: `stacks/tdarr/docker-compose.yml`
   - **Environment variables**: Load from `.env` file on VM
   - **GitOps updates**: Enabled (auto-pull every 5m)
   - Deploy

4. **Verify deployment**:
   ```bash
   ssh evan@vm-100.local.infinity-node.win
   docker ps | grep tdarr
   docker logs tdarr_server
   docker exec tdarr_node nvidia-smi  # Verify GPU access
   ```

5. **Access Web UI**:
   - Navigate to: `http://tdarr.local.infinity-node.win` (port-free) or `http://tdarr.local.infinity-node.win:8265` (direct)
   - Complete initial setup wizard
   - Configure libraries, schedule, workers

## Operations

### Accessing Web UI

```bash
# From local network (port-free via Traefik)
http://tdarr.local.infinity-node.win

# Or direct access
http://tdarr.local.infinity-node.win:8265
```

### Monitoring

**GPU utilization during Tdarr window:**
```bash
ssh evan@vm-100.local.infinity-node.win
watch -n 2 nvidia-smi
```

**Docker resource usage:**
```bash
ssh evan@vm-100.local.infinity-node.win
docker stats tdarr_server tdarr_node tdarr_mongodb
```

**Tdarr logs:**
```bash
ssh evan@vm-100.local.infinity-node.win
docker logs -f tdarr_server
docker logs -f tdarr_node
```

**Processing progress:**
- Tdarr Web UI → Activity → View active jobs
- Tdarr Web UI → Completed → View processed files
- Check file size reduction statistics

### Manual Control

**Stop Tdarr immediately (emergency):**
```bash
ssh evan@vm-100.local.infinity-node.win
cd /path/to/tdarr/stack
docker compose down
```

**Start Tdarr:**
```bash
ssh evan@vm-100.local.infinity-node.win
cd /path/to/tdarr/stack
docker compose up -d
```

**Restart Tdarr:**
```bash
# Via Portainer: Stacks → tdarr → Restart
# OR via SSH:
ssh evan@vm-100.local.infinity-node.win
cd /path/to/tdarr/stack
docker compose restart
```

### Adjusting Schedule

1. Tdarr Web UI → Libraries → [Library] → Schedule
2. Modify start/end times
3. Save changes
4. Verify in logs that schedule is enforced

### Adjusting Resource Limits

1. Tdarr Web UI → Nodes → MainNode → Options
2. Modify GPU workers / CPU workers
3. Save changes
4. Monitor impact on Emby performance

## Troubleshooting

### GPU not detected in node

**Check NVIDIA driver visible in container:**
```bash
ssh evan@vm-100.local.infinity-node.win
docker exec tdarr_node nvidia-smi
```

If not visible:
- Verify nvidia-docker runtime installed: `docker info | grep -i nvidia`
- Check deploy.resources.reservations in docker-compose.yml
- Restart docker daemon: `sudo systemctl restart docker`

### Tdarr processing outside schedule window

**Check timezone configuration:**
```bash
ssh evan@vm-100.local.infinity-node.win
docker exec tdarr_server date
docker exec tdarr_server cat /etc/timezone
```

Should show `America/New_York` and current Eastern time.

If wrong:
- Update TZ environment variable in docker-compose.yml
- Redeploy stack via Portainer

### Emby buffering during Tdarr window

**Immediately stop Tdarr:**
```bash
ssh evan@vm-100.local.infinity-node.win
cd /path/to/tdarr/stack
docker compose down
```

**Adjust schedule or resource limits:**
- Reduce GPU workers from 1 to 0 (CPU-only for testing)
- Shorten schedule window (e.g., 3-6 AM instead of 2-6 AM)
- Lower transcode priority in Tdarr settings

### Files not being processed

**Check plugin configuration:**
- Tdarr Web UI → Libraries → [Library] → Transcode options
- Verify conditional logic not too restrictive
- Check library scan completed: Libraries → [Library] → Database

**Check file size thresholds:**
- Movies plugin skips files <20GB
- TV plugin skips files <2GB
- Adjust thresholds in plugin settings if needed

### MongoDB connection errors

**Check MongoDB container:**
```bash
ssh evan@vm-100.local.infinity-node.win
docker logs tdarr_mongodb
docker exec tdarr_mongodb mongo --eval "db.adminCommand('ping')"
```

**Check password in .env matches Vaultwarden:**
```bash
export BW_SESSION=$(cat ~/.bw-session)
./scripts/secrets/get-vw-secret.sh "tdarr-mongodb-root" "vm-100-emby"
```

## Performance

**Expected processing speed:**
- **GPU (NVENC)**: 3-5 large movies per 4-hour window
- **CPU fallback**: 0.5-1 movie per 4-hour window (much slower)

**Expected size reduction:**
- **H.264 → H.265**: 30-50% smaller files at same quality
- **Quality level**: CQ:V 20-23 = visually lossless to near-lossless

**Library completion time estimate:**
- **40TB library**: ~880 movies @ 50GB average
- **Processing rate**: 4 movies/night
- **Completion**: 220 nights (7+ months)
- **Acceptable**: This is batch optimization, not time-sensitive

## Safety

### Emby Performance Protection

- **Scheduled operation**: 2-6 AM only (lowest usage)
- **Resource limits**: 1 GPU worker, low process priority
- **Temporal isolation**: Emby has GPU priority 20 hours/day
- **Monitoring**: Watch Emby performance during first week

### File Integrity Protection

- **Health check**: Tdarr verifies file playability before replacing original
- **Size validation**: Only replaces if new file is actually smaller
- **NAS snapshots**: Synology NAS has previous versions feature
- **Rollback**: Can restore from NAS snapshots if issues detected

### Over-transcoding Prevention

- **Codec check**: Skips files already in H.265/HEVC/AV1
- **Processed tracking**: Tdarr marks files to prevent re-processing
- **High quality preset**: CQ:V 20-23 maintains visual fidelity
- **Resolution preservation**: 1080p stays 1080p, 4K stays 4K

## Rollback

### Stop Tdarr completely

```bash
# Via Portainer: Stacks → tdarr → Delete
# OR via SSH:
ssh evan@vm-100.local.infinity-node.win
cd /path/to/tdarr/stack
docker compose down
```

### Remove from Git

```bash
cd /Users/evanstern/projects/evanstern/infinity-node
git revert <commit-hash>  # Revert Tdarr addition
git push
```

### Restore corrupted files

```bash
# Via Synology NAS File Station:
# Right-click file → Restore from previous version
# Select version before Tdarr processing

# OR re-download via arr services
```

### Clean up Tdarr data

```bash
ssh evan@vm-100.local.infinity-node.win
sudo rm -rf /mnt/nas/configs/tdarr
```

## Related Documentation

- [[tasks/completed/IN-032-implement-emby-gpu-passthrough|IN-032]]: GPU passthrough implementation
- [[docs/adr/013-emby-transcoding-optimization|ADR-013]]: Emby GPU transcoding decision
- [[docs/ARCHITECTURE|Architecture]]: VM 100 details
- [[stacks/emby/README|Emby Stack]]: GPU configuration reference

## Notes

**Why VM 100?**
- Only VM with GPU access (no multi-VM passthrough complexity)
- Scheduled operation avoids Emby contention during household usage

**Why 2-6 AM ET?**
- Lowest household usage window historically
- Allows 4 hours processing time per night
- Minimizes risk to critical Emby service

**Why not expand CPU cores?**
- Proxmox host only has 2 unallocated cores (92% already allocated)
- Conservative resource limits sufficient with GPU acceleration
- Slow processing acceptable for batch optimization task

**Storage impact:**
- 44TB library at 30-50% reduction = 13-22TB saved
- Extends runway before NAS expansion needed
- Better ROI on existing storage investment
