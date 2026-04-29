using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Text;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.Security;
using MySql.Data.MySqlClient;
using DevExpress.Web;

public partial class COOPERP_NewScreens_HREmployees : System.Web.UI.Page
{
    protected string QsSort
    {
        get
        {
            string sort = (Request.QueryString["sort"] ?? string.Empty).Trim().ToLower();
            switch (sort)
            {
                case "name":
                case "code":
                case "phone":
                case "type":
                case "dept":
                case "supervisor":
                case "station":
                case "status":
                case "pay":
                    return sort;
                default:
                    return string.Empty;
            }
        }
    }

    protected string QsSortDir
    {
        get
        {
            return string.Equals(Request.QueryString["dir"], "DESC", StringComparison.OrdinalIgnoreCase) ? "DESC" : "ASC";
        }
    }

    private string ConnStr
    {
        get { return ConfigurationManager.ConnectionStrings["vacConnectionString"].ConnectionString; }
    }

    private TextBox txtNewName { get { return txtEmpName; } }
    private TextBox txtNewEmail { get { return txtEmpEmail; } }
    private TextBox txtNewPhone { get { return txtEmpPhone; } }
    private TextBox txtNewDOB { get { return txtEmpDOB; } }
    private DropDownList ddlNewGender { get { return ddlGender; } }
    private TextBox txtNewQualifications { get { return txtQualifications; } }
    private DropDownList ddlNewEducation { get { return ddlEducation; } }
    private DropDownList ddlNewNationality { get { return ddlNationality; } }
    private DropDownList ddlNewType { get { return ddlEmpType; } }
    private DropDownList ddlNewMarital { get { return ddlMarital; } }
    private TextBox txtNewAddress { get { return txtAddress; } }
    private TextBox txtNewResidence { get { return txtResidence; } }
    private TextBox txtNewReligion { get { return txtReligion; } }
    private TextBox txtNewTribe { get { return txtTribe; } }
    private TextBox txtNewTIN { get { return txtTIN; } }
    private TextBox txtNewNSSF { get { return txtNSSF; } }
    private DropDownList ddlNewBank { get { return ddlBank; } }
    private TextBox txtNewBankAccount { get { return txtBankAccount; } }
    private TextBox txtNewSpouse { get { return txtSpouse; } }
    private TextBox txtNewChildren { get { return txtChildren; } }
    private TextBox txtNewFather { get { return txtFather; } }
    private TextBox txtNewMother { get { return txtMother; } }
    private TextBox txtNewContactPerson { get { return txtContactPerson; } }
    private TextBox txtNewRelation { get { return txtRelation; } }
    private TextBox txtNewContactPhone { get { return txtContactPhone; } }
    private TextBox txtNewReferee1 { get { return txtReferee1; } }
    private TextBox txtNewReferee2 { get { return txtReferee2; } }
    private TextBox txtNewMedical { get { return txtMedical; } }
    private TextBox txtNewSchooling { get { return txtSchooling; } }
    private TextBox txtNewEmployment { get { return txtEmploymentHist; } }
    private TextBox txtNewEntryYear { get { return txtEntryYear; } }
    private DropDownList ddlNewStation { get { return ddlStation; } }

    protected void Page_Init(object sender, EventArgs e)
    {
        // Handle AJAX actions
        string action = Request.QueryString["ajax"];
        if (string.IsNullOrEmpty(action))
            action = Request.QueryString["action"];

        if (!string.IsNullOrEmpty(action))
        {
            if (string.Equals(action, "export_employees", StringComparison.OrdinalIgnoreCase))
            {
                WriteEmployeesExportCsv();
                return;
            }

            HandleAjaxAction(action);
            return;
        }
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            LoadFilterDropdowns();
            ApplyFiltersFromQueryString();
            LoadStats();
        }
        BindEmployeeGrid();
    }

    private void ApplyFiltersFromQueryString()
    {
        txtSearch.Text = (Request.QueryString["q"] ?? string.Empty).Trim();
        SetSelectedValue(ddlFilterStatus, Request.QueryString["status"]);
        SetSelectedValue(ddlFilterType, Request.QueryString["type"]);
        SetSelectedValue(ddlFilterDept, Request.QueryString["dept"]);
        SetSelectedValue(ddlFilterStation, Request.QueryString["station"]);
        SetSelectedValue(ddlPageSize, Request.QueryString["sz"]);
    }

    private void SetSelectedValue(ListControl control, string value)
    {
        if (control == null || string.IsNullOrEmpty(value)) return;
        ListItem item = control.Items.FindByValue(value);
        if (item != null)
            control.SelectedValue = value;
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
            j.jobname,
            mm.CreationDate AS AccountCreated
        FROM hrm_employee e
        LEFT JOIN hrm_emp_contracts c ON c.empID = e.empID AND c.ID = (
            SELECT MAX(c2.ID) FROM hrm_emp_contracts c2 WHERE c2.empID = e.empID
        )
        LEFT JOIN hrm_departments d ON d.ID = c.departmentID
        LEFT JOIN hrm_stations st ON st.ID = e.Entry_Satation
        LEFT JOIN hrm_payscales ps ON ps.ID = c.payscale
        LEFT JOIN hrm_jobs j ON j.ID = c.jobID
        LEFT JOIN my_aspnet_users mu ON mu.name = e.usernames
        LEFT JOIN my_aspnet_membership mm ON mm.userId = mu.id
        WHERE 1=1 ");

        List<MySqlParameter> parms = new List<MySqlParameter>();

        if (!string.IsNullOrEmpty(search))
        {
            sql.Append(" AND (e.emp_name LIKE @search OR e.EMP_CODE LIKE @search OR e.emp_email LIKE @search OR e.emp_phone LIKE @search OR e.usernames LIKE @search) ");
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

        sql.Append(" ORDER BY " + GetOrderByClause() + " ");

        int pageSize = 50;
        int.TryParse(ddlPageSize.SelectedValue, out pageSize);
        if (pageSize <= 0) pageSize = 50;
        sql.Append(" LIMIT " + pageSize.ToString() + " ");

        DataTable dt = ExecuteQuery(sql.ToString(), parms.ToArray());
        StringBuilder body = new StringBuilder();
        int sn = 1;

        foreach (DataRow r in dt.Rows)
        {
            string empID = SafeVal(r["empID"]);
            string empCode = SafeVal(r["EMP_CODE"]);
            string empName = SafeVal(r["emp_name"]);
            string email = SafeVal(r["emp_email"]);
            string phone = SafeVal(r["emp_phone"]);
            string typeBadge = string.IsNullOrEmpty(SafeVal(r["EmpType"])) ? "" : string.Format("<span class='hr-badge {0}'>{1}</span>", SafeVal(r["EmpType"]).Contains("Acad") ? "hr-badge--academic" : "hr-badge--admin", HttpUtility.HtmlEncode(SafeVal(r["EmpType"])));

            body.Append("<tr>");
            body.AppendFormat("<td class='ct-col-num'>{0}</td>", sn++);
            body.AppendFormat("<td><div class='emp-cell'><img class='emp-thumb' src='{0}' alt='' onerror=\"this.onerror=null;this.src='../staffimages/default.jpg'\" onclick=\"openLightbox('{0}','{1}')\" /><div class='emp-info'><div class='emp-name'>{1}</div><div class='emp-sub'>{2}</div></div></div></td>", GetPhotoUrl(empCode), HttpUtility.HtmlEncode(empName), HttpUtility.HtmlEncode(email));
            body.AppendFormat("<td><span class='emp-code'>{0}</span></td>", HttpUtility.HtmlEncode(empCode));
            body.AppendFormat("<td>{0}<div class='emp-sub'>{1}</div></td>", HttpUtility.HtmlEncode(phone), HttpUtility.HtmlEncode(SafeVal(r["station_name"])));
            body.AppendFormat("<td>{0}</td>", typeBadge);
            body.AppendFormat("<td>{0}</td>", HttpUtility.HtmlEncode(SafeVal(r["dept_name"])));
            body.AppendFormat("<td>{0}</td>", HttpUtility.HtmlEncode(SafeVal(r["jobname"])));
            body.AppendFormat("<td class='ct-col-pay'>{0}<div class='emp-scale'>{1}</div></td>", FormatAmount(r["basicpay"]), HttpUtility.HtmlEncode(SafeVal(r["scale_name"])));
            body.AppendFormat("<td>{0}</td>", GetStatusBadge(r["contractStatus"]));
            body.AppendFormat("<td class='ct-col-actions'>{0}</td>", GetActionButtonsHtml(r["empID"], r["emp_name"], r["usernames"], r["emp_email"]));
            body.Append("</tr>");
        }

        if (body.Length == 0)
            body.Append("<tr><td colspan='10' class='ct-empty-state'>No employees found.</td></tr>");

        litGridBody.Text = body.ToString();
        litPagerInfo.Text = string.Format("Showing {0} employee(s)", dt.Rows.Count);
        litPager.Text = string.Empty;
    }

    private string GetOrderByClause()
    {
        switch (QsSort)
        {
            case "code":
                return "e.EMP_CODE " + QsSortDir;
            case "phone":
                return "e.emp_phone " + QsSortDir;
            case "type":
                return "e.EmpType " + QsSortDir + ", e.emp_name ASC";
            case "dept":
                return "d.dept_name " + QsSortDir + ", e.emp_name ASC";
            case "supervisor":
                return "j.jobname " + QsSortDir + ", e.emp_name ASC";
            case "station":
                return "st.station_name " + QsSortDir + ", e.emp_name ASC";
            case "status":
                return "c.contractStatus " + QsSortDir + ", e.emp_name ASC";
            case "pay":
                return "IFNULL(ps.basicpay, c.fixedamount) " + QsSortDir + ", e.emp_name ASC";
            case "name":
            case "":
            default:
                return "e.emp_name " + QsSortDir;
        }
    }

    private void LoadStats()
    {
        DataTable dt = ExecuteQuery(@"SELECT
                COUNT(*) AS total_cnt,
                SUM(CASE WHEN IFNULL(EmpType,'') LIKE '%Acad%' THEN 1 ELSE 0 END) AS academic_cnt,
                SUM(CASE WHEN IFNULL(EmpType,'') NOT LIKE '%Acad%' THEN 1 ELSE 0 END) AS admin_cnt,
                SUM(CASE WHEN UPPER(IFNULL(c.contractStatus,'')) = 'VALID' THEN 1 ELSE 0 END) AS active_cnt,
                SUM(CASE WHEN IFNULL(c.contractStatus,'') = '' OR UPPER(IFNULL(c.contractStatus,'')) <> 'VALID' THEN 1 ELSE 0 END) AS inactive_cnt
            FROM hrm_employee e
            LEFT JOIN hrm_emp_contracts c ON c.empID = e.empID AND c.ID = (
                SELECT MAX(c2.ID) FROM hrm_emp_contracts c2 WHERE c2.empID = e.empID
            )");

        if (dt.Rows.Count == 0) return;
        DataRow r = dt.Rows[0];
        litStatTotal.Text = SafeVal(r["total_cnt"]);
        litStatAcademic.Text = SafeVal(r["academic_cnt"]);
        litStatAdmin.Text = SafeVal(r["admin_cnt"]);
        litStatActive.Text = SafeVal(r["active_cnt"]);
        litStatInactive.Text = SafeVal(r["inactive_cnt"]);
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
        BindEmployeeGrid();
    }

    protected void gvEmployees_RowDeleting(object sender, DevExpress.Web.Data.ASPxDataDeletingEventArgs e)
    {
        int empID = Convert.ToInt32(e.Keys["empID"]);
        ExecuteNonQuery("DELETE FROM hrm_employee WHERE empID = @id", new MySqlParameter("@id", empID));

        e.Cancel = true;
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

    protected void btnEditEmployee_Click(object sender, EventArgs e)
    {
        int empID;
        if (!int.TryParse(hdnEditEmpID.Value, out empID) || empID <= 0)
            return;

        string name = txtNewName.Text.Trim();
        string email = txtNewEmail.Text.Trim();
        string phone = txtNewPhone.Text.Trim();

        if (string.IsNullOrEmpty(name) || string.IsNullOrEmpty(email) || string.IsNullOrEmpty(phone))
            return;

        DateTime dob;
        bool hasDOB = DateTime.TryParse(txtNewDOB.Text, out dob);
        int bankId = 0;
        int.TryParse(ddlNewBank.SelectedValue, out bankId);
        int nChildren = 0;
        int.TryParse(txtNewChildren.Text.Trim(), out nChildren);
        int entryYear = DateTime.Now.Year;
        int.TryParse(txtNewEntryYear.Text.Trim(), out entryYear);

        string sql = @"UPDATE hrm_employee SET
                emp_name = @name,
                emp_email = @email,
                emp_phone = @phone,
                emp_birthdate = @dob,
                gender = @gender,
                emp_qualifications = @qual,
                max_education = @maxEdu,
                emp_nationality = @nat,
                EmpType = @empType,
                marital_status = @marital,
                address = @addr,
                current_residence = @residence,
                religion = @religion,
                tribe = @tribe,
                tin = @tin,
                nssf_no = @nssf,
                bankID = @bankID,
                bankAccount = @bankAcct,
                spouse_name = @spouse,
                no_children = @nChildren,
                father_name = @father,
                mother_name = @mother,
                contact_person = @contactPerson,
                relation = @relation,
                phone_contacts = @contactPhone,
                referee_1 = @ref1,
                referee_2 = @ref2,
                medical_background = @medical,
                schooling_info = @schooling,
                employment_info = @employment,
                Entry_Year = @year,
                Entry_Satation = @station
            WHERE empID = @id";

        ExecuteNonQuery(sql,
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
            new MySqlParameter("@station", ddlNewStation.SelectedValue),
            new MySqlParameter("@id", empID)
        );

        BindEmployeeGrid();
    }

    protected void btnDeleteEmployee_Click(object sender, EventArgs e)
    {
        int empID;
        if (!int.TryParse(hdnDeleteEmpID.Value, out empID) || empID <= 0)
            return;

        ExecuteNonQuery("DELETE FROM hrm_employee WHERE empID = @id", new MySqlParameter("@id", empID));
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
        // Legacy server-side profile popup is no longer used by the current page markup.
        // Profile loading is handled by the current client-side UI.
        return;
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
                case "search_emp":
                    WriteEmployeeSearchResults();
                    break;
                case "get_emp":
                    WriteEmployeeDetails();
                    break;
                case "get_profile":
                    WriteEmployeeProfile();
                    break;
                case "getStats":
                    WriteStats();
                    break;
                case "reset_pwd":
                    WriteResetPwdAjax();
                    break;
                default:
                    WriteJson(new Dictionary<string, object> { { "error", "Unknown action" } });
                    break;
            }
        }
        catch (Exception ex)
        {
            WriteJson(new Dictionary<string, object> { { "error", ex.Message } });
        }

        Response.End();
    }

    private void WriteEmployeeSearchResults()
    {
        string q = (Request.QueryString["q"] ?? string.Empty).Trim();
        List<Dictionary<string, object>> results = new List<Dictionary<string, object>>();

        if (!string.IsNullOrEmpty(q))
        {
            DataTable dt = ExecuteQuery(@"
                SELECT e.empID, e.EMP_CODE, e.emp_name, IFNULL(j.jobname, '') AS emp_position
                FROM hrm_employee e
                LEFT JOIN hrm_emp_contracts c ON c.empID = e.empID AND c.ID = (
                    SELECT MAX(c2.ID) FROM hrm_emp_contracts c2 WHERE c2.empID = e.empID
                )
                LEFT JOIN hrm_jobs j ON j.ID = c.jobID
                WHERE e.emp_name LIKE @q OR e.EMP_CODE LIKE @q OR e.emp_email LIKE @q OR e.emp_phone LIKE @q
                ORDER BY e.emp_name ASC
                LIMIT 20",
                new MySqlParameter("@q", "%" + q + "%"));

            foreach (DataRow row in dt.Rows)
            {
                results.Add(new Dictionary<string, object>
                {
                    { "empID", SafeVal(row["empID"]) },
                    { "EMP_CODE", SafeVal(row["EMP_CODE"]) },
                    { "emp_name", SafeVal(row["emp_name"]) },
                    { "emp_position", SafeVal(row["emp_position"]) }
                });
            }
        }

        WriteJson(new Dictionary<string, object> { { "results", results } });
    }

    private void WriteEmployeeDetails()
    {
        int empID;
        if (!int.TryParse(Request.QueryString["id"], out empID) || empID <= 0)
        {
            WriteJson(new Dictionary<string, object> { { "error", "Invalid employee id." } });
            return;
        }

        DataTable dt = ExecuteQuery(@"
            SELECT e.*
            FROM hrm_employee e
            WHERE e.empID = @id",
            new MySqlParameter("@id", empID));

        if (dt.Rows.Count == 0)
        {
            WriteJson(new Dictionary<string, object> { { "error", "Employee not found." } });
            return;
        }

        DataRow row = dt.Rows[0];
        WriteJson(new Dictionary<string, object>
        {
            { "empID", SafeVal(row["empID"]) },
            { "emp_name", SafeVal(row["emp_name"]) },
            { "emp_email", SafeVal(row["emp_email"]) },
            { "emp_phone", SafeVal(row["emp_phone"]) },
            { "emp_birthdate", ToIsoDate(row["emp_birthdate"]) },
            { "gender", SafeVal(row["gender"]) },
            { "marital_status", SafeVal(row["marital_status"]) },
            { "emp_nationality", SafeVal(row["emp_nationality"]) },
            { "religion", SafeVal(row["religion"]) },
            { "tribe", SafeVal(row["tribe"]) },
            { "nin", SafeVal(row["tin"]) },
            { "current_residence", SafeVal(row["current_residence"]) },
            { "address", SafeVal(row["address"]) },
            { "EmpType", SafeVal(row["EmpType"]) },
            { "Entry_Satation", SafeVal(row["Entry_Satation"]) },
            { "Entry_Year", SafeVal(row["Entry_Year"]) },
            { "max_education", SafeVal(row["max_education"]) },
            { "emp_qualifications", SafeVal(row["emp_qualifications"]) },
            { "tin", SafeVal(row["tin"]) },
            { "nssf_no", SafeVal(row["nssf_no"]) },
            { "bankID", SafeVal(row["bankID"]) },
            { "bankAccount", SafeVal(row["bankAccount"]) },
            { "spouse_name", SafeVal(row["spouse_name"]) },
            { "no_children", SafeVal(row["no_children"]) },
            { "father_name", SafeVal(row["father_name"]) },
            { "mother_name", SafeVal(row["mother_name"]) },
            { "contact_person", SafeVal(row["contact_person"]) },
            { "relation", SafeVal(row["relation"]) },
            { "phone_contacts", SafeVal(row["phone_contacts"]) },
            { "referee_1", SafeVal(row["referee_1"]) },
            { "referee_2", SafeVal(row["referee_2"]) },
            { "medical_background", SafeVal(row["medical_background"]) },
            { "schooling_info", SafeVal(row["schooling_info"]) },
            { "employment_info", SafeVal(row["employment_info"]) },
            { "supervisorID", string.Empty },
            { "supervisor_name", string.Empty },
            { "supervisor_code", string.Empty },
            { "employment_status", string.Empty },
            { "date_joined", string.Empty },
            { "probation_end_date", string.Empty },
            { "to_be_appraised", "1" },
            { "appraisal_cycle", "ANNUAL" },
            { "reviewer_id", string.Empty },
            { "reviewer_name", string.Empty },
            { "reviewer_code", string.Empty }
        });
    }

    private void WriteEmployeeProfile()
    {
        int empID;
        if (!int.TryParse(Request.QueryString["id"], out empID) || empID <= 0)
        {
            WriteJson(new Dictionary<string, object> { { "error", "Invalid employee id." } });
            return;
        }

        DataTable dtEmp = ExecuteQuery(@"
            SELECT e.*, d.dept_name, st.station_name, c.contractStatus, c.contractStart, c.contractEnd,
                ps.scale_name, IFNULL(ps.basicpay, c.fixedamount) AS basicpay, j.jobname
            FROM hrm_employee e
            LEFT JOIN hrm_emp_contracts c ON c.empID = e.empID AND c.ID = (SELECT MAX(c2.ID) FROM hrm_emp_contracts c2 WHERE c2.empID = e.empID)
            LEFT JOIN hrm_departments d ON d.ID = c.departmentID
            LEFT JOIN hrm_stations st ON st.ID = e.Entry_Satation
            LEFT JOIN hrm_payscales ps ON ps.ID = c.payscale
            LEFT JOIN hrm_jobs j ON j.ID = c.jobID
            WHERE e.empID = @id",
            new MySqlParameter("@id", empID));

        if (dtEmp.Rows.Count == 0)
        {
            WriteJson(new Dictionary<string, object> { { "error", "Employee not found." } });
            return;
        }

        DataRow emp = dtEmp.Rows[0];
        string empCode = SafeVal(emp["EMP_CODE"]);

        WriteJson(new Dictionary<string, object>
        {
            { "name", SafeVal(emp["emp_name"]) },
            { "code", empCode },
            { "photo", GetPhotoUrl(empCode) },
            { "statusBadge", GetStatusBadge(emp["contractStatus"]) },
            { "type", SafeVal(emp["EmpType"]) },
            { "dept", SafeVal(emp["dept_name"]) },
            { "station", SafeVal(emp["station_name"]) },
            { "pay", emp["basicpay"] != DBNull.Value ? "UGX " + Convert.ToDecimal(emp["basicpay"]).ToString("N0") : "N/A" },
            { "bioHtml", BuildBioDataHtml(emp) },
            { "contractsHtml", BuildContractsHtml(empID) },
            { "qualificationsHtml", BuildQualificationsHtml(empCode) },
            { "leaveHtml", BuildLeaveHtml(empID) },
            { "payrollHtml", BuildPayrollHtml(empID) },
            { "emergencyHtml", BuildEmergencyHtml(emp) }
        });
    }

    private void WriteJson(object data)
    {
        JavaScriptSerializer serializer = new JavaScriptSerializer();
        serializer.MaxJsonLength = int.MaxValue;
        Response.Write(serializer.Serialize(data));
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

    private void WriteEmployeesExportCsv()
    {
        string search = (Request.QueryString["q"] ?? string.Empty).Trim();
        string dept = (Request.QueryString["dept"] ?? string.Empty).Trim();
        string station = (Request.QueryString["station"] ?? string.Empty).Trim();
        string empType = (Request.QueryString["type"] ?? string.Empty).Trim();
        string status = (Request.QueryString["status"] ?? string.Empty).Trim();

        StringBuilder sql = new StringBuilder();
        sql.Append(@"SELECT
            e.empID,
            e.EMP_CODE,
            e.emp_name,
            e.emp_email,
            e.emp_phone,
            e.EmpType,
            IFNULL(d.dept_name, '') AS department,
            IFNULL(st.station_name, '') AS station,
            IFNULL(j.jobname, '') AS job_title,
            IFNULL(c.contractStatus, '') AS contract_status,
            c.contractStart,
            c.contractEnd,
            IFNULL(ps.scale_name, '') AS pay_scale,
            IFNULL(ps.basicpay, c.fixedamount) AS basic_pay,
            IFNULL(c.fixedamount, 0) AS contract_fixed_amount,
            IFNULL(c.ID, 0) AS contract_id
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
            sql.Append(" AND (e.emp_name LIKE @search OR e.EMP_CODE LIKE @search OR e.emp_email LIKE @search OR e.emp_phone LIKE @search OR e.usernames LIKE @search) ");
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
            if (string.Equals(status, "NONE", StringComparison.OrdinalIgnoreCase))
                sql.Append(" AND (IFNULL(c.contractStatus,'') = '' OR UPPER(IFNULL(c.contractStatus,'')) <> 'VALID') ");
            else
            {
                sql.Append(" AND c.contractStatus = @status ");
                parms.Add(new MySqlParameter("@status", status));
            }
        }

        sql.Append(" ORDER BY " + GetOrderByClause() + " ");

        DataTable dt = ExecuteQuery(sql.ToString(), parms.ToArray());

        StringBuilder csv = new StringBuilder();
        csv.AppendLine("Employee ID,Staff Code,Employee Name,Email,Phone,Employee Type,Department,Station,Job Title,Contract Status,Contract Start,Contract End,Pay Scale,Basic Pay,Contract Fixed Amount,Contract ID");

        foreach (DataRow row in dt.Rows)
        {
            csv.Append(EscapeCsv(SafeVal(row["empID"]))).Append(',')
               .Append(EscapeCsv(SafeVal(row["EMP_CODE"]))).Append(',')
               .Append(EscapeCsv(SafeVal(row["emp_name"]))).Append(',')
               .Append(EscapeCsv(SafeVal(row["emp_email"]))).Append(',')
               .Append(EscapeCsv(SafeVal(row["emp_phone"]))).Append(',')
               .Append(EscapeCsv(SafeVal(row["EmpType"]))).Append(',')
               .Append(EscapeCsv(SafeVal(row["department"]))).Append(',')
               .Append(EscapeCsv(SafeVal(row["station"]))).Append(',')
               .Append(EscapeCsv(SafeVal(row["job_title"]))).Append(',')
               .Append(EscapeCsv(SafeVal(row["contract_status"]))).Append(',')
               .Append(EscapeCsv(FormatDateCsv(row["contractStart"]))).Append(',')
               .Append(EscapeCsv(FormatDateCsv(row["contractEnd"]))).Append(',')
               .Append(EscapeCsv(SafeVal(row["pay_scale"]))).Append(',')
               .Append(EscapeCsv(FormatAmountCsv(row["basic_pay"]))).Append(',')
               .Append(EscapeCsv(FormatAmountCsv(row["contract_fixed_amount"]))).Append(',')
               .Append(EscapeCsv(SafeVal(row["contract_id"])))
               .AppendLine();
        }

        string fileName = "employees_contracts_" + DateTime.Now.ToString("yyyyMMdd_HHmm") + ".csv";
        Response.Clear();
        Response.ContentType = "text/csv; charset=utf-8";
        Response.AddHeader("Content-Disposition", "attachment; filename=" + fileName);
        Response.Write("\uFEFF");
        Response.Write(csv.ToString());
        Response.End();
    }

    private string EscapeCsv(string value)
    {
        if (value == null) value = string.Empty;
        string clean = value.Replace("\r", " ").Replace("\n", " ");
        if (clean.IndexOf('"') >= 0 || clean.IndexOf(',') >= 0)
            return "\"" + clean.Replace("\"", "\"\"") + "\"";
        return clean;
    }

    private string FormatAmountCsv(object val)
    {
        if (val == null || val == DBNull.Value) return string.Empty;
        decimal d;
        if (decimal.TryParse(val.ToString(), out d)) return d.ToString("0.##");
        return val.ToString();
    }

    private string FormatDateCsv(object val)
    {
        if (val == null || val == DBNull.Value) return string.Empty;
        DateTime dt;
        return DateTime.TryParse(val.ToString(), out dt) ? dt.ToString("yyyy-MM-dd") : val.ToString();
    }

    private void WriteResetPwdAjax()
    {
        int empID;
        if (!int.TryParse(Request.QueryString["id"], out empID) || empID <= 0)
        {
            WriteJson(new Dictionary<string, object> { { "error", "Invalid employee id." } });
            return;
        }

        try
        {
            DataTable dt = ExecuteQuery("SELECT emp_name, usernames, emp_email, emp_phone FROM hrm_employee WHERE empID = @id", new MySqlParameter("@id", empID));
            if (dt.Rows.Count == 0)
            {
                WriteJson(new Dictionary<string, object> { { "error", "Employee record not found." } });
                return;
            }

            DataRow emp = dt.Rows[0];
            string empName = SafeVal(emp["emp_name"]);
            string username = NormalizeLoginValue(emp["usernames"]);
            string email = NormalizeLoginValue(emp["emp_email"]);
            string phone = NormalizeLoginValue(emp["emp_phone"]);
            string manualPassword = SafeVal(Request["new_password"]).Trim();

            if (string.IsNullOrEmpty(username))
            {
                if (!string.IsNullOrEmpty(email)) username = email;
                else if (!string.IsNullOrEmpty(phone)) username = phone;
            }

            if (string.IsNullOrEmpty(username))
            {
                WriteJson(new Dictionary<string, object> { { "error", "This employee has no username, email, or phone on record." } });
                return;
            }

            // Try to find existing membership account
            MembershipUser user;
            MembershipProvider provider;
            bool provisioned = false;
            if (!TryResolveMembershipUser(username, email, out user, out provider))
            {
                string provisionError;
                string provisionedUsername;
                bool autoCreated = AutoProvisionMembershipAccount(empName, username, email, out provisionedUsername, out provisionError);
                if (!autoCreated)
                {
                    WriteJson(new Dictionary<string, object> { { "error", "No membership account found and auto-provision failed: " + provisionError } });
                    return;
                }

                if (!TryResolveMembershipUser(provisionedUsername, email, out user, out provider))
                {
                    if (!TryResolveMembershipUser(username, email, out user, out provider))
                    {
                        WriteJson(new Dictionary<string, object> { { "error", "Account was provisioned but could not be resolved by membership provider. Please retry in a few seconds." } });
                        return;
                    }
                }

                provisioned = true;
            }

            // Account exists - proceed with reset
            if (user.IsLockedOut)
            {
                provider.UnlockUser(user.UserName);
            }

            // Reset password and get the new temporary password
            string generatedPassword = provider.ResetPassword(user.UserName, null);

            if (string.IsNullOrEmpty(generatedPassword))
            {
                WriteJson(new Dictionary<string, object> { { "error", "Password reset returned an empty temporary password. Please retry." } });
                return;
            }

            string finalPassword = generatedPassword;
            bool customApplied = false;

            if (!string.IsNullOrEmpty(manualPassword))
            {
                if (manualPassword.Length < 6)
                {
                    WriteJson(new Dictionary<string, object> { { "error", "Typed password is too short. Use at least 6 characters." } });
                    return;
                }

                bool changed = provider.ChangePassword(user.UserName, generatedPassword, manualPassword);
                if (!changed)
                {
                    WriteJson(new Dictionary<string, object> { { "error", "Unable to set the typed password. Please use a stronger password or leave blank to auto-generate." } });
                    return;
                }

                finalPassword = manualPassword;
                customApplied = true;
            }

            WriteJson(new Dictionary<string, object>
            {
                { "success", true },
                { "temp_password", finalPassword },
                { "username", user.UserName },
                { "provisioned", provisioned },
                { "custom_applied", customApplied }
            });
        }
        catch (Exception ex)
        {
            WriteJson(new Dictionary<string, object> { { "error", ex.Message } });
        }
    }

    private bool AutoProvisionMembershipAccount(string empName, string username, string email, out string provisionedUsername, out string error)
    {
        provisionedUsername = string.Empty;
        error = string.Empty;

        string loginName = NormalizeLoginValue(username);
        if (string.IsNullOrEmpty(loginName))
        {
            loginName = NormalizeLoginValue(email);
        }
        if (string.IsNullOrEmpty(loginName))
        {
            loginName = NormalizeLoginValue(empName);
        }
        if (string.IsNullOrEmpty(loginName))
        {
            error = "No valid username/email/name available for account creation.";
            return false;
        }

        string resolvedEmail = NormalizeLoginValue(email);
        if (string.IsNullOrEmpty(resolvedEmail) || !resolvedEmail.Contains("@"))
        {
            resolvedEmail = BuildFallbackEmail(loginName);
        }

        try
        {
            DataTable existingUser;
            try
            {
                existingUser = ExecuteQuery(@"SELECT id, name FROM my_aspnet_users WHERE name = @name LIMIT 1",
                    new MySqlParameter("@name", loginName));
            }
            catch (Exception ex)
            {
                error = "Lookup in my_aspnet_users failed: " + ex.Message;
                return false;
            }

            int userId;
            if (existingUser.Rows.Count > 0)
            {
                userId = Convert.ToInt32(existingUser.Rows[0]["id"]);
                provisionedUsername = SafeVal(existingUser.Rows[0]["name"]);
                if (string.IsNullOrEmpty(provisionedUsername))
                    provisionedUsername = loginName;
            }
            else
            {
                int appId = ResolveApplicationId();
                DateTime now = DateTime.UtcNow;

                try
                {
                    ExecuteNonQuery(@"
                        INSERT INTO my_aspnet_users
                        (applicationId, name, isAnonymous, lastActivityDate, user_verification_status, verified_email, user_type)
                        VALUES
                        (@applicationId, @name, 0, @lastActivityDate, @verificationStatus, @verifiedEmail, @userType)",
                        new MySqlParameter("@applicationId", appId),
                        new MySqlParameter("@name", loginName),
                        new MySqlParameter("@lastActivityDate", now),
                        new MySqlParameter("@verificationStatus", 1),
                        new MySqlParameter("@verifiedEmail", resolvedEmail),
                        new MySqlParameter("@userType", "user"));
                }
                catch (Exception ex)
                {
                    error = "Insert into my_aspnet_users failed: " + ex.Message;
                    return false;
                }

                DataTable inserted;
                try
                {
                    inserted = ExecuteQuery(@"SELECT id, name FROM my_aspnet_users WHERE name = @name ORDER BY id DESC LIMIT 1",
                        new MySqlParameter("@name", loginName));
                }
                catch (Exception ex)
                {
                    error = "Reload from my_aspnet_users failed: " + ex.Message;
                    return false;
                }

                if (inserted.Rows.Count == 0)
                {
                    error = "Inserted user could not be reloaded from my_aspnet_users.";
                    return false;
                }

                userId = Convert.ToInt32(inserted.Rows[0]["id"]);
                provisionedUsername = SafeVal(inserted.Rows[0]["name"]);
                if (string.IsNullOrEmpty(provisionedUsername))
                    provisionedUsername = loginName;
            }

            string membershipError;
            if (!EnsureMembershipRow(userId, resolvedEmail, out membershipError))
            {
                error = membershipError;
                return false;
            }

            return true;
        }
        catch (Exception ex)
        {
            error = ex.Message;
            return false;
        }
    }

    private int ResolveApplicationId()
    {
        try
        {
            DataTable dt = ExecuteQuery(@"SELECT MIN(applicationId) AS appId FROM my_aspnet_users WHERE applicationId IS NOT NULL");
            if (dt.Rows.Count > 0 && dt.Rows[0]["appId"] != DBNull.Value)
            {
                int appId;
                if (int.TryParse(dt.Rows[0]["appId"].ToString(), out appId) && appId > 0)
                    return appId;
            }
        }
        catch
        {
        }

        return 1;
    }

    private bool EnsureMembershipRow(int userId, string email, out string error)
    {
        error = string.Empty;

        DataTable existing;
        try
        {
            existing = ExecuteQuery("SELECT userId FROM my_aspnet_membership WHERE userId = @userId LIMIT 1",
                new MySqlParameter("@userId", userId));
        }
        catch (Exception ex)
        {
            error = "Membership lookup failed: " + ex.Message;
            return false;
        }
        if (existing.Rows.Count > 0) return true;

        DataTable cols;
        try
        {
            cols = ExecuteQuery(@"
                SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE, COLUMN_DEFAULT, EXTRA
                FROM INFORMATION_SCHEMA.COLUMNS
                WHERE TABLE_SCHEMA = DATABASE()
                  AND TABLE_NAME = 'my_aspnet_membership'
                ORDER BY ORDINAL_POSITION");
        }
        catch (Exception ex)
        {
            error = "Membership schema discovery failed: " + ex.Message;
            return false;
        }

        if (cols.Rows.Count == 0)
        {
            error = "No columns found for my_aspnet_membership.";
            return false;
        }

        DateTime now = DateTime.UtcNow;
        List<string> insertCols = new List<string>();
        List<MySqlParameter> insertParams = new List<MySqlParameter>();
        int paramIndex = 0;

        foreach (DataRow row in cols.Rows)
        {
            string colName = SafeVal(row["COLUMN_NAME"]);
            string lower = colName.ToLowerInvariant();
            string dataType = SafeVal(row["DATA_TYPE"]).ToLowerInvariant();
            bool isNullable = string.Equals(SafeVal(row["IS_NULLABLE"]), "YES", StringComparison.OrdinalIgnoreCase);
            bool hasDefault = row["COLUMN_DEFAULT"] != DBNull.Value;
            string extra = SafeVal(row["EXTRA"]).ToLowerInvariant();

            if (extra.Contains("auto_increment"))
                continue;

            object value = null;
            bool include = false;

            if (lower == "userid")
            {
                value = userId;
                include = true;
            }
            else if (lower == "email" || lower == "loweredemail")
            {
                value = email;
                include = true;
            }
            else if (lower == "isapproved")
            {
                value = 1;
                include = true;
            }
            else if (lower == "islockedout")
            {
                value = 0;
                include = true;
            }
            else if (lower == "passwordformat")
            {
                value = 0;
                include = true;
            }
            else if (lower == "password")
            {
                value = "autoprovisioned";
                include = true;
            }
            else if (lower == "isanonymous")
            {
                value = 0;
                include = true;
            }
            else if (lower == "applicationid")
            {
                value = ResolveApplicationId();
                include = true;
            }
            else if (lower == "passwordsalt" || lower == "passwordkey" || lower == "passwordquestion" || lower == "passwordanswer" || lower == "comment" || lower == "mobilepin")
            {
                value = string.Empty;
                include = true;
            }
            else if (lower.Contains("date") || lower.Contains("windowstart"))
            {
                value = now;
                include = true;
            }
            else if (lower.Contains("count"))
            {
                value = 0;
                include = true;
            }
            else if (!isNullable && !hasDefault)
            {
                if (dataType.Contains("int") || dataType == "decimal" || dataType == "numeric" || dataType == "double" || dataType == "float" || dataType == "bit" || dataType == "boolean")
                {
                    value = 0;
                }
                else if (dataType.Contains("date") || dataType.Contains("time"))
                {
                    value = now;
                }
                else if (dataType.Contains("binary") || dataType.Contains("blob"))
                {
                    value = new byte[0];
                }
                else
                {
                    value = string.Empty;
                }
                include = true;
            }

            if (include)
            {
                string paramName = "@p" + paramIndex++;
                insertCols.Add(colName);
                insertParams.Add(new MySqlParameter(paramName, value));
            }
        }

        if (insertCols.Count == 0)
        {
            error = "No insert columns resolved for my_aspnet_membership.";
            return false;
        }

        string sql = "INSERT INTO my_aspnet_membership (" + string.Join(", ", insertCols.ToArray()) + ") VALUES (";
        List<string> paramNames = new List<string>();
        foreach (MySqlParameter p in insertParams)
            paramNames.Add(p.ParameterName);
        sql += string.Join(", ", paramNames.ToArray()) + ")";

        try
        {
            ExecuteNonQuery(sql, insertParams.ToArray());
            return true;
        }
        catch (Exception ex)
        {
            error = "Insert into my_aspnet_membership failed: " + ex.Message + " | SQL: " + sql;
            return false;
        }
    }

    #endregion

    #region Password Change

    protected void btnChangePassword_Click(object sender, EventArgs e)
    {
        int empID;
        if (!int.TryParse(hdnPwdEmpID.Value, out empID)) return;

        try
        {
            DataTable dt = ExecuteQuery("SELECT emp_name, usernames, emp_email, emp_phone FROM hrm_employee WHERE empID = @id", new MySqlParameter("@id", empID));
            if (dt.Rows.Count == 0)
            {
                ShowPwdError("Employee record not found.");
                return;
            }

            DataRow emp = dt.Rows[0];
            string username = NormalizeLoginValue(emp["usernames"]);
            string email = NormalizeLoginValue(emp["emp_email"]);
            string phone = NormalizeLoginValue(emp["emp_phone"]);

            if (string.IsNullOrEmpty(username))
            {
                if (!string.IsNullOrEmpty(email)) username = email;
                else if (!string.IsNullOrEmpty(phone)) username = phone;
            }

            if (string.IsNullOrEmpty(username))
            {
                ShowPwdError("This employee has no username, email, or phone to create login credentials.");
                return;
            }

            // Try to find existing membership account
            MembershipUser user;
            MembershipProvider provider;
            if (!TryResolveMembershipUser(username, email, out user, out provider))
            {
                ShowPwdError("No membership account found for this employee. Please contact IT to create the account first, then retry this password reset.");
                return;
            }

            // Account exists - proceed with reset
            if (user.IsLockedOut)
            {
                provider.UnlockUser(user.UserName);
            }

            // Reset password and get the new temporary password
            string generatedPassword = provider.ResetPassword(user.UserName, null);

            if (string.IsNullOrEmpty(generatedPassword))
            {
                ShowPwdError("Password reset returned an empty temporary password. Please retry.");
                return;
            }

            string script = string.Format(
                "showResetPasswordResult('{0}','{1}',false);document.getElementById('changePwdModal').style.display='flex';",
                JsEncode(generatedPassword),
                JsEncode(user.UserName));
            ScriptManager.RegisterStartupScript(this, GetType(), "pwdOk", script, true);
        }
        catch (Exception ex)
        {
            ShowPwdError(ex.Message);
        }
    }

    private bool TryResolveMembershipUser(string username, string email, out MembershipUser user, out MembershipProvider selectedProvider)
    {
        user = null;
        selectedProvider = null;

        foreach (MembershipProvider provider in GetProvisioningProviders())
        {
            try
            {
                if (!string.IsNullOrEmpty(username))
                    user = provider.GetUser(username, false);

                if (user == null && !string.IsNullOrEmpty(email))
                {
                    string nameByEmail = provider.GetUserNameByEmail(email);
                    if (!string.IsNullOrEmpty(nameByEmail))
                        user = provider.GetUser(nameByEmail, false);
                }

                if (user != null)
                {
                    selectedProvider = provider;
                    return true;
                }
            }
            catch
            {
            }
        }

        return false;
    }

    private List<MembershipProvider> GetProvisioningProviders()
    {
        List<MembershipProvider> providers = new List<MembershipProvider>();

        if (Membership.Provider != null)
            providers.Add(Membership.Provider);

        MembershipProvider adminProvider = Membership.Providers["MySQLMembershipProviderAdmin"];
        if (adminProvider != null)
        {
            bool exists = false;
            foreach (MembershipProvider p in providers)
            {
                if (string.Equals(p.Name, adminProvider.Name, StringComparison.OrdinalIgnoreCase))
                {
                    exists = true;
                    break;
                }
            }
            if (!exists) providers.Add(adminProvider);
        }

        return providers;
    }

    private string NormalizeLoginValue(object value)
    {
        string text = SafeVal(value).Trim();
        if (text == "-" || text == "0") return string.Empty;
        return text;
    }

    private string BuildFallbackEmail(string username)
    {
        string local = username.ToLower().Replace(" ", ".");
        local = local.Replace("@", ".").Replace("..", ".");
        return local + "@mru.local";
    }

    private string GenerateStrongPassword()
    {
        const string upper = "ABCDEFGHJKLMNPQRSTUVWXYZ";
        const string lower = "abcdefghijkmnopqrstuvwxyz";
        const string digits = "23456789";
        const string symbols = "!@#$%&*";
        string all = upper + lower + digits + symbols;

        Random rnd = new Random(Guid.NewGuid().GetHashCode());
        StringBuilder sb = new StringBuilder();
        sb.Append(upper[rnd.Next(upper.Length)]);
        sb.Append(lower[rnd.Next(lower.Length)]);
        sb.Append(digits[rnd.Next(digits.Length)]);
        sb.Append(symbols[rnd.Next(symbols.Length)]);
        for (int i = 0; i < 8; i++) sb.Append(all[rnd.Next(all.Length)]);
        return sb.ToString();
    }

    private string JsEncode(string value)
    {
        if (value == null) return string.Empty;
        return value.Replace("\\", "\\\\").Replace("'", "\\'").Replace("\r", "").Replace("\n", "");
    }

    private void ShowPwdError(string message)
    {
        string msg = JsEncode(message);
        string script = "document.getElementById('pwdResult').className='hr-result hr-result--err';" +
                        "document.getElementById('pwdResult').innerHTML='" + msg + "';" +
                        "document.getElementById('changePwdModal').style.display='flex';";
        ScriptManager.RegisterStartupScript(this, GetType(), "pwdErr", script, true);
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
        return "openEditModal(" + empID + ")";
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
            "<li class='cd-action-popover__item'><button type='button' class='cd-action-popover__btn cd-action-popover__btn--edit' onclick='openEditModal(" + id + ")'>" + editSvg + " Edit</button></li>" +
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

    private string ToIsoDate(object val)
    {
        if (val == null || val == DBNull.Value) return string.Empty;
        DateTime dt;
        return DateTime.TryParse(val.ToString(), out dt) ? dt.ToString("yyyy-MM-dd") : string.Empty;
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
