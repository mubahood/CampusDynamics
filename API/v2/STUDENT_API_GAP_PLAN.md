# Student API — gap analysis and build plan

**Scope:** the student-facing surface of `API/v2` (eadmin), judged against what a student can
actually do in the portal (`CampusDynamics_Portal`). Written 23 Aug 2026.

**Why now:** the API is what a mobile app or any third party has to build on. Anything a student
can do on the web but not through the API is a feature the app cannot have. This document finds
every one of those, specifies it, and records what has been built and what has not.

---

## 1. How the gaps were found

Not by reading the docs page — by comparing three things against each other:

1. **Every action the API dispatches.** Extracted from the `switch` in each of the 15 modules:
   `academic 23 · admissions 14 · apply 25 · appraisal 12 · auth 5 · campus 11 · finance 26 ·
   idcard 28 · knowledgebase 8 · odel 27 · residence 5 · staff 47 · student 22 · support 9 ·
   timetable 2` — **264 actions**.
2. **Every page a student can open** in the portal — 101 `.aspx` files, of which ~35 are
   student-facing.
3. **The tables behind each portal feature, with live row counts**, so a "gap" means real data a
   student is producing today that the API cannot see.

Authentication was audited separately by resolving each handler's call graph, because several
modules authenticate through a shared helper (`GetStudentRegNo`) or once in `Page_Load`
(`idcard`) rather than inline. **No student-data endpoint was found unauthenticated.** The
genuinely public actions are all deliberate: `auth.*`, the `apply.*` applicant flows,
`campus` reference data (years, faculties, programmes, calendar), `odel.ping`,
`support.issue_types`, `academic.grading_scheme`, `admissions.application_status`.

---

## 2. What the student API covers well today

| Area | Actions | Verdict |
|---|---|---|
| Results, transcript, GPA, standing | `academic.results/transcript/gpa/academic_standing/student_academic_summary` | Good |
| Course registration | `academic.available_courses/registered_courses/register_course/drop_course` | Good |
| Semester registration + deletion requests | `academic.semester_registration/semester_status/registration_history/semester_deletion_*` | Good |
| Finance | `finance.balance/ledger/payment_history/fee_status/billing_*/fees_structure/access_status/waivers` | Good |
| Timetable | `timetable.lectures/exams` | Thin but present |
| ID card | `idcard.my/create/submit/cancel_own/detail/finance/identity/meta/windows` | Good |
| E-learning | `odel.my_learning/space/assignment/dashboard/lectures/updates/attendance/submit_*/self_checkin` | Good |
| Notices | `campus.notices/notice_detail/mark_read` | Good |
| Support tickets | `support.create/list/detail/reply/close/attachment` | Good |
| Knowledge base | `knowledgebase.articles/article/categories/search` | Good |
| Profile reads | `student.profile/photo/guardian/enrollment_history/clearance/id_card` | Read-only |

Self-scoping is correct where it exists: a student token can only ever address its own `regno`
(`academic`/`finance` force `regno = auth.UserId`; `student` rejects a mismatched `regno`).

---

## 3. The gap register

Each row is a feature a student uses **in the portal today** with **no API path at all**. Row
counts are live, taken 23 Aug 2026.

| # | Feature | Portal page | Table (rows) | Severity |
|---|---|---|---|---|
| G1 | **Change / forgot / reset password** | `ForcePasswordChange`, `ResetPassword`, `ForgotPassword` | `my_aspnet_membership` | **Critical** |
| G2 | **Mark correction requests** | `MarkRequests`, `MarkStatusCheck` | `acad_marks_requests` (**1,530**) | **Critical** |
| G3 | **Photograph upload + approval status** | `StudentPhoto` | `stud_photo_change` (**761**) | **High** |
| G4 | **Name rearrangement** | `MyName` | `stud_name_arrangement` (**134**) | **High** |
| G5 | **Date of birth correction** | `MyDateOfBirth` | `acad_student.dob` + `stud_name_arrangement` | **High** |
| G6 | **Course removal requests** | `CourseRemovalRequests` | `acad_course_deletion_requests` (**35**) | **High** |
| G7 | **Student elections — vote, candidates, results** | `Elections`, `ElectionVote`, `ElectionResults` | `elect_election/post/candidate/vote/voter/result` (15 candidates, 8 posts, 5 votes, 22 voters) | **High** |
| G8 | **Retake registration (write)** | `RetakeRegistration` | `acad_retake_registrations` (**197**) | Medium |
| G9 | **University email journey (SEMS)** | `MyEmail` | `sems_email_directory` (1,964), `sems_quiz_attempts` (403), `sems_notifications` (136), `sems_complaints` (15) | Medium |
| G10 | **Enrollment verification letter** | `EnrollmentVerification` | derived | Medium |
| G11 | **One "me" call for an app home screen** | `dashboard`, `Default` | derived | Medium |
| G12 | **Forced-reading acknowledgement** | `ForceRead` | `campus.force_read` exists staff-side only | Low |
| G13 | **Course bank / programme course search** | `CourseBank` | `acad_course` | Low |
| G14 | **Fee structure for the student's own programme** | `StudentFeeStructure` | partially in `finance.fees_structure` | Low |

**G1 deserves emphasis.** `auth` has `login/logout/validate/refresh/ping` and nothing else. An
app built on this API cannot let a student change their password, and cannot recover an account.
The applicant module (`apply`) has all three — students have none.

---

## 4. Conventions any new endpoint must follow

Taken from the existing modules, so new work is indistinguishable from old:

- One `.aspx` + `.aspx.cs` per module, class `API_v2_<file>`.
- `Page_Load`: `HandleCors` → `IsRateLimited` → `switch(action)` → `default: INVALID_ACTION`,
  whole body wrapped in `try/catch` → `SERVER_ERROR`.
- Auth: `TokenInfo auth = TokenManager.RequireAuth(Request, Response); if (auth == null) return;`
  Student endpoints must **force** `regno = auth.UserId` and never trust a `regno` parameter.
  Honour `TokenManager.IsSpecialToken` wherever a role gate is added.
- Envelope: `ApiHelper.Success(Response, data, msg)` / `ApiHelper.Error(Response, msg, CODE)`.
  HTTP is always 200; callers branch on `success`.
- JSON keys are **snake_case**, produced by SQL column aliases.
- All SQL parameterised with `MySqlParameter`. `TRIM()` both sides of `regno`/`courseID` joins.
- **DB routing:** `ApiHelper.Query/Execute/Scalar` → `campus_dynamics`.
  `QueryPortal/ExecutePortal/ExecuteInsertPortal/ScalarPortal` → `campus_dynamics_portal`
  (ODEL, `acad_course_registration`, `acad_marks_requests`, `acad_course_deletion_requests`,
  `acad_retake_registrations`, `sems_*`). Cross-DB reads use the `campus_dynamics.` prefix.
- Every business rule must be re-derived server-side. The portal is not the authority; the
  endpoint is.

---

## 5. Build plan

### Phase 1 — `me.aspx`: the student's own record ✅ BUILT

A single module for everything a student does *to their own record*, so an app has one place to
look. All actions are student-token-only and self-scoped; there is no `regno` parameter to abuse.

| Action | Method | Does |
|---|---|---|
| `me.summary` | GET | One call for an app home screen: identity, programme, registration standing, fee position, photo state, unread notices, outstanding requests |
| `me.name` | GET | Current name split into words, as the transcript renders it, plus the rearrangement history |
| `me.save_name` | POST | Reorder the words. Server re-derives from what is stored and refuses anything that is not a permutation |
| `me.dob` | GET | Date of birth, transcript-formatted, with the day/month swap suggestion and how many corrections remain |
| `me.save_dob` | POST | Correct it, under the same guards as the portal: real calendar date, not future, 14–90 today, ≥14 at entry, max 3 student corrections |
| `me.photo` | GET | Current photo state, any pending request, the reviewer's comment, **and a signed upload ticket** |
| `me.change_password` | POST | Verify the current password and set a new one |

**On the photograph, a decision worth recording.** The plan first said `me.upload_photo` would
accept the file. It does not, and should not. `COOPERP/StudentInfo/SelfPhotoUpload.ashx` — in
this same application — is already the one place that validates an image, builds the thumbnail,
names the file, and writes both `acad_student.photofile` and the `stud_photo_change` audit row.
A second implementation would be a second set of rules to drift apart from the first. `me.photo`
therefore returns a short-lived HMAC ticket for that handler (the same ticket the web page
issues), and the app posts the image straight to it. One write path, no drift.

### Phase 2 — `auth` extensions ✅ BUILT

| Action | Does |
|---|---|
| `auth.change_password` | Same as `me.change_password`, on the module an app looks in first. Works for staff too |
| `auth.forgot_password` | Issue a reset PIN to the address on record |
| `auth.reset_password` | Consume the PIN and set a new password |

### Phase 3 — `requests.aspx`: everything a student asks the University for ✅ BUILT

| Action | Does | Table |
|---|---|---|
| `requests.marks` | List my mark correction requests | `acad_marks_requests` |
| `requests.mark_detail` | One request with its history | " |
| `requests.submit_mark` | Raise one (course, semester, type, lecturer, reason) | " |
| `requests.course_removals` | List my course removal requests | `acad_course_deletion_requests` |
| `requests.submit_course_removal` | Ask for a course registration to be removed | " |
| `requests.cancel_course_removal` | Withdraw one still pending | " |
| `requests.retakes` | Courses I may retake, and those I have registered | `acad_retake_registrations` |
| `requests.register_retake` | Register a retake | " |

### Phase 4 — `elections.aspx`: student elections ✅ BUILT

| Action | Does |
|---|---|
| `elections.list` | Elections open to me |
| `elections.detail` | Posts and timings |
| `elections.candidates` | Candidates for a post |
| `elections.vote` | Cast one vote per post; one voter, one ballot, enforced server-side |
| `elections.my_votes` | What I have already cast (not who for, if the ballot is secret) |
| `elections.results` | Published results only |

### Phase 5 — remaining ✅ BUILT (two of them turned out not to need building)

| Item | Outcome |
|---|---|
| `me.email_journey` + `me.notifications` + `me.read_notification` (G9) | ✅ Built. The address is only returned once the quiz is passed — the API keeps the journey's own order rather than handing it over early |
| `me.fee_structure` (G14) | ✅ Built. Unfolds the wide `fin_programme_fees` row into `years[] → semesters[]` so an app gets a list, not forty column names |
| `academic.course_bank` (G13) | ✅ Built. Excludes archived, merged and blank codes |
| **G10 — "enrollment verification letter"** | ❌ **The gap was misread.** `EnrollmentVerification.aspx` is an *email*-verification gate, not a letter. There is no letter to expose. The real need — proving current enrolment — is already answered by `academic.enrollment_status` and `me.summary`. **No endpoint built, and none needed.** |
| **G12 — forced-reading acknowledgement** | ❌ **Already covered.** Forced-read notices live in `sys_communications` with `is_force_read`, and `campus.notices` already returns the flag while `campus.mark_read` already records the acknowledgement. Building a second endpoint would have duplicated a working one. |

Both corrections are recorded rather than quietly dropped: the first was my misreading of a page
name at analysis time, the second was a gap that closer reading showed was already closed.

---

## 6. Test plan

Every endpoint is exercised against the **live database** through the real HTTP surface, with a
student token, and asserted on:

1. **Auth** — no token is refused; a *staff* token cannot reach student-only actions; a student
   token cannot address another student's `regno`.
2. **Shape** — `success`, `data`, snake_case keys, and pagination nested inside `data`.
3. **Business rules** — each refusal path returns its own `error_code`, and writes nothing.
4. **Idempotence / cleanup** — every write test reverses itself; row counts return to baseline.

Test student: **MRU2027000002** (free to use).

---

## 7. Documentation

`API/v2/docs.aspx` is the published reference (static HTML cards, 4,331 lines). Every action
built must appear there with parameters, an example request and an example response, in a card
matching the existing style. `API_DOCUMENTATION.md` is the long-form companion.

---

## 8. Status

| Phase | State |
|---|---|
| 1 — `me.aspx` | ✅ Built, tested, documented |
| 2 — `auth` password actions | ✅ Built, tested, documented |
| 3 — `requests.aspx` | ✅ Built, tested, documented |
| 4 — `elections.aspx` | ✅ Built, tested, documented |
| 5 — SEMS / notifications / course bank / fee structure | ✅ Built, tested, documented |
| 5 — enrollment letter (G10), forced reading (G12) | ❌ Not needed — see the table above |

**All 14 gaps are closed.** Twelve by new endpoints, two by establishing that nothing was
missing. The student API grew from 264 actions to **288**, in three new modules
(`me`, `requests`, `elections`) plus additions to `auth` and `academic`.

### What was verified

Every endpoint was exercised against the **live database through real HTTP** with a genuine
student token (`MRU2027000002`), asserting on auth, shape, each refusal path writing nothing, and
cleanup. Elections were tested against a purpose-built `ZZ TEST` election — created Active,
voted in, results published, then removed entirely, with an orphan check afterwards proving
nothing was left behind. The test student's password was set temporarily and restored to its
original hash.

### Known limits, stated plainly

- **Ballot secrecy is schema-deep, not cryptographic.** `elect_vote.voter_id` ties a ballot to a
  voter; that is the existing design. The API declines to publish the link, but does not pretend
  it is absent. Making elections genuinely secret would be a schema change and a separate piece
  of work.
- **Retake fees are not billed by the API.** `register_retake` records the registration with
  `fee_billed='No'`; the Bursar's billing run raises the charge, as it does for the portal.
- **Mark requests open at `PENDING_LECTURER` only.** Routing to a specific lecturer is honoured
  via `assigned_lecturer_id` when supplied, but the API does not attempt the portal's fuller
  lecturer-inference; an unrouted request is picked up at the department.
