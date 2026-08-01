# SchoolPay Pull-Sync & Controller — Implementation Plan

**Goal:** Add the ability to **fetch SchoolPay transactions on demand / on a schedule** (the
"pull" / Sync API) so we recover payments made while our webhook was offline, reconcile against
SchoolPay daily, and self-heal stuck rows — **without changing or risking the working inbound
webhook**, and with **bullet-proof duplicate prevention**. Plus a dedicated admin **SchoolPay
Controller** page (trigger fetch, observe recent activity, analytics, reconciliation) added to
the menu.

**Status:** PLAN ONLY — no code written yet. Awaiting decisions in §11.
**Companion analysis:** `COOPERP/SCHOOLPAY_INTEGRATION_REPORT.md` (esp. §3 webhook, §6 GL
posting, §12 Pull API spec).
**Date:** 2026-06-30

---

## 0. Non-negotiable guardrails (how we avoid breaking what works)

1. **The inbound webhook is frozen.** `CampusDynamics_Portal/COOPERP/Mobile/schoolpay_api.aspx`
   and its data layer are **not modified** by this work. The pull path is 100% additive.
2. **Reuse, don't reinvent, the capture pipeline.** Every pulled transaction is funnelled
   through the **same** two steps the webhook uses:
   `INSERT fin_schoolpaydata(... ,'Pending')` → `fin_AutoPayCapture(...)`.
   No new GL-posting code. Identical ledger behaviour, identical balance maths.
3. **`fin_schoolpaydata` is the single source of truth + the dedup ledger.** It stays
   **append-only**: rows are never deleted by this feature; a reversal sets a status, it does
   not remove the row (see §4).
4. **Idempotent by construction.** Re-running any date any number of times must be a no-op for
   already-captured receipts (see §4 — three independent layers).
5. **Config-driven, not hardcoded.** School code, pull password, base URL live in
   `web.config`/secure config, never in source (unlike the current webhook secret).
6. **Fail safe, fail loud.** Any fetch error logs to a sync-audit table and surfaces in the UI;
   it never partially-posts or corrupts the ledger.

---

## 1. Prerequisites (Phase 1 — Discovery; blocks everything else)

Obtain from SchoolPay / finance and confirm by a single live call:

- [ ] **MRU `SCHOOLCODE`** for the pull API (the `7306` slot). *Our webhook serial `202401` is
      probably NOT this.*
- [ ] **Pull `Password`** (separate secret; "shared at integration").
- [ ] **Confirm the base URL** `https://schoolpay.co.ug/paymentapi/AndroidRS/SyncSchoolTransactions/`
      is current and reachable from the eadmin server over HTTPS.
- [ ] **Capture one real response** for a known busy day and record the exact schema:
      content-type (JSON/XML), the field names for amount, payment date, channel/bank, student
      identifier (reg-no vs SchoolPay payment code), student name, and any status — plus where
      `returnCode`/`returnMessage`/`schoolpayReceiptNumber` sit.

**Deliverable:** a short "field-mapping" note appended to the report mapping each response field
→ `fin_schoolpaydata` column. No further code until this is confirmed.

> Discovery hash to test once creds are known: `MD5(SCHOOLCODE + "yyyy-MM-dd" + Password)`.

---

## 2. Architecture

```
  ┌─────────────────────────────────────────────────────────────────────┐
  │  eadmin (main system) — NEW                                          │
  │                                                                       │
  │  SchoolPayController.aspx  ──trigger──►  SchoolPayPullService         │
  │   (admin page, menu item)                 (App_Code/Finance/…)        │
  │                                              │                        │
  │                                              │ 1. build URL+hash      │
  │                                              ▼                        │
  │                            GET schoolpay.co.ug/.../{code}/{date}/{hash}│
  │                                              │ returnCode==0?         │
  │                                              ▼ for each txn           │
  │                            ┌──────────────────────────────────────┐  │
  │                            │ DEDUP GATE (see §4)                   │  │
  │                            │  exists? Captured→skip                │  │
  │                            │          Pending→re-capture           │  │
  │                            │          none   →INSERT Pending       │  │
  │                            │  then CALL fin_AutoPayCapture (reuse) │  │
  │                            └──────────────────────────────────────┘  │
  │                                              │                        │
  │                                              ▼                        │
  │                            fin_schoolpaydata + GL (UNCHANGED SPs)    │
  │                            fin_schoolpay_synclog (NEW audit)         │
  └─────────────────────────────────────────────────────────────────────┘
```

**Why eadmin (not the portal):** finance staff work in eadmin; the accounts DB + the existing
`SchoolPayDatal` recapture control already live here; outbound HTTPS from the admin server is
appropriate. The portal webhook stays as the real-time path.

**New components:**
- `App_Code/Finance/SchoolPayPullService.cs` — HTTP fetch + parse + per-txn dedup-gated capture
  + sync-log writing. Pure server-side, reuses existing adapters/SPs.
- `NewScreens/SchoolPayController.aspx(.cs)` — admin UI (SidebarMaster, modern design system).
- `campus_dynamics_accounts.fin_schoolpay_synclog` — audit table (NEW).
- (Optional) two **nullable** columns on `fin_schoolpaydata` (see §3) — additive, safe for the
  existing typed datasets.

---

## 3. Data-model changes (additive only)

### 3.1 New table — `fin_schoolpay_synclog` (campus_dynamics_accounts)
One row per pull run, for audit + reconciliation + the UI history:

| Column | Type | Notes |
|---|---|---|
| `id` | BIGINT PK AUTO_INCREMENT | |
| `txn_date` | DATE | the day fetched |
| `trigger_type` | VARCHAR(20) | `MANUAL` / `SCHEDULED` / `CATCHUP` |
| `triggered_by` | VARCHAR(100) | username or `system` |
| `run_started` / `run_finished` | DATETIME | |
| `return_code` | INT | SchoolPay `returnCode` (0=ok) |
| `return_message` | VARCHAR(500) | error text if any |
| `fetched_count` | INT | txns SchoolPay returned |
| `new_count` | INT | newly inserted |
| `duplicate_count` | INT | already present (skipped) |
| `recaptured_count` | INT | existing Pending that we re-posted |
| `failed_count` | INT | capture failures |
| `sp_total_amount` | DOUBLE | sum from SchoolPay response |
| `local_total_amount` | DOUBLE | sum we now hold for that day |
| `status` | VARCHAR(20) | `OK` / `PARTIAL` / `FAILED` |

### 3.2 Optional additive columns on `fin_schoolpaydata`
To distinguish origin and support append-only reversal **without breaking the existing typed
datasets** (their INSERT/UPDATE use explicit column lists, so new nullable/defaulted columns are
ignored by them):

- `source VARCHAR(12) NULL` — `WEBHOOK` (default for legacy) / `PULL`.
- `synced_at DATETIME NULL` — when a pull touched the row.
- (reuse existing `captureStatus` for a new value `Reversed`/`Ignored` instead of deleting.)

> If we prefer **zero** changes to `fin_schoolpaydata`, we can skip 3.2 entirely and rely only
> on `fin_schoolpay_synclog`. Decision in §11.

---

## 4. Duplicate prevention — three independent layers (the core of the design)

A pulled transaction can collide with (a) itself on re-run, (b) the same payment already
captured by the webhook, or (c) a previously-failed Pending row. All are handled:

**Layer 1 — Application pre-check (per transaction):**
```
look up fin_schoolpaydata by ReceiptNo = schoolpayReceiptNumber
  • not found      → INSERT (…, 'Pending')  then call capture     → new_count++
  • found, Pending → DO NOT insert; call capture (re-drive)        → recaptured_count++
  • found, Captured→ skip entirely                                 → duplicate_count++
  • found, Reversed/Ignored → skip + flag for review              → duplicate_count++
```

**Layer 2 — Primary-key constraint:** `fin_schoolpaydata.ReceiptNo` is the PK. Even under a race
(webhook + pull at the same instant), the second INSERT throws a duplicate-key error which we
catch and treat as "already have it". Same mechanism the webhook already relies on.

**Layer 3 — GL-posting guard (already in `fin_AutoPayCapture`):** the SP posts to the ledger
**only when** `captureStatus='Pending'` for that receipt, then flips it to `Captured`. So the
double-entry can fire **at most once per receipt**, no matter how many times capture is called.
This is the ultimate backstop: *the money cannot be posted twice.*

**Append-only rule (prevents the one dangerous case):** never `DELETE` from `fin_schoolpaydata`.
If a payment must be reversed, post a GL reversal and set `captureStatus='Reversed'` — the row
stays, so a future pull sees it and **skips** it (it will never be re-introduced). Document this
for the finance team and, ideally, revoke DELETE on the table for app users.

---

## 5. Admin page — **SchoolPay Controller** (`NewScreens/SchoolPayController.aspx`)

Built on `SidebarMaster.master` + the design system (navy `#05275C`, etc.). Tabs/sections:

1. **Sync / Fetch**
   - Date picker (single day) **and** a date-range (loops day-by-day, one call per day — the API
     is one-day-per-request). "Fetch Now" button.
   - "Catch-up last N days" quick action (e.g. 7/30).
   - Live progress + per-day result (fetched / new / duplicates / recaptured / failed / totals,
     and `returnCode`/`returnMessage`).
2. **Recent activity (observe)**
   - Live feed of the last N captured transactions (auto-refresh), with channel, amount, student,
     status — a quick "is money flowing?" glance.
3. **Reconciliation**
   - Per-day table: SchoolPay total vs our total, count vs count, **missing receipts** list, and
     a one-click "fetch & fix this day".
   - Highlights days where `sp_total_amount ≠ local_total_amount`.
4. **Pending / failures**
   - The current stuck `Pending` rows (today there are 13 = UGX 5.84M) with a "Recapture"
     action — consolidates / links the existing `SchoolPayDatal` capability.
5. **Analytics**
   - Today/this-week/month totals, channel split (Airtel/MTN/Stanbic/…), daily trend, capture
     success rate. Read-only DevExpress or lightweight charts.
6. **Sync log**
   - Full `fin_schoolpay_synclog` history with filters (date, trigger, status).

**Menu placement:** add a **"SchoolPay Controller"** item under the **Finance/Accounts** group in
`NewScreens/SidebarMaster.master` (and optionally a link from the legacy
`financials/SchoolPayTransactions.aspx`). Gated to finance/admin roles.

---

## 6. Scheduling & offline recovery

- **Manual** (always available): the Controller page Fetch/Catch-up actions.
- **Automated daily catch-up:** a safe recurring job that re-syncs the **last K days** (e.g. 3)
  every night, so any webhook gaps self-heal within the window. Options (decision in §11):
  - a DB event / external Windows Task Scheduler hitting a protected `?task=sync` endpoint, or
  - an in-app scheduler. Whichever, it just calls `SchoolPayPullService.SyncDay(date)`.
- **Offline scenario covered:** webhook down 09:00–11:00 → those pushes are lost → the nightly
  catch-up (or a manual "fetch today") pulls the full day from SchoolPay → missing receipts are
  inserted + captured; already-captured ones are skipped. Net: complete, no duplicates.
- Maintain a "last fully-reconciled date" marker so we know the trailing edge of guaranteed
  coverage.

---

## 7. Robustness

- **HTTP:** explicit timeout (e.g. 60s), TLS, 1–2 retries with backoff on transport errors;
  treat a non-zero `returnCode` as a logged failure, not an exception.
- **Parsing:** defensive — tolerate missing/extra fields; reject a day's import if the response
  is unparseable (log, status=FAILED, change nothing).
- **Per-transaction isolation:** a failure on one txn (bad reg-no, capture error) is caught,
  counted in `failed_count`, and does **not** abort the rest of the day.
- **Concurrency:** a per-day advisory lock (or a "sync in progress" flag) so two operators can't
  double-run the same day simultaneously (Layer 2/3 still protect correctness regardless).
- **No secrets in logs.** Hash inputs/password never logged.
- **Everything observable:** every run writes `fin_schoolpay_synclog`; the UI shows it.

---

## 8. Security

- School code + pull password + base URL → `web.config` `appSettings` (or encrypted config),
  read at runtime. **Not** in source.
- While here, recommend (separate task, not required for pull) hardening the **inbound** webhook
  per report §10: move `202401`/`!Mr$u#2024` to config, HMAC the payload, IP allow-list.
- Controller page behind the finance/admin role; the auto-sync trigger endpoint protected by a
  shared secret + IP restriction.

---

## 9. Reconciliation logic

For a date D:
- `sp = ` SchoolPay response totals (count, Σamount) for D.
- `local = ` `SELECT COUNT(*), SUM(amount_paid) FROM fin_schoolpaydata WHERE DATE(datePaid)=D`.
- **Missing = ** receipt numbers in `sp` not in `fin_schoolpaydata` → fetch+capture them.
- **Extra/mismatch** (rare): receipts we have that SchoolPay's response lacks, or amount
  mismatches on the same receipt → list for manual review (never auto-overwrite a Captured row).
- Persist the comparison into `fin_schoolpay_synclog` (`sp_total_amount` vs `local_total_amount`,
  status OK/PARTIAL).

---

## 10. Phased rollout (each phase independently shippable & testable)

| Phase | Deliverable | Breaks anything? |
|---|---|---|
| **1. Discovery** | Creds obtained; one live call; field-mapping note | No (read-only) |
| **2. Service core** | `SchoolPayPullService.SyncDay(date)` (fetch→parse→dedup-gate→reuse capture) + `fin_schoolpay_synclog` | No (additive; dry-run first) |
| **3. Dedup hardening** | Append-only rule enforced; `Reversed` status; optional `source` column | No |
| **4. Controller page** | `SchoolPayController.aspx` (fetch, recent, reconcile, pending, analytics, log) + **menu item** | No |
| **5. Scheduling** | Nightly last-K-days catch-up | No |
| **6. Backfill** | One-time reconcile of recent history; clear the 13 Pending | Careful, audited |

Ship 1→4 first (manual, observable). Add 5 once trusted. Do 6 with finance sign-off.

---

## 11. Open decisions (need your input before Phase 2)

1. **Creds:** do we have MRU's pull `SCHOOLCODE` + `Password`, or must finance request them from
   SchoolPay? (Hard blocker.)
2. **Schema touch:** add the two nullable columns to `fin_schoolpaydata` (§3.2), or keep it
   **completely untouched** and rely solely on `fin_schoolpay_synclog`? (Recommend the columns —
   low risk, better provenance.)
3. **Controller location:** new modern page under `NewScreens/` (recommended), or extend the
   legacy `financials/SchoolPayTransactions.aspx`?
4. **Auto-sync mechanism:** Windows Task Scheduler hitting a protected endpoint, a MySQL event,
   or in-app — which fits ops best?
5. **Catch-up window K** (default 3 days) and retention of `fin_schoolpay_synclog`.
6. **Bank-GL routing:** fix the `AC….` vs `110/…` inconsistency (report §8) now or as a separate
   task? The pull path will use whichever `BankRouter` we standardise on.

---

## 12. Testing strategy

- **Dry-run mode** in `SyncDay` (fetch + classify, but skip insert/capture) to preview a day
  before committing.
- Re-run the **same day twice** → second run must report `new_count=0`, all duplicates, zero new
  GL entries (assert via `fin_studentfeestracking`/`fin_ledger` deltas).
- Pull a day that **overlaps** webhook captures → confirm zero double-posts (Layer 3 proof).
- Inject a **bad reg-no** txn → counted as failed, rest of day still imports.
- Verify totals reconcile (`sp_total_amount == local_total_amount`).
- Confirm the existing webhook still posts normally throughout (regression check).

---

*Plan only. No code or schema changes have been made. Built to extend the existing SchoolPay
integration (report §1–§11) with the Pull/Sync API (report §12) safely and without duplicates.*
