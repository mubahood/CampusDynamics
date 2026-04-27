# Finance System Realignment - Implementation Plan

## Next Batch Checklist (Batch 2)

- [x] B2-T1: Create implementation checklist tracker and align to roadmap next batch scope
- [x] B2-T2: Add shared Finance Realignment admin access helper (server-side role gating)
- [x] B2-T3: Implement live database-backed Transaction Batch Monitor page
- [x] B2-T4: Implement live database-backed Double-Entry Validation page
- [x] B2-T5: Validate new code for errors and integration readiness

## Notes
- Menu section and star-prefixed interface entries are already implemented in `COOPERP/accounts/MasterPage.master`.
- This batch focuses on secure server-side gating and live data wiring for first two interfaces.

## Next Batch Checklist (Batch 3)

- [x] B3-T1: Plan and stage Batch 3 implementation scope from roadmap
- [x] B3-T2: Implement live database-backed Accounting Period Management page with server-side access checks
- [x] B3-T3: Implement live database-backed Reversal and Correction Approvals page with server-side access checks
- [x] B3-T4: Implement live database-backed Transaction Audit Trail page with server-side access checks
- [x] B3-T5: Validate Batch 3 code changes and integration readiness

## Batch 3 Notes
- Focus is to complete next three high-priority roadmap interfaces with production-safe live data loading.
- All pages must use `FinanceSystemRealignmentHelper.EnsureFinanceAdminAccess(...)` before loading data.

## Next Batch Checklist (Batch 4)

- [x] B4-T1: Plan and stage Batch 4 implementation scope from roadmap
- [x] B4-T2: Implement live database-backed Bank Reconciliation Import Validation page with server-side access checks
- [x] B4-T3: Implement live database-backed Chart of Accounts Lifecycle Management page with server-side access checks
- [x] B4-T4: Implement live database-backed Period Close Management page with server-side access checks
- [x] B4-T5: Validate Batch 4 code changes and integration readiness

## Batch 4 Notes
- Focus is to complete remaining roadmap interfaces using production-safe read logic and explicit access enforcement.
- Existing admin menu labels with `*` are already in place and remain unchanged.

## Next Batch Checklist (Batch 5)

- [x] B5-T1: Plan and stage Batch 5 implementation scope from roadmap
- [x] B5-T2: Implement Reversal Approve/Reject action workflow in `ReversalApprovals.aspx` with parameterized UPDATE to `fin_transaction_reversal`
- [x] B5-T3: Implement Period state transition buttons in `PeriodManagement.aspx` (Open → Frozen → Closed → Archived) with prerequisite guards
- [x] B5-T4: Create Phase 1 SQL schema scripts for all 7 new roadmap tables (`Phase1_Schema.sql`) and `fin_ledger` ALTER script
- [x] B5-T5: Implement atomic voucher sequence helper + transaction batch creation helper in `FinanceSystemRealignmentHelper.cs`
- [x] B5-T6: Validate Batch 5 code changes and integration readiness

## Batch 5 Notes
- Batch 5 focuses on action workflows (approve/reject, state transitions), SQL deployment scripts, and the shared batch/voucher helpers that Phase 4 transaction processing will depend on.
- All UI actions must be server-side validated, parameterized, and logged with audit comments.
- SQL scripts are plain `.sql` files for DBA execution — not auto-run from code.

## Next Batch Checklist (Batch 6)

- [x] B6-T1: Plan and stage Batch 6 implementation scope from roadmap
- [x] B6-T2: Implement Transaction Batch Monitor drill-down and batch line inspection workflow
- [x] B6-T3: Implement Double-Entry Validation rule toggle actions and live summary metrics
- [x] B6-T4: Implement Transaction Audit Trail search and filter workflow
- [x] B6-T5: Add shared schema column helper support needed by Batch 6 pages
- [x] B6-T6: Validate Batch 6 code changes and integration readiness

## Batch 6 Notes
- Batch 6 focuses on deepening the admin workflows already created: inspect batch contents, toggle validation rules safely, and search audit records quickly.
- All new actions remain under the existing starred Finance System Realignment admin menu section.

## Next Batch Checklist (Batch 7)

- [x] B7-T1: Plan and stage Batch 7 implementation scope from roadmap
- [x] B7-T2: Implement Bank Reconciliation Import validation execution workflow with duplicate-hash guard actions
- [x] B7-T3: Implement Chart of Accounts deactivate and restore workflow with ledger-line safety guards
- [x] B7-T4: Implement Period Close execution panel wired to stored procedure when available and guarded fallback when unavailable
- [x] B7-T5: Validate Batch 7 code changes and integration readiness

## Batch 7 Notes
- Batch 7 focuses on admin execution workflows, not just read-only dashboards.
- All actions must remain server-side validated, parameterized, and safe against missing schema objects.

## Next Batch Checklist (Batch 8)

- [x] B8-T1: Plan and stage Batch 8 implementation scope from roadmap transaction-processing updates
- [x] B8-T2: Add shared helper support for voucher batch preparation and pre-posting double-entry validation
- [x] B8-T3: Integrate Student Receipt approval with transaction batch creation, validation, and audit logging
- [x] B8-T4: Integrate Payment Voucher approval with transaction batch creation, validation, and audit logging
- [x] B8-T5: Validate Batch 8 code changes and integration readiness

## Batch 8 Notes
- Batch 8 begins roadmap Phase 4 transaction-processing updates on the safest legacy approval flows first.
- Implementation remains additive: if roadmap tables or columns are missing, legacy approval still proceeds without destructive changes.

## Next Batch Checklist (Batch 9)

- [x] B9-T1: Plan and stage Batch 9 scope — remaining approval flows not yet wired to batch tracking
- [x] B9-T2: Integrate SponsorReceipt approval with transaction batch creation, validation, and audit logging
- [x] B9-T3: Integrate SponsorshipDistribution approval with batch tracking; improve silent exception swallowing
- [x] B9-T4: Integrate JournalDisplay approval with batch tracking using existing journal type selector
- [x] B9-T5: Integrate DisplayPaymentVoucher approval with batch tracking
- [x] B9-T6: Integrate ContraVoucher approval with batch tracking; upgrade from unsafe fin_ApproveJournal to fin_ApproveJournal_Safe
- [x] B9-T6b: Integrate ViewJournal approval with batch tracking (period check preserved)
- [x] B9-T7: Validate Batch 9 code changes and integration readiness

## Batch 9 Notes
- Batch 9 completes Phase 4 batch tracking across all direct approval posting paths.
- ContraVoucher was still using the legacy unsafe `fin_ApproveJournal` — upgraded to `fin_ApproveJournal_Safe` in this batch.
- All five files now: create a batch, validate balance before posting, audit log on approval, mark batch complete/failed safely.

## Next Batch Checklist (Batch 10)

- [x] B10-T1: Plan and stage Batch 10 scope — bank statement upload pipeline
- [x] B10-T2: Add file upload panel to BankReconciliationImport.aspx (bank account ID, statement date, format, opening/closing balance, FileUpload)
- [x] B10-T3: Implement SHA-256 hash generation from uploaded file bytes with duplicate guard
- [x] B10-T4: Implement 25-line CSV preview panel shown before confirmation
- [x] B10-T5: Implement confirm-and-save action inserting into fin_reco_bank_statement_import with all metadata
- [x] B10-T6: Add OriginalFilename column to grid and update BindImportSummary SELECT
- [x] B10-T7: Validate Batch 10 code changes and integration readiness

## Batch 10 Notes
- Batch 10 implements the full bank statement import pipeline: upload → hash → preview → confirm → save → validate.
- SHA-256 fingerprinting enforced at both preview and confirm steps to prevent duplicate imports.
- Import record is saved as status 'Pending'; admin then clicks 'Run Validation' on the saved record row.

## Next Batch Checklist (Batch 11)

- [x] B11-T1: Plan and stage Batch 11 scope — two new admin interfaces + SQL infrastructure scripts
- [x] B11-T2: Create * Initiate Reversal Request admin interface (voucher search → reversal form → insert to fin_transaction_reversal as Pending)
- [x] B11-T3: Create * Bank Reconciliation Matching admin interface (pick import → match unreconciled ledger entries → mark reconciled)
- [x] B11-T4: Add both new interfaces to Finance System Realignment admin menu with * prefix
- [x] B11-T5: Create Phase1_6_Migrate_Periods.sql — populate fin_accounting_periods from existing fin_financial_years
- [x] B11-T6: Create sp_MonthEndClose.sql — MySQL-compatible month-end close stored procedure
- [x] B11-T7: Validate Batch 11 code changes and integration readiness

## Batch 11 Notes
- Batch 11 introduces the last two remaining admin interface screens from the roadmap.
- ReversalRequest feeds into the existing ReversalApprovals.aspx approval queue — completing the full reversal lifecycle.
- BankRecoMatching provides the missing step between import validation and marking ledger entries as reconciled.
- SQL scripts are DBA-executed, not auto-run by application code.

## Next Batch Checklist (Batch 12)

- [x] B12-T1: Plan and stage Batch 12 scope — correction request workflow, Phase 3 migration scripts, year-end stored procedures
- [x] B12-T2: Create * Correction Request admin interface (transaction lookup → correction form → paired reversal+repost → Pending approval)
- [x] B12-T3: Add * Correction Request to Finance System Realignment admin menu
- [ ] B12-T4: Create Phase3_1_Backfill_Batches.sql — retroactively populate fin_transaction_batch from existing transactions
- [ ] B12-T5: Create Phase3_2_Backfill_Sequences.sql — populate fin_voucher_sequence with current max numbers per type
- [ ] B12-T6: Create Phase3_3_Link_Ledger_to_Batch.sql — backfill fin_ledger.batch_id from voucher number matching
- [ ] B12-T7: Create Phase3_4_Populate_Reversals.sql — retroactively link existing reversed transactions in fin_transaction_reversal
- [ ] B12-T8: Create sp_PostDepreciation.sql — MySQL-compatible depreciation posting stored procedure
- [ ] B12-T9: Create sp_YearEndClose.sql — MySQL-compatible year-end close stored procedure
- [ ] B12-T10: Validate Batch 12 code changes and integration readiness

## Batch 12 Notes
- Batch 12 completes the correction request workflow (Phase 5) and all Phase 3 data migration scripts.
- Phase 3 scripts are DBA-executed, idempotent, and leave legacy tables untouched.
- sp_PostDepreciation and sp_YearEndClose complete the full period-close stored procedure suite from Phase 6.
- CorrectionRequest.aspx plugs into the existing ReversalApprovals.aspx approval queue as a 'Correction' type.
