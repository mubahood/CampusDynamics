# AllMarksController Course Registration Enhancement

**Date:** 2026-07-07  
**Status:** Planning  
**Priority:** High  
**Scope:** Add delete and create course registration capabilities to AllMarksController.aspx for admins

---

## Executive Summary

Enhance the AllMarksController.aspx admin page with two new course registration management features:

1. **Delete Student Course Registration** — Remove a student from a course (with audit logging)
2. **Create/Register Student to Course** — Register a new student to a course for a specific semester (mirroring the portal's StudentCourseRegistrationController API)

Both features will use the exact same API approach as the student portal and will be fully logged for accountability.

---

## Current State Analysis

### AllMarksController.aspx (COOPERP)

**Purpose:** Admin marks management dashboard for all students across all statuses

**Current Capabilities:**
- View all student marks records with filters (year, semester, status, programme, lecturer)
- Bulk actions: approve, reject, publish marks
- Single record actions: 
  - View details
  - Review marks (approve/reject)
  - Publish to final results
  - Edit marks (admin override)
  - Reset to pending
  - Set status (pending/approved/rejected/published)
- Batch workflow wizard for mass approval/publishing

**Data Displayed per Record:**
- Reg No, Student Name, Course Code, Programme, Academic Year, Semester  
- Course Work, Exam, Total marks
- Published marks, Grade, Status
- Action dropdown menu

**Technical Stack:**
- ASP.NET Web Forms (.NET 4.0)
- WebMethods for AJAX calls
- MySQL database (campus_dynamics) for marks
- MarksActionLogger for comprehensive action logging
- MarksAuthorizationService for role-based access control

---

## Feature 1: Delete Student Course Registration

### Overview

Allow admins to delete a student's course registration directly from the AllMarksController table, with full audit logging.

### Use Cases

1. **Erroneous Registration:** Student registered to wrong course
2. **Drop Request Approved:** Student requested to drop course; admin executes delete
3. **Administrative Correction:** Clerical error needs to be corrected

### Implementation Details

#### Database Tables Affected

- `acad_course_registration` (campus_dynamics_portal DB) — primary table
- `acad_results` (campus_dynamics DB) — may have exam results for this registration
- `acad_marks` (campus_dynamics_portal DB or campus_dynamics) — marks entry for this course
- Both databases will be queried to ensure safe deletion

#### API Endpoint

**Location:** `AllMarksController.aspx.cs` (new WebMethod)

```csharp
[WebMethod(EnableSession = true)]
public static string DeleteCourseRegistration(int courseRegistrationId, string reason)
```

**Parameters:**
- `courseRegistrationId` (int) — the unique ID of the course registration record
- `reason` (string) — admin's reason for deletion (min 10 chars, required)

**Returns:**
```json
{
  "success": true/false,
  "message": "Human-readable status message",
  "deleted_registration": {
    "id": 123,
    "regno": "MRU2024001638",
    "course_id": "CS101",
    "acad_year": "2024/2025",
    "semester": 1,
    "programme_code": "BSC-IT"
  },
  "affected_marks_count": 0,
  "deleted_at": "2026-07-07T14:23:45Z"
}
```

**Validation Logic:**
1. Course registration ID exists and belongs to `acad_course_registration` table
2. Reason is provided and minimum 10 characters
3. Admin has scope to delete (based on programme/faculty)
4. Course registration is not already marked as deleted
5. If marks exist in `acad_results`, confirm deletion will cascade

**Deletion Logic:**
1. **Soft Delete Approach (Recommended):**
   - Add `is_deleted TINYINT(1) DEFAULT 0` column to `acad_course_registration`
   - Set `is_deleted = 1`, `deleted_by = {admin_username}`, `deleted_at = NOW()`, `deletion_reason = {reason}`
   - Queries exclude soft-deleted records via WHERE clause

2. **Alternative Hard Delete:**
   - If hard delete required, wrap in transaction with proper cleanup of:
     - `acad_marks` rows for this registration
     - `acad_results` rows for this registration
     - Any provisional marks in `acad_provisional_marks`

**Recommended:** Soft delete for auditability and reversibility.

**Logging:**
- Log to `acad_marks_action_log`:
  - `action` = `"delete_course_registration"`
  - `context` = course ID, student regno, acad year, semester, reason
  - `outcome` = `success` or `error`
  - `actor` = admin username
  - `duration_ms` = execution time

#### UI Components (AllMarksController.aspx)

**New Modal:** `modalDeleteCourseReg`

```html
<div id="modalDeleteCourseReg" class="pm-modal" style="max-width:480px;">
  <div class="pm-modal__head">
    <span class="pm-modal__title">Delete Course Registration</span>
    <button class="pm-modal__close" onclick="closeModal('modalDeleteCourseReg')">&times;</button>
  </div>
  <div class="pm-modal__body">
    <div id="delRegInfo" style="font-size:11px;background:#fff3cd;border:1px solid #ffc107;border-radius:4px;padding:8px 10px;margin-bottom:12px;color:#856404;">
      ⚠️ This will remove the student's enrollment in this course.
      <strong>This action cannot be easily undone.</strong>
    </div>
    <div id="delRegDetails" class="pm-dl" style="display:grid;margin-bottom:12px;"></div>
    <div class="pm-fg" style="margin-bottom:0;">
      <label style="font-size:9px;text-transform:uppercase;letter-spacing:.4px;color:#64748b;font-weight:800;margin-bottom:6px;display:block;">
        Reason for Deletion <span style="color:#b42318;">*required (min 10 chars)</span>
      </label>
      <textarea class="pm-comment-area" id="delRegReason" placeholder="e.g., Student requested drop, Registered to wrong course, etc." style="min-height:60px;"></textarea>
    </div>
    <div class="pm-alert" id="delRegAlert"></div>
  </div>
  <div class="pm-modal__foot">
    <button type="button" class="pm-btn pm-btn--ghost" onclick="closeModal('modalDeleteCourseReg')">Cancel</button>
    <button type="button" class="pm-btn pm-btn--danger" id="btnDelRegConfirm" onclick="submitDeleteCourseReg()">Delete Registration</button>
  </div>
</div>
```

**New Row Action Menu Item:**
- Add to the dropdown menu in each table row:
  - "Delete Course Registration..." (danger/red styling)

**JavaScript Handler:**
```javascript
window.openDeleteCourseReg = function(courseRegId, regno, courseId, acadYear, semester) {
  _id = courseRegId; // store for later submission
  clearAlert('delRegAlert');
  qs('delRegReason').value = '';
  qs('delRegDetails').innerHTML = 
    dlRow('Student', regno) +
    dlRow('Course', courseId) +
    dlRow('Year / Semester', acadYear + ' · Sem ' + semester);
  openModal('modalDeleteCourseReg');
};

window.submitDeleteCourseReg = function() {
  if (!_id) return;
  var reason = qs('delRegReason').value.trim();
  if (reason.length < 10) {
    showAlert('delRegAlert', 'Reason must be at least 10 characters.', 'err');
    return;
  }
  if (!confirm('Are you absolutely sure? This will remove the student from this course.')) return;
  
  clearAlert('delRegAlert');
  qs('btnDelRegConfirm').disabled = true;
  callAJAX('DeleteCourseRegistration', {courseRegistrationId: _id, reason: reason}, function(d) {
    qs('btnDelRegConfirm').disabled = false;
    if (d.success) {
      showToast('Course registration deleted.', 'ok');
      window.closeModal('modalDeleteCourseReg');
      setTimeout(function() { location.reload(); }, 800);
    } else {
      showAlert('delRegAlert', d.message || 'Deletion failed.', 'err');
    }
  });
};
```

---

## Feature 2: Create/Register Student to Course

### Overview

Allow admins to register a student to a course for a specific semester, using the same API and business logic as StudentCourseRegistrationController in the portal.

### Use Cases

1. **Late Registration:** Student misses registration window; admin registers manually
2. **Correction:** Student dropped course mistakenly; admin re-registers
3. **Prerequisite:** Student completes prerequisite late; admin registers for current course

### Implementation Details

#### Database Tables Affected

- `acad_course_registration` (campus_dynamics_portal DB) — INSERT new row
- `acad_student` — validate student and get context
- `acad_registration` — validate semester registration exists
- `acad_programme_courses` — validate course is in curriculum
- `acad_course` — validate course details

#### API Endpoint

**Location:** `AllMarksController.aspx.cs` (new WebMethod)

```csharp
[WebMethod(EnableSession = true)]
public static string RegisterStudentToCourse(string regno, string courseId, string acadYear, int semester, string reason)
```

**Parameters:**
- `regno` (string) — student registration number
- `courseId` (string) — course code/ID
- `acadYear` (string) — academic year (e.g., "2024/2025")
- `semester` (int) — 1, 2, or 3
- `reason` (string) — admin's reason (min 10 chars, required)

**Returns:**
```json
{
  "success": true/false,
  "message": "Human-readable status message",
  "new_registration": {
    "id": 456,
    "regno": "MRU2024001638",
    "course_id": "CS101",
    "course_name": "Introduction to Computer Science",
    "acad_year": "2024/2025",
    "semester": 1,
    "programme_code": "BSC-IT",
    "programme_name": "Bachelor of Science in Information Technology",
    "registered_at": "2026-07-07T14:23:45Z",
    "registered_by": "admin_username"
  }
}
```

**Validation Logic (Reuse from StudentCourseRegistrationController):**

1. **Student Validation:**
   - Student exists in `acad_student` table
   - Student is active (status = 'ACTIVE' or appropriate)
   - Student is not already deleted

2. **Context Validation:**
   - Semester registration exists for student in given acad_year/semester
   - Student's programme matches the course's programme

3. **Course Validation:**
   - Course exists in `acad_course`
   - Course is in student's programme curriculum (`acad_programme_courses`)
   - Course is not already registered by this student

4. **Registration Status:**
   - Cannot register if student has dropped the semester
   - Cannot register if student is on academic suspension

5. **Curriculum Check:**
   - Course must match student's year of study (if applicable)
   - Course prerequisites met (if applicable, use portal logic)

**Registration Logic:**
1. Create new row in `acad_course_registration`:
   - `regno` = {student}
   - `courseID` = {courseId}
   - `acad_year` = {acadYear}
   - `semester` = {semester}
   - `registered_date` = NOW()
   - `registered_by` = {admin_username}
   - `registration_reason` = {reason} (new column or metadata)
   - `provisional_course_work_marks` = NULL (no marks yet)
   - `provisional_exam_marks` = NULL
   - `provisional_total_marks` = NULL

2. Ensure `acad_course_registration` has columns:
   - `registered_by` (VARCHAR(50)) — who registered (admin vs. student)
   - `registration_reason` (TEXT) — why admin registered
   - `registration_source` (VARCHAR(20)) — 'ADMIN', 'STUDENT', 'SYSTEM'

**Logging:**
- Log to `acad_marks_action_log`:
  - `action` = `"admin_register_student_to_course"`
  - `context` = student regno, course ID, acad year, semester, reason
  - `outcome` = `success` or `error`
  - `actor` = admin username
  - `duration_ms` = execution time

#### UI Components (AllMarksController.aspx)

**New Button in Top Controls:**
```html
<button type="button" class="pm-btn pm-btn--primary" onclick="openRegisterStudent()" style="float:right;">
  ➕ Register Student to Course
</button>
```

**New Modal:** `modalRegisterStudent`

```html
<div id="modalRegisterStudent" class="pm-modal pm-modal--wide">
  <div class="pm-modal__head">
    <span class="pm-modal__title">Register Student to Course</span>
    <button class="pm-modal__close" onclick="closeModal('modalRegisterStudent')">&times;</button>
  </div>
  <div class="pm-modal__body">
    <div class="pm-wiz-steps">
      <span class="pm-wiz-step" id="regStep1">1. Select Student</span>
      <span class="pm-wiz-step" id="regStep2">2. Select Course</span>
      <span class="pm-wiz-step" id="regStep3">3. Review & Register</span>
    </div>

    <!-- Step 1: Select Student -->
    <div id="regPanel1" class="pm-wiz-panel">
      <div class="pm-fg" style="margin-bottom:12px;">
        <label>Find Student by Reg No or Name</label>
        <input type="text" class="pm-input" id="regSearch" placeholder="Enter reg no or name (min 3 chars)" onkeyup="searchStudents(this.value)" />
      </div>
      <div id="regSearchResults" style="max-height:200px;overflow-y:auto;border:1px solid #e0e5ed;border-radius:6px;display:none;">
        <div id="regResultsList"></div>
      </div>
      <div id="regSelectedStudent" style="display:none;padding:8px 10px;background:#f0fdf4;border:1px solid #bbf7d0;border-radius:6px;margin-top:8px;font-size:11px;color:#15803d;"></div>
      <div class="pm-alert" id="regAlert1"></div>
    </div>

    <!-- Step 2: Select Course -->
    <div id="regPanel2" class="pm-wiz-panel">
      <div style="display:grid;grid-template-columns:1fr 1fr;gap:8px;margin-bottom:12px;">
        <div class="pm-fg">
          <label>Academic Year</label>
          <select class="pm-select" id="regAcadYear" onchange="loadCoursesForStudent()">
            <option value="">— Select Year —</option>
          </select>
        </div>
        <div class="pm-fg">
          <label>Semester</label>
          <select class="pm-select" id="regSemester" onchange="loadCoursesForStudent()">
            <option value="">— Select Semester —</option>
            <option value="1">Sem 1</option>
            <option value="2">Sem 2</option>
            <option value="3">Sem 3</option>
          </select>
        </div>
      </div>
      <div class="pm-fg" style="margin-bottom:10px;">
        <label>Available Courses (not yet registered)</label>
        <select class="pm-select" id="regCourseSelect" onchange="onCourseSelected(this)" style="height:120px;min-height:120px;">
          <option value="">Loading courses…</option>
        </select>
      </div>
      <div id="regCourseInfo" style="display:none;padding:8px 10px;background:#eef2ff;border:1px solid #c5d5f5;border-radius:6px;margin-bottom:8px;font-size:11px;color:#174DA4;"></div>
      <div class="pm-alert" id="regAlert2"></div>
    </div>

    <!-- Step 3: Review & Register -->
    <div id="regPanel3" class="pm-wiz-panel">
      <div id="regReviewDetails" class="pm-dl" style="display:grid;margin-bottom:12px;"></div>
      <div class="pm-fg" style="margin-bottom:0;">
        <label style="font-size:9px;text-transform:uppercase;letter-spacing:.4px;color:#64748b;font-weight:800;margin-bottom:6px;display:block;">
          Reason for Registration <span style="color:#b42318;">*required (min 10 chars)</span>
        </label>
        <textarea class="pm-comment-area" id="regReason" placeholder="e.g., Late admission, Prerequisite completion, Administrative correction, etc." style="min-height:60px;"></textarea>
      </div>
      <div class="pm-alert" id="regAlert3"></div>
    </div>
  </div>
  <div class="pm-modal__foot">
    <button type="button" class="pm-btn pm-btn--ghost" id="regBackBtn" onclick="regWizardBack()" style="display:none;">Back</button>
    <button type="button" class="pm-btn pm-btn--primary" id="regNextBtn" onclick="regWizardNext()">Next</button>
    <button type="button" class="pm-btn pm-btn--success" id="regSubmitBtn" onclick="submitRegisterStudent()" style="display:none;">Register Student</button>
    <button type="button" class="pm-btn pm-btn--ghost" onclick="closeModal('modalRegisterStudent')">Cancel</button>
  </div>
</div>
```

**JavaScript Handler (Simplified Structure):**
```javascript
var _regWizStep = 1;
var _regStudent = null;
var _regCourse = null;

window.openRegisterStudent = function() {
  _regWizStep = 1;
  _regStudent = null;
  _regCourse = null;
  qs('regSearch').value = '';
  qs('regSearchResults').style.display = 'none';
  qs('regSelectedStudent').style.display = 'none';
  clearAlert('regAlert1');
  setRegWizStep(1);
  openModal('modalRegisterStudent');
};

function setRegWizStep(step) {
  _regWizStep = step;
  ['regPanel1', 'regPanel2', 'regPanel3'].forEach(function(id, i) {
    var el = qs(id);
    if (el) el.className = 'pm-wiz-panel' + (i + 1 === step ? ' active' : '');
  });
  qs('regBackBtn').style.display = step === 1 ? 'none' : 'inline-flex';
  qs('regNextBtn').style.display = step === 3 ? 'none' : 'inline-flex';
  qs('regSubmitBtn').style.display = step === 3 ? 'inline-flex' : 'none';
}

window.searchStudents = function(query) {
  if (query.length < 3) {
    qs('regSearchResults').style.display = 'none';
    return;
  }
  // Call AJAX to search students
  callAJAX('SearchStudents', {query: query}, function(d) {
    if (d.success && d.students && d.students.length > 0) {
      var html = '';
      d.students.forEach(function(s) {
        html += '<div class="pm-row-menu__item" onclick="selectStudent(' + JSON.stringify(s) + ')">' +
          '<strong>' + s.regno + '</strong> — ' + s.name + '</div>';
      });
      qs('regResultsList').innerHTML = html;
      qs('regSearchResults').style.display = 'block';
    } else {
      qs('regSearchResults').style.display = 'none';
    }
  });
};

window.selectStudent = function(student) {
  _regStudent = student;
  qs('regSelectedStudent').innerHTML = '<strong>' + student.regno + '</strong> — ' + student.name + ' (' + student.prog_id + ')';
  qs('regSelectedStudent').style.display = 'block';
  qs('regSearchResults').style.display = 'none';
};

window.regWizardNext = function() {
  if (_regWizStep === 1) {
    if (!_regStudent) {
      showAlert('regAlert1', 'Please select a student.', 'err');
      return;
    }
    // Load academic years for this student
    callAJAX('GetStudentAcademicYears', {regno: _regStudent.regno}, function(d) {
      if (d.success) {
        var html = '<option value="">— Select Year —</option>';
        d.years.forEach(function(y) {
          html += '<option value="' + y + '">' + y + '</option>';
        });
        qs('regAcadYear').innerHTML = html;
      }
    });
    setRegWizStep(2);
  } else if (_regWizStep === 2) {
    if (!_regCourse) {
      showAlert('regAlert2', 'Please select a course.', 'err');
      return;
    }
    // Load review details
    qs('regReviewDetails').innerHTML = 
      dlRow('Student', _regStudent.regno + ' — ' + _regStudent.name) +
      dlRow('Course', _regCourse.courseID + ' — ' + _regCourse.courseName) +
      dlRow('Year / Semester', qs('regAcadYear').value + ' · Sem ' + qs('regSemester').value) +
      dlRow('Programme', _regStudent.prog_id);
    setRegWizStep(3);
  }
};

window.regWizardBack = function() {
  if (_regWizStep > 1) setRegWizStep(_regWizStep - 1);
};

window.submitRegisterStudent = function() {
  if (!_regStudent || !_regCourse) return;
  var reason = qs('regReason').value.trim();
  if (reason.length < 10) {
    showAlert('regAlert3', 'Reason must be at least 10 characters.', 'err');
    return;
  }
  
  clearAlert('regAlert3');
  qs('regSubmitBtn').disabled = true;
  callAJAX('RegisterStudentToCourse', {
    regno: _regStudent.regno,
    courseId: _regCourse.courseID,
    acadYear: qs('regAcadYear').value,
    semester: parseInt(qs('regSemester').value, 10),
    reason: reason
  }, function(d) {
    qs('regSubmitBtn').disabled = false;
    if (d.success) {
      showToast('Student registered to course.', 'ok');
      window.closeModal('modalRegisterStudent');
      setTimeout(function() { location.reload(); }, 800);
    } else {
      showAlert('regAlert3', d.message || 'Registration failed.', 'err');
    }
  });
};
```

**New WebMethods in AllMarksController.aspx.cs:**
```csharp
[WebMethod(EnableSession = true)]
public static string SearchStudents(string query)

[WebMethod(EnableSession = true)]
public static string GetStudentAcademicYears(string regno)

[WebMethod(EnableSession = true)]
public static string GetAvailableCoursesForStudent(string regno, string acadYear, int semester)

[WebMethod(EnableSession = true)]
public static string RegisterStudentToCourse(string regno, string courseId, string acadYear, int semester, string reason)
```

---

## Database Schema Changes Required

### `acad_course_registration` Table (if columns don't exist)

```sql
ALTER TABLE acad_course_registration ADD COLUMN (
  registered_by VARCHAR(50) COMMENT 'Username of person who registered (ADMIN/STUDENT)',
  registration_reason TEXT COMMENT 'Why this registration was created (for admin registrations)',
  registration_source VARCHAR(20) DEFAULT 'STUDENT' COMMENT 'STUDENT, ADMIN, SYSTEM',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
```

### `acad_course_registration` Soft Delete (Recommended)

```sql
ALTER TABLE acad_course_registration ADD COLUMN (
  is_deleted TINYINT(1) DEFAULT 0 COMMENT 'Soft delete flag',
  deleted_by VARCHAR(50) COMMENT 'Admin who deleted',
  deleted_at TIMESTAMP NULL COMMENT 'When deleted',
  deletion_reason TEXT COMMENT 'Why deleted'
);

CREATE INDEX idx_deleted ON acad_course_registration(is_deleted);
```

### Migration Script

Create: `database/migrations/20260707_0001__acad_course_registration_admin_fields.up.sql`

```sql
-- Add admin course registration fields to acad_course_registration
ALTER TABLE campus_dynamics_portal.acad_course_registration ADD COLUMN (
  registered_by VARCHAR(50) NULL COMMENT 'Username who registered (ADMIN/STUDENT)',
  registration_reason TEXT NULL COMMENT 'Reason for admin registration',
  registration_source VARCHAR(20) DEFAULT 'STUDENT' COMMENT 'STUDENT, ADMIN, SYSTEM',
  is_deleted TINYINT(1) DEFAULT 0 COMMENT 'Soft delete flag for admin deletions',
  deleted_by VARCHAR(50) NULL COMMENT 'Admin who soft-deleted',
  deleted_at TIMESTAMP NULL COMMENT 'When soft-deleted',
  deletion_reason TEXT NULL COMMENT 'Why soft-deleted'
);

CREATE INDEX idx_acr_deleted ON campus_dynamics_portal.acad_course_registration(is_deleted);
CREATE INDEX idx_acr_registered_by ON campus_dynamics_portal.acad_course_registration(registered_by);
```

Drop Script: `database/migrations/20260707_0001__acad_course_registration_admin_fields.down.sql`

```sql
ALTER TABLE campus_dynamics_portal.acad_course_registration DROP COLUMN (
  registered_by,
  registration_reason,
  registration_source,
  is_deleted,
  deleted_by,
  deleted_at,
  deletion_reason
);

DROP INDEX idx_acr_deleted ON campus_dynamics_portal.acad_course_registration;
DROP INDEX idx_acr_registered_by ON campus_dynamics_portal.acad_course_registration;
```

---

## Logging Strategy

### Action Logging (acad_marks_action_log)

All actions logged with:
- `page` = "AllMarksController"
- `actor` = admin username (extracted from session)
- `action` = specific action name
- `context` = relevant field details (JSON serialized)
- `outcome` = "SUCCESS", "VALIDATION_ERROR", "ERROR"
- `duration_ms` = execution time
- `timestamp` = NOW()

### Actions to Log

| Action | Context | Outcome |
|--------|---------|---------|
| `delete_course_registration` | {courseRegId, regno, courseId, acadYear, semester, reason} | success / error |
| `register_student_to_course` | {regno, courseId, acadYear, semester, reason} | success / validation_error / error |
| `search_students` | {query} | success / error |
| `get_student_academic_years` | {regno} | success / error |
| `get_available_courses` | {regno, acadYear, semester} | success / error |

**Implementation Pattern (in AllMarksController.aspx.cs):**

```csharp
private static string LogAction(string action, Dictionary<string, object> context, Func<string> operation)
{
    System.Diagnostics.Stopwatch sw = MarksActionLogger.StartTimer();
    string outcome = MarksActionLogger.OUTCOME_SUCCESS;
    
    try
    {
        string result = operation();
        // Check success in result JSON
        outcome = OutcomeOf(result);
        return result;
    }
    catch (Exception ex)
    {
        outcome = MarksActionLogger.OUTCOME_ERROR;
        if (context == null) context = new Dictionary<string, object>();
        context["error"] = ex.Message;
        throw;
    }
    finally
    {
        try { context["actor"] = MarksAuthorizationService.GetCurrentUser(); } 
        catch { }
        MarksActionLogger.StopAndLog(sw, "AllMarksController", action, outcome, context, null);
    }
}
```

---

## Implementation Checklist

### Phase 1: Database & Core Logic (Week 1)

- [ ] 1.1 Create and apply migration for new `acad_course_registration` columns
- [ ] 1.2 Verify soft delete columns exist and indexed
- [ ] 1.3 Create deletion business logic helper class
- [ ] 1.4 Create registration business logic helper class (reference StudentCourseRegistrationController)
- [ ] 1.5 Test migration on staging database

### Phase 2: API Endpoints (Week 2)

- [ ] 2.1 Implement `DeleteCourseRegistration` WebMethod
  - [ ] 2.1a Input validation
  - [ ] 2.1b Authorization check (admin scope)
  - [ ] 2.1c Soft delete logic
  - [ ] 2.1d Logging
  - [ ] 2.1e Response JSON

- [ ] 2.2 Implement `RegisterStudentToCourse` WebMethod
  - [ ] 2.2a Input validation (student, course, semester)
  - [ ] 2.2b Authorization check
  - [ ] 2.2c Curriculum validation
  - [ ] 2.2d Insert into `acad_course_registration`
  - [ ] 2.2e Logging
  - [ ] 2.2f Response JSON

- [ ] 2.3 Implement helper WebMethods
  - [ ] 2.3a `SearchStudents` (by regno/name)
  - [ ] 2.3b `GetStudentAcademicYears`
  - [ ] 2.3c `GetAvailableCoursesForStudent`

- [ ] 2.4 Unit tests for each endpoint
- [ ] 2.5 Integration tests with sample data

### Phase 3: UI Enhancements (Week 3)

- [ ] 3.1 Add delete modal HTML to AllMarksController.aspx
- [ ] 3.2 Add register student modal HTML to AllMarksController.aspx
- [ ] 3.3 Add CSS styling for new modals
- [ ] 3.4 Implement delete course registration JavaScript
- [ ] 3.5 Implement student registration wizard JavaScript
- [ ] 3.6 Add new action menu items to existing table rows
- [ ] 3.7 Add "Register Student" button to top controls
- [ ] 3.8 Browser compatibility testing

### Phase 4: Testing & Documentation (Week 4)

- [ ] 4.1 Functional testing (happy path, error cases)
- [ ] 4.2 Permissions testing (ensure only admins can execute)
- [ ] 4.3 Logging verification (confirm all actions logged)
- [ ] 4.4 Performance testing (large student/course lists)
- [ ] 4.5 Create user documentation
- [ ] 4.6 Create admin guide for new features
- [ ] 4.7 UAT with stakeholders

### Phase 5: Deployment

- [ ] 5.1 Backup production database
- [ ] 5.2 Apply migration to production
- [ ] 5.3 Deploy updated AllMarksController.aspx + .aspx.cs
- [ ] 5.4 Smoke testing in production
- [ ] 5.5 Monitor logs for errors

---

## Error Handling & Validation

### Delete Course Registration Errors

| Error | Message | HTTP Status |
|-------|---------|-------------|
| Invalid course reg ID | "Course registration not found." | 404 |
| Insufficient reason | "Reason must be at least 10 characters." | 400 |
| Already deleted | "This registration is already deleted." | 409 |
| Insufficient permissions | "You do not have permission to delete this registration." | 403 |
| Database error | "Failed to delete registration: {error}" | 500 |

### Register Student Errors

| Error | Message | HTTP Status |
|-------|---------|-------------|
| Student not found | "Student with reg no {regno} not found." | 404 |
| Student inactive | "Student account is inactive." | 403 |
| Course not found | "Course {courseId} not found." | 404 |
| Not in curriculum | "Course is not in student's programme curriculum." | 400 |
| Already registered | "Student is already registered for this course." | 409 |
| No semester registration | "Student has no registration for {acadYear} Sem {semester}." | 403 |
| Insufficient reason | "Reason must be at least 10 characters." | 400 |
| Insufficient permissions | "You do not have permission to register students." | 403 |
| Database error | "Failed to register student: {error}" | 500 |

---

## Security Considerations

1. **Authorization:** Only staff users (admin role) can execute these features
2. **Scope Limits:** Admins limited to their scope (faculty/programme)
3. **Input Validation:** All string inputs sanitized and validated before DB operations
4. **Audit Trail:** Every action logged immutably for compliance
5. **Transaction Safety:** All DB operations wrapped in transactions
6. **SQL Injection Prevention:** Parameterized queries used throughout
7. **CSRF Protection:** Leverage existing ASP.NET CSRF tokens on WebMethods

---

## Performance Considerations

- Index on `acad_course_registration(is_deleted, regno, courseID)`
- Pagination for large student/course search results (50 records per load)
- AJAX calls use compression where applicable
- Batch operations for multiple registrations (future enhancement)

---

## Success Criteria

1. ✅ Delete course registration successfully soft-deletes records
2. ✅ All delete actions logged with actor, timestamp, reason
3. ✅ Register student creates new course registration
4. ✅ All register actions logged with full context
5. ✅ UI modals intuitive and responsive
6. ✅ Error messages clear and actionable
7. ✅ No unauthorized access possible
8. ✅ Performance acceptable with large datasets
9. ✅ UAT signoff from registrar/dean

---

## Appendix: Reference Implementation (StudentCourseRegistrationController)

**Key Methods to Mirror:**
- `GetCurrentContext()` — loads student's academic context
- `RegisterCourses()` — inserts new registrations
- `DropCourses()` — deletes existing registrations
- Validation methods: `IsCourseInCurriculum()`, `IsAlreadyRegistered()`

**Database Queries to Adapt:**
```sql
-- Get available courses for student
SELECT c.courseID, c.courseName, c.credit_hours
FROM acad_programme_courses pc
INNER JOIN acad_course c ON c.courseID = pc.courseID
WHERE pc.progid = @progid
AND c.acad_year = @acad_year
AND c.semester = @semester
AND NOT EXISTS (
  SELECT 1 FROM acad_course_registration cr
  WHERE cr.regno = @regno AND cr.courseID = c.courseID
  AND cr.acad_year = @acad_year AND cr.semester = @semester
)

-- Check if already registered
SELECT 1 FROM acad_course_registration
WHERE regno = @regno AND courseID = @courseId
AND acad_year = @acadYear AND semester = @semester
AND is_deleted = 0

-- Insert new registration
INSERT INTO acad_course_registration
  (regno, courseID, acad_year, semester, registered_by, registration_source, registration_reason)
VALUES (@regno, @courseId, @acadYear, @semester, @adminUser, 'ADMIN', @reason)
```

---

## Conclusion

This enhancement transforms AllMarksController from a marks-only tool into a comprehensive course registration management platform for admins. By mirroring the portal's StudentCourseRegistrationController API design, we ensure consistency, reliability, and extensive logging for all administrative actions.

**Implementation Timeline:** 4 weeks  
**Estimated Effort:** 160 hours  
**Risk Level:** Medium (modifies core registration data, requires careful testing)
