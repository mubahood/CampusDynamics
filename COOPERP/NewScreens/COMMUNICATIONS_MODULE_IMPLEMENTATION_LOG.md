# Communications Module — Implementation Log

## Overview

A comprehensive Communication/Notice Module for Campus Dynamics EMIS enabling admin-posted communications with rich text, attachments, force-read mechanisms, read tracking, confirmation flows, comments, and notification badges.

---

## Architecture

### Database Schema (4 tables)

| Table | Purpose |
|-------|---------|
| `sys_communications` | Main communications with title, rich content (LONGTEXT), target audience, priority, force-read flag + expiry, status (DRAFT/PUBLISHED/ARCHIVED), allow_comments, timestamps |
| `sys_communication_attachments` | File attachments linked by communication_id (CASCADE delete) |
| `sys_communication_reads` | Per-user read tracking with `read_at`, `confirmed_at`, `confirmation_text`; unique on (communication_id, user_id) |
| `sys_communication_comments` | User comments on communications |

### Migration File

**`migrations/comm_module_migration.sql`** — Run once to create all 4 tables + dummy data (5 communications, 4 attachments, 5 reads, 4 comments).

---

## Admin Pages (COOPERP/NewScreens/)

### Communications.aspx — Manage Communications
- **CSS prefix:** `cm-`
- **Stats row:** Total, Published, Draft, Archived, Force-Read counts
- **Filters:** Status, Audience, Priority, Search (debounced)
- **Table:** Communications with action dot-menus (Preview, Edit, Read Stats, Publish/Archive, Delete)
- **Create/Edit Modal:** Rich text editor (iframe contentEditable with toolbar: bold/italic/underline/lists/headings/links/tables), file upload queue, target audience, priority, force-read toggle with expiry date, allow comments toggle
- **Read Stats Modal:** Shows list of readers with read timestamps and confirmation status
- **Preview Modal:** Renders communication as students/staff would see it

**AJAX Endpoints (Communications.aspx.cs):**
| Endpoint | Method | Description |
|----------|--------|-------------|
| `list` | GET | Filtered list with stats |
| `get` | GET | Single communication with attachments |
| `save` | POST | Create or update |
| `delete` | POST | Delete with disk cleanup |
| `changestatus` | POST | Publish or archive |
| `upload` | POST | Multipart file upload to `~/Data_Uploads/Communications/` |
| `removeattachment` | POST | Remove attachment + delete file |
| `readstats` | GET | Reader list for a communication |

### CommunicationAnalytics.aspx — Read Tracking Analytics
- **CSS prefix:** `ca-`
- **Communication dropdown** with read counts
- **Reader filter:** Confirmed/Unconfirmed/Student/Staff
- **Stats row:** Total readers, confirmed count, student/staff breakdown
- **Reader details table** with timestamps
- **CSV export** button

**AJAX Endpoints (CommunicationAnalytics.aspx.cs):**
| Endpoint | Method | Description |
|----------|--------|-------------|
| `commlist` | GET | Dropdown data with read counts |
| `readdetails` | GET | Detailed reader list with stats |
| `exportcsv` | GET | CSV download |

---

## Portal Pages (CampusDynamics_Portal/)

### NoticeBoard.aspx — Notice List
- **CSS prefix:** `nb-`
- **Scrolling Marquee:** Top 5 unread notices, pauses on hover, seamlessly loops
- **Unread Section:** Blue dot indicators, notice cards with excerpts, badges (URGENT/HIGH/force-read)
- **Read Section:** Previously read notices in muted style
- **Each card links to** `NoticeDetail.aspx?id=`

**AJAX Endpoints (NoticeBoard.aspx.cs):**
| Endpoint | Method | Description |
|----------|--------|-------------|
| `list` | GET | Published communications split into read/unread arrays |
| `markread` | POST | INSERT IGNORE into reads table |

### NoticeDetail.aspx — Individual Notice View
- **CSS prefix:** `nd-`
- **Full notice** with rich content rendering, metadata
- **Attachment downloads** section
- **Confirmation section:** User must type "I HAVE READ THIS NOTICE" exactly; input turns green on match
- **Comments section:** View and add comments (if allowed)

**AJAX Endpoints (NoticeDetail.aspx.cs):**
| Endpoint | Method | Description |
|----------|--------|-------------|
| `getnotice` | GET | Full notice + attachments + user's confirmed status |
| `markread` | POST | INSERT IGNORE read record |
| `confirm` | POST | Validates exact text, updates confirmed_at |
| `loadcomments` | GET | Comment list |
| `addcomment` | POST | Add comment (checks allow_comments) |

### ForceRead.aspx — Force-Read Queue
- **CSS prefix:** `fr-`
- **Intercepts after login** when user has unread force-read notices
- **Progress bar** showing position in queue (e.g., "Notice 2 of 3")
- **Red alert banner** explaining acknowledgement is required
- **Full notice card** with content + attachments
- **Confirmation input:** Must type "I HAVE READ THIS NOTICE" to proceed
- **Queue system:** Shows notices one-by-one; advances to next on confirm
- **Redirects to dashboard** when all are confirmed

**AJAX Endpoints (ForceRead.aspx.cs):**
| Endpoint | Method | Description |
|----------|--------|-------------|
| `getpending` | GET | All pending force-read notices with attachments |
| `markread` | POST | INSERT IGNORE read record |
| `confirm` | POST | Validates text, updates confirmed_at + confirmation_text |

---

## Master Page Modifications

### SidebarMaster.master (Admin)
- **New section ⑨ COMMUNICATIONS** inserted between Load Allocation and System sections
- Roles: `dean registrar faculty_staff admin`
- Links: Manage Communications, Read Analytics
- System section renumbered to ⑩

### SidebarMaster.master.cs
- Added page title cases: `communications` → "Communications", `communicationanalytics` → "Communication Analytics"

### PortalMaster.master (Portal)
- Updated Notices nav link: `StudentNotices.aspx` → `NoticeBoard.aspx`
- Added notification badge (red dot) on Notices link when unread count > 0
- Added `cd-nav-badge` class for badge styling

### PortalMaster.master.cs
- **`UnreadNoticeCount`** property — Counts unread published communications for current user
- **`LoadNotificationBadge()`** — Queries `sys_communications` LEFT JOIN `sys_communication_reads` to compute unread count
- **`GetPendingForceReadCount()`** — Checks for unconfirmed force-read notices
- **Force-read redirect** in `Page_Load` — If pending force-reads exist and not already on ForceRead.aspx, redirects to ForceRead.aspx (runs before enrollment gate)
- Added `using MySql.Data.MySqlClient` import

---

## File Upload

- **Storage:** `~/Data_Uploads/Communications/`
- **Naming:** Original filename + random suffix for uniqueness
- **Cleanup:** Files deleted from disk when communication or attachment is removed
- **Access:** Direct URL via `ResolveUrl()`

---

## Key Design Decisions

1. **New tables** (`sys_communications` family) — Existing `acad_notices` table left untouched to avoid breaking legacy functionality
2. **INSERT IGNORE** for read tracking — Handles unique constraint gracefully for duplicate reads
3. **Force-read expiry** — Notices can have optional expiry dates; expired force-reads don't block login
4. **Confirmation text validation** — Server-side check that user typed exact phrase "I HAVE READ THIS NOTICE"
5. **Reflection for ActiveNav** — Portal pages set master page's `ActiveNav` property via reflection to avoid cast issues
6. **Portal connection string fallback** — `campus_dynamics_portalConnectionString` → `vacConnectionString`

---

## Files Created

| # | File | Location |
|---|------|----------|
| 1 | `comm_module_migration.sql` | `COOPERP/NewScreens/migrations/` |
| 2 | `Communications.aspx` | `COOPERP/NewScreens/` |
| 3 | `Communications.aspx.cs` | `COOPERP/NewScreens/` |
| 4 | `CommunicationAnalytics.aspx` | `COOPERP/NewScreens/` |
| 5 | `CommunicationAnalytics.aspx.cs` | `COOPERP/NewScreens/` |
| 6 | `NoticeBoard.aspx` | `CampusDynamics_Portal/` |
| 7 | `NoticeBoard.aspx.cs` | `CampusDynamics_Portal/` |
| 8 | `NoticeDetail.aspx` | `CampusDynamics_Portal/` |
| 9 | `NoticeDetail.aspx.cs` | `CampusDynamics_Portal/` |
| 10 | `ForceRead.aspx` | `CampusDynamics_Portal/` |
| 11 | `ForceRead.aspx.cs` | `CampusDynamics_Portal/` |

## Files Modified

| # | File | Changes |
|---|------|---------|
| 1 | `SidebarMaster.master` | Added ⑨ Communications section with 2 nav links |
| 2 | `SidebarMaster.master.cs` | Added 2 page title switch cases |
| 3 | `PortalMaster.master` | Updated Notices link to NoticeBoard.aspx + notification badge |
| 4 | `PortalMaster.master.cs` | Added UnreadNoticeCount, LoadNotificationBadge(), GetPendingForceReadCount(), force-read redirect, MySql import |
