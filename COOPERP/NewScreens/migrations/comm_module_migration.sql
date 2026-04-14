-- ═══════════════════════════════════════════════════════════════════════════
-- Communications Module — Database Migration
-- Campus Dynamics EMIS
-- Date: 2025
-- 
-- This migration creates the sys_communications family of tables to power
-- the new Communication / Notice module (admin + portal).
-- ═══════════════════════════════════════════════════════════════════════════

-- ───────────────────────────────────────────────────────────────
-- TABLE 1: sys_communications
-- The main communications/post table.
-- ───────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS `sys_communications` (
    `ID`                INT             NOT NULL AUTO_INCREMENT,
    `title`             VARCHAR(500)    NOT NULL,
    `content`           LONGTEXT        NOT NULL          COMMENT 'Rich-text HTML content',
    `target_audience`   VARCHAR(20)     NOT NULL DEFAULT 'BOTH'  COMMENT 'STUDENT | STAFF | BOTH',
    `is_force_read`     TINYINT(1)      NOT NULL DEFAULT 0       COMMENT '1 = must confirm before proceeding',
    `force_read_expiry` DATETIME        NULL                     COMMENT 'Force-read expires after this date',
    `priority`          VARCHAR(20)     NOT NULL DEFAULT 'NORMAL' COMMENT 'NORMAL | HIGH | URGENT',
    `status`            VARCHAR(20)     NOT NULL DEFAULT 'DRAFT'  COMMENT 'DRAFT | PUBLISHED | ARCHIVED',
    `allow_comments`    TINYINT(1)      NOT NULL DEFAULT 1,
    `created_by`        VARCHAR(100)    NOT NULL                 COMMENT 'Admin username / identifier',
    `created_by_name`   VARCHAR(200)    NOT NULL DEFAULT ''      COMMENT 'Admin display name',
    `created_at`        DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at`        DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `published_at`      DATETIME        NULL                     COMMENT 'Set when status changed to PUBLISHED',
    PRIMARY KEY (`ID`),
    INDEX `idx_comm_status`    (`status`),
    INDEX `idx_comm_audience`  (`target_audience`),
    INDEX `idx_comm_force`     (`is_force_read`, `force_read_expiry`),
    INDEX `idx_comm_published` (`published_at` DESC)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ───────────────────────────────────────────────────────────────
-- TABLE 2: sys_communication_attachments
-- File attachments linked to a communication.
-- ───────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS `sys_communication_attachments` (
    `ID`                INT             NOT NULL AUTO_INCREMENT,
    `communication_id`  INT             NOT NULL,
    `file_name`         VARCHAR(500)    NOT NULL  COMMENT 'Original file name',
    `file_path`         VARCHAR(1000)   NOT NULL  COMMENT 'Server-relative path',
    `file_type`         VARCHAR(100)    NULL      COMMENT 'MIME type e.g. application/pdf',
    `file_size`         BIGINT          NOT NULL DEFAULT 0  COMMENT 'Size in bytes',
    `uploaded_at`       DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`ID`),
    INDEX `idx_attach_comm` (`communication_id`),
    CONSTRAINT `fk_attach_comm` FOREIGN KEY (`communication_id`)
        REFERENCES `sys_communications` (`ID`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ───────────────────────────────────────────────────────────────
-- TABLE 3: sys_communication_reads
-- Tracks which users have read and/or confirmed each communication.
-- ───────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS `sys_communication_reads` (
    `ID`                INT             NOT NULL AUTO_INCREMENT,
    `communication_id`  INT             NOT NULL,
    `user_id`           VARCHAR(100)    NOT NULL  COMMENT 'Registration No or Staff username',
    `user_type`         VARCHAR(20)     NOT NULL  COMMENT 'STUDENT | STAFF',
    `user_name`         VARCHAR(200)    NULL      COMMENT 'Display name at time of read',
    `read_at`           DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `confirmed_at`      DATETIME        NULL      COMMENT 'When user clicked I HAVE READ THIS NOTICE',
    `confirmation_text` VARCHAR(500)    NULL      COMMENT 'Optional text they typed',
    PRIMARY KEY (`ID`),
    UNIQUE KEY `uq_comm_user` (`communication_id`, `user_id`),
    INDEX `idx_read_user`  (`user_id`),
    INDEX `idx_read_comm`  (`communication_id`),
    INDEX `idx_read_confirmed` (`confirmed_at`),
    CONSTRAINT `fk_read_comm` FOREIGN KEY (`communication_id`)
        REFERENCES `sys_communications` (`ID`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ───────────────────────────────────────────────────────────────
-- TABLE 4: sys_communication_comments
-- User comments on a communication.
-- ───────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS `sys_communication_comments` (
    `ID`                INT             NOT NULL AUTO_INCREMENT,
    `communication_id`  INT             NOT NULL,
    `user_id`           VARCHAR(100)    NOT NULL,
    `user_type`         VARCHAR(20)     NOT NULL  COMMENT 'STUDENT | STAFF',
    `user_name`         VARCHAR(200)    NULL,
    `comment_text`      TEXT            NOT NULL,
    `created_at`        DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`ID`),
    INDEX `idx_comment_comm` (`communication_id`),
    CONSTRAINT `fk_comment_comm` FOREIGN KEY (`communication_id`)
        REFERENCES `sys_communications` (`ID`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ═══════════════════════════════════════════════════════════════════════════
-- DUMMY DATA — for testing
-- ═══════════════════════════════════════════════════════════════════════════

INSERT INTO `sys_communications`
    (`title`, `content`, `target_audience`, `is_force_read`, `force_read_expiry`, `priority`, `status`, `allow_comments`, `created_by`, `created_by_name`, `published_at`)
VALUES
    ('Welcome to Semester II 2024/2025',
     '<h3>Dear Students and Staff,</h3><p>We are pleased to welcome you to Semester II of the 2024/2025 academic year. Please take note of the following important dates:</p><ul><li><strong>Lectures begin:</strong> 3rd February 2025</li><li><strong>Mid-semester exams:</strong> 17th - 21st March 2025</li><li><strong>End of semester exams:</strong> 26th May - 6th June 2025</li></ul><p>We wish you a productive and successful semester.</p><p><em>Office of the Academic Registrar</em></p>',
     'BOTH', 1, '2025-03-01 23:59:59', 'HIGH', 'PUBLISHED', 1,
     'admin', 'Academic Registrar', NOW()),

    ('Library Operating Hours Update',
     '<h3>Updated Library Hours</h3><p>Effective immediately, the university library will observe the following operating hours:</p><table border="1" cellpadding="6" cellspacing="0"><tr><th>Day</th><th>Hours</th></tr><tr><td>Monday - Friday</td><td>7:00 AM - 10:00 PM</td></tr><tr><td>Saturday</td><td>8:00 AM - 6:00 PM</td></tr><tr><td>Sunday</td><td>Closed</td></tr></table><p>Students are encouraged to make use of the quiet study rooms on the 2nd floor.</p>',
     'STUDENT', 0, NULL, 'NORMAL', 'PUBLISHED', 1,
     'admin', 'University Librarian', NOW()),

    ('Staff Development Workshop — ICT Skills',
     '<h3>Mandatory ICT Skills Workshop</h3><p>All academic and administrative staff are required to attend the upcoming ICT Skills Development Workshop.</p><p><strong>Date:</strong> 15th February 2025<br/><strong>Time:</strong> 9:00 AM - 4:00 PM<br/><strong>Venue:</strong> Computer Lab 3, Block C</p><p>Topics covered include:</p><ol><li>Using Campus Dynamics effectively</li><li>Digital assessment tools</li><li>Cybersecurity awareness</li></ol><p>Attendance is compulsory. Please confirm your participation via email to <a href="mailto:ict@mru.ac.ug">ict@mru.ac.ug</a>.</p>',
     'STAFF', 1, '2025-02-15 23:59:59', 'URGENT', 'PUBLISHED', 0,
     'admin', 'ICT Director', NOW()),

    ('Student Guild Elections 2025',
     '<h3>Guild Elections Notice</h3><p>The Electoral Commission is pleased to announce that the Student Guild Elections for the 2024/2025 academic year will be held on <strong>28th February 2025</strong>.</p><p>Key dates:</p><ul><li>Nomination period: 10th - 14th February</li><li>Campaigning: 17th - 27th February</li><li>Voting day: 28th February</li></ul><p>All registered students are eligible to vote. Please carry your student ID card on voting day.</p>',
     'STUDENT', 0, NULL, 'HIGH', 'PUBLISHED', 1,
     'admin', 'Dean of Students', NOW()),

    ('Maintenance Notice — Water Supply',
     '<h3>Scheduled Water Supply Interruption</h3><p>Please be informed that there will be a <strong>scheduled water supply interruption</strong> on campus on Saturday, 8th February 2025, from 6:00 AM to 6:00 PM.</p><p>This is to facilitate maintenance of the main water tank and distribution system.</p><p>We advise all residents and offices to store adequate water before the scheduled date. We apologize for any inconvenience.</p><p><em>Estates Department</em></p>',
     'BOTH', 0, NULL, 'NORMAL', 'DRAFT', 1,
     'admin', 'Estates Manager', NULL);

-- Dummy attachments
INSERT INTO `sys_communication_attachments`
    (`communication_id`, `file_name`, `file_path`, `file_type`, `file_size`)
VALUES
    (1, 'Academic_Calendar_2024_2025.pdf', 'Data_Uploads/Communications/Academic_Calendar_2024_2025.pdf', 'application/pdf', 245760),
    (1, 'Semester_II_Timetable.xlsx', 'Data_Uploads/Communications/Semester_II_Timetable.xlsx', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet', 102400),
    (3, 'ICT_Workshop_Agenda.pdf', 'Data_Uploads/Communications/ICT_Workshop_Agenda.pdf', 'application/pdf', 81920),
    (4, 'Elections_Guidelines.pdf', 'Data_Uploads/Communications/Elections_Guidelines.pdf', 'application/pdf', 163840);

-- Dummy reads
INSERT INTO `sys_communication_reads`
    (`communication_id`, `user_id`, `user_type`, `user_name`, `read_at`, `confirmed_at`, `confirmation_text`)
VALUES
    (1, 'MRU2027000002', 'STUDENT', 'John Doe', '2025-01-20 08:30:00', '2025-01-20 08:31:00', 'I have read this notice'),
    (1, 'MRU2027000003', 'STUDENT', 'Jane Smith', '2025-01-20 09:15:00', NULL, NULL),
    (2, 'MRU2027000002', 'STUDENT', 'John Doe', '2025-01-21 14:00:00', '2025-01-21 14:02:00', 'I have read this notice'),
    (3, 'staff001', 'STAFF', 'Prof. Robert Kamya', '2025-01-22 10:00:00', '2025-01-22 10:05:00', 'I have read this notice'),
    (4, 'MRU2027000002', 'STUDENT', 'John Doe', '2025-01-23 16:30:00', NULL, NULL);

-- Dummy comments
INSERT INTO `sys_communication_comments`
    (`communication_id`, `user_id`, `user_type`, `user_name`, `comment_text`)
VALUES
    (1, 'MRU2027000002', 'STUDENT', 'John Doe', 'Thank you for the update. Where can we access the detailed timetable for evening classes?'),
    (1, 'MRU2027000003', 'STUDENT', 'Jane Smith', 'Looking forward to a great semester!'),
    (2, 'MRU2027000002', 'STUDENT', 'John Doe', 'Can we also get access to the digital library on weekends?'),
    (4, 'MRU2027000002', 'STUDENT', 'John Doe', 'Where do we pick up the nomination forms?');
