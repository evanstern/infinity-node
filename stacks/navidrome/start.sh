#!/bin/sh

set -e

LOG_PIPE="/tmp/navidrome.log.pipe"

cleanup() {
    if [ -n "${TEE_PID:-}" ]; then
        kill "$TEE_PID" 2>/dev/null || true
    fi
    rm -f "$LOG_PIPE"
}
trap cleanup EXIT INT TERM

# Ensure log directory exists
mkdir -p /data/logs

# Create FIFO for tee so Navidrome exit status is preserved
rm -f "$LOG_PIPE"
mkfifo "$LOG_PIPE"

tee -a /data/logs/navidrome.log <"$LOG_PIPE" &
TEE_PID=$!

/app/navidrome "$@" >"$LOG_PIPE" 2>&1
NAV_EXIT=$?

wait "$TEE_PID" || true
exit "$NAV_EXIT"
