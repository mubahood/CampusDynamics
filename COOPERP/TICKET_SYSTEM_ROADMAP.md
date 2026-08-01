# Support Ticket System — Implementation Roadmap

> Campus Dynamics MRU · Implemented May 2026
> Covers: Student Portal (student/lecturer side) + Admin ERP (staff management side)

---

## 1. Architecture Overview

```
campus_dynamics_portal DB
  └── support_tickets          — ticket headers
  └── support_ticket_messages  — threaded chat messages
  └── support_ticket_attachments — file metadata

Portal (CampusDynamics_Portal/)
  └── MyTickets.aspx           — list + stats dashboard
  └── NewTicket.aspx           — submit new ticket
  └── TicketView.aspx          — thread view + reply
  └── App_Code/SupportTicketDB.cs — shared data layer
  └── COOPERP/Support/Uploads/   — uploaded files

Admin ERP (COOPERP/NewScreens/)
  └── TicketsController.aspx   — admin management panel
```

**Connection routing:**
- Portal → `vacConnectionString` → campus_dynamics_portal
- Admin → `campus_dynamics_portalConnectionString` → campus_dynamics_portal

---

## 2. Database Schema

```sql
-- Run once on campus_dynamics_portal

CREATE TABLE IF NOT EXISTS support_tickets (
    ticket_id      INT AUTO_INCREMENT PRIMARY KEY,
    submitter_regno VARCHAR(50)  NOT NULL,
    submitter_name  VARCHAR(150) NOT NULL,
    submitter_type  ENUM('STUDENT','LECTURER','STAFF') NOT NULL DEFAULT 'STUDENT',
    issue_type     VARCHAR(80)  NOT NULL,
    subject        VARCHAR(250) NOT NULL,
    status         ENUM('OPEN','IN_PROGRESS','AWAITING_REPLY','RESOLVED','CLOSED')
                   NOT NULL DEFAULT 'OPEN',
    priority       ENUM('LOW','NORMAL','HIGH','URGENT') NOT NULL DEFAULT 'NORMAL',
    assigned_to    VARCHAR(100) NULL,
    created_at     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    closed_at      DATETIME NULL,
    closed_by      VARCHAR(100) NULL,
    INDEX idx_regno  (submitter_regno),
    INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS support_ticket_messages (
    message_id   INT AUTO_INCREMENT PRIMARY KEY,
    ticket_id    INT NOT NULL,
    sender_regno VARCHAR(50)  NOT NULL,
    sender_name  VARCHAR(150) NOT NULL,
    sender_role  ENUM('SUBMITTER','ADMIN','SYSTEM') NOT NULL DEFAULT 'SUBMITTER',
    message      TEXT NOT NULL,
    is_internal  TINYINT(1) NOT NULL DEFAULT 0,  -- admin-only internal note
    created_at   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_msg_ticket (ticket_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS support_ticket_attachments (
    attachment_id INT AUTO_INCREMENT PRIMARY KEY,
    ticket_id     INT  NOT NULL,
    message_id    INT  NULL,
    original_name VARCHAR(255) NOT NULL,
    stored_name   VARCHAR(255) NOT NULL,  -- GUID-based, stored in Uploads/
    file_size     INT  NOT NULL DEFAULT 0,
    mime_type     VARCHAR(100) NULL,
    uploaded_by   VARCHAR(100) NOT NULL,
    uploaded_at   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_att_ticket  (ticket_id),
    INDEX idx_att_message (message_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

> Tables are auto-created via `SupportTicketDB.EnsureSchema()` called on first page load.

---

## 3. Issue Categories

| Category | Colour |
|---|---|
| Academic — Results & Marks | `#174DA4` blue |
| Academic — Transcripts & Certificates | `#174DA4` blue |
| Academic — Course Registration | `#174DA4` blue |
| Financial — Fees & Payments | `#16a34a` green |
| Financial — Receipt or Invoice | `#16a34a` green |
| Technical — Portal Login | `#dc3545` red |
| Technical — System Error | `#dc3545` red |
| Registration — Semester Registration | `#d97706` amber |
| Lecturer — Marks Entry | `#7c3aed` purple |
| Accommodation & Residence | `#ea580c` orange |
| Library Services | `#0d9488` teal |
| Other | `#6b7280` grey |

---

## 4. Ticket Lifecycle & Statuses

```
[OPEN] ──▶ [IN_PROGRESS] ──▶ [AWAITING_REPLY] ──▶ [RESOLVED] ──▶ [CLOSED]
                │                     │
                └─────────────────────┴──▶ [CLOSED]  (admin can force-close any time)
```

| Status | Trigger |
|---|---|
| OPEN | Student/lecturer submits ticket |
| IN_PROGRESS | Admin opens or student sends reply after admin response |
| AWAITING_REPLY | Admin sends a reply — waiting for student to respond |
| RESOLVED | Admin marks resolved |
| CLOSED | Admin closes (no further action expected) |

Status changes are logged as SYSTEM messages in the thread for full audit trail.

---

## 5. File Attachments

- **Allowed:** `.jpg`, `.jpeg`, `.png`, `.gif`, `.pdf`, `.doc`, `.docx`, `.txt`
- **Max size:** 5 MB per file, up to 3 files per message
- **Storage:** `~/COOPERP/Support/Uploads/` — files renamed to `{GUID}.{ext}` on save
- **Security:** extension whitelist + size check + random name (non-guessable URLs)
- **Serving:** direct URL (portal is behind auth; GUIDs prevent enumeration)

---

## 6. Files Created / Modified

| File | Action | Purpose |
|---|---|---|
| `App_Code/SupportTicketDB.cs` | CREATE | Shared data layer, schema init, helpers |
| `MyTickets.aspx` + `.cs` | CREATE | Portal ticket dashboard |
| `NewTicket.aspx` + `.cs` | CREATE | Submit form with file upload |
| `TicketView.aspx` + `.cs` | CREATE | Thread + reply UI |
| `PortalMaster.master` | MODIFY | Add Support nav link with active-ticket badge |
| `PortalMaster.master.cs` | MODIFY | Add `OpenTicketCount` property |
| `COOPERP/Support/Uploads/` | CREATE | Upload folder |
| `NewScreens/TicketsController.aspx` + `.cs` | CREATE | Admin full management panel |

---

## 7. Admin Panel Features (TicketsController.aspx)

- **Stats strip:** Total · Open · In Progress · Awaiting Reply · Resolved · Urgent
- **Filter tabs:** All | Open | In Progress | Awaiting Reply | Resolved | Closed
- **Search:** by student name, reg no, or subject
- **Ticket list:** sortable, colour-coded by status and priority
- **Ticket detail panel (right side):** full thread view with all messages
- **Reply form:** text + optional attachment + internal-note toggle
- **Status control:** dropdown to change status (triggers SYSTEM message in thread)
- **Priority control:** LOW / NORMAL / HIGH / URGENT badge selector
- **Assign to:** free-text assignee field

---

## 8. Security Checklist

- [x] All user input HTML-encoded before output (`HttpUtility.HtmlEncode`)
- [x] All DB queries use parameterized `MySqlCommand` — no string concatenation
- [x] File extension whitelist + GUID rename — no path traversal possible
- [x] Auth check on every Page_Load + every AJAX handler
- [x] Ticket ownership check before rendering TicketView (students can only see own tickets)
- [x] Admin AJAX handlers check session + page is in admin app
- [x] Internal notes hidden from student/lecturer views (`is_internal = 0` filter)
- [x] File size enforced both client-side (JS) and server-side (Content-Length check)

---

## 9. Design Tokens Used

Follows `NewScreens/DESIGN_SYSTEM.md` and portal `PortalMaster.master` conventions:
- Primary: `#05275C` | Accent: `#174DA4` | Surface: `#f5f7fa` | Border: `#e0e5ed`
- CSS prefix: `.tk-` for all ticket-specific classes
- Border-radius: `0` inputs/buttons | `0` cards (flat design)
- Font: system-ui stack, base 12–13px
- Status colours: Open `#174DA4` · Progress `#d97706` · Waiting `#7c3aed` · Resolved `#16a34a` · Closed `#6b7280`
