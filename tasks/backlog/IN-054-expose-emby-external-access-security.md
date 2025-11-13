---
type: task
task-id: IN-054
status: pending
priority: 1
category: security
agent: security
created: 2025-11-13
updated: 2025-11-13
started:
completed:

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

Deploy a dedicated LinuxServer fail2ban stack on VM-100 (Portainer GitOps), update VM-100 Traefik configuration to publish external/internal Emby routes with TLS, headers, and rate limiting, and wire both Traefik access logs and Emby application logs into fail2ban jails. Schedule changes during the 3‑6 AM low-usage window, capture backups, validate bans/unbans, and document operations/rollback similar to IN-050.

**Key components:**
- Component 1: `stacks/fail2ban-vm100/` (compose, `.env.example`, README, config) with `NET_ADMIN/NET_RAW`, mounts for `/home/evan/logs/traefik-vm100` and `/home/evan/data/emby/logs`.
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
- New VM-100 fail2ban stack, filters/jails, `.env.example`, documentation.
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
  **Mitigation**: Schedule work 3‑6 AM, announce maintenance window, perform pre/post smoke tests, keep prior compose files for instant rollback.

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
All changes scheduled during low-usage window with validated rollback plan and backups.

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
- [ ] **Audit current Emby + Traefik stack state** `[agent:infrastructure]` `[blocking]`
  - Confirm compose paths, Pangolin middleware references, logging locations.
- [ ] **Validate DNS/cert + maintenance window** `[agent:infrastructure]` `[blocking]`
  - Ensure `emby.infinity-node.com` (external) and internal hostname resolve and certificates ready.
- [ ] **Confirm backup/rollback artifacts** `[agent:infrastructure]`
  - Verify latest Emby backups and document how to restore quickly.

### Phase 1: Traefik Exposure Updates
**Primary Agent**: `docker`
- [ ] **Author Traefik config changes** `[agent:docker]` `[risk:1]`
  - Update routers/services, TLS, middleware, and access-log file path for VM-100.
- [ ] **Plan and execute Portainer redeploy** `[agent:docker]`
  - Dry-run validation, schedule low-usage deployment, capture logs/smoke tests.

### Phase 2: Fail2ban Deployment
**Primary Agent**: `security`
- [ ] **Create VM-100 fail2ban stack** `[agent:security]` `[risk:2]`
  - Compose file, `.env.example`, README, config mounts, capabilities.
- [ ] **Author Emby filters/jails** `[agent:security]` `[risk:3]`
  - Traefik + Emby log regex, allowlist guidance, sample logs, `fail2ban-regex` instructions.
- [ ] **Deploy + tune fail2ban** `[agent:security]`
  - Portainer redeploy, verify jails loaded, adjust thresholds with sample attacks.

### Phase 3: Validation & Testing
**Primary Agent**: `testing`
- [ ] **Simulate brute-force attempts** `[agent:testing]` `[risk:3]`
  - Failed logins via Traefik and direct Emby endpoints; confirm bans/unbans.
- [ ] **Regression + resource checks** `[agent:testing]` `[risk:4]`
  - Ensure legitimate traffic unaffected, monitor CPU/RAM, confirm low-usage timing adhered to.

### Phase 4: Documentation & Handoff
**Primary Agent**: `documentation`
- [ ] **Update runbooks/architecture** `[agent:documentation]`
  - Extend `docs/runbooks/emby-external-access-security`, `stacks/README`, Traefik/fail2ban READMEs.
- [ ] **Record work log & lessons learned** `[agent:documentation]`
  - Capture phase outcomes, discoveries, follow-up tasks (alerting, monitoring).

## Acceptance Criteria

- [ ] Traefik (VM-100) serves Emby external/internal hostnames with Pangolin removed, TLS valid, security middlewares applied.
- [ ] Fail2ban stack on VM-100 running with Emby-specific jails covering Traefik + Emby logs; regex validated via `fail2ban-regex`.
- [ ] Bans trigger after configured retries, block further logins, and unban workflow documented/tested without impacting legitimate users.
- [ ] Backups taken pre-change and rollback plan documented with successful smoke tests post-deployment.
- [ ] Documentation (runbooks, stack READMEs, architecture) updated; lessons learned captured during execution.
- [ ] All execution plan items completed and Testing Agent validation recorded.

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

**Follow-up Tasks**:
- IN-0XX: Integrate fail2ban alerts (Grafana/Telegram) for Emby bans.
- IN-0XX: Evaluate Pangolin decommissioning once Emby exposure stable.

---

> [!note]- 📋 Work Log
>
> *Fill this in during task execution. Record timestamps, agent hand-offs, and key decisions for each phase.*

> [!tip]- 💡 Lessons Learned
>
> **What Worked Well:**
> -
>
> **What Could Be Better:**
> -
>
> **Key Discoveries:**
> -
>
> **Scope Evolution:**
> -
>
> **Follow-Up Needed:**
> -
