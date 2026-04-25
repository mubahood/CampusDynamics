# Performance Appraisal — Scoring Formulas & Staff Category Comparison

> **Muteesa I Royal University — Performance Management System**
> Comprehensive scoring reference for all staff categories

---

## Staff Categories Overview

The university classifies employees into **three appraisal categories**, each with a distinct maximum score constant (Y). The constant Y is determined by the number of criteria assessed in Sections B and C of the respective appraisal form.

| Category | Section B (Level of Achievement) | Section C (Core Competencies) | Total (Y) |
|----------|--------------------------------|------------------------------|-----------|
| **Academic Staff** | 8 slots × 5 = **40** | 52 criteria × 5 = **260** | **300** |
| **Administrative Staff** | 8 slots × 5 = **40** | 22 criteria × 5 = **110** | **150** |
| **Support Staff** | 5 slots × 5 = **25** | 25 criteria × 5 = **125** | **150** |

---

## Universal Scoring Formula

The same formula applies to all staff categories — only the Y constant changes:

$$
\text{Final \%} = \frac{X}{Y} \times 100
$$

Where:
- **X** = Supervisor's Total Score (Section B + Section C)
- **Y** = Category Maximum (300, 150, or 150)

---

## Per-Category Formulas

### Academic Staff (Y = 300)

```
Final % = (Supervisor's Total Score ÷ 300) × 100
```

**Breakdown:**

| Component | Max |
|-----------|-----|
| Section B — Level of Achievement (8 outputs × 5) | 40 |
| Section C — Core Competencies (52 criteria × 5) | 260 |
| **Total** | **300** |

**Section C Sub-Breakdown (52 Criteria):**

| # | Competency Category | Criteria Count | Max Score |
|---|-------------------|---------------|-----------|
| C1 | Teaching Function | 6 | 30 |
| C2 | Administration | 7 | 35 |
| C3 | Examinations | 6 | 30 |
| C4 | Research and Publications | 7 | 35 |
| C5 | Supervision | 2 | 10 |
| C6 | Training of Trainers | 1 | 5 |
| C7 | Relations | 8 | 40 |
| C8 | Skills | 8 | 40 |
| C9 | Competences | 7 | 35 |
| | **Total** | **52** | **260** |

**Example:** Score 240 → 240 ÷ 300 × 100 = **80%**

---

### Administrative Staff (Y = 150)

```
Final % = (Supervisor's Total Score ÷ 150) × 100
```

**Breakdown:**

| Component | Max |
|-----------|-----|
| Section B — Level of Achievement (8 outputs × 5) | 40 |
| Section C — Core Competencies (22 criteria × 5) | 110 |
| **Total** | **150** |

**Section C Criteria List (22 Items):**

| # | Core Competence | Max |
|---|----------------|-----|
| 1 | Professional Knowledge / Skills | 5 |
| 2 | Planning, Organising & Coordinating | 5 |
| 3 | Managing People | 5 |
| 4 | Decision Making | 5 |
| 5 | Team Work | 5 |
| 6 | Initiative | 5 |
| 7 | Writing & Communication Skills | 5 |
| 8 | Integrity | 5 |
| 9 | Time Management & Meeting Deadlines | 5 |
| 10 | Meetings | 5 |
| 11 | Dependability | 5 |
| 12 | Loyalty | 5 |
| 13 | Financial Management & Accountability | 5 |
| 14 | Quality of Work & Results | 5 |
| 15 | Record Keeping | 5 |
| 16 | Interpersonal Relations | 5 |
| 17 | Verbal & Listening Skills | 5 |
| 18 | Discretion & Confidentiality | 5 |
| 19 | Punctuality & Attendance | 5 |
| 20 | Computer Knowledge | 5 |
| 21 | Customer Care | 5 |
| 22 | Adaptability & Flexibility | 5 |
| | **Total** | **110** |

**Example:** Score 120 → 120 ÷ 150 × 100 = **80%**

---

### Support Staff (Y = 150)

```
Final % = (Supervisor's Total Score ÷ 150) × 100
```

**Breakdown:**

| Component | Max |
|-----------|-----|
| Section B — Level of Achievement (5 outputs × 5) | 25 |
| Section C — Core Competencies (25 criteria × 5) | 125 |
| **Total** | **150** |

> **Note:** The Support Staff form criteria list will be documented separately once the form is provided. The Y constant of 150 has been confirmed.

**Example:** Score 120 → 120 ÷ 150 × 100 = **80%**

---

## Rating Scale (Universal)

All sections across all categories use the same 5-point rating scale:

| Rate | Level | Description |
|------|-------|-------------|
| **5** | Excellent / Exceptional | Exceeded all agreed targets. Consistently outstanding quality, productivity, and timeliness. A model of excellence. |
| **4** | Very Good | Achieved all agreed outputs in line with targets. Consistently meets expectations. |
| **3** | Good | Achieved most, but not all, agreed outputs with no supporting rationale for gaps. |
| **2** | Fair | Achieved minimal outputs in line with targets with no rationale for shortfall. |
| **1** | Poor / Unsatisfactory | Has not achieved most agreed targets without supporting rationale. |
| **N/A** | Not Applicable | Criterion does not apply to this employee's role. |

### N/A Handling

When a criterion is rated N/A, it must be **excluded** from the Y constant calculation:

$$
Y_{\text{adjusted}} = Y_{\text{standard}} - (N_{\text{NA}} \times 5)
$$

Where $N_{\text{NA}}$ is the count of criteria marked N/A.

**Example (Academic Staff):** If 3 competencies in Section C are marked N/A:
- Standard Y = 300
- Adjusted Y = 300 − (3 × 5) = **285**
- Final % = X ÷ 285 × 100

---

## Performance Classification Bands

Based on the final percentage, employees are classified as follows:

| Range | Classification | Recommended Action |
|-------|---------------|-------------------|
| 90% – 100% | **Exceptional** | Recognition, reward; potential promotion consideration |
| 75% – 89% | **Very Good** | Positive feedback; identify areas for further growth |
| 60% – 74% | **Good** | Meets standard; targeted improvement areas identified |
| 40% – 59% | **Fair** | Performance improvement plan (PIP) required |
| Below 40% | **Unsatisfactory** | Formal PIP with defined timeline; potential consequences |

---

## Dual-Score Model

Each appraisal captures **two parallel scores:**

| Score | Source | Purpose |
|-------|--------|---------|
| **Self-Assessment Score** | Employee rates themselves in Section B | Self-reflection; used in discussion meeting only |
| **Supervisor's Score** | Appraiser rates in Section B + all of Section C | **Official score** used for final percentage calculation |

> **The supervisor's total score is the only score used in the final percentage formula.** The self-assessment score is captured for comparison and dialogue purposes but does not factor into the official result.

---

## Score Computation Pseudocode

```
function computeAppraisalScore(sectionB_scores[], sectionC_scores[]):
    
    // Section B: sum of supervisor ratings for agreed outputs
    B_total = SUM(sectionB_scores where score != N/A)
    B_count = COUNT(sectionB_scores where score != N/A)
    
    // Section C: sum of supervisor ratings for competencies
    C_total = SUM(sectionC_scores where score != N/A)
    C_count = COUNT(sectionC_scores where score != N/A)
    
    // Raw total
    X = B_total + C_total
    
    // Adjusted maximum (excluding N/A items)
    Y_adjusted = (B_count + C_count) * 5
    
    // Final percentage
    Final_Percent = (X / Y_adjusted) * 100
    
    return {
        section_b_total: B_total,
        section_c_total: C_total,
        raw_score: X,
        max_possible: Y_adjusted,
        percentage: Final_Percent,
        classification: classify(Final_Percent)
    }
```

---

## Cross-Category Summary Table

| Metric | Academic | Administrative | Support |
|--------|---------|---------------|---------|
| Section B Slots | 8 | 8 | 5 |
| Section B Max | 40 | 40 | 25 |
| Section C Criteria | 52 | 22 | 25 |
| Section C Max | 260 | 110 | 125 |
| **Y Constant** | **300** | **150** | **150** |
| Has Self-Assessment | ✓ (Section B only) | ✓ (Section B only) | ✓ (Section B only) |
| Section C Rated By | Supervisor only | Supervisor only | Supervisor only |
| N/A Adjustable | ✓ | ✓ | ✓ |
| Action Plan Section | ✓ (Section D) | ✓ (Section D) | ✓ (Section D) |
| Reflections Section | ✓ (Section E, 6 Qs) | ✓ (Section E, 6 Qs) | ✓ (Section E, 6 Qs) |
