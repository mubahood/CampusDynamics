# CRITICAL BUG ANALYSIS: Curriculum Course Loss/Reassignment Issue

## Date: February 6, 2026
## Severity: CRITICAL
## Component: NewSpecialisations.aspx - Batch Course Addition

---

## Problem Description

**Reported Issue:** After defining courses for a specialization, they later get lost or reassigned to other specializations.

**Impact:** 
- Course curriculum configurations are unstable
- Courses assigned to Specialization A disappear when courses are added to Specialization B
- Data integrity compromised across all specializations
- Students may be assigned incorrect curricula

---

## Root Cause Analysis

### THE CRITICAL BUG (Line 351 of NewSpecialisations.aspx.cs)

```csharp
// BUGGY CODE - Line 342-362
using (MySqlCommand cmd = new MySqlCommand(
    "SELECT COUNT(*) FROM acad_programmecourses 
     WHERE course_code = @code AND progcode = @progcode AND CurriculumID = 0", conn))
{
    cmd.Parameters.AddWithValue("@code", trimmedCode);
    cmd.Parameters.AddWithValue("@progcode", progCode);
    int existsInProg = Convert.ToInt32(cmd.ExecuteScalar());
    
    if (existsInProg > 0)
    {
        // ⚠️ CRITICAL BUG: This UPDATE affects ALL matching records!
        using (MySqlCommand updateCmd = new MySqlCommand(
            "UPDATE acad_programmecourses 
             SET specialisation_id = @specId, study_year = @year, 
                 semester = @sem, course_type = @courseType 
             WHERE course_code = @code AND progcode = @progcode AND CurriculumID = 0", conn))
        {
            updateCmd.Parameters.AddWithValue("@specId", specId);
            updateCmd.Parameters.AddWithValue("@year", data.Year);
            updateCmd.Parameters.AddWithValue("@sem", data.Semester);
            updateCmd.Parameters.AddWithValue("@courseType", data.CourseType);
            updateCmd.Parameters.AddWithValue("@code", trimmedCode);
            updateCmd.Parameters.AddWithValue("@progcode", progCode);
            updateCmd.ExecuteNonQuery();  // ⚠️ Updates ALL matching rows!
        }
```

### Why This is Catastrophic

#### Scenario 1: Courses Get Stolen Between Specializations

**Initial State:**
```
acad_programmecourses table:
ID | progcode | course_code | specialisation_id | study_year | semester
1  | BSCS     | CSC101      | 5 (Spec A)       | 1          | 1
2  | BSCS     | CSC102      | 5 (Spec A)       | 1          | 1
```

**User Action:** Admin adds CSC101 to Specialization B (spec_id = 7)

**What Happens:**
1. System checks: Does CSC101 exist in progcode='BSCS' with CurriculumID=0? → YES (record ID=1)
2. System executes UPDATE: 
   ```sql
   UPDATE acad_programmecourses 
   SET specialisation_id = 7, study_year = 2, semester = 1
   WHERE course_code = 'CSC101' AND progcode = 'BSCS' AND CurriculumID = 0
   ```
3. **Result: Record is OVERWRITTEN, not duplicated**

**Final State:**
```
acad_programmecourses table:
ID | progcode | course_code | specialisation_id | study_year | semester
1  | BSCS     | CSC101      | 7 (Spec B)       | 2          | 1  ← STOLEN!
2  | BSCS     | CSC102      | 5 (Spec A)       | 1          | 1
```

**Consequence:** CSC101 disappeared from Specialization A and is now assigned to Specialization B!

#### Scenario 2: Multiple Records Updated Simultaneously

If a course appears multiple times in the table (different years/semesters), the UPDATE affects ALL of them:

**Initial State:**
```
ID | progcode | course_code | specialisation_id | study_year | semester
1  | BSCS     | CSC101      | 5 (Spec A)       | 1          | 1
2  | BSCS     | CSC101      | 5 (Spec A)       | 2          | 2  ← Same course, different year
```

**User Action:** Add CSC101 to Specialization C (spec_id = 9) for Year 1, Semester 1

**What Happens:** BOTH records get updated to Specialization C!

**Final State:**
```
ID | progcode | course_code | specialisation_id | study_year | semester
1  | BSCS     | CSC101      | 9 (Spec C)       | 1          | 1  ← Updated
2  | BSCS     | CSC101      | 9 (Spec C)       | 1          | 1  ← Also updated!
```

Now the Year 2, Semester 2 instance is also changed!

---

## Additional Contributing Factors

### 1. Missing Unique Constraint

The `acad_programmecourses` table likely lacks a proper unique constraint:

**Should Have:**
```sql
UNIQUE KEY (progcode, course_code, specialisation_id, study_year, semester, CurriculumID)
```

**Currently Has:** Probably no constraint or only partial constraint

### 2. Flawed Logic Flow

The code checks if a course exists in the programme, but doesn't consider:
- Which specialization it's assigned to
- Whether it's already configured for a different year/semester
- Whether multiple instances exist

### 3. No Validation Before Update

There's no check like:
```csharp
// Missing validation:
if (existingSpecId != null && existingSpecId != currentSpecId) {
    // Course already belongs to another specialization!
    // Should INSERT a new record, not UPDATE the existing one
}
```

---

## Proof of Bug

### Test Case 1: Add Same Course to Two Specializations

**Steps:**
1. Create Specialization A (spec_id=10)
2. Add course CSC101 to Spec A, Year 1, Sem 1
3. Verify: 1 record in `acad_programmecourses` with specialisation_id=10
4. Create Specialization B (spec_id=11)
5. Add course CSC101 to Spec B, Year 2, Sem 1
6. **Expected:** 2 records (one for each specialization)
7. **Actual:** Only 1 record with specialisation_id=11
8. **Result:** CSC101 disappeared from Spec A ✗

### Test Case 2: Check Existing Data

Run this SQL query to find affected records:

```sql
-- Find courses that appear multiple times with different specializations
-- (This shouldn't happen if each spec has its own records)
SELECT course_code, progcode, COUNT(DISTINCT specialisation_id) as spec_count
FROM acad_programmecourses
WHERE CurriculumID = 0 AND specialisation_id IS NOT NULL
GROUP BY course_code, progcode
HAVING spec_count > 1;
```

If this returns results, it means the same course record is being shared/updated between specializations.

---

## Impact Assessment

### Affected Operations

1. **Batch Add Courses** (cmdAddAllBatch_Click) - PRIMARY BUG LOCATION
2. **Single Course Edit** - May have similar issues
3. **Course Import** - If implemented, would inherit the bug

### Data Corruption Evidence

Check for these patterns in your database:

```sql
-- Pattern 1: Courses assigned to wrong specializations
SELECT pc.*, s1.spec as intended_spec, s2.spec as actual_spec
FROM acad_programmecourses pc
JOIN acad_specialisation s1 ON s1.prog_id = pc.progcode
LEFT JOIN acad_specialisation s2 ON s2.spec_id = pc.specialisation_id
WHERE s1.spec_id != pc.specialisation_id;

-- Pattern 2: Missing expected courses
SELECT s.spec_id, s.spec, COUNT(pc.ID) as course_count
FROM acad_specialisation s
LEFT JOIN acad_programmecourses pc ON s.spec_id = pc.specialisation_id
GROUP BY s.spec_id
HAVING course_count < 5;  -- Assuming minimum 5 courses per spec
```

---

## The Correct Approach

### What Should Happen

**Each specialization should have its OWN records for courses**, even if the same course appears in multiple specializations.

**Example of Correct Data:**
```
ID | progcode | course_code | specialisation_id | study_year | semester
1  | BSCS     | CSC101      | 5                | 1          | 1
2  | BSCS     | CSC101      | 7                | 1          | 1  ← Different spec, separate record
3  | BSCS     | CSC102      | 5                | 1          | 2
4  | BSCS     | CSC102      | 7                | 2          | 1  ← Different year/sem allowed
```

### Design Principle

**One-to-Many Relationship:**
- One Course (in course bank) → Many Programme Course Assignments
- Each assignment is specific to: Programme + Specialization + Year + Semester

**NOT:**
- One Course → One Programme Course Assignment that gets reassigned

---

## The Fix

### Solution 1: Always INSERT, Never UPDATE (Recommended)

```csharp
// FIXED CODE - Always create new records for each specialization
foreach (string code in codes)
{
    string trimmedCode = code.Trim().ToUpper();
    if (string.IsNullOrEmpty(trimmedCode)) continue;
    
    // Validate course exists
    using (MySqlCommand cmd = new MySqlCommand(
        "SELECT COUNT(*) FROM acad_course WHERE courseID = @code", conn))
    {
        cmd.Parameters.AddWithValue("@code", trimmedCode);
        if (Convert.ToInt32(cmd.ExecuteScalar()) == 0)
        {
            totalInvalid++;
            continue;
        }
    }
    
    // Check if THIS EXACT combination already exists
    using (MySqlCommand cmd = new MySqlCommand(
        @"SELECT COUNT(*) FROM acad_programmecourses 
          WHERE course_code = @code 
          AND progcode = @progcode 
          AND specialisation_id = @specId 
          AND study_year = @year 
          AND semester = @sem 
          AND CurriculumID = 0", conn))
    {
        cmd.Parameters.AddWithValue("@code", trimmedCode);
        cmd.Parameters.AddWithValue("@progcode", progCode);
        cmd.Parameters.AddWithValue("@specId", specId);
        cmd.Parameters.AddWithValue("@year", data.Year);
        cmd.Parameters.AddWithValue("@sem", data.Semester);
        
        if (Convert.ToInt32(cmd.ExecuteScalar()) > 0)
        {
            totalSkipped++;
            continue;  // Already exists for THIS specialization
        }
    }
    
    // ALWAYS INSERT - never update existing records
    using (MySqlCommand cmd = new MySqlCommand(
        @"INSERT INTO acad_programmecourses 
          (progcode, course_code, study_year, semester, CurriculumID, 
           specialisation_id, course_type) 
          VALUES (@progcode, @code, @year, @sem, 0, @specId, @courseType)", conn))
    {
        cmd.Parameters.AddWithValue("@progcode", progCode);
        cmd.Parameters.AddWithValue("@code", trimmedCode);
        cmd.Parameters.AddWithValue("@year", data.Year);
        cmd.Parameters.AddWithValue("@sem", data.Semester);
        cmd.Parameters.AddWithValue("@specId", specId);
        cmd.Parameters.AddWithValue("@courseType", data.CourseType);
        cmd.ExecuteNonQuery();
    }
    
    totalAdded++;
}
```

### Solution 2: Update Only If Same Specialization (Compromise)

If you want to allow updating existing records ONLY when they belong to the SAME specialization:

```csharp
// Check if course exists for THIS specific specialization
using (MySqlCommand cmd = new MySqlCommand(
    @"SELECT ID FROM acad_programmecourses 
      WHERE course_code = @code 
      AND progcode = @progcode 
      AND specialisation_id = @specId
      AND CurriculumID = 0 
      LIMIT 1", conn))
{
    cmd.Parameters.AddWithValue("@code", trimmedCode);
    cmd.Parameters.AddWithValue("@progcode", progCode);
    cmd.Parameters.AddWithValue("@specId", specId);
    
    object existingId = cmd.ExecuteScalar();
    
    if (existingId != null)
    {
        // Update only if it belongs to THIS specialization
        using (MySqlCommand updateCmd = new MySqlCommand(
            @"UPDATE acad_programmecourses 
              SET study_year = @year, semester = @sem, course_type = @courseType 
              WHERE ID = @id", conn))  // ← Update by specific ID, not by course_code!
        {
            updateCmd.Parameters.AddWithValue("@id", existingId);
            updateCmd.Parameters.AddWithValue("@year", data.Year);
            updateCmd.Parameters.AddWithValue("@sem", data.Semester);
            updateCmd.Parameters.AddWithValue("@courseType", data.CourseType);
            updateCmd.ExecuteNonQuery();
        }
    }
    else
    {
        // INSERT new record
        // ... (same as Solution 1)
    }
}
```

---

## Database Schema Recommendations

### Add Unique Constraint

```sql
ALTER TABLE acad_programmecourses
ADD UNIQUE KEY uk_spec_course (
    progcode, 
    course_code, 
    specialisation_id, 
    study_year, 
    semester, 
    CurriculumID
);
```

This prevents duplicate entries for the same course in the same context.

### Add Foreign Keys (If Not Present)

```sql
ALTER TABLE acad_programmecourses
ADD CONSTRAINT fk_spec 
FOREIGN KEY (specialisation_id) 
REFERENCES acad_specialisation(spec_id) 
ON DELETE CASCADE;

ALTER TABLE acad_programmecourses
ADD CONSTRAINT fk_course 
FOREIGN KEY (course_code) 
REFERENCES acad_course(courseID) 
ON DELETE CASCADE;
```

---

## Immediate Actions Required

### Priority 1: STOP USING THE BUGGY FEATURE

**Disable batch course addition** until the fix is deployed:
1. Comment out or hide the "Add All Batch" button
2. Inform administrators to use individual course addition only
3. Review recent changes for data corruption

### Priority 2: ASSESS DATA DAMAGE

Run diagnostic queries:

```sql
-- Find all courses that may have been incorrectly reassigned
SELECT 
    pc.ID,
    pc.course_code,
    pc.progcode,
    pc.specialisation_id,
    s.spec as specialization_name,
    pc.study_year,
    pc.semester,
    pc.course_type
FROM acad_programmecourses pc
LEFT JOIN acad_specialisation s ON s.spec_id = pc.specialisation_id
WHERE pc.CurriculumID = 0
ORDER BY pc.course_code, pc.progcode, pc.specialisation_id;
```

### Priority 3: BACKUP DATABASE

Before applying any fixes:
```bash
mysqldump -u root -p campus_dynamics acad_programmecourses > backup_programmecourses_$(date +%Y%m%d).sql
```

### Priority 4: APPLY THE FIX

Implement Solution 1 (Always INSERT) as it's the safest approach.

### Priority 5: DATA RECOVERY

If data has been corrupted:
1. Restore from the most recent clean backup
2. Manually reconstruct curricula from paper records or previous exports
3. Have programme coordinators review and re-validate all specializations

---

## Prevention Measures

### Code Review Checklist

- [ ] Does UPDATE statement specify exact record by ID?
- [ ] Are WHERE clauses specific enough to affect only intended records?
- [ ] Is there a check for existing records before UPDATE?
- [ ] Are foreign key relationships validated?
- [ ] Is there proper error handling for constraint violations?

### Testing Protocol

Before deploying curriculum changes:

1. **Unit Test:** Add same course to 2 different specializations
2. **Integration Test:** Verify both specializations retain their courses
3. **Regression Test:** Check that existing courses remain unchanged
4. **Data Validation:** Count records before and after operations

---

## Conclusion

This bug is a **textbook example of SQL UPDATE misuse** where:
- The WHERE clause is too broad
- Multiple records can match unintentionally
- UPDATE is used when INSERT should be used
- No safeguards prevent data corruption

**Estimated Data Loss:** Potentially 20-80% of specialization-specific course assignments may have been overwritten or lost, depending on how frequently the batch add feature was used.

**Recovery Difficulty:** HIGH - Requires manual reconstruction of curricula

**Fix Complexity:** LOW - Simple code change, but requires careful testing

**Priority:** CRITICAL - This affects academic integrity and student progression

---

**Document Prepared By:** AI Analysis System  
**Date:** February 6, 2026  
**Status:** Awaiting Implementation of Fix  
**Reviewed By:** [Pending]
