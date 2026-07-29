-- ============================================================
-- Course De-dup — Phase 0: BACKUPS (idempotent; safe to re-run)
-- Creates dated structural+data copies BEFORE any change.
-- Restore = TRUNCATE orig; INSERT ... SELECT * FROM bak;
-- ============================================================
-- Uses CREATE TABLE ... LIKE (keeps indexes/PK) + INSERT only if empty.
DELIMITER $$
DROP PROCEDURE IF EXISTS _bak_one $$
CREATE PROCEDURE _bak_one(IN db VARCHAR(64), IN tbl VARCHAR(64))
BEGIN
  DECLARE bak VARCHAR(160);
  SET bak = CONCAT(tbl,'_predup20260718');
  SET @s = CONCAT('CREATE TABLE IF NOT EXISTS `',db,'`.`',bak,'` LIKE `',db,'`.`',tbl,'`');
  PREPARE st FROM @s; EXECUTE st; DEALLOCATE PREPARE st;
  -- fill only if backup is empty (prevents double-insert on re-run)
  SET @c = 0;
  SET @s = CONCAT('SELECT COUNT(*) INTO @c FROM `',db,'`.`',bak,'`');
  PREPARE st FROM @s; EXECUTE st; DEALLOCATE PREPARE st;
  IF @c = 0 THEN
    SET @s = CONCAT('INSERT INTO `',db,'`.`',bak,'` SELECT * FROM `',db,'`.`',tbl,'`');
    PREPARE st FROM @s; EXECUTE st; DEALLOCATE PREPARE st;
  END IF;
END $$
DELIMITER ;

CALL _bak_one('campus_dynamics','acad_course');
CALL _bak_one('campus_dynamics','acad_programmecourses');
CALL _bak_one('campus_dynamics','acad_results');
CALL _bak_one('campus_dynamics','acad_results1');
CALL _bak_one('campus_dynamics','acad_resultsupdates');
CALL _bak_one('campus_dynamics','acad_results_status');
CALL _bak_one('campus_dynamics','acad_passrates');
CALL _bak_one('campus_dynamics','acad_transcript_results');
CALL _bak_one('campus_dynamics','acad_teaching_allocation');
CALL _bak_one('campus_dynamics','acad_marks_audit');
CALL _bak_one('campus_dynamics','acad_exam_timetable');
CALL _bak_one('campus_dynamics_portal','acad_course_registration');
CALL _bak_one('campus_dynamics_portal','odel_course_space');
CALL _bak_one('campus_dynamics_portal','acad_examsettings');
CALL _bak_one('campus_dynamics_portal','acad_coursework_settings');

DROP PROCEDURE IF EXISTS _bak_one;
