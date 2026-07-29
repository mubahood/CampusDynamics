-- ============================================================================
--  ID Card backfill from OmniPass PRINTED status  (one-time)
--
--  Creates one idcard_requests row per student whose OmniPass/XAXU check status
--  is PRINTED and who has no request yet, pre-advanced to status = PRINTED with a
--  full 5-step audit trail. finance_ok stays NULL (not asserted). No emails fire
--  (pure inserts, no funnel/notify).
--
--  Idempotent  : re-running skips students who already have a request, and skips
--                event rows that already exist.
--  Reversible  : every row is tagged created_by='OMNIPASS-BACKFILL' and events
--                channel='backfill' -> one scoped DELETE reverts it.
--
--  Ongoing equivalent: IDCardService.SyncPrintedRequests() (called after each
--  OmniPass BatchSync) creates the same shape for future PRINTED students.
-- ============================================================================

START TRANSACTION;

SET @yr := YEAR(NOW());
SET @n  := IFNULL((SELECT MAX(CAST(SUBSTRING(request_no, 10) AS UNSIGNED))
                   FROM idcard_requests
                   WHERE request_no LIKE CONCAT('IDR-', @yr, '-%')), 0);

-- 1) request rows (status = PRINTED)
INSERT INTO idcard_requests
    (request_no, requester_type, regno, card_type, status,
     photo_ref, photo_confirmed, guidelines_ack,
     submitted_at, approved_at, printed_at, approved_by, printed_by,
     notes, created_by, created_at, updated_at)
SELECT
    CONCAT('IDR-', @yr, '-', LPAD(@n := @n + 1, 6, '0')),
    'STUDENT', s.regno, 'NEW', 'PRINTED',
    IFNULL(s.photofile, ''), 1, 1,
    s.c, s.c, s.c, 'OMNIPASS-BACKFILL', 'OMNIPASS-BACKFILL',
    'Backfilled from OmniPass PRINTED status', 'OMNIPASS-BACKFILL', NOW(), NOW()
FROM (
    SELECT a.regno AS regno, a.photofile AS photofile, IFNULL(a.id_card_checked_at, NOW()) AS c
    FROM acad_student a
    WHERE a.id_card_status = 'PRINTED'
      AND NOT EXISTS (SELECT 1 FROM idcard_requests r WHERE TRIM(r.regno) = TRIM(a.regno))
    ORDER BY a.id_card_checked_at
) s;

-- 2) 5-step event trail for every backfilled request that has no events yet
INSERT INTO idcard_request_events
    (request_id, from_status, to_status, actor, actor_role, channel, note, created_at)
SELECT r.id, x.frm, x.too, 'OMNIPASS-BACKFILL', 'system', 'backfill',
       'Backfilled from OmniPass PRINTED status', r.printed_at
FROM idcard_requests r
JOIN (
              SELECT NULL            AS frm, 'REQUESTED'     AS too, 1 AS ord
    UNION ALL SELECT 'REQUESTED',    'FINANCE_CHECK',            2
    UNION ALL SELECT 'FINANCE_CHECK','SUBMITTED',                3
    UNION ALL SELECT 'SUBMITTED',    'APPROVED',                 4
    UNION ALL SELECT 'APPROVED',     'PRINTED',                  5
) x
WHERE r.created_by = 'OMNIPASS-BACKFILL'
  AND NOT EXISTS (SELECT 1 FROM idcard_request_events e WHERE e.request_id = r.id)
ORDER BY r.id, x.ord;

-- verify before COMMIT
SELECT (SELECT COUNT(*) FROM idcard_requests WHERE created_by='OMNIPASS-BACKFILL')      AS requests_created,
       (SELECT COUNT(*) FROM idcard_request_events WHERE channel='backfill')   AS events_created;

COMMIT;

-- ---------------------------------------------------------------------------
-- ROLLBACK / UNDO (run manually if needed):
--   DELETE e FROM idcard_request_events e JOIN idcard_requests r ON r.id=e.request_id
--     WHERE r.created_by='OMNIPASS-BACKFILL';
--   DELETE FROM idcard_requests WHERE created_by='OMNIPASS-BACKFILL';
-- ---------------------------------------------------------------------------
