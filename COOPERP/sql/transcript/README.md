# Transcript per-block academic-year fix (deployed 2026-07-01, DB `campus_dynamics`)

## Symptom
On a printed transcript, the academic year on top of a semester block was wrong for some
blocks, e.g. **"Year 3 — Semester 2 | Academic Year 2019/2020"** instead of **2018/2019**.

## Root cause
`acad_CreateTranscript` (the transcript-data builder, called by
`App_Code/AcademicDocuments/AcademicDocumentPdfService.cs` for
`NewStudentInfo.aspx?action=GenerateAcademicDocument&documentType=Transcript`, and by the
Registry transcript centre) does two things:
1. Copies each course's `acad` (academic year) straight from `acad_results` — which for a
   course is the year it was actually taken/retaken.
2. **Re-maps** each course's `studyyear`/`semester` to its position in the curriculum
   (`acad_programmecourses`).

After step 2, a single (studyyear, semester) block can contain courses that were taken in
**different** academic years (deferred/late courses, retakes, or curriculum slotting), so the
block's displayed "Academic Year" became inconsistent / reflected the wrong course. This was
**not** limited to retakes — many affected blocks had zero retakes.

## Fix
`acad_CreateTranscript_fixed.sql` adds **one** statement after the curriculum re-map: it sets
each block's `acad` from the year the student was **registered** for that study-year+semester
(`acad_registration` — the authoritative "when was the student in Year N, Semester S").
Blocks with no matching registration keep their existing year as a fallback. Nothing else
changed. Note `MIN(acad)` of the block would be **wrong** (a stray earlier-taken course sitting
in a later curriculum slot), which is why registration — not the results' years — is used.

```sql
SOURCE acad_CreateTranscript_fixed.sql;
```

## Verified 2026-07-01
- `MRU1700200314`: Year 3 (all semesters) → **2019/2020** (Sem 2 was wrongly 2018/2019; Sem 1/3
  were mixed). Y1=2017/2018, Y2=2018/2019 unchanged. 51 courses + GPAs intact.
- `MRU1700200259`: Year 3 Sem 1/2 → **2019/2020** (was mixed 2019/2020 + 2020/2021).

`acad_transcript_results` is rebuilt per student on every print, so all students self-correct on
their next print — no bulk backfill needed.

## Not covered (separate paths, if the same symptom appears there)
- The **HTML** transcript `NewScreens/TranscriptPrint.aspx` reads `acad_results` directly (no
  curriculum re-map) and groups by the results' own studyyear/semester — different logic.
- The **batch graduands** SPs `acad_GetBatchStudentTranscript_Col1/Col2` read `acad_results`
  directly, not `acad_transcript_results`.

## THE authoritative fix — `acad_GetResultsAcademicYear` (added after deeper tracing)
The FinalTranscript PDF does **not** read the `acad` column for its per-semester header — the
report's Col1/Col2 sub-reports embed a stored-proc query on **`acad_GetSingleStudentTranscript_Col1/Col2`**,
which compute the block year via the function **`acad_GetResultsAcademicYear(reg, studyyear, semester)`**.
That function originally returned `MIN(acad)` from `acad_transcript_results` (wrong after the re-map).
`acad_GetResultsAcademicYear_fixed.sql` makes it **registration-authoritative** (MIN(acad_year) from
`acad_registration` for that study-year+semester; falls back to the old MIN only when there's no
registration). This is the real, robust fix: verified it returns the right year even with
`acad_transcript_results` emptied. The **same `FinalTranscript` report is used for both Single and
Batch transcripts**, so both are covered; the legacy `acad_GetBatchStudentTranscript_Col1/Col2` SPs are
NOT wired to the report's course columns and were intentionally left untouched.

```sql
SOURCE acad_GetResultsAcademicYear_fixed.sql;   -- the authoritative fix
SOURCE acad_CreateTranscript_fixed.sql;         -- keeps stored acad + completion date consistent
```
Everything is one rule now (registration MIN per study-year+semester): the PDF header, the stored
`acad_transcript_results.acad`, the completion date, and the HTML transcript.

## Related transcript changes (same round, 2026-07-01)
Applied for consistency + the follow-up requests (all in code — need a redeploy; the SP is live):
- **HTML transcript** `NewScreens/TranscriptPrint.aspx.cs` — per-block academic year now also comes
  from `acad_registration` (same rule as the PDF), via a correlated subquery.
- **Completion date** `App_Code/AcademicDocuments/AcademicDocumentPdfService.cs` — after
  `acad_CreateTranscript`, `acad_graduands.comp_date` is set to **December of the ending year of the
  FINAL semester's academic year** (highest study-year/semester block), so the transcript's
  "Completion Date" is always the last month of the final academic year and consistent with the
  transcript's own final year. E.g. final block 2019/2020 → `comp_date = 2020-12-31` →
  "December, 2020" (bound via `acad_GetSingleStudentTranscriptData.formated_comp_date`).
- **DevExpress `FinalTranscript` fonts (long text)** — thesis/research-title value 10F→9F
  (`FinalTranscript.cs`); course-name cells 8.5F→8F (`FinalTranscriptCol1.cs` + `Col2.cs`). Pure
  font changes (no layout coordinates touched). Bottom-section spacing was intentionally left for a
  visual pass on a rendered PDF (blind coordinate edits risk breaking the professional layout).

## Rollback
```sql
SOURCE acad_CreateTranscript_ORIGINAL.sql;
```
(The C# / report changes revert via git.)
