# Student Application API — Implementation Plan
**File:** `API/v2/APPLY_API_PLAN.md`  
**Started:** 2026-05-24  
**Completed:** 2026-05-24  
**Status Legend:** ⬜ Pending | 🔄 In Progress | ✅ Done | ❌ Broken/Needs Fix

---

## Architecture Decisions

### New file: `apply.aspx` / `apply.aspx.cs`
All **applicant-facing** operations live here. `admissions.aspx.cs` is staff-only.

### Auth token for applicants
Applicant tokens are stored in `api_tokens` with `user_type = 'applicant'`. TokenManager already supports any string for user_type.

### OTP for mobile email verification
Portal uses GUID-link tokens (web click). Mobile gets a 6-digit cryptographic OTP stored in `apply_email_tokens` with `token_type = 'EMAIL_VERIFY_OTP'` or `'PASSWORD_RESET_OTP'`, 30-minute expiry.

### Database access pattern
| Table group | Connection | ApiHelper method |
|---|---|---|
| `my_aspnet_users`, `my_aspnet_membership`, `apply_email_tokens` | Portal DB | `GetPortalConnection()` |
| `acad_applications`, `acad_applicant_choices`, `apply_documents`, `apply_notifications`, `apply_intakes` | Main DB | `GetConnection()` (Query/Execute/Scalar) |
| `acad_programme`, `acad_faculty`, `acad_campuses` | Main DB | `Query()` |

### Schema alias mapping (legacy reuse)
The portal reuses columns for education data — documented here so API is consistent:
| Semantic field | Actual DB column |
|---|---|
| O-Level year | `stud_pob` |
| O-Level aggregate | `stud_district` |
| A-Level points | `stud_ward` |
| Other institution | `stud_prevcampus` |
| Other qualification | `stud_lg` |
| Other year | `stud_village` |
| Other grade | `stud_county` |

---

## Task List

### Phase 1 — Fix Existing Broken Endpoints
| # | Task | Status |
|---|---|---|
| 1.1 | Fix `admissions.aspx.cs` — all schema column mismatches (`app_id`→`stud_entry_no`, `applicant_name`→`stud_name`, `prog_code`→`prog_id`, etc.) | ✅ Done |
| 1.2 | Fix `admissions.aspx.cs` `HandleRegister()` — use `acad_RegNoCreator` SP instead of manual seq | ✅ Done |
| 1.3 | Fix `admissions.aspx.cs` `HandleApplicationStatus()` — use correct columns | ✅ Done |
| 1.4 | Fix `admissions.aspx.cs` `SaveNote()` LAST_INSERT_ID bug (separate connection) | ✅ Done |

### Phase 2 — New `apply.aspx` — Auth Endpoints (no token)
| # | Endpoint | Action | Status |
|---|---|---|---|
| 2.1 | Register applicant account | `register` | ✅ Done |
| 2.2 | Login and get token | `login` | ✅ Done |
| 2.3 | Verify email via OTP | `verify_email` | ✅ Done |
| 2.4 | Resend OTP | `resend_otp` | ✅ Done |
| 2.5 | Forgot password (send OTP) | `forgot_password` | ✅ Done |
| 2.6 | Reset password with OTP | `reset_password` | ✅ Done |

### Phase 3 — New `apply.aspx` — Application Wizard (applicant token)
| # | Endpoint | Action | Status |
|---|---|---|---|
| 3.1 | Load draft / resume application | `get_draft` | ✅ Done |
| 3.2 | Save Step 1 — personal details | `save_step1` | ✅ Done |
| 3.3 | Save Step 2 — education history | `save_step2` | ✅ Done |
| 3.4 | Save Step 3 — programme + emergency contact | `save_step3` | ✅ Done |
| 3.5 | Final submission with declaration | `submit` | ✅ Done |
| 3.6 | My application status + details | `my_application` | ✅ Done |
| 3.7 | Change password | `change_password` | ✅ Done |

### Phase 4 — Documents (applicant token)
| # | Endpoint | Action | Status |
|---|---|---|---|
| 4.1 | Upload document (multipart) | `upload_document` | ✅ Done |
| 4.2 | Delete document | `delete_document` | ✅ Done |
| 4.3 | List documents | `documents` | ✅ Done |
| 4.4 | Serve/download document | `get_document` | ✅ Done |

### Phase 5 — Notifications + Profile (applicant token)
| # | Endpoint | Action | Status |
|---|---|---|---|
| 5.1 | Get notifications | `notifications` | ✅ Done |
| 5.2 | Mark notification read | `mark_read` | ✅ Done |
| 5.3 | My profile | `my_profile` | ✅ Done |

### Phase 6 — Public Reference Data (no token)
| # | Endpoint | Action | Status |
|---|---|---|---|
| 6.1 | List programmes | `programmes` | ✅ Done |
| 6.2 | List faculties | `faculties` | ✅ Done |
| 6.3 | List campuses | `campuses` | ✅ Done |
| 6.4 | Open intakes | `intakes` | ✅ Done |
| 6.5 | Public status check | `check_status` | ✅ Done |

### Phase 7 — Documentation
| # | Task | Status |
|---|---|---|
| 7.1 | Add `apply.aspx` section (25 endpoints) to API_DOCUMENTATION.md | ✅ Done |
| 7.2 | Fix/update `admissions.aspx` section — correct params, add review/notes/notify/stats | ✅ Done |
| 7.3 | Update `docs.aspx` — add Applications sidebar section + 5 endpoint groups | ✅ Done |

### Phase 8 — Infrastructure
| # | Task | Status |
|---|---|---|
| 8.1 | Add `review`, `notes`, `notify` actions to `admissions.aspx.cs` | ✅ Done |
| 8.2 | Create SQL migration: `api/v2/sql/apply_tables_migration.sql` | ✅ Done |
| 8.3 | Add `ApplyUploadPath` to `web.config` appSettings | ✅ Done |

---

## Application Status Flow
```
DRAFT → SUBMITTED → UNDER_REVIEW → ADMITTED → [registered as student via SP]
                                  → REJECTED
                  → WITHDRAWN
```

## adm_status Values (acad_applicant_choices)
| Value | Label |
|---|---|
| 0 | PENDING |
| 1 | ADMITTED |
| 2 | REJECTED |
| 3 | WITHDRAWN |

## Document Types
| doc_type | Label |
|---|---|
| `PHOTO` | Passport-size Photo |
| `OLEVEL` | O-Level Certificate / Result Slip |
| `ALEVEL` | A-Level Certificate / Result Slip |
| `NATID` | National ID / Passport Copy |
| `OTHER` | Supporting Document |

---

## Files Created / Modified

| File | Action | Notes |
|---|---|---|
| `API/v2/apply.aspx` | Created | Thin ASPX shell |
| `API/v2/apply.aspx.cs` | Created | ~1400 lines — all 25 applicant endpoints |
| `API/v2/admissions.aspx.cs` | Rewritten | All 13 staff endpoints — correct schema throughout |
| `API/v2/sql/apply_tables_migration.sql` | Created | CREATE TABLE IF NOT EXISTS for all 7 new tables |
| `API/v2/API_DOCUMENTATION.md` | Updated | Sections 9 (25 endpoints) + 10 (13 endpoints) added |
| `API/v2/APPLY_API_PLAN.md` | Updated | All phases marked done |
| `API/v2/docs.aspx` | Updated | Applications sidebar + 5 new sections |
| `web.config` | Updated | Added `ApplyUploadPath` appSetting |
| `App_Code/ApiHelper.cs` | Updated | Added `ExecuteInsert()` method |

---

## Key Schema Notes

### `acad_applications` (main DB) — actual column names
`stud_entry_no` (PK), `applicant_user_id`, `stud_name`, `stud_surname`, `stud_other_names`, `stud_sex`, `stud_birthdate`, `stud_nationality`, `stud_religion`, `stud_mar_stat`, `physicalDisability`, `stud_id_number`, `stud_email`, `stud_phone`, `stud_phy_address`, `stud_campus`, `stud_intake`, `stud_sponsor`, `next_kin`, `kin_relationship`, `kin_contacts`, `olevel_school`, `olevel_index`, `stud_pob` (=olevel_year), `stud_district` (=olevel_agg), `alevel_school`, `alevel_index`, `alevel_year`, `stud_ward` (=alevel_points), `stud_prevcampus` (=other_inst), `stud_lg` (=other_qual), `stud_village` (=other_year), `stud_county` (=other_grade), `stud_entry_year`, `stud_reg_no`, `app_status`, `app_submitted_at`, `app_last_updated_at`, `app_created_at`

### `acad_applicant_choices` (main DB) — actual column names
`id` (PK), `stud_entry_no` (FK), `Choice`, `prog_id`, `adm_status`, `adm_session`, `sub_comb`, `stud_reg_no`

### Portal auth tables (portal DB via GetPortalConnection)
`my_aspnet_users`: `id`, `name` (=email), `user_type`, `verified_email`, `user_full_name`, `user_mobile`
`my_aspnet_membership`: `userId`, `password`, `passwordFormat`, `passwordKey`, `isLockedOut`, `failedPasswordAttemptCount`, `lastLockoutDate`
`apply_email_tokens`: `id`, `user_id`, `token`, `token_type`, `expires_at`, `used`, `created_at`

### New tables created by migration (main DB)
`apply_documents`, `apply_notifications`, `apply_intakes`, `apply_audit_log`, `acad_application_notes`

### New table created by migration (portal DB)
`apply_email_tokens`

## Production Deployment Checklist
- [ ] Run `sql/apply_tables_migration.sql` on **campus_dynamics** (main DB)
- [ ] Run `sql/apply_tables_migration.sql` on **campus_dynamics_portal** (portal DB)
- [ ] Verify `ApplyUploadPath = C:\inetpub\wwwroot\apply-uploads` directory exists and IIS app pool has write permission
- [ ] Verify `acad_ApplicNoGenerator(@yr)` function exists in campus_dynamics
- [ ] Verify `acad_RegisterApplicant(@yr, @eno, @usr)` SP exists in campus_dynamics
- [ ] Test register → verify_email → login → save_step1..3 → submit flow end-to-end
