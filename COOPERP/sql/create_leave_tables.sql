-- ═══════════════════════════════════════════════════════════════════════════
--  Leave Application System — MRU
--  Run once against campus_dynamics database
-- ═══════════════════════════════════════════════════════════════════════════

-- ── Main applications table ───────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS hrm_leave_applications (
    id                      INT AUTO_INCREMENT PRIMARY KEY,

    -- ── Employee Details (Section 1 of paper form) ────────────────────────
    employee_id             INT,                        -- FK hrm_employee.empID (nullable for non-staff)
    emp_name                VARCHAR(200) NOT NULL,
    emp_code                VARCHAR(50),
    faculty_dept            VARCHAR(200),               -- Faculty / Department / Section
    office_location         VARCHAR(200),               -- Office field on form
    position_held           VARCHAR(200),
    residence_address       TEXT,
    mobile_contact          VARCHAR(50),
    nok_name                VARCHAR(200),               -- Next of kin / Spouse / Parent
    nok_address             TEXT,
    nok_mobile              VARCHAR(50),

    -- ── Leave Request (filled by employee, confirmed by HOD) ──────────────
    leave_type              VARCHAR(30) NOT NULL DEFAULT 'annual',
    -- Values: annual | study | sick | maternity | bereavement
    leave_from              DATE NOT NULL,
    leave_to                DATE NOT NULL,
    num_days                INT,
    substitute_arrangement  TEXT,                       -- Coverage during leave

    -- ── Supervisor / HOD routing ──────────────────────────────────────────
    supervisor_username     VARCHAR(100),
    supervisor_name         VARCHAR(200),

    -- ── Workflow status ───────────────────────────────────────────────────
    -- DRAFT → SUBMITTED → HOD_APPROVED → HR_APPROVED → VC_GRANTED
    --                   → HOD_DECLINED
    --                                  → HR_DECLINED
    --                                               → VC_NOT_GRANTED
    --                                               → VC_POSTPONED
    -- Any stage → CANCELLED (admin only)
    status                  VARCHAR(30) NOT NULL DEFAULT 'DRAFT',

    -- ── Employee submission ───────────────────────────────────────────────
    employee_submitted_at   DATETIME,
    created_by              VARCHAR(100),               -- session username

    -- ── HOD / Head of Department Approval (Section 2) ────────────────────
    hod_handover_to         VARCHAR(300),               -- Title + name duties handed to
    hod_action              VARCHAR(20),                -- APPROVED | DECLINED
    hod_actor               VARCHAR(100),               -- username
    hod_actor_name          VARCHAR(200),
    hod_action_at           DATETIME,
    hod_notes               TEXT,

    -- ── HR Department (Section 3) ─────────────────────────────────────────
    hr_action               VARCHAR(20),                -- APPROVED | DECLINED
    hr_actor                VARCHAR(100),
    hr_actor_name           VARCHAR(200),
    hr_action_at            DATETIME,
    hr_effective_from       DATE,                       -- HR may confirm/adjust dates
    hr_effective_to         DATE,
    hr_notes                TEXT,

    -- ── Vice Chancellor's Office (Section 4) ──────────────────────────────
    vc_decision             VARCHAR(20),                -- GRANTED | NOT_GRANTED | POSTPONED
    vc_reason               TEXT,
    vc_accumulated_days     INT,
    vc_days_taken           INT,
    vc_actor                VARCHAR(100),
    vc_actor_name           VARCHAR(200),
    vc_action_at            DATETIME,

    -- ── Audit meta ────────────────────────────────────────────────────────
    is_active               TINYINT(1) NOT NULL DEFAULT 1,
    created_at              DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at              DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    INDEX idx_employee      (employee_id),
    INDEX idx_status        (status),
    INDEX idx_supervisor    (supervisor_username),
    INDEX idx_created_by    (created_by),
    INDEX idx_created_at    (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ── Audit trail table ──────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS hrm_leave_audit (
    id                  INT AUTO_INCREMENT PRIMARY KEY,
    application_id      INT NOT NULL,
    action_code         VARCHAR(50)  NOT NULL,          -- SUBMITTED, HOD_APPROVED, HR_DECLINED, etc.
    old_status          VARCHAR(30),
    new_status          VARCHAR(30),
    actor_name          VARCHAR(200),
    actor_username      VARCHAR(100),
    actor_role          VARCHAR(100),
    remarks             TEXT,
    ip_address          VARCHAR(50),
    created_at          DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    INDEX idx_app       (application_id),
    INDEX idx_when      (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ── Role permissions — grant hr.leave_applications to ALL active roles ────
-- This allows every logged-in staff member to apply for leave.
INSERT IGNORE INTO sys_role_permissions (role_id, menu_slug, can_view)
SELECT id, 'hr.leave_applications', 1
FROM sys_roles
WHERE is_active = 1;


-- ── Verify ────────────────────────────────────────────────────────────────
SELECT 'hrm_leave_applications created' AS result
UNION ALL
SELECT 'hrm_leave_audit created'
UNION ALL
SELECT CONCAT('hr.leave_applications permission granted to ',
    COUNT(*), ' roles') AS result
FROM sys_role_permissions WHERE menu_slug = 'hr.leave_applications';
