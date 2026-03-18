# Human Resource Module - Complete Analysis

## 1. FILE INVENTORY

### COOPERP/HumanResource/ (Main Pages)
| File | Purpose |
|------|---------|
| Default.aspx / .cs | Dynamic page loader - uses `HumanResourceLoader.PageLocator(pid)` to load UserControls based on `?pid=` query string |
| LeaveManagementCentre.aspx / .cs | Hosts `AnnualLeavel.ascx` user control for annual leave management |
| LeaveTracking.aspx / .cs | Standalone popup page for tracking individual leave records (dates taken) |
| ParttimePayRates.aspx / .cs | Hosts `PayrollSpecialRates.ascx` for managing part-time/consultant pay rates |
| PopUps.aspx / .cs | Dynamic popup loader - same pattern as Default.aspx, loads UserControls by pid |
| StaffProfile.aspx / .cs | Popup showing individual staff bio data, salary history, and photo upload |
| TeachingCentre.aspx / .cs | Hosts `hr_teaching_allocation.ascx` for academic teaching allocation |
| MasterPage.master / .cs | HR module master page with navigation menu |
| Reports/Default.aspx / .cs | Crystal Reports viewer for LargePayroll report |
| Reports/xtraReportCentre.aspx / .cs | DevExpress XtraReports viewer for Payroll and SpecialPayroll reports |
| Reports/LargePayroll.rpt | Crystal Reports template for full payroll report |

### UserControls/HumanResource/ (Core Business Logic)
| File | Purpose |
|------|---------|
| Employee.ascx / .cs | Staff registration & management (CRUD on hrm_employee) |
| ContractInfo.ascx / .cs | Employment contracts, job assignments, SMS to staff |
| AnnualLeavel.ascx / .cs | Annual leave allocation per year, leave tracking launcher |
| Payroll.ascx / .cs | Payroll period management (create/edit payroll runs) |
| PayrollDetails.ascx / .cs | Payroll details: staff list, deductions/allowances tab, special payments tab, documents tab |
| MonthlyDeductionAllowance.ascx / .cs | Assign monthly deductions/allowances to staff per payroll |
| Deductions_Allowances.ascx / .cs | Master list of all deduction/allowance definitions |
| DedAllowanceList.ascx / .cs | Staff list for a specific optional deduction/allowance |
| PayrollSpecialRates.ascx / .cs | Part-time/consultant pay rate configuration |
| JobsDepartments.ascx / .cs | Settings: Jobs, Departments, Banks, Salary Scales (4 tabs) |
| DocumentCentre.ascx / .cs | Print center for payroll documents (Main Payroll, PAYE, NSSF, Bank Schedule, etc.) |
| XtraReportsPrinter.ascx / .cs | DevExpress report renderer for MainPayroll, PayrollByStation, BankSchedule, PAYE, NSSF, StaffID |

### UserControls/HumanResource/TeacherMgt/ (Academic Staff)
| File | Purpose |
|------|---------|
| teachermgt.ascx / .cs | Academic staff list with profile popup |
| TutorManagement.ascx / .cs | Tutor management with same employee grid |
| AcademicStaffDetails.ascx / .cs | Subject/class allocation for academic staff, tutor group management |

### App_Code/HumanResource/
| File | Purpose |
|------|---------|
| HRMData.xsd | Typed DataSet with all table adapters |
| HRMData.xss | DataSet UI layout |
| Reports/GeneralPayroll.cs | XtraReport class for general payroll |
| Reports/SpecialPayments.cs | XtraReport class for special payments |

---

## 2. NAVIGATION MENU (MasterPage.master)

```
Control Panel          → ~/MyApplications.aspx
Staff Information      → ~/COOPERP/HumanResource/Default.aspx (pid=0 → Employee.ascx)
Leave Management       → ~/COOPERP/HumanResource/LeaveManagementCentre.aspx
Contract Information   → ~/COOPERP/HumanResource/Default.aspx?pid=1 (→ ContractInfo.ascx)
Payroll Management (submenu):
  ├── Payroll Centre           → Default.aspx?pid=3 (→ Payroll.ascx)
  ├── Payroll Ledger Posting   → (Disabled)
  ├── Deductions & Allowances  → Default.aspx?pid=5 (→ Deductions_Allowances.ascx)
  └── Parttime Pay Rates       → ParttimePayRates.aspx (→ PayrollSpecialRates.ascx)
Document Centre        → (menu item exists, no direct link)
```

### Page Routing (HumanResourceLoader.PageLocator):
| pid | UserControl Loaded |
|-----|--------------------|
| 0 (default) | Employee.ascx (Staff Information) |
| 1 | ContractInfo.ascx |
| 2 | JobsDepartments.ascx (via popup from ContractInfo) |
| 3 | Payroll.ascx |
| 4 | PayrollDetails.ascx (via popup from Payroll) |
| 5 | Deductions_Allowances.ascx |
| 6 | DedAllowanceList.ascx (via popup from Deductions) |
| 7 | XtraReportsPrinter.ascx (via popup from DocumentCentre/ContractInfo) |

---

## 3. DATABASE TABLES (All from HRMData.xsd)

### 3.1 `hrm_employee` — Core Staff Table
| Column | Type | Description |
|--------|------|-------------|
| empID | uint (PK, auto) | Employee ID |
| emp_name | string | Full name |
| emp_birthdate | datetime | Date of birth |
| emp_phone | string | Phone contact |
| emp_email | string | Email address |
| emp_qualifications | string (memo) | Qualifications description |
| emp_nationality | string | Nationality (UGANDAN, KENYAN, TANZANIAN, RWANDAN, SOUTH SUDANESE) |
| bankID | uint (FK→banks) | Bank reference |
| bankAccount | string | Bank account number |
| nssf_no | string | NSSF number |
| EmpType | string | Category: Academic, Administrative, Support, Consultant, Adjunct, Parttime |
| marital_status | string | SINGLE, MARRIED, DIVORCED |
| address | string | Address |
| religion | string | Religion |
| tribe | string | Tribe |
| spouse_name | string | Spouse name |
| no_children | uint | Number of children |
| contact_person | string | Emergency contact |
| relation | string | Relationship to contact |
| phone_contacts | string | Contact phone |
| current_residence | string | Current residence |
| father_name | string | Father's name |
| mother_name | string | Mother's name |
| referee_1 | string | Referee 1 |
| referee_2 | string | Referee 2 |
| medical_background | string (memo) | Medical info |
| schooling_info | string (memo) | Academic/professional training |
| employment_info | string (memo) | Employment history |
| usernames | string | System username |
| EMP_CODE | string | Staff code (e.g., MRU0001) |
| Entry_Year | uint | Year of entry |
| Entry_Satation | string | Entry station/campus |
| tin | string | Tax Identification Number |
| max_education | string | Education level: Certificate, Diploma, Bachelors, Masters, PHD, Proffessor, NA |

**Queries:**
- `Fill` / `GetData`: `SELECT hrm_employee.* FROM hrm_employee`
- `FillBy_AcademicStaff`: `WHERE EmpType = 'ACADEMIC'`
- `GetPhone`: `SELECT emp_phone WHERE empID=@ID`
- `MyName`: `SELECT emp_name WHERE empID=@ID`
- `NextStaffCode`: `SELECT MAX(SUBSTRING(EMP_CODE,4,4))+1 FROM hrm_employee`
- `SingleStaff` / `GetSingleStaff`: `WHERE empID = @ID`
- Full CRUD (Insert, Update, Delete)

### 3.2 `hrm_emp_contracts` — Employment Contracts
| Column | Type | Description |
|--------|------|-------------|
| ID | uint (PK, auto) | Contract ID |
| empID | uint (FK→hrm_employee) | Employee reference |
| contractStart | datetime | Contract start date |
| contractEnd | datetime | Contract end/expiry date |
| jobID | uint (FK→hrm_jobs) | Job reference |
| departmentID | uint (FK→hrm_departments) | Department reference |
| comments | string | Contract comments |
| contractStatus | string | VALID, EXPIRED, TERMINATED, RESIGNED |
| payscale | uint (FK→hrm_payscales) | Pay scale reference |
| fixedamount | double | Fixed contract amount |

**Queries:**
- `Fill` / `GetData`: `SELECT hrm_emp_contracts.* FROM hrm_emp_contracts`
- `GetValidContracts`: `WHERE contractStatus='VALID'` with JOIN to hrm_employee for emp_name
- Full CRUD

### 3.3 `hrm_payroll` — Payroll Periods
| Column | Type | Description |
|--------|------|-------------|
| ID | uint (PK, auto) | Payroll ID |
| payroll_title | string | Payroll title (e.g., "January 2026 Payroll") |
| payroll_month | string | Month name |
| payroll_year | uint | Year |
| payroll_comments | string | Comments |
| prepared_by | uint (FK→hrm_employee) | Prepared by employee |
| checked_by | uint (FK→hrm_employee) | Checked by employee |
| approved_by | uint (FK→hrm_employee) | Approved by employee |
| total_amount | double | Total payroll amount |
| lockStatus | byte (bool) | Lock status (locked = can't edit) |
| payroll_date | datetime | Payroll date |
| expected_days | int | Expected working days |

**Queries:**
- `Fill` / `GetData`: `SELECT hrm_payroll.* ORDER BY ID DESC`
- `PayrollByID`: `WHERE ID = @pid ORDER BY ID DESC`
- Full CRUD

### 3.4 `hrm_payroll_details` — Individual Payroll Line Items
| Column | Type | Description |
|--------|------|-------------|
| ID | uint (PK, auto) | Detail ID |
| payrollID | uint (FK→hrm_payroll) | Payroll period reference |
| empID | uint (FK→hrm_employee) | Employee reference |
| basic_pay | double | Basic salary |
| paye | double | PAYE tax |
| nssf | double | NSSF contribution |
| total_allowances | double | Sum of all allowances |
| total_deductions | double | Sum of other deductions |
| gross_pay | double | Gross pay (basic + allowances) |
| net_pay | double | Net pay (gross - all deductions) |
| days_attended | int | Days attended |

**Queries:**
- `Fill` / `GetData`: `SELECT hrm_payroll_details.* FROM hrm_payroll_details`
- `GetPayrollDetails`: `CALL hrm_GetPayrollDetails(@pid)` (stored procedure)
- `GetPayrollDetailsByBranch`: `CALL hrm_GetPayrollBranchDetails(@pid,@bname)` (SP)
- `DetailsByPayroll`: By payroll ID (for reports)
- Full CRUD

### 3.5 `hrm_allowance_deductions` — Deduction/Allowance Definitions
| Column | Type | Description |
|--------|------|-------------|
| ID | uint (PK, auto) | ID |
| dedall_name | string | Name (e.g., "Housing Allowance", "Loan Repayment") |
| dedall_type | string | STATUTORY, MANDATORY, OPTIONAL |
| dedall_amount | double | Default amount |
| computation_by | string | PERCENTAGE, PERCENT - TAX, FIXED, DYNAMIC, FORMULA, ATTENDANCE |
| ded_allowance | string | "Allowance" or "Deduction" |

**Queries:**
- `Fill` / `GetData`: `SELECT hrm_allowance_deductions.* FROM hrm_allowance_deductions`
- `GetDedAllowanceByType`: `WHERE ded_allowance=@typ`
- Full CRUD

### 3.6 `hrm_ded_allowance_stafflist` — Staff Assigned to Specific Deductions/Allowances
| Column | Type | Description |
|--------|------|-------------|
| ID | uint (PK, auto) | ID |
| ded_allID | uint (FK→hrm_allowance_deductions) | Deduction/allowance reference |
| empID | uint (FK→hrm_employee) | Employee reference |
| custom_amount | double | Custom amount for this employee (overrides default) |

**Queries:**
- `Fill` / `GetData`: Full select
- `GetStaffByDedAllowance`: `WHERE ded_allID = @dedAllID`
- `AddAllStaffOnDedAllowance`: `CALL hrm_AddAllStaffOnDedAllowance(@dedID)` (SP)
- Full CRUD

### 3.7 `hrm_monthly_ded_allowance` — Monthly Deductions/Allowances per Payroll
| Column | Type | Description |
|--------|------|-------------|
| ID | uint (PK, auto) | ID |
| payrollID | uint (FK→hrm_payroll) | Payroll period reference |
| empID | uint (FK→hrm_employee) | Employee reference |
| amount | double | Amount for this month |
| typ | string | "Allowance" or "Deduction" |
| ded_allID | uint (FK→hrm_allowance_deductions) | Deduction/allowance reference |

**Queries:**
- `Fill` / `GetData`: Full select
- `GetSingleMonthlyDedAllowancesList`: `CALL hrm_GenerateMonthlyDedAllowanceList(@pid, @dedAllID, @dedtyp, @act, @bid)` (SP - generates/displays list)
- `SaveChanges`: `UPDATE SET amount = @amount WHERE ID = @Original_ID`
- Full CRUD

### 3.8 `hrm_exemptions` — Employee Exemptions from Deductions
| Column | Type | Description |
|--------|------|-------------|
| ID | uint (PK, auto) | ID |
| empID | uint (FK→hrm_employee) | Employee |
| ded_allID | uint (FK→hrm_allowance_deductions) | Exempted deduction/allowance |

**Queries:** Full CRUD

### 3.9 `hrm_departments` — Departments
| Column | Type | Description |
|--------|------|-------------|
| ID | uint (PK, auto) | Department ID |
| dept_name | string | Department name |
| dept_headID | uint (FK→hrm_employee) | Head of department |

**Queries:** Full CRUD

### 3.10 `hrm_jobs` — Job Titles
| Column | Type | Description |
|--------|------|-------------|
| ID | uint (PK, auto) | Job ID |
| jobname | string | Job title |
| min_qualifications | string | Minimum qualifications |

**Queries:** Full CRUD

### 3.11 `hrm_payscales` — Salary Scales
| Column | Type | Description |
|--------|------|-------------|
| ID | uint (PK, auto) | Scale ID |
| scale_name | string | Scale code/name |
| basicpay | double | Basic pay amount |

**Queries:** Full CRUD, ordered by `basicpay DESC`

### 3.12 `banks` — Banks (shared table)
| Column | Type | Description |
|--------|------|-------------|
| bank_id | uint (PK, auto) | Bank ID |
| bank_name | string | Bank name |

**Queries:** Full CRUD, ordered by `bank_name`

### 3.13 `hrm_stations` — Work Stations/Campuses
| Column | Type | Description |
|--------|------|-------------|
| ID | uint (PK, auto) | Station ID |
| station_name | string | Station/campus name |

**Queries:** Full CRUD, ordered by `station_name`

### 3.14 `hrm_annual_leave` — Annual Leave Allocations
| Column | Type | Description |
|--------|------|-------------|
| ID | uint (PK, auto) | Leave allocation ID |
| empID | uint (FK→hrm_employee) | Employee |
| leave_year | uint | Year |
| default_days | uint | Default leave days (typically 30) |

**Additional computed fields from stored procedure (hrm_GetLeaveListByYear):**
- `emp_name` — Joined from hrm_employee
- `taken` — Days already taken
- `balance` — Remaining days

**Queries:**
- `GetLeaveByYear`: `CALL hrm_GetLeaveListByYear(@yr)` (SP)
- `hrm_CreateAnnualLeaveList`: `CALL hrm_CreateAnnualLeaveList(@yr, @def_days)` (SP - bulk creates leave records for all staff)
- Full CRUD

### 3.15 `hrm_leave_taken` — Individual Leave Records
| Column | Type | Description |
|--------|------|-------------|
| ID | uint (PK, auto) | Record ID |
| leaveID | uint (FK→hrm_annual_leave) | Annual leave allocation reference |
| startDate | datetime | Leave start date |
| endDate | datetime | Leave end date |
| no_days | uint | Number of days |

**Queries:**
- `GetLeaveTrackInfo`: `SELECT DATEDIFF(endDate,startDate) AS no_days, ID, leaveID, startDate, endDate FROM hrm_leave_taken WHERE leaveID=@lid ORDER BY startDate DESC`
- Full CRUD

### 3.16 `hrm_part_time_rates` — Part-time/Consultant Pay Rates
| Column | Type | Description |
|--------|------|-------------|
| ID | int (PK, auto) | Rate ID |
| staff_code | int (FK→hrm_employee.empID) | Staff reference |
| effect_date | datetime | Effective date |
| cur_status | string | Active, Suspended, InActive, Terminated |
| qualification | string | Qualification |
| pay_rate | double | Hourly/unit pay rate |
| pay_type | string | Parttime, Consultant, Special Payment, HOD Facilitation |

**Queries:**
- `GetPartTimeRatesList`: `SELECT emp_name, pt.* FROM hrm_part_time_rates pt, hrm_employee e WHERE empID=staff_code ORDER BY emp_name`
- Full CRUD

### 3.17 `hrm_special_payments` — Special/Part-time Payroll
| Column | Type | Description |
|--------|------|-------------|
| ID | int (PK, auto) | Payment ID |
| payroll_id | int (FK→hrm_payroll) | Payroll period reference |
| hours | double | Hours taught/worked |
| pay_rate | double | Pay rate per hour |
| gross_pay | double | Gross = hours × pay_rate |
| deductions | double | Deductions |
| net_pay | double | Net = gross - deductions |
| staff_code | int (FK→hrm_employee.empID) | Staff reference |
| pay_type | string | Payment category |

**Additional joined fields (from views/queries):**
- emp_name, bankAccount, bank_name, emp_phone, payroll_title

**Queries:**
- `GetSpecialPayList`: `WHERE payroll_id=@pid` with employee/bank joins
- `hrm_CreateSpecialPayList`: `CALL hrm_CreateSpecialPayList(@pid)` (SP - generates list from rates)
- `DeleteBlanks`: `DELETE WHERE net_pay=0 AND payroll_id=@pid`
- `SpecialPayList`: For report printing with full joins
- Full CRUD

### 3.18 `hrm_SinglestaffPayroll` (View/SP Result)
Used for StaffProfile salary tab:
- `CALL hrm_SinglestaffPayroll(@eid)` — Returns payroll history for single employee
- Fields: payrollid, payroll_title, payroll_month, payroll_year, empID, basic_pay, paye, nssf, total_allowances, total_deductions, gross_pay, net_pay

### 3.19 `hrm_GetPayrollDetailsFull` (SP Result)
- `CALL hrm_GetPayrollDetailsFull(@pid, @brch)` — Full payroll details with all joins for Crystal Reports

### 3.20 `hrm_StaffIDPrint` (SP Result)
- `CALL hrm_StaffIDPrint(@_id)` — Staff ID card data for printing

### 3.21 Supporting Tables (non-HRM)
- `companyinfo` — Company information for report headers
- `acad_university` — University info for report headers
- `int_subjectallocation` — Subject allocation for academic staff
- `int_tutorgroups` — Tutor group assignments

---

## 4. STORED PROCEDURES USED

| Stored Procedure | Purpose |
|-----------------|---------|
| `hrm_GetPayrollDetails(@pid)` | Generate/get payroll details for a payroll period |
| `hrm_GetPayrollBranchDetails(@pid, @bname)` | Get payroll details filtered by branch/station |
| `hrm_GetPayrollDetailsFull(@pid, @brch)` | Full payroll details for Crystal Reports |
| `hrm_GenerateMonthlyDedAllowanceList(@pid, @dedAllID, @dedtyp, @act, @bid)` | Generate/display monthly deduction/allowance list |
| `hrm_AddAllStaffOnDedAllowance(@dedID)` | Add all staff to a deduction/allowance |
| `hrm_CreateAnnualLeaveList(@yr, @def_days)` | Create annual leave records for all staff |
| `hrm_GetLeaveListByYear(@yr)` | Get leave list with taken/balance computed |
| `hrm_SinglestaffPayroll(@eid)` | Single staff payroll history |
| `hrm_StaffIDPrint(@_id)` | Staff ID card print data |
| `hrm_CreateSpecialPayList(@pid)` | Generate special payments list from rates |

---

## 5. BUSINESS LOGIC & WORKFLOWS

### 5.1 Employee Management (Employee.ascx)
- **Grid**: Full CRUD on `hrm_employee` via ASPxGridView with EditForm layout
- **Add New**: Defaults Entry_Year=current year, Entry_Satation="MASAKA", EmpType="Academic"
- **Staff Code Generation**: Auto-generates EMP_CODE as `MRU{nextNum}` where nextNum = MAX(SUBSTRING(EMP_CODE,4,4))+1, padded to 4 digits
- **Staff Profile**: Opens popup with StaffProfile.aspx showing bio, salary history, photo upload
- **Stations Management**: Popup to manage work stations (CRUD on hrm_stations)
- **Banks dropdown**: Populated from banks table
- **Nationality dropdown**: UGANDAN, KENYAN, TANZANIAN, RWANDAN, SOUTH SUDANESE
- **Category dropdown**: Academic, Administrative, Support, Consultant, Adjunct, Parttime
- **Education Level**: Certificate, Diploma, Bachelors, Masters, PHD, Proffessor, NA

### 5.2 Contract Management (ContractInfo.ascx)
- **Grid**: Full CRUD on `hrm_emp_contracts`
- **Employee lookup**: ComboBox from hrm_employee
- **Job lookup**: ComboBox from hrm_jobs
- **Department lookup**: ComboBox from hrm_departments
- **Pay Scale lookup**: ComboBox from hrm_payscales showing scale_name and basicpay
- **Status**: VALID, EXPIRED, TERMINATED, RESIGNED
- **Conditional formatting**: `HtmlDataCellPrepared` for expired contract highlighting
- **Print Staff ID**: Opens popup with XtraReportsPrinter for StaffIDocument report
- **SMS Centre**: Select staff → Add to SMS list → Send SMS via SMSSender.aspx
  - Uses `GetPhone()` to get phone numbers from hrm_employee
  - Session-based recipient list management (add/clear)
- **Settings popup** (pid=2): Opens JobsDepartments.ascx

### 5.3 Settings (JobsDepartments.ascx) — 4 Tabs
1. **Jobs**: CRUD on `hrm_jobs` (jobname, min_qualifications)
2. **Departments**: CRUD on `hrm_departments` (dept_name, dept_headID→employee)
3. **Banks**: CRUD on `banks` (bank_name)
4. **Salary Scales**: CRUD on `hrm_payscales` (scale_name, basicpay)

### 5.4 Leave Management (AnnualLeavel.ascx + LeaveTracking.aspx)
- **Annual Leave List**: Shows all staff with leave allocation for selected year
  - Columns: emp_name, default_days, taken, balance
  - Year selector dropdown
  - "Refresh List" button calls `hrm_CreateAnnualLeaveList` SP to bulk-create records
  - Leave days configurable (default 30)
  - Batch editing mode
- **Leave Tracking** (popup): Individual leave records per employee
  - Grid: startDate, endDate, no_days (auto-calculated as DATEDIFF)
  - "Add New" inserts blank record with today's date
  - Row updating validates: `noDays > Balance` throws exception "You can not Exceed 30 Days in a year!"
  - Total summary shows sum of no_days

### 5.5 Payroll Management (Payroll.ascx)
- **Grid**: CRUD on `hrm_payroll`
- **Fields**: payroll_title, month, year, prepared_by/checked_by/approved_by (employee lookups), total_amount, lockStatus, payroll_date, expected_days
- **Payroll Details** button: Opens popup with PayrollDetails.ascx (pid=4)

### 5.6 Payroll Details (PayrollDetails.ascx) — 4 Tabs

#### Tab 1: Payroll List
- Grid on `hrm_payroll_details` filtered by payroll ID and station
- Station filter dropdown (from hrm_stations)
- Columns: emp_name, days_attended (editable), basic_pay, total_allowances, gross_pay, paye, nssf, total_deductions, net_pay
- Batch editing for days_attended
- "Refresh" reloads data
- "Print" → Opens XtraReports viewer with GeneralPayroll report (session: Report="Payroll", branch=selected station)

#### Tab 2: Deductions & Allowances
- Hosts `MonthlyDeductionAllowance.ascx`
- Type filter: Allowance/Deduction
- Deduction/Allowance name dropdown
- Branch filter
- Grid shows staff with editable amount column
- "Refresh List": Calls `hrm_GenerateMonthlyDedAllowanceList` SP with action="Refresh"
- "Save Changes": Iterates visible rows, calls `SaveChanges()` to update amounts
- "Delete Selected": (button exists)

#### Tab 3: Special Payments
- Grid on `hrm_special_payments` filtered by payroll ID
- Columns: emp_name, pay_type, pay_rate, hours (editable), gross_pay, deductions (editable), net_pay
- "Refresh": Calls `hrm_CreateSpecialPayList` SP to generate from rates
- "Clean List": Deletes records where net_pay=0
- Row updating: gross_pay = hours × pay_rate; net_pay = gross - deductions
- Footer summaries for gross_pay and net_pay
- "Print": XtraReports with SpecialPayments report

#### Tab 4: Documents Centre
- Hosts `DocumentCentre.ascx`
- Document types: Main Payroll, Main Payroll By Branch, PAYE Schedule, NSSF Schedule, Bank Schedule, Allowance & Deductions
- Opens XtraReportsPrinter popup with appropriate report

### 5.7 Deductions & Allowances Setup (Deductions_Allowances.ascx)
- Type filter: Allowance/Deduction
- Grid: CRUD on `hrm_allowance_deductions`
- Fields: dedall_name, dedall_type (STATUTORY/MANDATORY/OPTIONAL), dedall_amount, computation_by, ded_allowance
- **Computation methods**: PERCENTAGE, PERCENT - TAX, FIXED, DYNAMIC, FORMULA, ATTENDANCE
- "Staff List" button (only for OPTIONAL type): Opens DedAllowanceList.ascx popup
- New row auto-sets ded_allowance from filter selection

### 5.8 Deduction/Allowance Staff List (DedAllowanceList.ascx)
- Grid: CRUD on `hrm_ded_allowance_stafflist`
- Shows staff assigned to specific deduction/allowance with custom_amount
- "Add Staff": Creates blank record
- "Add All Staff" checkbox: Calls `hrm_AddAllStaffOnDedAllowance` SP
- Batch editing mode, page size 500

### 5.9 Part-time Pay Rates (PayrollSpecialRates.ascx)
- Grid: CRUD on `hrm_part_time_rates`
- Fields: staff_code (employee lookup), effect_date, cur_status (Active/Suspended/InActive/Terminated), qualification, pay_rate, pay_type (Parttime/Consultant/Special Payment/HOD Facilitation)
- Employee join shows emp_name

### 5.10 Staff Profile (StaffProfile.aspx) — 3 Tabs

#### Tab 1: Bio Data
- Read-only display from `hrm_employee` via `GetSingleStaff(@ID)`
- Custom DataRow template showing: photo, name, staff code, phone, email, qualifications, entry year, station, marital status, address, nationality

#### Tab 2: Salary Profile
- Grid from `hrm_SinglestaffPayroll` SP
- Columns: month, year, basic_pay, total_allowances, gross_pay, paye, nssf, total_deductions, net_pay
- Filter row enabled

#### Tab 3: Photo
- Upload control for staff photo
- Saves to `~/COOPERP/staffimages/{empID}_photo.jpg`
- Uses `imageManager.MakeThumb()` for thumbnail generation

### 5.11 Reports

#### XtraReports (DevExpress):
| Report Class | Session Key | Data |
|-------------|-------------|------|
| MainPayroll | "MainPayroll" | hrm_payroll + hrm_payroll_details + companyinfo |
| PayrollByStation | "MainPayrollBranch" | Same, grouped by station |
| BankSchedules | "BankSchedule" | Same data |
| PAYE_Schedule | "PAYE" | Same data |
| NSSF_Schedule | "NSSF" | Same data |
| StaffIDocument | "STAFFID" | hrm_StaffIDPrint SP |
| GeneralPayroll | "Payroll" | With payrollID + branch parameters |
| SpecialPayments | "SpecialPayroll" | hrm_special_payments + acad_university |

#### Crystal Reports:
| Report | File | Data |
|--------|------|------|
| LargePayroll | LargePayroll.rpt | hrm_GetPayrollDetailsFull SP + acad_university |

---

## 6. DEVEXPRESS CONTROLS USED

| Control | Usage |
|---------|-------|
| `ASPxGridView` | Every data grid (employees, contracts, payroll, etc.) |
| `ASPxComboBox` | All dropdown selections (employee, bank, department, job, scale, year, type filters) |
| `ASPxButton` | All action buttons |
| `ASPxPopupControl` | Popup windows for details, profile, messages, reports |
| `ASPxRoundPanel` | Content containers/sections |
| `ASPxPageControl` | Tabbed interfaces (StaffProfile, JobsDepartments, PayrollDetails, AcademicStaffDetails) |
| `ASPxMenu` | Navigation menu in MasterPage |
| `ASPxLabel` | Text display, messages |
| `ASPxImage` | Staff photos, headers, decorative lines |
| `ASPxTextBox` | Text inputs (leave days, amounts) |
| `ASPxCheckBox` | "Add All Staff" checkbox |
| `ASPxUploadControl` | Photo upload |
| `ASPxHyperLink` | Password change link |
| `ReportToolbar` | XtraReports toolbar |
| `ReportViewer` | XtraReports viewer |
| `CrystalReportViewer` | Crystal Reports viewer |

### Grid Features Used:
- EditForm mode, Batch editing mode
- Filter rows, Search panels
- Row selection with checkboxes
- Focused row behavior
- Confirm delete dialogs
- HtmlRowPrepared / HtmlDataCellPrepared for formatting
- InitNewRow for default values
- RowInserting for business logic
- RowUpdating for validation
- Custom DataItemTemplate and DataRow templates
- Summary/footer totals
- ComboBox columns with lookup data

---

## 7. TABLE RELATIONSHIPS

```
banks (bank_id) ←——— hrm_employee (bankID)
hrm_employee (empID) ←——— hrm_emp_contracts (empID)
hrm_jobs (ID) ←——— hrm_emp_contracts (jobID)
hrm_departments (ID) ←——— hrm_emp_contracts (departmentID)
hrm_payscales (ID) ←——— hrm_emp_contracts (payscale)
hrm_employee (empID) ←——— hrm_payroll_details (empID)
hrm_payroll (ID) ←——— hrm_payroll_details (payrollID)
hrm_employee (empID) ←——— hrm_payroll (prepared_by, checked_by, approved_by)
hrm_allowance_deductions (ID) ←——— hrm_ded_allowance_stafflist (ded_allID)
hrm_employee (empID) ←——— hrm_ded_allowance_stafflist (empID)
hrm_allowance_deductions (ID) ←——— hrm_monthly_ded_allowance (ded_allID)
hrm_employee (empID) ←——— hrm_monthly_ded_allowance (empID)
hrm_payroll (ID) ←——— hrm_monthly_ded_allowance (payrollID)
hrm_employee (empID) ←——— hrm_exemptions (empID)
hrm_allowance_deductions (ID) ←——— hrm_exemptions (ded_allID)
hrm_employee (empID) ←——— hrm_annual_leave (empID)
hrm_annual_leave (ID) ←——— hrm_leave_taken (leaveID)
hrm_employee (empID) ←——— hrm_part_time_rates (staff_code)
hrm_employee (empID) ←——— hrm_special_payments (staff_code)
hrm_payroll (ID) ←——— hrm_special_payments (payroll_id)
hrm_employee (empID) ←——— hrm_departments (dept_headID)
hrm_stations ←——— hrm_employee (Entry_Satation) [by name, not FK]
```

---

## 8. SESSION VARIABLES USED

| Session Key | Purpose |
|-------------|---------|
| `empID` | Current selected employee ID |
| `pid` | Current payroll ID |
| `branch` | Current station/branch filter |
| `lid` | Current leave allocation ID (for leave tracking) |
| `HeaderText` | Leave tracking popup header |
| `balance` | Leave balance for validation |
| `dedAllID` | Current deduction/allowance ID |
| `default_amount` | Default amount for ded/allowance |
| `Report` | Report type identifier |
| `ID` | Generic ID for reports |
| `receipients` | SMS recipient phone list |
| `noReceipients` | SMS recipient count |
| `username` | Current logged-in user |
| `EmpNo` / `EmpName` / `EmpCode` | Academic staff tracking |
| `Cat` | Category (Academics/Tutorship) |
