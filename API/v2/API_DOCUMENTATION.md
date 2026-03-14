# CampusDynamics API v2 — Complete Documentation

> **Base URL:** `https://eadmin.mru.ac.ug/API/v2/`  
> **Server:** ASP.NET Web Forms (.NET 4.0) on IIS  
> **Database:** MySQL 6.6.7 (three databases: `campus_dynamics`, `campus_dynamics_portal`, `campus_dynamics_accounts`)  
> **Authentication:** Token-based (24-hour expiry)  
> **Content-Type:** All responses are `application/json`  
> **CORS:** Fully enabled (all origins, methods, headers allowed)

---

## Table of Contents

1. [Response Format](#1-response-format)
2. [Authentication (auth.aspx)](#2-authentication)
3. [Student Endpoints (student.aspx)](#3-student-endpoints)
4. [Staff Endpoints (staff.aspx)](#4-staff-endpoints)
5. [Academic Endpoints (academic.aspx)](#5-academic-endpoints)
6. [Finance Endpoints (finance.aspx)](#6-finance-endpoints)
7. [Timetable Endpoints (timetable.aspx)](#7-timetable-endpoints)
8. [Campus / Public Endpoints (campus.aspx)](#8-campus-endpoints)
9. [Error Codes Reference](#9-error-codes-reference)
10. [Grading & Classification Scales](#10-grading--classification-scales)
11. [Database Schema Notes](#11-database-schema-notes)
12. [Known Limitations](#12-known-limitations)

---

## 1. Response Format

Every API response follows one of two JSON structures:

### Success Response

```json
{
  "status": "success",
  "data": { ... }
}
```

`data` may be an object (single record) or an array (list of records), depending on the endpoint.

### Error Response

```json
{
  "status": "error",
  "message": "Human-readable error description",
  "code": "ERROR_CODE"
}
```

### HTTP Status Codes

All responses return HTTP 200. The `status` field in the JSON body indicates success or failure. Check `status === "success"` to determine if the request succeeded.

### CORS Headers

Every response includes:
```
Access-Control-Allow-Origin: *
Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS
Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With
```

Preflight `OPTIONS` requests receive a 200 response with these headers and an empty body.

---

## 2. Authentication

**Endpoint:** `auth.aspx`

Authentication uses token-based auth. On login, a 64-character hex token is generated and stored in the `api_tokens` MySQL table. The token expires after 24 hours. Each new login deactivates all previous tokens for that user.

### 2.1 Login

Authenticates a student or staff member and returns an access token.

| Property | Value |
|---|---|
| **URL** | `auth.aspx?action=login` |
| **Method** | `GET` or `POST` |
| **Auth Required** | No |

**Parameters:**

| Parameter | Type | Required | Description |
|---|---|---|---|
| `action` | string | Yes | Must be `login` |
| `username` | string | Yes | Student registration number, entry number, email, or staff username/email |
| `password` | string | Yes | User's password |

**Username Resolution Order:**

The system tries to resolve the username in the following order (stops at first match):

1. **Student Registration Number** — looks up `acad_student.regno` (case-insensitive)
2. **Student Entry Number** — looks up `acad_student.entryno` (case-insensitive), returns `acad_student.regno`
3. **Student Email** — looks up `acad_student.studemail` (case-insensitive), returns `acad_student.regno`
4. **Staff Username** — looks up `hrm_employee.usernames` (case-insensitive), returns `hrm_employee.usernames`
5. **Staff Email** — looks up `hrm_employee.emp_email` (case-insensitive), returns `hrm_employee.usernames`

**Password Validation:**

Passwords are validated against the `campus_dynamics_portal.my_aspnet_membership` table. The password is hashed using HMACSHA256 with the user's stored `passwordSalt` (base64-encoded). The hash is then base64-encoded and compared to the stored `password` field.

The membership record is located via:
- `my_aspnet_users` table: find user by `name` (case-insensitive)
- `my_aspnet_membership` table: find membership row by `userId` from above

**Example Request:**

```bash
# Login with student registration number
curl "https://eadmin.mru.ac.ug/API/v2/auth.aspx?action=login&username=MRU2025003204&password=123"

# Login with student entry number
curl "https://eadmin.mru.ac.ug/API/v2/auth.aspx?action=login&username=25/U/BAED/0084/K/DAY&password=123"

# Login with staff username
curl "https://eadmin.mru.ac.ug/API/v2/auth.aspx?action=login&username=muhindo&password=123"
```

**Success Response:**

```json
{
  "status": "success",
  "data": {
    "token": "a1b2c3d4e5f6...64_hex_characters...",
    "user_type": "student",
    "user_id": "MRU2025003204",
    "full_name": "RITAH NAKYESERO",
    "expires": "2025-07-07T14:30:00"
  }
}
```

For staff login:

```json
{
  "status": "success",
  "data": {
    "token": "f6e5d4c3b2a1...64_hex_characters...",
    "user_type": "staff",
    "user_id": "muhindo",
    "full_name": "Muhindo mubaraka",
    "expires": "2025-07-07T14:30:00"
  }
}
```

**User Type Determination:**

- If the resolved username matches a `regno` in `acad_student`, user_type = `"student"`
- Otherwise, user_type = `"staff"`

**Full Name Resolution:**

- **Students:** `CONCAT(firstname, ' ', othername)` from `acad_student` where `regno = resolved_username`
- **Staff:** `emp_name` from `hrm_employee` where `usernames = resolved_username`

**Error Responses:**

```json
{
  "status": "error",
  "message": "Username and password are required.",
  "code": "MISSING_CREDENTIALS"
}
```

```json
{
  "status": "error",
  "message": "User not found. Tried: student reg#, entry#, email, staff username, staff email.",
  "code": "USER_NOT_FOUND"
}
```

```json
{
  "status": "error",
  "message": "Membership record not found for user: MRU2025003204",
  "code": "MEMBERSHIP_NOT_FOUND"
}
```

```json
{
  "status": "error",
  "message": "Invalid password.",
  "code": "INVALID_PASSWORD"
}
```

---

### 2.2 Validate Token

Checks if a token is still valid and returns user info.

| Property | Value |
|---|---|
| **URL** | `auth.aspx?action=validate` |
| **Method** | `GET` or `POST` |
| **Auth Required** | Yes (token) |

**Parameters:**

| Parameter | Type | Required | Description |
|---|---|---|---|
| `action` | string | Yes | Must be `validate` |
| `token` | string | Yes | The token to validate |

**Example Request:**

```bash
curl "https://eadmin.mru.ac.ug/API/v2/auth.aspx?action=validate&token=a1b2c3d4e5f6..."
```

**Success Response:**

```json
{
  "status": "success",
  "data": {
    "valid": true,
    "user_type": "student",
    "user_id": "MRU2025003204",
    "expires": "2025-07-07T14:30:00"
  }
}
```

**Error Responses:**

```json
{
  "status": "error",
  "message": "Token is required.",
  "code": "MISSING_TOKEN"
}
```

```json
{
  "status": "error",
  "message": "Token is invalid or expired.",
  "code": "INVALID_TOKEN"
}
```

---

### 2.3 Logout

Deactivates the given token.

| Property | Value |
|---|---|
| **URL** | `auth.aspx?action=logout` |
| **Method** | `GET` or `POST` |
| **Auth Required** | Yes (token) |

**Parameters:**

| Parameter | Type | Required | Description |
|---|---|---|---|
| `action` | string | Yes | Must be `logout` |
| `token` | string | Yes | The token to deactivate |

**Example Request:**

```bash
curl "https://eadmin.mru.ac.ug/API/v2/auth.aspx?action=logout&token=a1b2c3d4e5f6..."
```

**Success Response:**

```json
{
  "status": "success",
  "data": {
    "message": "Logged out successfully."
  }
}
```

**Error Response (missing token):**

```json
{
  "status": "error",
  "message": "Token is required.",
  "code": "MISSING_TOKEN"
}
```

---

## 3. Student Endpoints

**Endpoint:** `student.aspx`  
**Auth Required:** Yes (all actions require a valid token)

All student endpoints require the `token` parameter. The token identifies the student automatically — no need to pass a student ID separately.

### 3.1 Profile

Returns the authenticated student's full profile information.

| Property | Value |
|---|---|
| **URL** | `student.aspx?action=profile` |
| **Method** | `GET` or `POST` |
| **Auth Required** | Yes |

**Parameters:**

| Parameter | Type | Required | Description |
|---|---|---|---|
| `action` | string | Yes | Must be `profile` |
| `token` | string | Yes | Valid auth token |

**Example Request:**

```bash
curl "https://eadmin.mru.ac.ug/API/v2/student.aspx?action=profile&token=a1b2c3d4e5f6..."
```

**Success Response:**

```json
{
  "status": "success",
  "data": {
    "regno": "MRU2025003204",
    "entryno": "25/U/BAED/0084/K/DAY",
    "firstname": "RITAH",
    "othername": "NAKYESERO",
    "gender": "Female",
    "programme": "Bachelor of Arts with Education",
    "progcode": "BAED",
    "campus": "MAIN",
    "study_year": "1",
    "entry_year": "2024/2025",
    "intake": "August",
    "session": "DAY",
    "status": "Active",
    "nationality": "Ugandan",
    "phone": "0771234567",
    "email": "ritah@example.com",
    "date_of_birth": "2001-05-15",
    "district": "Kampala",
    "photo_url": "https://eadmin.mru.ac.ug/COOPERP/patientimages/MRU2025003204.jpg"
  }
}
```

**Notes:**

- `study_year` is computed as `MAX(studyyear) FROM acad_registration WHERE regno = ...`. Defaults to `1` if no registration exists.
- `photo_url` points to `~/COOPERP/patientimages/{regno}.jpg`. The file may or may not exist on disk.
- The query sources from `acad_student` joined with `acad_programme` (on `progid = progcode`).

**Error Response (student not found):**

```json
{
  "status": "error",
  "message": "Student record not found.",
  "code": "NOT_FOUND"
}
```

---

### 3.2 Photo

Returns the student's photo URL.

| Property | Value |
|---|---|
| **URL** | `student.aspx?action=photo` |
| **Method** | `GET` or `POST` |
| **Auth Required** | Yes |

**Parameters:**

| Parameter | Type | Required | Description |
|---|---|---|---|
| `action` | string | Yes | Must be `photo` |
| `token` | string | Yes | Valid auth token |

**Example Request:**

```bash
curl "https://eadmin.mru.ac.ug/API/v2/student.aspx?action=photo&token=a1b2c3d4e5f6..."
```

**Success Response:**

```json
{
  "status": "success",
  "data": {
    "photo_url": "https://eadmin.mru.ac.ug/COOPERP/patientimages/MRU2025003204.jpg"
  }
}
```

**Notes:**

- The photo URL always uses the pattern `~/COOPERP/patientimages/{regno}.jpg`, resolved to an absolute URL.
- The image file might not exist — the consumer should handle 404s when fetching the image.

---

### 3.3 Lock Status

Checks whether the student's account is locked (e.g., for unpaid fees).

| Property | Value |
|---|---|
| **URL** | `student.aspx?action=lock_status` |
| **Method** | `GET` or `POST` |
| **Auth Required** | Yes |

**Parameters:**

| Parameter | Type | Required | Description |
|---|---|---|---|
| `action` | string | Yes | Must be `lock_status` |
| `token` | string | Yes | Valid auth token |

**Example Request:**

```bash
curl "https://eadmin.mru.ac.ug/API/v2/student.aspx?action=lock_status&token=a1b2c3d4e5f6..."
```

**Success Response (unlocked):**

```json
{
  "status": "success",
  "data": {
    "is_locked": false,
    "lock_reason": ""
  }
}
```

**Success Response (locked):**

```json
{
  "status": "success",
  "data": {
    "is_locked": true,
    "lock_reason": "Fees Balance"
  }
}
```

**Notes:**

- Queries `acad_student.studLock` column. The student is locked when `studLock` is not empty/null.
- The `lock_reason` is the raw value of `studLock`.

---

### 3.4 Summary

Returns a dashboard summary with student info, current registrations count, outstanding balance, and current semester/study year.

| Property | Value |
|---|---|
| **URL** | `student.aspx?action=summary` |
| **Method** | `GET` or `POST` |
| **Auth Required** | Yes |

**Parameters:**

| Parameter | Type | Required | Description |
|---|---|---|---|
| `action` | string | Yes | Must be `summary` |
| `token` | string | Yes | Valid auth token |

**Example Request:**

```bash
curl "https://eadmin.mru.ac.ug/API/v2/student.aspx?action=summary&token=a1b2c3d4e5f6..."
```

**Success Response:**

```json
{
  "status": "success",
  "data": {
    "regno": "MRU2025003204",
    "full_name": "RITAH NAKYESERO",
    "programme": "Bachelor of Arts with Education",
    "study_year": "1",
    "semester": "2",
    "registered_courses": 5,
    "outstanding_balance": 1250000.00
  }
}
```

**Notes:**

- `study_year` is from `MAX(studyyear) FROM acad_registration WHERE regno = ...`
- `semester` is from `acad_calender WHERE is_current = 1` (the current semester value)
- `registered_courses` is the count from `acad_registration` for the current academic year and semester
- `outstanding_balance` is from the accounts database (`campus_dynamics_accounts`) via `QueryAccounts()`, querying `fm_student_ledger` for SUM of amounts where `RegNo = ...`

---

## 4. Staff Endpoints

**Endpoint:** `staff.aspx`  
**Auth Required:** Yes (all actions require a valid token, and some verify staff-only access)

### 4.1 Profile

Returns the authenticated staff member's profile.

| Property | Value |
|---|---|
| **URL** | `staff.aspx?action=profile` |
| **Method** | `GET` or `POST` |
| **Auth Required** | Yes |

**Parameters:**

| Parameter | Type | Required | Description |
|---|---|---|---|
| `action` | string | Yes | Must be `profile` |
| `token` | string | Yes | Valid auth token |

**Example Request:**

```bash
curl "https://eadmin.mru.ac.ug/API/v2/staff.aspx?action=profile&token=f6e5d4c3b2a1..."
```

**Success Response:**

```json
{
  "status": "success",
  "data": {
    "empID": "307",
    "emp_name": "Muhindo mubaraka",
    "EMP_CODE": "MM15022026IT",
    "EmpType": "Teaching",
    "emp_email": "muhindo@mru.ac.ug",
    "emp_phone": "0701234567",
    "emp_nationality": "Ugandan",
    "department": "Information Technology",
    "emp_qualifications": "MSc Computer Science",
    "usernames": "muhindo",
    "contractStart": "2023-01-01",
    "contractEnd": "2025-12-31",
    "contractStatus": "VALID",
    "photo_url": "https://eadmin.mru.ac.ug/COOPERP/staffimages/307_photo.jpg"
  }
}
```

**Notes:**

- `emp_name` is a single combined field (not split into surname/othernames).
- `department` is resolved via `hrm_emp_contracts` (joining on `empID`, filtered by `contractStatus = 'VALID'`) → `hrm_departments` (joining on `departmentID = ID`).
- `photo_url` uses the pattern `~/COOPERP/staffimages/{empID}_photo.jpg`.
- Contract details (`contractStart`, `contractEnd`, `contractStatus`) come from `hrm_emp_contracts` table.

**Error Response (staff not found):**

```json
{
  "status": "error",
  "message": "Staff record not found.",
  "code": "NOT_FOUND"
}
```

---

### 4.2 Photo

Returns the staff member's photo URL.

| Property | Value |
|---|---|
| **URL** | `staff.aspx?action=photo` |
| **Method** | `GET` or `POST` |
| **Auth Required** | Yes |

**Parameters:**

| Parameter | Type | Required | Description |
|---|---|---|---|
| `action` | string | Yes | Must be `photo` |
| `token` | string | Yes | Valid auth token |

**Example Request:**

```bash
curl "https://eadmin.mru.ac.ug/API/v2/staff.aspx?action=photo&token=f6e5d4c3b2a1..."
```

**Success Response:**

```json
{
  "status": "success",
  "data": {
    "photo_url": "https://eadmin.mru.ac.ug/COOPERP/staffimages/307_photo.jpg"
  }
}
```

**Notes:**

- Resolves the staff member's `empID` from `hrm_employee` by matching `usernames = auth.UserId`.
- Photo URL pattern: `~/COOPERP/staffimages/{empID}_photo.jpg`.
- The image file might not exist on disk.

---

### 4.3 My Courses

Returns the list of courses allocated to the authenticated staff member for teaching.

| Property | Value |
|---|---|
| **URL** | `staff.aspx?action=my_courses` |
| **Method** | `GET` or `POST` |
| **Auth Required** | Yes (staff only) |

**Parameters:**

| Parameter | Type | Required | Description |
|---|---|---|---|
| `action` | string | Yes | Must be `my_courses` |
| `token` | string | Yes | Valid auth token |
| `acad_year` | string | No | Filter by academic year (e.g., `2024/2025`). If omitted, returns all. |
| `semester` | string | No | Filter by semester (e.g., `1` or `2`). If omitted, returns all. |

**Example Request:**

```bash
# All teaching allocations
curl "https://eadmin.mru.ac.ug/API/v2/staff.aspx?action=my_courses&token=f6e5d4c3b2a1..."

# Filter by academic year and semester
curl "https://eadmin.mru.ac.ug/API/v2/staff.aspx?action=my_courses&token=f6e5d4c3b2a1...&acad_year=2024/2025&semester=2"
```

**Success Response:**

```json
{
  "status": "success",
  "data": [
    {
      "courseID": "CSC1101",
      "course_name": "Introduction to Computer Science",
      "progcode": "BCS",
      "programme_name": "Bachelor of Computer Science",
      "cyear": "1",
      "semester": "1",
      "acad_year": "2024/2025"
    },
    {
      "courseID": "CSC2201",
      "course_name": "Data Structures",
      "progcode": "BCS",
      "programme_name": "Bachelor of Computer Science",
      "cyear": "2",
      "semester": "1",
      "acad_year": "2024/2025"
    }
  ]
}
```

**Notes:**

- The staff member's `EMP_CODE` is resolved from `hrm_employee` where `usernames = auth.UserId`.
- Teaching allocations come from `acad_teaching_allocation` where `staffCode = EMP_CODE`.
- Course names come from `acad_course` joined on `courseID`.
- Programme names come from `acad_programme` joined on `progcode`.
- `cyear` represents the year of study for that course.

**Error Response (not staff):**

```json
{
  "status": "error",
  "message": "Access denied. Staff only.",
  "code": "ACCESS_DENIED"
}
```

---

### 4.4 Class List

Returns the list of students registered for a specific course taught by the staff member.

| Property | Value |
|---|---|
| **URL** | `staff.aspx?action=class_list` |
| **Method** | `GET` or `POST` |
| **Auth Required** | Yes (staff only) |

**Parameters:**

| Parameter | Type | Required | Description |
|---|---|---|---|
| `action` | string | Yes | Must be `class_list` |
| `token` | string | Yes | Valid auth token |
| `course_code` | string | Yes | The course ID (e.g., `CSC1101`) |
| `acad_year` | string | Yes | Academic year (e.g., `2024/2025`) |
| `semester` | string | No | Semester filter (e.g., `1` or `2`). If omitted, not filtered by semester. |
| `study_year` | string | No | Study year filter (e.g., `1`). If omitted, not filtered by study year. |

**Example Request:**

```bash
curl "https://eadmin.mru.ac.ug/API/v2/staff.aspx?action=class_list&token=f6e5d4c3b2a1...&course_code=CSC1101&acad_year=2024/2025&semester=1"
```

**Success Response:**

```json
{
  "status": "success",
  "data": [
    {
      "regno": "MRU2025003204",
      "student_name": "RITAH NAKYESERO",
      "progcode": "BAED",
      "study_year": "1"
    },
    {
      "regno": "MRU2025003100",
      "student_name": "JOHN SSENTAMU",
      "progcode": "BCS",
      "study_year": "1"
    }
  ]
}
```

**Notes:**

- Sources from `acad_registration` joined with `acad_student`.
- Student name is `CONCAT(s.firstname, ' ', s.othername)`.
- If `acad_year` is missing, returns an error:

```json
{
  "status": "error",
  "message": "course_code and acad_year are required.",
  "code": "MISSING_PARAMS"
}
```

---

### 4.5 View Marks

Returns marks/results for a specific course.

| Property | Value |
|---|---|
| **URL** | `staff.aspx?action=marks` |
| **Method** | `GET` or `POST` |
| **Auth Required** | Yes (staff only) |

**Parameters:**

| Parameter | Type | Required | Description |
|---|---|---|---|
| `action` | string | Yes | Must be `marks` |
| `token` | string | Yes | Valid auth token |
| `course_code` | string | Yes | The course ID (e.g., `CSC1101`) |
| `acad_year` | string | Yes | Academic year (e.g., `2024/2025`) |
| `semester` | string | No | Semester filter |

**Example Request:**

```bash
curl "https://eadmin.mru.ac.ug/API/v2/staff.aspx?action=marks&token=f6e5d4c3b2a1...&course_code=CSC1101&acad_year=2024/2025"
```

**Success Response:**

```json
{
  "status": "success",
  "data": [
    {
      "regno": "MRU2025003204",
      "student_name": "RITAH NAKYESERO",
      "coursework": "30",
      "exam": "50",
      "total": "80",
      "grade": "A",
      "grade_point": "5.0"
    },
    {
      "regno": "MRU2025003100",
      "student_name": "JOHN SSENTAMU",
      "coursework": "25",
      "exam": "40",
      "total": "65",
      "grade": "C+",
      "grade_point": "3.5"
    }
  ]
}
```

**Notes:**

- Queries `acad_results` joined with `acad_student`.
- `total` is `coursework + exam`.
- Student name is `CONCAT(s.firstname, ' ', s.othername)`.

**Error Response (missing params):**

```json
{
  "status": "error",
  "message": "course_code and acad_year are required.",
  "code": "MISSING_PARAMS"
}
```

---

### 4.6 Submit Marks

Submits or updates marks for students in a course. Uses upsert (INSERT ... ON DUPLICATE KEY UPDATE).

| Property | Value |
|---|---|
| **URL** | `staff.aspx?action=submit_marks` |
| **Method** | `POST` |
| **Auth Required** | Yes (staff only) |

**Parameters:**

| Parameter | Type | Required | Description |
|---|---|---|---|
| `action` | string | Yes | Must be `submit_marks` |
| `token` | string | Yes | Valid auth token |
| `course_code` | string | Yes | The course ID |
| `acad_year` | string | Yes | Academic year (e.g., `2024/2025`) |
| `semester` | string | Yes | Semester (e.g., `1` or `2`) |
| `marks` | string (JSON) | Yes | JSON array of mark objects |

**Marks JSON Format:**

```json
[
  {"regno": "MRU2025003204", "coursework": 30, "exam": 50},
  {"regno": "MRU2025003100", "coursework": 25, "exam": 40}
]
```

Each mark object must have:
- `regno` (string) — student registration number
- `coursework` (number) — coursework marks
- `exam` (number) — exam marks

**Example Request:**

```bash
curl -X POST "https://eadmin.mru.ac.ug/API/v2/staff.aspx?action=submit_marks&token=f6e5d4c3b2a1...&course_code=CSC1101&acad_year=2024/2025&semester=1" \
  -d 'marks=[{"regno":"MRU2025003204","coursework":30,"exam":50},{"regno":"MRU2025003100","coursework":25,"exam":40}]'
```

**Success Response:**

```json
{
  "status": "success",
  "data": {
    "message": "Marks submitted successfully.",
    "processed": 2
  }
}
```

**Auto-Calculated Fields:**

For each mark submitted, the system automatically calculates:

| Field | Logic |
|---|---|
| `total` | `coursework + exam` |
| `grade` | Based on grading scale (see Section 10) |
| `GP` | Grade point (see Section 10) |
| `remarks` | `"NP"` if total ≥ 50, `"PP"` if total < 50 |

**Database Operation:**

Uses `INSERT INTO acad_results (...) VALUES (...) ON DUPLICATE KEY UPDATE ...` to upsert marks. The unique key is the combination of `(regno, courseID, acad_year, semester)`.

Fields written to `acad_results`:
- `courseID` — from `course_code` parameter
- `regno` — from marks array
- `coursework` — from marks array
- `exam` — from marks array
- `total` — calculated
- `grade` — calculated
- `GP` — calculated
- `remarks` — calculated (`NP` or `PP`)
- `acad_year` — from parameter
- `semester` — from parameter

**Error Responses:**

```json
{
  "status": "error",
  "message": "course_code, acad_year, semester and marks are required.",
  "code": "MISSING_PARAMS"
}
```

```json
{
  "status": "error",
  "message": "Invalid marks JSON format.",
  "code": "INVALID_FORMAT"
}
```

---

## 5. Academic Endpoints

**Endpoint:** `academic.aspx`  
**Auth Required:** Yes (all actions)

All academic endpoints work for the authenticated student only (identified by token).

### 5.1 Results

Returns the student's academic results for a specific academic year and semester.

| Property | Value |
|---|---|
| **URL** | `academic.aspx?action=results` |
| **Method** | `GET` or `POST` |
| **Auth Required** | Yes |

**Parameters:**

| Parameter | Type | Required | Description |
|---|---|---|---|
| `action` | string | Yes | Must be `results` |
| `token` | string | Yes | Valid auth token |
| `acad_year` | string | Yes | Academic year (e.g., `2024/2025`) |
| `semester` | string | Yes | Semester (e.g., `1` or `2`) |

**Example Request:**

```bash
curl "https://eadmin.mru.ac.ug/API/v2/academic.aspx?action=results&token=a1b2c3d4e5f6...&acad_year=2024/2025&semester=2"
```

**Success Response:**

```json
{
  "status": "success",
  "data": [
    {
      "courseID": "CSC1101",
      "courseName": "Introduction to Computer Science",
      "coursework": "30",
      "exam": "50",
      "total": "80",
      "grade": "A",
      "GP": "5.0",
      "remarks": "NP"
    },
    {
      "courseID": "MTH1101",
      "courseName": "Calculus I",
      "coursework": "20",
      "exam": "35",
      "total": "55",
      "grade": "D+",
      "GP": "2.5",
      "remarks": "NP"
    }
  ]
}
```

**Notes:**

- Sources from `acad_results` joined with `acad_course` on `courseID`.
- `remarks`: `"NP"` = Normal Progress, `"PP"` = Poor Progress.

**Error Response (missing params):**

```json
{
  "status": "error",
  "message": "acad_year and semester are required.",
  "code": "MISSING_PARAMS"
}
```

---

### 5.2 Transcript

Returns the student's complete academic transcript across all semesters, using the stored procedure `sp_StudentTranscript`.

| Property | Value |
|---|---|
| **URL** | `academic.aspx?action=transcript` |
| **Method** | `GET` or `POST` |
| **Auth Required** | Yes |

**Parameters:**

| Parameter | Type | Required | Description |
|---|---|---|---|
| `action` | string | Yes | Must be `transcript` |
| `token` | string | Yes | Valid auth token |

**Example Request:**

```bash
curl "https://eadmin.mru.ac.ug/API/v2/academic.aspx?action=transcript&token=a1b2c3d4e5f6..."
```

**Success Response:**

```json
{
  "status": "success",
  "data": {
    "student": {
      "regno": "MRU2025003204",
      "name": "RITAH NAKYESERO",
      "programme": "Bachelor of Arts with Education",
      "entry_year": "2024/2025"
    },
    "semesters": [
      {
        "acad_year": "2024/2025",
        "semester": "1",
        "courses": [
          {
            "courseID": "CSC1101",
            "courseName": "Introduction to Computer Science",
            "CreditUnits": "3",
            "grade": "A",
            "gradept": "5.0"
          },
          {
            "courseID": "MTH1101",
            "courseName": "Calculus I",
            "CreditUnits": "4",
            "grade": "B+",
            "gradept": "4.5"
          }
        ],
        "semester_gpa": 4.71,
        "total_credits": 7,
        "total_grade_points": 33.0
      }
    ],
    "cgpa": 4.71,
    "classification": "First Class",
    "total_credits": 7
  }
}
```

**Notes:**

- Uses stored procedure: `CALL sp_StudentTranscript(@reg)`.
- The stored procedure returns a DataTable with columns: `acad` (academic year), `semester`, `courseID`, `courseName`, `CreditUnits`, `grade`, `gradept` (grade point).
- Transcript is grouped by `acad + semester` to create semester blocks.
- `semester_gpa` = `SUM(CreditUnits × gradept) / SUM(CreditUnits)` for each semester.
- `cgpa` = Cumulative GPA across all semesters.
- `classification` is based on CGPA (see Section 10 for classification scale).

---

### 5.3 GPA

Returns the student's GPA/CGPA calculation, using stored procedure `sp_StudentResults`.

| Property | Value |
|---|---|
| **URL** | `academic.aspx?action=gpa` |
| **Method** | `GET` or `POST` |
| **Auth Required** | Yes |

**Parameters:**

| Parameter | Type | Required | Description |
|---|---|---|---|
| `action` | string | Yes | Must be `gpa` |
| `token` | string | Yes | Valid auth token |
| `acad_year` | string | No | Academic year filter. If omitted, returns CGPA across all semesters. |
| `semester` | string | No | Semester filter. Used only with `acad_year`. |

**Example Request:**

```bash
# CGPA (all time)
curl "https://eadmin.mru.ac.ug/API/v2/academic.aspx?action=gpa&token=a1b2c3d4e5f6..."

# Semester GPA
curl "https://eadmin.mru.ac.ug/API/v2/academic.aspx?action=gpa&token=a1b2c3d4e5f6...&acad_year=2024/2025&semester=2"
```

**Success Response (CGPA):**

```json
{
  "status": "success",
  "data": {
    "cgpa": 4.25,
    "total_credits": 42,
    "total_grade_points": 178.5,
    "classification": "First Class"
  }
}
```

**Success Response (Semester GPA):**

```json
{
  "status": "success",
  "data": {
    "gpa": 4.50,
    "total_credits": 18,
    "total_grade_points": 81.0,
    "acad_year": "2024/2025",
    "semester": "2"
  }
}
```

**Notes:**

- Uses stored procedure: `CALL sp_StudentResults(@reg)`.
- DataTable columns: `acad`, `courseID`, `courseName`, `CreditUnits`, `gradept`.
- When computing semester-specific GPA, filters by `acad_year` and optionally `semester` from the results DataTable.
- Classification is only included for CGPA (overall) calculations.

---

### 5.4 Available Courses

Lists courses available for registration for the student's current semester.

| Property | Value |
|---|---|
| **URL** | `academic.aspx?action=available_courses` |
| **Method** | `GET` or `POST` |
| **Auth Required** | Yes |

**Parameters:**

| Parameter | Type | Required | Description |
|---|---|---|---|
| `action` | string | Yes | Must be `available_courses` |
| `token` | string | Yes | Valid auth token |
| `acad_year` | string | No | Academic year filter. If omitted, defaults to current academic year from `acad_calender`. |
| `semester` | string | No | Semester filter. If omitted, defaults to `1`. |

**Example Request:**

```bash
curl "https://eadmin.mru.ac.ug/API/v2/academic.aspx?action=available_courses&token=a1b2c3d4e5f6...&acad_year=2024/2025&semester=2"
```

**Success Response:**

```json
{
  "status": "success",
  "data": [
    {
      "courseID": "CSC1201",
      "courseName": "Programming Fundamentals",
      "creditUnits": "3",
      "semester": "2",
      "study_year": "1"
    },
    {
      "courseID": "MTH1201",
      "courseName": "Linear Algebra",
      "creditUnits": "4",
      "semester": "2",
      "study_year": "1"
    }
  ]
}
```

**Notes:**

- Queries `acad_curriculum` joined with `acad_course` where the programme matches the student's `progid`.
- The student's `study_year` is determined from `MAX(studyyear) FROM acad_registration`.
- Courses are filtered by semester (defaults to `1` if not specified).
- Returns only courses for the student's current study year and programme.

---

### 5.5 Registered Courses

Lists courses the student is currently registered for.

| Property | Value |
|---|---|
| **URL** | `academic.aspx?action=registered_courses` |
| **Method** | `GET` or `POST` |
| **Auth Required** | Yes |

**Parameters:**

| Parameter | Type | Required | Description |
|---|---|---|---|
| `action` | string | Yes | Must be `registered_courses` |
| `token` | string | Yes | Valid auth token |
| `acad_year` | string | No | Academic year filter. If omitted, uses current academic year. |
| `semester` | string | No | Semester filter. If omitted, returns all semesters. |

**Example Request:**

```bash
curl "https://eadmin.mru.ac.ug/API/v2/academic.aspx?action=registered_courses&token=a1b2c3d4e5f6...&acad_year=2024/2025&semester=2"
```

**Success Response:**

```json
{
  "status": "success",
  "data": [
    {
      "courseID": "CSC1201",
      "courseName": "Programming Fundamentals",
      "creditUnits": "3",
      "acad_year": "2024/2025",
      "semester": "2",
      "study_year": "1",
      "registration_date": "2025-02-15 10:30:00"
    }
  ]
}
```

**Notes:**

- Queries `acad_registration` joined with `acad_course` on `courseID`.
- Returns courses where `regno = auth.UserId`.

---

### 5.6 Register Course

Registers the student for a specific course.

| Property | Value |
|---|---|
| **URL** | `academic.aspx?action=register_course` |
| **Method** | `POST` |
| **Auth Required** | Yes |

**Parameters:**

| Parameter | Type | Required | Description |
|---|---|---|---|
| `action` | string | Yes | Must be `register_course` |
| `token` | string | Yes | Valid auth token |
| `course_code` | string | Yes | The course ID to register for |
| `acad_year` | string | Yes | Academic year |
| `semester` | string | Yes | Semester |

**Example Request:**

```bash
curl -X POST "https://eadmin.mru.ac.ug/API/v2/academic.aspx?action=register_course&token=a1b2c3d4e5f6...&course_code=CSC1201&acad_year=2024/2025&semester=2"
```

**Success Response:**

```json
{
  "status": "success",
  "data": {
    "message": "Course registered successfully.",
    "course_code": "CSC1201",
    "acad_year": "2024/2025",
    "semester": "2"
  }
}
```

**Notes:**

- Before registration, checks if the student is already registered for this course in the same acad_year and semester. If so:

```json
{
  "status": "error",
  "message": "Already registered for this course.",
  "code": "DUPLICATE_REGISTRATION"
}
```

- Inserts into `acad_registration` with the student's `regno`, `courseID`, `acad_year`, `semester`, `studyyear` (from student's current study year), and `progid`.

**Error Responses:**

```json
{
  "status": "error",
  "message": "course_code, acad_year and semester are required.",
  "code": "MISSING_PARAMS"
}
```

---

### 5.7 Drop Course

Drops (deregisters) a course for the student.

| Property | Value |
|---|---|
| **URL** | `academic.aspx?action=drop_course` |
| **Method** | `POST` |
| **Auth Required** | Yes |

**Parameters:**

| Parameter | Type | Required | Description |
|---|---|---|---|
| `action` | string | Yes | Must be `drop_course` |
| `token` | string | Yes | Valid auth token |
| `course_code` | string | Yes | The course ID to drop |
| `acad_year` | string | Yes | Academic year |
| `semester` | string | Yes | Semester |

**Example Request:**

```bash
curl -X POST "https://eadmin.mru.ac.ug/API/v2/academic.aspx?action=drop_course&token=a1b2c3d4e5f6...&course_code=CSC1201&acad_year=2024/2025&semester=2"
```

**Success Response:**

```json
{
  "status": "success",
  "data": {
    "message": "Course dropped successfully.",
    "course_code": "CSC1201"
  }
}
```

**Notes:**

- Deletes from `acad_registration` where `regno`, `courseID`, `acad_year`, and `semester` all match.
- If no matching registration found, returns success silently (no error).

**Error Response (missing params):**

```json
{
  "status": "error",
  "message": "course_code, acad_year and semester are required.",
  "code": "MISSING_PARAMS"
}
```

---

### 5.8 Semester Registration

Performs semester registration (signs up for a full semester), which triggers auto-billing.

| Property | Value |
|---|---|
| **URL** | `academic.aspx?action=semester_registration` |
| **Method** | `POST` |
| **Auth Required** | Yes |

**Parameters:**

| Parameter | Type | Required | Description |
|---|---|---|---|
| `action` | string | Yes | Must be `semester_registration` |
| `token` | string | Yes | Valid auth token |
| `acad_year` | string | Yes | Academic year |
| `semester` | string | Yes | Semester |
| `study_year` | string | No | Study year. If omitted, auto-detected from `MAX(studyyear) FROM acad_registration`. |

**Example Request:**

```bash
curl -X POST "https://eadmin.mru.ac.ug/API/v2/academic.aspx?action=semester_registration&token=a1b2c3d4e5f6...&acad_year=2024/2025&semester=2&study_year=1"
```

**Success Response:**

```json
{
  "status": "success",
  "data": {
    "message": "Semester registration completed successfully.",
    "acad_year": "2024/2025",
    "semester": "2",
    "study_year": "1",
    "billing_status": "Billed"
  }
}
```

**Notes:**

- First checks for duplicate registration in `acad_semester_registration`.
- Inserts into `acad_semester_registration` with `regno`, `acad_year`, `semester`, `studyyear`, `progid`, `regdate` (NOW()), `campus`, `intake`, `session`.
- **Auto-Billing:** After registration, calls stored procedure `fin_Autobilling` on the **accounts database** (`campus_dynamics_accounts`) for both `REG` (registration fees) and `ACCOMO` (accommodation fees) billing types:
  ```sql
  CALL fin_Autobilling(@reg, @acad, @sem, @yr, 'REG')
  CALL fin_Autobilling(@reg, @acad, @sem, @yr, 'ACCOMO')
  ```
- `billing_status` reflects whether billing was successful.

**Error Responses:**

```json
{
  "status": "error",
  "message": "acad_year and semester are required.",
  "code": "MISSING_PARAMS"
}
```

```json
{
  "status": "error",
  "message": "Already registered for this semester.",
  "code": "DUPLICATE_REGISTRATION"
}
```

---

### 5.9 Registration History

Returns the student's semester registration history.

| Property | Value |
|---|---|
| **URL** | `academic.aspx?action=registration_history` |
| **Method** | `GET` or `POST` |
| **Auth Required** | Yes |

**Parameters:**

| Parameter | Type | Required | Description |
|---|---|---|---|
| `action` | string | Yes | Must be `registration_history` |
| `token` | string | Yes | Valid auth token |

**Example Request:**

```bash
curl "https://eadmin.mru.ac.ug/API/v2/academic.aspx?action=registration_history&token=a1b2c3d4e5f6..."
```

**Success Response:**

```json
{
  "status": "success",
  "data": [
    {
      "acad_year": "2024/2025",
      "semester": "1",
      "study_year": "1",
      "registration_date": "2024-08-20",
      "campus": "MAIN",
      "intake": "August",
      "session": "DAY"
    },
    {
      "acad_year": "2024/2025",
      "semester": "2",
      "study_year": "1",
      "registration_date": "2025-02-10",
      "campus": "MAIN",
      "intake": "August",
      "session": "DAY"
    }
  ]
}
```

**Notes:**

- Queries `acad_semester_registration` where `regno = auth.UserId`.
- Ordered by `acad_year DESC, semester DESC`.

---

## 6. Finance Endpoints

**Endpoint:** `finance.aspx`  
**Auth Required:** Yes (all actions)

Finance endpoints query the **accounts database** (`campus_dynamics_accounts`) using `ApiHelper.QueryAccounts()`.

### 6.1 Ledger

Returns the student's detailed financial ledger (all transactions).

| Property | Value |
|---|---|
| **URL** | `finance.aspx?action=ledger` |
| **Method** | `GET` or `POST` |
| **Auth Required** | Yes |

**Parameters:**

| Parameter | Type | Required | Description |
|---|---|---|---|
| `action` | string | Yes | Must be `ledger` |
| `token` | string | Yes | Valid auth token |
| `acad_year` | string | No | Filter by academic year. If omitted, returns all transactions. |

**Example Request:**

```bash
# All transactions
curl "https://eadmin.mru.ac.ug/API/v2/finance.aspx?action=ledger&token=a1b2c3d4e5f6..."

# Filtered by academic year
curl "https://eadmin.mru.ac.ug/API/v2/finance.aspx?action=ledger&token=a1b2c3d4e5f6...&acad_year=2024/2025"
```

**Success Response:**

```json
{
  "status": "success",
  "data": [
    {
      "trans_date": "2024-08-20",
      "description": "Tuition Fees - Semester 1",
      "debit": "1500000.00",
      "credit": "0.00",
      "balance": "1500000.00",
      "acad_year": "2024/2025",
      "semester": "1"
    },
    {
      "trans_date": "2024-09-01",
      "description": "Payment - Bank Deposit",
      "debit": "0.00",
      "credit": "500000.00",
      "balance": "1000000.00",
      "acad_year": "2024/2025",
      "semester": "1"
    }
  ]
}
```

**Notes:**

- Queries `fm_student_ledger` on the accounts database where `RegNo = auth.UserId`.
- Ordered by transaction date ascending.
- If `acad_year` is specified, adds `AND acad_year = @acad` to the query.

---

### 6.2 Balance

Returns the student's current outstanding financial balance.

| Property | Value |
|---|---|
| **URL** | `finance.aspx?action=balance` |
| **Method** | `GET` or `POST` |
| **Auth Required** | Yes |

**Parameters:**

| Parameter | Type | Required | Description |
|---|---|---|---|
| `action` | string | Yes | Must be `balance` |
| `token` | string | Yes | Valid auth token |

**Example Request:**

```bash
curl "https://eadmin.mru.ac.ug/API/v2/finance.aspx?action=balance&token=a1b2c3d4e5f6..."
```

**Success Response:**

```json
{
  "status": "success",
  "data": {
    "balance": 1250000.00,
    "currency": "UGX"
  }
}
```

**Notes:**

- Queries `SELECT SUM(amount) FROM fm_student_ledger WHERE RegNo = @reg` on the accounts database.
- Positive balance means the student owes money; negative means overpayment/credit.
- Currency is always `"UGX"` (Ugandan Shillings).
- If no ledger records exist, balance is `0`.

---

### 6.3 Fees Structure

Returns the fee structure applicable to the student.

| Property | Value |
|---|---|
| **URL** | `finance.aspx?action=fees_structure` |
| **Method** | `GET` or `POST` |
| **Auth Required** | Yes |

**Parameters:**

| Parameter | Type | Required | Description |
|---|---|---|---|
| `action` | string | Yes | Must be `fees_structure` |
| `token` | string | Yes | Valid auth token |
| `acad_year` | string | No | Academic year. If omitted, uses current academic year. |

**Example Request:**

```bash
curl "https://eadmin.mru.ac.ug/API/v2/finance.aspx?action=fees_structure&token=a1b2c3d4e5f6...&acad_year=2024/2025"
```

**Success Response:**

```json
{
  "status": "success",
  "data": [
    {
      "fee_item": "Tuition",
      "amount": "1500000.00",
      "semester": "1",
      "category": "Ugandan"
    },
    {
      "fee_item": "Functional Fees",
      "amount": "350000.00",
      "semester": "1",
      "category": "Ugandan"
    },
    {
      "fee_item": "Library Fees",
      "amount": "50000.00",
      "semester": "1",
      "category": "Ugandan"
    }
  ]
}
```

**Notes:**

- Determines fee category from the student's `nationality` field in `acad_student`:
  - If `nationality` contains `"Uganda"` → category = `"Ugandan"`
  - Otherwise → category = `"International"`
- Queries the accounts database for fee structures matching the student's `progid`, `study_year`, `acad_year`, and fee category.
- `study_year` is from `MAX(studyyear) FROM acad_registration`.

---

## 7. Timetable Endpoints

**Endpoint:** `timetable.aspx`  
**Auth Required:** Yes (all actions)

> **⚠️ Note:** These endpoints require the `acad_timetable` and `acad_exam_timetable` database tables, which **do not currently exist** in production. The endpoints will return server errors until these tables are created. See Section 12 for table schemas.

### 7.1 Lectures

Returns the lecture timetable. For students, returns their programme's timetable. For staff, returns the timetable for courses they teach.

| Property | Value |
|---|---|
| **URL** | `timetable.aspx?action=lectures` |
| **Method** | `GET` or `POST` |
| **Auth Required** | Yes |

**Parameters:**

| Parameter | Type | Required | Description |
|---|---|---|---|
| `action` | string | Yes | Must be `lectures` |
| `token` | string | Yes | Valid auth token |
| `acad_year` | string | No | Filter by academic year |
| `semester` | string | No | Filter by semester |

**Example Request (Student):**

```bash
curl "https://eadmin.mru.ac.ug/API/v2/timetable.aspx?action=lectures&token=a1b2c3d4e5f6...&acad_year=2024/2025&semester=2"
```

**Success Response (Student):**

```json
{
  "status": "success",
  "data": [
    {
      "day_of_week": "Monday",
      "start_time": "08:00",
      "end_time": "10:00",
      "course_code": "CSC1201",
      "course_name": "Programming Fundamentals",
      "room": "LH1",
      "building": "Main Block",
      "lecturer": "Muhindo mubaraka"
    },
    {
      "day_of_week": "Tuesday",
      "start_time": "10:00",
      "end_time": "12:00",
      "course_code": "MTH1201",
      "course_name": "Linear Algebra",
      "room": "LH3",
      "building": "Science Block",
      "lecturer": "Dr. Smith"
    }
  ]
}
```

**Example Request (Staff):**

```bash
curl "https://eadmin.mru.ac.ug/API/v2/timetable.aspx?action=lectures&token=f6e5d4c3b2a1...&acad_year=2024/2025&semester=2"
```

**Success Response (Staff):**

```json
{
  "status": "success",
  "data": [
    {
      "day_of_week": "Monday",
      "start_time": "08:00",
      "end_time": "10:00",
      "course_code": "CSC1201",
      "course_name": "Programming Fundamentals",
      "room": "LH1",
      "building": "Main Block",
      "programme_code": "BCS",
      "programme_name": "Bachelor of Computer Science"
    }
  ]
}
```

**Notes:**

- **Student view:** Filters by student's `progid` and `study_year`. Returns `lecturer` name from `hrm_employee.emp_name` joined via `lecturer_id`.
- **Staff view:** Filters by staff username via `hrm_employee.usernames`. Returns `programme_code` and `programme_name` instead of `lecturer`.
- Results are ordered by day of week (Monday→Sunday), then by `start_time`.
- Required table: `acad_timetable` (see Section 12).

---

### 7.2 Exams

Returns the exam timetable. For students, returns exams for their programme. For staff, returns exams they are invigilating.

| Property | Value |
|---|---|
| **URL** | `timetable.aspx?action=exams` |
| **Method** | `GET` or `POST` |
| **Auth Required** | Yes |

**Parameters:**

| Parameter | Type | Required | Description |
|---|---|---|---|
| `action` | string | Yes | Must be `exams` |
| `token` | string | Yes | Valid auth token |
| `acad_year` | string | No | Filter by academic year |
| `semester` | string | No | Filter by semester |

**Example Request:**

```bash
curl "https://eadmin.mru.ac.ug/API/v2/timetable.aspx?action=exams&token=a1b2c3d4e5f6...&acad_year=2024/2025&semester=2"
```

**Success Response (Student):**

```json
{
  "status": "success",
  "data": [
    {
      "exam_date": "2025-06-15",
      "start_time": "09:00",
      "end_time": "12:00",
      "course_code": "CSC1201",
      "course_name": "Programming Fundamentals",
      "venue": "Exam Hall A",
      "exam_type": "Final"
    }
  ]
}
```

**Success Response (Staff — invigilator view):**

```json
{
  "status": "success",
  "data": [
    {
      "exam_date": "2025-06-15",
      "start_time": "09:00",
      "end_time": "12:00",
      "course_code": "CSC1201",
      "course_name": "Programming Fundamentals",
      "venue": "Exam Hall A",
      "exam_type": "Final",
      "programme_code": "BCS"
    }
  ]
}
```

**Notes:**

- **Student view:** Filters by student's `progid` and `study_year`.
- **Staff view:** Displays exams assigned to the staff via `invigilator_id` matched to `hrm_employee.empID`.
- Results ordered by `exam_date`, then `start_time`.
- Required table: `acad_exam_timetable` (see Section 12).

---

## 8. Campus Endpoints

**Endpoint:** `campus.aspx`

This endpoint contains both **public** (no auth) and **authenticated** actions.

### 8.1 Academic Years (Public)

Returns all available academic years.

| Property | Value |
|---|---|
| **URL** | `campus.aspx?action=academic_years` |
| **Method** | `GET` or `POST` |
| **Auth Required** | **No** |

**Parameters:**

| Parameter | Type | Required | Description |
|---|---|---|---|
| `action` | string | Yes | Must be `academic_years` |

**Example Request:**

```bash
curl "https://eadmin.mru.ac.ug/API/v2/campus.aspx?action=academic_years"
```

**Success Response:**

```json
{
  "status": "success",
  "data": [
    {"acad_year": "2024/2025"},
    {"acad_year": "2023/2024"},
    {"acad_year": "2022/2023"},
    {"acad_year": "2021/2022"}
  ]
}
```

**Notes:**

- Queries `SELECT DISTINCT academic_year FROM acad_calender ORDER BY academic_year DESC`.
- If the query fails (table doesn't exist), falls back to generating academic years programmatically for the last 10 years.

---

### 8.2 Current Semester (Public)

Returns the current academic semester.

| Property | Value |
|---|---|
| **URL** | `campus.aspx?action=current_semester` |
| **Method** | `GET` or `POST` |
| **Auth Required** | **No** |

**Parameters:**

| Parameter | Type | Required | Description |
|---|---|---|---|
| `action` | string | Yes | Must be `current_semester` |

**Example Request:**

```bash
curl "https://eadmin.mru.ac.ug/API/v2/campus.aspx?action=current_semester"
```

**Success Response (from database):**

```json
{
  "status": "success",
  "data": {
    "acad_year": "2024/2025"
  }
}
```

**Fallback Response (computed from system date):**

```json
{
  "status": "success",
  "data": {
    "acad_year": "2024/2025",
    "semester": 2,
    "note": "Calculated from system date"
  }
}
```

**Notes:**

- Queries `acad_calender WHERE is_current = 1 LIMIT 1`.
- If no current semester is found or the query fails, calculates automatically:
  - Jan–Jun → Semester 2, academic year = `(year-1)/year`
  - Jul–Dec → Semester 1, academic year = `year/(year+1)`

---

### 8.3 Programmes (Public)

Returns all available academic programmes.

| Property | Value |
|---|---|
| **URL** | `campus.aspx?action=programmes` |
| **Method** | `GET` or `POST` |
| **Auth Required** | **No** |

**Parameters:**

| Parameter | Type | Required | Description |
|---|---|---|---|
| `action` | string | Yes | Must be `programmes` |

**Example Request:**

```bash
curl "https://eadmin.mru.ac.ug/API/v2/campus.aspx?action=programmes"
```

**Success Response:**

```json
{
  "status": "success",
  "data": [
    {"progcode": "BAED", "programme": "Bachelor of Arts with Education"},
    {"progcode": "BCS", "programme": "Bachelor of Computer Science"},
    {"progcode": "BBA", "programme": "Bachelor of Business Administration"},
    {"progcode": "BSWSA", "programme": "Bachelor of Social Work and Social Administration"}
  ]
}
```

**Notes:**

- Queries `acad_programme` where `progcode IS NOT NULL AND TRIM(progcode) <> ''`.
- Ordered alphabetically by programme name.

---

### 8.4 Campuses (Public)

Returns all campus locations.

| Property | Value |
|---|---|
| **URL** | `campus.aspx?action=campuses` |
| **Method** | `GET` or `POST` |
| **Auth Required** | **No** |

**Parameters:**

| Parameter | Type | Required | Description |
|---|---|---|---|
| `action` | string | Yes | Must be `campuses` |

**Example Request:**

```bash
curl "https://eadmin.mru.ac.ug/API/v2/campus.aspx?action=campuses"
```

**Success Response:**

```json
{
  "status": "success",
  "data": [
    {"campus_id": "MAIN", "campus_name": "Main Campus"},
    {"campus_id": "CITY", "campus_name": "City Campus"}
  ]
}
```

**Notes:**

- Queries `acad_campuses` where `TRIM(campus_name) <> ''`.
- Ordered by campus name.

---

### 8.5 Notices (Authenticated)

Returns active campus notices with pagination.

| Property | Value |
|---|---|
| **URL** | `campus.aspx?action=notices` |
| **Method** | `GET` or `POST` |
| **Auth Required** | Yes |

> **⚠️ Note:** This endpoint requires the `acad_notices` table, which **does not currently exist** in production.

**Parameters:**

| Parameter | Type | Required | Description |
|---|---|---|---|
| `action` | string | Yes | Must be `notices` |
| `token` | string | Yes | Valid auth token |
| `page` | int | No | Page number (default: `1`, minimum: `1`) |
| `limit` | int | No | Items per page (default: `20`, maximum: `50`) |

**Example Request:**

```bash
curl "https://eadmin.mru.ac.ug/API/v2/campus.aspx?action=notices&token=a1b2c3d4e5f6...&page=1&limit=10"
```

**Success Response:**

```json
{
  "status": "success",
  "data": {
    "notices": [
      {
        "notice_id": "1",
        "title": "Examination Timetable Released",
        "content": "The examination timetable for Semester 2 has been released...",
        "created_by": "Academic Registrar",
        "date_created": "2025-06-01 09:00",
        "target_audience": "All Students"
      }
    ],
    "pagination": {
      "page": 1,
      "limit": 10,
      "total": 15,
      "total_pages": 2
    }
  }
}
```

**Notes:**

- Queries `acad_notices WHERE Archive_Status = 'Active'`.
- Ordered by `Notice_date DESC` (newest first).
- Pagination: `LIMIT @limit OFFSET (page-1)*limit`.
- Required table: `acad_notices` (see Section 12).

---

### 8.6 Directory (Authenticated)

Returns the staff/department directory.

| Property | Value |
|---|---|
| **URL** | `campus.aspx?action=directory` |
| **Method** | `GET` or `POST` |
| **Auth Required** | Yes |

**Parameters:**

| Parameter | Type | Required | Description |
|---|---|---|---|
| `action` | string | Yes | Must be `directory` |
| `token` | string | Yes | Valid auth token |
| `category` | string | No | Filter by department name or employee type. If omitted, returns all. |

**Example Request:**

```bash
# All directory entries
curl "https://eadmin.mru.ac.ug/API/v2/campus.aspx?action=directory&token=a1b2c3d4e5f6..."

# Filter by department/category
curl "https://eadmin.mru.ac.ug/API/v2/campus.aspx?action=directory&token=a1b2c3d4e5f6...&category=IT"
```

**Success Response:**

```json
{
  "status": "success",
  "data": [
    {
      "empID": "307",
      "full_name": "Muhindo mubaraka",
      "EmpType": "Teaching",
      "emp_email": "muhindo@mru.ac.ug",
      "emp_phone": "0701234567",
      "department": "Information Technology"
    }
  ]
}
```

**Notes:**

- First tries the `mobile_GetDirectory` TableAdapter (existing stored procedure/query).
- If that fails, falls back to a direct SQL query joining `hrm_employee` → `hrm_emp_contracts` (on `empID`, where `contractStatus = 'VALID'`) → `hrm_departments` (on `departmentID = ID`).
- When `category` is provided, filters by `dept_name LIKE '%category%' OR EmpType LIKE '%category%'`.
- Ordered by `emp_name`.

---

## 9. Error Codes Reference

| Code | Description | HTTP Context |
|---|---|---|
| `MISSING_CREDENTIALS` | Username and/or password not provided | Login |
| `USER_NOT_FOUND` | No user found matching the provided username (tried all resolution paths) | Login |
| `MEMBERSHIP_NOT_FOUND` | User exists but has no membership record in the portal database | Login |
| `INVALID_PASSWORD` | Password hash does not match | Login |
| `MISSING_TOKEN` | Token parameter not provided | Validate, Logout |
| `INVALID_TOKEN` | Token is invalid, expired, or deactivated | Any authenticated endpoint |
| `AUTH_REQUIRED` | No token provided for an endpoint requiring authentication | Any authenticated endpoint |
| `NOT_FOUND` | Requested record (student/staff) not found | Profile, Photo |
| `ACCESS_DENIED` | User type does not have permission (e.g., student accessing staff-only endpoint) | Staff endpoints |
| `MISSING_PARAMS` | Required parameters missing | Various |
| `DUPLICATE_REGISTRATION` | Already registered for the course or semester | Register Course, Semester Registration |
| `INVALID_FORMAT` | Data format is invalid (e.g., malformed JSON) | Submit Marks |
| `INVALID_ACTION` | The `action` parameter is not recognized | Any endpoint |
| `SERVER_ERROR` | Internal server error (database error, exception, etc.) | Any endpoint |

---

## 10. Grading & Classification Scales

### Grading Scale

Used by the `submit_marks` action to auto-calculate grades:

| Total Score | Grade | Grade Point (GP) |
|---|---|---|
| 80 – 100 | A | 5.0 |
| 75 – 79 | B+ | 4.5 |
| 70 – 74 | B | 4.0 |
| 65 – 69 | C+ | 3.5 |
| 60 – 64 | C | 3.0 |
| 55 – 59 | D+ | 2.5 |
| 50 – 54 | D | 2.0 |
| 0 – 49 | F | 0.0 |

### Remarks

| Condition | Remark | Meaning |
|---|---|---|
| Total ≥ 50 | NP | Normal Progress |
| Total < 50 | PP | Poor Progress |

### Degree Classification (CGPA)

Used in `transcript` and `gpa` endpoints:

| CGPA Range | Classification |
|---|---|
| 4.4 – 5.0 | First Class |
| 3.6 – 4.39 | Second Class Upper |
| 2.8 – 3.59 | Second Class Lower |
| 2.0 – 2.79 | Pass |
| 0.0 – 1.99 | Below Pass |

### GPA Calculation Formula

$$GPA = \frac{\sum (CreditUnits_i \times GradePoint_i)}{\sum CreditUnits_i}$$

Where:
- $CreditUnits_i$ = credit units for course $i$
- $GradePoint_i$ = grade point for course $i$

---

## 11. Database Schema Notes

### Three Databases

| Database | Purpose | Connection Helper |
|---|---|---|
| `campus_dynamics` | Main database: students, staff, academic records, courses, programmes | `ApiHelper.Query()`, `ApiHelper.Execute()`, `ApiHelper.Scalar()` |
| `campus_dynamics_portal` | User membership/authentication (ASP.NET Membership Provider) | Used internally by `ValidatePassword()` |
| `campus_dynamics_accounts` | Financial records: ledger, billing, fee structures | `ApiHelper.QueryAccounts()` |

### Key Tables

| Table | Database | Purpose |
|---|---|---|
| `acad_student` | campus_dynamics | Student records (regno, name, programme, status) |
| `hrm_employee` | campus_dynamics | Staff records (empID, emp_name, EMP_CODE, usernames) |
| `hrm_emp_contracts` | campus_dynamics | Staff contracts (empID → departmentID, contractStatus) |
| `hrm_departments` | campus_dynamics | Departments (ID, dept_name) |
| `acad_programme` | campus_dynamics | Academic programmes (progcode, progname) |
| `acad_course` | campus_dynamics | Courses (courseID, courseName, creditUnits) |
| `acad_registration` | campus_dynamics | Student course registrations |
| `acad_semester_registration` | campus_dynamics | Semester-level registrations |
| `acad_results` | campus_dynamics | Student results/marks |
| `acad_curriculum` | campus_dynamics | Programme course mappings |
| `acad_teaching_allocation` | campus_dynamics | Staff teaching assignments (staffCode, courseID, progcode, cyear) |
| `acad_calender` | campus_dynamics | Academic calendar (academic_year, is_current) |
| `acad_campuses` | campus_dynamics | Campus locations |
| `api_tokens` | campus_dynamics | Authentication tokens (auto-created) |
| `my_aspnet_users` | campus_dynamics_portal | ASP.NET membership users |
| `my_aspnet_membership` | campus_dynamics_portal | ASP.NET membership passwords/salts |
| `fm_student_ledger` | campus_dynamics_accounts | Student financial transactions |

### Token Table Schema (Auto-Created)

```sql
CREATE TABLE IF NOT EXISTS api_tokens (
    id INT AUTO_INCREMENT PRIMARY KEY,
    token VARCHAR(128) NOT NULL,
    user_id VARCHAR(100) NOT NULL,
    user_type VARCHAR(20) NOT NULL,
    created_at DATETIME NOT NULL,
    expires_at DATETIME NOT NULL,
    is_active TINYINT(1) DEFAULT 1,
    UNIQUE KEY idx_token (token),
    KEY idx_user (user_id),
    KEY idx_expires (expires_at)
);
```

---

## 12. Known Limitations

### Missing Database Tables

The following tables do not currently exist in the production database. Endpoints referencing them will return `SERVER_ERROR`:

#### `acad_timetable` (for timetable.aspx → lectures)

Expected columns:
```sql
CREATE TABLE acad_timetable (
    id INT AUTO_INCREMENT PRIMARY KEY,
    day_of_week VARCHAR(20),          -- 'Monday', 'Tuesday', etc.
    start_time TIME,
    end_time TIME,
    course_code VARCHAR(50),          -- FK to acad_course.courseID
    programme_code VARCHAR(50),       -- FK to acad_programme.progcode
    study_year INT,
    room VARCHAR(50),
    building VARCHAR(100),
    lecturer_id INT,                  -- FK to hrm_employee.empID
    acad_year VARCHAR(20),            -- e.g. '2024/2025'
    semester VARCHAR(5)               -- e.g. '1' or '2'
);
```

#### `acad_exam_timetable` (for timetable.aspx → exams)

Expected columns:
```sql
CREATE TABLE acad_exam_timetable (
    id INT AUTO_INCREMENT PRIMARY KEY,
    exam_date DATE,
    start_time TIME,
    end_time TIME,
    course_code VARCHAR(50),          -- FK to acad_course.courseID
    programme_code VARCHAR(50),       -- FK to acad_programme.progcode
    study_year INT,
    venue VARCHAR(100),
    exam_type VARCHAR(50),            -- e.g. 'Final', 'Mid-term'
    invigilator_id INT,               -- FK to hrm_employee.empID
    acad_year VARCHAR(20),
    semester VARCHAR(5)
);
```

#### `acad_notices` (for campus.aspx → notices)

Expected columns:
```sql
CREATE TABLE acad_notices (
    ID INT AUTO_INCREMENT PRIMARY KEY,
    Notice_Title VARCHAR(500),
    Notice_detail TEXT,
    Author VARCHAR(200),
    Notice_date DATETIME,
    Target_category VARCHAR(100),     -- e.g. 'All Students', 'Staff', etc.
    Archive_Status VARCHAR(20)        -- 'Active' or 'Archived'
);
```

### Photo Files

- **Student photos:** `~/COOPERP/patientimages/{regno}.jpg` — files may not exist for all students.
- **Staff photos:** `~/COOPERP/staffimages/{empID}_photo.jpg` — files may not exist for all staff.

Consumers should handle HTTP 404 when fetching photo URLs.

### Password Hashing

The API relies on `MySQLMembershipProvider` with HMACSHA256 hashing. Users must have a valid membership record in the `campus_dynamics_portal` database. If a user exists in `acad_student` or `hrm_employee` but not in the portal membership tables, login will fail with `MEMBERSHIP_NOT_FOUND`.

### Token Management

- Tokens expire after 24 hours.
- Each login deactivates all previous active tokens for that user.
- Only one active token per user at a time.
- Expired tokens are cleaned up automatically when new tokens are generated.
- The `api_tokens` table is auto-created during the first token generation if it doesn't exist.

### Stored Procedures

The following stored procedures are used and must exist in the database:

| Procedure | Database | Used By |
|---|---|---|
| `sp_StudentTranscript` | campus_dynamics | academic.aspx → transcript |
| `sp_StudentResults` | campus_dynamics | academic.aspx → gpa |
| `fin_Autobilling` | campus_dynamics_accounts | academic.aspx → semester_registration |

---

## Appendix: Quick Reference

### All Endpoints Summary

| Endpoint | Action | Method | Auth | Description |
|---|---|---|---|---|
| `auth.aspx` | `login` | GET/POST | No | Authenticate user, get token |
| `auth.aspx` | `validate` | GET/POST | Token | Check if token is valid |
| `auth.aspx` | `logout` | GET/POST | Token | Deactivate token |
| `student.aspx` | `profile` | GET/POST | Token | Student full profile |
| `student.aspx` | `photo` | GET/POST | Token | Student photo URL |
| `student.aspx` | `lock_status` | GET/POST | Token | Account lock check |
| `student.aspx` | `summary` | GET/POST | Token | Dashboard summary |
| `staff.aspx` | `profile` | GET/POST | Token | Staff full profile |
| `staff.aspx` | `photo` | GET/POST | Token | Staff photo URL |
| `staff.aspx` | `my_courses` | GET/POST | Token (staff) | Teaching allocations |
| `staff.aspx` | `class_list` | GET/POST | Token (staff) | Students in a course |
| `staff.aspx` | `marks` | GET/POST | Token (staff) | View course marks |
| `staff.aspx` | `submit_marks` | POST | Token (staff) | Submit/update marks |
| `academic.aspx` | `results` | GET/POST | Token | Student results |
| `academic.aspx` | `transcript` | GET/POST | Token | Full transcript |
| `academic.aspx` | `gpa` | GET/POST | Token | GPA/CGPA calculation |
| `academic.aspx` | `available_courses` | GET/POST | Token | Courses for registration |
| `academic.aspx` | `registered_courses` | GET/POST | Token | Current registrations |
| `academic.aspx` | `register_course` | POST | Token | Register for a course |
| `academic.aspx` | `drop_course` | POST | Token | Drop a course |
| `academic.aspx` | `semester_registration` | POST | Token | Register for semester + billing |
| `academic.aspx` | `registration_history` | GET/POST | Token | Past semester registrations |
| `finance.aspx` | `ledger` | GET/POST | Token | Financial transactions |
| `finance.aspx` | `balance` | GET/POST | Token | Outstanding balance |
| `finance.aspx` | `fees_structure` | GET/POST | Token | Fee structure |
| `timetable.aspx` | `lectures` | GET/POST | Token | Lecture timetable ⚠️ |
| `timetable.aspx` | `exams` | GET/POST | Token | Exam timetable ⚠️ |
| `campus.aspx` | `notices` | GET/POST | Token | Campus notices ⚠️ |
| `campus.aspx` | `directory` | GET/POST | Token | Staff directory |
| `campus.aspx` | `academic_years` | GET/POST | **No** | All academic years |
| `campus.aspx` | `current_semester` | GET/POST | **No** | Current semester |
| `campus.aspx` | `programmes` | GET/POST | **No** | All programmes |
| `campus.aspx` | `campuses` | GET/POST | **No** | All campuses |

> ⚠️ = Requires database tables that don't exist yet.

### Authentication Header Alternative

While the primary method is passing `token` as a query parameter, the token can also be sent via:
- Query parameter: `?token=abc123...`
- Form POST body: `token=abc123...`

All endpoints accept both GET and POST methods (except `submit_marks`, `register_course`, `drop_course`, and `semester_registration` which should use POST).

---

*Last updated: July 2025*  
*API Version: 2.0*  
*Server: ASP.NET Web Forms on IIS — https://eadmin.mru.ac.ug/API/v2/*
