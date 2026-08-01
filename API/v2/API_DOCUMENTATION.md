# CampusDynamics API v2 — Complete Documentation

> **Base URL:** `https://eadmin.mru.ac.ug/API/v2/`  
> **Server:** ASP.NET Web Forms (.NET 4.0) on IIS  
> **Database:** MySQL 6.6.7 (three databases: `campus_dynamics`, `campus_dynamics_portal`, `campus_dynamics_accounts`)  
> **Authentication:** Token-based (24-hour expiry)  
> **Content-Type:** All responses are `application/json`  
> **CORS:** Fully enabled (all origins, methods, headers allowed)  
> **API Version:** 2.7 (Lecturer Mark Requests workflow)

---

## Table of Contents

1. [Response Format](#1-response-format)
2. [Authentication (auth.aspx)](#2-authentication) — incl. 2.4 Ping (ODEL)
3. [Student Endpoints (student.aspx)](#3-student-endpoints) — incl. 3.5-3.8 ODEL endpoints
4. [Staff Endpoints (staff.aspx)](#4-staff-endpoints) — incl. 4.7 Filter Options, 4.7b All Courses, 4.13-4.14 ODEL, 4.15-4.20 Mark Requests, 4.21-4.28 Provisional Marks (bulk save, stats, class list), 4.29 Student Search, 4.30-4.32 Course Self-Allocation, 4.33-4.38 Course Registration, 4.39-4.41 Lecturer Mark Requests
5. [Academic Endpoints (academic.aspx)](#5-academic-endpoints) — incl. 5.11-5.14 ODEL endpoints
6. [Finance Endpoints (finance.aspx)](#6-finance-endpoints) — incl. 6.6-6.7 ODEL endpoints, 6.8 Fee Access Policy
7. [Timetable Endpoints (timetable.aspx)](#7-timetable-endpoints)
8. [Campus / Public Endpoints (campus.aspx)](#8-campus-endpoints) — incl. 8.9 Academic Calendar (ODEL)
8a. [Support Tickets (support.aspx)](#8a-support-tickets-supportaspx) — Student help-desk ticketing system
9. [Applicant Endpoints (apply.aspx)](#9-applicant-endpoints-applyaspx) — Full application lifecycle for mobile app
10. [Admissions Management (admissions.aspx)](#10-admissions-management-admissionsaspx) — Staff-side admissions
11. [Error Codes Reference](#11-error-codes-reference)
12. [Grading & Classification Scales](#12-grading--classification-scales)
13. [Database Schema Notes](#13-database-schema-notes)
14. [Known Limitations](#14-known-limitations)
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

### 3.9 ID Card Printing Status

Returns the student's ID card printing status from the OmniPass card system. Results are cached for 6 hours in the `acad_student` table — pass `refresh=1` to force a live API call.

| Property | Value |
|---|---|
| **URL** | `student.aspx?action=id_card` |
| **Method** | GET or POST |
| **Auth Required** | Yes |

**Parameters:**

| Parameter | Type | Required | Description |
|---|---|---|---|
| `regno` | string | Staff only | Student registration number. Students always get their own card. |
| `refresh` | `1` / `0` | No | Pass `1` to bypass the 6-hour cache and call OmniPass live. Default: `0`. |

**Success Response:**

```json
{
  "status": "success",
  "data": {
    "regno": "MRU2025003204",
    "status": "PRINTED",
    "status_label": "Printed",
    "card_printed": true,
    "message": "ID card has been printed and is ready for collection.",
    "collection_note": "Your ID card is ready. Please visit the Student Services office with your admission letter or registration slip to collect it.",
    "checked_at": "2026-05-24 08:15",
    "from_cache": true,
    "card_record": {
      "card_id": 412,
      "card_type": "STUDENT",
      "print_status": "PRINTED",
      "expiry_date": "2027-08-31",
      "acadyear": "2026/2027",
      "semester": "1",
      "date_created": "2026-05-20 09:00"
    }
  }
}
```

**`status` Values:**

| Value | `status_label` | `card_printed` | Meaning |
|---|---|---|---|
| `PRINTED` | Printed | `true` | Card has been printed — ready for collection |
| `NOT_PRINTED` | Not Printed | `false` | Card is in the batch queue but not yet printed |
| `NOT_FOUND` | Not in System | `false` | Student not found in OmniPass — visit Student Services |
| `ERROR` | Check Failed | `false` | OmniPass API call failed; try again or visit Student Services |
| `UNKNOWN` | Unknown | `false` | No status on record yet — try `refresh=1` |

**`card_record` field:**  
Present when an `acad_student_cards` record exists. This tracks the internal card management workflow (`PENDING → READY → PRINTED → TAKEN`). It is separate from the OmniPass printing status and may be `null` if no card has been issued in the system yet.

**`from_cache`:**  
`true` means the result came from the database cache (up to 6 hours old). `false` means it was retrieved live from OmniPass this request. Pass `?refresh=1` to always get a live result.

**`collection_note`:**  
Human-readable guidance string ready to display directly to the student in the app.

**Error Responses:**

| Code | Message |
|---|---|
| `MISSING_PARAM` | Staff must supply ?regno= |
| `UNAUTHORIZED` | Missing or invalid token |

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

- Staff identity is resolved by matching `hrm_employee` on `usernames` OR `EMP_CODE` (whichever matches the token's UserId). This dual-match ensures staff whose portal username is their employee code are not missed.
- Courses are merged from three sources, deduplicated by `course_code + programme_code`:
  1. **`acad_programmecourses`** (primary) — rows where `lecturer_id = empID` and `is_lecturere_assigned = 'YES'`. Source = `"programme_assignment"`. These are courses set via self-allocation or admin assignment.
  2. **`acad_teaching_assignments`** — newer marks-module assignments by `teacher_username`. Source = `"assignments"`.
  3. **`acad_teaching_allocation`** — legacy allocations by `staffCode`. Source = `"allocation"`.
- The `source` field in each row tells the frontend which table the record came from.
- `acad_year` is empty string for `programme_assignment` rows (that table has no academic year column).
- Use `course_allocation_search` + `course_allocation_submit` to let a lecturer add courses to source 1.

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

> **Superseded.** This section describes the legacy `class_list` implementation that sourced from `acad_registration`. The current implementation is documented in [Section 4.28 Class List (Enhanced)](#428-class-list-enhanced) — use that instead. The URL (`staff.aspx?action=class_list`) is the same; the parameter name changed from `course_code` to `course_id` and the data source is now `campus_dynamics_portal.acad_course_registration`, which includes provisional mark status per student.

See **[4.28 Class List (Enhanced)](#428-class-list-enhanced)** for the current reference.

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

### 4.7 Filter Options

Returns all filter dropdown data for the provisional marks interface, scoped to the authenticated teacher's assigned courses. Clients should call this once on page load to populate Year, Programme, Course, Status, and Page Size controls before calling `provisional_marks_list`.

| Property | Value |
|---|---|
| **URL** | `staff.aspx?action=filter_options` |
| **Method** | `GET` or `POST` |
| **Auth Required** | Yes (staff only) |

**Parameters:**

| Parameter | Type | Required | Description |
|---|---|---|---|
| `action` | string | Yes | Must be `filter_options` |
| `token` | string | Yes | Valid auth token |
| `acad_year` | string | No | Scope programme/course lists to a specific academic year |
| `semester` | int | No | Scope year/programme/course lists to a specific semester |

**Example Request:**

```bash
curl "https://eadmin.mru.ac.ug/API/v2/staff.aspx?action=filter_options&token=f6e5d4c3b2a1..."
```

**Success Response:**

```json
{
  "status": "success",
  "data": {
    "years": [
      { "value": "2024/2025", "label": "2024/2025" },
      { "value": "2023/2024", "label": "2023/2024" }
    ],
    "semesters": [
      { "value": 1, "label": "Semester 1" },
      { "value": 2, "label": "Semester 2" },
      { "value": 3, "label": "Semester 3" }
    ],
    "programmes": [
      { "value": "BCS", "label": "Bachelor of Computer Science" },
      { "value": "BBA", "label": "Bachelor of Business Administration" }
    ],
    "courses": [
      {
        "value": "CSC1201",
        "label": "Programming Fundamentals",
        "programme_code": "BCS",
        "acad_year": "2024/2025",
        "semester": "2"
      }
    ],
    "statuses": [
      { "value": "",            "label": "All Statuses" },
      { "value": "not_entered", "label": "Not Entered" },
      { "value": "pending",     "label": "Pending Review" },
      { "value": "approved",    "label": "Approved" },
      { "value": "rejected",    "label": "Rejected" },
      { "value": "published",   "label": "Published" }
    ],
    "page_sizes": [
      { "value": 25,  "label": "25 per page" },
      { "value": 50,  "label": "50 per page" },
      { "value": 100, "label": "100 per page" },
      { "value": 200, "label": "200 per page" }
    ]
  }
}
```

**Notes:**

- `years` is derived from `campus_dynamics_portal.acad_course_registration` rows where the teacher is authorized — only years that have actual student registrations for this teacher's courses are returned.
- `programmes` is similarly scoped — only programmes with portal registrations for this teacher's courses appear.
- `courses` comes from `acad_teaching_assignments` (new) merged with `acad_teaching_allocation` (legacy), deduplicated by `course_code|programme_code`.
- `semesters`, `statuses`, and `page_sizes` are static lists identical to those in the portal UI.
- Authorization uses triple-source: `acad_teaching_assignments`, `acad_programmecourses.lecturer_id`, and `acad_teaching_allocation.staffCode`.
- Pass `acad_year` and/or `semester` to narrow the scope of `years`, `programmes`, and `courses` returned.

---

### 4.7b All Courses

Returns the full catalogue of course codes and names from `acad_course`, joined to `acad_programmecourses` for programme context. **No assignment restriction** — any authenticated staff member can call this, including admins and ICT staff who are not lecturers. Use this to power a searchable course-code dropdown in mark-entry flows.

| Property | Value |
|---|---|
| **URL** | `staff.aspx?action=all_courses` |
| **Method** | `GET` or `POST` |
| **Auth Required** | Yes (any staff token) |

**Parameters:**

| Parameter | Type | Required | Default | Description |
|---|---|---|---|---|
| `action` | string | Yes | — | Must be `all_courses` |
| `token` | string | Yes | — | Valid auth token |
| `q` | string | No | — | Keyword search on course code or course name (partial match) |
| `prog_code` | string | No | — | Filter to a single programme code (e.g., `BCS`) |
| `page` | int | No | 1 | Page number |
| `size` | int | No | 50 | Page size (max 200) |

**Example Requests:**

```bash
# Browse all courses (first 50)
curl "https://eadmin.mru.ac.ug/API/v2/staff.aspx?action=all_courses&token=..."

# Search by keyword
curl "https://eadmin.mru.ac.ug/API/v2/staff.aspx?action=all_courses&token=...&q=data+structures"

# Filter by programme
curl "https://eadmin.mru.ac.ug/API/v2/staff.aspx?action=all_courses&token=...&prog_code=BCS&size=200"
```

**Success Response:**

```json
{
  "status": "success",
  "data": {
    "total": 312,
    "page": 1,
    "size": 50,
    "pages": 7,
    "courses": [
      {
        "course_code": "CSC1201",
        "course_name": "Programming Fundamentals",
        "prog_code": "BCS",
        "prog_name": "Bachelor of Computer Science",
        "credit_units": "3"
      },
      {
        "course_code": "CSC2101",
        "course_name": "Data Structures and Algorithms",
        "prog_code": "BCS",
        "prog_name": "Bachelor of Computer Science",
        "credit_units": "4"
      }
    ]
  }
}
```

**Notes:**

- Returns one row per `course_code + prog_code` combination. A course shared across multiple programmes appears once per programme.
- When no `prog_code` filter is set, rows are ordered by `course_code` then `prog_code`.
- `q` matches against both `courseID` and `courseName` using a `LIKE %keyword%` pattern — suitable for a live-search input.
- Courses with a blank `courseName` are excluded from results.
- Unlike `my_courses`, this endpoint applies **no** teaching-assignment restriction — it reflects the full academic course catalogue.

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

### 4.15 List My Mark Requests

A teacher retrieves their own submitted mark change/correction requests, with optional status filter and pagination.

| Property | Value |
|---|---|
| **URL** | `staff.aspx?action=mark_requests_list` |
| **Method** | `GET` or `POST` |
| **Auth Required** | Yes (staff) |

**Parameters:**

| Parameter | Type | Required | Default | Description |
|---|---|---|---|---|
| `token` | string | Yes | — | Valid staff API token |
| `status` | string | No | all | Filter by status: `PENDING`, `APPROVED`, `REJECTED`, `CANCELLED` |
| `page` | int | No | 1 | Page number |
| `size` | int | No | 20 | Page size (max 100) |

**Example Request:**
```
GET /API/v2/staff.aspx?action=mark_requests_list&token=abc123&status=PENDING
```

**Example Response:**
```json
{
  "success": true,
  "message": "OK",
  "data": {
    "total": 2,
    "page": 1,
    "size": 20,
    "pages": 1,
    "requests": [
      {
        "id": 7,
        "teacher_username": "jdoe",
        "course_id": "CS101",
        "course_name": "Introduction to Computing",
        "regno": "MRU2025000001",
        "student_name": "John Mukasa",
        "registration_id": 4521,
        "acad_year": "2024/2025",
        "semester": 1,
        "request_type": "MARK_CHANGE",
        "reason": "Student exam paper was misread — correct exam score is 52 not 42.",
        "old_cw": 30,
        "old_exam": 42,
        "old_total": 72,
        "new_cw": 30,
        "new_exam": 52,
        "new_total": 82,
        "status": "PENDING",
        "admin_comment": null,
        "decided_by": null,
        "created_at": "2025-04-10 09:15",
        "decided_at": null
      }
    ]
  }
}
```

---

### 4.16 Create Mark Request

A teacher submits a mark change or correction request for admin approval.

| Property | Value |
|---|---|
| **URL** | `staff.aspx?action=create_mark_request` |
| **Method** | `POST` |
| **Auth Required** | Yes (staff) |

**Parameters:**

| Parameter | Type | Required | Default | Description |
|---|---|---|---|---|
| `token` | string | Yes | — | Valid staff API token |
| `course_id` | string | Yes | — | Course code (e.g. `CS101`) |
| `regno` | string | Yes | — | Student registration number |
| `reason` | string | Yes | — | Detailed explanation of the change request |
| `registration_id` | int | No | — | ID from `acad_course_registration` — links request to the exact mark record. If supplied, `old_cw`/`old_exam` are auto-populated from the current record values |
| `acad_year` | string | No | `""` | Academic year (e.g. `2024/2025`) |
| `semester` | int | No | 1 | Semester number |
| `request_type` | string | No | `MARK_CHANGE` | One of: `MARK_CHANGE`, `INITIAL_SUBMISSION`, `CORRECTION`, `OTHER` |
| `old_cw` | decimal | No | — | Current coursework marks (0–40). Auto-filled from record if `registration_id` supplied |
| `old_exam` | decimal | No | — | Current exam marks (0–60). Auto-filled from record if `registration_id` supplied |
| `new_cw` | decimal | No | — | Requested new coursework marks (0–40) |
| `new_exam` | decimal | No | — | Requested new exam marks (0–60) |

**Validation Rules:**
- A duplicate PENDING request for the same teacher/course/student/semester is rejected with `DUPLICATE_REQUEST`.
- `old_cw` / `new_cw` must be 0–40; `old_exam` / `new_exam` must be 0–60.
- `request_type` must be one of the four valid values above.

**Example Request:**
```
POST /API/v2/staff.aspx?action=create_mark_request
Body: token=abc123&course_id=CS101&regno=MRU2025000001&registration_id=4521
      &reason=Exam paper misread&request_type=MARK_CHANGE&new_cw=30&new_exam=52
```

**Example Response:**
```json
{
  "success": true,
  "message": "Mark change request submitted and is pending admin review",
  "data": {
    "id": 7,
    "status": "PENDING",
    "request_type": "MARK_CHANGE",
    "old_cw": 30,
    "old_exam": 42,
    "new_cw": 30,
    "new_exam": 52
  }
}
```

**Error Codes:**

| Code | Meaning |
|---|---|
| `DUPLICATE_REQUEST` | A PENDING request already exists for this teacher/course/student/semester |
| `VALIDATION_ERROR` | Invalid mark values or request_type |
| `MISSING_PARAM` | Required field missing |
| `FORBIDDEN` | Non-staff token used |

---

### 4.17 Mark Request Detail

Get the full detail of a single mark request. By default returns only the authenticated teacher's own requests.

| Property | Value |
|---|---|
| **URL** | `staff.aspx?action=mark_request_detail` |
| **Method** | `GET` or `POST` |
| **Auth Required** | Yes (staff) |

**Parameters:**

| Parameter | Type | Required | Default | Description |
|---|---|---|---|---|
| `token` | string | Yes | — | Valid staff API token |
| `id` | int | Yes | — | Mark request ID |
| `admin` | int | No | 0 | Pass `1` to allow any staff to fetch any request (for admin screens) |

**Example Request:**
```
GET /API/v2/staff.aspx?action=mark_request_detail&token=abc123&id=7
```

**Example Response:** Same shape as a single object from 4.15's `requests` array.

---

### 4.18 Cancel Mark Request

A teacher cancels their own PENDING request. Only PENDING requests can be cancelled.

| Property | Value |
|---|---|
| **URL** | `staff.aspx?action=cancel_mark_request` |
| **Method** | `POST` |
| **Auth Required** | Yes (staff — own requests only) |

**Parameters:**

| Parameter | Type | Required | Default | Description |
|---|---|---|---|---|
| `token` | string | Yes | — | Valid staff API token |
| `id` | int | Yes | — | Mark request ID to cancel |

**Example Response:**
```json
{
  "success": true,
  "message": "Mark request cancelled",
  "data": { "id": 7, "status": "CANCELLED" }
}
```

**Error Codes:**

| Code | Meaning |
|---|---|
| `INVALID_STATUS` | Request is not PENDING (already decided or cancelled) |
| `NOT_FOUND` | Request not found or does not belong to this teacher |

---

### 4.19 Admin — List All Mark Requests

An admin/supervisor lists ALL mark requests across all teachers, with full filtering. Default filter is `status=PENDING`.

| Property | Value |
|---|---|
| **URL** | `staff.aspx?action=admin_mark_requests` |
| **Method** | `GET` or `POST` |
| **Auth Required** | Yes (staff) |

**Parameters:**

| Parameter | Type | Required | Default | Description |
|---|---|---|---|---|
| `token` | string | Yes | — | Valid staff API token |
| `status` | string | No | `PENDING` | Status filter. Pass empty string for all statuses |
| `teacher_username` | string | No | — | Filter by specific teacher |
| `course_id` | string | No | — | Filter by course |
| `acad_year` | string | No | — | Filter by academic year |
| `semester` | int | No | — | Filter by semester |
| `page` | int | No | 1 | Page number |
| `size` | int | No | 20 | Page size (max 100) |

**Example Request:**
```
GET /API/v2/staff.aspx?action=admin_mark_requests&token=abc123&status=PENDING&acad_year=2024/2025
```

**Example Response:** Same shape as 4.15 (total, page, size, pages, requests array).

---

### 4.20 Decide Mark Request (Approve / Reject)

An admin approves or rejects a mark change request. When approved and the request has a `registration_id` plus `new_cw`/`new_exam` values, the marks are automatically applied to `acad_course_registration` and the record's status is reset to `approved` (unlocking it from `published`).

| Property | Value |
|---|---|
| **URL** | `staff.aspx?action=decide_mark_request` |
| **Method** | `POST` |
| **Auth Required** | Yes (staff — intended for admin/HOD users) |

**Parameters:**

| Parameter | Type | Required | Default | Description |
|---|---|---|---|---|
| `token` | string | Yes | — | Valid staff API token |
| `id` | int | Yes | — | Mark request ID |
| `decision` | string | Yes | — | `APPROVED` or `REJECTED` |
| `admin_comment` | string | No | `""` | Reason or comment for the decision |

**Mark Application Logic (on APPROVED):**
1. If `registration_id` is set AND `new_cw` or `new_exam` is present: marks are updated in `acad_course_registration` automatically.
2. If `registration_id` is missing: request is approved but marks must be applied manually.
3. If no new mark values were supplied: request is approved but no marks are changed.

**Example Request:**
```
POST /API/v2/staff.aspx?action=decide_mark_request
Body: token=abc123&id=7&decision=APPROVED&admin_comment=Verified against original script
```

**Example Response:**
```json
{
  "success": true,
  "message": "Request approved",
  "data": {
    "id": 7,
    "decision": "APPROVED",
    "decided_by": "admin_user",
    "mark_update": "Marks updated: CW=30, Exam=52, Total=82"
  }
}
```

**Error Codes:**

| Code | Meaning |
|---|---|
| `INVALID_STATUS` | Request is not PENDING |
| `NOT_FOUND` | Request ID not found |
| `VALIDATION_ERROR` | `decision` value not `APPROVED` or `REJECTED` |

---

### 4.21 List Provisional Marks

Returns a paginated list of provisional mark records. Any authenticated staff member can access all records. Filters are optional — omit any to get all records for that dimension.

| Property | Value |
|---|---|
| **URL** | `staff.aspx?action=provisional_marks_list` |
| **Method** | `GET` or `POST` |
| **Auth Required** | Yes (staff only) |

**Parameters:**

| Parameter | Type | Required | Default | Description |
|---|---|---|---|---|
| `token` | string | Yes | — | Valid staff API token |
| `acad_year` | string | No | all | Filter by academic year e.g. `2025/2026` |
| `semester` | int | No | all | Filter by semester: `1`, `2`, or `3` |
| `prog` | string | No | all | Filter by programme code e.g. `BAED` |
| `course_id` | string | No | all | Filter by course code e.g. `ICT1108B` |
| `student_regno` | string | No | — | Filter by exact student regno — use after `student_search` to show all marks for one student |
| `status` | string | No | all | Filter by mark status: `not_entered`, `pending`, `approved`, `rejected`, `published` |
| `ready` | int | No | 0 | `1` = only records where both CW and Exam are filled and not yet published |
| `sq` | string | No | — | Live text search: matches student name, regno, or entry number |
| `page` | int | No | 1 | Page number |
| `size` | int | No | 50 | Page size (max 200) |

> **Tip:** Call `student_search` first to let the user pick a student, then pass that student's `regno` as `student_regno` here to show all their marks across all courses.

**Status values:**
| Status | Meaning |
|---|---|
| `not_entered` | Both CW and Exam are NULL — no marks entered yet |
| `pending` | At least one mark entered, awaiting dean review |
| `approved` | Dean approved — locked from teacher edits |
| `rejected` | Dean rejected — teacher must correct and resubmit |
| `published` | Published to final results — permanently locked |

**Example Requests:**
```bash
# All marks for a course in a given year/semester
curl "https://eadmin.mru.ac.ug/API/v2/staff.aspx?action=provisional_marks_list&token=abc123&acad_year=2025/2026&semester=2&prog=BAED&course_id=ICT1108B"

# All marks for a specific student across all courses
curl "https://eadmin.mru.ac.ug/API/v2/staff.aspx?action=provisional_marks_list&token=abc123&student_regno=MRU2025002331"

# Live text search (use with debounce)
curl "https://eadmin.mru.ac.ug/API/v2/staff.aspx?action=provisional_marks_list&token=abc123&sq=Namubiru&course_id=ICT1108B"
```

**Success Response:**
```json
{
  "success": true,
  "data": {
    "total": 42,
    "page": 1,
    "size": 50,
    "pages": 1,
    "rows": [
      {
        "id": 133168,
        "entry_no": "25/U/BAED/0021/K/DAY",
        "student_name": "ANGEL NAMUBIRU",
        "course_code": "ICT1108B",
        "acad_year": "2025/2026",
        "semester": 2,
        "programme_code": "BAED",
        "cw_marks": null,
        "exam_marks": null,
        "total_marks": null,
        "prov_status": "not_entered"
      }
    ]
  }
}
```

---

### 4.22 Get Provisional Mark Detail

Returns full details for a single provisional mark record including review and publication metadata.

| Property | Value |
|---|---|
| **URL** | `staff.aspx?action=provisional_mark_detail` |
| **Method** | `GET` or `POST` |
| **Auth Required** | Yes (staff only) |

**Parameters:**

| Parameter | Type | Required | Default | Description |
|---|---|---|---|---|
| `token` | string | Yes | — | Valid staff API token |
| `id` | int | Yes | — | Registration record ID (from `provisional_marks_list`) |

**Success Response:**
```json
{
  "success": true,
  "data": {
    "id": 133168,
    "regno": "MRU2025002331",
    "entry_no": "25/U/BAED/0021/K/DAY",
    "student_name": "ANGEL NAMUBIRU",
    "gender": "FEMALE",
    "session": "Day",
    "course_code": "ICT1108B",
    "course_name": "INFORMATION COMMUNICATION TECHNOLOGY",
    "credit_units": 3,
    "acad_year": "2025/2026",
    "semester": 2,
    "programme_code": "BAED",
    "programme_name": "Bachelor of Arts in Education",
    "cw_marks": null,
    "exam_marks": null,
    "total_marks": null,
    "prov_status": "not_entered",
    "review_comments": "",
    "reviewed_by": "",
    "review_date": null,
    "submitted_by": "",
    "published_by": "",
    "published_date": null,
    "ready_to_publish": 0
  }
}
```

> `entry_no` is the human-readable student identifier (e.g. `25/U/BAED/0021/K/DAY`). `regno` is the internal key used in save endpoints and `student_regno` filter.

---

### 4.23 Save Provisional Mark (Single Record)

Saves CW and Exam marks for a single student registration record. Both fields are required.

| Property | Value |
|---|---|
| **URL** | `staff.aspx?action=save_provisional_mark` |
| **Method** | `POST` |
| **Auth Required** | Yes (staff only) |

**Parameters:**

| Parameter | Type | Required | Default | Description |
|---|---|---|---|---|
| `token` | string | Yes | — | Valid staff API token |
| `id` | int | Yes | — | Registration record ID |
| `cw` | decimal | Yes | — | Coursework marks (0–40) |
| `exam` | decimal | Yes | — | Exam marks (0–60) |

**Validation rules:**
- `cw` must be a number in range 0–40
- `exam` must be a number in range 0–60
- `total` is auto-calculated as `cw + exam`
- Records with `published` status are permanently locked — returns `MARKS_LOCKED`
- Records with `approved` status are reset to `pending` when edited (teacher's edit invalidates the approval)

**Success Response:**
```json
{
  "success": true,
  "message": "Provisional marks saved",
  "data": {
    "id": 4521,
    "cw_marks": 35,
    "exam_marks": 52,
    "total_marks": 87,
    "grade": "A"
  }
}
```

**Error Codes:**
| Code | Meaning |
|---|---|
| `MARKS_LOCKED` | Record is `published` — cannot be edited |
| `VALIDATION_ERROR` | `cw` or `exam` out of range |
| `NOT_FOUND` | Record ID does not exist |

---

### 4.24 Save Provisional Mark Inline (Single Field)

Updates only CW or only Exam mark for a record — useful for inline grid editing without re-submitting both fields.

| Property | Value |
|---|---|
| **URL** | `staff.aspx?action=save_provisional_mark_inline` |
| **Method** | `POST` |
| **Auth Required** | Yes (staff only) |

**Parameters:**

| Parameter | Type | Required | Default | Description |
|---|---|---|---|---|
| `token` | string | Yes | — | Valid staff API token |
| `id` | int | Yes | — | Registration record ID |
| `field` | string | Yes | — | Which field: `cw` or `exam` |
| `value` | decimal | Yes | — | New mark value (0–40 for CW, 0–60 for Exam) |

**Success Response:**
```json
{
  "success": true,
  "message": "Mark saved inline",
  "data": {
    "id": 4521,
    "field": "exam",
    "new_value": 52,
    "total_marks": 87,
    "grade": "A"
  }
}
```

**Error Codes:**
| Code | Meaning |
|---|---|
| `MARKS_LOCKED` | Record is `published` — cannot be edited |
| `VALIDATION_ERROR` | `value` out of range, or `field` is not `cw` or `exam` |
| `NOT_FOUND` | Record ID does not exist |

> The `field` parameter must be exactly `"cw"` or `"exam"` (case-sensitive); any other value returns `VALIDATION_ERROR`.

---

### 4.25 Bulk Save Marks

Saves provisional marks for multiple students in a single request. Supports partial updates (supply only `cw` or only `exam` to update one component while keeping the other). The teacher only needs access to the courses the records belong to.

| Property | Value |
|---|---|
| **URL** | `staff.aspx?action=bulk_save_marks` |
| **Method** | `POST` |
| **Auth Required** | Yes (staff only) |

**Request Body (JSON array in `marks` param or raw POST body):**

```json
[
  {"id": 4521, "cw": 35, "exam": 52},
  {"id": 4522, "cw": 28, "exam": 44},
  {"id": 4523, "exam": 58}
]
```

**Parameters per item:**

| Field | Type | Required | Description |
|---|---|---|---|
| `id` | int | Yes | Registration record ID |
| `cw` | decimal | No | Coursework marks (0–40) — omit to keep existing value |
| `exam` | decimal | No | Exam marks (0–60) — omit to keep existing value |

**Limits:** Maximum 500 records per request.

**Status behaviour:** Same as single-record save — editing resets `approved` → `pending`; `published` records are skipped.

**Success Response:**
```json
{
  "success": true,
  "message": "Bulk save complete: 3 saved, 0 skipped, 0 errors",
  "data": {
    "saved": 3,
    "skipped": 0,
    "errors": 0,
    "total_submitted": 3,
    "detail": [
      {"id": 4521, "cw_marks": 35, "exam_marks": 52, "total_marks": 87, "grade": "A"},
      {"id": 4522, "cw_marks": 28, "exam_marks": 44, "total_marks": 72, "grade": "B+"},
      {"id": 4523, "cw_marks": 32, "exam_marks": 58, "total_marks": 90, "grade": "A"}
    ]
  }
}
```

Each `detail` entry is one of:
- `{ "id": ..., "cw_marks": ..., "exam_marks": ..., "total_marks": ..., "grade": ... }` — saved
- `{ "id": ..., "skipped": "reason" }` — skipped (published, not found, or no data supplied)
- `{ "id": ..., "error": "reason" }` — validation or DB error

---

### 4.26 Provisional Marks Summary (Per Course)

Returns a per-course summary of mark entry progress and workflow status counts for all courses the teacher is assigned to.

| Property | Value |
|---|---|
| **URL** | `staff.aspx?action=provisional_marks_summary` |
| **Method** | `GET` or `POST` |
| **Auth Required** | Yes (staff only) |

**Parameters:**

| Parameter | Type | Required | Default | Description |
|---|---|---|---|---|
| `token` | string | Yes | — | Valid staff API token |
| `acad_year` | string | No | all | Filter by academic year |
| `semester` | int | No | all | Filter by semester |

**Success Response:**
```json
{
  "success": true,
  "data": {
    "total_courses": 3,
    "total_students": 120,
    "totals": {
      "not_entered": 10,
      "pending": 80,
      "approved": 20,
      "rejected": 2,
      "published": 8,
      "ready_to_publish": 82
    },
    "courses": [
      {
        "course_code": "CSC1101",
        "course_name": "Introduction to Computing",
        "programme_name": "Bachelor of Computer Science",
        "programme_code": "BCS",
        "acad_year": "2024/2025",
        "semester": 1,
        "total_students": 45,
        "not_entered": 3,
        "partially_entered": 5,
        "fully_entered": 42,
        "pending": 30,
        "approved": 10,
        "rejected": 1,
        "published": 4,
        "ready_to_publish": 31
      }
    ]
  }
}
```

---

### 4.27 Mark Stats Dashboard

Returns overall dashboard statistics for the teacher across all assigned courses, plus a per-course breakdown. Ideal for the app home screen.

| Property | Value |
|---|---|
| **URL** | `staff.aspx?action=mark_stats` |
| **Method** | `GET` or `POST` |
| **Auth Required** | Yes (staff only) |

**Parameters:**

| Parameter | Type | Required | Default | Description |
|---|---|---|---|---|
| `token` | string | Yes | — | Valid staff API token |
| `acad_year` | string | No | all | Filter by academic year |
| `semester` | int | No | all | Filter by semester |

**Success Response:**
```json
{
  "success": true,
  "data": {
    "filter_acad_year": "2024/2025",
    "filter_semester": 1,
    "summary": {
      "total_students": 120,
      "total_courses": 3,
      "total_programmes": 2,
      "not_entered": 10,
      "fully_entered": 110,
      "pending_review": 80,
      "approved": 20,
      "rejected": 2,
      "published": 8,
      "ready_to_publish": 82
    },
    "courses": [
      {
        "course_code": "CSC1101",
        "course_name": "Introduction to Computing",
        "programme_name": "Bachelor of Computer Science",
        "programme_code": "BCS",
        "acad_year": "2024/2025",
        "semester": 1,
        "total_students": 45,
        "not_entered": 3,
        "fully_entered": 42,
        "pending": 30,
        "approved": 10,
        "rejected": 1,
        "published": 4,
        "ready_to_publish": 31,
        "avg_total": 71.4
      }
    ]
  }
}
```

---

### 4.28 Class List (Enhanced)

Returns the student roster for a specific course with provisional mark status per student. Any authenticated staff member can call this — no course assignment required.

| Property | Value |
|---|---|
| **URL** | `staff.aspx?action=class_list` |
| **Method** | `GET` or `POST` |
| **Auth Required** | Yes (staff only) |

**Parameters:**

| Parameter | Type | Required | Default | Description |
|---|---|---|---|---|
| `token` | string | Yes | — | Valid staff API token |
| `course_id` | string | Yes | — | Course code |
| `acad_year` | string | Yes | — | Academic year e.g. `2025/2026` |
| `semester` | int | No | 1 | Semester |
| `progid` | string | No | all | Narrow to a specific programme code |

**Success Response:**
```json
{
  "success": true,
  "data": {
    "course_id": "ICT1108B",
    "course_name": "INFORMATION COMMUNICATION TECHNOLOGY",
    "credit_units": 3,
    "acad_year": "2025/2026",
    "semester": 2,
    "total_students": 45,
    "marks_summary": {
      "entered": 42,
      "not_entered": 3,
      "pending": 30,
      "approved": 10,
      "rejected": 1,
      "published": 4
    },
    "students": [
      {
        "registration_id": 133168,
        "regno": "MRU2025002331",
        "entry_no": "25/U/BAED/0021/K/DAY",
        "firstname": "ANGEL",
        "othername": "NAMUBIRU",
        "student_name": "ANGEL NAMUBIRU",
        "gender": "FEMALE",
        "session": "Day",
        "programme_code": "BAED",
        "cw_marks": null,
        "exam_marks": null,
        "total_marks": null,
        "grade": null,
        "mark_status": "not_entered",
        "ready_to_publish": 0
      }
    ]
  }
}
```

**Note:** This endpoint queries the portal database (`acad_course_registration`) and will return 0 students if marks have not been initialized for this course/year/semester.

---

### 4.29 Student Search

Live student search for use before filtering marks. Returns up to 100 students whose name, entry number, or registration number matches the query, ordered by closest match. Designed for a "pick a student" dialog before calling `provisional_marks_list?student_regno=...`.

| Property | Value |
|---|---|
| **URL** | `staff.aspx?action=student_search` |
| **Method** | `GET` or `POST` |
| **Auth Required** | Yes (staff only) |

**Parameters:**

| Parameter | Type | Required | Default | Description |
|---|---|---|---|---|
| `token` | string | Yes | — | Valid staff API token |
| `q` | string | No | — | Search query — matches name, entry number, or regno. If omitted, returns first `size` students alphabetically |
| `prog` | string | No | all | Narrow to a specific programme code e.g. `BAED` |
| `size` | int | No | 30 | Number of results (min 10, max 100) |

**Result ordering (when `q` is provided):**
1. Exact entry number or regno match
2. Entry number or regno starts with `q`
3. Full name starts with `q`
4. Contains `q` anywhere

**Response fields per student:**

| Field | Description |
|---|---|
| `regno` | Internal registration number — use as `student_regno` in `provisional_marks_list` |
| `entry_no` | Human-readable entry number e.g. `25/U/BAED/0021/K/DAY` |
| `student_name` | Full name (firstname + othername) |
| `firstname` | First name |
| `othername` | Other names / surname |
| `gender` | `MALE` or `FEMALE` |
| `session` | `Day` or `Evening` |
| `programme_code` | Programme code e.g. `BAED` |
| `programme_name` | Full programme name |
| `student_status` | `Active`, `Completed`, etc. |
| `photo_url` | Relative path to the photo — prepend `https://eadmin.mru.ac.ug` for the full URL. `null` if no photo uploaded |

**Example Requests:**
```bash
# Search by name (live search — debounce 300ms)
curl "https://eadmin.mru.ac.ug/API/v2/staff.aspx?action=student_search&token=abc123&q=Angel"

# Search by entry number prefix
curl "https://eadmin.mru.ac.ug/API/v2/staff.aspx?action=student_search&token=abc123&q=25/U/BAED"

# Narrow to one programme, first 30 students alphabetically
curl "https://eadmin.mru.ac.ug/API/v2/staff.aspx?action=student_search&token=abc123&prog=BAED"
```

**Success Response:**
```json
{
  "success": true,
  "data": {
    "count": 2,
    "query": "Angel",
    "results": [
      {
        "regno": "MRU2025002331",
        "entry_no": "25/U/BAED/0021/K/DAY",
        "student_name": "ANGEL NAMUBIRU",
        "firstname": "ANGEL",
        "othername": "NAMUBIRU",
        "gender": "FEMALE",
        "session": "Day",
        "programme_code": "BAED",
        "programme_name": "Bachelor of Arts in Education",
        "student_status": "Active",
        "photo_url": "/COOPERP/StudentInfo/photos/7391842.jpg"
      }
    ]
  }
}
```

---

### 4.30 Course Allocation Search

Search the full course catalogue to find which `acad_programmecourses` rows a lecturer can allocate themselves to. Use this as the **picker** before calling `course_allocation_submit`. Returns up to 100 rows showing current assignment state and whether the caller has already claimed a course.

| Property | Value |
|---|---|
| **URL** | `staff.aspx?action=course_allocation_search` |
| **Method** | `GET` |
| **Auth Required** | Yes (staff only) |

**Parameters:**

| Parameter | Type | Required | Default | Description |
|---|---|---|---|---|
| `token` | string | Yes | — | Valid staff API token |
| `q` | string | No | — | Free-text search — matches course code, course name, or programme name |
| `semester` | int | No | all | Filter by semester (`1` or `2`) |
| `size` | int | No | 50 | Max results (1–100) |

**Response fields per course:**

| Field | Type | Description |
|---|---|---|
| `programme_course_id` | string | Primary key of `acad_programmecourses` — required for submit and unassign |
| `course_code` | string | Course code e.g. `ICT1108B` |
| `course_name` | string | Full course name |
| `programme_code` | string | Programme code e.g. `BAED` |
| `programme_name` | string | Full programme name |
| `specialisation` | string | Specialisation name (empty string if none) |
| `study_year` | string | Year of study (`1`, `2`, etc.) |
| `semester` | string | Semester (`1` or `2`) |
| `is_assigned` | bool | `true` if this course context is currently assigned to any lecturer |
| `current_lecturer` | string\|null | Name and code of currently assigned lecturer, or `null` if none |
| `already_mine` | bool | `true` if this course is already allocated to the calling lecturer |
| `can_allocate` | bool | `true` if the caller can allocate themselves (= `!already_mine`) |
| `allocation_request_status` | string | `Yes` or `No` — whether a request was filed |
| `allocation_request_admin_status` | string | `Approved`, `Pending`, or `Rejected` |

**Example Request:**
```bash
# Search for courses matching "ICT"
curl "https://eadmin.mru.ac.ug/API/v2/staff.aspx?action=course_allocation_search&token=abc123&q=ICT"

# All semester-1 courses (first 50)
curl "https://eadmin.mru.ac.ug/API/v2/staff.aspx?action=course_allocation_search&token=abc123&semester=1"
```

**Success Response:**
```json
{
  "status": "success",
  "data": {
    "total": 2,
    "courses": [
      {
        "programme_course_id": "142",
        "course_code": "ICT1108B",
        "course_name": "Introduction to ICT",
        "programme_code": "BAED",
        "programme_name": "Bachelor of Arts in Education",
        "specialisation": "",
        "study_year": "1",
        "semester": "1",
        "is_assigned": false,
        "current_lecturer": null,
        "already_mine": false,
        "can_allocate": true,
        "allocation_request_status": "No",
        "allocation_request_admin_status": "Pending"
      }
    ]
  }
}
```

---

### 4.31 Course Allocation Submit (Self-Allocate)

Allocate the calling lecturer to one or more course contexts. The allocation is **immediate and auto-approved** — no admin step is required. A lecturer can only allocate themselves; they cannot allocate another lecturer.

| Property | Value |
|---|---|
| **URL** | `staff.aspx?action=course_allocation_submit` |
| **Method** | `GET` or `POST` |
| **Auth Required** | Yes (staff only) |

**Parameters:**

| Parameter | Type | Required | Default | Description |
|---|---|---|---|---|
| `token` | string | Yes | — | Valid staff API token |
| `programme_course_ids` | string | Yes | — | Comma-separated list of `programme_course_id` values from `course_allocation_search` |
| `message` | string | Yes | — | Brief reason for the allocation (max 1000 chars). Stored for audit. |

**How it works:**
- For each ID: the system checks the current `acad_programmecourses` row
- If already allocated to the calling lecturer → counted as `already_mine`, skipped
- If not found → counted as `not_found`, skipped
- Otherwise → sets `lecturer_id`, `is_lecturere_assigned = 'Yes'`, and marks as `Approved`
- All changes are committed in a single transaction

**Response fields:**

| Field | Type | Description |
|---|---|---|
| `assigned_count` | int | How many course contexts were newly allocated |
| `already_mine_count` | int | How many were skipped (already yours) |
| `not_found_count` | int | How many IDs were not found in the database |
| `skipped_count` | int | How many had no rows affected (edge case) |
| `message` | string | Human-readable summary |

**Example Request:**
```bash
curl -X POST "https://eadmin.mru.ac.ug/API/v2/staff.aspx" \
  -d "action=course_allocation_submit" \
  -d "token=abc123" \
  -d "programme_course_ids=142,143" \
  -d "message=I am the assigned lecturer for this course this semester"
```

**Success Response:**
```json
{
  "status": "success",
  "data": {
    "assigned_count": 2,
    "already_mine_count": 0,
    "not_found_count": 0,
    "skipped_count": 0,
    "message": "2 courses allocated."
  }
}
```

**Error — already yours:**
```json
{
  "status": "error",
  "message": "All selected courses are already allocated to you.",
  "code": "NO_CHANGE"
}
```

---

### 4.32 Course Unassign (Remove Self-Allocation)

Remove the calling lecturer from a course they are currently assigned to. A lecturer can only unassign themselves from their own courses — they cannot unassign someone else.

| Property | Value |
|---|---|
| **URL** | `staff.aspx?action=course_unassign` |
| **Method** | `GET` or `POST` |
| **Auth Required** | Yes (staff only) |

**Parameters:**

| Parameter | Type | Required | Description |
|---|---|---|---|
| `token` | string | Yes | Valid staff API token |
| `programme_course_id` | int | Yes | The `programme_course_id` from `course_allocation_search` or `my_courses` |

**What it clears:** `lecturer_id`, `is_lecturere_assigned`, `allocation_request_status`, `allocation_request_lecturer_id`, `allocation_request_date`, `allocation_request_message`, `allocation_request_admin_status`, `allocation_request_admin_message` are all reset to their default empty/NULL state.

**Example Request:**
```bash
curl -X POST "https://eadmin.mru.ac.ug/API/v2/staff.aspx" \
  -d "action=course_unassign" \
  -d "token=abc123" \
  -d "programme_course_id=142"
```

**Success Response:**
```json
{
  "status": "success",
  "data": {
    "message": "Course unassigned successfully."
  }
}
```

**Error — not your course:**
```json
{
  "status": "error",
  "message": "This course is not currently assigned to you.",
  "code": "NOT_FOUND"
}
```

---

### 4.33 Course Registration Summary (KPIs)

Returns aggregate counts for student enrolments in the lecturer's courses. Use this for a dashboard-style header above the student list.

| Property | Value |
|---|---|
| **URL** | `staff.aspx?action=course_reg_summary` |
| **Method** | `GET` |
| **Auth Required** | Yes (staff only) |

**Parameters:**

| Parameter | Type | Required | Default | Description |
|---|---|---|---|---|
| `token` | string | Yes | — | Valid staff API token |
| `acad_year` | string | No | all | Filter by academic year e.g. `2024/2025` |
| `semester` | int | No | all | `1` or `2` |
| `programme_code` | string | No | all | Programme code e.g. `BAED` |
| `course_code` | string | No | all | Single course code e.g. `ICT1108B` |

**Response:**

```json
{
  "status": "success",
  "data": {
    "total_registration_rows": 240,
    "total_students": 198,
    "total_unique_courses": 4,
    "total_programmes": 3,
    "pending_rows": 12,
    "approved_rows": 228
  }
}
```

Results are automatically restricted to courses assigned to the calling lecturer. If the lecturer has no assigned courses, all counts return 0.

---

### 4.34 Course Registration List (Students)

Paginated list of students registered in the lecturer's courses, grouped by student + year + semester.

| Property | Value |
|---|---|
| **URL** | `staff.aspx?action=course_reg_list` |
| **Method** | `GET` |
| **Auth Required** | Yes (staff only) |

**Parameters:**

| Parameter | Type | Required | Default | Description |
|---|---|---|---|---|
| `token` | string | Yes | — | Valid staff API token |
| `acad_year` | string | No | all | Filter by academic year |
| `semester` | int | No | all | `1` or `2` |
| `programme_code` | string | No | all | Filter by programme |
| `course_code` | string | No | all | Show only students registered for this specific course |
| `search` | string | No | — | Free text — matches regno, entry_no, name, or programme |
| `page` | int | No | 1 | Page number |
| `size` | int | No | 50 | Results per page (max 200) |

**Response fields per student row:**

| Field | Description |
|---|---|
| `regno` | Internal registration number |
| `entry_no` | Human-readable entry number e.g. `25/U/BAED/0021/K/DAY` |
| `student_name` | Full name |
| `programme_code` | e.g. `BAED` |
| `programme_name` | Full programme name |
| `enrolled_courses` | Comma-separated list of course codes this student is enrolled in (within the lecturer's courses only) |
| `course_count` | Number of the lecturer's courses this student is in |
| `acad_year` | Academic year |
| `semester` | Semester |
| `study_year` | Year of study |
| `pending_count` | How many of this student's enrolments have status `PENDING` |

**Example:**
```bash
curl "https://eadmin.mru.ac.ug/API/v2/staff.aspx?action=course_reg_list&token=abc123&acad_year=2024/2025&semester=1&size=50"
```

**Success Response:**
```json
{
  "status": "success",
  "data": {
    "total": 198,
    "page": 1,
    "size": 50,
    "pages": 4,
    "students": [
      {
        "regno": "MRU2025002331",
        "entry_no": "25/U/BAED/0021/K/DAY",
        "student_name": "NAMUBIRU ANGEL",
        "programme_code": "BAED",
        "programme_name": "Bachelor of Arts in Education",
        "enrolled_courses": "ICT1108B, ICT2201A",
        "course_count": "2",
        "acad_year": "2024/2025",
        "semester": "1",
        "study_year": "1",
        "pending_count": "0"
      }
    ]
  }
}
```

---

### 4.35 Validate Student (Before Enrolment)

Look up a student by regno and return their name, programme, and list of semester registration records. Call this first to confirm the student exists and to pick which registration period to enrol them under.

| Property | Value |
|---|---|
| **URL** | `staff.aspx?action=course_reg_validate_student` |
| **Method** | `GET` |
| **Auth Required** | Yes (staff only) |

**Parameters:**

| Parameter | Type | Required | Description |
|---|---|---|---|
| `token` | string | Yes | Valid staff API token |
| `regno` | string | Yes | Student registration number |

**Success Response:**
```json
{
  "status": "success",
  "data": {
    "regno": "MRU2025002331",
    "student_name": "NAMUBIRU ANGEL",
    "entry_no": "25/U/BAED/0021/K/DAY",
    "programme": "BAED - Bachelor of Arts in Education",
    "programme_code": "BAED",
    "registrations": [
      {
        "registration_id": 5892,
        "acad_year": "2024/2025",
        "semester": 1,
        "study_year": 1,
        "reg_status": "REGISTERED",
        "programme_name": "Bachelor of Arts in Education",
        "label": "2024/2025 — Sem 1, Year 1 [REGISTERED]"
      }
    ]
  }
}
```

**Error — not found:**
```json
{ "status": "error", "message": "Student not found.", "code": "NOT_FOUND" }
```

Pass the `registration_id` from this response into `course_reg_enroll` for the cleanest, safest enrolment.

---

### 4.36 Enrol Student to Course

Enrol a student into one of the calling lecturer's assigned courses. The lecturer can only enrol students into their own allocated courses.

| Property | Value |
|---|---|
| **URL** | `staff.aspx?action=course_reg_enroll` |
| **Method** | `POST` |
| **Auth Required** | Yes (staff only) |

**Parameters (two modes):**

**Mode A — via registration_id (recommended):**

| Parameter | Type | Required | Description |
|---|---|---|---|
| `token` | string | Yes | Valid staff API token |
| `regno` | string | Yes | Student registration number |
| `course_id` | string | Yes | Course code e.g. `ICT1108B` |
| `registration_id` | int | Yes | From `course_reg_validate_student` — auto-fills acad_year + semester |

**Mode B — manual (if no registration record):**

| Parameter | Type | Required | Description |
|---|---|---|---|
| `token` | string | Yes | Valid staff API token |
| `regno` | string | Yes | Student registration number |
| `course_id` | string | Yes | Course code |
| `acad_year` | string | Yes | e.g. `2024/2025` |
| `semester` | int | Yes | `1`, `2`, or `3` |

**Business rules enforced:**
1. The calling lecturer must be assigned to `course_id` for the specified semester (checked against `acad_programmecourses`)
2. The course must exist in `acad_course`
3. The student must not already be enrolled for this course + year + semester

**Success Response:**
```json
{
  "status": "success",
  "data": {
    "message": "Student enrolled successfully.",
    "regno": "MRU2025002331",
    "course_id": "ICT1108B",
    "acad_year": "2024/2025",
    "semester": 1
  }
}
```

**Error Examples:**
```json
{ "status": "error", "message": "You can only enroll students to your allocated course(s) for the selected semester.", "code": "ACCESS_DENIED" }
{ "status": "error", "message": "Student is already enrolled for this course in the selected period.", "code": "DUPLICATE" }
{ "status": "error", "message": "Registration record not found.", "code": "NOT_FOUND" }
```

**Example Request (Mode A):**
```bash
curl -X POST "https://eadmin.mru.ac.ug/API/v2/staff.aspx" \
  -d "action=course_reg_enroll" \
  -d "token=abc123" \
  -d "regno=MRU2025002331" \
  -d "course_id=ICT1108B" \
  -d "registration_id=5892"
```

---

### 4.37 Student's Registered Courses

Get the full list of courses a specific student is registered for, optionally filtered by year/semester.

| Property | Value |
|---|---|
| **URL** | `staff.aspx?action=course_reg_student_courses` |
| **Method** | `GET` |
| **Auth Required** | Yes (staff only) |

**Parameters:**

| Parameter | Type | Required | Description |
|---|---|---|---|
| `token` | string | Yes | Valid staff API token |
| `regno` | string | Yes | Student registration number |
| `acad_year` | string | No | Filter by year |
| `semester` | int | No | Filter by semester |

**Response:**
```json
{
  "status": "success",
  "data": {
    "regno": "MRU2025002331",
    "total": 3,
    "courses": [
      {
        "course_code": "ICT1108B",
        "course_name": "Introduction to ICT",
        "credit_units": "3",
        "status": "REGULAR",
        "acad_year": "2024/2025",
        "semester": "1"
      }
    ]
  }
}
```

---

### 4.38 Course Registration Popularity

Returns the top N courses by enrolment count, restricted to the lecturer's assigned courses.

| Property | Value |
|---|---|
| **URL** | `staff.aspx?action=course_reg_popularity` |
| **Method** | `GET` |
| **Auth Required** | Yes (staff only) |

**Parameters:**

| Parameter | Type | Required | Default | Description |
|---|---|---|---|---|
| `token` | string | Yes | — | Valid staff API token |
| `acad_year` | string | No | all | Filter by year |
| `semester` | int | No | all | Filter by semester |
| `programme_code` | string | No | all | Filter by programme |
| `top` | int | No | 20 | Max results (1–100) |

**Response:**
```json
{
  "status": "success",
  "data": {
    "total": 4,
    "courses": [
      {
        "course_code": "ICT1108B",
        "course_name": "Introduction to ICT",
        "registration_count": "98",
        "student_count": "98"
      }
    ]
  }
}
```

---

### 4.39 Lecturer Mark Requests — List

Returns all mark-change and missing-mark requests assigned to the authenticated lecturer, sourced from the student portal's `acad_marks_requests` table.

| Property | Value |
|---|---|
| **URL** | `staff.aspx?action=lmr_requests` |
| **Method** | `GET` or `POST` |
| **Auth Required** | Yes (staff only) |

**Parameters:**

| Parameter | Type | Required | Default | Description |
|---|---|---|---|---|
| `token` | string | Yes | — | Valid staff API token |
| `status` | string | No | `ALL` | Filter by status: `PENDING_LECTURER`, `PENDING_SUPERVISOR`, `PENDING_ADMIN`, `APPROVED`, `REJECTED`, or `ALL` |

**Response:**
```json
{
  "success": true,
  "message": "OK",
  "data": {
    "total": 2,
    "lecturer_has_supervisor": true,
    "requests": [
      {
        "id": 14,
        "regno": "2021/BCS/001",
        "entry_no": "E2021001",
        "student_name": "John Doe",
        "course_id": "ICT2201",
        "course_name": "Database Systems",
        "acad_year": "2024/2025",
        "semester": 1,
        "request_type": "MISSING_MARK",
        "student_reason": "My marks were not recorded after the exam.",
        "status": "PENDING_LECTURER",
        "lecturer_response": "",
        "supervisor_response": "",
        "admin_response": "",
        "proposed_cw": null,
        "proposed_exam": null,
        "proposed_total": null,
        "original_cw": null,
        "original_exam": null,
        "original_total": null,
        "original_grade": "",
        "created_at": "2025-03-10 09:14",
        "updated_at": "2025-03-10 09:14",
        "can_review": true
      }
    ]
  },
  "timestamp": "2025-03-10T09:20:00Z"
}
```

**Status values:**

| Status | Meaning |
|---|---|
| `PENDING_LECTURER` | Awaiting lecturer action — use `lmr_respond` or `lmr_reject` |
| `PENDING_SUPERVISOR` | Lecturer responded; awaiting supervisor sign-off |
| `PENDING_ADMIN` | Awaiting registry/admin approval |
| `APPROVED` | Fully approved; marks published |
| `REJECTED` | Request rejected at some stage |

**Request types:**

| `request_type` | Meaning | Lecturer action |
|---|---|---|
| `MISSING_MARK` | Student says marks are absent from the system | Lecturer enters CW (required) + Exam (optional); request auto-approved on submit |
| `MARK_CHANGE` | Student disputes an existing mark | Lecturer enters corrected CW + Exam; request forwards to supervisor |

**Notes:**
- `can_review: true` means the request is `PENDING_LECTURER` and the lecturer can act on it.
- `lecturer_has_supervisor: true` means the lecturer's profile has a supervisor assigned. For `MARK_CHANGE` requests, this determines whether the next step is `PENDING_SUPERVISOR` or `PENDING_ADMIN`.
- Marks fields: `original_*` = current marks on file; `proposed_*` = lecturer's proposed marks.

---

### 4.40 Lecturer Mark Requests — Respond

Submits the lecturer's response to a mark request. For `MISSING_MARK`, the request is approved immediately and marks are published to `acad_results`. For `MARK_CHANGE`, the request advances to `PENDING_SUPERVISOR` (if supervisor assigned) or `PENDING_ADMIN`.

| Property | Value |
|---|---|
| **URL** | `staff.aspx?action=lmr_respond` |
| **Method** | `POST` |
| **Auth Required** | Yes (staff only) |

**Parameters:**

| Parameter | Type | Required | Description |
|---|---|---|---|
| `token` | string | Yes | Valid staff API token |
| `request_id` | int | Yes | ID of the mark request (from `lmr_requests`) |
| `proposed_cw` | int | Conditional | Coursework mark (0–40). Required for `MISSING_MARK`; required for `MARK_CHANGE`. |
| `proposed_exam` | int | Conditional | Exam mark (0–60). Required for `MARK_CHANGE`; optional for `MISSING_MARK` (some courses have no exam). |
| `response` | string | No | Lecturer's comment/explanation (optional but recommended) |

**Validation rules:**
- `proposed_cw` must be 0–40 if provided.
- `proposed_exam` must be 0–60 if provided.
- For `MARK_CHANGE`: **both** `proposed_cw` and `proposed_exam` are required.
- For `MISSING_MARK`: `proposed_cw` is required; `proposed_exam` is optional.

**Response (MISSING_MARK — marks published):**
```json
{
  "success": true,
  "message": "Response submitted. Marks have been published and the request is now approved.",
  "data": {
    "request_id": 14,
    "next_status": "APPROVED",
    "marks_published": true,
    "published_total": 72
  }
}
```

**Response (MARK_CHANGE — forwarded to supervisor):**
```json
{
  "success": true,
  "message": "Response submitted. The request has been forwarded to your supervisor for review.",
  "data": {
    "request_id": 7,
    "next_status": "PENDING_SUPERVISOR"
  }
}
```

**Error codes:**

| Error Code | Meaning |
|---|---|
| `NOT_FOUND` | Request does not exist, is not assigned to you, or is not in `PENDING_LECTURER` status |
| `VALIDATION_ERROR` | Mark out of range, or required mark missing for request type |
| `CONFLICT` | Concurrent update: request was already processed |
| `ACCESS_DENIED` | Not a staff token, or staff profile not found |

---

### 4.41 Lecturer Mark Requests — Reject

Rejects a mark request with a mandatory reason. Sets status to `REJECTED`. Requires the lecturer's staff profile to have a supervisor assigned (matching the portal's enforcement policy).

| Property | Value |
|---|---|
| **URL** | `staff.aspx?action=lmr_reject` |
| **Method** | `POST` |
| **Auth Required** | Yes (staff only) |

**Parameters:**

| Parameter | Type | Required | Description |
|---|---|---|---|
| `token` | string | Yes | Valid staff API token |
| `request_id` | int | Yes | ID of the mark request to reject |
| `reason` | string | Yes | Rejection reason (minimum 10 characters) |

**Response:**
```json
{
  "success": true,
  "message": "Request rejected successfully.",
  "data": {
    "request_id": 14
  }
}
```

**Error codes:**

| Error Code | Meaning |
|---|---|
| `NOT_FOUND` | Request not found, not assigned to you, or not in `PENDING_LECTURER` status |
| `VALIDATION_ERROR` | `reason` is fewer than 10 characters |
| `ACCESS_DENIED` | No supervisor assigned to staff profile (required for rejection) |
| `MISSING_PARAM` | `request_id` not provided or 0 |

**Notes:**
- The rejection reason is stored in `lecturer_response` and is visible to the student and admin.
- A supervisor must be assigned on the staff profile to reject. This is a policy constraint from the portal — if no supervisor is assigned, neither approval nor rejection can proceed through this workflow.
- After rejection, the student sees the request as `REJECTED` with the provided reason.

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

### 6.8 Fee Access Status (Policy Evaluation)

Evaluates a student against the university's active **Fee Access Policy** — the bursar-defined set of rules that determine whether a student may access academic services (exams, results, registration, etc.) based on their financial standing.

This is the most detailed finance endpoint. It returns the student's profile, the full policy configuration, financial totals, bursary/scholarship status, per-rule evaluation results, a human-readable verdict, and actionable guidance for denied students.

| Property | Value |
|---|---|
| **URL** | `finance.aspx?action=access_status` |
| **Method** | `GET` or `POST` |
| **Auth Required** | Yes |

**Parameters:**

| Parameter | Type | Required | Description |
|---|---|---|---|
| `token` | string | Yes | Valid API token |
| `action` | string | Yes | Must be `access_status` |
| `regno` | string | Staff only | Student registration number. Students are auto-resolved from their token; staff must provide this. |

**Example Request (student):**
```
GET /API/v2/finance.aspx?action=access_status&token=abc123
```

**Example Request (staff checking a student):**
```
GET /API/v2/finance.aspx?action=access_status&regno=2024/BSC/001&token=abc123
```

#### Response Structure

The response always contains the same top-level keys regardless of whether access is granted or denied, ensuring consumers never encounter missing fields.

| Field | Type | Description |
|---|---|---|
| `access_allowed` | boolean | `true` if the student passes the policy (or no policy is active) |
| `has_policy` | boolean | `true` if an active fee access policy exists in the system |
| `verdict` | string | `"granted"` or `"denied"` — human-readable verdict |
| `verdict_reason` | string | Detailed explanation of why access was granted or denied |
| `student` | object | Student profile information |
| `policy` | object\|null | Full policy configuration (null if no active policy) |
| `finance` | object | Student's financial summary |
| `bursary` | object | Bursary/scholarship status |
| `criteria` | array | Per-rule evaluation results |
| `summary` | object | Aggregate pass/fail counters |
| `guidance` | string | Actionable steps for denied students (empty string if granted) |
| `evaluated_at` | string | ISO 8601 UTC timestamp of when evaluation was performed |

#### `student` Object

| Field | Type | Description |
|---|---|---|
| `regno` | string | Registration number |
| `name` | string | Full name (surname + other names) |
| `programme` | string | Programme name (e.g., "Bachelor of Science in Computer Science") |
| `programme_code` | string | Programme code (e.g., "BSC-CS") |
| `study_year` | integer | Current study year (1, 2, 3, etc.) |

#### `policy` Object

| Field | Type | Description |
|---|---|---|
| `policy_id` | integer | Database primary key of the active policy |
| `title` | string | Policy title set by the bursar |
| `academic_year` | string | Academic year the policy applies to (e.g., "2025/2026") |
| `semester` | integer | Semester number (1 or 2) |
| `combination_logic` | string | `"ALL"` or `"ANY"` — how rules are combined |
| `combination_logic_description` | string | Human-readable explanation of the logic |
| `notes` | string | Free-text notes entered by the bursar |
| `updated_at` | string | ISO 8601 timestamp of last policy update |
| `rules_enabled` | object | Boolean map of which rules are turned on |
| `thresholds` | object | Configured threshold values for each rule |

##### `policy.rules_enabled` Object

| Field | Type | Description |
|---|---|---|
| `balance_threshold` | boolean | Whether the balance rule is enabled |
| `payment_window` | boolean | Whether the payment window rule is enabled |
| `percentage_paid` | boolean | Whether the percentage paid rule is enabled |
| `bursary_exemption` | boolean | Whether the bursary exemption rule is enabled |
| `registration` | boolean | Whether the registration rule is enabled |

##### `policy.thresholds` Object

Values are `null` when the corresponding rule is disabled.

| Field | Type | Description |
|---|---|---|
| `max_balance` | decimal\|null | Maximum allowed outstanding balance (UGX) |
| `payment_window_min_amount` | decimal\|null | Minimum payment required within the window |
| `payment_window_start` | string\|null | Window start date (yyyy-MM-dd) |
| `payment_window_end` | string\|null | Window end date (yyyy-MM-dd) |
| `min_percentage_paid` | decimal\|null | Minimum percentage of total fees that must be paid |
| `bursary_min_coverage` | decimal\|null | Minimum bursary coverage percentage for exemption |

#### `finance` Object

| Field | Type | Description |
|---|---|---|
| `total_bill` | decimal | Sum of all debit transactions (fees invoiced) |
| `total_paid` | decimal | Sum of all credit transactions (payments made) |
| `balance` | decimal | Signed balance: **negative** = owing, **positive** = credit |
| `amount_owing` | decimal | Positive value of what the student owes (0 if in credit) |
| `credit_balance` | decimal | Positive value of credit balance (0 if owing) |
| `percentage_paid` | decimal | Percentage of total bill that has been paid (0-100+) |
| `currency` | string | Always `"UGX"` |

> **Note on financial totals:** The query uses `UNION ALL` across `fin_ledger` and `fin_studentfeestracking` (with deduplication via `NOT EXISTS`) to ensure totals match the student's fee statement page exactly.

#### `bursary` Object

| Field | Type | Description |
|---|---|---|
| `status` | string | `"None"` or `"Active: <Scheme Name>"` |
| `scheme_name` | string | Name of the scholarship/bursary scheme |
| `amount_offered` | decimal | Amount offered by the bursary |
| `coverage_percent` | decimal | Percentage of total bill covered by the bursary |
| `exempt` | boolean | `true` if the bursary short-circuited all other rules |

#### `criteria` Array

Each element is an object representing one evaluated rule:

| Field | Type | Description |
|---|---|---|
| `rule` | string | Rule name: `"Balance Threshold"`, `"Payment Window"`, `"Percentage Paid"`, `"Bursary Exemption"`, `"Registration"`, or `"No Active Restriction"` |
| `passed` | boolean | Whether the student passed this rule |
| `enabled` | boolean | Whether this rule is enabled in the policy |
| `detail` | string | Human-readable explanation of the evaluation result |
| `threshold` | string\|null | The configured threshold for this rule |
| `actual_value` | string\|null | The student's actual value against this rule |

#### `summary` Object

| Field | Type | Description |
|---|---|---|
| `total_rules` | integer | Number of rules evaluated |
| `rules_passed` | integer | Number of rules the student passed |
| `rules_failed` | integer | Number of rules the student failed |
| `enabled_rules` | array | List of enabled rule names (strings) |

---

#### Access Decision Logic

```
1. If no active policy exists (is_active ≠ 'yes'):
   → access_allowed = true, has_policy = false

2. If policy is active but NO rules are enabled:
   → access_allowed = true (no rules to fail)

3. If Bursary Exemption is enabled AND student has an approved bursary
   with coverage ≥ bursary_min_coverage:
   → access_allowed = true (short-circuit, other rules skipped)

4. Otherwise, evaluate all enabled rules:
   - If combination_logic = "ALL": student must pass EVERY enabled rule
   - If combination_logic = "ANY": student must pass AT LEAST ONE enabled rule

5. Guidance is generated only when access_allowed = false,
   with specific actionable tips per failed rule.
```

---

#### Example Response — Access Denied (ALL logic, 2 rules fail)

```json
{
  "success": true,
  "message": "OK",
  "data": {
    "access_allowed": false,
    "has_policy": true,
    "verdict": "denied",
    "verdict_reason": "2 of 3 rule(s) failed. Policy requires ALL rules to pass.",
    "student": {
      "regno": "2024/BSC/001",
      "name": "DOE John",
      "programme": "Bachelor of Science in Computer Science",
      "programme_code": "BSC-CS",
      "study_year": 2
    },
    "policy": {
      "policy_id": 1,
      "title": "University campus access",
      "academic_year": "2025/2026",
      "semester": 1,
      "combination_logic": "ALL",
      "combination_logic_description": "Student must satisfy ALL enabled rules to pass",
      "notes": "Enforced for Semester 1",
      "updated_at": "2026-04-15T10:30:00Z",
      "rules_enabled": {
        "balance_threshold": true,
        "payment_window": false,
        "percentage_paid": true,
        "bursary_exemption": false,
        "registration": true
      },
      "thresholds": {
        "max_balance": 500000,
        "payment_window_min_amount": null,
        "payment_window_start": null,
        "payment_window_end": null,
        "min_percentage_paid": 60,
        "bursary_min_coverage": null
      }
    },
    "finance": {
      "total_bill": 2500000,
      "total_paid": 800000,
      "balance": -1700000,
      "amount_owing": 1700000,
      "credit_balance": 0,
      "percentage_paid": 32.0,
      "currency": "UGX"
    },
    "bursary": {
      "status": "None",
      "scheme_name": "",
      "amount_offered": 0,
      "coverage_percent": 0,
      "exempt": false
    },
    "criteria": [
      {
        "rule": "Balance Threshold",
        "passed": false,
        "enabled": true,
        "detail": "Outstanding balance of 1,700,000 exceeds the allowed maximum of 500,000.",
        "threshold": "Max balance: UGX 500,000",
        "actual_value": "UGX 1,700,000"
      },
      {
        "rule": "Percentage Paid",
        "passed": false,
        "enabled": true,
        "detail": "Only 32.0% of total fees paid (required: 60%).",
        "threshold": "Min 60% paid",
        "actual_value": "32.0%"
      },
      {
        "rule": "Registration",
        "passed": true,
        "enabled": true,
        "detail": "Student is registered for 2025/2026 Semester 1.",
        "threshold": "Registered for 2025/2026 Sem 1",
        "actual_value": "Registered"
      }
    ],
    "summary": {
      "total_rules": 3,
      "rules_passed": 1,
      "rules_failed": 2,
      "enabled_rules": ["Balance Threshold", "Percentage Paid", "Registration"]
    },
    "guidance": "Pay at least UGX 1,200,000 to reduce the outstanding balance to the allowed maximum of UGX 500,000. Pay an additional UGX 700,000 to reach the required 60%.",
    "evaluated_at": "2026-04-16T08:45:12Z"
  },
  "timestamp": "2026-04-16T08:45:12.1234567Z"
}
```

#### Example Response — Access Granted (no policy active)

```json
{
  "success": true,
  "message": "OK",
  "data": {
    "access_allowed": true,
    "has_policy": false,
    "verdict": "granted",
    "verdict_reason": "No active fee access policy. All students are granted full access.",
    "student": {
      "regno": "2024/BSC/001",
      "name": "DOE John",
      "programme": "Bachelor of Science in Computer Science",
      "programme_code": "BSC-CS",
      "study_year": 2
    },
    "policy": null,
    "finance": {
      "total_bill": 0,
      "total_paid": 0,
      "balance": 0,
      "percentage_paid": 0,
      "currency": "UGX"
    },
    "bursary": {
      "status": "None",
      "scheme_name": "",
      "amount_offered": 0,
      "coverage_percent": 0
    },
    "criteria": [
      {
        "rule": "No Active Restriction",
        "passed": true,
        "enabled": false,
        "detail": "Fee access policy is currently disabled. No restrictions are being enforced.",
        "threshold": null
      }
    ],
    "summary": {
      "total_rules": 0,
      "rules_passed": 0,
      "rules_failed": 0,
      "enabled_rules": []
    },
    "guidance": "No active fee access restrictions. All students are granted access.",
    "evaluated_at": "2026-04-16T08:45:12Z"
  },
  "timestamp": "2026-04-16T08:45:12.1234567Z"
}
```

#### Example Response — Bursary Exemption (short-circuit)

```json
{
  "success": true,
  "message": "OK",
  "data": {
    "access_allowed": true,
    "has_policy": true,
    "verdict": "granted",
    "verdict_reason": "Student is exempt via bursary/scholarship (Government Scholarship).",
    "student": {
      "regno": "2024/BSC/002",
      "name": "SMITH Jane",
      "programme": "Bachelor of Arts in Education",
      "programme_code": "BA-ED",
      "study_year": 1
    },
    "policy": {
      "policy_id": 1,
      "title": "University campus access",
      "academic_year": "2025/2026",
      "semester": 1,
      "combination_logic": "ALL",
      "combination_logic_description": "Student must satisfy ALL enabled rules to pass",
      "notes": "",
      "updated_at": "2026-04-15T10:30:00Z",
      "rules_enabled": {
        "balance_threshold": true,
        "payment_window": false,
        "percentage_paid": true,
        "bursary_exemption": true,
        "registration": false
      },
      "thresholds": {
        "max_balance": 500000,
        "payment_window_min_amount": null,
        "payment_window_start": null,
        "payment_window_end": null,
        "min_percentage_paid": 60,
        "bursary_min_coverage": 80
      }
    },
    "finance": {
      "total_bill": 2500000,
      "total_paid": 100000,
      "balance": -2400000,
      "amount_owing": 2400000,
      "credit_balance": 0,
      "percentage_paid": 4.0,
      "currency": "UGX"
    },
    "bursary": {
      "status": "Active: Government Scholarship",
      "scheme_name": "Government Scholarship",
      "amount_offered": 2200000,
      "coverage_percent": 88.0,
      "exempt": true
    },
    "criteria": [
      {
        "rule": "Bursary Exemption",
        "passed": true,
        "enabled": true,
        "detail": "Bursary/scholarship (Government Scholarship) with 88% coverage — exempt.",
        "threshold": "Min coverage: 80%",
        "actual_value": "88%"
      }
    ],
    "summary": {
      "total_rules": 1,
      "rules_passed": 1,
      "rules_failed": 0,
      "enabled_rules": ["Balance Threshold", "Percentage Paid", "Bursary Exemption"]
    },
    "guidance": "",
    "evaluated_at": "2026-04-16T08:45:12Z"
  },
  "timestamp": "2026-04-16T08:45:12.1234567Z"
}
```

#### Available Access Rules

| Rule | DB Column (enabled) | DB Column (threshold) | Description |
|---|---|---|---|
| **Balance Threshold** | `rule_min_balance_enabled` | `rule_min_balance_amount` | Deny access if outstanding balance exceeds the max amount. |
| **Payment Window** | `rule_payment_window_enabled` | `rule_payment_min_amount`, `rule_payment_window_start`, `rule_payment_window_end` | Require a minimum payment within a specific date range. |
| **Percentage Paid** | `rule_pct_paid_enabled` | `rule_pct_paid_minimum` | Require at least X% of total fees to be paid. |
| **Bursary Exemption** | `rule_bursary_exempt` | `rule_bursary_min_coverage` | Auto-exempt students whose approved bursary covers ≥ X% of fees. If met, all other rules are skipped. |
| **Registration** | `rule_require_registration` | *(none)* | Checks `acad_registration` for active registration in the policy's academic year/semester. |

#### Database Tables Used

| Table | Database | Purpose |
|---|---|---|
| `fin_fee_access_policy` | `campus_dynamics_accounts` | Stores the policy configuration (one active row at a time) |
| `fin_ledger` | `campus_dynamics_accounts` | Primary financial ledger (debits/credits) |
| `fin_studentfeestracking` | `campus_dynamics_accounts` | Supplementary fee tracking (UNION'd with ledger, deduplicated) |
| `scholarshipstudents` | `campus_dynamics_accounts` | Bursary/scholarship assignments per student |
| `scholarships` | `campus_dynamics_accounts` | Scholarship scheme definitions |
| `acad_registration` | `campus_dynamics` | Student registration records |
| `acad_student` | `campus_dynamics` | Student profile (name, programme) |
| `acad_programme` | `campus_dynamics` | Programme definitions |

#### Error Codes

| Code | Description |
|---|---|
| `ACCESS_STATUS_ERROR` | General error during evaluation (DB connection, missing table, etc.) |
| `AUTH_REQUIRED` | No valid token provided |
| `MISSING_PARAM` | Staff request without `regno` parameter |

#### Integration Notes

- **Portal (Student-Facing):** The student portal's `PortalMaster.master.cs` calls `FeeAccessHelper.Evaluate()` on every page load (with 5-minute session cache). If `access_allowed = false`, a global restriction banner is displayed above page content. The banner is **not shown** when there is no restriction.
- **Admin Checker:** The admin page `FeeAccessChecker.aspx` calls this endpoint to let staff look up any student's access status.
- **Mobile / ODEL:** External systems can call this endpoint to gate access to resources (e.g., Moodle course materials) based on fee payment status.
- **Caching:** The portal caches the result in the user's session for 5 minutes. API consumers should implement their own caching strategy.
- **Balance Sign Convention:** The `finance.balance` field is **negative when the student owes money** and **positive when they have a credit**. The `finance.amount_owing` and `finance.credit_balance` fields provide unsigned convenience values.

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

Returns published campus notices for the authenticated user, filtered by their role (student or staff).
Notices are sourced from `sys_communications` in the portal database.

| Property | Value |
|---|---|
| **URL** | `campus.aspx?action=notices` |
| **Method** | `GET` or `POST` |
| **Auth Required** | Yes |

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
        "preview": "The examination timetable for Semester 2 has been released. Please check...",
        "target_audience": "STUDENT",
        "priority": "HIGH",
        "is_force_read": "0",
        "author": "Academic Registrar",
        "published_at": "2025-06-01 09:00",
        "attachment_count": "2",
        "is_read": "1",
        "read_at": "2025-06-02 14:30"
      }
    ],
    "unread_count": 3,
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

- Source: `sys_communications` in `campus_dynamics_portal` database.
- Filtered by `status = 'PUBLISHED'` and `target_audience IN ('BOTH', user_role)`.
- Student tokens see `STUDENT` and `BOTH` notices; staff tokens see `STAFF` and `BOTH` notices.
- `preview` is truncated to 300 characters — use `notice_detail` for full content.
- `is_read` is `1` if the user has opened this notice, `0` otherwise.
- Ordered by `priority DESC, published_at DESC`.

---

### 8.5a Notice Detail (Authenticated)

Returns a single notice with full content and attachments. Auto-marks the notice as read for the current user.

| Property | Value |
|---|---|
| **URL** | `campus.aspx?action=notice_detail` |
| **Method** | `GET` or `POST` |
| **Auth Required** | Yes |

**Parameters:**

| Parameter | Type | Required | Description |
|---|---|---|---|
| `action` | string | Yes | Must be `notice_detail` |
| `token` | string | Yes | Valid auth token |
| `notice_id` | int | Yes | ID of the notice (`sys_communications.ID`) |

**Example Request:**

```bash
curl "https://eadmin.mru.ac.ug/API/v2/campus.aspx?action=notice_detail&token=a1b2c3d4e5f6...&notice_id=1"
```

**Success Response:**

```json
{
  "status": "success",
  "data": {
    "notice_id": "1",
    "title": "Examination Timetable Released",
    "content": "<p>The examination timetable for Semester 2 has been released. Students are advised to...</p>",
    "target_audience": "STUDENT",
    "priority": "HIGH",
    "is_force_read": "0",
    "allow_comments": "0",
    "author": "Academic Registrar",
    "published_at": "2025-06-01 09:00",
    "created_at": "2025-05-31 16:00",
    "attachment_count": "2",
    "is_read": "1",
    "read_at": "2025-06-02 14:30",
    "attachments": [
      {
        "attachment_id": "5",
        "file_name": "exam_timetable_sem2.pdf",
        "file_path": "Data_Uploads/Communications/exam_timetable_sem2.pdf",
        "file_type": "application/pdf",
        "file_size": "524288"
      }
    ]
  }
}
```

**Error Responses:**

| Code | Meaning |
|---|---|
| `NOT_FOUND` | Notice does not exist or is not published / not visible to this user type |
| `MISSING_PARAM` | `notice_id` not provided |
| `INVALID_PARAM` | `notice_id` is not a number |

---

### 8.5b Mark Notice as Read (Authenticated)

Marks a specific notice as read for the authenticated user. Safe to call multiple times (idempotent).

| Property | Value |
|---|---|
| **URL** | `campus.aspx?action=mark_read` |
| **Method** | `GET` or `POST` |
| **Auth Required** | Yes |

**Parameters:**

| Parameter | Type | Required | Description |
|---|---|---|---|
| `action` | string | Yes | Must be `mark_read` |
| `token` | string | Yes | Valid auth token |
| `notice_id` | int | Yes | ID of the notice to mark as read |

**Example Request:**

```bash
curl "https://eadmin.mru.ac.ug/API/v2/campus.aspx?action=mark_read&token=a1b2c3d4e5f6...&notice_id=1"
```

**Success Response:**

```json
{
  "status": "success",
  "data": {
    "notice_id": 1,
    "marked_read": true
  }
}
```

**Notes:**

- Inserts into `sys_communication_reads(communication_id, user_id, read_at)`.
- On duplicate key, does nothing (first read timestamp is preserved).
- `notice_detail` action also auto-marks the notice as read when fetched.

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

#### Notices — `sys_communications` (portal DB: campus_dynamics_portal)

The notices endpoint reads from `sys_communications` in the portal database, which is also used by the web portal notice board. The migration in `NewScreens/migrations/comm_module_migration.sql` creates this table.

Key columns: `ID`, `title`, `content`, `target_audience` (`STUDENT`/`STAFF`/`BOTH`), `priority`, `is_force_read`, `status` (`PUBLISHED`/`DRAFT`), `created_by_name`, `published_at`.

Read tracking: `sys_communication_reads(communication_id, user_id, read_at)` — unique per user per notice.

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
| `staff.aspx` | `class_list` | GET/POST | Token (staff) | Students in a course with mark status |
| `staff.aspx` | `marks` | GET/POST | Token (staff) | View course marks |
| `staff.aspx` | `submit_marks` | POST | Token (staff) | Submit/update marks |
| `staff.aspx` | `filter_options` | GET/POST | Token (staff) | Filter dropdown data (years, programmes, courses, statuses) |
| `staff.aspx` | `all_courses` | GET/POST | Token (staff) | Full course catalogue — searchable by ?q=, no assignment restriction |
| `staff.aspx` | `student_search` | GET/POST | Token (staff) | Live student search by name / entry number / regno — returns photo, programme, entry_no |
| `staff.aspx` | `course_allocation_search` | GET | Token (staff) | Search course catalogue to pick courses for self-allocation |
| `staff.aspx` | `course_allocation_submit` | POST | Token (staff) | Self-allocate to one or more courses (immediate, auto-approved) |
| `staff.aspx` | `course_unassign` | POST | Token (staff) | Remove self from a course allocation |
| `staff.aspx` | `course_reg_summary` | GET | Token (staff) | KPI counts for students enrolled in lecturer's courses |
| `staff.aspx` | `course_reg_list` | GET | Token (staff) | Paginated list of students enrolled in lecturer's courses |
| `staff.aspx` | `course_reg_validate_student` | GET | Token (staff) | Look up student + get registration options before enrolment |
| `staff.aspx` | `course_reg_enroll` | POST | Token (staff) | Enrol a student into one of the lecturer's courses |
| `staff.aspx` | `course_reg_student_courses` | GET | Token (staff) | All courses a specific student is registered for |
| `staff.aspx` | `course_reg_popularity` | GET | Token (staff) | Top N courses by enrolment count (lecturer's courses only) |
| `staff.aspx` | `lmr_requests` | GET | Token (staff) | List all mark-change/missing-mark requests assigned to lecturer |
| `staff.aspx` | `lmr_respond` | POST | Token (staff) | Respond to a PENDING_LECTURER request with proposed marks |
| `staff.aspx` | `lmr_reject` | POST | Token (staff) | Reject a PENDING_LECTURER request with a reason |
| `staff.aspx` | `mark_sheet` | GET/POST | Token (staff) | Entry-level mark sheet |
| `staff.aspx` | `save_entry_marks` | POST | Token (staff) | Save marks to faculty table |
| `staff.aspx` | `submit_for_approval` | POST | Token (staff) | Submit sheet for dean approval |
| `staff.aspx` | `sheet_status` | GET/POST | Token (staff) | Marks workflow status |
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

## 8a. Support Tickets (support.aspx)

**Endpoint file:** `support.aspx`  
**Base URL:** `https://eadmin.mru.ac.ug/API/v2/support.aspx`  
**Database:** `campus_dynamics_portal` — tables `support_tickets`, `support_ticket_messages`, `support_ticket_attachments`

The support ticket system lets students submit complaints/requests and track responses from staff. Staff see all tickets and can reply, reassign, change priority, and update status.

### Database Schema

#### `support_tickets`
| Column | Type | Notes |
|---|---|---|
| `ticket_id` | INT PK | Auto-increment |
| `submitter_regno` | VARCHAR(50) | Student regno or staff username |
| `submitter_name` | VARCHAR(150) | Display name at time of submission |
| `submitter_type` | ENUM | `STUDENT`, `LECTURER`, `STAFF` |
| `issue_type` | VARCHAR(80) | Full category string e.g. `Academic — Results & Marks` |
| `subject` | VARCHAR(250) | |
| `status` | ENUM | `OPEN`, `IN_PROGRESS`, `AWAITING_REPLY`, `RESOLVED`, `CLOSED` |
| `priority` | ENUM | `LOW`, `NORMAL`, `HIGH`, `URGENT` (default `NORMAL`) |
| `assigned_to` | VARCHAR(100) | Staff username, nullable |
| `created_at` | DATETIME | |
| `updated_at` | DATETIME | Auto-updated |
| `closed_at` | DATETIME | Set when CLOSED or RESOLVED |
| `closed_by` | VARCHAR(100) | |

#### `support_ticket_messages`
| Column | Type | Notes |
|---|---|---|
| `message_id` | INT PK | |
| `ticket_id` | INT FK | |
| `sender_regno` | VARCHAR(50) | |
| `sender_name` | VARCHAR(150) | |
| `sender_role` | ENUM | `SUBMITTER`, `ADMIN`, `SYSTEM` |
| `message` | TEXT | For SYSTEM messages: `STATUS_CHANGE:{STATUS}` |
| `is_internal` | TINYINT(1) | `1` = staff-only note, never visible to students |
| `created_at` | DATETIME | |

#### `support_ticket_attachments`
| Column | Type | Notes |
|---|---|---|
| `attachment_id` | INT PK | |
| `ticket_id` | INT | |
| `message_id` | INT | Which message this file belongs to (nullable = ticket-level) |
| `original_name` | VARCHAR(255) | Original filename |
| `stored_name` | VARCHAR(255) | GUID-based filename on disk |
| `file_size` | INT | Bytes |
| `mime_type` | VARCHAR(100) | |
| `uploaded_by` | VARCHAR(100) | |
| `uploaded_at` | DATETIME | |

### Status Flow

```
OPEN  ──(student reply)──▶  IN_PROGRESS
OPEN  ──(admin reply)───▶  AWAITING_REPLY
IN_PROGRESS ──(admin reply)──▶  AWAITING_REPLY
AWAITING_REPLY ──(student reply)──▶  IN_PROGRESS
Any (except CLOSED) ──(staff action)──▶  RESOLVED
Any (except CLOSED) ──(staff or owner)──▶  CLOSED
```

Status transitions are auto-applied by `AddMessage()`: admin reply → `AWAITING_REPLY`; student reply → `IN_PROGRESS`. Tickets in `RESOLVED` or `CLOSED` do not accept new replies.

### Ticket Reference Format

`TKT-00001` (5-digit zero-padded `ticket_id`)

### Valid Issue Types

Use `action=issue_types` to get the canonical list. Categories:
- **Academic**: Results & Marks, Transcripts & Certificates, Course Registration, Other
- **Financial**: Fees & Payments, Receipt or Invoice, Financial Aid, Other
- **Registration**: Semester Registration, Course Registration, Programme Change, Other
- **Other**: Portal Login Issue, System Error or Bug, General Inquiry, Complaint or Suggestion

### File Upload Rules

- Allowed extensions: `.jpg`, `.jpeg`, `.png`, `.gif`, `.pdf`, `.doc`, `.docx`, `.txt`
- Max file size: **5 MB per file**
- Stored as `{GUID}.{ext}` in `~/COOPERP/Support/Uploads/`

---

### 8a.1 Issue Types (Public — no token required)

Returns the canonical list of issue type values for the create form.

| Property | Value |
|---|---|
| **URL** | `support.aspx?action=issue_types` |
| **Method** | GET |
| **Auth** | None |

**Response:**
```json
{
  "status": "success",
  "data": {
    "issue_types": [
      { "category": "Academic", "value": "Academic — Results & Marks" },
      { "category": "Academic", "value": "Academic — Transcripts & Certificates" },
      { "category": "Financial", "value": "Financial — Fees & Payments" }
    ]
  }
}
```

---

### 8a.2 List Tickets

Returns a paginated list of tickets. Students see only their own; staff see all.

| Property | Value |
|---|---|
| **URL** | `support.aspx?action=list&token=...` |
| **Method** | GET |
| **Auth** | Required |

**Parameters (students):**

| Parameter | Type | Default | Description |
|---|---|---|---|
| `status` | string | `ALL` | Filter: `OPEN`, `IN_PROGRESS`, `AWAITING_REPLY`, `RESOLVED`, `CLOSED` |
| `page` | int | 1 | Page number |
| `size` | int | 20 | Items per page (max 100) |

**Additional parameters (staff only):**

| Parameter | Type | Description |
|---|---|---|
| `issue_type` | string | Prefix match e.g. `Academic` |
| `priority` | string | `LOW`, `NORMAL`, `HIGH`, `URGENT` |
| `assigned_to` | string | Staff username |
| `q` | string | Search submitter name, regno, or subject |

**Response:**
```json
{
  "status": "success",
  "data": {
    "total": 12,
    "page": 1,
    "size": 20,
    "pages": 1,
    "tickets": [
      {
        "ticket_id": "3",
        "issue_type": "Academic — Results & Marks",
        "subject": "Missing mark for MTH101",
        "status": "AWAITING_REPLY",
        "priority": "HIGH",
        "assigned_to": "registrar",
        "created_at": "2025-06-01 08:00:00",
        "updated_at": "2025-06-02 14:30:00",
        "ref": "TKT-00003",
        "status_label": "Awaiting Reply",
        "status_color": "#7c3aed",
        "status_bg": "rgba(124,58,237,.12)",
        "priority_color": "#d97706",
        "issue_short": "Academic",
        "issue_color": "#174DA4"
      }
    ]
  }
}
```

---

### 8a.3 Ticket Detail

Returns a single ticket with full message thread and attachment list.

| Property | Value |
|---|---|
| **URL** | `support.aspx?action=detail&ticket_id=3&token=...` |
| **Method** | GET |
| **Auth** | Required (student must own the ticket) |

**Parameters:**

| Parameter | Type | Required | Description |
|---|---|---|---|
| `ticket_id` | int | Yes | ID of the ticket |

**Response:**
```json
{
  "status": "success",
  "data": {
    "ticket_id": "3",
    "submitter_regno": "MRU2024000012",
    "submitter_name": "John Doe",
    "submitter_type": "STUDENT",
    "issue_type": "Academic — Results & Marks",
    "subject": "Missing mark for MTH101",
    "status": "AWAITING_REPLY",
    "priority": "HIGH",
    "assigned_to": "registrar",
    "created_at": "2025-06-01 08:00:00",
    "updated_at": "2025-06-02 14:30:00",
    "closed_at": null,
    "closed_by": null,
    "ref": "TKT-00003",
    "status_label": "Awaiting Reply",
    "status_color": "#7c3aed",
    "status_bg": "rgba(124,58,237,.12)",
    "priority_color": "#d97706",
    "issue_short": "Academic",
    "issue_color": "#174DA4",
    "messages": [
      {
        "message_id": "1",
        "sender_regno": "MRU2024000012",
        "sender_name": "John Doe",
        "sender_role": "SUBMITTER",
        "message": "My mark for MTH101 is missing from the portal...",
        "is_internal": "0",
        "created_at": "2025-06-01 08:00:00"
      },
      {
        "message_id": "2",
        "sender_regno": "registrar",
        "sender_name": "Academic Registrar",
        "sender_role": "ADMIN",
        "message": "We are looking into this. Please allow 48 hours.",
        "is_internal": "0",
        "created_at": "2025-06-02 14:30:00"
      }
    ],
    "attachments": [
      {
        "attachment_id": "1",
        "message_id": "1",
        "original_name": "exam_card.jpg",
        "stored_name": "a1b2c3d4.jpg",
        "file_size": "204800",
        "mime_type": "image/jpeg",
        "download_url": "support.aspx?action=attachment&ticket_id=3&attachment_id=1"
      }
    ]
  }
}
```

**Notes:**
- `sender_role = SYSTEM` messages have `message = "STATUS_CHANGE:{STATUS}"` — render as timeline events, not chat bubbles.
- Staff see messages where `is_internal = 1`; students never see these.

---

### 8a.4 Create Ticket

Submit a new support ticket.

| Property | Value |
|---|---|
| **URL** | `support.aspx?action=create` |
| **Method** | POST |
| **Auth** | Required |

**Parameters:**

| Parameter | Type | Required | Description |
|---|---|---|---|
| `issue_type` | string | Yes | Full issue type value from `issue_types` action |
| `subject` | string | Yes | Short title (max 250 chars) |
| `message` | string | Yes | Initial message / description |
| `priority` | string | No | `LOW`, `NORMAL`, `HIGH`, `URGENT` (default `NORMAL`) |

**Rate limit:** Students may submit at most **5 tickets per 60 minutes**.

**Response:**
```json
{
  "status": "success",
  "message": "Ticket submitted successfully",
  "data": {
    "ticket_id": 3,
    "ref": "TKT-00003",
    "status": "OPEN",
    "priority": "NORMAL"
  }
}
```

**Errors:**

| Code | Meaning |
|---|---|
| `RATE_LIMITED` | Student has submitted 5 or more tickets in the last hour |
| `MISSING_PARAM` | `issue_type`, `subject`, or `message` not provided |

---

### 8a.5 Reply to Ticket

Add a message to an existing ticket.

| Property | Value |
|---|---|
| **URL** | `support.aspx?action=reply` |
| **Method** | POST (supports multipart for file attachments) |
| **Auth** | Required (student must own the ticket) |

**Parameters:**

| Parameter | Type | Required | Description |
|---|---|---|---|
| `ticket_id` | int | Yes | Ticket to reply to |
| `message` | string | Yes | Reply text |
| `is_internal` | `0`/`1` | No (staff only) | If `1`, message is visible to staff only |
| Files | multipart | No | Up to 3 files, 5 MB each, allowed extensions only |

**Status auto-advance:**
- Student reply → ticket status becomes `IN_PROGRESS` (unless already CLOSED/RESOLVED)
- Admin reply → ticket status becomes `AWAITING_REPLY` (unless already CLOSED/RESOLVED)

**Response:**
```json
{
  "status": "success",
  "message": "Reply added",
  "data": {
    "message_id": 5,
    "ticket_id": 3,
    "is_internal": false
  }
}
```

**Errors:**

| Code | Meaning |
|---|---|
| `TICKET_CLOSED` | Ticket is CLOSED or RESOLVED — open a new ticket |
| `FORBIDDEN` | Student trying to reply to another user's ticket |

---

### 8a.6 Update Ticket (Staff Only)

Change status, priority, and/or assigned handler in one call.

| Property | Value |
|---|---|
| **URL** | `support.aspx?action=update_status` |
| **Method** | POST |
| **Auth** | Staff only |

**Parameters (at least one required besides `ticket_id`):**

| Parameter | Type | Description |
|---|---|---|
| `ticket_id` | int | Required |
| `status` | string | `OPEN`, `IN_PROGRESS`, `AWAITING_REPLY`, `RESOLVED`, `CLOSED` |
| `priority` | string | `LOW`, `NORMAL`, `HIGH`, `URGENT` |
| `assigned_to` | string | Staff username to assign |

When `status` changes, a `SYSTEM` message `STATUS_CHANGE:{STATUS}` is automatically inserted into the thread for the audit trail.

**Response:**
```json
{
  "status": "success",
  "message": "Ticket updated",
  "data": {
    "ticket_id": 3,
    "new_status": "RESOLVED"
  }
}
```

---

### 8a.7 Close Ticket

Close a ticket. Students can close their own; staff can close any.

| Property | Value |
|---|---|
| **URL** | `support.aspx?action=close` |
| **Method** | POST |
| **Auth** | Required |

**Parameters:**

| Parameter | Type | Required | Description |
|---|---|---|---|
| `ticket_id` | int | Yes | Ticket to close |

**Response:**
```json
{
  "status": "success",
  "message": "Ticket closed",
  "data": { "ticket_id": 3, "status": "CLOSED" }
}
```

**Errors:**

| Code | Meaning |
|---|---|
| `ALREADY_CLOSED` | Ticket is already in CLOSED state |
| `FORBIDDEN` | Student trying to close another user's ticket |

---

### 8a.8 Stats

Returns ticket counts by status.

| Property | Value |
|---|---|
| **URL** | `support.aspx?action=stats&token=...` |
| **Method** | GET |
| **Auth** | Required |

**Student response** (scoped to own tickets):
```json
{
  "data": {
    "total": 5, "open": 1, "in_progress": 1,
    "awaiting_reply": 2, "resolved": 1, "closed": 0
  }
}
```

**Staff response** (all tickets):
```json
{
  "data": {
    "total": 120, "open": 18, "in_progress": 7,
    "awaiting_reply": 12, "resolved": 80, "closed": 3,
    "urgent_open": 4
  }
}
```

---

### 8a.9 Download Attachment

Streams a ticket attachment file. Must own the ticket (student) or be staff.

| Property | Value |
|---|---|
| **URL** | `support.aspx?action=attachment&ticket_id=3&attachment_id=1&token=...` |
| **Method** | GET |
| **Auth** | Required |

Returns the raw file with correct `Content-Type` and `Content-Disposition: attachment` header. Use the `download_url` from the `detail` response directly.

---

## 9. Applicant Endpoints (apply.aspx)

**Endpoint file:** `apply.aspx`  
**Base URL:** `https://eadmin.mru.ac.ug/API/v2/apply.aspx`

This endpoint file handles the complete student application lifecycle for mobile apps. It mirrors the web portal at `https://eportal.mru.ac.ug/apply/` and stores data in the same database tables.

### Authentication for Applicants

Applicant tokens differ from student/staff tokens:
- `user_type` = `"applicant"` in the `api_tokens` table
- Token is obtained by calling `apply.aspx?action=login`
- Pass the token as `?token=<value>` or as a POST parameter
- Token is valid for 24 hours

**Applicant token in request:**
```
GET apply.aspx?action=get_draft&token=abc123...
POST apply.aspx?action=save_step1&token=abc123...
```

### Application Status Flow

```
DRAFT → SUBMITTED → UNDER_REVIEW → ADMITTED
                                  → REJECTED
                  → WITHDRAWN
```

### Admission Status Values (`adm_status` in `acad_applicant_choices`)

| Value | Meaning |
|---|---|
| 0 | PENDING |
| 1 | ADMITTED |
| 2 | REJECTED |
| 3 | WITHDRAWN |

---

### 9.1 Register Applicant Account

Creates a new applicant account and sends an email OTP for verification.

| Property | Value |
|---|---|
| **URL** | `apply.aspx?action=register` |
| **Method** | GET or POST |
| **Auth Required** | No |

**Parameters:**

| Parameter | Type | Required | Description |
|---|---|---|---|
| `first_name` | string | Yes | Applicant's first name |
| `last_name` | string | Yes | Applicant's last name |
| `email` | string | Yes | Email address (must be valid, used as login) |
| `password` | string | Yes | Minimum 6 characters |
| `phone` | string | No | Mobile phone number |

**Success Response:**

```json
{
  "status": "success",
  "message": "Account created. Check your email for the verification code.",
  "data": {
    "user_id": 142,
    "email": "john.doe@example.com",
    "full_name": "John Doe",
    "otp_sent": true,
    "verified": false
  }
}
```

**Error Responses:**

| Code | Message |
|---|---|
| `VALIDATION_ERROR` | Invalid email address / Password must be at least 6 characters |
| `EMAIL_EXISTS` | An account with this email already exists |
| `SERVER_ERROR` | Account creation failed |

---

### 9.2 Login

Authenticates an applicant and returns an access token.

| Property | Value |
|---|---|
| **URL** | `apply.aspx?action=login` |
| **Method** | GET or POST |
| **Auth Required** | No |

**Parameters:**

| Parameter | Type | Required | Description |
|---|---|---|---|
| `email` | string | Yes | Registered email address |
| `password` | string | Yes | Account password |

**Success Response:**

```json
{
  "status": "success",
  "message": "Login successful",
  "data": {
    "token": "a1b2c3d4e5f6...64_hex_characters...",
    "user_id": 142,
    "email": "john.doe@example.com",
    "full_name": "John Doe",
    "phone": "+256700123456",
    "is_verified": true,
    "expires_at": "2026-05-25T10:30:00.000Z"
  }
}
```

**Note:** `is_verified: false` means the account email has not been verified. The applicant should still be allowed to proceed, but send them to the verification screen.

**Error Responses:**

| Code | Message |
|---|---|
| `INVALID_CREDENTIALS` | Invalid email or password |
| `ACCOUNT_LOCKED` | Account temporarily locked — includes minutes remaining |

**Account Lockout:** After 5 failed login attempts, the account is locked for 15 minutes.

---

### 9.3 Verify Email (OTP)

Verifies the applicant's email address using the 6-digit OTP sent during registration (or resend_otp).

| Property | Value |
|---|---|
| **URL** | `apply.aspx?action=verify_email` |
| **Method** | GET or POST |
| **Auth Required** | No |

**Parameters:**

| Parameter | Type | Required | Description |
|---|---|---|---|
| `email` | string | Yes | Registered email address |
| `otp` | string | Yes | 6-digit OTP from email |

**Success Response:**

```json
{
  "status": "success",
  "message": "Email verified successfully.",
  "data": { "verified": true }
}
```

**Error Responses:**

| Code | Message |
|---|---|
| `NOT_FOUND` | Account not found |
| `INVALID_OTP` | Invalid or expired verification code (OTP expires after 30 minutes) |

---

### 9.4 Resend OTP

Invalidates any existing OTP and sends a fresh one to the applicant's email.

| Property | Value |
|---|---|
| **URL** | `apply.aspx?action=resend_otp` |
| **Method** | GET or POST |
| **Auth Required** | No |

**Parameters:**

| Parameter | Type | Required | Description |
|---|---|---|---|
| `email` | string | Yes | Registered email address |

**Success Response:**

```json
{
  "status": "success",
  "message": "Verification code sent.",
  "data": { "otp_sent": true }
}
```

**Error Responses:**

| Code | Message |
|---|---|
| `NOT_FOUND` | Account not found |

---

### 9.5 Forgot Password

Sends a 6-digit password reset OTP to the applicant's email. Always returns success to prevent email enumeration.

| Property | Value |
|---|---|
| **URL** | `apply.aspx?action=forgot_password` |
| **Method** | GET or POST |
| **Auth Required** | No |

**Parameters:**

| Parameter | Type | Required | Description |
|---|---|---|---|
| `email` | string | Yes | Registered email address |

**Success Response:**

```json
{
  "status": "success",
  "message": "If an account with that email exists, a reset code has been sent.",
  "data": { "sent": true }
}
```

> Always returns success regardless of whether the email exists (anti-enumeration).

---

### 9.6 Reset Password

Verifies the reset OTP and sets a new password.

| Property | Value |
|---|---|
| **URL** | `apply.aspx?action=reset_password` |
| **Method** | GET or POST |
| **Auth Required** | No |

**Parameters:**

| Parameter | Type | Required | Description |
|---|---|---|---|
| `email` | string | Yes | Registered email address |
| `otp` | string | Yes | 6-digit OTP from forgot_password email |
| `new_password` | string | Yes | New password (minimum 6 characters) |

**Success Response:**

```json
{
  "status": "success",
  "message": "Password reset successfully.",
  "data": { "reset": true }
}
```

**Error Responses:**

| Code | Message |
|---|---|
| `VALIDATION_ERROR` | Password must be at least 6 characters |
| `NOT_FOUND` | Account not found |
| `INVALID_OTP` | Invalid or expired reset code |

---

### 9.7 My Profile

Returns the logged-in applicant's profile and a summary of their current application.

| Property | Value |
|---|---|
| **URL** | `apply.aspx?action=my_profile` |
| **Method** | GET or POST |
| **Auth Required** | Yes (applicant token) |

**Success Response:**

```json
{
  "status": "success",
  "data": {
    "email": "john.doe@example.com",
    "verified_email": "john.doe@example.com",
    "full_name": "John Doe",
    "phone": "+256700123456",
    "is_verified": true,
    "application": {
      "stud_entry_no": "APL2026000042",
      "app_status": "SUBMITTED",
      "prog_id": "BSCSE",
      "adm_status": 0,
      "submitted_at": "2026-05-20"
    }
  }
}
```

`application` is `null` if no application has been started yet.

---

### 9.8 Change Password

Changes the applicant's password (requires current password).

| Property | Value |
|---|---|
| **URL** | `apply.aspx?action=change_password` |
| **Method** | GET or POST |
| **Auth Required** | Yes (applicant token) |

**Parameters:**

| Parameter | Type | Required | Description |
|---|---|---|---|
| `current_password` | string | Yes | Current password |
| `new_password` | string | Yes | New password (minimum 6 characters) |

**Success Response:**

```json
{
  "status": "success",
  "message": "Password changed successfully.",
  "data": { "changed": true }
}
```

**Error Responses:**

| Code | Message |
|---|---|
| `VALIDATION_ERROR` | New password must be at least 6 characters |
| `INVALID_CREDENTIALS` | Current password is incorrect |

---

### 9.9 Get Draft (Resume Application)

Returns the applicant's current draft application with all saved fields, or `null` if no application has been started. Also includes the document list.

| Property | Value |
|---|---|
| **URL** | `apply.aspx?action=get_draft` |
| **Method** | GET or POST |
| **Auth Required** | Yes (applicant token) |

**Success Response (draft exists):**

```json
{
  "status": "success",
  "data": {
    "stud_entry_no": "APL2026000042",
    "stud_name": "John Doe",
    "surname": "Doe",
    "other_names": "John",
    "gender": "M",
    "nationality": "Ugandan",
    "religion": "Christian",
    "dob": "2000-04-15",
    "phone": "+256700123456",
    "address": "P.O. Box 123, Masaka",
    "marital": "Single",
    "disability": "",
    "national_id": "CM123456789ABCD",
    "olevel_school": "St. Henry's College Kitovu",
    "olevel_index": "U0001/123/2018",
    "olevel_year": "2018",
    "olevel_agg": "12",
    "alevel_school": "Namilyango College",
    "alevel_index": "U0002/456/2020",
    "alevel_year": 2020,
    "alevel_points": "18",
    "other_inst": "",
    "other_qual": "",
    "other_year": "",
    "other_grade": "",
    "campus": "MAIN",
    "intake": "AUG2026",
    "sponsor": "PRIVATE",
    "emergency_name": "Jane Doe",
    "emergency_rel": "Mother",
    "emergency_phone": "+256700987654",
    "app_status": "DRAFT",
    "submitted_at": null,
    "programme": "BSCSE",
    "session": "DAY",
    "choice_status": 0,
    "documents": [
      {
        "id": 7,
        "doc_type": "PHOTO",
        "original_filename": "passport_photo.jpg",
        "file_size_bytes": 87234,
        "uploaded_at": "2026-05-19 14:32"
      }
    ]
  }
}
```

**Success Response (no application yet):**

```json
{
  "status": "success",
  "message": "No application started yet.",
  "data": null
}
```

---

### 9.10 Save Step 1 — Personal Details

Saves personal details. Creates a new draft if this is the first step saved.

| Property | Value |
|---|---|
| **URL** | `apply.aspx?action=save_step1` |
| **Method** | GET or POST |
| **Auth Required** | Yes (applicant token) |

**Parameters:**

| Parameter | Type | Required | Description |
|---|---|---|---|
| `surname` | string | Yes | Family/last name |
| `other_names` | string | Yes | First and other names |
| `gender` | string | Yes | `M` or `F` |
| `nationality` | string | Yes | e.g. `Ugandan` |
| `phone` | string | Yes | Mobile phone number |
| `dob` | string | Yes | Date of birth: `YYYY-MM-DD` |
| `religion` | string | No | e.g. `Christian` |
| `address` | string | No | Physical address |
| `marital` | string | No | Marital status |
| `disability` | string | No | Physical disability notes (empty = none) |
| `national_id` | string | No | National ID or passport number |

**Success Response:**

```json
{
  "status": "success",
  "message": "Step 1 saved.",
  "data": { "entry_no": "APL2026000042", "step": 1 }
}
```

**Error Responses:**

| Code | Message |
|---|---|
| `VALIDATION_ERROR` | gender must be M or F / dob must be a valid date |
| `LOCKED` | Application has been submitted and cannot be edited |

---

### 9.11 Save Step 2 — Education History

Saves O-Level, A-Level, and other qualification details.

| Property | Value |
|---|---|
| **URL** | `apply.aspx?action=save_step2` |
| **Method** | GET or POST |
| **Auth Required** | Yes (applicant token) |

**Parameters:**

| Parameter | Type | Required | Description |
|---|---|---|---|
| `olevel_school` | string | Yes | Name of O-Level school |
| `olevel_index` | string | Yes | O-Level exam index number |
| `olevel_year` | integer | Yes | Year O-Level results were obtained (1960–present) |
| `olevel_agg` | string | No | O-Level aggregate score |
| `alevel_school` | string | No | Name of A-Level school |
| `alevel_index` | string | No | A-Level exam index number |
| `alevel_year` | integer | No | Year A-Level results obtained |
| `alevel_points` | string | No | A-Level points / subject combinations |
| `other_inst` | string | No | Other institution name (diploma, degree etc.) |
| `other_qual` | string | No | Other qualification name |
| `other_year` | string | No | Year other qualification was obtained |
| `other_grade` | string | No | Grade / classification of other qualification |

**Success Response:**

```json
{
  "status": "success",
  "message": "Step 2 saved.",
  "data": { "entry_no": "APL2026000042", "step": 2 }
}
```

**Error Responses:**

| Code | Message |
|---|---|
| `VALIDATION_ERROR` | Enter a valid O-Level year |
| `LOCKED` | Application has been submitted and cannot be edited |

---

### 9.12 Save Step 3 — Programme & Emergency Contact

Saves the chosen programme, session, campus, intake, sponsor type, and emergency contact.

| Property | Value |
|---|---|
| **URL** | `apply.aspx?action=save_step3` |
| **Method** | GET or POST |
| **Auth Required** | Yes (applicant token) |

**Parameters:**

| Parameter | Type | Required | Description |
|---|---|---|---|
| `programme` | string | Yes | Programme code from `programmes` endpoint (e.g. `BSCSE`) |
| `session` | string | Yes | Session type: `DAY`, `EVENING`, or `WEEKEND` |
| `campus` | string | Yes | Campus code (e.g. `MAIN`) |
| `intake` | string | Yes | Intake code (e.g. `AUG2026`) |
| `emergency_name` | string | Yes | Name of emergency contact (next of kin) |
| `sponsor` | string | No | Sponsor type: `PRIVATE`, `GOVERNMENT`, `SCHOLARSHIP` etc. |
| `emergency_rel` | string | No | Relationship to emergency contact |
| `emergency_phone` | string | No | Emergency contact phone number |

**Success Response:**

```json
{
  "status": "success",
  "message": "Step 3 saved.",
  "data": { "entry_no": "APL2026000042", "step": 3 }
}
```

**Error Responses:**

| Code | Message |
|---|---|
| `LOCKED` | Application has been submitted and cannot be edited |

---

### 9.13 Submit Application

Performs final validation and submits the application. After submission the form is locked for editing.

| Property | Value |
|---|---|
| **URL** | `apply.aspx?action=submit` |
| **Method** | GET or POST |
| **Auth Required** | Yes (applicant token) |

**Parameters:**

| Parameter | Type | Required | Description |
|---|---|---|---|
| `declaration_accepted` | string | Yes | Must be `"1"` or `"true"` |

**Pre-submission validation (required fields):**

- Full name (Step 1)
- Gender (Step 1)
- Nationality (Step 1)
- Date of birth (Step 1)
- Phone number (Step 1)
- O-Level school (Step 2)
- O-Level index number (Step 2)
- Emergency contact name (Step 3)
- Programme selection (Step 3)

**Success Response:**

```json
{
  "status": "success",
  "message": "Application submitted successfully.",
  "data": {
    "entry_no": "APL2026000042",
    "status": "SUBMITTED"
  }
}
```

A confirmation email is sent to the applicant and an in-app notification is created.

**Error Responses:**

| Code | Message |
|---|---|
| `VALIDATION_ERROR` | You must accept the declaration before submitting |
| `NOT_FOUND` | No draft application found |
| `ALREADY_SUBMITTED` | Application already submitted |
| `INCOMPLETE` | Lists all missing required fields |

---

### 9.14 My Application Status

Returns full application status with programme name, admission decision, and unread notification count.

| Property | Value |
|---|---|
| **URL** | `apply.aspx?action=my_application` |
| **Method** | GET or POST |
| **Auth Required** | Yes (applicant token) |

**Success Response:**

```json
{
  "status": "success",
  "data": {
    "stud_entry_no": "APL2026000042",
    "stud_name": "John Doe",
    "stud_email": "john.doe@example.com",
    "app_status": "ADMITTED",
    "submitted_at": "2026-05-20 09:15",
    "last_updated": "2026-05-22 14:30",
    "programme": "BSCSE",
    "programme_name": "Bachelor of Science in Computer Science",
    "choice_status": 1,
    "choice_status_label": "ADMITTED",
    "session": "DAY",
    "regno": "MRU2026004512",
    "unread_notifications": 2,
    "document_count": 4
  }
}
```

`regno` is populated only once the applicant has been registered as a student by admissions staff.

---

### 9.15 List Documents

Returns all documents uploaded for the applicant's current application.

| Property | Value |
|---|---|
| **URL** | `apply.aspx?action=documents` |
| **Method** | GET or POST |
| **Auth Required** | Yes (applicant token) |

**Success Response:**

```json
{
  "status": "success",
  "data": [
    {
      "id": 7,
      "doc_type": "PHOTO",
      "original_filename": "passport_photo.jpg",
      "file_size_bytes": 87234,
      "uploaded_at": "2026-05-19 14:32"
    },
    {
      "id": 8,
      "doc_type": "OLEVEL",
      "original_filename": "olevel_results.pdf",
      "file_size_bytes": 423120,
      "uploaded_at": "2026-05-19 14:35"
    }
  ]
}
```

---

### 9.16 Upload Document

Uploads a document file for the application. Uses `multipart/form-data`.

| Property | Value |
|---|---|
| **URL** | `apply.aspx?action=upload_document` |
| **Method** | POST (multipart/form-data) |
| **Auth Required** | Yes (applicant token) |

**Form Fields:**

| Field | Type | Required | Description |
|---|---|---|---|
| `doc_type` | string | Yes | One of: `PHOTO`, `OLEVEL`, `ALEVEL`, `NATID`, `OTHER` |
| `file` | file | Yes | The document file |
| `token` | string | Yes | Applicant token |

**Document Types:**

| doc_type | Description |
|---|---|
| `PHOTO` | Passport-size photograph |
| `OLEVEL` | O-Level certificate or result slip |
| `ALEVEL` | A-Level certificate or result slip |
| `NATID` | National ID or passport copy |
| `OTHER` | Any other supporting document |

**File Constraints:**
- Maximum size: **5 MB**
- Accepted formats: **JPG, JPEG, PNG, PDF**
- Each `doc_type` except `OTHER` replaces any previous upload of the same type

**Success Response:**

```json
{
  "status": "success",
  "message": "Document uploaded.",
  "data": {
    "id": 9,
    "doc_type": "PHOTO",
    "original_filename": "passport_photo.jpg",
    "file_size_bytes": 87234
  }
}
```

**Error Responses:**

| Code | Message |
|---|---|
| `VALIDATION_ERROR` | doc_type must be one of: PHOTO, OLEVEL, ALEVEL, NATID, OTHER |
| `MISSING_FILE` | No file uploaded / Uploaded file is empty |
| `FILE_TOO_LARGE` | File size must not exceed 5 MB |
| `INVALID_FILE_TYPE` | Only JPG, PNG, and PDF files are accepted |
| `NOT_FOUND` | No application found — complete Step 1 first |

---

### 9.17 Delete Document

Deletes a specific uploaded document.

| Property | Value |
|---|---|
| **URL** | `apply.aspx?action=delete_document` |
| **Method** | GET or POST |
| **Auth Required** | Yes (applicant token) |

**Parameters:**

| Parameter | Type | Required | Description |
|---|---|---|---|
| `id` | integer | Yes | Document ID (from documents list) |

**Success Response:**

```json
{
  "status": "success",
  "message": "Document deleted.",
  "data": { "id": 7 }
}
```

**Error Responses:**

| Code | Message |
|---|---|
| `MISSING_PARAM` | id is required |
| `NOT_FOUND` | Document not found |

---

### 9.18 Get / Download Document

Returns the raw file content for a document (for inline preview or download).

| Property | Value |
|---|---|
| **URL** | `apply.aspx?action=get_document` |
| **Method** | GET or POST |
| **Auth Required** | Yes (applicant token) |
| **Response Content-Type** | `image/jpeg`, `image/png`, or `application/pdf` (not JSON) |

**Parameters:**

| Parameter | Type | Required | Description |
|---|---|---|---|
| `id` | integer | Yes | Document ID |

> This endpoint returns the raw file, not JSON. Use it as the `src` of an `<img>` tag or open it in a PDF viewer. On error it still returns JSON with the error details.

---

### 9.19 Get Notifications

Returns paginated notifications for the logged-in applicant.

| Property | Value |
|---|---|
| **URL** | `apply.aspx?action=notifications` |
| **Method** | GET or POST |
| **Auth Required** | Yes (applicant token) |

**Parameters:**

| Parameter | Type | Required | Description |
|---|---|---|---|
| `page` | integer | No | Page number (default: 1) |
| `size` | integer | No | Items per page (default: 20, max: 50) |

**Success Response:**

```json
{
  "status": "success",
  "data": {
    "total": 5,
    "page": 1,
    "size": 20,
    "pages": 1,
    "notifications": [
      {
        "id": 12,
        "message": "Your application APL2026000042 has been admitted.",
        "is_read": 0,
        "link": "",
        "created_at": "2026-05-22 14:30"
      }
    ]
  }
}
```

---

### 9.20 Mark Notification Read

Marks one or all notifications as read.

| Property | Value |
|---|---|
| **URL** | `apply.aspx?action=mark_read` |
| **Method** | GET or POST |
| **Auth Required** | Yes (applicant token) |

**Parameters:**

| Parameter | Type | Required | Description |
|---|---|---|---|
| `id` | integer | No | Notification ID to mark read. Omit to mark **all** as read. |

**Success Response:**

```json
{
  "status": "success",
  "message": "Marked as read.",
  "data": { "marked": true }
}
```

---

### 9.21 List Programmes (Public)

Returns all active programmes. Optionally filter by faculty or search by name/code.

| Property | Value |
|---|---|
| **URL** | `apply.aspx?action=programmes` |
| **Method** | GET or POST |
| **Auth Required** | No |

**Parameters:**

| Parameter | Type | Required | Description |
|---|---|---|---|
| `faculty` | string | No | Filter by faculty code |
| `q` | string | No | Search by programme name or code |

**Success Response:**

```json
{
  "status": "success",
  "data": {
    "total": 42,
    "programmes": [
      {
        "progcode": "BSCSE",
        "progname": "Bachelor of Science in Computer Science",
        "faculty_code": "ICT",
        "faculty_name": "Faculty of Science and Technology",
        "duration": "3 Years",
        "award_type": "Degree"
      }
    ]
  }
}
```

---

### 9.22 List Faculties (Public)

Returns all faculties.

| Property | Value |
|---|---|
| **URL** | `apply.aspx?action=faculties` |
| **Method** | GET or POST |
| **Auth Required** | No |

**Success Response:**

```json
{
  "status": "success",
  "data": [
    { "faculty_code": "ICT", "faculty_name": "Faculty of Science and Technology" },
    { "faculty_code": "BUS", "faculty_name": "Faculty of Business and Management" }
  ]
}
```

---

### 9.23 List Campuses (Public)

Returns all campuses.

| Property | Value |
|---|---|
| **URL** | `apply.aspx?action=campuses` |
| **Method** | GET or POST |
| **Auth Required** | No |

**Success Response:**

```json
{
  "status": "success",
  "data": [
    { "campus_code": "MAIN", "campus_name": "Main Campus - Masaka" }
  ]
}
```

---

### 9.24 Open Intakes (Public)

Returns currently open application intakes.

| Property | Value |
|---|---|
| **URL** | `apply.aspx?action=intakes` |
| **Method** | GET or POST |
| **Auth Required** | No |

**Success Response:**

```json
{
  "status": "success",
  "data": [
    {
      "id": 3,
      "intake_year": 2026,
      "intake_label": "August 2026 Intake",
      "session_type": "ALL",
      "is_open": 1,
      "open_from": "2026-03-01",
      "open_to": "2026-07-31"
    }
  ]
}
```

---

### 9.25 Public Status Check

Allows anyone to check an application's status using only the entry number and date of birth (no login required). Useful for check-status screens.

| Property | Value |
|---|---|
| **URL** | `apply.aspx?action=check_status` |
| **Method** | GET or POST |
| **Auth Required** | No |

**Parameters:**

| Parameter | Type | Required | Description |
|---|---|---|---|
| `entry_no` | string | Yes | Application reference number (e.g. `APL2026000042`) |
| `dob` | string | Yes | Date of birth: `YYYY-MM-DD` |

**Success Response:**

```json
{
  "status": "success",
  "data": {
    "stud_entry_no": "APL2026000042",
    "stud_name": "John Doe",
    "app_status": "ADMITTED",
    "submitted_at": "2026-05-20",
    "programme": "BSCSE",
    "programme_name": "Bachelor of Science in Computer Science",
    "choice_status": 1,
    "choice_status_label": "ADMITTED",
    "regno": "MRU2026004512"
  }
}
```

`regno` is only returned when `choice_status` = 1 (ADMITTED). For other statuses it is omitted.

**Error Responses:**

| Code | Message |
|---|---|
| `MISSING_PARAM` | entry_no and dob (YYYY-MM-DD) are required |
| `NOT_FOUND` | Application not found. Check your reference number and date of birth |

---

## 10. Admissions Management (admissions.aspx)

**Endpoint file:** `admissions.aspx`  
**Base URL:** `https://eadmin.mru.ac.ug/API/v2/admissions.aspx`

Staff/admin endpoints for reviewing and managing applicant submissions. All endpoints require a staff token (from `auth.aspx?action=login`).

### 10.1 List Applications

Returns a paginated list of all applications with optional filters.

| Property | Value |
|---|---|
| **URL** | `admissions.aspx?action=list` |
| **Method** | GET or POST |
| **Auth Required** | Yes (staff token) |

**Parameters:**

| Parameter | Type | Required | Description |
|---|---|---|---|
| `status` | string | No | Filter by `app_status`: `DRAFT`, `SUBMITTED`, `UNDER_REVIEW`, `ADMITTED`, `REJECTED` |
| `programme` | string | No | Filter by programme code |
| `intake` | string | No | Filter by intake code |
| `q` | string | No | Search by name or entry number |
| `page` | integer | No | Page number (default: 1) |
| `size` | integer | No | Items per page (default: 20) |

---

### 10.2 Get Application Details

Returns full details of a single application.

| Property | Value |
|---|---|
| **URL** | `admissions.aspx?action=details` |
| **Method** | GET or POST |
| **Auth Required** | Yes (staff token) |

**Parameters:**

| Parameter | Type | Required | Description |
|---|---|---|---|
| `entry_no` | string | Yes | Application entry number |

---

### 10.3 Move to Under Review

Changes `app_status` from `SUBMITTED` to `UNDER_REVIEW`. Only works on applications that are in `SUBMITTED` status. Sends an in-app notification to the applicant. Logged in audit trail.

| Property | Value |
|---|---|
| **URL** | `admissions.aspx?action=review` |
| **Method** | GET or POST |
| **Auth Required** | Yes (staff token) |

**Parameters:**

| Parameter | Type | Required | Description |
|---|---|---|---|
| `entry_no` | string | Yes (or `choice_id`) | Application entry number |
| `choice_id` | integer | Yes (or `entry_no`) | Programme choice ID (from list endpoint) |

**Success Response:**

```json
{
  "status": "success",
  "message": "Application moved to UNDER_REVIEW",
  "data": { "entry_no": "APL2026000042", "app_status": "UNDER_REVIEW" }
}
```

**Error Responses:**

| Code | Message |
|---|---|
| `MISSING_PARAM` | entry_no or choice_id is required |
| `NOT_FOUND` | Application not found |
| `BUSINESS_ERROR` | Only SUBMITTED applications can be moved to UNDER_REVIEW |

---

### 10.4 Admit Applicant

Sets `adm_status = 1` (ADMITTED) on the programme choice and `app_status = ADMITTED` on the application. Sends congratulations notification to applicant. Logged in audit trail.

| Property | Value |
|---|---|
| **URL** | `admissions.aspx?action=admit` |
| **Method** | GET or POST |
| **Auth Required** | Yes (staff token) |

**Parameters:**

| Parameter | Type | Required | Description |
|---|---|---|---|
| `choice_id` | integer | Yes | Programme choice ID (from list endpoint) |

**Success Response:**

```json
{
  "status": "success",
  "message": "Applicant admitted",
  "data": { "choice_id": 55, "entry_no": "APL2026000042", "adm_status": 1, "status_label": "ADMITTED" }
}
```

---

### 10.5 Reject Applicant

Sets `adm_status = 2` (REJECTED) and `app_status = REJECTED`. Optional reason is saved as a note and included in the notification to the applicant.

| Property | Value |
|---|---|
| **URL** | `admissions.aspx?action=reject` |
| **Method** | GET or POST |
| **Auth Required** | Yes (staff token) |

**Parameters:**

| Parameter | Type | Required | Description |
|---|---|---|---|
| `choice_id` | integer | Yes | Programme choice ID |
| `reason` | string | No | Rejection reason — sent in notification and saved as note |

**Success Response:**

```json
{
  "status": "success",
  "message": "Applicant rejected",
  "data": { "choice_id": 55, "entry_no": "APL2026000042", "adm_status": 2, "status_label": "REJECTED" }
}
```

---

### 10.6 Withdraw Application

Sets `adm_status = 3` (WITHDRAWN) and `app_status = WITHDRAWN`. Can be triggered by staff on behalf of the applicant.

| Property | Value |
|---|---|
| **URL** | `admissions.aspx?action=withdraw` |
| **Method** | GET or POST |
| **Auth Required** | Yes (staff token) |

**Parameters:**

| Parameter | Type | Required | Description |
|---|---|---|---|
| `choice_id` | integer | Yes | Programme choice ID |
| `reason` | string | No | Reason for withdrawal |

---

### 10.7 Register Admitted Applicant as Student

Converts an ADMITTED applicant into a registered student by calling the `acad_RegisterApplicant` stored procedure. Returns the generated student registration number. Will error if the applicant is not ADMITTED or is already registered.

| Property | Value |
|---|---|
| **URL** | `admissions.aspx?action=register` |
| **Method** | GET or POST |
| **Auth Required** | Yes (staff token) |

**Parameters:**

| Parameter | Type | Required | Description |
|---|---|---|---|
| `choice_id` | integer | Yes | Programme choice ID (applicant must have `adm_status = 1`) |

**Success Response:**

```json
{
  "status": "success",
  "message": "Student registered successfully",
  "data": {
    "choice_id": 55,
    "entry_no": "APL2026000042",
    "regno": "MRU2026004512"
  }
}
```

**Error Responses:**

| Code | Message |
|---|---|
| `BUSINESS_ERROR` | Applicant must be ADMITTED before registration |
| `ALREADY_REGISTERED` | Applicant is already registered as student: MRU2026004512 |
| `SERVER_ERROR` | Registration SP failed: [error details] |

---

### 10.8 Application Status Check (Public)

Returns the status of any application. **No authentication required** — intended for applicant self-check screens. Requires both `entry_no` and `dob` to prevent fishing. `regno` only returned if applicant is ADMITTED.

| Property | Value |
|---|---|
| **URL** | `admissions.aspx?action=application_status` |
| **Method** | GET or POST |
| **Auth Required** | **No** |

**Parameters:**

| Parameter | Type | Required | Description |
|---|---|---|---|
| `entry_no` | string | Yes | Application entry number (also accepts `app_number` as alias) |
| `dob` | string | Yes | Applicant date of birth: `YYYY-MM-DD` |

**Success Response:**

```json
{
  "status": "success",
  "data": {
    "stud_entry_no": "APL2026000042",
    "stud_name": "John Doe",
    "app_status": "ADMITTED",
    "submitted_at": "2026-05-20",
    "prog_id": "BSCSE",
    "programme_name": "Bachelor of Science in Computer Science",
    "choice_status": 1,
    "status_label": "ADMITTED",
    "regno": "MRU2026004512"
  }
}
```

---

### 10.9 Add Note

Adds a private reviewer note to an application (visible only to staff).

| Property | Value |
|---|---|
| **URL** | `admissions.aspx?action=add_note` |
| **Method** | GET or POST |
| **Auth Required** | Yes (staff token) |

**Parameters:**

| Parameter | Type | Required | Description |
|---|---|---|---|
| `entry_no` | string | Yes (or `choice_id`) | Application entry number |
| `choice_id` | integer | Yes (or `entry_no`) | Programme choice ID |
| `note` | string | Yes | Note text |

**Success Response:**

```json
{
  "status": "success",
  "message": "Note added",
  "data": { "note_id": 7, "entry_no": "APL2026000042" }
}
```

---

### 10.10 List Notes

Returns all reviewer notes for an application, newest first.

| Property | Value |
|---|---|
| **URL** | `admissions.aspx?action=notes` |
| **Method** | GET or POST |
| **Auth Required** | Yes (staff token) |

**Parameters:**

| Parameter | Type | Required | Description |
|---|---|---|---|
| `entry_no` | string | Yes (or `choice_id`) | Application entry number |
| `choice_id` | integer | Yes (or `entry_no`) | Programme choice ID |

**Success Response:**

```json
{
  "status": "success",
  "data": {
    "entry_no": "APL2026000042",
    "total": 2,
    "notes": [
      {
        "note_id": 7,
        "note_text": "Awaiting O-Level certificate original",
        "added_by": "admissions_officer",
        "added_at": "2026-05-21 09:45"
      }
    ]
  }
}
```

---

### 10.11 Notify Applicant

Sends a custom in-app notification to the applicant. Also logged in the audit trail.

| Property | Value |
|---|---|
| **URL** | `admissions.aspx?action=notify` |
| **Method** | GET or POST |
| **Auth Required** | Yes (staff token) |

**Parameters:**

| Parameter | Type | Required | Description |
|---|---|---|---|
| `entry_no` | string | Yes (or `choice_id`) | Application entry number |
| `choice_id` | integer | Yes (or `entry_no`) | Programme choice ID |
| `message` | string | Yes | Notification message text |

**Success Response:**

```json
{
  "status": "success",
  "message": "Notification sent to applicant",
  "data": { "entry_no": "APL2026000042", "notified": true }
}
```

---

### 10.12 Admissions Stats

Returns pipeline summary counts and breakdown by programme.

| Property | Value |
|---|---|
| **URL** | `admissions.aspx?action=stats` |
| **Method** | GET or POST |
| **Auth Required** | Yes (staff token) |

**Parameters:**

| Parameter | Type | Required | Description |
|---|---|---|---|
| `session` | string | No | Filter by session code (e.g. `DAY`) |
| `acad_year` | string | No | Filter by academic year string |

**Success Response:**

```json
{
  "status": "success",
  "data": {
    "total": 312,
    "pending": 45,
    "admitted": 220,
    "rejected": 30,
    "withdrawn": 17,
    "registered": 198,
    "by_programme": [
      { "prog_id": "BSCSE", "programme_name": "BSc Computer Science", "total": 48, "pending": 5, "admitted": 38 }
    ]
  }
}
```

---

### 10.13 Repair

Diagnoses and auto-fixes a partially registered student (missing `acad_student` or `acad_registration` record).

| Property | Value |
|---|---|
| **URL** | `admissions.aspx?action=repair` |
| **Method** | GET or POST |
| **Auth Required** | Yes (staff token) |

**Parameters:**

| Parameter | Type | Required | Description |
|---|---|---|---|
| `regno` | string | Yes | Student registration number to diagnose |

**Success Response:**

```json
{
  "status": "success",
  "message": "Repair completed",
  "data": {
    "regno": "MRU2026004512",
    "actions_taken": ["acad_registration record created for 2026/2027 Semester 1."]
  }
}
```

---

## 11. Error Codes Reference

*(Renumbered from §9 — same content as before)*

---

## 12. Grading & Classification Scales

*(Renumbered from §10 — same content as before)*

---

## 13. Database Schema Notes

*(Renumbered from §11 — same content as before)*

### Application Tables (added in v2.3)

| Table | Database | Purpose |
|---|---|---|
| `acad_applications` | `campus_dynamics` | One row per application. PK: `stud_entry_no` |
| `acad_applicant_choices` | `campus_dynamics` | Programme choices per application |
| `apply_documents` | `campus_dynamics` | Uploaded document file records |
| `apply_notifications` | `campus_dynamics` | In-app notifications for applicants |
| `apply_intakes` | `campus_dynamics` | Open intake periods |
| `apply_email_tokens` | `campus_dynamics_portal` | OTP tokens for email verify / password reset |
| `my_aspnet_users` | `campus_dynamics_portal` | User accounts (students, staff, and applicants) |
| `my_aspnet_membership` | `campus_dynamics_portal` | Password hashes for all user types |

**Applicant users** are stored in `my_aspnet_users` with `user_type = 'APPLICANT'`.

**Legacy column aliases in `acad_applications`** (columns reused from student schema for applicant data):

| Semantic meaning | Actual DB column |
|---|---|
| O-Level year | `stud_pob` |
| O-Level aggregate | `stud_district` |
| A-Level points | `stud_ward` |
| Other institution | `stud_prevcampus` |
| Other qualification | `stud_lg` |
| Other year | `stud_village` |
| Other grade | `stud_county` |

The API response fields use the semantic names (e.g. `olevel_year`, `alevel_points`) — callers never see the raw column names.

---

## 14. Known Limitations

*(Renumbered from §12 — same content as before)*

---

## 15. ID Card Management (idcard.aspx)

Complete control of the ID-card lifecycle: request → finance check → submit → approve/halt → printed → ready → collected. Every write flows through the **one audited state machine** (`IDCardService.Transition`) shared by the eportal wizard, the eadmin console, and this API — so all changes are validated and recorded in `idcard_request_events`.

**Base URL:** `https://eadmin.mru.ac.ug/API/v2/idcard.aspx`
**Auth:** `Authorization: Bearer <token>` on every call.
**Envelope:** standard v2 — `{ "success", "message", "data", "error_code", "timestamp" }`. Payloads are under `data`.

### 15.1 Authorisation

| Group | Endpoints | Allowed token types |
|---|---|---|
| Read | `queue`, `detail`, `stats`, `windows`, `meta`, `export` | `staff`, `idcard_operator`, `admin` (students: own `detail` + self-service only) |
| Write | `approve`, `halt`, `printed`, `ready`, `collected`, `cancel`, `batch` | `idcard_operator`, `admin` |
| Windows | `window_create`, `window_activate`, `window_close` | `idcard_operator`, `admin` |
| Self-service | `my`, `identity`, `finance`, `create`, `submit`, `cancel_own` | the token owner (student/staff) on their own record |

Operator/admin token types are minted at login for accounts listed in web.config `appSettings`:
```xml
<add key="IDCard.OperatorUsers" value="xaxu_svc,registry_id" />
<add key="IDCard.AdminUsers" value="idcard_admin" />
```
These should be **dedicated operator/service accounts** (e.g. the XAXU integration user). Human Registry staff manage cards through the eadmin console (session-authenticated). Unauthorised calls return `FORBIDDEN`.

### 15.2 Statuses & transitions

`REQUESTED → FINANCE_CHECK → (SUBMITTED | BLOCKED) → SUBMITTED → (APPROVED | HALTED) → PRINTED → READY → COLLECTED` (plus `CANCELLED`). Terminal: `COLLECTED`, `CANCELLED`. Call `action=meta` for the machine-readable status list, legal transition map, action→status map, and filter enums.

### 15.3 Read endpoints

**`GET ?action=queue`** — paginated, filterable, sortable list.

| Param | Notes |
|---|---|
| `status` | single or CSV (e.g. `SUBMITTED,APPROVED`) → `IN` |
| `type` | `STUDENT` \| `STAFF` |
| `card_type` | `NEW` \| `REPLACEMENT` |
| `q` | request no / student no / name search |
| `date_from`, `date_to` | on `created_at` (`YYYY-MM-DD`) |
| `window_id` | requests tied to a request window |
| `finance` | `ok` \| `below` \| `flagged` |
| `has_replacement_fee` | `1` \| `0` |
| `page`, `page_size` | 1-based; `page_size` max 200 (default 50) |
| `sort` | `created_at` \| `submitted_at` \| `updated_at` \| `status` \| `request_no` |
| `order` | `asc` \| `desc` |

```json
{ "success": true, "message": "OK",
  "data": {
    "rows": [ { "requestNo":"IDR-2026-000003", "type":"STUDENT", "cardType":"NEW",
                "status":"SUBMITTED", "number":"27/U/BAED/0001/K/DAY", "name":"SABIA BIIRA MUTHEKE",
                "createdAt":"...", "submittedAt":"...", "updatedAt":"..." } ],
    "total": 3, "page": 1, "pages": 1, "page_size": 50,
    "has_prev": false, "has_next": false, "from": 1, "to": 3 } }
```

**`GET ?action=detail&request_no=IDR-2026-000003`** — `data:{ request, identity, finance, timeline }`.
**`GET ?action=stats[&date_from=&date_to=]`** — funnel counts + `byType` + `byCard`.
**`GET ?action=windows`** — request windows.
**`GET ?action=meta`** — statuses, transitions, actions, filter enums.
**`GET ?action=export[&<queue filters>]`** — CSV download of the filtered set (up to 10,000 rows).

### 15.4 Single lifecycle operations (operator/admin)

`POST ?action=<approve|halt|printed|ready|collected|cancel>&request_no=IDR-...`
- `halt` requires `reason`.
- `ready` accepts `collection_point`.
- Illegal transitions return `INVALID_TRANSITION` (via the funnel); response `data:{ status }`.

```bash
curl -X POST -H "Authorization: Bearer $TOK" \
  "https://eadmin.mru.ac.ug/API/v2/idcard.aspx?action=approve&request_no=IDR-2026-000003"
```

### 15.5 Batch operations (operator/admin)

`POST ?action=batch&batch_action=<approve|halt|printed|ready|collected|cancel>&request_nos=IDR-1,IDR-2,...`
- `request_nos` accepts CSV **or** a JSON array. Max **500** per call (`BATCH_TOO_LARGE`).
- Shared `reason` / `collection_point` apply to all. Each item runs independently through the funnel; incompatible states fail per-item (partial success allowed).

```json
{ "success": true, "message": "OK",
  "data": { "ok": 8, "fail": 2, "total": 10,
    "results": [ { "request_no":"IDR-2026-000123", "ok":true, "status":"APPROVED", "message":"" },
                 { "request_no":"IDR-2026-000124", "ok":false, "status":"", "message":"Illegal transition ..." } ] } }
```

### 15.6 Windows management (operator/admin)

- `POST ?action=window_create&title=&scope=BOTH|STUDENT|STAFF&opens_at=&closes_at=[&notes=]`
- `POST ?action=window_activate&id=NN` · `POST ?action=window_close&id=NN`

While no window exists, requests are open; once one exists, requests are only accepted inside an active window.

### 15.7 Self-service (card owner)

- `GET ?action=my` — the caller's current request + timeline.
- `GET ?action=identity` · `GET ?action=finance` (students).
- `POST ?action=create&card_type=NEW|REPLACEMENT&photo_confirmed=1&guidelines_ack=1`.
- `POST ?action=submit&request_no=...[&repl_ref=&repl_date=&repl_method=&repl_notes=]` (finance gate; replacement-fee proof for replacements).
- `POST ?action=cancel_own&request_no=...`.

Self-service acts only on the caller's own record (verified server-side); acting on another's returns `FORBIDDEN`.

### 15.8 Error codes

`MISSING_PARAM`, `INVALID_ACTION`, `FORBIDDEN`, `NOT_FOUND`, `INVALID_TRANSITION`, `WINDOW_CLOSED`, `FINANCE_BLOCKED`, `BATCH_TOO_LARGE`, `REQUEST_FAILED`, `RATE_LIMITED`, `SERVER_ERROR`.

---

*Last updated: July 2026*  
*API Version: 2.4 (ID Card Management Release — full lifecycle: queue/detail/stats/meta/export, single + batch operations, windows, self-service)*  
*Server: ASP.NET Web Forms on IIS — https://eadmin.mru.ac.ug/API/v2/*
