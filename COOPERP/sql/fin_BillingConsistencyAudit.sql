-- ============================================================================
--  fin_BillingConsistencyAudit(acadyear)  —  the "is billing 100% consistent?"
--  verification tool. Read-only. Pass '' or NULL to audit ALL years.
--
--    CALL fin_BillingConsistencyAudit('2026/2027');
--    CALL fin_BillingConsistencyAudit('');            -- all years
--
--  Reports four integrity metrics + a verdict:
--   1. double_bills_realitems   — >1 Bill row for the same (regno,acadyear,semester,item)
--                                 on a REAL fee item (item_code>0). MUST be 0.
--                                 (item_code=0 is the manual-adjustment catch-all —
--                                 waiver reversals / balance fixes — legitimately
--                                 multiple per key, so it is excluded.)
--   2. registered_unbilled      — an enrolled row (REGISTERED/LATE/CLEARED) with no
--                                 tuition (item 1) bill. Informational: some are
--                                 legitimately fee-less programmes; investigate via
--                                 fin_ReconcileEnrolledBilling.
--   3. cache_mismatches         — fin_student_balance_cache out of step with the
--                                 canonical balance. Rebuildable (fin_RefreshBalanceCache).
--   4. orphan_bills_unregistered— a tuition bill for a semester the student is now
--                                 UNREGISTERED for (and not registered elsewhere for it).
--
--  Verdict CONSISTENT requires the hard-integrity checks (1 & 4) AND registered_unbilled
--  AND cache to all be 0.
-- ============================================================================
DROP PROCEDURE IF EXISTS fin_BillingConsistencyAudit;
DELIMITER $$
CREATE PROCEDURE fin_BillingConsistencyAudit(IN p_acadyear CHAR(15))
BEGIN
  DECLARE v_double INT DEFAULT 0;
  DECLARE v_regunbilled INT DEFAULT 0;
  DECLARE v_cachemismatch INT DEFAULT 0;
  DECLARE v_orphanbill INT DEFAULT 0;

  SELECT COUNT(*) INTO v_double FROM (
    SELECT regno,acadyear,semester,item_code FROM fin_studentfeestracking
    WHERE trans_type='Bill' AND item_code>0 AND (p_acadyear='' OR p_acadyear IS NULL OR acadyear=p_acadyear)
    GROUP BY regno,acadyear,semester,item_code HAVING COUNT(*)>1) x;

  SELECT COUNT(*) INTO v_regunbilled
  FROM campus_dynamics.acad_registration r
  WHERE (p_acadyear='' OR p_acadyear IS NULL OR r.acad_year=p_acadyear)
    AND r.regstatus IN ('REGISTERED','LATE REGISTERED','CLEARED')
    AND NOT EXISTS(SELECT 1 FROM fin_studentfeestracking t
                   WHERE t.regno=r.regno AND t.acadyear=r.acad_year AND t.semester=r.semester
                     AND t.trans_type='Bill' AND t.item_code=1);

  SELECT COUNT(*) INTO v_cachemismatch
  FROM fin_student_balance_cache c
  WHERE EXISTS(SELECT 1 FROM fin_studentfeestracking t WHERE t.regno=c.regno
               AND (p_acadyear='' OR p_acadyear IS NULL OR t.acadyear=p_acadyear))
    AND ABS(c.total_balance + fin_GetCanonicalStudentBalance(c.regno)) > 0.01;

  SELECT COUNT(*) INTO v_orphanbill
  FROM fin_studentfeestracking t
  WHERE t.trans_type='Bill' AND t.item_code=1 AND (p_acadyear='' OR p_acadyear IS NULL OR t.acadyear=p_acadyear)
    AND EXISTS(SELECT 1 FROM campus_dynamics.acad_registration r WHERE r.regno=t.regno AND r.acad_year=t.acadyear AND r.semester=t.semester AND r.regstatus='UNREGISTERED')
    AND NOT EXISTS(SELECT 1 FROM campus_dynamics.acad_registration r2 WHERE r2.regno=t.regno AND r2.acad_year=t.acadyear AND r2.semester=t.semester AND r2.regstatus IN ('REGISTERED','LATE REGISTERED','CLEARED'));

  SELECT IFNULL(NULLIF(p_acadyear,''),'ALL YEARS') AS scope,
         v_double AS double_bills_realitems,
         v_regunbilled AS registered_unbilled,
         v_cachemismatch AS cache_mismatches,
         v_orphanbill AS orphan_bills_unregistered,
         IF(v_double=0 AND v_regunbilled=0 AND v_cachemismatch=0 AND v_orphanbill=0,'CONSISTENT','REVIEW NEEDED') AS verdict;
END$$
DELIMITER ;
