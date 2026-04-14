# Communications Module — Task Tracking

## Overview
A comprehensive notice/communication system for Campus Dynamics EMIS.
- **Admin** can post communications targeted to Students, Staff, or Both
- **Rich text** content with file attachments (PDF, Word, Excel, images, video)
- **Force-read** mechanism with expiration date and "I HAVE READ THIS NOTICE" confirmation
- **Individual read tracking** with timestamps and confirmation records
- **Post model**, view model, comment model
- **Sidebar menu section** for communications in admin portal
- **Portal-side** forced reading on login (queue system)
- **Notification icon** with unread count in top bar
- **Marquee** of top 5 unread notices
- **Separate read/unread sections** in notice list

## Database Tables (NEW — `sys_communications` family)
| Table | Purpose |
|-------|---------|
| `sys_communications` | Main post/notice records |
| `sys_communication_attachments` | File attachments per communication |
| `sys_communication_reads` | Per-user read + confirmation tracking |
| `sys_communication_comments` | User comments on communications |

## Tasks

### T1 — Database Migration ✅
- CREATE TABLE for all 4 tables with proper indexes
- INSERT dummy data for testing (5 communications, attachments, reads, comments)
- Migration file: `COOPERP/NewScreens/migrations/comm_module_migration.sql`

### T2 — Admin Communications Page (CRUD) ✅
- File: `COOPERP/NewScreens/Communications.aspx` + `.aspx.cs`
- MasterPage: `SidebarMaster.master`
- Features: List grid, create/edit modal, rich text editor, file upload, target audience, force-read toggle, priority, status
- AJAX endpoints: `list`, `get`, `save`, `delete`, `upload`, `removeattachment`, `readstats`
- Pattern: Same as LoadAllocations.aspx (vanilla JS XHR, JSON responses)

### T3 — Admin Communication Analytics Page ✅
- File: `COOPERP/NewScreens/CommunicationAnalytics.aspx` + `.aspx.cs`
- Features: Per-communication reader list, read/unread/confirmed counts, user details, timestamps
- AJAX endpoints: `commsummary`, `readdetails`, `exportcsv`

### T4 — Portal Notice Board Page ✅
- File: `CampusDynamics_Portal/NoticeBoard.aspx` + `.aspx.cs`
- MasterPage: `PortalMaster.master`
- Features: Marquee of top 5 unread, separate Unread/Read sections, cards layout
- Auto-marks as "read" when notice is expanded (but not "confirmed")
- AJAX endpoints: `list`, `markread`

### T5 — Portal Notice Detail Page ✅
- File: `CampusDynamics_Portal/NoticeDetail.aspx` + `.aspx.cs`
- Features: Full content display, attachment downloads, "I HAVE READ THIS NOTICE" confirmation input, comments section
- AJAX endpoints: `getnotice`, `confirm`, `addcomment`, `loadcomments`

### T6 — Portal Force-Read Flow ✅
- File: `CampusDynamics_Portal/ForceRead.aspx` + `.aspx.cs`
- Intercepts after login when user has unread force-read notices
- Queue system — shows notices one-by-one; must confirm each
- Redirects to dashboard when queue is empty
- AJAX endpoints: `getpending`, `confirm`

### T7 — Portal Master Page Modifications ✅
- Add notification bell icon with unread count badge to PortalMaster.master header
- Add `UnreadNoticeCount` property + `LoadNotificationBadge()` to PortalMaster.master.cs
- Add force-read redirect check in `Page_Load` (before enrollment gate)
- Update "Notices" nav link to point to new NoticeBoard.aspx

### T8 — Admin Sidebar Menu Entry ✅
- Add ⑨ COMMUNICATIONS section to SidebarMaster.master (before System)
- Add page title cases to SidebarMaster.master.cs
- Roles: dean registrar faculty_staff admin

### T9 — Implementation Documentation ✅
- Create `COMMUNICATIONS_MODULE_IMPLEMENTATION_LOG.md`
- Update this task file with completion status

## Status Summary
| Task | Status | Files |
|------|--------|-------|
| T1 | ✅ | `migrations/comm_module_migration.sql` |
| T2 | ✅ | `Communications.aspx`, `.aspx.cs` |
| T3 | ✅ | `CommunicationAnalytics.aspx`, `.aspx.cs` |
| T4 | ✅ | `NoticeBoard.aspx`, `.aspx.cs` |
| T5 | ✅ | `NoticeDetail.aspx`, `.aspx.cs` |
| T6 | ✅ | `ForceRead.aspx`, `.aspx.cs` |
| T7 | ✅ | `PortalMaster.master`, `.master.cs` |
| T8 | ✅ | `SidebarMaster.master`, `.master.cs` |
| T9 | ✅ | Documentation files |

**Progress: 9 / 9 tasks complete**
