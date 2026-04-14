# 🗳️ University Leaders Elections Module — Implementation Plan

> **Project:** Campus Dynamics – Elections Module  
> **Version:** 1.0  
> **Created:** 2026-04-10  
> **Platform:** ASP.NET 4.0 / C# / MySQL / DevExpress v16.1  
> **Databases:** `campus_dynamics` (main), `campus_dynamics_portal` (portal)

---

## Table of Contents

1. [Architecture Overview](#1-architecture-overview)
2. [Database Schema](#2-database-schema)
3. [Security & Integrity Design](#3-security--integrity-design)
4. [Implementation Tasks](#4-implementation-tasks)
5. [File Inventory](#5-file-inventory)
6. [Edge Cases & Scenarios](#6-edge-cases--scenarios)
7. [Testing Checklist](#7-testing-checklist)

---

## 1. Architecture Overview

### System Components

```
┌─────────────────────────────────────────────────────────────────┐
│                    ADMIN PORTAL (COOPERP)                       │
│  ┌──────────────────┐  ┌───────────────┐  ┌─────────────────┐  │
│  │ Elections         │  │ Posts         │  │ Candidates      │  │
│  │ Dashboard         │  │ Management   │  │ Management      │  │
│  └──────────────────┘  └───────────────┘  └─────────────────┘  │
│  ┌──────────────────┐  ┌───────────────┐  ┌─────────────────┐  │
│  │ Voter             │  │ Live Results │  │ Audit &         │  │
│  │ Management        │  │ Monitor      │  │ Reports         │  │
│  └──────────────────┘  └───────────────┘  └─────────────────┘  │
├─────────────────────────────────────────────────────────────────┤
│                  STUDENT PORTAL                                  │
│  ┌──────────────────┐  ┌───────────────┐  ┌─────────────────┐  │
│  │ Election Home     │  │ Voting Booth │  │ Live Results    │  │
│  │ (view candidates)│  │ (cast votes) │  │ (real-time)     │  │
│  └──────────────────┘  └───────────────┘  └─────────────────┘  │
├─────────────────────────────────────────────────────────────────┤
│                   SHARED DATA LAYER                              │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │  App_Code/Elections/ElectionsHelper.cs (admin)           │   │
│  │  App_Code/Portal/ElectionsPortalHelper.cs (portal)       │   │
│  │  MySQL tables: elect_* (6 tables)                        │   │
│  └──────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
```

### Design Principles

| Principle | Implementation |
|-----------|----------------|
| **Modularity** | All election tables prefixed `elect_`, all CSS prefixed `el-`, standalone helper classes |
| **Scalability** | Indexed vote table, batch voter import, paginated results |
| **Security** | SHA-256 vote tokens, one-vote-per-post constraint, server-side validation, no client-side vote data |
| **Integrity** | DB-level UNIQUE constraints, transaction-wrapped voting, audit trail |
| **UX** | responsive design, live results via AJAX polling, step-by-step voting wizard |

---

## 2. Database Schema

### 2.1 `elect_post` — Election Posts/Positions

```sql
CREATE TABLE elect_post (
    id              INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    post_name       VARCHAR(100) NOT NULL,          -- e.g., "Guild President"
    post_code       VARCHAR(30) NOT NULL UNIQUE,    -- e.g., "PRES", "VP", "SEC"
    description     TEXT NULL,                       -- What the post entails
    eligibility     TEXT NULL,                       -- Who can run for this post
    responsibilities TEXT NULL,                      -- Key responsibilities
    max_winners     TINYINT UNSIGNED NOT NULL DEFAULT 1, -- Usually 1, but some posts elect multiple
    display_order   INT NOT NULL DEFAULT 0,          -- Order posts appear on ballot
    is_active       TINYINT(1) NOT NULL DEFAULT 1,
    created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      DATETIME NULL ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_post_active (is_active),
    INDEX idx_post_order (display_order)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
```

### 2.2 `elect_election` — Elections

```sql
CREATE TABLE elect_election (
    id              INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    election_name   VARCHAR(200) NOT NULL,           -- e.g., "Guild Elections 2026"
    description     TEXT NULL,
    acad_year       VARCHAR(20) NULL,                -- Linked academic year
    start_date      DATETIME NOT NULL,               -- Voting opens
    end_date        DATETIME NOT NULL,               -- Voting closes
    status          ENUM('Draft','Upcoming','Nominations','Active','Closed','Cancelled')
                    NOT NULL DEFAULT 'Draft',
    -- Voting configuration
    require_registration TINYINT(1) NOT NULL DEFAULT 1, -- Must be registered student
    require_fees_cleared TINYINT(1) NOT NULL DEFAULT 0, -- Must have cleared fees
    allowed_programmes   TEXT NULL,                      -- JSON array of progcodes, NULL = all
    allowed_entry_years  TEXT NULL,                      -- JSON array of entry years, NULL = all
    -- Display settings
    show_live_results    TINYINT(1) NOT NULL DEFAULT 0, -- Show results during voting?
    show_vote_counts     TINYINT(1) NOT NULL DEFAULT 1, -- Show actual numbers or just bars
    results_public       TINYINT(1) NOT NULL DEFAULT 0, -- Public results page (no login)
    -- Audit
    created_by      VARCHAR(50) NULL,
    created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      DATETIME NULL ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_election_status (status),
    INDEX idx_election_dates (start_date, end_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
```

### 2.3 `elect_candidate` — Candidates

```sql
CREATE TABLE elect_candidate (
    id              INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    election_id     INT UNSIGNED NOT NULL,
    post_id         INT UNSIGNED NOT NULL,
    regno           VARCHAR(50) NOT NULL,            -- Student reg number
    candidate_name  VARCHAR(200) NOT NULL,           -- Display name
    photo_url       VARCHAR(500) NULL,               -- Photo path
    manifesto       TEXT NULL,                        -- Candidate manifesto
    slogan          VARCHAR(200) NULL,               -- Short campaign slogan
    status          ENUM('Pending','Approved','Rejected','Withdrawn','Disqualified')
                    NOT NULL DEFAULT 'Pending',
    rejection_reason VARCHAR(500) NULL,
    display_order   INT NOT NULL DEFAULT 0,          -- Order on ballot (randomised or fixed)
    created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      DATETIME NULL ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uq_candidate_election_post (election_id, post_id, regno),
    INDEX idx_candidate_election (election_id),
    INDEX idx_candidate_post (post_id),
    INDEX idx_candidate_status (status),
    FOREIGN KEY (election_id) REFERENCES elect_election(id) ON DELETE CASCADE,
    FOREIGN KEY (post_id) REFERENCES elect_post(id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
```

### 2.4 `elect_voter` — Eligible Voters

```sql
CREATE TABLE elect_voter (
    id              INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    election_id     INT UNSIGNED NOT NULL,
    regno           VARCHAR(50) NOT NULL,            -- Student reg number
    voter_name      VARCHAR(200) NULL,               -- Cached display name
    email           VARCHAR(200) NULL,               -- For notification
    programme       VARCHAR(100) NULL,               -- Cached programme code
    vote_token      VARCHAR(64) NULL,                -- SHA-256 token (issued when voting starts)
    has_voted       TINYINT(1) NOT NULL DEFAULT 0,   -- Master flag: has this voter cast ANY vote?
    voted_at        DATETIME NULL,                   -- When they completed voting
    ip_address      VARCHAR(45) NULL,                -- IP at time of vote submission
    user_agent      VARCHAR(500) NULL,               -- Browser info for audit
    is_eligible     TINYINT(1) NOT NULL DEFAULT 1,   -- Admin can revoke eligibility
    created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_voter_election (election_id, regno),
    INDEX idx_voter_election (election_id),
    INDEX idx_voter_token (vote_token),
    INDEX idx_voter_voted (election_id, has_voted),
    FOREIGN KEY (election_id) REFERENCES elect_election(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
```

### 2.5 `elect_vote` — Individual Votes (Ballot Entries)

```sql
CREATE TABLE elect_vote (
    id              INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    election_id     INT UNSIGNED NOT NULL,
    post_id         INT UNSIGNED NOT NULL,
    candidate_id    INT UNSIGNED NOT NULL,
    voter_id        INT UNSIGNED NOT NULL,
    vote_token      VARCHAR(64) NOT NULL,            -- Matches voter token for verification
    cast_at         DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    -- CRITICAL: One vote per voter per post per election
    UNIQUE KEY uq_vote_per_post (election_id, post_id, voter_id),
    INDEX idx_vote_candidate (candidate_id),
    INDEX idx_vote_election_post (election_id, post_id),
    FOREIGN KEY (election_id) REFERENCES elect_election(id) ON DELETE RESTRICT,
    FOREIGN KEY (post_id) REFERENCES elect_post(id) ON DELETE RESTRICT,
    FOREIGN KEY (candidate_id) REFERENCES elect_candidate(id) ON DELETE RESTRICT,
    FOREIGN KEY (voter_id) REFERENCES elect_voter(id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
```

### 2.6 `elect_result` — Computed Results (Materialised View)

```sql
CREATE TABLE elect_result (
    id              INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    election_id     INT UNSIGNED NOT NULL,
    post_id         INT UNSIGNED NOT NULL,
    candidate_id    INT UNSIGNED NOT NULL,
    vote_count      INT UNSIGNED NOT NULL DEFAULT 0,
    percentage      DECIMAL(5,2) NOT NULL DEFAULT 0.00,
    rank_position   TINYINT UNSIGNED NULL,           -- 1 = winner, 2 = runner-up, etc.
    is_winner       TINYINT(1) NOT NULL DEFAULT 0,
    is_tie          TINYINT(1) NOT NULL DEFAULT 0,   -- Flag if tied for position
    computed_at     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_result (election_id, post_id, candidate_id),
    INDEX idx_result_election (election_id),
    INDEX idx_result_winner (election_id, is_winner),
    FOREIGN KEY (election_id) REFERENCES elect_election(id) ON DELETE CASCADE,
    FOREIGN KEY (post_id) REFERENCES elect_post(id) ON DELETE RESTRICT,
    FOREIGN KEY (candidate_id) REFERENCES elect_candidate(id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
```

### 2.7 Entity Relationship Diagram

```
elect_election (1) ──────< (N) elect_candidate >────── (1) elect_post
      │                            │
      │                            │
      ├───< (N) elect_voter        ├───< (N) elect_vote
      │          │                 │
      │          └─────────────────┘ (voter_id → elect_voter)
      │
      └───< (N) elect_result >────── candidate, post
```

---

## 3. Security & Integrity Design

### 3.1 Vote Token System

```
┌──────────────────────────────────────────────────────┐
│ Token Generation (when student clicks "Start Voting") │
│                                                        │
│  token = SHA256(election_id + "|" + regno + "|" +     │
│          DateTime.UtcNow.Ticks + "|" + Guid.NewGuid())│
│                                                        │
│  → Stored in elect_voter.vote_token                   │
│  → Stored in Session["vote_token_" + election_id]     │
│  → Must match on every vote submission                │
└──────────────────────────────────────────────────────┘
```

### 3.2 Vote Submission Flow

```
Student clicks "Vote for [Candidate X]" for Post Y
    │
    ├── Server validates:
    │   ├── 1. Session["username"] is valid student
    │   ├── 2. Election is currently Active (start ≤ NOW ≤ end)
    │   ├── 3. Student is in elect_voter for this election
    │   ├── 4. elect_voter.is_eligible = 1
    │   ├── 5. vote_token matches Session token
    │   ├── 6. Candidate is Approved and belongs to this election/post
    │   ├── 7. No existing vote for this voter + post (DB UNIQUE check)
    │   └── 8. Anti-CSRF: form token validation
    │
    ├── BEGIN TRANSACTION
    │   ├── INSERT INTO elect_vote (...)
    │   ├── UPDATE elect_voter SET has_voted=1, voted_at=NOW()
    │   │   WHERE id=@voter AND has_voted=0
    │   └── COMMIT (or ROLLBACK on any failure)
    │
    └── Return JSON: {ok: true, post_id: Y, remaining: N}
```

### 3.3 Anti-Fraud Measures

| Threat | Mitigation |
|--------|------------|
| Double voting | DB `UNIQUE KEY uq_vote_per_post` + application check |
| Vote manipulation | All writes in transactions, vote_token validation |
| Session hijacking | Tokens bound to session, IP logged |
| Voter impersonation | Portal auth (Session["username"]) + enrollment gate |
| Admin tampering | Audit trail: created_by, timestamps, IP logging |
| Ballot stuffing | Voter records pre-generated from enrolled students |
| CSRF attacks | ASP.NET `__VIEWSTATEVALIDATION` + custom anti-forgery |
| Result falsification | Results computed from raw votes, not stored independently during voting |
| Ties | Explicit tie detection with `is_tie` flag, admin resolution workflow |

---

## 4. Implementation Tasks

### Legend

| Priority | Meaning |
|----------|---------|
| 🔴 P0 | Critical — blocks all other work |
| 🟠 P1 | High — core functionality |
| 🟡 P2 | Medium — important UX |
| 🟢 P3 | Low — polish & enhancement |

| Status | Meaning |
|--------|---------|
| ⬜ | Not Started |
| 🔄 | In Progress |
| ✅ | Completed |
| 🚫 | Blocked |

---

### Phase 1: Foundation (Database + Data Layer)

#### Task 1.1 — Create Database Tables
- **Priority:** 🔴 P0
- **Status:** ⬜ Not Started
- **Description:** Run the migration SQL to create all 6 `elect_*` tables in the `campus_dynamics` database.
- **Files:**
  - `COOPERP/sql/elections_migration.sql` (new)
- **Steps:**
  1. Create the migration SQL file with all 6 CREATE TABLE statements
  2. Include necessary indexes and foreign keys
  3. Add INSERT statements for default posts (President, Vice President, Secretary, Treasurer, Speaker, etc.)
  4. Execute against local MySQL
  5. Verify tables created correctly with `DESCRIBE` commands
- **Acceptance:** All 6 tables exist with correct columns, indexes, and FK constraints.

#### Task 1.2 — Create Admin ElectionsHelper.cs
- **Priority:** 🔴 P0
- **Status:** ⬜ Not Started
- **Description:** Centralized data-access class for all election operations in the admin portal.
- **File:** `App_Code/Elections/ElectionsHelper.cs` (new)
- **Methods to implement:**
  ```
  // ── Posts ──
  GetAllPosts(bool activeOnly)           → DataTable
  GetPost(int postId)                    → DataRow
  SavePost(int id, string name, string code, string desc, string eligibility, 
           string responsibilities, int maxWinners, int displayOrder, bool isActive)
  DeletePost(int postId)

  // ── Elections ──
  GetAllElections(string statusFilter)   → DataTable
  GetElection(int electionId)            → DataRow
  SaveElection(int id, string name, string desc, string acadYear,
               DateTime start, DateTime end, string status, ...)
  UpdateElectionStatus(int electionId, string newStatus)
  DeleteElection(int electionId)

  // ── Candidates ──
  GetCandidates(int electionId, int postId, string statusFilter) → DataTable
  GetCandidate(int candidateId)          → DataRow
  SaveCandidate(int id, int electionId, int postId, string regno, 
                string name, string photo, string manifesto, string slogan, string status)
  UpdateCandidateStatus(int candidateId, string status, string reason)

  // ── Voters ──
  GetVoters(int electionId, string searchTerm, bool? hasVoted) → DataTable
  GetVoterCount(int electionId)          → int[]  {total, voted, eligible}
  ImportVotersFromRegistered(int electionId, string progFilter, string yearFilter)
  ImportAllEligibleVoters(int electionId)
  RevokeVoterEligibility(int voterId, bool eligible)

  // ── Votes & Results ──
  GetVoteSummary(int electionId)         → DataTable (post, candidate, count)
  ComputeResults(int electionId)         → void (populates elect_result)
  GetResults(int electionId)             → DataTable
  GetLiveVoteCounts(int electionId)      → JSON string (for AJAX polling)

  // ── Utilities ──
  GenerateVoteToken(int electionId, string regno) → string
  ValidateVoteToken(int electionId, string regno, string token) → bool
  GetElectionStats(int electionId)       → DataRow {voters, voted, turnout%, posts, candidates}
  ```
- **Design Notes:**
  - Use `ConfigurationManager.ConnectionStrings["vacConnectionString"]` for DB access
  - All methods static, parameterised queries only
  - Transaction-wrap multi-statement operations
  - Private helpers: `ExecuteScalar()`, `ExecuteNonQuery()`, `ExecuteDataTable()`, `P()` (parameter factory)
- **Acceptance:** All CRUD methods work against the 6 tables, parameterised queries, no SQL injection.

#### Task 1.3 — Create Portal ElectionsPortalHelper.cs
- **Priority:** 🔴 P0
- **Status:** ⬜ Not Started
- **Description:** Student-facing data-access class for voting operations.
- **File:** `CampusDynamics_Portal/App_Code/Portal/ElectionsPortalHelper.cs` (new)
- **Methods to implement:**
  ```
  // ── Election Discovery ──
  GetActiveElections(string regno)       → DataTable  (elections the student can vote in)
  GetElectionDetail(int electionId)      → DataRow
  GetElectionPosts(int electionId)       → DataTable  (posts + candidate count)

  // ── Candidates ──
  GetApprovedCandidates(int electionId, int postId) → DataTable
  GetCandidateDetail(int candidateId)    → DataRow

  // ── Voting ──
  GetOrCreateVoterRecord(int electionId, string regno) → DataRow
  HasVotedForPost(int electionId, string regno, int postId) → bool
  GetVotingProgress(int electionId, string regno) → DataTable {post_id, post_name, has_voted}
  CastVote(int electionId, int postId, int candidateId, 
           string regno, string voteToken, string ip, string userAgent) → VoteResult
  GenerateAndStoreToken(int electionId, string regno) → string
  ValidateToken(int electionId, string regno, string token) → bool

  // ── Results ──
  GetLiveResults(int electionId)         → JSON string
  CanViewResults(int electionId)         → bool
  
  // ── Return type ──
  struct VoteResult { bool Success; string Message; int RemainingPosts; }
  ```
- **Design Notes:**
  - Connection string: `campus_dynamics_portalConnectionString` → fallback to `vacConnectionString`
  - Cross-database queries reference `campus_dynamics.acad_student` for student info
  - All vote operations wrapped in MySQL transactions
  - Token generation uses `System.Security.Cryptography.SHA256`
- **Acceptance:** Vote operations are atomic, tokens validated, double-vote prevented at DB level.

---

### Phase 2: Admin Portal — Election Management

#### Task 2.1 — Elections Dashboard Page
- **Priority:** 🟠 P1
- **Status:** ⬜ Not Started
- **Description:** Main dashboard showing elections overview with stats cards, quick actions, and election list.
- **Files:**
  - `COOPERP/NewScreens/ElectionsDashboard.aspx` (new)
  - `COOPERP/NewScreens/ElectionsDashboard.aspx.cs` (new)
- **Layout:**
  ```
  ┌─────────────────────────────────────────────────┐
  │ 📊 Stats Cards Row                              │
  │ [Total Elections] [Active] [Upcoming] [Total    │
  │                                       Voters]   │
  ├─────────────────────────────────────────────────┤
  │ 🗳️ Elections List (sortable table)              │
  │ ┌──────┬──────────┬────────┬────────┬─────────┐ │
  │ │ Name │ Period   │ Status │ Voters │ Actions │ │
  │ ├──────┼──────────┼────────┼────────┼─────────┤ │
  │ │ ...  │ ...      │ Badge  │ 150/200│ Manage  │ │
  │ └──────┴──────────┴────────┴────────┴─────────┘ │
  ├─────────────────────────────────────────────────┤
  │ ➕ Create New Election (button)                  │
  └─────────────────────────────────────────────────┘
  ```
- **Features:**
  - Stats cards: Total elections, Active elections, Upcoming, Total voters across all
  - Filterable table of elections with status badges (colour-coded)
  - Quick action buttons: Open, Edit, Archive, Delete
  - "Create New Election" button opens the election editor
- **CSS Prefix:** `el-`
- **Master Page:** `SidebarMaster.master`
- **Acceptance:** Dashboard loads with accurate stats, elections listed with correct statuses.

#### Task 2.2 — Election Editor (Create/Edit Election)
- **Priority:** 🟠 P1
- **Status:** ⬜ Not Started
- **Description:** Modal or inline form to create and configure elections.
- **Integrated into:** `ElectionsDashboard.aspx` (modal panel)
- **Fields:**
  - Election Name (required)
  - Description (textarea)
  - Academic Year (dropdown from `acad_acadyears`)
  - Start Date/Time, End Date/Time (datetime pickers)
  - Status (dropdown: Draft → Upcoming → Nominations → Active → Closed)
  - Configuration checkboxes:
    - ☑ Require active registration
    - ☑ Require fees cleared
    - ☑ Show live results during voting
    - ☑ Show actual vote counts (vs. percentage only)
    - ☑ Public results page
  - Programme filter (multi-select or "All Programmes")
  - Entry year filter (multi-select or "All Years")
- **Validation:**
  - End date must be after start date
  - Name is required
  - Cannot change status to Active if no candidates approved
- **Acceptance:** Elections can be created, edited, and status-transitioned with validation.

#### Task 2.3 — Posts Management Page
- **Priority:** 🟠 P1
- **Status:** ⬜ Not Started
- **Description:** CRUD interface for election posts/positions.
- **Files:**
  - `COOPERP/NewScreens/ElectionPosts.aspx` (new)
  - `COOPERP/NewScreens/ElectionPosts.aspx.cs` (new)
- **Layout:**
  ```
  ┌─────────────────────────────────────────────────┐
  │ Election Posts                     [+ Add Post] │
  ├─────────────────────────────────────────────────┤
  │ ┌────┬──────────────────┬────────┬────────────┐ │
  │ │ #  │ Post Name        │ Code   │ Actions    │ │
  │ ├────┼──────────────────┼────────┼────────────┤ │
  │ │ 1  │ Guild President  │ PRES   │ Edit | Del │ │
  │ │ 2  │ Vice President   │ VP     │ Edit | Del │ │
  │ │ 3  │ Secretary General│ SEC    │ Edit | Del │ │
  │ └────┴──────────────────┴────────┴────────────┘ │
  ├─────────────────────────────────────────────────┤
  │ [Edit Modal: Name, Code, Description,            │
  │  Eligibility, Responsibilities, Max Winners,     │
  │  Display Order, Active toggle]                   │
  └─────────────────────────────────────────────────┘
  ```
- **Features:**
  - List all posts with inline status toggle
  - Add/Edit via modal with all fields
  - Drag-to-reorder or manual display_order input
  - Cannot delete posts that have candidates linked
- **Acceptance:** Posts CRUD works, validation prevents orphaned references.

#### Task 2.4 — Candidates Management Page
- **Priority:** 🟠 P1
- **Status:** ⬜ Not Started
- **Description:** Manage candidates for a specific election.
- **Files:**
  - `COOPERP/NewScreens/ElectionCandidates.aspx` (new)
  - `COOPERP/NewScreens/ElectionCandidates.aspx.cs` (new)
- **Layout:**
  ```
  ┌─────────────────────────────────────────────────┐
  │ Candidates — [Election Name dropdown]            │
  ├─────────────────────────────────────────────────┤
  │ Filter: [Post ▼] [Status ▼] [Search...]         │
  ├─────────────────────────────────────────────────┤
  │ ┌───────┬──────────────┬──────────┬──────────┐  │
  │ │ Photo │ Name / Regno │ Post     │ Status   │  │
  │ │       │ Slogan       │          │ [Actions]│  │
  │ ├───────┼──────────────┼──────────┼──────────┤  │
  │ │ 🖼️    │ John Doe     │ President│ ✅ Approved│ │
  │ │       │ 20/U/1234    │          │ [View]   │  │
  │ └───────┴──────────────┴──────────┴──────────┘  │
  ├─────────────────────────────────────────────────┤
  │ [+ Add Candidate] — Search student by regno,     │
  │ auto-fill name, select post, upload photo        │
  └─────────────────────────────────────────────────┘
  ```
- **Features:**
  - Add candidate: search student by regno → auto-fill name from `acad_student`
  - Photo upload (stored as `/patientimages/elections/[election_id]/[regno].jpg`)
  - Manifesto rich text editor (or plain textarea)
  - Status workflow: Pending → Approved / Rejected (with reason) / Withdrawn / Disqualified
  - Bulk approve/reject actions
  - View candidate manifesto in modal
- **Acceptance:** Candidates linked correctly to elections and posts, status transitions logged.

#### Task 2.5 — Voter Management Page
- **Priority:** 🟠 P1
- **Status:** ⬜ Not Started
- **Description:** Manage eligible voters for an election.
- **Files:**
  - `COOPERP/NewScreens/ElectionVoters.aspx` (new)
  - `COOPERP/NewScreens/ElectionVoters.aspx.cs` (new)
- **Layout:**
  ```
  ┌─────────────────────────────────────────────────┐
  │ Voters — [Election Name dropdown]                │
  ├─────────────────────────────────────────────────┤
  │ 📊 [Total: 1,200] [Voted: 450] [Turnout: 37.5%]│
  ├─────────────────────────────────────────────────┤
  │ [Import All Registered Students]                 │
  │ [Import by Programme ▼] [Import by Year ▼]       │
  ├─────────────────────────────────────────────────┤
  │ Filter: [Voted ▼] [Programme ▼] [Search...]      │
  │ ┌──────────────┬──────────┬────────┬───────────┐ │
  │ │ Student      │ Programme│ Voted? │ Actions   │ │
  │ ├──────────────┼──────────┼────────┼───────────┤ │
  │ │ Jane Smith   │ BCS      │ ✅ Yes │ [Revoke]  │ │
  │ │ 20/U/5678    │          │ 14:32  │           │ │
  │ └──────────────┴──────────┴────────┴───────────┘ │
  └─────────────────────────────────────────────────┘
  ```
- **Features:**
  - Bulk import voters from `acad_student` + `acad_registration` (active, registered this year)
  - Filter by programme, entry year
  - Search by name or regno
  - Toggle individual voter eligibility
  - Export voter list to CSV
  - Real-time turnout statistics
- **Acceptance:** Voters imported correctly, turnout stats accurate, eligibility toggling works.

#### Task 2.6 — Admin Live Results Monitor
- **Priority:** 🟡 P2
- **Status:** ⬜ Not Started
- **Description:** Real-time results display for admin portal.
- **Integrated into:** `ElectionsDashboard.aspx` (expandable section or separate tab)
- **Features:**
  - Auto-refreshing every 10 seconds via AJAX
  - Bar chart per post showing candidate vote counts
  - Turnout gauge (percentage of eligible voters who voted)
  - Colour-coded leader indicators
  - "Compute Final Results" button (only when election is Closed)
- **Acceptance:** Results update in real-time, match actual vote counts.

#### Task 2.7 — Admin Sidebar Navigation Integration
- **Priority:** 🟠 P1
- **Status:** ⬜ Not Started
- **Description:** Add Elections section to the admin sidebar between HR and System.
- **Files to modify:**
  - `COOPERP/NewScreens/SidebarMaster.master` — Add section ⑦½ "Elections"
  - `COOPERP/NewScreens/SidebarMaster.master.cs` — Add `case` entries to `SetPageTitle()`
- **Menu structure:**
  ```
  Elections (heading) — data-roles="registrar admin student_services"
  ├── Elections Dashboard    → ElectionsDashboard.aspx
  ├── Election Setup (submenu)
  │   ├── Manage Posts      → ElectionPosts.aspx
  │   ├── Manage Candidates → ElectionCandidates.aspx
  │   └── Manage Voters     → ElectionVoters.aspx
  └── Live Results          → ElectionResults.aspx
  ```
- **SVG Icons:** Use ballot-box / vote / check-square style from feather-icons
- **Acceptance:** Menu items visible for correct roles, links navigate to correct pages, active state works.

---

### Phase 3: Student Portal — Voting Interface

#### Task 3.1 — Student Elections Page (Browse & Information)
- **Priority:** 🟠 P1
- **Status:** ⬜ Not Started
- **Description:** Landing page showing active/upcoming elections the student can participate in.
- **Files:**
  - `CampusDynamics_Portal/Elections.aspx` (new)
  - `CampusDynamics_Portal/Elections.aspx.cs` (new)
- **Layout:**
  ```
  ┌─────────────────────────────────────────────────┐
  │ 🗳️ Student Elections                             │
  ├─────────────────────────────────────────────────┤
  │                                                   │
  │ ┌─ Active Election Card ──────────────────────┐  │
  │ │ 🟢 Guild Elections 2026                     │  │
  │ │ Voting open until: April 15, 2026 at 5:00 PM│  │
  │ │                                              │  │
  │ │ Posts: 6  |  Candidates: 18                  │  │
  │ │                                              │  │
  │ │ Your Progress: 3/6 posts voted  ████░░ 50%   │  │
  │ │                                              │  │
  │ │ [View Candidates]  [Enter Voting Booth 🗳️]   │  │
  │ └──────────────────────────────────────────────┘  │
  │                                                   │
  │ ┌─ Upcoming Election Card ────────────────────┐  │
  │ │ 🟡 Faculty Rep Elections 2026               │  │
  │ │ Voting opens: May 1, 2026                   │  │
  │ │ [View Candidates]                            │  │
  │ └──────────────────────────────────────────────┘  │
  │                                                   │
  │ ┌─ Completed Election Card ───────────────────┐  │
  │ │ ⚫ Class Rep Elections 2025      Completed   │  │
  │ │ [View Results]                               │  │
  │ └──────────────────────────────────────────────┘  │
  └─────────────────────────────────────────────────┘
  ```
- **Features:**
  - Shows only elections the student is eligible for
  - Active elections prominently displayed with countdown timer
  - Progress bar shows how many posts the student has voted for
  - "View Candidates" opens candidate details with manifestos
  - "Enter Voting Booth" navigates to the voting page
- **Master Page:** `PortalMaster.master`, `ActiveNav = "Elections"`
- **Acceptance:** Only eligible elections shown, progress tracking accurate.

#### Task 3.2 — Candidate Showcase Page
- **Priority:** 🟡 P2
- **Status:** ⬜ Not Started
- **Description:** Detailed view of all candidates, organised by post.
- **Integrated into:** `Elections.aspx` (expandable sections or via AJAX modal)
- **Layout per post:**
  ```
  ┌─ Guild President ──────────────────────────────┐
  │                                                 │
  │  ┌────────────┐  ┌────────────┐  ┌──────────┐  │
  │  │  🖼️ Photo  │  │  🖼️ Photo  │  │ 🖼️ Photo │  │
  │  │ John Doe   │  │ Jane Smith │  │ Bob K.   │  │
  │  │ 20/U/1234  │  │ 20/U/5678  │  │ 21/U/999 │  │
  │  │ "Change!"  │  │ "Unity"    │  │ "Growth" │  │
  │  │ [Manifesto]│  │ [Manifesto]│  │[Manifesto]│  │
  │  └────────────┘  └────────────┘  └──────────┘  │
  └─────────────────────────────────────────────────┘
  ```
- **Features:**
  - Candidate cards with photo, name, regno, slogan
  - "Read Manifesto" expands/modal shows full manifesto HTML
  - Responsive grid: 3 columns desktop, 2 tablet, 1 mobile
  - Only shows "Approved" candidates
- **Acceptance:** All approved candidates displayed with correct info, responsive layout.

#### Task 3.3 — Voting Booth Page
- **Priority:** 🔴 P0
- **Status:** ⬜ Not Started
- **Description:** The core voting interface — step-by-step ballot for each post.
- **Files:**
  - `CampusDynamics_Portal/ElectionVote.aspx` (new)
  - `CampusDynamics_Portal/ElectionVote.aspx.cs` (new)
- **Flow:**
  ```
  Step 0: Confirmation
  ┌──────────────────────────────────────────────┐
  │ ⚠️ You are about to vote in:                 │
  │ Guild Elections 2026                          │
  │                                               │
  │ • Your vote is secret and cannot be changed   │
  │ • You may vote for ONE candidate per post     │
  │ • You must complete voting in one session     │
  │                                               │
  │ [I Understand — Begin Voting]                 │
  └──────────────────────────────────────────────┘
  
  Step 1-N: One post per step
  ┌──────────────────────────────────────────────┐
  │ Post 1 of 6: Guild President                  │
  │ ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ Progress: 16%  │
  │                                               │
  │ Select your candidate:                        │
  │                                               │
  │ ┌─ ○ ──────────────────────────────────────┐  │
  │ │ 🖼️  John Doe — "Change for the better!"  │  │
  │ │     [Read Manifesto ▼]                    │  │
  │ └──────────────────────────────────────────┘  │
  │ ┌─ ○ ──────────────────────────────────────┐  │
  │ │ 🖼️  Jane Smith — "Unity in diversity"    │  │
  │ │     [Read Manifesto ▼]                    │  │
  │ └──────────────────────────────────────────┘  │
  │                                               │
  │ [← Previous]         [Confirm & Next →]       │
  └──────────────────────────────────────────────┘
  
  Final Step: Review & Submit
  ┌──────────────────────────────────────────────┐
  │ ✅ Voting Complete!                           │
  │                                               │
  │ You have voted for:                           │
  │  • President: John Doe                        │
  │  • Vice President: Jane Smith                 │
  │  • Secretary: Bob K.                          │
  │  ...                                          │
  │                                               │
  │ Thank you for participating in democracy! 🎉  │
  │                                               │
  │ [View Live Results]  [Back to Portal]         │
  └──────────────────────────────────────────────┘
  ```
- **Features:**
  - Vote token generated on "Begin Voting" click
  - Each vote submitted individually via AJAX (not all at once)
  - Progress bar across top
  - Candidate order randomised per voter (prevent position bias)
  - Cannot go back and change a submitted vote
  - Skip voting for a post (abstain) option
  - Session timeout warning
  - Mobile-responsive touch-friendly radio buttons
- **Security:**
  - All votes submitted server-side via AJAX POST
  - Vote token validated on each submission
  - UNIQUE constraint prevents double votes
  - No candidate IDs exposed in page source until voting step
- **Acceptance:** Complete voting flow works end-to-end, double-vote prevented, mobile responsive.

#### Task 3.4 — Student Portal Navigation Integration
- **Priority:** 🟠 P1
- **Status:** ⬜ Not Started
- **Description:** Add "Elections" link to the student portal top navigation.
- **Files to modify:**
  - `CampusDynamics_Portal/PortalMaster.master` — Add nav link after "Notices"
  - `CampusDynamics_Portal/App_Code/Portal/PortalHelper.cs` — Add to `ExemptPaths` if needed
- **Nav link:** `<a href='<%= ResolveUrl("~/Elections.aspx") %>' class="cd-header__nav-link<%= GetNavClass("Elections") %>">Elections</a>`
- **Visibility:** Show to all students (both staff and student user types)
- **Conditional badge:** Show 🔴 notification dot when there's an active election the student hasn't completed voting in
- **Acceptance:** Nav link appears, active state works, notification dot shows when applicable.

---

### Phase 4: Live Results & Public Display

#### Task 4.1 — Live Results Page (Public/Portal)
- **Priority:** 🟡 P2
- **Status:** ⬜ Not Started
- **Description:** Real-time election results page accessible during and after elections.
- **Files:**
  - `CampusDynamics_Portal/ElectionResults.aspx` (new)
  - `CampusDynamics_Portal/ElectionResults.aspx.cs` (new)
- **Also create admin version:**
  - `COOPERP/NewScreens/ElectionResults.aspx` (new)
  - `COOPERP/NewScreens/ElectionResults.aspx.cs` (new)
- **Layout:**
  ```
  ┌──────────────────────────────────────────────────────┐
  │ 🗳️ Guild Elections 2026 — Live Results               │
  │                                                       │
  │ 📊 Turnout: 856 / 1,200 voters (71.3%)               │
  │ ████████████████████████████░░░░░░░░░░                │
  │ Last updated: 14:32:15 · Auto-refresh: ON             │
  ├──────────────────────────────────────────────────────┤
  │                                                       │
  │ 🏆 GUILD PRESIDENT                                    │
  │ ┌──────────────────────────────────────────────────┐  │
  │ │ 🖼️ John Doe          423 votes  ██████████▏ 49%  │  │
  │ │ 🖼️ Jane Smith        312 votes  ███████▍   36%  │  │
  │ │ 🖼️ Bob K.            121 votes  ██▊        14%  │  │
  │ └──────────────────────────────────────────────────┘  │
  │                                                       │
  │ 📋 VICE PRESIDENT                                     │
  │ ┌──────────────────────────────────────────────────┐  │
  │ │ 🖼️ Alice M.          389 votes  █████████▏  45%  │  │
  │ │ 🖼️ Tom N.            356 votes  ████████▍   41%  │  │
  │ │ 🖼️ Sara P.           111 votes  ██▌         13%  │  │
  │ └──────────────────────────────────────────────────┘  │
  │ ...                                                   │
  └──────────────────────────────────────────────────────┘
  ```
- **Features:**
  - Auto-refresh via AJAX every 10 seconds (configurable)
  - Animated progress bars (CSS transitions on width change)
  - Turnout counter at top
  - Leading candidate highlighted with gold/star indicator
  - Tie detection and display
  - Respect `show_live_results` and `show_vote_counts` election settings
  - Post-election: show final results with winner badges
  - Mobile responsive
- **AJAX Endpoint:** `?ajax=liveresults&eid=[election_id]` returns JSON:
  ```json
  {
    "ok": true,
    "election": "Guild Elections 2026",
    "status": "Active",
    "turnout": {"total": 1200, "voted": 856, "pct": 71.3},
    "posts": [
      {
        "post_id": 1, "post_name": "Guild President",
        "candidates": [
          {"id": 1, "name": "John Doe", "photo": "...", "votes": 423, "pct": 49.4},
          {"id": 2, "name": "Jane Smith", "photo": "...", "votes": 312, "pct": 36.4}
        ]
      }
    ]
  }
  ```
- **Acceptance:** Results display correctly, auto-refresh works, respects election visibility settings.

#### Task 4.2 — Results Computation & Winner Determination
- **Priority:** 🟠 P1
- **Status:** ⬜ Not Started
- **Description:** Algorithm to compute final results, handle ties, determine winners.
- **Implemented in:** `ElectionsHelper.ComputeResults(int electionId)`
- **Algorithm:**
  ```
  FOR EACH post in election:
    1. COUNT votes per candidate: GROUP BY candidate_id
    2. RANK candidates by vote_count DESC
    3. Check for ties at the winning position
    4. IF max_winners == 1 AND top 2 have same count → mark both is_tie = true
    5. IF max_winners > 1 → top N are winners (handle ties at cutoff)
    6. Calculate percentage: (candidate_votes / total_post_votes) * 100
    7. INSERT/UPDATE elect_result rows
  ```
- **Tie Resolution:**
  - System flags ties but does NOT auto-resolve
  - Admin gets notification: "Tie detected for [Post]—manual resolution required"
  - Admin can: trigger re-vote for that post only, or manually declare winner
- **Acceptance:** Results computed correctly, ties detected, percentages accurate.

---

### Phase 5: Integration, Polish & Security Hardening

#### Task 5.1 — Candidate Photo Upload System
- **Priority:** 🟡 P2
- **Status:** ⬜ Not Started
- **Description:** Allow admin (and optionally candidates via portal) to upload candidate photos.
- **Storage Path:** `/patientimages/elections/[election_id]/[candidate_id].jpg`
- **Constraints:** Max 2MB, JPEG/PNG only, auto-resize to 300x300px
- **Implementation:** Server-side `FileUpload` control with validation in `ElectionCandidates.aspx`
- **Acceptance:** Photos upload, validate, resize, and display correctly in all views.

#### Task 5.2 — Election Status Auto-Transition
- **Priority:** 🟡 P2
- **Status:** ⬜ Not Started
- **Description:** Automatic status transitions based on dates.
- **Logic (checked on admin page loads or via a scheduled check):**
  ```
  IF status = 'Upcoming' AND NOW() >= start_date → set to 'Active'
  IF status = 'Active' AND NOW() > end_date → set to 'Closed', auto-compute results
  ```
- **Implementation:** `ElectionsHelper.AutoTransitionElections()` called on dashboard load
- **Acceptance:** Elections transition correctly without manual intervention.

#### Task 5.3 — Voter Import & Eligibility Engine
- **Priority:** 🟡 P2
- **Status:** ⬜ Not Started
- **Description:** Smart voter import that considers election eligibility rules.
- **Logic:**
  ```sql
  INSERT INTO elect_voter (election_id, regno, voter_name, email, programme)
  SELECT [election_id], s.regno, 
         TRIM(CONCAT(IFNULL(s.firstname,''),' ',IFNULL(s.othername,''))),
         s.email, s.progid
  FROM acad_student s
  INNER JOIN acad_registration r ON r.regno = s.regno 
    AND r.acad_year = [current_acad_year]
  WHERE UPPER(COALESCE(s.new_status,'')) = 'ACTIVE'
    AND [programme_filter]
    AND [entry_year_filter]
  ON DUPLICATE KEY UPDATE voter_name = VALUES(voter_name)
  ```
- **Acceptance:** Voters imported matching election criteria, duplicates handled gracefully.

#### Task 5.4 — Email/SMS Notifications (Optional Enhancement)
- **Priority:** 🟢 P3
- **Status:** ⬜ Not Started
- **Description:** Notify voters when election starts, remind non-voters near end.
- **Integration:** Use existing `SMSSender.aspx` infrastructure if available
- **Acceptance:** Notifications sent at election start, reminder near end.

#### Task 5.5 — Audit Trail & Reporting
- **Priority:** 🟡 P2
- **Status:** ⬜ Not Started
- **Description:** Comprehensive audit logging for all election operations.
- **What to log:**
  - Election created/modified/status changed (who, when)
  - Candidate added/approved/rejected (who, when, reason)
  - Voter eligibility changed (who, when)
  - Vote tokens issued (when, to whom)
  - Votes cast (timestamp, IP — NOT who voted for whom)
- **Report exports:** CSV/PDF of voter turnout, results summary, audit trail
- **Acceptance:** Full audit trail queryable, exportable.

#### Task 5.6 — Responsive Design & Mobile Optimization
- **Priority:** 🟡 P2
- **Status:** ⬜ Not Started
- **Description:** Ensure all election pages work perfectly on mobile devices.
- **Key considerations:**
  - Voting booth: large touch targets for radio buttons (min 44px)
  - Candidate cards: stack vertically on mobile
  - Results bars: readable on narrow screens
  - Progress indicators: simplified on mobile
- **Breakpoints:** Follow existing portal pattern (768px tablet, 480px mobile)
- **Acceptance:** All pages usable on 320px+ screen widths.

---

### Phase 6: Testing & Deployment

#### Task 6.1 — Database Migration on Production
- **Priority:** 🔴 P0 (at deployment time)
- **Status:** ⬜ Not Started
- **Description:** Run migration SQL on production server (102.34.160.47).
- **Steps:**
  1. Backup production database
  2. Run `elections_migration.sql`
  3. Verify tables created
  4. Insert default post data
- **Acceptance:** All tables exist on production with correct schema.

#### Task 6.2 — End-to-End Testing Scenarios
- **Priority:** 🟠 P1
- **Status:** ⬜ Not Started
- **Description:** Test complete election lifecycle.
- **Scenarios:**
  1. Admin creates election → adds posts → adds candidates → imports voters → opens election
  2. Student logs in → sees election → views candidates → enters booth → votes all posts
  3. Second student votes → results update in real-time
  4. Student tries to vote again → properly blocked
  5. Election ends → results computed → ties detected if any
  6. Non-eligible student cannot see/vote in restricted election
  7. Admin closes election → final results displayed
- **Acceptance:** All 7 scenarios pass without errors.

#### Task 6.3 — Load Testing
- **Priority:** 🟢 P3
- **Status:** ⬜ Not Started
- **Description:** Ensure the system can handle concurrent voting load.
- **Target:** 200+ concurrent voters without degradation
- **Key concern:** `elect_vote` INSERT contention → InnoDB row-level locking should handle this
- **Acceptance:** No deadlocks or timeouts under simulated load.

---

## 5. File Inventory

### New Files to Create

| # | File | Project | Type | Description |
|---|------|---------|------|-------------|
| 1 | `COOPERP/sql/elections_migration.sql` | Admin | SQL | Database migration script |
| 2 | `App_Code/Elections/ElectionsHelper.cs` | Admin | C# | Admin data-access layer |
| 3 | `COOPERP/NewScreens/ElectionsDashboard.aspx` | Admin | ASPX | Elections dashboard + create/edit |
| 4 | `COOPERP/NewScreens/ElectionsDashboard.aspx.cs` | Admin | C# | Dashboard code-behind |
| 5 | `COOPERP/NewScreens/ElectionPosts.aspx` | Admin | ASPX | Posts CRUD |
| 6 | `COOPERP/NewScreens/ElectionPosts.aspx.cs` | Admin | C# | Posts code-behind |
| 7 | `COOPERP/NewScreens/ElectionCandidates.aspx` | Admin | ASPX | Candidates management |
| 8 | `COOPERP/NewScreens/ElectionCandidates.aspx.cs` | Admin | C# | Candidates code-behind |
| 9 | `COOPERP/NewScreens/ElectionVoters.aspx` | Admin | ASPX | Voter management |
| 10 | `COOPERP/NewScreens/ElectionVoters.aspx.cs` | Admin | C# | Voters code-behind |
| 11 | `COOPERP/NewScreens/ElectionResults.aspx` | Admin | ASPX | Admin results monitor |
| 12 | `COOPERP/NewScreens/ElectionResults.aspx.cs` | Admin | C# | Admin results code-behind |
| 13 | `CampusDynamics_Portal/App_Code/Portal/ElectionsPortalHelper.cs` | Portal | C# | Portal data-access layer |
| 14 | `CampusDynamics_Portal/Elections.aspx` | Portal | ASPX | Student elections home |
| 15 | `CampusDynamics_Portal/Elections.aspx.cs` | Portal | C# | Elections home code-behind |
| 16 | `CampusDynamics_Portal/ElectionVote.aspx` | Portal | ASPX | Voting booth |
| 17 | `CampusDynamics_Portal/ElectionVote.aspx.cs` | Portal | C# | Voting booth code-behind |
| 18 | `CampusDynamics_Portal/ElectionResults.aspx` | Portal | ASPX | Student results view |
| 19 | `CampusDynamics_Portal/ElectionResults.aspx.cs` | Portal | C# | Student results code-behind |

### Files to Modify

| # | File | Change |
|---|------|--------|
| 1 | `COOPERP/NewScreens/SidebarMaster.master` | Add Elections menu section |
| 2 | `COOPERP/NewScreens/SidebarMaster.master.cs` | Add `SetPageTitle()` cases |
| 3 | `CampusDynamics_Portal/PortalMaster.master` | Add "Elections" nav link |

---

## 6. Edge Cases & Scenarios

### Voting Edge Cases

| Scenario | Handling |
|----------|----------|
| Student votes, then session expires mid-ballot | Votes already cast are preserved; student can re-enter booth and continue with remaining posts |
| Two browser tabs open simultaneously | Vote token is per-session; DB UNIQUE constraint prevents doubles |
| Admin changes election status to Closed while students are voting | Ongoing votes complete; new votes rejected with "Election has ended" message |
| Candidate is disqualified after receiving votes | Votes remain in DB (for audit); candidate hidden from results display; admin can choose to count or void |
| Student transfers programmes after being imported as voter | Voter record remains valid (tied to election, not current status) |
| Zero candidates for a post | Post is skipped in the voting booth with a message |
| All candidates withdrawn for a post | Post marked as "No Contest" in results |
| Identical vote counts (tie) | Flag `is_tie = 1` in results; admin notified; no auto-resolution |
| Very long manifesto text | Truncate display in cards with "Read More"; full text in modal |
| Student not in voter list tries to vote | "You are not eligible for this election" message; suggest contacting admin |

### Admin Edge Cases

| Scenario | Handling |
|----------|----------|
| Delete election with existing votes | Soft-delete only (change status to Cancelled); hard-delete blocked if votes exist |
| Delete post with existing candidates | Blocked with error message |
| Import voters twice | `ON DUPLICATE KEY UPDATE` ensures no duplicates |
| Change election dates while Active | Only end_date can be extended; start_date locked once Active |
| No internet during vote submission | Client-side retry logic; server rejects if already voted |

---

## 7. Testing Checklist

### Unit Tests (per method)

- [ ] `ElectionsHelper.SavePost()` — creates and updates post
- [ ] `ElectionsHelper.SaveElection()` — creates with validation
- [ ] `ElectionsHelper.ImportVotersFromRegistered()` — correct count, no duplicates
- [ ] `ElectionsPortalHelper.CastVote()` — success case, double-vote rejection, invalid token rejection
- [ ] `ElectionsPortalHelper.GenerateAndStoreToken()` — unique per session
- [ ] `ElectionsHelper.ComputeResults()` — correct counts, correct percentages, tie detection

### Integration Tests (end-to-end)

- [ ] Full election lifecycle: Create → Configure → Nominate → Activate → Vote → Close → Results
- [ ] Multi-student concurrent voting (at least 5 simultaneous)
- [ ] Mobile viewport testing (320px, 375px, 768px, 1024px)
- [ ] Session expiry recovery during voting
- [ ] Voter eligibility filtering (programme-restricted election)

### Security Tests

- [ ] SQL injection: all user inputs parameterised
- [ ] XSS: all output HTML-encoded
- [ ] CSRF: form validation tokens present
- [ ] Direct URL access: unauthorized users redirected
- [ ] Vote token forgery: invalid tokens rejected
- [ ] Double voting: DB constraint prevents at all levels

---

## Implementation Order (Recommended)

```
Week 1: Phase 1 (Foundation)
  ├── Task 1.1: Database tables
  ├── Task 1.2: Admin ElectionsHelper
  └── Task 1.3: Portal ElectionsPortalHelper

Week 2: Phase 2 (Admin Portal)
  ├── Task 2.7: Sidebar navigation
  ├── Task 2.3: Posts management
  ├── Task 2.1: Elections dashboard
  ├── Task 2.2: Election editor
  ├── Task 2.4: Candidates management
  └── Task 2.5: Voter management

Week 3: Phase 3 (Student Portal)
  ├── Task 3.4: Portal navigation
  ├── Task 3.1: Student elections page
  ├── Task 3.2: Candidate showcase
  └── Task 3.3: Voting booth (CRITICAL)

Week 4: Phase 4 + 5 (Results & Polish)
  ├── Task 4.1: Live results page
  ├── Task 4.2: Results computation
  ├── Task 5.1: Photo upload
  ├── Task 5.2: Auto-transition
  ├── Task 5.3: Voter import engine
  └── Task 5.6: Mobile optimization

Week 5: Phase 6 (Testing & Deployment)
  ├── Task 6.1: Production migration
  ├── Task 6.2: E2E testing
  └── Task 6.3: Load testing
```

---

> **Next Step:** Begin with **Task 1.1 — Create Database Tables** by running the migration SQL.

---

## Phase 5 Completion Log — Hardening, Exports & Quality

**Completed:** 2026 (Session)

### Critical Bug Fixes

| # | Severity | Bug | Fix | File |
|---|----------|-----|-----|------|
| 1 | **CRITICAL** | `e.academic_year` — column is actually `acad_year` | Changed to `e.acad_year AS academic_year` | ElectionsPortalHelper.cs |
| 2 | **CRITICAL** | `vote_hash, voted_at` — columns are actually `vote_token, cast_at` | Fixed INSERT column names | ElectionsPortalHelper.cs |
| 3 | **HIGH** | `'Archived'` status referenced but not in DB ENUM | Replaced with `'Nominations'` and `'Closed'` as appropriate | ElectionsPortalHelper.cs, Elections.aspx.cs, ElectionResults.aspx.cs |
| 4 | **MEDIUM** | `ComputeResults` tie detection: `prevCount = voteCount` assigned BEFORE comparison | Moved assignment AFTER the tie check | ElectionsHelper.cs |
| 5 | **HIGH** | `has_voted` stays 0 when student skips posts | Added `MarkVotingComplete()` + `finishvoting` AJAX endpoint called from `showThanks()` | ElectionsPortalHelper.cs, ElectionVote.aspx.cs, ElectionVote.aspx |
| 6 | **LOW** | `GetPostsForElection(int electionId)` didn't use `electionId` | Added INNER JOIN on `elect_candidate` filtered by `@eid` | ElectionsPortalHelper.cs |

### New Features

| Feature | Description | Files Modified |
|---------|-------------|----------------|
| **Vote Confirmation Dialog** | `confirm()` dialog before casting vote — shows candidate name, warns action is irreversible | ElectionVote.aspx |
| **IP + User-Agent Audit Trail** | `CastVote()` now accepts + records IP & user-agent on `elect_voter`; `MarkVotingComplete()` also records them | ElectionsPortalHelper.cs, ElectionVote.aspx.cs |
| **Pending Nominations Banner** | Animated warning banner on admin Candidates page when pending self-nominations exist; includes election breakdown + "Review Now" button that filters to Pending | ElectionCandidates.aspx, ElectionCandidates.aspx.cs |
| **Pending Row Highlighting** | Pending candidate rows highlighted with amber left-border in the grid | ElectionCandidates.aspx.cs |
| **CSV Export — Results** | "Export CSV" button on admin Results page; exports post, candidate, votes, %, rank, winner, tie columns | ElectionResults.aspx, ElectionResults.aspx.cs |
| **CSV Export — Voters** | "CSV" button on admin Voters page; exports reg no, name, email, programme, eligible, voted, voted_at, IP | ElectionVoters.aspx, ElectionVoters.aspx.cs |

### Files Modified This Phase

**Portal (CampusDynamics_Portal):**
- `App_Code/Portal/ElectionsPortalHelper.cs` — 6 bug fixes + `MarkVotingComplete()` method + `CastVote()` IP/UA params
- `ElectionVote.aspx` — Vote confirmation dialog + `showThanks()` finishvoting AJAX call
- `ElectionVote.aspx.cs` — `finishvoting` AJAX handler + IP/UA passthrough to `CastVote()`
- `Elections.aspx.cs` — Removed `Archived` references
- `ElectionResults.aspx.cs` — Removed `Archived` references

**Admin (CampusDynamics/COOPERP):**
- `App_Code/Elections/ElectionsHelper.cs` — `ComputeResults()` tie detection fix
- `NewScreens/ElectionCandidates.aspx` — Pending banner CSS + HTML + `filterPending()` JS
- `NewScreens/ElectionCandidates.aspx.cs` — Banner logic in `LoadStats()` + row highlighting
- `NewScreens/ElectionResults.aspx` — Export CSV button
- `NewScreens/ElectionResults.aspx.cs` — `btnExportCsv_Click()` handler + `CsvEscape()`
- `NewScreens/ElectionVoters.aspx` — Export CSV button in Voter Roll header
- `NewScreens/ElectionVoters.aspx.cs` — `btnExportVotersCsv_Click()` handler + `CsvEscape()`

---

## Final Production Readiness Audit

**Completed:** 2026 (Final Audit Session)

### Comprehensive Audit Findings & Resolutions

A full 20+ file audit was conducted across admin and portal codebases. Database schemas were verified via `DESCRIBE` queries against the live DB.

#### Critical Bugs Fixed

| # | Severity | Bug | Fix | File |
|---|----------|-----|-----|------|
| C1 | **CRITICAL** | `GetPostsForElection()` used `INNER JOIN elect_candidate` — returned 0 posts for new elections with no candidates, making self-nomination impossible | Removed JOIN; now queries `elect_post` directly with `WHERE is_active = 1` | ElectionsPortalHelper.cs |
| H2 | **HIGH** | `status == "Results"` dead code — `Results` not in DB ENUM | Removed `\|\| status == "Results"` from isClosed check | ElectionResults.aspx.cs (Admin) |
| M1 | **MEDIUM** | `finishvoting` AJAX endpoint had no session validation — potential CSRF | Added session token verification (`vote_token_` + eid) | ElectionVote.aspx.cs |

#### New Feature: Candidate Withdrawal UI

| Feature | Description | Files Modified |
|---------|-------------|----------------|
| **Withdraw Application Button** | Students can now withdraw Pending candidacy applications via a "Withdraw" button with confirmation dialog. Uses existing `ElectionsPortalHelper.WithdrawApplication()`. Red ghost button with hover effect, visible only for Pending status. | CandidateApplication.aspx, CandidateApplication.aspx.cs |
| **Withdrawn Badge Style** | Added `.ca-status__badge--withdrawn` CSS (red background matching rejected style) and `GetStatusBadgeClass("Withdrawn")` case | CandidateApplication.aspx, CandidateApplication.aspx.cs |

#### Dead CSS Cleanup

| Item | Action | File |
|------|--------|------|
| `.el-badge--archived` | Removed — `Archived` status doesn't exist in DB ENUM | Elections.aspx |
| `.el-nom-highlight` + `@keyframes el-nom-glow` | Removed — animation defined but never applied | Elections.aspx |

#### Schema Verification (All Confirmed via DESCRIBE)

| Table | Columns Verified |
|-------|-----------------|
| `elect_post` | `eligibility`, `responsibilities`, `max_winners`, `updated_at` ✅ |
| `elect_election` | `require_registration`, `require_fees_cleared`, `allowed_programmes`, `allowed_entry_years`, `results_public`, `created_by`, `updated_at` ✅ |
| `elect_candidate` | `status ENUM` includes `'Withdrawn'`, `updated_at` present ✅ |
| `acad_acadyears` | `status ENUM('Active','Inactive')` ✅ |

#### Test Data Setup

| Action | Detail |
|--------|--------|
| Test student `MRU2027000002` registered as voter in Election 2 (Active) | Can test full voting flow |
| Test student `MRU2027000002` registered as voter in Election 3 (Nominations) | Can test self-nomination + withdrawal |
| Feature gate active | Elections tab only visible to `MRU2027000002` in PortalMaster.master |

### Production Toggle Checklist

When ready to go live, remove the test-student gate:

1. **PortalMaster.master** (~line 130): Remove the `CurrentRegno == "MRU2027000002"` wrapper around the Elections `<li>` nav link
2. **PortalMaster.master.cs** (~line 144): Remove `if (regno != "MRU2027000002") return;` from `LoadElectionBadge()`

### Module Status: COMPLETE

All phases implemented and audited:

| Phase | Status |
|-------|--------|
| Phase 1: Database Foundation (6 tables + helpers) | ✅ Complete |
| Phase 2: Admin Portal (5 pages + sidebar nav) | ✅ Complete |
| Phase 3: Student Portal (3 pages + helper + nav) | ✅ Complete |
| Phase 4.5: Polish (AutoTransition, badge, self-nomination, activity feed, seed data) | ✅ Complete |
| Phase 5: Hardening (bug fixes, CSV exports, pending banner, vote confirmation, IP audit) | ✅ Complete |
| Hotfixes: (v.voted_at, acad_programme.status, feature gate) | ✅ Complete |
| Final Audit: (3 bugs fixed, Withdraw UI, dead CSS, schema verified, test data) | ✅ Complete |
