# Departments and Heads of Department (HODs) — Status Report

**Muteesa I Royal University**
Generated: 2026-07-11
Source: `campus_dynamics` — `hrm_departments`, `acad_faculty`, `acad_programme`, `hrm_employee`

---

## 1. Summary

| Metric | Value |
|---|---:|
| Departments on record | 24 |
| Departments with a HOD assigned | 24 (100%) |
| Departments without a HOD | 0 |
| HOD records resolving to a real employee | 24 of 24 |
| Academic departments (linked to a faculty) | 7 |
| Administrative departments (no faculty) | 17 |
| Faculties on record | 6 |
| Faculties that have departments | 3 of 6 |
| Programmes on record | 131 |
| Programmes mapped to a department | 11 (8%) |

**Position.** Every department has a HOD, and every HOD record resolves to a real employee — there are no gaps or broken links on that side.

**Important caveat.** Only 11 of 131 programmes are actually linked to a department. The programme counts below therefore reflect only what has been mapped, not what each department genuinely teaches. See Section 5.

---

## 2. Academic departments, by faculty

The 7 departments that carry a faculty code. Programme counts include only programmes explicitly mapped to the department.

### Faculty of Education (FOE)
Dean: Lutamaguzi John Bosco

| Department | HOD | Email | Programmes |
|---|---|---|---:|
| Educational Psychology and Curriculum Studies | Nabbira Jackline | nabbiiraj@mru.ac.ug | 6 |
| Academic Registrar | Dr. Musisi Fred | fredmusisi50@yahoo.com | 1 |
| Professional Studies and Pedagogy | Kalyesubula Micheal | kalyesubulam@mru.ac.ug | 0 |

### Faculty of Science, Technology, Engineering, Art and Design (FSTEAD)
Dean: Kalyesubula Micheal

| Department | HOD | Email | Programmes |
|---|---|---|---:|
| Information Technology | Dr. Ali Najib | najibab@mru.ac.ug | 0 |
| Electrical Engineering | Bagaiga Richard | bagaigar@mru.ac.ug | 0 |
| Art and Design | Ntege Michael | ntegemr@mru.ac.ug | 0 |

### Faculty of Social Sciences, Arts and Humanities (FSSAH)
Dean: Dr. Rosemary Nakijoba

| Department | HOD | Email | Programmes |
|---|---|---|---:|
| Social Work and Social Administration / Development Studies | Nkumbi Julius Ceaser | juliusceasarn@gmail.com | 2 |

---

## 3. Administrative departments

All 17 have a head. None carry academic programmes, with the exception of Civil Engineering (see Section 5).

| Department | Head |
|---|---|
| Civil Engineering (holds 2 programmes — see Section 5) | Kalema Sarah Mbasanze |
| Vice Chancellor | Prof. Kakembo Vincent |
| Deputy Vice Chancellor | Assoc. Prof. Dr. Umar A. M. Kasule |
| University Bursar | Tiondi Emanuel Arams |
| Bursary | Ssekitoleko Vincent |
| Human Resource | Namayanja Agnes |
| Quality Assurance | Akullo Teopista |
| Post Graduate Studies | Dr. Rosemary Nakijoba |
| Library | Prof. Robert J. K. Kakembo |
| Information Communications Technology | Ssemakula Ronald |
| Dean of Students | Ssenkungu Paddy |
| Deputy Dean of Students | Nyombi Ronald |
| Estates | Bukenya Herbert |
| Stores | Nangendo Sharifah |
| Marketing Department | Birende Jamir |
| International Relations | Juliet Kakembo |
| Writing Center | Bbaale John Ggala |

---

## 4. Faculty coverage

| Faculty | Code | Departments | Status |
|---|---|---:|---|
| Faculty of Education | FOE | 3 | Covered |
| Faculty of Science, Technology, Engineering, Art and Design | FSTEAD | 3 | Covered |
| Faculty of Social Sciences, Arts and Humanities | FSSAH | 1 | Thin — a single department |
| Faculty of Business and Management | FBM | 0 | No departments, no HODs |
| Graduate Centre | GC | 0 | No departments, no HODs |

---

## 5. Findings requiring attention

HOD and Dean scoping in the system follows the chain `programme -> department_id -> department -> faculty_code`. That chain is what restricts a HOD to their own department's marks and results, so breaks in it have direct operational consequences.

| Priority | Finding | Consequence |
|---|---|---|
| High | 120 of 131 programmes (92%) have no `department_id`. Only 11 are mapped. | HOD and Dean scoping cannot see those programmes. A HOD's marks and results console is effectively blind to most of the catalogue. This is the highest-impact item. |
| High | Faculty of Business and Management (FBM) and Graduate Centre (GC) have no departments, and therefore no HODs. | No HOD can be scoped to any Business or Graduate programme. |
| Medium | Civil Engineering holds two real programmes (BCE, DCE) but has no faculty code, so it sits among the administrative departments. | It is excluded from every faculty-level (Dean) rollup even though it teaches. It should almost certainly be assigned to FSTEAD. |
| Medium | Academic Registrar is registered as an academic department under FOE and owns BBA (Bachelor of Business Administration). | A registry office is not a teaching department, and a business degree does not belong to Education. BBA should sit under FBM. |
| Low | Kalyesubula Micheal is Dean of FSTEAD while also serving as HOD of an FOE department (Professional Studies and Pedagogy). | A cross-faculty role overlap. Worth confirming that this is intentional. |
| Low | Four academic departments have no programmes mapped: Art and Design, Electrical Engineering, Information Technology, Professional Studies and Pedagogy. | Their HODs have nothing scoped to them. This is most likely a symptom of the unmapped-programmes issue above rather than genuinely empty departments. |

---

## 6. Recommended sequence

1. Map the 120 unmapped programmes to their departments. This unlocks HOD and Dean scoping across the board; the remaining items are minor by comparison.
2. Assign Civil Engineering a faculty code (most likely FSTEAD) so it rolls up to a Dean.
3. Create departments under FBM and Graduate Centre and appoint HODs, so Business and Graduate programmes can be scoped.
4. Re-assign BBA from Academic Registrar to a Business department.
5. Confirm whether the Dean and HOD overlap for Kalyesubula Micheal is intentional.

---

## Method

- **Department and HOD:** `hrm_departments.dept_headID` joined to `hrm_employee.empID` for name and email. All 24 resolve.
- **Faculty:** `hrm_departments.faculty_code` joined to `acad_faculty` for name, abbreviation and dean.
- **Programme count:** `COUNT(acad_programme WHERE department_id = department.ID)`.
- A department is treated as academic when it carries a non-empty `faculty_code`.
