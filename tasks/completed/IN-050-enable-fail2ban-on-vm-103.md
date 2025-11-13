---
type: task
task-id: IN-050
status: completed
priority: 2
category: security
agent: security
created: 2025-11-13
updated: 2025-11-13
started: 2025-11-13
completed: 2025-11-13

# Task classification
complexity: moderate
estimated_duration: 4-6h
critical_services_affected: false
requires_backup: false
requires_downtime: false

# Design tracking
alternatives_considered: true
risk_assessment_done: true
phased_approach: true

tags:
  - task
  - security
  - vm-103
  - navidrome
  - fail2ban
---

# Task: IN-050 - Enable fail2ban on VM-103

> **Quick Summary**: Harden VM-103 before exposing Navidrome publicly by deploying a containerised fail2ban stack, wiring in service logs, and validating ban behaviour.

## Problem Statement

**What problem are we solving?**
Navidrome (and several other services) on VM-103 currently rely on Pangolin tunnels for gated external access. The plan is to expose Navidrome directly to the internet, but VM-103 has no active intrusion throttling. Without fail2ban, repeated credential stuffing attempts against Navidrome (or other HTTP endpoints on Traefik) will go unchecked, greatly increasing compromise risk.

**Why now?**
- Navidrome will soon be reachable without Pangolin authentication, removing the existing protection layer.
- VM-103 hosts sensitive services (Vaultwarden, Paperless-NGX) that would benefit from consistent brute-force detection.
- Implementing fail2ban now enables time for tuning before DNS/port-forwarding changes go live.

**Who benefits?**
- **Household users**: Safer access to Navidrome with reduced breach risk.
- **Security Agent**: Establishes a repeatable hardening pattern for other VMs.
- **Infrastructure team**: Provides monitoring hooks for suspicious traffic prior to wider exposure.

## Solution Design

### Recommended Approach

Deploy the LinuxServer.io `fail2ban` container as a dedicated stack on VM-103, managed via Portainer GitOps. Provide custom configuration under `stacks/fail2ban/config` to ingest Navidrome and Traefik access logs, define a Navidrome-specific jail, and emit bans through iptables. Update Traefik and Navidrome logging so fail2ban can parse reliable, file-based logs, then validate operation with controlled login failures.

**Key components:**
- Component 1: `stacks/fail2ban/docker-compose.yml` using `lscr.io/linuxserver/fail2ban`, `NET_ADMIN`/`NET_RAW`, mapped `/config`, `/var/log`, and service log mounts.
- Component 2: Custom jail and filter files (`stacks/fail2ban/config/jail.d/navidrome.conf`, `stacks/fail2ban/config/filter.d/navidrome-traefik.conf`) tuned for Navidrome and Traefik JSON access logs.
- Component 3: Logging adjustments (Navidrome config to persist auth failures under `/home/evan/data/navidrome/logs/`, Traefik `accessLog.filePath` to `/home/evan/logs/traefik/access.log`) to give fail2ban stable inputs.

**Rationale**: Using the LinuxServer container keeps configuration aligned with the rest of the Git-managed stacks, avoids manually installing packages on the VM, and mirrors existing patterns documented for Emby hardening. Leveraging Traefik logs covers all HTTP ingress, while Navidrome-specific logs ensure direct-port monitoring if required.

> [!abstract]- 🔀 Alternative Approaches Considered
>
> **Option A: Host-level fail2ban installation**
> - ✅ Pros: No extra container overhead, direct systemd integration.
> - ✅ Pros: Mature documentation for Debian-based hosts.
> - ❌ Cons: Breaks with GitOps workflow; manual package management drifts from reproducible state.
> - ❌ Cons: Harder to version-control filters and share across VMs.
> - **Decision**: Not chosen - prefer containerised, declarative deployment.
>
> **Option B: Rely on Traefik middlewares (rate limiting/IP whitelist)**
> - ✅ Pros: No additional containers; native to reverse proxy.
> - ✅ Pros: Centralised request throttling for multiple services.
> - ❌ Cons: Does not block direct port forwards; limited persistence/visibility for security monitoring.
> - ❌ Cons: No automatic unban workflow and weaker response to distributed attacks.
> - **Decision**: Not chosen - lacks adaptive banning and does not protect non-Traefik entry points.
>
> **Option C: LinuxServer fail2ban container (chosen)**
> - ✅ Pros: Supports cap-add iptables usage in Docker, integrates with Portainer Git stacks.
> - ✅ Pros: Configuration stored in repo; easy to replicate across VMs.
> - ❌ Cons: Requires careful log mounting and Portainer capability support.
> - **Decision**: ✅ CHOSEN - aligns with GitOps, portable across hosts, minimal host modifications.

### Scope Definition

**✅ In Scope:**
- Create a `fail2ban` stack (compose, README, `.env.example`) for VM-103 with required capabilities and mounts.
- Add Navidrome/Trafik jail + filter definitions and ensure log files are generated and mounted read-only.
- Validate fail2ban bans/unbans against Navidrome login attempts and document operational procedures.

**❌ Explicitly Out of Scope:**
- Extending fail2ban coverage to other VMs or services (arr stack, downloads) in this task.
- Implementing HTTPS/TLS for Traefik or Navidrome (tracked separately).
- Replacing Pangolin tunnels or reworking external DNS beyond what is necessary for testing.

**🎯 MVP (Minimum Viable)**:
Fail2ban container running on VM-103 with Navidrome jail active, observing both Traefik and Navidrome logs, banning abusive IPs after configurable thresholds, and providing clear rollback/operational guidance.

## Risk Assessment

### Potential Pitfalls

- ⚠️ **Risk 1: Portainer cap_add limitations** → **Mitigation**: Validate Portainer version supports `NET_ADMIN/NET_RAW`; if not, plan CLI deployment fallback and document manual steps.

- ⚠️ **Risk 2: Log format mismatch leading to missed bans** → **Mitigation**: Capture sample Navidrome and Traefik log entries, iterate regex via `fail2ban-regex`, include JSON-specific patterns, and add monitoring to detect zero matches.

- ⚠️ **Risk 3: Legitimate users blocked by aggressive thresholds** → **Mitigation**: Start with moderate retry/bantime values (e.g., 5 attempts / 1h), document unban workflow, and whitelist trusted home IP ranges.

- ⚠️ **Risk 4: iptables rules impacting other services** → **Mitigation**: Use multiport rules scoped to relevant ports (80, 443, 4533), test connectivity post-ban removal, and capture `iptables-save` before/after for rollback reference.

### Dependencies

**Prerequisites (must exist before starting):**
- [x] **Confirm Traefik access log file path works in container** - Ensure `accessLog.filePath` writes to mounted host path (blocking: yes)
- [x] **Navidrome log file availability** - Validate `navidrome.toml` (or env) supports persistent auth failure logging (blocking: yes)
- [ ] **Router/port-forward plan** - Coordinate with Infrastructure agent on which ports will be exposed so ban actions cover correct entry points (blocking: no)

**Has blocking dependencies** - Cannot proceed until log file locations are verified.

### Critical Service Impact

**Services Affected**: Navidrome (VM-103), Traefik (VM-103 shared proxy)

No critical services (Emby/Downloads/Arr) are directly touched, but Traefik changes affect multiple ancillary services. Careful testing ensures no unintended downtime.

### Rollback Plan

**Applicable for**: security / docker

**How to rollback if this goes wrong:**
1. Disable fail2ban stack via Portainer (or `docker stack rm`) to remove iptables rules.
2. Revert Traefik/Navidrome logging changes by restoring previous compose/config files and redeploy.
3. Flush any remaining fail2ban chains with `iptables -F f2b-*` and confirm service reachability.

**Recovery time estimate**: 30 minutes.

**Backup requirements:**
- Snapshot `stacks/fail2ban/config` directory before major regex changes.
- Retain copies of previous Traefik and Navidrome config files (`git stash` or manual backup) prior to deployment.

## Execution Plan

### Phase 0: Discovery & Log Verification

**Primary Agent**: `security`

- [x] **Collect sample Navidrome + Traefik log entries** `[agent:security]` `[blocking]`
  - Trigger failed logins and confirm file-based logs contain client IP + status codes.
  - Adjust Navidrome config if file logging not enabled.

- [x] **Validate host log mount strategy** `[agent:infrastructure]`
  - Confirm permissions on `/home/evan/logs/` and `/home/evan/data/navidrome/logs/`.
  - Ensure read-only mounts suffice for fail2ban.

### Phase 1: Stack & Logging Configuration

**Primary Agent**: `docker`

- [x] **Add fail2ban stack definition** `[agent:docker]`
  - Create `stacks/fail2ban/docker-compose.yml`, `.env.example`, README.
  - Include `cap_add`, `PUID/PGID`, TZ, volume mounts (`/config`, log directories).

- [x] **Update Navidrome & Traefik logging** `[agent:docker]` `[depends:Phase 0]`
  - Configure Navidrome log path (e.g., `/data/logs/navidrome.log`) and ensure persistence.
  - Add Traefik `accessLog.filePath` and create host directory with rotation plan.

### Phase 2: Fail2ban Configuration & Deployment

**Primary Agent**: `security`

- [x] **Write jail/filter configuration** `[agent:security]` `[risk:2]`
  - Create `stacks/fail2ban/config/jail.d/navidrome.conf` with thresholds and actions.
  - Create `stacks/fail2ban/config/filter.d/navidrome-traefik.conf` with JSON regex.

- [x] **Deploy and tune fail2ban** `[agent:security]`
  - Redeploy stack via Portainer Git pull.
  - Use `fail2ban-regex` + log samples to verify matches; adjust as needed.

### Phase 3: Validation & Testing

**Primary Agent**: `testing`

- [x] **Simulate brute-force attempts** `[agent:testing]` `[risk:3]`
  - Execute repeated failed logins via Traefik and direct port (if exposed).
  - Confirm `fail2ban-client status navidrome` shows bans and IP is blocked.

- [x] **Verify unban workflow** `[agent:testing]`
  - Document `fail2ban-client set navidrome unbanip` procedure and confirm access restored.

### Phase 4: Documentation & Handoff

**Primary Agent**: `documentation`

- [x] **Update security runbooks** `[agent:documentation]`
  - Record fail2ban deployment steps, log locations, and monitoring commands in relevant docs (`docs/runbooks/`).
  - Add references to `stacks/fail2ban` README and usage notes.

## Acceptance Criteria

**Done when all of these are true:**
- [x] Fail2ban stack deployed on VM-103 via Portainer with container running healthy.
- [x] Navidrome/Traefik logs accessible to fail2ban and matching regex patterns (verified with `fail2ban-regex`).
- [x] Automated bans trigger after configured retries and blocks prevent further login attempts.
- [x] Unban procedure tested and documented; no collateral blocking of household IPs during validation.
- [x] All execution plan items completed
- [x] Testing Agent validates (see testing plan below)
- [ ] Changes committed with descriptive message (awaiting user approval)

## Testing Plan

**[[docs/agents/TESTING|Testing Agent]] validates:**
- Simulated failed Navidrome logins (HTTP 401) produce ban entries in `fail2ban-client status`.
- Attempting access from banned IP fails (curl returns timeout/connection reset).
- Unban command restores access and logs show removal.
- No unrelated services (Vaultwarden, Paperless, etc.) report connectivity loss.

**Manual validation:**
1. Attempt 6 incorrect Navidrome logins from a test IP; expect ban logged within findtime window.
2. Run `fail2ban-client status navidrome` to verify IP in ban list and note bantime expiration.
3. Execute `fail2ban-client set navidrome unbanip <IP>` and confirm immediate restored access.

## Related Documentation

- [[stacks/navidrome/README|Navidrome Stack]]
- [[stacks/traefik/vm-103/README|Traefik VM-103 Stack]]
- [[docs/agents/SECURITY|Security Agent]]
- [[docs/runbooks/emby-external-access-security|Emby External Access Security]] (reference fail2ban procedures)
- https://docs.linuxserver.io/images/docker-fail2ban/
- https://github.com/linuxserver/fail2ban-confs/blob/master/README.md

## Notes

**Priority Rationale**:
Exposing Navidrome without Pangolin removes a key security layer; fail2ban must be in place before the exposure to mitigate brute-force threats.

**Complexity Rationale**:
Moderate due to cross-stack configuration (Traefik + Navidrome), custom regex authoring, and Portainer capability considerations, but contained to a single VM.

**Implementation Notes**:
- Capture example Traefik JSON log lines early to accelerate regex tuning.
- Consider log rotation for `/home/evan/logs/traefik` to avoid disk pressure.
- Coordinate with Infrastructure before router/firewall changes to ensure ban coverage.

**Follow-up Tasks**:
- Draft new task to extend fail2ban coverage to Vaultwarden and Paperless login endpoints once Navidrome rollout stabilises.
- Draft new task to add alerting when fail2ban ban counts exceed defined thresholds.

---

> [!note]- 📋 Work Log
>
> **2025-11-13 - Task Created**
> - Drafted fail2ban enablement plan for VM-103.
> - Captured risks, scope, and execution phases.
>
> **2025-11-13 - Phase 0 Discovery**
> - Created sample Traefik JSON and Navidrome auth log entries under `stacks/fail2ban/config/samples/` for regex development.
> - Confirmed need for shared host directories (`/home/evan/logs/traefik`, `/home/evan/data/navidrome/logs`) to support fail2ban mounts.
> - Validated overall task plan after pre-task review; ready to begin stack/config authoring.
>
> **2025-11-13 - Phase 1 Logging Prep**
> - Added Traefik access log file output and volume mount for `/home/evan/logs/traefik`.
> - Wrapped Navidrome entrypoint with `stdbuf ... | tee -a /data/logs/navidrome.log` so logs persist alongside docker stdout.
> - Documented Navidrome log location in stack README for fail2ban reference.
>
> **2025-11-13 - Phase 2 Fail2ban Config**
> - Authored `navidrome-traefik` and `navidrome-auth` filters plus dual-jail config targeting `DOCKER-USER`.
> - Captured testing instructions and mount expectations in `stacks/fail2ban/config/README.md`.
> - Reused sample logs for `fail2ban-regex` validation guidance.
>
> **2025-11-13 - Deployment**
> - Coordinated Portainer redeploy of updated Navidrome/Traefik/fail2ban stacks after log mount verification.
> - Ran `fail2ban-regex` inside container against sample and live logs to confirm matches.
> - Simulated failed logins via Traefik; observed expected ban entries in both jails and documented unban procedure test.
> - Testing Agent witnessed ban/unban cycle remotely and confirmed no collateral service impact.
>
> **2025-11-13 - Phase 4 Documentation & Handoff**
> - Authored `docs/runbooks/navidrome-external-access-security.md` with deployment, validation, and rollback procedures.
> - Captured follow-up items for scripting the Navidrome start wrapper distribution and alerting enhancements.

> [!tip]- 💡 Lessons Learned
>
> **What Worked Well:**
> - LinuxServer fail2ban container slotted into Portainer Git workflow cleanly; config-only changes redeploy without touching the host OS.
> - Mirroring Navidrome stdout to `/data/logs/navidrome.log` via FIFO+`tee` preserved exit codes while giving fail2ban dependable log files.
>
> **What Could Be Better:**
> - Host-level script distribution needs a consistent pattern; captured action item to publish `/home/evan/scripts/navidrome-start.sh` directly from the repo to avoid manual copies.
>
> **Key Discoveries:**
> - Traefik v3 access logs still require `bufferingSize` tuning—100 worked best to flush entries quickly enough for fail2ban to react inside the findtime window.
> - Dual actions (`INPUT` and `DOCKER-USER`) are necessary so bans hit both direct 4533 traffic and routed ingress.
>
> **Scope Evolution:**
> - Added second jail targeting Navidrome’s native log alongside the Traefik-derived jail to cover future direct-port exposure.
>
> **Follow-Up Needed:**
> - Automate distribution of the Navidrome start wrapper (consider `scripts/deploy-navidrome-start.sh` or Portainer bind to repo file).
> - Add monitoring hook to alert when ban counts spike, so the security agent gets proactive visibility.
