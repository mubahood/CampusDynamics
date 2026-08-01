# How the Classic System Processes Course Codes

A plain-language map of how a course code (e.g. `FND1205B`, `FIN1202B`, `BSA1101`) is
created, stored, validated, and used across the classic Campus Dynamics system
(main system + student portal). Verified against code **and** the live database
(2026-06-30).

---

## 1. What a course code actually is

A course code is treated as an **opaque text identifier** — a label, nothing more.

- The 3-letter prefix + digits + optional trailing letter (`FND` `1` `2` `05` `B`) is a
  **human naming convention only**. The system does **not** parse it to work out the
  programme, year, or semester.
- Proof: `MMC5101` lives in the curriculum as **study_year = 2**, not "5". The digits
  in the code are not authoritative.
- The authoritative year/semester come from **columns**, not from the code (see §3).

> **Rule of thumb:** never derive meaning by slicing a course code. Always read the
> related columns (`study_year`, `semester`, `progcode`, `CreditUnit`).

---

## 2. The life of a course code (the flow)

```
acad_course               →  acad_programmecourses   →  acad_course_registration  →  acad_results
(master catalog)             (curriculum: which          (student actually            (final marks /
 courseID + name + CU)        course for which            registered for the           transcript per
                              programme/year/sem)         course this period)          student+course)
```

1. **Catalog** — every course exists once in `acad_course` (`courseID`, `courseName`, `CreditUnit`).
2. **Curriculum** — `acad_programmecourses` maps a course to a programme + study year +
   semester (`progcode`, `course_code`, `study_year`, `semester`, `course_type` CORE/ELECTIVE).
3. **Registration** — when a student registers, a row is inserted into
   `campus_dynamics_portal.acad_course_registration` (`regno`, `courseID`, `prog_id`,
   `acad_year`, `semester`, `course_status='REGULAR'`).
4. **Results** — when marks are published, the code keys the row in `acad_results`
   (`regno`, `courseid`, `acad`, `semester`, `studyyear`, `score`, `grade`, `gradept`, `CreditUnits`).

Joins between these tables are done **by the code string**, almost always wrapped in
`TRIM()` / `UPPER()` because of dirty data (see §6).

---

## 3. Where course codes live (tables & columns)

| Table | Column | Role |
|---|---|---|
| `campus_dynamics.acad_course` | `courseID` (char 25) | **Master catalog** — the canonical list of courses |
| `campus_dynamics.acad_course` | `courseName`, `CreditUnit` (double) | Display name + credit units |
| `campus_dynamics.acad_programmecourses` | `course_code` (char 15) | Course in a programme's curriculum |
| `campus_dynamics.acad_programmecourses` | `progcode`, `study_year`, `semester`, `course_type` | **Authoritative** programme / year / semester / CORE-ELECTIVE |
| `campus_dynamics_portal.acad_course_registration` | `courseID` (char 25) | The course a student registered for |
| `campus_dynamics_portal.acad_course_registration` | `regno`, `prog_id`, `acad_year`, `semester`, `course_status` | Who / which period / status |
| `campus_dynamics.acad_results` | `courseid` (char 25), `CreditUnits` | Final mark per student+course+period |
| `campus_dynamics.acad_teaching_allocation` / `acad_teaching_assignments` | `courseID` / `course_id` | Lecturer ↔ course |

Other tables that key on the code: `acad_marks_requests`, `acad_marks_audit`,
`acad_results_complaints`, `acad_examsettings`, `acad_coursework_settings`,
`acad_exam_timetable`, `acad_transcript_results`.

---

## 4. Registration flow (classic)

**Main pages / controls**
- Portal (student self-service): `CampusDynamics_Portal/CourseRegistration.aspx`
- Portal logic: `CampusDynamics_Portal/App_Code/Portal/StudentCourseRegistrationController.cs`
- Admin bulk: `CampusDynamics_Portal/App_Code/Portal/AdminCourseRegistrationController.cs`
- Classic main system: `COOPERP/UserControls/Timetables/CourseRegistration.ascx` (calls SP `acad_CourseRegister`)

**Steps**
1. **Context** — read the student's `progid` / `studyyear` / `semester` from `acad_registration`.
2. **Available courses** — list curriculum courses for that context:
   ```sql
   SELECT DISTINCT pc.course_code,
          IFNULL(c.courseName, pc.course_code) AS course_name,
          pc.study_year, pc.semester
   FROM acad_programmecourses pc
   LEFT JOIN acad_course c ON c.courseID = pc.course_code
   WHERE pc.progcode = @p AND pc.study_year = @y AND pc.semester = @s
   ```
3. **Availability check** — course must exist in the curriculum and not be already registered.
4. **Insert** — `INSERT INTO acad_course_registration (regno, courseID, prog_id, acad_year, semester, course_status, ...) VALUES (..., 'REGULAR', ...)`.
5. **Drop** — `DELETE ... WHERE TRIM(regno)=@r AND acad_year=@a AND semester=@s AND UPPER(TRIM(courseID))=@c`.

---

## 5. Marks & results keyed by course code

- Marks live first against the registration row (`acad_course_registration`), then are
  **published** into `acad_results` via an UPSERT keyed by
  `(regno, courseid, acad, semester, studyyear)`.
- The code is the join key from registration → results:
  ```sql
  ... WHERE ar.regno = cr.regno AND ar.courseid = cr.courseID
        AND ar.semester = cr.semester AND ar.acad = cr.acad_year
  ```
- See `App_Code/Marks/MarksControllerShared.cs` for the publish/UPSERT logic, and the
  staged marks workflow doc `COOPERP/MARKS_STAGED_WORKFLOW_PLAN.md`.

---

## 6. Validation & normalization (important)

Because the source data is dirty, the system normalizes course codes everywhere:

| Rule | What it does | Example |
|---|---|---|
| **Trim** | strip leading/trailing spaces | `" BAG2101B"` → `"BAG2101B"` |
| **Upper-case** | case-insensitive matching | `fin1202b` → `FIN1202B` |
| **Max length** | cap at 30 chars on input | `code.Substring(0, 30)` |
| **Dedup** | case-insensitive set on bulk register | `HashSet<string>(OrdinalIgnoreCase)` |
| **DB uniqueness** | one registration per course/period | unique `(regno, courseID, acad_year, semester, course_status)` |
| **Name fallback** | show code if name missing | `COALESCE(courseName, courseID)` |

Reference: `StudentCourseRegistrationController.NormalizeCourseCodes()` (Trim + Substring(0,30) + ToUpperInvariant + HashSet).

### Known data-quality gotchas (verified in DB)
- **Leading spaces** in `acad_course.courseID` (19 of 6,911 rows) — always `TRIM()` before joining.
- **Inconsistent variants** of the "same" course: e.g. `FND1101B` **and** `FND 1101`
  (space) both appear in registrations. Spacing/trailing-letter differences make codes
  that look identical fail an exact join — this is why every comparison uses `UPPER(TRIM(...))`.
- **Empty `course_code`** rows exist in `acad_programmecourses`.

---

## 7. Credit Units (CU)

CU is attached at two levels and resolved at runtime:

1. **Catalog** — `acad_course.CreditUnit`. When publishing marks the system reads:
   `SELECT COALESCE(NULLIF(<creditCol>,0), 3) FROM acad_course WHERE courseID=@c` —
   i.e. **defaults to 3** if missing/zero.
2. **Per result** — `acad_results.CreditUnits` (can differ per attempt / retake).
3. **GPA** — `App_Code/AcademicEngine.cs ComputeGPA()` uses `CreditUnits`; a row with
   **CU = 0 is excluded** from the GPA.

> The code even tolerates differently-named CU columns (`CreditUnits`, `creditunits`,
> `credit_units`, `cu`, …) by detecting the actual column at runtime.

---

## 8. Schema-adaptive behaviour (why the code looks defensive)

The classic system detects schema at runtime instead of hard-coding column names:
- Course-code column on registration: prefers `courseID`, falls back to `course_code`.
- CU column: tries 6 spellings; can **auto-create** `acad_results.CreditUnits` if absent.

This lets the same code run against slightly different DB versions — but it's also why
queries are verbose.

---

## 9. Key files (quick reference)

| File | Role |
|---|---|
| `CampusDynamics_Portal/App_Code/Portal/StudentCourseRegistrationController.cs` | Student registration: context, available courses, register, drop, normalize |
| `CampusDynamics_Portal/App_Code/Portal/AdminCourseRegistrationController.cs` | Admin bulk registration, insert, lecturer course lookups |
| `CampusDynamics/App_Code/Marks/MarksControllerShared.cs` | Marks → `acad_results`, course-column & CU resolution |
| `CampusDynamics/App_Code/AcademicEngine.cs` | GPA / classification (uses CreditUnits) |
| `CampusDynamics_Portal/CourseRegistration.aspx` | Student portal registration screen |
| `CampusDynamics/COOPERP/UserControls/Timetables/CourseRegistration.ascx` | Classic main-system registration (SP `acad_CourseRegister`) |
| `CampusDynamics/API/v2/academic.aspx.cs` | REST endpoints for course lookups |

---

## TL;DR
- A course code is an **opaque string**; its letters/digits are a naming convention, not data.
- Catalog (`acad_course`) → curriculum (`acad_programmecourses`, which holds the real
  year/semester) → registration (`acad_course_registration`) → results (`acad_results`),
  all joined **by the code string** using `TRIM()`/`UPPER()`.
- Always normalize (`TRIM` + `UPPER`) before comparing; the data has stray spaces and
  spacing variants. CU comes from `acad_course` (default 3) and drives GPA.
