# BILLFIX Reversal — Plan & Procedure (Delete / Reverse every bill we created)

**Target batch:** `BILLFIX-2026-06-24-01`
**Database:** `campus_dynamics_accounts` (live)
**Author/analysis verified against live DB:** 2026-06-25 (read-only)
**Status:** ✅ EXECUTED 2026-06-25 — reversal completed, all gates passed (see §11).

---

## 0. ⚠️ Decision advisory (read first)

The BILLFIX bills are **real, missing charges** (official fee-structure tuition + functional for semesters students were enrolled in). **Reversing them does not correct an error — it removes valid receivables.** Verified impact of a full reversal:

- **~UGX 2,336,845,300** of legitimate charges removed across **897 students**.
- Displayed balances jump up (toward credit): **~409 students would again show "overpaid" (> 50k)**, re-introducing **~UGX 254,345,390** of (phantom) credit; ~141 remain owing.
- This re-opens exactly the problem the fix solved. **Do not refund on the post-reversal numbers.**

Proceed only if the intent is explicitly to undo BILLFIX (e.g. to re-do it differently). This plan makes that **safe, exact, fully reversible, and audit-logged**. Scope is **Fix A only** (the bills); the Fix B code dedup is unaffected.

---

## 1. Objective & scope

Delete **every** transaction created by BILLFIX, identified by the hidden trackers:

| Store | Identifier | Rows | Amount |
|---|---|---:|---:|
| `fin_studentfeestracking` (Bill) | `fix_batch_id = 'BILLFIX-2026-06-24-01'` | **3,709** | 2,336,845,300 |
| `fin_ledger` (DR + CR) | `source_system = 'BILLFIX'` AND `RefNo = 'BILLFIX-2026-06-24-01'` | **7,418** | 2,336,845,300 (each side) |
| Registry | `fin_billfix_worklist.batch_id` (status APPLIED) | 3,709 | — |

**Total to delete: 11,127 financial rows.** The registry (`fin_billfix_worklist`, `fin_billfix_batch`) is **kept** (marked ROLLED_BACK) for audit and possible re-apply.

---

## 2. Pre-flight analysis — findings (all GREEN)

| Check | Result |
|---|---|
| Batch `mode` | `APPLIED`, 897 students, 3,709 bills, 2,336,845,300 |
| Tagged footprint | tracking 3,709 · GL DR 3,709 · GL CR 3,709 (matches registry exactly) |
| Registry integrity | 3,709 APPLIED, all carry `tracking_tid`, `ledger_dr_tid`, `ledger_cr_tid` |
| Drift | 0 worklist TIDs missing in tracking · 0 tagged bills missing from worklist |
| Tagged rows are all `Bill` | yes (3,709 / 3,709) |
| Foreign references to BILLFIX bills (non-BILLFIX GL pointing at them) | **0** → deleting creates no orphans |
| `fin_bill_uniqueness` slots for BILLFIX | 3,709 (freed automatically on delete — see §3) |
| Archive table `fin_deleted_ledger` | exists (117,457 rows) — receives deleted GL rows |
| Recompute proc `fin_UpdateAllLedgerBalances` | exists |
| Balance cache `fin_student_balance_cache` | exists |
| Pre-fix backups | `bak_20260624_fin_ledger`, `bak_20260624_fin_studentfeestracking` (now ~1 month stale) |

**Conclusion:** the footprint is clean, fully tagged, self-consistent, and dependency-free. A tag-keyed delete is exact and safe.

---

## 3. Trigger behaviour during reversal (verified — none block the delete)

| Trigger | Fires on | Effect on reversal |
|---|---|---|
| `trg_fin_ledger_before_delete` | BEFORE DELETE on `fin_ledger` | **Archives** each deleted row into `fin_deleted_ledger` (TID, amounts, particulars, `deleted_by`, `delete_date`). ✅ audit preserved, does **not** block. |
| `trg_sync_bill_uniqueness_delete` | AFTER DELETE on `fin_studentfeestracking` | If `trans_type='Bill'`, deletes the matching `fin_bill_uniqueness` slot → re-billing is possible later. ✅ |
| `trg_prevent_duplicate_bill` | BEFORE INSERT on tracking | Not involved in delete. On any **re-insert** it re-creates the uniqueness slot (slot is free after reversal), so re-apply works. |
| `trg_fin_ledger_before_update` / `after_update` | UPDATE only | Not involved. |

> Note: `fin_deleted_ledger` has **no** `source_system`/`RefNo` columns, so post-delete verification of the archive is done by **TID join** against the pre-reversal backup (§5), not by tag.

---

## 4. Reversal method

**Chosen method: tag-keyed hard DELETE** (matches the documented rollback in `BILLING_FIX_COMPLETION_REPORT.md` / `BILLING_FIX_EXECUTION_PLAN.md §14`). Justification: every row is uniquely tagged, the GL delete is **auto-archived** to `fin_deleted_ledger` (so a "delete" is itself audit-logged and recoverable), and uniqueness slots auto-free.

*(Alternative considered — posting contra/reversing entries instead of deleting — was rejected: it leaves the bills visible then cancelled, doubles the row count, and the user's instruction is to delete. The hard-delete + archive gives a cleaner end-state with an equivalent audit trail.)*

The operation is **fast** (bulk DELETE + one `fin_UpdateAllLedgerBalances`, ~sub-second with `idx_curr_balance`), so no batching is required — but a **canary** (§6) is still run first.

---

## 5. Procedure (exact, ordered)

> Run in `campus_dynamics_accounts`. Steps 0–2 are mandatory.

### Step 0 — Fresh, targeted backup of exactly what we will delete
```sql
DROP TABLE IF EXISTS bak_billfix_rev_ledger;
DROP TABLE IF EXISTS bak_billfix_rev_tracking;
CREATE TABLE bak_billfix_rev_ledger   AS
  SELECT * FROM fin_ledger             WHERE source_system='BILLFIX' AND RefNo='BILLFIX-2026-06-24-01';
CREATE TABLE bak_billfix_rev_tracking AS
  SELECT * FROM fin_studentfeestracking WHERE fix_batch_id='BILLFIX-2026-06-24-01';
-- VERIFY before continuing:  ledger = 7418,  tracking = 3709
SELECT (SELECT COUNT(*) FROM bak_billfix_rev_ledger)   AS gl_bak,
       (SELECT COUNT(*) FROM bak_billfix_rev_tracking) AS track_bak;
```

### Step 1 — Delete (single transaction)
```sql
START TRANSACTION;

-- 1a. GL rows (DR + CR) — each archived to fin_deleted_ledger by the before-delete trigger
DELETE FROM fin_ledger
 WHERE source_system='BILLFIX' AND RefNo='BILLFIX-2026-06-24-01';     -- expect 7418

-- 1b. Tracking Bill rows — frees fin_bill_uniqueness slots via after-delete trigger
DELETE FROM fin_studentfeestracking
 WHERE fix_batch_id='BILLFIX-2026-06-24-01';                          -- expect 3709

-- Inspect row counts in the session; if both correct:
COMMIT;
-- (else) ROLLBACK;  and investigate.
```

### Step 2 — Recompute balances, mark registry, rebuild cache
```sql
CALL fin_UpdateAllLedgerBalances();                                  -- recompute curr_balance

UPDATE fin_billfix_worklist SET status='ROLLED_BACK'
 WHERE batch_id='BILLFIX-2026-06-24-01' AND status='APPLIED';
UPDATE fin_billfix_batch SET mode='ROLLED_BACK'
 WHERE batch_id='BILLFIX-2026-06-24-01';
```
Then **rebuild `fin_student_balance_cache`**: load `StudentLedgers.aspx` once (its `EnsureBalanceCache` rebuilds on the 5-min TTL), or run the materialisation SQL used by `GetBalanceCacheRebuildSql`.

---

## 6. Canary (recommended before the full delete)

Reverse a small sample first, verify, then do the rest:
```sql
-- pick e.g. 5 students from the worklist; delete only their BILLFIX rows
SET @c := 'MRU2021000667,MRU2021000077,MRU2022000100,MRU2020000717,MRU2020000404';
DELETE FROM fin_ledger
 WHERE source_system='BILLFIX' AND RefNo='BILLFIX-2026-06-24-01'
   AND FIND_IN_SET(accountcode, @c);
DELETE FROM fin_studentfeestracking
 WHERE fix_batch_id='BILLFIX-2026-06-24-01' AND FIND_IN_SET(regno, @c);
CALL fin_UpdateAllLedgerBalances();
-- verify those 5 students' new balances ≈ (old balance + their BILLFIX amount); statements correct.
```
Worked projection (verified): `MRU2021000667` −16,040,000 → **−455,000**; `MRU2021000077` −7,726,000 → **+3,690,000**.

---

## 7. Verification gates (all must PASS after the full run)

```sql
-- G1: nothing tagged remains  => 0 / 0
SELECT (SELECT COUNT(*) FROM fin_ledger WHERE source_system='BILLFIX' AND RefNo='BILLFIX-2026-06-24-01') gl_left,
       (SELECT COUNT(*) FROM fin_studentfeestracking WHERE fix_batch_id='BILLFIX-2026-06-24-01') track_left;

-- G2: all 7418 GL rows landed in the archive  => 7418
SELECT COUNT(*) FROM fin_deleted_ledger d JOIN bak_billfix_rev_ledger b ON b.TID=d.TID;

-- G3: uniqueness slots freed  => 0 remaining for the batch combos
SELECT COUNT(*) FROM fin_bill_uniqueness u JOIN bak_billfix_rev_tracking t
  ON t.regno=u.regno AND t.acadyear=u.acadyear AND t.semester=u.semester AND t.item_code=u.item_code;

-- G4: no orphan GL referencing a now-deleted bill  => 0
SELECT COUNT(*) FROM fin_ledger l JOIN bak_billfix_rev_tracking t
  ON l.folio=CONCAT('BillNo:',CAST(t.TID AS CHAR));

-- G5: registry marked  => mode ROLLED_BACK, 0 APPLIED left
SELECT mode FROM fin_billfix_batch WHERE batch_id='BILLFIX-2026-06-24-01';
SELECT status, COUNT(*) FROM fin_billfix_worklist WHERE batch_id='BILLFIX-2026-06-24-01' GROUP BY status;

-- G6: spot-check 3 students — cache balance ≈ pre-reversal cache + their BILLFIX amount
```

---

## 8. Re-apply (rollback-of-the-rollback)

Two safe ways to put the bills back if reversal must be undone:

- **Option A (re-run, recommended):** reset and re-run the proven idempotent driver — creates fresh, correctly-tagged rows:
  ```sql
  UPDATE fin_billfix_worklist SET status='PLANNED', tracking_tid=NULL, ledger_dr_tid=NULL, ledger_cr_tid=NULL
   WHERE batch_id='BILLFIX-2026-06-24-01';
  CALL fin_BillFix_Apply('BILLFIX-2026-06-24-01');
  CALL fin_UpdateAllLedgerBalances();
  ```
- **Option B (exact restore from Step-0 backup):** re-insert the identical rows (uniqueness slots are free, so `trg_prevent_duplicate_bill` re-creates them):
  ```sql
  INSERT INTO fin_studentfeestracking SELECT * FROM bak_billfix_rev_tracking;
  INSERT INTO fin_ledger              SELECT * FROM bak_billfix_rev_ledger;
  CALL fin_UpdateAllLedgerBalances();
  ```
- **Ultimate fallback:** the pre-fix tables `bak_20260624_*` (note: month-stale; use only as last resort).

Keep `bak_billfix_rev_*` until the reversal is confirmed accepted.

---

## 9. Risks & sign-off

| Risk | Mitigation |
|---|---|
| Removes valid receivables → balances understate what students owe; ~409 re-show overpaid | Business decision — confirm intent (§0). Registry + backups make it fully re-appliable. |
| `curr_balance` running balances stale after delete | `fin_UpdateAllLedgerBalances()` in Step 2 |
| Statements/cache show old numbers | Rebuild `fin_student_balance_cache` (Step 2) |
| Accidental over-delete | Tag predicates are exact (7,418 / 3,709, verified); transaction-wrapped; Step-0 backup |
| Need audit of what was removed | Auto-archived to `fin_deleted_ledger` + `bak_billfix_rev_*` + registry ROLLED_BACK |

**Sign-off required before execution:**
- [ ] Finance confirms the intent to remove the BILLFIX receivables (understanding §0).
- [ ] Step-0 backup created & row counts verified (7,418 / 3,709).
- [ ] Canary (§6) run and verified.
- [ ] Full run + all §7 gates PASS.
- [ ] Cache rebuilt; 2–3 students spot-checked.

---

## 10. One-glance summary

```text
DELETE fin_ledger  WHERE source_system='BILLFIX' AND RefNo='BILLFIX-2026-06-24-01';   -- 7,418 (auto-archived)
DELETE fin_studentfeestracking WHERE fix_batch_id='BILLFIX-2026-06-24-01';            -- 3,709 (frees uniqueness)
CALL fin_UpdateAllLedgerBalances();                                                    -- recompute
UPDATE fin_billfix_batch/worklist -> ROLLED_BACK;  rebuild balance cache.              -- finalise
```
Exact · audit-logged · reversible.
```

---

## 11. Execution record (2026-06-25)

Executed exactly as planned, in controlled steps:

| Step | Result |
|---|---|
| Step 0 backup | `bak_billfix_rev_ledger` = 7,418 · `bak_billfix_rev_tracking` = 3,709 ✓ |
| Step 1 delete (txn) | GL & tracking removed → 0 / 0 BILLFIX rows remain ✓ |
| Step 2 recompute + mark | `fin_UpdateAllLedgerBalances` run; batch + 3,709 worklist rows → `ROLLED_BACK` ✓ |
| G2 archive | 7,418 GL rows in `fin_deleted_ledger` ✓ |
| G3 uniqueness | 0 slots left (all freed) ✓ |
| G4 orphans | 0 ✓ |
| G6 spot-check | MRU2021000667 −455,000 · MRU2021000077 +3,690,000 · MRU2022000100 −223,000 (match projection) ✓ |
| Step 4 cache rebuild | `fin_student_balance_cache` rebuilt = 5,813 rows ✓ |
| Final state | 0 BILLFIX anywhere; active overpaid>50k = 839, credit ≈ 500.2M, owing>50k = 419 |

Safety nets retained: `bak_billfix_rev_*` tables + `fin_deleted_ledger` archive + registry (`ROLLED_BACK`).

---

## 12. Backup consolidation & cleanup (2026-06-25)

The temporary working backups were consolidated into a clearly-named **permanent archive**, then the temp tables were dropped (create-and-verify *before* drop):

| Action | Result |
|---|---|
| Create `archive_billfix_20260624_ledger`  (= reversed GL rows) | **7,418** rows (DR total 2,336,845,300) ✓ |
| Create `archive_billfix_20260624_tracking` (= reversed Bill rows) | **3,709** rows ✓ |
| Drop `bak_billfix_rev_ledger` | removed ✓ |
| Drop `bak_billfix_rev_tracking` | removed ✓ |
| Post-drop exact recount of archives | 7,418 / 3,709 ✓ |

**Authoritative backups of the reversed BILLFIX batch (in `campus_dynamics_accounts`):**
- `archive_billfix_20260624_ledger` — the 7,418 deleted GL rows (DR+CR), full schema.
- `archive_billfix_20260624_tracking` — the 3,709 deleted tracking Bill rows, full schema.
- `fin_deleted_ledger` — independent auto-archive of the same 7,418 GL rows (by delete trigger).
- `fin_billfix_worklist` / `fin_billfix_batch` — registry (status `ROLLED_BACK`), with per-bill amounts/keys.

**Re-apply from the archive (if ever needed):**
```sql
INSERT INTO fin_studentfeestracking SELECT * FROM archive_billfix_20260624_tracking;
INSERT INTO fin_ledger              SELECT * FROM archive_billfix_20260624_ledger;
CALL fin_UpdateAllLedgerBalances();   -- then rebuild fin_student_balance_cache
```
*(Alternative: reset worklist to `PLANNED` and `CALL fin_BillFix_Apply('BILLFIX-2026-06-24-01')` to regenerate fresh rows.)*

**Note:** the pre-fix month-stale backups `bak_20260624_fin_ledger` / `bak_20260624_fin_studentfeestracking` were **left in place** (separate from this batch; drop them only after a wider finance review).

