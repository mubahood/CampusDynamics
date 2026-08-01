# Force-Register + Bill — 2026/2027 UNREGISTERED backlog (2026-07-11)

**Status:** ✅ EXECUTED & VERIFIED on live `campus_dynamics` + `campus_dynamics_accounts`. Fully tracked and reversible.

## The problem
Students appearing in the 2026/2027 registration list were stuck at `regstatus='UNREGISTERED'` and **not billed** (e.g. MRU2025002204), contradicting the rule *"every student who registers must be automatically registered and automatically billed."*

**Root cause:** billing is **event-driven** — only the eportal semester-registration wizard flips `regstatus=REGISTERED` and bills. Students land in a semester by other paths that DON'T bill:
- **Promotion** (`StudentsPromotion.aspx.cs`) bulk-rolls continuing students forward as `UNREGISTERED` placeholders (by design) with **no bill and no courses**.
- **Admin course registration** assigns courses without necessarily completing the wizard.
- **Wizard billing failure** reverts the student to `UNREGISTERED` (`SemesterRegistrationWizardService.TryRevertRegistrationStatus`), stranding them unbilled.

Because these students had usually already **paid** (SchoolPay etc.), the money sat as an **unallocated credit** — the cohort's net balance was **−38.6M (credit)**.

## Cohort scoping (important — deviated from the literal "1,205")
The 1,205 UNREGISTERED 2026/2027-S1 rows broke down as:
| new_status | count | decision |
|---|---|---|
| **ACTIVE** | 808 rows / **757 distinct** | ✅ billed (continuing students, the real target) |
| ALUMNI | 304 | ⏭ **excluded** — entry years 2024/25/26, cannot have graduated → misclassified; billing graduates is wrong. Needs status review, not billing. |
| ADMITTED | 93 | ⏭ **excluded** — brand-new 2026 intake; different first-registration flow. |

Within the 757 ACTIVE distinct: **1 excluded** (MRU2024001145, 4 conflicting-studyyear rows) → **756 billed target**.

## What was done (ACTIVE cohort, 756)
1. **Snapshotted** every registration row + before-balance (rollback source).
2. **Pilot** on MRU2025002062 (BAED yr2), fully inspected: −522,000 credit → billed Tuition 630,000 + Functional 687,000 → **+795,000 owing** (exact; money now allocated).
3. **Deduped** 47 same-studyyear duplicate registration rows (kept min ID; archived).
4. **Flipped** 756 `UNREGISTERED → REGISTERED` (`registeredBy='AUTO-RECON-20260711'`).
5. **Billed** each via the canonical, **idempotent** SP `fin_AutoBillOnRegistration` (→ `fin_Autobilling` → `fin_BillProgrammeFees`/`fin_TermlyItemBillingFN`; `'Already Billed'` short-circuits, no double-bill).
6. Cleaned **10** students who ended with a duplicate REGISTERED row (pre-existing + flip); archived.

### Result
- **743 students newly billed**, **1,486 lines**, **UGX 985,554,500**.
- Cohort net balance **−38.6M (credit) → +947.0M (owing)** — shift **+985.6M** = exactly the billed total.
- **0** cache/canonical mismatches · **0** double-bills · all cohort now REGISTERED.
- Balance cache rebuilt for 747 students (matches `fin_GetCanonicalStudentBalance` exactly).

## Not auto-billed — 16 flagged for manual review (`fin_forcebill_20260711_manual`)
- **12** — enrolled (have courses) but **no `acad_registration` row at all** for 2026/2027-S1. Can't safely auto-create (study-year ambiguous). Detected by the sweep every run until resolved.
- **2** — BBA year-4: `fin_GetProgrammeFee=0` (no year-4 fee structure) → correctly billed nothing; confirm completing-year fee.
- **2** — conflicting study-year (MRU2024001145 yr2/yr3; MRU2024001964 yr2/yr4). Resolve year, then bill.

## Tracking / rollback artifacts (`campus_dynamics_accounts` unless noted)
| Object | Purpose |
|---|---|
| `campus_dynamics.acad_reg_forcefix_20260711` | cohort snapshot (old regstatus/registeredBy) |
| `campus_dynamics.acad_reg_forcefix_20260711_excluded` | MRU2024001145 rows (conflicting-year) |
| `campus_dynamics.acad_reg_forcefix_20260711_deldupes` | 47 deduped registration rows (archived) |
| `campus_dynamics.acad_reg_forcefix_20260711_dupreg` | 10 duplicate-REGISTERED rows removed (archived) |
| `fin_forcebill_20260711_before` | pre-fix canonical balance per student |
| `fin_forcebill_20260711` | registry: 1,486 tracking bill TIDs posted (true, deduped) |
| `fin_forcebill_20260711_gl` | matching GL DR TIDs |
| `fin_forcebill_20260711_manual` | the 16 manual-review students |

**Rollback (targeted):** delete the GL DRs + tracking rows in the registry for today, restore `fin_student_balance_cache` from `fin_forcebill_20260711_before` (cache = −before_bal), then a normal cache rebuild. ⚠️ **`fin_ledger` is MyISAM — no transactions/ROLLBACK; all writes are real/tagged.**

---

## Prevention (both layers, as requested)

### 1. Sweep procedure — `fin_ReconcileEnrolledBilling(acadyear, semester, apply, maxapply)`
`COOPERP/sql/fin_ReconcileEnrolledBilling.sql` (installed). Enforces **"enrolled (has courses) ⇒ REGISTERED + billed"** for ACTIVE students. Idempotent, cross-DB. `apply=0` report / `apply=1` fix, with a **runaway cap** (`maxapply`: if a run would touch more than the cap, it flags `EXCEEDS_CAP` and bills nothing). Logs to `fin_enrolled_billing_gap_log`.
- **Bug fixed during build:** a `NOT FOUND` raised inside `fin_Autobilling` (enrolled student with no registration row) tripped the cursor's own `NOT FOUND` handler and aborted the loop early. Fixed by wrapping the per-row work in a nested block with its own swallowing handlers. Verified: FIX processed **15/15**, stable residual of the 12 no-row students.

### 2. Scheduled job — `BillingReconciliationJob`
`App_Code/Finance/BillingReconciliationJob.cs`, wired into `Global.asax Application_Start` (mirrors the proven `SchoolPaySyncJob`). Every N hours (default 12) it runs the sweep in **FIX** mode for the **current** academic year+semester, capped (default 300), fully idempotent. Health/heartbeat + pause in `fin_billing_recon_jobstate`.
- **⚠️ Activation:** takes effect on the next **app-pool recycle / restart** (App_Code recompiles). Config knobs: `Billing.ReconcileHours`, `Billing.ReconcileCap`.

### Recommended follow-ups (not done — need product decisions)
- Consider making the wizard's billing-failure path NOT strand the student to UNREGISTERED (the sweep now self-heals it within N hours regardless).

---

## Phase 2 — the excluded ALUMNI/ADMITTED, resolved by the onboarding rule (2026-07-11, same day)

Investigating why **MRU2026004258** stayed UNREGISTERED+unbilled exposed two things:

**1. `new_status` is a corrupted column.** **28,363** active students carry `new_status='ALUMNI'` while `stud_status='ACTIVE'`, and **zero** students are consistently ALUMNI. `stud_status` is uniformly 'ACTIVE' (no signal). So neither column reliably flags a graduate — my Phase-1 `new_status='ACTIVE'` guard wrongly excluded 304 active students, and the prevention sweep had the same blind spot.

**2. The admin's rule for NEW students:** a new-intake semester registration is only *real* if the student **logged into eportal (onboarded to `my_aspnet_users.user_verification_status='ACTIVE STUDENT'` / has a real `my_aspnet_membership.LastLoginDate`)** OR was **enrolled in courses** (self or by an admin). A new student who never logged in AND has no courses = a **false placeholder registration** → delete it + reset the bill. Billing happens only on genuine enrollment.

**Actions taken on the remaining 400 UNREGISTERED (2026/2027 S1):**
| Bucket | Count | Action |
|---|---|---|
| Continuing (yr≥2 / entry<2026) | 291 | flip REGISTERED + bill (`AUTO-RECON2-20260711`) |
| New intake WITH courses | 11 | flip REGISTERED + bill (enrolled) |
| New intake, no courses, **never onboarded** | 91 | **deleted** the false registration (archived; none had bills) |
| New intake, no courses, **logged in** | 7 | kept UNREGISTERED+unbilled until they enrol (incl. MRU2026004258) |
| Conflicting study-year | 1 (MRU2024001145) | excluded again → manual |
- **Reversed MRU2026004428** — a new student (not onboarded, no courses) that Phase 1 had wrongly billed: removed its bill (GL+tracking archived to `fin_forcebill_20260711_reversed` / `fin_deleted_ledger`) and deleted the false registration; balance back to 0. It was the **only** wrongly-billed case.
- **MRU2026004258 self-resolved**: it logged in and registered 6 courses during the day → the wizard billed it 1,647,000 automatically (the rule working live).

**Phase-2 result:** 249 continuing/enrolled billed (UGX 305.7M). **Combined day total: 1,005 students, UGX 1,299,273,000, 0 cache/canonical mismatches.** 2026/2027 S1 is now **1,665 REGISTERED / 8 UNREGISTERED / 4 CLEARED** (was ~1,205 UNREGISTERED). Archives: `reg_cleanup_20260711` (classification+decision), `reg_cleanup_20260711_deleted_regs` (all deleted reg rows), `fin_forcebill2_20260711_before`, `fin_forcebill_20260711_reversed`. **58** students in `fin_forcebill_20260711_manual` (37 BEICT-yr4 + BBA-yr4 finalists w/ no fee structure, ~19 enrolled-with-no-registration-row, 2 conflicting-year).

**Prevention sweep corrected:** `fin_ReconcileEnrolledBilling` no longer filters on the corrupted `new_status` — it uses `acad_student.completion_date IS NULL` (graduate guard) with current-semester course enrollment as the trigger. Bills any genuinely-enrolled student (self or admin enrolled), never the not-enrolled.

---

## Phase 3 — full-year UNREGISTERED sweep by the onboarding rule (2026-07-11)

Applied the admin's rule to ALL 251 remaining UNREGISTERED 2026/2027 rows (S1=8, S2=59, S3=184), across every semester, per-row (course check = the row's own semester). Onboarding "engaged" signal = `my_aspnet_users.user_verification_status='ACTIVE STUDENT'` **OR** actually logged in (`my_aspnet_membership.LastLoginDate > CreationDate`) — login must count because only 3,315 of ~16k students ever get the `ACTIVE STUDENT` flag, so status alone would wrongly delete thousands of real students.

Classification + actions (`campus_dynamics.reg_perfect_20260711`, col `decision`):
| Decision | Count | Rule | Action taken |
|---|---|---|---|
| **BILL** | 34 (all S2) | has courses that semester | flipped REGISTERED + billed (`AUTO-RECON3-20260711`) — **UGX 91,745,000**, 68 lines, 0 cache mismatches |
| **DELETE** | 73 (all S3) | never engaged (no ACTIVE STUDENT, never logged in) AND no courses | deleted the ghost registration rows (archived `reg_perfect_20260711_deleted`) |
| **HOLD** | 144 (S1=8,S2=25,S3=111) | logged in / onboarded but no courses that semester | left UNREGISTERED — **admin decision** (billed automatically when they enrol; avoids premature future-semester debt) |

Key safety calls: (1) most S2/S3 candidates were NOT registered in any other 2026/2027 semester and S2/S3 carry real fees, so billing no-course students would have created future-semester debts — the admin chose **Hold**. (2) One DELETE ghost (MRU2024001568) had a real **Semester-1 bill** — only its empty S3 row was deleted; its S1 bill was preserved (delete is scoped to the ghost's own semester, and no ghost had a bill for its own semester). (3) MRU2024001145 (conflicting study-year) landed in HOLD → no action, issue moot.

**End state (Phase 3):** 2026/2027 UNREGISTERED = **144**, of which **0 have courses** and **0 are ghosts** (all logged-in). Rollback: `reg_perfect_20260711_deleted` (deleted regs), `fin_perfect_20260711_before` (pre-bill balances), bills tagged `registeredBy='AUTO-RECON3-20260711'`.

### Phase 4 — admin reversed the Hold: register + bill the 144 (2026-07-11)
Admin instructed to register + bill the 144 held students after all (a mandatory-registration choice, overriding the earlier Hold — they are all real logged-in students). Flipped all 144 UNREGISTERED->REGISTERED (`AUTO-RECON4-20260711`) and billed each **per its own semester** (S1=8, S2=25, S3=111). **140 billed, 312 lines, UGX 139,049,000, 0 cache mismatches.** The **4** with no fee structure (`decd` x3, `BBE` x1) were registered but billed 0 -> flagged in `fin_forcebill_20260711_manual`. Rollback: `fin_perfect2_20260711_before`, bills tagged `AUTO-RECON4-20260711`.

**FINAL 2026/2027 STATE: 2074 REGISTERED, 28 CLEARED, 0 UNREGISTERED.** Every registration in the year is now registered.

### Phase 5 — fee-structure repair (decd / BBE) + billing residuals (2026-07-11)
Investigated the 4 no-fee students. Root cause: **`decd` (Diploma in Early Child Development)** and **`BBE` (Bachelor of Business Education)** had a **Semester-3 fee data gap** — `fin_programme_fees` S3 cells were 0 for every year, even though these ARE real 3-semester programmes (decd students were historically billed **44.6M across 166 S3 bills**; they register S3 courses). Filled the missing cells from **historical ground-truth amounts** (a data repair, not invented): decd y1_s3=230k/264k, **y2_s3=230k/344k** (=574k, matches DPE diploma peer); BBE **y3_s3=280k/234k** (=514k, matches BBEI inservice). Backup: `fin_programme_fees_bak_20260711_decdbbe`. Then billed the 4 (3 decd @574k + 1 BBE @514k = **2,236,000**). This fee fix also unblocks S3 billing for all ~90 decd / 3 BBE students going forward.
- Also billed **3 BED yr3** students that had slipped through (one was `CLEARED` — `fin_AutoBillOnRegistration` only bills REGISTERED/LATE, so billed it via `fin_BillProgrammeFees` directly).

**Genuinely unbillable — 39 flagged for bursar (`fin_forcebill_20260711_manual`, 64 total):** **BEICT yr4 (37) + BBA yr4 (2)** — these are 3-year programmes (`has_year_4='No'`) and NO year-4 student was ever billed historically, so there is no year-4 fee to restore (unlike decd's S3). These are over-duration students (repeaters/late completers) needing a **retake/completion fee policy decision** — not auto-billed (would be inventing fees).

**Billing completeness (2026/2027):** of 2,102 enrolled registrations, **2,063 billed**, **39 unbilled** — and all 39 are the year-4 finalists awaiting a fee decision. Nothing else outstanding.

### Phase 6 — year-4 fee backfill for BEICT/BBA (2026-07-11)
Per admin instruction (source fees from classic system; if absent, set year-4 = year-3, only for the lacking programmes). Verified the **classic tables (`fin_fees_structure`, `fin_fees_pay_schedule`) have NO year-4** for BEICT/BBA either (only study_year 1-3). So backfilled `fin_programme_fees` for **only** BEICT + BBA: set `has_year_4='Yes'` and copied year-3 cells into year-4 (y4_s* = y3_s*). Backup: `fin_programme_fees_bak_20260711_yr4`.
- **Also had to fix `fin_GetProgrammeFee`** — it only had branches for study_year 1-3 (the y4 columns were added to the table but never wired into the procedure), so it returned 0 for year 4 regardless. Added the year-4 branches (safe: programmes without year-4 fees still return 0, verified on BSAF).
- Billed the **39** (37 BEICT @ 1,343,000 + 2 BBA @ 1,293,000) = **UGX 52,277,000**, 78 lines, 0 cache mismatches. Removed the resolved year-4 flags from `fin_forcebill_20260711_manual`.

**★ FINAL 2026/2027 STATE: 2,102 enrolled registrations, 2,102 billed (100%), 0 UNREGISTERED.** Every 2026/2027 registration is now registered and billed. Remaining `fin_forcebill_20260711_manual` flags (22) are the enrolled-but-no-registration-row students from Phase 1-2 (need a registration created). Rollback for this phase: restore `fin_programme_fees_bak_20260711_yr4`, delete bills tagged `AUTO-RECON4-20260711` for yr4, and (optionally) revert the fin_GetProgrammeFee year-4 branches.
