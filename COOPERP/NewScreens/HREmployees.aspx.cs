using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.Security;
using MySql.Data.MySqlClient;
using DevExpress.Web;

public partial class COOPERP_NewScreens_HREmployees : System.Web.UI.Page
{
    private string ConnStr
    {
        get { return ConfigurationManager.ConnectionStrings["vacConnectionString"].ConnectionString; }
    }

    protected void Page_Init(object sender, EventArgs e)
    {
        // Handle AJAX actions
        string action = Request.QueryString["action"];
        if (!string.IsNullOrEmpty(action))
        {
            HandleAjaxAction(action);
            return;
        }
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            LoadFilterDropdowns();
        }
        BindEmployeeGrid();
    }

    #region Grid Binding

    private void BindEmployeeGrid()
    {
        string search = txtSearch.Text.Trim();
        string dept = ddlFilterDept.SelectedValue;
        string station = ddlFilterStation.SelectedValue;
        string empType = ddlFilterType.SelectedValue;
        string status = ddlFilterStatus.SelectedValue;

        StringBuilder sql = new StringBuilder();
        sql.Append(@"SELECT e.empID, e.EMP_CODE, e.emp_name, e.emp_email, e.emp_phone, e.emp_birthdate,
            e.emp_qualifications, e.emp_nationality, e.EmpType, e.marital_status, e.address,
            e.religion, e.tin, e.nssf_no, e.gender, e.max_education,
            e.bankID, e.bankAccount, e.tribe, e.spouse_name, e.no_children,
            e.contact_person, e.relation, e.phone_contacts, e.current_residence,
            e.father_name, e.mother_name, e.referee_1, e.referee_2,
            e.medical_background, e.schooling_info, e.employment_info,
            e.usernames, e.Entry_Year, e.Entry_Satation,
            d.dept_name, st.station_name,
            c.contractStatus, c.contractStart, c.contractEnd,
            ps.scale_name, IFNULL(ps.basicpay, c.fixedamount) AS basicpay,
            j.jobname
        FROM hrm_employee e
        LEFT JOIN hrm_emp_contracts c ON c.empID = e.empID AND c.ID = (
            SELECT MAX(c2.ID) FROM hrm_emp_contracts c2 WHERE c2.empID = e.empID
        )
        LEFT JOIN hrm_departments d ON d.ID = c.departmentID
        LEFT JOIN hrm_stations st ON st.ID = e.Entry_Satation
        LEFT JOIN hrm_payscales ps ON ps.ID = c.payscale
        LEFT JOIN hrm_jobs j ON j.ID = c.jobID
        WHERE 1=1 ");

        List<MySqlParameter> parms = new List<MySqlParameter>();

        if (!string.IsNullOrEmpty(search))
        {
            sql.Append(" AND (e.emp_name LIKE @search OR e.EMP_CODE LIKE @search OR e.emp_email LIKE @search OR e.emp_phone LIKE @search) ");
            parms.Add(new MySqlParameter("@search", "%" + search + "%"));
        }
        if (!string.IsNullOrEmpty(dept))
        {
            sql.Append(" AND c.departmentID = @dept ");
            parms.Add(new MySqlParameter("@dept", dept));
        }
        if (!string.IsNullOrEmpty(station))
        {
            sql.Append(" AND e.Entry_Satation = @station ");
            parms.Add(new MySqlParameter("@station", station));
        }
        if (!string.IsNullOrEmpty(empType))
        {
            sql.Append(" AND e.EmpType = @empType ");
            parms.Add(new MySqlParameter("@empType", empType));
        }
        if (!string.IsNullOrEmpty(status))
        {
            sql.Append(" AND c.contractStatus = @status ");
            parms.Add(new MySqlParameter("@status", status));
        }

        sql.Append(" ORDER BY e.emp_name ASC ");

        DataTable dt = ExecuteQuery(sql.ToString(), parms.ToArray());
        gvEmployees.DataSource = dt;
        gvEmployees.DataBind();

        litCount.Text = dt.Rows.Count.ToString();
    }

    #endregion

    #region Filter Dropdowns

    private void LoadFilterDropdowns()
    {
        // Departments
        DataTable dtDepts = ExecuteQuery("SELECT ID, dept_name FROM hrm_departments ORDER BY dept_name");
        ddlFilterDept.Items.Clear();
        ddlFilterDept.Items.Add(new ListItem("All Departments", ""));
        foreach (DataRow r in dtDepts.Rows)
        {
            ddlFilterDept.Items.Add(new ListItem(r["dept_name"].ToString(), r["ID"].ToString()));
        }

        // Stations (for filter + add form)
        DataTable dtStations = ExecuteQuery("SELECT ID, station_name FROM hrm_stations ORDER BY station_name");
        ddlFilterStation.Items.Clear();
        ddlFilterStation.Items.Add(new ListItem("All Stations", ""));
        ddlNewStation.Items.Clear();
        ddlNewStation.Items.Add(new ListItem("-- Select Station --", ""));
        foreach (DataRow r in dtStations.Rows)
        {
            ddlFilterStation.Items.Add(new ListItem(r["station_name"].ToString(), r["ID"].ToString()));
            ddlNewStation.Items.Add(new ListItem(r["station_name"].ToString(), r["ID"].ToString()));
        }
        // Pre-select MASAKA if exists
        ListItem masaka = ddlNewStation.Items.FindByText("MASAKA");
        if (masaka != null) ddlNewStation.SelectedValue = masaka.Value;

        // Banks (for add form)
        DataTable dtBanks = ExecuteQuery("SELECT bank_id, bank_name FROM banks ORDER BY bank_name");
        ddlNewBank.Items.Clear();
        ddlNewBank.Items.Add(new ListItem("-- Select Bank --", "0"));
        foreach (DataRow r in dtBanks.Rows)
        {
            ddlNewBank.Items.Add(new ListItem(r["bank_name"].ToString(), r["bank_id"].ToString()));
        }

        // Default entry year
        txtNewEntryYear.Text = DateTime.Now.Year.ToString();
    }

    protected void ddlFilter_Changed(object sender, EventArgs e)
    {
        BindEmployeeGrid();
    }

    protected void btnSearch_Click(object sender, EventArgs e)
    {
        BindEmployeeGrid();
    }

    protected void btnReset_Click(object sender, EventArgs e)
    {
        txtSearch.Text = "";
        ddlFilterDept.SelectedIndex = 0;
        ddlFilterStation.SelectedIndex = 0;
        ddlFilterType.SelectedIndex = 0;
        ddlFilterStatus.SelectedIndex = 0;
        BindEmployeeGrid();
    }

    #endregion

    #region Grid Editing

    protected void gvEmployees_RowUpdating(object sender, DevExpress.Web.Data.ASPxDataUpdatingEventArgs e)
    {
        int empID = Convert.ToInt32(e.Keys["empID"]);
        string sql = @"UPDATE hrm_employee SET 
            emp_name = @name, emp_email = @email, emp_phone = @phone, emp_birthdate = @dob,
            emp_qualifications = @qual, emp_nationality = @nat, EmpType = @empType,
            marital_status = @marital, address = @addr, religion = @religion,
            tin = @tin, nssf_no = @nssf, gender = @gender, max_education = @maxEdu,
            tribe = @tribe, current_residence = @residence,
            bankID = @bankID, bankAccount = @bankAcct,
            spouse_name = @spouse, no_children = @nChildren,
            father_name = @father, mother_name = @mother,
            contact_person = @contactPerson, relation = @relation, phone_contacts = @contactPhone,
            referee_1 = @ref1, referee_2 = @ref2,
            medical_background = @medical, schooling_info = @schooling, employment_info = @employment,
            usernames = @uname, Entry_Year = @entryYear, Entry_Satation = @entryStation
            WHERE empID = @empID";

        int bankVal = 0;
        if (e.NewValues["bankID"] != null) int.TryParse(e.NewValues["bankID"].ToString(), out bankVal);
        int nChild = 0;
        if (e.NewValues["no_children"] != null) int.TryParse(e.NewValues["no_children"].ToString(), out nChild);
        int entryYr = DateTime.Now.Year;
        if (e.NewValues["Entry_Year"] != null) int.TryParse(e.NewValues["Entry_Year"].ToString(), out entryYr);

        ExecuteNonQuery(sql,
            new MySqlParameter("@name", SafeVal(e.NewValues["emp_name"])),
            new MySqlParameter("@email", SafeVal(e.NewValues["emp_email"])),
            new MySqlParameter("@phone", SafeVal(e.NewValues["emp_phone"])),
            new MySqlParameter("@dob", e.NewValues["emp_birthdate"] != null ? (object)Convert.ToDateTime(e.NewValues["emp_birthdate"]) : DBNull.Value),
            new MySqlParameter("@qual", SafeVal(e.NewValues["emp_qualifications"])),
            new MySqlParameter("@nat", SafeVal(e.NewValues["emp_nationality"])),
            new MySqlParameter("@empType", SafeVal(e.NewValues["EmpType"])),
            new MySqlParameter("@marital", SafeVal(e.NewValues["marital_status"])),
            new MySqlParameter("@addr", SafeVal(e.NewValues["address"])),
            new MySqlParameter("@religion", SafeVal(e.NewValues["religion"])),
            new MySqlParameter("@tin", SafeVal(e.NewValues["tin"])),
            new MySqlParameter("@nssf", SafeVal(e.NewValues["nssf_no"])),
            new MySqlParameter("@gender", SafeVal(e.NewValues["gender"])),
            new MySqlParameter("@maxEdu", SafeVal(e.NewValues["max_education"])),
            new MySqlParameter("@tribe", SafeVal(e.NewValues["tribe"])),
            new MySqlParameter("@residence", SafeVal(e.NewValues["current_residence"])),
            new MySqlParameter("@bankID", bankVal),
            new MySqlParameter("@bankAcct", SafeVal(e.NewValues["bankAccount"])),
            new MySqlParameter("@spouse", SafeVal(e.NewValues["spouse_name"])),
            new MySqlParameter("@nChildren", nChild),
            new MySqlParameter("@father", SafeVal(e.NewValues["father_name"])),
            new MySqlParameter("@mother", SafeVal(e.NewValues["mother_name"])),
            new MySqlParameter("@contactPerson", SafeVal(e.NewValues["contact_person"])),
            new MySqlParameter("@relation", SafeVal(e.NewValues["relation"])),
            new MySqlParameter("@contactPhone", SafeVal(e.NewValues["phone_contacts"])),
            new MySqlParameter("@ref1", SafeVal(e.NewValues["referee_1"])),
            new MySqlParameter("@ref2", SafeVal(e.NewValues["referee_2"])),
            new MySqlParameter("@medical", SafeVal(e.NewValues["medical_background"])),
            new MySqlParameter("@schooling", SafeVal(e.NewValues["schooling_info"])),
            new MySqlParameter("@employment", SafeVal(e.NewValues["employment_info"])),
            new MySqlParameter("@uname", SafeVal(e.NewValues["usernames"])),
            new MySqlParameter("@entryYear", entryYr),
            new MySqlParameter("@entryStation", SafeVal(e.NewValues["Entry_Satation"])),
            new MySqlParameter("@empID", empID)
        );

        e.Cancel = true;
        gvEmployees.CancelEdit();
        BindEmployeeGrid();
    }

    protected void gvEmployees_RowDeleting(object sender, DevExpress.Web.Data.ASPxDataDeletingEventArgs e)
    {
        int empID = Convert.ToInt32(e.Keys["empID"]);
        ExecuteNonQuery("DELETE FROM hrm_employee WHERE empID = @id", new MySqlParameter("@id", empID));

        e.Cancel = true;
        gvEmployees.CancelEdit();
        BindEmployeeGrid();
    }

    #endregion

    #region Add Employee

    protected void btnAddEmployee_Click(object sender, EventArgs e)
    {
        string name = txtNewName.Text.Trim();
        string email = txtNewEmail.Text.Trim();
        string phone = txtNewPhone.Text.Trim();

        if (string.IsNullOrEmpty(name) || string.IsNullOrEmpty(email) || string.IsNullOrEmpty(phone))
        {
            ScriptManager.RegisterStartupScript(this, GetType(), "addErr",
                "document.getElementById('addEmpResult').innerHTML='<span style=\"color:red;\">Name, Email and Phone are required.</span>';document.getElementById('addEmployeeModal').style.display='flex';", true);
            return;
        }

        // Generate EMP_CODE
        string empCode = GenerateEmpCode();

        DateTime dob;
        bool hasDOB = DateTime.TryParse(txtNewDOB.Text, out dob);
        int bankId = 0;
        int.TryParse(ddlNewBank.SelectedValue, out bankId);
        int nChildren = 0;
        int.TryParse(txtNewChildren.Text.Trim(), out nChildren);
        int entryYear = DateTime.Now.Year;
        int.TryParse(txtNewEntryYear.Text.Trim(), out entryYear);

        string sql = @"INSERT INTO hrm_employee 
            (EMP_CODE, emp_name, emp_email, emp_phone, emp_birthdate, gender, emp_qualifications, 
             max_education, emp_nationality, EmpType, marital_status, address, current_residence,
             religion, tribe, tin, nssf_no, bankID, bankAccount,
             spouse_name, no_children, father_name, mother_name,
             contact_person, relation, phone_contacts,
             referee_1, referee_2, medical_background, schooling_info, employment_info,
             Entry_Year, Entry_Satation)
            VALUES 
            (@code, @name, @email, @phone, @dob, @gender, @qual, 
             @maxEdu, @nat, @empType, @marital, @addr, @residence,
             @religion, @tribe, @tin, @nssf, @bankID, @bankAcct,
             @spouse, @nChildren, @father, @mother,
             @contactPerson, @relation, @contactPhone,
             @ref1, @ref2, @medical, @schooling, @employment,
             @year, @station)";

        ExecuteNonQuery(sql,
            new MySqlParameter("@code", empCode),
            new MySqlParameter("@name", name),
            new MySqlParameter("@email", email),
            new MySqlParameter("@phone", phone),
            new MySqlParameter("@dob", hasDOB ? (object)dob : DBNull.Value),
            new MySqlParameter("@gender", ddlNewGender.SelectedValue),
            new MySqlParameter("@qual", txtNewQualifications.Text.Trim()),
            new MySqlParameter("@maxEdu", ddlNewEducation.SelectedValue),
            new MySqlParameter("@nat", ddlNewNationality.SelectedValue),
            new MySqlParameter("@empType", ddlNewType.SelectedValue),
            new MySqlParameter("@marital", ddlNewMarital.SelectedValue),
            new MySqlParameter("@addr", txtNewAddress.Text.Trim()),
            new MySqlParameter("@residence", txtNewResidence.Text.Trim()),
            new MySqlParameter("@religion", txtNewReligion.Text.Trim()),
            new MySqlParameter("@tribe", txtNewTribe.Text.Trim()),
            new MySqlParameter("@tin", txtNewTIN.Text.Trim()),
            new MySqlParameter("@nssf", txtNewNSSF.Text.Trim()),
            new MySqlParameter("@bankID", bankId),
            new MySqlParameter("@bankAcct", txtNewBankAccount.Text.Trim()),
            new MySqlParameter("@spouse", txtNewSpouse.Text.Trim()),
            new MySqlParameter("@nChildren", nChildren),
            new MySqlParameter("@father", txtNewFather.Text.Trim()),
            new MySqlParameter("@mother", txtNewMother.Text.Trim()),
            new MySqlParameter("@contactPerson", txtNewContactPerson.Text.Trim()),
            new MySqlParameter("@relation", txtNewRelation.Text.Trim()),
            new MySqlParameter("@contactPhone", txtNewContactPhone.Text.Trim()),
            new MySqlParameter("@ref1", txtNewReferee1.Text.Trim()),
            new MySqlParameter("@ref2", txtNewReferee2.Text.Trim()),
            new MySqlParameter("@medical", txtNewMedical.Text.Trim()),
            new MySqlParameter("@schooling", txtNewSchooling.Text.Trim()),
            new MySqlParameter("@employment", txtNewEmployment.Text.Trim()),
            new MySqlParameter("@year", entryYear),
            new MySqlParameter("@station", ddlNewStation.SelectedValue)
        );

        // Clear form
        txtNewName.Text = "";
        txtNewEmail.Text = "";
        txtNewPhone.Text = "";
        txtNewDOB.Text = "";
        txtNewQualifications.Text = "";
        txtNewTIN.Text = "";
        txtNewNSSF.Text = "";
        txtNewAddress.Text = "";
        txtNewResidence.Text = "UGANDA";
        txtNewReligion.Text = "";
        txtNewTribe.Text = "";
        txtNewBankAccount.Text = "";
        txtNewSpouse.Text = "";
        txtNewChildren.Text = "0";
        txtNewFather.Text = "";
        txtNewMother.Text = "";
        txtNewContactPerson.Text = "";
        txtNewRelation.Text = "";
        txtNewContactPhone.Text = "";
        txtNewReferee1.Text = "-";
        txtNewReferee2.Text = "-";
        txtNewMedical.Text = "";
        txtNewSchooling.Text = "";
        txtNewEmployment.Text = "";
        txtNewEntryYear.Text = DateTime.Now.Year.ToString();

        BindEmployeeGrid();
    }

    private string GenerateEmpCode()
    {
        string yearPrefix = "MRU/" + DateTime.Now.Year.ToString() + "/";
        DataTable dt = ExecuteQuery(
            "SELECT EMP_CODE FROM hrm_employee WHERE EMP_CODE LIKE @prefix ORDER BY empID DESC LIMIT 1",
            new MySqlParameter("@prefix", yearPrefix + "%"));

        int nextNum = 1;
        if (dt.Rows.Count > 0)
        {
            string lastCode = dt.Rows[0]["EMP_CODE"].ToString();
            string numPart = lastCode.Substring(lastCode.LastIndexOf('/') + 1);
            int parsed;
            if (int.TryParse(numPart, out parsed))
            {
                nextNum = parsed + 1;
            }
        }
        return yearPrefix + nextNum.ToString("D4");
    }

    #endregion

    #region Employee Profile Loader

    protected void btnLoadProfile_Click(object sender, EventArgs e)
    {
        int empID;
        if (!int.TryParse(hdnSelectedEmpID.Value, out empID)) return;

        DataTable dtEmp = ExecuteQuery(@"
            SELECT e.*, d.dept_name, st.station_name, c.contractStatus, c.contractStart, c.contractEnd,
                ps.scale_name, IFNULL(ps.basicpay, c.fixedamount) AS basicpay, j.jobname
            FROM hrm_employee e
            LEFT JOIN hrm_emp_contracts c ON c.empID = e.empID AND c.ID = (SELECT MAX(c2.ID) FROM hrm_emp_contracts c2 WHERE c2.empID = e.empID)
            LEFT JOIN hrm_departments d ON d.ID = c.departmentID
            LEFT JOIN hrm_stations st ON st.ID = e.Entry_Satation
            LEFT JOIN hrm_payscales ps ON ps.ID = c.payscale
            LEFT JOIN hrm_jobs j ON j.ID = c.jobID
            WHERE e.empID = @id", new MySqlParameter("@id", empID));

        if (dtEmp.Rows.Count == 0) return;

        DataRow emp = dtEmp.Rows[0];

        // Header
        string empCode = emp["EMP_CODE"].ToString();
        imgProfilePhoto.ImageUrl = GetPhotoUrl(empCode);
        imgProfilePhoto.Attributes["onerror"] = "this.onerror=null; this.src='../staffimages/default.jpg'";
        litEmpName.Text = HttpUtility.HtmlEncode(emp["emp_name"].ToString());
        litEmpCode.Text = HttpUtility.HtmlEncode(empCode);
        litEmpType.Text = HttpUtility.HtmlEncode(SafeVal(emp["EmpType"]));
        litDeptStat.Text = HttpUtility.HtmlEncode(SafeVal(emp["dept_name"]));
        litStationStat.Text = HttpUtility.HtmlEncode(SafeVal(emp["station_name"]));

        object bpVal = emp["basicpay"];
        litPayStat.Text = bpVal != null && bpVal != DBNull.Value
            ? "UGX " + Convert.ToDecimal(bpVal).ToString("N0")
            : "N/A";

        litStatusBadge.Text = GetStatusBadge(emp["contractStatus"]);

        // Tab: Bio Data
        litBioData.Text = BuildBioDataHtml(emp);

        // Tab: Contracts
        litContracts.Text = BuildContractsHtml(empID);

        // Tab: Qualifications
        litQualifications.Text = BuildQualificationsHtml(empCode);

        // Tab: Leave
        litLeave.Text = BuildLeaveHtml(empID);

        // Tab: Payroll
        litPayroll.Text = BuildPayrollHtml(empID);

        // Tab: Emergency Info
        litEmergency.Text = BuildEmergencyHtml(emp);

        // Show popup
        popEmployeeProfile.ShowOnPageLoad = true;
    }

    private string BuildBioDataHtml(DataRow emp)
    {
        StringBuilder sb = new StringBuilder();

        // Section: Personal Details
        sb.Append("<div style='font-size:10px;text-transform:uppercase;letter-spacing:.5px;color:#174DA4;font-weight:700;padding:6px 10px 3px;border-bottom:1px solid #e8e8e8;'>Personal Details</div>");
        sb.Append("<div class='ep-bio-grid'>");
        AddBioItem(sb, "Full Name", emp["emp_name"]);
        AddBioItem(sb, "Staff Code", emp["EMP_CODE"]);
        AddBioItem(sb, "Date of Birth", emp["emp_birthdate"] != DBNull.Value ? Convert.ToDateTime(emp["emp_birthdate"]).ToString("dd MMM yyyy") : "");
        AddBioItem(sb, "Gender", emp["gender"]);
        AddBioItem(sb, "Nationality", emp["emp_nationality"]);
        AddBioItem(sb, "Religion", emp["religion"]);
        AddBioItem(sb, "Tribe", emp["tribe"]);
        AddBioItem(sb, "Marital Status", emp["marital_status"]);
        AddBioItem(sb, "Current Residence", emp["current_residence"]);
        AddBioItem(sb, "Address", emp["address"]);
        AddBioItem(sb, "Email", emp["emp_email"]);
        AddBioItem(sb, "Phone", emp["emp_phone"]);
        sb.Append("</div>");

        // Section: Employment Details
        sb.Append("<div style='font-size:10px;text-transform:uppercase;letter-spacing:.5px;color:#174DA4;font-weight:700;padding:6px 10px 3px;border-bottom:1px solid #e8e8e8;margin-top:4px;'>Employment Details</div>");
        sb.Append("<div class='ep-bio-grid'>");
        AddBioItem(sb, "Employee Type", emp["EmpType"]);
        AddBioItem(sb, "Education Level", emp["max_education"]);
        AddBioItem(sb, "Qualifications", emp["emp_qualifications"]);
        AddBioItem(sb, "Entry Year", emp["Entry_Year"]);
        AddBioItem(sb, "Station", emp["station_name"]);
        AddBioItem(sb, "Job Title", emp["jobname"]);
        AddBioItem(sb, "User Name", emp["usernames"]);
        sb.Append("</div>");

        // Section: Financial Details
        string bankName = ResolveBankName(emp["bankID"]);
        sb.Append("<div style='font-size:10px;text-transform:uppercase;letter-spacing:.5px;color:#174DA4;font-weight:700;padding:6px 10px 3px;border-bottom:1px solid #e8e8e8;margin-top:4px;'>Financial Details</div>");
        sb.Append("<div class='ep-bio-grid'>");
        AddBioItem(sb, "Bank", bankName);
        AddBioItem(sb, "Bank Account", emp["bankAccount"]);
        AddBioItem(sb, "TIN", emp["tin"]);
        AddBioItem(sb, "NSSF No", emp["nssf_no"]);
        AddBioItem(sb, "Pay Scale", emp["scale_name"]);
        AddBioItem(sb, "Basic Pay", emp["basicpay"] != DBNull.Value ? Convert.ToDecimal(emp["basicpay"]).ToString("N0") : "");
        sb.Append("</div>");

        // Section: Family  
        sb.Append("<div style='font-size:10px;text-transform:uppercase;letter-spacing:.5px;color:#174DA4;font-weight:700;padding:6px 10px 3px;border-bottom:1px solid #e8e8e8;margin-top:4px;'>Family</div>");
        sb.Append("<div class='ep-bio-grid'>");
        AddBioItem(sb, "Spouse Name", emp["spouse_name"]);
        AddBioItem(sb, "No. of Children", emp["no_children"]);
        AddBioItem(sb, "Father's Name", emp["father_name"]);
        AddBioItem(sb, "Mother's Name", emp["mother_name"]);
        sb.Append("</div>");

        // Section: Additional Info (memo fields)
        string schooling = SafeVal(emp["schooling_info"]);
        string employment = SafeVal(emp["employment_info"]);
        string medical = SafeVal(emp["medical_background"]);
        if (!string.IsNullOrEmpty(schooling) || !string.IsNullOrEmpty(employment) || !string.IsNullOrEmpty(medical))
        {
            sb.Append("<div style='font-size:10px;text-transform:uppercase;letter-spacing:.5px;color:#174DA4;font-weight:700;padding:6px 10px 3px;border-bottom:1px solid #e8e8e8;margin-top:4px;'>Additional Information</div>");
            sb.Append("<div style='padding:8px 12px;'>");
            if (!string.IsNullOrEmpty(schooling))
            {
                sb.Append("<div style='margin-bottom:10px;'><div class='ep-bio-label'>Academic / Prof. Training</div>");
                sb.AppendFormat("<div style='font-size:12px;color:#333;white-space:pre-wrap;'>{0}</div></div>", HttpUtility.HtmlEncode(schooling));
            }
            if (!string.IsNullOrEmpty(employment))
            {
                sb.Append("<div style='margin-bottom:10px;'><div class='ep-bio-label'>Employment History</div>");
                sb.AppendFormat("<div style='font-size:12px;color:#333;white-space:pre-wrap;'>{0}</div></div>", HttpUtility.HtmlEncode(employment));
            }
            if (!string.IsNullOrEmpty(medical))
            {
                sb.Append("<div style='margin-bottom:10px;'><div class='ep-bio-label'>Medical Background</div>");
                sb.AppendFormat("<div style='font-size:12px;color:#333;white-space:pre-wrap;'>{0}</div></div>", HttpUtility.HtmlEncode(medical));
            }
            sb.Append("</div>");
        }

        return sb.ToString();
    }

    private string ResolveBankName(object bankID)
    {
        if (bankID == null || bankID == DBNull.Value) return "";
        int bid;
        if (!int.TryParse(bankID.ToString(), out bid) || bid == 0) return "";
        DataTable dt = ExecuteQuery("SELECT bank_name FROM banks WHERE bank_id = @id", new MySqlParameter("@id", bid));
        if (dt.Rows.Count > 0) return dt.Rows[0]["bank_name"].ToString();
        return bankID.ToString();
    }

    private void AddBioItem(StringBuilder sb, string label, object value)
    {
        string val = (value != null && value != DBNull.Value && value.ToString().Trim().Length > 0) ? HttpUtility.HtmlEncode(value.ToString()) : "<span style='color:#bbb;'>&mdash;</span>";
        sb.AppendFormat("<div class='ep-bio-item'><div class='ep-bio-label'>{0}</div><div class='ep-bio-value'>{1}</div></div>",
            HttpUtility.HtmlEncode(label), val);
    }

    private string BuildContractsHtml(int empID)
    {
        DataTable dt = ExecuteQuery(@"
            SELECT c.ID, c.contractStart, c.contractEnd, c.contractStatus, c.comments,
                   c.fixedamount, j.jobname, d.dept_name, ps.scale_name, ps.basicpay
            FROM hrm_emp_contracts c
            LEFT JOIN hrm_jobs j ON j.ID = c.jobID
            LEFT JOIN hrm_departments d ON d.ID = c.departmentID
            LEFT JOIN hrm_payscales ps ON ps.ID = c.payscale
            WHERE c.empID = @id ORDER BY c.contractStart DESC",
            new MySqlParameter("@id", empID));

        if (dt.Rows.Count == 0)
            return "<div style='padding:20px;text-align:center;color:#888;font-size:12px;'>No contracts found.</div>";

        StringBuilder sb = new StringBuilder();
        sb.Append("<table class='ep-data-table'><thead><tr>");
        sb.Append("<th>Start</th><th>End</th><th>Job</th><th>Department</th><th>Scale</th><th>Basic Pay</th><th>Status</th><th>Comments</th>");
        sb.Append("</tr></thead><tbody>");

        foreach (DataRow r in dt.Rows)
        {
            sb.Append("<tr>");
            sb.AppendFormat("<td>{0}</td>", FormatDate(r["contractStart"]));
            sb.AppendFormat("<td>{0}</td>", FormatDate(r["contractEnd"]));
            sb.AppendFormat("<td>{0}</td>", HttpUtility.HtmlEncode(r["jobname"].ToString()));
            sb.AppendFormat("<td>{0}</td>", HttpUtility.HtmlEncode(r["dept_name"].ToString()));
            sb.AppendFormat("<td>{0}</td>", HttpUtility.HtmlEncode(r["scale_name"].ToString()));
            sb.AppendFormat("<td class='text-right'>{0}</td>", FormatAmount(r["basicpay"] != DBNull.Value ? r["basicpay"] : r["fixedamount"]));
            sb.AppendFormat("<td>{0}</td>", GetStatusBadge(r["contractStatus"]));
            sb.AppendFormat("<td>{0}</td>", HttpUtility.HtmlEncode(r["comments"].ToString()));
            sb.Append("</tr>");
        }

        sb.Append("</tbody></table>");
        return sb.ToString();
    }

    private string BuildQualificationsHtml(string empCode)
    {
        DataTable dt = ExecuteQuery(@"
            SELECT qualif, institution, period_start, period_end, award_class 
            FROM hrm_qualifications WHERE empcode = @code ORDER BY period_end DESC",
            new MySqlParameter("@code", empCode));

        if (dt.Rows.Count == 0)
            return "<div style='padding:20px;text-align:center;color:#888;font-size:12px;'>No qualifications recorded.</div>";

        StringBuilder sb = new StringBuilder();
        sb.Append("<table class='ep-data-table'><thead><tr>");
        sb.Append("<th>Qualification</th><th>Institution</th><th>From</th><th>To</th><th>Classification</th>");
        sb.Append("</tr></thead><tbody>");

        foreach (DataRow r in dt.Rows)
        {
            sb.Append("<tr>");
            sb.AppendFormat("<td><strong>{0}</strong></td>", HttpUtility.HtmlEncode(r["qualif"].ToString()));
            sb.AppendFormat("<td>{0}</td>", HttpUtility.HtmlEncode(r["institution"].ToString()));
            sb.AppendFormat("<td>{0}</td>", FormatDate(r["period_start"]));
            sb.AppendFormat("<td>{0}</td>", FormatDate(r["period_end"]));
            sb.AppendFormat("<td>{0}</td>", HttpUtility.HtmlEncode(r["award_class"].ToString()));
            sb.Append("</tr>");
        }

        sb.Append("</tbody></table>");
        return sb.ToString();
    }

    private string BuildLeaveHtml(int empID)
    {
        DataTable dtAlloc = ExecuteQuery(@"
            SELECT al.leave_year, al.default_days,
                COALESCE(SUM(lt.no_days),0) AS taken_days
            FROM hrm_annual_leave al
            LEFT JOIN hrm_leave_taken lt ON lt.leaveID = al.ID
            WHERE al.empID = @id
            GROUP BY al.ID, al.leave_year, al.default_days
            ORDER BY al.leave_year DESC",
            new MySqlParameter("@id", empID));

        if (dtAlloc.Rows.Count == 0)
            return "<div style='padding:20px;text-align:center;color:#888;font-size:12px;'>No leave records found.</div>";

        StringBuilder sb = new StringBuilder();
        sb.Append("<table class='ep-data-table'><thead><tr>");
        sb.Append("<th>Year</th><th class='text-center'>Allocated</th><th class='text-center'>Taken</th><th class='text-center'>Remaining</th>");
        sb.Append("</tr></thead><tbody>");

        foreach (DataRow r in dtAlloc.Rows)
        {
            int allocated = Convert.ToInt32(r["default_days"]);
            int taken = Convert.ToInt32(r["taken_days"]);
            int remaining = allocated - taken;
            string color = remaining <= 0 ? "color:#dc3545;font-weight:600;" : remaining <= 5 ? "color:#ffc107;font-weight:600;" : "color:#28a745;font-weight:600;";

            sb.Append("<tr>");
            sb.AppendFormat("<td><strong>{0}</strong></td>", r["leave_year"]);
            sb.AppendFormat("<td class='text-center'>{0}</td>", allocated);
            sb.AppendFormat("<td class='text-center'>{0}</td>", taken);
            sb.AppendFormat("<td class='text-center' style='{0}'>{1}</td>", color, remaining);
            sb.Append("</tr>");
        }

        sb.Append("</tbody></table>");

        // Leave details
        DataTable dtDetails = ExecuteQuery(@"
            SELECT lt.startDate, lt.endDate, lt.no_days, al.leave_year
            FROM hrm_leave_taken lt
            JOIN hrm_annual_leave al ON al.ID = lt.leaveID
            WHERE al.empID = @id
            ORDER BY lt.startDate DESC LIMIT 20",
            new MySqlParameter("@id", empID));

        if (dtDetails.Rows.Count > 0)
        {
            sb.Append("<div style='margin-top:12px;'><strong style='font-size:11px;color:#555;'>Recent Leave Taken</strong></div>");
            sb.Append("<table class='ep-data-table' style='margin-top:6px;'><thead><tr>");
            sb.Append("<th>Start Date</th><th>End Date</th><th class='text-center'>Days</th><th>Year</th>");
            sb.Append("</tr></thead><tbody>");

            foreach (DataRow r in dtDetails.Rows)
            {
                sb.Append("<tr>");
                sb.AppendFormat("<td>{0}</td>", FormatDate(r["startDate"]));
                sb.AppendFormat("<td>{0}</td>", FormatDate(r["endDate"]));
                sb.AppendFormat("<td class='text-center'>{0}</td>", r["no_days"]);
                sb.AppendFormat("<td>{0}</td>", r["leave_year"]);
                sb.Append("</tr>");
            }
            sb.Append("</tbody></table>");
        }

        return sb.ToString();
    }

    private string BuildPayrollHtml(int empID)
    {
        DataTable dt = ExecuteQuery(@"
            SELECT p.payroll_title, p.payroll_month, p.payroll_year, p.payroll_date,
                   pd.basic_pay, pd.paye, pd.nssf, pd.total_allowances, pd.total_deductions,
                   pd.gross_pay, pd.net_pay
            FROM hrm_payroll_details pd
            JOIN hrm_payroll p ON p.ID = pd.payrollID
            WHERE pd.empID = @id
            ORDER BY p.payroll_year DESC, p.payroll_month DESC
            LIMIT 24",
            new MySqlParameter("@id", empID));

        if (dt.Rows.Count == 0)
            return "<div style='padding:20px;text-align:center;color:#888;font-size:12px;'>No payroll records found.</div>";

        StringBuilder sb = new StringBuilder();
        sb.Append("<table class='ep-data-table'><thead><tr>");
        sb.Append("<th>Period</th><th class='text-right'>Basic Pay</th><th class='text-right'>Allowances</th>");
        sb.Append("<th class='text-right'>Gross Pay</th><th class='text-right'>PAYE</th><th class='text-right'>NSSF</th>");
        sb.Append("<th class='text-right'>Deductions</th><th class='text-right'>Net Pay</th>");
        sb.Append("</tr></thead><tbody>");

        foreach (DataRow r in dt.Rows)
        {
            sb.Append("<tr>");
            sb.AppendFormat("<td><strong>{0}/{1}</strong><br/><span style='font-size:9px;color:#888;'>{2}</span></td>",
                r["payroll_month"], r["payroll_year"], HttpUtility.HtmlEncode(r["payroll_title"].ToString()));
            sb.AppendFormat("<td class='text-right'>{0}</td>", FormatAmount(r["basic_pay"]));
            sb.AppendFormat("<td class='text-right'>{0}</td>", FormatAmount(r["total_allowances"]));
            sb.AppendFormat("<td class='text-right' style='font-weight:600;'>{0}</td>", FormatAmount(r["gross_pay"]));
            sb.AppendFormat("<td class='text-right' style='color:#dc3545;'>{0}</td>", FormatAmount(r["paye"]));
            sb.AppendFormat("<td class='text-right' style='color:#dc3545;'>{0}</td>", FormatAmount(r["nssf"]));
            sb.AppendFormat("<td class='text-right' style='color:#dc3545;'>{0}</td>", FormatAmount(r["total_deductions"]));
            sb.AppendFormat("<td class='text-right' style='font-weight:700;color:#174DA4;'>{0}</td>", FormatAmount(r["net_pay"]));
            sb.Append("</tr>");
        }

        sb.Append("</tbody></table>");
        return sb.ToString();
    }

    private string BuildEmergencyHtml(DataRow emp)
    {
        StringBuilder sb = new StringBuilder();

        // Emergency Contact
        sb.Append("<div style='font-size:10px;text-transform:uppercase;letter-spacing:.5px;color:#174DA4;font-weight:700;padding:6px 10px 3px;border-bottom:1px solid #e8e8e8;'>Emergency Contact</div>");
        sb.Append("<div class='ep-bio-grid' style='grid-template-columns:repeat(2,1fr);'>");
        AddBioItem(sb, "Contact Person", emp["contact_person"]);
        AddBioItem(sb, "Relationship", emp["relation"]);
        AddBioItem(sb, "Contact Phone", emp["phone_contacts"]);
        sb.Append("</div>");

        // Referees
        sb.Append("<div style='font-size:10px;text-transform:uppercase;letter-spacing:.5px;color:#174DA4;font-weight:700;padding:6px 10px 3px;border-bottom:1px solid #e8e8e8;margin-top:4px;'>Referees</div>");
        sb.Append("<div class='ep-bio-grid' style='grid-template-columns:repeat(2,1fr);'>");
        AddBioItem(sb, "Referee 1", emp["referee_1"]);
        AddBioItem(sb, "Referee 2", emp["referee_2"]);
        sb.Append("</div>");

        return sb.ToString();
    }

    #endregion

    #region AJAX Handler

    private void HandleAjaxAction(string action)
    {
        Response.ContentType = "application/json";
        Response.Clear();

        try
        {
            switch (action)
            {
                case "getStats":
                    WriteStats();
                    break;
                default:
                    Response.Write("{\"error\":\"Unknown action\"}");
                    break;
            }
        }
        catch (Exception ex)
        {
            Response.Write("{\"error\":\"" + ex.Message.Replace("\"", "'") + "\"}");
        }

        Response.End();
    }

    private void WriteStats()
    {
        DataTable dt = ExecuteQuery(@"
            SELECT 
                COUNT(*) AS total,
                SUM(CASE WHEN e.EmpType='Academic' THEN 1 ELSE 0 END) AS academic,
                SUM(CASE WHEN e.EmpType='Administrative' THEN 1 ELSE 0 END) AS admin,
                SUM(CASE WHEN c.contractStatus='VALID' THEN 1 ELSE 0 END) AS active_contracts
            FROM hrm_employee e
            LEFT JOIN hrm_emp_contracts c ON c.empID = e.empID AND c.ID = (SELECT MAX(c2.ID) FROM hrm_emp_contracts c2 WHERE c2.empID = e.empID)");

        DataRow r = dt.Rows[0];
        Response.Write(string.Format("{{\"total\":{0},\"academic\":{1},\"admin\":{2},\"active\":{3}}}",
            r["total"], r["academic"], r["admin"], r["active_contracts"]));
    }

    #endregion

    #region Password Change

    protected void btnChangePassword_Click(object sender, EventArgs e)
    {
        int empID;
        if (!int.TryParse(hdnPwdEmpID.Value, out empID)) return;

        string newPwd = txtNewPassword.Text.Trim();
        string confirmPwd = txtConfirmPassword.Text.Trim();

        if (string.IsNullOrEmpty(newPwd) || newPwd != confirmPwd) return;

        // Get the employee's username (fall back to email if usernames field is empty)
        DataTable dt = ExecuteQuery("SELECT usernames, emp_email FROM hrm_employee WHERE empID = @id", new MySqlParameter("@id", empID));
        if (dt.Rows.Count == 0) return;

        string username = dt.Rows[0]["usernames"].ToString().Trim();
        if (string.IsNullOrEmpty(username) || username == "-")
            username = dt.Rows[0]["emp_email"].ToString().Trim();
        if (username == "-") username = "";

        if (string.IsNullOrEmpty(username))
        {
            ScriptManager.RegisterStartupScript(this, GetType(), "pwdErr",
                "document.getElementById('pwdResult').innerHTML='<span style=\"color:#d32f2f;\">This employee has no username or email assigned.</span>';document.getElementById('changePwdModal').style.display='flex';", true);
            return;
        }

        try
        {
            // Resolve to a MembershipUser: try by username, then by email
            MembershipUser user = Membership.GetUser(username);
            if (user == null)
            {
                string nameByEmail = Membership.GetUserNameByEmail(username);
                if (!string.IsNullOrEmpty(nameByEmail))
                    user = Membership.GetUser(nameByEmail);
            }

            if (user == null)
            {
                ScriptManager.RegisterStartupScript(this, GetType(), "pwdErr",
                    "document.getElementById('pwdResult').innerHTML='<span style=\"color:#d32f2f;\">No membership account found for \\'" + Server.HtmlEncode(username) + "\\'.</span>';document.getElementById('changePwdModal').style.display='flex';", true);
                return;
            }

            // Unlock if locked out
            if (user.IsLockedOut)
            {
                user.UnlockUser();
            }

            // Reset then change to new password
            string tempPwd = user.ResetPassword();
            user.ChangePassword(tempPwd, newPwd);

            ScriptManager.RegisterStartupScript(this, GetType(), "pwdOk",
                "document.getElementById('pwdResult').innerHTML='<span style=\"color:#28a745;\">Password changed successfully for \\'" + Server.HtmlEncode(user.UserName) + "\\'.</span>';document.getElementById('changePwdModal').style.display='flex';", true);
        }
        catch (Exception ex)
        {
            string msg = ex.Message.Replace("'", "\\'").Replace("\"", "&quot;");
            ScriptManager.RegisterStartupScript(this, GetType(), "pwdErr",
                "document.getElementById('pwdResult').innerHTML='<span style=\"color:#d32f2f;\">" + msg + "</span>';document.getElementById('changePwdModal').style.display='flex';", true);
        }
    }

    #endregion

    #region Helper Methods

    protected string GetPhotoUrl(object empCode)
    {
        if (empCode == null || empCode == DBNull.Value) return "../staffimages/default.jpg";
        string code = empCode.ToString().Replace("/", "_");
        return "../staffimages/" + code + ".jpg";
    }

    protected string GetStatusBadge(object status)
    {
        if (status == null || status == DBNull.Value) return "<span class='hr-badge hr-badge--admin'>No Contract</span>";
        string s = status.ToString().ToUpper();
        string cssClass = "hr-badge--admin";
        if (s == "VALID") cssClass = "hr-badge--valid";
        else if (s == "EXPIRED") cssClass = "hr-badge--expired";
        else if (s == "TERMINATED") cssClass = "hr-badge--terminated";
        else if (s == "RESIGNED") cssClass = "hr-badge--resigned";
        return string.Format("<span class='hr-badge {0}'>{1}</span>", cssClass, HttpUtility.HtmlEncode(s));
    }

    protected string FormatAmount(object val)
    {
        if (val == null || val == DBNull.Value) return "&mdash;";
        decimal d;
        if (decimal.TryParse(val.ToString(), out d))
        {
            return d.ToString("N0");
        }
        return val.ToString();
    }

    protected string GetProfileClickScript(object empID)
    {
        return "openEmployeeProfile(" + empID + ")";
    }

    protected string GetEditClickScript(object empID)
    {
        return "gridEditRow('gvEmployees'," + empID + ")";
    }

    protected string GetActionButtonsHtml(object empID, object empNameObj, object usernameObj, object emailObj)
    {
        string id = empID.ToString();
        string dotsSvg = "<svg xmlns='http://www.w3.org/2000/svg' width='16' height='16' viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2'><circle cx='12' cy='5' r='1'></circle><circle cx='12' cy='12' r='1'></circle><circle cx='12' cy='19' r='1'></circle></svg>";
        string viewSvg = "<svg xmlns='http://www.w3.org/2000/svg' width='14' height='14' viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2'><path d='M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z'></path><circle cx='12' cy='12' r='3'></circle></svg>";
        string editSvg = "<svg xmlns='http://www.w3.org/2000/svg' width='14' height='14' viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2'><path d='M12 20h9'></path><path d='M16.5 3.5a2.121 2.121 0 0 1 3 3L7 19l-4 1 1-4L16.5 3.5z'></path></svg>";
        string pwdSvg = "<svg xmlns='http://www.w3.org/2000/svg' width='14' height='14' viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2'><rect x='3' y='11' width='18' height='11' rx='2' ry='2'></rect><path d='M7 11V7a5 5 0 0 1 10 0v4'></path></svg>";

        string empName = SafeVal(empNameObj).Replace("'", "\\'");
        string username = SafeVal(usernameObj).Replace("'", "\\'");
        string email = SafeVal(emailObj).Replace("'", "\\'");
        if (username == "-") username = "";
        if (email == "-") email = "";
        string displayUsername = string.IsNullOrEmpty(username) ? email : username;

        return "<div class='cd-action-wrapper'>" +
            "<button type='button' class='cd-action-trigger' onclick='toggleActionPopover(this, event)'>" + dotsSvg + "</button>" +
            "<div class='cd-action-popover'>" +
            "<ul class='cd-action-popover__menu'>" +
            "<li class='cd-action-popover__item'><button type='button' class='cd-action-popover__btn cd-action-popover__btn--view' onclick='openEmployeeProfile(" + id + ")'>" + viewSvg + " View Profile</button></li>" +
            "<li class='cd-action-popover__item'><button type='button' class='cd-action-popover__btn cd-action-popover__btn--edit' onclick='gridEditRow(" + '"' + "gvEmployees" + '"' + "," + id + ")'>" + editSvg + " Edit</button></li>" +
            "<li class='cd-action-popover__divider'></li>" +
            "<li class='cd-action-popover__item'><button type='button' class='cd-action-popover__btn cd-action-popover__btn--password' onclick='openPasswordModal(" + id + "," + '"' + empName + '"' + "," + '"' + displayUsername + '"' + ")'>" + pwdSvg + " Change Password</button></li>" +
            "</ul></div></div>";
    }

    private string FormatDate(object val)
    {
        if (val == null || val == DBNull.Value) return "&mdash;";
        DateTime dt;
        if (DateTime.TryParse(val.ToString(), out dt))
            return dt.ToString("dd MMM yyyy");
        return val.ToString();
    }

    private string SafeVal(object val)
    {
        if (val == null || val == DBNull.Value) return "";
        return val.ToString();
    }

    #endregion

    #region Data Access

    private DataTable ExecuteQuery(string sql, params MySqlParameter[] parms)
    {
        DataTable dt = new DataTable();
        using (MySqlConnection conn = new MySqlConnection(ConnStr))
        {
            conn.Open();
            using (MySqlCommand cmd = new MySqlCommand(sql, conn))
            {
                if (parms != null)
                {
                    foreach (MySqlParameter p in parms)
                        cmd.Parameters.Add(p);
                }
                using (MySqlDataAdapter da = new MySqlDataAdapter(cmd))
                {
                    da.Fill(dt);
                }
            }
        }
        return dt;
    }

    private int ExecuteNonQuery(string sql, params MySqlParameter[] parms)
    {
        using (MySqlConnection conn = new MySqlConnection(ConnStr))
        {
            conn.Open();
            using (MySqlCommand cmd = new MySqlCommand(sql, conn))
            {
                if (parms != null)
                {
                    foreach (MySqlParameter p in parms)
                        cmd.Parameters.Add(p);
                }
                return cmd.ExecuteNonQuery();
            }
        }
    }

    #endregion
}
