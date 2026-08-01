# Course Registration — Lecturer Approval Status (PENDING / APPROVED / REMOVED)

**Date:** 2026-07-18. Table: `campus_dynamics_portal.acad_course_registration` (130,401 rows).

## Locked decisions (from the requester)
1. **Backfill:** `acad_year >= '2026/2027'` → **APPROVED** (4,956 + 20 future); everything older → **REMOVED** (125,445, treated as completed). New registrations default to **PENDING**.
2. **Gate scope:** **ODEL online-course participation ONLY.** Official registration, marks entry, billing, transcripts, counts are NOT gated by this status.
3. **Who can change:** **Lecturers AND admins.** Students & everyone else: view-only.
4. **Notifications:** **In-app only** (status shown to the student; no email).

## Data model
New columns on `acad_course_registration` (self-heal + one-time migration `sql/course_reg_lecturer_status.sql`):
- `lecturer_status VARCHAR(10) NOT NULL DEFAULT 'PENDING'` — one of PENDING / APPROVED / REMOVED.
- `lecturer_status_by VARCHAR(150) NULL`, `lecturer_status_at DATETIME NULL` — audit.
- Index `idx_lecturer_status (lecturer_status)`.

**Why DEFAULT works with zero insert-code changes:** the stored proc `campus_dynamics.acad_CourseRegister` and every direct `INSERT` use an *explicit column list* that omits `lecturer_status`, so every new row gets the DEFAULT `PENDING` automatically. No proc edit, no insert-code edit.

## Gating — add `lecturer_status='APPROVED'` to these ODEL reads ONLY
(campus_dynamics_portal `App_Code/Odel/`)
- `OdelService.cs` — `IsEnrolled` (#1 gate), `StudentHome`, `RosterCount`, `TeachingSpacesLite` roster sub-select, `EnrolledCount`, `AssignmentStudents`, `TeachingRoster`, `EnsureMySpaces`.
- `OdelCore.cs` — `ProvisionTerm`.
- `OdelPushService.cs` — `BuildRows` (coursework-push recipients).
- `OdelNotify.cs` — `AssignmentPublished` (email recipients).
- eadmin `NewScreens/OdelDashboard.aspx.cs` — roster count.
After backfill there are no NULLs, so `cr.lecturer_status='APPROVED'` is used uniformly (kept identical across all reads so IsEnrolled / rosters / notify never disagree). **No marks/billing/registration query is touched.**

## Status control (lecturers + admins)
- **eportal `AdminCourseRegistration.aspx`** (lecturer screen): status column + sections Active/Pending/Removed + batch Approve/Remove/Set-Pending, scoped to the lecturer's assigned courses; every change logged. New AJAX action `set_status`.
- **eadmin `NewScreens/CourseRegistration.aspx`** (admin): view + change status (admins can change any).
- Backend guard: only PENDING/APPROVED/REMOVED accepted; lecturer changes limited to their taught courses; admin changes unrestricted; `lecturer_status_by`/`_at` stamped + activity log.

## Student visibility (in-app notification)
Student sees their per-course status (Active / Pending approval / Removed) with the change date on their courses view — this IS the in-app notification (no email).

## Status (2026-07-18)
- [x] **migration + backfill** — `sql/course_reg_lecturer_status.sql` applied. APPROVED=4,976 (>=2026/2027), REMOVED=125,425 (past). New regs default PENDING (verified). One-time gated backfill.
- [x] **self-heal** — `OdelCore.EnsureRegStatusColumns` (adds cols + one-time backfill only on fresh column add) called at ODEL landing points.
- [x] **ODEL gating** — `lecturer_status='APPROVED'` added to all 12 participation reads (IsEnrolled, StudentHome, RosterCount, TeachingSpacesLite, EnrolledCount, AssignmentStudents, TeachingRoster, EnsureMySpaces, ProvisionTerm, BuildRows, AssignmentPublished, OdelDashboard). **Verified end-to-end:** removing a student drops them from ODEL spaces + roster; restoring returns them.
- [x] **backend** — `AdminCourseRegistrationController.SetRegistrationStatus` (batch, lecturer-scoped / admin-unscoped, stamped + logged) + `GetRegistrationRows` (per-reg list) + `GetSummary` fixed to count lecturer_status. Compiles clean.
- [x] **lecturer UI (eportal)** — `AdminCourseRegistration.aspx`: "Registration Approval Status" console with section chips (All/Pending/Approved/Removed), search, per-registration rows with status badges + checkboxes, batch Approve/Set-Pending/Remove, pagination. AJAX `set_status` (scoped) + `status_rows`.
- [x] **student in-app visibility** — `MyCourses.aspx` shows an Active / Pending approval / Removed badge per course.
- [ ] **admin console (eadmin `NewScreens/CourseRegistration.aspx`)** — REMAINING. Backend is ready: call `SetRegistrationStatus(ids, status, null /*admin=all*/, adminUser)` from an eadmin AJAX endpoint (eadmin connects to portal via vacConnectionString cross-db). Same console pattern as eportal but unscoped. This is the only piece left to let admins also change status.

## Deploy (required order)
1. Run `sql/course_reg_lecturer_status.sql` on production `campus_dynamics_portal` (adds columns + one-time backfill) **before** deploying the code (self-heal is a backstop, but run the SQL first).
2. Deploy: portal `App_Code/Odel/{OdelService,OdelCore,OdelPushService,OdelNotify}.cs`, `App_Code/Portal/AdminCourseRegistrationController.cs`, `AdminCourseRegistration.aspx(.cs)`, `MyCourses.aspx.cs`, `OdelApi.ashx`; eadmin `NewScreens/OdelDashboard.aspx.cs`.
