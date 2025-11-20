#!/usr/local/bin/bash
#
# sync-ghcr-stacks.sh
#
# Detect stacks that pull from ghcr.io and update them to use the GHCR registry.
#
set -euo pipefail

COLOR_GREEN='\033[0;32m'
COLOR_YELLOW='\033[1;33m'
COLOR_RED='\033[0;31m'
COLOR_RESET='\033[0m'

log_info() {
  echo -e "${COLOR_GREEN}[INFO]${COLOR_RESET} $*" >&2
}

log_warn() {
  echo -e "${COLOR_YELLOW}[WARN]${COLOR_RESET} $*" >&2
}

log_error() {
  echo -e "${COLOR_RED}[ERROR]${COLOR_RESET} $*" >&2
}

usage() {
  cat <<'EOF' >&2
Usage: sync-ghcr-stacks.sh --portainer-secret NAME --collection NAME [--endpoint-id ID | --endpoint-name NAME] [options]

Required:
  --portainer-secret NAME   Vaultwarden item with Portainer API token
  --collection NAME         Vaultwarden collection containing the token

Endpoint (choose one):
  --endpoint-id ID          Portainer endpoint ID to redeploy against
  --endpoint-name NAME      Portainer endpoint name to look up (auto-detect if single endpoint when omitted)

Options:
  --compose-root PATH       Root directory to scan (default: stacks)
  --registry-name NAME      Registry name (default: ghcr)
  --registry-url URL        Registry URL (default: https://ghcr.io)
  --registry-username USER  Registry username (default: evanstern)
  --pat-secret NAME         Vaultwarden item with PAT (default: portainer-github-pat)
  --pat-collection NAME     Collection for PAT item (default: same as --collection)
  --pat-field NAME          Field within PAT item (default: PAT)
  --dry-run                 Show actions without calling the API
EOF
}

PORTAINER_SECRET=""
COLLECTION=""
ENDPOINT_ID=""
ENDPOINT_NAME=""
COMPOSE_ROOT="stacks"
REGISTRY_NAME="ghcr"
REGISTRY_URL="https://ghcr.io"
REGISTRY_USERNAME="evanstern"
PAT_SECRET="portainer-github-pat"
PAT_COLLECTION=""
PAT_FIELD="PAT"
DRY_RUN=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --portainer-secret)
      PORTAINER_SECRET="$2"
      shift 2
      ;;
    --collection)
      COLLECTION="$2"
      shift 2
      ;;
    --endpoint-id)
      ENDPOINT_ID="$2"
      shift 2
      ;;
    --endpoint-name)
      ENDPOINT_NAME="$2"
      shift 2
      ;;
    --compose-root)
      COMPOSE_ROOT="$2"
      shift 2
      ;;
    --registry-name)
      REGISTRY_NAME="$2"
      shift 2
      ;;
    --registry-url)
      REGISTRY_URL="$2"
      shift 2
      ;;
    --registry-username)
      REGISTRY_USERNAME="$2"
      shift 2
      ;;
    --pat-secret)
      PAT_SECRET="$2"
      shift 2
      ;;
    --pat-collection)
      PAT_COLLECTION="$2"
      shift 2
      ;;
    --pat-field)
      PAT_FIELD="$2"
      shift 2
      ;;
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage
      exit 1
      ;;
  esac
done

if [[ -z "$PORTAINER_SECRET" || -z "$COLLECTION" ]]; then
  usage
  exit 1
fi

if [[ -z "$PAT_COLLECTION" ]]; then
  PAT_COLLECTION="$COLLECTION"
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SET_STACK_SCRIPT="$SCRIPT_DIR/set-stack-registry.sh"
GET_SECRET="$SCRIPT_DIR/../secrets/get-vw-secret.sh"

if [[ ! -x "$SET_STACK_SCRIPT" ]]; then
  log_error "Missing helper script: $SET_STACK_SCRIPT"
  exit 1
fi

if [[ ! -x "$GET_SECRET" ]]; then
  log_error "Missing helper script: $GET_SECRET"
  exit 1
fi

log_info "Retrieving Portainer credentials from Vaultwarden item '$PORTAINER_SECRET' (collection '$COLLECTION')"
API_TOKEN=$("$GET_SECRET" "$PORTAINER_SECRET" "$COLLECTION" "password")
PORTAINER_URL=$("$GET_SECRET" "$PORTAINER_SECRET" "$COLLECTION" "url")

log_info "Querying Portainer stacks from $PORTAINER_URL"
if ! STACKS_JSON=$(curl -sk -H "X-API-Key: $API_TOKEN" "$PORTAINER_URL/api/stacks"); then
  log_error "curl failed while querying stacks at $PORTAINER_URL/api/stacks"
  exit 1
fi

if [[ -z "$STACKS_JSON" ]]; then
  log_error "Empty response while querying Portainer stacks"
  exit 1
fi

if ! echo "$STACKS_JSON" | jq empty >/dev/null 2>&1; then
  log_error "Non-JSON response while querying stacks (check Portainer URL/port). Snippet:"
  echo "$STACKS_JSON" | head -c 300 >&2
  echo >&2
  exit 1
fi

STACK_COUNT=$(echo "$STACKS_JSON" | jq 'length')
if [[ "$STACK_COUNT" -eq 0 ]]; then
  log_warn "No stacks returned from Portainer; ensure Git stacks are configured for this endpoint"
fi
log_info "Retrieved $STACK_COUNT stack(s) from Portainer"

if [[ -z "$ENDPOINT_ID" ]]; then
  log_info "Endpoint ID not provided; querying Portainer endpoints"
  if ! ENDPOINTS_JSON=$(curl -sk -H "X-API-Key: $API_TOKEN" "$PORTAINER_URL/api/endpoints"); then
    log_error "curl failed while querying endpoints at $PORTAINER_URL/api/endpoints"
    exit 1
  fi

  if [[ -z "$ENDPOINTS_JSON" ]]; then
    log_error "Empty response while querying Portainer endpoints; specify --endpoint-id manually"
    exit 1
  fi

  if ! echo "$ENDPOINTS_JSON" | jq empty >/dev/null 2>&1; then
    log_error "Non-JSON response while querying endpoints. Snippet:"
    echo "$ENDPOINTS_JSON" | head -c 300 >&2
    echo >&2
    exit 1
  fi

  if [[ -n "$ENDPOINT_NAME" ]]; then
    ENDPOINT_ID=$(echo "$ENDPOINTS_JSON" | jq -r --arg name "$ENDPOINT_NAME" '.[] | select(.Name == $name) | .Id' | head -n1)
    if [[ -z "$ENDPOINT_ID" || "$ENDPOINT_ID" == "null" ]]; then
      log_error "Endpoint named '$ENDPOINT_NAME' not found in Portainer; available: $(echo "$ENDPOINTS_JSON" | jq -r '.[].Name' | paste -sd ', ' -)"
      exit 1
    fi
  else
    ENDPOINT_COUNT=$(echo "$ENDPOINTS_JSON" | jq 'length')
    if [[ "$ENDPOINT_COUNT" -eq 1 ]]; then
      ENDPOINT_ID=$(echo "$ENDPOINTS_JSON" | jq -r '.[0].Id')
    else
      log_error "Multiple endpoints detected; specify --endpoint-id or --endpoint-name. Available endpoints:"
      echo "$ENDPOINTS_JSON" | jq -r '.[] | "  - \(.Id): \(.Name)"' >&2
      exit 1
    fi
  fi
fi

log_info "Using endpoint ID $ENDPOINT_ID"
UPDATED=0
SKIPPED=0
CHECKED=0

while IFS= read -r stack_json; do
  CONFIG_PATH=$(echo "$stack_json" | jq -r '.GitConfig.ConfigFilePath // empty')
  STACK_ID=$(echo "$stack_json" | jq -r '.Id')
  STACK_NAME=$(echo "$stack_json" | jq -r '.Name')
  ((CHECKED++)) || true

  if [[ -z "$CONFIG_PATH" ]]; then
    log_warn "Stack '$STACK_NAME' (ID $STACK_ID) has no GitConfig path; skipping"
    ((SKIPPED++)) || true
    continue
  fi

  if [[ ! -f "$CONFIG_PATH" ]]; then
    log_warn "Compose file '$CONFIG_PATH' for stack '$STACK_NAME' not found locally; skipping"
    ((SKIPPED++)) || true
    continue
 fi

  if ! rg -q 'ghcr\.io' "$CONFIG_PATH"; then
    log_info "Stack '$STACK_NAME' does not reference ghcr.io; skipping"
    continue
  fi

  log_info "Stack '$STACK_NAME' references ghcr.io (compose: $CONFIG_PATH)"

  if [[ "$DRY_RUN" == true ]]; then
    log_info "DRY-RUN: would update stack '$STACK_NAME' (ID $STACK_ID)"
    ((UPDATED++)) || true
    continue
  fi

  log_info "Updating stack '$STACK_NAME' (ID $STACK_ID) to use registry '$REGISTRY_NAME'"
  "$SET_STACK_SCRIPT" \
    --portainer-secret "$PORTAINER_SECRET" \
    --collection "$COLLECTION" \
    --stack-id "$STACK_ID" \
    --endpoint-id "$ENDPOINT_ID" \
    --registry-name "$REGISTRY_NAME" \
    --registry-url "$REGISTRY_URL" \
    --registry-username "$REGISTRY_USERNAME" \
    --pat-secret "$PAT_SECRET" \
    --pat-collection "$PAT_COLLECTION" \
    --pat-field "$PAT_FIELD"

  log_info "Stack '$STACK_NAME' updated successfully"
  ((UPDATED++)) || true
done < <(echo "$STACKS_JSON" | jq -c '.[]')

log_info "Checked $CHECKED stack(s). Updated $UPDATED. Skipped $SKIPPED (no compose or unmapped)."

# If any stacks were updated (non-dry-run), prompt user to verify in Portainer UI and suggest follow-up with redeploy if necessary.
if [[ "$UPDATED" -gt 0 && "$DRY_RUN" == false ]]; then
  log_info "One or more stacks were updated to use the '$REGISTRY_NAME' registry."
  log_info "For best practices: verify stack status and service health in the Portainer UI."
  log_info "If stacks require a manual redeploy or additional validation, follow MDTD checklist and document in the work log."
fi
