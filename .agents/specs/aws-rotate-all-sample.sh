#!/usr/bin/env bash
set -euo pipefail

LOG_DIR="${HOME}/.aws-rotate-logs"
mkdir -p "$LOG_DIR"
TS="$(date --iso-8601=seconds 2>/dev/null || date +%Y-%m-%dT%H:%M:%S%z)"
LOGFILE="$LOG_DIR/rotate-$TS.log"
exec > >(tee -a "$LOGFILE") 2>&1

PROFILES=(ausgovstg ausgovprd)      # <- add your profiles here
BACKUP_DIR="$HOME/.aws/credentials-backup"
mkdir -p "$BACKUP_DIR"

echo "Starting AWS rotate run at $TS"

for prof in "${PROFILES[@]}"; do
  echo "---- Profile: $prof ----"
  # snapshot credentials
  CREDFILE="${HOME}/.aws/credentials"
  if [[ -f "$CREDFILE" ]]; then
    cp "$CREDFILE" "$BACKUP_DIR/credentials-$prof-$TS" || true
  fi

  # run rotation (assumes aws-rotate-key exits non-zero on failure)
  if ! aws-rotate-key -profile "$prof"; then
    echo "ERROR: aws-rotate-key failed for $prof" >&2
    exit 2
  fi

  # small delay to let credentials settle
  sleep 2

  # verify new creds by calling STS
  if ! AWS_PROFILE="$prof" aws sts get-caller-identity --output json >/dev/null; then
    echo "ERROR: verification failed for profile $prof. Restoring previous credentials." >&2
    # attempt restore from last backup for this run (best-effort)
    latest_backup=$(ls -1t "$BACKUP_DIR"/credentials-"$prof"-* 2>/dev/null | head -n1 || true)
    if [[ -n "$latest_backup" ]]; then
      cp "$latest_backup" "$CREDFILE"
      echo "Restored credentials from $latest_backup"
    fi
    exit 3
  fi

  echo "Success: rotated & verified $prof"
done

echo "All profiles rotated successfully at $(date --iso-8601=seconds 2>/dev/null || date)"
# Optional: trigger a desktop notification (macOS)
if command -v osascript >/dev/null; then
  osascript -e 'display notification "AWS keys rotated" with title "aws-rotate-key"'
fi