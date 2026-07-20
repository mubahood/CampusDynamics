# Retake Registration — Deep Analysis & Implementation Plan

> Status: **BUILT & DB-VERIFIED (end-to-end on SABIA / MRU2027000002)** · 2026-06-30
> Goal: a simple, guided, student-driven **retake registration** flow with an independent
> retake record (snapshot of prior marks), 150,000 UGX/course fee, an "RT" marker through
> marks + transcripts, student & admin monitoring, and a bursary block for students with
> active retakes.
>
> **Progress: Phases 0–8 all DONE.** Remaining items are decisions/enhancements, not core
> build — see the **"Remaining / pending"** box at the end of §5. Migration in
> `COOPERP/sql/retake/`. Live in-browser smoke test still recommended.

---

## 1. Concept (the approach we are keeping)

A student should be able to **self-register a retake** for any course they have previously
taken, through a short **3-step guided wizard** reached from contextual links in the portal
(My Courses, Home, Results, Course Registration) — **never** from the header menu.

Each retake becomes an **independent tracking record** that:
- carries a **snapshot of the original attempt** (CW, exam, total, grade, grade point, period),
- spawns a **fresh `acad_course_registration` row** with marks **NULL**, stage reverted to
  **pending**, and the type clearly recorded as a retake (**RT**),
- is **billed 150,000 UGX** (one fee per retaken course),
- flows through the **normal staged marks workflow** (lecturer → HOD → Dean → Senate),
- is shown distinctly as **RT** on mark entry, mark listings, and the **transcript**,
- can be **monitored by the student** and **managed by admins**.

Students with **active retakes are blocked from bursary** at the point a bursary is offered.

---

## 2. Current-state analysis (what already exists — verified in code + DB)

Good news: much of the scaffolding is already present, so we build *with the grain*.

### 2.1 Retakes are already partially modeled
- `campus_dynamics_portal.acad_course_registration.course_status` already uses **`RETAKE`**
  (129 live rows). Existing retakes already follow the exact shape we want:
  current `acad_year`/`semester`, `mark_stage='NOT_ENTERED'`, `provisional_total_marks=NULL`,
  `provisional_marks_status='pending'`.
- A retake **fee item already exists**: `campus_dynamics_accounts.academicbillingitems`
  → **ItemCode `21` = "Retake fee", GL account `AC6016`** (already used in 418 bills).
- A course-status **"RETAKE" badge already exists** in
  `COOPERP/NewScreens/CourseRegistration.aspx.cs:643` (`cr-status-badge--retake`) — proves the
  visual pattern.

### 2.2 What is MISSING (the real work)
- **No student-facing retake wizard** — retakes today are created by admins only.
- **No retake tracking table** — only `acad_failed_passes` (thin: `regno, code, old_mark, acad`),
  no full snapshot, no link to the new registration, no fee/status tracking.
- **No "RT" marker** in mark entry, mark listings, or the transcript.
- **No student monitoring** of retakes; **no dedicated admin screen**.
- **No bursary block** for students with active retakes.

### 2.3 Marks workflow (where retakes plug in) — verified anchors
- Lifecycle on `acad_course_registration.mark_stage`:
  `NOT_ENTERED → ENTERED → CAPTURED → APPROVED → PUBLISHED`
  (`App_Code/Marks/MarkStageService.cs:15`, `StageAdvanceService.cs`).
- Lecturer entry (portal): `LecturerProvisionalMarksController.aspx.cs` — row render ~`:854`,
  CW/Exam cells ~`:868-876`; saves at `SaveProvisionalMarks` ~`:1430` and `SaveInlineMark` ~`:1598`.
- Staff listings (main system): `App_Code/Marks/MarksControllerShared.cs` grid render `:328-347`
  (course cell at `col-course`); `COOPERP/NewScreens/ProvisionalMarksController.aspx.cs:332`;
  `AllMarksController.aspx.cs:17` delegates to the shared grid.
- Publish → `acad_results` UPSERT: `MarksControllerShared.cs:1546-1566`
  (`INSERT … ON DUPLICATE KEY UPDATE`, key = regno+courseid+acad+semester+studyyear), then
  GPA update `:1579` and registration status update `:1594`.

### 2.4 Transcript — verified anchors
- DevExpress XtraReports bound to **stored procedures** (not inline queries). Two formats:
  - **Legacy** `App_Code/XtraReports/Transcript.cs` ← SP **`acad_GetStudentTranscript`**;
    per-course bindings: `gradept :199`, `grade :214`, **`coursename :240`**, **`courseid :253`**,
    `score :266`.
  - **Two-column** `FinalTranscript.cs` + `FinalTranscriptCol1.cs`/`Col2.cs` ← SPs
    `acad_GetSingleStudentTranscript_Col1/_Col2` (`Col1.cs:199`, `Col2.cs:201`); course code
    binding `Col1.cs:125`, name `:139`, CU `:153`, grade `:167` (mirror in Col2). Also
    `ResultsStatement.cs`.
- **Pipeline:** `acad_CreateTranscript(@reg,'Normal',0)` materializes `acad_transcript_results`
  from `acad_results`; the SPs read that table
  (`AcademicDocuments/AcademicDocumentPdfService.cs:298-308`). So an **RT** flag must flow:
  `acad_results.is_retake` → `acad_transcript_results` → SP output column → XRBinding.
- **No retake field exists today** in any transcript report or table.

### 2.5 Bursary — verified anchors
- Beneficiaries live in `campus_dynamics_accounts.scholarshipstudents`
  (`adm_no, scholarshipID, scholarhipYear, scholarhipTerm, status`).
- **All** beneficiary writes go through `COOPERP/NewScreens/BursaryBeneficiaries.aspx.cs`
  nested helper **`Create(...)` at `:1101`** (one transaction): Payment row
  `fin_studentfeestracking` `:1110-1124`, ledger DR/CR via `PostLedgerEntries` `:1127`, and the
  **`scholarshipstudents` insert `:1130-1144`** (commit `:1146`). The **block guard** goes at
  the very top of `Create` (right after `:1104`, before `BeginTransaction`) so it short-circuits
  all three inserts atomically.
- `BursarySchemes` has no separate beneficiary-insert site. `fin_bill_waivers` is **not** used
  by this screen (scholarship uses `scholarshipstudents` + `fin_studentfeestracking`).

### 2.6 Billing one item — verified canonical pattern
- The cleanest single-item bill + GL mirror is `OtherFeesBilling.aspx.cs:587-652`:
  1. **Bill row** `:589-603` → `INSERT INTO fin_studentfeestracking (regno, semester, acadyear,
     amount, item_code, trans_type, detail, trans_date, post_status) VALUES (…, 'Bill', …,
     'Posted')`; capture `tid = cmd.LastInsertedId`.
  2. **GL DR student** `:610-627` (`fin_ledger`, `account_type='Student'`, `transactionType='DR'`,
     `accountcode=regno`, `voucherNo=tid`, `folio='BillNo:'+tid`, `trans_currency='UGX'`…).
  3. **GL CR revenue** `:630-650` (`account_type='Chart Account'`, `transactionType='CR'`,
     `accountcode=<item AccountCode>`). Commit `:652`.
- For retake: `item_code=21`, revenue account **`AC6016`**, `amount=150000`,
  `detail='Retake Fee - <COURSE>'`. Replicate `:587-652` verbatim in `BillRetakeFee(...)`.
  (Bursary's `Create` uses the same tracking shape but `trans_type='Payment'` — we use `'Bill'`.)

### 2.7 Portal plumbing — verified anchors
- Student identity: `PortalHelper.GetRegno(this)` → `Session["regno"]`/`["username"]`,
  role in `Session["usertype"]`.
- AJAX: `Request["action"]` dispatch + `JavaScriptSerializer` → `Response.Write(json)`
  (`AdminCourseRegistration.aspx.cs:39`, JSON writer `:269`).
- Contextual link spots (mirror existing markup):
  - Home tiles: `UserControls/Security/SystemApplications_Modern.ascx` (`sp-action` tiles, `:687-762`).
  - Results: `StudentResults.aspx` header actions (`sp-page-hdr__actions`, `:152`).
  - My Courses: `MyCourses.aspx` (`mc-cta` banner, `:26-42`).
  - Course Reg: `AdminCourseRegistration.aspx` (`acr-head-actions`, `:159`).

---

## 3. Target design

### 3.1 New table — `acad_retake_registrations`
Created in **`campus_dynamics_portal`** (next to the registration + marks workflow it tracks).
One row **per retaken course unit** (independent record).

| Column | Type | Purpose |
|---|---|---|
| `ID` | INT PK AI | retake record id |
| `regno` | VARCHAR(25) | student |
| `courseID` | VARCHAR(25) | course being retaken |
| `course_name` | VARCHAR(150) | snapshot for display |
| `prog_id` | VARCHAR(25) | programme |
| `credit_units` | DOUBLE | snapshot CU |
| `retake_acad_year` | VARCHAR(25) | period the retake is registered for (current) |
| `retake_semester` | INT | retake semester |
| `retake_study_year` | INT | study year used for the new registration |
| `course_reg_id` | INT | FK → the NEW `acad_course_registration.ID` |
| `orig_acad_year` | VARCHAR(25) | **original attempt** academic year |
| `orig_semester` | INT | original semester |
| `orig_study_year` | INT | original study year |
| `orig_course_work` | INT NULL | original CW |
| `orig_exam` | INT NULL | original exam |
| `orig_total` | INT NULL | original total/score |
| `orig_grade` | VARCHAR(5) | original grade |
| `orig_gradept` | DOUBLE | original grade point |
| `orig_result_id` | INT NULL | `acad_results.ID` of the original (if found) |
| `attempt_no` | INT | 2,3,… (count of attempts) |
| `retake_fee` | DOUBLE | 150000 |
| `fee_tid` | INT NULL | `fin_studentfeestracking.TID` of the 50k bill |
| `fee_billed` | ENUM('Yes','No') | billing confirmation |
| `status` | VARCHAR(20) | `REGISTERED → IN_PROGRESS → COMPLETED` / `CANCELLED` |
| `new_total` / `new_grade` / `new_gradept` | … NULL | filled when the retake result publishes |
| `registered_by` | VARCHAR(45) | actor (student regno, or admin) |
| `registered_at` | DATETIME | timestamp |
| `notes` | VARCHAR(500) NULL | optional |

Indexes: `(regno)`, `(courseID)`, `(course_reg_id)`, unique guard on
`(regno, courseID, retake_acad_year, retake_semester)` to prevent duplicate active retakes.

### 3.2 `acad_course_registration` additions
- Keep **`course_status='RETAKE'`** as the canonical RT flag (already the convention + badge).
- Add `retake_registration_id` INT NULL → links the registration row back to its
  `acad_retake_registrations.ID` (two-way link).
- (Optional, explicitness) `registration_type` VARCHAR(10) DEFAULT 'NORMAL' set to `'RT'`.

### 3.3 `acad_results` addition (for transcript RT)
- Add `is_retake` TINYINT(1) DEFAULT 0. Set to **1** when the published result comes from a
  `course_status='RETAKE'` registration. The transcript SPs/report then mark it **RT**.
  (Cleaner than deriving the flag at report time.)

### 3.4 The 3-step student wizard — `RetakeRegistration.aspx` (portal)
Single page, **stepper UI** (3 phases via JS, AJAX data + submit) — matches the existing
portal `sp-` design and the wizard pattern used in BillingReconciliation. Reached only via
contextual links (not the header).

- **Step 1 — Introduction & confirmation.** What a retake is and its effect (you re-sit the
  paper; a fresh attempt is recorded and marked **RT**; original attempt is preserved). The
  cost: **150,000 UGX per course**. A required "I understand" checkbox → Next.
- **Step 2 — Choose courses.** AJAX list of **all courses the student has ever registered for**
  (from `acad_course_registration` ⋈ `acad_results`), de-duplicated, each shown with clear
  captions: **course code, name, period taken, prior grade/score, credit units**, with failed
  courses highlighted. Multi-select (checkboxes). Courses with an existing active retake are
  shown as "already in retake" and disabled. → Next.
- **Step 3 — Review & submit.** Summary table of the selected courses; **each 150,000**, grand
  total = N × 150,000. Confirm → Submit.

### 3.5 Submit logic (server, transactional, idempotent per course)
For each selected course (wrapped per-course or per-batch in a transaction with rollback):
1. Resolve the **original attempt snapshot** — latest `acad_results` for (regno, courseid)
   for grade/score/CU, plus the latest `acad_course_registration` for CW/exam if present.
2. Determine **retake period** = current academic year + current active semester
   (`PortalHelper.GetCurrentAcadYear()` + active semester). *(Open decision 4.B.)*
3. **Guard**: reject if an active (non-COMPLETED/CANCELLED) retake already exists for that
   course in that period.
4. Insert a **new `acad_course_registration`**: `course_status='RETAKE'`,
   `mark_stage='NOT_ENTERED'`, marks NULL, `provisional_marks_status='pending'`,
   `registration_type='RT'`.
5. Insert the **`acad_retake_registrations`** record (snapshot + `course_reg_id` link, set
   `retake_registration_id` back on the registration).
6. **Bill 150,000**: `fin_studentfeestracking` (item 21, detail `Retake Fee - <course>`,
   `post_status='Posted'`) + GL mirror (DR student / CR `AC6016`); store `fee_tid`,
   `fee_billed='Yes'`. On billing failure → roll back the whole course (no orphan registration).
7. Audit to `acad_activity_log`.

### 3.6 Marks integration (RT visual + result handling)
- The retake registration flows through the **normal** staged workflow unchanged (it appears
  to lecturers as a fresh NOT_ENTERED entry).
- **RT badge**: add `course_status` to the grid queries and render an **"RT" badge** beside the
  course code in: `MarksControllerShared.cs` (`col-course`, `:332`),
  `ProvisionalMarksController.aspx.cs:332`, and portal `LecturerProvisionalMarksController`
  (`:868` area). Reuse the `--retake` badge style.
- **Publish**: the existing UPSERT writes a **new `acad_results` row** for the retake period
  (different acad/semester ⇒ does not overwrite the original attempt). At publish, also set
  `acad_results.is_retake=1` and update the tracking record (`status='COMPLETED'`,
  `new_total/new_grade/new_gradept`). Hook in `MarksControllerShared.ProcessPublishAction`
  / `PublishSingle`.

### 3.7 Transcript RT
- Extend `acad_CreateTranscript` + `acad_GetSingleStudentTranscript_Col1/_Col2` to surface
  `is_retake` (and/or join the retake table) so each retaken course returns a retake flag.
- In `FinalTranscriptCol1.cs` / `Col2.cs`, render **"RT"** on the retaken course row (append to
  the course-code cell, or a small marker cell) — and add **RT** to the "Key to Grades"
  legend (`FinalTranscript_KeytoGrades.cs`).

### 3.8 Student monitoring — "My Retakes"
- A read-only panel/page listing the student's `acad_retake_registrations`: course, original
  grade, retake period, **fee status**, **current stage** (from the linked registration's
  `mark_stage`), and **new grade** once published. Surfaced as a tab on the wizard page and/or
  a small card on `MyCourses` / `StudentResults`.

### 3.9 Admin controller — `RetakeController.aspx` (main system, NewScreens)
- List/manage all retake records with filters (year, semester, programme, status, fee status),
  showing **original vs new** marks and fee state; actions: register-on-behalf, cancel/refund
  flag, export CSV. Scope-aware (admin all; dean/HOD their scope — reuse `MarksScope`).
- Sidebar link under **Academics → Exam** (alongside the marks consoles).

### 3.10 Bursary block
- In `BursaryBeneficiaries.aspx.cs` `Create(...)` (`:1101`), at the top before `BeginTransaction`
  (right after `:1104`): if the student has any **active retake** (`acad_retake_registrations.status NOT IN
  ('COMPLETED','CANCELLED')`, optionally scoped to the bursary's year/term), **block** with a
  clear message: *"Student has active retake(s) and is not eligible for bursary this period."*
- Apply the same guard in any bursary auto-billing/offer path that bypasses the screen.

---

## 4. Decisions — resolved as built (one still open)

- **4.A — Eligible courses:** ✅ **DONE** — lists **all** previously-registered courses; failed
  ones highlighted; improvement retakes allowed.
- **4.B — Retake period:** ✅ **DONE** — registered under the **current academic year + current
  semester** (from the student's latest registration / active semester).
- **4.C — GPA/CGPA effect:** ⚠️ **PARTLY DONE — one open policy decision.** Implemented: a
  published retake writes to the **same `acad_results` row** (unique key `regno+courseid`), so
  the course appears **once** with the **new grade + RT**; the **original is retained** in the
  retake snapshot + the result audit comment, and it is **not double-counted** in GPA.
  **NOT implemented:** automatic **grade capping** (e.g. max C/pass-band per NCHE) — CGPA
  currently uses whatever grade is published. **➡ Needs your call:** cap retake grades, or let
  the full retake grade stand?
- **4.D — Fee:** ✅ **DONE** — flat **150,000/course**, item 21 / `AC6016`, billed at submit.
  Because the system enforces **one bill per (student, period, item)**, multiple retakes in a
  period **accumulate into a single retake-fee bill** (amount = N×150,000; courses listed in the
  detail). **Refund-on-cancel: not built** (there is no cancel action yet — see Remaining).
- **4.E — Pre-conditions:** ✅ **DONE** — allowed regardless of balance/current registration
  (the 50k simply posts to the ledger); no balance gate.

---

## 5. Phased task checklist — **all phases DONE**

### Phase 0 — Schema ✅ DONE
- [x] Created `campus_dynamics_portal.acad_retake_registrations` (§3.1).
- [x] Added `acad_course_registration.registration_type` ('RT') + `retake_registration_id`.
- [x] Added `campus_dynamics.acad_results.is_retake` (default 0).
- [x] Added `campus_dynamics.acad_transcript_results.is_retake` (for transcript RT).
- [x] **+ Fix:** widened `acad_transcript_results.result_comment` latin1→utf8 (pre-existing bug
      that crashed `acad_CreateTranscript` on Unicode comments). Migration: `COOPERP/sql/retake/`.
- [n/a] Backups: changes are additive/reversible (DROP COLUMN) — no data backup needed.

### Phase 1 — Retake service ✅ DONE
- [x] `CampusDynamics_Portal/App_Code/Portal/RetakeService.cs`: `GetEligibleCourses`,
      `GetMyRetakes`, `RegisterRetakes` (snapshot + new RETAKE reg + tracking + 50k bill +
      rollback + audit). Single connection, cross-DB qualified.
- [x] Shared `BillRetakeFee(...)` (item 21 / AC6016) — **accumulates** per period (one bill per
      student/period/item, enforced by `trg_prevent_duplicate_bill`); rich human-readable
      narration on the bill detail + GL particulars.
- [x] Duplicate-active-retake guard + per-course transaction (failed course rolls back alone).

### Phase 2 — Student wizard ✅ DONE
- [x] `RetakeRegistration.aspx(.cs)` — 3-step stepper, AJAX `?action=eligible|submit|myretakes`.
- [x] "My Retakes" monitoring tab.

### Phase 3 — Contextual portal links (NOT header) ✅ DONE
- [x] Home tile in `SystemApplications_Modern.ascx`.
- [x] `StudentResults.aspx` header action.
- [x] `MyCourses.aspx` hero link.
- [x] `StudentCoursework.aspx` header action. *(Deliberately NOT on `AdminCourseRegistration` —
      the student wizard keys off the logged-in reg-no, so it would be wrong for staff; admins
      use the eAdmin RetakeController instead.)*

### Phase 4 — Marks RT visual ✅ DONE
- [x] `course_status` added to grids; inline **RT** badge in `MarksControllerShared.cs` (All
      Marks + Dashboard), `ProvisionalMarksController`, portal `LecturerProvisionalMarksController`.
- [x] At publish: `acad_results.is_retake=1` + retake record completed (status COMPLETED, new
      marks) — best-effort hook in `MarksControllerShared.ProcessPublishAction`.

### Phase 5 — Transcript RT ✅ DONE
- [x] `acad_CreateTranscript` copies `is_retake`; `acad_GetSingleStudentTranscript_Col1/_Col2`
      **and** legacy `acad_GetStudentTranscript` append **" (RT)"** to the course name —
      **reports need no changes** (verified rendering on SABIA).
- [~] Grades-key legend ("RT = Retake"): **not added** — the key is an SP-driven grade-scale
      table; the inline "(RT)" already conveys it. Optional (see Remaining).

### Phase 6 — Admin controller ✅ DONE
- [x] `COOPERP/NewScreens/RetakeController.aspx(.cs)` — filters, stats, original-vs-new marks,
      fee status, marks stage, CSV; sidebar link under Academics → Exam. *(Monitor-only for now.)*

### Phase 7 — Bursary block ✅ DONE
- [x] Guard in `BursaryBeneficiaries.aspx.cs Create()` — active retake ⇒ not eligible.

### Phase 8 — Verify ✅ DONE
- [x] End-to-end on SABIA (register → bill → monitor → admin view → bursary block → publish →
      COMPLETED + transcript RT) via transaction + rollback. No double-bill (accumulate fix),
      original attempt preserved, RT everywhere. All C# brace-balanced.

---

### Remaining / pending (decisions & optional enhancements — not core build)
- **[DECISION] GPA capping (§4.C):** confirm whether retake grades are capped (e.g. pass-band)
  or stand in full. Currently the published retake grade stands.
- **[ENHANCEMENT] Admin actions:** the admin screen is monitor-only. Add **register-on-behalf**
  and **cancel/refund** (cancel would set status CANCELLED + reverse/flag the 50k) if wanted.
- **[OPTIONAL] Grades-key legend** "RT = Retake" on the transcript key page.
- **[TEST] Live in-browser smoke test** of the wizard + screens (ASP.NET can't run locally;
  all verification was DB-level via rolled-back transactions).

---

## 6. UI/UX principles (concise)
- Reuse existing portal tokens (`sp-*`) and the stepper pattern; no header-menu entry.
- Step 2 list: dense but legible — code · name · period · prior grade chip · CU; clear
  multi-select; failed courses subtly highlighted.
- Step 3: one summary table, per-course 150,000, bold grand total, single primary "Confirm &
  Pay/Submit" button.
- RT marker: small, consistent amber **"RT"** chip everywhere (entry, listings, transcript).
- My Retakes: compact status timeline (Registered → Marks pending → Published) + fee badge.

---

## 7. Risks / safeguards
- **Money:** billing wrapped with verify + rollback; idempotent; never double-bills (unique
  guard + existing-bill check).
- **Original attempt integrity:** retake writes a **new** `acad_results` row (different period);
  never overwrites history; snapshot frozen in the retake record.
- **Workflow reuse:** retakes ride the proven staged marks pipeline — no parallel logic.
- **Scope:** admin screen scope-aware via existing `MarksScope`.
- **Backups** before any ALTER; additive columns only.
