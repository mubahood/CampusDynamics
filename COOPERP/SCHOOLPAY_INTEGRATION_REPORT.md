# SchoolPay Payment Integration — Technical Analysis Report

**System:** Campus Dynamics MRU (Muteesa I Royal University)
**Scope:** Main system (eadmin / COOPERP), Student portal (eportal), Shared resources
**Date of analysis:** 2026-06-30
**Author:** Engineering analysis (code + live database review)

---

## 1. Executive Summary

SchoolPay is **the primary fees-collection channel** for MRU. It is a Ugandan school-fees
payment aggregator (schoolpay.co.ug) that lets parents/students pay via mobile money
(Airtel, MTN) and bank agents/USSD. Money collected by SchoolPay is pushed into Campus
Dynamics through a single **inbound webhook (IPN-style) endpoint**, which records the
payment and immediately posts it to the student's ledger via double-entry accounting.

**The integration is live and high-volume:**

| Metric | Value |
|---|---|
| Total transactions captured | **39,176** |
| Total value | **UGX 13,336,434,204** (~13.34 billion) |
| Date range | 2021-02-23 → 2026-06-30 (today; still processing) |
| Captured (posted to ledger) | 39,163 (UGX 13.33 B) |
| **Pending (received but NOT posted)** | **13 (UGX 5,837,000)** ⚠️ |
| Dominant channels | Airtel Money (26,950), MTN MobileMoney (11,601), Stanbic agent/USSD/bank, PayWay |

**Integration model:** Pure **inbound webhook**. SchoolPay calls *us*; the system makes
**no outbound HTTP calls** to SchoolPay. There is no SOAP/WSDL, no REST client, no
scheduled pull.

---

## 2. Architecture & End-to-End Flow

```
  Parent / Student
        │  pays via Airtel *185# / MTN *165# / bank agent
        ▼
  ┌──────────────────────┐
  │   SchoolPay platform  │   (aggregator; holds valid MRU student numbers)
  └──────────┬───────────┘
             │  HTTP GET/POST webhook (PUSH)
             │  ?task=StudCheck  (validate student no.)
             │  ?task=PostPayment (post a payment)
             ▼
  ┌─────────────────────────────────────────────────────────────┐
  │  eportal:  /COOPERP/Mobile/schoolpay_api.aspx(.cs)            │
  │  (https://eportal.mru.ac.ug/COOPERP/Mobile/schoolpay_api.aspx)│
  │   1. Authenticate (MD5 of SNO + date + secret)               │
  │   2. Validate reg-no  → fin_APIStudentData(@reg)             │
  │   3. INSERT fin_schoolpaydata (captureStatus='Pending')     │
  │   4. CALL fin_AutoPayCapture(...)  → posts to GL            │
  │   5. UpdateCaptureStatus('Captured')                        │
  │   6. SMS receipt to student                                 │
  └──────────┬──────────────────────────────────────────────────┘
             ▼
  ┌─────────────────────────────────────────────────────────────┐
  │  campus_dynamics_accounts DB                                  │
  │   • fin_schoolpaydata          (raw SchoolPay records)       │
  │   • fin_AutoPayCapture (SP)     → fin_TransactionCreator     │
  │        DR  Bank GL account  /  CR  Student ledger            │
  │   • fin_studentfeestracking     (canonical payment row)     │
  │   • fin_ledger / fin_UpdateLedgerBalances                    │
  └──────────┬──────────────────────────────────────────────────┘
             ▼
  ┌─────────────────────────────────────────────────────────────┐
  │  eadmin: Finance → SchoolPay Transactions (admin UI)          │
  │   SchoolPayDatal.ascx  — list, filter, "Recapture Selected",  │
  │   export to Excel (for the 13 stuck Pending rows)            │
  └─────────────────────────────────────────────────────────────┘
```

---

## 3. The Inbound Endpoint

**File:** `CampusDynamics_Portal/COOPERP/Mobile/schoolpay_api.aspx(.cs)`
**Public URL:** `https://eportal.mru.ac.ug/COOPERP/Mobile/schoolpay_api.aspx`
**Class:** `COOPERP_Mobile_schoolpay_api` (bare `.aspx`; all logic in `Page_Load`)
**Data layer:** typed dataset `App_Code/Mobile/MobileData.xsd` (adapters
`fin_APIStudentDataTableAdapter`, `fin_schoolpaydataTableAdapter`), connection
`campus_dynamics_accountsConnectionString`.

It routes on the `task` query parameter:

### 3.1 `task=StudCheck` — student validation

```
GET ...schoolpay_api.aspx?task=StudCheck&reg=<regno>
```
- Calls `fin_APIStudentData(@reg)` and returns:
  - `{"Message":"Valid","Data":[ {regno, studnames, stud_campus, studphone, email, curBalance} ]}` if exactly one match
  - `{"Message":"Invalid"}` otherwise
- `fin_APIStudentData` looks up `campus_dynamics.acad_student` **UNION**
  `campus_dynamics_admissions.applic_form` (by `form_no`), so **both registered students
  and applicants** can be validated. `curBalance` is derived from `fin_ledger.curr_balance`
  (latest row; CR rendered negative). Campus is hard-returned as `'MUTEESA I ROYAL UNIVERSITY'`.

### 3.2 `task=PostPayment` — payment posting

```
GET ...schoolpay_api.aspx?task=PostPayment
    &Key=<md5>&API_ID=202401
    &recno=<receiptNo>&reg=<regno>&paydate=<date>
    &pay_source=<channel>&amount=<ugx>&stud_name=<name>
```

Processing:
1. **Authenticate** (see §4). If `Key`/`API_ID` mismatch → `{"Message":Invalid Code OR Password}`.
2. **Validate** the student (`fin_APIStudentData` row count == 1). If not → `{"Message":"Data Capture Failed. Invalid Reg No"}` (nothing is stored).
3. **Insert** the raw record into `fin_schoolpaydata` with `captureStatus='Pending'`.
4. **Auto-capture**: `fin_AutoPayCapture(regno, "<name> [<regno>] - SCHOOLPAY", BankRouter(pay_source), amount, paydate, "autocapture", bankChannel, recno)`.
5. **Mark** `captureStatus='Captured'`.
6. **SMS** the student a receipt (best-effort).
7. Return `{"Message":"Data Capture Complete"}`. Duplicate PK → `{"Message":"Data Already Captured"}` (idempotent re-post is safe).

---

## 4. Authentication Scheme

Credentials are **hardcoded in the code-behind** (not in `web.config`):

```
SNO (API_ID) = "202401"
PS  (secret) = "!Mr$u#2024"
TransDate    = today as yyyyMMdd
apiKey       = MD5( SNO + TransDate + PS )      // computed in MySQL: SELECT MD5(@txt)
```

SchoolPay must send `API_ID = 202401` and `Key = ` that day's MD5. The hash **rotates daily**
(date is baked in) but is **otherwise static** — there is no per-transaction signature, no
amount/receipt in the signed payload, and no nonce.

**Security observations (see §10 for the full risk list):**
- Shared secret + serial are in source control (`!Mr$u#2024`, `202401`).
- The signature does not cover the transaction body, so any party that learns the day's
  `Key` could post arbitrary `reg`/`amount`/`recno` for the rest of that day.
- No evidence of IP allow-listing or mutual TLS at the application layer.

---

## 5. Data Storage — `fin_schoolpaydata`

**Database:** `campus_dynamics_accounts`

```sql
CREATE TABLE `fin_schoolpaydata` (
  `ReceiptNo`     char(45)    NOT NULL,           -- SchoolPay receipt no. (PK → natural idempotency)
  `regno`         varchar(45) NOT NULL,           -- student reg no.
  `datePaid`      datetime    NOT NULL,
  `channelPaid`   varchar(45) NOT NULL,           -- "Airtel Money", "MTN MobileMoney", "Stanbic Agent", ...
  `amount_paid`   double      NOT NULL,           -- UGX
  `stud_name`     varchar(75) NOT NULL,
  `captureStatus` char(30)    NOT NULL DEFAULT 'Pending',  -- 'Pending' | 'Captured'
  PRIMARY KEY (`ReceiptNo`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
```

`ReceiptNo` as PK gives natural de-duplication: a re-posted SchoolPay receipt throws a
duplicate-key error, caught and returned as "Data Already Captured".

---

## 6. GL Posting — `fin_AutoPayCapture` (stored procedure)

**Database:** `campus_dynamics_accounts`
**Signature:** `(reg, stud_nm, bankCode, amount, TDate, teller, bankName, tid)`

Logic:
1. Read latest `acad_registration` (acad_year, semester, studyYear) for the student.
2. Guard: proceed only if `fin_schoolpaydata` has this `ReceiptNo` with `CaptureStatus='Pending'`.
3. `CRaccountType = fin_GetStudentLedgerName(reg)` (the student's ledger account).
4. **Double-entry** via `fin_TransactionCreator(...)`:
   - **CR** student ledger — *"Fees Payment for &lt;sys&gt; &lt;sem&gt;, &lt;year&gt; on &lt;date&gt; thru &lt;bankName&gt; TNo:&lt;tid&gt;"*
   - **DR** bank GL account (`bankCode`, a Chart Account) — *"Paid on &lt;date&gt; by &lt;name&gt; TNo:&lt;tid&gt;"*
5. `INSERT IGNORE fin_studentfeestracking(regno, acadyear, semester, amount, item_code=0, 'Payment', detail, now, 'Posted')` — the **canonical payment record** used by balance logic.
6. `UPDATE fin_schoolpaydata SET CaptureStatus='Captured'`.
7. `fin_UpdateLedgerBalances(reg)` and `fin_UpdateLedgerBalances(bankCode)`.

This ties directly into the canonical balance model (fees balance = `fin_ledger` +
`fin_studentfeestracking`, deduped — see the FinanceEngine balance logic). SchoolPay
payments land as `item_code = 0`, `trans_type = 'Payment'`.

---

## 7. Admin Reconciliation UI

**eadmin page:** `COOPERP/financials/SchoolPayTransactions.aspx` (a thin host)
**Control:** `UserControls/financials/SchoolPayDatal.ascx(.cs)`

Features:
- Date-range + status (Pending/Captured) filter via `fin_schoolpaydataTableAdapter.GetTransactionsByDate(sDate, eDate, stat)`
  → `SELECT * FROM fin_schoolpaydata WHERE datePaid BETWEEN @sDate AND @eDate AND captureStatus=@stat ORDER BY datePaid DESC, stud_name`.
- DevExpress grid (`gvSchoolPayList`) with checkbox selection and an amount total.
- **"Recapture Selected"** (`cmdCapture_Click`): re-runs `fin_AutoPayCapture` + `UpdateCaptureStatus('Captured')` for selected rows — the tool to clear **stuck "Pending"** payments.
- **Export to Excel** of the filtered list.

There is also a stub page `UserControls/Accounts/SchoolPayPLatform.ascx` (empty — likely a
placeholder for an embedded SchoolPay portal that was never wired up).

---

## 8. Bank-Channel → GL Account Routing

`channelPaid` is mapped to a bank Chart-Account code by a `BankRouter()` method — but there
are **three different, hardcoded mappings** in the codebase, which do **not agree**:

| Location | Centenary | Stanbic | Eco | DFCU | Housing | Default |
|---|---|---|---|---|---|---|
| eportal endpoint `schoolpay_api.aspx.cs` | `AC1303` | `AC1302` | `AC1308` | `AC1303` | — | `AC1302` |
| eadmin `SchoolPayDatal.ascx.cs` (BankRouter) | `110/007` | `110/001` | `110/008` | — | `110/006` | `110/011` |
| eadmin `SchoolPayDatal.ascx.cs` (`CaptureTransaction`) | — | — | — | hard-coded `IU1427` / "DFCU BANK" | — | — |

The `bankChannel` label is also normalised: `pay_source` containing `"Shared"` → `"Bank of
Africa"`; default `"Bank Of Africa"`. This divergence is a real risk: **the live webhook posts
to `AC….` accounts, while the admin "Recapture" button posts to `110/…` accounts** — so a
payment captured automatically and the same payment recaptured manually could hit different GL
accounts (one of which may not exist in MRU's chart).

---

## 9. Student-Facing Pieces

### 9.1 Payment instructions (admission letters) — correctly MRU-localised
`App_Code/AdmissionLetterHelper.cs` embeds USSD instructions in every admission letter:
- **Airtel:** `*185#` → 6 (School Fees) → 2 (School Pay) → 1 (Pay Fees) → Student No. `MRU202600…` → confirm name → amount → PIN
- **MTN:** `*165#` → 4 (Payments) → 3 (School Fees) → 1 (School Pay) → 1 (Pay Fees) → Student No. → confirm → amount → PIN

### 9.2 SMS receipt
On capture, an SMS is sent via `SMSSendingBLL.SMSSending(...)` →
`POST https://instantsms.eurosatgroup.com/API/SMS_Sender.aspx` (eurosatgroup gateway).
⚠️ **The SMS text is hardcoded to the WRONG university** (see §10).

### 9.3 Student roster export — `fin_GetSchoolPayList(yr)`
A stored procedure exists that exports student bio (name, reg-no, sex, email, phone, parent…)
filtered by entry year — the kind of roster an institution uploads to SchoolPay so the
aggregator knows valid student numbers. ⚠️ It reads from **`erp.student`** (a different/legacy
schema), not `campus_dynamics.acad_student`, so it may be stale or unused in the MRU deployment.

---

## 10. Findings, Risks & Recommendations

### 🔴 Critical

1. **Wrong-university branding sent to MRU students/accounts.** — ✅ **FIXED 2026-06-30.** The
   integration was clearly copy-pasted from other Campus Dynamics deployments and never fully
   localised. The two payment-SMS templates have now been corrected to **Muteesa I Royal
   University** (sender **"MRU Accounts"**):
   - `schoolpay_api.aspx.cs` (webhook receipt SMS) — was *"…Kampala University…"* / *"KU Accounts Dept"*.
   - `SchoolPayDatal.ascx.cs` (admin recapture SMS) — was *"…YMCA Institute…"* / *"YCI Accounts Dept"*.
   - ⚠️ Still open (separate, BankRouter issue #3): `SchoolPayDatal.CaptureTransaction` hardcodes
     bank code `IU1427` / "DFCU BANK". No remaining wrong-university **SMS** strings (verified by search).

2. **13 payments received but never posted (UGX 5,837,000).** These sit `captureStatus='Pending'`
   — real money collected by SchoolPay that the student ledgers do **not** reflect. Spanning
   2024-04 → 2026-06. Students affected (reg-no / amount):
   `MRU2025003896` 600k, `MRU2024002055` 200k, `MRU2025003282` 200k, `MRU2026005084` 20k,
   `MRU2025003909` 250k, `MRU2023001389` 700k, `MRU2024000983` 863k, `MRU2024000846` 300k,
   `MRU2022000570` 800k, `MRU2022000920` 110k, `MRU2024000093` 914k, `MRU2022000292` 530k,
   `MRU2022000355` 350k. → Investigate why auto-capture failed for each (likely no current
   `acad_registration` row, or a GL-code mismatch — see #3), then "Recapture Selected" or post
   manually. Recommend root-causing before bulk-recapturing.

3. **Inconsistent bank GL routing (§8).** The webhook (`AC….`) and the admin recapture
   (`110/…`) post to different accounts; `CaptureTransaction` even hardcodes a foreign code
   (`IU1427`). → Consolidate to a single, configuration-driven channel→GL map validated against
   MRU's actual chart of accounts.

### 🟠 High

4. **Hardcoded credentials in source** (`SNO="202401"`, `PS="!Mr$u#2024"`). → Move to
   `web.config`/secret store; rotate the secret since it has been in the repository.

5. **Weak webhook authentication.** The signature is `MD5(serial + date + secret)` — it does
   **not** include `reg`, `amount`, or `recno`, rotates only daily, and uses MD5. Anyone who
   obtains the day's `Key` can post arbitrary payments until midnight. → Move to a per-request
   HMAC-SHA256 over the full payload, add an IP allow-list for SchoolPay's servers, and enforce
   HTTPS.

### 🟡 Medium / Latent

6. **`int.Parse(tid)` overflow risk.** Both the endpoint and the admin control pass the receipt
   number to `fin_AutoPayCapture` via `int.Parse(tid)` / `int.Parse(...)`. `ReceiptNo` is
   `char(45)`; current values max out at **59,499,515** (within Int32, so safe today), but any
   SchoolPay receipt number above 2,147,483,647 would throw `OverflowException` and fail capture
   (a candidate cause for future "Pending" rows). → Parse as `long`/keep as string (the SP
   parameter is already `CHAR(45)`).

7. **Minor code issues:** the invalid-credentials branch writes malformed JSON
   (`{"Message":Invalid Code OR Password}` — unquoted), and `amount` is read inconsistently
   (`double.Parse` for the insert vs `long.Parse` for capture). UGX has no decimals so there is
   no rounding loss today, but it is fragile.

8. **`fin_GetSchoolPayList` reads `erp.student`** (a non-MRU schema). → Verify whether the
   student-roster export to SchoolPay is still used; if so, repoint it to
   `campus_dynamics.acad_student`.

### 🟢 Strengths (keep)

- Natural idempotency via `ReceiptNo` PK + the "Data Already Captured" path.
- Clean double-entry posting through the standard `fin_TransactionCreator` and the canonical
  `fin_studentfeestracking`, so SchoolPay money flows through the same balance logic as all
  other payments.
- A working manual-reconciliation UI ("Recapture Selected") for the rare capture failures.
- Student-facing USSD instructions are correctly MRU-localised.

---

## 11. File & Object Inventory

| Layer | Path / object | Role |
|---|---|---|
| Inbound webhook | `CampusDynamics_Portal/COOPERP/Mobile/schoolpay_api.aspx(.cs)` | Receives StudCheck / PostPayment |
| Data layer (portal) | `CampusDynamics_Portal/App_Code/Mobile/MobileData.xsd` | `fin_APIStudentData`, `fin_schoolpaydata`, `fin_AutoPayCapture`, `MD5_Data`, `GetStudPhone` adapters |
| Data layer (eadmin) | `CampusDynamics/App_Code/Finance/StudentAccountingData.xsd` | `fin_schoolpaydataTableAdapter` incl. `GetTransactionsByDate` |
| Admin UI | `CampusDynamics/COOPERP/financials/SchoolPayTransactions.aspx` + `UserControls/financials/SchoolPayDatal.ascx(.cs)` | List / filter / recapture / export |
| Admin UI (stub) | `UserControls/Accounts/SchoolPayPLatform.ascx(.cs)` | Empty placeholder |
| SMS | `CampusDynamics_Portal/App_Code/communications/SMSSendingBLL.cs` | eurosatgroup SMS gateway |
| Student instructions | `CampusDynamics/App_Code/AdmissionLetterHelper.cs` | USSD payment steps in admission letters |
| DB table | `campus_dynamics_accounts.fin_schoolpaydata` | Raw SchoolPay records |
| DB SP | `campus_dynamics_accounts.fin_AutoPayCapture` | GL posting |
| DB SP | `campus_dynamics.fin_APIStudentData` | Student/applicant validation |
| DB SP | `campus_dynamics_accounts.fin_GetSchoolPayList` | Student-roster export (reads `erp.student`) |
| Docs | `COOPERP/CAMPUS_DYNAMICS_ACCOUNTS_CATALOG.md` | Catalogs the table + SPs |

---

## 12. SchoolPay **Transaction Pull / Sync API** (v0.1, 2018) — the missing inbound-recovery path

The integration analysed in §1–§11 is **push-only**: SchoolPay calls our webhook in real time.
If our endpoint is **down/unreachable** when a payment happens (server restart, deploy, network
blip, DB lock), that notification can be **lost** — the money is with SchoolPay but never lands
in `fin_schoolpaydata`/the ledger. This is the most likely root cause of the **13 unposted
"Pending"** rows and of any silently-missing transactions.

SchoolPay also publishes a **pull (sync) API** that lets the school *fetch* a given day's
transactions on demand. This is the recovery/reconciliation channel we do **not** currently use.

### 12.1 Specification (verbatim from SchoolPay "SCHOOLPAY TRANSACTION SYNC API, Version 0.1, 2018")

**Purpose:** Schoolpay transaction **pull** API — fetch the transactions for a single day.

**Endpoint (GET):**
```
https://schoolpay.co.ug/paymentapi/AndroidRS/SyncSchoolTransactions/{SCHOOLCODE}/{TRANSACTION_DATE}/{REQUEST_HASH}
```

**Path parameters:**

| Token | Meaning | Format / notes |
|---|---|---|
| `{SCHOOLCODE}` | The school's SchoolPay code | e.g. `7306` (MRU's code **must be obtained** — see §12.3) |
| `{TRANSACTION_DATE}` | The day whose transactions to fetch | `yyyy-MM-dd`, e.g. `2017-01-01`. **Returns exactly one day.** |
| `{REQUEST_HASH}` | Security hash | `MD5( SchoolCode + TransactionDate + Password )` |

**Password:** *"Will be shared when the school is integrating"* — a **separate secret** from our
inbound webhook secret (`!Mr$u#2024`). It is **not currently in our codebase** and must be
obtained from SchoolPay / the finance team.

**Hash computation:** concatenate `SchoolCode`, `TransactionDate`, and `Password` (in that
order, no separators) and take the MD5. Same MD5 family already used by our inbound path, so the
algorithm is familiar.

**Example request (from the spec):**
```
https://schoolpay.co.ug/paymentapi/AndroidRS/SyncSchoolTransactions/7306/2017-04-06/B0548C2C783C59D49D623212237AF744
```
(here `MD5("7306" + "2017-04-06" + Password) = B0548C2C783C59D49D623212237AF744`)

**Response contract:**
- A `returnCode` field: **`0` = success**, **non-zero = failure**.
- On failure, a `returnMessage` field holds the error text.
- A list of transactions for that day. **Each transaction carries a `schoolpayReceiptNumber`**
  which uniquely identifies it. *"each transaction should be imported once per receipt number."*

### 12.2 How it maps onto what we already have

This is a clean fit with the existing model — **`schoolpayReceiptNumber` ↔ our
`fin_schoolpaydata.ReceiptNo` (PRIMARY KEY)**. That single fact is the backbone of safe
de-duplication: a pulled transaction whose receipt number already exists is simply skipped,
exactly like the webhook's "Data Already Captured" path. Crucially, our GL posting SP
`fin_AutoPayCapture` **only posts when the row's `captureStatus='Pending'`** (its `TCheck=1`
guard), so even if a receipt is seen by *both* the webhook and a later pull, it can be posted to
the ledger **at most once**. The pull path can therefore reuse the entire existing capture
pipeline verbatim.

### 12.3 Unknowns / prerequisites before this can be built

| Item | Status | Needed for |
|---|---|---|
| **MRU SchoolPay `SCHOOLCODE`** | ❓ unknown (our inbound `202401` is the *webhook* serial, not necessarily the pull school code) | building the URL |
| **Pull `Password`** | ❓ not in codebase ("shared at integration") | the request hash |
| **Exact transaction field names** in the response JSON (amount, date, channel, student code/reg-no, student name, bank…) | ❓ spec v0.1 only names `schoolpayReceiptNumber`, `returnCode`, `returnMessage` | mapping to `fin_schoolpaydata` columns |
| **Response content-type** (JSON vs XML) and pagination (spec implies a single day, no paging) | ❓ confirm via one live call | the parser |
| **Student-code vs reg-no** — SchoolPay may key students by a payment code rather than the MRU reg-no | ❓ confirm | mapping `regno` |

These are resolved by a one-off **discovery call** (a single authenticated GET for a known busy
day) once the school code + password are in hand — captured in the plan below as Phase 1.

### 12.4 Live test result (2026-06-30) — endpoint confirmed live; our webhook creds are NOT the pull creds

We probed the pull endpoint (read-only) using our **existing webhook credentials** as the school
code/password to see whether they double as pull credentials:

```
GET https://schoolpay.co.ug/paymentapi/AndroidRS/SyncSchoolTransactions/202401/2026-06-29/<MD5(202401 + 2026-06-29 + !Mr$u#2024)>
→ HTTP/1.1 200 OK   Content-Type: application/json
→ {"returnCode":97,"returnMessage":"School not found","transactions":[],"supplementaryFeePayments":[]}
```

Findings:
- ✅ **The pull endpoint is live and reachable** over HTTPS (nginx, HSTS, returns JSON).
- ❌ **`202401` is not a valid pull `SCHOOLCODE`.** `returnCode 97 = "School not found"` — so the
  request format/hash was well-formed enough to reach a school lookup, but our **webhook serial
  `202401` is not the SchoolPay school code** (confirming §12.3). Note the asymmetry: SchoolPay
  uses `202401` to identify MRU when **pushing** to our webhook, yet the **pull** API does not
  recognise it as a school code — the pull side uses a different short identifier (the `7306`
  slot in the spec example).
- 🔎 **Response schema discovered** (useful for the future parser): the JSON has
  `returnCode` (int), `returnMessage` (string), **`transactions`** (array), and a second array
  **`supplementaryFeePayments`** (array — likely non-tuition / supplementary fee items). Field
  names *inside* those arrays still need a successful (returnCode 0) call to enumerate.
- 🔍 **No SchoolPay school code exists anywhere in our codebase or config** (verified by search) —
  so it must be obtained from SchoolPay; we cannot derive it locally.

**Conclusion:** the pull channel is ready to use *technically*, but it needs MRU's **real
SchoolPay `SCHOOLCODE` + pull `Password`** (different from the webhook's `202401` / `!Mr$u#2024`).
This is the hard blocker noted in the plan (§11.1). We did **not** brute-force school codes
against production.

### 12.5 Why we want it (value)

1. **Offline recovery** — backfill any transactions missed while the webhook was unavailable
   (the primary ask).
2. **Daily reconciliation** — compare SchoolPay's day total/count against ours and surface gaps.
3. **Self-healing** — clear stuck `Pending` rows automatically by re-driving them through capture.
4. **Confidence** — a definitive "we have everything SchoolPay has for date X" check.

---

## 13. Enhancement Plan — additive pull-sync + admin controller

A full, phased implementation plan (designed to **add** the pull channel without changing the
working webhook, with multi-layer duplicate prevention and a dedicated admin "SchoolPay
Controller" page added to the menu) is documented separately in:

➡️ **`COOPERP/SCHOOLPAY_PULL_SYNC_PLAN.md`**

Headline guarantees of that plan:
- **Non-destructive:** the inbound webhook (§3) is untouched; the pull path is purely additive
  and reuses `fin_schoolpaydata` + `fin_AutoPayCapture` as-is.
- **Duplicate-proof by construction:** receipt-number PK + the `captureStatus='Pending'` GL
  guard mean a payment posts at most once regardless of how many times it is seen.
- **`fin_schoolpaydata` becomes append-only** (the dedup ledger): reversals change status, never
  delete rows — so a later re-pull can never re-introduce a removed payment.
- **Admin "SchoolPay Controller"** page: trigger a fetch for a date/range, watch a live recent
  feed, view per-day reconciliation + analytics, and recapture pending — added to the Finance
  menu.

---

## 14. Deployed stabilization (2026-06-30) — self-healing, double-post-proof capture

Additive and **non-breaking** (the inbound webhook and all application code are unchanged). All
in `campus_dynamics_accounts`; versioned scripts in `COOPERP/sql/schoolpay/`.

### 14.1 Hardened engine — `fin_AutoPayCapture` (the key change)
The GL-posting engine is now **double-post-proof for every caller** (the live webhook, the admin
"Recapture Selected" button, and the sweep). Two cheap, indexed guards were added; **the hot path
(a fresh capture) behaves exactly as before** plus one indexed `COUNT(*)`:

- **GL guard:** the double-entry is posted only if `fin_ledger.folio = 'TransCode:<receipt>'` does
  not already exist (`folio` is indexed — `Index_3`). So a receipt's DR/CR can be created **at
  most once** — re-capturing an already-posted/partial row can never double-credit the student.
- **Tracking guard:** the `fin_studentfeestracking` row is added at most once (a `regno`-narrowed
  `NOT EXISTS`, run only on the rare re-capture path).

Behaviour by ledger state: **fresh** → full post (DR bank / CR student / tracking / `Captured`);
**already posted (partial or re-capture)** → **no re-post**, just add the missing tracking row +
mark `Captured`. This also **retires the previous "Recapture Selected" double-post landmine** — no
app change was needed; the engine itself now refuses to double-post.

### 14.2 Sweep + schedule
- **`fin_SchoolPayRecaptureAllPending()`** — snapshots all `captureStatus='Pending'` rows and
  drives each through the hardened engine (the engine decides clean-vs-partial). Idempotent,
  per-row rollback handler, bank routing mirrors the webhook (`AC1302` default / `AC1303`
  dfcu·centenary / `AC1308` eco).
- **`ev_schoolpay_autosweep`** — `EVERY 10 MINUTE` (ENABLED; `event_scheduler` ON). The webhook
  always **inserts the row before capturing**, so a failed capture is never lost — it sits
  `Pending` and self-heals within ~10 minutes.

### 14.3 Duplicate prevention — every scenario covered
| Scenario | Outcome |
|---|---|
| Fresh payment | Posted once (DR/CR/tracking/Captured). |
| Webhook re-receives same receipt | `ReceiptNo` PK → "Data Already Captured" (no re-capture). |
| Re-capture of a **fully**-posted row | GL guard + tracking guard → no change. |
| Re-capture of a **partial** (GL posted, tracking/status missing) | Completes (tracking + Captured), **no** second GL post. |
| Admin "Recapture Selected" on any of the above | Safe — engine refuses to double-post. |
| Receipt number > Int32 (webhook `int.Parse` would throw) | Webhook stores the row; sweep (CHAR-based) captures it. |

### 14.4 Verified end-to-end (live DB, 2026-06-30)
- **Sabia** (`MRU2027000002`): clean capture, **double-post attempt**, partial completion, and
  **triple-stress re-capture** — ledger always 2 legs, tracking always 1 row. Test data reverted.
- **13 real stuck payments (UGX 5,837,000)** posted: all `Captured`, each exactly **1 credit / 1
  debit / 1 tracking row** (the 5 partials kept their single credit). `Pending` 13 → 0; re-run
  idempotent.

### 14.5 Residual notes
- Tiny theoretical race (webhook capturing a row the instant the event sweeps it) — negligible at
  a 10-min cadence vs millisecond captures; the engine's GL guard would still prevent a double
  even if it occurred.
- ✅ Wrong-university SMS branding **fixed 2026-06-30** (both payment-SMS templates → "Muteesa I
  Royal University" / sender "MRU Accounts").
- Still open from §10/§12: the `AC….` vs `110/…` admin BankRouter inconsistency (incl. the
  hardcoded `IU1427`/"DFCU BANK" in `CaptureTransaction`), and obtaining the pull-API credentials
  (§12.4).

---

## 15. Official SchoolPay API Reference (fetched from https://schoolpay.co.ug/apidocumentation, 2026-07-01)

The current official docs are **much richer than the v0.1 (2018) spec in §12** — they add a
**date-range** sync endpoint, the full **response field list**, an **Adhoc One-Time Payments** API,
and a modern **Web Hook** notification API with SHA-256 signatures. This section reproduces them in
full. It **resolves the §12.3 unknowns**: the transaction field names, the response content-type
(JSON), and that a student is keyed by `studentPaymentCode` (with `studentRegistrationNumber` often
empty) — critical for mapping into `fin_schoolpaydata`.

### 15.0 Authentication (all APIs)
Requests are authenticated by an **MD5 hash**:  `MD5(schoolCode + identifyingDate + password)`,
returned/used as **UPPERCASE hex**. The "identifying" value varies by endpoint:
- Single-date sync → the **transactionDate**
- Range sync → the **fromDate** (NOT toDate)
- Adhoc register/request → the **externalReference**
- Adhoc status check → the **paymentReference**

The Web Hook uses a different scheme (SHA-256, see §15.4).

### 15.1 Transaction Sync API

**A. Single-date fetch**
```
GET https://schoolpay.co.ug/paymentapi/AndroidRS/SyncSchoolTransactions/{schoolCode}/{transactionDate}/{requestHash}
```
| Path param | Format | Notes |
|---|---|---|
| `schoolCode` | numeric string | our school identifier |
| `transactionDate` | `YYYY-MM-DD` | returns exactly this day |
| `requestHash` | `MD5(schoolCode + transactionDate + password)` UPPER | |

**B. Date-range fetch** (⭐ ideal for offline recovery — one call covers up to a month)
```
GET https://schoolpay.co.ug/paymentapi/AndroidRS/SchoolRangeTransactions/{schoolCode}/{fromDate}/{toDate}/{requestHash}
```
| Path param | Format | Notes |
|---|---|---|
| `fromDate` / `toDate` | `YYYY-MM-DD` | **max range 31 days** |
| `requestHash` | `MD5(schoolCode + fromDate + password)` UPPER | uses **fromDate** |

**Response envelope (both A and B), content-type `application/json`:**
- `returnCode` — int (**0 = success**, non-zero = failure)
- `returnMessage` — string (e.g. "3 transaction(s) found (1 regular, 2 supplementary fee)")
- `transactions` — array of regular fee payments
- `supplementaryFeePayments` — array of non-tuition/other-fee payments

**Transaction object fields:**
| Field | Meaning |
|---|---|
| `schoolpayReceiptNumber` | SchoolPay receipt (unique id — **import once per receipt**) ↔ our `fin_schoolpaydata.ReceiptNo` |
| `amount` | amount (string) |
| `paymentDateAndTime` | `YYYY-MM-DD HH:MM:SS` |
| `sourcePaymentChannel` | e.g. "MTN MobileMoney", "Airtel Money" ↔ our `channelPaid` |
| `settlementBankCode` | settlement bank, e.g. "CENTENARY", "TROPICAL" |
| `sourceChannelTransactionId` | the aggregator/telco transaction id |
| `sourceChannelTransDetail` | free-text channel detail (payer / narration) |
| `studentPaymentCode` | **the student identifier SchoolPay keys on** ↔ our reg-no lookup |
| `studentRegistrationNumber` | often **empty** (`""`) — do not rely on it alone |
| `studentName` | payer/student name ↔ our `stud_name` |
| `transactionCompletionStatus` | e.g. "Completed" |

**Supplementary-fee object** = all of the above **plus**: `studentClass`,
`supplementaryFeeDescription` (e.g. "UNIFORM FEES"), `supplementaryFeeId` (e.g. "20"),
`transactionCompletionDateAndTime`.

**Sample response:**
```json
{
  "returnCode": 0,
  "returnMessage": "3 transaction(s) found (1 regular, 2 supplementary fee)",
  "transactions": [
    { "amount": "350000", "paymentDateAndTime": "2023-08-22 12:45:42",
      "schoolpayReceiptNumber": "18843014", "settlementBankCode": "CENTENARY",
      "sourceChannelTransDetail": "PHIONAH NABALAMBA", "sourceChannelTransactionId": "90269163351",
      "sourcePaymentChannel": "Airtel Money", "studentName": "Rachelle  Faith",
      "studentPaymentCode": "1005416321", "studentRegistrationNumber": "",
      "transactionCompletionStatus": "Completed" }
  ],
  "supplementaryFeePayments": [
    { "amount": "150000.00", "paymentDateAndTime": "2023-08-22 13:35:36",
      "schoolpayReceiptNumber": "18843597", "settlementBankCode": "CENTENARY",
      "sourceChannelTransactionId": "21882064988", "sourcePaymentChannel": "MTN MobileMoney",
      "studentClass": "JUNIORTWO", "studentName": "Jim Kapere", "studentPaymentCode": "1000000001",
      "supplementaryFeeDescription": "UNIFORM FEES", "supplementaryFeeId": "20",
      "transactionCompletionDateAndTime": "2023-08-22 13:35:36", "transactionCompletionStatus": "Completed" }
  ]
}
```

**C# hash (matches our stack):**
```csharp
string input = schoolCode + date + password;              // range: schoolCode + fromDate + password
byte[] hash = MD5.Create().ComputeHash(Encoding.ASCII.GetBytes(input));
string requestHash = Convert.ToHexString(hash).ToUpper(); // .NET Core; on 4.0 use BitConverter/StringBuilder
string url = $"https://schoolpay.co.ug/paymentapi/AndroidRS/SyncSchoolTransactions/{schoolCode}/{date}/{requestHash}";
```

### 15.2 Adhoc One-Time Payments API (register/charge a one-off payment — e.g. application fees)
Hash = `MD5(SchoolCode + IdentifyingReference + Password)` UPPER.

**C. Register** — `POST /paymentapi/AndroidRS/AdhocPayments/Register/{SchoolCode}/{Hash}` (hash uses `externalReference`)
Body: `{ "amount":52000, "externalReference":"63140", "firstName":"Kapere", "lastName":"Lugard", "reason":"Admissions 2021", "callBackUrl":"https://…/callback" }`
Response: `{ "paymentReference":"21AD100011", "returnCode":0, "returnMessage":"Request has been processed", "status":"PENDING" }`

**D. Request (mobile-money debit)** — `POST /paymentapi/AndroidRS/AdhocPayments/Request/{SchoolCode}/{Hash}` (hash uses `externalReference`)
Body adds `"phoneNumber":"0771000955"` (local `077…` or intl `25677…`).
Response: `{ "returnCode":0, "returnMessage":"Debit request sent", "paymentReference":"21AD100012", "status":"PENDING" }`

**E. Check status** — `GET /paymentapi/AndroidRS/AdhocPayments/Check/{SchoolCode}/{Hash}/{Reference}` (hash uses `paymentReference`)
Response (paid): `{ "paymentCode":"21AD100010", "receiptNumber":"5615857", "status":"PAID", "transactionId":"1188814", "returnCode":0 }`

**F. Adhoc callback** — SchoolPay POSTs to your `callBackUrl` on success:
`{ "amount":52000, "channelName":"Airtel Money", "paymentReference":"21AD100011", "receiptNumber":"5615855", "status":"PAID", "transactionId":"1188813", "returnCode":0 }`
Verify `status == "PAID"` before updating records; **return HTTP 200** to acknowledge.

### 15.3 Web Hook Notification API (real-time push, modern replacement/companion to our current webhook)
Schools register a webhook URL in the portal; SchoolPay POSTs JSON for every successful payment.
- `type: "SCHOOL_FEES"` → `{ signature, type, payment:{ amount, paymentDateAndTime, schoolpayReceiptNumber, settlementBankCode, sourceChannelTransDetail, sourceChannelTransactionId, sourcePaymentChannel, studentName, studentPaymentCode, studentRegistrationNumber, transactionCompletionStatus } }`
- `type: "OTHER_FEES"` → same `payment` **plus** `studentClass`, `supplementaryFeeDescription`, `supplementaryFeeId`, `transactionCompletionDateAndTime`.

### 15.4 Web Hook signature + delivery rules (important)
- **Signature:** `signature = SHA256_HEX( SchoolAPIPassword + schoolpayReceiptNumber )`. Verify it before accepting a payment.
- **IP whitelisting** available on request (source IPs provided by SchoolPay).
- **Ack:** return **HTTP 200**; the body is ignored (only the status code matters).
- ⚠️ **Web Hooks are sent ONCE — no retry.** If our endpoint is down/unreachable, the notification is
  **lost** — which is *exactly* the failure mode behind the §1/§14 stuck payments, and the definitive
  justification for the Pull/Sync recovery in §12–§13.
- Web Hooks only fire while the school's SchoolPay subscription is **active** (suppressed if expired).

### 15.5 What this changes for our plan
- The **Pull/Sync plan (§13, `SCHOOLPAY_PULL_SYNC_PLAN.md`)** can now be built without a discovery
  call for field names — the mapping is: `schoolpayReceiptNumber→ReceiptNo`, `studentPaymentCode→regno`
  (resolve to our reg-no), `paymentDateAndTime→datePaid`, `sourcePaymentChannel→channelPaid`,
  `amount→amount_paid`, `studentName→stud_name`.
- Prefer the **range endpoint (`SchoolRangeTransactions`, ≤31 days)** for catch-up — one call per gap.
- Still blocked only on **our school code + pull password** (§12.4).
- Contact for those: support@schoolpay.co.ug · 0200 502 140 · WhatsApp +256 750 923262.

---

*Prepared from a live read of the source across all three applications and the production MySQL
schema/data on 2026-06-30. §12 added from the SchoolPay "Transaction Sync API v0.1 (2018)" spec;
§15 added 2026-07-01 from the official docs at schoolpay.co.ug/apidocumentation.
§14 documents the stabilization deployed the same day (scripts in `COOPERP/sql/schoolpay/`, with
the original engine kept for rollback). The only data changes were: posting the 13 genuinely-paid
stuck transactions, and creating the hardened engine + sweep SP + auto-sweep event. Sabia test
data was created and fully reverted.*
