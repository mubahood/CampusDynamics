# Re-billing Transactions — Deletion Review

**Source:** `fin_ledger` entries with description `Re-billing (registered student; erroneous fee reversal cancelled): …` (teller `REBILLFIX`, posted 2026-07-10).

These are the fixer's re-billing debits, in Tuition + Functional **pairs** (a few students have two pairs = two semesters).

## ✅ EXECUTED — 2026-08-01

Every one of these re-billings was for an academic year **before 2026/2027** (2023/24, 2024/25, 2025/26) — **none were 2026/2027** — so per instruction (delete anything not billed for 2026) **all 89 were deleted.**

- **Students affected:** 44
- **Transactions deleted:** 89 (all DR / debits) — UGX **63,823,400** of erroneous re-billing removed
- **Backup:** every row saved in `campus_dynamics_accounts.fin_ledger_rebilldel_bak` (restore = `INSERT … SELECT` back) — fully reversible
- **Balances recomputed:** all 44 students' running ledger balances rebuilt via `fin_UpdateLedgerBalances`; each student's stored balance now matches the independent DR−CR sum exactly
- **Verified:** 0 re-billing rows remain live; ledger-only (no `fin_studentfeestracking` mirror existed)

The per-student breakdown below is kept as the record of exactly what was removed.

---

### 1. COSTANTINA NAKALEMBE  
**Reg No:** MRU2023000196  •  **Date:** 2026-07-10  •  **Balance at first entry:** 1,936,000CR  

| TID | Amount (UGX) | Fee re-billed |
|---|---:|---|
| 284379 | 630,000 | Tuition Fees for Semester:2, 2024/2025 - reason -double bill |
| 284380 | 659,000 | Function Fees for Semester:2, 2024/2025 - reason -double bill |

  - **Delete these transactions?** [x] — ✅ DELETED (backed up, balance recomputed)

### 2. Andrew SSEREMBA  
**Reg No:** MRU2023000396  •  **Date:** 2026-07-10  •  **Balance at first entry:** 420,000DR  

| TID | Amount (UGX) | Fee re-billed |
|---|---:|---|
| 284415 | 630,000 | Tuition Fees for Semester:2, 2025/2026 AUTO reason -wrong semester |
| 284416 | 933,000 | Function Fees for Semester:2, 2025/2026 AUTO reason -wrong semester |

  - **Delete these transactions?** [x] — ✅ DELETED (backed up, balance recomputed)

### 3. Peter Matovu MUYOMBA  
**Reg No:** MRU2023000876  •  **Date:** 2026-07-10  •  **Balance at first entry:** 780,000DR  

| TID | Amount (UGX) | Fee re-billed |
|---|---:|---|
| 284399 | 780,000 | Tuition Fees for Semester:1, 2024/2025 - reason -wrong semester |
| 284400 | 783,000 | Function Fees for Semester:1, 2024/2025 - reason -wrong semester |
| 284401 | 780,000 | Tuition Fees for Semester:2, 2024/2025 - reason -wrong semester |
| 284402 | 1,053,000 | Function Fees for Semester:2, 2024/2025 - reason -wrong semester |

  - **Delete these transactions?** [x] — ✅ DELETED (backed up, balance recomputed)

### 4. Lutwama Daniel KYAGERA  
**Reg No:** MRU2023001124  •  **Date:** 2026-07-10  •  **Balance at first entry:** 2,229,000CR  

| TID | Amount (UGX) | Fee re-billed |
|---|---:|---|
| 284403 | 683,000 | Function Fees for Semester:2, 2023/2024 - reason -wrong semester |
| 284404 | 630,000 | Tuition Fees for Semester:2, 2023/2024 - reason -wrong semester |

  - **Delete these transactions?** [x] — ✅ DELETED (backed up, balance recomputed)

### 5. ABDULAH NTUMWA  
**Reg No:** MRU2023001213  •  **Date:** 2026-07-10  •  **Balance at first entry:** 4,805,000CR  

| TID | Amount (UGX) | Fee re-billed |
|---|---:|---|
| 284441 | 1,455,000 | Tuition Fees for Semester:2, 2025/2026 - reason -wrong billing |

  - **Delete these transactions?** [x] — ✅ DELETED (backed up, balance recomputed)

### 6. IVAN KIMBUGWE  
**Reg No:** MRU2024000547  •  **Date:** 2026-07-10  •  **Balance at first entry:** 2,404,000CR  

| TID | Amount (UGX) | Fee re-billed |
|---|---:|---|
| 284395 | 630,000 | Tuition Fees for Semester:2, 2025/2026 - reason -Reversal |
| 284396 | 653,000 | Function Fees for Semester:2, 2025/2026 - reason -Reversal |

  - **Delete these transactions?** [x] — ✅ DELETED (backed up, balance recomputed)

### 7. UWAISU KASULE  
**Reg No:** MRU2024000594  •  **Date:** 2026-07-10  •  **Balance at first entry:** 641,000CR  

| TID | Amount (UGX) | Fee re-billed |
|---|---:|---|
| 284383 | 630,000 | Tuition Fees for Semester:1, 2024/2025 - reason -wrong billing |
| 284384 | 773,000 | Function Fees for Semester:1, 2024/2025 - reason -wrong billing |

  - **Delete these transactions?** [x] — ✅ DELETED (backed up, balance recomputed)

### 8. KEEFA TURYAGUMANAWE  
**Reg No:** MRU2024000761  •  **Date:** 2026-07-10  •  **Balance at first entry:** 3,847,000CR  

| TID | Amount (UGX) | Fee re-billed |
|---|---:|---|
| 284381 | 1,224,500 | Function Fees for Semester:2, 2025/2026 - reason -wrong semester registred |
| 284382 | 530,000 | Tuition Fees for Semester:2, 2025/2026 - reason -wrong semester registred |

  - **Delete these transactions?** [x] — ✅ DELETED (backed up, balance recomputed)

### 9. MATHIUS MUKISA  
**Reg No:** MRU2024000960  •  **Date:** 2026-07-10  •  **Balance at first entry:** 2,001,000CR  

| TID | Amount (UGX) | Fee re-billed |
|---|---:|---|
| 284393 | 683,000 | Function Fees for Semester:2, 2024/2025 reason -wrong semester |
| 284394 | 680,000 | Tuition Fees for Semester:2, 2024/2025 reason -wrong semester |

  - **Delete these transactions?** [x] — ✅ DELETED (backed up, balance recomputed)

### 10. JOHN MUGARURA  
**Reg No:** MRU2024001070  •  **Date:** 2026-07-10  •  **Balance at first entry:** 471,000CR  

| TID | Amount (UGX) | Fee re-billed |
|---|---:|---|
| 284397 | 683,000 | Function Fees for Semester:2, 2024/2025 - reason -NOT STUDIED |
| 284398 | 780,000 | Tuition Fees for Semester:2, 2024/2025 - reason -NOT STUDIED |

  - **Delete these transactions?** [x] — ✅ DELETED (backed up, balance recomputed)

### 11. PARDON KAGWISAGYE  
**Reg No:** MRU2024001135  •  **Date:** 2026-07-10  •  **Balance at first entry:** 1,565,700CR  

| TID | Amount (UGX) | Fee re-billed |
|---|---:|---|
| 284385 | 1,455,000 | Tuition Fees for Semester:2, 2025/2026 - reason -wrong semester |
| 284386 | 1,568,000 | Function Fees for Semester:2, 2025/2026 - reason -wrong semester |

  - **Delete these transactions?** [x] — ✅ DELETED (backed up, balance recomputed)

### 12. OWEN SSENYONJO  
**Reg No:** MRU2024001385  •  **Date:** 2026-07-10  •  **Balance at first entry:** 800,000CR  

| TID | Amount (UGX) | Fee re-billed |
|---|---:|---|
| 284375 | 680,000 | Tuition Fees for Semester:2, 2025/2026 - reason -wrong semester |
| 284376 | 853,000 | Function Fees for Semester:2, 2025/2026 - reason -wrong semester |

  - **Delete these transactions?** [x] — ✅ DELETED (backed up, balance recomputed)

### 13. HILDA AUO  
**Reg No:** MRU2024001565  •  **Date:** 2026-07-10  •  **Balance at first entry:** 1,474,800CR  

| TID | Amount (UGX) | Fee re-billed |
|---|---:|---|
| 284355 | 630,000 | Tuition Fees for Semester:2, 2025/2026 - reason -double billing |
| 284356 | 933,000 | Function Fees for Semester:2, 2025/2026 - reason -double billing |

  - **Delete these transactions?** [x] — ✅ DELETED (backed up, balance recomputed)

### 14. RICHARD OKURUT OMODING  
**Reg No:** MRU2024001732  •  **Date:** 2026-07-10  •  **Balance at first entry:** 2,104,000CR  

| TID | Amount (UGX) | Fee re-billed |
|---|---:|---|
| 284407 | 1,298,000 | Function Fees for Semester:1, 2025/2026 - reason -DEAD SEMESTER |
| 284408 | 1,455,000 | Tuition Fees for Semester:1, 2025/2026 - reason -DEAD SEMESTER |

  - **Delete these transactions?** [x] — ✅ DELETED (backed up, balance recomputed)

### 15. Dimitria NASSUUNA  
**Reg No:** MRU2024001925  •  **Date:** 2026-07-10  •  **Balance at first entry:** 220,300CR  

| TID | Amount (UGX) | Fee re-billed |
|---|---:|---|
| 284359 | 780,000 | Tuition Fees for Semester:1, 2025/2026 reason -wrong semester |
| 284360 | 953,700 | Function Fees for Semester:1, 2025/2026 reason -wrong semester |

  - **Delete these transactions?** [x] — ✅ DELETED (backed up, balance recomputed)

### 16. GETRUDE NALUBINGA  
**Reg No:** MRU2024002090  •  **Date:** 2026-07-10  •  **Balance at first entry:** 264,000CR  

| TID | Amount (UGX) | Fee re-billed |
|---|---:|---|
| 284439 | 230,000 | Tuition Fees for Semester:1, 2025/2026 reason -wrong semester |
| 284440 | 154,000 | Function Fees for Semester:1, 2025/2026 reason -wrong semester |

  - **Delete these transactions?** [x] — ✅ DELETED (backed up, balance recomputed)

### 17. Mellanie NANTALE  
**Reg No:** MRU2025002092  •  **Date:** 2026-07-10  •  **Balance at first entry:** 385,000CR  

| TID | Amount (UGX) | Fee re-billed |
|---|---:|---|
| 284373 | 400,000 | Tuition Fees for Semester:1, 2025/2026 - reason -wrong semester |
| 284374 | 430,000 | Function Fees for Semester:1, 2025/2026 - reason -wrong semester |

  - **Delete these transactions?** [x] — ✅ DELETED (backed up, balance recomputed)

### 18. DAVID SSERWANGA  
**Reg No:** MRU2025002130  •  **Date:** 2026-07-10  •  **Balance at first entry:** 680,000DR  

| TID | Amount (UGX) | Fee re-billed |
|---|---:|---|
| 284411 | 680,000 | Tuition Fees for Semester:1, 2025/2026 AUTO reason -dead semester |
| 284412 | 767,000 | Function Fees for Semester:1, 2025/2026 AUTO reason -dead semester |

  - **Delete these transactions?** [x] — ✅ DELETED (backed up, balance recomputed)

### 19. Immaculate Gift NAMIIRO  
**Reg No:** MRU2025002192  •  **Date:** 2026-07-10  •  **Balance at first entry:** 490,000DR  

| TID | Amount (UGX) | Fee re-billed |
|---|---:|---|
| 284369 | 400,000 | Tuition Fees for Semester:1, 2025/2026 - reason -wrong semester |
| 284370 | 430,000 | Function Fees for Semester:1, 2025/2026 - reason -wrong semester |

  - **Delete these transactions?** [x] — ✅ DELETED (backed up, balance recomputed)

### 20. MILLY BATOMA  
**Reg No:** MRU2025002203  •  **Date:** 2026-07-10  •  **Balance at first entry:** 515,300CR  

| TID | Amount (UGX) | Fee re-billed |
|---|---:|---|
| 284389 | 400,000 | Tuition Fees for Semester:1, 2025/2026 - reason -wrong semester |
| 284390 | 430,000 | Function Fees for Semester:1, 2025/2026 - reason -wrong semester |

  - **Delete these transactions?** [x] — ✅ DELETED (backed up, balance recomputed)

### 21. SHAROT NALUWAGA  
**Reg No:** MRU2025003010  •  **Date:** 2026-07-10  •  **Balance at first entry:** 400,000CR  

| TID | Amount (UGX) | Fee re-billed |
|---|---:|---|
| 284391 | 400,000 | Tuition Fees for Semester:1, 2025/2026 - reason -Double bill |
| 284392 | 430,000 | Function Fees for Semester:1, 2025/2026 - reason -Double bill |

  - **Delete these transactions?** [x] — ✅ DELETED (backed up, balance recomputed)

### 22. BRIDGET NAKIBUULE  
**Reg No:** MRU2025003039  •  **Date:** 2026-07-10  •  **Balance at first entry:** 380,000DR  

| TID | Amount (UGX) | Fee re-billed |
|---|---:|---|
| 284353 | 400,000 | Tuition Fees for Semester:2, 2025/2026 reason -double billing |
| 284354 | 365,000 | Function Fees for Semester:2, 2025/2026 reason -double billing |

  - **Delete these transactions?** [x] — ✅ DELETED (backed up, balance recomputed)

### 23. DAVID MAGALA  
**Reg No:** MRU2025003049  •  **Date:** 2026-07-10  •  **Balance at first entry:** 395,000CR  

| TID | Amount (UGX) | Fee re-billed |
|---|---:|---|
| 284357 | 400,000 | Tuition Fees for Semester:1, 2025/2026 - reason -wrong billing |
| 284358 | 430,000 | Function Fees for Semester:1, 2025/2026 - reason -wrong billing |

  - **Delete these transactions?** [x] — ✅ DELETED (backed up, balance recomputed)

### 24. JOSEPH MOURICE KAWEESI  
**Reg No:** MRU2025003054  •  **Date:** 2026-07-10  •  **Balance at first entry:** 355,000CR  

| TID | Amount (UGX) | Fee re-billed |
|---|---:|---|
| 284387 | 400,000 | Tuition Fees for Semester:1, 2025/2026 - reason -wrong semester |
| 284388 | 430,000 | Function Fees for Semester:1, 2025/2026 - reason -wrong semester |

  - **Delete these transactions?** [x] — ✅ DELETED (backed up, balance recomputed)

### 25. FAHIMA NAMATOVU  
**Reg No:** MRU2025003111  •  **Date:** 2026-07-10  •  **Balance at first entry:** 480,000CR  

| TID | Amount (UGX) | Fee re-billed |
|---|---:|---|
| 284351 | 400,000 | Tuition Fees for Semester:1, 2025/2026 - reason -Billing error |
| 284352 | 430,000 | Function Fees for Semester:1, 2025/2026 - reason -Billing error |

  - **Delete these transactions?** [x] — ✅ DELETED (backed up, balance recomputed)

### 26. RONALD SSERUNJOJI  
**Reg No:** MRU2025003179  •  **Date:** 2026-07-10  •  **Balance at first entry:** 1,402,000DR  

| TID | Amount (UGX) | Fee re-billed |
|---|---:|---|
| 284405 | 1,402,000 | Function Fees for Semester:1, 2025/2026 - reason -wrong semester |
| 284406 | 1,455,000 | Tuition Fees for Semester:1, 2025/2026 - reason -wrong semester |

  - **Delete these transactions?** [x] — ✅ DELETED (backed up, balance recomputed)

### 27. SHANITAH NANSUBUGA  
**Reg No:** MRU2025003305  •  **Date:** 2026-07-10  •  **Balance at first entry:** 400,000DR  

| TID | Amount (UGX) | Fee re-billed |
|---|---:|---|
| 284377 | 400,000 | Tuition Fees for Semester:1, 2025/2026 - reason -wrong semester |
| 284378 | 430,000 | Function Fees for Semester:1, 2025/2026 - reason -wrong semester |

  - **Delete these transactions?** [x] — ✅ DELETED (backed up, balance recomputed)

### 28. ISREAL HORTON NSEREKO  
**Reg No:** MRU2025003433  •  **Date:** 2026-07-10  •  **Balance at first entry:** 430,000CR  

| TID | Amount (UGX) | Fee re-billed |
|---|---:|---|
| 284361 | 400,000 | Tuition Fees for Semester:1, 2025/2026 - reason -wrong semester |
| 284362 | 430,000 | Function Fees for Semester:1, 2025/2026 - reason -wrong semester |

  - **Delete these transactions?** [x] — ✅ DELETED (backed up, balance recomputed)

### 29. RACHEAL LUCKY NAMYALO  
**Reg No:** MRU2025003454  •  **Date:** 2026-07-10  •  **Balance at first entry:** 450,000CR  

| TID | Amount (UGX) | Fee re-billed |
|---|---:|---|
| 284371 | 400,000 | Tuition Fees for Semester:1, 2025/2026 - reason -wrong semester |
| 284372 | 430,000 | Function Fees for Semester:1, 2025/2026 - reason -wrong semester |

  - **Delete these transactions?** [x] — ✅ DELETED (backed up, balance recomputed)

### 30. CEDRICK KIBALAMA  
**Reg No:** MRU2025003557  •  **Date:** 2026-07-10  •  **Balance at first entry:** 400,000DR  

| TID | Amount (UGX) | Fee re-billed |
|---|---:|---|
| 284367 | 400,000 | Tuition Fees for Semester:1, 2025/2026 - reason -wrong semester |
| 284368 | 430,000 | Function Fees for Semester:1, 2025/2026 - reason -wrong semester |

  - **Delete these transactions?** [x] — ✅ DELETED (backed up, balance recomputed)

### 31. Dorothy NAKIGUDDE  
**Reg No:** MRU2025003578  •  **Date:** 2026-07-10  •  **Balance at first entry:** 365,000CR  

| TID | Amount (UGX) | Fee re-billed |
|---|---:|---|
| 284365 | 400,000 | Tuition Fees for Semester:1, 2025/2026 - reason -wrong semester |
| 284366 | 430,000 | Function Fees for Semester:1, 2025/2026 - reason -wrong semester |

  - **Delete these transactions?** [x] — ✅ DELETED (backed up, balance recomputed)

### 32. SHARON ATIGO  
**Reg No:** MRU2025003579  •  **Date:** 2026-07-10  •  **Balance at first entry:** 400,000DR  

| TID | Amount (UGX) | Fee re-billed |
|---|---:|---|
| 284363 | 400,000 | Tuition Fees for Semester:1, 2025/2026 - reason -wrong semester |
| 284364 | 430,000 | Function Fees for Semester:1, 2025/2026 - reason -wrong semester |

  - **Delete these transactions?** [x] — ✅ DELETED (backed up, balance recomputed)

### 33. HADIJJAH NAMPOZA  
**Reg No:** MRU2025003885  •  **Date:** 2026-07-10  •  **Balance at first entry:** 461,000DR  

| TID | Amount (UGX) | Fee re-billed |
|---|---:|---|
| 284437 | 630,000 | Tuition Fees for Semester:1, 2025/2026 AUTO reason -wrong semester |
| 284438 | 767,000 | Function Fees for Semester:1, 2025/2026 AUTO reason -wrong semester |

  - **Delete these transactions?** [x] — ✅ DELETED (backed up, balance recomputed)

### 34. DEAZY NANYANZI  
**Reg No:** MRU2025003905  •  **Date:** 2026-07-10  •  **Balance at first entry:** 629,000DR  

| TID | Amount (UGX) | Fee re-billed |
|---|---:|---|
| 284429 | 630,000 | Tuition Fees for Semester:1, 2025/2026 AUTO reason -WRONG SEMESTER |
| 284430 | 767,000 | Function Fees for Semester:1, 2025/2026 AUTO reason -WRONG SEMESTER |

  - **Delete these transactions?** [x] — ✅ DELETED (backed up, balance recomputed)

### 35. PETER KIRIBAKI  
**Reg No:** MRU2025003913  •  **Date:** 2026-07-10  •  **Balance at first entry:** 680,000DR  

| TID | Amount (UGX) | Fee re-billed |
|---|---:|---|
| 284419 | 680,000 | Tuition Fees for Semester:1, 2025/2026 AUTO reason -wrong semester |
| 284420 | 767,000 | Function Fees for Semester:1, 2025/2026 AUTO reason -wrong semester |

  - **Delete these transactions?** [x] — ✅ DELETED (backed up, balance recomputed)

### 36. SARAH NANTEZA  
**Reg No:** MRU2025003917  •  **Date:** 2026-07-10  •  **Balance at first entry:** 630,000DR  

| TID | Amount (UGX) | Fee re-billed |
|---|---:|---|
| 284433 | 630,000 | Tuition Fees for Semester:1, 2025/2026 AUTO reason -wrong semester |
| 284434 | 767,000 | Function Fees for Semester:1, 2025/2026 AUTO reason -wrong semester |

  - **Delete these transactions?** [x] — ✅ DELETED (backed up, balance recomputed)

### 37. MUKASA BEN SSEKUBULWA  
**Reg No:** MRU2025003932  •  **Date:** 2026-07-10  •  **Balance at first entry:** 552,000CR  

| TID | Amount (UGX) | Fee re-billed |
|---|---:|---|
| 284423 | 1,455,000 | Tuition Fees for Semester:1, 2025/2026 AUTO reason -WRONG SEMESTER |
| 284424 | 1,402,000 | Function Fees for Semester:1, 2025/2026 AUTO reason -WRONG SEMESTER |

  - **Delete these transactions?** [x] — ✅ DELETED (backed up, balance recomputed)

### 38. EMILLY JOVIA NAKANDI  
**Reg No:** MRU2025004087  •  **Date:** 2026-07-10  •  **Balance at first entry:** 780,000DR  

| TID | Amount (UGX) | Fee re-billed |
|---|---:|---|
| 284435 | 780,000 | Tuition Fees for Semester:1, 2025/2026 AUTO reason -wrong semester |
| 284436 | 1,033,700 | Function Fees for Semester:1, 2025/2026 AUTO reason -wrong semester |

  - **Delete these transactions?** [x] — ✅ DELETED (backed up, balance recomputed)

### 39. FAHIMAH NAMULINDWA  
**Reg No:** MRU2025004105  •  **Date:** 2026-07-10  •  **Balance at first entry:** 680,000DR  

| TID | Amount (UGX) | Fee re-billed |
|---|---:|---|
| 284421 | 680,000 | Tuition Fees for Semester:1, 2025/2026 AUTO reason -WRONG SEMESTER |
| 284422 | 767,000 | Function Fees for Semester:1, 2025/2026 AUTO reason -WRONG SEMESTER |

  - **Delete these transactions?** [x] — ✅ DELETED (backed up, balance recomputed)

### 40. Yusuf WAMALA  
**Reg No:** MRU2025004143  •  **Date:** 2026-07-10  •  **Balance at first entry:** 202,000CR  

| TID | Amount (UGX) | Fee re-billed |
|---|---:|---|
| 284417 | 1,455,000 | Tuition Fees for Semester:1, 2025/2026 AUTO reason -wrong semester |
| 284418 | 1,402,000 | Function Fees for Semester:1, 2025/2026 AUTO reason -wrong semester |

  - **Delete these transactions?** [x] — ✅ DELETED (backed up, balance recomputed)

### 41. JASPER KIBADDE KAYE  
**Reg No:** MRU2025004148  •  **Date:** 2026-07-10  •  **Balance at first entry:** 597,000DR  

| TID | Amount (UGX) | Fee re-billed |
|---|---:|---|
| 284409 | 680,000 | Tuition Fees for Semester:1, 2025/2026 AUTO reason -wrong semester |
| 284410 | 767,000 | Function Fees for Semester:1, 2025/2026 AUTO reason -wrong semester |

  - **Delete these transactions?** [x] — ✅ DELETED (backed up, balance recomputed)

### 42. IMURAN SSEGAWA  
**Reg No:** MRU2025004154  •  **Date:** 2026-07-10  •  **Balance at first entry:** 1,056,000DR  

| TID | Amount (UGX) | Fee re-billed |
|---|---:|---|
| 284413 | 780,000 | Tuition Fees for Semester:1, 2025/2026 AUTO reason -wrong semester |
| 284414 | 867,000 | Function Fees for Semester:1, 2025/2026 AUTO reason -wrong semester |

  - **Delete these transactions?** [x] — ✅ DELETED (backed up, balance recomputed)

### 43. OLIVER NAMIYINGO  
**Reg No:** MRU2025004170  •  **Date:** 2026-07-10  •  **Balance at first entry:** 630,000DR  

| TID | Amount (UGX) | Fee re-billed |
|---|---:|---|
| 284427 | 630,000 | Tuition Fees for Semester:1, 2025/2026 AUTO reason -wrong semester |
| 284428 | 767,000 | Function Fees for Semester:1, 2025/2026 AUTO reason -wrong semester |

  - **Delete these transactions?** [x] — ✅ DELETED (backed up, balance recomputed)

### 44. ANDREW JUNIOR EKUSAI  
**Reg No:** MRU2025004176  •  **Date:** 2026-07-10  •  **Balance at first entry:** 690,000DR  

| TID | Amount (UGX) | Fee re-billed |
|---|---:|---|
| 284431 | 530,000 | Tuition Fees for Semester:1, 2025/2026 AUTO reason -wrong semester |
| 284432 | 1,058,500 | Function Fees for Semester:1, 2025/2026 AUTO reason -wrong semester |

  - **Delete these transactions?** [x] — ✅ DELETED (backed up, balance recomputed)

