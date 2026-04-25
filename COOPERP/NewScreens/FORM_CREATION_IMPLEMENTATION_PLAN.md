# Course Registration Form Creation System - Architecture & Implementation Plan

**Date:** April 16, 2026  
**Scope:** Create new course registration records with intelligent auto-fill + Actions column for edit/delete  
**Status:** IN PROGRESS

---

## 📋 Executive Summary

We will implement a **two-phase system:**

### **Phase 1: New Record Creation Form**
- **Minimal Input:** 4 required fields only
  1. Student Registration Number (with real-time validation)
  2. Course ID (dropdown with search)
  3. Academic Year (dropdown from cached data)
  4. Semester (numeric 1-3 selector)
- **Auto-fill:** Remaining fields populated after submission
  - Student Name ← from `acad_student` table
  - Programme Name ← from student's programme
  - Course Name ← from `acad_course` table
  - Registration Status ← default to "REGULAR"

### **Phase 2: Ledger Actions Column**
- **Edit Button:** Allows editing non-computed fields
- **Delete Button:** Disabled/hidden if record has marks or grades
- **Confirmation:** Modal confirmation before deletion
- **Validation:** Prevents deletion of scored records

---

## 🏗️ Technical Architecture

### **Data Flow Diagram**

```
┌─────────────────────────────────────────────────────────────────┐
│ USER INTERFACE                                                  │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  [New Registration] Button ──→ Opens Form Modal                 │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │ FORM MODAL: Create New Course Registration              │  │
│  │                                                          │  │
│  │ Student Reg No:  [____________]  [Check...]  ↓Validate  │  │
│  │ Course:          [____________] [Course List...]        │  │
│  │ Academic Year:   [____________] [Dropdown...]           │  │
│  │ Semester:        [ 1 ][ 2 ][ 3 ]                        │  │
│  │                                                          │  │
│  │ [Create Record] [Cancel]                                │  │
│  └──────────────────────────────────────────────────────────┘  │
│                          ↓                                      │
│                    FORM SUBMITTED                              │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│ JAVASCRIPT LAYER (Client-Side Validation)                       │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│ 1. Check all 4 fields are filled                               │
│ 2. Validate registration number format                         │
│ 3. Show "Checking..." indicator                                │
│ 4. Submit via AJAX POST                                        │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌──────────────────────────────────────────────────────────────────────┐
│ ASP.NET BACKEND (WebMethods)                                         │
├──────────────────────────────────────────────────────────────────────┤
│                                                                      │
│ WebMethod: CreateCourseRegistration                                 │
│ ├─ STEP 1: Input Validation                                        │
│ │  └─ Check all parameters not null/empty                          │
│ │                                                                   │
│ ├─ STEP 2: Verify Student Exists                                   │
│ │  └─ Query: SELECT * FROM acad_student WHERE regno = @regno       │
│ │     If not found → Return error                                  │
│ │                                                                   │
│ ├─ STEP 3: Fetch Student Data                                      │
│ │  └─ Query: Get firstname, othername, progid, progname            │
│ │                                                                   │
│ ├─ STEP 4: Verify Course Exists                                    │
│ │  └─ Query: SELECT * FROM acad_course WHERE courseID = @courseID  │
│ │     If not found → Return error                                  │
│ │                                                                   │
│ ├─ STEP 5: Fetch Course Data                                       │
│ │  └─ Query: Get courseName                                        │
│ │                                                                   │
│ ├─ STEP 6: Check Duplicate Registration                            │
│ │  └─ Query: SELECT * FROM acad_course_registration                │
│ │     WHERE regno = @regno AND courseID = @courseID                │
│ │           AND acad_year = @acad_year AND semester = @semester    │
│ │     If exists → Return error (already registered)                │
│ │                                                                   │
│ ├─ STEP 7: Insert New Record                                       │
│ │  └─ INSERT INTO acad_course_registration                         │
│ │     (regno, courseID, prog_id, acad_year, semester,              │
│ │      course_status, created_date)                                │
│ │     VALUES (@values...)                                          │
│ │                                                                   │
│ ├─ STEP 8: Build Response with Auto-fill Data                      │
│ │  └─ Return JSON with:                                            │
│ │     - success: true                                              │
│ │     - student_name: "John Doe"                                   │
│ │     - programme_name: "BSc Computing"                            │
│ │     - course_name: "Intro to CS"                                 │
│ │                                                                   │
│ └─ STEP 9: Log Transaction (optional)                              │
│                                                                     │
└──────────────────────────────────────────────────────────────────────┘
                              ↓
┌──────────────────────────────────────────────────────────────────────┐
│ DATABASE (MySQL)                                                     │
├──────────────────────────────────────────────────────────────────────┤
│                                                                      │
│ Tables Involved:                                                    │
│ ├─ acad_course_registration (PRIMARY: Insert operation)            │
│ ├─ acad_student (LOOKUP: Validate + Fetch data)                    │
│ ├─ acad_programme (LOOKUP: Fetch programme name)                   │
│ ├─ acad_course (LOOKUP: Validate + Fetch name)                     │
│ └─ acad_results (LOOKUP: Check if record has marks/grades)         │
│                                                                      │
│ Query Pattern: Parameterized SQL with proper escaping              │
│                                                                      │
└──────────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│ RESPONSE HANDLING (JavaScript)                                  │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│ Success Response:                                              │
│ {                                                              │
│   "success": true,                                             │
│   "message": null,                                             │
│   "data": {                                                    │
│     "regno": "REG001234",                                      │
│     "student_name": "John Doe",                                │
│     "programme_name": "BSc Computing",                         │
│     "courseID": "CS101",                                       │
│     "course_name": "Intro to Computer Science",                │
│     "acad_year": "2024/2025",                                  │
│     "semester": "1",                                           │
│     "registration_id": 12345                                   │
│   }                                                            │
│ }                                                              │
│                                                                 │
│ Error Response:                                                │
│ {                                                              │
│   "success": false,                                            │
│   "message": "Student not found" / "Duplicate registration",   │
│   "data": null                                                 │
│ }                                                              │
│                                                                 │
│ ├─ Hide form                                                   │
│ ├─ Show success message                                        │
│ ├─ Refresh ledger table (auto-reload)                          │
│ ├─ Reset form for next entry (optional)                        │
│ └─ Close modal after 2 seconds                                 │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🎯 Implementation Strategy

### **Part 1: Form UI Components**

**Location:** `CourseRegistrationLedgerController.aspx`

**Components to Add:**
1. "New Registration" button above table
2. Modal form container (hidden by default)
3. Form fields with client-side validation
4. Real-time student validation
5. Success/error message display

### **Part 2: Form Validation & AJAX**

**Location:** `CourseRegistrationLedgerController.aspx` (script section)

**Functions to Create:**
- `openCreateFormModal()` – Show form
- `closeCreateFormModal()` – Hide form
- `validateStudentNumber()` – Real-time validation via AJAX
- `submitCreateForm()` – Submit form with validation
- `handleCreateFormResponse()` – Process server response
- `refreshLedgerTable()` – Reload table after successful creation

### **Part 3: Backend WebMethods**

**Location:** `CourseRegistrationLedgerController.aspx.cs`

**WebMethods to Create:**
1. `ValidateStudentExists(string regno)` – Check if student exists
   - Input: Registration number
   - Output: JSON with student name (if found)

2. `CreateCourseRegistration(string regno, string courseID, string acad_year, string semester)`
   - Input: 4 required fields
   - Process: Multi-step validation → Insert → Fetch auto-fill data
   - Output: JSON with all inserted data + auto-filled fields

3. `DeleteCourseRegistration(string registration_id)`
   - Input: Record ID
   - Validation: Check no marks/grades exist
   - Output: JSON success/error

4. `EditCourseRegistration(string registration_id, ...)`
   - Input: Record ID + editable fields
   - Validation: Prevent editing marks/grades
   - Output: JSON success/error

### **Part 4: Ledger Actions Column**

**Location:** `CourseRegistrationLedgerController.aspx` (table section)

**Changes:**
- Add 13th column: "Actions"
- Add Edit icon/button
- Add Delete icon/button (conditional disable)
- Add edit modal form
- Add confirmation dialog for deletion

---

## 📊 Database Requirements

### **Existing Tables Used:**

```
acad_course_registration
├── id (Primary Key, Auto-increment)
├── regno (FK → acad_student)
├── courseID (FK → acad_course)
├── prog_id (FK → acad_programme)
├── acad_year (String)
├── semester (Numeric 1-3)
├── course_status (Default: 'REGULAR')
├── created_date (Timestamp)
└── modified_date (Nullable)

acad_student
├── regno (Primary Key)
├── firstname (String)
├── othername (String)
├── progid (FK → acad_programme)
└── ... (other fields)

acad_programme
├── progcode (Primary Key)
├── progname (String)
└── ... (other fields)

acad_course
├── courseID (Primary Key)
├── courseName (String)
└── ... (other fields)

acad_results
├── id (Primary Key)
├── regno (FK)
├── courseid (FK)
├── acad (Academic Year)
├── semester (Numeric)
├── score (Numeric, Nullable)
├── grade (String, Nullable)
└── ... (other fields)
```

### **New Fields (if needed):**
- Possibly add `registration_id` or use existing `id` as primary key
- Or track `created_by` (admin who created record) for audit trail

---

## 🔒 Security Implementation

### **Server-Side (ASP.NET)**

1. **Input Validation:**
   - All parameters checked for null/empty
   - Type checking (semester must be 1-3)
   - String length limits

2. **Parameterized SQL:**
   - All user inputs use `@parameter` placeholders
   - No string concatenation in SQL

3. **Business Logic Validation:**
   - Student must exist in `acad_student`
   - Course must exist in `acad_course`
   - Prevent duplicate registrations
   - Prevent deletion if marks exist

4. **Error Handling:**
   - Never expose raw SQL errors
   - Log errors server-side for debugging
   - Return user-friendly messages

### **Client-Side (JavaScript)**

1. **Input Sanitization:**
   - Trim whitespace
   - Validate format (numbers only for semester)
   - Display format-specific error messages

2. **AJAX Security:**
   - Use `X-Requested-With` header
   - Validate response structure before using data
   - Handle errors gracefully

3. **User Feedback:**
   - Show validation errors in real-time
   - Prevent form submission if validation fails
   - Clear confirmation before deletion

---

## ✅ Implementation Checklist

- [ ] Create form modal HTML
- [ ] Style form with existing design system
- [ ] Implement form validation JavaScript
- [ ] Create `ValidateStudentExists` WebMethod
- [ ] Create `CreateCourseRegistration` WebMethod
- [ ] Create `DeleteCourseRegistration` WebMethod
- [ ] Create `EditCourseRegistration` WebMethod
- [ ] Add edit functionality (modal form)
- [ ] Add delete functionality (confirmation modal)
- [ ] Add Actions column to ledger table
- [ ] Test all form validations
- [ ] Test edge cases (duplicate, missing student, etc.)
- [ ] Test delete prevention (records with marks)
- [ ] Create comprehensive documentation
- [ ] Validate security measures
- [ ] Performance test with large datasets

---

## 🎨 UI/UX Design Specs

### **Color & Typography** (Consistent with existing system)
- Primary: Navy #05275C
- Buttons: Border #cdd3de, hover #174DA4
- Success: Green (if new)
- Error: Red #b42318
- Fonts: 11-12px base, uppercase labels

### **Form Modal Layout**
- Centered, responsive (90% mobile, 600px max desktop)
- Clear field labels (uppercase)
- Inline validation messages
- Disabled state for buttons during submission

### **Actions Column**
- Icons: Edit (✎), Delete (🗑)
- Delete disabled if record has marks/grades
- Tooltip explaining why delete is disabled

---

## 📈 Performance Considerations

1. **Database:**
   - Use indexed lookups on regno, courseID, acad_year
   - Batch inserts if creating multiple records

2. **AJAX:**
   - Prevent multiple form submissions (disable button)
   - Show loading indicator during AJAX call
   - Cache lookups where possible

3. **Frontend:**
   - Lazy-load form fields
   - Minimize re-rendering of ledger table

---

## 🧪 Testing Strategy

### **Unit Tests**
- Form validation logic
- Parameter escaping
- JSON response formatting

### **Integration Tests**
- AJAX request/response cycle
- Database insert/update/delete operations
- Duplicate detection

### **User Acceptance Tests**
- Create new registration (happy path)
- Try invalid student number (error handling)
- Try duplicate registration (error handling)
- Delete record without marks (success)
- Try delete record with marks (prevented)
- Edit registration (change status)
- Refresh table after operations

---

## 📝 Documentation to Create

1. **Form Architecture:**
   - Data flow diagrams
   - Field mapping
   - Validation rules

2. **API Reference:**
   - WebMethod signatures
   - Request/response examples
   - Error codes & messages

3. **Installation & Usage:**
   - How to enable new registration feature
   - How to use form
   - How to edit/delete records

4. **Security & Best Practices:**
   - Input sanitization
   - SQL injection prevention
   - Error handling

---

## 🚀 Deployment Checklist

- [ ] All WebMethods tested
- [ ] Form validation working
- [ ] Delete prevention working
- [ ] Ledger refresh working
- [ ] Error messages user-friendly
- [ ] Performance acceptable
- [ ] Security measures verified
- [ ] Documentation complete

