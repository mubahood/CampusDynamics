-- ================================================================
--  APPRAISAL BACKFILL — UNDO (reverts batch BF-2026-07-05)
--  Restores the 70 lecturer records + section B/C rows to pre-backfill
--  state from the backup tables, and removes the backfill audit rows.
--  Run only if you want to reverse the backfill. Requires the backup
--  tables zz_bak_appr_records_bf / _sb_bf / _sc_bf to still exist.
-- ================================================================
USE campus_dynamics;
START TRANSACTION;

UPDATE appraisal_records r JOIN zz_bak_appr_records_bf bak ON bak.record_id=r.record_id
SET r.reviewer_id=bak.reviewer_id,
    r.section_b_supervisor_total=bak.section_b_supervisor_total,
    r.section_c_total=bak.section_c_total,
    r.raw_score=bak.raw_score, r.max_possible=bak.max_possible,
    r.final_percentage=bak.final_percentage, r.classification=bak.classification,
    r.supervisor_submitted_at=bak.supervisor_submitted_at, r.status=bak.status,
    r.hr_status=bak.hr_status, r.hr_officer_name=bak.hr_officer_name,
    r.hr_overall_rating=bak.hr_overall_rating, r.hr_recommendation=bak.hr_recommendation,
    r.hr_comments=bak.hr_comments, r.hr_submitted_at=bak.hr_submitted_at;

UPDATE appraisal_section_b b JOIN zz_bak_appr_sb_bf bak ON bak.entry_id=b.entry_id
SET b.supervisor_rating=bak.supervisor_rating, b.comments=bak.comments;

UPDATE appraisal_section_c c JOIN zz_bak_appr_sc_bf bak ON bak.entry_id=c.entry_id
SET c.rating=bak.rating, c.supervisor_comment=bak.supervisor_comment;

DELETE FROM appraisal_record_audit WHERE payload_json LIKE '%BF-2026-07-05%';

SELECT r.status, COUNT(*) n FROM appraisal_records r JOIN hrm_employee e ON e.empID=r.employee_id
WHERE r.session_id=4 AND e.EmpType='Academic' GROUP BY r.status ORDER BY n DESC;
-- Review the output above; if correct, COMMIT. Otherwise ROLLBACK.
COMMIT;
