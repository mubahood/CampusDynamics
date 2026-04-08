# CampusDynamics API v2 — Complete Documentation

> **Base URL:** `https://eadmin.mru.ac.ug/API/v2/`  
> **Server:** ASP.NET Web Forms (.NET 4.0) on IIS  
> **Database:** MySQL 6.6.7 (three databases: `campus_dynamics`, `campus_dynamics_portal`, `campus_dynamics_accounts`)  
> **Authentication:** Token-based (24-hour expiry)  
> **Content-Type:** All responses are `application/json`  
> **CORS:** Fully enabled (all origins, methods, headers allowed)  
> **API Version:** 2.2 (ODEL Integration Release)

---

## Table of Contents

1. [Response Format](#1-response-format)
2. [Authentication (auth.aspx)](#2-authentication) — incl. 2.4 Ping (ODEL)
3. [Student Endpoints (student.aspx)](#3-student-endpoints) — incl. 3.5-3.8 ODEL endpoints
4. [Staff Endpoints (staff.aspx)](#4-staff-endpoints) — incl. 4.13-4.14 ODEL endpoints
5. [Academic Endpoints (academic.aspx)](#5-academic-endpoints) — incl. 5.11-5.14 ODEL endpoints
6. [Finance Endpoints (finance.aspx)](#6-finance-endpoints) — incl. 6.6-6.7 ODEL endpoints
7. [Timetable Endpoints (timetable.aspx)](#7-timetable-endpoints)
8. [Campus / Public Endpoints (campus.aspx)](#8-campus-endpoints) — incl. 8.9 Academic Calendar (ODEL)
9. [Error Codes Reference](#9-error-codes-reference)
10. [Grading & Classification Scales](#10-grading--classification-scales)
11. [Database Schema Notes](#11-database-schema-notes)
12. [Known Limitations](#12-known-limitations)
Appendix: [Quick Reference & ODEL Integration Summary](#appendix-quick-reference)

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

### 2.4 Ping (Health Check)

Tests API connectivity. No authentication required. Used by ODEL/Moodle integration to verify the API is online.

| Property | Value |
|---|---|
| **URL** | `auth.aspx?action=ping` |
| **Method** | `GET` or `POST` |
| **Auth Required** | **No** |

**Example Request:**
```
GET /API/v2/auth.aspx?action=ping
```

**Example Response:**
```json
{
  "status": "success",
  "data": {
    "status": "ok",
    "timestamp": "2025-07-15T10:30:00.0000000Z",
    "version": "2.1",
    "server": "CampusDynamics API v2"
  }
}
```

**Notes:**
- No authentication needed — useful for monitoring and connectivity checks.
- `timestamp` is UTC in ISO 8601 format.

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

### 3.5 Lookup (Identity Verification)

**ODEL Integration.** Finds a person (student or staff) by email address. This is the primary endpoint for Moodle user identity verification during registration/login.

| Property | Value |
|---|---|
| **URL** | `student.aspx?action=lookup` |
| **Method** | `GET` or `POST` |
| **Auth Required** | Yes |

**Parameters:**

| Parameter | Type | Required | Description |
|---|---|---|---|
| `token` | string | Yes | Valid API token |
| `email` | string | Yes | Email address to look up |

**Example Request:**
```
GET /API/v2/student.aspx?action=lookup&token=abc123&email=john@example.com
```

**Example Response (Student Found):**
```json
{
  "status": "success",
  "message": "Person found as student",
  "data": {
    "found": true,
    "person_type": "student",
    "mru_id": "2024/BSC/001",
    "data": {
      "regno": "2024/BSC/001",
      "entryno": "ENT001",
      "firstname": "John",
      "othername": "Doe",
      "gender": "Male",
      "programme": "Bachelor of Science in IT",
      "progcode": "BSC-IT",
      "campus": "Main Campus",
      "entry_year": "2024",
      "intake": "August",
      "session": "Day",
      "status": "Active",
      "nationality": "Ugandan",
      "phone": "0771234567",
      "email": "john@example.com",
      "date_of_birth": "2000-01-15",
      "district": "Fort Portal"
    }
  }
}
```

**Example Response (Staff Found):**
```json
{
  "status": "success",
  "message": "Person found as staff",
  "data": {
    "found": true,
    "person_type": "staff",
    "mru_id": "EMP001",
    "data": {
      "empID": 42,
      "emp_code": "EMP001",
      "emp_name": "Dr. Jane Smith",
      "username": "jsmith",
      "email": "jsmith@mru.ac.ug",
      "phone": "0701234567",
      "emp_type": "Academic",
      "status": "Active",
      "nationality": "Ugandan",
      "qualifications": "PhD Computer Science",
      "department": "Computer Science",
      "faculty": "Faculty of Science"
    }
  }
}
```

**Example Response (Not Found):**
```json
{
  "status": "success",
  "message": "No person found with this email",
  "data": {
    "found": false,
    "person_type": null,
    "mru_id": null,
    "data": null
  }
}
```

**Notes:**
- Searches `acad_student.email` and `acad_student.studemail` first, then `hrm_employee.emp_email`.
- Case-insensitive email matching.
- Returns `person_type` of `"student"` or `"staff"` so ODEL/Moodle can assign appropriate roles.

---

### 3.6 Verify Student

**ODEL Integration.** Quick student verification by registration number or entry number. Lightweight check to confirm a student exists and is active.

| Property | Value |
|---|---|
| **URL** | `student.aspx?action=verify` |
| **Method** | `GET` or `POST` |
| **Auth Required** | Yes |

**Parameters:**

| Parameter | Type | Required | Description |
|---|---|---|---|
| `token` | string | Yes | Valid API token |
| `id` | string | Yes | Student reg number or entry number |

**Example Request:**
```
GET /API/v2/student.aspx?action=verify&token=abc123&id=2024/BSC/001
```

**Example Response (Verified):**
```json
{
  "status": "success",
  "message": "Student verified",
  "data": {
    "verified": true,
    "mru_id": "2024/BSC/001",
    "full_name": "John Doe",
    "status": "Active",
    "programme_code": "BSC-IT",
    "programme_name": "Bachelor of Science in IT",
    "email": "john@example.com"
  }
}
```

**Example Response (Not Found):**
```json
{
  "status": "success",
  "message": "Student not found",
  "data": {
    "verified": false,
    "mru_id": null,
    "full_name": null,
    "status": null,
    "programme_code": null,
    "programme_name": null,
    "email": null
  }
}
```

**Notes:**
- Searches both `regno` and `entryno` fields.
- Returns basic identity info without full profile data.

---

### 3.7 Search Students

**ODEL Integration.** Search students by name, email, or student number. Staff only. Used by ODEL admin interfaces to find students.

| Property | Value |
|---|---|
| **URL** | `student.aspx?action=search` |
| **Method** | `GET` or `POST` |
| **Auth Required** | Yes (Staff only) |

**Parameters:**

| Parameter | Type | Required | Default | Description |
|---|---|---|---|---|
| `token` | string | Yes | — | Valid API token (staff) |
| `q` | string | Yes | — | Search query string |
| `type` | string | No | `any` | Search type: `name`, `email`, `student_no`, or `any` |
| `limit` | integer | No | `50` | Max results (max 200) |

**Example Request:**
```
GET /API/v2/student.aspx?action=search&token=abc123&q=john&type=name&limit=10
```

**Example Response:**
```json
{
  "status": "success",
  "data": {
    "count": 3,
    "search_type": "name",
    "query": "john",
    "results": [
      {
        "regno": "2024/BSC/001",
        "entryno": "ENT001",
        "firstname": "John",
        "othername": "Doe",
        "gender": "Male",
        "progcode": "BSC-IT",
        "programme": "Bachelor of Science in IT",
        "status": "Active",
        "email": "john@example.com",
        "phone": "0771234567"
      }
    ]
  }
}
```

**Notes:**
- Staff-only endpoint — students get `ACCESS_DENIED`.
- Case-insensitive LIKE search with wildcards.
- `type=any` searches across all fields simultaneously.
- Maximum 200 results per request.

---

### 3.8 Students by Programme

**ODEL Integration.** Get all students in a programme with pagination and filters. Staff only. Used for bulk student sync to Moodle.

| Property | Value |
|---|---|
| **URL** | `student.aspx?action=by_programme` |
| **Method** | `GET` or `POST` |
| **Auth Required** | Yes (Staff only) |

**Parameters:**

| Parameter | Type | Required | Default | Description |
|---|---|---|---|---|
| `token` | string | Yes | — | Valid API token (staff) |
| `progcode` | string | Yes | — | Programme code |
| `status` | string | No | all | Filter by student status (e.g., `Active`) |
| `acad_year` | string | No | all | Filter by academic year (e.g., `2024/2025`) |
| `page` | integer | No | `1` | Page number |
| `per_page` | integer | No | `100` | Results per page (max 500) |

**Example Request:**
```
GET /API/v2/student.aspx?action=by_programme&token=abc123&progcode=BSC-IT&status=Active&page=1&per_page=50
```

**Example Response:**
```json
{
  "status": "success",
  "data": {
    "programme_code": "BSC-IT",
    "total": 125,
    "page": 1,
    "per_page": 50,
    "total_pages": 3,
    "students": [
      {
        "regno": "2024/BSC/001",
        "entryno": "ENT001",
        "firstname": "John",
        "othername": "Doe",
        "gender": "Male",
        "progcode": "BSC-IT",
        "programme": "Bachelor of Science in IT",
        "status": "Active",
        "email": "john@example.com",
        "phone": "0771234567",
        "entry_year": "2024",
        "intake": "August",
        "nationality": "Ugandan"
      }
    ]
  }
}
```

**Notes:**
- Staff-only endpoint for bulk data sync.
- Pagination via `page` and `per_page` (max 500 per page).
- Optional `acad_year` filter checks `acad_registration` for that academic year.
- Sorted alphabetically by name.

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

### 4.7 Teaching Assignments

Returns courses assigned to the authenticated teacher from the new `acad_teaching_assignments` table. Falls back to the legacy `acad_teaching_allocation` table when no assignments are found.

| Property | Value |
|---|---|
| **URL** | `staff.aspx?action=teaching_assignments` |
| **Method** | `GET` or `POST` |
| **Auth Required** | Yes (staff only) |

**Parameters:**

| Parameter | Type | Required | Description |
|---|---|---|---|
| `action` | string | Yes | Must be `teaching_assignments` |
| `token` | string | Yes | Valid auth token |
| `acad_year` | string | No | Filter by academic year (e.g., `2024/2025`) |
| `semester` | int | No | Filter by semester (e.g., `1` or `2`) |

**Example Request:**

```bash
curl "https://eadmin.mru.ac.ug/API/v2/staff.aspx?action=teaching_assignments&token=f6e5d4c3b2a1...&acad_year=2024/2025&semester=2"
```

**Success Response:**

```json
{
  "status": "success",
  "data": {
    "total_assignments": 3,
    "assignments": [
      {
        "assignment_id": "12",
        "teacher_username": "muhindo",
        "course_id": "CSC1201",
        "course_name": "Programming Fundamentals",
        "programme_code": "BCS",
        "programme_name": "Bachelor of Computer Science",
        "acad_year": "2024/2025",
        "semester": "2",
        "study_year": "1",
        "campus_id": "1",
        "session": "Day",
        "is_active": "1",
        "assigned_by": "admin",
        "assigned_at": "2025-02-01 09:00",
        "notes": ""
      }
    ]
  }
}
```

**Notes:**

- First checks `acad_teaching_assignments` (new marks module table) for active assignments (`is_active = 1`).
- If no results found, falls back to legacy `acad_teaching_allocation` table using the teacher's `EMP_CODE`.
- Assignments from the legacy table return `assignment_id = 0` and empty `assigned_by`/`assigned_at`.
- Course and programme names are resolved via joins to `acad_courses` / `acad_programme`.

---

### 4.8 Mark Sheet

Returns the entry-level mark sheet from `acad_examresults_faculty` for a specific course context. This includes raw entered marks (coursework, test, exam), calculated weighted marks, totals, grades, and the workflow status.

| Property | Value |
|---|---|
| **URL** | `staff.aspx?action=mark_sheet` |
| **Method** | `GET` or `POST` |
| **Auth Required** | Yes (staff only) |

**Parameters:**

| Parameter | Type | Required | Description |
|---|---|---|---|
| `action` | string | Yes | Must be `mark_sheet` |
| `token` | string | Yes | Valid auth token |
| `course_id` | string | Yes | The course code (e.g., `CSC1201`) |
| `progid` | string | Yes | Programme code (e.g., `BCS`) |
| `acad_year` | string | Yes | Academic year (e.g., `2024/2025`) |
| `semester` | int | No | Semester (default: `1`) |
| `study_year` | int | No | Study year (default: `1`) |
| `campus_id` | int | No | Campus ID (default: `1`) |
| `session` | string | No | Student session (default: `Day`) |

**Example Request:**

```bash
curl "https://eadmin.mru.ac.ug/API/v2/staff.aspx?action=mark_sheet&token=f6e5d4c3b2a1...&course_id=CSC1201&progid=BCS&acad_year=2024/2025&semester=2&study_year=1"
```

**Success Response:**

```json
{
  "status": "success",
  "data": {
    "course_id": "CSC1201",
    "programme_code": "BCS",
    "acad_year": "2024/2025",
    "semester": 2,
    "study_year": 1,
    "campus_id": 1,
    "session": "Day",
    "ratios": {
      "coursework": 30,
      "test": 10,
      "exam": 60,
      "credit_units": 3
    },
    "status": "DRAFT",
    "status_detail": null,
    "total_students": 45,
    "marks_entered": 40,
    "students": [
      {
        "entry_id": "1023",
        "regno": "MRU2025003204",
        "student_name": "RITAH NAKYESERO",
        "cw_entered": "85",
        "test_entered": "70",
        "exam_entered": "65",
        "cw_mark": "25.50",
        "test_mark": "7.00",
        "exam_mark": "39.00",
        "total_mark": "71.50",
        "grade": "B"
      }
    ]
  }
}
```

**Response Fields:**

| Field | Description |
|---|---|
| `ratios` | Mark weight ratios from `acad_programmecourses` (e.g., 30/10/60 for CW/Test/Exam) |
| `status` | Workflow status: `DRAFT`, `SUBMITTED`, `DEAN_APPROVED`, `PROVISIONAL_PUBLISHED`, `FINAL_PUBLISHED` |
| `status_detail` | Full status record when available (submitted_by, submitted_at, approved_by, etc.) |
| `marks_entered` | Count of students with at least one non-zero entered mark |
| `cw_entered` / `test_entered` / `exam_entered` | Raw teacher-entered marks (out of 100) |
| `cw_mark` / `test_mark` / `exam_mark` | Weighted marks (entered × ratio / 100) |
| `total_mark` | Sum of weighted marks |
| `grade` | Auto-calculated from total_mark using grading scale |

**Notes:**

- This endpoint reads from `acad_examresults_faculty` (entry-level marks) — the teacher's working data.
- The older `marks` endpoint reads from `acad_results` (published/final marks).
- Ratios come from `acad_programmecourses` where `course_code` and `progcode` match.

---

### 4.9 Save Entry Marks

Saves entry-level marks to `acad_examresults_faculty`. Marks are saved as **DRAFT** — the teacher must call `submit_for_approval` separately to advance the workflow.

| Property | Value |
|---|---|
| **URL** | `staff.aspx?action=save_entry_marks` |
| **Method** | `POST` |
| **Auth Required** | Yes (staff only) |

**Parameters:**

| Parameter | Type | Required | Description |
|---|---|---|---|
| `action` | string | Yes | Must be `save_entry_marks` |
| `token` | string | Yes | Valid auth token |
| `marks` | string (JSON) | Yes | JSON array of mark objects (max 200 per request) |

**Marks JSON Format:**

```json
[
  {"entry_id": 1023, "cw_entered": 85, "test_entered": 70, "exam_entered": 65},
  {"entry_id": 1024, "cw_entered": 60, "test_entered": 55, "exam_entered": 72}
]
```

Each mark object must have:
- `entry_id` (int) — the row ID from `acad_examresults_faculty` (obtained from `mark_sheet`)
- `cw_entered` (number) — raw coursework mark (0–100)
- `test_entered` (number) — raw test mark (0–100)
- `exam_entered` (number) — raw exam mark (0–100)

**Example Request:**

```bash
curl -X POST "https://eadmin.mru.ac.ug/API/v2/staff.aspx?action=save_entry_marks&token=f6e5d4c3b2a1..." \
  -d 'marks=[{"entry_id":1023,"cw_entered":85,"test_entered":70,"exam_entered":65}]'
```

**Success Response:**

```json
{
  "status": "success",
  "data": {
    "updated": 1,
    "errors": 0,
    "total_processed": 1
  },
  "message": "Entry marks saved successfully"
}
```

**Auto-Calculated Fields:**

For each mark saved, the system automatically calculates:

| Field | Formula |
|---|---|
| `cw_mark` | `cw_entered × cw_ratio / 100` |
| `test_mark` | `test_entered × test_ratio / 100` |
| `exam_mark` | `exam_entered × exam_ratio / 100` |
| `total_mark` | `cw_mark + test_mark + exam_mark` |
| `grade` | Based on grading scale (see Section 10) |

Ratios are fetched per-entry from `acad_programmecourses` via the entry's `course_id` and `progid`.

**Error Responses:**

```json
{
  "status": "error",
  "message": "Maximum 200 marks per request.",
  "code": "VALIDATION_ERROR"
}
```

```json
{
  "status": "error",
  "message": "Missing marks data. Send JSON array: [{\"entry_id\":123, \"cw_entered\":25, \"test_entered\":10, \"exam_entered\":40}]",
  "code": "MISSING_PARAM"
}
```

**Notes:**

- Unlike `submit_marks` (which writes directly to `acad_results`), this endpoint writes to `acad_examresults_faculty` — the entry-level marks table that integrates with the marks workflow.
- Entries must already exist in `acad_examresults_faculty` (created when students are allocated to a mark sheet). Use `mark_sheet` to get the available `entry_id` values.

---

### 4.10 Submit for Approval

Submits a mark sheet for dean approval. Changes the workflow status from `DRAFT` to `SUBMITTED` in `acad_results_status`.

| Property | Value |
|---|---|
| **URL** | `staff.aspx?action=submit_for_approval` |
| **Method** | `POST` |
| **Auth Required** | Yes (staff only) |

**Parameters:**

| Parameter | Type | Required | Description |
|---|---|---|---|
| `action` | string | Yes | Must be `submit_for_approval` |
| `token` | string | Yes | Valid auth token |
| `course_id` | string | Yes | Course code |
| `progid` | string | Yes | Programme code |
| `acad_year` | string | Yes | Academic year |
| `semester` | int | No | Semester (default: `1`) |
| `study_year` | int | No | Study year (default: `1`) |
| `campus_id` | int | No | Campus ID (default: `1`) |
| `session` | string | No | Student session (default: `Day`) |

**Example Request:**

```bash
curl -X POST "https://eadmin.mru.ac.ug/API/v2/staff.aspx?action=submit_for_approval&token=f6e5d4c3b2a1...&course_id=CSC1201&progid=BCS&acad_year=2024/2025&semester=2&study_year=1"
```

**Success Response:**

```json
{
  "status": "success",
  "data": {
    "course_id": "CSC1201",
    "programme_code": "BCS",
    "acad_year": "2024/2025",
    "semester": 2,
    "new_status": "SUBMITTED",
    "submitted_by": "muhindo",
    "submitted_at": "2025-07-06T14:30:00.000+03:00"
  },
  "message": "Mark sheet submitted for dean approval"
}
```

**Workflow Status Transitions:**

```
DRAFT → SUBMITTED → DEAN_APPROVED → PROVISIONAL_PUBLISHED → FINAL_PUBLISHED
                  ↘ REJECTED (back to DRAFT)
```

Only sheets in `DRAFT` status can be submitted. Attempting to submit a sheet in any other status returns:

```json
{
  "status": "error",
  "message": "Sheet cannot be submitted. Current status is SUBMITTED. Only DRAFT sheets can be submitted.",
  "code": "BUSINESS_ERROR"
}
```

**Notes:**

- Uses `INSERT ... ON DUPLICATE KEY UPDATE` to upsert the status record.
- The unique key is the combination of (`course_id`, `progid`, `acadyear`, `semester`, `study_year`, `campus_id`, `stud_session`).
- Any existing `reject_reason` is cleared on resubmission.

---

### 4.11 Sheet Status

Returns the workflow status of a mark sheet from `acad_results_status`.

| Property | Value |
|---|---|
| **URL** | `staff.aspx?action=sheet_status` |
| **Method** | `GET` or `POST` |
| **Auth Required** | Yes (staff only) |

**Parameters:**

| Parameter | Type | Required | Description |
|---|---|---|---|
| `action` | string | Yes | Must be `sheet_status` |
| `token` | string | Yes | Valid auth token |
| `course_id` | string | Yes | Course code |
| `progid` | string | Yes | Programme code |
| `acad_year` | string | Yes | Academic year |
| `semester` | int | No | Semester (default: `1`) |
| `study_year` | int | No | Study year (default: `1`) |
| `campus_id` | int | No | Campus ID (default: `1`) |
| `session` | string | No | Student session (default: `Day`) |

**Example Request:**

```bash
curl "https://eadmin.mru.ac.ug/API/v2/staff.aspx?action=sheet_status&token=f6e5d4c3b2a1...&course_id=CSC1201&progid=BCS&acad_year=2024/2025&semester=2"
```

**Success Response (status record exists):**

```json
{
  "status": "success",
  "data": {
    "status": "SUBMITTED",
    "submitted_by": "muhindo",
    "submitted_at": "2025-07-06 14:30",
    "approved_by": null,
    "approved_at": null,
    "published_by": null,
    "published_at": null,
    "reject_reason": null,
    "updated_at": "2025-07-06 14:30"
  }
}
```

**Success Response (no record — implies DRAFT):**

```json
{
  "status": "success",
  "data": {
    "status": "DRAFT",
    "note": "No status record found — sheet is in draft state."
  }
}
```

**Status Values:**

| Status | Description |
|---|---|
| `DRAFT` | Initial state, teacher is entering/editing marks |
| `SUBMITTED` | Teacher has submitted for dean review |
| `DEAN_APPROVED` | Dean has approved the marks |
| `PROVISIONAL_PUBLISHED` | Marks published provisionally (visible to students) |
| `FINAL_PUBLISHED` | Marks finalized and locked |
| `REJECTED` | Dean rejected — returns to DRAFT for corrections |

---

### 4.12 Deadlines

Returns active mark submission deadlines. Useful for showing teachers when marks are due.

| Property | Value |
|---|---|
| **URL** | `staff.aspx?action=deadlines` |
| **Method** | `GET` or `POST` |
| **Auth Required** | Yes (staff only) |

**Parameters:**

| Parameter | Type | Required | Description |
|---|---|---|---|
| `action` | string | Yes | Must be `deadlines` |
| `token` | string | Yes | Valid auth token |
| `acad_year` | string | No | Filter by academic year |
| `semester` | int | No | Filter by semester |

**Example Request:**

```bash
curl "https://eadmin.mru.ac.ug/API/v2/staff.aspx?action=deadlines&token=f6e5d4c3b2a1...&acad_year=2024/2025&semester=2"
```

**Success Response:**

```json
{
  "status": "success",
  "data": {
    "total_deadlines": 2,
    "deadlines": [
      {
        "deadline_type": "Marks Submission",
        "deadline": "2025-07-15 23:59:59",
        "campus_id": "1",
        "acad_year": "2024/2025",
        "semester": "2",
        "session": "Day",
        "is_active": "1",
        "is_past_due": "0",
        "hours_remaining": "216"
      },
      {
        "deadline_type": "Late Marks Submission",
        "deadline": "2025-07-22 23:59:59",
        "campus_id": "1",
        "acad_year": "2024/2025",
        "semester": "2",
        "session": "Day",
        "is_active": "1",
        "is_past_due": "0",
        "hours_remaining": "384"
      }
    ]
  }
}
```

**Response Fields:**

| Field | Description |
|---|---|
| `deadline_type` | The activity name (e.g., "Marks Submission", "Late Marks Submission") |
| `deadline` | The deadline datetime |
| `is_past_due` | `1` if the deadline has already passed, `0` otherwise |
| `hours_remaining` | Hours until the deadline (negative if past due) |
| `is_active` | Whether the deadline is currently enforced |

**Notes:**

- Deadlines come from the `acad_deadlines` table.
- Only active deadlines (`is_active = 1`) are returned.
- `hours_remaining` is computed server-side using `TIMESTAMPDIFF(HOUR, NOW(), deadline)`.

---

### 4.13 Staff Lookup

**ODEL Integration.** Find a staff member by email address. Used by Moodle to verify staff/lecturer accounts.

| Property | Value |
|---|---|
| **URL** | `staff.aspx?action=lookup` |
| **Method** | `GET` or `POST` |
| **Auth Required** | Yes |

**Parameters:**

| Parameter | Type | Required | Description |
|---|---|---|---|
| `token` | string | Yes | Valid API token |
| `email` | string | Yes | Staff email address |

**Example Request:**
```
GET /API/v2/staff.aspx?action=lookup&token=abc123&email=jsmith@mru.ac.ug
```

**Example Response (Found):**
```json
{
  "status": "success",
  "message": "Staff member found",
  "data": {
    "found": true,
    "data": {
      "empID": 42,
      "emp_code": "EMP001",
      "emp_name": "Dr. Jane Smith",
      "username": "jsmith",
      "email": "jsmith@mru.ac.ug",
      "phone": "0701234567",
      "emp_type": "Academic",
      "status": "Active",
      "nationality": "Ugandan",
      "qualifications": "PhD Computer Science",
      "department": "Computer Science",
      "department_id": 5,
      "faculty": "Faculty of Science",
      "faculty_code": "SCI",
      "photo_url": "/API/v2/staff.aspx?action=photo&emp_code=EMP001"
    }
  }
}
```

**Example Response (Not Found):**
```json
{
  "status": "success",
  "message": "No staff member found with this email",
  "data": {
    "found": false,
    "data": null
  }
}
```

**Notes:**
- Case-insensitive email search.
- Returns department and faculty info from active contracts.
- Includes `photo_url` for profile image.

---

### 4.14 Staff by Department

**ODEL Integration.** List all staff in a department. Used by Moodle to sync department lecturer rosters.

| Property | Value |
|---|---|
| **URL** | `staff.aspx?action=by_department` |
| **Method** | `GET` or `POST` |
| **Auth Required** | Yes |

**Parameters:**

| Parameter | Type | Required | Default | Description |
|---|---|---|---|---|
| `token` | string | Yes | — | Valid API token |
| `department_id` | string | Yes | — | Department ID |
| `role` | string | No | all | Filter by emp type (e.g., `academic`) |
| `status` | string | No | `Active` | Contract status filter |

**Example Request:**
```
GET /API/v2/staff.aspx?action=by_department&token=abc123&department_id=5&role=academic
```

**Example Response:**
```json
{
  "status": "success",
  "data": {
    "department_id": "5",
    "department_name": "Computer Science",
    "faculty": "Faculty of Science",
    "filter_role": "academic",
    "filter_status": "Active",
    "total": 8,
    "staff": [
      {
        "empID": 42,
        "emp_code": "EMP001",
        "emp_name": "Dr. Jane Smith",
        "username": "jsmith",
        "email": "jsmith@mru.ac.ug",
        "phone": "0701234567",
        "emp_type": "Academic",
        "status": "Active",
        "qualifications": "PhD Computer Science",
        "department": "Computer Science",
        "faculty": "Faculty of Science"
      }
    ]
  }
}
```

**Notes:**
- Defaults to `Active` contract status if not specified.
- `role` filter is case-insensitive and matches the `EmpType` field.
- Returns department and faculty metadata alongside the staff list.

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

### 5.10 Enrollment Status

Returns a student's enrollment verification status. Useful for confirming active enrollment to third parties (employers, embassies, financial institutions, etc.). Returns student biodata, current registration status, and full registration history.

| Property | Value |
|---|---|
| **URL** | `academic.aspx?action=enrollment_status` |
| **Method** | `GET` or `POST` |
| **Auth Required** | Yes |

**Parameters:**

| Parameter | Type | Required | Description |
|---|---|---|---|
| `action` | string | Yes | Must be `enrollment_status` |
| `token` | string | Yes | Valid auth token |
| `acad_year` | string | No | Filter registrations by academic year |
| `semester` | int | No | Filter registrations by semester |

**Example Request:**

```bash
# Check overall enrollment
curl "https://eadmin.mru.ac.ug/API/v2/academic.aspx?action=enrollment_status&token=a1b2c3d4e5f6..."

# Check specific semester
curl "https://eadmin.mru.ac.ug/API/v2/academic.aspx?action=enrollment_status&token=a1b2c3d4e5f6...&acad_year=2024/2025&semester=2"
```

**Success Response:**

```json
{
  "status": "success",
  "data": {
    "student": {
      "regno": "MRU2025003204",
      "entryno": "25/U/BAED/0084/K/DAY",
      "firstname": "RITAH",
      "othername": "NAKYESERO",
      "programme": "Bachelor of Arts with Education",
      "programme_code": "BAED",
      "status": "Active",
      "entry_year": "2024/2025",
      "session": "DAY",
      "campus": "Main Campus"
    },
    "is_enrolled": true,
    "total_semesters_registered": 2,
    "registrations": [
      {
        "acad_year": "2024/2025",
        "semester": "2",
        "study_year": "1",
        "reg_status": "active",
        "registration_date": "2025-02-10",
        "campus_id": "MAIN"
      },
      {
        "acad_year": "2024/2025",
        "semester": "1",
        "study_year": "1",
        "reg_status": "active",
        "registration_date": "2024-08-20",
        "campus_id": "MAIN"
      }
    ]
  }
}
```

**Response Fields:**

| Field | Description |
|---|---|
| `student` | Student biodata including name, programme, campus, status |
| `is_enrolled` | `true` if at least one registration has status "active" or "registered" |
| `total_semesters_registered` | Count of registration records matching the filters |
| `registrations` | Array of registration records sorted newest first |

**Notes:**

- The `student` object is always returned regardless of filters.
- `is_enrolled` scans registrations for any with status "active" or "registered".
- When `acad_year` and/or `semester` are provided, only matching registrations are returned.
- Sources from `acad_registration` joined with `acad_student`, `acad_programme`, and `acad_campuses`.

---

### 5.11 Course Details

**ODEL Integration.** Get detailed information for a single course including department, credit units, and which programmes include it.

| Property | Value |
|---|---|
| **URL** | `academic.aspx?action=course_details` |
| **Method** | `GET` or `POST` |
| **Auth Required** | Yes |

**Parameters:**

| Parameter | Type | Required | Description |
|---|---|---|---|
| `token` | string | Yes | Valid API token |
| `course_code` | string | Yes | Course ID/code |

**Example Request:**
```
GET /API/v2/academic.aspx?action=course_details&token=abc123&course_code=CSC101
```

**Example Response:**
```json
{
  "status": "success",
  "data": {
    "course_code": "CSC101",
    "course_name": "Introduction to Computer Science",
    "credit_units": 4,
    "category": "Core",
    "department": "Computer Science",
    "faculty": "Faculty of Science",
    "programmes": [
      {
        "progcode": "BSC-IT",
        "programme_name": "Bachelor of Science in IT",
        "study_year": 1,
        "semester": 1
      },
      {
        "progcode": "BSC-CS",
        "programme_name": "Bachelor of Science in Computer Science",
        "study_year": 1,
        "semester": 1
      }
    ],
    "prerequisites": [
      {
        "course_code": "MTH100",
        "course_name": "Basic Mathematics"
      }
    ]
  }
}
```

**Notes:**
- `programmes` lists all programmes that include this course (from `acad_programmecourses`).
- `prerequisites` may be empty if the `acad_prerequisites` table doesn't exist.
- Course category comes from `acad_course.courseCategory`.

---

### 5.12 Course Enrollments

**ODEL Integration.** Get all students enrolled in a specific course for a given semester. Staff only. Used by Moodle to sync course rosters.

| Property | Value |
|---|---|
| **URL** | `academic.aspx?action=course_enrollments` |
| **Method** | `GET` or `POST` |
| **Auth Required** | Yes (Staff only) |

**Parameters:**

| Parameter | Type | Required | Description |
|---|---|---|---|
| `token` | string | Yes | Valid API token (staff) |
| `course_code` | string | Yes | Course ID/code |
| `acad_year` | string | Yes | Academic year (e.g., `2024/2025`) |
| `semester` | string | Yes | Semester number (e.g., `1`) |

**Example Request:**
```
GET /API/v2/academic.aspx?action=course_enrollments&token=abc123&course_code=CSC101&acad_year=2024/2025&semester=1
```

**Example Response:**
```json
{
  "status": "success",
  "data": {
    "course_code": "CSC101",
    "course_name": "Introduction to Computer Science",
    "credit_units": "4",
    "academic_year": "2024/2025",
    "semester": "1",
    "total_enrolled": 45,
    "students": [
      {
        "regno": "2024/BSC/001",
        "firstname": "John",
        "othername": "Doe",
        "email": "john@example.com",
        "progcode": "BSC-IT",
        "programme": "Bachelor of Science in IT",
        "status": "Registered",
        "phone": "0771234567",
        "gender": "Male"
      }
    ]
  }
}
```

**Notes:**
- Staff-only endpoint — students get `ACCESS_DENIED`.
- Queries `acad_course_registration` joined with `acad_student`.
- `status` is the registration status (`Registered`, `Dropped`, etc.).

---

### 5.13 Programme Curriculum

**ODEL Integration.** Get full curriculum for a programme grouped by year and semester. Used by Moodle to auto-create course structures.

| Property | Value |
|---|---|
| **URL** | `academic.aspx?action=programme_curriculum` |
| **Method** | `GET` or `POST` |
| **Auth Required** | Yes |

**Parameters:**

| Parameter | Type | Required | Description |
|---|---|---|---|
| `token` | string | Yes | Valid API token |
| `progcode` | string | Yes | Programme code |

**Example Request:**
```
GET /API/v2/academic.aspx?action=programme_curriculum&token=abc123&progcode=BSC-IT
```

**Example Response:**
```json
{
  "status": "success",
  "data": {
    "programme": {
      "progcode": "BSC-IT",
      "progname": "Bachelor of Science in IT",
      "faculty": "Faculty of Science",
      "department": "Computer Science",
      "level": "Undergraduate",
      "duration_years": 3
    },
    "total_courses": 36,
    "total_credit_units": 144,
    "curriculum": {
      "Year 1 - Semester 1": [
        {
          "course_code": "CSC101",
          "course_name": "Introduction to Computer Science",
          "credit_units": "4",
          "course_type": "Core",
          "category": "Core"
        }
      ],
      "Year 1 - Semester 2": [
        {
          "course_code": "CSC102",
          "course_name": "Programming Fundamentals",
          "credit_units": "4",
          "course_type": "Core",
          "category": "Core"
        }
      ]
    }
  }
}
```

**Notes:**
- Curriculum is grouped by `"Year X - Semester Y"` keys.
- Data from `acad_programmecourses` joined with `acad_course`.
- `total_credit_units` is the sum of all credit units in the curriculum.
- Programme metadata includes faculty, department, level, and duration.

---

### 5.14 Grading Scheme (Public)

**ODEL Integration.** Returns the grading scale used by MRU. No authentication required. Used by Moodle to configure grade mappings.

| Property | Value |
|---|---|
| **URL** | `academic.aspx?action=grading_scheme` |
| **Method** | `GET` or `POST` |
| **Auth Required** | **No** |

**Example Request:**
```
GET /API/v2/academic.aspx?action=grading_scheme
```

**Example Response:**
```json
{
  "status": "success",
  "data": {
    "institution": "Mountains of the Moon University",
    "pass_mark": 50,
    "max_gpa": 5.0,
    "total_grades": 8,
    "scale": [
      { "letter": "A",  "min_score": 90, "max_score": 100, "grade_point": 5.0, "remark": "Excellent" },
      { "letter": "B+", "min_score": 80, "max_score": 89,  "grade_point": 4.5, "remark": "Very Good" },
      { "letter": "B",  "min_score": 70, "max_score": 79,  "grade_point": 4.0, "remark": "Good" },
      { "letter": "C+", "min_score": 60, "max_score": 69,  "grade_point": 3.5, "remark": "Fairly Good" },
      { "letter": "C",  "min_score": 50, "max_score": 59,  "grade_point": 3.0, "remark": "Pass" },
      { "letter": "D+", "min_score": 45, "max_score": 49,  "grade_point": 2.5, "remark": "Marginal Pass" },
      { "letter": "D",  "min_score": 40, "max_score": 44,  "grade_point": 2.0, "remark": "Marginal Fail" },
      { "letter": "F",  "min_score": 0,  "max_score": 39,  "grade_point": 0.0, "remark": "Fail" }
    ]
  }
}
```

**Notes:**
- No authentication needed — public reference data.
- Returns hardcoded MRU grading scale by default.
- If `acad_grading_scale` table exists in the database, dynamically loads from there instead.
- `pass_mark` of 50 means grades C and above are passing.

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

### 6.4 Payment History

Returns only payment (credit) entries from the student's ledger. Useful for displaying payment receipts or a dedicated payment history screen.

| Property | Value |
|---|---|
| **URL** | `finance.aspx?action=payment_history` |
| **Method** | `GET` or `POST` |
| **Auth Required** | Yes |

**Parameters:**

| Parameter | Type | Required | Description |
|---|---|---|---|
| `action` | string | Yes | Must be `payment_history` |
| `token` | string | Yes | Valid auth token |
| `regno` | string | Staff only | Student registration number (staff can look up any student) |

**Example Request:**

```bash
# Student checking own payment history
curl "https://eadmin.mru.ac.ug/API/v2/finance.aspx?action=payment_history&token=a1b2c3d4e5f6..."

# Staff checking a student's payment history
curl "https://eadmin.mru.ac.ug/API/v2/finance.aspx?action=payment_history&token=f6e5d4c3b2a1...&regno=MRU2025003204"
```

**Success Response:**

```json
{
  "status": "success",
  "data": {
    "total_payments": 2500000.00,
    "payment_count": 3,
    "currency": "UGX",
    "payments": [
      {
        "trans_date": "2024-09-01",
        "description": "Payment - Bank Deposit",
        "debit": "0.00",
        "credit": "1000000.00",
        "acad_year": "2024/2025",
        "semester": "1"
      },
      {
        "trans_date": "2025-01-15",
        "description": "Payment - Mobile Money",
        "debit": "0.00",
        "credit": "500000.00",
        "acad_year": "2024/2025",
        "semester": "1"
      },
      {
        "trans_date": "2025-03-01",
        "description": "Payment - Bank Deposit",
        "debit": "0.00",
        "credit": "1000000.00",
        "acad_year": "2024/2025",
        "semester": "2"
      }
    ]
  }
}
```

**Notes:**

- Filters the full ledger to only entries where `credit > 0`.
- All ledger columns are preserved in each payment object.
- `total_payments` is the sum of all credit entries.
- Staff members can query any student by passing `?regno=` parameter.

---

### 6.5 Billing Summary

Returns a high-level billing summary grouped by academic year and semester. Shows total charges, payments, and balance per period.

| Property | Value |
|---|---|
| **URL** | `finance.aspx?action=billing_summary` |
| **Method** | `GET` or `POST` |
| **Auth Required** | Yes |

**Parameters:**

| Parameter | Type | Required | Description |
|---|---|---|---|
| `action` | string | Yes | Must be `billing_summary` |
| `token` | string | Yes | Valid auth token |
| `regno` | string | Staff only | Student registration number |

**Example Request:**

```bash
curl "https://eadmin.mru.ac.ug/API/v2/finance.aspx?action=billing_summary&token=a1b2c3d4e5f6..."
```

**Success Response:**

```json
{
  "status": "success",
  "data": {
    "overall_charges": 3500000.00,
    "overall_payments": 2500000.00,
    "overall_balance": 1000000.00,
    "currency": "UGX",
    "periods": [
      {
        "period": "2024/2025_S1",
        "charges": 1750000.00,
        "payments": 1500000.00,
        "balance": 250000.00
      },
      {
        "period": "2024/2025_S2",
        "charges": 1750000.00,
        "payments": 1000000.00,
        "balance": 750000.00
      }
    ]
  }
}
```

**Response Fields:**

| Field | Description |
|---|---|
| `overall_charges` | Total debit entries across all periods |
| `overall_payments` | Total credit entries across all periods |
| `overall_balance` | `overall_charges - overall_payments` (positive = owes) |
| `periods` | Array of period summaries |
| `periods[].period` | Key in format `{acad_year}_S{semester}` (e.g., `2024/2025_S1`) |
| `periods[].charges` | Total debits for the period |
| `periods[].payments` | Total credits for the period |
| `periods[].balance` | `charges - payments` for the period |

**Notes:**

- Groups ledger entries by `acad_year` and `semester` columns (if available in the ledger data).
- If `acad_year` or `semester` columns are missing from the ledger, entries are grouped under an `"overall"` key.
- Positive balance means the student owes money.

---

### 6.6 Fee Status (Clearance Check)

**ODEL Integration.** Check fee clearance status for a student. Returns `cleared`, `partial`, or `not_cleared`. Used by Moodle to gate access to resources based on payment status.

| Property | Value |
|---|---|
| **URL** | `finance.aspx?action=fee_status` |
| **Method** | `GET` or `POST` |
| **Auth Required** | Yes |

**Parameters:**

| Parameter | Type | Required | Default | Description |
|---|---|---|---|---|
| `token` | string | Yes | — | Valid API token |
| `regno` | string | Staff only | — | Student reg number (staff can query any student) |
| `acad_year` | string | No | all | Filter by academic year |
| `semester` | string | No | all | Filter by semester |

**Example Request:**
```
GET /API/v2/finance.aspx?action=fee_status&token=abc123&regno=2024/BSC/001&acad_year=2024/2025
```

**Example Response:**
```json
{
  "status": "success",
  "data": {
    "regno": "2024/BSC/001",
    "fee_status": "partial",
    "total_fees": 2500000,
    "amount_paid": 1800000,
    "balance": 700000,
    "currency": "UGX",
    "last_payment_date": "2025-06-15",
    "has_financial_lock": false,
    "academic_year": "2024/2025",
    "semester": ""
  }
}
```

**Fee Status Values:**

| Status | Meaning |
|---|---|
| `cleared` | Balance is zero or negative (paid in full or overpaid) |
| `partial` | Some payment made but balance remains |
| `not_cleared` | No payments made at all |

**Notes:**
- Students can only check their own fee status. Staff can check any student via `?regno=`.
- `has_financial_lock` checks the `studLock` field in `acad_student`.
- When no `acad_year` filter is provided, returns cumulative status across all periods.
- Data from `fm_student_ledger` in the accounts database.

---

### 6.7 Bulk Fee Check

**ODEL Integration.** Check fee status for multiple students in a single request. Staff only. Used by Moodle for bulk enrollment clearance checks.

| Property | Value |
|---|---|
| **URL** | `finance.aspx?action=bulk_fee_check` |
| **Method** | `POST` |
| **Auth Required** | Yes (Staff only) |

**Request Body (JSON):**
```json
{
  "students": ["2024/BSC/001", "2024/BSC/002", "2024/BSC/003"]
}
```

**Parameters:**

| Parameter | Type | Required | Description |
|---|---|---|---|
| `token` | string | Yes | Valid API token (staff) |
| `acad_year` | string | No | Filter by academic year |
| `students` | string | Alternative | Comma-separated list (query param fallback) |

**Example Request:**
```
POST /API/v2/finance.aspx?action=bulk_fee_check&token=abc123&acad_year=2024/2025
Content-Type: application/json

{"students": ["2024/BSC/001", "2024/BSC/002", "2024/BSC/003"]}
```

**Example Response:**
```json
{
  "status": "success",
  "data": {
    "academic_year": "2024/2025",
    "total_checked": 3,
    "currency": "UGX",
    "results": [
      {
        "regno": "2024/BSC/001",
        "fee_status": "cleared",
        "total_fees": 2500000,
        "amount_paid": 2500000,
        "balance": 0
      },
      {
        "regno": "2024/BSC/002",
        "fee_status": "partial",
        "total_fees": 2500000,
        "amount_paid": 1200000,
        "balance": 1300000
      },
      {
        "regno": "2024/BSC/003",
        "fee_status": "not_cleared",
        "total_fees": 2500000,
        "amount_paid": 0,
        "balance": 2500000
      }
    ]
  }
}
```

**Notes:**
- Staff-only endpoint — students get `ACCESS_DENIED`.
- Maximum 200 students per request.
- Accepts JSON POST body or comma-separated `students` query parameter as fallback.
- If a student lookup fails, their entry shows `fee_status: "error"`.

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

### 8.3 Programmes (Public) — Enhanced for ODEL

Returns all available academic programmes with faculty, department, level, and duration information.

| Property | Value |
|---|---|
| **URL** | `campus.aspx?action=programmes` |
| **Method** | `GET` or `POST` |
| **Auth Required** | **No** |

**Parameters:**

| Parameter | Type | Required | Default | Description |
|---|---|---|---|---|
| `action` | string | Yes | — | Must be `programmes` |
| `faculty_code` | string | No | all | Filter by faculty code |
| `level` | string | No | all | Filter by programme level (e.g., `Undergraduate`) |

**Example Request:**

```bash
curl "https://eadmin.mru.ac.ug/API/v2/campus.aspx?action=programmes&faculty_code=SCI"
```

**Success Response:**

```json
{
  "status": "success",
  "data": {
    "count": 4,
    "programmes": [
      {
        "progcode": "BSC-IT",
        "programme": "Bachelor of Science in IT",
        "faculty_code": "SCI",
        "faculty": "Faculty of Science",
        "department": "Computer Science",
        "level": "Undergraduate",
        "duration_years": 3,
        "study_mode": "Full-time"
      }
    ]
  }
}
```

**Notes:**

- Queries `acad_programme` joined with `acad_faculty` and `hrm_departments`.
- Optional filters: `faculty_code` and `level`.
- `duration_years` and `study_mode` from `progduration` and `progtype` columns.
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

### 8.7 Faculties (Public) — Enhanced for ODEL

Returns all academic faculties with nested departments. Enhanced for ODEL integration to show organizational structure.

| Property | Value |
|---|---|
| **URL** | `campus.aspx?action=faculties` |
| **Method** | `GET` or `POST` |
| **Auth Required** | **No** |

**Parameters:**

| Parameter | Type | Required | Description |
|---|---|---|---|
| `action` | string | Yes | Must be `faculties` |

**Example Request:**

```bash
curl "https://eadmin.mru.ac.ug/API/v2/campus.aspx?action=faculties"
```

**Success Response:**

```json
{
  "status": "success",
  "data": {
    "count": 5,
    "faculties": [
      {
        "faculty_code": "FSAS",
        "faculty_name": "Faculty of Science and Applied Science",
        "departments": [
          { "department_id": "5", "department_name": "Computer Science" },
          { "department_id": "8", "department_name": "Mathematics" },
          { "department_id": "12", "department_name": "Biology" }
        ]
      },
      {
        "faculty_code": "FBMSE",
        "faculty_name": "Faculty of Business, Management Science and Economics",
        "departments": [
          { "department_id": "3", "department_name": "Accounting" },
          { "department_id": "7", "department_name": "Business Administration" }
        ]
      }
    ]
  }
}
```

**Notes:**

- Each faculty now includes a `departments` array with all departments under it.
- Queries `acad_faculty` and `hrm_departments` tables with grouping.
- Only returns faculties and departments with non-empty names.
- Ordered alphabetically by faculty name, departments ordered alphabetically within each faculty.

---

### 8.8 Departments (Public)

Returns all departments, optionally filtered by faculty code. Each department includes its parent faculty.

| Property | Value |
|---|---|
| **URL** | `campus.aspx?action=departments` |
| **Method** | `GET` or `POST` |
| **Auth Required** | **No** |

**Parameters:**

| Parameter | Type | Required | Description |
|---|---|---|---|
| `action` | string | Yes | Must be `departments` |
| `faculty_code` | string | No | Filter departments by faculty code (e.g., `FBMSE`) |

**Example Request:**

```bash
# All departments
curl "https://eadmin.mru.ac.ug/API/v2/campus.aspx?action=departments"

# Departments in a specific faculty
curl "https://eadmin.mru.ac.ug/API/v2/campus.aspx?action=departments&faculty_code=FBMSE"
```

**Success Response:**

```json
{
  "status": "success",
  "data": {
    "count": 3,
    "faculty_filter": "FBMSE",
    "departments": [
      {
        "department_id": "5",
        "department_name": "Accounting",
        "faculty_code": "FBMSE",
        "faculty_name": "Faculty of Business, Management Science and Economics"
      },
      {
        "department_id": "12",
        "department_name": "Business Administration",
        "faculty_code": "FBMSE",
        "faculty_name": "Faculty of Business, Management Science and Economics"
      },
      {
        "department_id": "8",
        "department_name": "Economics",
        "faculty_code": "FBMSE",
        "faculty_name": "Faculty of Business, Management Science and Economics"
      }
    ]
  }
}
```

**Response Fields:**

| Field | Description |
|---|---|
| `count` | Total departments returned |
| `faculty_filter` | The faculty code used to filter, or `"all"` if not filtered |
| `departments[].department_id` | Internal department ID |
| `departments[].department_name` | Department name |
| `departments[].faculty_code` | Parent faculty code |
| `departments[].faculty_name` | Parent faculty name (resolved via JOIN) |

**Notes:**

- Queries `hrm_departments` joined with `acad_faculty` on `fax_code`.
- Only returns departments with non-empty names.
- Ordered alphabetically by department name.

---

### 8.9 Academic Calendar (Public)

**ODEL Integration.** Returns the academic calendar with semester dates, exam periods, and registration deadlines.

| Property | Value |
|---|---|
| **URL** | `campus.aspx?action=academic_calendar` |
| **Method** | `GET` or `POST` |
| **Auth Required** | **No** |

**Parameters:**

| Parameter | Type | Required | Default | Description |
|---|---|---|---|---|
| `acad_year` | string | No | all | Filter by academic year (e.g., `2024/2025`) |

**Example Request:**
```
GET /API/v2/campus.aspx?action=academic_calendar&acad_year=2024/2025
```

**Example Response:**
```json
{
  "status": "success",
  "data": {
    "current_academic_year": "2024/2025",
    "current_semester": "2",
    "total_periods": 2,
    "periods": [
      {
        "acad_year": "2024/2025",
        "semester": "1",
        "semester_start": "2024-08-15",
        "semester_end": "2024-12-15",
        "exam_start": "2024-12-01",
        "exam_end": "2024-12-15",
        "registration_deadline": "2024-09-01",
        "is_current": 0
      },
      {
        "acad_year": "2024/2025",
        "semester": "2",
        "semester_start": "2025-01-15",
        "semester_end": "2025-06-15",
        "exam_start": "2025-06-01",
        "exam_end": "2025-06-15",
        "registration_deadline": "2025-02-01",
        "is_current": 1
      }
    ]
  }
}
```

**Notes:**
- No authentication required — public information.
- Data from `acad_calender` table.
- If the table is not fully configured, returns basic data calculated from the system date.
- `is_current` indicates the currently active period.
- Date fields may be empty strings if not set in the database.

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
| `VALIDATION_ERROR` | Data failed validation (e.g., exceeds max batch size) | Save Entry Marks |
| `BUSINESS_ERROR` | Business rule violation (e.g., submitting a non-DRAFT sheet) | Submit for Approval |
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
| `acad_teaching_allocation` | campus_dynamics | Legacy staff teaching assignments (staffCode, courseID, progcode, cyear) |
| `acad_teaching_assignments` | campus_dynamics | New marks-module teaching assignments (teacher_username, course_id, progid) |
| `acad_examresults_faculty` | campus_dynamics | Entry-level marks (teacher working data before approval) |
| `acad_results_status` | campus_dynamics | Marks workflow status (DRAFT → SUBMITTED → DEAN_APPROVED → PUBLISHED) |
| `acad_deadlines` | campus_dynamics | Mark submission deadlines per activity/campus/session |
| `acad_faculty` | campus_dynamics | Academic faculties (fax_code, faculty_name) |
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
| `auth.aspx` | `ping` | GET/POST | **No** | 🆕 Health check / connectivity test |
| `student.aspx` | `profile` | GET/POST | Token | Student full profile |
| `student.aspx` | `photo` | GET/POST | Token | Student photo URL |
| `student.aspx` | `lock_status` | GET/POST | Token | Account lock check |
| `student.aspx` | `summary` | GET/POST | Token | Dashboard summary |
| `student.aspx` | `lookup` | GET/POST | Token | 🆕 Find person by email (ODEL) |
| `student.aspx` | `verify` | GET/POST | Token | 🆕 Quick student verification (ODEL) |
| `student.aspx` | `search` | GET/POST | Token (staff) | 🆕 Search students (ODEL) |
| `student.aspx` | `by_programme` | GET/POST | Token (staff) | 🆕 Students by programme (ODEL) |
| `staff.aspx` | `profile` | GET/POST | Token | Staff full profile |
| `staff.aspx` | `photo` | GET/POST | Token | Staff photo URL |
| `staff.aspx` | `my_courses` | GET/POST | Token (staff) | Teaching allocations |
| `staff.aspx` | `class_list` | GET/POST | Token (staff) | Students in a course |
| `staff.aspx` | `marks` | GET/POST | Token (staff) | View course marks |
| `staff.aspx` | `submit_marks` | POST | Token (staff) | Submit/update marks |
| `staff.aspx` | `teaching_assignments` | GET/POST | Token (staff) | Teaching assignments (new + legacy) |
| `staff.aspx` | `mark_sheet` | GET/POST | Token (staff) | Entry-level mark sheet |
| `staff.aspx` | `save_entry_marks` | POST | Token (staff) | Save marks to faculty table |
| `staff.aspx` | `submit_for_approval` | POST | Token (staff) | Submit sheet for dean approval |
| `staff.aspx` | `sheet_status` | GET/POST | Token (staff) | Marks workflow status |
| `staff.aspx` | `deadlines` | GET/POST | Token (staff) | Submission deadlines |
| `staff.aspx` | `lookup` | GET/POST | Token | 🆕 Find staff by email (ODEL) |
| `staff.aspx` | `by_department` | GET/POST | Token | 🆕 Staff in a department (ODEL) |
| `academic.aspx` | `results` | GET/POST | Token | Student results |
| `academic.aspx` | `transcript` | GET/POST | Token | Full transcript |
| `academic.aspx` | `gpa` | GET/POST | Token | GPA/CGPA calculation |
| `academic.aspx` | `available_courses` | GET/POST | Token | Courses for registration |
| `academic.aspx` | `registered_courses` | GET/POST | Token | Current registrations |
| `academic.aspx` | `register_course` | POST | Token | Register for a course |
| `academic.aspx` | `drop_course` | POST | Token | Drop a course |
| `academic.aspx` | `semester_registration` | POST | Token | Register for semester + billing |
| `academic.aspx` | `registration_history` | GET/POST | Token | Past semester registrations |
| `academic.aspx` | `enrollment_status` | GET/POST | Token | Enrollment verification |
| `academic.aspx` | `course_details` | GET/POST | Token | 🆕 Single course metadata (ODEL) |
| `academic.aspx` | `course_enrollments` | GET/POST | Token (staff) | 🆕 Students in a course (ODEL) |
| `academic.aspx` | `programme_curriculum` | GET/POST | Token | 🆕 Programme curriculum (ODEL) |
| `academic.aspx` | `grading_scheme` | GET/POST | **No** | 🆕 Grading scale (ODEL) |
| `finance.aspx` | `ledger` | GET/POST | Token | Financial transactions |
| `finance.aspx` | `balance` | GET/POST | Token | Outstanding balance |
| `finance.aspx` | `fees_structure` | GET/POST | Token | Fee structure |
| `finance.aspx` | `payment_history` | GET/POST | Token | Payment receipts/history |
| `finance.aspx` | `billing_summary` | GET/POST | Token | Charges vs payments by period |
| `finance.aspx` | `fee_status` | GET/POST | Token | 🆕 Fee clearance status (ODEL) |
| `finance.aspx` | `bulk_fee_check` | POST | Token (staff) | 🆕 Bulk fee check (ODEL) |
| `timetable.aspx` | `lectures` | GET/POST | Token | Lecture timetable ⚠️ |
| `timetable.aspx` | `exams` | GET/POST | Token | Exam timetable ⚠️ |
| `campus.aspx` | `notices` | GET/POST | Token | Campus notices ⚠️ |
| `campus.aspx` | `directory` | GET/POST | Token | Staff directory |
| `campus.aspx` | `academic_years` | GET/POST | **No** | All academic years |
| `campus.aspx` | `current_semester` | GET/POST | **No** | Current semester |
| `campus.aspx` | `programmes` | GET/POST | **No** | All programmes (enhanced) |
| `campus.aspx` | `campuses` | GET/POST | **No** | All campuses |
| `campus.aspx` | `faculties` | GET/POST | **No** | All faculties (enhanced) |
| `campus.aspx` | `departments` | GET/POST | **No** | All departments |
| `campus.aspx` | `academic_calendar` | GET/POST | **No** | 🆕 Academic calendar (ODEL) |

> ⚠️ = Requires database tables that don't exist yet.  
> 🆕 = New endpoint added for ODEL/Moodle integration.

### ODEL Integration Summary

The following endpoints are specifically designed for Moodle ODEL integration:

| ODEL Requirement | Endpoint | Action |
|---|---|---|
| Connectivity Check | `auth.aspx` | `ping` |
| Identity Verification | `student.aspx` | `lookup` |
| Student Verification | `student.aspx` | `verify` |
| Student Search | `student.aspx` | `search` |
| Students by Programme | `student.aspx` | `by_programme` |
| Staff Lookup | `staff.aspx` | `lookup` |
| Staff by Department | `staff.aspx` | `by_department` |
| Course Metadata | `academic.aspx` | `course_details` |
| Course Roster | `academic.aspx` | `course_enrollments` |
| Programme Curriculum | `academic.aspx` | `programme_curriculum` |
| Grading Scale | `academic.aspx` | `grading_scheme` |
| Fee Clearance | `finance.aspx` | `fee_status` |
| Bulk Fee Check | `finance.aspx` | `bulk_fee_check` |
| Academic Calendar | `campus.aspx` | `academic_calendar` |
| Programmes (Enhanced) | `campus.aspx` | `programmes` |
| Faculties (Enhanced) | `campus.aspx` | `faculties` |

### Authentication Header Alternative

While the primary method is passing `token` as a query parameter, the token can also be sent via:
- Query parameter: `?token=abc123...`
- Form POST body: `token=abc123...`

All endpoints accept both GET and POST methods (except `submit_marks`, `register_course`, `drop_course`, `semester_registration`, and `bulk_fee_check` which should use POST).

### ODEL Webhook Support (Planned)

Webhook support for real-time notifications (enrollment changes, grade updates, fee payments) is planned for a future release. ODEL systems should currently use polling with the above endpoints.

---

*Last updated: July 2025*  
*API Version: 2.2 (ODEL Integration Release — 14 new endpoints + 2 enhanced for Moodle integration)*  
*Server: ASP.NET Web Forms on IIS — https://eadmin.mru.ac.ug/API/v2/*
