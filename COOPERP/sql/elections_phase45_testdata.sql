-- ═══════════════════════════════════════════════════════════════════════════
-- Elections Phase 4.5 — Test Data: Nominations Election + Self-Nomination
-- Run after elections_migration.sql and elections_phase3_testdata.sql
-- ═══════════════════════════════════════════════════════════════════════════

-- ── 1. Create a Nominations-status election ─────────────────────────────
INSERT INTO elect_election (
    election_name, description, acad_year, 
    start_date, end_date, status,
    require_registration, require_fees_cleared,
    show_live_results, show_vote_counts, results_public,
    created_by, created_at
) VALUES (
    'Student Council Elections 2025/2026',
    'Elect your Student Council representatives for the 2025/2026 academic year. Nominations are now open — apply to stand for any available position!',
    '2025/2026',
    DATE_ADD(NOW(), INTERVAL 14 DAY),
    DATE_ADD(NOW(), INTERVAL 28 DAY),
    'Nominations',
    1, 0,
    1, 1, 0,
    'admin',
    NOW()
);

SET @nom_election_id = LAST_INSERT_ID();

-- ── 2. Ensure standard posts exist ──────────────────────────────────────
-- (Posts are global, not per-election. These may already exist.)
INSERT IGNORE INTO elect_post (post_name, description, is_active, display_order) VALUES
    ('President', 'Head of the Student Council', 1, 1),
    ('Vice President', 'Deputy Head of the Student Council', 1, 2),
    ('Secretary General', 'Oversees documentation and communications', 1, 3),
    ('Treasurer', 'Manages student council finances', 1, 4),
    ('Speaker', 'Presides over council meetings and debates', 1, 5),
    ('Minister of Academics', 'Advocates for academic quality and student academic welfare', 1, 6),
    ('Minister of Welfare', 'Handles student welfare, health, and accommodation issues', 1, 7),
    ('Minister of Sports', 'Coordinates sports and recreational activities', 1, 8);

-- ── 3. Add a couple of early self-nominations (simulate students who applied) ─
-- Get post IDs dynamically
SET @pres_id = (SELECT id FROM elect_post WHERE post_name = 'President' LIMIT 1);
SET @vp_id = (SELECT id FROM elect_post WHERE post_name = 'Vice President' LIMIT 1);
SET @sec_id = (SELECT id FROM elect_post WHERE post_name = 'Secretary General' LIMIT 1);

-- Self-nomination: one Pending, one Approved (simulating admin review)
INSERT INTO elect_candidate
    (election_id, post_id, regno, candidate_name, slogan, manifesto, status, created_at)
VALUES
    (@nom_election_id, @pres_id, '2024/JAN/BSE/0001',
     'John Mukasa',
     'Leadership Through Service',
     'As your President, I will:\n1. Improve campus Wi-Fi coverage to all hostels\n2. Establish a Student Emergency Fund\n3. Create monthly Town Hall meetings\n4. Advocate for extended library hours during exam season\n5. Launch a peer mentorship programme',
     'Pending',
     DATE_SUB(NOW(), INTERVAL 2 DAY)),

    (@nom_election_id, @vp_id, '2024/JAN/BBA/0002',
     'Sarah Nalubega',
     'Together We Rise',
     'My vision for Vice President:\n- Bridge the gap between students and administration\n- Champion mental health awareness and support services\n- Organize inter-faculty cultural festivals\n- Push for affordable meal plans in the cafeteria',
     'Approved',
     DATE_SUB(NOW(), INTERVAL 1 DAY));

-- ── 4. Add some voters for the nominations election ─────────────────────
INSERT INTO elect_voter (election_id, regno, voter_name, email, programme, is_eligible)
VALUES
    (@nom_election_id, '2024/JAN/BSE/0001', 'John Mukasa', 'john.mukasa@mru.ac.ug', 'BSE', 1),
    (@nom_election_id, '2024/JAN/BBA/0002', 'Sarah Nalubega', 'sarah.n@mru.ac.ug', 'BBA', 1),
    (@nom_election_id, '2024/JAN/BSE/0003', 'Peter Okello', 'peter.o@mru.ac.ug', 'BSE', 1),
    (@nom_election_id, '2024/JAN/BIT/0004', 'Grace Nambi', 'grace.n@mru.ac.ug', 'BIT', 1),
    (@nom_election_id, '2024/JAN/BBA/0005', 'David Ssempijja', 'david.s@mru.ac.ug', 'BBA', 1);

-- ── 5. Also create an Upcoming election for auto-transition testing ─────
INSERT INTO elect_election (
    election_name, description, acad_year,
    start_date, end_date, status,
    require_registration, require_fees_cleared,
    show_live_results, show_vote_counts, results_public,
    created_by, created_at
) VALUES (
    'Faculty of Science Representatives 2025',
    'Election of faculty representatives for the Faculty of Science.',
    '2025/2026',
    DATE_ADD(NOW(), INTERVAL 30 DAY),
    DATE_ADD(NOW(), INTERVAL 44 DAY),
    'Upcoming',
    1, 0,
    0, 1, 0,
    'admin',
    NOW()
);

-- ── Verification Queries ────────────────────────────────────────────────
SELECT 'Elections by Status' AS `Check`;
SELECT status, COUNT(*) AS cnt FROM elect_election GROUP BY status ORDER BY FIELD(status, 'Draft','Upcoming','Nominations','Active','Closed','Cancelled');

SELECT 'Nominations Election Details' AS `Check`;
SELECT id, election_name, status, start_date, end_date FROM elect_election WHERE status = 'Nominations';

SELECT 'Candidate Applications' AS `Check`;
SELECT c.candidate_name, c.status, p.post_name, e.election_name
FROM elect_candidate c
JOIN elect_post p ON p.id = c.post_id
JOIN elect_election e ON e.id = c.election_id
WHERE e.status = 'Nominations';

SELECT 'All Posts Available' AS `Check`;
SELECT id, post_name, is_active, display_order FROM elect_post ORDER BY display_order;

SELECT 'Phase 4.5 seed data loaded successfully!' AS Result;
