-- ============================================================================
-- Student Photo Change Tracker
-- ----------------------------------------------------------------------------
-- Records every student self-service photo change (eportal), holds it PENDING
-- until an eadmin admin approves/rejects. A REJECTED photo is unlinked from the
-- student (photofile blanked) so it is no longer served anywhere; the student
-- must upload a new one or delete. acad_student.photo_status drives display:
--   APPROVED : normal (default for ALL existing photos — nothing changes)
--   PENDING  : uploaded, awaiting admin review (still visible, badged)
--   REJECTED : blocked; photofile blanked, student must re-upload/delete
-- ============================================================================

CREATE TABLE IF NOT EXISTS campus_dynamics.stud_photo_change (
    id             INT AUTO_INCREMENT PRIMARY KEY,
    regno          VARCHAR(35)  NOT NULL,
    old_photofile  VARCHAR(255) NULL,          -- photo before this change ('' if none)
    new_photofile  VARCHAR(255) NOT NULL,      -- the photo they changed TO (the file on disk)
    status         VARCHAR(15)  NOT NULL DEFAULT 'PENDING',   -- PENDING / APPROVED / REJECTED
    source         VARCHAR(24)  NULL,          -- e.g. 'eportal-self'
    requested_at   DATETIME     NOT NULL,
    reviewed_by    VARCHAR(100) NULL,
    reviewed_at    DATETIME     NULL,
    review_comment VARCHAR(255) NULL,
    KEY ix_regno     (regno),
    KEY ix_status    (status),
    KEY ix_requested (requested_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Photo approval status on the student. DEFAULT 'APPROVED' back-fills every
-- existing row, so all current photos remain visible immediately.
ALTER TABLE campus_dynamics.acad_student
    ADD COLUMN photo_status VARCHAR(15) NULL DEFAULT 'APPROVED';
