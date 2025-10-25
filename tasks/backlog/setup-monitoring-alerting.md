---
type: task
status: pending
priority: medium
category: infrastructure
agent: infrastructure
created: 2025-10-24
updated: 2025-10-24
tags:
  - task
  - infrastructure
  - monitoring
  - alerting
---

# Task: Set Up Monitoring and Alerting

## Description

Research, select, and implement a monitoring and alerting solution for the infinity-node infrastructure to track service health, resource usage, and receive alerts for critical issues.

## Context

Currently, all monitoring is manual. We need automated monitoring for:
- Service health (are containers running?)
- Resource usage (CPU, RAM, disk, network)
- Critical service uptime (Emby, downloads, arr)
- System health (Proxmox, VMs, NAS)
- Alert notifications when issues occur

This is especially important for critical services that affect household users.

## Acceptance Criteria

- [ ] Research monitoring solutions suitable for home lab
- [ ] Select monitoring solution (document in ADR)
- [ ] Deploy monitoring infrastructure
- [ ] Configure monitoring for all VMs
- [ ] Configure monitoring for critical services
- [ ] Set up alerting (email, push notifications, etc.)
- [ ] Configure alert thresholds
- [ ] Test alert delivery
- [ ] Create monitoring dashboard
- [ ] Document monitoring setup
- [ ] Create runbook for responding to alerts

## Dependencies

- Decision on monitoring solution
- VM resources for monitoring services
- Notification method (email, Pushover, etc.)
- Understanding of what to monitor

## Testing Plan

[[docs/agents/TESTING|Testing Agent]] should validate:
- Monitoring collects metrics successfully
- Alerts trigger appropriately
- Alert notifications delivered
- Dashboard shows accurate data
- No false positives
- Monitors detect real issues

## Related Documentation

- [[docs/ARCHITECTURE|Architecture]]
- [[docs/DECISIONS|Decisions]] - Future ADR needed
- [[docs/agents/INFRASTRUCTURE|Infrastructure Agent]]

## Notes

**Monitoring solution options:**

1. **Prometheus + Grafana**
   - Industry standard
   - Powerful but complex
   - Resource intensive

2. **Uptime Kuma**
   - Simple, beautiful UI
   - Good for service monitoring
   - Less detailed metrics

3. **Netdata**
   - Real-time monitoring
   - Low resource usage
   - Auto-discovery

4. **Zabbix**
   - Enterprise-grade
   - Complex setup
   - Very powerful

**What to monitor:**

**Critical Service Health:**
- Emby container running
- Download clients running
- *arr services running
- VPN connection active

**Resource Usage:**
- CPU usage per VM
- RAM usage per VM
- Disk usage (Proxmox, NAS)
- Network bandwidth
- Container resource usage

**System Health:**
- Proxmox node status
- VM status
- NFS mount health
- Disk health (SMART)

**Alert priorities:**
- Critical: Emby down, VPN down, disk full
- Warning: High resource usage, service errors
- Info: Updates available, backup completion

**Considerations:**
- Where to deploy monitoring (VM 103?)
- Resource overhead of monitoring
- Alert fatigue (tune thresholds)
- Historical data retention
- Dashboard accessibility
