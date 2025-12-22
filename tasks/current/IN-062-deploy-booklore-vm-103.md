---
type: task
task-id: IN-062
status: in-progress
priority: 4
category: docker
agent: docker
created: 2025-12-22
updated: 2025-12-22
started: 2025-12-22
completed:

# Task classification
complexity: moderate
estimated_duration: 3-5h
critical_services_affected: false
requires_backup: true
requires_downtime: false

# Design tracking
alternatives_considered: true
risk_assessment_done: true
phased_approach: true

tags:
  - task
  - vm-103
  - docker
  - stack
  - booklore
  - ebooks
  - traefik
  - vaultwarden
---

# Task: IN-062 - Deploy BookLore on VM 103 (misc)

> **Quick Summary**: Deploy BookLore (BookLore + MariaDB) on VM-103 with persistent storage, secrets in Vaultwarden, and mandatory Traefik routing at `booklore.local.infinity-node.win`.

## Problem Statement

**What problem are we solving?**
We want a self-hosted digital library experience for ebooks/comics/PDFs with multi-user support, metadata, OPDS, and BookDrop imports. BookLore provides this and should run on VM-103 (misc) alongside other non-critical services.

**Why now?**
- Add a modern “books” stack that complements existing media services without impacting critical VMs (Emby/downloads/arr).
- Standardize deployment using our Portainer + Git workflow and Vaultwarden for secrets.
- Enable BookDrop imports from the NAS-backed path for easier ingestion.

**Who benefits?**
- **Household users**: Browse/read/manage books in a modern web UI.
- **Operator (Evan)**: Repeatable stack deployment, documented ops, consistent secrets handling.

## Solution Design

### Recommended Approach

Deploy BookLore using the upstream Docker images and the upstream “Set Up Your docker-compose.yml Configuration” guidance, adapted to infinity-node conventions:
- Create a new stack directory: `stacks/booklore/`
- Add `docker-compose.yml` + `.env.example` (no secrets committed)
- Store DB passwords in Vaultwarden (automated via CLI scripts)
- Deploy as a Git-based Portainer stack on VM-103
- Add mandatory Traefik route + Pi-hole DNS record so `booklore.local.infinity-node.win` works port-free

**Upstream reference:** BookLore repo + Docker section: [BookLore](https://github.com/booklore-app/BookLore)

**Key components:**
- **BookLore app container**: `booklore/booklore:latest`
- **MariaDB container**: `lscr.io/linuxserver/mariadb:11.4.5`
- **Traefik routing**: file-provider routes on VM-103 (`stacks/traefik/vm-103/dynamic.yml`) deployed to `/home/evan/.config/traefik/`
- **Secrets**: stored in Vaultwarden under `infinity-node/vm-103-misc/`

**Rationale**: This matches our infrastructure pattern (`stacks/*`, Portainer GitOps, Vaultwarden secrets) and minimizes custom work while keeping persistence and routing consistent with existing VM-103 services.

> [!abstract]- 🔀 Alternative Approaches Considered
>
> **Option A: Expose BookLore via direct port only (no Traefik)**
> - ✅ Pros: simplest routing
> - ❌ Cons: violates requirement (Traefik routing mandatory), inconsistent UX vs other VM-103 services
> - **Decision**: Not chosen
>
> **Option B: Traefik via Docker labels instead of file-provider**
> - ✅ Pros: less manual editing of `dynamic.yml`
> - ❌ Cons: current VM-103 Traefik is file-provider-first and uses manual `scp` sync; adding labels would diverge from established ops
> - **Decision**: Not chosen (keep consistent)
>
> **Option C: Use external MariaDB (shared DB)**
> - ✅ Pros: fewer containers
> - ❌ Cons: increases coupling/blast radius; harder to back up/restore independently
> - **Decision**: Not chosen (keep DB scoped to stack)

### Scope Definition

**✅ In Scope:**
- Create `stacks/booklore/docker-compose.yml` and `stacks/booklore/.env.example`
- Store BookLore DB credentials in Vaultwarden (automated creation + retrieval)
- Create `stacks/booklore/README.md` documenting deployment, secrets, ops
- Create Portainer Git stack on VM-103 and deploy
- Add DNS record + Traefik route for `booklore.local.infinity-node.win` (mandatory)
- Basic validation (UI reachable, DB healthy, persistence across restart)

**❌ Explicitly Out of Scope:**
- External access via Pangolin / public domain
- Deep BookLore feature configuration (Kobo sync tuning, advanced auth/OIDC)
- Automated backups/restore pipeline (can be follow-up task if needed)

**🎯 MVP (Minimum Viable)**:
BookLore is reachable at `http://booklore.local.infinity-node.win` (or `https` if later enabled), can import at least one test book, persists data across container restart, and secrets are stored in Vaultwarden (not in git).

## Risk Assessment

### Potential Pitfalls

- ⚠️ **Risk 1: Host path permissions cause app/db failures** → **Mitigation**: Verify UID/GID, pre-create directories, confirm read/write before deploy.
- ⚠️ **Risk 2: Port conflict on VM-103 (6060)** → **Mitigation**: Check port availability; prefer Traefik routing; if needed, adjust published host port without changing internal app port.
- ⚠️ **Risk 3: Traefik route breaks due to container DNS name mismatch** → **Mitigation**: Set `container_name: booklore` (recommended) or confirm actual container name on `traefik-network` and match in `dynamic.yml`.
- ⚠️ **Risk 4: Bookdrop folder is not mounted/writable** → **Mitigation**: Verify `/mnt/video/Books/Bookdrop` is mounted on VM-103 and writable by container UID/GID; test with a copied sample file first.
- ⚠️ **Risk 5: Secrets accidentally committed** → **Mitigation**: Only commit `.env.example`; keep real `.env` in a temp path; audit diffs for secrets before commit.

### Dependencies

**Prerequisites (must exist before starting):**
- [ ] **VM-103 reachable and healthy** - SSH works; Docker + Portainer running (blocking: yes)
- [ ] **Traefik running on VM-103** - `traefik` container healthy; file-provider config mount path is `/home/evan/.config/traefik` (blocking: yes)
- [ ] **Vaultwarden reachable for CLI** - Bitwarden CLI configured to `http://vaultwarden.local.infinity-node.win:8111` and vault can be unlocked (blocking: yes)
- [ ] **Pi-hole admin access** - credentials in Vaultwarden `shared/pihole-admin` for adding DNS record (blocking: yes)

**Has blocking dependencies**: VM-103 + Traefik + Vaultwarden + Pi-hole access required.

### Critical Service Impact

**Services Affected**: None of the “critical” services (Emby/downloads/arr). Work is limited to VM-103 and its Traefik routing file.

### Rollback Plan

**Applicable for**: docker + routing config

**How to rollback if this goes wrong:**
1. In Portainer (VM-103), stop/remove the `booklore` stack (or revert stack env vars) and confirm containers are gone.
2. Revert `stacks/traefik/vm-103/dynamic.yml` changes in git and re-`scp` the previous `dynamic.yml` back to `/home/evan/.config/traefik/dynamic.yml`.
3. If any host directories were created, leave them in place (safe) or archive/remove if desired (ensure no valuable data inside first).

**Recovery time estimate**: 5–15 minutes.

**Backup requirements:**
- Snapshot/copy any existing content in `/mnt/video/Books/Bookdrop` before enabling automated import if you’re unsure how BookLore handles files.
- If reusing an existing `/home/evan/booklore` library, back it up before first run.

## Execution Plan

### Phase 0: Discovery & Preflight (VM-103) — mandatory

**Primary Agent**: `infrastructure`

- [ ] **Confirm VM-103 resources + disk space** `[agent:infrastructure]`
  - Run `./scripts/validation/check-vm-disk-space.sh` (or manually `df -h`) and confirm VM-103 has headroom for DB + library metadata.
  - Confirm Docker is healthy: `ssh evan@vm-103.local.infinity-node.win "docker ps"`.

- [ ] **Verify required host paths exist and are writable** `[agent:infrastructure]` `[risk:1]` `[risk:4]`
  - Ensure these directories exist on VM-103 (create if missing):
    - `/home/evan/data/booklore/data`
    - `/home/evan/data/booklore/marianadb/config`
    - `/home/evan/booklore`
  - Confirm NAS mount exists: `/mnt/video/Books/Bookdrop`
  - Verify write access with a non-destructive test (e.g., create/remove a temp file).

- [ ] **Confirm UID/GID values to use for containers** `[agent:infrastructure]` `[risk:1]`
  - On VM-103: `id -u evan` and `id -g evan`
  - Use these for `APP_USER_ID/APP_GROUP_ID` and `DB_USER_ID/DB_GROUP_ID` in `.env.example` (default likely 1000/1000).

### Phase 1: Secrets (Vaultwarden) — mandatory

**Primary Agent**: `security`

- [ ] **Create BookLore DB secrets in Vaultwarden (automated)** `[agent:security]` `[risk:5]`
  - Collection: `vm-103-misc`
  - Item name: `booklore-secrets`
  - Fields to store (custom fields recommended):
    - `service`: `booklore`
    - `vm`: `103`
    - `db_password`: (generated)
    - `mysql_root_password`: (generated)
  - Generate strong passwords locally (examples):
    - `openssl rand -base64 36 | tr -d '=/+' | head -c 32`
  - Create item using our script:
    - `./scripts/secrets/create-secret.sh "booklore-secrets" "vm-103-misc" "" '{"service":"booklore","vm":"103","db_password":"<generated>","mysql_root_password":"<generated>"}'`
  - Retrieve as needed (recommended helper script):
    - `export BW_SESSION=$(cat ~/.bw-session)` (or `export BW_SESSION=$(bw unlock --raw)`)
    - `DB_PASSWORD=$(./scripts/secrets/get-vw-secret.sh "booklore-secrets" "vm-103-misc" "db_password")`
    - `MYSQL_ROOT_PASSWORD=$(./scripts/secrets/get-vw-secret.sh "booklore-secrets" "vm-103-misc" "mysql_root_password")`

> [!note]
> Vaultwarden CLI access requires direct port access; see [[docs/SECRET-MANAGEMENT]].

### Phase 2: Stack configuration in git (`stacks/booklore/`) — mandatory

**Primary Agent**: `docker`

- [ ] **Create `stacks/booklore/.env.example`** `[agent:docker]`
  - Follow BookLore’s “Set Up Your docker-compose.yml Configuration” section as the baseline: [BookLore](https://github.com/booklore-app/BookLore)
  - Required values (per request):
    - `TZ=America/New_York`
    - Volumes documented (see compose below)
  - Include Vaultwarden references (no real secrets), similar to `stacks/n8n/.env.example`:
    - `DB_PASSWORD=PLACEHOLDER_RETRIEVE_FROM_VAULTWARDEN`
    - `MYSQL_ROOT_PASSWORD=PLACEHOLDER_RETRIEVE_FROM_VAULTWARDEN`
  - Keep defaults for non-secret values (adjust as needed):
    - `BOOKLORE_PORT=6060`
    - `DB_USER=booklore`
    - `MYSQL_DATABASE=booklore`

- [ ] **Create `stacks/booklore/docker-compose.yml`** `[agent:docker]` `[risk:2]` `[risk:3]`
  - Services:
    - `booklore` (image `booklore/booklore:latest`)
    - `mariadb` (image `lscr.io/linuxserver/mariadb:11.4.5`)
  - Must include requested volume mappings:
    - BookLore:
      - `/home/evan/data/booklore/data:/app/data`
      - `/home/evan/booklore:/books`
      - `/mnt/video/Books/Bookdrop:/bookdrop`
    - MariaDB:
      - `/home/evan/data/booklore/marianadb/config:/config`
  - Must join `traefik-network` (external) for `booklore` service so Traefik can reach it.
  - Recommended: set `container_name: booklore` to make Traefik upstream stable.
  - Include DB healthcheck + `depends_on: condition: service_healthy` as in upstream docs.

- [ ] **Create `stacks/booklore/README.md`** `[agent:docker]`
  - Include:
    - Access: `http://booklore.local.infinity-node.win` (Traefik) and optional direct port if exposed
    - Secrets table (Vaultwarden item + fields)
    - Ops: logs, restart, persistence test, basic backup notes

### Phase 3: Mandatory DNS + Traefik routing (git + manual sync to VM-103)

**Primary Agent**: `infrastructure` (DNS) + `docker` (Traefik config)

- [ ] **Add Pi-hole DNS record (mandatory)** `[agent:infrastructure]`
  - Add: `booklore.local.infinity-node.win` → `192.168.1.103`
  - Follow [[docs/runbooks/pihole-dns-management]] (manual UI entry is currently the expected method).
  - Verify: `dig +short booklore.local.infinity-node.win` returns `192.168.1.103`.

- [ ] **Add Traefik route in repo (mandatory)** `[agent:docker]`
  - Edit: `stacks/traefik/vm-103/dynamic.yml`
  - Add router:
    - `Host(\`booklore.local.infinity-node.win\`)` → service `booklore`
  - Add service:
    - URL should match container DNS on `traefik-network`
    - Preferred if `container_name: booklore`: `http://booklore:6060`
    - If not using `container_name`, confirm actual container name and use that (similar to Linkwarden’s note in `dynamic.yml`).

- [ ] **Manual sync Traefik configs to VM-103 (mandatory)** `[agent:docker]`
  - We *do not* rely on Portainer Git update for these files on VM-103.
  - Copy both files to VM-103:
    - `scp stacks/traefik/vm-103/dynamic.yml evan@vm-103.local.infinity-node.win:/home/evan/.config/traefik/dynamic.yml`
    - `scp stacks/traefik/vm-103/traefik.yml evan@vm-103.local.infinity-node.win:/home/evan/.config/traefik/traefik.yml`
  - Confirm Traefik reloads:
    - Check Traefik logs for config reload (or restart Traefik stack via Portainer if unsure).

### Phase 4: Portainer deployment (VM-103) — mandatory

**Primary Agent**: `docker`

- [ ] **Create a real `.env` (not committed) from Vaultwarden** `[agent:docker]` `[risk:5]`
  - Copy `stacks/booklore/.env.example` → a safe temp location (avoid committing by accident), e.g. `/tmp/booklore.env`
  - Populate secrets from Vaultwarden:
    - `DB_PASSWORD` from `booklore-secrets:db_password`
    - `MYSQL_ROOT_PASSWORD` from `booklore-secrets:mysql_root_password`
  - Keep `TZ=America/New_York`

- [ ] **Create/deploy the Portainer Git stack** `[agent:docker]`
  - Preferred: use `./scripts/infrastructure/create-git-stack.sh` from your local repo checkout:
    - Stack name: `booklore`
    - Compose path: `stacks/booklore/docker-compose.yml`
    - Endpoint: VM-103 (typically endpoint id `3` for local Portainer instance)
  - Alternative: Portainer UI (Stacks → Add stack → Repository), then set env vars from `/tmp/booklore.env`.

- [ ] **Verify stack health** `[agent:docker]`
  - Use `./scripts/infrastructure/verify-stack-health.sh "portainer-api-token-vm-103" "shared" "booklore" 3`
  - Confirm `booklore` and `mariadb` containers are running and healthy.

### Phase 5: Validation & Testing — mandatory

**Primary Agent**: `testing`

- [ ] **Validate routing + UI access** `[agent:testing]`
  - Confirm DNS resolves: `dig +short booklore.local.infinity-node.win`
  - Confirm Traefik routing works (port-free):
    - Browser: `http://booklore.local.infinity-node.win`
    - CLI: `curl -I -H "Host: booklore.local.infinity-node.win" http://vm-103.local.infinity-node.win/`

- [ ] **Validate persistence** `[agent:testing]` `[risk:1]`
  - Create a small test library entry / import one test book.
  - Restart stack (Portainer “Restart” / “Pull and redeploy”) and verify data remains.

- [ ] **Validate BookDrop** `[agent:testing]` `[risk:4]`
  - Copy a test file into `/mnt/video/Books/Bookdrop` (use a copy, not an original).
  - Confirm BookLore detects/processes it as expected.

### Phase 6: Documentation — mandatory

**Primary Agent**: `documentation`

- [ ] **Update architecture/service inventory docs** `[agent:documentation]`
  - Add BookLore to `docs/ARCHITECTURE.md` VM-103 services list (or appropriate section).
  - Ensure `stacks/booklore/README.md` is complete and accurate.

## Acceptance Criteria

**Done when all of these are true:**
- [ ] `stacks/booklore/docker-compose.yml` exists and matches requested volumes + timezone
- [ ] `stacks/booklore/.env.example` exists with placeholders and Vaultwarden references (no secrets)
- [ ] Vaultwarden contains `booklore-secrets` in `vm-103-misc` with required fields
- [ ] Pi-hole DNS record exists and resolves `booklore.local.infinity-node.win` → `192.168.1.103`
- [ ] Traefik routes `booklore.local.infinity-node.win` to BookLore successfully (port-free access)
- [ ] BookLore UI is reachable and usable
- [ ] Restart test passes and data persists
- [ ] All execution plan items completed
- [ ] Testing Agent validates (see testing plan below)
- [ ] Changes committed with descriptive message (awaiting user approval)

## Testing Plan

**[[docs/agents/TESTING|Testing Agent]] validates:**
- DNS resolution for `booklore.local.infinity-node.win`
- Traefik routing works and returns a valid HTTP response
- Portainer stack containers healthy
- Persistence across restart
- BookDrop workflow works with a copied test file

**Manual validation:**
1. Load `http://booklore.local.infinity-node.win` and confirm UI loads.
2. Import a test book and confirm it appears in library.
3. Restart the stack, re-open UI, confirm the imported book remains.

## Related Documentation

- [[docs/SECRET-MANAGEMENT|Secret Management]]
- [[docs/runbooks/pihole-dns-management|Pi-hole DNS Management]]
- [[stacks/traefik/vm-103/README|Traefik (VM-103)]]
- [[docs/agents/DOCKER|Docker Agent]]
- [[docs/agents/SECURITY|Security Agent]]
- [[docs/agents/TESTING|Testing Agent]]
- Upstream: [BookLore](https://github.com/booklore-app/BookLore)

## Notes

**Priority Rationale**:
Medium priority: adds a useful household service without impacting critical services.

**Complexity Rationale**:
Moderate: new multi-container stack + secrets + mandatory DNS/Traefik routing + Portainer deployment.

**Implementation Notes**:
- Traefik on VM-103 uses manual `scp` to `/home/evan/.config/traefik` for `dynamic.yml` and `traefik.yml`—do not skip this step.
- Prefer stable BookLore upstream reference name `booklore` for Traefik backend resolution.

**Follow-up Tasks**:
- Create a backup/restore automation for BookLore (optional future task if used heavily).

---

> [!note]- 📋 Work Log
>
> **YYYY-MM-DD - Started**
> - TODO: What was accomplished
> - TODO: Important decisions made
> - TODO: Issues encountered and resolved
>
> **YYYY-MM-DD - Completed**
> - TODO: What was accomplished
> - TODO: Important decisions made
>
> [!tip]- 💡 Lessons Learned
>
> *Fill this in AS YOU GO during task execution. Not every task needs extensive notes here, but capture important learnings that could affect future work.*
>
> **What Worked Well:**
> - TODO: What patterns/approaches were successful that we should reuse?
>
> **What Could Be Better:**
> - TODO: What would we do differently next time?
>
> **Key Discoveries:**
> - TODO: Did we learn something that affects other systems/services?
>
> **Scope Evolution:**
> - TODO: How did the scope change from original plan and why?
>
> **Follow-Up Needed:**
> - TODO: Documentation that should be updated based on this work
