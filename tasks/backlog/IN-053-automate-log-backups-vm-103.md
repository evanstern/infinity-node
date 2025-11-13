---
type: task
task-id: IN-053
status: pending
priority: 3
category: infrastructure
agent: infrastructure
created: 2025-11-13
updated: 2025-11-13
started:
completed:

# Task classification
complexity: moderate
estimated_duration: 3-4h
critical_services_affected: false
requires_backup: false
requires_downtime: false

# Design tracking
alternatives_considered: true
risk_assessment_done: true
phased_approach: true

tags:
  - task
  - logging
  - backup
---

# Task: IN-053 - Automate log backups for VM-103 services

> **Quick Summary**: Create a reusable log-backup script plus cron jobs on VM-103 to archive Traefik and Navidrome logs to the NAS nightly at 03:00.

## Problem Statement

**What problem are we solving?**

VM-103 now generates Traefik and Navidrome logs under `/home/evan/logs/traefik` and `/home/evan/data/navidrome/logs`, but nothing moves them off the VM. Without backups we lose observability data if the VM fails, and disk usage will keep growing. We need parity with other backup workflows so logs are archived and shipped to the NAS automatically.

**Why now?**
- Recent logging improvements created new data we want preserved.
- Aligns with the broader push for documented/automated backups.
- Enables future troubleshooting by keeping historical logs centralized.

**Who benefits?**
- **Infrastructure operations**: Consistent tooling and reduced manual work.
- **Security/observability**: Retains evidence for incident review.
- **Future automation**: Establishes a reusable script for other services.

## Solution Design

### Recommended Approach

Build `scripts/backup/backup-logs.sh`, a generic Bash utility modeled after `backup-vaultwarden.sh`. The script accepts one or more log file paths, verifies readability, bundles them into a timestamped tar.gz in `/tmp`, uploads the archive to the NAS (`backup@nas.local.infinity-node.com`) under service-specific subdirectories, and cleans up local artifacts. No retention logic is required yet; focus on reliable packaging and transfer. Add cron entries on VM-103 that call the script for Traefik and Navidrome at 03:00 daily.

**Key components:**
- Component 1: Argument-driven log selection (accepts arbitrary paths, validates each).
- Component 2: Archive + checksum creation in `/tmp`, with traps to remove temporary files.
- Component 3: `scp` upload to NAS using existing backup user and directory structure, per-service cron wrappers.

**Rationale**: Mirrors established backup patterns, keeps logic centralized, and lets future services piggyback by passing different log paths without writing new scripts.

> [!abstract]- 🔀 Alternative Approaches Considered
>
> **Option A: Logrotate with remote copy hooks**
> - ✅ Pros: Native rotation/compression lifecycle
> - ✅ Pros: Familiar tooling for system logs
> - ❌ Cons: Harder to share across services; copy logic duplicated per config
> - ❌ Cons: Adds complexity for each new log file
> - **Decision**: Not chosen – less reusable and more config sprawl.
>
> **Option B: Mount NAS share and copy directly**
> - ✅ Pros: Simple `cp`/`mv` commands
> - ✅ Pros: Avoids `scp` overhead
> - ❌ Cons: Requires persistent mount + credentials; new failure modes
> - ❌ Cons: Diverges from established backup practice
> - **Decision**: Not chosen – higher operational overhead.
>
> **Option C: Dedicated backup script (chosen)**
> - ✅ Pros: Reusable across services, parity with other backups
> - ✅ Pros: Keeps remote transfer encapsulated and logged
> - ❌ Cons: Need to maintain script + cron
> - **Decision**: ✅ CHOSEN – best balance of reuse and clarity.

### Scope Definition

**✅ In Scope:**
- New generic log-backup script in `scripts/backup/`.
- NAS upload workflow using `backup@nas` account and service-specific directories.
- Cron jobs on VM-103 for Traefik and Navidrome at 03:00 daily.

**❌ Explicitly Out of Scope:**
- Automated retention/cleanup on NAS (manual for now, future task).
- Full log rotation policy or integration with `logrotate`.
- Centralized monitoring/alerting on backup results.

**🎯 MVP (Minimum Viable)**:
Script successfully archives Traefik/Navidrome logs and cron executes daily at 03:00, depositing archives on NAS.

## Risk Assessment

### Potential Pitfalls

- ⚠️ **NAS unreachable during run** → **Mitigation**: Script exits non-zero with clear message; cron email highlights failure for manual follow-up.

- ⚠️ **Insufficient permissions on log files** → **Mitigation**: Run cron as user owning logs (likely `evan`), verify access during testing.

- ⚠️ **Temporary files accumulate** → **Mitigation**: Use `trap` to remove archive on exit/failure.

- ⚠️ **Cron overlap or long runtime** → **Mitigation**: Single daily run at low-usage window; script logs start/end times for debugging.

### Dependencies

**Prerequisites (must exist before starting):**
- [ ] **`backup@nas` SSH key auth** - Confirmed working from VM-103 (blocking: yes)
- [ ] **Destination directories on NAS** - Create `/volume1/backups/logs/{traefik,navidrome}` if missing (blocking: no)

**Has blocking dependencies** - Need to confirm NAS SSH access before deploying cron.

### Critical Service Impact

**Services Affected**: None (Traefik/Navidrome logs only)

Backups operate out-of-band and do not touch Emby/downloads/arr stacks, so no critical services impacted directly.

### Rollback Plan

**Applicable for**: infrastructure scripting/cron changes

**How to rollback if this goes wrong:**
1. Remove or comment cron entries for affected services.
2. Delete or disable the log-backup script.
3. Remove any partially created archives from NAS directories if necessary.

**Recovery time estimate**: <30 minutes

**Backup requirements:**
- Not required (script creation only). Log files remain original sources.

## Execution Plan

### Phase 0: Discovery & Verification

**Primary Agent**: `[agent:infrastructure]`

- [ ] **Confirm NAS connectivity + directories** `[agent:infrastructure]`
  - Test `ssh backup@nas...` from VM-103
  - Create service directories if missing

### Phase 1: Script Implementation

**Primary Agent**: `[agent:infrastructure]`

- [ ] **Implement `backup-logs.sh`** `[agent:infrastructure]`
  - Argument parsing & validation
  - Tar/gzip creation + trap cleanup
  - `scp` upload with informative logging

- [ ] **Local testing with sample logs** `[agent:infrastructure]`
  - Dry-run on VM-103 logs
  - Verify archive arrives on NAS

### Phase 2: Cron Integration

**Primary Agent**: `[agent:infrastructure]`

- [ ] **Add Traefik cron entry (03:00)** `[agent:infrastructure]`
  - Command: script + `/home/evan/logs/traefik/access.log` (and other relevant files)

- [ ] **Add Navidrome cron entry (03:00)** `[agent:infrastructure]`
  - Command: script + `/home/evan/data/navidrome/logs/navidrome.log`

### Phase 3: Validation & Testing

**Primary Agent**: `testing`

- [ ] **Manual validation run** `[agent:testing]`
  - Invoke script manually and confirm archive on NAS with correct naming.

- [ ] **Cron dry-run confirmation** `[agent:testing]`
  - Use `run-parts`/`crontab -l` verification; ensure job scheduled for 03:00.

### Phase 4: Documentation

**Primary Agent**: `documentation`

- [ ] **Document script usage** `[agent:documentation]`
  - Update task worklog and reference relevant README/runbook if needed.

## Acceptance Criteria

**Done when all of these are true:**
- [ ] `scripts/backup/backup-logs.sh` accepts ≥1 log path and uploads archive to NAS.
- [ ] Failure cases (missing path, SSH failure) exit non-zero with clear messaging.
- [ ] Cron entries exist on VM-103 for Traefik and Navidrome at 03:00 daily referencing the script.
- [ ] Manual test confirms archives land under `/volume1/backups/logs/<service>/`.
- [ ] All execution plan items completed.
- [ ] Testing Agent validates (see testing plan below).
- [ ] Changes committed with descriptive message (awaiting user approval).

## Testing Plan

**[[docs/agents/TESTING|Testing Agent]] validates:**
- Manual invocation of script with Traefik log path; verify tarball name + NAS presence.
- Simulated failure (missing file) to confirm non-zero exit and stderr message.

**Manual validation:**
1. Run script for Traefik logs; `ls` destination on NAS to ensure new archive exists.
2. Inspect tar contents on NAS to confirm log files included.
3. `crontab -l` for target user shows both 03:00 entries referencing correct paths.

## Related Documentation

- [[docs/agents/INFRASTRUCTURE|Infrastructure Agent]]
- [[scripts/README|Scripts Overview]]
- [[docs/runbooks/navidrome-external-access-security|Navidrome Runbook]] (context on service location)

## Notes

**Priority Rationale**:
Medium priority because it protects new log data and supports troubleshooting, but no production outage risk today.

**Complexity Rationale**:
Moderate due to new reusable script, NAS interactions, and multiple cron jobs requiring testing.

**Implementation Notes**:
- Mirror logging style from other backup scripts (colorized output, exit codes).
- Consider optional checksum generation for future integrity checks.
- Keep service names configurable via env or derived from arguments for reuse.

**Follow-up Tasks**:
- IN-XXX: Add retention/cleanup automation for NAS log archives.
- IN-XXX: Integrate with monitoring/alerting for backup failures.

---

> [!note]- 📋 Work Log
>
> **2025-11-13 - Task Created**
> - Captured requirements and plan for log backup automation.
> - Identified scope exclusions (retention) and dependencies.
>
> **YYYY-MM-DD - [Milestone]**
> - [What was accomplished]
> - [Important decisions made]
> - [Issues encountered and resolved]
>
> **YYYY-MM-DD - [Milestone]**
> - [What was accomplished]
> - [Important decisions made]

> [!tip]- 💡 Lessons Learned
>
> **What Worked Well:**
> - [Add during execution]
>
> **What Could Be Better:**
> - [Add during execution]
>
> **Key Discoveries:**
> - [Add during execution]
>
> **Scope Evolution:**
> - [Add during execution]
>
> **Follow-Up Needed:**
> - [Add during execution]
