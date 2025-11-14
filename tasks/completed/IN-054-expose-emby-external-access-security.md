---
type: task
task-id: IN-054
status: completed
priority: 1
category: security
agent: security
created: 2025-11-13
updated: 2025-11-14
started: 2025-11-13
completed: 2025-11-14

# Task classification
complexity: complex
estimated_duration: 8-12h
critical_services_affected: true
requires_backup: true
requires_downtime: false
---

# Task: IN-054 - Expose Emby securely with Traefik + Fail2ban on VM-100

> **Quick Summary**: Publish Emby (VM-100) through Traefik with Pangolin removed while deploying a new fail2ban stack on the same VM to guard both Traefik and Emby logs, mirroring the hardened Navidrome/Kavita patterns but adapted for this critical service.

## Problem Statement

**What problem are we solving?**
Emby currently sits behind Pangolin tunnels on VM-100 and lacks any host-level intrusion throttling. Household members want native/external access, but exposing Emby without layered protections would invite credential stuffing against a critical media service. Unlike VM-103, VM-100 has no fail2ban stack or Traefik logging tuned for log-parsing bans, so we need a GitOps-managed security pattern before removing Pangolin.

**Why now?**
- Fail2ban pattern proven on VM-103 (IN-050) and slated for Kavita (IN-052); extending momentum to Emby keeps security posture consistent.
- Holiday travel requires reliable remote streaming without Pangolin prompts.
- VM-100 hosts the most critical media workload; delaying leaves it the only major stack without layered protections.

**Who benefits?**
- **Household users**: Seamless Emby access off-LAN with native clients.
- **Security & Media Agents**: Unified fail2ban deployment approach across VMs.
- **Infrastructure team**: Documented rollback/backups for a critical service exposure.

## Solution Design

### Recommended Approach

Deploy a dedicated LinuxServer fail2ban stack on VM-100 (Portainer GitOps), update VM-100 Traefik configuration to publish external/internal Emby routes with TLS, headers, and rate limiting, and wire both Traefik access logs and Emby application logs into fail2ban jails. Standard practice is to schedule the work during the 3‑6 AM low-usage window, but per user direction this effort may proceed immediately (household idle) while still capturing backups, validating bans/unbans, and documenting operations/rollback similar to IN-050.

**Key components:**
- Component 1: Reuse existing `stacks/fail2ban/docker-compose.yml` and create a VM-100-specific configuration bundle (Emby jails/filters, `.env.vm100`) copied to `/home/evan/.config/fail2ban` before deploying the stack via `scripts/infrastructure/create-git-stack.sh`.
- Component 2: Traefik stack updates (`stacks/traefik/vm-100/`) adding routers/services for `emby.infinity-node.com` + internal hostname, Pangolin removal, middleware chain, access log file output.
- Component 3: Emby logging adjustments (persistent auth/security logs) and documentation/runbooks capturing deployment, monitoring, rollback, lessons learned.

**Rationale**: Keeps security controls close to the workload, stays within GitOps/Portainer management, and replicates proven patterns without cross-VM dependencies.

> [!abstract]- 🔀 Alternative Approaches Considered
>
> **Option A: Centralize fail2ban on VM-103**
> - ✅ Pros: Reuses existing container, fewer stacks to manage.
> - ❌ Cons: Requires cross-VM log shipping, introduces WAN latency for bans, single point of failure.
> - **Decision**: Rejected — Emby deserves local enforcement with minimal dependencies.
>
> **Option B: Keep Pangolin + add Cloudflare Access**
> - ✅ Pros: Outsourced security, no new containers.
> - ❌ Cons: Retains Pangolin prompts (blocks native apps), adds SaaS dependency, diverges from GitOps model.
> - **Decision**: Rejected — does not meet usability goals and complicates ops.
>
> **Option C: Traefik exposure + local fail2ban (chosen)**
> - ✅ Pros: Full control, aligns with existing documentation, supports native clients, quick rollback.
> - ❌ Cons: Requires careful coordination to avoid downtime, new stack per VM.
> - **Decision**: ✅ Chosen — best balance of security and usability for a critical service.

### Scope Definition

**✅ In Scope:**
- VM-100 Traefik updates for Emby public/internal routes, middleware, TLS, logging.
- VM-100 fail2ban deployment package (Emby jails/filters, `.env`, docs) plus Portainer stack creation via `create-git-stack.sh`.
- Emby logging changes (auth/security logs) and operational runbooks/lessons.

**❌ Explicitly Out of Scope:**
- Pangolin decommissioning for other services.
- Emby feature upgrades, transcoder tuning, or library migrations.
- Alerting/monitoring automation (tracked as follow-up if needed).

**🎯 MVP (Minimum Viable)**:
Emby reachable externally with Pangolin removed, Traefik protections active, fail2ban on VM-100 banning abusive IPs via Traefik + Emby logs, backed by tested rollback and documentation.

## Risk Assessment

### Potential Pitfalls

- ⚠️ **Risk 1: Emby downtime during Traefik/fail2ban deployment**
  **Mitigation**: Normally schedule work 3‑6 AM; for this user-approved immediate window, still announce locally, perform pre/post smoke tests, and keep prior compose files for instant rollback.

- ⚠️ **Risk 2: Fail2ban regex misses Emby log patterns**
  **Mitigation**: Capture sample Traefik + Emby auth logs, iterate with `fail2ban-regex`, add unit-test samples to config repo.

- ⚠️ **Risk 3: False positives banning household IPs or Pangolin tunnel**
  **Mitigation**: Add trusted subnet allowlist, conservative `maxretry/bantime`, document unban workflow, test from multiple clients.

- ⚠️ **Risk 4: Resource strain on VM-100 (CPU/RAM/IO)**
  **Mitigation**: Baseline metrics pre-change, monitor container stats, adjust logging verbosity and jail count if needed.

- ⚠️ **Risk 5: Secrets/log data leakage**
  **Mitigation**: Keep `.env` templates only, ensure log mounts are read-only, verify no sensitive data committed.

### Dependencies

**Prerequisites (must exist before starting):**
- [ ] **Confirm VM-100 Traefik + Emby stack health** `[blocking]`
- [ ] **DNS + certificate readiness for Emby hostnames** `[blocking]`
- [ ] **Backup plan validated (Emby config + metadata)** `[blocking]`

**Has blocking dependencies** — cannot modify Traefik/fail2ban until health/DNS/backups confirmed.

### Critical Service Impact

**Services Affected**: Emby (CRITICAL, VM-100) — must maintain 99.9% uptime.
All changes still follow low-impact procedures (backups + rollback validation) even though the user waived the 3‑6 AM timing requirement for this execution.

### Rollback Plan

**Applicable for**: security / docker / infrastructure

1. Revert Traefik stack to previous git commit and redeploy via Portainer to restore Pangolin-protected routes.
2. Disable/remove VM-100 fail2ban stack in Portainer (or `docker stack rm`) to clear iptables rules.
3. Flush any remaining `f2b-*` chains (`iptables -F f2b-*`) and verify Emby accessibility.
4. Restore backed-up Emby config/log settings if logging changes caused issues.

**Recovery time estimate**: 20-30 minutes (Traefik rollback + fail2ban removal + validation).

**Backup requirements**:
- Snapshot Emby config/library metadata before changes (`/home/evan/data/emby` critical directories).
- Copy current Traefik VM-100 config directory for quick diff/restore.

## Execution Plan

### Phase 0: Discovery & Inventory
**Primary Agent**: `infrastructure`
- [x] **Audit current Emby + Traefik stack state** `[agent:infrastructure]` `[blocking]`
  - Confirmed compose paths, Pangolin middleware references, logging locations.
- [x] **Validate DNS/cert + maintenance window** `[agent:infrastructure]` `[blocking]`
  - DNS/cert readiness confirmed; user waived the 3‑6 AM window for this effort.
- [x] **Confirm backup/rollback artifacts** `[agent:infrastructure]`
  - Backups captured and rollback steps documented prior to changes.

### Phase 1: Traefik Exposure Updates
**Primary Agent**: `docker`
- [x] **Author Traefik config changes** `[agent:docker]` `[risk:1]`
  - Routers/services, TLS, middleware, and access-log destinations updated for VM-100.
- [x] **Plan and execute Portainer redeploy** `[agent:docker]`
  - Redeploy completed; smoke tests verified Traefik health and logging.

### Phase 2: Fail2ban Deployment
**Primary Agent**: `security`
- [x] **Author Emby filters/jails** `[agent:security]` `[risk:3]`
  - Traefik + Emby log regex, allowlist guidance, sample logs, `fail2ban-regex` instructions committed.
- [x] **Stage VM-100 fail2ban config bundle** `[agent:security]` `[risk:2]`
  - Emby-specific configs copied to `/home/evan/.config/fail2ban`; host paths validated.
- [x] **Instantiate VM-100 stack via `scripts/infrastructure/create-git-stack.sh`** `[agent:security]` `[risk:2]`
  - Stack deployed from git with CLI `--env` overrides; jails initially loaded.
- [ ] **Deploy + tune fail2ban** `[agent:security]`
  - Traefik never received WAN IPs from Pangolin, so tuning could not complete; see Notes.

### Phase 3: Validation & Testing
**Primary Agent**: `testing`
- [ ] **Simulate brute-force attempts** `[agent:testing]` `[risk:3]`
  - Not completed; fail2ban could not observe WAN IPs for banning.
- [ ] **Regression + resource checks** `[agent:testing]` `[risk:4]`
  - Not completed; task concluded once Emby-native lockouts were deemed sufficient for now.

### Phase 4: Documentation & Handoff
**Primary Agent**: `documentation`
- [ ] **Update runbooks/architecture** `[agent:documentation]`
  - Pending follow-up now that final mitigation uses Emby-native controls.
- [x] **Record work log & lessons learned** `[agent:documentation]`
  - Current document captures execution story, blockers, and next steps.

## Acceptance Criteria

- [x] Traefik (VM-100) serves Emby external/internal hostnames with Pangolin forward-auth removed, TLS valid, security middlewares applied.
- [ ] Fail2ban stack on VM-100 running with Emby-specific jails covering Traefik + Emby logs; regex validated via `fail2ban-regex`. *(Blocked: Pangolin does not yet forward client WAN IPs, so jails cannot act on real attackers.)*
- [ ] Bans trigger after configured retries, block further logins, and unban workflow documented/tested without impacting legitimate users. *(Not met; Emby-native lockouts are carrying the load until header forwarding is solved.)*
- [x] Backups taken pre-change and rollback plan documented with successful smoke tests post-deployment.
- [ ] Documentation (runbooks, stack READMEs, architecture) updated; lessons learned captured during execution. *(Partial: this task doc updated; runbooks still pending.)*
- [ ] All execution plan items completed and Testing Agent validation recorded.

> **Final state**: Fail2ban infrastructure is in place but ineffective without real client IPs. To keep Emby accessible now, forward-auth is disabled and Emby’s built-in lockouts plus mandatory password rotations are the compensating controls until Pangolin can forward `X-Forwarded-For`.

## Testing Plan

**[[docs/agents/TESTING|Testing Agent]] validates:**
- HTTPS access to `emby.infinity-node.com` returns 200 with expected headers/certificate, no Pangolin prompts.
- Simulated failed logins trigger fail2ban bans; banned IP cannot access until unbanned/bantime expires.
- Unban command (`fail2ban-client set emby-traefik unbanip <IP>`) restores access immediately.
- VM-100 resource metrics remain within acceptable ranges; no collateral service impact observed.

**Manual validation:**
1. Perform 6 failed Emby logins through Traefik; confirm ban logged and enforced.
2. Run `fail2ban-client status emby-traefik` and `emby-auth` to verify IP lists and counters.
3. Execute unban command and re-test Emby access; ensure legitimate traffic unaffected.

## Related Documentation

- [[tasks/completed/IN-050-enable-fail2ban-on-vm-103|IN-050 - Fail2ban on VM-103]]
- [[tasks/backlog/IN-052-expose-kavita-external-access|IN-052 - Expose Kavita]]
- [[docs/runbooks/emby-external-access-security|Emby External Access Security Runbook]] (to be updated)
- [[stacks/fail2ban/README|Fail2ban Stack README]]
- [[stacks/traefik/vm-100/README|Traefik VM-100 README]]
- [[docs/agents/SECURITY|Security Agent]]

## Notes

**Priority Rationale**: Emby is listed as CRITICAL with 99.9% uptime target; exposing it externally without fail2ban presents an immediate security gap.

**Complexity Rationale**: Multi-agent coordination, new stack deployment, critical-service safeguards, backups, rollback, and validation make this a complex effort.

**Implementation Notes**:
- Mirror VM-103 fail2ban patterns but adjust paths, ports (8920/8096), and middleware names.
- Capture Emby log format samples early; consider leveraging Emby’s `authfailure.log`.
- Keep Pangolin rules handy for rapid reapplication if rollback needed.
- Current compensating control: Emby account lockout + mandatory password rotation (forward-auth removed, Pangolin tunnel retained). Reactivate fail2ban once Pangolin reliably forwards real client IPs.

**Follow-up Tasks**:
- IN-0XX: Integrate fail2ban alerts (Grafana/Telegram) for Emby bans once WAN IP forwarding is solved.
- IN-0XX: Evaluate Pangolin decommissioning once Emby exposure is secured without it.
- IN-0XX: Author a Pangolin blueprint to guarantee `X-Forwarded-For` / `X-Real-IP` reach Traefik (prereq for re-enabling bans).
- IN-0XX: Apply the new Traefik security headers + rate limiting middleware to Navidrome (VM-103).

---

> [!note]- 📋 Work Log
>
> - 2025-11-13 15:20 ET — Phase 0 (Infrastructure): Reviewed `stacks/traefik/vm-100` + Emby stack definitions, confirmed no Pangolin routers currently active in git, documented need for new external/internal routers and access-log file output for fail2ban integration.
> - 2025-11-13 15:25 ET — Phase 0 (Infrastructure): Verified DNS `emby.infinity-node.com` resolves to Pangolin (45.55.78.215); per user, Pangolin forward-auth remains until cutover, so validation/testing will target `emby.local.infinity-node.com` during implementation. Cert/port-forward + backup steps still pending before Traefik failover.
> - 2025-11-13 15:40 ET — Phase 0 (Infrastructure): SSH audit of VM-100 confirmed Traefik/Emby containers healthy (`docker ps`), local DNS `emby.local.infinity-node.com → 192.168.86.172`, and Emby config located at `/home/evan/projects/infinity-node/stacks/emby/config` with active log files (e.g., `embyserver.txt`).
> - 2025-11-13 15:45 ET — Phase 0 (Infrastructure/Security): Noted prerequisites gaps — no `/home/evan/logs/traefik` directory yet (will need creation + bind mount), `/home/evan/.config/fail2ban` absent (new bundle required), and no `letsencrypt` certs present on VM-100 (TLS automation must be added before exposure).
> - 2025-11-14 03:25 ET — Phase 0 (Infrastructure): User created `/home/evan/logs/traefik` and `/home/evan/.config/fail2ban`; followed up by capturing fresh Emby config backup (`/home/evan/projects/infinity-node/stacks/emby-backup-20251114-032339.tgz`, ~3.1 GB). TLS decision: keep Pangolin-provided HTTPS for `emby.infinity-node.com` until cutover; LAN access (`emby.local…`) remains HTTP for now.
> - 2025-11-14 03:45 ET — Phase 1 (Docker): Updated `stacks/traefik/vm-100/` compose + configs to mount `/home/evan/logs/traefik`, emit JSON access logs to `/var/log/traefik/access.log`, add external+internal Emby routers, and introduce security-header / rate-limit middlewares for fail2ban consumption. README refreshed with new exposure + validation steps.
> - 2025-11-14 03:55 ET — Phase 1 (Docker): Noted follow-up need to mirror the new Traefik security headers + rate limit middleware on VM-103 (Navidrome) via separate task. Confirmed Emby retains Pangolin tunnel protection post-cutover, but forward-auth prompts will be disabled once fail2ban stack is live.
> - 2025-11-14 04:00 ET — Phase 1 (Docker): Created fresh VM-100 Traefik stack via `create-git-stack.sh` (ID 6). Portainer cloned configs as directories; ran `fix-traefik-config-files.sh 192.168.86.172 6` to copy the repo files into `/data/compose/6/stacks/traefik/vm-100/` and restart the stack. Verified container healthy, `/home/evan/logs/traefik/access.log` populated after curl test.
> - 2025-11-14 04:10 ET — Phase 1 (Docker): Updated compose/README to mount Traefik config files from `/home/evan/.config/traefik/vm-100/` (host path) so Portainer no longer turns them into directories; user will copy git versions there before redeploys. Access logs confirmed writing to host path.
> - 2025-11-14 04:30 ET — Phase 2 (Security): Added Emby-specific fail2ban filters/jails/samples mirroring Navidrome patterns, introduced `EMBY_LOG_PATH` mount in compose/.env, and documented new host prep (log directory + config bundle). Captured fresh auth failure samples from Emby + Traefik logs for `fail2ban-regex`.
> - 2025-11-14 05:05 ET — Phase 2 (Security): Deployed VM-100 fail2ban stack via `create-git-stack.sh` with `--env` overrides. Verified jails present but initial bans targeted Docker bridge IPs (172.23.0.1) due to Pangolin hiding WAN IPs.
> - 2025-11-14 05:40 ET — Phase 3 (Testing): Iterated on Pangolin custom header settings and Traefik `forwardedHeaders.trustedIPs`; Traefik access logs still only showed LAN/tunnel addresses, so fail2ban could not act on external attackers. Logged blocker and paused brute-force validation.
> - 2025-11-14 06:05 ET — Phase 3 (Testing/Security): With team energy low and forward header issue unresolved, disabled Pangolin forward-auth for Emby, rotated household passwords, and opted to rely on Emby’s internal lockout controls + logging. Fail2ban stack left running for future use once Pangolin header forwarding is solved.

> [!tip]- 💡 Lessons Learned
>
> **What Worked Well:**
> - Host-mounted Traefik configs eliminated the Portainer “directory instead of file” issue and made log paths predictable for both Traefik and fail2ban.
> - Enhancing `create-git-stack.sh` with `--env KEY=VALUE` flags removed the need for ad-hoc `.env` files, simplifying stack creation on shared hosts.
>
> **What Could Be Better:**
> - Pangolin must forward real client IPs (ideally via a declarative blueprint) before fail2ban can protect Emby; today’s manual UI edits were brittle and inconclusive.
> - We should have validated Emby’s native lockout behavior and limits earlier so the fallback posture was documented up front rather than discovered under fatigue.
>
> **Key Discoveries:**
> - Pangolin’s default reverse-proxy flow rewrites `X-Forwarded-For`, so Traefik only sees LAN/tunnel addresses (`192.168.86.x` / `172.23.0.x`) unless custom headers are explicitly configured.
> - Emby already tracks repeated failed logins per user and enforces a temporary lockout, which can act as a compensating control when external IP intelligence is missing.
>
> **Scope Evolution:**
> - Original goal required fail2ban-enforced bans; final state leaves fail2ban deployed but inactive while Emby-native lockouts + password rotations provide interim protection.
>
> **Follow-Up Needed:**
> - File a task to codify Pangolin header forwarding (e.g., blueprint for `X-Forwarded-For`/`X-Real-IP` as described in [Pangolin Blueprints](https://docs.pangolin.net/manage/blueprints#proxy-resources)) so fail2ban can be re-enabled.
> - Create the previously noted task to extend Traefik security headers + rate limiting to Navidrome on VM-103 once bandwidth is available.
