# Billing System Hardening — "won't miss a bill, won't double-bill" (2026-07-11)

Final consistency + robustness pass over the enrolment-billing system (eportal wizard + eadmin), verified end-to-end on the SABIA test student (MRU2027000002).

## Baseline audit (before)
- **Double-bills on real fee items: 0** — the duplicate guard (`fin_TermlyItemBillingFN` pre-checks 'Already Billed'/'Already In Ledger' + `fin_bill_uniqueness` UNIQUE(regno,acadyear,semester,item_code)) was already sound.
  - The only "duplicates" were `item_code=0` rows — that code is the manual-adjustment catch-all (waiver reversals, balance fixes), legitimately multiple per key. Excluded from the audit.
- **2026/2027 registered-but-unbilled: 0.**

## Defects found & fixed
1. **CLEARED students were never auto-billed.** `fin_AutoBillOnRegistration` billed only REGISTERED / LATE REGISTERED, so a student set to CLEARED without a prior bill stayed unbilled, and the reconcile sweep *downgraded* CLEARED→REGISTERED to bill them (losing the status). **Fix:** `fin_AutoBillOnRegistration` now bills CLEARED **in place** via `fin_BillProgrammeFees` (no downgrade); the sweep no longer downgrades CLEARED, and its gap-detection now treats CLEARED as an enrolled/billable status (so an already-billed CLEARED student is not falsely re-flagged — this removed 28 false gaps). Files: `sql/fin_AutoBillOnRegistration.sql`, `sql/fin_ReconcileEnrolledBilling.sql`.
2. **Sweep only ran for the "current" semester.** Students register across S1/S2/S3. **Fix:** `BillingReconciliationJob` now sweeps **all three semesters** each run (idempotent; an inactive semester is a harmless no-op).
3. **Balance cache drifted** as payments/bills posted with no refresh (audit found 6 stale rows in 2026/2027). **Fix:** new `fin_RefreshBalanceCache(regno)` recomputes one student's cache from the canonical dedup; the sweep now calls it for every student it bills, so a fresh bill never leaves a stale balance. Files: `sql/fin_RefreshBalanceCache.sql`.
4. (From the prior phase) `fin_GetProgrammeFee` had no year-4 branch — added.

## SABIA test matrix (all PASS)
Using MRU2027000002 on a throwaway 2027/2028 year, fully cleaned up afterward (balance restored to 2,296,500):
| Scenario | Expected | Result |
|---|---|---|
| REGISTERED → bill | tuition+functional posted once | ✅ 1,000,000 + 700,000 |
| CLEARED → bill in place | billed, status stays CLEARED | ✅ 900,000 + 600,000, still CLEARED |
| Call billing SP 3× | exactly 1 bill per item | ✅ no double-bill |
| UNREGISTERED → bill | nothing billed (gate) | ✅ 0 bills |
| Sweep on enrolled-unbilled | flip+bill (UNREG) / bill-in-place (CLEARED) | ✅ billed, cache auto-refreshed |
| Re-run sweep after billing | 0 gaps (no false re-flag) | ✅ 0 |

## The verification tool
**`fin_BillingConsistencyAudit(acadyear)`** (`sql/fin_BillingConsistencyAudit.sql`) — read-only; pass '' for all years. Reports: double-bills (real items), registered-unbilled, cache-mismatches, orphan-bills (billed but now UNREGISTERED) + a CONSISTENT / REVIEW-NEEDED verdict.
- **`CALL fin_BillingConsistencyAudit('2026/2027')` → CONSISTENT (0 / 0 / 0 / 0).**
- 2025/2026 shows historical gaps (registered-unbilled + orphan bills) — a separate prior-year cleanup, out of scope here.

## How the guarantee holds now
- **Won't double-bill:** every billing path funnels through `fin_TermlyItemBillingFN`, which checks tracking + GL before inserting, backed by the `fin_bill_uniqueness` UNIQUE constraint. Proven idempotent on SABIA (3× calls → 1 bill).
- **Won't miss a bill:** the wizard bills on self-registration; admin actions bill on registration; and the nightly `BillingReconciliationJob` sweeps **all semesters** in FIX mode (capped, idempotent), billing any enrolled (has-courses) student — REGISTERED, LATE, or CLEARED — that lacks a bill.
- **Stays consistent:** cache self-heals on every sweep-bill; the audit proc proves it at any time.

## Residual (surfaced, not silently ignored) — 34 in `fin_forcebill_20260711_manual`
- Students with **2026/2027 courses but no registration row** (ambiguous study-year: repeat yr3 vs progress yr4 → different fee). The sweep flags them every run; an admin must create the registration (correct study-year) then they bill normally. This is deliberate — the system surfaces them rather than guessing a fee.

## Follow-up recommendation
Wire `fin_BillingConsistencyAudit` into an admin screen (or the reconcile job's heartbeat) so the CONSISTENT/REVIEW verdict is visible without a manual query.
