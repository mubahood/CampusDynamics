# Campus Dynamics API v2 — Documentation

**Base URL:** `https://eadmin.mru.ac.ug/API/v2/`

---

## Overview

The Campus Dynamics API v2 provides RESTful JSON endpoints for student and staff data access, covering authentication, academic records, finance, timetables, and campus information. All actions are passed via `?action=` query parameter (case-insensitive). Tokens are passed as `?token=` query parameter.

### Response Format

All endpoints return JSON with this structure:

```json
{
  "success": true,
  "message": "OK",
  "data": { ... },
  "timestamp": "2026-03-14T12:00:00.000Z"
}
```

Error responses include an `error_code`:

```json
{
  "success": false,
  "message": "Human-readable error message",
  "error_code": "MACHINE_READABLE_CODE",
  "data": null,
  "timestamp": "2026-03-14T12:00:00.000Z"
}
```

HTTP status is always `200` — check the `success` boolean. The only exception is binary photo responses.

### CORS

All origins are allowed. Supported methods: `GET, POST, DELETE, OPTIONS`. OPTIONS preflight requests are handled automatically.

---

## Authentication

**Endpoint:** `auth.aspx`

### Login

**Action:** `login` | **Auth:** None | **Method:** POST

Authenticates a user and returns a session token valid for 24 hours.

**Parameters:**

| Param | Required | Description |
|---|---|---|
| `username` | Yes | Registration number, student/entry number, or email |
| `password` | Yes | Account password |

**Username Resolution Order:**

The login system accepts multiple identifier types. Resolution is tried in this order:

1. **Student registration number** — e.g. `MRU2025003204`
2. **Student entry/student number** — e.g. `25/U/BAED/0084/K/DAY`
3. **Student email** — e.g. `student@example.com`
4. **Staff username** — matching `hrm_employee.usernames`
5. **Staff email** — matching `hrm_employee.emp_email`

Once resolved, the identifier maps to a registration number (students) or username (staff), and the password is validated against the membership database.

**Response:**

```json
{
  "success": true,
  "message": "Login successful",
  "data": {
    "token": "RGPWYovSJBDV1lfRJFpQ...",
    "user_type": "student",
    "user_id": "MRU2025003204",
    "full_name": "NAKYESERO RITAH",
    "expires": "2026-03-15T19:04:00.000Z"
  }
}
```

**Notes:**
- Each login deactivates all previous tokens for that user
- Expired tokens are cleaned up automatically after login
- Locked accounts are rejected with `AUTH_LOGIN_FAILED`

### Logout

**Action:** `logout` | **Auth:** Token | **Method:** POST

Deactivates the session token.

**Parameters:**

| Param | Required | Description |
|---|---|---|
| `token` | Yes | Active session token |

### Validate

**Action:** `validate` | **Auth:** Token | **Method:** GET

Checks if a token is still valid without performing any action.

**Parameters:**

| Param | Required | Description |
|---|---|---|
| `token` | Yes | Session token to validate |

**Response:**

```json
{
  "success": true,
  "data": {
    "user_id": "MRU2025003204",
    "user_type": "student",
    "full_name": "NAKYESERO RITAH",
    "expires": "2026-03-15T19:04:00.000Z"
  }
}
```

---

## Student

**Endpoint:** `student.aspx`

All student endpoints require authentication. Students can only view their own data. Staff can pass `?regno=` to query any student.

### Profile

**Action:** `profile` | **Auth:** Required | **Access:** Both

Returns the student's biographical and academic profile.

**Parameters:**

| Param | Required | Description |
|---|---|---|
| `token` | Yes | Session token |
| `regno` | Staff only | Registration number to query |

**Response fields:** `regno`, `entryno`, `firstname`, `othername`, `gender`, `programme`, `progcode`, `campus`, `study_year`, `entry_year`, `intake`, `session`, `status`, `nationality`, `phone`, `email`, `date_of_birth`, `district`, `photo_url`

### Photo

**Action:** `photo` | **Auth:** Required | **Access:** Both

Returns the student's photo as a binary JPEG image (not JSON).

| Param | Required | Description |
|---|---|---|
| `token` | Yes | Session token |
| `regno` | Staff only | Registration number to query |

**Response:** `Content-Type: image/jpeg` (binary image data). Falls back to a file at `~/patientimages/{regno}.jpg` if no database blob.

### Lock Status

**Action:** `lock_status` | **Auth:** Required | **Access:** Both

Returns the student's account lock status.

| Param | Required | Description |
|---|---|---|
| `token` | Yes | Session token |
| `regno` | Staff only | Registration number to query |

**Response fields:** `regno`, `lock_status`, `lock_reason`, `lock_date`, `locked_by`, `stud_name`, `progid`, `entryno`

### Summary

**Action:** `summary` | **Auth:** Required | **Access:** Both

Returns a quick summary of the student's current academic and financial standing.

| Param | Required | Description |
|---|---|---|
| `token` | Yes | Session token |
| `regno` | Staff only | Registration number to query |

**Response fields include:** `cgpa`, `bal` (balance), `regno`, `acad_year`, `semester`, `regstatus`, `examClearance`

---

## Staff

**Endpoint:** `staff.aspx`

All staff endpoints require authentication and staff user type.

### Profile

**Action:** `profile` | **Auth:** Required | **Access:** Staff only

Returns the staff member's profile.

| Param | Required | Description |
|---|---|---|
| `token` | Yes | Session token |
| `staff_id` | No | Query another staff member's profile |

**Response fields:** `emp_id`, `emp_surname`, `emp_othernames`, `emp_gender`, `emp_email`, `emp_phone`, `emp_title`, `department`, `faculty`, `emp_status`, `emp_designation`, `emp_contract_type`, `emp_date_employed`, `emp_national_id`, `usernames`, `photo_url`

### Photo

**Action:** `photo` | **Auth:** Required | **Access:** Staff only

Returns the staff member's photo as binary JPEG (own photo only).

### My Courses

**Action:** `my_courses` | **Auth:** Required | **Access:** Staff only

Returns courses assigned to the staff member for teaching.

| Param | Required | Description |
|---|---|---|
| `token` | Yes | Session token |
| `acad_year` | No | Filter by academic year |
| `semester` | No | Filter by semester |

**Response fields per course:** `course_code`, `course_name`, `credit_units`, `programme_code`, `programme_name`, `acad_year`, `semester`, `study_year`

### Class List

**Action:** `class_list` | **Auth:** Required | **Access:** Staff only

Returns the list of students registered for a specific course.

| Param | Required | Description |
|---|---|---|
| `token` | Yes | Session token |
| `course_id` | Yes | Course code |
| `acad_year` | Yes | Academic year |
| `semester` | No | Default: 1 |

**Response:** `course_id`, `acad_year`, `semester`, `total_students`, `students[]` (each: `registration_id`, `regno`, `firstname`, `othername`, `gender`, `study_year`, `session`)

### View Marks

**Action:** `marks` | **Auth:** Required | **Access:** Staff only

Returns submitted marks for a course.

| Param | Required | Description |
|---|---|---|
| `token` | Yes | Session token |
| `course_id` | Yes | Course code |
| `acad_year` | Yes | Academic year |
| `semester` | No | Default: 1 |

**Response:** `course_id`, `acad_year`, `semester`, `total_students`, `marks[]` (each: `regno`, `firstname`, `othername`, `course_work`, `exam_total`, `total`, `grade`, `gp`, `remarks`)

### Submit Marks

**Action:** `submit_marks` | **Auth:** Required | **Access:** Staff only

Submits or updates marks for students in a course. Accepts a JSON array of mark entries.

| Param | Required | Description |
|---|---|---|
| `token` | Yes | Session token |
| `course_id` | Yes | Course code |
| `acad_year` | Yes | Academic year |
| `semester` | No | Default: 1 |
| `marks` | Yes | JSON array via param or request body |

**Marks format:**

```json
[
  {"regno": "MRU2025003204", "coursework": 30, "exam": 50},
  {"regno": "MRU2025003205", "coursework": 25, "exam": 45}
]
```

The system auto-calculates `total`, `grade`, `gp`, and `remarks` using the grading scale:

| Score | Grade | GP |
|---|---|---|
| ≥ 80 | A | 5.0 |
| ≥ 75 | B+ | 4.5 |
| ≥ 70 | B | 4.0 |
| ≥ 65 | C+ | 3.5 |
| ≥ 60 | C | 3.0 |
| ≥ 55 | D+ | 2.5 |
| ≥ 50 | D | 2.0 |
| < 50 | F | 0.0 |

Remarks: `NP` (Normal Pass) if total ≥ 50, `PP` (Poor Performance) if < 50.

**Response:** `updated`, `inserted`, `errors`, `total_processed`

---

## Academic

**Endpoint:** `academic.aspx`

All academic endpoints require authentication. Students can only view their own data. Staff must pass `?regno=` to query a student.

### Results

**Action:** `results` | **Auth:** Required | **Access:** Both

Returns the student's academic results.

| Param | Required | Description |
|---|---|---|
| `token` | Yes | Session token |
| `regno` | Staff only | Registration number |
| `acad_year` | No | Filter by academic year |
| `semester` | No | Filter by semester |

**Response fields per result:** `coursename`, `courseid`, `semester`, `acad` (academic year), `studyyear`, `score`, `grade`, `gradept`, `gpa`, `result_comment`, `CreditUnits`, `progid`

### Transcript

**Action:** `transcript` | **Auth:** Required | **Access:** Both

Returns a full structured transcript with semester-by-semester GPA calculations.

| Param | Required | Description |
|---|---|---|
| `token` | Yes | Session token |
| `regno` | Staff only | Registration number |

**Response:**

```json
{
  "student": { "firstname": "...", "othername": "...", "programme": "...", ... },
  "semesters": [
    {
      "acad_year": "2025/2026",
      "semester": "1",
      "courses": [ ... ],
      "semester_gpa": 4.21,
      "semester_credits": 21
    }
  ],
  "cgpa": 4.21,
  "total_credits": 21,
  "classification": "Second Class Upper"
}
```

### GPA

**Action:** `gpa` | **Auth:** Required | **Access:** Both

Returns GPA summary without individual course details.

| Param | Required | Description |
|---|---|---|
| `token` | Yes | Session token |
| `regno` | Staff only | Registration number |

**Response:** `semesters[]` (each: `acad_year`, `semester`, `gpa`, `credits`), `cgpa`, `total_credits`, `classification`

**Degree Classification Scale:**

| CGPA | Classification |
|---|---|
| ≥ 4.4 | First Class |
| ≥ 3.6 | Second Class Upper |
| ≥ 2.8 | Second Class Lower |
| ≥ 2.0 | Pass |
| < 2.0 | Below Pass |

### Available Courses

**Action:** `available_courses` | **Auth:** Required | **Access:** Both

Returns courses available for registration.

| Param | Required | Description |
|---|---|---|
| `token` | Yes | Session token |
| `acad_year` | Yes | Academic year |
| `regno` | Staff only | Registration number |
| `semester` | No | Default: 1 |

### Registered Courses

**Action:** `registered_courses` | **Auth:** Required | **Access:** Both

Returns courses the student is currently registered for.

| Param | Required | Description |
|---|---|---|
| `token` | Yes | Session token |
| `acad_year` | Yes | Academic year |
| `regno` | Staff only | Registration number |
| `semester` | No | Default: 1 |

### Register Course

**Action:** `register_course` | **Auth:** Required | **Access:** Student only

Registers a student for a course.

| Param | Required | Description |
|---|---|---|
| `token` | Yes | Session token |
| `course_id` | Yes | Course code to register |
| `acad_year` | Yes | Academic year |
| `semester` | No | Default: 1 |

**Notes:** Duplicate registrations return a friendly error message.

### Drop Course

**Action:** `drop_course` | **Auth:** Required | **Access:** Student only

Drops a previously registered course.

| Param | Required | Description |
|---|---|---|
| `token` | Yes | Session token |
| `registration_id` | Yes | The registration record ID |

### Semester Registration

**Action:** `semester_registration` | **Auth:** Required | **Access:** Student only

Processes semester registration and triggers automatic billing.

| Param | Required | Description |
|---|---|---|
| `token` | Yes | Session token |
| `acad_year` | Yes | Academic year |
| `semester` | No | Default: 1 |

**Important:** This action automatically triggers financial billing (tuition and accommodation) via the `fin_Autobilling` stored procedure.

**Response:** `registration_result`, `acad_year`, `semester`, `billing_processed`

### Registration History

**Action:** `registration_history` | **Auth:** Required | **Access:** Both

Returns the student's semester registration history.

| Param | Required | Description |
|---|---|---|
| `token` | Yes | Session token |
| `regno` | Staff only | Registration number |

**Response fields per record:** `acad_year`, `semester`, `regstatus`, `studyyear`, `id_cardStatus`, `residence_status`, `examClearance`, `examClearanceDate`, `clearedBy`, `registeredBy`

---

## Finance

**Endpoint:** `finance.aspx`

All finance endpoints require authentication. Students view their own data. Staff pass `?regno=`.

### Ledger

**Action:** `ledger` | **Auth:** Required | **Access:** Both

Returns the full financial ledger for the student.

| Param | Required | Description |
|---|---|---|
| `token` | Yes | Session token |
| `regno` | Staff only | Registration number |

**Response:** `balance`, `total_charges`, `total_payments`, `currency` ("UGX"), `entries[]` (full ledger rows with debits and credits)

### Balance

**Action:** `balance` | **Auth:** Required | **Access:** Both

Returns a financial summary without individual line items.

| Param | Required | Description |
|---|---|---|
| `token` | Yes | Session token |
| `regno` | Staff only | Registration number |

**Response:** `balance`, `total_charges`, `total_payments`, `currency` ("UGX"), `last_payment_date`

### Fees Structure

**Action:** `fees_structure` | **Auth:** Required | **Access:** Both

Returns the fee breakdown for the student's programme and study year.

| Param | Required | Description |
|---|---|---|
| `token` | Yes | Session token |
| `regno` | Staff only | Registration number |

**Response:** `programme_code`, `study_year`, `fee_category`, `currency` ("UGX"), `total_fees`, `items[]` (each: `item`, `amount`, `semester`)

**Notes:** Fee category (Ugandan vs International) is automatically determined from the student's nationality.

---

## Timetable

**Endpoint:** `timetable.aspx`

All timetable endpoints require authentication.

### Lectures

**Action:** `lectures` | **Auth:** Required | **Access:** Both

Returns the lecture timetable. Students get their programme's timetable. Staff get courses they teach.

| Param | Required | Description |
|---|---|---|
| `token` | Yes | Session token |
| `acad_year` | No | Filter by academic year |
| `semester` | No | Filter by semester |

**Student response fields:** `day_of_week`, `start_time`, `end_time`, `course_code`, `course_name`, `room`, `building`, `lecturer`

**Staff response fields:** Same plus `programme_code`, `programme_name`

**Notes:** Ordered by day (Monday → Sunday), then by start time.

### Exams

**Action:** `exams` | **Auth:** Required | **Access:** Both

Returns the exam timetable. Students get exams for their programme. Staff get exams where they are invigilator.

| Param | Required | Description |
|---|---|---|
| `token` | Yes | Session token |
| `acad_year` | No | Filter by academic year |
| `semester` | No | Filter by semester |

**Student response fields:** `exam_date`, `start_time`, `end_time`, `course_code`, `course_name`, `venue`, `exam_type`

---

## Campus (Public & Authenticated)

**Endpoint:** `campus.aspx`

Some campus endpoints are public (no auth required), others require authentication.

### Academic Years (Public)

**Action:** `academic_years` | **Auth:** None

Returns all available academic years.

### Current Semester (Public)

**Action:** `current_semester` | **Auth:** None

Returns the current academic year and semester.

**Response:** `acad_year`, `semester` (if available), `note` (fallback info)

### Programmes (Public)

**Action:** `programmes` | **Auth:** None

Returns all available programmes.

**Response fields:** `progcode`, `programme`

### Campuses (Public)

**Action:** `campuses` | **Auth:** None

Returns all campus locations.

**Response fields:** `campus_id`, `campus_name`

### Notices

**Action:** `notices` | **Auth:** Required | **Access:** Both

Returns active notices with pagination.

| Param | Required | Description |
|---|---|---|
| `token` | Yes | Session token |
| `page` | No | Default: 1 |
| `limit` | No | Default: 20, max: 50 |

**Response:** `notices[]` (each: `notice_id`, `title`, `content`, `created_by`, `date_created`, `target_audience`), `pagination` (`page`, `limit`, `total`, `total_pages`)

### Directory

**Action:** `directory` | **Auth:** Required | **Access:** Both

Returns the staff directory.

| Param | Required | Description |
|---|---|---|
| `token` | Yes | Session token |
| `category` | No | Filter by department, faculty, or designation |

**Response fields:** `emp_id`, `full_name`, `emp_title`, `emp_designation`, `emp_email`, `emp_telephone`, `department`, `faculty`

---

## Error Codes

| Code | Description |
|---|---|
| `INVALID_ACTION` | Unknown action parameter |
| `SERVER_ERROR` | Internal server error |
| `MISSING_PARAM` | Required parameter not provided |
| `AUTH_MISSING_TOKEN` | No token in request |
| `AUTH_INVALID_TOKEN` | Token expired or invalid |
| `AUTH_LOGIN_FAILED` | Bad username/password or account not found |
| `ACCESS_DENIED` | User type not permitted for this action |
| `NOT_FOUND` | Requested resource doesn't exist |

---

## Quick Start Examples

### Login with Registration Number

```
POST /API/v2/auth.aspx?action=login&username=MRU2025003204&password=123
```

### Login with Entry Number

```
POST /API/v2/auth.aspx?action=login&username=25/U/BAED/0084/K/DAY&password=123
```

### Get Student Profile

```
GET /API/v2/student.aspx?action=profile&token=YOUR_TOKEN
```

### Get Academic Results

```
GET /API/v2/academic.aspx?action=results&token=YOUR_TOKEN
```

### Get Financial Balance

```
GET /API/v2/finance.aspx?action=balance&token=YOUR_TOKEN
```

### Get GPA Summary

```
GET /API/v2/academic.aspx?action=gpa&token=YOUR_TOKEN
```

### Staff: View Student Profile

```
GET /API/v2/student.aspx?action=profile&token=STAFF_TOKEN&regno=MRU2025003204
```

### Staff: Submit Marks

```
POST /API/v2/staff.aspx?action=submit_marks&token=STAFF_TOKEN&course_id=FND1101&acad_year=2025/2026&marks=[{"regno":"MRU2025003204","coursework":30,"exam":50}]
```

---

## Token Management

- Tokens expire after **24 hours**
- Each new login **deactivates all previous tokens** for that user
- Invalid or expired tokens return `AUTH_INVALID_TOKEN` error
- Use `auth.aspx?action=validate` to check token validity without side effects
- Use `auth.aspx?action=logout` to explicitly deactivate a token

---

## Architecture Notes

- **Database connections:** Main DB (`campus_dynamics`), Portal DB (`campus_dynamics_portal` — student membership), Accounts DB (`campus_dynamics_accounts` — financial data)
- **Password security:** HMACSHA256 hashing with per-user salt, matching MySQLMembershipProvider
- **Study year:** Derived from `acad_registration.studyyear` (latest registration), not stored on the student record
- **Timetable tables:** `acad_timetable` (lectures) and `acad_exam_timetable` (exams) must exist in the database for timetable endpoints to function
