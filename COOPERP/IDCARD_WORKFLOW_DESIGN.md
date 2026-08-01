# ID Card Request & Printing Module — Design & Task Blueprint

**Muteesa I Royal University · Campus Dynamics**
Status: DESIGN (no code yet) · Author: engineering · Last updated: 2026-07-15
Partner / print bureau: **XAXU** (operates the existing **OmniPass** card system, `omnipass.mru.ac.ug`)

---

## BUILD STATUS (2026-07-15) — core module BUILT & verified

Decisions in §14a were taken and the working module was built end-to-end. Verified against live data (SABIA finance-gate block, full state-machine walk, list/detail/stats/identity queries). Activates on next app-pool recycle of each app.

**Delivered (working):**
- **Data model** — `idcard_requests`, `idcard_request_events`, `idcard_windows` (campus_dynamics) + `hrm_employee.photo_file`. SQL: `COOPERP/sql/idcard_schema.sql`; self-healed by `IDCardService.EnsureSchema`.
- **Engine** — `App_Code/IDCard/IDCardService.cs` (state machine, one-active-request guard, `IDR-YYYY-NNNNNN` generator, single audited `Transition()` funnel with optimistic guard + email hook) and `IDCardService.Business.cs` (identity, 10% finance gate, windows, submit, list/detail/stats, action dispatch, branded email templates). Copied into the eportal app too (both compile their own copy against the same DB; connection + email resolved per-app).
- **eadmin** — `COOPERP/NewScreens/IDCardController.aspx(.cs)`: dashboard counts, filterable request list, detail (identity + timeline + finance + replacement proof), Approve/Halt/Printed/Ready/Collected/Cancel actions, and Request-Windows CRUD. Sidebar link added under Students.
- **eportal** — `IDCardRequest.aspx(.cs)`: strict wizard (identity + photo confirm + guidelines + card type → finance gate + replacement-fee proof + submit) and a live status tracker for the person's existing request; every WebMethod acts only on the session-owner's request. Menu link added under All Services.
- **XAXU API** — `API/v2/idcard.aspx(.cs)`: token-authed, rate-limited, action-routed (`queue`, `detail`, `windows`, `approve`, `halt`, `printed`, `ready`, `collected`) funnelling into the same `Transition()`.
- **Email** — decoupled behind `IDCardService.Mailer`, wired in both apps' `Application_Start` to their own `EmailSenderProtocol` (signatures differ). Fires on SUBMITTED/APPROVED/HALTED/PRINTED/READY/COLLECTED.

**Deliberately deferred (follow-on, not blocking the flow):**
- Photo **upload/crop** UI (today the wizard confirms the existing `photofile`; students update via profile). 
- OmniPass **auto-reconcile** into the lifecycle (eadmin/API mark PRINTED manually today; `OmniPassHelper` pull still runs).
- XAXU **token issuance** + documented rate limits.

---

## 0. Purpose of this document

This is the agreed blueprint for a **new, independent ID Card module** covering the full request → print → collection lifecycle for **students and teachers**, across **eportal** (self-service), **eadmin** (administration + XAXU operations), and a **secured API** for XAXU integration.

It is written as **tasks**. Nothing here is built yet. Build only after this document is signed off, and build in the phase order in Section 12.

Guiding rules for the whole module:
- One active request per person at a time.
- Every state change is **auditable**, **email-notified**, and **exposed via API**.
- The wizard is **strictly sequential** — a step cannot be reached until the previous step is valid.
- **Reuse** what already exists; do not duplicate or fork it (see Section 2).
- Maintain the existing eportal and eadmin **UI/UX standards** (design system in `NewScreens/DESIGN_SYSTEM.md`; portal chrome `PortalMaster.master`).

---

## 1. What already exists (verified against the codebase)

| Asset | Where | Role in the new module |
|---|---|---|
| **XAXU/OmniPass status pull** | `App_Code/OmniPassHelper.cs` → `GET omnipass.mru.ac.ug/api/external/student-cards/{mru}` | Currently **read-only**: pulls `PRINTED / NOT_PRINTED / NOT_FOUND` into `acad_student.id_card_status` + `id_card_checked_at`. Will be **wrapped, not replaced** — the new print/collect statuses supersede it and it becomes one input to the richer lifecycle. |
| **eadmin ID status screen** | `COOPERP/NewScreens/IDCardStatus.aspx(.cs)` | Existing status board + batch sync. Evolves into (or links to) the new admin dashboard. |
| **eportal student ID view** | `StudentIDStatus.aspx` | Existing student status page. Becomes the entry point / status tracker for the wizard. |
| **ID card print artwork** | `App_Code/XtraReports/StudentDocs/IDCard.cs` | The physical card layout (used if we ever print in-house; XAXU prints today). |
| **API verifiers** | `API/id_verifier.aspx`, `API/staff_id_verifier.aspx` | Existing public verify-by-number endpoints; extend under the v2 pattern. |
| **API v2 auth** | `App_Code/TokenManager.cs` → `TokenManager.RequireAuth(Request, Response)` (Bearer) | Auth pattern for all new API endpoints. |
| **Email** | `App_Code/communications/EmailSenderProtocol.cs` → `SendHtmlEmail(message, recipients, subject, sender)` | The single mailing entry point for all notifications. |
| **Student photo** | `acad_student.photofile` (+ `signfile`) | Source of the student photo shown/confirmed in Step 1. |
| **Finance engine** | `fin_GetProgrammeFee(prog, studyyear, sem, …)`, `fin_GetCanonicalStudentBalance(regno)`, `fin_studentfeestracking` | Basis of the Step-2 finance gate (10% rule). |
| **Student / staff identity** | `acad_student` (regno, entryno, names, progid, studyyear), `hrm_employee` (empID, emp_name, emp_email, usernames) | The two requester types. |

### Gaps this module must close
- **Staff have no photo field.** `hrm_employee` stores no photo. A staff photo column + upload flow must be added (Task 3.4 / 5.x).
- The existing OmniPass status vocabulary (`PRINTED/NOT_PRINTED/NOT_FOUND`) is **narrower** than the new lifecycle. We keep it as a sync input but drive the module off the new `status` (Section 4).
- Replacement fee is paid **to XAXU's own accounts** (not the university), so it will **never** appear in `fin_ledger` — it is handled as **proof-of-payment** metadata, not a GL transaction (Section 8.2).

---

## 2. Reuse decisions (do not re-invent)

- **One controller in eadmin** owns the whole lifecycle: `IDCardController.aspx` (+ `App_Code/IDCard/IDCardService.cs` engine, mirroring the `StageConsoleShared` / `MarksControllerShared` service pattern already in the repo).
- **Email** only through `EmailSenderProtocol.SendHtmlEmail`.
- **Finance** only through the existing `fin_*` functions — no new balance math.
- **API** under `API/v2/` using `TokenManager.RequireAuth` + the existing JSON response conventions.
- **XAXU** through an enhanced `OmniPassHelper` (rename its role to `XaxuGateway` internally if clearer), preserving the current `student-cards` pull.

---

## 3. Data model (new)

All new tables in `campus_dynamics` (or `campus_dynamics_portal` if student-photo writes are portal-side — decide in Task 0.2). Auto-create/self-heal on controller load, as other modules do.

### 3.1 `idcard_requests` — the spine of the module
| Column | Type | Notes |
|---|---|---|
| `id` | INT PK AI | internal id |
| `request_no` | VARCHAR(20) UNIQUE | human Request ID, e.g. `IDR-2026-000123` (Task 4.3 generator) |
| `requester_type` | ENUM('STUDENT','STAFF') | |
| `regno` | VARCHAR(35) NULL | for students (= `acad_student.regno`) |
| `emp_id` | INT NULL | for staff (= `hrm_employee.empID`) |
| `card_type` | ENUM('NEW','REPLACEMENT') | |
| `status` | VARCHAR(20) | state machine, Section 4 |
| `photo_ref` | VARCHAR(255) NULL | snapshot of the photo file used at request time |
| `photo_confirmed` | TINYINT | student confirmed the photo |
| `guidelines_ack` | TINYINT | read-and-understood the photo guidelines |
| `finance_ok` | TINYINT NULL | Step-2 result (students only) |
| `finance_snapshot_json` | TEXT NULL | the numbers behind the gate (fee, paid, %) for audit |
| `replacement_fee_ref` | VARCHAR(60) NULL | XAXU payment reference (replacement only) |
| `replacement_fee_date` | DATE NULL | |
| `replacement_fee_method` | VARCHAR(20) NULL | MTN / Centenary |
| `replacement_fee_notes` | VARCHAR(255) NULL | |
| `window_id` | INT NULL | the open window it was submitted under |
| `halt_reason` | VARCHAR(255) NULL | XAXU rejection/halt reason |
| `submitted_at` / `approved_at` / `printed_at` / `ready_at` / `collected_at` | DATETIME NULL | timeline stamps |
| `approved_by` / `printed_by` / `collected_by` | VARCHAR(150) NULL | actor at each stage |
| `created_at` / `updated_at` | DATETIME | |

**Constraint:** a partial-unique rule enforcing **one active request per person** (Task 4.2): unique on `(requester_type, COALESCE(regno,emp_id))` where `status` is not terminal (`COLLECTED`/`CANCELLED`). Enforce in code + a guard, since MySQL 5.6 lacks partial indexes.

### 3.2 `idcard_request_events` — full audit trail
`id, request_id, from_status, to_status, actor, actor_role, channel(ENUM eportal/eadmin/api/system), note, created_at`. One row per transition. Powers the timeline UI + the dashboard.

### 3.3 `idcard_windows` — request windows
`id, title, requester_scope(ENUM STUDENT/STAFF/BOTH), opens_at, closes_at, is_active, notes, created_by, created_at`. Requests are only accepted when `NOW()` is inside an active window matching the requester type (Task 6).

### 3.4 Staff photo (new)
Add `hrm_employee.photo_file VARCHAR(255) NULL` (+ optional `photo_updated_at`). Self-heal on controller load. Feeds the staff wizard's photo step.

---

## 4. Status lifecycle (state machine)

```
                 (student only)
REQUESTED ──▶ FINANCE_CHECK ──▶ SUBMITTED ──▶ APPROVED ──▶ PRINTED ──▶ READY ──▶ COLLECTED
    │              │  (fail)         │  (XAXU)   │            │(XAXU)     │(admin)   │
    │              ▼                 ▼           ▼                                   │(terminal)
    └────────▶  BLOCKED         (stays)      HALTED ──▶ (back to SUBMITTED on fix)   │
   CANCELLED (by requester while still REQUESTED/BLOCKED) ◀───────────────────────────
```

| Status | Meaning | Set by | Next |
|---|---|---|---|
| `REQUESTED` | Wizard started, Step 1 complete | eportal | FINANCE_CHECK / (staff → SUBMITTED) |
| `FINANCE_CHECK` | Running/failed the 10% gate | system | SUBMITTED (pass) / BLOCKED (fail) |
| `BLOCKED` | Dues/underpayment; cannot proceed | system | FINANCE_CHECK (on re-check) / CANCELLED |
| `SUBMITTED` | Submitted to XAXU for approval | eportal | APPROVED / HALTED |
| `APPROVED` | XAXU approved; queued to print | eadmin/api (XAXU) | PRINTED |
| `HALTED` | XAXU rejected/halted (reason required) | eadmin/api (XAXU) | SUBMITTED (requester resubmits after fixing) / CANCELLED |
| `PRINTED` | Card physically printed | eadmin/api (XAXU) | READY |
| `READY` | Ready for collection (location/time shown) | eadmin | COLLECTED |
| `COLLECTED` | Handed over (terminal) | eadmin/api | — |
| `CANCELLED` | Withdrawn (terminal) | requester/admin | — |

Rules:
- Only the transitions in the table are legal; `IDCardService.Transition()` rejects anything else (Task 4.4).
- Every transition writes an `idcard_request_events` row **and** (where the table says a person is notified) sends an email.
- `PRINTED`/`READY`/`COLLECTED` may arrive from **eadmin OR the API** (XAXU) — both funnel through the same `Transition()`.

---

## 5. The wizard (eportal) — step by step

A strict, sequential wizard on eportal (`IDCardRequest.aspx`, portal chrome, mobile-first). Server re-validates every step; the client never advances on its own.

### Step 1 — Request ID (student or teacher)
- [ ] Gate: an **open window** exists for this requester type, and the person has **no active request** (else show the existing request's status tracker instead of the wizard).
- [ ] Show the requester's identity **read-only** (name, number, programme/department, etc.) with clear **"Update my details"** links to the existing profile screens.
- [ ] **Photo confirmation:** display the current professional photo (`acad_student.photofile` / new `hrm_employee.photo_file`). Student confirms it is correct, or opens the **photo upload interface** (Section 7). Must tick **"I have read and understood the photo requirements"** (`guidelines_ack`).
- [ ] Choose `card_type`: **New** or **Replacement** (+ any extra info).
- [ ] Cannot continue until: identity acknowledged, photo confirmed, guidelines acknowledged, card type chosen.

### Step 2 — Finance check (automatic)
- [ ] **Students only.** Auto-run the **10% rule**: total paid toward the current semester ≥ 10% of that semester's fee (`fin_GetProgrammeFee` for the fee; payments from `fin_studentfeestracking`/canonical balance). Store `finance_snapshot_json`.
  - Pass → `finance_ok=1`, proceed.
  - Fail → `BLOCKED`, show exactly how much is needed; cannot proceed until cleared (re-check button).
- [ ] **Teachers skip this** entirely (`finance_ok` = N/A).
- [ ] **Replacement fee (replacement cards):** require proof of the **UGX 30,000** paid to Xazu Technologies Limited —
  - DFCU Bank a/c **01410015331595** (Xazu Technologies Limited), or Airtel Money **0759952103** (Sandra Atuheire Mutabaazi).
  - Capture `replacement_fee_ref`, `replacement_fee_date`, `replacement_fee_method`, `replacement_fee_notes`. Validate presence/format; this is **out-of-band** (never posted to `fin_ledger`).
- [ ] **Summary screen:** identity + photo + card type + finance result + (replacement) payment proof. Explicit **Submit** action.
- [ ] On submit → `SUBMITTED`; show the **Request ID**, current status, and next steps.

### Steps 3–6 are status views for the requester (driven by XAXU/admin actions)
- [ ] **Approve/Halt (Step 3):** requester sees `SUBMITTED → APPROVED` or `HALTED (+reason)`; email on each. On halt, allow fix + resubmit.
- [ ] **Printed (Step 4):** status `PRINTED`; email.
- [ ] **Ready for collection (Step 5):** status `READY` with **collection location + timings**; email; instruction to bring **Request ID + a valid ID document**.
- [ ] **Collected (Step 6):** status `COLLECTED`; email; request closes.

---

## 6. Request windows

- [ ] Admin CRUD for `idcard_windows` (title, scope, open/close datetimes, active).
- [ ] eportal **refuses new requests** outside an active, in-range window for that requester type — with a friendly message showing the next window.
- [ ] Windows are surfaced to students/teachers in advance (portal banner + the block message).
- [ ] The gate is enforced **server-side** in `IDCardService.CanRequest()` (never client-only).

---

## 7. Photo handling & guidelines

- [ ] Reusable **photo upload/crop interface** (portal): preview, replace, square crop, size/format limits.
- [ ] **Guidelines panel** shown before upload: plain background, face centered, no hats/filters, min resolution, max file size, accepted formats. Require the read-and-understood tick.
- [ ] On confirm, snapshot the file reference into `idcard_requests.photo_ref` so the card is printed from exactly what was approved (later profile edits don't silently change an in-flight request).
- [ ] Student photo persists to `acad_student.photofile`; staff photo to new `hrm_employee.photo_file`.
- [ ] Decide storage location + naming (Task 0.2) consistent with how `photofile` is served today.

---

## 8. Finance gating (detail)

### 8.1 The 10% eligibility rule (students)
- Semester fee = `fin_GetProgrammeFee(progid, studyyear, semester)` (tuition + functional) for the student's **current** registration.
- Paid-this-semester = payments recorded for that `acad_year`+`semester` (from `fin_studentfeestracking` / canonical balance), consistent with `FeesManagement`/`BillingHealth`.
- Eligible iff `paid ≥ 0.10 × semester_fee`. Persist the three numbers + verdict in `finance_snapshot_json`.
- Edge cases to specify: zero/undefined fee structure (e.g., finalists with no fee row — see billing work) → **do not hard-block**; flag for admin review.

### 8.2 Replacement fee (out-of-band)
- Not a university charge → **no GL entry**. Stored only as proof metadata on the request.
- XAXU reconciles the UGX 30,000 against their own account; eadmin shows the reference for their verification during approval.

---

## 9. eadmin — the XAXU/admin controller

- [ ] **`IDCardController.aspx`** (SidebarMaster, design system) — the single operations console:
  - Queue/list with filters (status, requester type, card type, window, date, programme/faculty, search by number/name).
  - Row → **request detail**: identity, photo, timeline (`idcard_request_events`), finance snapshot, replacement-payment proof.
  - Actions (role-gated for XAXU/registry): **Approve**, **Halt (reason required)**, mark **Printed**, mark **Ready** (set location/time), mark **Collected**.
  - Bulk actions where safe (e.g., approve many).
- [ ] **Admin dashboard** (can extend `IDCardStatus.aspx` or a new tab): counts by status (Requested/Blocked/Submitted/Approved/Halted/Printed/Ready/Collected), throughput over time, per-window and per-faculty breakdowns, filter/sort, and inline approve/halt.
- [ ] **Window management** UI (Section 6).
- [ ] All actions go through `IDCardService.Transition()` → audit + email.

---

## 10. API (for XAXU integration)

All under `API/v2/idcard.aspx` (+ `idcard.aspx.cs`), Bearer auth via `TokenManager.RequireAuth`, JSON in/out matching existing v2 endpoints, **rate-limited** and **logged**.

| Method | Endpoint | Purpose |
|---|---|---|
| GET | `/api/v2/idcard/requests?status=&type=&since=` | XAXU pulls the approval/print queue |
| GET | `/api/v2/idcard/requests/{request_no}` | One request (identity + photo URL + payment proof) |
| POST | `/api/v2/idcard/requests/{request_no}/approve` | XAXU approves |
| POST | `/api/v2/idcard/requests/{request_no}/halt` | XAXU halts (reason) |
| POST | `/api/v2/idcard/requests/{request_no}/printed` | Mark printed |
| POST | `/api/v2/idcard/requests/{request_no}/ready` | Mark ready (location/time) |
| POST | `/api/v2/idcard/requests/{request_no}/collected` | Mark collected |
| GET | `/api/v2/idcard/photo/{request_no}` | Secured photo fetch for printing |
| GET | `/api/v2/idcard/windows` | Current/next windows |

- [ ] Every write endpoint funnels into the same `IDCardService.Transition()` used by eadmin — one code path, one audit trail (idempotent: repeat calls are no-ops with a clear response).
- [ ] Enhance `OmniPassHelper` so the legacy `student-cards` pull continues to **reconcile** OmniPass `PRINTED` into the new lifecycle (a printed-in-OmniPass card advances a `SUBMITTED/APPROVED` request to `PRINTED`), with error handling + logging.
- [ ] API keys/tokens for XAXU issued and scoped via `TokenManager`; document rate limits.

---

## 11. Notifications (email)

- [ ] One helper `IDCardMailer` wrapping `EmailSenderProtocol.SendHtmlEmail` with branded MRU templates (never "Mbarara"; sender = MRU).
- [ ] Triggers: SUBMITTED (received), APPROVED, HALTED (with reason), PRINTED, READY (with collection details), COLLECTED.
- [ ] Recipient = student email (`acad_student.email`) / staff email (`hrm_employee.emp_email`); log send success/failure on the event row.

---

## 12. Implementation phases (build in this order)

- [ ] **Phase 0 — Foundations & decisions.** Sign off this doc; decide photo storage/DB (0.2); create `idcard_requests`, `idcard_request_events`, `idcard_windows`; add `hrm_employee.photo_file`; build `IDCardService` (state machine + `Transition()` + `request_no` generator + one-active-request guard).
- [ ] **Phase 1 — eadmin controller.** `IDCardController.aspx` list + detail + all status actions + audit + email. (Lets ops work even before self-service exists.)
- [ ] **Phase 2 — Request windows.** `idcard_windows` CRUD + server-side gate.
- [ ] **Phase 3 — eportal wizard.** Steps 1–2 (identity, photo confirm, guidelines, card type, finance gate, replacement proof, summary, submit) + Steps 3–6 status tracker.
- [ ] **Phase 4 — Photo module.** Upload/crop UI + guidelines + snapshot into request; staff photo capture.
- [ ] **Phase 5 — Finance gate hardening.** 10% rule with the fee-structure edge cases; replacement-fee proof validation.
- [ ] **Phase 6 — Admin dashboard.** Status/throughput analytics + inline actions.
- [ ] **Phase 7 — API.** All `/api/v2/idcard/*` endpoints, auth, rate limiting, logging.
- [ ] **Phase 8 — XAXU integration.** Wire OmniPass reconcile into the lifecycle; issue XAXU tokens; end-to-end test with XAXU; real-time updates + error handling/logging.
- [ ] **Phase 9 — Documentation & handover.** API docs (extend `API/v2/API_DOCUMENTATION.md`), admin/user guides, this doc kept current.

---

## 13. Cross-cutting requirements

- **Security:** server-side validation on every step and transition; role gates in eadmin (XAXU/registry vs read-only); Bearer + rate-limited API; no client-trusted state; audit every change.
- **Reliability:** idempotent transitions; email/API failures logged and retryable; the wizard tolerant of refresh/back.
- **UX:** eportal mobile-first (`PortalMaster.master`), eadmin desktop-first (`SidebarMaster.master` + design system); consistent status chips and timeline across both.
- **Integrity:** one active request per person; in-flight requests immune to later profile/photo edits (via `photo_ref` snapshot); windows enforced server-side.

---

## 14a. DECISIONS FINALIZED (2026-07-15) — build to these

1. **Photo storage** — reuse the existing photo mechanism: student = `acad_student.photofile`, staff = new `hrm_employee.photo_file`. `idcard_requests.photo_ref` snapshots the filename in use at request time. Uploads write a file and store the filename, served like existing photos.
2. **Staff finance** — teachers are fully exempt from the finance gate.
3. **10% base** — 10% of the **current semester** fee = `fin_GetProgrammeFee(progid, studyyear, semester)` (tuition + functional) for the student's latest REGISTERED registration. Paid-this-semester = sum of Payment rows for that `acad_year`+`semester`. If the fee is 0/undefined (e.g., finalists with no fee row) → treated as eligible and flagged for admin review, not hard-blocked.
4. **Windows** — enforced server-side. Bootstrap rule: if **no** windows exist at all, requests are open; once any window exists, a request must fall inside an active, in-range window for its requester type.
5. **Halt → resubmit** — the **same** `request_no` is reused (HALTED → SUBMITTED).
6. **XAXU role in eadmin** — approve / halt / printed / ready / collected are gated to authenticated eadmin admins (system-wide RBAC is not enforced yet; session-authenticated admin = allowed). A dedicated XAXU role can be layered on later without changing the funnel.
7. **Collection point** — the admin enters the collection location/time when marking a card **Ready**; stored on the request (`collection_point`).
8. **OmniPass mapping** — the enhanced sync advances a `SUBMITTED`/`APPROVED` request to `PRINTED` when OmniPass reports the card printed.

## 14. Open decisions (superseded by 14a — kept for context)

1. **Photo storage/DB** — reuse the `photofile` storage/serving path, or a new secured store? Portal DB vs main DB for photo writes.
2. **Staff finance** — confirmed: teachers are exempt from the finance gate. Any staff-side eligibility rule at all?
3. **10% base** — 10% of the **current semester** fee specifically (confirm vs full-year or programme fee).
4. **Replacement re-print of the same card_type** — does an approved replacement need a fresh window, or is it always open?
5. **Halt → resubmit** — same `request_no` reused (recommended) vs a new request.
6. **Who plays "XAXU" in eadmin** — a dedicated role/account, and which existing role maps to it.
7. **Collection points & hours** — fixed config or per-window.
8. **OmniPass status mapping** — exact reconciliation rules between OmniPass `PRINTED/NOT_PRINTED` and the new lifecycle.

---

### Appendix A — verified references
- XAXU/OmniPass: `App_Code/OmniPassHelper.cs` (`omnipass.mru.ac.ug/api/external/student-cards/{mru}`; statuses PRINTED/NOT_PRINTED/NOT_FOUND).
- Status cache: `acad_student.id_card_status`, `id_card_checked_at`; screen `COOPERP/NewScreens/IDCardStatus.aspx`.
- Email: `EmailSenderProtocol.SendHtmlEmail(message, recipients, subject, sender)`.
- API auth: `TokenManager.RequireAuth(Request, Response)`; base `API/v2/*`.
- Photo: `acad_student.photofile` (student); **no** staff photo field yet.
- Finance: `fin_GetProgrammeFee`, `fin_GetCanonicalStudentBalance`, `fin_studentfeestracking`.
- Print artwork: `App_Code/XtraReports/StudentDocs/IDCard.cs`.
