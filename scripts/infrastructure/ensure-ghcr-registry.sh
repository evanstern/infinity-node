#!/bin/bash
#
# ensure-ghcr-registry.sh
#
# Ensure a GHCR registry entry exists in Portainer and return its ID.
#
# Requirements:
#   - BW_SESSION exported (see docs/SECRET-MANAGEMENT.md)
#   - jq, curl installed
#   - scripts/secrets/get-vw-secret.sh available
#
# Usage:
#   ./ensure-ghcr-registry.sh \
#     --portainer-secret portainer-api-token-vm-103 \
#     --collection shared
#
set -euo pipefail

usage() {
  cat <<'EOF' >&2
Usage: ensure-ghcr-registry.sh --portainer-secret NAME --collection NAME [options]

Required:
  --portainer-secret NAME   Vaultwarden item containing the Portainer API token
  --collection NAME         Vaultwarden collection for the Portainer secret

Options:
  --registry-name NAME      Portainer registry name (default: ghcr)
  --registry-url URL        Registry URL (default: https://ghcr.io)
  --registry-username USER  Registry username (default: evanstern)
  --pat-secret NAME         Vaultwarden item containing the PAT (default: portainer-github-pat)
  --pat-collection NAME     Collection for the PAT (default: same as --collection)
  --pat-field NAME          Field inside PAT secret (default: PAT)
EOF
}

PORTAINER_SECRET=""
COLLECTION=""
REGISTRY_NAME="ghcr"
REGISTRY_URL="https://ghcr.io"
REGISTRY_USERNAME="evanstern"
PAT_SECRET="portainer-github-pat"
PAT_COLLECTION=""
PAT_FIELD="PAT"

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
GET_SECRET="$SCRIPT_DIR/../secrets/get-vw-secret.sh"

if [[ ! -x "$GET_SECRET" ]]; then
  echo "Missing helper script: $GET_SECRET" >&2
  exit 1
fi

API_TOKEN=$("$GET_SECRET" "$PORTAINER_SECRET" "$COLLECTION" "password")
PORTAINER_URL=$("$GET_SECRET" "$PORTAINER_SECRET" "$COLLECTION" "url")

if [[ -z "$API_TOKEN" || -z "$PORTAINER_URL" ]]; then
  echo "Failed to retrieve Portainer credentials" >&2
  exit 1
fi

REGISTRIES=$(curl -sk -H "X-API-Key: $API_TOKEN" "$PORTAINER_URL/api/registries")

if [[ -z "$REGISTRIES" ]]; then
  echo "Unable to query existing registries from Portainer" >&2
  exit 1
fi

NORMALIZED_TARGET=$(echo "$REGISTRY_URL" | sed -E 's#^https?://##' | sed 's:/*$::')

REGISTRY_ID=$(echo "$REGISTRIES" | jq -r --arg name "$REGISTRY_NAME" --arg url "$NORMALIZED_TARGET" '
  .[] |
  .Id as $id |
  (.Name // "") as $n |
  (((.URL // "") | sub("^https?://";"") | rtrimstr("/")) // "") as $u |
  select(($n == $name) or ($u == $url)) |
  $id' | head -n1)

if [[ -n "$REGISTRY_ID" && "$REGISTRY_ID" != "null" ]]; then
  echo -n "$REGISTRY_ID"
  exit 0
fi

# Need to create the registry entry
PAT_VALUE=$("$GET_SECRET" "$PAT_SECRET" "$PAT_COLLECTION" "$PAT_FIELD")

if [[ -z "$PAT_VALUE" ]]; then
  echo "Failed to retrieve GitHub PAT" >&2
  exit 1
fi

CREATE_PAYLOAD=$(jq -n \
  --arg name "$REGISTRY_NAME" \
  --arg url "$REGISTRY_URL" \
  --arg user "$REGISTRY_USERNAME" \
  --arg pass "$PAT_VALUE" \
  '{
      Name: $name,
      URL: $url,
      Authentication: true,
      Username: $user,
      Password: $pass,
      Type: 2
    }')

RESPONSE=$(curl -sk -X POST \
  -H "X-API-Key: $API_TOKEN" \
  -H "Content-Type: application/json" \
  "$PORTAINER_URL/api/registries" \
  -d "$CREATE_PAYLOAD")

if [[ -z "$RESPONSE" ]]; then
  echo "Failed to create GHCR registry entry" >&2
  exit 1
fi

REGISTRY_ID=$(echo "$RESPONSE" | jq -r '.Id // .id // empty')

if [[ -z "$REGISTRY_ID" ]]; then
  echo "Portainer did not return a registry ID. Response: $RESPONSE" >&2
  exit 1
fi

echo -n "$REGISTRY_ID"
