-- Marks audit: capture EVERY acad_results change into acad_marks_audit (bulletproof, no path bypasses).
--
-- Attribution is connector-safe: the app writes (actor, source, reason, ip) into mark_audit_context
-- keyed by CONNECTION_ID() immediately before the acad_results write; the trigger reads it back for
-- the same connection. (The MySQL .NET connector cannot SET @user_vars without Allow User Variables=True,
-- so a per-connection context table is used instead of session variables.) Un-attributed writes
-- (direct SQL / un-instrumented paths) fall back to performed_by='system', source_page='db-trigger'.
--
-- UPDATE only logs when score/grade actually change (null-safe <=>), so GPA-only updates don't spam
-- the log. Nothing else writes acad_results rows into acad_marks_audit, so no de-duplication is needed.
USE campus_dynamics;

CREATE TABLE IF NOT EXISTS mark_audit_context (
  conn_id  BIGINT UNSIGNED NOT NULL PRIMARY KEY,
  actor    VARCHAR(90)  NULL,
  source   VARCHAR(100) NULL,
  reason   VARCHAR(200) NULL,
  ip       VARCHAR(45)  NULL,
  set_at   DATETIME     NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TRIGGER IF EXISTS trg_acad_results_audit_ai;
DROP TRIGGER IF EXISTS trg_acad_results_audit_au;
DROP TRIGGER IF EXISTS trg_acad_results_audit_ad;
DELIMITER $$

CREATE TRIGGER trg_acad_results_audit_ai AFTER INSERT ON acad_results FOR EACH ROW
BEGIN
  DECLARE v_actor VARCHAR(90);  DECLARE v_source VARCHAR(100);
  DECLARE v_reason VARCHAR(200); DECLARE v_ip VARCHAR(45);
  DECLARE CONTINUE HANDLER FOR NOT FOUND BEGIN END;
  SELECT actor, source, reason, ip INTO v_actor, v_source, v_reason, v_ip
    FROM mark_audit_context WHERE conn_id = CONNECTION_ID() AND set_at >= (NOW() - INTERVAL 60 SECOND) LIMIT 1;
  INSERT INTO acad_marks_audit
    (action_type, performed_by, ip_address, target_table, target_id, regno, course_id, acad_year, semester,
     field_changed, new_value, new_total, new_grade, change_reason, source_page, created_at)
  VALUES
    ('INSERT', IFNULL(NULLIF(TRIM(v_actor),''),'system'), NULLIF(TRIM(v_ip),''),
     'acad_results', IFNULL(NEW.ID,0), IFNULL(NEW.regno,''), IFNULL(NEW.courseid,''), NEW.acad, NEW.semester,
     'result', CONCAT('score=',IFNULL(NEW.score,'-'),' grade=',IFNULL(NEW.grade,'-')),
     NEW.score, NEW.grade, NULLIF(TRIM(v_reason),''),
     IFNULL(NULLIF(TRIM(v_source),''),'db-trigger'), NOW());
END$$

CREATE TRIGGER trg_acad_results_audit_au AFTER UPDATE ON acad_results FOR EACH ROW
BEGIN
  DECLARE v_actor VARCHAR(90);  DECLARE v_source VARCHAR(100);
  DECLARE v_reason VARCHAR(200); DECLARE v_ip VARCHAR(45);
  DECLARE CONTINUE HANDLER FOR NOT FOUND BEGIN END;
  IF (NOT (OLD.score <=> NEW.score)) OR (NOT (OLD.grade <=> NEW.grade)) THEN
    SELECT actor, source, reason, ip INTO v_actor, v_source, v_reason, v_ip
      FROM mark_audit_context WHERE conn_id = CONNECTION_ID() AND set_at >= (NOW() - INTERVAL 60 SECOND) LIMIT 1;
    INSERT INTO acad_marks_audit
      (action_type, performed_by, ip_address, target_table, target_id, regno, course_id, acad_year, semester,
       field_changed, old_value, new_value, old_total, new_total, old_grade, new_grade, change_reason, source_page, created_at)
    VALUES
      ('UPDATE', IFNULL(NULLIF(TRIM(v_actor),''),'system'), NULLIF(TRIM(v_ip),''),
       'acad_results', IFNULL(NEW.ID,0), IFNULL(NEW.regno,''), IFNULL(NEW.courseid,''), NEW.acad, NEW.semester,
       'result', CONCAT('score=',IFNULL(OLD.score,'-'),' grade=',IFNULL(OLD.grade,'-')),
       CONCAT('score=',IFNULL(NEW.score,'-'),' grade=',IFNULL(NEW.grade,'-')),
       OLD.score, NEW.score, OLD.grade, NEW.grade, NULLIF(TRIM(v_reason),''),
       IFNULL(NULLIF(TRIM(v_source),''),'db-trigger'), NOW());
  END IF;
END$$

CREATE TRIGGER trg_acad_results_audit_ad AFTER DELETE ON acad_results FOR EACH ROW
BEGIN
  DECLARE v_actor VARCHAR(90);  DECLARE v_source VARCHAR(100);
  DECLARE v_reason VARCHAR(200); DECLARE v_ip VARCHAR(45);
  DECLARE CONTINUE HANDLER FOR NOT FOUND BEGIN END;
  SELECT actor, source, reason, ip INTO v_actor, v_source, v_reason, v_ip
    FROM mark_audit_context WHERE conn_id = CONNECTION_ID() AND set_at >= (NOW() - INTERVAL 60 SECOND) LIMIT 1;
  INSERT INTO acad_marks_audit
    (action_type, performed_by, ip_address, target_table, target_id, regno, course_id, acad_year, semester,
     field_changed, old_value, old_total, old_grade, change_reason, source_page, created_at)
  VALUES
    ('DELETE', IFNULL(NULLIF(TRIM(v_actor),''),'system'), NULLIF(TRIM(v_ip),''),
     'acad_results', IFNULL(OLD.ID,0), IFNULL(OLD.regno,''), IFNULL(OLD.courseid,''), OLD.acad, OLD.semester,
     'result', CONCAT('score=',IFNULL(OLD.score,'-'),' grade=',IFNULL(OLD.grade,'-')),
     OLD.score, OLD.grade, NULLIF(TRIM(v_reason),''),
     IFNULL(NULLIF(TRIM(v_source),''),'db-trigger'), NOW());
END$$
DELIMITER ;
