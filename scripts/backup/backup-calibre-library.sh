#!/bin/bash
#
# backup-calibre-library.sh
#
# Purpose: Backup Calibre library from VM disk to NAS
#
# This script creates a backup of the Calibre library (database + books)
# from the VM's local disk to the NAS for disaster recovery.
#
# Usage:
#   ./backup-calibre-library.sh
#
# Cron Usage:
#   # Daily at 3 AM
#   0 3 * * * /home/evan/scripts/backup-calibre-library.sh >> /var/log/calibre-backup.log 2>&1
#
# What it does:
#   1. Stops Calibre containers to ensure clean backup
#   2. Creates timestamped backup on NAS
#   3. Keeps last 7 daily backups
#   4. Restarts Calibre containers
#   5. Logs all operations
#
# Requirements:
#   - /mnt/video/Backups/calibre directory on NAS
#   - Sufficient space on NAS for backups
#   - Docker access (user in docker group)
#
# Exit Codes:
#   0 - Success
#   1 - Backup failed
#   2 - Container management failed

set -euo pipefail

# Configuration
SOURCE_DIR="/home/evan/calibre-library"
BACKUP_BASE="/mnt/video/Backups/calibre"
BACKUP_NAME="calibre-library-$(date +%Y%m%d-%H%M%S).tar.gz"
BACKUP_PATH="${BACKUP_BASE}/${BACKUP_NAME}"
RETENTION_DAYS=7
LOG_PREFIX="[$(date '+%Y-%m-%d %H:%M:%S')]"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() { echo -e "${LOG_PREFIX} $1"; }
error() { echo -e "${LOG_PREFIX} ${RED}ERROR: $1${NC}" >&2; }
success() { echo -e "${LOG_PREFIX} ${GREEN}✓ $1${NC}"; }
info() { echo -e "${LOG_PREFIX} ${BLUE}→ $1${NC}"; }
warn() { echo -e "${LOG_PREFIX} ${YELLOW}⚠ $1${NC}"; }

# Check if source exists
if [ ! -d "$SOURCE_DIR" ]; then
    error "Source directory does not exist: $SOURCE_DIR"
    exit 1
fi

# Create backup directory if it doesn't exist
if [ ! -d "$BACKUP_BASE" ]; then
    info "Creating backup directory: $BACKUP_BASE"
    mkdir -p "$BACKUP_BASE" || {
        error "Failed to create backup directory"
        exit 1
    }
fi

# Check if Calibre containers are running
CALIBRE_RUNNING=$(docker ps --filter "name=calibre" --filter "status=running" --format "{{.Names}}" | wc -l)

if [ "$CALIBRE_RUNNING" -gt 0 ]; then
    info "Stopping Calibre containers for clean backup..."
    docker stop calibre calibre-web 2>/dev/null || {
        warn "Some containers may not have stopped cleanly"
    }
    CONTAINERS_STOPPED=true
else
    info "Calibre containers not running, proceeding with backup"
    CONTAINERS_STOPPED=false
fi

# Calculate library size
LIBRARY_SIZE=$(du -sh "$SOURCE_DIR" | cut -f1)
info "Library size: $LIBRARY_SIZE"

# Create backup
info "Creating backup: $BACKUP_NAME"
START_TIME=$(date +%s)

tar czf "$BACKUP_PATH" -C "$(dirname "$SOURCE_DIR")" "$(basename "$SOURCE_DIR")" 2>&1 || {
    error "Backup creation failed"

    # Restart containers if we stopped them
    if [ "$CONTAINERS_STOPPED" = true ]; then
        warn "Restarting Calibre containers after failed backup..."
        docker start calibre calibre-web 2>/dev/null || error "Failed to restart containers"
    fi

    exit 1
}

END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))
BACKUP_SIZE=$(du -sh "$BACKUP_PATH" | cut -f1)

success "Backup created: $BACKUP_PATH"
info "Backup size: $BACKUP_SIZE"
info "Duration: ${DURATION} seconds"

# Restart containers if we stopped them
if [ "$CONTAINERS_STOPPED" = true ]; then
    info "Restarting Calibre containers..."
    docker start calibre calibre-web || {
        error "Failed to restart containers"
        exit 2
    }

    # Wait a moment and verify they started
    sleep 3
    RUNNING_NOW=$(docker ps --filter "name=calibre" --filter "status=running" --format "{{.Names}}" | wc -l)
    if [ "$RUNNING_NOW" -eq 2 ]; then
        success "Calibre containers restarted successfully"
    else
        warn "Not all Calibre containers are running (${RUNNING_NOW}/2)"
    fi
fi

# Clean up old backups
info "Cleaning up backups older than $RETENTION_DAYS days..."
find "$BACKUP_BASE" -name "calibre-library-*.tar.gz" -type f -mtime +$RETENTION_DAYS -delete 2>/dev/null || true

REMAINING_BACKUPS=$(find "$BACKUP_BASE" -name "calibre-library-*.tar.gz" -type f | wc -l)
info "Backups retained: $REMAINING_BACKUPS"

# List recent backups
info "Recent backups:"
find "$BACKUP_BASE" -name "calibre-library-*.tar.gz" -type f -printf "%T+ %p\n" | sort -r | head -5 | while read -r line; do
    TIMESTAMP=$(echo "$line" | cut -d' ' -f1)
    FILE=$(echo "$line" | cut -d' ' -f2-)
    SIZE=$(du -sh "$FILE" | cut -f1)
    log "  - $(basename "$FILE") ($SIZE) - $TIMESTAMP"
done

success "Backup completed successfully"
exit 0
