-- ============================================================================
-- role_management_schema.sql
-- Slug-based dynamic role & permission system for CampusDynamics eAdmin
-- Run against: campus_dynamics database
-- Run order:   1. DDL  2. Roles  3. Menu Items  4. Permissions
-- Bootstrap:   role_management_bootstrap.sql  (run separately, set username)
-- ============================================================================

-- ── 1. DDL — Create Tables ──────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS sys_menu_items (
    id          INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    slug        VARCHAR(120) NOT NULL UNIQUE,
    label       VARCHAR(120) NOT NULL,
    section     VARCHAR(60)  NOT NULL,
    item_type   ENUM('heading','parent','subitem','standalone') NOT NULL DEFAULT 'subitem',
    parent_slug VARCHAR(120) DEFAULT NULL,
    url         VARCHAR(300) DEFAULT NULL,
    icon_svg    TEXT         DEFAULT NULL,
    sort_order  SMALLINT     NOT NULL DEFAULT 100,
    is_active   TINYINT(1)   NOT NULL DEFAULT 1,
    created_at  DATETIME     NOT NULL DEFAULT NOW(),
    INDEX idx_section (section),
    INDEX idx_parent  (parent_slug)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS sys_roles (
    id              INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    role_code       VARCHAR(60)  NOT NULL UNIQUE,
    role_name       VARCHAR(120) NOT NULL,
    description     TEXT         DEFAULT NULL,
    color_hex       VARCHAR(7)   DEFAULT '#64748b',
    is_system_role  TINYINT(1)   NOT NULL DEFAULT 0,
    is_active       TINYINT(1)   NOT NULL DEFAULT 1,
    created_by      VARCHAR(100) DEFAULT NULL,
    created_at      DATETIME     NOT NULL DEFAULT NOW(),
    updated_at      DATETIME     DEFAULT NULL ON UPDATE NOW()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS sys_role_permissions (
    id          INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    role_id     INT UNSIGNED NOT NULL,
    menu_slug   VARCHAR(120) NOT NULL,
    can_view    TINYINT(1)   NOT NULL DEFAULT 1,
    can_edit    TINYINT(1)   NOT NULL DEFAULT 0,
    can_delete  TINYINT(1)   NOT NULL DEFAULT 0,
    granted_by  VARCHAR(100) NOT NULL DEFAULT 'system',
    granted_at  DATETIME     NOT NULL DEFAULT NOW(),
    FOREIGN KEY (role_id) REFERENCES sys_roles(id) ON DELETE CASCADE,
    UNIQUE KEY uq_role_slug (role_id, menu_slug),
    INDEX idx_slug (menu_slug)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS sys_user_roles (
    id          INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    username    VARCHAR(100) NOT NULL,
    emp_id      INT          DEFAULT NULL,
    role_id     INT UNSIGNED NOT NULL,
    granted_by  VARCHAR(100) NOT NULL DEFAULT 'system',
    granted_at  DATETIME     NOT NULL DEFAULT NOW(),
    expires_at  DATETIME     DEFAULT NULL,
    is_active   TINYINT(1)   NOT NULL DEFAULT 1,
    notes       VARCHAR(300) DEFAULT NULL,
    FOREIGN KEY (role_id) REFERENCES sys_roles(id) ON DELETE CASCADE,
    UNIQUE KEY uq_user_role (username, role_id),
    INDEX idx_username (username),
    INDEX idx_emp      (emp_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS sys_role_audit (
    id          INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    action_type ENUM('ROLE_CREATED','ROLE_UPDATED','ROLE_DELETED',
                     'PERMISSION_GRANTED','PERMISSION_REVOKED',
                     'USER_ROLE_ASSIGNED','USER_ROLE_REVOKED',
                     'USER_ROLE_EXPIRED') NOT NULL,
    target_type ENUM('role','permission','user_role') NOT NULL,
    target_id   VARCHAR(200) NOT NULL,
    detail      TEXT         DEFAULT NULL,
    actor       VARCHAR(100) NOT NULL,
    ip_address  VARCHAR(45)  DEFAULT NULL,
    created_at  DATETIME     NOT NULL DEFAULT NOW(),
    INDEX idx_actor  (actor),
    INDEX idx_type   (action_type),
    INDEX idx_target (target_type, target_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS sys_role_section_settings (
    id              INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    role_id         INT UNSIGNED NOT NULL,
    section_slug    VARCHAR(60)  NOT NULL,
    default_open    TINYINT(1)   NOT NULL DEFAULT 0,
    FOREIGN KEY (role_id) REFERENCES sys_roles(id) ON DELETE CASCADE,
    UNIQUE KEY uq_role_section (role_id, section_slug)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- ── 2. Seed sys_roles ───────────────────────────────────────────────────────

INSERT IGNORE INTO sys_roles (role_code, role_name, description, color_hex, is_system_role) VALUES
('admin',           'System Administrator',  'Full unrestricted access to all modules',        '#05275C', 1),
('dean',            'Dean',                  'Faculty academic oversight',                     '#7c3aed', 1),
('registrar',       'Registrar',             'Student registration and records management',    '#174DA4', 1),
('faculty_staff',   'Faculty Staff',         'Teaching and academic delivery staff',           '#0369a1', 1),
('exam_officer',    'Examination Officer',   'Exam administration, results and transcripts',   '#d97706', 1),
('admissions',      'Admissions Officer',    'Application processing and admissions workflow', '#16a34a', 1),
('student_services','Student Services',      'Student support, welfare and services',          '#059669', 1),
('fees_officer',    'Fees Officer',          'Student fee collection and administration',      '#ca8a04', 1),
('bursar',          'Bursar',                'Bursary management and financial routing',       '#b45309', 1),
('finance_officer', 'Finance Officer',       'Finance operations, ledgers and accounts',      '#0891b2', 1),
('accountant',      'Accountant',            'Accounting, ledgers and financial reporting',   '#0e7490', 1),
('hr_manager',      'HR Manager',            'Human resources, payroll and staff management', '#be185d', 1),
('procurement',     'Procurement Officer',   'Procurement workflow and requisitions',          '#9333ea', 1),
('vc',              'Vice-Chancellor',       'Executive oversight and high-level approvals',  '#1e293b', 1);


-- ── 3. Seed sys_menu_items ──────────────────────────────────────────────────

INSERT IGNORE INTO sys_menu_items (slug, label, section, item_type, parent_slug, url, sort_order) VALUES

-- HOME
('home.dashboard','Dashboard','home','standalone',NULL,'~/COOPERP/NewScreens/NewDashboard.aspx',10),

-- ── ACADEMICS ────────────────────────────────────────────────────────────────
('academics','Academics','academics','heading',NULL,NULL,100),

('academics.students','Students','academics','parent','academics',NULL,110),
('academics.students.online_applications','Online Applications','academics','subitem','academics.students','~/COOPERP/NewScreens/OnlineApplicationsController.aspx',111),
('academics.students.register_new','Register New Student','academics','subitem','academics.students','~/COOPERP/NewScreens/NewStudentRegistration.aspx',112),
('academics.students.semester_registration','Semester Registration','academics','subitem','academics.students','~/COOPERP/NewScreens/StudentsRegistration.aspx',113),
('academics.students.semester_deletions','Semester Deletion Requests','academics','subitem','academics.students','~/COOPERP/NewScreens/SemesterDeletionRequestsController.aspx',114),
('academics.students.course_registration','Student Course Registration','academics','subitem','academics.students','~/COOPERP/NewScreens/CourseRegistration.aspx',115),
('academics.students.enrollment_analysis','Enrolment Analysis','academics','subitem','academics.students','~/COOPERP/NewScreens/EnrollmentAnalysis.aspx',116),
('academics.students.active_students','Active Students','academics','subitem','academics.students','~/COOPERP/NewScreens/ActiveStudents.aspx',117),
('academics.students.all_students','All Students','academics','subitem','academics.students','~/COOPERP/NewScreens/AllStudents.aspx',118),
('academics.students.alumni','Alumni','academics','subitem','academics.students','~/COOPERP/NewScreens/AlumniStudents.aspx',119),
('academics.students.id_card_status','ID Card Status','academics','subitem','academics.students','~/COOPERP/NewScreens/IDCardStatus.aspx',120),
('academics.students.portal_onboarding','Portal Onboarding','academics','subitem','academics.students','~/COOPERP/NewScreens/PortalOnboarding.aspx',121),
('academics.students.nche_export','NCHE Data Export','academics','subitem','academics.students','~/COOPERP/NewScreens/NCHEExporter.aspx',122),
('academics.students.admissions_controller','Admissions Controller','academics','subitem','academics.students','~/COOPERP/NewScreens/AdmissionsController.aspx',123),

('academics.programmes','Programmes & Courses','academics','parent','academics',NULL,130),
('academics.programmes.faculties','Faculties','academics','subitem','academics.programmes','~/COOPERP/NewScreens/NewFaculties.aspx',131),
('academics.programmes.programmes','Programmes','academics','subitem','academics.programmes','~/COOPERP/NewScreens/NewFacultyProgrammes.aspx',132),
('academics.programmes.specialisations','Specialisations','academics','subitem','academics.programmes','~/COOPERP/NewScreens/NewSpecialisations.aspx',133),
('academics.programmes.course_bank','Course Bank','academics','subitem','academics.programmes','~/COOPERP/NewScreens/NewCourses.aspx',134),
('academics.programmes.programme_courses','Programme Courses','academics','subitem','academics.programmes','~/COOPERP/NewScreens/NewProgrammeCourses.aspx',135),
('academics.programmes.unlocated_courses','Unlocated Courses','academics','subitem','academics.programmes','~/COOPERP/NewScreens/UnlocatedNewProgrammeCourses.aspx',136),
('academics.programmes.allocated_courses','Allocated Courses','academics','subitem','academics.programmes','~/COOPERP/NewScreens/AllocatedNewProgrammeCourses.aspx',137),
('academics.programmes.requested_courses','Requested Courses','academics','subitem','academics.programmes','~/COOPERP/NewScreens/RequestedNewProgrammeCourses.aspx',138),
('academics.programmes.courses_dashboard','Programme Courses Dashboard','academics','subitem','academics.programmes','~/COOPERP/NewScreens/DashboardNewProgrammeCourses.aspx',139),
('academics.programmes.committee_report','Academic Committee Report','academics','subitem','academics.programmes','~/COOPERP/NewScreens/AcademicCommitteeReport.aspx',140),

('academics.exam','Exam','academics','parent','academics',NULL,150),
('academics.exam.marks_dashboard','Marks Dashboard','academics','subitem','academics.exam','~/COOPERP/NewScreens/MarksDashboard.aspx',151),
('academics.exam.mark_requests','Mark Requests','academics','subitem','academics.exam','~/COOPERP/NewScreens/MarkRequestsAdmin.aspx',152),
('academics.exam.all_marks','All Marks','academics','subitem','academics.exam','~/COOPERP/NewScreens/AllMarksController.aspx',153),
('academics.exam.published_marks','Published Marks','academics','subitem','academics.exam','~/COOPERP/NewScreens/PublishedMarksController.aspx',154),
('academics.exam.provisional_marks','Provisional Marks','academics','subitem','academics.exam','~/COOPERP/NewScreens/ProvisionalMarksController.aspx',155),
('academics.exam.pending_exam_marks','Pending Exam Marks','academics','subitem','academics.exam','~/COOPERP/NewScreens/PendingExamMarksController.aspx',156),
('academics.exam.pending_coursework_marks','Pending Coursework Marks','academics','subitem','academics.exam','~/COOPERP/NewScreens/PendingCourseworkMarksController.aspx',157),

('academics.allocation','Allocation Management','academics','parent','academics',NULL,160),
('academics.allocation.dashboard','Allocation Dashboard','academics','subitem','academics.allocation','~/COOPERP/NewScreens/LoadAllocationDashboard.aspx',161),
('academics.allocation.teaching_allocations','Teaching Allocations','academics','subitem','academics.allocation','~/COOPERP/NewScreens/LoadAllocations.aspx',162),
('academics.allocation.workload_analysis','Workload Analysis','academics','subitem','academics.allocation','~/COOPERP/NewScreens/WorkloadAnalysis.aspx',163),

('academics.timetable','Timetable','academics','parent','academics',NULL,170),
('academics.timetable.view','Timetable View','academics','subitem','academics.timetable','~/COOPERP/NewScreens/TimetableView.aspx',171),

('academics.settings','Settings','academics','parent','academics',NULL,180),
('academics.settings.lecture_rooms','Lecture Rooms','academics','subitem','academics.settings','~/COOPERP/NewScreens/LectureRooms.aspx',181),

-- ── SCHOOL FEES ───────────────────────────────────────────────────────────────
('fees','School Fees','fees','heading',NULL,NULL,200),

('fees.fee_admin','Fee Administration','fees','parent','fees',NULL,210),
('fees.fee_admin.dashboard','Fees Dashboard','fees','subitem','fees.fee_admin','~/COOPERP/NewScreens/FeesManagement.aspx',211),
('fees.fee_admin.access_policy','Fee Access Policy','fees','subitem','fees.fee_admin','~/COOPERP/NewScreens/FeeAccessPolicy.aspx',212),
('fees.fee_admin.access_checker','Fee Access Checker','fees','subitem','fees.fee_admin','~/COOPERP/NewScreens/FeeAccessChecker.aspx',213),
('fees.fee_admin.structure','Fee Structure & Settings','fees','subitem','fees.fee_admin','~/COOPERP/NewScreens/FeesStructure.aspx',214),
('fees.fee_admin.registration','Fee Registration','fees','subitem','fees.fee_admin','~/COOPERP/NewScreens/FeesRegistration.aspx',215),
('fees.fee_admin.audit_trail','Audit Trail','fees','subitem','fees.fee_admin','~/COOPERP/NewScreens/FeesAuditTrail.aspx',216),
('fees.fee_admin.other_fees_billing','Other Fees Billing','fees','subitem','fees.fee_admin','~/COOPERP/NewScreens/OtherFeesBilling.aspx',217),
('fees.fee_admin.bill_waivers','Bill Waivers','fees','subitem','fees.fee_admin','~/COOPERP/NewScreens/BillWaivers.aspx',218),
('fees.fee_admin.transactions','Transactions','fees','subitem','fees.fee_admin','~/COOPERP/NewScreens/FeesTransactions.aspx',219),
('fees.fee_admin.student_ledgers','Student Ledgers','fees','subitem','fees.fee_admin','~/COOPERP/NewScreens/StudentLedgers.aspx',220),
('fees.fee_admin.double_billing','Double Billing','fees','subitem','fees.fee_admin','~/COOPERP/NewScreens/DoubleBillingController.aspx',221),
('fees.fee_admin.active_students_fees','Active Students','fees','subitem','fees.fee_admin','~/COOPERP/NewScreens/ActiveStudents.aspx',222),

('fees.bursaries','Bursaries & Scholarships','fees','parent','fees',NULL,230),
('fees.bursaries.dashboard','Bursary Dashboard','fees','subitem','fees.bursaries','~/COOPERP/NewScreens/BursaryDashboard.aspx',231),
('fees.bursaries.schemes','Bursary Schemes','fees','subitem','fees.bursaries','~/COOPERP/NewScreens/BursarySchemes.aspx',232),
('fees.bursaries.beneficiaries','Bursary Beneficiaries','fees','subitem','fees.bursaries','~/COOPERP/NewScreens/BursaryBeneficiaries.aspx',233),

-- ── EXPENDITURE & ACCOUNTS ───────────────────────────────────────────────────
('accounts','Expenditure & Accounts','accounts','heading',NULL,NULL,300),

('accounts.ledgers','Accounts & Ledgers','accounts','parent','accounts',NULL,310),
('accounts.ledgers.main_accounts','Main Accounts Controller','accounts','subitem','accounts.ledgers','~/COOPERP/NewScreens/MainAccountsController.aspx',311),
('accounts.ledgers.sub_accounts','Sub Accounts Controller','accounts','subitem','accounts.ledgers','~/COOPERP/NewScreens/SubAccountsController.aspx',312),
('accounts.ledgers.categories','Ledger Categories','accounts','subitem','accounts.ledgers','~/COOPERP/NewScreens/LedgerCategories.aspx',313),
('accounts.ledgers.general_ledger','General Ledger','accounts','subitem','accounts.ledgers','~/COOPERP/NewScreens/GeneralLedger.aspx',314),
('accounts.ledgers.suppliers','Supplier Management','accounts','subitem','accounts.ledgers','~/COOPERP/NewScreens/SupplierManagement.aspx',315),

('accounts.transactions','Expenditure Transactions','accounts','parent','accounts',NULL,320),
('accounts.transactions.journal_entries','Journal Entries','accounts','subitem','accounts.transactions','~/COOPERP/NewScreens/JournalEntries.aspx',321),
('accounts.transactions.payment_vouchers','Payment Vouchers','accounts','subitem','accounts.transactions','~/COOPERP/NewScreens/PaymentVouchers.aspx',322),
('accounts.transactions.contra_vouchers','Contra Vouchers','accounts','subitem','accounts.transactions','~/COOPERP/NewScreens/ContraVouchers.aspx',323),

('accounts.control','Periods & Control','accounts','parent','accounts',NULL,330),
('accounts.control.finance_dashboard','Finance Dashboard','accounts','subitem','accounts.control','~/COOPERP/NewScreens/FinanceDashboard.aspx',331),
('accounts.control.financial_periods','Financial Periods','accounts','subitem','accounts.control','~/COOPERP/NewScreens/FinancialPeriods.aspx',332),
('accounts.control.audit_trail','Audit Trail','accounts','subitem','accounts.control','~/COOPERP/NewScreens/FinanceAuditTrail.aspx',333),
('accounts.control.batch_monitor','Transaction Batch Monitor','accounts','subitem','accounts.control','~/COOPERP/Finance/Admin/TransactionBatchMonitor.aspx',334),
('accounts.control.double_entry','Double-Entry Validation','accounts','subitem','accounts.control','~/COOPERP/Finance/Admin/DoubleEntryValidation.aspx',335),
('accounts.control.period_management','Accounting Period Management','accounts','subitem','accounts.control','~/COOPERP/Finance/Admin/PeriodManagement.aspx',336),
('accounts.control.period_close','Period Close Management','accounts','subitem','accounts.control','~/COOPERP/Finance/Admin/PeriodClose.aspx',337),
('accounts.control.reversal_approvals','Reversal & Correction Approvals','accounts','subitem','accounts.control','~/COOPERP/Finance/Admin/ReversalApprovals.aspx',338),
('accounts.control.audit_trail_tx','Transaction Audit Trail','accounts','subitem','accounts.control','~/COOPERP/Finance/Admin/TransactionAuditTrail.aspx',339),
('accounts.control.bank_reco_import','Bank Reconciliation Import','accounts','subitem','accounts.control','~/COOPERP/Finance/Admin/BankReconciliationImport.aspx',340),
('accounts.control.bank_reco_match','Bank Reconciliation Matching','accounts','subitem','accounts.control','~/COOPERP/Finance/Admin/BankRecoMatching.aspx',341),
('accounts.control.account_lifecycle','Chart of Accounts Lifecycle','accounts','subitem','accounts.control','~/COOPERP/Finance/Admin/AccountManagement.aspx',342),
('accounts.control.reversal_request','Initiate Reversal Request','accounts','subitem','accounts.control','~/COOPERP/Finance/Admin/ReversalRequest.aspx',343),
('accounts.control.correction_request','Initiate Correction Request','accounts','subitem','accounts.control','~/COOPERP/Finance/Admin/CorrectionRequest.aspx',344),

('accounts.reports','Financial Reports','accounts','parent','accounts',NULL,350),
('accounts.reports.trial_balance','Trial Balance','accounts','subitem','accounts.reports','~/COOPERP/NewScreens/TrialBalance.aspx',351),
('accounts.reports.income_statement','Income Statement','accounts','subitem','accounts.reports','~/COOPERP/NewScreens/IncomeStatement.aspx',352),
('accounts.reports.balance_sheet','Balance Sheet','accounts','subitem','accounts.reports','~/COOPERP/NewScreens/BalanceSheet.aspx',353),

-- ── HUMAN RESOURCE ────────────────────────────────────────────────────────────
('hr','Human Resource','hr','heading',NULL,NULL,400),
('hr.dashboard','HR Dashboard','hr','standalone',NULL,'~/COOPERP/NewScreens/HRDashboard.aspx',401),

('hr.people','People & Contracts','hr','parent','hr',NULL,410),
('hr.people.employees','Employee Directory','hr','subitem','hr.people','~/COOPERP/NewScreens/HREmployees.aspx',411),
('hr.people.contracts','Contracts','hr','subitem','hr.people','~/COOPERP/NewScreens/HRContracts.aspx',412),
('hr.people.leave','Leave Management','hr','subitem','hr.people','~/COOPERP/NewScreens/HRLeaveManagement.aspx',413),

('hr.payroll','Payroll','hr','parent','hr',NULL,420),
('hr.payroll.management','Payroll Management','hr','subitem','hr.payroll','~/COOPERP/NewScreens/HRPayroll.aspx',421),
('hr.payroll.payslips','Payslips','hr','subitem','hr.payroll','~/COOPERP/NewScreens/HRPayslips.aspx',422),
('hr.payroll.allowances','Allowance Records','hr','subitem','hr.payroll','~/COOPERP/NewScreens/HRAllowances.aspx',423),
('hr.payroll.deductions','Deduction Records','hr','subitem','hr.payroll','~/COOPERP/NewScreens/HRDeductions.aspx',424),

('hr.settings','HR Settings','hr','parent','hr',NULL,430),
('hr.settings.org_structure','Org Structure & Scales','hr','subitem','hr.settings','~/COOPERP/NewScreens/HRSettings.aspx',431),
('hr.settings.payroll_config','Payroll & Tax Config','hr','subitem','hr.settings','~/COOPERP/NewScreens/HRConfig.aspx',432),

('hr.appraisal','Performance Appraisal','hr','parent','hr',NULL,440),
('hr.appraisal.dashboard','Appraisal Dashboard','hr','subitem','hr.appraisal','~/COOPERP/NewScreens/AppraisalDashboard.aspx',441),
('hr.appraisal.sessions','Appraisal Sessions','hr','subitem','hr.appraisal','~/COOPERP/NewScreens/AppraisalSessions.aspx',442),
('hr.appraisal.view','View Appraisals','hr','subitem','hr.appraisal','~/COOPERP/NewScreens/AppraisalView.aspx',443),
('hr.appraisal.reports','Appraisal Reports','hr','subitem','hr.appraisal','~/COOPERP/NewScreens/AppraisalReports.aspx',444),

-- ── REQUISITIONS ──────────────────────────────────────────────────────────────
('requisitions','Requisitions','requisitions','heading',NULL,NULL,500),

('requisitions.main','Requisitions','requisitions','parent','requisitions',NULL,510),
('requisitions.main.controller','Master Dashboard','requisitions','subitem','requisitions.main','~/COOPERP/NewScreens/RequisitionsController.aspx',511),
('requisitions.main.bursar_queue','Bursar Queue','requisitions','subitem','requisitions.main','~/COOPERP/NewScreens/BursarRequisitions.aspx',512),
('requisitions.main.finance_queue','Finance Queue','requisitions','subitem','requisitions.main','~/COOPERP/NewScreens/FinanceRequisitions.aspx',513),

-- ── COMMUNICATIONS ────────────────────────────────────────────────────────────
('comms','Communications','comms','heading',NULL,NULL,600),

('comms.notices','Notices','comms','parent','comms',NULL,610),
('comms.notices.manage','Manage Communications','comms','subitem','comms.notices','~/COOPERP/NewScreens/Communications.aspx',611),
('comms.notices.analytics','Read Analytics','comms','subitem','comms.notices','~/COOPERP/NewScreens/CommunicationAnalytics.aspx',612),

('comms.tickets','Support Tickets','comms','standalone',NULL,'~/COOPERP/NewScreens/TicketsController.aspx',620),

-- ── SYSTEM ────────────────────────────────────────────────────────────────────
('system','System','system','heading',NULL,NULL,700),

('system.config','Configuration','system','parent','system',NULL,710),
('system.config.academic_years','Academic Years','system','subitem','system.config','~/COOPERP/NewScreens/AcademicYears.aspx',711),
('system.config.system_config','System Configuration','system','subitem','system.config','~/COOPERP/NewScreens/SystemConfig.aspx',712),

('system.more','More Features','system','parent','system',NULL,720),
('system.more.elections_dashboard','Elections Dashboard','system','subitem','system.more','~/COOPERP/NewScreens/ElectionsDashboard.aspx',721),
('system.more.election_posts','Election Posts','system','subitem','system.more','~/COOPERP/NewScreens/ElectionPosts.aspx',722),
('system.more.election_candidates','Election Candidates','system','subitem','system.more','~/COOPERP/NewScreens/ElectionCandidates.aspx',723),
('system.more.election_voters','Election Voters','system','subitem','system.more','~/COOPERP/NewScreens/ElectionVoters.aspx',724),
('system.more.election_results','Election Results','system','subitem','system.more','~/COOPERP/NewScreens/ElectionResults.aspx',725),
('system.more.validation_stats','Validation Stats','system','subitem','system.more','~/COOPERP/NewScreens/SystemValidationStats.aspx',726),
('system.more.knowledgebase','Knowledgebase Management','system','subitem','system.more','~/COOPERP/NewScreens/KnowledgebaseManagement.aspx',727),
('system.more.id_cards','ID Cards','system','subitem','system.more','~/COOPERP/NewScreens/StudentsIDCards.aspx',728),
('system.more.graduating_students','Graduating Students','system','subitem','system.more','~/COOPERP/NewScreens/GraduateStudents.aspx',729),
('system.more.specialisations','Student Specialisations','system','subitem','system.more','~/COOPERP/NewScreens/StudentsSpecialisation.aspx',730),
('system.more.year_promotions','Year Promotions','system','subitem','system.more','~/COOPERP/NewScreens/StudentsPromotion.aspx',731),
('system.more.student_documents','Student Documents','system','subitem','system.more','~/COOPERP/NewScreens/StudentDocuments.aspx',732),
('system.more.residence_allocation','Residence Allocation','system','subitem','system.more','~/COOPERP/NewScreens/ResidenceAllocation.aspx',733),
('system.more.nche_student_exporter','NCHE Student Exporter','system','subitem','system.more','~/COOPERP/NewScreens/NCHEStudentExporter.aspx',734),
('system.more.research_marksheets','Research Marksheets','system','subitem','system.more','~/COOPERP/NewScreens/ResearchMarksheets.aspx',735),
('system.more.academic_results','Academic Results','system','subitem','system.more','~/COOPERP/NewScreens/AcademicResults.aspx',736),
('system.more.results_release','Results Release','system','subitem','system.more','~/COOPERP/NewScreens/ResultsRelease.aspx',737),
('system.more.results_updates','Results Updates','system','subitem','system.more','~/COOPERP/NewScreens/ResultsUpdates.aspx',738),
('system.more.hold_list','Hold List','system','subitem','system.more','~/COOPERP/NewScreens/ResultsHoldList.aspx',739),
('system.more.results_audit_log','Results Audit Log','system','subitem','system.more','~/COOPERP/NewScreens/ResultsAuditLog.aspx',740),
('system.more.student_profile','Student Profile','system','subitem','system.more','~/COOPERP/NewScreens/StudentProfile.aspx',741),
('system.more.results_analytics','Results Analytics','system','subitem','system.more','~/COOPERP/NewScreens/ResultsAnalytics.aspx',742),
('system.more.student_results_view','Student Results View','system','subitem','system.more','~/COOPERP/NewScreens/StudentResultsView.aspx',743),
('system.more.chart_of_accounts','Chart of Accounts','system','subitem','system.more','~/COOPERP/NewScreens/ChartOfAccounts.aspx',744),

-- ── USER & ROLE MANAGEMENT (Super Admin only) ─────────────────────────────────
('system.user_roles','User & Role Management','system','parent','system',NULL,800),
('system.user_roles.users','Users','system','subitem','system.user_roles','~/COOPERP/NewScreens/UserRoleUsers.aspx',801),
('system.user_roles.roles','Roles','system','subitem','system.user_roles','~/COOPERP/NewScreens/UserRoleRoles.aspx',802),
('system.user_roles.permissions','Permission Matrix','system','subitem','system.user_roles','~/COOPERP/NewScreens/UserRolePermissions.aspx',803),
('system.user_roles.audit','Audit Log','system','subitem','system.user_roles','~/COOPERP/NewScreens/UserRoleAudit.aspx',804);


-- ── 4. Seed sys_role_permissions ────────────────────────────────────────────
-- Translates existing sidebar data-roles into DB permission rows.

SET @dean_id      = (SELECT id FROM sys_roles WHERE role_code='dean');
SET @registrar_id = (SELECT id FROM sys_roles WHERE role_code='registrar');
SET @faculty_id   = (SELECT id FROM sys_roles WHERE role_code='faculty_staff');
SET @exam_id      = (SELECT id FROM sys_roles WHERE role_code='exam_officer');
SET @admit_id     = (SELECT id FROM sys_roles WHERE role_code='admissions');
SET @svc_id       = (SELECT id FROM sys_roles WHERE role_code='student_services');
SET @fees_id      = (SELECT id FROM sys_roles WHERE role_code='fees_officer');
SET @bursar_id    = (SELECT id FROM sys_roles WHERE role_code='bursar');
SET @fin_id       = (SELECT id FROM sys_roles WHERE role_code='finance_officer');
SET @acc_id       = (SELECT id FROM sys_roles WHERE role_code='accountant');
SET @hr_id        = (SELECT id FROM sys_roles WHERE role_code='hr_manager');
SET @proc_id      = (SELECT id FROM sys_roles WHERE role_code='procurement');
SET @vc_id        = (SELECT id FROM sys_roles WHERE role_code='vc');

-- ── Dean ──────────────────────────────────────────────────────────────────────
INSERT IGNORE INTO sys_role_permissions (role_id, menu_slug) VALUES
(@dean_id,'home.dashboard'),
(@dean_id,'academics'),
(@dean_id,'academics.students'),
(@dean_id,'academics.students.enrollment_analysis'),
(@dean_id,'academics.students.active_students'),
(@dean_id,'academics.students.all_students'),
(@dean_id,'academics.programmes'),
(@dean_id,'academics.programmes.faculties'),
(@dean_id,'academics.programmes.programmes'),
(@dean_id,'academics.programmes.specialisations'),
(@dean_id,'academics.programmes.course_bank'),
(@dean_id,'academics.programmes.programme_courses'),
(@dean_id,'academics.programmes.committee_report'),
(@dean_id,'academics.exam'),
(@dean_id,'academics.allocation'),
(@dean_id,'academics.allocation.dashboard'),
(@dean_id,'academics.allocation.teaching_allocations'),
(@dean_id,'academics.allocation.workload_analysis'),
(@dean_id,'academics.timetable'),
(@dean_id,'academics.timetable.view'),
(@dean_id,'academics.settings'),
(@dean_id,'academics.settings.lecture_rooms'),
(@dean_id,'comms'),
(@dean_id,'comms.notices'),
(@dean_id,'comms.notices.manage'),
(@dean_id,'comms.notices.analytics'),
(@dean_id,'system.more'),
(@dean_id,'system.more.graduating_students'),
(@dean_id,'system.more.research_marksheets'),
(@dean_id,'system.more.academic_results'),
(@dean_id,'system.more.results_analytics');

-- ── Registrar ─────────────────────────────────────────────────────────────────
INSERT IGNORE INTO sys_role_permissions (role_id, menu_slug) VALUES
(@registrar_id,'home.dashboard'),
(@registrar_id,'academics'),
(@registrar_id,'academics.students'),
(@registrar_id,'academics.students.online_applications'),
(@registrar_id,'academics.students.register_new'),
(@registrar_id,'academics.students.semester_registration'),
(@registrar_id,'academics.students.semester_deletions'),
(@registrar_id,'academics.students.course_registration'),
(@registrar_id,'academics.students.enrollment_analysis'),
(@registrar_id,'academics.students.active_students'),
(@registrar_id,'academics.students.all_students'),
(@registrar_id,'academics.students.alumni'),
(@registrar_id,'academics.students.id_card_status'),
(@registrar_id,'academics.students.portal_onboarding'),
(@registrar_id,'academics.students.nche_export'),
(@registrar_id,'academics.students.admissions_controller'),
(@registrar_id,'academics.programmes'),
(@registrar_id,'academics.programmes.faculties'),
(@registrar_id,'academics.programmes.programmes'),
(@registrar_id,'academics.programmes.specialisations'),
(@registrar_id,'academics.programmes.course_bank'),
(@registrar_id,'academics.programmes.programme_courses'),
(@registrar_id,'academics.programmes.committee_report'),
(@registrar_id,'academics.exam'),
(@registrar_id,'academics.allocation'),
(@registrar_id,'academics.allocation.dashboard'),
(@registrar_id,'academics.allocation.teaching_allocations'),
(@registrar_id,'academics.allocation.workload_analysis'),
(@registrar_id,'academics.timetable'),
(@registrar_id,'academics.timetable.view'),
(@registrar_id,'academics.settings'),
(@registrar_id,'academics.settings.lecture_rooms'),
(@registrar_id,'comms'),
(@registrar_id,'comms.notices'),
(@registrar_id,'comms.notices.manage'),
(@registrar_id,'comms.notices.analytics'),
(@registrar_id,'comms.tickets'),
(@registrar_id,'system.more'),
(@registrar_id,'system.more.elections_dashboard'),
(@registrar_id,'system.more.election_posts'),
(@registrar_id,'system.more.election_candidates'),
(@registrar_id,'system.more.election_voters'),
(@registrar_id,'system.more.election_results'),
(@registrar_id,'system.more.validation_stats'),
(@registrar_id,'system.more.id_cards'),
(@registrar_id,'system.more.graduating_students'),
(@registrar_id,'system.more.specialisations'),
(@registrar_id,'system.more.year_promotions'),
(@registrar_id,'system.more.student_documents'),
(@registrar_id,'system.more.nche_student_exporter'),
(@registrar_id,'system.more.research_marksheets'),
(@registrar_id,'system.more.academic_results'),
(@registrar_id,'system.more.results_release'),
(@registrar_id,'system.more.results_updates'),
(@registrar_id,'system.more.hold_list'),
(@registrar_id,'system.more.results_audit_log'),
(@registrar_id,'system.more.student_profile'),
(@registrar_id,'system.more.results_analytics'),
(@registrar_id,'system.more.student_results_view');

-- ── Faculty Staff ─────────────────────────────────────────────────────────────
INSERT IGNORE INTO sys_role_permissions (role_id, menu_slug) VALUES
(@faculty_id,'home.dashboard'),
(@faculty_id,'academics'),
(@faculty_id,'academics.exam'),
(@faculty_id,'academics.allocation'),
(@faculty_id,'academics.allocation.teaching_allocations'),
(@faculty_id,'academics.timetable'),
(@faculty_id,'academics.timetable.view'),
(@faculty_id,'comms'),
(@faculty_id,'comms.notices'),
(@faculty_id,'comms.notices.manage');

-- ── Examination Officer ───────────────────────────────────────────────────────
INSERT IGNORE INTO sys_role_permissions (role_id, menu_slug) VALUES
(@exam_id,'home.dashboard'),
(@exam_id,'academics'),
(@exam_id,'academics.exam'),
(@exam_id,'academics.exam.marks_dashboard'),
(@exam_id,'academics.exam.mark_requests'),
(@exam_id,'academics.exam.all_marks'),
(@exam_id,'academics.exam.published_marks'),
(@exam_id,'academics.exam.provisional_marks'),
(@exam_id,'academics.exam.pending_exam_marks'),
(@exam_id,'academics.exam.pending_coursework_marks'),
(@exam_id,'system.more'),
(@exam_id,'system.more.research_marksheets'),
(@exam_id,'system.more.academic_results'),
(@exam_id,'system.more.results_release'),
(@exam_id,'system.more.results_updates'),
(@exam_id,'system.more.hold_list'),
(@exam_id,'system.more.results_audit_log'),
(@exam_id,'system.more.results_analytics'),
(@exam_id,'system.more.student_results_view');

-- ── Admissions Officer ────────────────────────────────────────────────────────
INSERT IGNORE INTO sys_role_permissions (role_id, menu_slug) VALUES
(@admit_id,'home.dashboard'),
(@admit_id,'academics'),
(@admit_id,'academics.students'),
(@admit_id,'academics.students.online_applications'),
(@admit_id,'academics.students.active_students'),
(@admit_id,'academics.students.all_students');

-- ── Student Services ──────────────────────────────────────────────────────────
INSERT IGNORE INTO sys_role_permissions (role_id, menu_slug) VALUES
(@svc_id,'home.dashboard'),
(@svc_id,'academics'),
(@svc_id,'academics.students'),
(@svc_id,'academics.students.active_students'),
(@svc_id,'academics.students.all_students'),
(@svc_id,'academics.students.id_card_status'),
(@svc_id,'comms.tickets'),
(@svc_id,'system.more'),
(@svc_id,'system.more.elections_dashboard'),
(@svc_id,'system.more.election_posts'),
(@svc_id,'system.more.election_candidates'),
(@svc_id,'system.more.election_voters'),
(@svc_id,'system.more.election_results'),
(@svc_id,'system.more.id_cards'),
(@svc_id,'system.more.student_documents'),
(@svc_id,'system.more.residence_allocation'),
(@svc_id,'system.more.student_profile');

-- ── Fees Officer ──────────────────────────────────────────────────────────────
INSERT IGNORE INTO sys_role_permissions (role_id, menu_slug) VALUES
(@fees_id,'home.dashboard'),
(@fees_id,'fees'),
(@fees_id,'fees.fee_admin'),
(@fees_id,'fees.fee_admin.dashboard'),
(@fees_id,'fees.fee_admin.access_policy'),
(@fees_id,'fees.fee_admin.access_checker'),
(@fees_id,'fees.fee_admin.structure'),
(@fees_id,'fees.fee_admin.registration'),
(@fees_id,'fees.fee_admin.audit_trail'),
(@fees_id,'fees.fee_admin.other_fees_billing'),
(@fees_id,'fees.fee_admin.bill_waivers'),
(@fees_id,'fees.fee_admin.transactions'),
(@fees_id,'fees.fee_admin.student_ledgers'),
(@fees_id,'fees.fee_admin.double_billing'),
(@fees_id,'fees.fee_admin.active_students_fees');

-- ── Bursar ────────────────────────────────────────────────────────────────────
INSERT IGNORE INTO sys_role_permissions (role_id, menu_slug) VALUES
(@bursar_id,'home.dashboard'),
(@bursar_id,'fees'),
(@bursar_id,'fees.fee_admin'),
(@bursar_id,'fees.fee_admin.dashboard'),
(@bursar_id,'fees.fee_admin.access_policy'),
(@bursar_id,'fees.fee_admin.access_checker'),
(@bursar_id,'fees.fee_admin.structure'),
(@bursar_id,'fees.fee_admin.registration'),
(@bursar_id,'fees.fee_admin.audit_trail'),
(@bursar_id,'fees.fee_admin.other_fees_billing'),
(@bursar_id,'fees.fee_admin.bill_waivers'),
(@bursar_id,'fees.fee_admin.transactions'),
(@bursar_id,'fees.fee_admin.student_ledgers'),
(@bursar_id,'fees.fee_admin.double_billing'),
(@bursar_id,'fees.fee_admin.active_students_fees'),
(@bursar_id,'fees.bursaries'),
(@bursar_id,'fees.bursaries.dashboard'),
(@bursar_id,'fees.bursaries.schemes'),
(@bursar_id,'fees.bursaries.beneficiaries'),
(@bursar_id,'requisitions'),
(@bursar_id,'requisitions.main'),
(@bursar_id,'requisitions.main.controller'),
(@bursar_id,'requisitions.main.bursar_queue');

-- ── Finance Officer ───────────────────────────────────────────────────────────
INSERT IGNORE INTO sys_role_permissions (role_id, menu_slug) VALUES
(@fin_id,'home.dashboard'),
(@fin_id,'accounts'),
(@fin_id,'accounts.ledgers'),
(@fin_id,'accounts.ledgers.main_accounts'),
(@fin_id,'accounts.ledgers.sub_accounts'),
(@fin_id,'accounts.ledgers.categories'),
(@fin_id,'accounts.ledgers.general_ledger'),
(@fin_id,'accounts.ledgers.suppliers'),
(@fin_id,'accounts.transactions'),
(@fin_id,'accounts.transactions.journal_entries'),
(@fin_id,'accounts.transactions.payment_vouchers'),
(@fin_id,'accounts.transactions.contra_vouchers'),
(@fin_id,'accounts.control'),
(@fin_id,'accounts.control.finance_dashboard'),
(@fin_id,'accounts.control.financial_periods'),
(@fin_id,'accounts.control.audit_trail'),
(@fin_id,'accounts.control.reversal_request'),
(@fin_id,'accounts.control.correction_request'),
(@fin_id,'accounts.reports'),
(@fin_id,'accounts.reports.trial_balance'),
(@fin_id,'accounts.reports.income_statement'),
(@fin_id,'accounts.reports.balance_sheet'),
(@fin_id,'requisitions'),
(@fin_id,'requisitions.main'),
(@fin_id,'requisitions.main.controller'),
(@fin_id,'requisitions.main.finance_queue');

-- ── Accountant ────────────────────────────────────────────────────────────────
INSERT IGNORE INTO sys_role_permissions (role_id, menu_slug) VALUES
(@acc_id,'home.dashboard'),
(@acc_id,'accounts'),
(@acc_id,'accounts.ledgers'),
(@acc_id,'accounts.ledgers.main_accounts'),
(@acc_id,'accounts.ledgers.sub_accounts'),
(@acc_id,'accounts.ledgers.categories'),
(@acc_id,'accounts.ledgers.general_ledger'),
(@acc_id,'accounts.ledgers.suppliers'),
(@acc_id,'accounts.transactions'),
(@acc_id,'accounts.transactions.journal_entries'),
(@acc_id,'accounts.transactions.payment_vouchers'),
(@acc_id,'accounts.transactions.contra_vouchers'),
(@acc_id,'accounts.control'),
(@acc_id,'accounts.control.finance_dashboard'),
(@acc_id,'accounts.control.financial_periods'),
(@acc_id,'accounts.control.audit_trail'),
(@acc_id,'accounts.reports'),
(@acc_id,'accounts.reports.trial_balance'),
(@acc_id,'accounts.reports.income_statement'),
(@acc_id,'accounts.reports.balance_sheet');

-- ── HR Manager ────────────────────────────────────────────────────────────────
INSERT IGNORE INTO sys_role_permissions (role_id, menu_slug) VALUES
(@hr_id,'home.dashboard'),
(@hr_id,'hr'),
(@hr_id,'hr.dashboard'),
(@hr_id,'hr.people'),
(@hr_id,'hr.people.employees'),
(@hr_id,'hr.people.contracts'),
(@hr_id,'hr.people.leave'),
(@hr_id,'hr.payroll'),
(@hr_id,'hr.payroll.management'),
(@hr_id,'hr.payroll.payslips'),
(@hr_id,'hr.payroll.allowances'),
(@hr_id,'hr.payroll.deductions'),
(@hr_id,'hr.settings'),
(@hr_id,'hr.settings.org_structure'),
(@hr_id,'hr.settings.payroll_config'),
(@hr_id,'hr.appraisal'),
(@hr_id,'hr.appraisal.dashboard'),
(@hr_id,'hr.appraisal.sessions'),
(@hr_id,'hr.appraisal.view'),
(@hr_id,'hr.appraisal.reports');

-- ── Procurement Officer ───────────────────────────────────────────────────────
INSERT IGNORE INTO sys_role_permissions (role_id, menu_slug) VALUES
(@proc_id,'home.dashboard'),
(@proc_id,'requisitions'),
(@proc_id,'requisitions.main'),
(@proc_id,'requisitions.main.controller');

-- ── Vice-Chancellor ───────────────────────────────────────────────────────────
INSERT IGNORE INTO sys_role_permissions (role_id, menu_slug) VALUES
(@vc_id,'home.dashboard'),
(@vc_id,'requisitions'),
(@vc_id,'requisitions.main'),
(@vc_id,'requisitions.main.controller');

-- ── Verification queries ───────────────────────────────────────────────────────
-- SELECT COUNT(*) AS menu_items   FROM sys_menu_items;          -- expect ~112
-- SELECT COUNT(*) AS roles        FROM sys_roles;               -- expect 14
-- SELECT COUNT(*) AS permissions  FROM sys_role_permissions;    -- expect ~220+
-- SELECT role_code, COUNT(*) AS slugs
--   FROM sys_role_permissions rp JOIN sys_roles r ON rp.role_id=r.id
--   GROUP BY role_code ORDER BY slugs DESC;
