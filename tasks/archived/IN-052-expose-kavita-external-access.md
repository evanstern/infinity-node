---
type: task
task-id: IN-052
status: archived
priority: 4
category: security
agent: security
created: 2025-11-13
updated: 2025-11-13
started:
completed:

# Task classification
complexity: complex
estimated_duration: 6-10h
critical_services_affected: false
requires_backup: true
requires_downtime: false

# Design tracking
alternatives_considered: true
risk_assessment_done: true
phased_approach: true

tags:
  - task
  - kavita
  - vm-103
  - security
  - fail2ban
---

# Task: IN-052 - Expose Kavita publicly with Traefik + Fail2ban

> **Quick Summary**: Remove Pangolin-only gating for Kavita and publish a HTTPS route through Traefik on VM-103 with new Fail2ban protections modeled after Navidrome.

## Problem Statement

**What problem are we solving?**
Kavita (from [[tasks/backlog/IN-051-deploy-kavita-server-vm-103|IN-051]]) currently sits behind Pangolin and is inaccessible to household members when off-LAN. The ad-hoc forward-auth layer blocks native clients and prevents bookmarking the service. Without Fail2ban coverage, exposing it directly would increase brute-force risk. We need a GitOps-managed path to publish Kavita safely while keeping operational parity with other media stacks.

**Why now?**
- IN-051 targets an internal deployment this cycle; external access is the next logical milestone.
- Fail2ban stack was recently proven for Navidrome, so we can reuse patterns while momentum is fresh.
- Household readers are requesting remote ebook access before the holiday travel window.

**Who benefits?**
- **Household users**: Can reach Kavita remotely without VPN or Pangolin prompts.
- **Security Agent**: Establishes a repeatable Traefik + Fail2ban recipe for future services.
- **Media Stack Agent**: Gains documentation for operational monitoring, rollback, and future automations.

## Solution Design

### Recommended Approach

Publish Kavita via Traefik’s Git-managed stack on VM-103 using a dedicated router, TLS cert, and middleware chain (headers, rate limit, fail-to-ban friendly logging). Disable Pangolin forward-auth for this host while keeping Pangolin as the tunnel/edge entry point. Serve traffic at `kavita.infinity-node.com` (external) and `kavita.local.infinity-node.com` (internal) with consistent middleware. Extend the Fail2ban stack with Kavita-specific filters leveraging both Traefik access logs and Kavita application logs, mirroring the Navidrome external security runbook. Document deployment, monitoring, and rollback steps.

**Key components:**
- Component 1: Update `stacks/traefik/vm-103` (`dynamic.yml`, `traefik.yml`, README) with new routers/services for `kavita.infinity-node.com` and `kavita.local.infinity-node.com`, ensuring Pangolin forward-auth is disabled while LAN/internal rules stay intact.
- Component 2: Enhance `stacks/fail2ban` config (`filter.d`, `jail.d`, `.env.example`, README) with Kavita jails targeting Traefik and Kavita logs, plus sample regex validation steps.
- Component 3: Documentation + runbooks covering exposure rationale, monitoring, backup expectations, and lessons learned.

**Rationale**: This keeps all changes under Git/Portainer orchestration, reuses hardened patterns from Navidrome, and avoids introducing new SaaS dependencies. Removing Pangolin aligns with native-client needs while Fail2ban + middleware provide layered defense.

> [!abstract]- 🔀 Alternative Approaches Considered
>
> **Option A: Keep Pangolin and simply add Fail2ban**
> - ✅ Pros: Minimal Traefik changes; Pangolin remains an auth wall.
> - ❌ Cons: Still blocks native apps; Pangolin failures would keep service unusable externally.
> - **Decision**: Not chosen - does not satisfy external usability goal.
>
> **Option B: Cloudflare Tunnel + Access policies**
> - ✅ Pros: Outsourced security, no fail2ban maintenance.
> - ❌ Cons: Introduces new dependency, diverges from existing GitOps pattern, adds latency.
> - **Decision**: Not chosen - prefer on-prem controls and parity with Navidrome stack.
>
> **Option C: Traefik exposure + Fail2ban (chosen)**
> - ✅ Pros: Full control, reusable recipe, works with native clients.
> - ✅ Pros: Matches documentation, can be audited via Portainer + git history.
> - ❌ Cons: Requires careful Traefik reconfiguration and new jails.
> - **Decision**: ✅ CHOSEN - best balance of usability and security.

### Scope Definition

**✅ In Scope:**
- Traefik router/service/middleware updates to serve Kavita publicly w/ TLS.
- Fail2ban configuration additions (filters, jails, env template, docs) for Kavita.
- Documentation updates: architecture, stack READMEs, runbooks, lessons.

**❌ Explicitly Out of Scope:**
- Pangolin changes for other services.
- Pangolin removal automation or Pangolin decommissioning.
- OPDS/mobile onboarding, Pangolin replacement, or Cloudflare integrations.

**🎯 MVP (Minimum Viable)**:
Kavita accessible at the public hostname with Pangolin disabled, Traefik protections in place, Fail2ban enforcing bans from Traefik + app logs, and documentation/runbooks describing deployment + rollback.

## Risk Assessment

### Potential Pitfalls

- ⚠️ **Risk 1: Security regression when Pangolin removed** → **Mitigation**: Layer Traefik middlewares (headers, rate limiting, IP safelist if needed) plus Fail2ban coverage before exposing host.

- ⚠️ **Risk 2: Misconfigured Traefik impacting other services** → **Mitigation**: Validate config via tooling, stage deployment during low-usage window, capture pre/post status.

- ⚠️ **Risk 3: Fail2ban false positives** → **Mitigation**: Test regex filters against real logs, add allowlist for trusted subnets, document unban workflow.

- ⚠️ **Risk 4: Resource strain on VM-103** → **Mitigation**: Snapshot CPU/RAM/disk before/after exposure, monitor container stats, adjust jails if overhead noted.

### Dependencies

**Prerequisites (must exist before starting):**
- [ ] **IN-051 completion** - Kavita stack deployed internally with documented config. (blocking: yes)
- [ ] **DNS + certificate readiness** - `kavita.infinity-node.com` (external via Pangolin tunnel) and `kavita.local.infinity-node.com` (internal Traefik) delegated with valid certificate paths. (blocking: yes)
- [ ] **Fail2ban stack healthy on VM-103** - baseline configuration from IN-050 running. (blocking: no)

**Has blocking dependencies** - cannot begin Traefik/F2B changes until IN-051 and DNS readiness confirmed.

### Critical Service Impact

**Services Affected**: Non-critical service addition only. Emby/downloads/arr remain untouched; work isolated to Kavita exposure plus shared Traefik/F2B configs. Changes scheduled during low-usage windows to avoid collateral impact.

### Rollback Plan

**Applicable for**: docker/security/traefik configuration work

**How to rollback if this goes wrong:**
1. Use Portainer to stop/disable the Kavita Traefik router or revert to previous git commit, then redeploy Traefik stack.
2. Re-enable Pangolin middleware via previous config (kept in git history) if immediate auth gate needed.
3. Remove/disable new Fail2ban jails (`fail2ban-client delete <jail>`) and redeploy stack to previous config.

**Recovery time estimate**: 30-45 minutes (Traefik + Fail2ban redeploy + validation).

**Backup requirements:**
- Snapshot `stacks/traefik/vm-103` and `stacks/fail2ban` directories via git branch or copy before editing.
- Ensure `/home/evan/logs/traefik` and Kavita logs referenced by Fail2ban are included in existing backup jobs.

## Execution Plan

### Phase 0: Discovery & Inventory

**Primary Agent**: `infrastructure`

- [ ] **Verify IN-051 completion + stack health** `[agent:infrastructure]` `[depends:IN-051]`
  - Confirm Portainer stack `kavita` running, review current Traefik labels.

- [ ] **Confirm DNS/cert + Pangolin references** `[agent:infrastructure]`
  - Ensure `kavita.infinity-node.com` (external) and `kavita.local.infinity-node.com` (internal) resolve correctly and cert automation ready.
  - Locate Pangolin middleware entries affecting the Kavita route so forward-auth can be disabled while leaving the tunnel intact.

### Phase 1: Traefik Exposure Updates

**Primary Agent**: `docker`

- [ ] **Author Traefik config changes** `[agent:docker]` `[risk:2]`
  - Update `dynamic.yml` with routers/services, TLS options, middleware chain.
  - Remove Pangolin forward-auth & ensure internal router still available if needed.

- [ ] **Plan/execute Portainer redeploy** `[agent:docker]`
  - Validate config locally then trigger Traefik stack redeploy during low-use window.
  - Capture logs/metrics and verify route resolves.

### Phase 2: Fail2ban Hardening

**Primary Agent**: `security`

- [ ] **Create Kavita filters/jails** `[agent:security]` `[risk:1]`
  - Add regex filters for Traefik and Kavita logs, update `.env.example` with log paths.
  - Document allowlist expectations and jail parameters (maxretry, bantime).

- [ ] **Test and deploy Fail2ban updates** `[agent:security]` `[risk:3]`
  - Run `fail2ban-regex` tests; update docs with commands.
  - Redeploy Fail2ban stack and confirm new jails registered.

### Phase 3: Deployment & Validation

**Primary Agent**: `media`

- [ ] **Functional smoke + security tests** `[agent:media]` `[risk:1]`
  - Access Kavita via Traefik URL (browser + native client) ensuring no Pangolin prompt.
  - Trigger failed logins to confirm bans, verify unban workflow documented.

- [ ] **Persistence/monitoring checks** `[agent:media]` `[risk:4]`
  - Restart Kavita stack/Traefik to confirm config persists.
  - Observe VM-103 resource metrics for anomalies.

### Phase 3: Validation & Testing

**Primary Agent**: `testing`

- [ ] **Public access verification** `[agent:testing]`
  - Confirm HTTPS 200, valid TLS chain, and Traefik headers present.

- [ ] **Fail2ban effectiveness test** `[agent:testing]`
  - Simulate repeated failures, verify IP banned/unbanned appropriately, ensure legitimate traffic unaffected.

### Phase 4: Documentation

**Primary Agent**: `documentation`

- [ ] **Update architecture/runbooks** `[agent:documentation]`
  - Add Kavita exposure details to `ARCHITECTURE.md`, `stacks/README.md`, new/updated runbook referencing Navidrome pattern.
  - Capture lessons learned/work log entries.

## Acceptance Criteria

**Done when all of these are true:**
- [ ] Traefik serves `kavita.infinity-node.com` (via Pangolin tunnel) and `kavita.local.infinity-node.com` with Pangolin auth disabled, TLS valid, and middleware applied.
- [ ] Fail2ban stack includes Kavita jails with tested regex + documented allowlist/unban steps.
- [ ] Smoke/security tests confirm access, bans, and persistence; resource monitoring shows no regressions.
- [ ] Documentation (architecture, stack READMEs, runbook, lessons) updated with new exposure pattern.
- [ ] All execution plan items completed
- [ ] Testing Agent validates (see testing plan below)
- [ ] Changes committed with descriptive message (awaiting user approval)

## Testing Plan

**[[docs/agents/TESTING|Testing Agent]] validates:**
- Traefik route responds 200/HTTPS with expected headers and certificate chain.
- Fail2ban jails activate on failed login attempts and release after configured bantime/unban commands.
- Service restart maintains accessibility and logs clean of errors.
- VM-103 resource metrics remain within acceptable ranges during exposure tests.

**Manual validation:**
1. Browse to `https://kavita.infinity-node.com` and `https://kavita.local.infinity-node.com`, confirm login + library access without Pangolin prompt.
2. Attempt ≥5 failed logins to trigger ban; ensure traffic blocked and unban procedure works.
3. Restart Traefik + Fail2ban stacks and re-test route to ensure persistence and no regressions.

## Related Documentation

- [[tasks/backlog/IN-051-deploy-kavita-server-vm-103|IN-051 - Deploy Kavita on VM-103]]
- [[docs/runbooks/navidrome-external-access-security|Navidrome External Access Security Runbook]]
- [[stacks/fail2ban/README|Fail2ban Stack]]
- [[stacks/traefik/vm-103/README|Traefik VM-103 Stack]]

## Notes

**Priority Rationale**:
Matches IN-051 (priority 4) since external access is the follow-up deliverable enabling real user adoption, but no critical service downtime expected.

**Complexity Rationale**:
Requires multi-agent coordination, Traefik + Fail2ban changes, security validation, and thorough documentation; multiple risks/unknowns place it firmly in complex territory.

**Implementation Notes**:
- Schedule Traefik redeploy + Fail2ban tests during low-usage window (3-6 AM) to minimize user impact.
- Keep prior Pangolin config reachable for quick rollback.
- Mirror UID/GID/log paths used for Navidrome to simplify maintenance.
- Pangolin tunnel and perimeter Traefik remain in place; this work only disables the forward-auth gate for Kavita.

**Follow-up Tasks**:
- IN-0XX: Evaluate Pangolin decommissioning plan once more services migrate to Fail2ban-only exposure.
- IN-0XX: Automate Kavita Fail2ban metrics into monitoring/alerting (Grafana/Telegram).

---

> [!note]- 📋 Work Log
>
> **2025-11-13 - Task Created**
> - Captured scope, risks, and execution plan for exposing Kavita.
> - Linked dependencies on IN-051, DNS readiness, and Fail2ban patterns.
>
>
> [!tip]- 💡 Lessons Learned
>
> *Fill this in AS YOU GO during task execution. Not every task needs extensive notes here, but capture important learnings that could affect future work.*
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
>
