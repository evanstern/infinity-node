---
type: task
task-id: IN-063
status: in-progress
priority: 2
category: infrastructure
agent: infrastructure
created: 2025-12-25
updated: 2025-12-25
started: 2025-12-25
completed:

# Task classification
complexity: moderate
estimated_duration: 4-8h
critical_services_affected: false
requires_backup: false
requires_downtime: false

# Design tracking
alternatives_considered: true
risk_assessment_done: true
phased_approach: true

tags:
  - task
  - wireguard
  - ssh
  - remote-access
---

# Task: IN-063 - Deploy WireGuard bastion for external SSH to VMs 1–4

> **Quick Summary**: Stand up a minimal WireGuard bastion (single UDP entry point) to enable secure external SSH access to VMs 1–4 with split-tunnel client configs, including mobile (Pixel Fold) setup instructions and firewall hardening.

## Problem Statement

**What problem are we solving?**
External SSH to VMs 1–4 is unavailable; access is limited to LAN hostnames (`vm-xxx.local.infinity-node.win`) or Pangolin tunnels that lack strong auth in places. We need a hardened, low-ops path for remote SSH without exposing multiple services.

**Why now?**
- Enable reliable remote administration when off-LAN.
- Reduce reliance on unauthenticated Pangolin endpoints.
- Prepare groundwork before later Pangolin 1.13 upgrade.

**Who benefits?**
- **Infra/ops**: Secure remote SSH for maintenance/troubleshooting.
- **Security posture**: Single, hardened ingress instead of many exposed SSH surfaces.
- **Future projects**: Reusable private path for other internal services.

## Solution Design

### Recommended Approach

Deploy a new minimal VM/LXC (1 vCPU, minimal RAM) running WireGuard as a single ingress. Expose one UDP port (direct or fronted by Traefik/Pangolin), restrict via firewall, and route only internal subnets. Provide split-tunnel peer configs for laptop and Pixel Fold. Push internal DNS/search domain so `*.local.infinity-node.win` resolves when remote; keep local-LAN preference when on-site via narrow AllowedIPs. No secrets in git; distribute peer configs out-of-band.

**Key components:**
- WireGuard server on new minimal VM/LXC; key-only auth.
- Firewall rules limiting inbound UDP and SSH reachability to WG subnet.
- Routing + DNS push for internal subnets/hosts; split-tunnel AllowedIPs.
- Client profiles: laptop + Pixel Fold (with PIA coexistence via per-app exclusion).
- Optional fronting of WG UDP via Traefik/Pangolin for allowlist/rate-limit.

**Rationale**: Single UDP entry with split tunnel is low-overhead, reliable for SSH/SFTP/admin, and avoids per-VM SSH exposure. Keeps Pangolin for HTTP/S tunnels while decoupling SSH.

> [!abstract]- 🔀 Alternative Approaches Considered
>
> **Option A: Pangolin SSH tunnels**
> - ✅ Pros: Reuses existing tunnels; can add SSO/mTLS in front.
> - ❌ Cons: SSH over HTTP tunnel adds latency; requires strong auth config; dependent on Pangolin uptime.
> - **Decision**: Not chosen—more moving parts and auth gaps today.
>
> **Option B: Tailscale/mesh overlay**
> - ✅ Pros: Easiest client UX, MagicDNS.
> - ❌ Cons: New SaaS/dependency; diverges from Pangolin/infra patterns.
> - **Decision**: Not chosen—keep stack minimal and self-hosted.
>
> **Option C: Per-VM SSH exposure with allowlists**
> - ✅ Pros: No new service.
> - ❌ Cons: Larger attack surface, harder to manage.
> - **Decision**: Not chosen—centralize ingress instead.

### Scope Definition

**✅ In Scope:**
- Provision minimal VM/LXC for WireGuard (1 vCPU, minimal RAM).
- Install/configure WireGuard; keys, peers, routing, DNS push.
- Firewall rules and exposure decision (direct vs Traefik/Pangolin fronting).
- Client configs for laptop + Pixel Fold; phone setup instructions.

**❌ Explicitly Out of Scope:**
- Pangolin 1.13 upgrade.
- Per-VM SSH policy/hardening beyond WG allowlists.
- Broader network topology changes or additional services over WG.

**🎯 MVP (Minimum Viable)**:
WireGuard endpoint reachable externally with split-tunnel peers for laptop and phone; SSH to VMs 1–4 works; phone instructions documented.

## Risk Assessment

### Potential Pitfalls

- ⚠️ **Misrouting or DNS issues while on LAN** → **Mitigation**: Use narrow AllowedIPs and push internal DNS only; test on-LAN with split-tunnel profile.
- ⚠️ **Phone + PIA conflict** → **Mitigation**: Use per-app exclusion so SSH app bypasses PIA; document toggle workflow.
- ⚠️ **Exposed UDP port attack surface** → **Mitigation**: Firewall allowlist/rate-limit; single entry point; key-only auth; monitor logs.
- ⚠️ **Resource contention on new VM/LXC** → **Mitigation**: Minimal sizing, place off critical hosts, monitor CPU/RAM.

### Dependencies

**Prerequisites (must exist before starting):**
- [x] **Host placement decision** - New minimal VM 104 (vm-104-wireguard) (blocking: yes)
- [ ] **Port selection + FW allowance** - UDP 51820 with FW rate-limit (blocking: yes)
- [x] **Internal DNS info** - Push resolver + search domain `local.infinity-node.win` (blocking: no)

**Has blocking dependencies** - need placement + port choice before build.

### Critical Service Impact

**Services Affected**: None (ingress-only path; no changes to Emby/downloads/arr services).

### Rollback Plan

**Applicable for**: infrastructure/security

**How to rollback if this goes wrong:**
1. Disable WireGuard service on bastion.
2. Remove/disable WG interface routes; flush peers.
3. Close UDP port and related FW rules; remove Traefik/Pangolin exposure if applied.

**Recovery time estimate**: 15–30 minutes.

**Backup requirements:**
- None required (config-only). Save WG configs off-box before rollback if needed.

## Execution Plan

### Phase 0: Discovery/Inventory

**Primary Agent**: `infrastructure`

- [ ] Confirm host/placement (VM vs LXC, which Proxmox node) `[agent:infrastructure]`
- [ ] Choose WG UDP port and exposure path (direct vs Traefik/Pangolin) `[agent:infrastructure]`
- [ ] Confirm internal DNS resolver + search domain to push `[agent:infrastructure]`

### Phase 1: Provisioning

**Primary Agent**: `infrastructure`

- [ ] Create minimal VM/LXC (1 vCPU, minimal RAM/disk) `[agent:infrastructure]`
  - Baseline hardening (updates, users, SSH key auth)
- [ ] Network config ready for WG (static IP, firewall baseline) `[agent:infrastructure]`

### Phase 2: WireGuard Server

**Primary Agent**: `security`

- [ ] Install WireGuard; generate server keys `[agent:security]`
- [ ] Configure interface: addresses, AllowedIPs (internal subnets), DNS push `[agent:security]`
- [ ] Add peers (laptop, Pixel Fold) with split-tunnel AllowedIPs `[agent:security]`
- [ ] Persist configs and secure permissions `[agent:security]`

### Phase 3: Exposure & Firewall

**Primary Agent**: `security`

- [ ] Apply firewall rules (ingress UDP, limit to known IPs if possible) `[agent:security]`
- [ ] (If chosen) Configure Traefik/Pangolin fronting of WG UDP with rate limits/allowlist `[agent:security]`
- [ ] Verify routing to VMs 1–4 and restrict SSH exposure to WG subnet `[agent:security]`

### Phase 4: Clients (Laptop + Pixel Fold)

**Primary Agent**: `security`

- [ ] Generate client configs; distribute securely (no git) `[agent:security]`
- [ ] Document Pixel Fold setup: app, import, AllowedIPs, DNS/search domain, PIA per-app exclusion `[agent:security]`
- [ ] Laptop setup notes (CLI/client, on-demand use) `[agent:security]`

### Phase 5: Validation & Testing

**Primary Agent**: `testing`

- [ ] External test: handshake + SSH to VMs 1–4 `[agent:testing]`
- [ ] On-LAN test with WG enabled: ensure LAN discovery/DNS acceptable `[agent:testing]`
- [ ] Phone test with PIA active + per-app exclusion `[agent:testing]`

### Phase 6: Documentation

**Primary Agent**: `documentation`

- [ ] Update task notes, runbook snippet for WG access, phone steps `[agent:documentation]`
- [ ] Capture lessons learned during execution `[agent:documentation]`

## Acceptance Criteria

**Done when all of these are true:**
- [ ] WireGuard bastion running on new minimal VM/LXC with single UDP port exposed and firewalled.
- [ ] Peers created for laptop and Pixel Fold; configs distributed out-of-band (no secrets in git).
- [ ] External SSH to VMs 1–4 works through WG; routes/DNS behave as intended (split tunnel).
- [ ] Pixel Fold instructions documented (app, profile import, AllowedIPs, DNS/search, PIA coexistence).
- [ ] Rollback steps documented and validated mentally.
- [ ] All execution plan items completed.
- [ ] Testing Agent validates per testing plan.
- [ ] Changes staged for commit pending user approval.

## Testing Plan

**[[docs/agents/TESTING|Testing Agent]] validates:**
- WireGuard handshake from remote network and latency within expectations.
- SSH to each VM (100–103) succeeds via WG interface.
- DNS resolution for `*.local.infinity-node.win` works remotely; on-LAN with WG enabled still prefers LAN for general traffic.

**Manual validation:**
1. From remote network, `wg show` on server shows peer handshakes; SSH to VM 100–103 succeeds.
2. From laptop on LAN with WG enabled, confirm local internet path unchanged and LAN hostnames resolve.
3. On Pixel Fold with PIA running + SSH app excluded, toggle WG profile and confirm SSH works; confirm general apps stay on PIA.

## Related Documentation

- [[docs/agents/INFRASTRUCTURE|Infrastructure Agent]]
- [[docs/agents/SECURITY|Security Agent]]
- [[docs/agents/TESTING|Testing Agent]]
- [[docs/SECRET-MANAGEMENT|Secret Management]]
- [[docs/AI-COLLABORATION|AI Collaboration Guide]]

## Notes

**Priority Rationale**:
High-impact enabler for secure remote admin with small blast surface and minimal ongoing ops.

**Complexity Rationale**:
Moderate: new VM + network/firewall + client configs; known patterns, limited integrations.

**Implementation Notes**:
- Use split-tunnel AllowedIPs for internal subnets and host routes; keep general traffic on normal/PIA.
- Consider fronting WG UDP via Traefik/Pangolin only if allowlisting/rate-limit is simpler there; otherwise direct with FW.
- Push internal DNS/search domain; verify LAN preference when on-site.
- Decisions: Host = VM 104 (vm-104-wireguard), UDP 51820 (open with FW rate-limit), AllowedIPs start with `192.168.1.0/24`, DNS push `local.infinity-node.win` resolver/search domain, no IP allowlist available.
- Recommended WG addressing: server `10.66.66.1/24`; peers laptop `10.66.66.2/32`, phone `10.66.66.3/32`.
- Peer AllowedIPs: `10.66.66.0/24,192.168.1.0/24` (split tunnel); server routes `192.168.1.0/24` via LAN.
- DNS push: internal resolver (e.g., `192.168.1.1`) and search domain `local.infinity-node.win`.
- Enable forwarding: `net.ipv4.ip_forward=1`, `net.ipv6.conf.all.forwarding=1` if v6 needed.
- Firewall idea (nftables): allow udp dport 51820 with rate-limit (e.g., `limit rate 25/minute burst 50`), allow SSH only from WG subnet, drop rest.
- Keep secrets out of git: generate keys on vm-104-wireguard and distribute peer configs out-of-band.
- Store config artifacts (templates only) in-repo, e.g., `config/wireguard/vm-104/` with placeholders (no private keys); deploy via `scp` or git pull + symlinks (`/etc/wireguard/wg0.conf -> /opt/infinity-node/config/wireguard/vm-104/wg0.conf`), and keep key files local-only.

**Follow-up Tasks**:
- IN-XXX: Upgrade Pangolin to 1.13 after SSH path is in place.
- IN-XXX: Add monitoring/alerting for WG endpoint availability.

---

> [!note]- 📋 Work Log
>
> **2025-12-25 - Task created**
> - Captured plan for WG bastion, scope, risks, and testing.
>
> **2025-12-25 - Phase 0 decisions**
> - Placement: new VM 104 (vm-104-wireguard), minimal.
> - Exposure: UDP 51820 open with FW rate-limit (no source allowlist).
> - DNS: push internal resolver + search domain `local.infinity-node.win`.
> - Routing: initial AllowedIPs `192.168.1.0/24` (single LAN).
>
> **2025-12-25 - Phase 1 planning**
> - Chose WG addressing: server 10.66.66.1/24; laptop 10.66.66.2/32; phone 10.66.66.3/32.
> - Split tunnel AllowedIPs: 10.66.66.0/24, 192.168.1.0/24.
> - FW concept: nftables rate-limit on udp/51820; SSH only from WG subnet.
> - ISO source: reuse existing Ubuntu 24.04.3 live server ISO at NAS path `evan/images/ubuntu-24.04.3-live-server-amd64.iso`.
> - Config mgmt: keep templates in-repo under `config/wireguard/vm-104/`, deploy via scp or git + symlinks; never store private keys in git.
>
> **2025-12-25 - Phase 1 artifacts**
> - Added repo templates for vm-104: `config/wireguard/vm-104/{wg0.conf,nftables/wg-allow.nft,nftables/wg-allow-nuke.nft,sysctl/99-wg.conf,README.md}` with placeholders (no secrets).
> - Added netplan template for static IP `192.168.1.104/24` on `ens18` with gateway `192.168.1.1` and DNS `192.168.1.79, 192.168.1.1, 8.8.8.8`.
>
> **2025-12-25 - Phase 1 execution**
> - Created VM 104 on node `infinity-node`: name `vm-104-wireguard`, 1 vCPU, 1GB RAM, 16G disk on `local-lvm`, bridge `vmbr0`.
> - Attached ISO `local:iso/ubuntu-24.04.1-live-server-amd64.iso`; boot order set to `scsi0`.
>
> **2025-12-25 - Phase 2 execution**
> - On vm-104: cloned repo to `/opt/infinity-node`; installed `wireguard`, `nftables`.
> - Applied netplan for static IP `192.168.1.104/24`; confirmed reachability.
> - Installed sysctl forwarding, nftables rules; added flush to wg nftables table and reapplied (deduped rules).
> - Generated WG keys on-host; rendered `/etc/wireguard/wg0.conf`; enabled `wg-quick@wg0` (listening 51820).
> - Removed DNS directive from server wg0.conf to avoid overriding host DNS; server DNS now resolves normally.
> - Generated peer configs with private keys at `/home/evan/wg-peers/{laptop.conf,phone.conf}` (Endpoint placeholder `<public_or_ddns>`).
>
> **2025-12-25 - Forwarding/NAT fix**
> - Updated nftables to include forward chain and MASQUERADE for `10.66.66.0/24` out `ens18` (file and host applied). This fixes LAN reachability/DNS for peers.

> **2025-12-25 - Teardown (CGNAT identified)**
> - Determined ISP CGNAT (WAN IP 100.77.69.204) preventing inbound WG. No traffic reached vm-104 despite forwarding.
> - Destroyed VM 104 on Proxmox (purged disk) and removed WG config templates from repo (`config/wireguard/vm-104/*`).
> - Plan pivot: replace WG ingress with Tailscale (user has account). No-IP DDNS to be removed by user.

> **2025-12-25 - Tailscale plan (Portainer/GitOps)**
> - Added `stacks/tailscale/docker-compose.yml` and `stacks/tailscale/README.md` for per-host Tailscale via Portainer.
> - Uses external secret `ts_authkey` (from Vaultwarden `infinity-node -> vm-10x-xxx/shared`), host overrides via env vars (TS_HOSTNAME, TS_ROUTES, TS_ACCEPT_DNS, TS_EXIT_NODE, TS_EXTRA_ARGS).
> - Default host target vm-100; subnet router to be chosen (set TS_ROUTES on that host only).
> - Added `.env.example` with configurable state path (`TS_STATE_DIR_HOST` default `/home/evan/config/tailscale`) and tun device; volume mounts now configurable.
>
> **YYYY-MM-DD - [Milestone]**
> - [What was accomplished]
> - [Important decisions made]
> - [Issues encountered and resolved]

> [!tip]- 💡 Lessons Learned
>
> **What Worked Well:**
> - [What patterns/approaches were successful that we should reuse?]
> - [What tools/techniques proved valuable?]
>
> **What Could Be Better:**
> - [What would we do differently next time?]
> - [What unexpected challenges did we face?]
> - [What gaps in documentation/tooling did we discover?]
>
> **Key Discoveries:**
> - [Did we learn something that affects other systems/services?]
> - [Are there insights that should be documented elsewhere (runbooks, ADRs)?]
> - [Did we uncover technical debt or improvement opportunities?]
>
> **Scope Evolution:**
> - [How did the scope change from original plan and why?]
> - [Were there surprises that changed our approach?]
>
> **Follow-Up Needed:**
> - [Documentation that should be updated based on this work]
> - [New tasks that should be created]
> - [Process improvements to consider]
