-- ============================================================================
--  Repair the bill-uniqueness guard, and stop it locking students out
--  Muteesa I Royal University                                     2026-08-28
--
--  THE FAULT
--  ---------
--  fin_bill_uniqueness exists to stop double-billing: trg_prevent_duplicate_bill
--  writes a row on every bill insert, and the UNIQUE key on
--  (regno, acadyear, semester, item_code) makes a second identical bill fail.
--
--  But a guard row that outlives its bill becomes a permanent lock. The insert
--  then fails with "Duplicate entry ... for key 'UNQ_one_bill_per_student'",
--  fin_Autobilling raises nothing, and the portal wizard — which treats "no bill
--  raised" as failure — throws "Automatic billing failed for semester
--  registration" and ROLLS BACK the registration it just created. The student is
--  locked out of registering, permanently, with no trace left behind.
--
--  VERONICA NAKIYIMBA (MRU2026005204) hit exactly this: guard rows dated
--  2026-07-07 with tid=0 and no matching bill. Reproduced, then cleared, and she
--  billed normally on the next attempt (680,000 + 862,000).
--
--  HOW THE ORPHANS AROSE
--  ---------------------
--  There is a trigger for INSERT and one for DELETE, but none for UPDATE. Any
--  statement that MOVES a bill — changing its acadyear, semester or item_code —
--  leaves the guard row behind on the old key and leaves the new key unguarded.
--
--  Two of the four orphans are exactly that, and they are mine: yesterday's
--  restore of MRU2026004388 re-tagged her two bills from 2025/2026 to 2026/2027
--  so they sat on the semester she is registered for. The bills moved; the guard
--  rows did not. That left her old term falsely locked AND her new term
--  unguarded — i.e. re-runnable into a double bill. Both are corrected below.
--
--  The remaining orphan pair is keyed by ENTRY NUMBER (26/U/BCE/0024/M/DAY)
--  rather than a registration number. Bills are always keyed by regno, so that
--  row can never match a real bill; it is junk and is removed.
--
--  Safe to re-run.
-- ============================================================================

-- ---------------------------------------------------------------------------
-- 0. Backup every guard row this script touches.
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS campus_dynamics.bk_billuniq_orphans_20260828
AS SELECT * FROM campus_dynamics_accounts.fin_bill_uniqueness WHERE 1=0;

INSERT INTO campus_dynamics.bk_billuniq_orphans_20260828
SELECT u.* FROM campus_dynamics_accounts.fin_bill_uniqueness u
 WHERE NOT EXISTS (SELECT 1 FROM campus_dynamics_accounts.fin_studentfeestracking f
                    WHERE f.regno=u.regno AND f.acadyear=u.acadyear
                      AND f.semester=u.semester AND f.item_code=u.item_code
                      AND f.trans_type='Bill')
   AND NOT EXISTS (SELECT 1 FROM campus_dynamics.bk_billuniq_orphans_20260828 b
                    WHERE b.regno=u.regno AND b.acadyear=u.acadyear
                      AND b.semester=u.semester AND b.item_code=u.item_code);

-- ---------------------------------------------------------------------------
-- 1. Re-point guard rows whose bill still exists but has MOVED.
--    Matched by tid, which survives the move, so the guard follows its own bill
--    rather than being guessed at. Done before the orphan sweep so these are
--    corrected rather than deleted.
-- ---------------------------------------------------------------------------
UPDATE campus_dynamics_accounts.fin_bill_uniqueness u
  JOIN campus_dynamics_accounts.fin_studentfeestracking f
    ON f.TID = u.tid AND f.trans_type = 'Bill'
   SET u.acadyear = f.acadyear, u.semester = f.semester, u.item_code = f.item_code
 WHERE u.tid > 0
   AND (u.acadyear <> f.acadyear OR u.semester <> f.semester OR u.item_code <> f.item_code);

-- ---------------------------------------------------------------------------
-- 2. Remove guard rows that no longer protect anything.
--    A guard row with no bill behind it cannot prevent a duplicate — there is
--    nothing to duplicate — it can only block the first legitimate bill.
-- ---------------------------------------------------------------------------
DELETE u FROM campus_dynamics_accounts.fin_bill_uniqueness u
 WHERE NOT EXISTS (SELECT 1 FROM campus_dynamics_accounts.fin_studentfeestracking f
                    WHERE f.regno=u.regno AND f.acadyear=u.acadyear
                      AND f.semester=u.semester AND f.item_code=u.item_code
                      AND f.trans_type='Bill');

-- ---------------------------------------------------------------------------
-- 3. Close the hole: keep the guard in step when a bill is MOVED.
--    Without this, the next correction that re-tags a bill recreates exactly the
--    orphan that locked Veronica out.
-- ---------------------------------------------------------------------------
DROP TRIGGER IF EXISTS campus_dynamics_accounts.trg_sync_bill_uniqueness_update;

DELIMITER $$
CREATE TRIGGER campus_dynamics_accounts.trg_sync_bill_uniqueness_update
AFTER UPDATE ON campus_dynamics_accounts.fin_studentfeestracking
FOR EACH ROW
BEGIN
    IF OLD.trans_type = 'Bill'
       AND (   IFNULL(OLD.acadyear,'')  <> IFNULL(NEW.acadyear,'')
            OR IFNULL(OLD.semester,0)   <> IFNULL(NEW.semester,0)
            OR IFNULL(OLD.item_code,0)  <> IFNULL(NEW.item_code,0)
            OR IFNULL(OLD.regno,'')     <> IFNULL(NEW.regno,'')
            OR IFNULL(OLD.trans_type,'')<> IFNULL(NEW.trans_type,'')) THEN

        -- Release the old key.
        DELETE FROM campus_dynamics_accounts.fin_bill_uniqueness
         WHERE regno = OLD.regno AND acadyear = OLD.acadyear
           AND semester = OLD.semester AND item_code = OLD.item_code;

        -- Claim the new one, but only while the row is still a bill.
        -- INSERT IGNORE: if the destination is already guarded, that guard is
        -- the correct one and must not be disturbed.
        IF NEW.trans_type = 'Bill' THEN
            INSERT IGNORE INTO campus_dynamics_accounts.fin_bill_uniqueness
                   (regno, acadyear, semester, item_code, tid)
            VALUES (NEW.regno, NEW.acadyear, NEW.semester, NEW.item_code, NEW.TID);
        END IF;
    END IF;
END$$
DELIMITER ;

-- ---------------------------------------------------------------------------
-- 4. Verification.
-- ---------------------------------------------------------------------------
SELECT '--- 1. orphaned guard rows remaining (expect 0) ---' AS check_1;
SELECT COUNT(*) AS orphans_left
  FROM campus_dynamics_accounts.fin_bill_uniqueness u
 WHERE NOT EXISTS (SELECT 1 FROM campus_dynamics_accounts.fin_studentfeestracking f
                    WHERE f.regno=u.regno AND f.acadyear=u.acadyear
                      AND f.semester=u.semester AND f.item_code=u.item_code
                      AND f.trans_type='Bill');

SELECT '--- 2. every real bill is guarded (expect 0 unguarded) ---' AS check_2;
SELECT COUNT(*) AS unguarded_bills
  FROM campus_dynamics_accounts.fin_studentfeestracking f
 WHERE f.trans_type='Bill'
   AND NOT EXISTS (SELECT 1 FROM campus_dynamics_accounts.fin_bill_uniqueness u
                    WHERE u.regno=f.regno AND u.acadyear=f.acadyear
                      AND u.semester=f.semester AND u.item_code=f.item_code);

SELECT '--- 3. the update trigger is in place (expect 3 triggers) ---' AS check_3;
SELECT TRIGGER_NAME, ACTION_TIMING, EVENT_MANIPULATION FROM information_schema.TRIGGERS
 WHERE EVENT_OBJECT_SCHEMA='campus_dynamics_accounts'
   AND EVENT_OBJECT_TABLE='fin_studentfeestracking' ORDER BY TRIGGER_NAME;

SELECT '--- 4. MRU2026004388 guard rows now follow her re-tagged bills ---' AS check_4;
SELECT u.regno, u.acadyear, u.semester, u.item_code, u.tid,
       f.acadyear AS bill_acadyear, f.semester AS bill_semester
  FROM campus_dynamics_accounts.fin_bill_uniqueness u
  LEFT JOIN campus_dynamics_accounts.fin_studentfeestracking f ON f.TID = u.tid
 WHERE TRIM(u.regno)='MRU2026004388';
