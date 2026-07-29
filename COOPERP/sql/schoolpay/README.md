# SchoolPay stabilization (deployed 2026-06-30, DB: `campus_dynamics_accounts`)

Makes SchoolPay payment capture **stable, self-healing, and double-post-proof** without
changing the inbound webhook or any application code. See the full analysis in
`COOPERP/SCHOOLPAY_INTEGRATION_REPORT.md` (§14).

## Files (apply in order)
| File | What it does |
|---|---|
| `00_fin_AutoPayCapture_ORIGINAL.sql` | The pre-change engine, kept **for rollback only**. |
| `01_fin_AutoPayCapture_hardened.sql` | **Hardened engine** — double-post-proof for every caller. |
| `02_fin_SchoolPayRecaptureAllPending.sql` | Sweep SP — re-posts every `Pending` row via the engine. |
| `03_ev_schoolpay_autosweep.sql` | Event — runs the sweep every 10 minutes. |

```sql
SOURCE 01_fin_AutoPayCapture_hardened.sql;
SOURCE 02_fin_SchoolPayRecaptureAllPending.sql;
SOURCE 03_ev_schoolpay_autosweep.sql;
SET GLOBAL event_scheduler = ON;   -- already ON in production
```

## How it prevents duplicates (three layers, all verified)
1. **Receipt PK** on `fin_schoolpaydata.ReceiptNo` — a re-posted webhook receipt is rejected
   ("Data Already Captured").
2. **GL guard (NEW):** the engine checks `fin_ledger.folio = 'TransCode:<receipt>'` (indexed,
   `Index_3`) and posts the double-entry **at most once** — so re-capturing a partial/already-
   posted row can never double-credit the student.
3. **Tracking guard (NEW):** the `fin_studentfeestracking` row is added at most once
   (`regno`-narrowed `NOT EXISTS`, only on the re-capture path).

The **hot path (fresh capture) is unchanged** — `alreadyPosted = 0`, so the engine behaves
exactly like the original plus one indexed `COUNT(*)`.

## Capture behaviour by ledger state
| Student already credited? | Action |
|---|---|
| No (clean / fresh) | Full post: DR bank / CR student / tracking row / `Captured`. |
| Yes (partial or re-capture) | **No re-post**; add the tracking row if missing + mark `Captured`. |

## Verified 2026-06-30
- Cleared the 13 stuck payments (UGX 5,837,000) → all `Captured`, each exactly 1 credit / 1
  debit / 1 tracking row. `Pending` 13 → 0.
- Tested on the **Sabia** account (`MRU2027000002`): clean capture, double-post attempt, partial
  completion, and triple-stress re-capture — ledger always 2 legs, tracking always 1 row. Test
  data fully reverted.

## Rollback
```sql
SOURCE 00_fin_AutoPayCapture_ORIGINAL.sql;   -- restore engine
ALTER EVENT ev_schoolpay_autosweep DISABLE;  -- or DROP EVENT ev_schoolpay_autosweep;
```
