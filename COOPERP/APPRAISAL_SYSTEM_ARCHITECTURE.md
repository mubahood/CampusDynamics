# Performance Appraisal System — Architecture & Workflow

> **Muteesa I Royal University — Campus Dynamics**
> System design reference for the digital Performance Appraisal Module

---

## Table of Contents

1. [System Overview](#system-overview)
2. [Workflow Stages](#workflow-stages)
3. [Database Schema Design](#database-schema-design)
4. [Admin Module Pages](#admin-module-pages)
5. [Portal Module Pages](#portal-module-pages)
6. [Role Matrix](#role-matrix)
7. [Status Machine](#status-machine)
8. [Notification Flow](#notification-flow)
9. [Report Generation](#report-generation)
10. [UI/UX Specifications](#uiux-specifications)

---

## 1. System Overview

The Performance Appraisal Module digitises the paper-based appraisal process into a structured, tracked, and auditable workflow spanning two applications:

| Application | Purpose | Users |
|-------------|---------|-------|
| **CampusDynamics** (Admin) | Session management, monitoring dashboard, report generation | HR Officers, Supervisors (admin view) |
| **CampusDynamics_Portal** (Portal) | Self-appraisal wizard, supervisor appraisal wizard | Employees, Supervisors |

### Design Principles

- **Step-by-step wizard screens** — Clean, guided, one-section-at-a-time experience
- **Perfect branding** — All generated reports follow university design templates
- **Complete dashboard** — Real-time monitoring of individual + overall progress
- **Independent session model** — Each appraisal period is a self-contained session with its own configurations

---

## 2. Workflow Stages

```
┌─────────────────────────────────────────────────────────────────────┐
│                        APPRAISAL LIFECYCLE                          │
│                                                                     │
│  ┌──────────┐    ┌──────────────┐    ┌──────────────┐              │
│  │ 1. HR    │───>│ 2. Generate  │───>│ 3. Notify    │              │
│  │ Creates  │    │ Individual   │    │ Employees    │              │
│  │ Session  │    │ Appraisals   │    │ via Portal   │              │
│  └──────────┘    └──────────────┘    └──────┬───────┘              │
│                                             │                       │
│  ┌──────────────────────────────────────────▼───────────────────┐  │
│  │ 4. EMPLOYEE SELF-APPRAISAL (Portal — Wizard)                │  │
│  │    Step 1: Confirm Personal Info (Section A)                 │  │
│  │    Step 2: Agreed Outputs — Self-Rating (Section B)          │  │
│  │    Step 3: Reflections & Comments (Section E Questions)      │  │
│  │    Step 4: Review & Submit                                   │  │
│  └──────────────────────────────┬───────────────────────────────┘  │
│                                 │                                   │
│  ┌──────────────────────────────▼───────────────────────────────┐  │
│  │ 5. SUPERVISOR APPRAISAL (Portal — Wizard)                   │  │
│  │    Step 1: Review Employee's Self-Assessment                 │  │
│  │    Step 2: Rate Section B — Level of Achievement             │  │
│  │    Step 3: Rate Section C — Core Competencies                │  │
│  │    Step 4: Action Plan (Section D)                           │  │
│  │    Step 5: Final Comments & Submit                           │  │
│  └──────────────────────────────┬───────────────────────────────┘  │
│                                 │                                   │
│  ┌──────────────────────────────▼───────────────────────────────┐  │
│  │ 6. COMPLETION                                                │  │
│  │    - Scores computed automatically                           │  │
│  │    - Status marked COMPLETED                                 │  │
│  │    - HR notified                                             │  │
│  └──────────────────────────────┬───────────────────────────────┘  │
│                                 │                                   │
│  ┌──────────────────────────────▼───────────────────────────────┐  │
│  │ 7. HR MONITORING & REPORTING                                 │  │
│  │    - Dashboard: progress bars, stats, overdue alerts         │  │
│  │    - Individual appraisal report (branded PDF)               │  │
│  │    - General/aggregate report with export                    │  │
│  └──────────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────┘
```

### Stage Details

| # | Stage | Actor | Location | Description |
|---|-------|-------|----------|-------------|
| 1 | **Create Session** | HR Officer | Admin | Create a new appraisal session/instance with: title, period (start/end dates), target staff categories, deadline, description |
| 2 | **Generate Appraisals** | HR Officer / System | Admin | Auto-generate individual appraisal records for all eligible employees (based on `to_be_appraised = 1` and staff category match). Links each record to the session. |
| 3 | **Notify Employees** | System | Auto | Alert employees on portal that their appraisal is pending. Dashboard notification + optional email. |
| 4 | **Employee Self-Appraisal** | Employee | Portal | Step-by-step wizard: confirm personal info → self-rate Section B outputs → write reflections → review & submit. |
| 5 | **Supervisor Appraisal** | Supervisor | Portal | After employee submits, appraisal appears in supervisor's queue. Wizard: review self-assessment → rate Section B → rate Section C → write action plan → submit. |
| 6 | **Completion** | System | Auto | Final score calculated. Both parties have submitted. Status → COMPLETED. |
| 7 | **Monitoring & Reports** | HR Officer | Admin | Dashboard shows real-time progress. Generate individual branded reports. Export aggregate data. |

---

## 3. Database Schema Design

### Table: `appraisal_sessions`

The independent session model — each appraisal period is a distinct record.

| Column | Type | Description |
|--------|------|-------------|
| `session_id` | INT AUTO_INCREMENT PK | Unique session identifier |
| `session_title` | VARCHAR(255) | e.g., "Annual Performance Appraisal 2024/2025" |
| `session_description` | TEXT | Details about this appraisal period |
| `period_start` | DATE | Assessment period start date |
| `period_end` | DATE | Assessment period end date |
| `deadline` | DATE | Submission deadline |
| `target_categories` | VARCHAR(255) | Comma-separated: "ACADEMIC,ADMINISTRATIVE,SUPPORT" |
| `status` | ENUM('DRAFT','ACTIVE','CLOSED','ARCHIVED') | Session lifecycle status |
| `created_by` | INT | FK → hrm_employee.empID |
| `created_at` | DATETIME | Creation timestamp |
| `updated_at` | DATETIME | Last modification timestamp |

### Table: `appraisal_records`

One record per employee per session — the core appraisal instance.

| Column | Type | Description |
|--------|------|-------------|
| `record_id` | INT AUTO_INCREMENT PK | Unique appraisal record |
| `session_id` | INT FK | Links to appraisal_sessions |
| `employee_id` | INT FK | FK → hrm_employee.empID |
| `reviewer_id` | INT FK | FK → hrm_employee.empID (supervisor) |
| `staff_category` | ENUM('ACADEMIC','ADMINISTRATIVE','SUPPORT') | Determines form type and Y constant |
| `status` | ENUM('PENDING','EMPLOYEE_IN_PROGRESS','EMPLOYEE_SUBMITTED','SUPERVISOR_IN_PROGRESS','SUPERVISOR_SUBMITTED','COMPLETED','CANCELLED') | Appraisal progress status |
| `employee_submitted_at` | DATETIME NULL | When employee submitted self-appraisal |
| `supervisor_submitted_at` | DATETIME NULL | When supervisor submitted their appraisal |
| `section_b_self_total` | DECIMAL(5,2) NULL | Employee's self-rating total (Section B) |
| `section_b_supervisor_total` | DECIMAL(5,2) NULL | Supervisor's rating total (Section B) |
| `section_c_total` | DECIMAL(5,2) NULL | Supervisor's competency rating total (Section C) |
| `raw_score` | DECIMAL(5,2) NULL | X = section_b_supervisor_total + section_c_total |
| `max_possible` | DECIMAL(5,2) NULL | Y adjusted (accounting for N/A) |
| `final_percentage` | DECIMAL(5,2) NULL | (X / Y_adjusted) × 100 |
| `classification` | VARCHAR(50) NULL | Exceptional / Very Good / Good / Fair / Unsatisfactory |
| `created_at` | DATETIME | Record creation timestamp |
| `updated_at` | DATETIME | Last modification timestamp |

### Table: `appraisal_section_b`

Individual output/achievement entries (Section B).

| Column | Type | Description |
|--------|------|-------------|
| `entry_id` | INT AUTO_INCREMENT PK | Unique entry |
| `record_id` | INT FK | Links to appraisal_records |
| `slot_number` | TINYINT | 1–8 (or 1–5 for Support) |
| `agreed_output` | TEXT | Key duties & outputs agreed upon |
| `performance_indicators` | TEXT | Indicators and targets |
| `result_areas` | TEXT | Agreed level / result areas |
| `self_rating` | TINYINT NULL | Employee's self-rating (1–5) |
| `supervisor_rating` | TINYINT NULL | Supervisor's rating (1–5) |
| `comments` | TEXT NULL | Comments on performance |

### Table: `appraisal_section_c`

Competency ratings (Section C) — one row per competency per appraisal.

| Column | Type | Description |
|--------|------|-------------|
| `entry_id` | INT AUTO_INCREMENT PK | Unique entry |
| `record_id` | INT FK | Links to appraisal_records |
| `competency_code` | VARCHAR(10) | e.g., "C1.1", "C2.3" — matches form reference |
| `competency_name` | VARCHAR(255) | Display name of the competency |
| `category_name` | VARCHAR(100) | Parent category (e.g., "Teaching Function") |
| `rating` | TINYINT NULL | Supervisor's rating (1–5 or NULL for N/A) |
| `is_na` | TINYINT(1) DEFAULT 0 | 1 if marked N/A |
| `comment` | TEXT NULL | Supervisor's comment |

### Table: `appraisal_section_d`

Action plan entries.

| Column | Type | Description |
|--------|------|-------------|
| `entry_id` | INT AUTO_INCREMENT PK | Unique entry |
| `record_id` | INT FK | Links to appraisal_records |
| `performance_gap` | TEXT | Identified gap |
| `agreed_action` | TEXT | Remedial action agreed |
| `time_frame` | VARCHAR(100) | Timeline for action |

### Table: `appraisal_section_e`

Comments and reflections.

| Column | Type | Description |
|--------|------|-------------|
| `entry_id` | INT AUTO_INCREMENT PK | Unique entry |
| `record_id` | INT FK | Links to appraisal_records |
| `question_number` | TINYINT | 1–6 |
| `question_text` | TEXT | The reflection question |
| `response` | TEXT NULL | Employee's written response |

### Table: `appraisal_competency_templates`

Master list of competencies per staff category — used to auto-populate Section C.

| Column | Type | Description |
|--------|------|-------------|
| `template_id` | INT AUTO_INCREMENT PK | Unique template entry |
| `staff_category` | ENUM('ACADEMIC','ADMINISTRATIVE','SUPPORT') | Which category |
| `competency_code` | VARCHAR(10) | Unique code (C1.1, C2.3, etc.) |
| `category_name` | VARCHAR(100) | Parent category heading |
| `competency_name` | VARCHAR(255) | Competency display name |
| `description` | TEXT | Full description of the competency |
| `sort_order` | INT | Display ordering |

---

## 4. Admin Module Pages

Located under: `CampusDynamics/HumanResource/`

### 4.1 Appraisal Sessions Manager (`AppraisalSessions.aspx`)

**Purpose:** Create, manage, and monitor appraisal sessions.

**Features:**
- Grid of all sessions (title, period, deadline, status, progress %)
- Create New Session modal (title, description, period dates, deadline, target categories)
- Activate / Close / Archive session actions
- "Generate Appraisals" button — bulk-creates individual records for eligible employees
- Progress bar showing completion rate per session

### 4.2 Appraisal Dashboard (`AppraisalDashboard.aspx`)

**Purpose:** Comprehensive monitoring dashboard for HR.

**Features:**
- **Summary Cards:** Total employees, appraised, pending, overdue, completed %
- **Stats by Category:** Academic / Administrative / Support breakdown
- **Stats by Department:** Department-level completion rates
- **Progress Timeline:** Visual timeline of appraisal period with milestones
- **Overdue Alerts:** List of employees past deadline
- **Score Distribution:** Histogram / chart of final percentages
- **Quick Actions:** Send reminders, export data, generate reports
- **Filters:** By session, department, category, status

### 4.3 Individual Appraisal Viewer (`AppraisalView.aspx`)

**Purpose:** View and generate reports for individual appraisal records.

**Features:**
- Full read-only view of completed appraisal (all sections A–E)
- Score breakdown visualization
- Print / Export as branded PDF
- Comparison view (self-rating vs supervisor rating for Section B)
- Action plan tracking

### 4.4 Appraisal Reports (`AppraisalReports.aspx`)

**Purpose:** Aggregate reporting and data export.

**Features:**
- General report with filters (session, department, category, date range)
- Export to Excel / CSV
- Score distribution charts
- Department ranking tables
- Year-over-year comparison (when multiple sessions exist)

---

## 5. Portal Module Pages

Located under: `CampusDynamics_Portal/`

### 5.1 Employee Self-Appraisal Wizard (`SelfAppraisal.aspx`)

**Purpose:** Step-by-step guided form for employee self-assessment.

**Wizard Steps:**

| Step | Title | Content |
|------|-------|---------|
| 1 | **Personal Information** | Pre-populated Section A from profile. Employee confirms / updates. Read-only fields from HR system. |
| 2 | **Key Outputs & Self-Rating** | Section B table: Employee enters agreed outputs, performance indicators, targets, result areas, and self-rates each (1–5). Up to 8 slots (5 for Support). |
| 3 | **Reflections** | Section E questions (1–6). Text areas for each reflection question. |
| 4 | **Review & Submit** | Full summary of everything entered. Confirm and submit. After submission, status → EMPLOYEE_SUBMITTED. |

**UX Requirements:**
- Clean, modern card-based layout
- Progress indicator (Step 1 of 4, Step 2 of 4, etc.)
- Save Draft functionality (can come back later)
- Validation before each step transition
- Mobile-responsive

### 5.2 Supervisor Appraisal Wizard (`SupervisorAppraisal.aspx`)

**Purpose:** Step-by-step guided form for supervisor to appraise their subordinate.

**Wizard Steps:**

| Step | Title | Content |
|------|-------|---------|
| 1 | **Review Employee Info & Self-Assessment** | Read-only view of employee's Section A and their self-ratings from Section B. Sets context for the appraisal conversation. |
| 2 | **Rate Level of Achievement** | Section B: Supervisor enters their own rating (1–5) for each agreed output alongside the employee's self-rating (read-only comparison column). Comments field per row. |
| 3 | **Rate Core Competencies** | Section C: Full competency grid specific to staff category. Supervisor rates each competency (1–5 or N/A). Comment field per competency. Running total displayed. |
| 4 | **Action Plan** | Section D: Supervisor identifies performance gaps and agrees on actions. Rows for gap, action, timeframe. |
| 5 | **Final Comments & Submit** | Supervisor's overall comments. Review score summary. Confirm and submit. Status → COMPLETED. |

**UX Requirements:**
- Same clean wizard style as employee form
- Side-by-side comparison where applicable (self-rating vs supervisor rating)
- Auto-calculated running totals and percentage
- Draft save capability
- Queue view: list of employees pending supervisor appraisal

### 5.3 Appraisal Queue / My Appraisals (`MyAppraisals.aspx`)

**Purpose:** Dashboard for portal users showing their appraisal activities.

**For Employees:**
- Current appraisal status (Pending / In Progress / Submitted / Completed)
- Link to start/continue self-appraisal
- View completed appraisal results (after supervisor submits)
- Historical appraisals

**For Supervisors:**
- Count of employees pending appraisal
- List of subordinates with status indicators
- Link to start/continue each supervisor appraisal
- Completed appraisals summary

---

## 6. Role Matrix

| Action | Employee | Supervisor | HR Officer |
|--------|----------|------------|------------|
| Fill Section A (Personal Info) | ✓ Confirm | Read-only | Read-only |
| Self-Rate Section B | ✓ Rate | Read-only | Read-only |
| Rate Section B (Official) | — | ✓ Rate | Read-only |
| Rate Section C (Competencies) | — | ✓ Rate | Read-only |
| Fill Section D (Action Plan) | — | ✓ Fill | Read-only |
| Fill Section E (Reflections) | ✓ Fill | Read-only | Read-only |
| Section E (Comments) | — | ✓ Fill | Read-only |
| Create Appraisal Session | — | — | ✓ |
| Generate Individual Appraisals | — | — | ✓ |
| View Dashboard | — | Own team | ✓ All |
| Generate Reports | — | Own team | ✓ All |
| Export Data | — | — | ✓ |
| Send Reminders | — | — | ✓ |

---

## 7. Status Machine

```
PENDING
  │
  ├──> EMPLOYEE_IN_PROGRESS  (employee opens wizard)
  │         │
  │         ├──> EMPLOYEE_SUBMITTED  (employee completes & submits)
  │         │         │
  │         │         ├──> SUPERVISOR_IN_PROGRESS  (supervisor opens wizard)
  │         │         │         │
  │         │         │         ├──> COMPLETED  (supervisor submits → scores computed)
  │         │         │         │
  │         │         │         └──> SUPERVISOR_IN_PROGRESS  (draft saved, return later)
  │         │         │
  │         │         └──> EMPLOYEE_SUBMITTED  (waiting for supervisor)
  │         │
  │         └──> EMPLOYEE_IN_PROGRESS  (draft saved, return later)
  │
  └──> CANCELLED  (HR cancels the appraisal)
```

### Status Descriptions

| Status | Description | Who Can Transition |
|--------|-------------|-------------------|
| `PENDING` | Appraisal generated, waiting for employee to begin | System (auto on generate) |
| `EMPLOYEE_IN_PROGRESS` | Employee has started but not yet submitted | Employee |
| `EMPLOYEE_SUBMITTED` | Employee self-appraisal complete, in supervisor queue | Employee → System |
| `SUPERVISOR_IN_PROGRESS` | Supervisor has started reviewing/rating | Supervisor |
| `COMPLETED` | Both parties done, scores calculated | Supervisor → System |
| `CANCELLED` | Appraisal voided by HR | HR Officer |

---

## 8. Notification Flow

| Trigger | Recipient | Channel | Message |
|---------|-----------|---------|---------|
| Session activated & appraisals generated | All target employees | Portal notification | "Your performance appraisal for [period] is now open. Please complete your self-assessment by [deadline]." |
| Employee submits self-appraisal | Supervisor | Portal notification | "[Employee Name] has submitted their self-appraisal and is awaiting your review." |
| Supervisor completes appraisal | Employee | Portal notification | "Your performance appraisal for [period] has been completed. You can now view your results." |
| Deadline approaching (7 days) | Pending employees | Portal notification | "Reminder: Your self-appraisal is due in 7 days." |
| Deadline passed | HR Officer | Admin notification | "[N] employees have not yet submitted their self-appraisal." |

---

## 9. Report Generation

### Individual Appraisal Report (Branded PDF)

**Content:**
- University logo + header
- Section A: Personal Information table
- Section B: Level of Achievement (dual columns: self-rating & supervisor rating)
- Section C: Core Competencies with ratings
- Section D: Action Plan
- Section E: Comments & Reflections
- Score Summary: B total + C total = X, Y, Final %, Classification
- Signature lines (Appraisee, Appraiser, Responsible Officer)

**Design:**
- University branding (logo, colors, fonts)
- Clean, professional layout matching paper form aesthetics
- Print-optimized (A4)

### General / Aggregate Report

**Content:**
- Session summary (title, period, deadline)
- Overall statistics (total, completed, pending, overdue)
- Department breakdown table
- Category breakdown table
- Score distribution histogram
- Top/bottom performers (anonymized or full, based on permissions)
- Export: Excel / CSV with all individual scores

---

## 10. UI/UX Specifications

### CSS Prefix

All appraisal module CSS classes use the prefix: **`pa-`** (Performance Appraisal)

### Wizard Design

```
┌─────────────────────────────────────────────────────┐
│  ● Step 1    ○ Step 2    ○ Step 3    ○ Step 4      │  ← Progress bar
├─────────────────────────────────────────────────────┤
│                                                     │
│  Step Title                                         │
│  ─────────                                          │
│                                                     │
│  [ Form content for current step ]                  │
│                                                     │
│                                                     │
│                                                     │
├─────────────────────────────────────────────────────┤
│  [← Previous]              [Save Draft] [Next →]   │  ← Navigation
└─────────────────────────────────────────────────────┘
```

### Dashboard Cards

```
┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐
│  Total   │  │ Completed│  │ Pending  │  │ Overdue  │
│   245    │  │   180    │  │    52    │  │    13    │
│          │  │  73.5%   │  │  21.2%   │  │   5.3%   │
└──────────┘  └──────────┘  └──────────┘  └──────────┘
```

### Color Scheme (aligned with existing Campus Dynamics theme)

| Element | Color | Usage |
|---------|-------|-------|
| Primary | Existing theme primary | Buttons, headers, progress bar |
| Success | #28a745 | Completed status, good scores |
| Warning | #ffc107 | In-progress status, approaching deadline |
| Danger | #dc3545 | Overdue, poor scores |
| Info | #17a2b8 | Pending status, neutral info |

---

## Implementation Order

| Phase | Tasks | Priority |
|-------|-------|----------|
| **Phase 1** | Database tables + schema migration | High |
| **Phase 2** | Competency templates seeding (master data) | High |
| **Phase 3** | Admin: Session management page | High |
| **Phase 4** | Admin: Generate individual appraisals logic | High |
| **Phase 5** | Portal: Employee self-appraisal wizard | High |
| **Phase 6** | Portal: Supervisor appraisal wizard | High |
| **Phase 7** | Portal: My Appraisals queue page | Medium |
| **Phase 8** | Admin: Monitoring dashboard | Medium |
| **Phase 9** | Admin: Individual appraisal viewer + report | Medium |
| **Phase 10** | Admin: Aggregate reports + export | Lower |
| **Phase 11** | Notification system integration | Lower |
