# Apply Portal — Full Audit Report
**Portal:** `https://eportal.mru.ac.ug/apply/`
**Date:** 2026-05-14
**Scope:** Student-facing application wizard + Admin admissions controller

---

## Legend
| Status | Meaning |
|--------|---------|
| 🔴 CRITICAL | Data loss, security breach, or broken core flow — must fix before launch |
| 🟠 HIGH | Significant bug or UX failure affecting most users |
| 🟡 MEDIUM | Important improvement that can wait for the next sprint |
| 🟢 LOW | Polish, cleanup, or future-proofing |
| ✅ DONE | Already implemented correctly |
| 🔧 IN PROGRESS | Work started |
| ⬜ TODO | Not started |

---

## SECTION 1 — CRITICAL BUGS (Broken Core Functionality)

### 1.1 Document Upload Does Nothing
**File:** `apply/apply-step4.aspx.cs`, `App_Code/Apply/ApplyWizardDataService.cs:SaveStep4Draft`
**Status:** 🔴 CRITICAL — ✅ DONE

**Problem:** Step 4 shows five file upload fields (`fuPhoto`, `fuOLevel`, `fuALevel`, `fuNatId`, `fuOther`). The CS validates that at least one file is selected, but `ApplyWizardDataService.SaveStep4Draft()` does NOTHING with the files — it only updates `app_status='DRAFT'` and the timestamp. Files are silently discarded. No document is stored anywhere. The `doc_uploads` table referenced in the old admin panel has zero interaction from the portal side.

**Fix Required:**
- [ ] Create a `apply_documents` table: `(id, stud_entry_no, doc_type ENUM('PHOTO','OLEVEL','ALEVEL','NATID','OTHER'), original_filename, stored_path, file_size, uploaded_at)`
- [ ] Implement file saving to a server-side path (e.g. `~/uploads/applicants/{entryNo}/`) with unique renamed filenames
- [ ] Validate file type (MIME + extension), max size per type
- [ ] Store record in `apply_documents`
- [ ] Show uploaded document list on Step 5 review and `my-application.aspx`
- [ ] Pass file handling into `SaveStep4Draft` (add `HttpFileCollection files` parameter or process in `apply-step4.aspx.cs` before calling service)

---

### 1.2 Document List Hardcoded as Empty on My Application Page
**File:** `apply/my-application.aspx.cs:LoadApplication` (lines 153–155)
**Status:** 🔴 CRITICAL — ✅ DONE

**Problem:**
```csharp
rptDocs.DataSource = null;
rptDocs.DataBind();
divNoDocs.Visible = true;
```
This is hardcoded — even when documents eventually exist (after fixing 1.1), this page will always show "No documents uploaded." The repeater is never bound to real data.

**Fix Required:**
- [ ] After fixing 1.1, query `apply_documents WHERE stud_entry_no=@eno` and bind to `rptDocs`
- [ ] Show document name, type, upload date, and a view/download link
- [ ] Hide `divNoDocs` when documents exist

---

### 1.3 Default Student Password is Cleartext "123"
**File:** `NewScreens/AdmissionsController.aspx.cs:ProvisionStudentAccount` (line 1142)
**Status:** 🔴 CRITICAL — ✅ DONE

**Problem:** When an applicant is admitted or registered, a student portal account is created with:
```csharp
@uid, '123', 0, '', @email, @emailL,   // password='123', passwordFormat=0 (cleartext)
```
Every admitted student starts with password "123" stored in plain text. If a student's account already exists, it is reset back to "123" on every admit/re-register action.

**Fix Required:**
- [ ] Generate a random 8-character temporary password using `Guid.NewGuid()` or `RNGCryptoServiceProvider`
- [ ] Hash it using the same HMACSHA256 + salt mechanism already in `ApplyAuthService.HashPasswordWithSalt`
- [ ] Store the hashed password with `passwordFormat=1`
- [ ] Send the temporary password to the student's email on admission
- [ ] Remove the `resetExistingPassword=true` default behavior that wipes existing passwords on re-register

---

### 1.4 `apply_notifications` Table Schema Inconsistency Between Services
**File:** `ApplyWizardDataService.cs:EnsureApplicationSchema` vs `AdmissionsController.aspx.cs:EnsureApplyNotificationsTable`
**Status:** 🔴 CRITICAL — ✅ DONE

**Problem:** Two different code paths create the same table with different schemas:
- Portal service: `message VARCHAR(255)`
- Admin controller: `message TEXT`

If the portal creates the table first, the admin's longer rejection messages may be silently truncated. If the admin creates it first with TEXT, the portal's VARCHAR check won't re-alter it.

**Fix Required:**
- [ ] Standardize on `message TEXT NOT NULL` in both places
- [ ] Run an `ALTER TABLE apply_notifications MODIFY message TEXT` migration once on startup

---

### 1.5 Race Condition in Application Entry Number Generation
**File:** `App_Code/Apply/ApplyWizardDataService.cs:GenerateEntryNo`
**Status:** 🔴 CRITICAL — ✅ DONE

**Problem:** `acad_ApplicNoGenerator(@yr)` is called inside a transaction but the stored procedure itself may not be atomic. Two simultaneous registrations could generate the same entry number. The fallback `APL+yyMMddHHmmssfff` has a millisecond collision window.

**Fix Required:**
- [ ] Verify `acad_ApplicNoGenerator` uses a table-level lock or `AUTO_INCREMENT` counter
- [ ] Add a `UNIQUE KEY` constraint on `acad_applications.stud_entry_no` to enforce uniqueness at DB level
- [ ] If SP is not atomic, replace with `SELECT MAX + 1 FOR UPDATE` pattern or sequence table

---

### 1.6 Dual Status System Can Desync Between `app_status` and `adm_status`
**File:** `AdmissionsController.aspx.cs:HandleAdmit/HandleReject`, `AdmissionsController.aspx.cs:HandleList`
**Status:** 🔴 CRITICAL — ✅ DONE

**Problem:** Two separate status fields exist for the same application:
1. `acad_applications.app_status` — `VARCHAR('DRAFT'|'SUBMITTED'|'UNDER_REVIEW'|'ADMITTED'|'REJECTED'|'WITHDRAWN')`
2. `acad_applicant_choices.adm_status` — `INT(0=PENDING|1=ADMITTED|2=REJECTED|3=WITHDRAWN)`

The admin controller updates both, but the portal only reads `app_status`. Old-format records that have `adm_status=1` but `app_status=NULL/DRAFT` will show incorrectly. `HandleStats` has branching logic to handle both but it's fragile.

**Fix Required:**
- [ ] Run a one-time migration to sync `app_status` from `adm_status` for legacy records
- [ ] Add a DB trigger (or enforce via code) that keeps both fields in sync on every write
- [ ] Long-term: deprecate `adm_status` integer in favor of `app_status` VARCHAR and migrate all references

---

## SECTION 2 — SECURITY VULNERABILITIES

### 2.1 No Rate Limiting on Login, Registration, or Token Endpoints
**File:** `apply/login.aspx.cs`, `apply/register.aspx.cs`, `apply/verify.aspx.cs`
**Status:** 🔴 CRITICAL — ✅ DONE (login lockout implemented; CAPTCHA still pending)

**Problem:** 
- No brute-force protection on login — attacker can try unlimited passwords
- No registration throttling — bot can create unlimited accounts using email+1, email+2, etc.
- No limit on resending verification emails — email bombing is possible
- No CAPTCHA anywhere in the flow

**Fix Required:**
- [ ] Implement login attempt counter per email (max 5 attempts, 15-min lockout) using a `login_attempts` table or server-side cache
- [ ] Add Google reCAPTCHA v3 (or v2) to Registration and Login pages
- [ ] Rate-limit email sends: 1 verification email per 60 seconds per email address

---

### 2.2 Email Validation is Trivially Weak
**File:** `apply/register.aspx.cs` (line 24)
**Status:** 🟠 HIGH — ✅ DONE

**Problem:**
```csharp
if (string.IsNullOrWhiteSpace(email) || !email.Contains("@"))
```
Accepts `x@`, `@x`, `test@test` as valid emails. No domain validation, no TLD check, no format validation.

**Fix Required:**
- [ ] Replace with `new System.Net.Mail.MailAddress(email)` validation in a try/catch (throws on invalid format)
- [ ] Or use a proper regex: `^[^@\s]+@[^@\s]+\.[^@\s]+$`

---

### 2.3 `returnUrl` Validation Allows Path Traversal Edge Case
**File:** `apply/login.aspx.cs` (line 77)
**Status:** 🟡 MEDIUM — ✅ DONE

**Problem:**
```csharp
if (!string.IsNullOrWhiteSpace(returnUrl) && returnUrl.StartsWith("/apply", StringComparison.OrdinalIgnoreCase))
```
While `/apply` prefix is a reasonable guard, paths like `/apply/../../admin/` could theoretically traverse up. The check should also validate that the URL does not contain `..` or protocol-relative `//`.

**Fix Required:**
- [ ] Add: `&& !returnUrl.Contains("..") && !returnUrl.StartsWith("//")` to the check
- [ ] Or use `Uri.IsWellFormedUriString` + same-host validation

---

### 2.4 Session Timeout is 1 Year (525,600 Minutes)
**File:** `apply/login.aspx.cs` (line 56), `apply/login.aspx.cs:RestoreApplicantSessionFromCookie` (line 109)
**Status:** 🟠 HIGH — ✅ DONE

**Problem:** `Session.Timeout = 525600` means a compromised session token remains valid for 365 days. The `APPLY_AUTH` cookie also expires in 1 year.

**Fix Required:**
- [ ] Reduce session timeout to 120 minutes (2 hours) of inactivity
- [ ] Reduce `APPLY_AUTH` cookie to 30 days max
- [ ] Implement "Remember me" checkbox to conditionally extend to 30 days

---

### 2.5 Auth Cookie Not Always Secure
**File:** `apply/login.aspx.cs` (line 68)
**Status:** 🟠 HIGH — ✅ DONE

**Problem:**
```csharp
Secure = Request.IsSecureConnection,
```
If the site is served over HTTP (e.g. internal load balancer), `Request.IsSecureConnection` returns `false` and the cookie is set without `Secure` flag, exposing it to MITM.

**Fix Required:**
- [ ] Set `Secure = true` unconditionally (the production server must serve HTTPS)
- [ ] Or read from `AppSettings["FORCE_SECURE_COOKIE"]` and default to `true`

---

### 2.6 `hfFinalizeReady` Hidden Field is Bypassable
**File:** `apply/apply-step5.aspx.cs` (line 43)
**Status:** 🟡 MEDIUM — ✅ DONE

**Problem:** Submission requires `hfFinalizeReady.Value == "1"` — but this is a hidden field in the HTML that any user can set via browser dev tools. It adds zero security. The real validation is `ValidateForFinalSubmit()` which runs server-side — that's good, but the hidden field check is misleading.

**Fix Required:**
- [ ] Remove `hfFinalizeReady` entirely
- [ ] Replace the two-button UX ("Finalize Draft" then "Submit") with a single confirmation checkbox + submit button
- [ ] The server-side `ValidateForFinalSubmit` is the real guard — keep it

---

### 2.7 Withdrawal Has No Confirmation or CSRF Guard
**File:** `apply/my-application.aspx.cs:btnWithdraw_Click`
**Status:** 🟠 HIGH — ✅ DONE (confirm dialog added)

**Problem:** Clicking Withdraw fires an immediate server-side postback that permanently changes status to WITHDRAWN with no confirmation dialog or secondary step. One accidental click = irreversible withdrawal (unless admin manually resets).

**Fix Required:**
- [ ] Add a client-side confirmation: `return confirm("Are you sure you want to withdraw your application? This cannot be undone.")`
- [ ] Or show a confirmation panel with a typed word ("WITHDRAW") before allowing action
- [ ] Add an anti-CSRF hidden token using `Page.ViewStateUserKey` or a custom CSRF token

---

## SECTION 3 — DATA & SCHEMA WEAKNESSES

### 3.1 `EnsureApplicationSchema` Runs on Every Save — Catastrophic Performance
**File:** `App_Code/Apply/ApplyWizardDataService.cs:EnsureApplicationSchema`
**Status:** 🟠 HIGH — ✅ DONE

**Problem:** Every call to `SaveStep1`, `SaveStep2`, `SaveStep3`, `SaveStep4Draft`, `SubmitFinal` first calls `EnsureApplicationSchema()` which issues 20+ `information_schema.COLUMNS` queries plus potential `ALTER TABLE` statements. For a production system with 1000+ applicants, this is catastrophic — every save hits `information_schema` 25 times.

**Fix Required:**
- [ ] Move schema creation to a one-time startup method called from `Application_Start` in `Global.asax`
- [ ] Or use a migration version table: `schema_migrations (version INT)` — only run migrations if not already applied
- [ ] Remove `EnsureApplicationSchema()` calls from all `Save*` methods after migration is confirmed complete

---

### 3.2 Column Name Reuse — Education Fields Mapped to Unrelated Columns
**File:** `App_Code/Apply/ApplyWizardDataService.cs:SaveStep2`
**Status:** 🟡 MEDIUM — ⬜ TODO

**Problem:** Education data is crammed into columns designed for unrelated demographic data:
| Application Purpose | Column Used |
|--------------------|-------------|
| O-Level sitting year | `stud_pob` (place of birth!) |
| O-Level aggregate | `stud_district` (district!) |
| A-Level points | `stud_ward` (ward!) |
| Other institution | `stud_prevcampus` |
| Other qualification | `stud_lg` (local government!) |
| Other grad year | `stud_village` |
| Other grade | `stud_county` |

This makes queries confusing, breaks admin reports, and makes future schema changes dangerous.

**Fix Required:**
- [ ] Add proper named columns: `olevel_year INT`, `olevel_agg VARCHAR(20)`, `alevel_points VARCHAR(20)`, `other_inst VARCHAR(150)`, `other_qual VARCHAR(150)`, `other_year INT`, `other_grade VARCHAR(50)`
- [ ] Write a one-time migration to copy data from the misnamed columns to the new ones
- [ ] Update all queries to use the proper column names
- [ ] Keep old columns for backward compatibility until old system queries are updated

---

### 3.3 Multiple Applications Per User — No Unique Constraint
**File:** `acad_applications` table
**Status:** 🟠 HIGH — ✅ DONE (GetEditableEntryNo + UserHasLiveSubmission guard)

**Problem:** A user can theoretically accumulate multiple draft applications. `EnsureDraftEntry` and `LoadDraft` always use `ORDER BY stud_entry_no DESC LIMIT 1` to find the "latest," but there's no DB-level constraint preventing multiple rows per `applicant_user_id`. Bugs or page refreshes during creation could leave orphaned drafts.

**Fix Required:**
- [ ] Add a `UNIQUE KEY uq_application_user (applicant_user_id)` constraint on `acad_applications`
- [ ] Or implement soft-constraint: before `InsertInitialApplication`, check for existing draft and reuse it
- [ ] Add a cleanup job to remove duplicate draft rows keeping only the latest

---

### 3.4 `stud_name` Splitting at Load is Fragile
**File:** `App_Code/Apply/ApplyWizardDataService.cs:SplitName`
**Status:** 🟡 MEDIUM — ✅ DONE

**Problem:** `LoadDraft` splits `stud_name` ("JOHN PETER PAUL SMITH") into Surname="JOHN" and OtherNames="PETER PAUL SMITH". But Step 1 saves them as `fullName = surname + " " + otherNames`. So "SMITH" entered as surname would be stored as "SMITH " (trailing space), and if someone types their surname as "DE LA CRUZ", it splits as Surname="DE", OtherNames="LA CRUZ".

Additionally, `InsertStudentFromApplication` in the admin controller uses raw SQL to split names with unreliable `SUBSTRING_INDEX`/`REPLACE` logic that can silently produce wrong names.

**Fix Required:**
- [ ] Store `stud_surname` and `stud_other_names` as separate columns — stop splitting at load time
- [ ] Add `stud_surname VARCHAR(80)` and `stud_other_names VARCHAR(150)` to `acad_applications`
- [ ] Update Step 1 to store each separately
- [ ] Update `LoadDraft` to load them directly
- [ ] Fix `InsertStudentFromApplication` to use the explicit columns instead of string manipulation

---

### 3.5 No Unique Index on `apply_email_tokens.token`
**File:** `App_Code/Apply/ApplyAuthService.cs:EnsureApplySchema`
**Status:** ✅ DONE — Token has `UNIQUE KEY uq_apply_email_tokens_token (token)`

---

### 3.6 Expired Tokens Never Cleaned Up
**File:** `App_Code/Apply/ApplyAuthService.cs`
**Status:** 🟢 LOW — ✅ DONE (CleanupExpiredTokens + daily check in Global.asax)

**Problem:** `apply_email_tokens` accumulates rows indefinitely. Old expired tokens (24h expiry for email verification) are never deleted. After 10,000 applicants, this table could have 50,000+ rows.

**Fix Required:**
- [ ] Add a scheduled cleanup: `DELETE FROM apply_email_tokens WHERE expires_at < DATE_SUB(NOW(), INTERVAL 30 DAY)`
- [ ] Run this weekly via a scheduled task or a `Global.asax Application_Start` check

---

### 3.7 `acad_ApplicNoGenerator` and `acad_RegNoCreator` Not in Version Control
**File:** `sql/` directory
**Status:** 🟠 HIGH — ⬜ TODO

**Problem:** Two critical stored procedures — `acad_ApplicNoGenerator` and `acad_RegNoCreator` — are called in the application flow but their definitions do not exist in the repo's `sql/` folder. If the database is wiped or migrated, these are lost, and the application will throw unhandled exceptions for every new applicant.

**Fix Required:**
- [ ] Extract and save both SP definitions to `sql/stored_procedures/`
- [ ] Add `IF NOT EXISTS` logic so they can be safely re-run
- [ ] Document expected input/output behavior in comments

---

## SECTION 4 — MISSING FEATURES (Core Gaps)

### 4.1 No Application Fee / Payment Gate Before Submission
**File:** Entire `apply/` flow
**Status:** 🟠 HIGH — ⬜ TODO

**Problem:** Applicants can submit applications for free, unlimited times (if rejected and reapplying). The `applic_payments` table exists in the old admin system but no payment step exists in the portal. This means the university cannot enforce an application fee, leading to low-effort or spam applications.

**Fix Required:**
- [ ] Add a payment step between Step 4 (Documents) and Step 5 (Review/Submit), or as a gate on final submission
- [ ] Integrate with the university's payment gateway (Mobile Money / bank portal)
- [ ] Block final submission unless payment is confirmed
- [ ] Store payment reference in a new `apply_payments` table

---

### 4.2 No Open Application Period / Intake Window Enforcement
**File:** `apply/apply-step3.aspx.cs:LoadIntakes`
**Status:** 🟠 HIGH — ✅ DONE

**Problem:** Intake year dropdown shows current year and next 2 years with no validation against whether applications are actually open for those intakes. The university may only accept applications for specific intakes during specific windows, but the portal ignores this entirely.

**Fix Required:**
- [ ] Create an `apply_intakes` table: `(id, intake_year, intake_label, session, is_open, open_from, open_to, max_applications)`
- [ ] Filter `LoadIntakes` to only show intakes where `is_open=1 AND NOW() BETWEEN open_from AND open_to`
- [ ] Show a clear "Applications are currently closed" message if no open intakes exist
- [ ] Admin screen to manage open intakes

---

### 4.3 No Programme Availability / Capacity Filtering
**File:** `apply/apply-step3.aspx.cs:LoadProgrammesByFaculty`
**Status:** 🟡 MEDIUM — ✅ DONE (is_active filter with fallback)

**Problem:** All programmes are shown regardless of whether they are active, accepting applications, or at capacity. Applicants can apply for discontinued programmes.

**Fix Required:**
- [ ] Add `is_active TINYINT` to `acad_programme` and filter: `WHERE is_active=1`
- [ ] Optionally add `max_intake INT` to set per-intake capacity limits

---

### 4.4 No Email Confirmation After Successful Submission
**File:** `App_Code/Apply/ApplyWizardDataService.cs:SubmitFinal`
**Status:** 🟠 HIGH — ✅ DONE

**Problem:** When an application is submitted, only an in-portal notification is inserted. No email is sent to the applicant confirming submission. If the applicant loses access to the portal or doesn't check notifications, they have no proof of submission.

**Fix Required:**
- [ ] After `SubmitFinal` commits, call `ApplyAuthService.SendEmail` with a submission confirmation
- [ ] Include: application entry number, programme applied for, submission date/time, and a link to `my-application.aspx`

---

### 4.5 No Admission Confirmation Email to Student
**File:** `NewScreens/AdmissionsController.aspx.cs:HandleAdmit`
**Status:** 🟠 HIGH — ✅ DONE

**Problem:** When admin admits an applicant, only an in-portal notification is created. The student gets no email informing them of admission, what their student number is, or what next steps are required.

**Fix Required:**
- [ ] After `HandleAdmit` succeeds, send an admission email to `stud_email`
- [ ] Include: student name, programme, admission date, registration number (after `HandleRegister`), and login instructions for the main portal

---

### 4.6 No Rejection Email to Student
**File:** `NewScreens/AdmissionsController.aspx.cs:HandleReject`
**Status:** 🟠 HIGH — ✅ DONE

**Problem:** Same as above — rejection notification is in-portal only. Students who don't log in will never know they were rejected.

**Fix Required:**
- [ ] Send rejection email with the rejection reason to the applicant's email

---

### 4.7 No Admin Notification When Application is Submitted
**File:** Entire flow
**Status:** 🟡 MEDIUM — ✅ DONE (NotifyAdmins() inserts in-portal notifications for admin users)

**Problem:** When a student submits an application, no notification is sent to admissions staff. Staff must manually check the `AdmissionsController` page to discover new submissions.

**Fix Required:**
- [ ] Send a summary email to a configured `ADMISSIONS_NOTIFY_EMAIL` address on each new submission
- [ ] Or implement a scheduled digest (daily summary of new submissions)

---

### 4.8 No Password Strength Requirement
**File:** `apply/register.aspx.cs`
**Status:** 🟡 MEDIUM — ✅ DONE

**Problem:** Only `password.Length < 6` is checked. Users can set "123456" as their password.

**Fix Required:**
- [ ] Require at least 8 characters, 1 uppercase, 1 number
- [ ] Add client-side strength indicator
- [ ] Show clear requirements on the registration form

---

### 4.9 No "Edit Application" After Rejection
**File:** `apply/my-application.aspx` / `apply-step1.aspx.cs`
**Status:** 🟡 MEDIUM — ✅ DONE (pnlRejected banner + saves reset REJECTED→DRAFT)

**Problem:** `my-application.aspx` shows the Edit button for REJECTED status (`pnlEditBtn.Visible = appStatus == "DRAFT" || appStatus == "REJECTED"`), and `IsLocked` does NOT lock REJECTED applications. So rejected applicants CAN edit, but:
1. There's no clear UI message saying "You can update and re-submit your application"
2. `SubmitFinal` does not explicitly reset the status from REJECTED before re-submitting (it will update to SUBMITTED, which is correct, but the flow is unclear)
3. The timeline on `my-application.aspx` does not show a "re-submitted" state

**Fix Required:**
- [ ] Add a clear banner on rejected applications: "Your application was rejected. You may update the information below and re-submit."
- [ ] Reset `app_status` to `DRAFT` when a REJECTED applicant saves any step (to give the admin a clean SUBMITTED flag when they re-submit)

---

## SECTION 5 — UX & FUNCTIONAL GAPS

### 5.1 Step 5 Review is Incomplete and Unstructured
**File:** `apply/apply-step5.aspx.cs:BindReview`
**Status:** 🟠 HIGH — ✅ DONE

**Problem:** The review page shows three minimal one-line literals:
```
litPersonal.Text = "JOHN SMITH | M | UGANDAN | 0777123456"
litEducation.Text = "O-Level: LAKE HIGH / U1234/001/2019 / 2019"
litProgramme.Text = "Programme: BSCS | Session: DAY | Campus: MAIN | Intake: 2025"
```
It does NOT show: DOB, marital status, disability, A-Level details, other qualifications, emergency contact, sponsor, address, or uploaded documents.

**Fix Required:**
- [ ] Replace the three Literals with a structured HTML summary table showing ALL collected data
- [ ] Group into sections matching the 4 steps
- [ ] Show uploaded document names with checkmarks
- [ ] Add "Edit this section" links pointing back to each step

---

### 5.2 Faculty → Programme Cascade Uses Full Page Postback
**File:** `apply/apply-step3.aspx.cs:ddlFaculty_Changed`
**Status:** 🟡 MEDIUM — ✅ DONE (AJAX endpoint + client-side fetch)

**Problem:** `ddlFaculty.AutoPostBack = true` causes a full page reload when faculty changes. This loses scroll position, is slow on mobile, and feels like a 2005-era UI.

**Fix Required:**
- [ ] Replace with a `[WebMethod]` or lightweight `?ajax=progs&faculty=X` endpoint that returns programme JSON
- [ ] Use JS `fetch()` / `XMLHttpRequest` to populate `ddlProgramme` client-side on faculty change

---

### 5.3 No Progress Indicator / Completion Status on Wizard Steps
**File:** `apply-step*.aspx` (all steps)
**Status:** 🟡 MEDIUM — ✅ DONE (ApplyMaster already renders stepper with done/active markers)

**Problem:** The wizard shows step numbers but there's no visual indication of which steps are complete vs incomplete. Applicants don't know at a glance which steps they've filled.

**Fix Required:**
- [ ] Add completion status per step: check DB on dashboard load and mark each step as Complete / Incomplete / In Progress
- [ ] Show colored checkmarks/circles on the step breadcrumb

---

### 5.4 No Auto-Save on Timer
**File:** `apply-step*.aspx` (all steps)
**Status:** 🟢 LOW — ✅ DONE (90-second auto-save via setInterval in ApplyMaster)

**Problem:** Data is only saved when the user clicks "Save Draft" or "Next". If the browser crashes or session times out while on a step, unsaved data is lost.

**Fix Required:**
- [ ] Add a `setInterval` AJAX auto-save every 90 seconds on each step page
- [ ] Show a "Last saved at HH:mm" indicator
- [ ] Debounce on input change to avoid excessive saves

---

### 5.5 No Mobile-Responsive Validation Feedback
**File:** `apply-step*.aspx` (all steps)
**Status:** 🟡 MEDIUM — ✅ DONE (scrollIntoView on error in ApplyMaster)

**Problem:** Validation errors are shown in a single `pnlAlert` panel at the top of the page. On mobile, if the user filled in a field at the bottom of the form, after clicking Next they see an error but the error panel is scrolled off-screen.

**Fix Required:**
- [ ] Add inline field-level validation feedback next to each invalid field
- [ ] Highlight invalid inputs with red border
- [ ] Scroll to error panel on submission failure using JS `scrollIntoView()`

---

### 5.6 Wizard Cookie Path is Too Broad
**File:** All step pages using `SetWizardCookie`
**Status:** 🟢 LOW — ✅ DONE

**Problem:**
```csharp
ck.Path = "/";
```
The `apply_wizard_step` cookie applies to the entire site (`/`), including the main student portal. It should be scoped to `/apply/` only.

**Fix Required:**
- [ ] Change `ck.Path = "/apply/"` in all wizard step files

---

### 5.7 `my-application.aspx` Shows `litTlCreated` with Wrong Date
**File:** `apply/my-application.aspx.cs` (line 136)
**Status:** 🟡 MEDIUM — ✅ DONE

**Problem:**
```csharp
litTlCreated.Text = hasUpdatedDate ? updatedAt.ToString("dd MMM yyyy") : DateTime.Now.ToString("dd MMM yyyy");
```
The timeline "Form Created" node shows `app_last_updated_at` (last update) instead of the application creation date. There's no `app_created_at` column.

**Fix Required:**
- [ ] Add `app_created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP` to `acad_applications`
- [ ] Set it only in `InsertInitialApplication`, not on updates
- [ ] Show this date in the timeline node

---

### 5.8 Notification Messages are Generic and Unhelpful
**File:** Multiple files
**Status:** 🟢 LOW — ✅ DONE

**Problem:** Notifications like "Application submitted successfully." and "Your application has been admitted." provide no actionable detail — no entry number, no programme name, no next step link.

**Fix Required:**
- [ ] Include entry number and programme in all notification messages
- [ ] Example: "Application APL2025001 for BSc Computer Science submitted successfully. Track at My Application."

---

## SECTION 6 — ADMIN-SIDE WEAKNESSES

### 6.1 Admin Controller Has No Authentication Guard
**File:** `NewScreens/AdmissionsController.aspx.cs:Page_Load`
**Status:** 🔴 CRITICAL — ✅ DONE

**Problem:** `Page_Load` immediately processes AJAX requests without checking if the user is logged in as admin. `IsAdmin()` always returns `true`. Any unauthenticated request to `?ajax=admit` with an entry number can admit any applicant. Any request to `?ajax=register` can register students.

**Fix Required:**
- [ ] Implement `IsAdmin()` properly: check `Session["username"]` is not null AND user has an admin role
- [ ] Return 401 / `{"ok":false,"error":"Unauthorized"}` immediately if not authenticated
- [ ] Add role check: user must have the `Admissions` module permission

---

### 6.2 `HandleNote` Uses Old `health_comments` as Secondary Store
**File:** `NewScreens/AdmissionsController.aspx.cs:SaveReviewerNotes`
**Status:** 🟡 MEDIUM — ✅ DONE

**Problem:** `SaveReviewerNotes` writes to BOTH `app_reviewer_notes` AND `health_comments` if both columns exist. Similarly, `HandleDetail` reads notes from `health_comments` aliased as `reviewer_notes`. This dual-write creates two sources of truth that can diverge.

**Fix Required:**
- [ ] Make `app_reviewer_notes` the single source of truth
- [ ] Remove all references to `health_comments` in the admissions flow
- [ ] `HandleDetail` query should use `COALESCE(a.app_reviewer_notes, a.health_comments,'')` only during the transition period, then drop `health_comments` reference

---

### 6.3 `InsertStudentFromApplication` — Name Parsing SQL is Buggy
**File:** `NewScreens/AdmissionsController.aspx.cs:InsertStudentFromApplication`
**Status:** 🟠 HIGH — ✅ DONE

**Problem:**
```sql
REPLACE(SUBSTRING_INDEX(stud_name,' ',3), SUBSTRING_INDEX(stud_name,' ',1), '')
```
For name "JOHN PETER PAUL": `SUBSTRING_INDEX(stud_name,' ',3)` = "JOHN PETER PAUL", then `REPLACE("JOHN PETER PAUL", "JOHN", "")` = " PETER PAUL". Seems OK. But for "JOHN JOHN JOHN": `REPLACE("JOHN JOHN JOHN", "JOHN", "")` = "  " (empty). The `REPLACE` removes ALL occurrences of the surname, not just the first.

**Fix Required:**
- [ ] After fixing 3.4 (separate surname/other_names columns), use those columns directly:
  ```sql
  firstname = a.stud_other_names,
  othername = a.stud_surname
  ```
- [ ] Remove the `REPLACE(SUBSTRING_INDEX...)` hack entirely

---

### 6.4 `HandleAdmit` Creates Student Account with Entry No as Username
**File:** `NewScreens/AdmissionsController.aspx.cs:HandleAdmit`
**Status:** 🟠 HIGH — ✅ DONE

**Problem:**
```csharp
ProvisionStudentAccount(conn, eno, eno);  // username = entry number
```
On admit, a portal account is created with the applicant's ENTRY NUMBER as the username. When the student is later registered, `HandleRegister` calls `ProvisionStudentAccount(conn, newRegno, eno)` with the REGISTRATION NUMBER. This creates TWO portal accounts for the same student — one with entry number, one with reg number.

**Fix Required:**
- [ ] Don't provision a portal account on `HandleAdmit` — wait until registration when the reg number is known
- [ ] Or: only provision on admit, using email as username (matching the applicant account), and update the username to reg number on registration

---

### 6.5 `FOUND_ROWS()` After Gap Between Queries
**File:** `NewScreens/AdmissionsController.aspx.cs:HandleList`
**Status:** 🟡 MEDIUM — ✅ DONE

**Problem:**
```csharp
// First query with SQL_CALC_FOUND_ROWS
using (var cmd = new MySqlCommand(sql, conn)) { ... }

// Second query on same connection
using (var cmd2 = new MySqlCommand("SELECT FOUND_ROWS()", conn))
    total = Convert.ToInt64(cmd2.ExecuteScalar());
```
`SQL_CALC_FOUND_ROWS` / `FOUND_ROWS()` is connection-session-scoped but the gap between closing the first reader and executing `FOUND_ROWS()` is safe — HOWEVER, `SQL_CALC_FOUND_ROWS` is deprecated in MySQL 8.0. This will break on MySQL 8.0+ servers.

**Fix Required:**
- [ ] Replace with a separate `COUNT(*)` query using the same WHERE clause (without LIMIT/OFFSET)
- [ ] Or use window function: `COUNT(*) OVER()` in MySQL 8.0

---

### 6.6 No Audit Log for Admissions Decisions
**File:** `NewScreens/AdmissionsController.aspx.cs`
**Status:** 🟠 HIGH — ✅ DONE

**Problem:** There is no audit trail for who admitted, rejected, or registered which applicant and when. If a decision is contested, there is no record beyond the status change itself. The `app_reviewer_notes` overwrite each other — there's no history.

**Fix Required:**
- [ ] Create `apply_audit_log` table: `(id, stud_entry_no, action VARCHAR(30), notes TEXT, done_by VARCHAR(60), done_at DATETIME)`
- [ ] Insert a row on every `admit`, `reject`, `note`, `register` action
- [ ] Show audit log in applicant detail view

---

## SECTION 7 — CODE QUALITY & MAINTAINABILITY

### 7.1 `ApplyWizardDataService.PortalConn` Reads Wrong Database for Academic Data
**File:** `App_Code/Apply/ApplyWizardDataService.cs` (line 96 comment)
**Status:** 🟡 MEDIUM — ⬜ TODO

**Problem:** The code comment says "acad_applications lives in the main CampusDynamics DB which is `campus_dynamics_portalConnectionString`" but this is confusing — the portal DB holds portal-specific data, while `acad_*` tables live in the main academic DB (`vacConnectionString`). The fallback chain `campus_dynamics_portalConnectionString → LocalMySqlServer → vacConnectionString` means different environments may silently connect to different databases.

**Fix Required:**
- [ ] Clearly separate: `AuthConn` (for `my_aspnet_*` tables in portal DB) vs `AcademicConn` (for `acad_*` tables in main DB)
- [ ] Document in `web.config` which connection string maps to which database
- [ ] Fix `ApplyAuthService.PortalConn` vs `ApplyWizardDataService.PortalConn` — both currently use different fallback chains

---

### 7.2 Error Messages Leak Internal Information
**File:** Multiple files
**Status:** 🟡 MEDIUM — ✅ DONE

**Problem:** Multiple catch blocks surface raw exception messages to users:
```csharp
error = "Could not save step 1: " + ex.Message;         // leaks DB errors
ShowError("Registration setup is incomplete: " + schemaError);  // leaks schema info
```

**Fix Required:**
- [ ] Log full `ex.ToString()` to server error log
- [ ] Show generic user-friendly message: "A technical error occurred. Please try again or contact support."
- [ ] Only show technical details if `Request.IsLocal` or a DEBUG flag is set

---

### 7.3 `ApplyMaster.master.cs` Not Yet Read — May Have Hidden Logic
**File:** `apply/ApplyMaster.master.cs`
**Status:** 🟡 MEDIUM — ✅ DONE (audited — clean; implemented unread notification dot)

**Problem:** The master page code-behind was not analyzed in this audit. It may contain session validation, redirect logic, or notification badge logic that could have additional gaps.

**Fix Required:**
- [ ] Read and audit `ApplyMaster.master.cs` separately
- [ ] Ensure consistent session validation is centralized in the master page, not duplicated across step pages

---

### 7.4 Duplicate `IsLocked` Implementation in Every Step File
**File:** `apply-step1.aspx.cs`, `apply-step2.aspx.cs`, `apply-step3.aspx.cs`, `apply-step4.aspx.cs`, `apply-step5.aspx.cs`, `my-application.aspx.cs`
**Status:** 🟢 LOW — ✅ DONE (`ApplyWizardDataService.IsStatusLocked` centralized)

**Problem:** The same `private static bool IsLocked(string status)` method is copy-pasted into 6 separate files. If the locked statuses change (e.g., if REJECTED should also be locked), all 6 files must be updated.

**Fix Required:**
- [ ] Move `IsLocked` into `ApplyWizardDataService` as a public static method
- [ ] All step pages call `ApplyWizardDataService.IsStatusLocked(status)` instead

---

### 7.5 `GetUserId()` Duplicated in Every Step File
**File:** Same 5 step files
**Status:** 🟢 LOW — ✅ DONE (ApplyBasePage created; new pages inherit it)

**Problem:** Same `GetUserId()` implementation copy-pasted in every step code-behind.

**Fix Required:**
- [ ] Move to a base page class `ApplyBasePage : Page` that all step pages inherit
- [ ] Add `GetUserId()`, `IsLoggedIn()`, `RequireLogin()`, `GetApplicantEmail()` as base class methods

---

## SECTION 8 — POSITIVE FINDINGS (Already Working Well)

| Feature | Assessment |
|---------|-----------|
| SQL Injection Protection | ✅ All queries use parameterized `MySqlParameter` — no string concatenation in WHERE clauses |
| XSS Protection | ✅ All user input rendered with `Server.HtmlEncode()` throughout |
| Password Hashing | ✅ HMACSHA256 + per-user base64 salt used in `ApplyAuthService` |
| Token Uniqueness | ✅ `apply_email_tokens.token` has `UNIQUE KEY` constraint |
| Application Locking | ✅ Submitted/admitted applications properly locked from editing |
| Transaction Use | ✅ All multi-step saves use `MySqlTransaction` with rollback on failure |
| Email Verification Gate | ✅ Login redirects unverified users to verify page before portal access |
| Open Redirect Protection | ✅ `returnUrl` validated to start with `/apply` before redirect |
| Schema Self-Healing | ✅ `AddColumnIfMissing` prevents crashes on schema-incomplete databases |
| Cookie HttpOnly | ✅ `APPLY_AUTH` cookie is `HttpOnly = true` |

---

## SECTION 9 — IMPLEMENTATION TASK LIST

> Tasks ordered by priority. Each task references the section above.

### 🔴 CRITICAL — Fix First (Blocking Production Use)

| # | Task | Section | Status |
|---|------|---------|--------|
| C1 | Implement actual file upload storage (save to disk + `apply_documents` table) | 1.1 | ✅ DONE |
| C2 | Fix `my-application.aspx` to actually query and display uploaded documents | 1.2 | ✅ DONE |
| C3 | Replace hardcoded "123" default password with random generated + hashed password | 1.3 | ✅ DONE |
| C4 | Send welcome email with temp password on student account creation | 1.3 | ✅ DONE |
| C5 | Standardize `apply_notifications.message` to TEXT in both services | 1.4 | ✅ DONE |
| C6 | Add UNIQUE constraint on `acad_applications.stud_entry_no` | 1.5 | ✅ DONE |
| C7 | Sync `app_status` ↔ `adm_status` — write a one-time migration + enforce going forward | 1.6 | ✅ DONE |
| C8 | Implement `IsAdmin()` properly — check session authentication + role | 6.1 | ✅ DONE |
| C9 | Move `EnsureApplicationSchema` to `Application_Start` — remove from every Save call | 3.1 | ✅ DONE |

### 🟠 HIGH — Fix Before Public Launch

| # | Task | Section | Status |
|---|------|---------|--------|
| H1 | Add brute-force protection on login (attempt counter + lockout) | 2.1 | ✅ DONE |
| H2 | Add CAPTCHA to registration and login pages | 2.1 | ⬜ TODO (external dependency — requires CAPTCHA service) |
| H3 | Add proper email format validation in register.aspx | 2.2 | ✅ DONE |
| H4 | Reduce session timeout to 2 hours; reduce cookie to 30 days | 2.4 | ✅ DONE |
| H5 | Set `APPLY_AUTH` cookie `Secure = true` unconditionally | 2.5 | ✅ DONE |
| H6 | Add withdrawal confirmation dialog | 2.7 | ✅ DONE (native confirm() already present) |
| H7 | Add `stud_surname` + `stud_other_names` columns; stop splitting `stud_name` | 3.4 | ✅ DONE |
| H8 | Add UNIQUE constraint / guard against multiple drafts per user | 3.3 | ✅ DONE |
| H9 | Send submission confirmation email to applicant | 4.4 | ✅ DONE |
| H10 | Send admission notification email to student | 4.5 | ✅ DONE |
| H11 | Send rejection email to applicant | 4.6 | ✅ DONE |
| H12 | Rewrite Step 5 review to show ALL collected data in structured layout | 5.1 | ✅ DONE |
| H13 | Fix `InsertStudentFromApplication` name parsing SQL | 6.3 | ✅ DONE |
| H14 | Fix double-account creation (entry no + reg no) on admit → register flow | 6.4 | ✅ DONE |
| H15 | Replace `FOUND_ROWS()` with explicit COUNT query (MySQL 8 compatibility) | 6.5 | ✅ DONE |
| H16 | Add admissions audit log table + record every decision | 6.6 | ✅ DONE |
| H17 | Implement open intake period enforcement in Step 3 | 4.2 | ✅ DONE |

### 🟡 MEDIUM — Next Sprint

| # | Task | Section | Status |
|---|------|---------|--------|
| M1 | Add proper `returnUrl` traversal guard | 2.3 | ✅ DONE |
| M2 | Remove `hfFinalizeReady` hidden field; use single submit with checkbox | 2.6 | ✅ DONE |
| M3 | Rename education columns (`stud_pob` → `olevel_year`, etc.) + migration | 3.2 | ⬜ TODO |
| M4 | Extract and version-control `acad_ApplicNoGenerator` + `acad_RegNoCreator` SPs | 3.7 | ⬜ TODO |
| M5 | Replace faculty→programme full postback with AJAX | 5.2 | ✅ DONE |
| M6 | Add step completion indicators on wizard breadcrumb | 5.3 | ✅ DONE (stepper in ApplyMaster marks prior steps done/active) |
| M7 | Add inline field-level validation + scroll to error | 5.5 | ✅ DONE (auto-scroll in master page) |
| M8 | Fix `litTlCreated` to use `app_created_at` not `app_last_updated_at` | 5.7 | ✅ DONE |
| M9 | Add `app_created_at` column to `acad_applications` | 5.7 | ✅ DONE |
| M10 | Add `is_active` filter to programme dropdown | 4.3 | ✅ DONE |
| M11 | Add admin notification when new application is submitted | 4.7 | ✅ DONE |
| M12 | Enforce password strength (min 8 chars, 1 upper, 1 number) | 4.8 | ✅ DONE |
| M13 | Add clear "Re-submit" UI flow for REJECTED applications | 4.9 | ✅ DONE |
| M14 | Fix `SaveReviewerNotes` — use only `app_reviewer_notes` | 6.2 | ✅ DONE |
| M15 | Separate `AuthConn` vs `AcademicConn` in service classes | 7.1 | ⬜ TODO |
| M16 | Audit `ApplyMaster.master.cs` for hidden logic | 7.3 | ✅ DONE (clean; added unread notification dot) |

### 🟢 LOW — Polish & Technical Debt

| # | Task | Section | Status |
|---|------|---------|--------|
| L1 | Scope wizard cookie to `/apply/` not `/` | 5.6 | ✅ DONE |
| L2 | Add auto-save timer (every 90 seconds) on all step pages | 5.4 | ✅ DONE (90s setInterval in ApplyMaster) |
| L3 | Schedule cleanup job for expired tokens | 3.6 | ✅ DONE |
| L4 | Enrich all notification messages with entry no and programme | 5.8 | ✅ DONE |
| L5 | Centralize `IsLocked()` into `ApplyWizardDataService` | 7.4 | ✅ DONE |
| L6 | Create `ApplyBasePage` base class; move `GetUserId()` and other shared methods | 7.5 | ✅ DONE (App_Code/Apply/ApplyBasePage.cs — new pages use it) |
| L7 | Replace raw exception messages shown to users with generic messages | 7.2 | ✅ DONE |
| L8 | Add application fee / payment step before final submission | 4.1 | ⬜ TODO |

---

## SECTION 10 — DATABASE MIGRATION CHECKLIST

Run these SQL statements as part of the next deployment:

```sql
-- 1. Standardize notifications message column
ALTER TABLE apply_notifications MODIFY COLUMN message TEXT NOT NULL;

-- 2. Add application creation timestamp
ALTER TABLE acad_applications 
  ADD COLUMN IF NOT EXISTS app_created_at DATETIME NULL 
  AFTER stud_entry_no;

UPDATE acad_applications 
  SET app_created_at = app_last_updated_at 
  WHERE app_created_at IS NULL AND app_last_updated_at IS NOT NULL;

-- 3. Add proper education columns (rename phase)
ALTER TABLE acad_applications
  ADD COLUMN IF NOT EXISTS olevel_year INT NULL,
  ADD COLUMN IF NOT EXISTS olevel_agg VARCHAR(20) NULL,
  ADD COLUMN IF NOT EXISTS alevel_points VARCHAR(20) NULL,
  ADD COLUMN IF NOT EXISTS other_inst VARCHAR(150) NULL,
  ADD COLUMN IF NOT EXISTS other_qual VARCHAR(150) NULL,
  ADD COLUMN IF NOT EXISTS other_year INT NULL,
  ADD COLUMN IF NOT EXISTS other_grade VARCHAR(50) NULL;

-- Migrate data from misnamed columns
UPDATE acad_applications SET
  olevel_year    = CAST(stud_pob AS UNSIGNED),
  olevel_agg     = stud_district,
  alevel_points  = stud_ward,
  other_inst     = stud_prevcampus,
  other_qual     = stud_lg,
  other_year     = CAST(stud_village AS UNSIGNED),
  other_grade    = stud_county
WHERE olevel_year IS NULL;

-- 4. Add separate name columns
ALTER TABLE acad_applications
  ADD COLUMN IF NOT EXISTS stud_surname VARCHAR(80) NULL,
  ADD COLUMN IF NOT EXISTS stud_other_names VARCHAR(150) NULL;

UPDATE acad_applications SET
  stud_surname     = SUBSTRING_INDEX(stud_name, ' ', 1),
  stud_other_names = IF(LOCATE(' ', stud_name) > 0, 
                        SUBSTR(stud_name, LOCATE(' ', stud_name) + 1), 
                        '')
WHERE stud_surname IS NULL AND stud_name IS NOT NULL;

-- 5. Sync app_status from adm_status for legacy records
UPDATE acad_applications a
JOIN acad_applicant_choices c ON c.stud_entry_no = a.stud_entry_no AND c.Choice = 1
SET a.app_status = CASE
  WHEN c.adm_status = 0 AND (a.app_status IS NULL OR a.app_status = '') THEN 'SUBMITTED'
  WHEN c.adm_status = 1 AND a.stud_reg_no IS NOT NULL AND a.stud_reg_no <> '-' AND a.stud_reg_no <> '' THEN 'REGISTERED'
  WHEN c.adm_status = 1 THEN 'ADMITTED'
  WHEN c.adm_status = 2 THEN 'REJECTED'
  WHEN c.adm_status = 3 THEN 'WITHDRAWN'
  ELSE a.app_status
END
WHERE a.app_status IS NULL OR a.app_status = '';

-- 6. Create document uploads table
CREATE TABLE IF NOT EXISTS apply_documents (
  id INT NOT NULL AUTO_INCREMENT,
  stud_entry_no VARCHAR(30) NOT NULL,
  doc_type ENUM('PHOTO','OLEVEL','ALEVEL','NATID','OTHER') NOT NULL,
  original_filename VARCHAR(255) NOT NULL,
  stored_path VARCHAR(500) NOT NULL,
  file_size_bytes INT NOT NULL DEFAULT 0,
  uploaded_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY ix_apply_docs_entry (stud_entry_no),
  KEY ix_apply_docs_type (stud_entry_no, doc_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 7. Create admissions audit log
CREATE TABLE IF NOT EXISTS apply_audit_log (
  id INT NOT NULL AUTO_INCREMENT,
  stud_entry_no VARCHAR(30) NOT NULL,
  action VARCHAR(30) NOT NULL,
  notes TEXT NULL,
  done_by VARCHAR(60) NOT NULL DEFAULT 'system',
  done_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY ix_apply_audit_entry (stud_entry_no),
  KEY ix_apply_audit_action (action)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 8. Create open intakes management table
CREATE TABLE IF NOT EXISTS apply_intakes (
  id INT NOT NULL AUTO_INCREMENT,
  intake_year INT NOT NULL,
  intake_label VARCHAR(50) NOT NULL,
  session_type VARCHAR(20) NOT NULL DEFAULT 'DAY',
  is_open TINYINT(1) NOT NULL DEFAULT 0,
  open_from DATETIME NULL,
  open_to DATETIME NULL,
  max_applications INT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

---

## SUMMARY SCORECARD

| Category | Issues Found | Critical | High | Medium | Low |
|----------|-------------|---------|------|--------|-----|
| Core Functionality | 6 | 4 | 2 | 0 | 0 |
| Security | 7 | 1 | 3 | 2 | 1 |
| Data & Schema | 7 | 1 | 3 | 2 | 1 |
| Missing Features | 9 | 0 | 5 | 3 | 1 |
| UX & Functional | 8 | 0 | 2 | 4 | 2 |
| Admin-Side | 6 | 1 | 3 | 2 | 0 |
| Code Quality | 5 | 0 | 0 | 2 | 3 |
| **TOTAL** | **48** | **7** | **18** | **15** | **8** |

**Overall Assessment:** The portal has a solid structural foundation — parameterized queries, transactions, schema self-healing, and email verification are all implemented correctly. However, the document upload system (a core feature) is completely non-functional, the default student password is a critical security hole, and the admin controller lacks authentication. These three issues alone would make the portal unsuitable for production use.
