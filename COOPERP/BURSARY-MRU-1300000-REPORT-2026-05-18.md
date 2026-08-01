# Bursary: MRU — 1,300,000 Analysis Report
**Date:** 2026-05-18  
**Analyst:** Claude Code (full database audit)  
**Query scope:** `campus_dynamics_accounts.fin_studentfeestracking` + `scholarshipstudents` + `campus_dynamics.acad_student`

---

## 1. What Is This Bursary?

The "Bursary: MRU" is the **Muteesa I Royal University institutional bursary scheme** — the university's own internal bursary, separate from external funders (KEF, SAZZA, District, etc.).

### Scheme Record (scholarships table)

| Field | Value |
|-------|-------|
| scholarshipID | 7 |
| scholarshipName | MRU |
| scholarshipdetails | Muteesa University Bursary |
| scheme_type | FIXED |
| scheme_value | 315,000 |
| status | **Inactive** |

> ⚠️ **Critical discrepancy:** The scheme is currently recorded as `Inactive` with a scheme_value of **315,000** — yet every single one of the 120 bursary entries awarded to students carries the amount **1,300,000**. This means the scheme was either reconfigured after the disbursements were made, or all amounts were manually entered/migrated at a different rate. The 1,300,000 amount does **not** match the current scheme configuration.

### How It Appears in the Student Ledger

The entry appears in the system's `fin_studentfeestracking` table (type = `Payment`, post_status = `Posted`) as:

```
detail   : Bursary: MRU
amount   : 1,300,000
trans_type: Payment
```

This is what renders in the student's ledger view as `Bursary: MRU  -  1,300,000`.

Unlike other bursaries (MRU VC 50%, KEF, SAZZA) which are posted directly to `fin_ledger` as credit entries, the MRU bursary lives in `fin_studentfeestracking`. The records were **migrated from late bursary renewal** fee transactions.

---

## 2. Summary Statistics

| Metric | Value |
|--------|-------|
| Unique students | **104** |
| Total bursary entries | **120** |
| Amount per entry | **UGX 1,300,000 (fixed, no exceptions)** |
| Grand total disbursed | **UGX 156,000,000** |
| Post status | **100% Posted** |
| Scheme status | Inactive (scheme value currently 315,000) |

---

## 3. Disbursement Timeline

| Academic Year | Semester | Entries | Unique Students | Total (UGX) |
|---------------|----------|---------|-----------------|-------------|
| 2022/2023 | 2 | 1 | 1 | 1,300,000 |
| 2023/2024 | 1 | 3 | 3 | 3,900,000 |
| 2023/2024 | 2 | 1 | 1 | 1,300,000 |
| 2024/2025 | 1 | 10 | 10 | 13,000,000 |
| 2024/2025 | 2 | 43 | 43 | 55,900,000 |
| 2025/2026 | 1 | 62 | 62 | 80,600,000 |
| **TOTAL** | | **120** | **104*** | **156,000,000** |

> *16 students appear in more than one semester, so unique students < total entries.

**Observation:** The bursary was negligible before 2024/2025. It exploded in Sem 2 2024/2025 (43 entries) and continued accelerating into Sem 1 2025/2026 (62 entries). This is not a gradual ramp — it's a bulk migration/retroactive application pattern.

---

## 4. Programme Breakdown

| Programme | Code | Students | Entries | Total (UGX) |
|-----------|------|----------|---------|-------------|
| Bachelor of Information Technology | BIT | 17 | 20 | 26,000,000 |
| Bachelor of Science in Accounting & Finance | BSAF | 14 | 17 | 22,100,000 |
| Bachelor of Arts with Education | BAED | 14 | 14 | 18,200,000 |
| Bachelor of Business Administration | BBA | 14 | 14 | 18,200,000 |
| Bachelor of Education with ICT | BEICT | 11 | 13 | 16,900,000 |
| Bachelor of Mass Communication | BMC | 8 | 9 | 11,700,000 |
| Bachelor of Social Work & Social Administration | SWSA | 5 | 5 | 6,500,000 |
| Bachelor of Public Administration | BPA | 3 | 5 | 6,500,000 |
| Bachelor of Tourism & Hotel Management | BTHM | 3 | 5 | 6,500,000 |
| Bachelor of Science in Electrical Engineering | BEE | 3 | 4 | 5,200,000 |
| Bachelor of Education in Early Childhood Dev. | BECD | 2 | 3 | 3,900,000 |
| Diploma in Information Technology | DIT | 2 | 3 | 3,900,000 |
| Bachelor of Procurement & Logistics Mgt | BPLM | 2 | 2 | 2,600,000 |
| Diploma in Accounting & Finance | DAF | 2 | 2 | 2,600,000 |
| Bachelor of Commerce | BCOM | 1 | 1 | 1,300,000 |
| Bachelor of Education Vocational Studies | BVS | 1 | 1 | 1,300,000 |
| Diploma in Art & Design | DAD | 1 | 1 | 1,300,000 |
| Bachelor of Science in Civil Engineering | BCE | 1 | 1 | 1,300,000 |
| **TOTAL** | | **104** | **120** | **156,000,000** |

---

## 5. Gender Breakdown

| Gender | Students | Entries |
|--------|----------|---------|
| FEMALE | 61 | 69 |
| MALE | 43 | 51 |
| **Total** | **104** | **120** |

---

## 6. Students Who Received Bursary in Multiple Semesters

14 students received the 1,300,000 MRU bursary in more than one semester.

| Reg. No. | Name | Programme | Semesters | Count | Total (UGX) |
|----------|------|-----------|-----------|-------|-------------|
| MRU2023001145 | CHARLES LWANGA | BIT | Sem1/2024/25 \| Sem2/2024/25 \| Sem1/2025/26 | **3** | **3,900,000** |
| MRU2023001394 | RUTH KYASIIMIRE | BTHM | Sem1/2024/25 \| Sem2/2024/25 \| Sem1/2025/26 | **3** | **3,900,000** |
| MRU2023000254 | SAMUEL JAMES LUBWAMA | BSAF | Sem1/2023/24 \| Sem1/2025/26 | 2 | 2,600,000 |
| MRU2023000904 | HENRY KITANDWE | BEE | Sem2/2024/25 \| Sem1/2025/26 | 2 | 2,600,000 |
| MRU2023000995 | Alex MWESIGWA | BEICT | Sem1/2024/25 \| Sem1/2025/26 | 2 | 2,600,000 |
| MRU2023001119 | Hellen NABWATO | BECD | Sem2/2024/25 \| Sem1/2025/26 | 2 | 2,600,000 |
| MRU2023001168 | Pavin MUKISA | BMC | Sem2/2024/25 \| Sem1/2025/26 | 2 | 2,600,000 |
| MRU2023001421 | SALIMU ISABIRYE | BEICT | Sem2/2024/25 \| Sem1/2025/26 | 2 | 2,600,000 |
| MRU2024000575 | SARAH NAZZIWA | BSAF | Sem2/2024/25 \| Sem1/2025/26 | 2 | 2,600,000 |
| MRU2024000730 | WATSON SSEGANE | BPA | Sem2/2024/25 \| Sem1/2025/26 | 2 | 2,600,000 |
| MRU2024001386 | JOAN NABATAMBALA | BSAF | Sem2/2024/25 \| Sem1/2025/26 | 2 | 2,600,000 |
| MRU2024001490 | COLLIN SSEKINYIKO | DIT | Sem2/2024/25 \| Sem1/2025/26 | 2 | 2,600,000 |
| MRU2024001528 | SYLIVIA NINSIIMA | BPA | Sem2/2024/25 \| Sem1/2025/26 | 2 | 2,600,000 |
| MRU2024001899 | JOY AFAAYO BABIRYE | BIT | Sem2/2024/25 \| Sem1/2025/26 | 2 | 2,600,000 |

---

## 7. Complete Student List (All 104 Beneficiaries)

Sorted by programme code, then registration number.

| # | Reg. No. | Name | Gender | Code | Semesters Received | Total (UGX) |
|---|----------|------|--------|------|--------------------|-------------|
| 1 | MRU2023000105 | Nelson SSENDEGEYA | M | BAED | Sem1/2025/26 | 1,300,000 |
| 2 | MRU2023000464 | Saudah NALWERE | F | BAED | Sem2/2024/25 | 1,300,000 |
| 3 | MRU2023000598 | Winnie NASSAKA | F | BAED | Sem1/2025/26 | 1,300,000 |
| 4 | MRU2023000722 | MAUREEN NAJJUMA | F | BAED | Sem2/2024/25 | 1,300,000 |
| 5 | MRU2023000786 | David Wasswa SSENTAMU | M | BAED | Sem1/2025/26 | 1,300,000 |
| 6 | MRU2023000931 | Teddy NAKATO | M | BAED | Sem1/2025/26 | 1,300,000 |
| 7 | MRU2024000151 | BITIJJUMA BABIRYE | F | BAED | Sem1/2025/26 | 1,300,000 |
| 8 | MRU2024001176 | PATRICIA NALUYIMA MIREMBE | F | BAED | Sem1/2025/26 | 1,300,000 |
| 9 | MRU2024001244 | MARIAM NAKAWOOYA | F | BAED | Sem1/2025/26 | 1,300,000 |
| 10 | MRU2024001469 | JOANITAH WANYANA | F | BAED | Sem1/2025/26 | 1,300,000 |
| 11 | MRU2024001559 | Josephine NAKIBONEKA | F | BAED | Sem1/2025/26 | 1,300,000 |
| 12 | MRU2024001585 | JUSTUS BYARUHANGA | M | BAED | Sem2/2024/25 | 1,300,000 |
| 13 | MRU2024002022 | MELISHA BABIRYE | F | BAED | Sem2/2024/25 | 1,300,000 |
| 14 | MRU2025002712 | BRIAN SSEKIZIVU | M | BAED | Sem1/2025/26 | 1,300,000 |
| 15 | MRU2021000084 | LILIAN NABAYIKI | F | BBA | Sem1/2023/24 | 1,300,000 |
| 16 | MRU2022000552 | AKATALIKAWE ATEGEKA JACOB | M | BBA | Sem2/2023/24 | 1,300,000 |
| 17 | MRU2022000644 | JOSEPH BUULE | M | BBA | Sem1/2024/25 | 1,300,000 |
| 18 | MRU2022000704 | Nuruh NAKKAZI | F | BBA | Sem2/2024/25 | 1,300,000 |
| 19 | MRU2023000082 | Magidu Abdul KILENZI | M | BBA | Sem2/2024/25 | 1,300,000 |
| 20 | MRU2023000258 | Martin YAAWE | M | BBA | Sem1/2025/26 | 1,300,000 |
| 21 | MRU2023001002 | Robert Kelly SSENFUMA | M | BBA | Sem1/2024/25 | 1,300,000 |
| 22 | MRU2024000295 | TEOPISTA NAGGAYI | F | BBA | Sem1/2025/26 | 1,300,000 |
| 23 | MRU2024000574 | ANDREW KWANZA NSUBUGA | M | BBA | Sem1/2025/26 | 1,300,000 |
| 24 | MRU2024000591 | NORAH IRIBOT | F | BBA | Sem2/2024/25 | 1,300,000 |
| 25 | MRU2024001173 | MIKE MATOVU | M | BBA | Sem2/2024/25 | 1,300,000 |
| 26 | MRU2024001339 | SHERINA NABUYUNGO | F | BBA | Sem1/2025/26 | 1,300,000 |
| 27 | MRU2024001541 | RACHEAL NAKIMERA | F | BBA | Sem1/2025/26 | 1,300,000 |
| 28 | MRU2024001551 | FLAVIA NALUBIRI | F | BBA | Sem1/2025/26 | 1,300,000 |
| 29 | MRU2022000947 | Susan NAKAZIBWE | F | BECD | Sem2/2024/25 | 1,300,000 |
| 30 | MRU2023001119 | Hellen NABWATO | F | BECD | Sem2/2024/25 \| Sem1/2025/26 | **2,600,000** |
| 31 | MRU2023000027 | Restetuta NANYONGA | F | BEICT | Sem2/2024/25 | 1,300,000 |
| 32 | MRU2023000081 | Miriam NANKOOMI | F | BEICT | Sem1/2024/25 | 1,300,000 |
| 33 | MRU2023000223 | Rebecca Ayebale NASSALI | F | BEICT | Sem1/2025/26 | 1,300,000 |
| 34 | MRU2023000995 | Alex MWESIGWA | M | BEICT | Sem1/2024/25 \| Sem1/2025/26 | **2,600,000** |
| 35 | MRU2023001421 | SALIMU ISABIRYE | M | BEICT | Sem2/2024/25 \| Sem1/2025/26 | **2,600,000** |
| 36 | MRU2024000747 | ASTONE LUBOWA | M | BEICT | Sem2/2024/25 | 1,300,000 |
| 37 | MRU2024000760 | UNIA NABBOWA | F | BEICT | Sem1/2025/26 | 1,300,000 |
| 38 | MRU2024000869 | Sumayya KATUMBA | F | BEICT | Sem2/2024/25 | 1,300,000 |
| 39 | MRU2024001115 | EDITH NALUGWA | F | BEICT | Sem1/2025/26 | 1,300,000 |
| 40 | MRU2024001398 | KENNEDY SSEMPEERA | M | BEICT | Sem2/2024/25 | 1,300,000 |
| 41 | MRU2024001494 | Catherine BAKANANSA | F | BEICT | Sem1/2025/26 | 1,300,000 |
| 42 | MRU2023000122 | IAN MICHEAL JOOGA | M | BIT | Sem1/2025/26 | 1,300,000 |
| 43 | MRU2023000177 | NALUBEGA JANNIPHER | F | BIT | Sem1/2025/26 | 1,300,000 |
| 44 | MRU2023000523 | ANGELA NASSUUNA NATASHA | F | BIT | Sem2/2024/25 | 1,300,000 |
| 45 | MRU2023000622 | JAMIRAH NABUKEERA | F | BIT | Sem1/2025/26 | 1,300,000 |
| 46 | MRU2023000629 | JONATHAN MWESIGWA | M | BIT | Sem1/2025/26 | 1,300,000 |
| 47 | MRU2023000689 | DEBORAH MBATUDDE | F | BIT | Sem1/2025/26 | 1,300,000 |
| 48 | MRU2023000691 | NAKIWALA WINNIE | F | BIT | Sem1/2025/26 | 1,300,000 |
| 49 | MRU2023000903 | ISAAC MIYINGO | M | BIT | Sem2/2024/25 | 1,300,000 |
| 50 | MRU2023001004 | Hawah NAYIGA | F | BIT | Sem1/2025/26 | 1,300,000 |
| 51 | MRU2023001145 | CHARLES LWANGA | M | BIT | Sem1/2024/25 \| Sem2/2024/25 \| Sem1/2025/26 | **3,900,000** |
| 52 | MRU2023001331 | NAKAWEESA JOSEPHINE | F | BIT | Sem1/2024/25 | 1,300,000 |
| 53 | MRU2024000566 | KEVIN KASUMBA | M | BIT | Sem2/2024/25 | 1,300,000 |
| 54 | MRU2024001117 | BASHIIRAH NAKAFEERO | F | BIT | Sem2/2024/25 | 1,300,000 |
| 55 | MRU2024001201 | TEDDY NAKANWAGI | F | BIT | Sem1/2025/26 | 1,300,000 |
| 56 | MRU2024001354 | MUHAMMAD MASIKO | M | BIT | Sem2/2024/25 | 1,300,000 |
| 57 | MRU2024001406 | ABRAHAM NJUBA NYANZI | M | BIT | Sem1/2025/26 | 1,300,000 |
| 58 | MRU2024001899 | JOY AFAAYO BABIRYE | F | BIT | Sem2/2024/25 \| Sem1/2025/26 | **2,600,000** |
| 59 | MRU2023000745 | Rose NAMIGGO | F | BMC | Sem1/2025/26 | 1,300,000 |
| 60 | MRU2023000982 | Rhodine MUGEMA | M | BMC | Sem2/2024/25 | 1,300,000 |
| 61 | MRU2023001168 | Pavin MUKISA | F | BMC | Sem2/2024/25 \| Sem1/2025/26 | **2,600,000** |
| 62 | MRU2023001428 | JOSEPH KAYE EZRA | M | BMC | Sem1/2025/26 | 1,300,000 |
| 63 | MRU2024000020 | PATRICIA NALUWU | F | BMC | Sem1/2025/26 | 1,300,000 |
| 64 | MRU2024000092 | GETRUDE NALWEYISO | F | BMC | Sem1/2025/26 | 1,300,000 |
| 65 | MRU2024000137 | LEILAH NABAWEESI | F | BMC | Sem1/2025/26 | 1,300,000 |
| 66 | MRU2024001371 | Janat NALULE | F | BMC | Sem1/2025/26 | 1,300,000 |
| 67 | MRU2022000677 | Esther NANNONO | F | BCOM | Sem2/2024/25 | 1,300,000 |
| 68 | MRU2022000845 | Juliet NABUKEERA | F | BPLM | Sem2/2024/25 | 1,300,000 |
| 69 | MRU2023000417 | Bashir WABBI | M | BPLM | Sem1/2023/24 | 1,300,000 |
| 70 | MRU2023000478 | ISAAC KALULE | M | BPA | Sem1/2024/25 | 1,300,000 |
| 71 | MRU2024000730 | WATSON SSEGANE | M | BPA | Sem2/2024/25 \| Sem1/2025/26 | **2,600,000** |
| 72 | MRU2024001528 | SYLIVIA NINSIIMA | F | BPA | Sem2/2024/25 \| Sem1/2025/26 | **2,600,000** |
| 73 | MRU2022000582 | Diana Kisakye NAJINGO | F | BSAF | Sem2/2024/25 | 1,300,000 |
| 74 | MRU2022000940 | Reagan NIZEYIMANA | M | BSAF | Sem2/2022/23 | 1,300,000 |
| 75 | MRU2023000254 | SAMUEL JAMES LUBWAMA | M | BSAF | Sem1/2023/24 \| Sem1/2025/26 | **2,600,000** |
| 76 | MRU2023000365 | SAMUEL MIRACLE KIYAGA | M | BSAF | Sem1/2025/26 | 1,300,000 |
| 77 | MRU2023000823 | NASSOZI AGATHA | F | BSAF | Sem1/2024/25 | 1,300,000 |
| 78 | MRU2023001023 | YASIN KIKOMEKO | M | BSAF | Sem2/2024/25 | 1,300,000 |
| 79 | MRU2024000102 | BARBRA NAMULI | F | BSAF | Sem1/2025/26 | 1,300,000 |
| 80 | MRU2024000537 | SHUBELA TUSUBIRA NALUBEGA | F | BSAF | Sem2/2024/25 | 1,300,000 |
| 81 | MRU2024000575 | SARAH NAZZIWA | F | BSAF | Sem2/2024/25 \| Sem1/2025/26 | **2,600,000** |
| 82 | MRU2024001145 | DOREEN NAKACWA | F | BSAF | Sem1/2025/26 | 1,300,000 |
| 83 | MRU2024001300 | VANESSA S NABAGULANYI | F | BSAF | Sem2/2024/25 | 1,300,000 |
| 84 | MRU2024001386 | JOAN NABATAMBALA | F | BSAF | Sem2/2024/25 \| Sem1/2025/26 | **2,600,000** |
| 85 | MRU2024001729 | CREVIN NAMULINDWA | F | BSAF | Sem1/2025/26 | 1,300,000 |
| 86 | MRU2024002019 | TRACIE CLOWIE NALWANGA | F | BSAF | Sem1/2025/26 | 1,300,000 |
| 87 | MRU2023000776 | Andrew KAYIZZI | M | BCE | Sem1/2025/26 | 1,300,000 |
| 88 | MRU2023000904 | HENRY KITANDWE | M | BEE | Sem2/2024/25 \| Sem1/2025/26 | **2,600,000** |
| 89 | MRU2023001212 | Lawrence NDALIKE | M | BEE | Sem2/2024/25 | 1,300,000 |
| 90 | MRU2023001213 | ABDULAH NTUMWA | M | BEE | Sem2/2024/25 | 1,300,000 |
| 91 | MRU2022000713 | Bashir MUGAGGA | M | SWSA | Sem1/2024/25 | 1,300,000 |
| 92 | MRU2023000770 | VICENT YIGA | M | SWSA | Sem1/2025/26 | 1,300,000 |
| 93 | MRU2023000826 | DOREEN NANTEZA | F | SWSA | Sem2/2024/25 | 1,300,000 |
| 94 | MRU2023000877 | Ibrahim Mahmudah AISHA | F | SWSA | Sem2/2024/25 | 1,300,000 |
| 95 | MRU2024001400 | GERALD MAVUMIRIZI | M | SWSA | Sem1/2025/26 | 1,300,000 |
| 96 | MRU2023000156 | NANSUBUGA AIDAH | F | BTHM | Sem1/2025/26 | 1,300,000 |
| 97 | MRU2023001049 | SSERWANGA .B KKAMBWE LUCAS | M | BTHM | Sem1/2025/26 | 1,300,000 |
| 98 | MRU2023001394 | RUTH KYASIIMIRE | F | BTHM | Sem1/2024/25 \| Sem2/2024/25 \| Sem1/2025/26 | **3,900,000** |
| 99 | MRU2023000021 | Halimah NASSOZI | F | DAF | Sem2/2024/25 | 1,300,000 |
| 100 | MRU2024001766 | JACINTA MARGARET RUKUNDO | F | DAF | Sem1/2025/26 | 1,300,000 |
| 101 | MRU2023000961 | EDWARD SSEBIINA | M | DAD | Sem2/2024/25 | 1,300,000 |
| 102 | MRU2024001490 | COLLIN SSEKINYIKO | M | DIT | Sem2/2024/25 \| Sem1/2025/26 | **2,600,000** |
| 103 | MRU2024001495 | EMMANUEL ALORO | M | DIT | Sem1/2025/26 | 1,300,000 |
| 104 | MRU2025002872 | ETHRO NAKAYENGA MPOLOGOMA | F | BVS | Sem1/2025/26 | 1,300,000 |

---

## 8. Key Findings & Flags

### 8.1 Amount vs Scheme Configuration Mismatch
The `scholarships` table records the MRU scheme with `scheme_value = 315,000` and `status = Inactive`. Every single disbursement is **1,300,000** — more than **4× the recorded scheme value**. This warrants investigation: Was the scheme value changed after disbursements? Were amounts entered manually? Who authorised 1,300,000 per student?

### 8.2 Scheme Is Inactive But Still Referenced
The scheme is currently flagged as `Inactive`, yet 62 entries are posted to Sem 1 2025/2026 (the most recent semester). If Inactive means "no longer accepting new students," those Sem 1 2025/2026 entries should be reviewed.

### 8.3 Migration Origin
All `scholarshipstudents` records carry the note: *"Migrated from Late Bursary renewal (TID:XXXXX)"*. The bursaries were not created through the normal bursary disbursement workflow — they were bulk-migrated from a legacy tracking mechanism. The original TID references in those notes do **not** point to bursary transactions; they point to regular billing entries (tuition/functional fee bills) for unrelated students.

### 8.4 No Direct Ledger Posting
Unlike other bursaries (`Bursary: MRU VC 50%`, `Bursary: KEF 50%`, etc.) which produce a **CR entry in `fin_ledger`** under the student's account, the MRU 1,300,000 bursary exists only in `fin_studentfeestracking` as a `Payment` type entry. There is no corresponding debit on the university's bursary/subsidy account in the double-entry ledger. This could mean:
- The student's balance appears reduced in the tracking view but is **not matched by a posted GL journal**
- A reconciliation gap may exist between what students see and what the accounts department sees

### 8.5 Top Recipients by Total Amount

| Student | Total Received | Semesters |
|---------|---------------|-----------|
| CHARLES LWANGA (MRU2023001145) | 3,900,000 | 3 semesters |
| RUTH KYASIIMIRE (MRU2023001394) | 3,900,000 | 3 semesters |
| 12 other students | 2,600,000 each | 2 semesters each |

### 8.6 Spread Across All Faculties
The bursary is not limited to one faculty or one level. It spans 18 different programmes — from engineering (BCE, BEE) to arts, education, business, diplomas. This is consistent with a general university-wide institutional bursary, not a faculty-specific one.

---

## 9. Data Sources

| Table | Database | Role |
|-------|----------|------|
| `fin_studentfeestracking` | campus_dynamics_accounts | **Primary source** — 120 `Bursary: MRU` entries |
| `scholarshipstudents` | campus_dynamics_accounts | Secondary — 121 migration records (some overlap) |
| `scholarships` | campus_dynamics_accounts | Scheme definition (MRU, ID=7) |
| `acad_student` | campus_dynamics | Student name, gender, programme |
| `acad_programme` | campus_dynamics | Programme names |

---

*Full data extracted 2026-05-18. Cross-reference with `BURSARY-MRU-1300000-REPORT-2026-05-18.md` for any disputes.*
