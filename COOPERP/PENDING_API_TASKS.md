# Campus Dynamics — Pending API Tasks
**Generated:** 2026-05-16  
**Scope:** Features fully implemented in the web UI (admin + portal) that are not yet exposed via the REST API at `/API/v2/`  
**Principle:** Every UI capability that a mobile app or ODEL integration would need must have a matching API endpoint.

---

## Priority Legend
| Symbol | Meaning |
|--------|---------|
| 🔴 | **Critical** — blocks mobile app or ODEL integration |
| 🟠 | **High** — needed for full portal parity |
| 🟡 | **Medium** — improves completeness |
| 🟢 | **Low** — admin/reporting, not student-facing |

---

## 1. 🔴 Support Ticket System (`support.aspx`)

**UI Location:** Portal → `MyTickets.aspx` (student) | Admin → staff side  
**DB Tables:** `support_tickets`, `support_ticket_messages`, `support_ticket_attachments`  
**Auth:** Student tickets scoped to own `submitter_regno`; staff sees all  

### Schema (auto-created by `SupportTicketDB.EnsureSchema()`)
```
support_tickets         ticket_id, submitter_regno, submitter_name, submitter_type,
                        issue_type, subject, status (OPEN|IN_PROGRESS|AWAITING_REPLY|RESOLVED|CLOSED),
                        priority (LOW|NORMAL|HIGH|URGENT), assigned_to, created_at, updated_at,
                        closed_at, closed_by
support_ticket_messages message_id, ticket_id, sender_regno, sender_name,
                        sender_role (SUBMITTER|ADMIN|SYSTEM), message, is_internal, created_at
support_ticket_attachments attachment_id, ticket_id, message_id, original_name, stored_name,
                        file_size, mime_type, uploaded_by, uploaded_at
```

### Endpoints to add to `support.aspx` (new file)

| Action | Method | Auth | Description |
|--------|--------|------|-------------|
| `list` | GET | student/staff | Student: own tickets filtered by `?status=`. Staff: all tickets with `?regno=`, `?status=`, `?priority=`, `?assigned_to=` |
| `detail` | GET | student/staff | Single ticket with full message thread |
| `create` | POST | student/staff | Submit new ticket: `issue_type`, `subject`, `message`, `priority` |
| `reply` | POST | student/staff | Add message to thread: `ticket_id`, `message`. Staff only: `is_internal=1` |
| `update_status` | POST | staff | Change status/assignment: `ticket_id`, `status`, `assigned_to` |
| `close` | POST | student/staff | Close own ticket (student) or any ticket (staff) |
| `stats` | GET | student/staff | Count per status for dashboard cards |

### Implementation Notes
- `SupportTicketDB` static class already has all DB logic — call it from the handler
- Student can only see their own tickets; check `submitter_regno = auth.UserId` for non-staff
- Internal messages (`is_internal=1`) must NOT be returned to student callers
- Attachment upload is separate (use existing file-upload pattern from finance API)
- Rate-limit `create` tightly (max 5/hour per student) to prevent spam

---

## 2. 🔴 Knowledgebase (`knowledgebase.aspx`)

**UI Location:** Portal → `KnowledgebasePortal.aspx` (read) | Admin → `KnowledgebaseManagement.aspx` (write)  
**DB Tables:** `kb_categories`, `kb_articles`  

### Schema
```
kb_categories  id, title, description, photo_path, display_order, is_active,
               created_by, created_at
kb_articles    id, category_id, title, description, content (HTML/markdown),
               photo_path, is_youtube_video, youtube_url, display_order,
               view_count, visibility (PUBLIC|STUDENTS|STAFF), status (DRAFT|PUBLISHED),
               created_by, created_at, updated_at
```

### Endpoints to add to `knowledgebase.aspx` (new file)

| Action | Method | Auth | Description |
|--------|--------|------|-------------|
| `categories` | GET | student/staff | All active categories ordered by `display_order` |
| `articles` | GET | student/staff | Articles in a category: `?category_id=`, `?search=`. Excludes `DRAFT` for non-admin. |
| `article` | GET | student/staff | Single article; increments `view_count`. Returns full `content` field. |
| `search` | GET | student/staff | Full-text search across `title + description + content` |
| `save_category` | POST | staff (admin) | Create or update a category (pass `id` to update) |
| `delete_category` | POST | staff (admin) | Delete only if no published articles remain |
| `save_article` | POST | staff (admin) | Create or update an article |
| `delete_article` | POST | staff (admin) | Delete article by `id` |

### Implementation Notes
- `visibility` filter: PUBLIC = any auth token; STUDENTS = student token; STAFF = staff token
- `view_count` increment should be debounced per (user, article, day) via a lightweight cache
- Search uses `LIKE %term%` on `title`, `description`, `content` — consider `FULLTEXT` index on large installs

---

## 3. 🔴 Provisional Marks API (`staff.aspx` — extend existing)

**UI Location:** Portal → `LecturerProvisionalMarksController.aspx`  
**DB Tables:** `campus_dynamics_portal.acad_course_registration` (columns added: `provisional_course_work_marks`, `provisional_exam_marks`, `provisional_total_marks`, `provisional_marks_status`)  
**Status values:** `null` / `pending` / `approved` / `rejected` / `published`  

### Endpoints to add to existing `staff.aspx`

| Action | Method | Auth | Description |
|--------|--------|------|-------------|
| `provisional_marks_list` | GET | staff | Lecturer's assigned rows: `?acad_year=`, `?semester=`, `?prog=`, `?status=`, `?sq=` (student search), `?page=`, `?size=` |
| `provisional_mark_detail` | GET | staff | Single row by `?id=` — returns saved CW/Exam/Total, status, published mark/grade |
| `save_provisional_mark` | POST | staff | Set CW + Exam for one row (`id`, `cw`, `exam`). Rejected if `provisional_marks_status = published`. |
| `save_provisional_mark_inline` | POST | staff | Partial save (one field at a time, merge strategy). Same lock rules. |
| `provisional_marks_summary` | GET | staff | Per-course aggregate: total assigned, entered, pending, approved, published |

### Key Business Rules (mirror the portal page)
- A row is **locked** when `provisional_marks_status = 'published'` — return `MARKS_LOCKED` error
- Staff may only edit rows where their `empID` matches `acad_programmecourses.lecturer_id` for that `courseID`
- CW max = 40, Exam max = 60, Total = CW + Exam
- Exam cannot be entered before CW

---

## 4. 🔴 Admissions Pipeline (`admissions.aspx` — new file)

**UI Location:** Admin → `AdmissionsController.aspx`  
**DB Tables:** `acad_applications`, `acad_applicant_choices`, `acad_student`, `acad_registration`, `my_aspnet_users`, `my_aspnet_membership`  
**Status mapping:** `adm_status` 0=PENDING, 1=ADMITTED, 2=REJECTED, 3=WITHDRAWN; REGISTERED = adm_status=1 AND `stud_reg_no` is set  

### Endpoints to add to `admissions.aspx` (new file)

| Action | Method | Auth | Description |
|--------|--------|------|-------------|
| `list` | GET | staff | Paginated applicant list. Filters: `status`, `prog`, `acad_year`, `session`, `source` (ONLINE/WALKIN), `min_pending_days`, `q` (name/email search) |
| `detail` | GET | staff | Full applicant record including education history, choice details, reviewer notes |
| `admit` | POST | staff | Set `adm_status=1`; provision portal account; send admission email |
| `reject` | POST | staff | Set `adm_status=2` with `reason` |
| `withdraw` | POST | staff | Set `adm_status=3` with `reason` |
| `register` | POST | staff | Convert admitted applicant → student: generate `regno`, create `acad_student` + `acad_registration` rows, create billing ID |
| `repair` | POST | staff | Fix incomplete registration (missing student or registration record) |
| `add_note` | POST | staff | Save reviewer comment on application |
| `stats` | GET | staff | Count by status, programme, source for dashboard |

### Implementation Notes
- `register` is a multi-step transaction: generate regno → insert acad_student → insert acad_registration → create billing account. Wrap in `BEGIN/COMMIT`.
- Account provisioning (my_aspnet_users + my_aspnet_membership) requires password hashing — reuse existing `PortalHelper` or `auth.aspx` logic
- `admit` should send email via the existing SMTP helper (same as forgotten-password flow)
- Staff auth only — no student access to any admissions endpoint

---

## 5. 🔴 Semester Deletion Requests (`academic.aspx` — extend)

**UI Location:** Admin → `SemesterDeletionRequestsController.aspx`  
**DB Tables:** `campus_dynamics_portal.acad_semester_deletion_requests`  

### Schema
```
acad_semester_deletion_requests
    id, regno, student_name, programme_code, programme_name,
    acad_year, study_year, semester, request_reason,
    status (PENDING|APPROVED|REJECTED),
    admin_username, admin_comment, deletion_executed (0|1),
    created_at, decided_at
```

### Endpoints to add to `academic.aspx`

| Action | Method | Auth | Description |
|--------|--------|------|-------------|
| `semester_deletion_requests` | GET | staff | List with pagination and filters: `?status=`, `?acad_year=`, `?q=` |
| `semester_deletion_request` | GET | staff/student | Single request detail (student sees only own) |
| `submit_semester_deletion` | POST | student | Student submits request: `acad_year`, `semester`, `reason` |
| `decide_semester_deletion` | POST | staff | Approve or reject: `id`, `decision` (APPROVED/REJECTED), `comment` |
| `batch_decide_semester_deletion` | POST | staff | Bulk approve/reject: `ids[]`, `decision`, `comment` |

### Implementation Notes
- Once `deletion_executed=1`, the row is immutable — return `ALREADY_EXECUTED` error on further decisions
- Approved requests trigger deletion of the `acad_course_registration` rows for that semester (execute via a stored procedure or explicit DELETE)
- Student can submit at most one PENDING request per (regno, acad_year, semester)

---

## 6. 🟠 Appraisal System (`appraisal.aspx` — new file)

**UI Location:** Admin → `AppraisalSessions.aspx`, `AppraisalView.aspx`, `AppraisalDashboard.aspx`, `AppraisalReports.aspx`  
**DB Tables:** `appraisal_sessions`, `appraisal_records`, `appraisal_section_b`, `appraisal_section_c`, `appraisal_section_d`, `appraisal_section_e`, `appraisal_competency_templates`  

### Schema Summary
```
appraisal_sessions          id, session_title, period_start, period_end, deadline,
                            target_categories (JSON/CSV), status (DRAFT|ACTIVE|CLOSED), created_by

appraisal_records           id, session_id, employee_id, reviewer_id, staff_category
                            (ACADEMIC|ADMINISTRATIVE), status, employee_submitted_at,
                            supervisor_submitted_at, final_percentage, classification

appraisal_section_b         competency ratings (self + supervisor)
appraisal_section_c         overall assessment
appraisal_section_d         performance gaps and agreed actions
appraisal_section_e         open-ended narrative questions

appraisal_competency_templates  52 criteria for ACADEMIC, 22+ for ADMINISTRATIVE
```

### Endpoints to add to `appraisal.aspx` (new file)

| Action | Method | Auth | Description |
|--------|--------|------|-------------|
| `sessions` | GET | staff | List appraisal sessions (admin sees all; staff sees ACTIVE sessions assigned to them) |
| `session` | GET | staff | Single session detail with statistics |
| `create_session` | POST | staff (admin) | Create new session with title, period, deadline, target categories |
| `update_session` | POST | staff (admin) | Edit session or change status (DRAFT→ACTIVE→CLOSED) |
| `my_appraisals` | GET | staff | Logged-in staff's assigned appraisal records |
| `appraisal_record` | GET | staff | Full record including all section data |
| `save_self_appraisal` | POST | staff | Employee fills section B (competency self-ratings) |
| `save_supervisor_appraisal` | POST | staff | Supervisor fills section B (supervisor ratings), C, D, E |
| `submit_appraisal` | POST | staff | Lock own submission (employee or supervisor role) |
| `report` | GET | staff (admin) | Aggregate report: filter by session, department, category; returns averages, classifications, submission rates |
| `export_report` | GET | staff (admin) | CSV export of full appraisal results for a session |
| `competency_templates` | GET | staff | List competency criteria for a given `staff_category` |

### Implementation Notes
- Two-phase submission: employee submits first → supervisor can then submit
- `final_percentage` computed server-side from weighted competency scores — not client-provided
- Classification derived from percentage: Excellent (≥90), Good (≥75), Satisfactory (≥60), Needs Improvement (<60)
- Templates auto-seeded on `EnsureSchema()` (52 academic / 22 admin criteria); `competency_templates` endpoint exposes them for mobile display

---

## 7. 🟠 Residence Allocation (`student.aspx` — extend OR `residence.aspx` new)

**UI Location:** Admin → `ResidenceAllocation.aspx`  
**DB Tables:** `acad_halls`, `acad_residence`, `acad_registration`  
> API currently has `finance → accommodation_status` (read-only). Full CRUD is missing.

### Schema
```
acad_halls     id, hall_name, hall_capacity
acad_residence id, regno, hall_id, room_id, acadyear, semester
acad_registration.residence_status  RESIDENT | NON-RESIDENT
```

### Endpoints to add to `student.aspx` or new `residence.aspx`

| Action | Method | Auth | Description |
|--------|--------|------|-------------|
| `halls` | GET | staff | List halls with capacity and current occupancy count |
| `allocations` | GET | staff | All allocations for a year/semester with filters: `?prog=`, `?study_year=`, `?hall_id=`, `?residence_status=`, `?q=` |
| `allocate` | POST | staff | Assign student to hall/room: `regno`, `hall_id`, `room_id`, `acad_year`, `semester` |
| `deallocate` | POST | staff | Remove student from hall by `regno` + `acad_year` + `semester` |
| `residence_stats` | GET | staff | Occupancy %, allocated vs unallocated by hall |

### Implementation Notes
- `accommodation_status` in `finance.aspx` can remain as the student-facing read endpoint
- Allocation should update `acad_registration.residence_status` to `RESIDENT`
- Check hall capacity before allocating; return `HALL_FULL` if at limit

---

## 8. 🟠 HR Employee CRUD (`staff.aspx` — extend)

**UI Location:** Admin → `HREmployees.aspx`  
**DB Tables:** `hrm_employee`, `hrm_contract`, `hrm_department`  
> API currently has `staff → profile` (read-only) and `staff → lookup`. Create/Update is missing.

### Endpoints to add to `staff.aspx`

| Action | Method | Auth | Description |
|--------|--------|------|-------------|
| `employees` | GET | staff (admin) | Paginated list with filters: `?dept=`, `?type=`, `?status=`, `?q=` (name/code/email search) |
| `employee` | GET | staff (admin) | Full profile including contract history |
| `create_employee` | POST | staff (admin) | Create new HR record with all fields |
| `update_employee` | POST | staff (admin) | Edit employee fields |
| `update_contract` | POST | staff (admin) | Set/renew contract dates and status |
| `departments` | GET | staff | List departments (used for filter dropdowns) |

### Implementation Notes
- Admin-only scope: verify the caller has an admin role (`auth.UserType == "staff"` is necessary but not sufficient — also check `hrm_employee.EmpType` or a role flag)
- Password/account fields (`usernames`) must never be returned in API responses
- `departments` can be cached aggressively (TTL 1 hour)

---

## 9. 🟡 Portal Onboarding Management (`admin.aspx` OR `student.aspx` — extend)

**UI Location:** Admin → `PortalOnboarding.aspx`  
**DB Tables:** `acad_student` (columns: `onboarding_status`, `portal_email_verified`, `first_login_at`)  

### Endpoints to add

| Action | Method | Auth | Description |
|--------|--------|------|-------------|
| `onboarding_list` | GET | staff (admin) | Students with onboarding status; filter `?status=`, `?prog=`, `?q=` |
| `resolve_onboarding_email` | POST | staff (admin) | Verify/update student email and resend portal invite |
| `onboarding_stats` | GET | staff (admin) | Count by `onboarding_status` for dashboard |

---

## 10. 🟡 Admissions — Student Self-Service (`student.aspx` OR `admissions.aspx`)

Students who applied online should be able to check their own admission status without a full student account.

| Action | Method | Auth | Description |
|--------|--------|------|-------------|
| `application_status` | GET | public (by `?app_id=` + `?dob=`) | Check own application status without a token |
| `application_detail` | GET | student (post-admission) | Admitted student views their acceptance letter data |

---

## 11. 🟡 Chart of Accounts (`finance.aspx` — extend)

**UI Location:** Admin → `MainAccountsController.aspx`  
**DB Tables:** `fin_mainaccounts`  

### Endpoints to add to `finance.aspx`

| Action | Method | Auth | Description |
|--------|--------|------|-------------|
| `chart_of_accounts` | GET | staff | All main accounts with category/sub-category grouping |
| `account` | GET | staff | Single account detail |
| `create_account` | POST | staff (finance admin) | Create via `MainAccountEditor` SP |
| `update_account` | POST | staff (finance admin) | Update via `MainAccountEditor` SP |
| `delete_account` | POST | staff (finance admin) | Delete via `DeleteMainAccount` SP |

---

## 12. 🟢 Student Profile — Extended Fields (`student.aspx` — extend existing `profile`)

**UI Location:** Portal → `StudentProfile.aspx` | Admin → `StudentProfile.aspx`  
The existing `profile` action returns core fields. Missing:

| Missing Field / Action | Where to get it |
|------------------------|----------------|
| Next of kin (name, relationship, phone) | `acad_applications.nok_*` |
| Sponsor name and type | `acad_applications.sponsor_*` |
| Full registration history (all years/semesters with status labels) | `acad_registration` — already in `registration_history` academic action |
| ID card status + production date | `acad_student.id_card_status`, `id_card_checked_at` |
| Onboarding status | `acad_student.onboarding_status`, `portal_email_verified`, `first_login_at` |

**Recommendation:** Add `?include=next_of_kin,sponsor,id_card,onboarding` optional flags to the existing `profile` action rather than a new endpoint.

---

## 13. 🟢 Mark Requests (`staff.aspx` — extend)

**UI Location:** Portal → `LecturerMarkRequests.aspx`  
Lecturers need to raise requests when marks cannot be entered (student withdrawal, exam irregularity, etc.).  

| Action | Method | Auth | Description |
|--------|--------|------|-------------|
| `mark_requests_list` | GET | staff | Lecturer's submitted requests with status |
| `create_mark_request` | POST | staff | Submit request with `course_id`, `regno`, `reason`, `request_type` |
| `mark_request_detail` | GET | staff | Single request with decision history |

---

## Summary — New Files to Create

| File | Actions count | Priority |
|------|--------------|----------|
| `API/v2/support.aspx` + `.cs` | 7 | 🔴 |
| `API/v2/knowledgebase.aspx` + `.cs` | 8 | 🔴 |
| `API/v2/admissions.aspx` + `.cs` | 9 | 🔴 |
| `API/v2/appraisal.aspx` + `.cs` | 12 | 🟠 |
| `API/v2/residence.aspx` + `.cs` | 5 | 🟠 |

## Summary — Existing Files to Extend

| File | New actions | Priority |
|------|------------|----------|
| `staff.aspx` | `provisional_marks_list`, `provisional_mark_detail`, `save_provisional_mark`, `save_provisional_mark_inline`, `provisional_marks_summary`, `employees`, `employee`, `create_employee`, `update_employee`, `update_contract`, `departments`, `mark_requests_list`, `create_mark_request`, `mark_request_detail` | 🔴🟠 |
| `academic.aspx` | `semester_deletion_requests`, `semester_deletion_request`, `submit_semester_deletion`, `decide_semester_deletion`, `batch_decide_semester_deletion` | 🔴 |
| `student.aspx` | `application_status`, `application_detail`, `onboarding_list`, `resolve_onboarding_email`, `onboarding_stats` | 🟡 |
| `finance.aspx` | `chart_of_accounts`, `account`, `create_account`, `update_account`, `delete_account`, `halls`, `allocations`, `allocate`, `deallocate`, `residence_stats` | 🟡🟢 |

---

## ✅ ALL 61 ENDPOINTS IMPLEMENTED — v2.3 COMPLETE

| File | New Endpoints | Status |
|------|--------------|--------|
| `support.aspx` (new) | 7 | ✅ Done |
| `knowledgebase.aspx` (new) | 8 | ✅ Done |
| `admissions.aspx` (new) | 10 | ✅ Done |
| `residence.aspx` (new) | 5 | ✅ Done |
| `appraisal.aspx` (new) | 12 | ✅ Done |
| `finance.aspx` (extended) | 5 | ✅ Done |
| `staff.aspx` (extended) | 14 | ✅ Done |
| `academic.aspx` (extended) | 5 | ✅ Done |
| `student.aspx` (extended) | 4 + profile include | ✅ Done |
| **Total** | **61+** | ✅ Done |

---

## Implementation Summary (completed 2026-05-16)

All phases completed:
- Phase 1 ✅ — support.aspx, knowledgebase.aspx, staff provisional marks, academic semester deletion
- Phase 2 ✅ — admissions.aspx, residence.aspx, staff HR CRUD
- Phase 3 ✅ — appraisal.aspx, finance chart of accounts, student profile extensions + onboarding

---

## Standards to Follow for Each New File

Every new endpoint file must:

1. Call `ApiHelper.HandleCors()` at the top of `Page_Load`
2. Call `ApiHelper.IsRateLimited()` immediately after CORS
3. Use `TokenManager.RequireAuth()` — never roll your own auth
4. Scope student endpoints: `auth.UserType != "staff"` → force `regno = auth.UserId` (no impersonation)
5. Scope admin endpoints: reject if `auth.UserType != "staff"` with `FORBIDDEN`
6. Return errors via `ApiHelper.Error(Response, message, "UPPER_SNAKE_CODE")`
7. Return success via `ApiHelper.Success(Response, data)`
8. Use `MySqlParameter` for every value — never string-concatenate SQL
9. Register the `.aspx` markup file (even if empty) — IIS requires it for the handler to route
10. Add the new endpoint(s) to `docs.aspx` sidebar, stats counter, and changelog

---

*Last updated: 2026-05-16 by Campus Dynamics Developer*
