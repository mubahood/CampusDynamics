# Fee Structure Audit & Correction Report
**Date:** 2026-05-18  
**Source file:** `COOPERP/ORIGINAL-FEE-STRUCTURE.xlsx`  
**Database:** `campus_dynamics_accounts` → table `fin_programme_fees`  
**Analyst:** Claude Code (automated cell-by-cell comparison)

---

## What the Excel Contains

The `ORIGINAL-FEE-STRUCTURE.xlsx` is the **authoritative master** for all programme fee figures. It has 136 programme data rows (rows 4–133) plus a legend section. The sheet layout is:

| Columns | Content |
|---------|---------|
| A | Programme name |
| B | Programme code (authoritative key) |
| C | Status (Active / Inactive) |
| D–K | Year 1: Sem1 Tuition, Sem1 Functional, Sem2 Tuition, Sem2 Functional, Sem3 Tuition, Sem3 Functional, Year Total, Has Year 1 |
| L–S | Year 2 (same structure) |
| T–AA | Year 3 (same structure) |
| AB–AI | Year 4 (same structure) |
| AJ | Grand Total |
| AK | Notes |
| AL | **Import Instruction** — contains the action code (key field) |

### Action Codes in Import Instruction column

| Code | Meaning |
|------|---------|
| `[UPDATE]` | Figures have drift from legacy template; overwrite production |
| `[VERIFY]` | Figures should already match; confirm and overwrite if they differ |
| `[PRESERVE]` | No legacy template exists (certificates, postgrad); keep production as-is |
| `[SKIP]` | Default/template row — do not import |
| `[REVIEW]` | Manual human review required before any change |

### HAS YEAR flags
- `✓` → `Yes` (year is active and has figures)
- `✗` → `No` (year does not apply)
- `—` → `No` (N/A — typically Year 4 for non-engineering programmes)

---

## Comparison Results (before corrections)

| Category | Count |
|----------|-------|
| Programmes matching Excel perfectly | 105 |
| Programmes with differences (corrected) | **22** |
| Excel rows not in DB (legend rows only) | 5 (legend text rows, not programmes) |
| REVIEW — flagged for human attention | 2 |
| SKIP — default template | 1 |

---

## Corrections Applied

All 22 corrections were applied to `fin_programme_fees` on **2026-05-18**.  
SQL script: `C:\Temp\fee_corrections.sql` (kept for audit trail).

### Engineering (BEE-BCE template) — Year 4 enabled + Y2S1_FUNC corrected

These are **4-year engineering programmes**. Their Year 4 was not yet enabled in the DB and one functional fee had drifted.

| Code | Programme | Changes |
|------|-----------|---------|
| **BCE** | Bachelor of Science in Civil Engineering | Y2S1_FUNC: 1,402,000 → **1,322,000**; has_year_4: No → **Yes**; Y4S1T: 0 → **1,455,000**; Y4S1F: 0 → **1,298,000**; Y4S2T: 0 → **1,455,000**; Y4S2F: 0 → **1,568,000** |
| **BEE** | Bachelor of Science in Electrical Engineering | Same as BCE, **plus** Y3S1_FUNC: 1,402,000 → **1,298,000** |
| **BCE3207** | Ghost code (Hydrology II course code mis-entered as programme) | Same as BCE |
| **BEE1101** | Ghost code (BSc EE course code) | Same as BCE |
| **DCS1101** | Ghost code (BSc EE course code) | Same as BCE |
| **ECB1101** | Ghost code (BSc EE course code) | Same as BCE |
| **EMB1101** | Ghost code (BSc EE course code) | Same as BCE |
| **SDB1101** | Ghost code (BSc EE course code) | Same as BCE |
| **SEB1101** | Ghost code (BSc EE course code) | Same as BCE |

> **Note on ghost codes** (BCE3207, BEE1101, DCS1101, ECB1101, EMB1101, SDB1101, SEB1101): These are course-unit codes that were mistakenly entered as programme codes in the EMIS. The Excel notes flag them as duplicates of BCE/BEE. Their fees were updated to match the BEE-BCE template since they exist as active records in the DB and may have enrolled students. Deactivation of these ghost records requires registrar confirmation — see REVIEW section.

---

### Business & Management (BBC template) — Y2S1_FUNC corrected

The BBC template Y2 Sem1 Functional was 767,000 in the DB; the correct figure is **687,000**.

| Code | Programme | Change |
|------|-----------|--------|
| **BBM** | Bachelor of Business Management | Y2S1_FUNC: 767,000 → **687,000** |
| **BCOM** | Bachelor of Commerce | Y2S1_FUNC: 767,000 → **687,000** |
| **BHRM** | Bachelor of Human Resource Management | Y2S1_FUNC: 767,000 → **687,000** |
| **BPA** | Bachelor of Public Administration | Y2S1_FUNC: 767,000 → **687,000** |
| **BSAF** | Bachelor of Science in Accounting & Finance | Y2S1_FUNC: 767,000 → **687,000** |
| **BSM** | Bachelor of Secretarial Management | Y2S1_FUNC: 767,000 → **687,000** |
| **BPLM** | Bachelor of Procurement & Logistics Management | Y2S1_FUNC: 767,000 → **687,000**; Y3S1_FUNC: 669,000 → **663,000**; Y3S2_FUNC: 939,000 → **933,000** |

---

### Media & Communication (BMC template) — Y2S1_FUNC corrected

| Code | Programme | Change |
|------|-----------|--------|
| **BPRM** | Bachelor of Public Relations Management | Y2S1_FUNC: 887,000 → **807,000** |
| **BMC** | Bachelor of Mass Communication | Y2S1_FUNC: 887,000 → **807,000** |

---

### Education — multiple functional fees corrected

| Code | Programme | Changes |
|------|-----------|---------|
| **BECD** | Bachelor of Education in Early Childhood Development | Y1S2_FUNC: 877,000 → **677,000**; Y2S2_FUNC: 933,000 → **853,000** |
| **BED(ECD)** | Bachelor of Education in Early Child Hood Development | Y2S2_FUNC: 264,000 → **154,000**; Y2S3_FUNC: 264,000 → **154,000**; Y3S2_FUNC: 344,000 → **154,000**; Y3S3_FUNC: 344,000 → **234,000** |
| **BVS** | Bachelor of Education Vocational Studies | Y3S2_FUNC: 1,151,250 → **951,250** |
| **DECD** | Diploma in Early Child Development | Y1S2_FUNC: 677,000 → **877,000** *(DB had the figure too low)* |

---

## Post-correction Verification

After applying all 22 corrections, a full re-comparison was run:

**127 programmes now match the Excel exactly. Zero remaining differences.**

---

## Items Requiring Human Review (NOT auto-applied)

These two programmes are flagged **[REVIEW]** in the Excel and were not touched.

### 1. HRP 1101
- **Code:** `HRP 1101` (contains a space — structured like a course code)
- **Programme name in DB:** BPA
- **Issue:** The code looks like a course reference (department letters + 4-digit number), not a programme code. The Excel notes suggest this may be a data-entry error where a course code was mis-entered as a programme code.
- **Fee figures:** Match BBC template (same as BPA/BBM etc.)
- **Action needed:** Registrar to confirm whether this is a legitimate standalone programme. If not, deactivate and route any enrolled students to the canonical programme (BPA or equivalent).

### 2. BSCEDU
- **Code:** `BSCEDU`
- **Programme name:** Bachelor of Science with Education
- **Issue:** Duplicate name — another programme `BSCED` has the same official name.
- **Action needed:** Registrar to confirm whether BSCEDU is a duplicate record. If yes, deactivate and migrate enrolments to BSCED.

---

## Programmes Not Changed (PRESERVE)

The following are **1-year certificates** or programmes with no legacy fee template. Their figures were verified to already be in the DB and were not touched:

CITE, CLIS, ACAD, ACBA, ACFD, ACGC, ACITE, ACJM, ACTE, CAD, and all other certificate/postgraduate programmes flagged `[PRESERVE]` in the Excel.

---

## Fee Structure Patterns (discovered)

The Excel reveals the university uses **fee templates** — groups of programmes share identical fee structures:

| Template | Programmes | Y1S1T | Y1S1F | Y2S1F | Notes |
|----------|-----------|-------|-------|-------|-------|
| **BEE-BCE** (Engineering 4yr) | BCE, BEE | 1,455,000 | 1,402,000 | 1,322,000 | Year 4 active |
| **BBC** (Business) | BBM, BCOM, BHRM, BPA, BPLM, BSAF, BSM | 630,000 | 767,000 | 687,000 | 3 years |
| **BMC** (Media/Comms) | BMC, BPRM | 780,000 | 887,000 | 807,000 | 3 years |
| **Certificate** | CITE, CLIS, ACAD, etc. | 400,000 | 430,000 | — | 1 year only |
| **DCS/DIT** (Diploma Eng) | DCS | 430,000 | 917,000 | 837,000 | 2 years |

---

## Important Observations

1. **DECD (lowercase in DB):** The programme code is stored as `decd` (lowercase) in the database while the Excel shows `DECD`. MySQL's default collation is case-insensitive so queries work, but the display in the fee structure screen may show lowercase. Consider normalising to uppercase.

2. **Year 4 now active for 9 records:** BCE, BEE, BCE3207, BEE1101, DCS1101, ECB1101, EMB1101, SDB1101, SEB1101 now have `has_year_4 = 'Yes'` with the following Year 4 figures:
   - Sem 1: Tuition 1,455,000 | Functional 1,298,000
   - Sem 2: Tuition 1,455,000 | Functional 1,568,000
   - Sem 3: (not applicable, 0)

3. **BPLM has unique Y3 figures** among the BBC-template programmes (Y3S1_FUNC=663,000; Y3S2_FUNC=933,000 vs the common 663,000/933,000 — actually these match now after correction).

4. **BED(ECD) is a distance/open programme** — its tuition figures (280,000) are significantly lower than standard degree programmes, and it has 3 semesters per year active across all 3 years. This is expected for in-service teacher education.

5. **The "ALL (Default Template)" row** (code `-`, Inactive) in the Excel is a seeding row for new programmes. It was correctly identified as `[SKIP]` and not touched.

---

## SQL Applied

```sql
-- 1. BCE
UPDATE fin_programme_fees SET
  y2_s1_functional = 1322000, has_year_4 = 'Yes',
  y4_s1_tuition = 1455000, y4_s1_functional = 1298000,
  y4_s2_tuition = 1455000, y4_s2_functional = 1568000,
  y4_s3_tuition = 0, y4_s3_functional = 0
WHERE progcode = 'BCE';

-- 2. BEE
UPDATE fin_programme_fees SET
  y2_s1_functional = 1322000, y3_s1_functional = 1298000, has_year_4 = 'Yes',
  y4_s1_tuition = 1455000, y4_s1_functional = 1298000,
  y4_s2_tuition = 1455000, y4_s2_functional = 1568000,
  y4_s3_tuition = 0, y4_s3_functional = 0
WHERE progcode = 'BEE';

-- 3–9. Ghost engineering codes (BCE3207, BEE1101, DCS1101, ECB1101, EMB1101, SDB1101, SEB1101)
--      Same as BCE above, applied to each code individually.

-- 10–16. BBC Business template — Y2S1_FUNC correction
UPDATE fin_programme_fees SET y2_s1_functional = 687000 WHERE progcode IN ('BBM','BCOM','BHRM','BPA','BSAF','BSM');
UPDATE fin_programme_fees SET y2_s1_functional = 687000, y3_s1_functional = 663000, y3_s2_functional = 933000 WHERE progcode = 'BPLM';

-- 17–18. BMC Media template — Y2S1_FUNC correction
UPDATE fin_programme_fees SET y2_s1_functional = 807000 WHERE progcode IN ('BPRM','BMC');

-- 19. BECD Education
UPDATE fin_programme_fees SET y1_s2_functional = 677000, y2_s2_functional = 853000 WHERE progcode = 'BECD';

-- 20. BED(ECD) Education distance
UPDATE fin_programme_fees SET
  y2_s2_functional = 154000, y2_s3_functional = 154000,
  y3_s2_functional = 154000, y3_s3_functional = 234000
WHERE progcode = 'BED(ECD)';

-- 21. BVS Education vocational
UPDATE fin_programme_fees SET y3_s2_functional = 951250 WHERE progcode = 'BVS';

-- 22. DECD Diploma ECD
UPDATE fin_programme_fees SET y1_s2_functional = 877000 WHERE progcode = 'DECD';
```

---

*Reference document generated by automated audit. Cross-reference with `ORIGINAL-FEE-STRUCTURE.xlsx` for any disputes.*
