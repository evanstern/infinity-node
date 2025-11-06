---
title: "Libby Automation Project Dashboard"
created: 2025-11-05
updated: 2025-11-05
tags:
  - dashboard
  - libby-project
---

# Libby Automation Project Dashboard

**Project Goal:** Build an automated system to checkout books from Libby, download them, remove DRM, and import to Calibre library.

**Current Phase:** Research & POC Planning

---

## Project Tasks

### Current Tasks

```dataview
TABLE WITHOUT ID
  file.link as "Task",
  status as "Status",
  priority as "Priority",
  complexity as "Complexity"
FROM "tasks"
WHERE contains(tags, "libby-project")
  AND (status = "in-progress" OR status = "current")
SORT priority ASC, created ASC
```

### Backlog Tasks

```dataview
TABLE WITHOUT ID
  file.link as "Task",
  priority as "Priority",
  complexity as "Complexity",
  estimated_effort as "Effort"
FROM "tasks"
WHERE contains(tags, "libby-project")
  AND status = "backlog"
SORT priority ASC, created ASC
```

### Completed Tasks

```dataview
TABLE WITHOUT ID
  file.link as "Task",
  completed as "Completed",
  priority as "Priority"
FROM "tasks"
WHERE contains(tags, "libby-project")
  AND status = "completed"
SORT completed DESC
```

---

## Project Overview

### Planned Phases

1. **Phase 1: Research & POC (IN-042)** ← Current
   - Reverse engineer Libby API
   - Build TypeScript CLI tool
   - Validate end-to-end workflow
   - Document findings and limitations

2. **Phase 2: Web UI** (Future)
   - Build Next.js or React interface
   - Visual book management
   - Real-time progress tracking
   - Better UX for household use

3. **Phase 3: Docker Deployment** (Future)
   - Deploy to VM 103 (misc services)
   - Portainer stack integration
   - Secure secret management

4. **Phase 4: Advanced Features** (Future)
   - Hold/waitlist management
   - Multi-library card support
   - Goodreads import integration
   - Notification system

### Key Principles

- **Collaboration First:** Consult before major decisions, work in tandem
- **Safety:** Conservative rate limiting, don't anger libraries
- **Quality Over Speed:** Taking a week to process books is fine
- **Documentation:** Capture everything learned about the API
- **Ethics:** Personal use only, no redistribution

### Technical Stack

**Current (CLI POC):**
- TypeScript + Node.js
- Adobe Digital Editions (link handling)
- Calibre CLI (import + DRM removal)

**Future (Web UI):**
- Next.js or React + FastAPI/NestJS
- SQLite or PostgreSQL
- Docker deployment to VM 103

---

## Quick Links

- **Main Task:** [[IN-042-libby-calibre-automation]]
- **Task Dashboard:** [[DASHBOARD]]
- **Research:** `docs/research/libby-api-endpoints.md` (to be created)

---

## Project Status

**Last Updated:** 2025-11-05

**Current Status:**
- ✅ Initial task created (IN-042)
- 🔍 **OverDrive API Discovery:** Official API exists but appears different from Libby's internal API
- ✅ **Strategy Clarified:** Reverse engineer Libby's internal API, use OverDrive docs as reference
- ⏳ Awaiting start of research phase
- 🎯 Next: Begin Phase 1 with Libby API deep dive via browser DevTools

**Blockers:** None

**Notes:**
- User has working cURL examples for Libby's internal API (`sentry.libbyapp.com/card/{id}/loan/{id}`)
- Official OverDrive API exists but uses different endpoints (not directly compatible)
- OverDrive API docs valuable as architectural reference for auth patterns
- Primary approach: Reverse engineer Libby's internal API
- ADE download process understood at high level
- Conservative approach planned to avoid library issues
