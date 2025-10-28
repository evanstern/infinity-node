---
type: task
task-id: IN-021
status: pending
priority: 4
category: security
agent: security
created: 2025-10-27
updated: 2025-10-27
tags:
  - task
  - security
  - secrets
  - audit
  - compliance
  - rotation
---

# Task: IN-021 - Security Audit and Secret Rotation Policy

<!-- Priority Scale: 0 (critical/urgent) → 1-2 (high) → 3-4 (medium) → 5-6 (low) → 7-9 (very low) -->

## Description

Perform advanced security audit on secret management practices, establish secret rotation policy, and audit git history for accidentally committed secrets. This task covers the remaining security scope items from [[../completed/IN-006-audit-secret-storage|IN-006]].

## Context

**Origin:** Extracted from [[../completed/IN-006-audit-secret-storage|IN-006]] during backlog review on 2025-10-27.

**Current State:**
- Basic secret audit completed via IN-002 (inventory, migration to .env)
- Secrets now stored in Vaultwarden
- No git history audit performed
- No secret rotation policy established
- No compliance audit against security best practices

**Why This Matters:**
- Accidentally committed secrets in git history are a security risk
- Secrets should be rotated periodically as best practice
- Compliance with security standards important for infrastructure maturity
- Proactive security posture prevents future incidents

## Acceptance Criteria

### Phase 1: Git History Audit
- [ ] Scan git history for potential secrets using tools (gitleaks, truffleHog, etc.)
- [ ] Identify any accidentally committed secrets
- [ ] Document findings (severity, exposure period, services affected)
- [ ] Rotate any secrets found in git history
- [ ] Create remediation plan if secrets were exposed
- [ ] Document git security best practices

### Phase 2: Secret Rotation Assessment
- [ ] Inventory all current secrets and their ages
- [ ] Define secret rotation policy by criticality:
  - Critical secrets (VPN keys, root passwords): rotation frequency
  - High priority (admin passwords, API keys): rotation frequency
  - Medium priority (webhook tokens): rotation frequency
  - Low priority (notification tokens): rotation frequency
- [ ] Identify secrets that need immediate rotation
- [ ] Create secret rotation runbook/procedure
- [ ] Document rotation impact (what services need reconfig)

### Phase 3: Security Best Practices Audit
- [ ] Audit current secret storage against industry standards
- [ ] Review file permissions on .env files (should be 600)
- [ ] Verify all secrets are gitignored
- [ ] Check for secrets in backup files
- [ ] Audit Vaultwarden security settings (2FA, access policies)
- [ ] Review least privilege access to secrets
- [ ] Document compliance gaps and remediation

### Phase 4: Ongoing Security
- [ ] Create automated tools/scripts for:
  - Pre-commit hooks to prevent secret commits
  - Periodic git history scanning
  - Secret age tracking and rotation reminders
- [ ] Document security audit procedures
- [ ] Schedule periodic security reviews (quarterly?)

## Implementation Plan

### Step 1: Git History Audit Tools

**Option A: gitleaks** (Recommended)
```bash
# Install gitleaks
brew install gitleaks  # macOS
# or download from GitHub releases

# Scan repository
cd /Users/evanstern/projects/evanstern/infinity-node
gitleaks detect --source . --report-path security-audit-report.json

# Review findings
gitleaks detect --source . --verbose
```

**Option B: truffleHog**
```bash
# Install
pip install truffleHog

# Scan
trufflehog git file:///Users/evanstern/projects/evanstern/infinity-node
```

**Manual Check:**
```bash
# Search for common secret patterns
git log -p | grep -i "password\|secret\|api[_-]key\|token" | less
```

### Step 2: Secret Rotation Priority

**Immediate Rotation Needed If:**
- Found in git history (exposed)
- Older than 1 year (critical secrets)
- Shared with former team members/services
- Suspected compromise

**Proposed Rotation Schedule:**
- **Critical** (VPN, root, Vaultwarden master): Every 90 days
- **High** (admin passwords, service API keys): Every 6 months
- **Medium** (webhooks, read-only keys): Annually
- **Low** (notifications): On compromise only

### Step 3: Compliance Standards

Audit against:
- **OWASP Secrets Management Cheat Sheet**
- **CIS Docker Benchmark** (secret handling)
- **NIST SP 800-53** (AC-2: Account Management)
- Home lab reasonable standards (don't over-engineer)

### Step 4: Automation Ideas

**Pre-commit Hook:**
```bash
#!/bin/bash
# .git/hooks/pre-commit
# Prevent secret commits

gitleaks protect --staged --verbose
if [ $? -ne 0 ]; then
  echo "❌ gitleaks detected secrets in staged changes"
  echo "Please remove secrets before committing"
  exit 1
fi
```

**Secret Age Tracking:**
```bash
# scripts/security/check-secret-age.sh
# Query Vaultwarden for secret creation dates
# Alert on secrets older than rotation policy
```

## Dependencies

- Git history access
- gitleaks or truffleHog installed
- Access to Vaultwarden
- Understanding of all services and their secret dependencies

## Testing Plan

[[docs/agents/TESTING|Testing Agent]] should validate:

**Git Audit:**
- [ ] Scan completes without errors
- [ ] Tool detects known test secrets (plant false positive)
- [ ] Report is generated correctly
- [ ] False positives can be suppressed

**Rotation Process:**
- [ ] Can rotate test secret successfully
- [ ] Dependent services updated correctly
- [ ] No service disruption during rotation
- [ ] Old secret truly invalid after rotation

**Automation:**
- [ ] Pre-commit hook prevents secret commits
- [ ] Secret age tracking identifies old secrets
- [ ] Alerts trigger appropriately

## Related Documentation

- [[../completed/IN-006-audit-secret-storage|IN-006]] - Original audit task
- [[../completed/IN-002-migrate-secrets-to-env|IN-002]] - Secret migration
- [[docs/agents/SECURITY|Security Agent]]
- [[docs/SECRET-MANAGEMENT|Secret Management]]
- [[IN-016-backup-ui-managed-secrets|IN-016]] - UI secrets backup

## Notes

### Git History Audit Considerations

**What to look for:**
- Actual passwords, API keys, tokens (high severity)
- Connection strings with credentials
- Private keys (SSH, SSL, etc.)
- Commented-out secrets (still in history)
- Old .env files that were committed

**If secrets found:**
1. Assess exposure (public repo? when committed? still valid?)
2. Rotate immediately if still in use
3. Document in security incident log
4. Consider git history rewrite if critical (use BFG Repo-Cleaner)
5. Update .gitignore to prevent recurrence

### Secret Rotation Impact

**Services affected by rotation:**
- **Pangolin tunnel:** NEWT_ID/NEWT_SECRET → Need to update tunnel config
- **VPN:** Credentials → May need to reconnect all VPN-dependent services
- **API keys:** *arr stack coordination → Update all dependent services
- **Database passwords:** Multiple services → Coordinate downtime
- **Vaultwarden master:** ALL secrets → High impact, plan carefully

**Rotation Runbook Should Include:**
1. Pre-rotation checklist (backups, maintenance window)
2. Generate new secret
3. Update secret in Vaultwarden
4. Update dependent services (.env files)
5. Deploy updated configurations
6. Test service functionality
7. Revoke/disable old secret
8. Verify old secret no longer works
9. Document rotation in audit log

### Compliance Gaps to Check

Common issues:
- Secrets with 644 permissions (should be 600)
- Secrets readable by non-owner users
- No 2FA on Vaultwarden
- Shared admin passwords across services
- No audit logging of secret access
- Secrets in unencrypted backups
- No access control policies

### Automation Priority

**High Value:**
- Pre-commit hook to prevent secret commits
- Git history scanning (monthly cron job)
- Secret age tracking and rotation reminders

**Nice to Have:**
- Automated secret rotation (risky, needs careful design)
- Secret usage tracking (which services use which secrets)
- Compliance dashboard

### Success Metrics

After completion:
- ✅ Zero secrets in git history (or all rotated if found)
- ✅ Secret rotation policy documented and scheduled
- ✅ Compliance audit completed with <5 high-severity findings
- ✅ Pre-commit hooks prevent future secret commits
- ✅ Rotation runbook tested on non-critical secret

---

**Priority Rationale:** Medium priority (4) because:
- Not urgent - basic secret management in place via IN-002
- Important - advanced security practices and compliance
- Proactive - prevents future security incidents
- Can be implemented gradually (audit first, automation later)
- Lower priority than active infrastructure work
- Higher than nice-to-have enhancements
