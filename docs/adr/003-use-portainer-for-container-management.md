---
type: adr
number: 003
title: Use Portainer for Container Management
date: 2025-10-24
status: accepted
deciders:
  - Evan
tags:
  - adr
  - docker
  - portainer
  - management
---

# ADR-003: Use Portainer for Container Management

**Date:** 2025-10-24 (retroactive documentation)
**Status:** Accepted
**Deciders:** Evan

## Context
Need a web UI for managing Docker containers and stacks across multiple VMs. Requirements:
- Visual container management
- Stack deployment
- Log viewing
- Works on each VM independently

## Decision
Deploy Portainer CE on each VM for local container management.

## Consequences

**Positive:**
- Excellent web UI
- Easy stack deployment
- Log viewing and debugging
- Resource monitoring
- Template support
- Free version sufficient

**Negative:**
- Instance per VM (not centralized)
- Additional container on each VM
- Learning curve for Portainer-specific features

**Neutral:**
- Could use Portainer Agent + central server model
- Alternative to command-line docker management

## Alternatives Considered

1. **Portainer Business (centralized)**
   - Paid version
   - Central management of multiple environments
   - Overkill for home lab

2. **CLI only**
   - No UI overhead
   - Steeper learning curve
   - Harder to troubleshoot visually

3. **Other UIs** (Yacht, Cockpit, etc.)
   - Less mature
   - Smaller communities
   - Fewer features
