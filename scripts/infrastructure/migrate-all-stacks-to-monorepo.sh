#!/bin/bash
#
# migrate-all-stacks-to-monorepo.sh
#
# Purpose: Master script to migrate all Portainer stacks to monorepo
#
# This script automates the migration of all stacks across all VMs to use
# the infinity-node monorepo with GitOps enabled. It handles both:
# - Non-Git stacks: Stop, backup, delete, recreate from Git
# - Git stacks: Update repository URL to monorepo
#
# Usage:
#   ./migrate-all-stacks-to-monorepo.sh [--dry-run] [--phase {2|3|all}]
#
# Options:
#   --dry-run: Show what would be done without making changes
#   --phase:   Which phase to run (2=non-Git stacks, 3=Git stacks, all=both)
#              Default: all
#
# Examples:
#   # Migrate all stacks
#   ./migrate-all-stacks-to-monorepo.sh
#
#   # Dry run to see what would happen
#   ./migrate-all-stacks-to-monorepo.sh --dry-run
#
#   # Only migrate non-Git stacks (Phase 2)
#   ./migrate-all-stacks-to-monorepo.sh --phase 2
#
# Requirements:
#   - All migration scripts in place
#   - BW_SESSION set: export BW_SESSION=$(cat ~/.bw-session)
#   - Monorepo must have all stack compose files and .env.example files
#
# Exit Codes:
#   0 - Success
#   1 - Invalid arguments
#   2 - Migration failed

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'

error() { echo -e "${RED}ERROR: $1${NC}" >&2; }
success() { echo -e "${GREEN}✓ $1${NC}"; }
info() { echo -e "${BLUE}→ $1${NC}"; }
warn() { echo -e "${YELLOW}⚠ $1${NC}"; }
header() { echo -e "${MAGENTA}═══ $1 ═══${NC}"; }

# Parse arguments
DRY_RUN=false
PHASE="all"

while [[ $# -gt 0 ]]; do
    case $1 in
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --phase)
            PHASE="$2"
            shift 2
            ;;
        *)
            error "Unknown argument: $1"
            exit 1
            ;;
    esac
done

# Validate phase
if [[ ! "$PHASE" =~ ^(2|3|all)$ ]]; then
    error "Invalid phase: $PHASE. Must be 2, 3, or all"
    exit 1
fi

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Migration scripts
MIGRATE_NONGIT="$SCRIPT_DIR/migrate-nonGit-stack-to-monorepo.sh"
MIGRATE_GIT="$SCRIPT_DIR/migrate-stack-to-monorepo.sh"

# Check scripts exist
if [ ! -f "$MIGRATE_NONGIT" ]; then
    error "migrate-nonGit-stack-to-monorepo.sh not found"
    exit 1
fi

if [ ! -f "$MIGRATE_GIT" ]; then
    error "migrate-stack-to-monorepo.sh not found"
    exit 1
fi

echo ""
echo -e "${MAGENTA}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${MAGENTA}║  Mass Migration to Monorepo                                    ║${NC}"
echo -e "${MAGENTA}╚════════════════════════════════════════════════════════════════╝${NC}"
echo ""

if [ "$DRY_RUN" = true ]; then
    warn "DRY RUN MODE - No changes will be made"
    echo ""
fi

# ==============================================================================
# PHASE 2: Non-Git Stacks
# ==============================================================================

PHASE2_STACKS=(
    # VM 103 (misc) - Low risk
    "portainer-api-token-vm-103|shared|7|3|linkwarden|stacks/linkwarden/docker-compose.yml|$REPO_ROOT/stacks/linkwarden/.env.example"

    # VM 102 (arr) - Combined and critical
    "portainer-api-token-vm-102|shared|2|3|utils|stacks/utils/docker-compose.yml|$REPO_ROOT/stacks/utils/.env.example"
    "portainer-api-token-vm-102|shared|3|3|arr|stacks/arr/docker-compose.yml|$REPO_ROOT/stacks/arr/.env.example"
)

if [[ "$PHASE" == "2" || "$PHASE" == "all" ]]; then
    header "PHASE 2: Migrating Non-Git Stacks"
    echo ""

    PHASE2_COUNT=${#PHASE2_STACKS[@]}
    PHASE2_SUCCESS=0
    PHASE2_FAILED=0

    for (( i=0; i<$PHASE2_COUNT; i++ )); do
        STACK_INFO="${PHASE2_STACKS[$i]}"
        IFS='|' read -r SECRET COLLECTION STACK_ID ENDPOINT STACK_NAME COMPOSE_PATH ENV_FILE <<< "$STACK_INFO"

        echo -e "${CYAN}[$((i+1))/$PHASE2_COUNT]${NC} Migrating: $STACK_NAME (ID: $STACK_ID)"

        if [ "$DRY_RUN" = true ]; then
            info "Would migrate: $STACK_NAME"
            info "  Secret: $SECRET"
            info "  Stack ID: $STACK_ID"
            info "  Compose: $COMPOSE_PATH"
            info "  Env file: $ENV_FILE"
            echo ""
            continue
        fi

        # Run migration
        if echo "N" | "$MIGRATE_NONGIT" "$SECRET" "$COLLECTION" "$STACK_ID" "$ENDPOINT" "$STACK_NAME" "$COMPOSE_PATH" "$ENV_FILE" > /tmp/migration-$STACK_NAME.log 2>&1; then
            success "$STACK_NAME migrated successfully"
            ((PHASE2_SUCCESS++))
        else
            error "$STACK_NAME migration failed"
            warn "See /tmp/migration-$STACK_NAME.log for details"
            ((PHASE2_FAILED++))
        fi
        echo ""
    done

    echo ""
    header "Phase 2 Summary"
    success "Successful: $PHASE2_SUCCESS"
    if [ $PHASE2_FAILED -gt 0 ]; then
        error "Failed: $PHASE2_FAILED"
    fi
    echo ""
fi

# ==============================================================================
# PHASE 3: Existing Git Stacks
# ==============================================================================

PHASE3_STACKS=(
    # VM 100 (emby)
    "portainer-api-token-vm-100|shared|1|3|watchtower|stacks/watchtower/docker-compose.yml"
    "portainer-api-token-vm-100|shared|2|3|newt|stacks/newt/docker-compose.yml"

    # VM 101 (downloads)
    "portainer-api-token-vm-101|shared|2|3|downloads|stacks/downloads/docker-compose.yml"
    "portainer-api-token-vm-101|shared|5|3|watchtower|stacks/watchtower/docker-compose.yml"

    # VM 103 (misc)
    "portainer-api-token-vm-103|shared|8|3|vaultwarden|stacks/vaultwarden/docker-compose.yml"
    "portainer-api-token-vm-103|shared|9|3|watchtower|stacks/watchtower/docker-compose.yml"
    "portainer-api-token-vm-103|shared|10|3|newt|stacks/newt/docker-compose.yml"
    "portainer-api-token-vm-103|shared|11|3|audiobookshelf|stacks/audiobookshelf/docker-compose.yml"
    "portainer-api-token-vm-103|shared|12|3|navidrome|stacks/navidrome/docker-compose.yml"
)

if [[ "$PHASE" == "3" || "$PHASE" == "all" ]]; then
    header "PHASE 3: Migrating Existing Git Stacks"
    echo ""

    PHASE3_COUNT=${#PHASE3_STACKS[@]}
    PHASE3_SUCCESS=0
    PHASE3_FAILED=0

    for (( i=0; i<$PHASE3_COUNT; i++ )); do
        STACK_INFO="${PHASE3_STACKS[$i]}"
        IFS='|' read -r SECRET COLLECTION STACK_ID ENDPOINT STACK_NAME COMPOSE_PATH <<< "$STACK_INFO"

        echo -e "${CYAN}[$((i+1))/$PHASE3_COUNT]${NC} Migrating: $STACK_NAME (ID: $STACK_ID)"

        if [ "$DRY_RUN" = true ]; then
            info "Would migrate: $STACK_NAME"
            info "  Secret: $SECRET"
            info "  Stack ID: $STACK_ID"
            info "  Compose: $COMPOSE_PATH"
            echo ""
            continue
        fi

        # Run migration
        if "$MIGRATE_GIT" "$SECRET" "$COLLECTION" "$STACK_ID" "$ENDPOINT" "$STACK_NAME" main > /tmp/migration-$STACK_NAME.log 2>&1; then
            success "$STACK_NAME migrated successfully"
            ((PHASE3_SUCCESS++))
        else
            error "$STACK_NAME migration failed"
            warn "See /tmp/migration-$STACK_NAME.log for details"
            ((PHASE3_FAILED++))
        fi
        echo ""
    done

    echo ""
    header "Phase 3 Summary"
    success "Successful: $PHASE3_SUCCESS"
    if [ $PHASE3_FAILED -gt 0 ]; then
        error "Failed: $PHASE3_FAILED"
    fi
    echo ""
fi

# ==============================================================================
# Final Summary
# ==============================================================================

echo ""
echo -e "${GREEN}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  Migration Complete!                                           ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════════════╝${NC}"
echo ""

if [ "$DRY_RUN" = true ]; then
    info "This was a dry run. Run without --dry-run to perform migrations."
else
    success "All migrations completed"
    info "All stacks are now using the monorepo with GitOps enabled"
    echo ""
    info "Next steps:"
    info "  1. Verify all stacks are running correctly"
    info "  2. Delete backup stacks when confident"
    info "  3. Monitor GitOps auto-updates (5min interval)"
fi

echo ""
exit 0
