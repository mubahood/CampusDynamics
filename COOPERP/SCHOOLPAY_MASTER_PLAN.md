# SchoolPay — Master Integration & Controller Plan

**Status:** credentials LIVE & verified · plan for build. **Date:** 2026-07-02
**Companion docs:** `SCHOOLPAY_INTEGRATION_REPORT.md` (§1–§11 current state, §12/§15 API spec, §14 hardened
capture) · `sql/schoolpay/` (capture engine + auto-sweep) · this file (the build plan).

---

## 0. What we now have (verified 2026-07-02)
- **Credentials work.** School code **17184**, password stored in `web.config`
  (`SchoolPay.SchoolCode` / `SchoolPay.Password` / `SchoolPay.ApiBaseUrl`). Auth hash =
  `MD5(SchoolCode + identifyingDate + Password)` UPPERCASE.
- **Field bridge is exact** (from a live pull): `schoolpayReceiptNumber → fin_schoolpaydata.ReceiptNo`,
  `studentRegistrationNumber → regno` (POPULATED for MRU, e.g. `MRU2025003101`),
  `paymentDateAndTime → datePaid`, `amount → amount_paid`, `sourcePaymentChannel → channelPaid`,
  `studentName → stud_name`. Also available: `studentPaymentCode`, `sourceChannelTransactionId`,
  `settlementBankCode`, `studentClass`, `transactionCompletionStatus`.
- **The gap is real & quantified.** A one-week range pull (2026‑06‑25…07‑01) returned 67 payments;
  **6 were missing from our DB** (UGX 1,338,000) — money students paid that our webhook never captured.
  This is the core problem the pull solves.
- **Capture engine is ready & idempotent** (§14): `fin_AutoPayCapture` is double-post-proof; the
  `ev_schoolpay_autosweep` event already posts anything in `fin_schoolpaydata` still `Pending`.

---

## 1. Goal
A single, robust **SchoolPay Controller** in eadmin that manages *everything* SchoolPay, and a backend
that **never loses a payment**: real-time webhook (existing) + **pull-based reconciliation/recovery**
(new) + **adhoc one-time payments** (new) — all funnelling through the one hardened capture engine,
fully deduplicated, audited, and observable.

## 2. Architecture (additive; the existing webhook stays untouched)
```
  SchoolPay  ──(1) real-time webhook POST──►  eportal schoolpay_api.aspx ──► fin_schoolpaydata ─┐
             ──(2) PULL (we fetch)──────────►  SchoolPayPullService (eadmin, C#)                 │
             ◄─(3) ADHOC register/charge────►  SchoolPayAdhocService (eadmin, C#)                │
                                                     │                                           ▼
                                                     ├─ parse JSON ─► fin_schoolpay_pull_staging │
                                                     └─ CALL fin_SchoolPayReconcilePulled() ─────┤
                                                                                                 ▼
                                        fin_AutoPayCapture (ONE hardened engine, §14) ──► GL + fin_studentfeestracking
                                                                                                 │
                              fin_schoolpay_synclog (audit)   ◄─────────────────────────────────┘
                                                                                                 ▼
                                        SchoolPay Controller page (eadmin, UI/UX) drives + observes all of it
```
**Why eadmin:** finance staff work there; the accounts DB + the recapture control live there; outbound
HTTPS is appropriate. The portal webhook remains the real-time path.

## 3. Feature coverage — exploit ALL SchoolPay APIs
| SchoolPay feature | We use it for | Endpoint |
|---|---|---|
| **Transaction Sync — single day** | daily reconcile / re-pull a specific day | `GET …/SyncSchoolTransactions/{code}/{date}/{hash}` |
| **Transaction Sync — range (≤31d)** | offline-gap recovery in one call, backfills | `GET …/SchoolRangeTransactions/{code}/{from}/{to}/{hash}` |
| **Adhoc — Register** | create a one-off charge (e.g. application/graduation fees) → get a payment code | `POST …/AdhocPayments/Register/{code}/{hash}` |
| **Adhoc — Request (debit)** | push a mobile-money debit prompt to a payer's phone | `POST …/AdhocPayments/Request/{code}/{hash}` |
| **Adhoc — Check** | poll an adhoc payment's status | `GET …/AdhocPayments/Check/{code}/{hash}/{ref}` |
| **Adhoc — Callback** | receive adhoc completion → post it | our `callBackUrl` |
| **Web Hook (modern, SHA-256)** | optional upgrade of our inbound to signed webhooks | portal endpoint |

## 4. Data model (new; all in `campus_dynamics_accounts`)
1. **`fin_schoolpay_pull_staging`** — raw pulled rows (idempotent landing zone):
   `id PK, run_id, receipt_no (idx), regno, student_payment_code, amount, channel, settlement_bank,
   source_txn_id, pay_datetime, student_name, txn_status, fee_type ('SCHOOL'/'SUPPLEMENTARY'),
   supp_fee_desc, raw_json, pulled_at, reconcile_status ('New'/'Existed'/'Captured'/'Failed')`.
2. **`fin_schoolpay_synclog`** — one row per pull run (as in the earlier plan): dates, trigger,
   fetched/new/existed/captured/failed counts, sp_total vs local_total, returnCode/message, status.
3. **`fin_schoolpay_adhoc`** — adhoc payments we create: `id, external_ref (uniq), payment_reference,
   amount, first_name, last_name, phone, reason, status ('PENDING'/'PAID'/'FAILED'), receipt_no,
   transaction_id, created_by, created_at, paid_at`.
> `fin_schoolpaydata` remains the canonical capture/dedup ledger (unchanged shape).

## 5. Backend pieces
### 5.1 `SchoolPayPullService` (C#, App_Code/SchoolPay)
- Reads config; builds URL + `MD5(code+date+password).ToUpper()`.
- `SyncDay(date)` and `SyncRange(from,to)` → HTTP GET (timeout, 1–2 retries), parse JSON.
- Insert each txn into `fin_schoolpay_pull_staging` (INSERT IGNORE on receipt_no) with a `run_id`.
- `CALL fin_SchoolPayReconcilePulled(run_id, actor)`.
- Write `fin_schoolpay_synclog`. Return a summary object.

### 5.2 `fin_SchoolPayReconcilePulled(run_id, actor)` (SP — testable now)
For each staged row of the run:
- If `receipt_no` already in `fin_schoolpaydata` → mark `Existed` (nothing to do).
- Else → INSERT into `fin_schoolpaydata(...,'Pending')` (resolve regno: prefer `regno`, else map
  `student_payment_code`), then `CALL fin_AutoPayCapture(...)` → mark `Captured`/`Failed`.
- The **3-layer dedup** from §14 guarantees no double-post even if the webhook also has it.
- Update `fin_schoolpay_synclog` counters. Atomic per row; one failure never aborts the run.

### 5.3 `SchoolPayAdhocService` (C#)
- `Register/Request/Check` wrappers (hash uses externalReference / paymentReference).
- Persist to `fin_schoolpay_adhoc`; on callback or a successful Check, capture via the engine.

### 5.4 Scheduling
- Extend the existing `ev_schoolpay_autosweep` idea: a nightly **catch-up** that pulls the last **K=3
  days** via `SyncRange` and reconciles — so any webhook gap self-heals daily without human action.
  (Windows Task → protected `?task=autosync`, or a MySQL event calling a thin trigger.)

## 6. The SchoolPay Controller (eadmin UI/UX) — `NewScreens/SchoolPayController.aspx`
Modern SidebarMaster + design system. One page, tabbed:
1. **Overview / Analytics** — today/week/month totals, channel split (Airtel/MTN/Stanbic…), capture
   success rate, count of `Pending`, count of unreconciled days, trend chart.
2. **Reconcile & Recover** — pick a day or range → "Pull from SchoolPay" → table of results
   (New/Existed/Captured/Failed) with a per-row **Post** action; one-click "Recover all missing".
   *(This is what would recover today's 6 missing payments.)*
3. **Live activity** — auto-refreshing feed of the latest captured payments (webhook + pull).
4. **Pending / failures** — the current stuck `Pending` rows with **Recapture** (drives the hardened engine).
5. **Adhoc payments** — create a one-off charge (Register/Request), list them, poll status, see receipts.
6. **Sync log** — full `fin_schoolpay_synclog` history (date, trigger, counts, totals, status).
7. **Settings/health** — masked credential + base URL, a "Test connection" button (dry pull of today),
   webhook status, last successful sync per day.
Menu: add **"SchoolPay"** under Finance in `SidebarMaster.master`, role-gated to finance/admin.

## 7. Dedup / idempotency (unchanged, proven §14)
`ReceiptNo` PK + the `fin_ledger.folio='TransCode:<receipt>'` GL guard + the tracking `NOT EXISTS`
guard ⇒ a payment posts **at most once** regardless of how many channels see it (webhook, pull,
re-pull, manual). `fin_schoolpaydata` is append-only (reversals set status, never delete).

## 8. Security
- Credentials in `web.config` (consistent with existing secrets); never logged.
- All pull URLs over HTTPS; MD5 hash per call.
- Controller behind finance/admin role; auto-sync endpoint behind a shared secret + IP allow-list.
- Ask SchoolPay for their notification source IPs (docs §15.4) and whitelist the webhook.

## 9. Sabia test plan (MRU2027000002) — every path proven before real use
1. **Reconcile/capture (clean):** stage a fake pulled txn (receipt `ZZSP_SABIA1`, regno
   MRU2027000002, 50,000, Airtel) → run reconcile → assert it lands in `fin_schoolpaydata` + posts
   (DR AC1302 / CR student / tracking) + `synclog` counts, then **revert**.
2. **Dedup:** stage the same receipt again → reconcile → asserts `Existed`, no double-post.
3. **Overlap with webhook:** stage a receipt already Captured → `Existed`, ledger unchanged.
4. **Adhoc:** register an adhoc for Sabia (dry, or with a tiny amount to a test phone) → Check status.
All Sabia artefacts fully reverted after each assertion.

## 10. Phased rollout
| Phase | Deliverable | Risk |
|---|---|---|
| **1 ✅** | Creds stored + verified; gap quantified (this doc) | none (read-only) |
| **2** | `fin_schoolpay_pull_staging` + `fin_SchoolPayReconcilePulled` SP + synclog; **Sabia-tested** | low (additive) |
| **3** | `SchoolPayPullService` (C#) + a minimal trigger; recover the 6 real missing (audited) | posts real owed money |
| **4** | `SchoolPayController.aspx` UI (Overview/Reconcile/Pending/Log) + menu | UI only |
| **5** | Nightly catch-up auto-sync (last 3 days) | additive |
| **6** | Adhoc payments (Register/Request/Check/Callback) + webhook signing upgrade | new surface |

## 11. Risks / mitigations
- **Posting real money** on backfill → every capture is idempotent + audited; recover via the
  controller with a confirmation and a visible before/after.
- **studentRegistrationNumber occasionally blank** → fall back to `studentPaymentCode` mapping; if a
  student can't be resolved, land as `Pending`+`Failed` for manual review (never silently dropped).
- **Large range pulls** → cap at 31 days (API limit); page day-by-day for big backfills; long timeouts.
- **Wrong-university SMS** (report §10) is already fixed; the pull path reuses the same engine so it
  inherits the correct SMS.

---
*Phase 1 complete and verified live on 2026-07-02. Build proceeds Phase 2 → onward.*
