# Management Information System — Upgrade Programme
## Technical & Operational Response to the Bursar's Memorandum of 20 May 2026

**FROM:** Manager of Information Systems / Systems Development Team
**TO:** The Vice Chancellor, Muteesa I Royal University
**DATE:** May 2026
**RE:** Response to Bursar's Memorandum — MIS Concerns, System Upgrade, and Service Continuity
**CLASSIFICATION:** Internal — For Management Review

---

## Preamble

This document is prepared in response to the memorandum submitted by the University Bursar on 20 May 2026 (hereinafter referred to as "the Bursar's Memo"). We welcome the opportunity to provide a full technical account of the upgrade programme, address specific concerns raised, and outline the position of the ICT and Systems team with respect to service continuity, financial data integrity, and the path forward.

We acknowledge that a system upgrade of this scale is disruptive. The disruption has been real, documented, and temporary. The purpose of this response is not to dismiss the concerns of the Bursar's office — many of which are legitimate observations about a system mid-transition — but to provide the Vice Chancellor with accurate technical context so that informed decisions can be made.

---

## SECTION 1 — Why This Upgrade Was Necessary

Before evaluating the challenges that have arisen, it is important to understand the documented deficiencies of the previous system that made this upgrade not just desirable, but operationally necessary.

### 1.1 Billing Engine Failures in the Previous System

The original system contained a structural defect in its billing engine. Students were routinely either:

- **Under-billed** — fee items were omitted during the billing cycle, resulting in students showing artificially low balances and paying less than required.
- **Double-billed** — the same fee item was posted to a student's ledger more than once, resulting in inflated balances and student complaints.

These errors were not edge cases. They were systemic, recurring every semester, and required manual intervention by the Bursar's team to identify and correct. The previous system provided no automated detection mechanism for these anomalies.

**The upgrade introduced automated duplicate billing detection** — an integrity check that flags, at the point of billing, whether a student has already been charged the same fee item for the same semester. This check did not exist before.

### 1.2 Absence of Real-Time Financial Reporting and Dashboards

The previous system had no real-time income monitoring. There were no charts, no daily receipts summary, no monthly trend analysis, no department-level revenue breakdown, and no way to see at a glance what income had been received on any given day from any source.

Finance management was essentially blind between reporting periods. The only way to know the university's cash position was to manually extract raw data and process it in a spreadsheet — a process that was slow, error-prone, and dependent on individual effort.

**The upgraded system now provides:**

- A live Fees Management Dashboard showing daily, monthly, and semester-level income.
- Breakdown of income by source: Mobile Money, Direct Bank, and other channels.
- Separate reporting of cash receipts versus non-cash credits (bursaries, waivers, adjustments).
- Per-programme revenue tables with collection rates.
- Real-time identification of students with outstanding balances.

At any point in time, management can see exactly how much cash the university has collected, from which source, and which students have not yet paid.

### 1.3 Bursary Management Was Structurally Unsound

In the previous system, when a bursary was granted to a student, the implementation was inconsistent. In some cases the student's bill was directly reduced (making the bursary invisible in the ledger). In others, no corresponding transaction was posted at all, and the balance simply decreased without explanation. This created a situation where:

- It was impossible to independently audit bursary expenditure.
- The university could not produce a clean bursary register or report bursary liability reliably.
- Students on bursaries appeared to have lower bills than their peers for no documented reason.

**The upgraded system changes the bursary approach fundamentally:**

1. Every student is billed the full fee applicable to their programme.
2. A separate, positive credit transaction is posted to the student's ledger, explicitly identified as a bursary or scholarship.
3. This credit is independently tracked, reportable, and fully auditable.

This approach means the full obligation is always visible, the credit is always traceable, and bursary expenditure can be reported accurately. It is a best-practice accounting approach — debit first, then credit — consistent with double-entry principles.

The Bursar's memo acknowledges concerns about financial reporting accuracy. This bursary reform directly improves exactly that.

### 1.4 Limited Controls in the Previous System

The previous system had no:

- Batch billing controls — no way to review a billing run before it was committed.
- Reversal authorisation workflow — any user with billing access could post and reverse transactions without a second approval.
- Audit trail on who performed which action — accountability was nearly non-existent.
- Access policy integration — the system did not communicate student financial status to examination rooms, academic gateways, or other control points.

### 1.5 Poor Usability and Interface Design

The old interface was designed for a desktop era and was not responsive. Staff and students reported difficulty using it on standard devices. The student-facing portal was particularly poor — students could not easily see their balance, payment history, or examination card status, which reduced payment motivation and increased the volume of enquiries directed at the Bursar's counter.

---

## SECTION 2 — Service Continuity: The Facts on System Suspension

This section directly addresses paragraph 3.0 of the Bursar's Memo, which raises concerns about service disconnections and their impact on operations.

### 2.1 Total Number of Suspensions This Semester: 2

During the entire current semester, the system interface was suspended on **exactly two (2) occasions**. These suspensions were not arbitrary, punitive, or done without reason. Each was a scheduled, technically justified maintenance window carried out to protect the integrity of the upgrade.

This figure — two suspensions in a full semester — is a factually low number for a system undergoing a major architectural upgrade. For reference, major enterprise software providers (Oracle, SAP, Sage) typically schedule four to eight maintenance windows per year for far smaller systems, with advance notice of days to weeks.

### 2.2 Maximum Duration of Any Suspension: Under 12 Hours

The longest any suspension lasted was **under twelve (12) hours**. Both suspensions were completed within the business day or overnight, meaning that by the start of the next working session, the system was fully operational.

No suspension extended into a second consecutive business day. Students, staff, and the Bursar's team were not unable to access the system for any extended period.

This is not a "service disconnection" in the sense implied by the Bursar's Memo. A service disconnection is an unplanned, indefinite outage caused by infrastructure failure, vendor withdrawal, or contractual dispute. What occurred was a **planned interface lock** — a fundamentally different event.

### 2.3 Critical Distinction: Interface Lock vs. System Shutdown

This is the most important technical clarification in this response, and it is necessary for an accurate understanding of what happened during each suspension.

**When the interface was locked, only the user-facing login screens were temporarily disabled. The underlying system — the database engine, the transaction processing layer, and the data storage infrastructure — remained fully operational at all times.**

In practical terms, this means:

| What Happened During Suspension | What Did NOT Happen |
|----------------------------------|---------------------|
| Staff could not log into the admin interface | No data was lost |
| Students could not log into the portal | No transactions were dropped |
| New screens and modules were being deployed | No payment records were deleted |
| Data integrity checks were being run | No student balances were corrupted |
| — | No bank integration was disconnected |

Every payment received through the payment gateway (School Pay, Mobile Money, bank channels) during the suspension period was **recorded, queued, and posted correctly**. The system continued receiving and logging transactions even while the interface was temporarily unavailable.

There is no evidence of any financial transaction that was lost, missed, or irrecoverable as a result of either suspension. If the Bursar's office has identified specific transactions believed to have been lost during these windows, the Systems team invites a joint review — with full audit trail access — to verify.

This distinction matters for governance purposes: **a lock of the interface is operationally equivalent to closing an office reception for maintenance while the back office continues to function.** It is not a shutdown of the institution's financial operations.

### 2.4 Advance Communication

Both suspension windows were communicated to the relevant stakeholders before they occurred. The Systems team acknowledges that communication cadence and channel could be improved — a formal change management protocol with structured advance notice will be adopted going forward (see Section 6 — Way Forward).

---

## SECTION 3 — The Transition Disruption: What Happened and Why

### 3.1 The Bursary Billing Transition — Root Cause of Disruption

The single most disruptive consequence of the upgrade was the change in how bursaries are handled. As described in Section 1.3, the old system either quietly reduced a student's bill or made no posting at all. The new system bills every student in full and then posts a separate, visible bursary credit.

When the new approach went live, students who had previously appeared to owe, say, UGX 1,000,000 (because their bill had silently been reduced) now appeared to owe UGX 3,000,000 (because the full bill was now visible, with the bursary credit posted separately). To a student or parent looking at a balance, this looked like they had been overcharged.

**They had not been overcharged.** Their effective balance — bill minus bursary — was identical. But the presentation was completely different, and it caused understandable alarm.

### 3.2 Balance Recalibration — The Recovery Work Done

In response, the ICT team and the Bursar's team undertook a **student-by-student balance recalibration exercise**. Every student affected by the transition was reviewed, their old balance confirmed from the previous system's records, and their new ledger adjusted to reflect the correct, agreed figure.

This was a significant exercise. It was also a **one-time exercise**. Once completed, the system's automated billing and bursary posting process handles all future students correctly from the point of registration. No manual recalibration will be needed in subsequent semesters.

As of the date of this memo, **approximately 95% of student balances have been reviewed, recalibrated, and confirmed** by members of the Bursar's team. The remaining 5% are in progress.

### 3.3 Double Billing During Transition

Some students were identified as having been double-billed during the transition period. These arose from the interaction between old data and the new billing engine — a known risk in any system migration. Each identified case was corrected using a documented reversal, recorded in the audit trail with the identity of the officer who performed it and the justification.

**The occurrence of these errors does not indicate a lack of control. It indicates that the detection mechanism worked — errors were found and fixed.** The previous system had the same billing errors but no mechanism to reliably detect them.

---

## SECTION 4 — Addressing Specific Concerns in the Bursar's Memo

### 4.1 On Financial Reports Showing Inaccurate Figures (Section 5 of Memo)

The Bursar's Memo raises concern that financial reports appear inconsistent with underlying transactions. This is a technically correct observation — but the cause is now understood and has been addressed.

The primary source of the discrepancy was that **the "Total Paid" figure in the old dashboard included non-cash credits** — bursaries, bill waivers, and balance adjustment entries — alongside actual cash receipts. This meant that the reported income figure was higher than the cash actually received.

**This has been corrected in the latest upgrade.** The system now:

- Reports **Cash Received** separately from non-cash credits.
- Distinguishes Mobile Money receipts from Direct Bank deposits.
- Shows Bursaries and Scholarships as a separate, clearly labelled line.
- Shows Bill Waivers and Balance Adjustments as a separate, clearly labelled line.
- Reports the **true net outstanding balance** as: Total Billed minus all credits (cash + bursary + adjustments).

Financial staff can now see exactly what has come in as cash, what has been credited as a bursary, and what remains outstanding — all from a single dashboard, updated in real time.

### 4.2 On Transaction Reversals Without Authorisation (Sections 4.0 and 7.0 of Memo)

The Bursar's Memo raises concern that reversals are being performed without adequate authorisation or audit trails. This concern is taken seriously and is partially valid in the context of the current transition period.

**Current position:** During the recalibration exercise, a broader set of finance staff were granted the ability to perform balance adjustments in order to speed up the correction of erroneous balances from the old system. This was a deliberate, temporary decision to allow the Bursar's team to work efficiently through the backlog. It was not a permanent loosening of controls — it was an operational response to a specific, time-limited task.

Every adjustment made during this period is recorded with:
- The identity of the staff member who made it.
- The date and time of the transaction.
- The reason or justification entered at the point of action.
- The before and after balance values.

**No adjustment is invisible.** The audit trail is complete and available for review.

**Going forward (see Section 6):** Role-based access will be tightened. Reversal and adjustment rights will be restricted to specifically authorised roles. A secondary approval workflow for reversals above a defined threshold will be implemented.

### 4.3 On Students Having Administrative Rights (Section 4.0 of Memo)

The allegation that students have been granted administrative rights within the system is taken very seriously. We are not aware of any case where a student was granted access to the administrative system. However, we invite the Bursar's office to provide specific evidence — for example, a student name and registration number alleged to have administrative access — so that we can investigate and respond conclusively within 48 hours of receiving that information.

What is accurate is that students have access to their **own portal** (`eportal.mru.ac.ug`), where they can:

- View their own balance and payment history.
- View their own examination card status.
- Download their own examination card (with QR code verification).
- Complete their own self-appraisal (for staff).

Students **cannot** access any other student's data, the administrative system, billing screens, ledger postings, or any management function. Portal access is authenticated, session-controlled, and logged. Access is strictly scoped to the individual student's own record.

If any student has been found to have access beyond their own record, this is a defect that requires immediate investigation and the Systems team commits to treating it as a Priority 1 issue.

### 4.4 On Accounting Reports and Reconciliation (Sections 5.0 and 8.0 of Memo)

Financial reports are now significantly more detailed and segmented than they were in the previous system. The concern about reports not matching external records is, in the transition context, explainable:

- The new system bills students at full rate before bursaries are posted. A report from the new system showing total billings will therefore appear higher than a calculation done using the old system's net-of-bursary approach.
- Where bank reconciliation discrepancies exist, these require a joint review between the Systems team and the Bursar's office, with bank statements, payment gateway reports, and system ledger extracts compared side by side.

The Systems team is prepared to support a structured reconciliation exercise with the Bursar's team to document and close all identified variances.

---

## SECTION 5 — What the Upgrade Has Already Delivered

Despite the disruptions of the transition period, the upgrade has produced measurable improvements that directly address longstanding weaknesses in the university's financial operations:

| Area | Before Upgrade | After Upgrade |
|------|---------------|--------------|
| Real-time income visibility | None | Live dashboard with daily, monthly, and channel-level data |
| Bursary tracking | Silent ledger reductions; not independently auditable | Full debit-and-credit posting; independently reportable |
| Billing accuracy | Recurring under- and double-billing with no detection | Automated duplicate billing detection; anomaly cards on dashboard |
| Student balance clarity | Mixed and often incorrect | 95% recalibrated and confirmed by Bursar's team |
| Examination card generation | Manual, paper-based | Automated, student self-generated with QR code verification |
| Access policy enforcement | Manual, inconsistent | Dynamic, bursar-configurable; auto-updates student portal |
| Transaction audit trail | Minimal | Full: who, what, when, before/after on every action |
| Ghost student detection | Not possible | Active vs. inactive student identification live on dashboard |
| Double-entry accounting | Partial | Full double-entry; Trial Balance and Balance Sheet in progress |
| Programme revenue reporting | Not available | Live per-programme collection table with rates |

---

## SECTION 6 — Acknowledged Issues and the Way Forward

We acknowledge the following issues and commit to addressing them on the timelines indicated:

### 6.1 Role-Based Access Control — To Be Tightened Immediately

**Issue:** During the recalibration exercise, broader adjustment rights were granted to facilitate the correction work. This has served its purpose.

**Action:** Role-based access restrictions will be reimposed within the coming weeks. Billing rights, reversal rights, and adjustment rights will be restricted to specifically designated roles. A secondary approval workflow for reversals above a defined threshold will be implemented.

**Timeline:** By end of June 2026.

### 6.2 Formal Staff Training — To Be Scheduled

**Issue:** The Bursar's team has not received a formal structured training on the upgraded system. This is an acknowledged gap that has contributed to discomfort and uncertainty.

**Action:** A structured training programme will be developed and delivered to all Bursar's office users. The training will cover: new billing workflow, bursary posting, dashboard interpretation, reversal procedures, report generation, and audit trail access.

**Timeline:** Training sessions to be scheduled by mid-June 2026.

### 6.3 Double-Entry Financial Module — In Progress

**Issue:** The full double-entry accounting module (Trial Balance, Balance Sheet, Income Statement) is not yet fully deployed.

**Action:** This module is currently in active development and testing. Target deployment is July 2026.

**Timeline:** July 2026.

### 6.4 Digital Requisition and Procurement Module — In Progress

**Issue:** Procurement and requisition processes remain paper-based.

**Action:** A digital requisition and procurement module is in development. Target deployment is mid-June 2026.

**Timeline:** Mid-June 2026.

### 6.5 Change Communication Protocol — To Be Formalised

**Issue:** Communication about maintenance windows and system changes has not been structured formally enough, causing uncertainty among users.

**Action:** A formal change communication protocol will be adopted. All planned maintenance windows will be notified at least 48 hours in advance to designated contacts in the Bursar's office, Registrar's office, and Senior Management. A simple status page will also be made available.

**Timeline:** Immediately.

---

## SECTION 7 — Position on Vendor Conduct

The Bursar's Memo characterises the relationship with the system developers as involving threats to withdraw support in response to routine queries. The Systems team wishes to address this characterisation directly.

The system is developed and maintained by an in-house team working under the supervision of the Manager of Information Systems. There is no external vendor in the conventional sense. Development decisions, including the timing of interface locks and the scope of the upgrade, are made in the interest of system integrity and the long-term operational health of the university.

What may have been perceived as "threats" were technical assessments communicated under pressure — for example, statements that deploying a change incorrectly or prematurely could result in data corruption, or that proceeding without a maintenance window would risk transaction loss. These are factual technical positions, not threats.

The Systems team is committed to communicating such assessments more clearly, more constructively, and through formal channels in future. Tone and format of communication will be improved.

---

## SECTION 8 — Conclusion

The upgrade of the University's Management Information System is a necessary investment in the long-term accuracy, accountability, and efficiency of financial operations. The disruptions experienced during the transition period — while genuinely inconvenient — are temporary and are being systematically addressed.

**Key facts for the Vice Chancellor's consideration:**

1. The system interface was suspended only **twice** during the entire semester.
2. Neither suspension lasted more than **twelve (12) hours**.
3. During every suspension, **the underlying system remained operational** — transactions continued to be recorded and no data was lost.
4. The "inaccurate figures" identified by the Bursar's office have been **diagnosed and corrected** — they arose from including non-cash credits in cash income totals, now fixed in the dashboard.
5. Approximately **95% of student balances** have been reviewed, corrected, and confirmed by the Bursar's team.
6. Every adjustment and reversal made during the transition is **logged with full attribution** — who, when, what, and why.
7. The upgrade has delivered capabilities that **did not previously exist**: real-time income dashboards, bursary audit trails, automated examination card generation, and live anomaly detection.

The Systems team is committed to working collaboratively with the Bursar's office to resolve all outstanding concerns. We propose a joint technical review meeting, attended by representatives of both offices and chaired by the Vice Chancellor or a nominated delegate, to work through specific transactions, reports, or access rights that require clarification.

We remain committed to building a system that serves the university's mission reliably, transparently, and securely.

---

## Appendix A — Summary of Upgrade Scope and Progress

| Module | Status | Completion |
|--------|--------|-----------|
| Fees Billing Engine (new approach) | Complete | 100% |
| Student Balance Recalibration | Substantially complete | 95% |
| Real-Time Financial Dashboard | Complete | 100% |
| Daily / Monthly Income Charts | Complete | 100% |
| Bursary Tracking (debit/credit approach) | Complete | 100% |
| Cash vs. Non-Cash Income Split in Reports | Complete (latest release) | 100% |
| Student Portal (balance, exam card, policy) | Complete | 100% |
| QR Code Examination Card with Access Policy | Complete | 100% |
| Double-Entry Accounting Module | In Progress | ~60% |
| Trial Balance / Balance Sheet Generation | In Progress | ~50% |
| Digital Requisition & Procurement | In Progress | ~40% |
| Role-Based Access Control Tightening | Planned | Q2 2026 |
| Staff Training Programme | Planned | June 2026 |

---

## Appendix B — Suspension Log

| # | Date | Duration | Reason | Impact |
|---|------|----------|--------|--------|
| 1 | Semester 2026 | < 12 hours | Upgrade deployment — bursary module | Interface locked; transactions continued uninterrupted |
| 2 | Semester 2026 | < 12 hours | Upgrade deployment — dashboard & reporting module | Interface locked; transactions continued uninterrupted |

**Total downtime this semester: fewer than 24 combined hours across two events. Zero transactions lost.**

---

*Document prepared by: Manager of Information Systems / Systems Development Team*
*Muteesa I Royal University*
*May 2026*
*This document is prepared for internal management review and is not intended for external distribution.*
