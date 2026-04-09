-- ============================================================================
-- ELECTIONS MODULE — Database Migration
-- Campus Dynamics — campus_dynamics database
-- Created: 2026-04-10
-- ============================================================================

-- ─── 1. Election Posts / Positions ──────────────────────────────────────────
CREATE TABLE IF NOT EXISTS elect_post (
    id              INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    post_name       VARCHAR(100) NOT NULL,
    post_code       VARCHAR(30) NOT NULL,
    description     TEXT NULL,
    eligibility     TEXT NULL,
    responsibilities TEXT NULL,
    max_winners     TINYINT UNSIGNED NOT NULL DEFAULT 1,
    display_order   INT NOT NULL DEFAULT 0,
    is_active       TINYINT(1) NOT NULL DEFAULT 1,
    created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      DATETIME NULL ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uq_post_code (post_code),
    INDEX idx_post_active (is_active),
    INDEX idx_post_order (display_order)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ─── 2. Elections ───────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS elect_election (
    id              INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    election_name   VARCHAR(200) NOT NULL,
    description     TEXT NULL,
    acad_year       VARCHAR(20) NULL,
    start_date      DATETIME NOT NULL,
    end_date        DATETIME NOT NULL,
    status          ENUM('Draft','Upcoming','Nominations','Active','Closed','Cancelled')
                    NOT NULL DEFAULT 'Draft',
    require_registration TINYINT(1) NOT NULL DEFAULT 1,
    require_fees_cleared TINYINT(1) NOT NULL DEFAULT 0,
    allowed_programmes   TEXT NULL,
    allowed_entry_years  TEXT NULL,
    show_live_results    TINYINT(1) NOT NULL DEFAULT 0,
    show_vote_counts     TINYINT(1) NOT NULL DEFAULT 1,
    results_public       TINYINT(1) NOT NULL DEFAULT 0,
    created_by      VARCHAR(50) NULL,
    created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      DATETIME NULL ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_election_status (status),
    INDEX idx_election_dates (start_date, end_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ─── 3. Candidates ─────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS elect_candidate (
    id              INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    election_id     INT UNSIGNED NOT NULL,
    post_id         INT UNSIGNED NOT NULL,
    regno           VARCHAR(50) NOT NULL,
    candidate_name  VARCHAR(200) NOT NULL,
    photo_url       VARCHAR(500) NULL,
    manifesto       TEXT NULL,
    slogan          VARCHAR(200) NULL,
    status          ENUM('Pending','Approved','Rejected','Withdrawn','Disqualified')
                    NOT NULL DEFAULT 'Pending',
    rejection_reason VARCHAR(500) NULL,
    display_order   INT NOT NULL DEFAULT 0,
    created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      DATETIME NULL ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uq_candidate_election_post (election_id, post_id, regno),
    INDEX idx_candidate_election (election_id),
    INDEX idx_candidate_post (post_id),
    INDEX idx_candidate_status (status),
    FOREIGN KEY (election_id) REFERENCES elect_election(id) ON DELETE CASCADE,
    FOREIGN KEY (post_id) REFERENCES elect_post(id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ─── 4. Eligible Voters ────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS elect_voter (
    id              INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    election_id     INT UNSIGNED NOT NULL,
    regno           VARCHAR(50) NOT NULL,
    voter_name      VARCHAR(200) NULL,
    email           VARCHAR(200) NULL,
    programme       VARCHAR(100) NULL,
    vote_token      VARCHAR(64) NULL,
    has_voted       TINYINT(1) NOT NULL DEFAULT 0,
    voted_at        DATETIME NULL,
    ip_address      VARCHAR(45) NULL,
    user_agent      VARCHAR(500) NULL,
    is_eligible     TINYINT(1) NOT NULL DEFAULT 1,
    created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_voter_election (election_id, regno),
    INDEX idx_voter_election (election_id),
    INDEX idx_voter_token (vote_token),
    INDEX idx_voter_voted (election_id, has_voted),
    FOREIGN KEY (election_id) REFERENCES elect_election(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ─── 5. Individual Votes (Ballot Entries) ──────────────────────────────────
CREATE TABLE IF NOT EXISTS elect_vote (
    id              INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    election_id     INT UNSIGNED NOT NULL,
    post_id         INT UNSIGNED NOT NULL,
    candidate_id    INT UNSIGNED NOT NULL,
    voter_id        INT UNSIGNED NOT NULL,
    vote_token      VARCHAR(64) NOT NULL,
    cast_at         DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_vote_per_post (election_id, post_id, voter_id),
    INDEX idx_vote_candidate (candidate_id),
    INDEX idx_vote_election_post (election_id, post_id),
    FOREIGN KEY (election_id) REFERENCES elect_election(id) ON DELETE RESTRICT,
    FOREIGN KEY (post_id) REFERENCES elect_post(id) ON DELETE RESTRICT,
    FOREIGN KEY (candidate_id) REFERENCES elect_candidate(id) ON DELETE RESTRICT,
    FOREIGN KEY (voter_id) REFERENCES elect_voter(id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ─── 6. Computed Results (Materialised View) ───────────────────────────────
CREATE TABLE IF NOT EXISTS elect_result (
    id              INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    election_id     INT UNSIGNED NOT NULL,
    post_id         INT UNSIGNED NOT NULL,
    candidate_id    INT UNSIGNED NOT NULL,
    vote_count      INT UNSIGNED NOT NULL DEFAULT 0,
    percentage      DECIMAL(5,2) NOT NULL DEFAULT 0.00,
    rank_position   TINYINT UNSIGNED NULL,
    is_winner       TINYINT(1) NOT NULL DEFAULT 0,
    is_tie          TINYINT(1) NOT NULL DEFAULT 0,
    computed_at     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_result (election_id, post_id, candidate_id),
    INDEX idx_result_election (election_id),
    INDEX idx_result_winner (election_id, is_winner),
    FOREIGN KEY (election_id) REFERENCES elect_election(id) ON DELETE CASCADE,
    FOREIGN KEY (post_id) REFERENCES elect_post(id) ON DELETE RESTRICT,
    FOREIGN KEY (candidate_id) REFERENCES elect_candidate(id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


-- ═══════════════════════════════════════════════════════════════════════════
-- SEED DATA — Default election posts
-- ═══════════════════════════════════════════════════════════════════════════

INSERT INTO elect_post (post_name, post_code, description, eligibility, responsibilities, max_winners, display_order, is_active) VALUES
('Guild President',        'PRES',  'Chief executive of the Students\' Guild. Represents the student body at all university forums.', 'Must be a continuing student in good academic standing with no disciplinary record.', 'Chairs Guild Council meetings, represents students at Senate, manages Guild budget, coordinates student welfare activities.', 1, 1, 1),
('Vice President',         'VP',    'Deputy to the Guild President. Assumes presidential duties in absence of the President.', 'Must be a continuing student in good academic standing.', 'Assists the President, oversees Guild committees, coordinates inter-faculty activities, acts as President in their absence.', 1, 2, 1),
('Secretary General',      'SEC',   'Chief administrative officer of the Guild. Manages all Guild records and communications.', 'Must be a continuing student with good organizational skills.', 'Records minutes of Guild meetings, manages official correspondence, maintains Guild documents, coordinates communication between Guild and student body.', 1, 3, 1),
('Treasurer',              'TRES',  'Chief financial officer of the Guild. Manages Guild funds and financial reporting.', 'Must be a continuing student, preferably with financial knowledge.', 'Manages Guild bank accounts, prepares financial reports, oversees Guild budget, ensures transparency in financial matters.', 1, 4, 1),
('Speaker',                'SPKR',  'Presiding officer of the Guild Parliament/General Assembly.', 'Must be a continuing student with knowledge of parliamentary procedure.', 'Presides over Guild General Assembly, ensures order during debates, interprets Guild constitution, manages parliamentary procedures.', 1, 5, 1),
('Minister of Academic Affairs', 'ACAD', 'Oversees academic welfare and represents students on academic matters.', 'Must be a continuing student in good academic standing.', 'Addresses academic complaints, liaises with faculty on curriculum matters, organizes academic workshops, represents students at Academic Board.', 1, 6, 1),
('Minister of Social Affairs',  'SOC',  'Coordinates social events and student welfare programmes.', 'Must be a continuing student.', 'Organizes social events, coordinates freshers\' welcome, manages student clubs liaison, oversees entertainment activities.', 1, 7, 1),
('Minister of Health',          'HLTH', 'Advocates for student health and wellness services.', 'Must be a continuing student.', 'Coordinates with university health services, organizes health awareness campaigns, advocates for improved health facilities.', 1, 8, 1);


-- ═══════════════════════════════════════════════════════════════════════════
-- SEED DATA — Sample election with candidates for testing
-- ═══════════════════════════════════════════════════════════════════════════

INSERT INTO elect_election (election_name, description, acad_year, start_date, end_date, status, created_by) VALUES
('Guild Elections 2025/2026', 'Annual Students\' Guild Leadership Elections for the 2025/2026 academic year.', '2025/2026', '2026-04-15 08:00:00', '2026-04-17 17:00:00', 'Draft', 'admin');

-- Note: Candidate and voter data will be added once actual student regnos are available.
-- The admin page provides UI to import voters and add candidates.

SELECT 'Elections module migration completed successfully.' AS result;
SELECT CONCAT('Created ', COUNT(*), ' election posts.') AS result FROM elect_post;
SELECT CONCAT('Created ', COUNT(*), ' elections.') AS result FROM elect_election;
