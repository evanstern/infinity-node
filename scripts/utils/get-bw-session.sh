#!/usr/bin/env bash
# get-bw-session.sh - Get Bitwarden session token for Claude Code
#
# This script unlocks Bitwarden and outputs a session token that can be
# provided to Claude Code for accessing secrets during work sessions.
#
# Usage:
#   ./get-bw-session.sh
#
# Process:
#   1. Run this script
#   2. Copy the session token (the long string after "BW_SESSION=")
#   3. Tell Claude: "Here's the BW_SESSION: <paste token>"
#   4. Claude will then be able to use bw commands during the session
#
# Security Note:
#   - Session tokens expire after ~30 minutes of inactivity
#   - Don't commit session tokens to git
#   - Don't share session tokens outside the current work session

set -euo pipefail

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Bitwarden Session Token Generator ===${NC}"
echo ""
echo "This will unlock your Bitwarden vault and generate a session token."
echo ""
echo -e "${YELLOW}Please enter your Bitwarden master password when prompted...${NC}"
echo ""

# Unlock and get session token
if ! SESSION=$(bw unlock --raw 2>&1); then
    echo ""
    echo -e "${RED}ERROR: Failed to unlock Bitwarden${NC}"
    echo "This usually means:"
    echo "  - Incorrect password"
    echo "  - Bitwarden CLI not configured"
    echo "  - Network connectivity issues"
    echo ""
    echo "Details: $SESSION"
    exit 1
fi

# Display the token in a copy-friendly format
echo -e "${GREEN}✓ Bitwarden unlocked successfully!${NC}"
echo ""
echo -e "${YELLOW}=== COPY THIS TOKEN ===${NC}"
echo ""
echo "$SESSION"
echo ""
echo -e "${YELLOW}=======================${NC}"
echo ""
echo -e "${BLUE}Instructions:${NC}"
echo "1. Copy the token above (the long alphanumeric string)"
echo "2. In Claude Code chat, paste:"
echo "   Here's the BW_SESSION: <paste token>"
echo ""
echo "Note: Token expires after ~30 minutes of inactivity"
echo ""
