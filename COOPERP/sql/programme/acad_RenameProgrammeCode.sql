-- ============================================================================
-- acad_RenameProgrammeCode(oldCode, newCode, actor, dryRun)   created 2026-07-01
-- ----------------------------------------------------------------------------
-- Safely renames a programme code EVERYWHERE it is referenced. There are NO foreign
-- keys on acad_programme.progcode, and ~50 columns across three databases store the
-- code (progcode / progid / prog_id / prog_code / programme_code / program_code …),
-- so this discovers them dynamically from information_schema and updates only rows
-- holding the old code. Backup/temp/work tables are excluded.
--
--   dryRun = 1  -> changes NOTHING; returns the footprint (db, table, column, rows).
--   dryRun = 0  -> performs the rename atomically (one transaction; rolls back on any
--                  error), writes an audit row, and returns the per-table row counts.
--
-- Validations: old/new required, differ, old must exist, new must NOT already exist.
-- ============================================================================
DROP PROCEDURE IF EXISTS acad_RenameProgrammeCode;
DELIMITER $$
CREATE PROCEDURE acad_RenameProgrammeCode(IN oldCode VARCHAR(45), IN newCode VARCHAR(45), IN actor VARCHAR(100), IN dryRun TINYINT)
BEGIN
    DECLARE done INT DEFAULT 0;
    DECLARE v_schema, v_table, v_col VARCHAR(128);
    DECLARE cur CURSOR FOR
        SELECT TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME
        FROM information_schema.COLUMNS
        WHERE TABLE_SCHEMA IN ('campus_dynamics','campus_dynamics_accounts','campus_dynamics_portal')
          AND COLUMN_NAME IN ('progcode','progid','prog_id','prog_code','programme_code','program_code','programcode')
          AND TABLE_NAME NOT REGEXP '(_bak_|_bak$|_backup|backfill|worklist|^temp_|info_data$)'
        ORDER BY TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
    -- Any failure -> undo everything and surface the error to the caller.
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    SET oldCode = UPPER(TRIM(IFNULL(oldCode,'')));
    SET newCode = UPPER(TRIM(IFNULL(newCode,'')));

    IF oldCode = '' OR newCode = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Old and new programme codes are both required.';
    END IF;
    IF oldCode = newCode THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'The new programme code is the same as the current one.';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM acad_programme WHERE progcode = oldCode) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'The current programme code was not found.';
    END IF;
    IF EXISTS (SELECT 1 FROM acad_programme WHERE progcode = newCode) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'A programme with the new code already exists.';
    END IF;

    SET @old = oldCode;
    SET @new = newCode;

    DROP TEMPORARY TABLE IF EXISTS tmp_prog_rename_log;
    CREATE TEMPORARY TABLE tmp_prog_rename_log (db VARCHAR(64), tbl VARCHAR(128), col VARCHAR(128), n INT);

    IF dryRun = 0 THEN
        START TRANSACTION;
    END IF;

    OPEN cur;
    scan: LOOP
        FETCH cur INTO v_schema, v_table, v_col;
        IF done = 1 THEN LEAVE scan; END IF;

        IF dryRun = 1 THEN
            SET @q = CONCAT('INSERT INTO tmp_prog_rename_log SELECT ''', v_schema, ''',''', v_table, ''',''', v_col,
                            ''', COUNT(*) FROM `', v_schema, '`.`', v_table, '` WHERE `', v_col, '` = @old');
            PREPARE st FROM @q; EXECUTE st; DEALLOCATE PREPARE st;
        ELSE
            SET @q = CONCAT('UPDATE `', v_schema, '`.`', v_table, '` SET `', v_col, '` = @new WHERE `', v_col, '` = @old');
            PREPARE st FROM @q; EXECUTE st;
            SET @rc = ROW_COUNT();          -- capture BEFORE DEALLOCATE (which would reset it)
            DEALLOCATE PREPARE st;
            INSERT INTO tmp_prog_rename_log VALUES (v_schema, v_table, v_col, @rc);
        END IF;
    END LOOP;
    CLOSE cur;

    IF dryRun = 0 THEN
        -- Compute the summary into variables first — a TEMPORARY table may only be referenced
        -- once per statement, so it cannot appear twice inside one INSERT ... VALUES.
        SELECT COUNT(*)          INTO @rn_tables FROM tmp_prog_rename_log WHERE n > 0;
        SELECT IFNULL(SUM(n), 0) INTO @rn_rows   FROM tmp_prog_rename_log;
        INSERT INTO acad_activity_log (user_id, page_function, par, comments, access_date)
        VALUES (IFNULL(NULLIF(TRIM(actor),''),'system'), 'Programme Code Change',
                CONCAT(oldCode, ' -> ', newCode),
                CONCAT('Renamed programme code across ', @rn_tables, ' table(s), ', @rn_rows, ' row(s).'), NOW());
        COMMIT;
    ELSE
        -- dry-run only: return the footprint. The rename (dryRun=0) returns no result set,
        -- so a plain ExecuteNonQuery caller has nothing to consume.
        SELECT db, tbl, col, n FROM tmp_prog_rename_log WHERE n > 0 ORDER BY db, tbl, col;
    END IF;

    DROP TEMPORARY TABLE IF EXISTS tmp_prog_rename_log;
END$$
DELIMITER ;
