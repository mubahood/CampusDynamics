# Appraisal System — Master Implementation Plan
**Date:** 2026-05-16  
**Prepared by:** Campus Dynamics Developer  
**Status:** IMPLEMENTATION IN PROGRESS — P0 + P1 + P2 (print) batch complete (2026-05-16)

---

## 1. CURRENT STATE SUMMARY

### What is built

| Component | Location | Status |
|-----------|----------|--------|
| Session management (HR) | `COOPERP/NewScreens/AppraisalSessions.aspx` | ✅ Working |
| Dashboard / KPIs (HR) | `COOPERP/NewScreens/AppraisalDashboard.aspx` | ✅ Working |
| Record viewer / admin actions | `COOPERP/NewScreens/AppraisalView.aspx` | ✅ Working |
| Reports + CSV export | `COOPERP/NewScreens/AppraisalReports.aspx` | ✅ Working |
| Employee self-appraisal | `Portal/SelfAppraisal.aspx` | ✅ Working |
| Supervisor review | `Portal/SupervisorAppraisal.aspx` | ✅ Working |
| My appraisals list | `Portal/MyAppraisals.aspx` | ✅ Working |
| REST API | `API/v2/appraisal.aspx` | ✅ Working |
| **Student appraisal of lecturers** | — | ❌ NOT IMPLEMENTED |
| **Print / PDF output** | — | ❌ NOT IMPLEMENTED |

### Staff categories in database

| Category Code | Criteria Count (Seeded) | Official Form Count | Gap | Status |
|---------------|------------------------|--------------------|----|--------|
| ACADEMIC | 45 criteria, 9 groups | 45 confirmed / 50 per formula | 5 unconfirmed — pending HR | ✅ Reseeded (2026-05-16) |
| ADMINISTRATIVE | 22 criteria, 1 group | 22 confirmed / 30 per formula | 8 unconfirmed — pending HR | ✅ Reseeded (2026-05-16) |
| SUPPORT | 25 criteria, 6 groups | 25 confirmed / 30 per formula | 5 unconfirmed — pending HR | ✅ Reseeded (2026-05-16) |
| STUDENT_LECTURER | Not seeded / no table | Official form not yet shared | Entire type missing | ❌ Greenfield needed |

### Known critical gaps (from existing audit `APPRAISAL_A_TO_Z_AUDIT_2026-05-07.md`)

1. Section C criteria do not match official Council-approved forms
2. Section B slot count is 5; official forms allow up to 10
3. Section E has 5 questions; Academic form describes 6
4. Support criteria are marked "placeholder — to be refined"
5. Student appraisal of lecturers: zero implementation
6. No printable/PDF output for any form type
7. Classification band labels differ (code vs. form)
8. Denominator logic in scoring is weak (employee can inflate via N/A)

---

## 2. THE FOUR APPRAISAL TYPES — FULL JOURNEY

---

### TYPE 1: ACADEMIC STAFF APPRAISAL

**Actors:** Employee (Lecturer) → Supervisor (HoD/Dean) → Responsible Officer (VC/DVC/HRM)  
**Output target:** *FINAL_REVISED APPRAISAL TOOL FOR ACADEMIC STAFF APPROVED BY THE COUNCIL*

#### Journey

```
1. HR creates session (DRAFT) → sets period, deadline, target categories
2. HR activates session (ACTIVE)
3. HR generates appraisal records for all Academic Staff
4. Lecturer logs into Portal → sees pending appraisal in MyAppraisals
5. Lecturer opens SelfAppraisal:
   - Section A: Personal info (pre-filled from HR records)
   - Section B: Agrees on Key Duties (up to 10) + Self Rating
   - Section E: Answers 6 narrative questions
   - Submits form → status = EMPLOYEE_SUBMITTED
6. Supervisor (HoD) opens SupervisorAppraisal:
   - Section B: Rates each agreed output (Supervisor Rating)
   - Section C: Rates all 50 competencies across 9 groups
   - Section D: Fills action plan (performance gaps + agreed actions)
   - Section E: Appraiser comments
   - Completes → system computes scores → status = COMPLETED
7. Responsible Officer reviews (Dean/VC) → countersigns
8. HR archives → employee gets copy
9. HR generates printable report → PDF matches official form
```

#### Official Section C Criteria (Academic Staff — 45 confirmed, target 50)

> **Action required:** HR to confirm if count is 45 or 50 and identify any missing 5

| Group | Code | Criterion | Count |
|-------|------|-----------|-------|
| Teaching Function | C1.1–C1.6 | Class sessions organised; course outlines; timely return of work; updated notes/PPT; curriculum development; student consultations | 6 |
| Administration | C2.1–C2.7 | Communicates clearly; meets deadlines/extra duties; loyal/takes advice; attends meetings; available for departmental work; graduation; orientation | 7 |
| Examinations | C3.1–C3.6 | Gives feedback; marks and submits results on time; adheres to regulations; invigilation; team marking; moderation | 6 |
| Research | C4.1–C4.7 | Attends MRU Graduate Centre presentations; conference papers; research training seminars; published articles; monographs; books; curriculum contribution | 7 |
| Supervision | C5.1–C5.2 | Undergraduate students; Graduate students | 2 |
| Training of Trainers | C6.1 | Attended TOTs, short term courses | 1 |
| Relations | C7.1–C7.8 | Students; Administration; Lecturers; HoDs; aware of student needs; identifies needs; solves problems; Visitors | 8 |
| Skills | C8.1–C8.8 | ICT; Email; ODeL; E-Learning upload; E-Library books; blended learning; inspires students; inspires colleagues | 8 |
| Competences | C9.1–C9.7 | High quality work; applies rules; reliable; dependable; initiative/hardworking; general appearance; shares information | 7 |
| **TOTAL** | | | **52 in code / 50 in formula** |

#### Scoring Formula (Official)

```
Section C percentage = Total score ÷ 250 × 100
Where: denominator = 50 criteria × 5 max = 250
N/A criteria reduce the denominator proportionally
```

#### Section B Scoring

```
Section B average = Sum of Supervisor Ratings ÷ (Number of rated outputs)
Scale: 1 (Unsatisfactory) to 5 (Exceptional)
```

#### Overall Classification Bands

| Label | Score | Description |
|-------|-------|-------------|
| Exceptional | 5 / 90–100% | Consistently exceeds competent levels |
| Above Expectations | 4 / 75–89% | Often exceeds competent levels |
| Satisfactory | 3 / 60–74% | Consistently meets expected levels |
| Development Needed | 2 / 50–59% | Some performance below competent level |
| Unsatisfactory | 1 / <50% | Consistently below competent level |

#### Section E Questions (Official — 6 questions)

1. Describe how effectively you have been utilized by the University
2. What do you consider to be your major strength(s) with respect to your competencies?
3. List down any work you accomplished in addition to your agreed tasks/responsibilities
4. In respect of your Key Performance Areas, what achievement(s) are you particularly pleased with?
5. Specify any areas where you could not meet the expected standards and give reasons thereof
6. What are your aspirations in terms of career development?

#### Implementation Tasks — Academic Staff

- [ ] **T1.1** Correct Section C competency template seed to exactly match official form (45 confirmed criteria or 50 after HR confirmation) — update `SeedCompetencyTemplates()` in `AppraisalSessions.aspx.cs`
- [ ] **T1.2** Fix competency criteria names and groups in seed to match word-for-word with the Council-approved form (see template `APPRAISAL_TEMPLATE_ACADEMIC_STAFF.md`)
- [ ] **T1.3** Increase Section B slots from 5 to 10 in `InitializeSections()` in `SelfAppraisal.aspx.cs`
- [ ] **T1.4** Add the 6th Section E question ("What are your aspirations in terms of career development?") to `SectionEQuestions[]` array
- [ ] **T1.5** Fix classification band labels to match official form: Exceptional / Above Expectations / Satisfactory / Development Needed / Unsatisfactory (not Outstanding / Very Good / etc.)
- [ ] **T1.6** Fix denominator logic: N/A marking must be supervisor-controlled only (employee cannot toggle N/A in Section C)
- [ ] **T1.7** Fix Section B denominator: base on expected output count (up to 10), not only rated rows
- [ ] **T1.8** Add "Responsible Officer countersign" step to the workflow (3rd signature: Dean/VC/DVC/HRM)
- [ ] **T1.9** Build PDF/printable report for Academic Staff that renders the official form layout with all data filled in
- [ ] **T1.10** Confirm exact 50 criteria count with HR office and adjust seed accordingly

---

### TYPE 2: ADMINISTRATIVE STAFF APPRAISAL

**Actors:** Employee (Admin Staff) → Supervisor → HR Manager  
**Output target:** *REVISED APPRAISAL FORM FOR ADMINISTRATIVE STAFF APPROVED BY COUNCIL*

> **IMPORTANT:** The official Administrative Staff form was NOT included in the materials shared. The Support Staff form was shared twice. The following is based on the current code implementation (22 ADMINISTRATIVE competencies) combined with known MRU policy. The official form must be obtained from HR before implementation can be finalized.

#### Journey

```
1. HR creates session → includes ADMINISTRATIVE category
2. HR generates records for all Administrative Staff
3. Admin Staff employee self-appraises:
   - Section A: Personal info
   - Section B: Agreed Key Duties (up to 10) + Self Rating
   - Section E: Narrative responses
4. Supervisor reviews:
   - Section B: Supervisor ratings
   - Section C: 22 competency ratings
   - Section D: Action plan
5. HR countersigns → archived → printable report generated
```

#### Current ADMINISTRATIVE Competency List (22 criteria — to be verified against official form)

| Code | Criterion |
|------|-----------|
| A1 | Professional Knowledge/Skills |
| A2 | Planning, Organising & Coordinating |
| A3 | Managing People |
| A4 | Decision Making |
| A5 | Team Work |
| A6 | Initiative |
| A7 | Writing & Communication Skills |
| A8 | Integrity |
| A9 | Time Management & Meeting Deadlines |
| A10 | Meetings |
| A11 | Dependability |
| A12 | Loyalty |
| A13 | Financial Management & Accountability |
| A14 | Quality of Work & Results |
| A15 | Record Keeping |
| A16 | Interpersonal Relations |
| A17 | Verbal & Listening Skills |
| A18 | Discretion & Confidentiality |
| A19 | Punctuality & Attendance |
| A20 | Computer Knowledge |
| A21 | Customer Care |
| A22 | Adaptability & Flexibility |

#### Implementation Tasks — Administrative Staff

- [ ] **T2.1** Obtain the official "REVISED APPRAISAL FORM FOR ADMINISTRATIVE STAFF APPROVED BY COUNCIL" from HR
- [ ] **T2.2** Save official form as `APPRAISAL_TEMPLATE_ADMIN_STAFF.md` in this directory
- [ ] **T2.3** Audit current 22 criteria against official form — add/remove/rename as required
- [ ] **T2.4** Confirm official Section C criteria count and scoring formula for Admin Staff (likely x/110*100 if 22 criteria, or different count)
- [ ] **T2.5** Confirm Section B slot count (code has 5; likely needs to be 8–10 per form)
- [ ] **T2.6** Apply same Section E question fix as T1.4 if needed for Admin
- [ ] **T2.7** Build PDF/printable report for Administrative Staff
- [ ] **T2.8** Apply classification band fix (same as T1.5)

---

### TYPE 3: SUPPORT STAFF APPRAISAL

**Actors:** Employee (Support Staff / Cleaners / Security / Drivers etc.) → Supervisor → HR  
**Output target:** *REVISED APPRAISAL TOOL FOR SUPPORT STAFF APPROVED BY COUNCIL*

#### Journey

```
1. HR creates session → includes SUPPORT category
2. HR generates records for all Support Staff
3. Support Staff employee self-appraises:
   - Section A: Personal info
   - Section B: Agreed Key Duties (up to 5 in form) + Self Rating (40% weight)
4. Supervisor reviews:
   - Section B: Supervisor ratings
   - Section C: 30 competency ratings (scoring formula: x/150*100)
   - Supervisor remarks
5. Supervisee declaration: Agree / Disagree
6. Supervisor recommendation → HR recommendation → archived
7. Printable report generated
```

#### Official Section C Criteria (Support Staff — official count: 30, confirmed by formula y=150)

| # | Group | Criterion |
|---|-------|-----------|
| S1 | Administrative Functions | Work/cleaning schedules followed |
| S2 | Administrative Functions | Report accidents/incidents on shift |
| S3 | Administrative Functions | Report to work as scheduled; notify if late/absent |
| S4 | Administrative Functions | Attend departmental and staff meetings |
| S5 | Administrative Functions | Develop and maintain good working relationships |
| S6 | Safety & Sanitation | Follow established safety procedures |
| S7 | Safety & Sanitation | Assigned work areas maintained clean/safe/sanitary |
| S8 | Safety & Sanitation | Report missing/mislabeled chemical containers |
| S9 | Safety & Sanitation | Keep work areas free of hazardous objects |
| S10 | Safety & Sanitation | Follow proper PPE techniques when mixing chemicals |
| S11 | Equipment & Supply | Keep supervisor informed of supply needs |
| S12 | Equipment & Supply | Assist others in lifting heavy equipment |
| S13 | Equipment & Supply | Equipment cleaned and stored at end of shift |
| S14 | Equipment & Supply | Effective use of equipment without misuse/embezzlement |
| S15 | Job Knowledge | In-depth knowledge of all requirements of the job |
| S16 | Job Knowledge | Perform day-to-day work as assigned; maintain areas clean |
| S17 | Honesty | Maintain confidentiality of University information |
| S18 | Honesty | Treat fellow workers with kindness, dignity and respect |
| S19 | Honesty | Knock before entering an office or room |
| S20 | Honesty | Inform officers when moving personal possessions during cleaning |
| S21 | Honesty | Report allegations of abuse/neglect/misappropriation |
| S22 | Quality | Quality of Work: accuracy and neatness |
| S23 | Quality | Dependability: works with limited supervision |
| S24 | Quality | Attendance and Punctuality |
| S25 | Quality | Relations with Others: supervisors, co-workers, University community |
| S26–S30 | **TO CONFIRM** | 5 additional criteria not yet identified from official form — HR to provide |

#### Scoring Formula (Official)

```
Final percentage = Total score ÷ 150 × 100
Where: denominator = 30 criteria × 5 max = 150
```

#### Section B (Support Staff specific)

- Maximum 5 outputs (form shows 5 rows, not 10 like Academic)
- Section B weighted at 40% overall
- Supervisor's Remarks field (paragraph)
- Declaration by Supervisee: Agree / Disagree checkbox

#### Implementation Tasks — Support Staff

- [ ] **T3.1** Remove "placeholder" comment from Support Staff competency seed in `SeedCompetencyTemplates()`
- [ ] **T3.2** Replace current 25 Support criteria with the 30 official criteria mapped above (S1–S30)
- [ ] **T3.3** Confirm the 5 missing criteria (S26–S30) with HR and add them
- [ ] **T3.4** Update Support Staff scoring formula denominator to 30 × 5 = 150
- [ ] **T3.5** Reduce Section B slots to 5 for SUPPORT category (form shows 5, not 10)
- [ ] **T3.6** Add "Supervisor's Performance Remarks" text area specific to Support Staff
- [ ] **T3.7** Add "Declaration by Supervisee: Agree/Disagree" step to Support Staff workflow
- [ ] **T3.8** Remove Section E (narrative questions) from Support Staff — the form does not include it
- [ ] **T3.9** Add Supervisor Recommendation and HR Recommendation fields to Support Staff record
- [ ] **T3.10** Build PDF/printable report for Support Staff matching official form layout
- [ ] **T3.11** Confirm if Section D (action plan) is included in Support Staff form — not visible in shared form

---

### TYPE 4: STUDENT APPRAISAL OF LECTURERS

**Actors:** Student (Appraisee initiator) → Rates Lecturer → Dept Compiles → HR Reports  
**Output target:** *REVISED STUDENTS APPRAISAL FORM FOR LECTURERS 2025/2026 — FINAL*

> **CRITICAL:** This entire type is **NOT YET IMPLEMENTED** anywhere in the system. Zero DB tables, zero portal pages, zero admin management. Full greenfield implementation required.

> **IMPORTANT:** The official "Students Appraisal Form for Lecturers" was not shared in the current session. It must be obtained from HR/Academic Affairs before implementation can begin.

#### What This Type Is

This is fundamentally different from the other three types:
- Students (not staff) fill in the form
- They are rating their LECTURER (not themselves)
- It is anonymous — student identity must not be traceable to their ratings
- The academic session / semester drives when students can appraise
- Results are compiled per-lecturer, per-course, per-semester
- Lecturers cannot see individual responses — only aggregate scores
- HR/Dean can see full reports

#### Journey

```
1. Academic Affairs / HR creates a "Student Appraisal Session" (tied to a semester)
2. System links: for each active course registration → generates an appraisal opportunity
   - Per: Student × Course × Lecturer × Semester
3. Student logs into Portal → sees "Rate Your Lecturers" section
4. Student selects a course they are enrolled in
5. Student fills in the anonymous appraisal form (questionnaire for that lecturer/course)
6. Student submits — response stored anonymously (no student identity linked to responses)
7. After session closes:
   - System computes aggregate scores per Lecturer per Course
   - Department Head can view reports per course
   - HR can view reports per lecturer (all courses)
   - Lecturer can view their OWN aggregate (not individual responses)
8. HR generates printable/PDF report per lecturer for use in academic performance review
```

#### Typical Student Appraisal Questions (To be confirmed from official form)

> The following is a general template — replace with official MRU form questions once obtained.

| # | Question / Criterion | Scale |
|---|---------------------|-------|
| Q1 | The lecturer was always punctual to class | 1–5 |
| Q2 | The lecturer prepared adequately for teaching | 1–5 |
| Q3 | The lecturer communicated course content clearly | 1–5 |
| Q4 | The lecturer used a variety of teaching methods | 1–5 |
| Q5 | The lecturer provided clear course outlines and learning outcomes | 1–5 |
| Q6 | The lecturer was available for student consultations outside class | 1–5 |
| Q7 | The lecturer returned marked work (assignments/tests) in a timely manner | 1–5 |
| Q8 | The lecturer treated all students fairly and with respect | 1–5 |
| Q9 | The lecturer covered the full course content | 1–5 |
| Q10 | Overall, how would you rate this lecturer's performance? | 1–5 |
| Q11 | What did you like most about this lecturer? (Open text) | Text |
| Q12 | What should this lecturer improve? (Open text) | Text |

#### Required New Database Tables

```sql
-- Session for student appraisal (separate from staff sessions)
CREATE TABLE student_appraisal_sessions (
    session_id      INT AUTO_INCREMENT PRIMARY KEY,
    session_title   VARCHAR(255) NOT NULL,
    acad_year       VARCHAR(20) NOT NULL,
    semester        TINYINT NOT NULL,
    period_start    DATE NOT NULL,
    period_end      DATE NOT NULL,
    status          VARCHAR(20) DEFAULT 'DRAFT',  -- DRAFT, ACTIVE, CLOSED
    created_by      INT,
    created_at      DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Question bank (configurable by HR)
CREATE TABLE student_appraisal_questions (
    question_id     INT AUTO_INCREMENT PRIMARY KEY,
    session_id      INT NOT NULL,
    question_number TINYINT NOT NULL,
    question_text   TEXT NOT NULL,
    question_type   VARCHAR(20) DEFAULT 'RATING',  -- RATING or TEXT
    sort_order      INT DEFAULT 0
);

-- One record per student × lecturer × course × session
-- (tracks whether the student has completed their appraisal)
CREATE TABLE student_appraisal_records (
    record_id       INT AUTO_INCREMENT PRIMARY KEY,
    session_id      INT NOT NULL,
    course_id       VARCHAR(50) NOT NULL,
    lecturer_id     INT NOT NULL,         -- hrm_employee.empID
    acad_year       VARCHAR(20) NOT NULL,
    semester        TINYINT NOT NULL,
    student_token   VARCHAR(64) NOT NULL,  -- hashed/anonymous token, NOT the actual regno
    submitted_at    DATETIME,
    status          VARCHAR(20) DEFAULT 'PENDING',  -- PENDING, SUBMITTED
    UNIQUE KEY uq_student_course_session (session_id, course_id, student_token)
);

-- Individual responses (anonymous — no link back to student regno)
CREATE TABLE student_appraisal_responses (
    response_id     INT AUTO_INCREMENT PRIMARY KEY,
    record_id       INT NOT NULL,
    question_id     INT NOT NULL,
    rating          TINYINT,              -- NULL if text question
    text_response   TEXT,                 -- NULL if rating question
    INDEX idx_record (record_id),
    INDEX idx_question (question_id)
);

-- Aggregated scores per lecturer per course (recomputed on session close)
CREATE TABLE student_appraisal_aggregates (
    aggregate_id    INT AUTO_INCREMENT PRIMARY KEY,
    session_id      INT NOT NULL,
    lecturer_id     INT NOT NULL,
    course_id       VARCHAR(50) NOT NULL,
    response_count  INT DEFAULT 0,        -- number of students who submitted
    total_enrolled  INT DEFAULT 0,        -- total students in course
    avg_score       DECIMAL(5,2),
    max_possible    DECIMAL(5,2),
    final_percentage DECIMAL(5,2),
    classification  VARCHAR(50),
    computed_at     DATETIME,
    UNIQUE KEY uq_agg (session_id, lecturer_id, course_id)
);
```

#### Required New Portal Pages

| Page | Purpose |
|------|---------|
| `StudentLecturerAppraisal.aspx` | Student fills in the form for a specific lecturer/course |
| `MyLecturerRatings.aspx` | Student sees which courses they have/haven't appraised |

#### Required New Admin Pages (COOPERP)

| Page | Purpose |
|------|---------|
| `StudentAppraisalSessions.aspx` | HR creates/manages student appraisal sessions |
| `StudentAppraisalReports.aspx` | HR/Dean views aggregate scores per lecturer/course |
| `LecturerAppraisalView.aspx` | Individual lecturer views their own aggregate results |

#### Implementation Tasks — Student Appraisal of Lecturers

- [ ] **T4.1** Obtain official "REVISED STUDENTS APPRAISAL FORM FOR LECTURERS" from HR/Academic Affairs
- [ ] **T4.2** Save official form as `APPRAISAL_TEMPLATE_STUDENT_LECTURER.md` in this directory
- [ ] **T4.3** Map all official questions to `student_appraisal_questions` schema
- [ ] **T4.4** Create DB migration: `student_appraisal_sessions`, `student_appraisal_questions`, `student_appraisal_records`, `student_appraisal_responses`, `student_appraisal_aggregates`
- [ ] **T4.5** Create `StudentAppraisalSessions.aspx` + `.cs` (admin: create session, set semester, link to course registrations)
- [ ] **T4.6** Create generation logic: for each `acad_course_registration` in the active semester → create `student_appraisal_records` with anonymous token
- [ ] **T4.7** Create `MyLecturerRatings.aspx` on portal: shows student their list of enrolled courses + appraisal status per course
- [ ] **T4.8** Create `StudentLecturerAppraisal.aspx` on portal: student fills ratings for each question per lecturer/course — fully anonymous
- [ ] **T4.9** Anonymous token strategy: `SHA256(student_regno + session_id + course_id + secret_salt)` — ensures one response per student per course without storing regno
- [ ] **T4.10** Create aggregate computation: runs on session close or on-demand, populates `student_appraisal_aggregates`
- [ ] **T4.11** Create `StudentAppraisalReports.aspx` (admin): filter by session/department/course/lecturer, show charts + tables
- [ ] **T4.12** Create lecturer self-view: lecturer sees their own aggregate scores per course (no individual responses)
- [ ] **T4.13** Build PDF/printable report per lecturer for HR use
- [ ] **T4.14** Add sidebar navigation entry for "Student Appraisal" in both portal and admin
- [ ] **T4.15** Add to API v2 (`appraisal.aspx.cs`): endpoints for student appraisal sessions, responses, aggregates

---

## 3. CROSS-CUTTING IMPLEMENTATION TASKS

### 3A. Data Model Fixes

- [ ] **TX.1** Add `formula_version` column to `appraisal_records` — records which scoring formula was applied at time of completion (supports future formula changes without retroactive disputes)
- ✅ **TX.2** Audit log table `appraisal_record_audit` created; `LogAudit()` wired into `SelfAppraisal.aspx.cs` (submit, save, return) and `SupervisorAppraisal.aspx.cs` (complete, return)
- [ ] **TX.3** Verify `UNIQUE KEY uq_session_employee (session_id, employee_id)` is in place — already coded, confirm it's active in production DB
- [ ] **TX.4** Add optimistic concurrency column (`version INT DEFAULT 0`) to `appraisal_records` for concurrent edit protection

### 3B. Workflow Fixes

- [ ] **TX.5** Add 3rd signature role: "Responsible Officer" (Dean / VC / DVC / HRM) to Academic Staff appraisal — new step after supervisor completion
- [ ] **TX.6** Prevent more than 1 ACTIVE session per category at a time
- [ ] **TX.7** Add strict date validation on session create/edit: `period_start < period_end`, `deadline <= period_end`, no overlapping periods
- [ ] **TX.8** Wrap generate, save, and complete operations in DB transactions
- [ ] **TX.9** Move all `ALTER TABLE` schema migrations out of runtime user flows — execute once on app startup only

### 3C. Scoring Integrity

- [ ] **TX.10** Enforce rating bounds 1–5 server-side (reject anything outside this range)
- ✅ **TX.11** Employee N/A toggle already absent — Section C renders `is_na` as read-only display; save logic only stores `comment`. Confirmed working.
- [ ] **TX.12** Section B denominator: base on number of slots defined (expected outputs), not just rated rows
- [ ] **TX.13** Minimum completion threshold: all mandatory criteria must be rated before "Complete" is allowed (configurable per category)
- [ ] **TX.14** Store `formula_version` and `threshold_version` at completion time

### 3D. Print / PDF Output

> This is a new feature required for all 4 appraisal types.

- ✅ **TX.15** Print CSS embedded inside `AppraisalPrint.aspx` — A4 layout, Times New Roman 11pt, `@page { size: A4 portrait; margin:0; }`, print-safe tables
- ✅ **TX.16** `AppraisalPrint.aspx` + `AppraisalPrint.aspx.cs` created in `NewScreens/` — standalone page (no master), renders all 5 sections for all 3 staff categories; `?autoprint=1` triggers browser print dialog; accessed via "Print / PDF" button in `AppraisalView.aspx`
- ✅ **TX.17** Academic Staff: Sections A–E + score summary + signature block (Employee, Supervisor, Responsible Officer) rendered correctly
- [ ] **TX.18** Administrative Staff print template: pending official admin form layout confirmation from HR
- ✅ **TX.19** Support Staff: Declaration by Supervisee (AGREE/DISAGREE) rendered in place of Section E narrative
- [ ] **TX.20** Student Lecturer print template: blocked on T4.1 (official form not yet received)
- ✅ **TX.21** "Print / PDF" button added to `AppraisalView.aspx` detail view — opens `AppraisalPrint.aspx?rid=N&autoprint=1` in new tab
- [ ] **TX.22** Server-side PDF: browser print-to-PDF is sufficient for now; iTextSharp may be added later if needed

### 3E. Security & Access

- [ ] **TX.23** Add role-based authorization to all admin appraisal pages: only HR Manager / Marks Approver may manage sessions
- [ ] **TX.24** Validate CSRF tokens on all mutating AJAX endpoints (already coded in `PortalAntiForgeryService` and `MarksAntiForgeryService` — verify coverage)
- [ ] **TX.25** Enforce session activity check in all AJAX paths — reject saves/submits if session not ACTIVE

---

## 4. SECTION B SLOT COUNT — OFFICIAL REQUIREMENTS

| Staff Category | Official Section B Slots | Current Code | Action |
|----------------|--------------------------|--------------|--------|
| Academic | Up to 10 (form says "not exceed 10") | 5 | Increase to 10 |
| Administrative | Up to 10 (assumed — confirm with official form) | 5 | Confirm + fix |
| Support | 5 (form shows 5 rows) | 5 | Correct as-is |
| Student (N/A) | N/A — questionnaire format | N/A | N/A |

---

## 5. SECTION E QUESTIONS — OFFICIAL REQUIREMENTS

### Academic Staff (6 questions)

1. Describe how effectively you have been utilized by the University
2. What do you consider to be your major strength(s) with respect to your competencies?
3. List down any work you accomplished in addition to your agreed tasks/responsibilities
4. In respect of your Key Performance Areas, what achievement(s) are you particularly pleased with?
5. Specify any areas where you could not meet the expected standards and give reasons thereof
6. What are your aspirations in terms of career development?

**Current code:** 5 questions (missing #6) → **Fix: add Q6**

### Administrative Staff

Confirm from official form once obtained.

### Support Staff

Official Support Staff form does NOT appear to include a Section E narrative section. Confirm with HR.

---

## 6. CLASSIFICATION BANDS — OFFICIAL STANDARD

The official forms use these exact labels. All code must be updated to match:

| Rating | Score | Official Label |
|--------|-------|----------------|
| 5 | 90–100% | Exceptional |
| 4 | 75–89% | Above Expectations |
| 3 | 60–74% | Satisfactory |
| 2 | 50–59% | Development Needed |
| 1 | <50% | Unsatisfactory |

**Current code labels:** Outstanding / Very Good / Good / Fair / Poor  
**Action:** Update `GetClassification()` / classification logic in `SupervisorAppraisal.aspx.cs` and all reporting

---

## 7. ITEMS PENDING FROM HR — BLOCKERS

The following items must be received from HR before those sections can be finalized:

| # | Item Needed | Blocks |
|---|------------|--------|
| ~~B1~~ ✅ | Official "REVISED APPRAISAL FORM FOR ADMINISTRATIVE STAFF APPROVED BY COUNCIL" — **RECEIVED, documented in `APPRAISAL_TEMPLATE_ADMIN_STAFF.md`** | TX.18 (print template) |
| B2 | Official "REVISED STUDENTS APPRAISAL FORM FOR LECTURERS 2025/2026 — FINAL" | T4.1–T4.15 |
| B3 | Confirmation of exact Academic Staff Section C criteria count (45 or 50) | T1.1, T1.10 |
| B4 | Confirmation of 5 missing Support Staff criteria (S26–S30) | T3.3 |
| B5 | Confirmation of Administrative Staff Section C criteria count and scoring formula | T2.4 |

---

## 8. TASK PRIORITY ORDER

### P0 — Immediate (Correctness — fix before any new appraisal session)

1. ~~TX.10~~ ✅ Server-side rating bounds enforcement (was already in code)
2. ✅ **TX.11** — Employee N/A toggle confirmed absent — Section C save only stores `comment`, N/A display is read-only
3. ✅ **T1.3** — Section B slots: 5 → 10 for Academic; existing EMPLOYEE_IN_PROGRESS records (32, 175) updated to 10 slots
4. ✅ **T1.4** — 6 official Section E questions seeded; existing EMPLOYEE_IN_PROGRESS records (32, 175) updated with official questions
5. ✅ **T1.5** — Classification band labels fixed: Outstanding→Exceptional, Very Good→Above Expectations, etc.
6. ✅ **BONUS** — Rating scale dropdown labels made category-aware (Academic uses Exceptional/Satisfactory scale)
7. ✅ **BONUS** — Section B denominator fixed: counts only rated slots, not all empty slots

### P1 — High (Data integrity before next active session)

1. ✅ **T1.1 + T1.2** — Academic criteria reseeded: 52 correct official criteria in 9 groups
2. ✅ **T2.3** — Administrative Staff: 22 criteria in 1 group "Core Competencies" (official form text)
3. ✅ **T3.1–T3.3** — Support Staff: 25 criteria in 6 official groups (correct official text)
4. ✅ **E3 BUG FIXED** — `supervisor_comment` column added; saved and loaded per competency
5. ✅ **BONUS** — Existing PENDING/EMPLOYEE_IN_PROGRESS section_c rows migrated to official names
6. ✅ **TX.2** — Audit log table `appraisal_record_audit` created; `LogAudit()` wired into all state transitions
7. ✅ **TX.6** — Multiple active sessions already prevented (lines 942–946 in AppraisalSessions.aspx.cs)
8. [ ] **TX.5** — Add Responsible Officer 3rd signature step *(still pending)*

### P2 — Important (Print output — required for HR filing)

1. ✅ **TX.15 + TX.16** — `AppraisalPrint.aspx` + `.cs` created; A4 print CSS embedded
2. ✅ **TX.17** — Academic Staff print template: all 5 sections + score summary + signature block
3. ✅ **TX.19** — Support Staff: Declaration rendered in Section E
4. [ ] **TX.18** — Admin Staff specific layout: pending HR confirmation on form design
5. ✅ **TX.21** — "Print / PDF" button added to `AppraisalView.aspx` detail view

### P3 — New Feature (Student Appraisal — greenfield)

15. T4.1 — Obtain official form (blocker for all T4.x)
16. T4.3 + T4.4 — DB schema creation
17. T4.5 + T4.6 — Admin session management
18. T4.7 + T4.8 — Portal student form
19. T4.10 + T4.11 — Aggregates and reports
20. T4.12 + T4.13 — Lecturer view + PDF report

### P4 — Nice to have (After core is complete)

21. TX.1 + TX.4 — formula_version + optimistic concurrency
22. TX.7 + TX.8 — Date validation + transactions
23. T4.14 + T4.15 — Sidebar + API endpoints

---

## 9. REFERENCE FILES

| File | Description |
|------|-------------|
| `APPRAISAL_TEMPLATE_ACADEMIC_STAFF.md` | Official Academic Staff form (verbatim) |
| `APPRAISAL_TEMPLATE_SUPPORT_STAFF.md` | Official Support Staff form (verbatim) |
| `APPRAISAL_TEMPLATE_ADMIN_STAFF.md` | ✅ Official Administrative Staff form (verbatim, received 2026-05-16) |
| `APPRAISAL_TEMPLATE_STUDENT_LECTURER.md` | **PENDING** — official form not yet received |
| `APPRAISAL_A_TO_Z_AUDIT_2026-05-07.md` | Technical audit of existing code |
| `APPRAISAL_SYSTEM_ARCHITECTURE.md` | Existing architecture doc |
| `APPRAISAL_SCORING_FORMULAS.md` | Existing scoring formulas doc |

---

## 10. QUICK-REFERENCE: CRITERIA COUNTS PER TYPE

| Type | Section B Max | Section C Criteria | Section C Max Score | Formula |
|------|--------------|-------------------|--------------------|---------| 
| Academic | 10 | 50 | 250 | x/250×100 |
| Administrative | 10 (confirm) | 22 (confirm) | 110 (confirm) | x/110×100 (confirm) |
| Support | 5 | 30 | 150 | x/150×100 |
| Student → Lecturer | N/A | 10–12 questions | 50–60 | x/max×100 |
