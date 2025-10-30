#!/bin/bash
#
# bw-setup-session.sh
#
# Purpose: Setup Bitwarden CLI session for use with Claude Code
#
# This script helps establish a BW_SESSION that Claude Code can access.
# Run this once per work session after unlocking Bitwarden.
#
# Usage:
#   ./scripts/utils/bw-setup-session.sh
#
# What it does:
# 1. Checks if BW_SESSION is set in your current shell
# 2. If not, prompts you to unlock Bitwarden
# 3. Stores session token in ~/.bw-session (chmod 600)
# 4. Provides commands for Claude Code to use

set -euo pipefail

SESSION_FILE="$HOME/.bw-session"

echo "=== Bitwarden CLI Session Setup for Claude Code ==="
echo ""

# Check if already unlocked in current shell
if [ -n "${BW_SESSION:-}" ]; then
    echo "✓ BW_SESSION already set in current shell"
    echo ""
    echo "Saving to $SESSION_FILE..."
    echo "$BW_SESSION" > "$SESSION_FILE"
    chmod 600 "$SESSION_FILE"
    echo "✓ Session saved"
else
    echo "BW_SESSION not found in current shell."
    echo "Please unlock Bitwarden and export the session:"
    echo ""
    echo "  export BW_SESSION=\$(bw unlock --raw)"
    echo ""
    echo "Then run this script again."
    exit 1
fi

echo ""
echo "=== Setup Complete ==="
echo ""
echo "Claude Code can now use Bitwarden CLI with:"
echo "  export BW_SESSION=\$(cat ~/.bw-session) && bw <command>"
echo ""
echo "This session will remain valid until you:"
echo "  - Run: bw lock"
echo "  - Session expires"
echo "  - Delete: rm ~/.bw-session"
echo ""
