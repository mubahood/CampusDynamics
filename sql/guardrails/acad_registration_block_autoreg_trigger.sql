-- ============================================================================
--  GUARDRAIL: block AUTOMATIC semester registrations at the database level.
--  Task 2 (2026-08-04). Belt-and-suspenders on top of the disabled auto-reconcile
--  engine (BillingReconciliationJob.AutoReconcileDisabled + fin_billing_recon_jobstate.enabled=0).
--
--  Policy: a row in acad_registration may ONLY be created by
--    (a) a student via the eportal registration wizard  -> registeredBy = their regno (MRU…)
--    (b) a named staff member via an admin screen        -> registeredBy = their username / email
--  It may NEVER be created by an automatic/system routine. Those historically used
--  registeredBy markers like 'AUTO-RECON…', 'RECON-ENROLLED', 'system_newstud_fix',
--  which produced unbilled phantom registrations (see the 2026-08-04 cleanup).
--
--  This trigger REJECTS any INSERT whose registeredBy starts with an automatic marker,
--  so even a rogue job/script/SP can no longer auto-register a student. Legit values
--  (student regnos, staff usernames, blank/'-') are unaffected.
--
--  To run a legitimate one-off backfill, temporarily DROP this trigger, do the work with
--  a clearly-attributed registeredBy, then re-create it.
-- ============================================================================

DROP TRIGGER IF EXISTS trg_acadreg_block_autoreg;

DELIMITER $$
CREATE TRIGGER trg_acadreg_block_autoreg
BEFORE INSERT ON acad_registration
FOR EACH ROW
BEGIN
    IF UPPER(TRIM(COALESCE(NEW.registeredBy,''))) REGEXP '^(AUTO-|AUTO_|RECON-|RECON_|AUTORECON|SYSTEM_)' THEN
        -- MESSAGE_TEXT is capped at 128 chars by MySQL; keep it short.
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Automatic semester registration is disabled by policy. Use the eportal or an admin screen (no system/auto registeredBy).';
    END IF;
END$$
DELIMITER ;
