# Performance Appraisal A-to-Z Audit (Code + Process)

Date: 07-May-2026  
Scope: CampusDynamics (Admin) + CampusDynamics_Portal (Employee/Supervisor)

---

## 1) Scope Reviewed

### Admin (CampusDynamics)
- `COOPERP/NewScreens/AppraisalSessions.aspx.cs`
- `COOPERP/NewScreens/AppraisalDashboard.aspx.cs`
- `COOPERP/NewScreens/AppraisalReports.aspx.cs`
- `COOPERP/NewScreens/AppraisalView.aspx.cs`

### Portal (CampusDynamics_Portal)
- `MyAppraisals.aspx.cs`
- `SelfAppraisal.aspx` + `SelfAppraisal.aspx.cs`
- `SupervisorAppraisal.aspx` + `SupervisorAppraisal.aspx.cs`

### Existing design docs reviewed
- `APPRAISAL_SYSTEM_ARCHITECTURE.md`
- `APPRAISAL_SCORING_FORMULAS.md`
- `APPRAISAL_FORM_ACADEMIC_STAFF.md`
- `APPRAISAL_FORM_ADMIN_STAFF.md`

---

## 2) End-to-End Process (As Implemented)

1. HR creates session (`DRAFT`) in `AppraisalSessions`.
2. HR activates session (`ACTIVE`).
3. HR runs generate action (`ajax=generate_appraisals`) to create records in `appraisal_records`.
4. Employee opens `MyAppraisals` and works in `SelfAppraisal`.
5. Employee save/submit updates Section B/C/D/E and record status.
6. Supervisor opens `SupervisorAppraisal`, scores B/C, edits D, saves/completes/returns.
7. Completion computes `raw_score`, `max_possible`, `final_percentage`, `classification`.
8. HR/Admin monitors via `AppraisalDashboard`, `AppraisalReports`, `AppraisalView`.

---

## 3) Critical Loopholes / Risks Found

## A. Security & Access Control

### A1. No explicit authorization checks in Admin appraisal pages (Critical)
Admin pages handling session creation, generation, cancellation/reopen operations do not show explicit role/permission enforcement in page code.

Affected:
- `AppraisalSessions.aspx.cs`
- `AppraisalDashboard.aspx.cs`
- `AppraisalReports.aspx.cs`
- `AppraisalView.aspx.cs`

Risk:
- Unauthorized internal users could manage sessions or alter records if they can reach endpoints.

---

### A2. CSRF protection missing on AJAX mutations (Critical)
Portal pages use JSON POST (`save_draft`, `submit`, `complete`, `return_to_employee`) without anti-CSRF token checks.

Affected:
- `SelfAppraisal.aspx` + `.cs`
- `SupervisorAppraisal.aspx` + `.cs`
- Admin AJAX mutators in `AppraisalView.aspx.cs`, `AppraisalSessions.aspx.cs`

Risk:
- Cross-site request forgery can submit/return/complete records using a logged-in staff browser.

---

### A3. Status/session enforcement bypass in AJAX paths (High)
AJAX routing in portal pages runs before full `LoadRecord()` checks. Ownership is checked, but session activity constraints are not fully enforced in AJAX path.

Affected:
- `SelfAppraisal.aspx.cs` (`VerifyRecordOwnership()` checks employee+status only)
- `SupervisorAppraisal.aspx.cs` (`VerifyReviewerAccess()` checks reviewer+status only)

Risk:
- Crafted requests may change records when UI would be view-only (e.g., after session closure), depending on record status.

---

## B. Data Integrity & Scoring Logic

### B1. Employee can influence denominator via `is_na` in Section C (Critical)
Employee self form updates `appraisal_section_c.is_na` and comments. Supervisor page treats `is_na=1` as non-rateable; denominator excludes N/A.

Affected:
- Employee write in `SelfAppraisal.aspx.cs` (Section C update)
- Scoring in `SupervisorAppraisal.aspx.cs` (`section_c_total` and `max_possible` logic)

Risk:
- Employee can mark many competencies N/A before supervisor review and artificially inflate final percentage.

---

### B2. Section B denominator based only on rated rows (High)
`max_possible` for Section B is computed as `COUNT(supervisor_rating IS NOT NULL) * 5`, not by expected applicable rows.

Affected:
- `SupervisorAppraisal.aspx.cs` in `RecalculateTotals()`

Risk:
- Supervisor can rate very few Section B rows and still get high final percentage due to small denominator.

---

### B3. Validation threshold too weak for Section C completion (High)
Completion allows only 50% of applicable competencies to be rated.

Affected:
- `SupervisorAppraisal.aspx.cs` (`HandleComplete`)

Risk:
- Final scores can be produced with incomplete competency assessment.

---

### B4. No server-side rating bounds validation (Medium)
Server accepts rating values from client and only checks >0 before storing; no strict 1..5 validation in save handlers.

Affected:
- `SelfAppraisal.aspx.cs` and `SupervisorAppraisal.aspx.cs`

Risk:
- Out-of-range values may enter DB via tampered requests.

---

### B5. Non-transactional multi-step saves (Medium)
Section saves delete/reinsert and recompute totals without DB transaction wrappers.

Affected:
- `SelfAppraisal.aspx.cs` (`SaveSections`)
- `SupervisorAppraisal.aspx.cs` (`SaveSupervisorData`, `RecalculateTotals`)

Risk:
- Partial writes on failure, inconsistent sections/totals.

---

## C. Process / Design Mismatches

### C1. Documented Section B slot counts do not match implementation (High)
Scoring docs state 8 slots (Academic/Admin) and 5 (Support), but code initializes 5 slots for all staff categories.

Affected:
- `SelfAppraisal.aspx.cs` (`InitializeSections` loop for Section B)
- `APPRAISAL_SCORING_FORMULAS.md`

Risk:
- Policy non-compliance and unreliable cross-category comparability.

---

### C2. Section E question count mismatch (Medium)
Code seeds 5 questions; docs describe 6 questions.

Affected:
- `SelfAppraisal.aspx.cs` (`SectionEQuestions`)
- `APPRAISAL_SYSTEM_ARCHITECTURE.md`, scoring docs

Risk:
- Form/report inconsistency and governance confusion.

---

### C3. Classification bands mismatch across artifacts (Medium)
Code uses: >=90 Outstanding, >=75 Very Good, >=60 Good, >=50 Fair, else Poor. Docs include variant with Fair at 40–59 in one section.

Affected:
- `SupervisorAppraisal.aspx.cs`
- `APPRAISAL_SCORING_FORMULAS.md`

Risk:
- Appeals/disputes due to inconsistent policy interpretation.

---

### C4. Competency template for Support marked as placeholder (Medium)
Code comments indicate support criteria is a placeholder to be refined.

Affected:
- `AppraisalSessions.aspx.cs` template seed block

Risk:
- Incomplete rubric quality, weak defensibility of outcomes.

---

## D. Session/Generation Control Risks

### D1. No uniqueness guarantee for (session_id, employee_id) (High)
`appraisal_records` lacks a unique key for per-employee-per-session record.

Affected:
- Schema creation in `AppraisalSessions.aspx.cs`

Risk:
- Duplicate appraisals can occur via reruns/races/manual inserts.

---

### D2. Generate operation race window and no transaction (Medium)
Generation checks count then inserts in loop; no transaction/locking.

Affected:
- `AjaxGenerateAppraisals()` in `AppraisalSessions.aspx.cs`

Risk:
- Concurrent requests can bypass “already generated” check.

---

### D3. Multiple ACTIVE sessions not prevented (Medium)
Activation updates selected DRAFT to ACTIVE without ensuring only one active session.

Affected:
- `btnActivateSession_Click` in `AppraisalSessions.aspx.cs`

Risk:
- Conflicting employee queues and reporting ambiguity.

---

### D4. Weak date/business validations on sessions (Medium)
No strict checks for period order, deadline within period, or overlap constraints.

Affected:
- Session create/edit handlers in `AppraisalSessions.aspx.cs`

Risk:
- Invalid sessions and deadline logic failures.

---

## E. Auditability & Reliability

### E1. No immutable audit trail table for key transitions (High)
Status changes, score edits, return/cancel/reopen actions are not recorded in dedicated append-only history.

Risk:
- Difficult forensic tracing and weak compliance evidence.

---

### E2. Dynamic `ALTER TABLE` in runtime user flows (Medium)
`EnsureReturnColumn()` and schema checks alter DB during normal requests.

Risk:
- Runtime lock/contention and non-deterministic behavior across environments.

---

### E3. Supervisor Section C comment input not persisted (Low/Medium)
UI captures a supervisor comment per competency, but save handler for Section C stores rating only.

Affected:
- `SupervisorAppraisal.aspx` (input exists)
- `SupervisorAppraisal.aspx.cs` (`SaveSupervisorData` ignores comment)

Risk:
- Data loss / reviewer frustration / incomplete records.

---

## 4) Priority Fix Plan

## P0 (Immediate — block exploitation)
1. Add role-based authorization checks for all admin appraisal pages and AJAX actions.
2. Add anti-CSRF token validation for all mutating endpoints.
3. Disallow employee update of Section C `is_na`; make N/A supervisor/admin-controlled only.
4. Enforce strict server-side status/session gates in AJAX paths.

## P1 (Scoring integrity)
1. Redefine denominator logic to policy-approved rule:
   - Either fixed-by-template expected counts,
   - Or applicable-count excluding approved N/A only.
2. Require minimum completion threshold policy (recommended >=100% of mandatory criteria, or explicit configurable threshold).
3. Enforce rating bounds `1..5` server-side.

## P2 (Data model hardening)
1. Add unique key on `(session_id, employee_id)` in `appraisal_records`.
2. Wrap generate and save workflows in transactions.
3. Prevent >1 active session (or make policy explicit and coded).
4. Add server-side session date and overlap validations.

## P3 (Governance + docs alignment)
1. Align docs and implementation on slot counts (Section B), question counts (Section E), classification bands.
2. Finalize support competency model (remove placeholder state).
3. Add immutable audit log table for critical actions.

---

## 5) Recommended Technical Controls (Concrete)

- Add `UNIQUE KEY uq_appraisal_record (session_id, employee_id)`.
- Add history table:
  - `appraisal_record_audit(audit_id, record_id, actor_empid, action, old_status, new_status, payload_json, created_at)`.
- Add optimistic concurrency/version column on `appraisal_records`.
- Add stored procedure or service-level method for score recompute from canonical rules.
- Add “policy snapshot” fields per record (`formula_version`, `threshold_version`) to avoid retroactive disputes.

---

## 6) Test Checklist (Post-fix)

1. Employee cannot mutate Section C N/A flags.
2. Employee cannot save/submit when session not active.
3. Supervisor cannot complete with insufficient mandatory ratings (per policy).
4. CSRF attempts fail on all mutation endpoints.
5. Duplicate generation for same session+employee is blocked at DB level.
6. Two simultaneous generation requests produce no duplicates.
7. Admin actions (return/cancel/reopen) are permission-gated and audited.
8. Score recompute is deterministic and matches published formula docs.

---

## 7) Executive Summary

The appraisal module is functionally complete and usable, but it has high-impact integrity and control gaps that can materially distort appraisal outcomes or allow unauthorized state changes. The most urgent loopholes are:
- employee control of Section C N/A,
- weak denominator construction for Section B,
- missing CSRF controls,
- and missing explicit admin authorization checks.

Addressing P0/P1 items will significantly improve fairness, defensibility, and compliance of appraisal results.
