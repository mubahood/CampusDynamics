# Programme-code rename (NewFacultyProgrammes) — 2026-07-01

Two changes to `COOPERP/NewScreens/NewFacultyProgrammes.aspx(.cs)`:
1. **Removed the Delete button** (render button, `deleteProg` JS, hidden `btnDeleteProgramme`, and its
   `btnDeleteProgramme_Click` handler).
2. **Editable programme code** — during Edit the code field is **locked by default**; a
   "Change programme code" **toggle** unlocks it (with a red warning). On save, if the code
   changed, it is renamed **everywhere** via the stored procedure below.

## `acad_RenameProgrammeCode(oldCode, newCode, actor, dryRun)`
`acad_programme.progcode` has **no foreign keys**, and ~50 columns across three databases store the
code (`progcode / progid / prog_id / prog_code / programme_code / program_code`). The SP:
- **Discovers** every such column dynamically from `information_schema` (excludes backup/temp/work
  tables), so it is comprehensive and future-proof.
- Updates only rows holding the old code, then `acad_programme.progcode` itself.
- Is **atomic** — one transaction; `EXIT HANDLER ... ROLLBACK; RESIGNAL` undoes everything on any error.
- **Validates**: old/new required, must differ, old must exist, new must NOT already exist (each `SIGNAL`s).
- **Audits** to `acad_activity_log` ("Programme Code Change", `old -> new`, N tables / M rows).
- `dryRun=1` → returns the footprint (db, table, column, rows), changes nothing; `dryRun=0` → performs
  it and returns no result set (clean for `ExecuteNonQuery`).

```sql
SOURCE acad_RenameProgrammeCode.sql;
-- preview:  CALL acad_RenameProgrammeCode('OLD','NEW','user',1);
-- execute:  CALL acad_RenameProgrammeCode('OLD','NEW','user',0);
```

## Verified 2026-07-01 (round-trip on the live DB, fully reverted)
- Dry-run of `DEE` → **26 tables / 24,886 rows** across `campus_dynamics`, `_accounts`, `_portal`
  (acad_student 661, acad_results 11,312, acad_course_registration 2,428, fin_fees_structure, teaching
  allocations, exam settings, student locks, …).
- Live `DEE → ZZDEE_TMP → DEE`: all references moved and restored exactly; **0 leftover**; audit rows written.
- Atomicity proven (an induced error rolled back with DEE untouched).
- All 3 guard-rails fire (same code / not found / already exists) — DEE intact after each.

## App call
`NewFacultyProgrammes.aspx.cs` → `RenameProgrammeCode(old,new)` runs
`CALL acad_RenameProgrammeCode(@o,@n,@a,0)` with a 300s timeout; the SP throws on any problem and the
save handler shows the message. Field metadata is then updated keyed on the new code.

## Rollback
`DROP PROCEDURE acad_RenameProgrammeCode;` (data changes are per-rename and reversible by renaming back).
