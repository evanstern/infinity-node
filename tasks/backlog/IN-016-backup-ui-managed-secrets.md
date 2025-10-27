---
type: task
task-id: IN-016
status: pending
priority: 2
category: security
agent: security
created: 2025-10-26
updated: 2025-10-26
tags:
  - task
  - security
  - secrets
  - automation
  - backup
---

# Task: IN-016 - Backup and Automate UI-Managed Secrets

<!-- Priority Scale: 0 (critical/urgent) → 1-2 (high) → 3-4 (medium) → 5-6 (low) → 7-9 (very low) -->

## Description

Establish automated backup and code-as-config strategy for secrets managed through service UIs rather than environment variables. These secrets (API keys, admin passwords) are auto-generated and stored in service config files/databases, making them vulnerable to volume loss.

**Philosophy:** Shift from UI-only management to code-as-config wherever possible using APIs and configuration file management.

## Context

During IN-002 secret inventory, we identified 7 services that manage secrets through UI rather than docker-compose:

**arr Services (VM 102):**
- radarr, sonarr, lidarr, prowlarr, jellyseerr
- Auto-generate API keys on first run
- Store in `/config/config.xml` or similar
- API keys used for inter-service communication
- Currently: If volume lost, secrets lost forever

**Infrastructure Services:**
- portainer (VM 103): Admin password set on first run
- emby (VM 100): Configured via UI

**Risk:** Volume corruption/loss = lose all secrets, break inter-service communication, require full reconfiguration.

**Goal:** Automate backup AND enable infrastructure-as-code for these services where APIs allow.

## Proposed Automation Strategies

### Strategy 1: API-Based Secret Extraction (PREFERRED)

Most modern services expose APIs to read configuration. We can:
- Query API for current secrets
- Store in Vaultwarden automatically
- Optionally: Pre-seed secrets via API on deployment

**Services with APIs:**
- ✅ Radarr: API for config management
- ✅ Sonarr: API for config management
- ✅ Lidarr: API for config management
- ✅ Prowlarr: API for config management
- ✅ Jellyseerr: API available
- ⚠️ Portainer: API exists, admin password can't be extracted (hash only)
- ⚠️ Emby: API exists, but auth is token-based

**Example Workflow:**
```bash
# Extract radarr API key
API_KEY=$(curl -s http://radarr:7878/api/v3/config/host | jq -r '.apiKey')

# Store in Vaultwarden
./scripts/secrets/create-secret.sh "radarr-api-key" "$API_KEY" "vm-102-arr"

# Future: Pre-seed on deployment
# curl -X PUT http://radarr:7878/api/v3/config/host -d '{"apiKey": "'$API_KEY'"}'
```

### Strategy 2: Config File Parsing

For services without good APIs or where API doesn't expose secrets:
- Parse config files (XML, JSON, TOML)
- Extract secrets programmatically
- Store in Vaultwarden

**Example:**
```bash
# Extract from radarr config.xml if API not available
xmllint --xpath "//ApiKey/text()" /path/to/config.xml
```

### Strategy 3: Manual Extraction + Documentation

Fallback for services where automation isn't feasible:
- Document exact location of secrets in config
- Manual backup process
- Schedule regular checks

## Acceptance Criteria

### Phase 1: Investigation & Documentation
- [ ] Research APIs for each service (radarr, sonarr, lidarr, prowlarr, jellyseerr)
- [ ] Document API endpoints for secret retrieval
- [ ] Test API access with current deployments
- [ ] Identify which secrets can be pre-seeded via API
- [ ] Document config file locations and formats for fallback

### Phase 2: Script Development
- [ ] Create `scripts/secrets/extract-ui-secrets.sh`
  - Service name as parameter
  - Try API first, fall back to config parsing
  - Store in Vaultwarden automatically
- [ ] Create `scripts/secrets/seed-ui-secrets.sh`
  - Pre-seed secrets from Vaultwarden on deployment (where APIs allow)
  - Enable infrastructure-as-code for these services
- [ ] Add to `scripts/README.md`

### Phase 3: Backup All Secrets
- [ ] Extract and backup radarr API key
- [ ] Extract and backup sonarr API key
- [ ] Extract and backup lidarr API key
- [ ] Extract and backup prowlarr API key
- [ ] Extract and backup jellyseerr API key
- [ ] Document portainer admin password location (hash only, not extractable)
- [ ] Document emby authentication approach
- [ ] Verify all secrets stored in Vaultwarden with proper folders/labels

### Phase 4: Automation & Monitoring
- [ ] Schedule periodic backup (cron job or similar)
- [ ] Implement drift detection (has secret changed since last backup?)
- [ ] Alert on changes (optional, but good for security)
- [ ] Document manual process for portainer/emby if automation not possible

### Phase 5: Infrastructure-as-Code Migration (Stretch Goal)
- [ ] Test pre-seeding secrets on fresh deployment
- [ ] Update deployment runbooks to include secret seeding
- [ ] Document API-based configuration management
- [ ] Consider: Can we deploy services with pre-configured secrets?

## Dependencies

- [[tasks/current/IN-002-migrate-secrets-to-env|IN-002]] - .env migration (understand overall secret strategy)
- Vaultwarden accessible and healthy
- SSH access to all VMs
- Service APIs need to be available (most are)

## Testing Plan

[[docs/agents/TESTING|Testing Agent]] should validate:

**For Each Service:**
- [ ] Can extract secret via script
- [ ] Secret stored in Vaultwarden correctly
- [ ] Can retrieve secret from Vaultwarden
- [ ] Service continues functioning after secret extraction
- [ ] (Stretch) Can re-deploy service with pre-seeded secret

**Integration Tests:**
- [ ] Arr services can communicate after secret backup/restore
- [ ] Prowlarr → Radarr/Sonarr/Lidarr connections work
- [ ] API endpoints are accessible from script runner

## Related Documentation

- [[docs/agents/SECURITY|Security Agent]]
- [[docs/SECRET-MANAGEMENT|Secret Management]]
- [[docs/ARCHITECTURE|Architecture]] - Service locations
- [[tasks/current/IN-002-migrate-secrets-to-env|IN-002]] - Related secret work

## Notes

### API Research Notes
*To be populated during Phase 1*

**Radarr API:**
- Endpoint: `GET /api/v3/config/host`
- Auth: `X-Api-Key` header (chicken-egg: need key to get key)
- Alternative: Parse `config.xml` on first backup

**Sonarr API:**
- Similar to Radarr (same underlying framework)

### Automation Ideas

**Idea 1: First-Run Hook**
- Detect when service first starts
- Wait for API key generation
- Immediately backup to Vaultwarden
- No manual intervention needed

**Idea 2: Deployment Template**
- Generate secrets in Vaultwarden FIRST
- Seed via API on deployment
- True infrastructure-as-code

**Idea 3: Periodic Drift Check**
```bash
# Check if current secret matches Vaultwarden
current_key=$(get_api_key_from_service)
stored_key=$(get_secret_from_vaultwarden "radarr-api-key")

if [ "$current_key" != "$stored_key" ]; then
  # Alert or update
fi
```

### Questions to Resolve

1. **Can arr services accept pre-configured API keys?**
   - Or do they HAVE to auto-generate on first run?
   - Research: LinuxServer.io container environment variables

2. **Portainer admin password:**
   - Stored as bcrypt hash
   - Can't extract plaintext
   - Alternative: Store password in Vaultwarden when we SET it
   - Or: Accept that admin password is manual-only

3. **Frequency of backup:**
   - Daily? Weekly?
   - After any UI change? (drift detection)
   - On-demand via script?

4. **Secret rotation strategy:**
   - Should we rotate arr API keys regularly?
   - If yes, need to update all dependent services
   - This task enables rotation (know where they all are)

### Stretch Goals

- **GitOps Integration:** Secrets in Vaultwarden → Deploy services with correct config
- **Drift Detection:** Alert if UI-changed secret doesn't match Vaultwarden
- **Automated Rotation:** Rotate arr API keys on schedule, update all dependents
- **Terraform/Ansible:** Could this be part of IaC tool?

---

**Priority Rationale:** High priority (2) because volume loss would be catastrophic for arr stack coordination. Should be done before major infrastructure changes but after IN-002 and IN-017 (Vaultwarden backup).
