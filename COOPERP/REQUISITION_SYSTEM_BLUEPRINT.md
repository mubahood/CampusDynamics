# Requisition Management System — Full Blueprint
**Campus Dynamics MRU · COOPERP · v1.0 · 2026-05-21**
**Lead: Campus Dynamics Developer**

---

## 1. Executive Summary

The Requisition Management System replaces informal paper-based procurement requests with a fully digital, multi-stage approval workflow spanning both the Employee Portal (ePortal) and the Administration System (eAdmin). Every requisition travels through a defined approval chain — from the requester through their supervisor, to the Bursar (who may escalate to the Vice Chancellor or divert to Procurement), and finally to Finance for payment and ledger posting.

The system is modelled architecturally on the Performance Appraisal module (same stage-progress UI, same audit trail pattern, same card-based layout) to ensure consistency and fast staff uptake.

---

## 2. Workflow State Machine

```
╔══════════════════════════════════════════════════════════╗
║              REQUISITION LIFECYCLE                       ║
╚══════════════════════════════════════════════════════════╝

[Requester — ePortal]
   DRAFT ──(submit)──► SUBMITTED
                           │
                    [Supervisor — ePortal]
                           │
               ┌───────────┴────────────┐
         SUPERVISOR_APPROVED       SUPERVISOR_REJECTED ──► (requester revises → DRAFT)
               │
         [Bursar — eAdmin]
         BURSAR_REVIEW
               │
     ┌─────────┼─────────┐
     │         │         │
  (Direct)  (Escalate) (Procure)
     │         │         │
BURSAR_    VC_PENDING  PROCUREMENT
APPROVED       │         │
     │    VC_APPROVED  PROCUREMENT_COMPLETE
     │    VC_REJECTED       │
     │         │           │
     └────┬────┘           │
          │                │
     [Finance — eAdmin]    │
     FINANCE_REVIEW ◄──────┘
          │
     ┌────┴────┐
  PAID_OUT  PENDING_PAYMENT
     │         │
  (Ledger   (Stays in
   Posted)   Finance
             Queue)

At any stage (except PAID_OUT):
  → RETURNED   (returned to requester with remarks for revision)
  → CANCELLED  (by requester or admin)
```

### Status Codes Reference

| Status Code            | Stage        | Actor        | Meaning                                         |
|------------------------|--------------|--------------|--------------------------------------------------|
| `DRAFT`                | Requester    | Requester    | Created, not yet submitted                       |
| `SUBMITTED`            | Supervisor   | System       | Awaiting supervisor sanction                     |
| `SUPERVISOR_APPROVED`  | Bursar       | Supervisor   | Sanctioned — sent to Bursar queue                |
| `SUPERVISOR_REJECTED`  | Requester    | Supervisor   | Rejected — requester must revise or cancel       |
| `BURSAR_REVIEW`        | Bursar       | System       | Under Bursar review                              |
| `BURSAR_APPROVED`      | Finance      | Bursar       | Approved — sent directly to Finance              |
| `VC_PENDING`           | VC Office    | Bursar       | Escalated — awaiting Vice Chancellor approval    |
| `VC_APPROVED`          | Finance      | VC/System    | VC approved — sent to Finance                    |
| `VC_REJECTED`          | Requester    | VC           | VC rejected — returned to requester              |
| `PROCUREMENT`          | Procurement  | Bursar       | Routed to Procurement section                    |
| `PROCUREMENT_COMPLETE` | Finance      | Procurement  | Procurement done — sent to Finance               |
| `FINANCE_REVIEW`       | Finance      | System       | Under Finance review/processing                  |
| `PAID_OUT`             | Closed       | Finance      | Payment confirmed and disbursed                  |
| `PENDING_PAYMENT`      | Finance      | Finance      | Acknowledged — awaiting payment funds            |
| `RETURNED`             | Requester    | Any approver | Returned with remarks for correction             |
| `CANCELLED`            | Closed       | Any          | Cancelled — no further action                    |

---

## 3. Database Schema

All tables go into the **`campus_dynamics`** database (shared with the admin system). Portal reads via `campus_dynamics_portalConnectionString`.

### 3.1 `sys_requisitions` — Master Requisition Table

```sql
CREATE TABLE sys_requisitions (
  ID                     INT AUTO_INCREMENT PRIMARY KEY,
  req_number             VARCHAR(20)  NOT NULL UNIQUE,          -- REQ-2026-0001
  title                  VARCHAR(255) NOT NULL,
  description            TEXT,                                  -- justification / purpose
  req_type               ENUM(
                           'GOODS','SERVICES','WORKS',
                           'TRAVEL','MAINTENANCE','OTHER'
                         ) NOT NULL DEFAULT 'GOODS',
  priority               ENUM('LOW','MEDIUM','HIGH','URGENT') DEFAULT 'MEDIUM',
  status                 VARCHAR(30)  NOT NULL DEFAULT 'DRAFT',
  total_amount           DECIMAL(15,2) DEFAULT 0.00,
  currency               VARCHAR(5)   DEFAULT 'UGX',
  financial_year         VARCHAR(10),                           -- e.g. 2025/2026
  period_label           VARCHAR(50),                          -- e.g. Semester I 2026

  -- Requester
  requester_id           INT,
  requester_name         VARCHAR(150),
  requester_email        VARCHAR(150),
  requester_phone        VARCHAR(30),
  department             VARCHAR(150),
  section                VARCHAR(100),

  -- Supervisor Stage
  supervisor_id          INT,
  supervisor_name        VARCHAR(150),
  supervisor_action      ENUM('PENDING','APPROVED','REJECTED') DEFAULT 'PENDING',
  supervisor_remarks     TEXT,
  supervisor_at          DATETIME,

  -- Bursar Stage
  bursar_action          ENUM('PENDING','APPROVED','RETURNED','ESCALATED','PROCUREMENT') DEFAULT 'PENDING',
  bursar_remarks         TEXT,
  bursar_route           ENUM('FINANCE','VC','PROCUREMENT') DEFAULT 'FINANCE',
  bursar_processed_by    VARCHAR(150),
  bursar_at              DATETIME,

  -- VC Stage (optional)
  vc_action              ENUM('PENDING','APPROVED','REJECTED') DEFAULT 'PENDING',
  vc_remarks             TEXT,
  vc_processed_by        VARCHAR(150),
  vc_at                  DATETIME,

  -- Procurement Stage (optional)
  procurement_status     VARCHAR(50),
  procurement_remarks    TEXT,
  procurement_processed_by VARCHAR(150),
  procurement_at         DATETIME,
  lpo_number             VARCHAR(50),                          -- Local Purchase Order ref

  -- Finance Stage
  finance_action         ENUM('PENDING','PAID','PENDING_PAYMENT','REJECTED') DEFAULT 'PENDING',
  finance_remarks        TEXT,
  finance_processed_by   VARCHAR(150),
  finance_at             DATETIME,
  payment_method         ENUM('CASH','CHEQUE','BANK_TRANSFER','MOBILE_MONEY','IMPREST') DEFAULT 'CASH',
  payment_ref            VARCHAR(100),
  payment_date           DATE,
  ledger_ref             VARCHAR(100),                         -- GL reference after posting
  ledger_posted          TINYINT(1) DEFAULT 0,
  ledger_posted_at       DATETIME,

  -- Meta
  submitted_at           DATETIME,
  created_by             VARCHAR(100),
  created_at             DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at             DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  is_deleted             TINYINT(1) DEFAULT 0,

  INDEX idx_status (status),
  INDEX idx_requester (requester_id),
  INDEX idx_req_number (req_number),
  INDEX idx_created_at (created_at)
);
```

### 3.2 `sys_requisition_items` — Line Items

```sql
CREATE TABLE sys_requisition_items (
  ID                INT AUTO_INCREMENT PRIMARY KEY,
  requisition_id    INT NOT NULL,
  item_no           INT NOT NULL DEFAULT 1,                    -- line number 1, 2, 3…
  description       VARCHAR(500) NOT NULL,
  unit              VARCHAR(30)  DEFAULT 'pcs',               -- pcs, kg, litres, reams…
  qty               DECIMAL(10,2) NOT NULL DEFAULT 1,
  unit_price        DECIMAL(15,2) NOT NULL DEFAULT 0,
  total_price       DECIMAL(15,2) GENERATED ALWAYS AS (qty * unit_price) STORED,
  category          VARCHAR(100),                             -- Stationery, ICT, Furniture…
  notes             TEXT,
  created_at        DATETIME DEFAULT CURRENT_TIMESTAMP,

  FOREIGN KEY (requisition_id) REFERENCES sys_requisitions(ID) ON DELETE CASCADE,
  INDEX idx_req_items (requisition_id)
);
```

> **Note:** If the MySQL version doesn't support generated columns, compute `total_price` in application code (qty × unit_price) and store as a regular DECIMAL column.

### 3.3 `sys_requisition_audit` — Full Audit Trail

```sql
CREATE TABLE sys_requisition_audit (
  ID              INT AUTO_INCREMENT PRIMARY KEY,
  requisition_id  INT NOT NULL,
  action_code     VARCHAR(50) NOT NULL,                       -- SUBMITTED, APPROVED, REJECTED…
  old_status      VARCHAR(30),
  new_status      VARCHAR(30),
  actor_name      VARCHAR(150),
  actor_role      VARCHAR(80),                                -- REQUESTER, SUPERVISOR, BURSAR…
  remarks         TEXT,
  ip_address      VARCHAR(45),
  created_at      DATETIME DEFAULT CURRENT_TIMESTAMP,

  FOREIGN KEY (requisition_id) REFERENCES sys_requisitions(ID) ON DELETE CASCADE,
  INDEX idx_audit_req (requisition_id)
);
```

### 3.4 `sys_requisition_attachments` — Supporting Documents

```sql
CREATE TABLE sys_requisition_attachments (
  ID              INT AUTO_INCREMENT PRIMARY KEY,
  requisition_id  INT NOT NULL,
  file_name       VARCHAR(255) NOT NULL,
  file_path       VARCHAR(500) NOT NULL,
  file_size       INT DEFAULT 0,                              -- bytes
  file_type       VARCHAR(20),                               -- pdf, jpg, png, docx
  uploaded_by     VARCHAR(150),
  uploaded_at     DATETIME DEFAULT CURRENT_TIMESTAMP,

  FOREIGN KEY (requisition_id) REFERENCES sys_requisitions(ID) ON DELETE CASCADE
);
```

### 3.5 Auto-Numbering Stored Procedure

```sql
DELIMITER $$
CREATE PROCEDURE sp_generate_req_number(OUT p_number VARCHAR(20))
BEGIN
  DECLARE v_year VARCHAR(4);
  DECLARE v_seq  INT;
  SET v_year = YEAR(NOW());
  SELECT COALESCE(MAX(CAST(SUBSTRING_INDEX(req_number, '-', -1) AS UNSIGNED)), 0) + 1
    INTO v_seq
    FROM sys_requisitions
   WHERE req_number LIKE CONCAT('REQ-', v_year, '-%');
  SET p_number = CONCAT('REQ-', v_year, '-', LPAD(v_seq, 4, '0'));
END$$
DELIMITER ;
```

---

## 4. Pages & Screens

### 4.1 ePortal Pages (Staff-Facing)

| Page | File | Who Sees It | Purpose |
|------|------|-------------|---------|
| New Requisition | `RequisitionForm.aspx` | All staff | Create / edit a requisition with items |
| My Requisitions | `MyRequisitions.aspx` | All staff | Dashboard showing own requisitions + status |
| Supervisor Queue | `SupervisorRequisitions.aspx` | Supervisors | Pending sanctions + history |
| View Requisition | `RequisitionView.aspx` | All staff | Read-only detail + timeline (portal-side) |

### 4.2 eAdmin Pages (Management/Finance)

| Page | File | Who Uses It | Purpose |
|------|------|-------------|---------|
| Master Controller | `NewScreens/RequisitionsController.aspx` | Admin / IT | All requisitions, charts, search |
| Bursar Queue | `NewScreens/BursarRequisitions.aspx` | Bursar | Review, approve, route, escalate |
| Finance Queue | `NewScreens/FinanceRequisitions.aspx` | Finance officer | Process payment, post to ledger |
| Procurement Queue | `NewScreens/ProcurementRequisitions.aspx` | Procurement | Handle LPO, supplier, delivery |
| Detail View | `NewScreens/RequisitionDetail.aspx` | All admin roles | Full requisition + timeline (admin-side) |

---

## 5. UI Design Specification

### 5.1 Stage Progress Bar (top of every requisition page)

```
[1. Submitted] ──► [2. Supervisor] ──► [3. Bursar] ──► [4. Finance] ──► [5. Closed]
   ●──────────────────●──────────────────○──────────────────○──────────────────○
   DONE               DONE             CURRENT            PENDING           PENDING
```

- Filled circle (`●`) = completed stage
- Hollow circle (`○`) = pending
- Pulsing circle = current active stage
- Rejected/returned stages turn red

### 5.2 Colour Coding (Status Badges)

| Status | Badge Style |
|--------|-------------|
| DRAFT | `background:#f1f5f9; color:#64748b` (grey) |
| SUBMITTED | `background:#dbeafe; color:#1d4ed8` (blue) |
| SUPERVISOR_APPROVED | `background:#dcfce7; color:#16a34a` (green) |
| SUPERVISOR_REJECTED | `background:#fee2e2; color:#dc2626` (red) |
| BURSAR_REVIEW | `background:#fef3c7; color:#d97706` (amber) |
| BURSAR_APPROVED | `background:#dcfce7; color:#16a34a` (green) |
| VC_PENDING | `background:#f3e8ff; color:#7c3aed` (purple) |
| VC_APPROVED | `background:#dcfce7; color:#16a34a` (green) |
| VC_REJECTED | `background:#fee2e2; color:#dc2626` (red) |
| PROCUREMENT | `background:#e0f2fe; color:#0369a1` (sky) |
| FINANCE_REVIEW | `background:#fef3c7; color:#d97706` (amber) |
| PAID_OUT | `background:#05275C; color:#fff` (navy) |
| PENDING_PAYMENT | `background:#fef9c3; color:#854d0e` (yellow) |
| RETURNED | `background:#ffedd5; color:#c2410c` (orange) |
| CANCELLED | `background:#f1f5f9; color:#475569` (slate) |

### 5.3 Items Table Layout (RequisitionForm)

```
┌────┬──────────────────────────────┬──────┬────────┬──────────────┬───────────────┐
│ #  │ Description                  │ Unit │  Qty   │ Unit Price   │   Total (UGX) │
├────┼──────────────────────────────┼──────┼────────┼──────────────┼───────────────┤
│ 1  │ A4 Paper Reams               │ reams│  10    │ 15,000       │   150,000     │
│ 2  │ Printer Cartridge HP 85A     │ pcs  │   2    │ 120,000      │   240,000     │
│    │ [+ Add Item]                 │      │        │              │               │
├────┴──────────────────────────────┴──────┴────────┴──────────────┼───────────────┤
│                                                    GRAND TOTAL   │   390,000     │
└─────────────────────────────────────────────────────────────────┴───────────────┘
```

### 5.4 Approval Action Panel (bottom of detail view — role-conditional)

```
┌─────────────────────────────────────────────────────────────────────┐
│  SUPERVISOR ACTION — REQ-2026-0001                                  │
│                                                                     │
│  Remarks: [______________________________________________]           │
│                                                                     │
│  [✓ Approve & Forward]   [↩ Return for Correction]   [✗ Reject]   │
└─────────────────────────────────────────────────────────────────────┘
```

For Bursar, the panel has routing options:
```
  Route to: ● Finance directly   ○ Vice Chancellor   ○ Procurement
```

For Finance, the panel has:
```
  Payment Method: [Cash ▼]    Reference: [__________]    Date: [____]
  [✓ Mark as Paid & Post Ledger]    [⏳ Mark as Pending Payment]
```

### 5.5 Audit Timeline (bottom of all detail views)

```
  ─ REQ-2026-0001 TIMELINE ──────────────────────────────────
  
  ✓ 2026-05-21 09:14  SUBMITTED       John Mukasa (Requester)
    "Submitted for supervisor review"

  ✓ 2026-05-21 11:02  APPROVED        Dr. Sarah Nanteza (Supervisor)
    "Approved. Items within departmental budget."

  ◉ 2026-05-21 14:30  BURSAR_REVIEW   [Current Stage]
  
  ○ —————————————     FINANCE         [Pending]
  ○ —————————————     CLOSED          [Pending]
```

---

## 6. Business Rules

### 6.1 Requisition Number
- Format: `REQ-YYYY-NNNN` (e.g. REQ-2026-0001)
- Auto-generated on first save (even in DRAFT)
- Sequence resets each calendar year
- Never reused, never editable

### 6.2 Item Totals
- `total_price = qty × unit_price` (computed — never manually entered)
- Grand total = SUM of all `total_price` values
- Grand total auto-refreshes on every item add/edit/remove (client-side JS)
- Grand total stored in `sys_requisitions.total_amount`

### 6.3 Amount Thresholds (suggested — configurable)
| Amount | Required Approval Level |
|--------|------------------------|
| UGX 0 – 500,000 | Bursar can approve directly |
| UGX 500,001 – 5,000,000 | Bursar recommends; VC approves |
| UGX 5,000,001+ | Must go to VC — Bursar cannot approve directly |
- **Note:** These are soft guidelines. The Bursar always has discretion to escalate or approve at any amount.

### 6.4 Edit Restrictions
| Status | Requester Can Edit? | Notes |
|--------|---------------------|-------|
| DRAFT | Yes | Full edit + add/remove items |
| SUBMITTED | No | Read-only until returned |
| RETURNED | Yes | Full edit again, then re-submit |
| Any approved status | No | Locked permanently |

### 6.5 Audit Requirement
- Every status change writes a row to `sys_requisition_audit`
- Remarks are mandatory when: REJECTING, RETURNING, ESCALATING TO VC
- Remarks are optional when: APPROVING, MARKING PAID

### 6.6 Procurement Route
When Bursar routes to Procurement:
1. Procurement officer sees it in their queue
2. Procurement can enter: LPO Number, supplier name, expected delivery date
3. On completion, Procurement marks `PROCUREMENT_COMPLETE` → auto-moves to Finance queue

### 6.7 Ledger Posting
- Finance may post to ledger after marking `PAID_OUT`
- Posting writes: debit to expense account, credit to cash/bank
- `ledger_ref` stored on the requisition for cross-reference
- Once ledger is posted (`ledger_posted = 1`), the requisition is truly closed

---

## 7. ePortal — RequisitionForm.aspx

### Purpose
Create a new requisition or edit a DRAFT/RETURNED one.

### Sections
1. **Header Card** — Requisition number (auto), title, type, priority, period
2. **Justification Card** — Full description / purpose text area
3. **Items Table** — Dynamic add/remove rows (JS-driven)
4. **Totals Summary** — Grand total auto-computed
5. **Action Bar** — [Save as Draft] [Submit for Approval]

### Key Behaviors
- Item rows added/removed dynamically (no postback) via JS `addItemRow()` / `removeItemRow()`
- Grand total computed client-side and shown in real time
- On submit: validate ≥1 item, total > 0, title not empty
- Req number generated on server on first save

---

## 8. ePortal — MyRequisitions.aspx

### Purpose
Requester's personal dashboard.

### Layout
- **Hero Stats Row** (4 cards): Total Submitted | Pending Approval | Approved | Paid Out
- **Status Filter Tabs**: All | Pending | Approved | Paid | Returned/Rejected
- **Requisitions Table**: req_number | title | total (UGX) | status badge | submitted_at | action
- **[+ New Requisition]** button → RequisitionForm.aspx

---

## 9. ePortal — SupervisorRequisitions.aspx

### Purpose
Supervisor sees all requisitions from their team awaiting their action.

### Layout
- **Pending Tab** — Requisitions in `SUBMITTED` status from staff under this supervisor
- **History Tab** — All requisitions the supervisor has ever acted on
- **[View & Decide]** opens the detail/action panel inline or as popup

### Supervisor Identification
- Supervisor ID pulled from `Session["supervisor_id"]` or staff profile
- Filter: `WHERE supervisor_id = @my_id AND status = 'SUBMITTED'`

---

## 10. eAdmin — RequisitionsController.aspx

### Purpose
Master admin overview for IT/Management — see all requisitions, search, filter, export.

### Layout
- **KPI Cards Row** (5): Total Requisitions | In Pipeline | Paid Out | Total Value UGX | Avg Processing Days
- **Chart Row**: Monthly Requisitions by Status (stacked bar) | By Department (horizontal bar) | By Type (doughnut)
- **Filter Bar**: Year | Department | Status | Type | Date Range | Search
- **Master Grid**: All requisitions — sortable, paginated, exportable
- **Quick Actions**: View | Print | Cancel

---

## 11. eAdmin — BursarRequisitions.aspx

### Purpose
Bursar's approval queue.

### Tabs
1. **Pending** — `status = 'SUPERVISOR_APPROVED'` → Bursar Review
2. **VC Pending** — Escalated to VC — track without action needed
3. **History** — All bursar-actioned requisitions

### Action Panel (for each requisition)
- Remarks text area
- Route selector: Finance / Vice Chancellor / Procurement
- Buttons: [Approve & Route] [Return for Correction] [Reject]

---

## 12. eAdmin — FinanceRequisitions.aspx

### Purpose
Finance processes payment and posts to ledger.

### Tabs
1. **Awaiting Payment** — `status IN ('BURSAR_APPROVED','VC_APPROVED','PROCUREMENT_COMPLETE')`
2. **Pending Payment** — `status = 'PENDING_PAYMENT'` — acknowledged, funds not yet released
3. **Paid Out** — `status = 'PAID_OUT'` — complete history
4. **Ledger Unposted** — `status = 'PAID_OUT' AND ledger_posted = 0` — action needed

### Action Panel
- Payment Method dropdown
- Reference / cheque number input
- Payment Date picker
- Remarks
- Buttons: [Mark Paid & Post Ledger] [Mark as Pending] [Return to Bursar]

---

## 13. eAdmin — RequisitionDetail.aspx

### Purpose
Universal read + action view for all admin roles.

### Layout
1. **Stage Progress Bar** — visual workflow position
2. **Requisition Header** — number, title, type, priority, department, requester
3. **Items Table** — all line items (read-only in this view)
4. **Totals Panel** — grand total, payment details (if actioned by finance)
5. **Role-Conditional Action Panel** — shown only if current user's role matches current stage
6. **Audit Timeline** — full history from submission to present
7. **Attachments** — downloadable files

---

## 14. Implementation Order

| Step | Task | Files |
|------|------|-------|
| 1 | Run DDL SQL — create 4 tables | `sql/requisitions_schema.sql` |
| 2 | ePortal: RequisitionForm | `RequisitionForm.aspx` + `.cs` |
| 3 | ePortal: MyRequisitions | `MyRequisitions.aspx` + `.cs` |
| 4 | ePortal: SupervisorRequisitions | `SupervisorRequisitions.aspx` + `.cs` |
| 5 | eAdmin: RequisitionsController | `NewScreens/RequisitionsController.aspx` + `.cs` |
| 6 | eAdmin: BursarRequisitions | `NewScreens/BursarRequisitions.aspx` + `.cs` |
| 7 | eAdmin: FinanceRequisitions | `NewScreens/FinanceRequisitions.aspx` + `.cs` |
| 8 | eAdmin: RequisitionDetail | `NewScreens/RequisitionDetail.aspx` + `.cs` |
| 9 | Sidebar navigation links | `SidebarMaster.master` |
| 10 | Portal navigation links | Portal master page / menu |

---

## 15. Shared Helper Class — RequisitionHelper.cs

Location: `CampusDynamics/App_Code/Requisitions/RequisitionHelper.cs`

```csharp
// Key methods:
string GenerateReqNumber()           // REQ-YYYY-NNNN
void   LogAudit(int reqId, ...)      // writes sys_requisition_audit
void   SetStatus(int reqId, string status, string actor, string role, string remarks)
string GetStatusBadge(string status) // returns HTML badge span
string GetPriorityBadge(string priority)
string FormatUGX(decimal amount)     // "UGX 1,250,000"
bool   CanEdit(string status)        // DRAFT or RETURNED only
```

---

## 16. Security & Access Control

| Role | Portal Access | Admin Access |
|------|--------------|--------------|
| All Staff | RequisitionForm, MyRequisitions | — |
| Supervisors | + SupervisorRequisitions | — |
| Bursar | — | BursarRequisitions, RequisitionDetail |
| Finance Officer | — | FinanceRequisitions, RequisitionDetail |
| Procurement | — | ProcurementRequisitions, RequisitionDetail |
| VC | — | RequisitionDetail (VC action panel) |
| Admin / IT | — | RequisitionsController (read-only master) |

Access enforced via:
- Portal: `Session["emp_id"]` + `Session["supervisor_flag"]`
- Admin: `Session["username"]` + role group check per page

---

## 17. Key CSS Classes (consistent with appraisal theme)

```css
/* Progress bar */
.req-progress-bar { display:flex; align-items:center; margin-bottom:24px; }
.req-stage { flex:1; text-align:center; position:relative; }
.req-stage.done .req-dot { background:#16a34a; border-color:#16a34a; }
.req-stage.current .req-dot { background:#174DA4; border-color:#174DA4; animation:pulse 1.5s infinite; }
.req-stage.pending .req-dot { background:#fff; border-color:#cbd5e1; }

/* Item table */
.req-items-table { width:100%; border-collapse:collapse; }
.req-items-table th { background:#05275C; color:#fff; padding:8px 10px; font-size:11px; }
.req-items-table td { padding:6px 10px; border-bottom:1px solid #e0e5ed; font-size:12px; }
.req-items-table .col-total { text-align:right; font-weight:600; color:#05275C; }
.req-grand-total { background:#05275C; color:#fff; padding:10px 14px; text-align:right; font-size:14px; font-weight:700; }

/* Action panel */
.req-action-panel { background:#f0f4ff; border:1px solid #174DA4; border-radius:4px; padding:18px; margin-top:20px; }
.req-action-panel h4 { color:#05275C; margin:0 0 12px; font-size:13px; font-weight:700; }

/* Timeline */
.req-timeline { padding:0; list-style:none; }
.req-timeline li { display:flex; gap:12px; padding:10px 0; border-left:2px solid #e0e5ed; margin-left:10px; padding-left:16px; position:relative; }
.req-timeline li::before { content:'●'; position:absolute; left:-9px; color:#174DA4; background:#fff; }
.req-timeline li.current::before { color:#d97706; }
```

---

## 18. Notifications (Future Enhancement)

- Email on SUBMITTED → supervisor email
- Email on SUPERVISOR_APPROVED → bursar email  
- Email on BURSAR_APPROVED → finance email
- Email on PAID_OUT → requester email
- Email on RETURNED/REJECTED → requester email with remarks

Use existing `erp.edusaterp.com` notification API (same as password reset).

---

*This document is the authoritative specification for the Requisition Management System.  
All implementation decisions not covered here should default to the Performance Appraisal module patterns.*
