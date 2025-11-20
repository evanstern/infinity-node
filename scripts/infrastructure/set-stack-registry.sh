#!/bin/bash
#
# set-stack-registry.sh
#
# Ensure a Portainer stack references the GHCR registry and optionally redeploy it.
#
set -euo pipefail

usage() {
  cat <<'EOF' >&2
Usage: set-stack-registry.sh --portainer-secret NAME --collection NAME --stack-id ID --endpoint-id ID [options]

Required:
  --portainer-secret NAME   Vaultwarden item containing the Portainer API token
  --collection NAME         Vaultwarden collection for the Portainer secret
  --stack-id ID             Portainer stack ID to update
  --endpoint-id ID          Portainer endpoint ID hosting the stack

Options:
  --registry-name NAME      Registry name (default: ghcr)
  --registry-url URL        Registry URL (default: https://ghcr.io)
  --registry-username USER  Registry username (default: evanstern)
  --pat-secret NAME         Vaultwarden item containing PAT (default: portainer-github-pat)
  --pat-collection NAME     Collection for PAT secret (default: same as --collection)
  --pat-field NAME          Field holding PAT value (default: PAT)
  --no-redeploy             Skip the git pull / redeploy after updating
EOF
}

PORTAINER_SECRET=""
COLLECTION=""
STACK_ID=""
ENDPOINT_ID=""
REGISTRY_NAME="ghcr"
REGISTRY_URL="https://ghcr.io"
REGISTRY_USERNAME="evanstern"
PAT_SECRET="portainer-github-pat"
PAT_COLLECTION=""
PAT_FIELD="PAT"
REDEPLOY=true

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
    --stack-id)
      STACK_ID="$2"
      shift 2
      ;;
    --endpoint-id)
      ENDPOINT_ID="$2"
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
    --no-redeploy)
      REDEPLOY=false
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

if [[ -z "$PORTAINER_SECRET" || -z "$COLLECTION" || -z "$STACK_ID" || -z "$ENDPOINT_ID" ]]; then
  usage
  exit 1
fi

if [[ -z "$PAT_COLLECTION" ]]; then
  PAT_COLLECTION="$COLLECTION"
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENSURE_REGISTRY_SCRIPT="$SCRIPT_DIR/ensure-ghcr-registry.sh"
GET_SECRET="$SCRIPT_DIR/../secrets/get-vw-secret.sh"

if [[ ! -x "$ENSURE_REGISTRY_SCRIPT" ]]; then
  echo "Missing helper script: $ENSURE_REGISTRY_SCRIPT" >&2
  exit 1
fi

API_TOKEN=$("$GET_SECRET" "$PORTAINER_SECRET" "$COLLECTION" "password")
PORTAINER_URL=$("$GET_SECRET" "$PORTAINER_SECRET" "$COLLECTION" "url")

if [[ -z "$API_TOKEN" || -z "$PORTAINER_URL" ]]; then
  echo "Failed to retrieve Portainer credentials" >&2
  exit 1
fi

REGISTRY_ID=$("$ENSURE_REGISTRY_SCRIPT" \
  --portainer-secret "$PORTAINER_SECRET" \
  --collection "$COLLECTION" \
  --registry-name "$REGISTRY_NAME" \
  --registry-url "$REGISTRY_URL" \
  --registry-username "$REGISTRY_USERNAME" \
  --pat-secret "$PAT_SECRET" \
  --pat-collection "$PAT_COLLECTION" \
  --pat-field "$PAT_FIELD")

if [[ -z "$REGISTRY_ID" ]]; then
  echo "Could not determine GHCR registry ID" >&2
  exit 1
fi

STACK_JSON=$(curl -sk -H "X-API-Key: $API_TOKEN" "$PORTAINER_URL/api/stacks/$STACK_ID")

if [[ -z "$STACK_JSON" ]]; then
  echo "Unable to fetch stack $STACK_ID" >&2
  exit 1
fi

UPDATED_STACK=$(echo "$STACK_JSON" | jq -c --argjson rid "$REGISTRY_ID" '.RegistryId = $rid')

curl -sk -X PUT \
  -H "X-API-Key: $API_TOKEN" \
  -H "Content-Type: application/json" \
  "$PORTAINER_URL/api/stacks/$STACK_ID" \
  -d "$UPDATED_STACK" >/dev/null

if [[ "$REDEPLOY" == true ]]; then
  curl -sk -X POST \
    -H "X-API-Key: $API_TOKEN" \
    "$PORTAINER_URL/api/stacks/$STACK_ID/git/pull?endpointId=$ENDPOINT_ID" >/dev/null
fi

echo "Updated stack $STACK_ID to use registry ID $REGISTRY_ID"
