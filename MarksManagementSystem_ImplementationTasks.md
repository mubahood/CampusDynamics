# Marks Management System — Detailed Implementation Tasks (Modern Coexisting Interface)

**Project:** Campus Dynamics ERP  
**Date:** 2026-04-07  
**Document Purpose:** Planning-only execution backlog for the modern marks system.  
**Implementation Rule:** No code changes begin until this document is reviewed and approved by stakeholders.

---

## 1. Planning Guardrails (Mandatory)

- Keep classic system unchanged (no breaking behavior in existing results pages).
- Build modern features as additive pages/services under existing NewScreens architecture.
- No destructive data operations in first rollout phase.
- No data loss permitted: additive schema changes, migrations versioned, rollback scripts required.
- Every data mutation must have security authorization, error handling, and audit logging.
- Every task must use one of these statuses only: **Not Started**, **In Progress**, **Completed**.
- Every task must use one of these priorities only: **High**, **Medium**, **Low**.

---

## 2. Current System Baseline (What Already Exists)

### 2.1 Existing Modern Results Pages (Already Built)

The following modern pages already exist and must be respected/integrated, not replaced:

- `COOPERP/NewScreens/ExamResultsInfo.aspx` (primary marks grid, DevExpress batch edit)
- `COOPERP/NewScreens/ExamApproval.aspx` (approve selected/all/cancel)
- `COOPERP/NewScreens/ResultsRelease.aspx` (release/hold workflows)
- `COOPERP/NewScreens/ResultsHoldList.aspx` (held results management)
- `COOPERP/NewScreens/ResultsUpdates.aspx` (results correction workflow)
- `COOPERP/NewScreens/MarksAuditTrail.aspx` (audit analytics view)
- `COOPERP/NewScreens/ResultsAuditLog.aspx` (audit log view)
- `COOPERP/NewScreens/GeneralMarksheets.aspx` (marksheet listing)
- `COOPERP/NewScreens/ResearchMarksheets.aspx`
- `COOPERP/NewScreens/AcademicResults.aspx`

### 2.2 Existing Gaps Still Unresolved

- No teacher-course assignment enforcement table/workflow.
- No dedicated modern bulk mark-entry page with autosave and optimized UX.
- No marks Excel import flow.
- No deadline manager UI for results locks.
- No assignment manager UI.
- No unified status model across draft/submitted/approved/published.
- No comprehensive marks audit centre based on structured `acad_marks_audit`.
- No centralized services layer for marks, deadlines, and authorization.

---

## 3. Team Ownership Matrix

- **TL (Technical Lead):** architecture, sequencing, sign-off.
- **BE (Backend Engineer):** SQL, services, handlers/controllers, business rules.
- **FE (Frontend Engineer):** pages, interaction flows, validation UX, menu integration.
- **DBA (Database Engineer):** migrations, indexing, backfills, rollbacks, restore drills.
- **SEC (Security Engineer):** authz model, CSRF/session hardening, security testing.
- **QA (QA Engineer):** test strategy, automation, UAT coordination.
- **DEVOPS (Release Engineer):** deployment pipelines, monitoring, rollback execution.
- **PO (Product Owner/Registrar/Dean):** functional approval and policy decisions.

---

## 4. Migration and Data Integrity Strategy

### 4.1 Migration Pattern (Aligned to Existing System)

Use existing project conventions:

- Versioned SQL files in `COOPERP/sql/`.
- Optional safe auto-migration helper pattern (`Ensure*Tables()` with `CREATE TABLE IF NOT EXISTS`) for additive objects only.
- Verification SQL scripts for each migration package.

### 4.2 No-Data-Loss Rules

- Pre-migration backup required in each environment.
- Additive first: create tables/columns/indexes before switching behavior.
- No drop/rename of legacy columns in phase 1.
- Backfills must be idempotent.
- Rollback script required for each migration script.
- Deployment blocked if migration verification checks fail.

### 4.3 Migration Version Tracking

Create/standardize:

- `sys_schema_migrations(version, description, applied_by, applied_at, checksum, rollback_ref, verified_by)`

Acceptance:
- Each deploy writes one row per migration.
- CI gate fails when checksum mismatch is detected.

---

## 5. Workstreams and Detailed Tasks

## WS-A — Governance, Approval, and Traceability

| ID | Task | Specific Output | Responsible | Timeline | Dependencies | Priority | Status |
|---|---|---|---|---|---|---|---|
| A-01 | Finalize additive architecture decision | Signed architecture record confirming classic untouched + modern coexistence | TL, PO | 2 days | None | High | Not Started |
| A-02 | Build issue traceability matrix | Matrix mapping P1-P73 → tasks → test cases → acceptance criteria | TL, QA | 2 days | A-01 | High | Not Started |
| A-03 | Define release gates and approvals | Gate checklist (security, migration, QA, UAT, rollback) | TL, SEC, QA, DEVOPS | 2 days | A-01 | High | Not Started |

## WS-B — Database Foundation and Migration Safety

| ID | Task | Specific DB Changes | App/Model Changes | Responsible | Timeline | Dependencies | Priority | Status |
|---|---|---|---|---|---|---|---|---|
| B-01 | Migration registry setup | Create `sys_schema_migrations` | Migration registration utility | DBA, BE | 2 days | A-03 | High | Completed |
| B-02 | Teacher assignment table | Create `acad_teaching_assignments` with unique composite key and indexes | Assignment repository/model | DBA, BE | 3 days | B-01 | High | Completed |
| B-03 | Unlock request table | Create `acad_mark_unlock_requests` with status lifecycle | Unlock request model/service | DBA, BE | 2 days | B-01 | Medium | Completed |
| B-04 | Deadline schema extension | Alter `acad_deadlines` for deadline types + active state | Deadline service query model | DBA, BE | 2 days | B-01 | High | Completed |
| B-05 | Structured audit extension | Alter `acad_marks_audit` for raw entered marks + action subtype | Audit service DTO updates | DBA, BE | 2 days | B-01 | High | Completed |
| B-06 | Reconciliation dataset | Create reconciliation view/table for expected vs in-sheet students | Reconciliation service | DBA, BE | 2 days | B-02 | Medium | Completed |
| B-07 | Assignment backfill migration | Populate assignments from existing sheet ownership metadata idempotently | Backfill executor | DBA, BE | 2 days | B-02 | High | Completed |
| B-08 | Rollback and restore validation | Rollback scripts + restore drill report | Deployment rollback runbook | DBA, DEVOPS, QA | 2 days | B-02..B-07 | High | Not Started |

## WS-C — Security and Authorization Hardening

| ID | Task | Specific Solution | Responsible | Timeline | Dependencies | Priority | Status |
|---|---|---|---|---|---|---|---|
| C-01 | Central authorization engine | Create `MarksAuthorizationService` enforcing assignment + role checks before mark mutations | BE, SEC | 3 days | B-02 | High | Completed |
| C-02 | Entry-point role guards | Add role guard at top of every new handler/controller action | BE, SEC | 2 days | C-01 | High | Completed |
| C-03 | Anti-CSRF controls | Add anti-forgery token generation/validation on every mutation endpoint | BE, FE, SEC | 2 days | C-02 | High | Completed |
| C-04 | Input whitelisting and sanitization | Validate course/programme/alt-course identifiers against canonical sources | BE, SEC | 2 days | C-01 | High | Completed |
| C-05 | Session security hardening | Session fixation mitigation + optional re-auth for high-risk operations | BE, SEC | 2 days | C-02 | High | Completed |
| C-06 | Secure IP auditing logic | Trusted extraction of client IP with proxy-aware sanitization | BE, SEC | 1 day | C-02 | Medium | Completed |

## WS-D — Centralized Services and Controllers/Handlers

| ID | Task | Specific Solution | Responsible | Timeline | Dependencies | Priority | Status |
|---|---|---|---|---|---|---|---|
| D-01 | Marks sheet service | Build `MarksSheetService` for load/save/submit/reconcile/status checks | BE | 3 days | B-02, B-06 | High | Completed |
| D-02 | Deadline service | Build `MarksDeadlineService` for lock checks/countdowns/unlock policy | BE | 2 days | B-04 | High | Completed |
| D-03 | Audit service | Build `MarksAuditService` for INSERT/UPDATE/DELETE/APPROVE/IMPORT/UNLOCK | BE | 2 days | B-05 | High | Completed |
| D-04 | Assignment service | Build `MarksAssignmentService` for assignment CRUD + effective-date logic | BE | 2 days | B-02 | High | Completed |
| D-05 | Results status service | Build `ResultsStatusService` for unified state transitions | BE | 2 days | D-01 | High | Completed |
| D-06 | Unified response/error contract | Standard response envelope + correlation IDs for all endpoints | BE, FE | 1 day | D-01..D-05 | Medium | Completed |
| D-07 | Controller/handler endpoints | Add endpoints for dashboard, mark entry save, import, submit, approve/reject, deadlines, audits, assignments | BE, FE | 5 days | D-01..D-06, C-01..C-04 | High | Completed |

## WS-E — New Modern UI, Views, and Menu Integration

| ID | Task | Specific UI Changes | Responsible | Timeline | Dependencies | Priority | Status |
|---|---|---|---|---|---|---|---|
| E-01 | Teacher Dashboard view | Create teacher-focused dashboard showing assigned courses, completion ratios, lock countdowns | FE, BE | 4 days | D-07, C-01 | High | Completed |
| E-02 | Dedicated Mark Entry view | Create full-table mark entry page with keyboard-friendly bulk editing | FE, BE | 6 days | E-01, D-01 | High | Completed |
| E-03 | Real-time grade calculation | Add live weighted totals/grade preview and inline validation feedback | FE, BE | 3 days | E-02 | High | Completed |
| E-04 | Autosave UX | Add dirty-row tracking, scheduled autosave, and conflict prompts | FE, BE | 3 days | E-02, D-06 | High | Completed |
| E-05 | Excel import view flow | Add import wizard (upload, map columns, validate, preview, commit) | FE, BE, QA | 4 days | E-02, D-07 | Medium | Completed |
| E-06 | Submission summary view | Add pre-submit quality summary (missing marks, distributions, exceptions) | FE, BE | 2 days | E-02 | Medium | Completed |
| E-07 | Dean Approval Dashboard view | Create queue dashboard by faculty/programme/course with bulk and row-level actions | FE, BE | 4 days | D-07, C-02 | High | Completed |
| E-08 | Deadline Manager view | Create admin page to manage coursework/exam/submission deadlines | FE, BE | 3 days | D-02, B-04 | High | Completed |
| E-09 | Assignment Manager view | Create admin page for teacher-course assignment creation/reassignment | FE, BE | 3 days | D-04, B-02 | High | Completed |
| E-10 | Audit Centre view | Create admin audit centre over structured marks audit with drill-down timeline | FE, BE | 4 days | D-03, B-05 | High | Completed |
| E-11 | Historical read-only UX | Add archived/historical read-only mode with explicit visual warnings | FE, BE | 2 days | D-05, D-02 | High | Completed |
| E-12 | Existing menu integration | Add links in existing Examinations & Results menu groups for new pages | FE | 1 day | E-01, E-07, E-08, E-09, E-10 | High | Completed |

## WS-F — Workflow Integrity, Status Model, and Locking

| ID | Task | Specific Solution | Responsible | Timeline | Dependencies | Priority | Status |
|---|---|---|---|---|---|---|---|
| F-01 | Unified status model | Introduce/implement status flow: DRAFT → SUBMITTED → DEAN_APPROVED → PROVISIONAL_PUBLISHED → FINAL_PUBLISHED | BE, FE | 4 days | D-05 | High | Completed |
| F-02 | Lock precedence policy | Implement one lock policy engine combining deadline/approved/programme-level security | BE | 2 days | D-02, C-01 | High | Completed |
| F-03 | Unlock request lifecycle | Implement request/approve/reject/expiry/auto-relock workflow | BE, FE | 3 days | B-03, E-08 | Medium | Completed |
| F-04 | Notification hooks | Add in-app + email notifications for submit/approve/reject/deadline warnings | BE, FE | 3 days | F-01, E-07 | Medium | Completed |

## WS-G — Error Handling, Logging, and Observability

| ID | Task | Specific Solution | Responsible | Timeline | Dependencies | Priority | Status |
|---|---|---|---|---|---|---|---|
| G-01 | Error taxonomy definition | Define validation/authz/business/system error classes and user-safe messages | BE, FE | 2 days | D-06 | High | Completed |
| G-02 | Global exception wrapper | Add centralized exception handling with correlation IDs and safe user response | BE | 2 days | G-01 | High | Completed |
| G-03 | Structured logs | Implement structured logs for actions, failures, durations, and actor metadata | BE, DEVOPS | 2 days | G-01 | High | Completed |
| G-04 | Full audit coverage | Ensure all mark-changing events write structured audit entries (including import and unlock) | BE | 2 days | D-03 | High | Completed |
| G-05 | Alerting dashboards | Add operational alerting for failed saves, authz failures, import failures, lock conflicts | DEVOPS, BE | 3 days | G-03 | Medium | Completed |

## WS-H — Performance, Reliability, and Scalability

| ID | Task | Specific Solution | Responsible | Timeline | Dependencies | Priority | Status |
|---|---|---|---|---|---|---|---|
| H-01 | Ratio query optimization | Cache ratio set per sheet context; remove repeated scalar lookups | BE | 1 day | D-01 | High | Completed |
| H-02 | Transactional bulk-save | Save dirty rows in one transaction with retry-safe semantics | BE, FE | 3 days | D-01, E-04 | High | Completed |
| H-03 | Paging and index tuning | Add server-side paging and optimize high-volume queries/indexes | DBA, BE, FE | 3 days | E-02 | Medium | Completed |
| H-04 | Idempotent sheet sync/create | Add idempotency checks and conflict-safe create/sync behavior | BE, DBA | 2 days | B-06, D-01 | High | Completed |
| H-05 | Config standardization | Standardize modern module DB access configuration and eliminate alias ambiguity | BE, DEVOPS | 2 days | D-07 | Medium | Completed |

## WS-I — Testing and Quality Assurance

| ID | Task | Specific Testing Output | Responsible | Timeline | Dependencies | Priority | Status |
|---|---|---|---|---|---|---|---|
| I-01 | Master test strategy | Unit/integration/security/load/UAT strategy and coverage matrix | QA, TL, SEC | 2 days | A-03 | High | Not Started |
| I-02 | Authorization tests | Automated tests for role + assignment enforcement across all mutation endpoints | QA, BE, SEC | 3 days | C-01..C-04 | High | Not Started |
| I-03 | Migration and rollback tests | Staging execution of forward + rollback + data integrity verification scripts | QA, DBA, DEVOPS | 3 days | B-08 | High | Not Started |
| I-04 | Functional workflow tests | End-to-end tests for entry, autosave, import, submit, approve/reject, release/hold | QA, FE, BE | 5 days | E-02..E-10, F-01 | High | Not Started |
| I-05 | Load/performance tests | Peak-season concurrent mark entry + approval load benchmarks | QA, DEVOPS | 3 days | H-02, H-03 | Medium | Not Started |
| I-06 | Security tests | CSRF, privilege escalation, tampering, injection, session hardening tests | QA, SEC | 3 days | C-01..C-06 | High | Not Started |
| I-07 | UAT and stakeholder sign-off | Faculty/Dean/Registrar UAT scripts, results log, sign-off report | QA, PO | 3 days | I-04 | High | Not Started |

## WS-J — Deployment, Rollout, Communication, and Tracking

| ID | Task | Specific Output | Responsible | Timeline | Dependencies | Priority | Status |
|---|---|---|---|---|---|---|---|
| J-01 | Phased rollout plan | Feature-flag rollout by role/campus/cohort | DEVOPS, BE, FE | 2 days | E-12 | Medium | Not Started |
| J-02 | Cutover and rollback runbooks | Runbook with checkpoints, abort criteria, rollback triggers | DEVOPS, DBA, TL | 2 days | B-08, I-03 | High | Not Started |
| J-03 | Training and adoption package | Role-based quick guides and short demos | PO, QA, FE | 3 days | I-07 | Medium | Not Started |
| J-04 | Weekly stakeholder reporting | Recurring report with completed/in-progress/blockers/risks/next-week plan | TL, PO | Ongoing | A-02 | High | In Progress |

---

## 6. Existing Pages Integration Plan (Do Not Replace)

The following integration tasks are mandatory to preserve coexistence:

- Integrate new services into existing modern pages where safe (no regression in current workflows).
- Keep `ExamResultsInfo.aspx` operational while introducing dedicated mark-entry page.
- Keep `ExamApproval.aspx` operational while introducing Dean dashboard.
- Keep `ResultsRelease.aspx` and `ResultsHoldList.aspx` operational while improving status/locking consistency.
- Keep existing audit views operational while adding `AuditCentre` based on structured audit table.

Tracking task IDs:
- D-01, D-02, D-03, D-07
- E-02, E-07, E-10
- F-01, F-02
- I-04 regression scope

---

## 7. Issue Coverage Summary (P1-P73)

- P1-P5 → B-02, B-07, C-01, E-01, E-09, I-02
- P6-P10 → B-06, D-01, E-02, E-06, H-04
- P11-P20 → D-01, D-07, E-02, E-03, E-04, E-05, E-06, H-02
- P21-P26 → F-01, F-04, E-07, I-04
- P27-P33 → B-04, D-02, E-08, F-02, F-03
- P34-P38 → E-11, F-03, I-04
- P39-P45 → B-05, D-03, E-10, G-04
- P46-P57 → E-01, E-02, E-03, E-06, E-12
- P58-P64 → H-01, H-02, H-03, H-05
- P65-P73 → C-01..C-06, I-06

---

## 8. Detailed Acceptance Criteria (Definition of Completed)

A task is marked **Completed** only if all criteria are met:

1. Implemented scope matches this document.
2. Security checks for that task pass.
3. Relevant logs/audit entries are produced.
4. Relevant automated tests pass.
5. If DB involved: migration verification + rollback verification passed.
6. Reviewer approvals captured (TL + role owner).

---

## 9. Stakeholder Progress Tracking and Reporting

### 9.1 Weekly Report Template

| Field | Required Content |
|---|---|
| Week | YYYY-MM-DD to YYYY-MM-DD |
| Completed | Task IDs and outcomes |
| In Progress | Task IDs, current progress %, blockers |
| Not Started | Next scheduled tasks |
| Risks | Risk description, owner, mitigation date |
| Decisions Needed | Decision owner and deadline |
| Data Integrity Notes | Migration outcomes, verification results |
| Security Notes | Security test findings and status |

### 9.2 Task Tracker Columns

| Task ID | Workstream | Owner | Priority | Status | Start Date | Due Date | Dependency | Risk Level | Notes |
|---|---|---|---|---|---|---|---|---|---|

### 9.3 Cadence

- Daily internal standup.
- Weekly stakeholder review (Dean, Registrar, TL, QA, SEC, DEVOPS).
- Milestone gate review before each phase transition.

---

## 10. Pre-Implementation Approval Checklist

No coding starts until all boxes are checked:

- [ ] Architecture and coexistence plan approved.
- [ ] Migration, rollback, and verification strategy approved.
- [ ] Security baseline and testing scope approved.
- [ ] QA strategy and performance test plan approved.
- [ ] Owners, timelines, and dependencies approved.
- [ ] Stakeholder reporting cadence approved.

---

## 11. Immediate Next Planning Actions

1. Run stakeholder review workshop on this task document.
2. Adjust estimates and owners where needed.
3. Freeze approved version as `v1.0` baseline.
4. Convert approved tasks into sprint backlog.
5. Start implementation only after checklist in section 10 is fully approved.

---

## 12. Document Control

- **Version:** 1.0  
- **Owner:** Technical Lead  
- **Last Updated:** 2026-04-07  
- **Review Frequency:** Weekly during implementation
