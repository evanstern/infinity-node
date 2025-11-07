#!/usr/bin/env bash
# backup-jelu.sh - Automated Jelu database backup
#
# Backs up Jelu SQLite database to NAS via scp with retention policy.
# Ensures database consistency using SQLite's built-in backup command.
#
# Requirements:
#   - sqlite3
#   - scp (for file transfer over SSH)
#   - expect (for password-based SSH authentication)
#   - NAS backup password in ~/.nas-backup-password (chmod 600)
#
# Setup:
#   echo 'your-nas-backup-password' > ~/.nas-backup-password
#   chmod 600 ~/.nas-backup-password
#
# Usage:
#   ./backup-jelu.sh
#
# Schedule via cron:
#   0 2 * * * /home/evan/scripts/backup-jelu.sh >> /var/log/jelu-backup.log 2>&1
#
# Exit codes:
#   0 - Success
#   1 - Source database not found
#   2 - Backup failed
#   3 - Backup integrity check failed
#   4 - NAS not accessible or scp failed
#   5 - Missing required tools or credentials

set -euo pipefail

# Configuration
SOURCE_DB_DIR="/home/evan/data/jelu/database"
NAS_HOST="192.168.86.43"
NAS_USER="backup"
NAS_BACKUP_DIR="backups/jelu"  # Relative to Synology SFTP chroot (/volume1/)
NAS_BACKUP_DIR_FULL="/volume1/backups/jelu"  # Full path for SSH commands
LOCAL_TMP_DIR="/tmp"
DATE=$(date +%Y%m%d-%H%M%S)
RETENTION_DAYS=30

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
error() { echo -e "${RED}ERROR: $1${NC}" >&2; }
success() { echo -e "${GREEN}✓ $1${NC}"; }
info() { echo -e "${YELLOW}→ $1${NC}"; }

# Start backup process
info "Starting Jelu backup at $(date)"

# Verify required tools are installed
for cmd in sqlite3 expect scp; do
    if ! command -v $cmd &> /dev/null; then
        error "Required command not found: $cmd"
        exit 5
    fi
done

# Read NAS backup password from secure file
PASSWORD_FILE="$HOME/.nas-backup-password"
if [ ! -f "$PASSWORD_FILE" ]; then
    error "Password file not found: $PASSWORD_FILE"
    error "Create it with: echo 'your-password' > $PASSWORD_FILE && chmod 600 $PASSWORD_FILE"
    exit 5
fi

# Verify password file permissions
if [ "$(stat -c '%a' "$PASSWORD_FILE" 2>/dev/null || stat -f '%A' "$PASSWORD_FILE")" != "600" ]; then
    error "Password file has incorrect permissions (should be 600)"
    error "Fix with: chmod 600 $PASSWORD_FILE"
    exit 5
fi

NAS_PASSWORD=$(cat "$PASSWORD_FILE")

# Find database file (Jelu uses single SQLite file, typically db.sqlite3 or jelu.db)
SOURCE_DB=""
if [ -f "$SOURCE_DB_DIR/db.sqlite3" ]; then
    SOURCE_DB="$SOURCE_DB_DIR/db.sqlite3"
elif [ -f "$SOURCE_DB_DIR/jelu.db" ]; then
    SOURCE_DB="$SOURCE_DB_DIR/jelu.db"
else
    # Try to find any .sqlite3 or .db file in the directory
    SOURCE_DB=$(find "$SOURCE_DB_DIR" -maxdepth 1 -type f \( -name "*.sqlite3" -o -name "*.db" \) | head -1)
    if [ -z "$SOURCE_DB" ]; then
        error "Source database not found in $SOURCE_DB_DIR"
        error "Expected: db.sqlite3 or jelu.db"
        exit 1
    fi
fi

# Verify source database exists
if [ ! -f "$SOURCE_DB" ]; then
    error "Source database not found: $SOURCE_DB"
    exit 1
fi

# Get source database size for logging
SOURCE_SIZE=$(du -h "$SOURCE_DB" | cut -f1)
info "Source database: $SOURCE_DB"
info "Source database size: $SOURCE_SIZE"

# Generate backup filename based on source filename
DB_FILENAME=$(basename "$SOURCE_DB")
LOCAL_BACKUP_FILE="$LOCAL_TMP_DIR/jelu-backup-$DATE-${DB_FILENAME}"
REMOTE_BACKUP_FILE="jelu-backup-$DATE-${DB_FILENAME}"

# Create backup locally using SQLite's VACUUM INTO command (handles locks better)
# This method works even when database is in use by Jelu
info "Creating local backup..."
if ! sqlite3 "$SOURCE_DB" "VACUUM INTO '$LOCAL_BACKUP_FILE'"; then
    error "SQLite backup command failed"
    error "Database may be locked. Trying alternative method..."

    # Fallback: Use cp with sync for consistency
    if cp "$SOURCE_DB" "$LOCAL_BACKUP_FILE" && sync; then
        info "Used fallback copy method"
    else
        error "Both backup methods failed"
        exit 2
    fi
fi

# Verify backup file was created
if [ ! -f "$LOCAL_BACKUP_FILE" ]; then
    error "Backup file not created: $LOCAL_BACKUP_FILE"
    exit 2
fi

# Check backup file size
BACKUP_SIZE=$(du -h "$LOCAL_BACKUP_FILE" | cut -f1)
info "Backup file size: $BACKUP_SIZE"

# Verify backup is a valid SQLite database
info "Verifying backup integrity..."
if ! sqlite3 "$LOCAL_BACKUP_FILE" "PRAGMA integrity_check;" | grep -q "ok"; then
    error "Backup integrity check failed - database may be corrupt"
    error "Backup file: $LOCAL_BACKUP_FILE"
    rm -f "$LOCAL_BACKUP_FILE"
    exit 3
fi

success "Local backup created successfully: $LOCAL_BACKUP_FILE"

# Copy backup to NAS via scp over SSH
info "Uploading backup to NAS ($NAS_HOST)..."
expect <<EOFEXP
set password [exec cat "$PASSWORD_FILE"]
set timeout 60
spawn scp -o StrictHostKeyChecking=no "$LOCAL_BACKUP_FILE" ${NAS_USER}@${NAS_HOST}:${NAS_BACKUP_DIR}/${REMOTE_BACKUP_FILE}
expect {
    "password:" {
        send "\$password\r"
        expect eof
    }
    timeout {
        puts "Connection timeout"
        exit 1
    }
}
EOFEXP

if [ $? -ne 0 ]; then
    error "Failed to upload backup to NAS"
    rm -f "$LOCAL_BACKUP_FILE"
    exit 4
fi

success "Backup uploaded to NAS: $NAS_BACKUP_DIR_FULL/$REMOTE_BACKUP_FILE"

# Clean up local temporary file
rm -f "$LOCAL_BACKUP_FILE"
info "Cleaned up local temporary backup file"

# Cleanup old backups on NAS
info "Cleaning up backups older than $RETENTION_DAYS days on NAS..."
expect <<EOFEXP
set password [exec cat "$PASSWORD_FILE"]
set timeout 30
spawn ssh -o StrictHostKeyChecking=no ${NAS_USER}@${NAS_HOST} "find ${NAS_BACKUP_DIR_FULL} -name 'jelu-backup-*.sqlite3' -o -name 'jelu-backup-*.db' -mtime +${RETENTION_DAYS} -delete && find ${NAS_BACKUP_DIR_FULL} -name 'jelu-backup-*' | wc -l"
expect {
    "password:" {
        send "\$password\r"
        expect eof
    }
    timeout {
        puts "SSH timeout during cleanup"
        exit 1
    }
}
EOFEXP

if [ $? -eq 0 ]; then
    success "Old backups cleaned up successfully"
else
    error "Warning: Cleanup may have failed (non-critical)"
fi

# Get backup statistics from NAS
info "Retrieving backup statistics from NAS..."
STATS=$(expect <<EOFEXP
set password [exec cat "$PASSWORD_FILE"]
set timeout 30
log_user 0
spawn ssh -o StrictHostKeyChecking=no ${NAS_USER}@${NAS_HOST} "cd ${NAS_BACKUP_DIR_FULL} && find . -name 'jelu-backup-*' | wc -l && du -sh ."
expect {
    "password:" {
        send "\$password\r"
        expect eof
        puts \$expect_out(buffer)
    }
    timeout {
        puts "ERROR"
        exit 1
    }
}
EOFEXP
)

success "Backup complete!"
echo ""
echo "Statistics:"
echo "  Latest backup: $NAS_BACKUP_DIR_FULL/$REMOTE_BACKUP_FILE"
echo "  Backup size: $BACKUP_SIZE"
echo "  NAS backup directory: $NAS_BACKUP_DIR_FULL"
echo "  Retention policy: $RETENTION_DAYS days"
if [ "$STATS" != "ERROR" ]; then
    echo "  Remote statistics: (use ssh to NAS for details)"
fi
echo ""

exit 0
