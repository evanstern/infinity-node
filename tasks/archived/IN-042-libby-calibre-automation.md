---
id: IN-042
title: "Research and Build Libby-to-Calibre Automation System"
status: archived
priority: 5
created: 2025-11-05
updated: 2025-11-05
tags:
  - research
  - automation
  - calibre
  - libby
  - proof-of-concept
  - libby-project
agents:
  - documentation
  - infrastructure
complexity: high
estimated_effort: 3-5 days
parent_project: libby-automation
---

# Research and Build Libby-to-Calibre Automation System

## Overview

**⚠️ This is the FIRST task in a multi-task project - work deliberately and collaboratively!**

Research and build a proof-of-concept automation system (in **TypeScript**) that can:
1. Connect to Libby (library app) via reverse-engineered API
2. Batch checkout books from a list (CSV/JSON)
3. Download ePub files via Adobe Digital Editions link automation
4. Import to Calibre and remove DRM
5. Return books automatically

This is a proof-of-concept to validate feasibility before building a full UI-based application.

**Project Philosophy:** We're building a complex system that will likely span multiple tasks. Work in tandem, consult before major decisions, present thoughts before implementing. Speed is NOT a priority - correctness and understanding are.

## Context

### Official OverDrive API Discovery

🎉 **FINDING:** OverDrive (makers of Libby) has an official API!

- **Documentation:** https://developer.overdrive.com/api-docs/authentication
- **Status:** Requires access request, restrictive ToS
- **Important:** Official API may be **different** from Libby's internal API
  - User's curl tests hit endpoints like `/loan/<id>` which don't exist in official docs
  - Official API appears to be for OverDrive platform (web, apps)
  - Libby may use a separate, internal API with different endpoints

**Strategic Value:**
- Official API docs provide **architectural reference** (auth patterns, data models)
- May not be a direct substitute for Libby's API
- Could still request official access to see if it supports our use case
- Best use: **Guide for reverse engineering** Libby's internal API structure

**Research Questions:**
1. Are OverDrive API and Libby API the same? (Evidence suggests NO)
2. Does official API support book checkout automation?
3. Can we use official API patterns to better understand Libby's internals?

### Working cURL Examples (Libby Internal API)

Successfully tested Libby API endpoints:

**List libraries:**
```bash
curl 'https://libbyapp.com/api/branding/libraries.json' \
  -H 'Accept-Language: en-US,en,la' \
  -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36'
```

**Borrow book (SUCCESSFUL TEST):**
```bash
curl 'https://sentry.libbyapp.com/card/97052173/loan/5626444' \
  -H 'Accept: application/json' \
  -H 'Authorization: Bearer [TOKEN]' \
  -H 'Content-Type: application/json' \
  --data-raw '{"period":14,"units":"days","lucky_day":null,"title_format":"audiobook",...}'
```

### Key Observations

- **Official OverDrive API exists** but appears separate from Libby's internal API
- **Libby uses custom endpoints:** `sentry.libbyapp.com/card/{id}/loan/{id}` (not in official docs)
- **Authentication:** Bearer token-based (likely similar pattern to official API)
- **API Endpoints:** `libbyapp.com` and `sentry.libbyapp.com` (Libby-specific)
- **Format:** Standard REST API with JSON payloads
- **Already tested:** Basic list and borrow operations work via Libby endpoints
- **ADE Integration:** Manual process involves downloading a link from Libby that auto-opens in ADE, which then downloads the ePub to ADE's directory (user-configurable location). File appears on filesystem as DRM'd ePub.
- **Library Limits:** 20 book checkout limit per card/library

**Strategic Decision:**
- **Primary approach:** Reverse engineer Libby's internal API (proven to work with curl tests)
- **Secondary use:** Official OverDrive API docs as architectural reference
- **Rationale:** Libby's `/loan/<id>` endpoints don't match official API structure

### Desired Workflow

```
Input (CSV/JSON) → Batch (5-10 books) → Checkout → Trigger ADE Link →
Wait for Download → Move to Calibre Import → DRM Removal → Return →
Optional Cooldown (10 min after 10 books) → Repeat
```

## Goals

1. **Research Phase:**
   - **PRIMARY:** Reverse engineer Libby's internal API via browser DevTools
   - **SECONDARY:** Review official OverDrive API as architectural reference
   - Document Libby API endpoints (sentry.libbyapp.com, libbyapp.com)
   - Understand authentication mechanism and token lifecycle
   - Map complete checkout → download → return flow
   - Identify rate limiting concerns
   - Document error scenarios (unavailable, waitlist, etc.)

2. **Build Phase:**
   - Create TypeScript CLI tool for automation
   - Implement book list parsing (CSV/JSON)
   - Integrate with Libby API (checkout/return)
   - Automate Adobe Digital Editions link handling and download monitoring
   - Integrate with Calibre CLI for import/DRM removal
   - Add error handling and reporting

3. **Validation Phase:**
   - Test with small batch (2-3 books)
   - Verify DRM removal works
   - Confirm return process completes
   - Document success/failure scenarios

## Pre-Task Review

### Critical Questions

**1. API Stability & Terms of Service**
- ✅ **OverDrive API exists** but appears different from Libby's internal API
- ✅ **Primary approach:** Reverse engineer Libby's internal API (already working with curl)
- ✅ **Official API value:** Architectural reference and authentication patterns
- ✅ **Strategy:** Conservative rate limiting, randomized delays, cooldown periods
- **NEEDS RESEARCH:** Libby endpoint stability (how often do they change?)
- **NEEDS RESEARCH:** Full authentication flow (token lifecycle, refresh mechanism)

**2. Technical Feasibility**
- ✅ **ADE Process:** Download link from Libby → auto-opens ADE → ADE downloads to configured directory → file appears on filesystem (DRM'd)
- **NEEDS RESEARCH:** How to programmatically trigger ADE link opening and monitor download completion
- ✅ **Calibre:** CLI support confirmed via `calibredb` and DeDRM plugin
- **NEEDS RESEARCH:** Token refresh mechanism and lifecycle

**3. Error Handling Strategy**
- ✅ **Book not available:** Skip + report in summary
- ✅ **Book on waitlist:** Skip + report (no holds automation in POC)
- ✅ **Download fails:** Note error, move on (no special retry logic initially)
- ✅ **DRM removal fails:** Quarantine file + report to user
- ✅ **Token expires:** Fail with clear error message (re-auth out of scope for POC)

**4. Rate Limiting & Ethics**
- ✅ **Batch size:** 5-10 books per batch (library limit: 20 total)
- ✅ **Cooldown:** 10-minute pause after every 10 books
- ✅ **Delays:** Randomized delays between operations
- ✅ **Philosophy:** Not stress-testing, just automating manual process. Taking a week to process thousands of books is fine.
- Goal: Don't anger librarians (they're scary!)

**5. Security & Privacy**
- ✅ **Token storage (POC):** In-memory during script execution, no persistent storage needed yet
- ✅ **Token expiration:** Script fails with clear error, manual re-auth required
- ✅ **Auth automation:** Explore automating auth WITHIN the script
- ✅ **Book storage:** Files automatically moved to Calibre import directory (user will specify location), Calibre handles rest
- ✅ **Long-term:** Vaultwarden integration deferred to future tasks

**6. Book Data Strategy**
- **NEEDS DECISION:** Query per book individually vs. pull master paginated list and search locally?
- **Trade-off:** Master list = fewer queries but pagination complexity; Individual queries = simpler but more API calls
- **Storage:** Flat files for POC (`.gitignore`d), SQLite for future phases

### Known Risks

1. **Account Ban Risk:** Low if conservative (already doing manually)
2. **API Changes:** Undocumented API could change without notice
3. **DRM Legal Gray Area:** Personal use should be fine, no redistribution
4. **ADE Automation:** May require platform-specific link handling (macOS `open` command)
5. **Rate Limiting:** Mitigated by conservative approach and cooldown periods

### Dependencies

- Node.js 18+ and TypeScript
- Adobe Digital Editions (installed on host, with configured download directory)
- Calibre CLI tools (`calibredb`, `ebook-convert`)
- Calibre DeDRM plugin (for DRM removal)
- Access to Libby account with active library card
- Bearer token extraction method (browser DevTools)

### Success Criteria

- [ ] Document 10+ Libby API endpoints with authentication details
- [ ] Understand and document ADE link triggering mechanism (macOS)
- [ ] Successfully checkout → download → import → return cycle for 1 book
- [ ] Batch processing works for 3+ books with proper delays
- [ ] Error reporting captures all failure modes
- [ ] DRM removal success rate >90%
- [ ] No account issues/bans during testing
- [ ] Clear documentation for future UI development
- [ ] Cooldown mechanism works (10 min after 10 books)

## Acceptance Criteria

### Research Deliverables

- [ ] Document Libby API endpoints in `/docs/research/libby-api-endpoints.md`
- [ ] OverDrive API architectural reference notes (auth patterns, data models)
- [ ] Comparison: Official OverDrive API vs. Libby's internal API
- [ ] Authentication flow documented with in-script automation strategy
- [ ] ADE link handling research documented (how to trigger, monitor completion)
- [ ] Rate limiting analysis and recommended delays/cooldown strategy
- [ ] Error scenario mapping (unavailable, waitlist, failures)
- [ ] Decision: Individual queries vs. master list pagination approach

### Implementation Deliverables

- [ ] TypeScript CLI tool structure: `scripts/automation/libby/`
- [ ] Package setup with TypeScript, dependencies in `package.json`
- [ ] Input format specification (CSV/JSON schema)
- [ ] Libby API client module with rate limiting
- [ ] ADE link handler and download monitor
- [ ] Calibre integration working (import + DRM removal)
- [ ] Book return automation implemented
- [ ] Cooldown mechanism (10 min after 10 books)
- [ ] Error reporting output (success/failure summary)
- [ ] README with usage instructions and token setup

### Validation Deliverables

- [ ] Successfully process 3-book batch end-to-end
- [ ] Error handling tested (skip unavailable book)
- [ ] Performance metrics captured (time per book, success rate)
- [ ] No rate limiting or account issues observed
- [ ] DRM-free books imported to Calibre library

## Execution Plan

**⚠️ COLLABORATIVE WORK REQUIRED: Consult before major decisions, present thoughts before implementing**

### Phase 1: Deep Research & API Mapping (Day 1)

**Goal: Thoroughly understand Libby's internal API and ADE integration**

- [ ] **1.0** Review OverDrive API Documentation (Reference Only)
  - Review [OverDrive API docs](https://developer.overdrive.com/api-docs/authentication) for architectural patterns
  - Note authentication approach (likely informs Libby's auth)
  - Understand data models and structures
  - **Key insight:** Libby uses different endpoints (e.g., `/loan/<id>` not in official API)
  - **Purpose:** Use as reference guide, not direct implementation
  - **COLLABORATE:** Share architectural insights learned

- [ ] **1.1** Deep dive into Libby's internal API (PRIMARY FOCUS)
  - Use browser DevTools to capture all API calls during typical workflow
  - Document request/response formats for each Libby-specific endpoint
  - Map endpoints: `libbyapp.com/*` and `sentry.libbyapp.com/*`
  - Identify all `/card/{id}/loan/{id}` type patterns
  - Compare authentication with OverDrive API patterns (similar Bearer token structure?)
  - Map complete user journey: search → borrow → download URL generation → return
  - **CONSULT:** Present findings on Libby API structure before proceeding

- [ ] **1.2** Extract and test key endpoints
  - Search/browse: Find book by title/author/ISBN
  - Borrow: Checkout book (already tested ✓)
  - Loan status: Check current loans
  - Download URL: Get ADE link for borrowed book
  - Return: Return book early
  - Holds: Check if holds/waitlist API exists (for future phase)
  - **COLLABORATE:** Share curl examples for validation

- [ ] **1.3** Authentication deep dive
  - How to obtain Bearer token programmatically? (explore automation)
  - Token structure and claims (JWT?)
  - Token expiration time and behavior when expired
  - Test if token survives across sessions
  - Multiple cards/libraries handling in token
  - **CONSULT:** Review authentication strategy before implementation

- [ ] **1.4** ADE Link Handling Research
  - **CRITICAL:** Understand the download link format from Libby
  - Test triggering link with macOS `open` command
  - Determine ADE download directory location (user will specify)
  - How to monitor for download completion? (file watcher, polling?)
  - What happens if ADE isn't running? Does `open` launch it?
  - Can we detect download failures?
  - **CONSULT:** Present ADE automation approach before coding

- [ ] **1.5** Rate limiting analysis
  - Test conservative request patterns (3-5 second delays)
  - Document any 429 responses or rate limit headers
  - Check response times to gauge server load
  - **Decision point:** Individual queries vs. master list approach
    - Test pagination if going master list route
    - Test search endpoint if going individual query route
  - **COLLABORATE:** Discuss trade-offs and decide on approach

- [ ] **1.6** Document findings
  - Create `/docs/research/libby-api-endpoints.md`
  - Include curl examples for each Libby endpoint
  - Document OverDrive API architectural patterns (as reference)
  - Note similarities/differences between official OverDrive and Libby APIs
  - Document ADE integration mechanism
  - Note any undocumented behaviors or quirks
  - Flag remaining risks and unknowns
  - **Present findings for review**

### Phase 2: Architecture & Design (Day 1-2)

**Goal: Design TypeScript architecture that's maintainable and extensible**

- [ ] **2.1** Design TypeScript CLI architecture
  - Input parser (CSV/JSON)
  - Libby API client class with rate limiting
  - ADE link handler module
  - Calibre integration module
  - Cooldown manager (10 min after 10 books)
  - Error handling and reporting
  - Logging strategy
  - **CONSULT:** Present architecture diagram and module breakdown

- [ ] **2.2** Define input format
  - CSV schema: title, author, ISBN, format preference
  - JSON alternative structure
  - Validation rules (required fields, format checks)
  - Example files for testing
  - **COLLABORATE:** Review input format with user

- [ ] **2.3** Error handling strategy
  - Book unavailable: Skip + log to summary
  - Book on hold: Skip + log (future: add to hold queue?)
  - Download timeout: How long to wait? Fallback behavior?
  - DRM removal failure: Quarantine directory + detailed log
  - Network errors: Simple retry or fail fast?
  - Token expiration: Clear error message + exit
  - **CONSULT:** Review error handling approach

- [ ] **2.4** TypeScript project structure
  - `scripts/automation/libby/` directory
  - `package.json` with dependencies (node-fetch, commander, csv-parse, etc.)
  - `tsconfig.json` configuration
  - Module organization (src/ directory structure)
  - Build and run scripts
  - **COLLABORATE:** Review project setup

- [ ] **2.5** Design document
  - Create `.docs/libby-automation-design.md` in libby directory
  - Include flowcharts/pseudo-code
  - List external dependencies and why chosen
  - Rate limiting and cooldown strategy
  - Note future UI considerations (keep in mind for design decisions)
  - **Present design for review before implementation**

### Phase 3: Core Implementation (Day 2-3)

**Goal: Build the core TypeScript modules with careful testing**

- [ ] **3.1** Setup TypeScript project
  - Create `scripts/automation/libby/` directory structure
  - Initialize `package.json` with TypeScript and dependencies
  - Configure `tsconfig.json` (target ES2020+, strict mode)
  - Add build scripts and dev scripts
  - Setup `.gitignore` (node_modules, dist, *.env, book lists)
  - **COLLABORATE:** Review setup before proceeding

- [ ] **3.2** Implement Libby API client
  - `src/libby-client.ts`: Core API wrapper class
  - Methods: search, borrow, getCurrentLoans, getDownloadUrl, returnBook
  - Authentication handling (Bearer token from CLI arg or env var)
  - Rate limiting with configurable delays + random jitter
  - Request/response logging
  - Error handling and typed responses
  - **CONSULT:** Review API client implementation
  - **TEST:** Verify against actual Libby API with curl equivalents

- [ ] **3.3** Implement book list parser
  - `src/book-parser.ts`
  - Support CSV and JSON input formats
  - Validation (required fields: title, author)
  - Optional fields: ISBN, format preference
  - Deduplication logic
  - Batch splitting (configurable size, default 10)
  - **COLLABORATE:** Test with sample book lists

- [ ] **3.4** Implement Adobe Digital Editions handler
  - `src/ade-handler.ts`
  - Method: triggerDownload(adeLink: string, adeDir: string)
  - Use Node.js `child_process` to execute macOS `open` command
  - Method: waitForDownload(adeDir: string, timeout: number)
  - File watcher or polling approach for completion detection
  - Return downloaded file path or timeout error
  - **CONSULT:** Present ADE handler approach
  - **TEST:** Manual testing with actual ADE link

- [ ] **3.5** Implement Calibre integration
  - `src/calibre-client.ts`
  - Method: importBook(epubPath: string, calibreLib: string)
  - Use `child_process` to call `calibredb add`
  - Verify import success by checking exit code
  - Method: removeDRM (handled by Calibre DeDRM plugin during import?)
  - Error handling for failed imports
  - **CONSULT:** Review Calibre CLI usage
  - **TEST:** Import test ePub file

- [ ] **3.6** Implement cooldown manager
  - `src/cooldown.ts`
  - Track book count and trigger 10-min cooldown after 10 books
  - Progress logging during cooldown
  - Configurable cooldown duration
  - **COLLABORATE:** Review cooldown logic

### Phase 4: CLI Tool Assembly (Day 3-4)

**Goal: Integrate all modules into working CLI application**

- [ ] **4.1** Main CLI application
  - `src/cli.ts` (entry point)
  - Use `commander` for argument parsing
  - Required: --token, --input, --ade-dir, --calibre-lib
  - Optional: --batch-size, --delay, --cooldown
  - Orchestrate full workflow: parse → batch → checkout → download → import → return
  - Progress reporting (book X of Y, current phase)
  - **CONSULT:** Review CLI interface design

- [ ] **4.2** Logging and reporting
  - Use structured logging library (winston or pino)
  - Log levels: INFO (progress), WARN (skipped), ERROR (failures)
  - Summary output at end: successful count, skipped count, failed count
  - Per-book status in output file (`results.json`)
  - Error details for debugging (stack traces, API responses)
  - **COLLABORATE:** Review logging approach

- [ ] **4.3** Configuration file support
  - Optional `libby-config.json` in project root
  - Default values: batch size (10), delay (3-5s), cooldown (10min)
  - Path configuration: ADE directory, Calibre library location
  - CLI args override config file
  - **CONSULT:** Review configuration strategy

- [ ] **4.4** Build and run scripts
  - `npm run build` - compile TypeScript
  - `npm run dev` - run with ts-node for development
  - `npm start` - run compiled version
  - Add example run command to README
  - **COLLABORATE:** Test build process

- [ ] **4.5** Testing with mock/test data
  - Create test CSV with 2-3 known books
  - Test input parsing and validation
  - Test error handling (mock unavailable book response)
  - Verify logging output format
  - **CONSULT:** Review before live API testing

### Phase 5: End-to-End Testing (Day 4-5)

**Goal: Validate complete workflow with real books - GO SLOW!**

- [ ] **5.1** Single book test (CRITICAL VALIDATION)
  - Choose one book known to be available
  - Run full cycle: checkout → trigger ADE → wait for download → import → return
  - Verify ADE link opens and downloads correctly
  - Check DRM removal worked (can open in different reader)
  - Confirm book appears in Calibre library
  - Verify book returned successfully in Libby
  - **COLLABORATE:** Review results before proceeding

- [ ] **5.2** Small batch test (3 books)
  - Test with 3 books, all known to be available
  - Verify batch processing with delays
  - Check cooldown logic (won't trigger with only 3)
  - Monitor API responses and timing
  - Check error reporting for any issues
  - **CONSULT:** Discuss any issues or unexpected behavior

- [ ] **5.3** Error scenario testing
  - Test with unavailable book (verify skip + log behavior)
  - Test with invalid input (malformed CSV, missing fields)
  - Test token expiration if possible (or simulate)
  - Test ADE timeout (long download or ADE not running)
  - Test Calibre import failure (invalid file)
  - **COLLABORATE:** Review error handling effectiveness

- [ ] **5.4** Cooldown mechanism test
  - Test with 11+ books to trigger cooldown
  - Verify 10-minute pause after 10th book
  - Check that processing resumes correctly after cooldown
  - **CONSULT:** Validate cooldown behavior

- [ ] **5.5** Performance and reliability
  - Measure time per book (average)
  - Calculate success rate
  - Document any API quirks or failures
  - Note any rate limiting encountered (should be none with conservative approach)
  - Check for any account issues or warnings
  - **COLLABORATE:** Present performance metrics and observations

### Phase 6: Documentation & Handoff (Day 5)

**Goal: Document everything for future development and usage**

- [ ] **6.1** User documentation
  - `scripts/automation/libby/README.md`
  - Installation instructions (Node.js, dependencies, ADE, Calibre)
  - How to extract Bearer token from browser (step-by-step with screenshots if helpful)
  - Example usage commands with all options explained
  - Configuration file format and options
  - Troubleshooting guide (common errors and solutions)
  - **COLLABORATE:** Review documentation for clarity

- [ ] **6.2** Technical documentation
  - Code documentation (JSDoc comments for all public methods)
  - API endpoint reference (all discovered Libby endpoints)
  - Error codes and meanings
  - Architecture overview (module interactions)
  - Future enhancement ideas
  - **CONSULT:** Ensure technical docs are complete

- [ ] **6.3** Research artifact finalization
  - Finalize `/docs/research/libby-api-endpoints.md`
  - Include success rates and findings from testing
  - Document API quirks and behaviors
  - Note any limitations discovered
  - Recommend next steps (UI development, additional features)
  - List potential follow-up tasks
  - **PRESENT:** Research findings summary

- [ ] **6.4** Demo and knowledge transfer
  - Live demo of CLI tool if possible
  - Walk through code structure and key decisions
  - Discuss long-term viability based on testing
  - Propose next phase: Web UI or additional features?
  - **COLLABORATE:** Final discussion and next steps

## Open Questions

**Most questions answered - remaining items for research phase:**

1. **Libby Internal API Mapping (HIGHEST PRIORITY)**
   - Map all Libby-specific endpoints (`libbyapp.com`, `sentry.libbyapp.com`)
   - Document `/card/{id}/loan/{id}` and similar patterns
   - Understand Bearer token structure and lifecycle
   - How does authentication work? Can we automate token extraction?

2. **OverDrive API as Reference**
   - Review official docs: https://developer.overdrive.com/api-docs/authentication
   - Extract architectural patterns (auth flow, data models)
   - Note similarities to help understand Libby's internal API
   - **Clarified:** Different APIs, official API not directly usable

3. **ADE Link Handling:**
   - Research: Exact link format from Libby API
   - Research: Does macOS `open` command work reliably?
   - Research: How to detect download completion vs. timeout?

4. **Book Search Strategy:**
   - **DECISION NEEDED:** Query per book vs. master list pagination?
   - Will decide during Phase 1 research based on API exploration

5. **Calibre DRM Removal:**
   - Confirm: Does DeDRM plugin work automatically during import?
   - Or do we need explicit DRM removal step?

## Follow-Up Tasks

After POC validation, potential next tasks (will be tagged with `libby-project`):

- **IN-XXX:** Build web UI for Libby automation (React + FastAPI or Next.js)
- **IN-XXX:** Dockerize Libby automation service for deployment to VM 103
- **IN-XXX:** Add hold/waitlist management features
- **IN-XXX:** Multi-library card support
- **IN-XXX:** Reading list import from Goodreads/other sources
- **IN-XXX:** Notification system (book available, import complete)
- **IN-XXX:** Create dashboard view for libby-project tagged tasks

## Recommendations & Considerations

### Technical Recommendations

**Language Choice: TypeScript ✅**
- ✅ User expertise and preference
- Easier transition to web UI later (shared code)
- Strong typing helps with API client development
- Great CLI libraries available (commander, inquirer)
- Node.js ecosystem for file operations

**Architecture: Modular TypeScript CLI**
```
libby-automation/
├── src/
│   ├── libby-client.ts      # API wrapper with rate limiting
│   ├── book-parser.ts        # CSV/JSON input parsing
│   ├── ade-handler.ts        # ADE link triggering & monitoring
│   ├── calibre-client.ts     # Calibre CLI integration
│   ├── cooldown.ts           # Cooldown manager
│   ├── types.ts              # TypeScript interfaces
│   └── cli.ts                # Entry point
├── package.json
├── tsconfig.json
├── .gitignore
└── README.md
```

**Error Handling: Fail-Safe Approach ✅**
- Skip problematic books, don't abort batch
- Detailed error reporting at end
- Quarantine failed files (don't delete)
- Simple error handling initially (no complex retry logic)

**Rate Limiting: Conservative by Default ✅**
- 3-5 second delay between operations with random jitter
- Configurable via CLI flag
- 10-minute cooldown after every 10 books
- Respect any HTTP 429 responses (though unlikely with this approach)
- Philosophy: Slow and steady, librarians are scary!

### Batch Size Recommendation ✅

Batch configuration based on library limits and safety:
- **Library limit:** 20 books total per card
- **Default batch size:** 10 books
- **Cooldown trigger:** After every 10 books, pause 10 minutes
- **Initial testing:** Start with 1, then 3, then 10
- **Philosophy:** Taking a week to process thousands of books is fine!

### Security Recommendations

**Token Storage (POC Scope) ✅:**
- Pass Bearer token via CLI argument or environment variable
- Held in memory during script execution only
- No persistent storage for POC
- Token expiration: Script fails with clear error message
- **Future:** Vaultwarden integration in later phases

**Token Automation:**
- Research automating token extraction within script (Phase 1)
- Fallback: Manual extraction via browser DevTools (documented)

**Book List Storage ✅:**
- Input files stored outside git repo (user's choice of location)
- `.gitignore` pattern for any book lists in project
- No sensitive data concerns (just book titles/authors)
- **Future:** SQLite database for persistence in UI phase

### Ethical Considerations ✅

**Library System Respect:**
- Use reasonable delays (3-5 seconds minimum, randomized)
- 10-minute cooldown after every 10 books
- Don't circumvent hold queues (skip books on waitlist)
- Return books promptly after DRM removal
- Monitor for any library system issues

**Terms of Service:**
- Acknowledge risk of API reverse engineering
- Conservative approach should fly under radar
- Personal use only (already doing manually)
- User assumes responsibility
- Be prepared to stop if library objects

**DRM Removal ✅:**
- Personal use only, no redistribution
- User's media system for personal use
- Not legal advice - user assumes responsibility
- Tool for personal library management only
- **NEVER redistribute DRM-free files**

### Future UI Considerations

**When building web interface (post-POC):**

**Features to Add:**
- Visual book list management (add/remove/reorder)
- Real-time progress tracking with WebSocket updates
- Cover image display from Libby API
- Library card management (multiple cards)
- Schedule batch jobs (run overnight, etc.)
- Import history/analytics dashboard
- Book availability monitoring
- Hold/waitlist management

**Tech Stack Suggestions:**
- **Option A - Full Stack TypeScript:**
  - Next.js (React + API routes)
  - tRPC for type-safe API
  - Prisma + SQLite for data
  - Tailwind CSS for styling

- **Option B - Separated:**
  - Frontend: React or Vue.js
  - Backend: FastAPI (Python) or NestJS (TypeScript)
  - Database: PostgreSQL for production scale
  - Queue: Bull (Redis) for background jobs

**Docker Deployment (VM 103):**
- Separate containers: web, worker, database
- Volume mounts for Calibre library access
- Secure secrets via Docker secrets or env vars
- Portainer stack integration (git-ops ready)
- Reverse proxy via Traefik or Nginx

**Key Design Principles:**
- Keep CLI tool functional (power users)
- Web UI wraps CLI functionality
- Shared TypeScript types between CLI and UI
- Background job queue for long-running operations

### Alternative Approaches

**Option A: Pure CLI ✅ (Recommended for POC)**
- Fast to build and test
- Easy to debug and iterate
- Scriptable/automatable
- Low maintenance
- **THIS IS OUR APPROACH**

**Option B: TUI (Terminal UI)**
- Use `blessed` or `ink` (React for CLI)
- Better progress visualization
- Still runs in terminal
- Medium complexity
- **Consider for Phase 2 if CLI feels too bare**

**Option C: Web UI (Future Phase)**
- Best UX for non-technical users
- Requires more infrastructure
- Harder to debug initially
- Best for long-term use
- **Post-POC if successful**

**Recommendation:** Start with Option A (pure CLI) for POC. If successful and useful, move to Option C (web UI) for family/household use.

## Risk Mitigation

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|---------|------------|
| Account ban | Low | High | Conservative rate limits, cooldowns, already doing manually |
| API changes | Medium-High | High | Modular code for easy updates, comprehensive docs |
| ADE automation fails | Medium | High | Research thoroughly in Phase 1, fallback to manual if needed |
| DRM removal fails | Low | Medium | Quarantine + manual review, DeDRM plugin well-established |
| Token expiration | High | Low | Clear error message + simple re-run with new token |
| Rate limiting | Very Low | Low | Conservative delays + cooldowns, monitoring |

## Notes

- This is explicitly a **proof-of-concept** - validate before investing in full UI
- **COLLABORATION IS KEY** - Work in tandem, consult before major decisions
- Focus on **reliability over speed** - better to take 5 minutes per book than fail
- **Document everything** - API behaviors, failures, quirks, decisions
- Consider **legal implications** in your jurisdiction (personal use should be fine)
- Be prepared to **abandon** if technical or ToS barriers are too high
- This is a **learning project** - embrace the research phase
- **Don't anger librarians** - they're scary! 📚

## Work Log

<!-- Add timestamped notes as work progresses -->

## Lessons Learned

<!-- Capture insights during and after execution -->

---

**Related:**
- [[CALIBRE]] - Calibre library management
- [[SECRET-MANAGEMENT]] - For Bearer token storage
- Future tasks: Web UI, Docker deployment, enhanced features
