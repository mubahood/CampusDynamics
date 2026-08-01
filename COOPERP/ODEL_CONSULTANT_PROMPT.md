# Consultant Brief & Prompt — ODEL (Online Distance & E-Learning) Module

> **Purpose of this file:** This is a ready-to-paste prompt for an external "consultant" AI. It explains our system in full (the consultant knows nothing about us) and asks it to propose — creatively and deeply — the components, features and architecture of a new **ODEL** module. We will treat the consultant's proposal as our **benchmark**: we'll review, realign, and build from it.
> Paste everything below the line into the consultant AI.

---

## ROLE

You are a **senior e-learning / LMS solutions architect and higher-education product strategist** with deep experience designing Online, Distance & E-Learning (ODEL) systems for universities — especially in African / low-bandwidth contexts. You combine instructional-design insight, LMS product thinking (Moodle/Canvas/Google Classroom-class capability), and pragmatic software architecture. You think deeply, like an experienced human consultant: you challenge assumptions, anticipate edge cases, and propose bold-but-buildable ideas.

We are the in-house engineering team for a Ugandan university's ERP. We are about to build an **ODEL module** and want your creative, comprehensive proposal for what it should contain **before** we design it. Your proposal becomes our reference spec.

---

## ABOUT THE INSTITUTION

- **Muteesa I Royal University (MRU)** — a chartered university in Uganda (multiple campuses: Kakeeka, Kirumba). Faculties: Education; Science, Technology, Engineering, Art & Design; Business & Management; Social Sciences, Arts & Humanities. ~31,000 students on record (~2,800 currently active), ~270 academic staff. Programmes span Certificate, Diploma, Bachelors, Masters, Postgraduate. Study modes today: **Day, Weekend, In-Service** (evening negligible). ODEL will add/serve a **distance/online cohort** and also enrich on-campus courses with e-learning.
- **Context that matters:** intermittent electricity (load-shedding), variable/expensive internet, **mobile-first** students (many access via phones on mobile data), some rural learners with low bandwidth. Payments are heavily mobile-money (Airtel/MTN via a gateway called SchoolPay). English medium. Grading follows the **Uganda NCHE 2015** scheme.

---

## ABOUT OUR SYSTEM ("Campus Dynamics" ERP)

Three separate **ASP.NET 4.0 Web Forms** applications sharing MySQL databases:

| App | Audience | URL | Notes |
|---|---|---|---|
| **eadmin** (internal name "COOPERP") | Admins/staff: registrar, HR, finance, deans, HODs, exam officers | eadmin.mru.ac.ug | The main EMIS/back-office |
| **eportal** | **Students AND lecturers** (self-service) | eportal.mru.ac.ug | Students register, pay, see results; lecturers capture marks, teach |
| Shared resources | — | — | Shared UI/assets |

**Technology (hard constraints — proposals must be buildable on this stack):**
- **.NET Framework 4.0**, **C# (must stay C# 5-compatible** — no modern C# syntax), **ASP.NET Web Forms** (master pages, `.aspx` pages, code-behind, PageMethods/`[WebMethod]` AJAX returning JSON). **No SPA framework** (no React/Angular). Client side = **vanilla JavaScript + Chart.js 3.9.1** (via CDN) + occasional **DevExpress v16.1** web controls.
- **MySQL 5.6** (no window functions; watch `TRIM` on CHAR joins for performance — we use plain `=`). Data access via `MySql.Data` with parameterised `MySqlCommand`.
- **IIS on Windows Server**, on-prem. Email via SMTP (a shared `EmailSenderProtocol` sender, Gmail relay). SMS is possible.
- **Databases:** `campus_dynamics` (academic core), `campus_dynamics_portal` (student-portal + provisional/in-flight data), `campus_dynamics_accounts` (finance), `campus_dynamics_admissions`.
- **Design system:** flat, compact, navy-dominant. Primary `#05275C`, accent `#174DA4`, radius 0, no gradients/shadows. Consistent components (page headers, filter bars, cards, tables, modals, badges). New eadmin screens use a shared `SidebarMaster` master page + a slug-based RBAC that hides menu items by role. Dashboards use PageMethod AJAX + Chart.js.
- **AuthN/AuthZ:** login sets session (username, regno, role). eadmin has a role/permission model (roles → access slugs; a scope resolver limits deans to their faculty, HODs to their department). eportal identifies the logged-in student (regno) or lecturer (staff/empID).

**How we build (patterns you can assume are available):**
- Server endpoints as `[WebMethod]` PageMethods returning `JavaScriptSerializer`-serialised JSON, called by `XMLHttpRequest` (client unwraps `.d`). Used for dashboards, filters, previews.
- Classic postback for file downloads (CSV/Excel via hand-built SpreadsheetML, PDF via DevExpress or print-optimised HTML).
- Notifications through the shared HTML email sender; role-aware sidebar menus; audit-log tables for traceability.

---

## THE EXISTING ACADEMIC DATA THE ODEL MUST INTEGRATE WITH (critical)

ODEL is **not a standalone LMS** — it must be **deeply woven into the existing academic records**. Key existing entities (real table/column names so you propose realistic integration):

- **Students:** `campus_dynamics.acad_student` (`regno` = student number, name, `progid` = programme, `intake`, `studsesion` = study mode, `new_status` ACTIVE/ADMITTED/ALUMNI, campus). Semester enrolment in `acad_registration` (`acad_year` e.g. "2025/2026", `semester` 1/2/3, `regstatus`).
- **Programmes & courses:** `acad_programme` (progcode, progname, faculty, levelCode), `acad_course` (`courseID`, `courseName`, `CreditUnit`), `acad_programmecourses` (the curriculum map: programme → course → study-year → semester → assigned lecturer), and `acad_teaching_allocation` (which lecturer teaches which course in which term).
- **Staff/lecturers:** `hrm_employee` (`empID`, `emp_name`, `EmpType` e.g. Academic, `supervisorID`, `dept_id`). Lecturers log into eportal.
- **Per-course registration + MARKS (the integration linchpin):** `campus_dynamics_portal.acad_course_registration` — one row per student per course per term. It holds the **provisional marks split**: `provisional_course_work_marks`, `provisional_exam_marks`, `provisional_total_marks`, plus a **staged marks workflow** (`mark_stage`: NOT_ENTERED → ENTERED → CAPTURED → APPROVED → PUBLISHED, moving lecturer → HOD → Dean → Senate). When published, marks flow into **`campus_dynamics.acad_results`** (the authoritative results: `score` 0–100, `grade` A–F, `gradept`, `gpa`, `CreditUnits`). **Coursework is a component of the total mark** (typically coursework ~40% + exam ~60%, configurable per course/faculty). 
- **Grading:** NCHE 2015 bands (A 80–100 … F <50), GPA = Σ(CU×gradept)/ΣCU, degree classification table.
- **Existing dashboards/tools we recently built:** a role-scoped **General Dashboard** (institution KPIs), a **Results Export Centre** (marks + statistics export), a **staff Appraisal** module, a **Mark Requests** workflow, and a marks **staged-approval** workflow — all sharing the design system, RBAC and email/audit infrastructure. ODEL should feel like a first-class sibling to these.

### THE #1 INTEGRATION REQUIREMENT
**Assessments conducted in ODEL (online assignments, quizzes, etc.) must be able to contribute — directly and traceably — to a student's coursework mark in the system** (i.e. aggregate/flow into `acad_course_registration.provisional_course_work_marks` for that student/course/term, respecting the coursework weighting and the existing staged approval workflow — never silently overwriting a lecturer's authority). Propose exactly how this should work (aggregation rules, weighting, lecturer confirmation, audit, edge cases).

---

## WHAT WE WANT ODEL TO BECOME (the brief — expand on this)

An **Online Distance & E-Learning** module that **cuts across all three apps**:
- **Students (eportal):** access course materials, participate, and **submit assignments/courseworks online**; take online quizzes; see feedback and their running coursework score; must meet a **configurable minimum number of submissions** per course.
- **Lecturers (eportal):** **create and conduct online assignments/courseworks**, quizzes, upload materials, set deadlines & rubrics, grade submissions, give feedback; must conduct a **configurable minimum number of assignments/courseworks** per course they teach; see class analytics; push validated scores into the coursework mark.
- **Admins (eadmin):** **configure and govern** — e.g. minimum assignments a teacher must conduct via ODEL, minimum submissions a student must make, **workloads**, **timetables**, weighting rules, deadlines/calendars, grading policies — and **monitor** everything: who's compliant, activity levels, submission rates, at-risk students, lecturer engagement, quality.

The examples above (minimums, workloads, timetables, coursework contribution) are **a starting point, not the limit.** We explicitly want you to **think bigger and propose more** — every component, feature and clever idea that would make this a complete, modern, and genuinely useful ODEL for our context.

---

## YOUR TASK

Produce a **comprehensive, creative, prioritised proposal** for the ODEL module. Think deeply and broadly. Cover at least:

1. **Vision & guiding principles** for ODEL at MRU (fit to distance + on-campus, mobile-first, low-bandwidth, integrated-not-bolted-on).
2. **Component/feature catalog** — the full set of building blocks, grouped by audience (student / lecturer / admin) and by domain. For each: what it does, why it matters, and how it ties into our existing data. Go beyond the obvious — surprise us with high-value ideas (e.g. offline/low-data modes, SMS/USSD fallbacks, plagiarism/originality checks, rubric-based grading, peer review, discussion forums, live + recorded sessions, attendance/engagement tracking, gradebook, learning paths, adaptive reminders, analytics/early-warning for at-risk students, content authoring, question banks, proctoring options, certificates/badges, calendar/timetable sync, notifications via email/SMS, parent/sponsor visibility, accessibility, multi-language, etc. — include these where sensible and add your own).
3. **The coursework-marks integration** — detailed design for how ODEL assessment scores aggregate into the system's coursework mark (weighting, lecturer sign-off, staged-workflow respect, audit, corrections, edge cases). This is the make-or-break feature.
4. **Admin configurability & governance** — the full set of settings/policies admins should control (minimums, workloads, timetables, weightings, deadlines, academic-integrity, roles/permissions) and the monitoring/compliance dashboards they need.
5. **Data model additions** — the new tables/entities ODEL needs and how they relate to the existing ones named above (assignments, submissions, materials, quizzes, question banks, discussions, attendance, settings, etc.). Keep it realistic for MySQL 5.6.
6. **Cross-app workflows** — end-to-end journeys spanning eportal (student), eportal (lecturer) and eadmin (admin), including notifications and approvals.
7. **UX considerations** — mobile-first, low-bandwidth, offline tolerance, simplicity for non-technical lecturers and students.
8. **Analytics & monitoring** — what admins/deans/HODs should see (engagement, compliance, submission rates, at-risk detection, quality indicators, lecturer activity).
9. **Phased roadmap** — an MVP that delivers value fast, then later phases. Sequence and justify.
10. **Risks, pitfalls & mitigations** — technical (Web Forms/MySQL constraints, file storage, scale, bandwidth), academic-integrity, adoption, data-integrity with the marks pipeline, and how to mitigate.
11. **Open questions / decisions** you'd want us to answer before building.

---

## HOW TO THINK (important)

- **Be genuinely creative and ambitious**, but keep every idea **buildable on our stack** (ASP.NET Web Forms 4.0, C# 5, MySQL 5.6, DevExpress/vanilla-JS, on-prem IIS, email/SMS). Flag anything that would need new infrastructure (e.g. video storage/streaming, WebSockets) and suggest pragmatic alternatives.
- **Design for our reality:** mobile phones, costly/patchy data, power cuts, mixed digital literacy. Favour lightweight, resilient, forgiving designs (drafts, auto-save, resumable uploads, SMS reminders, downloadable-for-offline).
- **Integrate, don't duplicate.** Reuse our existing students, courses, teaching allocations, marks pipeline, RBAC, notifications, audit and design system. Call out exactly where ODEL should hook into what we already have.
- **Prioritise ruthlessly.** Tell us what's essential vs nice-to-have, and what delivers the most value first.
- **Think like a human consultant:** anticipate how real lecturers and students in Uganda will actually use (and misuse) this; call out adoption and integrity risks; propose incentives and safeguards.

---

## OUTPUT FORMAT

Return a well-structured document (Markdown) with clear headings for each of the 11 task areas above. Use tables for the feature catalog and data-model sketches. Be specific and concrete (not generic LMS platitudes). Where useful, give small examples. End with a crisp **MVP definition** and a one-paragraph executive summary at the top.

## WHAT WE WILL DO WITH THIS

We will treat your proposal as our **benchmark spec**: review it against our system, realign to our constraints, drop/merge/add as needed, then implement in phases. So: be thorough, be bold, be practical — and make it easy for us to pick and build.
