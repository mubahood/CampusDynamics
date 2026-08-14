# MUTEESA I ROYAL UNIVERSITY
## Functional Fee Correction — Academic Year 2026/2027

**Date:** 14 August 2026
**Scope:** 2026/2027 only. No earlier academic year was touched.
**Action:** Existing functional-fee bills corrected in place. **No new bill was raised.**

---

## 1. What was found in the fee structures

The functional fee was raised in `fin_programme_fees` on 14 August 2026. The audit trail
(`fin_fee_adjustment_batch`) records exactly what was applied:

| Increase | Structures | Fee cells | Applied by |
|---|---:|---:|---|
| **+95,000** | 46 | 250 | mugweri |
| +25,000 | 1 | 4 | muhindo |

Three points Senate/Bursary should note, because they differ from the instruction as given:

1. **The increase was applied to 47 of 130 fee structures**, not to every programme. 83 structures
   were not changed. Their students are billed correctly against their own (unchanged) structure.
2. **Only semesters 1 and 2** were raised. Semester 3 was not.
3. One structure received **+25,000**, not +95,000.

Because of this, the correction below was **not** applied as a flat +95,000 to everybody. Each
bill was recomputed from **the fee structure that actually applies to that student** — their
programme, their year of study, their semester — and only bills that disagreed with it were
touched. That approach is correct whatever each programme's increase happened to be.

---

## 2. The population examined

Every semester registration for 2026/2027, years 1–4, semesters 1–3:

| | Count |
|---|---:|
| Registrations for 2026/2027 | 3,548 |
| Distinct students | 3,301 |
| With a fee structure for their programme | 3,548 (100%) |
| Structure exists but the fee cell is 0 | 0 |

Every registered student resolved to a fee structure and a non-zero functional fee, so nothing
was skipped for want of a rate.

---

## 3. Bills against the structure, before the correction

| State | Bills | Students | Billed | Should be |
|---|---:|---:|---:|---:|
| Already correct | 437 | 354 | 114,210,500 | 114,210,500 |
| **Differs from the structure** | **2,615** | **2,596** | 2,166,191,300 | 2,413,649,850 |
| Registered but never billed | 496 | 478 | 0 | 480,326,450 |

Of the 2,615 that differed, **2,585 were short by exactly 95,000** — the structure increase not
yet reflected in the bill. The remaining 30 differed by other amounts and are unrelated to it.

---

## 4. What was corrected

Only bills that were **exactly 95,000 short** and whose ledger voucher was a clean, balanced
1 DR + 1 CR pair.

| | |
|---|---:|
| Bills corrected | **2,571** |
| Students affected | **2,558** |
| Programmes | 33 |
| Value before | 2,127,382,400 |
| Value after | **2,371,627,400** |
| **Increase billed** | **+244,245,000** |

By semester — nothing outside semesters 1 and 2 was touched:

| Semester | Bills | Increase |
|---|---:|---:|
| 1 | 2,493 | 236,835,000 |
| 2 | 78 | 7,410,000 |

Largest programmes by volume:

| Programme | Bills | Students | Increase |
|---|---:|---:|---:|
| BAED | 440 | 440 | 41,800,000 |
| BEICT | 377 | 377 | 35,815,000 |
| BIT | 268 | 268 | 25,460,000 |
| BBA | 255 | 254 | 24,225,000 |
| BEE | 188 | 187 | 17,860,000 |
| BSAF | 183 | 183 | 17,385,000 |
| BCE | 150 | 150 | 14,250,000 |

### How each bill was changed

A functional-fee bill exists in three places. All three moved together:

```
fin_ledger  DR   student account      687,000  ->  782,000
fin_ledger  CR   AC6007 receivable    687,000  ->  782,000
fin_studentfeestracking (item 52)     687,000  ->  782,000
```

*(Real example: MRU2025002261, Semester 1.)*

**The record was updated, not replaced.** Row counts are identical before and after —
`fin_ledger` 175,164 and `fin_studentfeestracking` 80,856 — so no new transaction was
created, as required.

---

## 5. Verification

| Check | Result |
|---|---|
| Ledger rows before / after | 175,164 / **175,164** — none created or deleted |
| Tracking rows before / after | 80,856 / **80,856** — none created or deleted |
| Affected vouchers, DR total | **2,371,627,400** |
| Affected vouchers, CR total | **2,371,627,400** — still balanced to the shilling |
| Bills now matching the structure | **2,571 of 2,571** |
| Tracking rows in step with the ledger | 2,570 of 2,570 that have one |
| Rows touched outside 2026/2027 | **0** |
| Rows touched that are not Function Fees | **0** |
| Tracking rows touched that are not item 52 | **0** |

**Reversible.** Every changed row was recorded with its previous value, before the change, in
`campus_dynamics_accounts.bak_ff_increase_20260814` — 7,712 rows (2,571 DR + 2,571 CR + 2,570
tracking). The ledger's own audit trigger also wrote 5,142 rows to `edit_ledger`.

---

## 6. A defect found and fixed on the way

The first attempt failed with:

```
Field 'accountcode' doesn't have a default value
```

`edit_ledger` began as a full mirror of a ledger row — `accountcode`, `account_type`,
`particulars`, `voucherNo`, `teller` and others are all `NOT NULL` with no default. The
`trigger_*` audit columns were added later, and `trg_fin_ledger_after_update` filled only those.
Under `STRICT_TRANS_TABLES`, which this server runs, that INSERT fails on the first unsupplied
column — and because it fires from an AFTER UPDATE trigger, it takes the UPDATE down with it.

**The practical effect: no ledger amount could be corrected at all**, and the error named the
audit table rather than the statement, so the cause was not obvious.

The trigger now records the whole previous row alongside the before/after values, which is what
the table was shaped for. Script: `COOPERP/sql/finance/fix_edit_ledger_trigger.sql`.

---

## 7. Left alone, and why — requires a decision

Three groups were deliberately **not** changed.

### a) 496 registrations never billed at all — 478 students, 480,326,450

| Semester | Registrations | Students | Would bill |
|---|---:|---:|---:|
| 1 | 420 | 420 | 459,650,450 |
| 2 | 10 | 10 | 4,162,000 |
| 3 | 66 | 66 | 16,514,000 |

These students are registered for 2026/2027 but have **no functional-fee bill at any amount**.
Correcting them means *raising* a bill, not updating one — the opposite of the instruction —
so nothing was done. This is the largest open item and it is a billing gap, not a rate problem.

### b) 31 bills that differ by something other than 95,000 — 29 students, net 1,978,550

Gaps ranged from −248,500 to +684,000. They pre-date this increase and each needs its own
explanation; six are **over-billed** (the student was charged more than the structure allows), so
correcting them would *reduce* a bill. Not a decision to automate.

### c) 13 bills that are 95,000 short but sit on an irregular voucher

Their ledger vouchers are not a clean 1 DR + 1 CR pair (two vouchers carry 2 DR + 2 CR, one has
1 DR and no CR, one 2 DR + 1 CR, one 3 DR + 3 CR). Changing an amount on an unbalanced voucher
would deepen the imbalance, so they were excluded. They need the voucher repaired first.

Affected: MRU2024001080, MRU2025003714, MRU2025003729, MRU2025003742, MRU2025003744,
MRU2026004512, MRU2026004621, MRU2026005103, MRU2026005138, MRU2026005142, MRU2026005154,
MRU2026005240, MRU2026005345.

---

## Summary

1. **2,571 functional-fee bills across 2,558 students were corrected** to match the current fee
   structure, adding **UGX 244,245,000** to 2026/2027 billing.
2. **Existing records were updated, not duplicated** — row counts are unchanged and both ledger
   legs moved together, so every voucher remains balanced.
3. **Nothing outside 2026/2027 was touched**, verified explicitly.
4. **The increase was +95,000 on 46 structures, not on every programme** — 83 structures were
   never raised, and semester 3 was not included. Worth confirming that was intended.
5. **496 registered students have no functional-fee bill at all**, worth UGX 480,326,450. This is
   now the largest outstanding item.
6. Everything is reversible from `bak_ff_increase_20260814`.

---

*Scripts: `COOPERP/sql/finance/ff_increase_2026_2027.sql` (correction) and
`COOPERP/sql/finance/fix_edit_ledger_trigger.sql` (audit-trigger repair).*
