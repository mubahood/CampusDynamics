-- ============================================================================
-- CURRICULUM DATA INTEGRITY TEST & VALIDATION SCRIPT
-- Date: February 6, 2026
-- Purpose: Test and validate the specialization course assignment fix
-- ============================================================================

USE campus_dynamics;

-- ============================================================================
-- PART 1: PRE-FIX DIAGNOSTICS (Run this BEFORE applying the fix)
-- ============================================================================

-- Test 1: Find courses that may have been incorrectly shared between specializations
-- (If this returns results, it indicates the bug was active)
SELECT 
    'POTENTIAL BUG EVIDENCE' as test_name,
    pc.course_code,
    pc.progcode,
    COUNT(DISTINCT pc.specialisation_id) as specialization_count,
    GROUP_CONCAT(DISTINCT s.spec ORDER BY s.spec SEPARATOR ' | ') as specializations
FROM acad_programmecourses pc
LEFT JOIN acad_specialisation s ON s.spec_id = pc.specialisation_id
WHERE pc.CurriculumID = 0 
  AND pc.specialisation_id IS NOT NULL
GROUP BY pc.course_code, pc.progcode
HAVING specialization_count > 1
ORDER BY specialization_count DESC, pc.course_code
LIMIT 20;

-- Test 2: Check for missing courses (specializations with too few courses)
SELECT 
    'MISSING COURSES CHECK' as test_name,
    s.spec_id,
    s.spec as specialization_name,
    p.prog as programme_name,
    COUNT(pc.ID) as course_count,
    s.is_fully_set
FROM acad_specialisation s
JOIN acad_programme p ON p.progcode = s.prog_id
LEFT JOIN acad_programmecourses pc ON s.spec_id = pc.specialisation_id
WHERE s.spec != '-'
GROUP BY s.spec_id
HAVING course_count < 3
ORDER BY course_count ASC, s.spec
LIMIT 20;

-- Test 3: Identify duplicate entries within same specialization (should be 0)
SELECT 
    'DUPLICATE DETECTION' as test_name,
    pc.course_code,
    pc.specialisation_id,
    s.spec as specialization_name,
    pc.study_year,
    pc.semester,
    COUNT(*) as duplicate_count
FROM acad_programmecourses pc
LEFT JOIN acad_specialisation s ON s.spec_id = pc.specialisation_id
WHERE pc.CurriculumID = 0
GROUP BY pc.course_code, pc.specialisation_id, pc.study_year, pc.semester
HAVING duplicate_count > 1
ORDER BY duplicate_count DESC;

-- Test 4: Check current data distribution
SELECT 
    'DATA DISTRIBUTION' as test_name,
    p.prog as programme,
    s.spec as specialization,
    COUNT(pc.ID) as total_courses,
    COUNT(CASE WHEN pc.study_year = 1 THEN 1 END) as year1_courses,
    COUNT(CASE WHEN pc.study_year = 2 THEN 1 END) as year2_courses,
    COUNT(CASE WHEN pc.study_year = 3 THEN 1 END) as year3_courses,
    COUNT(CASE WHEN pc.study_year = 4 THEN 1 END) as year4_courses
FROM acad_specialisation s
JOIN acad_programme p ON p.progcode = s.prog_id
LEFT JOIN acad_programmecourses pc ON s.spec_id = pc.specialisation_id
WHERE s.spec != '-'
GROUP BY p.prog, s.spec
ORDER BY p.prog, s.spec;

-- ============================================================================
-- PART 2: DATABASE INTEGRITY SETUP (Apply these constraints)
-- ============================================================================

-- Check if unique constraint exists
SELECT 
    'CONSTRAINT CHECK' as test_name,
    CONSTRAINT_NAME,
    CONSTRAINT_TYPE
FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
WHERE TABLE_SCHEMA = 'campus_dynamics'
  AND TABLE_NAME = 'acad_programmecourses'
  AND CONSTRAINT_NAME = 'uk_spec_course';

-- If the above returns no results, add the unique constraint:
/*
ALTER TABLE acad_programmecourses
ADD UNIQUE KEY uk_spec_course (
    progcode, 
    course_code, 
    specialisation_id, 
    study_year, 
    semester, 
    CurriculumID
);
*/

-- Check foreign key constraints
SELECT 
    'FOREIGN KEY CHECK' as test_name,
    CONSTRAINT_NAME,
    COLUMN_NAME,
    REFERENCED_TABLE_NAME,
    REFERENCED_COLUMN_NAME
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = 'campus_dynamics'
  AND TABLE_NAME = 'acad_programmecourses'
  AND REFERENCED_TABLE_NAME IS NOT NULL;

-- ============================================================================
-- PART 3: POST-FIX VALIDATION TESTS
-- ============================================================================

-- Test 5: Simulate adding same course to two different specializations
-- This should create TWO separate records (not update existing one)

-- Step 1: Get test data
SELECT 
    'TEST SETUP' as step,
    s1.spec_id as spec1_id,
    s1.spec as spec1_name,
    s2.spec_id as spec2_id,
    s2.spec as spec2_name,
    c.courseID as test_course
FROM acad_specialisation s1
CROSS JOIN acad_specialisation s2
CROSS JOIN acad_course c
WHERE s1.spec_id < s2.spec_id
  AND s1.prog_id = s2.prog_id
  AND s1.spec != '-'
  AND s2.spec != '-'
LIMIT 1;

-- Step 2: Check if test course exists in either specialization
-- (Replace @spec1, @spec2, @course with values from above)
SET @spec1 = 1;  -- Replace with actual spec_id from Test Setup
SET @spec2 = 2;  -- Replace with actual spec_id from Test Setup
SET @course = 'CSC101';  -- Replace with actual courseID from Test Setup
SET @prog = 'BSCS';  -- Replace with actual progcode

SELECT 
    'BEFORE TEST' as step,
    pc.*,
    s.spec as specialization_name
FROM acad_programmecourses pc
LEFT JOIN acad_specialisation s ON s.spec_id = pc.specialisation_id
WHERE pc.course_code = @course
  AND pc.progcode = @prog
  AND pc.specialisation_id IN (@spec1, @spec2);

-- Step 3: After adding course via UI to both specializations, verify TWO records exist
SELECT 
    'AFTER TEST - VERIFICATION' as step,
    COUNT(*) as total_records,
    COUNT(CASE WHEN specialisation_id = @spec1 THEN 1 END) as spec1_records,
    COUNT(CASE WHEN specialisation_id = @spec2 THEN 1 END) as spec2_records
FROM acad_programmecourses
WHERE course_code = @course
  AND progcode = @prog
  AND specialisation_id IN (@spec1, @spec2);

-- Expected Result: total_records = 2, spec1_records = 1, spec2_records = 1
-- If total_records = 1, the bug is STILL present

-- Test 6: Verify no cross-contamination
-- Add a course to Spec A, then add different course to Spec B
-- Check that Spec A's course is still intact

SELECT 
    'CROSS-CONTAMINATION TEST' as test_name,
    s.spec as specialization,
    COUNT(pc.ID) as course_count_before_test
FROM acad_specialisation s
LEFT JOIN acad_programmecourses pc ON s.spec_id = pc.specialisation_id
WHERE s.spec != '-'
GROUP BY s.spec_id
ORDER BY s.spec;

-- After making changes in UI, run again and compare counts
-- Counts should NEVER decrease (only increase or stay same)

-- ============================================================================
-- PART 4: DATA RECOVERY HELPER QUERIES
-- ============================================================================

-- If data was corrupted, use these queries to identify affected specializations

-- Find specializations with suspiciously low course counts
SELECT 
    'RECOVERY - LOW COUNTS' as issue,
    s.spec_id,
    s.spec as specialization,
    p.prog as programme,
    COUNT(pc.ID) as current_courses,
    'Expected: 15-20 courses per specialization' as note
FROM acad_specialisation s
JOIN acad_programme p ON p.progcode = s.prog_id
LEFT JOIN acad_programmecourses pc ON s.spec_id = pc.specialisation_id
WHERE s.spec != '-'
  AND s.is_fully_set = 'Yes'  -- Marked as complete but has few courses
GROUP BY s.spec_id
HAVING current_courses < 10
ORDER BY current_courses ASC;

-- Find students assigned to specializations with missing courses
SELECT 
    'RECOVERY - AFFECTED STUDENTS' as issue,
    st.regno,
    CONCAT(st.firstname, ' ', st.othername) as student_name,
    s.spec as specialization,
    COUNT(pc.ID) as available_courses
FROM acad_student st
JOIN acad_specialisation s ON s.spec_id = st.specialisation
LEFT JOIN acad_programmecourses pc ON pc.specialisation_id = s.spec_id
WHERE st.specialisation IS NOT NULL
  AND st.specialisation != '-'
  AND st.specialisation != '13'
GROUP BY st.regno, st.specialisation
HAVING available_courses < 5
ORDER BY available_courses ASC, st.regno;

-- ============================================================================
-- PART 5: MONITORING QUERIES (Run periodically)
-- ============================================================================

-- Daily health check
SELECT 
    'DAILY HEALTH CHECK' as report,
    COUNT(DISTINCT s.spec_id) as total_specializations,
    COUNT(DISTINCT pc.ID) as total_course_assignments,
    AVG(course_counts.cnt) as avg_courses_per_spec,
    MIN(course_counts.cnt) as min_courses,
    MAX(course_counts.cnt) as max_courses
FROM acad_specialisation s
LEFT JOIN acad_programmecourses pc ON s.spec_id = pc.specialisation_id
LEFT JOIN (
    SELECT specialisation_id, COUNT(*) as cnt
    FROM acad_programmecourses
    WHERE specialisation_id IS NOT NULL
    GROUP BY specialisation_id
) course_counts ON s.spec_id = course_counts.specialisation_id
WHERE s.spec != '-';

-- Alert: Specializations that lost courses (compare with historical data)
-- Save baseline first:
-- CREATE TABLE curriculum_baseline AS
-- SELECT specialisation_id, COUNT(*) as course_count, NOW() as snapshot_date
-- FROM acad_programmecourses GROUP BY specialisation_id;

-- Then run this daily:
/*
SELECT 
    'COURSE LOSS ALERT' as alert,
    b.specialisation_id,
    s.spec as specialization,
    b.course_count as baseline_count,
    COALESCE(current.cnt, 0) as current_count,
    (b.course_count - COALESCE(current.cnt, 0)) as lost_courses
FROM curriculum_baseline b
LEFT JOIN (
    SELECT specialisation_id, COUNT(*) as cnt
    FROM acad_programmecourses
    GROUP BY specialisation_id
) current ON b.specialisation_id = current.specialisation_id
LEFT JOIN acad_specialisation s ON s.spec_id = b.specialisation_id
WHERE b.course_count > COALESCE(current.cnt, 0)
ORDER BY lost_courses DESC;
*/

-- ============================================================================
-- PART 6: BULLETPROOF VALIDATION CHECKLIST
-- ============================================================================

/*
✅ VALIDATION CHECKLIST - Run after applying the fix:

1. [ ] Unique constraint added to acad_programmecourses
2. [ ] Foreign keys validated
3. [ ] Pre-fix diagnostic queries run and results saved
4. [ ] Code fix deployed to NewSpecialisations.aspx.cs
5. [ ] Test Case 1: Add same course to 2 different specs → 2 records created ✓
6. [ ] Test Case 2: Add course to Spec A, then to Spec B → Both retain their courses ✓
7. [ ] Test Case 3: Try to add duplicate within same spec → Properly rejected ✓
8. [ ] Test Case 4: Verify existing courses unchanged ✓
9. [ ] Post-fix validation queries show no data corruption
10. [ ] Daily monitoring queries scheduled
11. [ ] Backup created before applying changes
12. [ ] Staff trained on correct usage
13. [ ] Documentation updated in README.md
14. [ ] Change log entry created

EXPECTED OUTCOMES:
- Same course CAN exist in multiple specializations (different records)
- Same course CANNOT exist twice in same specialization (prevented by constraint)
- Adding course to Spec B does NOT affect Spec A's courses
- All UPDATE operations removed, only INSERT operations remain
- Zero data loss after fix implementation
*/

-- ============================================================================
-- END OF TEST SCRIPT
-- ============================================================================
