# Abnormal-Balance Fix — 2026-08-01

Follow-up to the re-billing deletion. Analysed the 44 students whose `REBILLFIX` re-billings were deleted and fixed those with "not normal" balances.

## What was actually wrong

Each affected student had a **bill → erroneous reversal → re-billing** chain. We had deleted the re-billing (it was a pre-2026 year). That left the **erroneous reversal (a CR entry that exists ONLY in the ledger)** standing alone, while the **original bill still exists in `fin_studentfeestracking`**. Result: the *tracking* balance was correct (student owes), but the *ledger* balance showed a phantom credit.

**Proof (Yusuf WAMALA MRU2025004143):** tracking balance = **2,753,000 DR** (owes); ledger balance = **104,000 CR** — the exact divergence was the 2,857,000 reversal that lived only in the ledger.

So "billing them the missed semester" was impossible/wrong (the bill already exists — `UNQ_one_bill_per_student` blocks a duplicate). The genuine fix was to **remove the erroneous reversal**, which makes the ledger reflect the bill that was already there.

## Part A — 4 students registered for 2026/2027 (phantom credit removed)

Removed each one's erroneous reversal → they now correctly owe their missed semester.

| Reg No | Name | Before | After |
|---|---|---|---|
| MRU2025004143 | Yusuf WAMALA | 104,000 CR | **2,753,000 DR** |
| MRU2024000960 | MATHIUS MUKISA | 90,000 DR | **1,453,000 DR** |
| MRU2024001732 | RICHARD OKURUT OMODING | 2,318,000 DR | **5,071,000 DR** |
| MRU2024000547 | IVAN KIMBUGWE | 993,000 DR | **2,276,000 DR** |

## Part B — 5 non-registered students with credit > 1M

Removed erroneous reversals ("bill them genuinely"), then — per rule — any residual **credit over 100,000** was zeroed with a clear adjustment.

| Reg No | Name | Before | After | Action |
|---|---|---|---|---|
| MRU2024001135 | PARDON KAGWISAGYE | 3,020,700 CR | 2,300 DR | reversals removed |
| MRU2023000196 | COSTANTINA NAKALEMBE | 2,716,000 CR | 0 | reversals removed + 1,377,000 DR zeroing |
| MRU2023001213 | ABDULAH NTUMWA | 2,028,000 CR | 0 | reversals removed + 573,000 DR zeroing |
| MRU2024000761 | KEEFA TURYAGUMANAWE | 1,754,500 CR | 0 | reversals removed |
| MRU2025003885 | HADIJJAH NAMPOZA | 1,046,000 CR | 351,000 DR | reversals removed |

Result: **no non-registered student carries a credit over 100,000**.

## Safety / reversibility

- 18 removed reversal rows backed up in `campus_dynamics_accounts.fin_ledger_revfix_bak` (restore = `INSERT … SELECT` back).
- 2 zeroing adjustments logged in `campus_dynamics_accounts.fin_balfix_2026_log` (teller `BALFIX`, clear particulars).
- All 9 students' running ledger balances recomputed via `fin_UpdateLedgerBalances`.

## Note (separate, pre-existing)

For 3 Part-A students (MUKISA, RICHARD, IVAN) the ledger now shows they owe, but `fin_studentfeestracking` shows they owe *even more* — a leftover ledger↔tracking desync unrelated to these reversals (the wider 248-student desync). The phantom **credit** is fixed; full ledger↔tracking reconciliation for these is a separate exercise if wanted.
