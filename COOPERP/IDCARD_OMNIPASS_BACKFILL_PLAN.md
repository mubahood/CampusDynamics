# ID Card Backfill from OmniPass PRINTED status — Plan

**Goal:** for every student whose card OmniPass/XAXU reports as **PRINTED**, auto-create an `idcard_requests` record that has already passed through the whole lifecycle and sits at **printed → ready for collection**, with a full audit trail — so the ID-card module (eadmin console, eportal tracker, API) reflects reality.

Status: **DONE & verified 2026-07-16.** One-time backfill committed (2,486 requests + 12,430 events, all at PRINTED with a 5-step trail); ongoing sweep `IDCardService.SyncPrintedRequests()` wired into `OmniPassHelper.BatchSync`.

**Locked decisions:** (1) final status **PRINTED** (not READY) — trail stops at PRINTED, `ready_at`/`collection_point` stay NULL; (2) `finance_ok` **NULL** (don't assert finance); (3) **backfill the 257 no-photo too** (photo_ref blank); (4) **one-time now + wire ongoing** — future newly-PRINTED students auto-get a PRINTED request. Event trail = 5 steps: `NULL→REQUESTED→FINANCE_CHECK→SUBMITTED→APPROVED→PRINTED`. No emails fire (direct insert, no funnel/notify). Timeline cols (`submitted_at`/`approved_at`/`printed_at`) = `id_card_checked_at`.

## 1. Analysis (live, campus_dynamics, 2026-07-16)

- Source of truth: `acad_student.id_card_status` (values `PRINTED | NOT_PRINTED | NOT_FOUND | ERROR | null`), populated by the OmniPass read-only sync (`OmniPassHelper` → `omnipass.mru.ac.ug`), plus `id_card_checked_at`.
- **PRINTED = 2,486 students.** All `stud_status = ACTIVE`. **0** already have an `idcard_requests` row → 2,486 to create.
- Data quality among the 2,486: 0 blank regno, 0 null `checked_at`, **257 with no photo on file** (card physically printed regardless).
- Sequence: max 2026 request no = `IDR-2026-000003`; backfill starts `IDR-2026-000004`. Table is InnoDB (transaction-safe).
- Staff are out of scope (OmniPass status lives on `acad_student`; `hrm_employee` has no OmniPass status).

## 2. What each backfilled request will look like

One row in `idcard_requests` per PRINTED student, mirroring exactly what the funnel would have produced:

| Column | Value |
|---|---|
| `request_no` | `IDR-2026-NNNNNN` (sequential from 000004) |
| `requester_type` | `STUDENT` |
| `regno` | student's regno |
| `card_type` | `NEW` |
| `status` | **`READY`** (final — see §6 decision 1) |
| `photo_ref` | `photofile` (blank for the 257 without one) |
| `photo_confirmed`, `guidelines_ack` | 1, 1 |
| `finance_ok` | 1 (has a printed card ⇒ treated as cleared — see §6.2) |
| `finance_snapshot_json` | `{"source":"OMNIPASS_BACKFILL"}` marker |
| `collection_point` | default text (see §6.5) |
| `window_id` | NULL |
| `created_by` | `OMNIPASS-BACKFILL` (tag → fully reversible) |
| `submitted_at / approved_at / printed_at / ready_at` | `id_card_checked_at` (realistic print time); `created_at`/`updated_at` = now |

Plus the full **event trail** in `idcard_request_events` (one row per transition), so the timeline reads as a real walk:
`NULL→REQUESTED → FINANCE_CHECK → SUBMITTED → APPROVED → PRINTED → READY` — actor `OMNIPASS-BACKFILL`, role `system`, channel `backfill`, note "Backfilled from OmniPass PRINTED status". ≈ 2,486 × 6 ≈ **~15k event rows**.

## 3. Method

Idempotent SQL script `COOPERP/sql/idcard_backfill_omnipass_printed.sql`, run inside a transaction:
1. `SET @n :=` current max 2026 sequence.
2. `INSERT ... SELECT` request rows for `id_card_status='PRINTED'` **AND NOT EXISTS** a request for that regno (dedupe), generating `request_no` via `@n := @n + 1`.
3. `INSERT ... SELECT` the 6 event rows for every request tagged `created_by='OMNIPASS-BACKFILL'` that has **no events yet** (dedupe).
Re-runnable safely: existing requests/events are skipped.

## 4. Verification (before COMMIT)

- Dry-run counts (rows to be created) match 2,486.
- Spot-check 3 students: request at READY + 6-row ordered event trail + timeline columns populated.
- Confirm eadmin queue (`status=READY`) and stats reflect the new volume; confirm one student's eportal tracker shows "ready for collection".
- Confirm the one-active guard now blocks a duplicate request for a backfilled student.

## 5. Reversibility

Every artifact is tagged: `idcard_requests.created_by='OMNIPASS-BACKFILL'` and `idcard_request_events.channel='backfill'` (12-char column). A single scoped `DELETE` (events first, then requests) fully reverts the run.

## 6. Decisions to confirm

1. **Final status** — `READY` (student sees "ready for collection" — recommended) vs `PRINTED` (printed but not yet marked at the collection desk).
2. **finance_ok = 1** — treat a printed card as finance-cleared? (They physically have a card.) Alternative: leave NULL.
3. **The 257 with no photo** — still backfill them (recommended; the card exists)? Or skip until a photo is on file?
4. **One-time vs repeatable** — just backfill the current 2,486 now, or also wire the OmniPass sync so future newly-PRINTED students auto-get a READY request going forward?
5. **collection_point** text (default: `ID Card Office, Admin Block`).
