# Course Registration Ledger Controller - Complete Documentation

**Version**: 2.0  
**Last Updated**: April 2026  
**Module**: COOPERP → NewScreens  
**System**: Campus Dynamics Portal  

---

## 📋 Table of Contents

1. [System Overview](#system-overview)
2. [Architecture](#architecture)
3. [Form System](#form-system)
4. [User Workflows](#user-workflows)
5. [Admin Workflows](#admin-workflows)
6. [API Reference](#api-reference)
7. [Database Schema](#database-schema)
8. [Security Implementation](#security-implementation)
9. [Error Handling](#error-handling)
10. [Performance Considerations](#performance-considerations)
11. [Troubleshooting](#troubleshooting)

---

## 1. System Overview

### Purpose
The Course Registration Ledger Controller provides comprehensive management of course registrations with features for:
- Viewing all student course registrations
- Creating new course registrations
- Editing registration status
- Deleting registrations (with data protection)
- Filtering and sorting records
- Real-time validation

### Key Features
- ✅ **Intelligent Auto-fill**: Student/course information automatically populated from database
- ✅ **Real-time Validation**: Student verification before registration
- ✅ **Duplicate Prevention**: Prevents same student registering for same course multiple times
- ✅ **Data Protection**: Cannot delete registrations with assessment results
- ✅ **Status Management**: Update registration status (REGULAR, RETAKE, PENDING, NORMAL)
- ✅ **Advanced Filtering**: Filter by year, semester, programme, course, status, student
- ✅ **Responsive Design**: Works on desktop and mobile devices
- ✅ **Professional UI**: Navy and grey themed, consistent with Campus Dynamics

### User Roles
- **Student**: Can view their own registrations (in other modules)
- **Admin/Academic Officer**: Can create, edit, delete registrations; manage status
- **Dean/Programme Head**: Can view registrations for their programme

---

## 2. Architecture

### Technology Stack
```
Frontend:
  - ASP.NET Web Forms (ASPX)
  - HTML5 / CSS3
  - Vanilla JavaScript (XMLHttpRequest, no jQuery)
  - Responsive grid layout

Backend:
  - C# .NET Framework 4.0
  - ASP.NET WebMethods (AJAX via HTTP POST)
  - MySQL 5.6+ database
  - Parameterized SQL (injection-safe)

Security:
  - Input validation (client and server)
  - Output encoding (HTML attribute encoding)
  - Parameterized SQL queries
  - Session-based authentication (inherited from master page)
```

### Component Structure

```
CourseRegistrationLedgerController.aspx
├── CSS Styling (800+ lines)
│   ├── Grid/card layout
│   ├── Modal styling (form + detail)
│   ├── Table styling with responsive columns
│   ├── Actions column styling
│   └── Loading spinners & animations
│
├── HTML Markup
│   ├── Main ledger table with 13 columns
│   ├── Advanced filter panels
│   ├── Detail modal (existing feature)
│   ├── Create form modal
│   ├── Edit form modal
│   └── Pagination controls
│
└── JavaScript (1200+ lines of logic)
    ├── Filter management (apply, reset, auto-wire)
    ├── Table interaction (sorting, pagination)
    ├── Detail modal (opens when clicking registration number)
    ├── Create form modal
    │   ├── Student real-time validation
    │   ├── Form field-level validation
    │   ├── AJAX form submission
    │   └── Success/error message display
    ├── Edit form modal
    │   ├── Modal population from table data
    │   ├── Status update submission
    │   └── Error handling
    └── Delete confirmation & execution
        ├── Confirmation dialog
        ├── AJAX deletion request
        └── Table refresh

CourseRegistrationLedgerController.aspx.cs (Backend)
├── Page lifecycle (Page_Load, BindGrid)
├── SQL query builders
│   ├── Heavy path (sorts by marks then grade)
│   ├── Light path (normal sort by latest)
│   └── Status badge styling
├── WebMethods (AJAX endpoints)
│   ├── ValidateStudentExists
│   ├── CreateCourseRegistration
│   ├── DeleteCourseRegistration
│   └── EditCourseRegistration
└── Helper functions
    ├── GetDBString (NULL-safe reading)
    ├── CreateJsonResponse (standardized JSON)
    └── EscapeJsonString (JSON-safe strings)
```

### Data Flow Diagram

#### Create Registration Flow
```
User Interface → Form Validation → Student Verification AJAX → Dropdown Selection
    ↓
User clicks "Create Record" → Validate all 4 fields → AJAX POST
    ↓
CreateCourseRegistration WebMethod (Server)
    ├─ Validate inputs
    ├─ Check student exists
    ├─ Check course exists
    ├─ Check duplicate registration
    ├─ Fetch auto-fill data
    ├─ INSERT into database
    └─ Return registration ID + auto-filled fields
    ↓
Success → Show message → Refresh table → Close modal
    ↓
User sees new registration in table with all fields populated
```

#### Edit Registration Flow
```
User clicks Edit button (✎) → Extract record data from table row
    ↓
Show edit modal with:
  - Registration number (read-only)
  - Course name (read-only)
  - Academic year (read-only)
  - Semester (read-only)
  - Status dropdown (REGULAR, RETAKE, PENDING, NORMAL)
    ↓
User selects new status → Clicks "Save Changes"
    ↓
EditCourseRegistration WebMethod (Server)
    ├─ Validate status value
    ├─ Verify record exists
    ├─ UPDATE course_status
    └─ Set modified_date = NOW()
    ↓
Success → Close modal → Refresh table
    ↓
User sees updated status in table
```

#### Delete Registration Flow
```
User clicks Delete button (🗑) → Check if button disabled
    ↓
If disabled: Button is grayed out (record has marks/grades)
    ↓
If enabled: Show confirmation dialog
    ↓
User confirms deletion
    ↓
DeleteCourseRegistration WebMethod (Server)
    ├─ Validate record ID
    ├─ Get registration details
    ├─ Check for marks/grades in acad_results table
    ├─ If has results → Return error
    ├─ Otherwise → DELETE record
    └─ Return success
    ↓
Success → Close confirmation → Refresh table
    ↓
User sees registration removed from table
```

---

## 3. Form System

### Create New Registration Form

#### Requirements
**Input Fields**: 4 required fields
1. **Student Registration Number** (max 20 chars)
   - User enters manually
   - Verify button triggers real-time AJAX validation
   - Disabled after successful verification

2. **Course** (dropdown)
   - Auto-populated from database lookup cache
   - Shows: Course ID - Course Name
   - Shows course count for easy selection

3. **Academic Year** (dropdown)
   - Auto-populated from cached data
   - Shows available years

4. **Semester** (radio buttons)
   - 3 options: Semester 1, Semester 2, Semester 3
   - Must select exactly one

**Auto-filled Fields** (after successful submission):
- Student name
- Programme name
- Course name
- Registration ID
- Course status (always "REGULAR" for new)

#### Form Modal Structure

```html
┌─────────────────────────────────────────────────────┐
│ Create New Course Registration              [×]    │
├─────────────────────────────────────────────────────┤
│                                                     │
│ ✅ Record created successfully!                    │
│    Auto-filled data is being loaded...              │
│                                                     │
│ Student Registration Number *                       │
│ ┌──────────────────────────┬──────────┐             │
│ │ [text input]             │ [Verify] │             │
│ └──────────────────────────┴──────────┘             │
│ Student Name (Programme Name)         [after verify] │
│                                                     │
│ Course *                                            │
│ ┌─────────────────────────────────────┐             │
│ │ [dropdown: Course Code - Name]      │             │
│ └─────────────────────────────────────┘             │
│                                                     │
│ Academic Year *                                     │
│ ┌─────────────────────────────────────┐             │
│ │ [dropdown: 2024/2025]               │             │
│ └─────────────────────────────────────┘             │
│                                                     │
│ Semester *                                          │
│ ○ Semester 1  ○ Semester 2  ○ Semester 3           │
│                                                     │
├─────────────────────────────────────────────────────┤
│                      [Cancel]  [Create Record]      │
└─────────────────────────────────────────────────────┘
```

#### Validation Rules

**Client-side Validation**:
```
Student Reg No:
  ✓ Not empty (required)
  ✓ Max 20 characters
  ✓ Must pass server verification
  
Course:
  ✓ Not empty (required)
  ✓ Must be valid course ID from dropdown
  
Academic Year:
  ✓ Not empty (required)
  ✓ Must be valid year from dropdown
  
Semester:
  ✓ Exactly one selected (required)
  ✓ Must be 1, 2, or 3
```

**Server-side Validation**:
```
Step 1: Input Validation
  ✓ All parameters required
  ✓ Semester must be integer 1-3
  
Step 2: Student Verification
  ✓ Registration number must exist in acad_student table
  ✓ Must have valid programme assignment
  
Step 3: Course Verification
  ✓ Course ID must exist in acad_course table
  ✓ Course must be active/available
  
Step 4: Duplicate Check
  ✓ Same student + course + year + semester cannot exist
  ✓ Prevents accidental duplicate registrations
  
Step 5: Data Population
  ✓ Fetch auto-fill data before INSERT
  ✓ Ensure all required fields populated
  
Step 6: INSERT
  ✓ Parameterized SQL prevents injection
  ✓ created_date set to NOW()
  ✓ course_status always 'REGULAR'
```

#### Error Handling

**Example Error Messages**:
```
"Registration number is required" 
  → User: Empty field
  
"Student not found"
  → User: Invalid registration number
  
"Course not found"
  → User: Selected invalid course
  
"All fields are required"
  → User: Forgot to fill a field
  
"This student is already registered for this course 
   in the specified period"
  → User: Duplicate registration attempt
  
"Error creating registration: [exception]"
  → User: Database error (rare)
```

### Edit Registration Form

#### Purpose
Update the **course_status** only. Other fields are read-only to prevent data corruption.

#### Form Modal Structure

```html
┌─────────────────────────────────────────────────────┐
│ Edit Course Registration Status            [×]     │
├─────────────────────────────────────────────────────┤
│                                                     │
│ Student Registration Number                        │
│ ┌─────────────────────────────────────┐             │
│ │ REG001234           [disabled]       │             │
│ └─────────────────────────────────────┘             │
│                                                     │
│ Course                                              │
│ ┌─────────────────────────────────────┐             │
│ │ CS101 - Data Structures [disabled]   │             │
│ └─────────────────────────────────────┘             │
│                                                     │
│ Academic Year                                       │
│ ┌─────────────────────────────────────┐             │
│ │ 2024/2025           [disabled]       │             │
│ └─────────────────────────────────────┘             │
│                                                     │
│ Semester                                            │
│ ┌─────────────────────────────────────┐             │
│ │ 1                   [disabled]       │             │
│ └─────────────────────────────────────┘             │
│                                                     │
│ Course Status *                                     │
│ ┌─────────────────────────────────────┐             │
│ │ [▼ Dropdown: REGULAR, RETAKE, ...]  │ ← editable │
│ └─────────────────────────────────────┘             │
│                                                     │
├─────────────────────────────────────────────────────┤
│                      [Cancel]  [Save Changes]       │
└─────────────────────────────────────────────────────┘
```

#### Status Options
- **REGULAR**: Normal course registration
- **RETAKE**: Student retaking the course
- **PENDING**: Registration pending approval
- **NORMAL**: Alternative status designation

#### Validation Rules
```
Status:
  ✓ Not empty (required)
  ✓ Must be one of: REGULAR, RETAKE, PENDING, NORMAL
  ✓ Server validates against whitelist
```

---

## 4. User Workflows

### Workflow 1: Create New Course Registration

**Step-by-step**:

1. **Click "New Registration" button**
   - Location: Top-right of the ledger card header
   - Form modal appears with overlay
   - All fields empty and ready for input

2. **Enter Student Registration Number**
   - Type the 10-15 character registration number (e.g., "REG001234")
   - Click "Verify" button
   - System checks database for student
   - **If found**: Student name and programme appear below field, campo disabled
   - **If not found**: Red error message, can retry

3. **Select Course**
   - Click Course dropdown
   - Choose desired course from list
   - Dropdown shows format: "Code - Course Name"

4. **Select Academic Year**
   - Click Academic Year dropdown
   - Choose the year (e.g., "2024/2025")

5. **Select Semester**
   - Click one of three radio buttons: 1, 2, or 3
   - Only one can be selected at a time

6. **Submit Form**
   - Click "Create Record" button
   - System validates all fields
   - **If validation fails**: Error message shows, can fix and retry
   - **If validation passes**: AJAX request sent to server
   - Button shows loading spinner while processing

7. **Success**
   - Green success message appears
   - After 1.5 seconds, modal closes automatically
   - Ledger table refreshes showing new registration
   - Course status shows "REGULAR" by default

**Common Issues**:
- Forgot to click "Verify" before selecting course
  → Fix: Click Verify, wait for student confirmation
- Typed wrong registration number
  → Fix: Clear field (modal doesn't disable until verified), type correct number, verify again
- Duplicate registration attempt
  → Fix: Check if student already registered for that course in that semester

### Workflow 2: Edit Registration Status

**Step-by-step**:

1. **Locate the Registration** in the ledger table
   - Use filters to narrow down results if needed
   - Find the row for the student/course/year you want to edit

2. **Click Edit Button** (✎ pencil icon)
   - Location: Actions column (rightmost)
   - Edit form modal appears
   - All fields pre-populated from table data
   - Registration info is read-only
   - Status dropdown is editable

3. **Select New Status**
   - Click Status dropdown
   - Choose new status: REGULAR, RETAKE, PENDING, or NORMAL
   - Previous status pre-selected

4. **Save Changes**
   - Click "Save Changes" button
   - AJAX request sent to server
   - Button shows loading spinner

5. **Success**
   - Modal closes automatically
   - Ledger table refreshes
   - Updated status visible in table

### Workflow 3: Delete Course Registration

**Step-by-step**:

1. **Locate the Registration**
   - Use filters if needed
   - Find the row to delete

2. **Check Delete Button Status**
   - If button is **enabled** (normal appearance): Safe to delete
   - If button is **disabled** (grayed out): Record has assessment results, cannot delete

3. **Click Delete Button** (🗑 trash icon)
   - If disabled: Nothing happens (button is inactive)
   - If enabled: Confirmation dialog appears

4. **Confirm Deletion**
   - Dialog shows: "Are you sure you want to delete the course registration for [REGNO]? This action cannot be undone."
   - Click OK to proceed, Cancel to abort

5. **Deletion Process**
   - Server checks for assessment data one more time
   - **If has data**: Returns error "Cannot delete - has assessment results"
   - **If safe**: Record deleted from database
   - Ledger table refreshes
   - Row removed from display

**Safety Features**:
- Delete button disabled automatically if record has marks or grades
- Server-side verification prevents accidental deletion of scored records
- Confirmation dialog requires explicit user confirmation
- Cannot undo deletion (permanent removal)

---

## 5. Admin Workflows

### Workflow: Bulk Operations

**For admins managing multiple registrations**:

1. **Use Advanced Filtering**
   - Click "Toggle Filters" to show filter panel
   - Filter by: Academic Year, Semester, Programme, Course, Status
   - Search by: Student name or registration number
   - Choose rows per page (25, 50, 100, 200)
   - Click "Apply" to filter

2. **Sort Results**
   - Click column headers to sort by that column
   - Sorts available on: Reg No, Student Name, Programme, Course, Academic Year, Semester, Status, Marks, Grade

3. **Click on Detail**
   - Click any registration number (blue and underlined)
   - Modal shows complete record details with timestamps

4. **Bulk Status Updates** (if needed for multiple records)
   - Edit one registration at a time using Edit button
   - Future enhancement: Multi-select bulk operations (not currently implemented)

### Workflow: Academic Integrity Check

**Before finalizing results**:

1. **Filter registrations with status = PENDING**
   - Set Status filter to "PENDING"
   - Click "Apply"

2. **Review each pending registration**
   - Click registration number for full details
   - Verify registration validity

3. **Change status when approved**
   - Click Edit button
   - Change status to "REGULAR" or "RETAKE" as appropriate
   - Click "Save Changes"

---

## 6. API Reference

### WebMethod: ValidateStudentExists

**Purpose**: Real-time validation of student registration number

**Endpoint**: `POST /CourseRegistrationLedgerController.aspx/ValidateStudentExists`

**Parameters**:
```
GET:  regno (string, max 20 chars, required)

Example: 
  ValidateStudentExists('REG001234')
```

**Response** (JSON):
```json
{
  "d": {
    "success": true,
    "message": null,
    "data": {
      "student_name": "John Doe",
      "programme_name": "Bachelor of Science in Computer Science"
    }
  }
}

OR (Error):

{
  "d": {
    "success": false,
    "message": "Student not found.",
    "data": null
  }
}
```

**Validation** (Server-side):
- regno parameter required
- Query checks acad_student table
- Returns first and other names combined
- Includes programme name from acad_programme table

**Example Usage** (JavaScript):
```javascript
var xhr = new XMLHttpRequest();
xhr.open('POST', 'CourseRegistrationLedgerController.aspx/ValidateStudentExists', true);
xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
xhr.setRequestHeader('X-Requested-With', 'XMLHttpRequest');

xhr.onload = function() {
    var response = JSON.parse(xhr.responseText);
    if (response.d.success) {
        console.log(response.d.data.student_name);
    } else {
        console.error(response.d.message);
    }
};

xhr.send('regno=REG001234');
```

---

### WebMethod: CreateCourseRegistration

**Purpose**: Create new course registration with validation and auto-fill

**Endpoint**: `POST /CourseRegistrationLedgerController.aspx/CreateCourseRegistration`

**Parameters**:
```
POST Body:
  - regno (string, required)
  - courseID (string, required)
  - acad_year (string, required)
  - semester (string: "1", "2", or "3", required)

Example:
  CreateCourseRegistration('REG001234', 'CS101', '2024/2025', '1')
```

**Validation Process**:
1. All parameters required and non-empty
2. Semester must be integer 1-3
3. Student must exist in acad_student table
4. Course must exist in acad_course table
5. Duplicate check: (student + course + year + semester) must not already exist
6. Fetch student/course auto-fill data
7. INSERT into acad_course_registration

**Response** (JSON - Success):
```json
{
  "d": {
    "success": true,
    "message": null,
    "data": {
      "registration_id": 12345,
      "regno": "REG001234",
      "student_name": "John Doe",
      "courseID": "CS101",
      "course_name": "Data Structures",
      "programme_name": "Bachelor of Science in Computer Science",
      "acad_year": "2024/2025",
      "semester": "1",
      "course_status": "REGULAR"
    }
  }
}
```

**Response** (JSON - Validation Error):
```json
{
  "d": {
    "success": false,
    "message": "This student is already registered for this course in the specified period.",
    "data": null
  }
}
```

**Database Insert Details**:
```sql
INSERT INTO campus_dynamics_portal.acad_course_registration 
  (regno, courseID, prog_id, acad_year, semester, course_status, created_date)
VALUES 
  ('REG001234', 'CS101', 'BSCS', '2024/2025', 1, 'REGULAR', NOW())
```

---

### WebMethod: EditCourseRegistration

**Purpose**: Update registration status only

**Endpoint**: `POST /CourseRegistrationLedgerController.aspx/EditCourseRegistration`

**Parameters**:
```
POST Body:
  - id (string/int, required)
  - course_status (string: "REGULAR", "RETAKE", "PENDING", "NORMAL", required)

Example:
  EditCourseRegistration('12345', 'RETAKE')
```

**Validation**:
1. ID and course_status required
2. Status must be in: ["REGULAR", "RETAKE", "PENDING", "NORMAL"]
3. Record with given ID must exist
4. Server-side whitelist validation on status

**Response** (JSON - Success):
```json
{
  "d": {
    "success": true,
    "message": null,
    "data": null
  }
}
```

**Response** (JSON - Error):
```json
{
  "d": {
    "success": false,
    "message": "Invalid status value.",
    "data": null
  }
}
```

**Database Update**:
```sql
UPDATE campus_dynamics_portal.acad_course_registration 
SET course_status = 'RETAKE', 
    modified_date = NOW() 
WHERE id = 12345
```

---

### WebMethod: DeleteCourseRegistration

**Purpose**: Delete registration with assessment data protection

**Endpoint**: `POST /CourseRegistrationLedgerController.aspx/DeleteCourseRegistration`

**Parameters**:
```
POST Body:
  - id (string/int, required)

Example:
  DeleteCourseRegistration('12345')
```

**Validation Process**:
1. ID required
2. ID must be valid integer format
3. Record with ID must exist (query retrieves: regno, courseID, acad_year, semester)
4. Check acad_results table:
   - Count records with matching (regno, courseid, acad, semester)
   - Where (score IS NOT NULL) OR (grade IS NOT NULL)
   - If count > 0: Cannot delete
5. If safe: DELETE from acad_course_registration

**Response** (JSON - Success):
```json
{
  "d": {
    "success": true,
    "message": null,
    "data": null
  }
}
```

**Response** (JSON - Error - Has Results):
```json
{
  "d": {
    "success": false,
    "message": "Cannot delete this record - it has assessment results associated with it.",
    "data": null
  }
}
```

**Response** (JSON - Error - Invalid ID):
```json
{
  "d": {
    "success": false,
    "message": "Record not found.",
    "data": null
  }
}
```

**Database Deletion**:
```sql
DELETE FROM campus_dynamics_portal.acad_course_registration WHERE id = 12345
```

---

## 7. Database Schema

### Related Tables

**acad_course_registration** (Primary)
```
Column               Type        Constraints    Purpose
─────────────────────────────────────────────────────────────
id                  INT         PK, AUTO_INC   Unique registration ID
regno               VARCHAR(20) NOT NULL       Student registration number
courseid            VARCHAR(10) NOT NULL       Foreign key to acad_course
prog_id             VARCHAR(10)                Programme ID
acad_year           VARCHAR(10) NOT NULL       Academic year (e.g., 2024/2025)
semester            INT         NOT NULL       1, 2, or 3
course_status       VARCHAR(20) DEFAULT REG    REGULAR, RETAKE, PENDING, NORMAL
created_date        TIMESTAMP   DEFAULT NOW()  Registration created
modified_date       TIMESTAMP   NULL           Last status update
```

**acad_student** (Lookup)
```
Column               Type        Purpose
────────────────────────────────────────────────────────
regno               VARCHAR(20) Student registration number (PK)
firstname           VARCHAR(50) Student first name
othername           VARCHAR(50) Student other names
progid              VARCHAR(10) Programme ID (FK to acad_programme)
... other fields
```

**acad_course** (Lookup)
```
Column               Type        Purpose
────────────────────────────────────────────────────────
courseid            VARCHAR(10) Course code (PK)
coursename          VARCHAR(100) Course name
... other fields
```

**acad_programme** (Lookup)
```
Column               Type        Purpose
────────────────────────────────────────────────────────
progcode            VARCHAR(10) Programme code (PK)
progname            VARCHAR(100) Programme name
... other fields
```

**acad_results** (Assessment Check)
```
Column               Type        Purpose
────────────────────────────────────────────────────────
id                  INT         Record ID
regno               VARCHAR(20) Student registration number
courseid            VARCHAR(10) Course ID
acad                VARCHAR(10) Academic year
semester            INT         Semester
score               DECIMAL     Marks/score (0-100)
grade               VARCHAR(2)  Letter grade (A, B, C, D, F)
... other fields
```

### Key Queries

**Fetch registrations for ledger display**:
```sql
SELECT 
  ROW_NUMBER() OVER (ORDER BY cr.acad_year DESC, cr.semester DESC) AS row_no,
  cr.id AS ID,
  cr.regno,
  CONCAT(s.firstname, ' ', s.othername) AS student_name,
  p.progname AS programme_name,
  cr.courseid AS courseID,
  c.coursename AS course_name,
  cr.acad_year,
  cr.semester,
  cr.course_status,
  COALESCE(r.score, '-') AS score,
  COALESCE(r.grade, '-') AS grade,
  COALESCE(r.comment, '') AS comment
FROM acad_course_registration cr
INNER JOIN acad_student s ON cr.regno = s.regno
INNER JOIN acad_programme p ON cr.prog_id = p.progcode
INNER JOIN acad_course c ON cr.courseid = c.courseid
LEFT JOIN acad_results r ON cr.regno = r.regno 
  AND cr.courseid = r.courseid 
  AND cr.acad_year = r.acad
  AND cr.semester = r.semester
WHERE 1=1
  -- Filters applied based on form inputs
ORDER BY cr.acad_year DESC, cr.semester DESC, cr.created_date DESC
LIMIT 50 OFFSET 0
```

---

## 8. Security Implementation

### Input Validation

**Client-side** (JavaScript):
```javascript
// Semester validation
var sem = parseInt(semester);
if (isNaN(sem) || sem < 1 || sem > 3) {
    return false; // Invalid
}

// Required field checks
if (!regno || regno.trim().length === 0) {
    showError("Registration number required");
}

// Length checks
if (regno.length > 20) {
    showError("Registration number too long");
}
```

**Server-side** (C#):
```csharp
// All WebMethods validate parameters
if (string.IsNullOrWhiteSpace(regno))
    return CreateJsonResponse(false, "Registration number is required.", null);

// Type validation
int sem;
if (!int.TryParse(semester, out sem) || sem < 1 || sem > 3)
    return CreateJsonResponse(false, "Invalid semester value.", null);

// Whitelist validation for status
string[] allowedStatuses = { "REGULAR", "RETAKE", "PENDING", "NORMAL" };
if (System.Array.IndexOf(allowedStatuses, status.Trim().ToUpper()) < 0)
    return CreateJsonResponse(false, "Invalid status value.", null);
```

### SQL Injection Prevention

**Parameterized Queries**:
```csharp
// ✅ SAFE: Using parameters
string sql = "SELECT * FROM acad_student WHERE regno = @regno";
using (MySqlCommand cmd = new MySqlCommand(sql, conn))
{
    cmd.Parameters.AddWithValue("@regno", userInput);
    // SQL injection impossible - @ parameters are escaped
}

// ❌ UNSAFE: String concatenation (NOT USED)
string sql = "SELECT * FROM acad_student WHERE regno = '" + userInput + "'";
// Vulnerable if userInput contains: ' OR '1'='1
```

### Cross-site Scripting (XSS) Prevention

**Output Encoding**:
```html
<!-- ❌ UNSAFE: Could allow XSS -->
<span><%# Eval("student_name") %></span>

<!-- ✅ SAFE: HTML encoded -->
<span>
  <%# HttpUtility.HtmlEncode(Eval("student_name").ToString()) %>
</span>

<!-- ✅ SAFE: In attributes -->
<button data-name="<%# HttpUtility.HtmlAttributeEncode(...) %>">
```

**JavaScript Sanitization**:
```javascript
// Extract from user input - already safe via parameters
var status = userInput; // Could contain script tags

// Safe because we validate against whitelist
if (["REGULAR", "RETAKE", "PENDING", "NORMAL"].indexOf(status) < 0) {
    reject(); // Not in whitelist
}
// Pass to server only if in whitelist
```

### CSRF Protection

**Inherited from Master Page**:
- Session-based authentication
- WebMethod calls include `X-Requested-With: XMLHttpRequest` header
- ASP.NET automatically validates ViewState/EventValidation tokens

### Data Encryption

**In Transit**:
- HTTPS (SSL/TLS) - handled by IIS configuration
- All AJAX requests go over HTTPS

**At Rest**:
- Database passwords never stored in code
- Connection string in web.config (IIS protected)
- Sensitive data (marks, grades) restricted by role-based access

---

## 9. Error Handling

### Common Errors and Solutions

**Error: "Student not found"**
```
Cause:    User entered invalid registration number
Solution: Double-check registration number spelling
          Click "Verify" button to confirm existence
          Check if student is actually enrolled
```

**Error: "This student is already registered for this course..."**
```
Cause:    Attempting duplicate registration
Solution: Check existing registrations using filters
          Contact records office if needed to modify existing
          Delete existing if incorrect, create new if needed
```

**Error: "Cannot delete this record - it has assessment results..."**
```
Cause:    Record has marks/grades, cannot delete
Solution: Delete button should be disabled (visual feedback)
          Contact records office to clear results if needed
          Edit status instead of deleting if appropriate
```

**Error: "Course not found"**
```
Cause:    Course code doesn't exist
Solution: Verify course code in dropdown
          Confirm course is active/available
          Contact admin if course should exist
```

**Error: "All fields are required"**
```
Cause:    User didn't fill all 4 required fields
Solution: Verify all fields have values:
          ✓ Registration number verified
          ✓ Course selected
          ✓ Academic year selected
          ✓ Semester selected
```

**Error: HTTP 500 or "Server error"**
```
Cause:    Database error or server crash
Solution: Wait a moment and retry
          Contact IT support if persists
          Check error logs on server
```

**Error: "Network error. Please try again."**
```
Cause:    Connection lost to server
Solution: Check internet connection
          Wait and retry
          Contact IT if network down
```

### Error Recovery

**Form Submission Fails**:
1. Error message displays in red
2. Form remains open with entered data preserved
3. User can fix error and retry
4. No partial data saved to database

**Deletion Fails**:
1. Confirmation dialog closes
2. Alert shows error message
3. Record remains in table
4. User can retry or contact admin

**Modal Unresponsive**:
1. Press ESC key to close
2. Click overlay area to close
3. Close browser tab and reload if stuck

---

## 10. Performance Considerations

### Query Optimization

**Indexed Columns**:
```
acad_course_registration:
  ✓ id (PK - clustered)
  ✓ regno (FK lookup)
  ✓ courseid (FK lookup)
  ✓ acad_year
  ✓ semester
  ✓ course_status

acad_student:
  ✓ regno (PK)
  ✓ progid (FK)

acad_course:
  ✓ courseid (PK)

acad_results:
  ✓ id (PK)
  ✓ (regno, courseid, acad, semester) composite index
```

**Pagination**:
- Default: Show 50 records per page
- Options: 25, 50, 100, 200 rows
- Prevents loading thousands of records at once
- Server uses LIMIT/OFFSET for pagination

**Caching Strategy**:
- Dropdown data cached in JavaScript on page load
- Prevents repeated database queries for lists
- 10-minute TTL for lookup tables
- Cache resets on page reload

### Frontend Performance

**Lazy Loading**:
- Detail modal only fetches data when clicked
- Edit/delete modals populate from visible table data

**Event Delegation**:
- Uses data attributes instead of inline onclick where possible
- Reduces DOM event listener overhead

**Modal Optimization**:
- Only one modal shown at a time (z-index layering)
- Overlay click event handles modal closure
- ESC key listener on document (single handler)

### Database Connection

**Connection Pooling**:
- ASP.NET manages connection pool
- Reuses connections vs. creating new each time
- Configured in web.config

**Query Efficiency**:
- LEFT JOINs for optional data (results)
- Single query for most operations
- Parameterized queries prevent plan eviction

---

## 11. Troubleshooting

### Issue: Form Modal Not Opening

**Symptoms**: Click "New Registration" button, nothing happens

**Solutions**:
1. Check browser console for JavaScript errors (F12)
2. Verify browser supports JavaScript (enable if disabled)
3. Check if modal divs exist in HTML (search for "crlcFormModal")
4. Reload page to reset JavaScript state
5. Clear browser cache (Ctrl+Shift+Delete)

### Issue: Student Verification Takes Too Long

**Symptoms**: Click "Verify" button, "Checking..." spins for > 5 seconds

**Solutions**:
1. Check network tab in developer tools (F12)
2. Verify internet connection
3. Try again - temporary server load
4. Contact IT if consistently slow

### Issue: Create Button Disabled After First Use

**Symptoms**: Can create one registration, then button is always disabled

**Solutions**:
1. Close modal (X button or ESC key)
2. Click "New Registration" again to reset
3. Reload page if still stuck

### Issue: Delete Button Always Disabled

**Symptoms**: Delete button grayed out even for new registrations

**Solutions**:
1. **Expected**: If record has marks/grades, button is disabled by design
2. **Fix**: Edit registration status to mark as duplicate/pending, then delete
   OR contact records office to clear assessment data
3. Check column "Marks" and "Grade" - if not "-", button is disabled

### Issue: Edit Changes Don't Save

**Symptoms**: Change status, click Save, nothing happens/error message

**Solutions**:
1. Check error message for details
2. Verify status dropdown has value selected
3. Verify record ID exists (should auto-populate)
4. Try again - may be temporary server issue
5. Reload page and retry

### Issue: Ledger Table Not Showing Any Records

**Symptoms**: Page loads but no registrations visible

**Solutions**:
1. Check if filters are too restrictive
   - Click "Reset" to clear all filters
   - Then "Apply" to reload
2. Check "Total Records" count at top (may be 0)
3. Change "Rows" dropdown and apply (sometimes helps)
4. Navigate to different pages using pagination
5. Contact admin - may be access restriction

### Issue: Confirmation Dialog Got Stuck

**Symptoms**: Delete confirmation dialog remains displayed, can't close

**Solutions**:
1. Press ESC key
2. Click outside the dialogs
3. Reload page (F5)
4. Clear browser cache

### Issue: Form Shows Weird Characters

**Symptoms**: Student names or course names show strange symbols

**Solutions**:
1. Check browser character encoding (View → Character Encoding → UTF-8)
2. Reload page
3. Report to IT - may be database collation issue

---

## Support and Contact

**For Technical Issues**:
- Contact: IT Support / Database Administration
- Include: Error message, registration number, steps to reproduce
- Attach: Screenshot if error persists

**For Business Questions**:
- Contact: Records Office / Registrar
- Include: Registration details, specific issue
- Reference: This documentation for feature descriptions

**For Enhancement Requests**:
- Suggest: Bulk operations, export to Excel, API access
- Contact: Business Analyst / System Owner
- Priority: Based on impact and resources

---

## Change Log

| Date     | Version | Changes |
|----------|---------|---------|
| Apr 2026 | 2.0     | Added edit functionality, complete documentation |
| Apr 2026 | 1.5     | Added delete with data protection |
| Apr 2026 | 1.0     | Initial release with create form |

---

## Appendix A: Database Maintenance

### Recommended Indexes
```sql
CREATE INDEX idx_acad_cr_regno ON acad_course_registration(regno);
CREATE INDEX idx_acad_cr_courseid ON acad_course_registration(courseid);
CREATE INDEX idx_acad_cr_acad_year ON acad_course_registration(acad_year);
CREATE INDEX idx_acad_cr_semester ON acad_course_registration(semester);
CREATE INDEX idx_acad_results_comp ON acad_results(regno, courseid, acad, semester);
```

### Regular Maintenance Tasks
- **Weekly**: Backup database
- **Monthly**: Review slow query logs
- **Quarterly**: Archive old registrations (>5 years)
- **Annually**: Update lookup tables (programmes, courses)

---

## Appendix B: Configuration Reference

### web.config Settings
```xml
<configuration>
  <connectionStrings>
    <add name="vacConnectionString" 
         connectionString="Server=localhost;Database=campus_dynamics_portal;..." 
         providerName="MySql.Data.MySqlClient" />
  </connectionStrings>
  
  <!-- Page timeout and validation settings -->
  <system.web>
    <httpRuntime executionTimeout="300" />
    <sessionState timeout="20" />
  </system.web>
</configuration>
```

### Application Settings
- **Session Timeout**: 20 minutes
- **Max Upload Size**: Not applicable
- **Page Load Timeout**: 300 seconds
- **AJAX Request Timeout**: 30 seconds (JavaScript)

---

**End of Document**
