-- ============================================================
-- Course De-dup — Phase 4 (subject layer + tagging) & Phase 3 (orphan archive)
-- Additive/reversible only. NO results/registration rows touched.
-- Re-runnable.
-- ============================================================
SET NAMES utf8;

-- ===== PHASE 4: canonical subject layer =====================================
-- one subject per distinct (normalised) course name
INSERT IGNORE INTO campus_dynamics.acad_subject (subject_name, norm_name, course_count, is_shared, created_at, updated_at)
SELECT MIN(TRIM(courseName)), TRIM(UPPER(courseName)), COUNT(*), 0, NOW(), NOW()
FROM campus_dynamics.acad_course
GROUP BY TRIM(UPPER(courseName));

-- mark subjects that span >1 programme as shared (category B grouping)
UPDATE campus_dynamics.acad_subject s
JOIN campus_dynamics._cd_xprog x ON x.norm_name = s.norm_name
SET s.is_shared = IF(x.prog_span>1,1,0);

-- backfill acad_course.subject_id for every catalog row
UPDATE campus_dynamics.acad_course c
JOIN campus_dynamics.acad_subject s ON s.norm_name = TRIM(UPPER(c.courseName))
SET c.subject_id = s.subject_id;

-- tag category-D genuine specialisation courses with their specialisation
UPDATE campus_dynamics.acad_course c
JOIN (SELECT TRIM(course_code) cc, MAX(specialisation_id) sid
      FROM campus_dynamics.acad_programmecourses
      WHERE IFNULL(specialisation_id,0)>0 GROUP BY TRIM(course_code)) p
  ON p.cc = TRIM(c.courseID)
SET c.specialisation_scope = p.sid
WHERE c.dedup_category = 'D_SPECIALISATION';

-- ===== PHASE 3: archive zero-data orphans (858) =============================
-- reversible: sets state only; deletes nothing. Excludes orphans that carry data.
UPDATE campus_dynamics.acad_course c
JOIN campus_dynamics.acad_course_merge_map m
  ON m.category='C_ORPHAN' AND m.decision='ARCHIVE' AND m.loser_code = TRIM(c.courseID)
SET c.course_state='ARCHIVED', c.merged_at=NOW()
WHERE c.course_state='ACTIVE';

-- audit the archival
INSERT INTO campus_dynamics.acad_course_merge_audit
  (run_tag, phase, db_name, tbl, action, loser_code, detail, rows_affected, at_ts)
SELECT 'dedup20260718','P3_ORPHAN_ARCHIVE','campus_dynamics','acad_course','STATE',
       TRIM(c.courseID), 'orphan zero-data -> ARCHIVED', 1, NOW()
FROM campus_dynamics.acad_course c
JOIN campus_dynamics.acad_course_merge_map m
  ON m.category='C_ORPHAN' AND m.decision='ARCHIVE' AND m.loser_code = TRIM(c.courseID)
WHERE c.course_state='ARCHIVED'
  AND NOT EXISTS (SELECT 1 FROM campus_dynamics.acad_course_merge_audit z
                  WHERE z.run_tag='dedup20260718' AND z.phase='P3_ORPHAN_ARCHIVE'
                    AND z.loser_code=TRIM(c.courseID));
