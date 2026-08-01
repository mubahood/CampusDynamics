# General Dashboard — Master Plan & Roadmap

> **Screen:** `NewScreens/GeneralDashboard.aspx` (eadmin / main system)
> **Audience:** ALL users who access eadmin (institution-wide overview, role-aware emphasis).
> **Status:** PLAN — nothing built yet. This document is the single source of truth for the build.
> **Author context:** Muteesa I Royal University (MRU) — Campus Dynamics.
> **Last updated:** 2026-07-04.

---

## 0. Purpose & Vision

A **one-stop, dynamically-filterable overview** of the whole institution's data, opening with a deep focus on **students** — how they enter (onboarding/applications), how they progress (semester registrations), and how they pay (collections over date ranges). Every number is backed by a **real, verified query** (see §2), every filter uses **real values pulled from the live DB**, and the whole board **re-computes live when the user changes a filter**.

Design principles:
1. **Accuracy over impressiveness** — no metric ships unless its query is verified against the live DB. Where the data has a known limitation (e.g. no true registration date), the widget states it honestly rather than faking precision.
2. **One page, many lenses** — a global filter bar drives every widget through a single aggregate endpoint.
3. **Reuse, don't reinvent** — match the existing dashboards' stack exactly (Chart.js 3.9.1, PageMethod AJAX, `.stat-card`/`.section-card` CSS, the `.md-loader`, the AI-insights contract).
4. **Fail-soft** — every widget query is independently try/caught; one broken widget never blanks the page.
5. **Visible to everyone** — `data-roles="all"`; institution overview is not gated. Role only tweaks *emphasis*, never *access* to this page.

---

## 1. Architecture Decisions (locked)

| Concern | Decision | Why |
|---|---|---|
| **Page shell** | `MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master"`, `Inherits="COOPERP_NewScreens_GeneralDashboard"`, `AutoEventWireup="true"`, `CodeFile="GeneralDashboard.aspx.cs"` | Matches every NewScreens page (verified vs FeesStructure/NewDashboard/MarksDashboard). |
| **Data loading** | **PageMethod AJAX** (MarksDashboard "Pattern B") — `Page_Load` stays empty; client calls `[WebMethod(EnableSession=true)] static string` methods, serialized with `JavaScriptSerializer`, unwrapped client-side via `o.d`. | Dynamic filtering needs re-fetch without full postback. Server-side `Page_Load` binding (NewDashboard "Pattern A") can't re-run on filter change without a postback flicker. |
| **Aggregate endpoint** | ONE method `GetDashboard(string filtersJson)` returns the entire board payload (KPIs + all chart series) as a single JSON object. Secondary methods for drill-downs / AI. | One round-trip per filter change; simplest to keep widgets in sync. |
| **Charting** | **Chart.js 3.9.1** via `https://cdn.jsdelivr.net/npm/chart.js@3.9.1/dist/chart.min.js` | Exact version already used by NewDashboard; no new dependency. |
| **CSS** | Inline `<style>` in `HeadContent`; reuse `.stat-card`, `.section-card`, `.mini-table`, `.stats-grid` patterns; theme.css + sidebar.css already loaded by master. | Consistency + zero new CSS files. |
| **Colors** | Primary navy `#05275C`, accent blue `#174DA4`, surface `#f5f7fa`, border `#e0e5ed`, text `#1a1a2e`. Semantic: success `#28A745`, warning `#FFC107`, danger `#DC3545`, info `#17A2B8`. **Never** the retired purple `#422774`. | Design-system spec + FeesStructure benchmark. (theme.css exposes `--cd-*` vars.) |
| **Loader** | Reuse the `.md-loader` fixed-overlay + `.show` toggle pattern from MarksDashboard; show during every fetch. | Proven, matches "clear JS loader" expectation. |
| **AI insights** | Reuse the MarksDashboard contract: rule-based narrative always; optional Claude via `AppSettings["Anthropic.ApiKey"]` + `["Anthropic.Model"]`; response `{success, powered_by, narrative, highlights[], risks[], recommendations[]}`. | Key is currently empty → graceful rule-based fallback. |
| **Connections** | **Two DBs.** Student/academic data → `campus_dynamics`; finance → `campus_dynamics_accounts`. Reuse existing connection helpers (e.g. the `ApiHelper.QueryAccounts` path used by FinanceEngine) rather than hardcoding. Confirm exact `connectionStrings` keys in `web.config` during Phase 0. | Cross-DB is unavoidable; must not assume a single connection. |
| **Language** | **C# 5 only** — no string interpolation `$""`, no null-conditional `?.`, no auto-property initializers. Verify by brace-count + live query (no compiler). | Project constraint. |

---

## 2. Grounded Data Model (VERIFIED against live DB — do not guess)

All row counts / distributions below were pulled live on 2026-07-03/04. Host: `localhost`, `root`. **Every code-to-code join is `TRIM()`'d** (CHAR columns are space-padded).

### 2.1 Students — `campus_dynamics.acad_student` (31,683 rows)
| Field | Column | Notes |
|---|---|---|
| Reg no (PK) | `regno` char(50) | join key everywhere |
| Name | `firstname` + `othername` | system order = firstname **then** othername |
| Programme | `progid` → `acad_programme.progcode` (**TRIM join**) | |
| Faculty | `acad_programme.faculty_code` → `acad_faculty.faculty_code` | derived, not stored on student |
| Intake | `intake` | AUGUST 30,979 · JANUARY 502 · FEBRUARY 121 · APRIL 55 · MAY 11 · DECEMBER 9 · JULY 4 (+ dirty: `2026`,`NOVEMBER`) |
| Entry year | `entryyear` int | 2026=568 · 2025=2,222 · 2024=2,084 · 2023=1,453 … |
| Session | `studsesion` | DAY 28,936 · INSERVICE 1,614 · WEEKEND 1,127 (EVENING negligible) |
| Gender | `gender` | MALE 16,701 · FEMALE 14,980 |
| **Status** | `new_status` | **ALUMNI 28,369 · ACTIVE 2,817 · ADMITTED 497** ← use THIS |
| (avoid) | `stud_status` | always `ACTIVE` — useless as filter |
| Campus | `studCampus` int | |

⚠️ **No created/registered date on `acad_student`.** For "new students over time" use `acad_applications.app_created_at` (2026+ only) or `entryyear` (year granularity only).

### 2.2 Semester registration — `campus_dynamics.acad_registration` (29,130 rows)
| Field | Column | Notes |
|---|---|---|
| Student | `regno` | → acad_student |
| Academic year | `acad_year` varchar | format **"2025/2026"**; range 2008/2009 … 2027/2028; current = **2025/2026** |
| Semester | `semester` int | **1, 2, 3** (3 = recess/trimester, small) |
| **Status** | `regstatus` | UNREGISTERED 14,733 · REGISTERED 11,058 · CLEARED 3,028 · LATE REGISTERED 192 · HALTED 96 · DEAD YEAR 22 |
| Year of study | `studyyear` | 1=13,255 · 2=9,789 · 3=5,913 · 4=173 |
| Date proxy | `examClearanceDate` date | ⚠️ only date-ish column; 9,013 non-null (2024-05→2026-06). **No true registration-date column.** |

**Real `acad_year × semester` volumes (top):** 2025/2026 S1=4,562 · 2024/2025 S1=3,965 · 2025/2026 S2=3,851 · 2023/2024 S1=3,370 · 2024/2025 S2=3,217 · 2025/2026 S3=763 · 2026/2027 S1=661.

### 2.3 Onboarding / applications — `campus_dynamics.acad_applications` (5,622 rows)
| Field | Column | Notes |
|---|---|---|
| Entry no (PK) | `stud_entry_no` | |
| Resulting reg | `stud_reg_no` | set when admitted+registered |
| **Status** | `app_status` | **ADMITTED 5,002 · DRAFT 501 · REGISTERED 76 · SUBMITTED 33 · REJECTED 5 · WITHDRAWN 5** |
| **Onboarding date** | `app_created_at` datetime | ⚠️ populated only for **2026 cohort (92 rows)**; historical rows NULL |
| Submitted date | `app_submitted_at` datetime | 46 non-null, 2026-05-28 → 2026-07-03 |
| Intake | `stud_intake` | AUGUST 4,519 · JANUARY 390 · FEBRUARY 286 · MAY 186 … |

- Programme choices: `campus_dynamics.acad_applicant_choices` (5,574) — `prog_id`, `adm_status` (**1=admitted 5,094 · 0=pending 461**), `adm_session` (DAY 3,533 · WEEKEND 1,088 · INSERVICE 943).
- App-fee proof: `campus_dynamics.apply_payments` (14 rows) — `status` default PENDING, `created_at`/`reviewed_at`.
- ⚠️ `campus_dynamics.apply_intakes` is **EMPTY** — do not source filter values from it.

**Date reality:** timestamped onboarding analytics only work for the **2026+ online-apply cohort**. Pre-2026 admissions have no timestamps → for "applications over time" scope to 2026+ and label it "Online applications (2026+)".

### 2.4 Payments / finance — `campus_dynamics_accounts` (MySQL, current to 2026-07-03)

**THREE overlapping tables — a single SchoolPay receipt appears in ALL THREE. NEVER sum across them.** Canonical single source for the dashboard = **`fin_ledger`**.

**`fin_ledger`** (the GL):
| Field | Column | Notes |
|---|---|---|
| Student ref | `accountcode` | also holds non-student accounts → filter `account_type='Student'` (34,960 student rows) |
| Type | `transactionType` char(2) | **`CR` = payment (money in)** · **`DR` = bill/charge** ← the discriminator |
| Amount | `transaction_amount` bigint **unsigned** | sign carried by type, NOT the number — never rely on sign |
| **Date** | `transactionDate` date | **indexed**, fully populated → THE range-filter column |
| Narration | `particulars` | |
| Origin | `source_system` | Manual, SB_COLLECTIONS (SchoolPay), CB_COLLECTIONS, Billing, RESTORED_STUDENT_LEDGER, OPENING_BALANCE, JOURNAL_VOUCHERS, REVERSAL, … |
| Link | `folio` | e.g. `TransCode:59783984`, `BillNo:<TID>` |

**Canonical "payments in a date range" query (verified):**
```sql
SELECT DATE_FORMAT(transactionDate,'%Y-%m') AS ym,
       COUNT(*) AS num_payments,
       SUM(transaction_amount) AS total_paid
FROM fin_ledger
WHERE transactionType = 'CR'
  AND transaction_amount > 0
  AND account_type = 'Student'
  AND transactionDate BETWEEN @start AND @end
  -- optional GL-noise exclusion for "real fee receipts":
  -- AND source_system NOT IN ('OPENING_BALANCE','JOURNAL_VOUCHERS','CB_OPERATIONS','REVERSAL')
GROUP BY ym ORDER BY ym;
```
**Real monthly CR volumes (last 12 mo):** 2025-11 = 5,699 pmts / 8.24B · 2026-03 = 6,572 / 6.59B · 2026-05 = 6,546 / 3.36B · 2026-06 = 1,007 / 1.53B … (billing cycles drive the spikes).

**`fin_schoolpaydata`** (mobile-money feed, payments only): `regno`, `datePaid`, `channelPaid` (Airtel Money 26,995 · MTN MobileMoney 11,622 · Stanbic USSD/Agent/PayWay …), `amount_paid`, `captureStatus` (only value = `Captured`). Use for the **"payments by channel"** breakdown only — do NOT add to `fin_ledger` totals.

**`fin_studentfeestracking`**: `regno`, `amount`, `trans_type` (Payment/Bill), `post_status` (`Posted`), `trans_date`, `semester`, `acadyear`. Payment filter = `trans_type='Payment' AND post_status='Posted'`. Used by `FinanceEngine.cs` (the deduped per-student balance, see [[canonical-student-balance]]); the dashboard's aggregate view uses `fin_ledger` single-source instead of the heavy dedup UNION.

**Billing vs collections:** `DR` (bills) vs `CR` (payments) in `fin_ledger` over the same window → outstanding/collection-rate metrics.

---

## 3. Dynamic Filter Model

A sticky **filter bar** at the top drives one endpoint. Changing any filter → show loader → `GetDashboard(filtersJson)` → repaint all widgets.

| Filter | Source of options (REAL values) | Applies to |
|---|---|---|
| **Date range** (from / to; presets: This month / Last 30d / This term / Last 12 mo / Custom) | — | payments (`transactionDate`), onboarding (`app_created_at`/`submitted`) |
| **Academic year** | distinct `acad_registration.acad_year`, newest first (default 2025/2026) | registrations, term-scoped fees |
| **Semester** | 1 / 2 / 3 | registrations |
| **Faculty** | `acad_faculty` (name + code) | students, registrations, fees (via student join) |
| **Programme** (optional, cascades from faculty) | `acad_programme` | same |
| **Intake** | cleaned distinct set: AUGUST/JANUARY/FEBRUARY/APRIL/MAY/DECEMBER | students, onboarding |
| **Session** | DAY / INSERVICE / WEEKEND | students |
| **Gender** | MALE / FEMALE | students |
| **Student status** | `new_status`: ACTIVE / ADMITTED / ALUMNI | students |
| **Campus** | distinct `studCampus` (resolve to names if a campus table exists — confirm Phase 0) | students |

Rules:
- Defaults: date = Last 12 months; acad_year = current (2025/2026); everything else = All.
- Filters are **AND**-combined; "All" = omit the predicate.
- Server builds predicates only from a **whitelist** (never string-concat raw user input; parameterize; map filter keys → fixed SQL fragments).
- A "Reset" chip clears to defaults. Active filters render as removable chips under the bar.
- Debounce rapid changes (250ms) to avoid endpoint spam.

---

## 4. Widget Catalog (Phase-1 = Students, Onboarding, Payments)

Each widget lists its **backing source** so nothing is guessed. Grouped into board sections.

### Section A — Student Body (snapshot; respects student filters, ignores date range)
- **KPI cards:** Total students (all) · Active (`new_status='ACTIVE'`) · Admitted-not-yet-active · Alumni · Male/Female split · # Faculties · # Programmes.
- **Chart — Gender doughnut** (MALE/FEMALE).
- **Chart — Students by Faculty** (bar; via TRIM join to `acad_faculty`).
- **Chart — Students by Session** (DAY/INSERVICE/WEEKEND doughnut).
- **Chart — Enrolment by entry year** (bar, last ~8 years from `entryyear`).
- **Mini-table — Top programmes by headcount.**
- **Chart — Year-of-study pyramid** (from `acad_registration.studyyear`, current acad_year).

### Section B — Onboarding & Admissions (respects date range where dates exist)
- **KPI cards:** Applications (total) · Admitted · Draft (incomplete) · Submitted-awaiting-decision · Admission rate (adm_status=1 / total choices).
- **Chart — Application status funnel** (DRAFT → SUBMITTED → ADMITTED → REGISTERED) from `app_status`.
- **Chart — Online applications over time** (2026+ cohort, by `app_created_at`, daily/weekly) — labeled "Online apply (2026+)".
- **Chart — Programme demand** (top `acad_applicant_choices.prog_id` as first choice).
- **KPI — Application-fee proofs** (`apply_payments` pending vs verified) — small, honest about the 14-row volume.

### Section C — Registrations (respects acad_year + semester + faculty)
- **KPI cards:** Registered · Unregistered · Cleared · Registration rate (Registered+Cleared / total for the term).
- **Chart — Registrations by acad_year × semester** (grouped bar; real distribution from §2.2).
- **Chart — Registration status breakdown** (doughnut) for the selected term.
- **Chart — Registered vs Unregistered by faculty** (stacked bar) → highlights where enrolment is leaking.
- **Widget — "Revenue at risk"**: count of UNREGISTERED students in the current term (ties to fees in Section D).

### Section D — Fees & Collections (respects date range + term + faculty)
- **KPI cards:** Total collected (date range, `fin_ledger` CR) · # payments · Avg payment · Total billed (DR) · Collection rate (CR/DR).
- **Chart — Collections trend** (daily or monthly line over the date range).
- **Chart — Payments by channel** (`fin_schoolpaydata.channelPaid`: Airtel/MTN/Stanbic…) — SchoolPay-only view, clearly labeled.
- **Chart — Collections by source_system** (Manual vs SchoolPay/SB_COLLECTIONS vs CB_COLLECTIONS …).
- **Chart — Billed vs Collected** over time (dual series) → the gap = outstanding trend.
- **Mini-table — Top paying programmes/faculties** in the window.

### Section E — Insight Layer (cross-cutting)
- **AI Insights panel** (rule-based + optional Claude) summarizing the *currently filtered* view: highlights, risks, recommendations. Same contract as MarksDashboard.
- **Data-quality strip** (creative, useful): flags dirty intake values, the ~463 students whose `progid` doesn't match a programme, unregistered-but-billed anomalies. Turns the dashboard into a stewardship tool, not just a viewer.

---

## 5. Creative Enhancements (beyond the brief — proposed, opt-in)

1. **Conversion funnel (headline widget):** Applied → Admitted → Account Active → Semester-Registered → Fees-Cleared, as one horizontal funnel with drop-off %. This is the single most powerful "story" the data can tell about a cohort.
2. **"Revenue at risk" linkage:** unregistered students × their outstanding balance (DR−CR) → a money figure leadership cares about, backed by real ledger data.
3. **Drill-down everywhere:** clicking any KPI/segment opens a slide-over list of the underlying students (paged, exportable) — reuses the PageMethod pattern.
4. **Export & print:** CSV export per widget + a print-optimized layout (the system already does print-optimized transcripts — same ethos).
5. **Comparison mode:** toggle to compare the selected window vs the previous equivalent window (this term vs last term; this month vs last) with ▲▼ deltas on KPI cards.
6. **Saved views:** persist a user's favorite filter combo (localStorage first; a `sys_` table later).
7. **"As of" freshness stamp + last-refresh** so users trust the numbers.
8. **Auto-refresh (optional, off by default)** for a wall-display mode.
9. **Role-aware default emphasis:** everyone sees the whole board, but a bursar lands scrolled to Fees, a registrar to Registrations — via the RBAC slugs already in session (non-blocking, cosmetic).

> These are proposals. Phase 1 ships Sections A–D + basic filters; §5 items are scheduled into later phases (§7) and can be trimmed on your call.

---

## 6. Sidebar Integration (verified mechanics)

- **Insert point:** `NewScreens/SidebarMaster.master`, immediately **after line 52** (right after the existing `lnkDashboard` HOME item, before the `Academics` heading).
- **Markup** (top-level, visible to all):
```html
<li class="cd-sidebar__item" data-roles="all">
    <asp:HyperLink ID="lnkGeneralDashboard" runat="server"
        NavigateUrl="~/COOPERP/NewScreens/GeneralDashboard.aspx" CssClass="cd-sidebar__link">
        <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24"
             fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <path d="M3 3h18v18H3z"></path><line x1="12" y1="3" x2="12" y2="21"></line>
            <line x1="3" y1="12" x2="21" y2="12"></line>
        </svg>
        <span>General Dashboard</span>
    </asp:HyperLink>
</li>
```
- **Visibility guarantee:** two RBAC layers exist — (a) legacy `data-roles` (set to `all`), and (b) the slug-map client filter (`applyMenuAccessFilter` using `window.cdUrlSlugMap`). **Action:** confirm `GeneralDashboard.aspx` is either absent from `cdUrlSlugMap` (fail-safe shows it) or mapped to a universally-granted slug, exactly like `NewDashboard.aspx`. Verify in Phase 0 by diffing how the current Dashboard is handled.
- Label it "General Dashboard"; keep the existing "Dashboard" (NewDashboard) as-is to avoid disruption.

---

## 7. Phased Roadmap & Task Breakdown

### Phase 0 — Foundation & Verification (no user-visible features yet)
- [ ] 0.1 Read `web.config` connectionStrings; record exact keys for `campus_dynamics` and `campus_dynamics_accounts`; confirm the helper(s) to reuse (FinanceEngine/ApiHelper path).
- [ ] 0.2 Confirm campus code→name source (or decide to show raw `studCampus`).
- [ ] 0.3 Confirm how `NewDashboard.aspx` passes the slug-map filter → replicate for GeneralDashboard.
- [ ] 0.4 Create `GeneralDashboard.aspx` + `.aspx.cs` scaffold (master, HeadContent, ContentPlaceHolder1, Chart.js CDN, `.md-loader`, empty filter bar + empty KPI grid). Page loads blank-but-styled.
- [ ] 0.5 Add sidebar item (§6) + verify it shows for a non-admin test session.
- [ ] 0.6 Stand up `GetDashboard(filtersJson)` returning a **stubbed** payload; wire the AJAX helper (`.d` unwrap) + loader; render one KPI card end-to-end to prove the pipe.

### Phase 1 — Students, Onboarding, Payments (the core ask) ✦ primary deliverable
- [ ] 1.1 Filter bar UI (all §3 filters) with real option values loaded from DB; chips + reset; debounce.
- [ ] 1.2 Section A (Student Body): KPIs + gender/faculty/session/entry-year charts + top-programmes table. **Verify each query live.**
- [ ] 1.3 Section B (Onboarding): status funnel + online-apply-over-time (2026+) + programme demand + app-fee KPI.
- [ ] 1.4 Section C (Registrations): term KPIs + acad_year×semester chart + status breakdown + registered-vs-unregistered-by-faculty.
- [ ] 1.5 Section D (Fees): collections KPIs + trend + by-channel + by-source + billed-vs-collected. **fin_ledger single-source; never cross-sum.**
- [ ] 1.6 Wire ALL widgets to the filter payload; confirm every filter re-computes correctly (incl. cross-DB student↔fees joins by regno).
- [ ] 1.7 Empty/zero/dirty-data states for every widget (no NaN, no blank canvases).

### Phase 2 — Insight & Integrity
- [ ] 2.1 AI Insights panel (rule-based first; Claude when key present) over the filtered payload.
- [ ] 2.2 Conversion funnel headline widget (§5.1).
- [ ] 2.3 Data-quality strip (§4-E) + "Revenue at risk" money figure (§5.2).
- [ ] 2.4 Comparison mode deltas on KPI cards (§5.5).

### Phase 3 — Depth & Convenience
- [ ] 3.1 Drill-down slide-overs (§5.3) + CSV export (§5.4).
- [ ] 3.2 Print-optimized layout.
- [ ] 3.3 Saved views + freshness stamp (§5.6–5.7).
- [ ] 3.4 Role-aware default scroll/emphasis (§5.9).

### Phase 4 — Extend beyond students (optional, later)
- [ ] 4.1 Add HR headcount, requisitions, accounts sections as additional collapsible board sections — same filter/endpoint pattern.

---

## 8. Error-Prevention & Verification Checklist (apply to every phase)

- [ ] **C# 5 only** — no `$""`, no `?.`, no auto-prop initializers. Brace-balance count after each `.cs` edit.
- [ ] **TRIM every code join** (`progid`↔`progcode`, `faculty_code`) — CHAR padding will silently drop rows otherwise.
- [ ] **Finance single-source** — payments from `fin_ledger` (`CR`, `account_type='Student'`); channel view from `fin_schoolpaydata`; **never add the two**. Amount is unsigned — type carries sign.
- [ ] **Cross-DB awareness** — student data (`campus_dynamics`) and fees (`campus_dynamics_accounts`) are different DBs; join by `regno` in app code or via fully-qualified names, not a single connection assumption.
- [ ] **Parameterize everything**; build predicates from a whitelist map, never raw concat of filter input.
- [ ] **Per-widget try/catch** — one failure returns an error marker for that widget only; page survives.
- [ ] **Honest date handling** — registrations have no true date (use term grouping / `examClearanceDate` proxy, labeled); onboarding timestamps are 2026+ only (scope + label).
- [ ] **Dirty-data hygiene** — normalize/exclude junk intake values (`2026`, `1`, `ALL`); surface the ~463 unmatched-programme students rather than dropping them silently.
- [ ] **Verify each metric live** with `mysql.exe` before wiring it; keep the verifying query in a comment near the C# method.
- [ ] **Loader on every fetch**; empty-state on every zero result; no raw `NaN`/`Infinity` reaching the UI.
- [ ] **RBAC visibility test** — load the page as a non-admin, low-privilege user; confirm both the menu item and the page render.

---

## 9. Open Decisions (need your call before/within Phase 1)

1. **Scope of Phase 1 charts** — ship all of Sections A–D as listed, or trim to a tighter first cut (e.g. A + C + D, defer B)? *(Recommendation: ship all four; B is small.)*
2. **"Payments" definition for the headline KPI** — include GL noise (`OPENING_BALANCE`, `JOURNAL_VOUCHERS`) or restrict to real fee receipts (exclude them)? *(Recommendation: exclude noise; show a footnote.)*
3. **Campus display** — is there a campus lookup table, or show raw `studCampus` codes for now?
4. **AI insights** — enable the Claude path now (needs a real `Anthropic.ApiKey` in web.config) or ship rule-based only for launch? *(Recommendation: rule-based now; Claude when key added.)*
5. **Creative items (§5)** — which are in-scope vs parked? Funnel + revenue-at-risk are high-value; drill-downs/export are heavier.

---

## 10. Reference Anchors (from live investigation)

- Dashboards to mirror: `NewScreens/NewDashboard.aspx(.cs)` (Chart.js, KPI CSS), `NewScreens/MarksDashboard.aspx(.cs)` (PageMethod AJAX, `.md-loader`, AI-insights contract, `MarksScopeResolver`).
- Sidebar: `NewScreens/SidebarMaster.master` (insert after line 52) + `SidebarMaster.master.cs` (`RegisterRbacMenuScript`, `RoleAccessService.SESSION_SLUGS`).
- Page scaffold template: `NewScreens/FeesStructure.aspx`.
- Theme: `NewScreens/css/theme.css` (`--cd-*` tokens), `NewScreens/css/sidebar.css`.
- Finance logic: `App_Code/FinanceEngine.cs` (canonical balance / dedup — see [[canonical-student-balance]], [[billing-overpaid-root-cause]], [[migration-ledger-transactions]]).
- Related memory: [[dashboard-role-widgets]], [[marksdashboard-ai-insights]], [[faculty-dept-programme-hod]], [[schoolpay-integration]].
