# ODEL Module — Progress Tracker

> Living status of the ODEL build. Legend: ✅ done · 🟡 in progress · ⬜ pending (planned) · ⏭ deferred to a later phase.
> Companion docs: `ODEL_MODULE_SPEC_AND_TASKS.md` (spec), `ODEL_CONSULTANT_PROMPT.md` (brief). Updated 2026-07-05.

---

## A. Architecture / centralization (this pass)

| Item | Status | Notes |
|---|---|---|
| Centralized **API backend** `OdelApi.ashx` (portal) | ✅ | One handler → App_Code service layer (`OdelService`/`OdelPushService`/`OdelNotify`). **GET reads** (refresh-safe), POST writes. All 8 portal pages now call it; verified live. |
| Shared client lib **`odel/odel.js`** | ✅ | `Odel.get/post`, toast, loader, esc/fmt, **drag-and-drop dropzone** (with per-file progress), **GET-state** (`Odel.state`), pagination, tabs. Served 200. |
| Shared stylesheet **`odel/odel.css`** | ✅ | Design tokens + components (cards, tiles, tables, buttons, badges, KPIs, meters, forms, tabs, dropzone, toast, loader, pager) — page CSS de-duplicated. Served 200. |
| GET/URL-driven page state (refresh-safe) | ✅ | `?space=`/`?a=` read from URL; refresh preserves the page. |
| Drag-and-drop uploads | ✅ | `Odel.dropzone` used by Submit (student) + Content builder (lecturer). |
| Centralized business logic (`OdelCore` + `OdelService`) | ✅ | All action logic lives in App_Code (DRY); page code-behinds gutted to thin shells. |
| eadmin styling | ✅ | Already navy design-system consistent; retains eadmin PageMethods + Chart.js pattern (separate app). |

## B. Phase-1 (MVP) features

| Feature | Status | Notes |
|---|---|---|
| Schema (`odel_*`) + seeded policies | ✅ | campus_dynamics_portal |
| Course-space auto-provisioning | ✅ | from `acad_programmecourses.lecturer_id` |
| File service (upload + entitlement-checked download) | ✅ | multipart now; **chunked/resumable = ⏭ P2** |
| Activity log | ✅ | `odel_activity_log` |
| **Lecturer:** My Teaching home | ✅ | compliance meters |
| **Lecturer:** Content builder + copy-forward | ✅ | topics/materials (file/page/link) |
| **Lecturer:** Assignment builder | ✅ | weights, publish |
| **Lecturer:** Grading + queue | ✅ | → gradebook recompute |
| **Lecturer:** Coursework Push (linchpin) | ✅ | writes provisional_course_work_marks 0–40; verified sabia→31/40 |
| **Student:** My Learning home | ✅ | deadlines, running coursework, compliance |
| **Student:** Course space + materials | ✅ | size labels |
| **Student:** Submission + receipt | ✅ | autosave + upload + emailed receipt |
| **Student:** Running coursework & feedback | ✅ | on course space |
| **Admin:** Monitoring dashboard | ✅ | Chart.js KPIs + compliance |
| **Admin:** Policy Centre | ✅ | versioned |
| Menu wiring (eportal + eadmin) | ✅ | nav + sidebar |
| Notifications (receipt + assignment-published) | ✅ | via EmailSenderProtocol |
| Bulk grading (ZIP down / CSV up) | ⬜ | queue done; bulk tools pending |
| Rubric-based grading | ⬜ | tables exist; UI pending |
| Pagination on long lists (GET-state) | 🟡 | added via odel.js this pass |

## C. Phase-2 (planned next)

⬜ Quizzes + question banks · ⬜ Discussion forums · ⬜ SMS + adaptive reminders (gateway) · ⬜ Class analytics · ⬜ At-risk console · ⬜ Workload/timetable view · ⏭ Live-session scheduling + attendance (external links) · ⬜ Exception/extension approvals · ⬜ Rollover assistant · ⬜ Storage console · ⬜ Chunked resumable uploads · ⬜ Faculty/dept dashboard scoping · ⬜ Appraisal compliance feed.

## D. Phase-3 (later)

⏭ Similarity screening + integrity console · ⏭ Peer review · ⏭ Offline packs · ⏭ Audio feedback · ⏭ Badges/certificates · ⏭ Sponsor digest · ⏭ USSD · ⏭ Short-course/CPD storefront.

---

## This pass — task list (UI/UX + centralization) — ✅ DONE
1. ✅ Central API `OdelApi.ashx` (+ App_Code service layer) + `odel.js` + `odel.css`.
2. ✅ Refactored all 8 portal pages → shared infra, AJAX, GET-state, drag-drop, consistent design; code-behinds gutted to shells.
3. ✅ eadmin pages retained (navy-consistent, PageMethods + Chart.js).
4. ✅ Mastering pass: added `ping`, `push.history`, `push.snapshot`; GET cache-buster; push-history UI. All actions route; sabia verified (31/40).
5. ✅ **`COOPERP/ODEL_API.md`** — full reference for all 26 endpoints (central API actions, file handlers, eadmin PageMethods) with method, auth, params, response shape, errors, examples.

## E. API
| Item | Status |
|---|---|
| Central API `OdelApi.ashx` (21 actions inc. ping/history/snapshot) | ✅ |
| File handlers (`OdelUpload.ashx`, `OdelFile.ashx`, `ViewPage.aspx`) | ✅ |
| eadmin PageMethods (dashboard, policy) | ✅ |
| **API documentation `ODEL_API.md`** | ✅ every endpoint documented + verified live |
