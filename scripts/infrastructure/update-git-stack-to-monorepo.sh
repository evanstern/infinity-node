#!/bin/bash
set -e

# Script: update-git-stack-to-monorepo.sh
# Description: Updates an existing Git-based Portainer stack to point to the monorepo
# Usage: ./update-git-stack-to-monorepo.sh <vaultwarden-secret-name> <vaultwarden-collection> <stack-id> <endpoint-id> <stack-name> <new-compose-path>

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if required number of arguments provided
if [ "$#" -ne 6 ]; then
    echo -e "${RED}ERROR: Invalid number of arguments${NC}"
    echo "Usage: $0 <vaultwarden-secret-name> <vaultwarden-collection> <stack-id> <endpoint-id> <stack-name> <new-compose-path>"
    echo ""
    echo "Example:"
    echo "  $0 portainer-api-token-vm-100 shared 1 3 watchtower stacks/watchtower/docker-compose.yml"
    exit 1
fi

VAULTWARDEN_SECRET_NAME=$1
VAULTWARDEN_COLLECTION=$2
STACK_ID=$3
ENDPOINT_ID=$4
STACK_NAME=$5
NEW_COMPOSE_PATH=$6

# New monorepo URL (hardcoded since all stacks go to same place)
NEW_REPO_URL="https://github.com/evanstern/infinity-node"

echo -e "${BLUE}→ Retrieving Portainer credentials from Vaultwarden...${NC}"

# Get credentials from Vaultwarden
CREDS=$(bw get item "$VAULTWARDEN_SECRET_NAME" 2>/dev/null)
if [ $? -ne 0 ]; then
    echo -e "${RED}ERROR: Failed to retrieve credentials from Vaultwarden${NC}"
    exit 1
fi

PORTAINER_URL=$(echo "$CREDS" | jq -r '.fields[] | select(.name=="url") | .value')
API_TOKEN=$(echo "$CREDS" | jq -r '.login.password')

if [ -z "$PORTAINER_URL" ] || [ -z "$API_TOKEN" ]; then
    echo -e "${RED}ERROR: Missing Portainer URL or API token${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Retrieved credentials${NC}"

# Get current stack configuration
echo -e "${BLUE}→ Getting current stack configuration...${NC}"

CURRENT_STACK=$(curl -sk -X GET \
    -H "X-API-Key: $API_TOKEN" \
    "$PORTAINER_URL/api/stacks/$STACK_ID" 2>/dev/null)

if [ $? -ne 0 ]; then
    echo -e "${RED}ERROR: Failed to get current stack configuration${NC}"
    exit 1
fi

CURRENT_REPO=$(echo "$CURRENT_STACK" | jq -r '.GitConfig.URL // empty')
CURRENT_PATH=$(echo "$CURRENT_STACK" | jq -r '.EntryPoint // empty')

echo -e "${GREEN}✓ Current configuration:${NC}"
echo -e "  Repository: $CURRENT_REPO"
echo -e "  Compose path: $CURRENT_PATH"

# Update stack Git configuration
echo -e "${BLUE}→ Updating stack to monorepo...${NC}"
echo -e "${BLUE}→ New repository: $NEW_REPO_URL${NC}"
echo -e "${BLUE}→ New compose path: $NEW_COMPOSE_PATH${NC}"

UPDATE_RESPONSE=$(curl -sk -X PUT \
    -H "X-API-Key: $API_TOKEN" \
    -H "Content-Type: application/json" \
    "$PORTAINER_URL/api/stacks/$STACK_ID/git" \
    -d "{
        \"RepositoryURL\": \"$NEW_REPO_URL\",
        \"RepositoryReferenceName\": \"\",
        \"ComposeFilePathInRepository\": \"$NEW_COMPOSE_PATH\",
        \"RepositoryAuthentication\": false,
        \"Prune\": false,
        \"Env\": []
    }" 2>/dev/null)

if [ $? -ne 0 ]; then
    echo -e "${RED}ERROR: Failed to update stack configuration${NC}"
    exit 1
fi

# Check for errors in response
ERROR_MSG=$(echo "$UPDATE_RESPONSE" | jq -r '.message // .details // empty' 2>/dev/null)
if [ ! -z "$ERROR_MSG" ]; then
    echo -e "${RED}ERROR: $ERROR_MSG${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Stack updated successfully!${NC}"

# Redeploy the stack to pull from new repository
echo -e "${BLUE}→ Redeploying stack from new repository...${NC}"

REDEPLOY_RESPONSE=$(curl -sk -X PUT \
    -H "X-API-Key: $API_TOKEN" \
    -H "Content-Type: application/json" \
    "$PORTAINER_URL/api/stacks/$STACK_ID/git/redeploy?endpointId=$ENDPOINT_ID" \
    -d "{
        \"Prune\": false,
        \"PullImage\": false
    }" 2>/dev/null)

if [ $? -ne 0 ]; then
    echo -e "${RED}ERROR: Failed to redeploy stack${NC}"
    exit 1
fi

# Check for errors in response
ERROR_MSG=$(echo "$REDEPLOY_RESPONSE" | jq -r '.message // .details // empty' 2>/dev/null)
if [ ! -z "$ERROR_MSG" ]; then
    echo -e "${RED}ERROR: $ERROR_MSG${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Stack redeployed successfully!${NC}"
echo -e "${GREEN}✓ Stack '$STACK_NAME' (ID: $STACK_ID) now points to monorepo${NC}"
