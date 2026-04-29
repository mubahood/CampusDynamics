---
title: Academic Transcript Collection
date: 2026-04-28
---

# Academic Transcript Collection — Step-by-Step Restoration Runbook

## Purpose
This runbook restores lost academic data with strict controls for:
1) student master registration,
2) semester registration,
3) course registration,
4) marks capture,
5) results grading and GPA/CGPA consistency.

It is written as task-driven execution with statuses to minimize errors.

---

## Scope
- Student 1: **NAKASULE Sylvia** (`10/U/DPE/935/KB/INS`)
- Student 2: **KAYIWA Patrick** (`21/U/BMC/0508/K/DAY`, Student No: `MRU/21000537`)

For any missing student number:
- Use **Reg No as temporary Student Number** until official student number is confirmed.

---

## Status Legend
- `[ ]` Not started
- `[-]` In progress
- `[x]` Completed
- `[!]` Blocked / Needs decision

---

## Phase 0 — Governance, Safety, and Pre-Checks

### 0.1 Change Control
- [ ] Open restoration ticket with reason: "Lost academic records restoration"
- [ ] Assign owner (Academic Registry + DBA + System Admin)
- [ ] Confirm restoration window and freeze conflicting edits

### 0.2 Backup & Rollback Safety
- [ ] Full backup of affected schemas (at minimum: `campus_dynamics`, `campus_dynamics_portal`)
- [ ] Export current rows (if any) for both reg numbers from:
  - `acad_student`
  - `acad_registration`
  - `acad_course_registration`
  - `acad_results`
- [ ] Save rollback SQL script before insert/update execution

### 0.3 Identity and Programme Mapping Validation
- [ ] Confirm exact programme codes in DB:
  - Diploma in Primary Education (Sylvia)
  - Bachelor of Mass Communication (Patrick)
- [ ] Confirm faculty/school IDs used by current ERP
- [ ] Confirm grading scale in active system (classic 5-point currently in use)

---

## Phase 1 — Student Master Record Restoration

### 1.1 Create or Repair Student Core Profile
- [ ] Insert/update student in `acad_student` for Sylvia
- [ ] Insert/update student in `acad_student` for Patrick
- [ ] Confirm names, sex, DOB, nationality, faculty/programme alignment

### 1.2 Student Number Rules
- [ ] Sylvia: set student number = reg number (`10/U/DPE/935/KB/INS`) if no official number available
- [ ] Patrick: set student number = `MRU/21000537`

### 1.3 Validation Checkpoint
- [ ] Verify unique keys: no duplicate regno/student no conflicts
- [ ] Verify student can be resolved by regno from academic modules

---

## Phase 2 — Semester Registration Restoration (`acad_registration`)

### 2.1 Sylvia Semester Rows
- [ ] 2010/2011 Session 1
- [ ] 2010/2011 Session 2
- [ ] 2010/2011 Session 3
- [ ] 2011/2012 Session 1
- [ ] 2011/2012 Session 2
- [ ] 2011/2012 Session 3

### 2.2 Patrick Semester Rows
- [ ] 2021/2022 Semester 1
- [ ] 2021/2022 Semester 2
- [ ] 2022/2023 Semester 1
- [ ] 2022/2023 Semester 2
- [ ] 2023/2024 Semester 1
- [ ] 2023/2024 Semester 2

### 2.3 Semester Metadata
- [ ] Set study year correctly per semester
- [ ] Set registration status to valid/cleared according to institutional policy
- [ ] Ensure programme/faculty links are consistent with student profile

### 2.4 Validation Checkpoint
- [ ] No missing semester expected from transcript
- [ ] No duplicate semester rows per student/acad year/semester

---

## Phase 3 — Course Registration Restoration (`acad_course_registration`)

### 3.1 Course Master Verification (Before Insert)
- [ ] Verify every transcript course code exists in `acad_course`
- [ ] For missing course codes, create/repair course master records before registration
- [ ] Verify credit units match transcript source

### 3.2 Register Sylvia Courses by Session
- [ ] Insert all Year 1 Session 1 courses
- [ ] Insert all Year 1 Session 2 courses
- [ ] Insert all Year 1 Session 3 courses
- [ ] Insert all Year 2 Session 1 courses
- [ ] Insert all Year 2 Session 2 courses
- [ ] Insert all Year 2 Session 3 courses

### 3.3 Register Patrick Courses by Semester
- [ ] Insert all Year 1 Semester 1 courses
- [ ] Insert all Year 1 Semester 2 courses
- [ ] Insert all Year 2 Semester 1 courses
- [ ] Insert all Year 2 Semester 2 courses
- [ ] Insert all Year 3 Semester 1 courses
- [ ] Insert all Year 3 Semester 2 courses

### 3.4 Validation Checkpoint
- [ ] Student-course duplicates prevented
- [ ] Course counts per semester match transcript exactly
- [ ] CU totals per semester match transcript

---

## Phase 4 — Marks Capture (Two-Layer Update)

> Policy: update both provisional layer and published layer for consistency.

### 4.1 Update Provisional Marks (`acad_course_registration`)
- [ ] For each registered course, set:
  - `provisional_course_work_marks`
  - `provisional_exam_marks`
  - `provisional_total_marks` = CW + Exam
- [ ] Set provisional workflow fields to published/final state per system convention

### 4.2 Update Published Results (`acad_results`)
- [ ] Upsert each course mark row with:
  - regno, courseid, acad, semester, studyyear
  - score (total)
  - grade
  - gradept
  - credit units
  - result_comment/audit reason

### 4.3 Numeric Integrity Rules
- [ ] Every row must satisfy: `Total = CW + Exam`
- [ ] Grade must match active grading function in system
- [ ] Grade point must match grade mapping in active system

---

## Phase 5 — GPA, CGPA, and Classification Consistency

### 5.1 Semester GPA Recalculation
- [ ] Recompute GPA per semester from restored course rows
- [ ] Compare computed GPA with source transcript GPA
- [ ] Document any approved variance caused by grading-scale differences

### 5.2 Cumulative CGPA Recalculation
- [ ] Recompute CGPA across all semesters for each student
- [ ] Validate Patrick target CGPA (source: 3.79) if same grading policy applies

### 5.3 Final Classification
- [ ] Sylvia classification should align to transcript: **Second Class Upper**
- [ ] Verify classification engine output from current institutional thresholds

---

## Phase 6 — End-to-End Verification and Sign-Off

### 6.1 Functional Verification
- [ ] Student transcript opens correctly from portal
- [ ] Semester grouping/order is correct
- [ ] All course rows visible with correct marks/grades/CU

### 6.2 Data Reconciliation
- [ ] Count check: inserted rows = transcript rows
- [ ] Aggregate check: CU totals per semester match source
- [ ] GPA/CGPA check passed

### 6.3 Audit Trail and Approval
- [ ] Record who restored each student and when
- [ ] Attach transcript source file/hash
- [ ] Academic Registry sign-off
- [ ] Final status marked complete

---

## Execution Board (Live)

### Student A — NAKASULE Sylvia (`10/U/DPE/935/KB/INS`)
- [ ] A1 Master profile restored
- [ ] A2 Student number set (using reg number)
- [ ] A3 All 6 sessions registered
- [ ] A4 All courses registered
- [ ] A5 Provisional marks updated
- [ ] A6 Published results updated
- [ ] A7 GPA/CGPA validated
- [ ] A8 Classification validated
- [ ] A9 Sign-off complete

### Student B — KAYIWA Patrick (`21/U/BMC/0508/K/DAY`)
- [ ] B1 Master profile restored
- [ ] B2 Student number set (`MRU/21000537`)
- [ ] B3 All 6 semesters registered
- [ ] B4 All courses registered
- [ ] B5 Provisional marks updated
- [ ] B6 Published results updated
- [ ] B7 GPA/CGPA validated
- [ ] B8 Transcript parity validated
- [ ] B9 Sign-off complete

---

## Source Academic Data (Canonical Input)

## Academic Transcript: Sylvia Nakasule

### Personal Details
- **Name:** NAKASULE Sylvia
- **Reg No:** 10/U/DPE/935/KB/INS
- **Sex:** Female
- **DOB:** 24 October, 1986
- **Nationality:** Ugandan
- **Faculty:** Faculty of Education
- **Award:** DIPLOMA IN PRIMARY EDUCATION
- **Class:** SECOND CLASS UPPER
- **Graduation:** 15th Feb 2013

### Year 1 - Session One (2010/2011)
| Code | Course Name | CU | Grade | CW | Exam | Total |
| :--- | :--- | :---: | :---: | :---: | :---: | :---: |
| DIT1101 | COMPUTER LITERACY | 2 | B+ | 31 | 46 | 77 |
| PEOI1101 | INDIGENOUS AND FORMAL EDUCATION (PRIMARY) | 2 | B | 29 | 43 | 72 |
| PEOI1102 | HUMAN GROWTH, LEARNING AND DEVELOPMENT | 2 | C+ | 25 | 38 | 63 |
| PEOI1103 | EARLY CHILDHOOD EDUCATION | 2 | B- | 27 | 40 | 67 |
| PEOI1104 | THE PRIMARY CURRICULUM | 2 | B | 28 | 43 | 71 |
| PEOI1105 | RESEARCH METHODS | 2 | B+ | 30 | 46 | 76 |
| | **GPA: 3.92** | | | | | |

### Year 1 - Session Two (2010/2011)
| Code | Course Name | CU | Grade | CW | Exam | Total |
| :--- | :--- | :---: | :---: | :---: | :---: | :---: |
| DEFI1201 | SOCIOLOGICAL FOUNDATIONS OF EDUCATION | 2 | B- | 26 | 40 | 66 |
| DEFI1202 | CONTEMPORARY PRIMARY EDUCATIONAL SYSTEMS | 2 | B- | 28 | 40 | 68 |
| DELI1201 | INTRODUCTION TO LANGUAGE STUDY | 2 | B | 29 | 44 | 73 |
| DELI1202 | LANGUAGE STUDY AND TEACHING | 2 | B+ | 32 | 46 | 78 |
| DSSI1201 | EVOLUTION AND FOREIGN INTRUSION IN UGANDA | 2 | B- | 25 | 40 | 65 |
| DSSI1202 | MAN AND ENVIRONMENT IN AFRICA | 2 | A | 34 | 51 | 85 |
| | **GPA: 3.96** | | | | | |

### Year 1 - Session Three (2010/2011)
| Code | Course Name | CU | Grade | CW | Exam | Total |
| :--- | :--- | :---: | :---: | :---: | :---: | :---: |
| DELI1301 | LITERATURE AND LANGUAGE STUDY | 2 | B+ | 31 | 46 | 77 |
| DELI1302 | LANGUAGE DEVELOPMENT AND PRIMARY METHODOLOGY | 2 | B+ | 32 | 47 | 79 |
| DEMI1301 | EDUCATIONAL MEASUREMENT AND EVALUATION | 2 | B- | 26 | 41 | 67 |
| DSSI1302 | THE ECONOMIC DEVELOPMENT IN AFRICA | 2 | B- | 28 | 41 | 69 |
| | **GPA: 3.97** | | | | | |

### Year 2 - Session One (2011/2012)
| Code | Course Name | CU | Grade | CW | Exam | Total |
| :--- | :--- | :---: | :---: | :---: | :---: | :---: |
| DCUI2101 | ESSENTIALS OF EDUCATIONAL TECHNOLOGY | 2 | B | 28 | 44 | 72 |
| DEFI2101 | PHILOSOPHICAL FOUNDATIONS OF EDUCATION | 2 | B- | 26 | 40 | 66 |
| DELI2101 | LANGUAGE IN SOCIETY | 2 | A | 35 | 53 | 88 |
| DELI2102 | DRAMA AND POETRY | 2 | A | 32 | 50 | 82 |
| DSSI2101 | POLITICAL DEVELOPMENT OF UGANDA | 2 | B | 28 | 43 | 71 |
| DSSI2102 | MAN RESOURCES AND DEVELOPMENT | 2 | B+ | 30 | 46 | 76 |
| | **GPA: 4.07** | | | | | |

### Year 2 - Session Two (2011/2012)
| Code | Course Name | CU | Grade | CW | Exam | Total |
| :--- | :--- | :---: | :---: | :---: | :---: | :---: |
| DEEI2201 | PROFESSIONAL ETHICS | 2 | C- | 21 | 31 | 52 |
| DELI2201 | INSTRUCTIONAL MODES AND RESOURCES IN ENGLISH | 2 | B+ | 31 | 46 | 77 |
| DGCI2201 | INTRODUCTION TO GUIDANCE AND COUNSELING | 2 | B+ | 32 | 46 | 78 |
| DSSI2201 | INSTUCTIONAL MODES AND RESOURCES IN SOCIAL STUDIES | 2 | B | 29 | 44 | 73 |
| | **GPA: 4.02** | | | | | |

### Year 2 - Session Three (2011/2012)
| Code | Course Name | CU | Grade | CW | Exam | Total |
| :--- | :--- | :---: | :---: | :---: | :---: | :---: |
| DELI2301 | ASSESSMENT OF PRIMARY ENGLISH | 2 | C+ | 25 | 37 | 62 |
| DERI2301 | RESEARCH PROPOSAL | 2 | C+ | 26 | 38 | 64 |
| DMAI2301 | ESSENTIALS OF EDUCATIONAL MANAGEMENT AND ADMINISTRATION | 2 | B- | 27 | 41 | 68 |
| DSPI2301 | SCHOOL PRACTICE (12 WKS) | 2 | B | 30 | 44 | 74 |
| DSSI2301 | ASSESSMENT OF PRIMARY SOCIAL STUDIES | 2 | B | 28 | 42 | 70 |
| | **GPA: 3.94** | | | | | |

---

# Statement of Results: Patrick Kayiwa

### Personal Details
- **Name:** KAYIWA PATRICK
- **Reg No:** 21/U/BMC/0508/K/DAY
- **Student No:** MRU/21000537
- **Programme:** Bachelor of Mass Communication
- **Faculty:** Social Sciences, Arts and Humanities
- **CGPA:** 3.79

### Year 1 - Semester 1 (2021/2022)
| Code | Course Name | CU | Grade | CW | Exam | Total |
| :--- | :--- | :---: | :---: | :---: | :---: | :---: |
| DVS1101B | INTRODUCTORY ECONOMICS | 3 | C | 25 | 37 | 62 |
| FND1101B | COMMUNICATION AND LANGUAGE SKILLS | 3 | C+ | 26 | 40 | 66 |
| ICT1108B | COMPUTER LITERACY | 4 | B | 30 | 44 | 74 |
| MSC1111B | INTRODUCTION TO MASS COMMUNICATION | 3 | B+ | 31 | 47 | 78 |
| MSC1113B | INTRODUCTION TO WRITING FOR MASS MEDIA | 3 | B+ | 30 | 46 | 76 |
| MSC1112B | MEDIA HISTORY AND ISSUES | 3 | A | 32 | 49 | 81 |
| MSC1114B | INTRODUCTION TO RADIO JOURNALISM | 3 | C+ | 26 | 40 | 66 |
| MSC1115B | INTRODUCTION TO TELEVISION JOURNALISM | 3 | D+ | 23 | 34 | 57 |
| | **GPA: 3.82** | | | | | |

### Year 1 - Semester 2 (2021/2022)
| Code | Course Name | CU | Grade | CW | Exam | Total |
| :--- | :--- | :---: | :---: | :---: | :---: | :---: |
| FND1205B | HISTORY AND CULTURAL HERITAGE OF UGANDA | 3 | C | 26 | 38 | 64 |
| MSC1206B | ENTREPRENEURSHIP DEVELOPMENT AND MANAGEMENT | 3 | A | 32 | 49 | 81 |
| MSC1211B | MASS MEDIA AND SOCIETY | 3 | D | 20 | 31 | 51 |
| MSC1212B | INTRODUCTION TO POLITICAL SCIENCE | 3 | B+ | 31 | 47 | 78 |
| MSC1213B | INTRODUCTION TO PHOTO JOURNALISM | 3 | A | 32 | 48 | 80 |
| MSC1214B | INTRODUCTION TO PUBLIC RELATIONS | 3 | A | 32 | 48 | 80 |
| MSC1215B | THEORIES OF MASS COMMUNICATION | 3 | C | 25 | 38 | 63 |
| | **GPA: 3.93** | | | | | |

### Year 2 - Semester 1 (2022/2023)
| Code | Course Name | CU | Grade | CW | Exam | Total |
| :--- | :--- | :---: | :---: | :---: | :---: | :---: |
| DVS2115B | RESEARCH METHODS IN MASS COMMUNICATION | 3 | B+ | 30 | 45 | 75 |
| MSC2111B | MEDIA LAW AND ETHICS | 3 | C+ | 27 | 41 | 68 |
| MSC2112B | NEWS WRITING AND REPORTING | 3 | B+ | 30 | 45 | 75 |
| MSC2113B | NEWSPAPER EDITING LAYOUT AND DESIGN | 3 | D+ | 22 | 33 | 55 |
| MSC2114B | PUBLIC INFORMATION PROGRAMMES | 3 | D+ | 24 | 35 | 59 |
| MSC2116B | ADVERTISING AND COPY LAYOUT | 3 | B | 28 | 42 | 70 |
| MSC2117B | HUMAN RIGHTS, CULTURE AND THE MEDIA | 3 | D+ | 24 | 35 | 59 |
| | **GPA: 3.43** | | | | | |

### Year 2 - Semester 2 (2022/2023)
| Code | Course Name | CU | Grade | CW | Exam | Total |
| :--- | :--- | :---: | :---: | :---: | :---: | :---: |
| DVS1108B | SOCIOLOGICAL ISSUES AND CONCEPTS | 3 | C | 24 | 36 | 60 |
| MSC2211B | PUBLIC AFFAIRS REPORTING | 3 | C+ | 27 | 41 | 68 |
| MSC2212B | PUBLIC RELATIONS AND MEDIA PRACTICE | 3 | B+ | 30 | 46 | 76 |
| MSC2213B | INVESTIGATIVE JOURNALISM | 3 | B | 29 | 44 | 73 |
| MSC2214B | NEWSPAPER AND MAGAZINE PRODUCTION | 3 | D+ | 22 | 33 | 55 |
| MSC2215B | DEVELOPMENT COMMUNICATION | 3 | B+ | 30 | 46 | 76 |
| MSC2216B | POLITICS AND GOVERNMENT OF E. AFRICAN STATES | 3 | B | 29 | 43 | 72 |
| MSC2221B | INTERNSHIP REPORT- INTERNSHIP 1 | 4 | B+ | 31 | 46 | 77 |
| | **GPA: 3.84** | | | | | |

### Year 3 - Semester 1 (2023/2024)
| Code | Course Name | CU | Grade | CW | Exam | Total |
| :--- | :--- | :---: | :---: | :---: | :---: | :---: |
| MSC3111B | THE ART OF PUBLIC SPEAKING | 3 | C+ | 28 | 41 | 69 |
| MSC3112B | GRAPHICS OF COMMUNICATION | 3 | C+ | 27 | 41 | 68 |
| MSC3113B | ADVANCED RADIO JOURNALISM AND PRODUCTION | 3 | B+ | 30 | 46 | 76 |
| MSC3114B | ADVANCED TV JOURNALISM AND PRODUCTION | 3 | B | 28 | 42 | 70 |
| MSC3115B | PUBLIC RELATIONS STRATEGIES AND CASE STUDIES | 3 | B | 30 | 44 | 74 |
| MSC3116B | MEDIA MANAGEMENT | 3 | B+ | 30 | 45 | 75 |
| MSC3118B | GENDER ISSUES IN MASS COMMUNICATION | 3 | B+ | 30 | 46 | 76 |
| | **GPA: 4.07** | | | | | |

### Year 3 - Semester 2 (2023/2024)
| Code | Course Name | CU | Grade | CW | Exam | Total |
| :--- | :--- | :---: | :---: | :---: | :---: | :---: |
| MSC3201B | SPECIALIZED WRITING | 3 | B+ | 30 | 46 | 76 |
| MSC3208B | ADVANCED FILMING AND NEW MEDIA | 3 | C+ | 27 | 40 | 67 |
| MSC3211B | ENVIRONMENTAL JOURNALISM | 3 | B+ | 31 | 47 | 78 |
| MSC3212B | INTERNATIONAL AND ONLINE JOURNALISM | 3 | D | 20 | 30 | 50 |
| MSC3213B | CONTEMPORARY ISSUES IN JOURNALISM AND MASSCOMMUNICATION | 3 | C | 24 | 37 | 61 |
| MSC3214B | COMMERCIAL AND PROMOTIONAL WRITING | 3 | D+ | 23 | 35 | 58 |
| MSC3215B | ADVANCED PHOTO JOURNALISM | 3 | B+ | 31 | 46 | 77 |
| MSC3218B | RESEARCH REPORT | 3 | B | 28 | 43 | 71 |
| MSC3219B | INTERNSHIP REPORT- INTERNSHIP 2 | 4 | B+ | 32 | 47 | 79 |
| | **GPA: 3.70** | | | | | |

---

## Final Completion Gate
- [ ] All tasks above completed with evidence
- [ ] Independent verifier reran checks
- [ ] Registry approved transcript parity
- [ ] Ticket closed
