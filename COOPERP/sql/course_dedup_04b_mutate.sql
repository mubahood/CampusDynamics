-- ============================================================
-- Course De-dup — MERGE MUTATE (PURE DML; NO DDL, so it is fully
-- transactional and can be ROLLED BACK for a dry run).
-- Requires course_dedup_04a_prep.sql to have run first (staging present).
-- The runner wraps this in START TRANSACTION ... (ROLLBACK | COMMIT).
-- ============================================================
SET NAMES utf8;

-- ===== RESULTS: quarantine discards -> delete -> re-key survivors ==========
INSERT INTO campus_dynamics.acad_results_quarantine
  (run_tag,reason,quar_at,orig_id,regno,courseid,semester,acad,studyyear,score,grade,gpa,progid)
SELECT 'dedup20260718','A_MERGE_dup_result',NOW(),r.ID,r.regno,r.courseid,r.semester,r.acad,
       r.studyyear,r.score,r.grade,r.gpa,r.progid
FROM campus_dynamics.acad_results r JOIN campus_dynamics._cd_res_discard d ON d.rid=r.ID;

DELETE r FROM campus_dynamics.acad_results r JOIN campus_dynamics._cd_res_discard d ON d.rid=r.ID;

UPDATE campus_dynamics.acad_results r JOIN campus_dynamics._cd_losers l ON TRIM(r.courseid)=l.cc
  SET r.courseid=l.surv;

-- ===== REGISTRATIONS: quarantine discards -> delete -> re-key survivors ====
INSERT INTO campus_dynamics_portal.acad_course_registration_quarantine
  (run_tag,reason,quar_at,orig_id,regno,courseID,acad_year,semester,prog_id)
SELECT 'dedup20260718','A_MERGE_dup_registration',NOW(),g.ID,g.regno,g.courseID,g.acad_year,g.semester,g.prog_id
FROM campus_dynamics_portal.acad_course_registration g
JOIN campus_dynamics._cd_reg_discard d ON d.rid=g.ID;

DELETE g FROM campus_dynamics_portal.acad_course_registration g
  JOIN campus_dynamics._cd_reg_discard d ON d.rid=g.ID;

UPDATE campus_dynamics_portal.acad_course_registration g
  JOIN campus_dynamics._cd_losers l ON TRIM(g.courseID)=l.cc SET g.courseID=l.surv;

-- ===== SECONDARY tables WITHOUT a unique index: plain re-key ================
-- (acad_timetable is a VIEW over base tables -> not re-keyed directly.)
UPDATE campus_dynamics.acad_transcript_results r JOIN campus_dynamics._cd_losers l ON TRIM(r.courseid)=l.cc SET r.courseid=l.surv;
UPDATE campus_dynamics.acad_marks_audit r JOIN campus_dynamics._cd_losers l ON TRIM(r.course_id)=l.cc SET r.course_id=l.surv;

-- ===== SECONDARY tables WITH a unique index: re-key what fits (UPDATE IGNORE).
-- Rows that would collide keep their old code (a survivor row already carries
-- that config/allocation); nothing is deleted -> FK-safe and fully lossless.
UPDATE IGNORE campus_dynamics.acad_teaching_allocation r JOIN campus_dynamics._cd_losers l ON TRIM(r.courseID)=l.cc SET r.courseID=l.surv;
UPDATE campus_dynamics.acad_teaching_allocation r JOIN campus_dynamics._cd_losers l ON TRIM(r.course_code)=l.cc SET r.course_code=l.surv;
UPDATE IGNORE campus_dynamics.acad_exam_timetable r JOIN campus_dynamics._cd_losers l ON TRIM(r.courseID)=l.cc SET r.courseID=l.surv;
UPDATE IGNORE campus_dynamics_portal.acad_examsettings r JOIN campus_dynamics._cd_losers l ON TRIM(r.courseID)=l.cc SET r.courseID=l.surv;
UPDATE IGNORE campus_dynamics_portal.acad_coursework_settings r JOIN campus_dynamics._cd_losers l ON TRIM(r.courseID)=l.cc SET r.courseID=l.surv;
UPDATE IGNORE campus_dynamics_portal.odel_course_space r JOIN campus_dynamics._cd_losers l ON TRIM(r.courseID)=l.cc SET r.courseID=l.surv;

-- ===== PROGRAMMECOURSES: re-key what fits (IGNORE) then drop leftover loser =
-- mappings (the survivor offering already exists -> that is why they collided).
UPDATE IGNORE campus_dynamics.acad_programmecourses r JOIN campus_dynamics._cd_losers l ON TRIM(r.course_code)=l.cc SET r.course_code=l.surv;
DELETE r FROM campus_dynamics.acad_programmecourses r JOIN campus_dynamics._cd_losers l ON TRIM(r.course_code)=l.cc;

-- ===== CATALOG: mark losers MERGED ========================================
UPDATE campus_dynamics.acad_course c JOIN campus_dynamics._cd_losers l ON TRIM(c.courseID)=l.cc
  SET c.course_state='MERGED', c.merged_into=l.surv, c.merged_at=NOW();
