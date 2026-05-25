using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using MySql.Data.MySqlClient;

public partial class COOPERP_NewScreens_NewStudentRegistration : System.Web.UI.Page
{
    // -- Connection strings ------------------------------------------
    private string ConnectionString
    {
        get { return ConfigurationManager.ConnectionStrings["vacConnectionString"].ConnectionString; }
    }

    private string AcctConnStr
    {
        get
        {
            var cs = ConfigurationManager.ConnectionStrings["accountsConnectionString"];
            return cs != null ? cs.ConnectionString
                : "server=localhost;User Id=root;password=24thdecember1977;database=campus_dynamics_accounts;DefaultCommandTimeout=600;Convert Zero Datetime=True;charset=utf8";
        }
    }

    // -- Programme cache (for JSON output to JS) ---------------------
    private List<ProgrammeItem> _programmeList;

    private class ProgrammeItem
    {
        public string Code;
        public string Name;
        public string FacultyCode;
    }

    // -- Specialisation cache (for JSON output to JS) ---------------
    private List<SpecialisationItem> _specList;

    private class SpecialisationItem
    {
        public int Id;
        public string ProgCode;
        public string Name;
    }

    // -- Edit mode flag --------------------------------------------
    private bool IsEditMode
    {
        get { return !string.IsNullOrEmpty(hfEditRegNo.Value); }
    }

    // ===============================================================
    //  PAGE LOAD
    // ===============================================================
    protected void Page_Load(object sender, EventArgs e)
    {
        // AJAX: delete student
        if (Request.QueryString["ajax"] == "delete")
        {
            HandleDeleteStudent();
            return;
        }

        // ALWAYS reload dropdown items - ViewState is disabled on master page,
        // so dropdown items are lost on every postback. ASP.NET's second
        // ProcessPostData pass will restore user selections from posted form data
        // once the items are available.
        LoadAllDropdownItems();

        if (!IsPostBack)
        {
            SetDefaults();

            // Capture the return URL if provided via querystring
            string returnUrl = Request.QueryString["returnUrl"];
            if (!string.IsNullOrEmpty(returnUrl))
                hfReturnUrl.Value = returnUrl;

            // -- EDIT MODE: populate form with existing student data --
            string editRegNo = Request.QueryString["edit"];
            if (!string.IsNullOrEmpty(editRegNo))
            {
                hfEditRegNo.Value = editRegNo.Trim();
                LoadStudentForEdit(editRegNo.Trim());
            }
        }
    }

    // ===============================================================
    //  DROPDOWN LOADING
    // ===============================================================
    private void LoadAllDropdownItems()
    {
        LoadFaculties();
        LoadProgrammeList();
        PopulateProgrammeDropdown("");   // ALL programmes so posted value matches
        LoadSpecialisationList();
        PopulateSpecialisationDropdown(""); // ALL specs so posted value matches
        LoadCampuses();
        LoadSessions();
        LoadEntryYears();
        LoadBillingSystems();
        LoadNationalities();
    }

    // -- Faculties ---------------------------------------------------
    private void LoadFaculties()
    {
        ddlFaculty.Items.Clear();
        ddlFaculty.Items.Add(new ListItem("-- All Faculties --", "ALL"));
        try
        {
            using (var conn = new MySqlConnection(ConnectionString))
            {
                conn.Open();
                using (var cmd = new MySqlCommand(
                    "SELECT faculty_code, faculty_name FROM acad_faculty WHERE faculty_code != '00' ORDER BY faculty_name", conn))
                using (var rdr = cmd.ExecuteReader())
                    while (rdr.Read())
                        ddlFaculty.Items.Add(new ListItem(
                            rdr["faculty_name"].ToString(),
                            rdr["faculty_code"].ToString()));
            }
        }
        catch { }
    }

    // -- Programme master list (cached for JSON + server dropdown) ---
    private void LoadProgrammeList()
    {
        if (_programmeList != null) return;
        _programmeList = new List<ProgrammeItem>();
        try
        {
            using (var conn = new MySqlConnection(ConnectionString))
            {
                conn.Open();
                using (var cmd = new MySqlCommand(
                    "SELECT progcode, progname, IFNULL(faculty_code,'00') AS fc FROM acad_programme WHERE progcode != '-' ORDER BY progname", conn))
                using (var rdr = cmd.ExecuteReader())
                    while (rdr.Read())
                    {
                        var item = new ProgrammeItem();
                        item.Code = rdr["progcode"].ToString();
                        item.Name = rdr["progname"].ToString();
                        item.FacultyCode = rdr["fc"].ToString();
                        _programmeList.Add(item);
                    }
            }
        }
        catch { }
    }

    private void PopulateProgrammeDropdown(string facultyCode)
    {
        ddlProgramme.Items.Clear();
        ddlProgramme.Items.Add(new ListItem("-- Select Programme --", ""));
        if (_programmeList == null) LoadProgrammeList();
        foreach (var p in _programmeList)
        {
            if (!string.IsNullOrEmpty(facultyCode) && facultyCode != "ALL" && p.FacultyCode != facultyCode)
                continue;
            ddlProgramme.Items.Add(new ListItem(
                p.Code + " - " + p.Name, p.Code));
        }
    }

    // -- Specialisations (Programme → Specialisation cascade) --------
    private void LoadSpecialisationList()
    {
        if (_specList != null) return;
        _specList = new List<SpecialisationItem>();
        try
        {
            using (var conn = new MySqlConnection(ConnectionString))
            {
                conn.Open();
                using (var cmd = new MySqlCommand(
                    "SELECT spec_id, prog_id, spec FROM acad_specialisation WHERE spec != '-' AND is_active='Active' ORDER BY spec", conn))
                using (var rdr = cmd.ExecuteReader())
                    while (rdr.Read())
                    {
                        var item = new SpecialisationItem();
                        item.Id = Convert.ToInt32(rdr["spec_id"]);
                        item.ProgCode = rdr["prog_id"].ToString();
                        item.Name = rdr["spec"].ToString();
                        _specList.Add(item);
                    }
            }
        }
        catch { }
    }

    private void PopulateSpecialisationDropdown(string progCode)
    {
        ddlSpecialisation.Items.Clear();
        ddlSpecialisation.Items.Add(new ListItem("-- None / Not Applicable --", ""));
        if (_specList == null) LoadSpecialisationList();
        foreach (var s in _specList)
        {
            if (!string.IsNullOrEmpty(progCode) && s.ProgCode != progCode)
                continue;
            ddlSpecialisation.Items.Add(new ListItem(
                s.Name, s.Id.ToString()));
        }
    }

    // -- Campuses ----------------------------------------------------
    private void LoadCampuses()
    {
        ddlCampus.Items.Clear();
        ddlCampus.Items.Add(new ListItem("-- Select Campus --", ""));
        try
        {
            using (var conn = new MySqlConnection(ConnectionString))
            {
                conn.Open();
                using (var cmd = new MySqlCommand(
                    "SELECT campus_code, campus_name FROM acad_campuses WHERE campus_code != '00' ORDER BY campus_name", conn))
                using (var rdr = cmd.ExecuteReader())
                    while (rdr.Read())
                        ddlCampus.Items.Add(new ListItem(
                            rdr["campus_name"].ToString(),
                            rdr["campus_code"].ToString()));
            }
        }
        catch { }
    }

    // -- Study Sessions ----------------------------------------------
    private void LoadSessions()
    {
        ddlSession.Items.Clear();
        ddlSession.Items.Add(new ListItem("-- Select Session --", ""));
        try
        {
            using (var conn = new MySqlConnection(ConnectionString))
            {
                conn.Open();
                using (var cmd = new MySqlCommand(
                    "SELECT Session FROM acad_studysessions ORDER BY Session", conn))
                using (var rdr = cmd.ExecuteReader())
                    while (rdr.Read())
                        ddlSession.Items.Add(new ListItem(
                            rdr["Session"].ToString(),
                            rdr["Session"].ToString()));
            }
        }
        catch { }
    }

    // -- Entry Years -------------------------------------------------
    private void LoadEntryYears()
    {
        ddlEntryYear.Items.Clear();
        ddlEntryYear.Items.Add(new ListItem("-- Select Year --", ""));
        int currentYear = DateTime.Now.Year;
        for (int y = currentYear + 1; y >= currentYear - 10; y--)
            ddlEntryYear.Items.Add(new ListItem(y.ToString(), y.ToString()));
    }

    // -- Billing Systems ---------------------------------------------
    private void LoadBillingSystems()
    {
        ddlBilling.Items.Clear();
        ddlBilling.Items.Add(new ListItem("-- Select Billing --", ""));
        try
        {
            using (var conn = new MySqlConnection(AcctConnStr))
            {
                conn.Open();
                using (var cmd = new MySqlCommand(
                    "SELECT ID, bs_name FROM fin_billing_systems ORDER BY ID", conn))
                using (var rdr = cmd.ExecuteReader())
                    while (rdr.Read())
                        ddlBilling.Items.Add(new ListItem(
                            rdr["bs_name"].ToString(),
                            rdr["ID"].ToString()));
            }
        }
        catch { }
    }

    // -- Nationalities -----------------------------------------------
    private void LoadNationalities()
    {
        ddlNationality.Items.Clear();
        ddlNationality.Items.Add(new ListItem("UGANDAN", "UGANDAN"));
        try
        {
            using (var conn = new MySqlConnection(ConnectionString))
            {
                conn.Open();
                using (var cmd = new MySqlCommand(
                    "SELECT nationality_name FROM nationalities WHERE nationality_name != 'UGANDAN' ORDER BY nationality_name", conn))
                using (var rdr = cmd.ExecuteReader())
                    while (rdr.Read())
                        ddlNationality.Items.Add(new ListItem(
                            rdr["nationality_name"].ToString(),
                            rdr["nationality_name"].ToString()));
            }
        }
        catch
        {
            // Fallback - add common nationalities
            string[] common = { "KENYAN", "TANZANIAN", "RWANDAN", "CONGOLESE", "SOUTH SUDANESE", "BURUNDIAN", "SOMALI", "ETHIOPIAN", "NIGERIAN" };
            foreach (string n in common)
                ddlNationality.Items.Add(new ListItem(n, n));
        }
    }

    // -- Set defaults ------------------------------------------------
    private void SetDefaults()
    {
        int currentYear = DateTime.Now.Year;

        // Entry year → current year
        if (ddlEntryYear.Items.FindByValue(currentYear.ToString()) != null)
            ddlEntryYear.SelectedValue = currentYear.ToString();

        // Study session → DAY
        if (ddlSession.Items.FindByValue("DAY") != null)
            ddlSession.SelectedValue = "DAY";

        // Intake → AUGUST
        if (ddlIntake.Items.FindByValue("AUGUST") != null)
            ddlIntake.SelectedValue = "AUGUST";

        // Billing → first real item
        if (ddlBilling.Items.Count > 1)
            ddlBilling.SelectedIndex = 1;

        // DOB → 20 years ago from today
        txtDOB.Text = DateTime.Now.AddYears(-20).ToString("yyyy-MM-dd");

        // Nationality → UGANDAN (already first item, but ensure selection)
        if (ddlNationality.Items.FindByValue("UGANDAN") != null)
            ddlNationality.SelectedValue = "UGANDAN";

        // Campus → first real item if only one campus
        if (ddlCampus.Items.Count == 2)
            ddlCampus.SelectedIndex = 1;

        // Entry method → DIRECT
        if (ddlEntryMethod.Items.FindByValue("DIRECT") != null)
            ddlEntryMethod.SelectedValue = "DIRECT";

        // Study year → Year 1
        if (ddlStudyYear.Items.FindByValue("1") != null)
            ddlStudyYear.SelectedValue = "1";

        // District → UGANDA
        txtDistrict.Text = "UGANDA";
        txtResCountry.Text = "UGANDA";
    }

    // ===============================================================
    //  JSON OUTPUT - Programme data for cascading JS
    // ===============================================================
    public string GetProgrammesJson()
    {
        if (_programmeList == null) LoadProgrammeList();
        var sb = new StringBuilder("[");
        for (int i = 0; i < _programmeList.Count; i++)
        {
            if (i > 0) sb.Append(",");
            sb.Append("{\"c\":\"");
            sb.Append(EscapeJs(_programmeList[i].Code));
            sb.Append("\",\"n\":\"");
            sb.Append(EscapeJs(_programmeList[i].Name));
            sb.Append("\",\"f\":\"");
            sb.Append(EscapeJs(_programmeList[i].FacultyCode));
            sb.Append("\"}");
        }
        sb.Append("]");
        return sb.ToString();
    }

    // ===============================================================
    //  JSON OUTPUT - Specialisation data for cascading JS
    // ===============================================================
    public string GetSpecialisationsJson()
    {
        if (_specList == null) LoadSpecialisationList();
        var sb = new StringBuilder("[");
        for (int i = 0; i < _specList.Count; i++)
        {
            if (i > 0) sb.Append(",");
            sb.Append("{\"id\":");
            sb.Append(_specList[i].Id);
            sb.Append(",\"p\":\"");
            sb.Append(EscapeJs(_specList[i].ProgCode));
            sb.Append("\",\"n\":\"");
            sb.Append(EscapeJs(_specList[i].Name));
            sb.Append("\"}");
        }
        sb.Append("]");
        return sb.ToString();
    }

    private static string EscapeJs(string s)
    {
        if (string.IsNullOrEmpty(s)) return "";
        return s.Replace("\\", "\\\\").Replace("\"", "\\\"").Replace("'", "\\'").Replace("\n", "").Replace("\r", "");
    }

    // ===============================================================
    //  AJAX: DELETE STUDENT
    // ===============================================================
    private void HandleDeleteStudent()
    {
        Response.Clear();
        Response.ContentType = "application/json";
        string regno = (Request.QueryString["regno"] ?? "").Trim();
        if (string.IsNullOrEmpty(regno))
        {
            Response.Write("{\"ok\":false,\"error\":\"Registration number required.\"}");
            Response.End(); return;
        }
        try
        {
            using (MySqlConnection conn = new MySqlConnection(ConnectionString))
            {
                conn.Open();

                // Safety check: block delete if the student has any financial transactions
                using (MySqlCommand chk = new MySqlCommand(
                    "SELECT COUNT(*) FROM fin_studentfeestracking WHERE regno = @r", conn))
                {
                    chk.Parameters.AddWithValue("@r", regno);
                    long txCount = Convert.ToInt64(chk.ExecuteScalar());
                    if (txCount > 0)
                        throw new Exception(string.Format(
                            "Cannot delete {0}: {1} fee transaction(s) exist. Reverse all transactions first.", regno, txCount));
                }

                MySqlTransaction tx = conn.BeginTransaction();
                try
                {
                    // Delete semester enrolment
                    using (MySqlCommand d1 = new MySqlCommand(
                        "DELETE FROM acad_student_semester WHERE regno = @r", conn, tx))
                    { d1.Parameters.AddWithValue("@r", regno); d1.ExecuteNonQuery(); }

                    // Delete programme enrolment
                    using (MySqlCommand d2 = new MySqlCommand(
                        "DELETE FROM acad_student_programme WHERE regno = @r", conn, tx))
                    { d2.Parameters.AddWithValue("@r", regno); d2.ExecuteNonQuery(); }

                    // Delete core student record
                    using (MySqlCommand d3 = new MySqlCommand(
                        "DELETE FROM acad_student WHERE regno = @r", conn, tx))
                    { d3.Parameters.AddWithValue("@r", regno); d3.ExecuteNonQuery(); }

                    tx.Commit();
                }
                catch { tx.Rollback(); throw; }
            }
            Response.Write("{\"ok\":true,\"message\":\"Student " + regno.Replace("\"", "") + " deleted successfully.\"}");
        }
        catch (Exception ex)
        {
            Response.Write("{\"ok\":false,\"error\":\"" + ex.Message.Replace("\\", "\\\\").Replace("\"", "\\\"") + "\"}");
        }
        Response.End();
    }

    // ===============================================================
    //  LOAD EXISTING STUDENT FOR EDIT MODE
    // ===============================================================
    private void LoadStudentForEdit(string regno)
    {
        try
        {
            using (var conn = new MySqlConnection(ConnectionString))
            {
                conn.Open();

                // Query student data + optional application data
                const string sql = @"
                    SELECT s.*, 
                           a.stud_sponsor, a.sponsor_contact, a.next_kin, a.kin_contacts,
                           a.kin_relationship, a.stud_phy_address, a.post_box,
                           a.residence_country, a.olevel_school, a.olevel_index,
                           a.alevel_school, a.alevel_index, a.stud_mar_stat,
                           a.title AS app_title, a.physicalDisability AS app_disability
                    FROM acad_student s
                    LEFT JOIN acad_applications a ON s.entryno = a.stud_entry_no
                    WHERE s.regno = @r
                    LIMIT 1";
                using (var cmd = new MySqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@r", regno);
                    using (var rdr = cmd.ExecuteReader())
                    {
                        if (!rdr.Read())
                        {
                            ShowError("Student not found: " + Server.HtmlEncode(regno));
                            return;
                        }

                        // -- Page chrome --
                        litPageTitle.Text = "Edit Student";
                        litPageSubtitle.Text = "Editing record for <strong>" + Server.HtmlEncode(regno) + "</strong>";
                        litSubmitBtnText.Text = "Update Student";
                        litSuccessActionText.Text = "Back to Student Record";
                        pnlRegistrationOptions.Visible = false;

                        // -- Personal Info --
                        string fname = SafeStr(rdr, "firstname");
                        string oname = SafeStr(rdr, "othername");
                        txtFullName.Text = (fname + " " + oname).Trim();

                        // Gender: acad_student stores MALE/FEMALE, form uses M/F
                        string genderDb = SafeStr(rdr, "gender").ToUpper();
                        string genderVal = "M";
                        if (genderDb.StartsWith("F")) genderVal = "F";
                        else if (genderDb == "OTHER") genderVal = "OTHER";
                        TrySelect(ddlGender, genderVal);

                        // DOB
                        if (rdr["dob"] != DBNull.Value)
                        {
                            DateTime dob = Convert.ToDateTime(rdr["dob"]);
                            txtDOB.Text = dob.ToString("yyyy-MM-dd");
                        }

                        // Nationality
                        string nat = SafeStr(rdr, "nationality");
                        if (!string.IsNullOrEmpty(nat))
                            TrySelect(ddlNationality, nat);

                        // National ID
                        txtNationalId.Text = SafeStr(rdr, "national_id");

                        // Phone & Email
                        txtPhone.Text = SafeStr(rdr, "studPhone");
                        txtEmail.Text = SafeStr(rdr, "email");

                        // Religion
                        string religion = SafeStr(rdr, "religion");
                        if (!string.IsNullOrEmpty(religion))
                            TrySelect(ddlReligion, religion);

                        // Title - from applications if exists
                        string title = SafeStr(rdr, "app_title");
                        if (!string.IsNullOrEmpty(title))
                            TrySelect(ddlTitle, title);

                        // Marital - from applications
                        string marital = SafeStr(rdr, "stud_mar_stat");
                        if (!string.IsNullOrEmpty(marital))
                            TrySelect(ddlMarital, marital);

                        // Disability - from applications
                        string disability = SafeStr(rdr, "app_disability");
                        if (!string.IsNullOrEmpty(disability) && disability != "-")
                            txtDisability.Text = disability;

                        // -- Academic Details --
                        string progId = SafeStr(rdr, "progid");
                        if (!string.IsNullOrEmpty(progId))
                        {
                            TrySelect(ddlProgramme, progId);
                            hfProgramme.Value = progId;

                            // Set faculty from programme cache to trigger JS cascade
                            if (_programmeList != null)
                            {
                                foreach (var p in _programmeList)
                                {
                                    if (p.Code == progId)
                                    {
                                        TrySelect(ddlFaculty, p.FacultyCode);
                                        hfFaculty.Value = p.FacultyCode;
                                        break;
                                    }
                                }
                            }
                        }

                        // Specialisation - reverse lookup
                        // DB may store spec_id as string ("22") or plain text name
                        string specVal = SafeStr(rdr, "specialisation");
                        if (!string.IsNullOrEmpty(specVal) && specVal != "-")
                        {
                            if (_specList != null)
                            {
                                bool found = false;

                                // Try 1: match by spec_id (existing data stores IDs as strings)
                                int specIdParsed;
                                if (int.TryParse(specVal, out specIdParsed) && specIdParsed > 0)
                                {
                                    foreach (var sp in _specList)
                                    {
                                        if (sp.Id == specIdParsed)
                                        {
                                            TrySelect(ddlSpecialisation, sp.Id.ToString());
                                            hfSpecialisation.Value = sp.Id.ToString();
                                            found = true;
                                            break;
                                        }
                                    }
                                }

                                // Try 2: match by name (plain-text data)
                                if (!found)
                                {
                                    foreach (var sp in _specList)
                                    {
                                        if (sp.Name == specVal && (string.IsNullOrEmpty(progId) || sp.ProgCode == progId))
                                        {
                                            TrySelect(ddlSpecialisation, sp.Id.ToString());
                                            hfSpecialisation.Value = sp.Id.ToString();
                                            found = true;
                                            break;
                                        }
                                    }
                                }
                            }
                        }

                        // Session
                        string session = SafeStr(rdr, "studsesion");
                        if (!string.IsNullOrEmpty(session))
                        {
                            TrySelect(ddlSession, session);
                            hfSession.Value = session;
                        }

                        // Campus - studCampus stores int (1,2) but dropdown
                        // values are zero-padded campus_code strings ("01","02")
                        int campusCode = SafeInt(rdr["studCampus"], 0);
                        if (campusCode > 0)
                        {
                            string campusStr = campusCode.ToString().PadLeft(2, '0');
                            TrySelect(ddlCampus, campusStr);
                            hfCampus.Value = campusStr;
                        }

                        // Entry year
                        int entryYear = SafeInt(rdr["entryyear"], 0);
                        if (entryYear > 0)
                        {
                            // Ensure the year exists in the dropdown
                            if (ddlEntryYear.Items.FindByValue(entryYear.ToString()) == null)
                                ddlEntryYear.Items.Insert(0, new ListItem(entryYear.ToString(), entryYear.ToString()));
                            TrySelect(ddlEntryYear, entryYear.ToString());
                            hfEntryYear.Value = entryYear.ToString();
                        }

                        // Entry method
                        string entMethod = SafeStr(rdr, "entrymethod");
                        if (!string.IsNullOrEmpty(entMethod))
                            TrySelect(ddlEntryMethod, entMethod);

                        // Intake
                        string intake = SafeStr(rdr, "intake");
                        if (!string.IsNullOrEmpty(intake))
                            TrySelect(ddlIntake, intake);

                        // Billing
                        int billingId = SafeInt(rdr["billingID"], 0);
                        if (billingId > 0)
                        {
                            TrySelect(ddlBilling, billingId.ToString());
                            hfBilling.Value = billingId.ToString();
                        }

                        // -- Address & Contact (from applications) --
                        string addr = SafeStr(rdr, "stud_phy_address");
                        if (!string.IsNullOrEmpty(addr)) txtAddress.Text = addr;

                        string pb = SafeStr(rdr, "post_box");
                        if (!string.IsNullOrEmpty(pb)) txtPostBox.Text = pb;

                        string dist = SafeStr(rdr, "home_dist");
                        if (!string.IsNullOrEmpty(dist)) txtDistrict.Text = dist;

                        string resCntry = SafeStr(rdr, "residence_country");
                        if (!string.IsNullOrEmpty(resCntry)) txtResCountry.Text = resCntry;

                        // -- Sponsor & Kin (from applications) --
                        string sponsor = SafeStr(rdr, "stud_sponsor");
                        if (!string.IsNullOrEmpty(sponsor)) txtSponsor.Text = sponsor;

                        string spContact = SafeStr(rdr, "sponsor_contact");
                        if (!string.IsNullOrEmpty(spContact)) txtSponsorContact.Text = spContact;

                        string kin = SafeStr(rdr, "next_kin");
                        if (!string.IsNullOrEmpty(kin)) txtKinName.Text = kin;

                        string kinRel = SafeStr(rdr, "kin_relationship");
                        if (!string.IsNullOrEmpty(kinRel)) TrySelect(ddlKinRelation, kinRel);

                        string kinCon = SafeStr(rdr, "kin_contacts");
                        if (!string.IsNullOrEmpty(kinCon)) txtKinContact.Text = kinCon;

                        // -- Education Background (from applications) --
                        string olSchool = SafeStr(rdr, "olevel_school");
                        if (!string.IsNullOrEmpty(olSchool)) txtOLevelSchool.Text = olSchool;

                        string olIdx = SafeStr(rdr, "olevel_index");
                        if (!string.IsNullOrEmpty(olIdx)) txtOLevelIndex.Text = olIdx;

                        string alSchool = SafeStr(rdr, "alevel_school");
                        if (!string.IsNullOrEmpty(alSchool)) txtALevelSchool.Text = alSchool;

                        string alIdx = SafeStr(rdr, "alevel_index");
                        if (!string.IsNullOrEmpty(alIdx)) txtALevelIndex.Text = alIdx;
                    }
                }
            }
        }
        catch (Exception ex)
        {
            ShowError("Error loading student for edit: " + ex.Message);
        }
    }

    /// <summary>Safe string reader - returns "" for null/DBNull columns.</summary>
    private static string SafeStr(MySqlDataReader rdr, string col)
    {
        try
        {
            int ord = rdr.GetOrdinal(col);
            if (rdr.IsDBNull(ord)) return "";
            return rdr.GetString(ord).Trim();
        }
        catch { return ""; }
    }

    // ===============================================================
    //  REGISTRATION HANDLER - 8-step process
    // ===============================================================
    protected void btnSubmitRegistration_Click(object sender, EventArgs e)
    {
        // -- EDIT MODE: route to update logic ------------------------
        if (IsEditMode)
        {
            UpdateExistingStudent();
            return;
        }

        // -- Gather form values --------------------------------------
        // Use hidden-field fallback for dropdowns (ViewState is off,
        // and programme list may have been filtered client-side by JS)
        string title        = ddlTitle.SelectedValue;
        string fullName     = (txtFullName.Text ?? "").Trim().ToUpper();
        string gender       = ddlGender.SelectedValue;
        string dobStr       = (txtDOB.Text ?? "").Trim();
        string phone        = (txtPhone.Text ?? "").Trim();
        string email        = (txtEmail.Text ?? "").Trim();
        string nationality  = DdlOrHidden(ddlNationality, hfNationality);
        string religion     = ddlReligion.SelectedValue;
        string marital      = ddlMarital.SelectedValue;
        string disability   = (txtDisability.Text ?? "").Trim();
        string nationalId   = (txtNationalId.Text ?? "").Trim().ToUpper();

        string programme    = DdlOrHidden(ddlProgramme, hfProgramme);
        string session      = DdlOrHidden(ddlSession, hfSession);
        string campus       = DdlOrHidden(ddlCampus, hfCampus);
        string entryMethod  = ddlEntryMethod.SelectedValue;
        string entryYear    = DdlOrHidden(ddlEntryYear, hfEntryYear);
        string intake       = ddlIntake.SelectedValue;
        string billing      = DdlOrHidden(ddlBilling, hfBilling);
        string specIdStr    = DdlOrHidden(ddlSpecialisation, hfSpecialisation);

        string address      = (txtAddress.Text ?? "").Trim();
        string postBox      = (txtPostBox.Text ?? "").Trim();
        string district     = (txtDistrict.Text ?? "").Trim();
        string resCountry   = (txtResCountry.Text ?? "").Trim();

        string sponsor        = (txtSponsor.Text ?? "").Trim();
        string sponsorContact = (txtSponsorContact.Text ?? "").Trim();
        string kinName        = (txtKinName.Text ?? "").Trim();
        string kinRelation    = ddlKinRelation.SelectedValue;
        string kinContact     = (txtKinContact.Text ?? "").Trim();

        string oLevelSchool = (txtOLevelSchool.Text ?? "").Trim();
        string oLevelIndex  = (txtOLevelIndex.Text ?? "").Trim();
        string aLevelSchool = (txtALevelSchool.Text ?? "").Trim();
        string aLevelIndex  = (txtALevelIndex.Text ?? "").Trim();

        // -- Server-side validation ----------------------------------
        if (string.IsNullOrEmpty(fullName))
        { ShowError("Please enter the student's full name."); return; }
        if (string.IsNullOrEmpty(programme))
        { ShowError("Please select a programme."); return; }
        if (string.IsNullOrEmpty(phone))
        { ShowError("Please enter the student's phone number."); return; }
        if (string.IsNullOrEmpty(session))
        { ShowError("Please select a study session."); return; }
        if (string.IsNullOrEmpty(campus))
        { ShowError("Please select a campus."); return; }
        if (string.IsNullOrEmpty(entryYear))
        { ShowError("Please select an entry year."); return; }
        if (string.IsNullOrEmpty(billing))
        { ShowError("Please select a billing system."); return; }

        // Parse DOB
        DateTime birthDate = new DateTime(1980, 1, 1);
        if (!string.IsNullOrEmpty(dobStr))
        {
            DateTime parsed;
            if (DateTime.TryParse(dobStr, out parsed))
                birthDate = parsed;
        }

        if (string.IsNullOrEmpty(nationality)) nationality = "UGANDAN";
        if (string.IsNullOrEmpty(district))    district = "UGANDA";

        try
        {
            using (var conn = new MySqlConnection(ConnectionString))
            {
                conn.Open();

                // -- Step 1: Generate entry number ------------------
                string entryNo = "";
                using (var cmd = new MySqlCommand(
                    "SELECT acad_ApplicNoGenerator(@yr) AS eno", conn))
                {
                    cmd.Parameters.AddWithValue("@yr", SafeInt(entryYear, DateTime.Now.Year));
                    object result = cmd.ExecuteScalar();
                    if (result != null) entryNo = result.ToString();
                }
                if (string.IsNullOrEmpty(entryNo) || entryNo == "-")
                {
                    ShowError("Failed to generate an entry number. Please try again.");
                    return;
                }

                // -- Step 2: Insert into acad_applications ----------
                const string insertAppSql = @"
                    INSERT INTO acad_applications (
                        stud_entry_no, stud_name, stud_sex, stud_nationality, stud_religion,
                        stud_entry_method, stud_sponsor, sponsor_contact, stud_entry_year,
                        stud_birthdate, stud_phone, next_kin, stud_phy_address, stud_email,
                        stud_mar_stat, stud_campus, IsAccountTransfered, spouse_name,
                        residence_country, olevel_school, alevel_school, referee_name,
                        referee_contacts, referee_comments, letter_campus, health_comments,
                        olevel_index, alevel_index, spouse_contacts, post_box, home_district,
                        stud_occupation, kin_contacts, kin_relationship, alevel_year, hall,
                        stud_intake, spouseOccupation, title, physicalDisability,
                        stud_reg_no, billingID, national_id
                    ) VALUES (
                        @entryNo, @name, @sex, @nationality, @religion,
                        @entryMethod, @sponsor, @sponsorContact, @entryYear,
                        @dob, @phone, @kinName, @address, @email,
                        @marital, @campus, 0, '',
                        @resCountry, @oLevelSchool, @aLevelSchool, '',
                        '', '', '', '',
                        @oLevelIndex, @aLevelIndex, '', @postBox, @district,
                        '', @kinContact, @kinRelation, 0, '',
                        @intake, '', @title, @disability,
                        '-', @billingID, @nationalId
                    )";
                using (var cmd = new MySqlCommand(insertAppSql, conn))
                {
                    cmd.Parameters.AddWithValue("@entryNo",        entryNo);
                    cmd.Parameters.AddWithValue("@name",           fullName);
                    cmd.Parameters.AddWithValue("@sex",            gender);
                    cmd.Parameters.AddWithValue("@nationality",    nationality);
                    cmd.Parameters.AddWithValue("@religion",       religion);
                    cmd.Parameters.AddWithValue("@entryMethod",    entryMethod);
                    cmd.Parameters.AddWithValue("@sponsor",        sponsor);
                    cmd.Parameters.AddWithValue("@sponsorContact", sponsorContact);
                    cmd.Parameters.AddWithValue("@entryYear",      entryYear);
                    cmd.Parameters.AddWithValue("@dob",            birthDate);
                    cmd.Parameters.AddWithValue("@phone",          phone);
                    cmd.Parameters.AddWithValue("@kinName",        kinName);
                    cmd.Parameters.AddWithValue("@address",        address);
                    cmd.Parameters.AddWithValue("@email",          email);
                    cmd.Parameters.AddWithValue("@marital",        marital);
                    cmd.Parameters.AddWithValue("@campus",         campus);
                    cmd.Parameters.AddWithValue("@resCountry",     resCountry);
                    cmd.Parameters.AddWithValue("@oLevelSchool",   oLevelSchool);
                    cmd.Parameters.AddWithValue("@aLevelSchool",   aLevelSchool);
                    cmd.Parameters.AddWithValue("@oLevelIndex",    oLevelIndex);
                    cmd.Parameters.AddWithValue("@aLevelIndex",    aLevelIndex);
                    cmd.Parameters.AddWithValue("@postBox",        postBox);
                    cmd.Parameters.AddWithValue("@district",       district);
                    cmd.Parameters.AddWithValue("@kinContact",     kinContact);
                    cmd.Parameters.AddWithValue("@kinRelation",    kinRelation);
                    cmd.Parameters.AddWithValue("@intake",         intake);
                    cmd.Parameters.AddWithValue("@title",          title);
                    cmd.Parameters.AddWithValue("@disability",     disability);
                    cmd.Parameters.AddWithValue("@billingID",      SafeInt(billing, 1));
                    cmd.Parameters.AddWithValue("@nationalId",    nationalId);
                    cmd.ExecuteNonQuery();
                }

                // -- Step 3: Insert applicant choice (admitted) -----
                const string insertChoiceSql = @"
                    INSERT INTO acad_applicant_choices
                        (stud_entry_no, Choice, prog_id, adm_status, adm_session, sub_comb)
                    VALUES
                        (@eno, 1, @prog, 1, @session, @specId)";
                using (var cmd = new MySqlCommand(insertChoiceSql, conn))
                {
                    cmd.Parameters.AddWithValue("@eno",     entryNo);
                    cmd.Parameters.AddWithValue("@prog",    programme);
                    cmd.Parameters.AddWithValue("@session", session);
                    cmd.Parameters.AddWithValue("@specId",  SafeInt(specIdStr, 0));
                    cmd.ExecuteNonQuery();
                }

                // -- Step 4: Generate registration number -----------
                string regNo = "-";
                using (var cmd = new MySqlCommand(
                    "SELECT acad_RegNoCreator(@eno) AS regno", conn))
                {
                    cmd.Parameters.AddWithValue("@eno", entryNo);
                    object result = cmd.ExecuteScalar();
                    if (result != null) regNo = result.ToString();
                }

                // -- Step 5: Update stud_reg_no in applications -----
                if (regNo != "-" && !string.IsNullOrEmpty(regNo))
                {
                    using (var cmd = new MySqlCommand(
                        "UPDATE acad_applications SET stud_reg_no=@rn WHERE stud_entry_no=@eno AND (stud_reg_no='-' OR stud_reg_no='')",
                        conn))
                    {
                        cmd.Parameters.AddWithValue("@rn",  regNo);
                        cmd.Parameters.AddWithValue("@eno", entryNo);
                        cmd.ExecuteNonQuery();
                    }
                }

                // -- Step 6: Register applicant (acad_student + acad_registration)
                // Inline equivalent of acad_RegisterApplicant SP — bypasses any SP-level
                // academic-year restriction so registration works for any entry year.
                int eyrInt = SafeInt(entryYear, DateTime.Now.Year);
                string acadYearForReg = string.Format("{0}/{1}", eyrInt, eyrInt + 1);

                // 6a: Look up prog/session/spec from applicant choices
                string regProg = "", regSess = "", regSpec = "", regNewNo = "";
                using (var cmd = new MySqlCommand(
                    "SELECT prog_id, adm_session, sub_comb FROM acad_applicant_choices WHERE stud_entry_no=@eno AND choice=1 LIMIT 1", conn))
                {
                    cmd.Parameters.AddWithValue("@eno", entryNo);
                    using (var rdr = cmd.ExecuteReader())
                        if (rdr.Read())
                        {
                            regProg = rdr["prog_id"]    != DBNull.Value ? rdr["prog_id"].ToString()    : "";
                            regSess = rdr["adm_session"] != DBNull.Value ? rdr["adm_session"].ToString() : "";
                            regSpec = rdr["sub_comb"]   != DBNull.Value ? rdr["sub_comb"].ToString()   : "";
                        }
                }
                using (var cmd = new MySqlCommand(
                    "SELECT stud_reg_no FROM acad_applications WHERE stud_entry_no=@eno LIMIT 1", conn))
                {
                    cmd.Parameters.AddWithValue("@eno", entryNo);
                    object v = cmd.ExecuteScalar();
                    if (v != null && v != DBNull.Value) regNewNo = v.ToString();
                }

                // 6b: Insert into acad_student
                using (var cmd = new MySqlCommand(@"
                    INSERT IGNORE INTO acad_student(
                        entryno, regno, firstname, dob, gender, nationality, religion,
                        entrymethod, progid, studPhone, email, entryyear, studsesion,
                        home_dist, intake, gradSystemID, othername, duration, specialisation, studcampus
                    )
                    SELECT stud_reg_no, stud_entry_no,
                        REPLACE(SUBSTRING_INDEX(stud_name,' ',3), SUBSTRING_INDEX(stud_name,' ',1), ''),
                        stud_birthdate,
                        IF(stud_sex='M','MALE',IF(stud_sex='F','FEMALE',stud_sex)),
                        stud_nationality, stud_religion, stud_entry_method,
                        @prog, stud_phone, stud_email, stud_entry_year, @sess, home_district,
                        stud_intake, 1,
                        UPPER(SUBSTRING_INDEX(stud_name,' ',1)),
                        Acad_GetApplicantDetails(6, @prog),
                        @spec, stud_campus
                    FROM acad_applications WHERE stud_entry_no=@eno", conn))
                {
                    cmd.Parameters.AddWithValue("@prog", regProg);
                    cmd.Parameters.AddWithValue("@sess", regSess);
                    cmd.Parameters.AddWithValue("@spec", regSpec);
                    cmd.Parameters.AddWithValue("@eno",  entryNo);
                    cmd.ExecuteNonQuery();
                }

                // 6c: Insert into acad_registration
                using (var cmd = new MySqlCommand(@"
                    INSERT IGNORE INTO acad_registration(
                        regno, acad_year, semester, regstatus, studyyear,
                        id_cardStatus, residence_status, reg_CardStatus,
                        examClearance, clearedBy, registeredBy
                    ) VALUES(@eno, @acad_year, 1, 'UNREGISTERED', 1, '-', '-', '-', 'UNCLEARED', '-', @usr)", conn))
                {
                    cmd.Parameters.AddWithValue("@eno",       entryNo);
                    cmd.Parameters.AddWithValue("@acad_year", acadYearForReg);
                    cmd.Parameters.AddWithValue("@usr",       GetCurrentUser());
                    cmd.ExecuteNonQuery();
                }

                // 6d: Activity log
                using (var cmd = new MySqlCommand(@"
                    INSERT INTO acad_activity_log(user_id, page_function, par, comments, access_date)
                    VALUES(@usr, 'Applicant Registration', @par, 'Registered Applicant', NOW())", conn))
                {
                    cmd.Parameters.AddWithValue("@usr", GetCurrentUser());
                    cmd.Parameters.AddWithValue("@par", string.Format("prog: {0} Reg No: {1}", regProg, regNewNo));
                    cmd.ExecuteNonQuery();
                }

                // -- Step 7: Update billing system + specialisation on acad_student
                // Store the spec_id (not the name) so the JOIN in listing pages works
                int specId = SafeInt(specIdStr, 0);
                using (var cmd = new MySqlCommand(
                    "UPDATE acad_student SET billingID=@bid, specialisation=@spec, national_id=@nid WHERE regno=@rno", conn))
                {
                    cmd.Parameters.AddWithValue("@bid", SafeInt(billing, 1));
                    cmd.Parameters.AddWithValue("@spec", specId > 0 ? specIdStr : "");
                    cmd.Parameters.AddWithValue("@nid", nationalId);
                    cmd.Parameters.AddWithValue("@rno", regNo);
                    cmd.ExecuteNonQuery();
                }

                // -- Step 8: Immediate registration disabled — students self-register via the portal --

                // -- Success - show result via JS -------------------
                ScriptManager.RegisterStartupScript(this, GetType(), "regSuccess",
                    string.Format("showSuccess('{0}','{1}',{2});",
                        EscapeJs(entryNo), EscapeJs(regNo), "false"), true);
            }
        }
        catch (Exception ex)
        {
            ShowError("Failed to register student: " + ex.Message);
        }
    }

    // ===============================================================
    //  AUTO-BILLING
    // ===============================================================
    private void AutoBillStudent(int regId)
    {
        try
        {
            string regno = "", acadYear = "";
            int semester = 0;
            using (var conn = new MySqlConnection(ConnectionString))
            {
                conn.Open();
                using (var cmd = new MySqlCommand(
                    "SELECT regno, acad_year, semester FROM acad_registration WHERE ID=@id LIMIT 1", conn))
                {
                    cmd.Parameters.AddWithValue("@id", regId);
                    using (var rdr = cmd.ExecuteReader())
                    {
                        if (!rdr.Read()) return;
                        regno    = rdr["regno"].ToString();
                        acadYear = rdr["acad_year"].ToString();
                        semester = Convert.ToInt32(rdr["semester"]);
                    }
                }
            }
            if (string.IsNullOrEmpty(regno)) return;

            using (var conn = new MySqlConnection(AcctConnStr))
            {
                conn.Open();
                using (var cmd = new MySqlCommand("fin_AutoBillOnRegistration", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.CommandTimeout = 120;
                    cmd.Parameters.AddWithValue("@p_regno",    regno);
                    cmd.Parameters.AddWithValue("@p_acadyear", acadYear);
                    cmd.Parameters.AddWithValue("@p_semester",  semester);
                    cmd.Parameters.AddWithValue("@p_user",     GetCurrentUser());
                    using (var rdr = cmd.ExecuteReader())
                    {
                        while (rdr.NextResult()) { }
                    }
                }
            }
        }
        catch { /* billing failure should not block registration */ }
    }

    // ===============================================================
    //  UPDATE EXISTING STUDENT (edit mode)
    // ===============================================================
    private void UpdateExistingStudent()
    {
        string regno = hfEditRegNo.Value;
        if (string.IsNullOrEmpty(regno))
        {
            ShowError("No student registration number found for update.");
            return;
        }

        // -- Gather form values (same as create) ----------------------
        string title        = ddlTitle.SelectedValue;
        string fullName     = (txtFullName.Text ?? "").Trim().ToUpper();
        string gender       = ddlGender.SelectedValue;
        string dobStr       = (txtDOB.Text ?? "").Trim();
        string phone        = (txtPhone.Text ?? "").Trim();
        string email        = (txtEmail.Text ?? "").Trim();
        string nationality  = DdlOrHidden(ddlNationality, hfNationality);
        string religion     = ddlReligion.SelectedValue;
        string marital      = ddlMarital.SelectedValue;
        string disability   = (txtDisability.Text ?? "").Trim();
        string nationalId   = (txtNationalId.Text ?? "").Trim().ToUpper();

        string programme    = DdlOrHidden(ddlProgramme, hfProgramme);
        string session      = DdlOrHidden(ddlSession, hfSession);
        string campus       = DdlOrHidden(ddlCampus, hfCampus);
        string entryMethod  = ddlEntryMethod.SelectedValue;
        string entryYear    = DdlOrHidden(ddlEntryYear, hfEntryYear);
        string intake       = ddlIntake.SelectedValue;
        string billing      = DdlOrHidden(ddlBilling, hfBilling);
        string specIdStr    = DdlOrHidden(ddlSpecialisation, hfSpecialisation);

        string address      = (txtAddress.Text ?? "").Trim();
        string postBox      = (txtPostBox.Text ?? "").Trim();
        string district     = (txtDistrict.Text ?? "").Trim();
        string resCountry   = (txtResCountry.Text ?? "").Trim();

        string sponsor        = (txtSponsor.Text ?? "").Trim();
        string sponsorContact = (txtSponsorContact.Text ?? "").Trim();
        string kinName        = (txtKinName.Text ?? "").Trim();
        string kinRelation    = ddlKinRelation.SelectedValue;
        string kinContact     = (txtKinContact.Text ?? "").Trim();

        string oLevelSchool = (txtOLevelSchool.Text ?? "").Trim();
        string oLevelIndex  = (txtOLevelIndex.Text ?? "").Trim();
        string aLevelSchool = (txtALevelSchool.Text ?? "").Trim();
        string aLevelIndex  = (txtALevelIndex.Text ?? "").Trim();

        // -- Validation ---------------------------------------------
        if (string.IsNullOrEmpty(fullName))
        { ShowError("Please enter the student's full name."); return; }
        if (string.IsNullOrEmpty(programme))
        { ShowError("Please select a programme."); return; }
        if (string.IsNullOrEmpty(phone))
        { ShowError("Please enter the student's phone number."); return; }
        if (string.IsNullOrEmpty(session))
        { ShowError("Please select a study session."); return; }
        if (string.IsNullOrEmpty(campus))
        { ShowError("Please select a campus."); return; }

        // Parse DOB
        DateTime birthDate = new DateTime(1980, 1, 1);
        if (!string.IsNullOrEmpty(dobStr))
        {
            DateTime parsed;
            if (DateTime.TryParse(dobStr, out parsed))
                birthDate = parsed;
        }

        if (string.IsNullOrEmpty(nationality)) nationality = "UGANDAN";
        if (string.IsNullOrEmpty(district))    district = "UGANDA";

        // Split full name into firstname + othername
        // Convention: first token = firstname, remainder = othername
        string firstName = fullName;
        string otherName = "";
        int spaceIdx = fullName.IndexOf(' ');
        if (spaceIdx > 0)
        {
            firstName = fullName.Substring(0, spaceIdx).Trim();
            otherName = fullName.Substring(spaceIdx + 1).Trim();
        }

        // Gender mapping: form sends M/F, DB stores MALE/FEMALE
        string genderDb = "MALE";
        if (gender == "F") genderDb = "FEMALE";
        else if (gender == "OTHER") genderDb = "OTHER";

        // Store the spec_id (not the name) so the JOIN in listing pages works
        int specId = SafeInt(specIdStr, 0);
        string specName = specId > 0 ? specIdStr : "";

        try
        {
            using (var conn = new MySqlConnection(ConnectionString))
            {
                conn.Open();

                // -- Update acad_student ---------------------------
                const string updateStudentSql = @"
                    UPDATE acad_student SET
                        firstname       = @firstName,
                        othername       = @otherName,
                        gender          = @gender,
                        dob             = @dob,
                        nationality     = @nationality,
                        national_id     = @nationalId,
                        religion        = @religion,
                        entrymethod     = @entryMethod,
                        progid          = @programme,
                        studPhone       = @phone,
                        email           = @email,
                        entryyear       = @entryYear,
                        studsesion      = @session,
                        home_dist       = @district,
                        intake          = @intake,
                        specialisation  = @specName,
                        studCampus      = @campus,
                        billingID       = @billingId
                    WHERE regno = @regno";

                using (var cmd = new MySqlCommand(updateStudentSql, conn))
                {
                    cmd.Parameters.AddWithValue("@firstName",   firstName);
                    cmd.Parameters.AddWithValue("@otherName",   otherName);
                    cmd.Parameters.AddWithValue("@gender",      genderDb);
                    cmd.Parameters.AddWithValue("@dob",         birthDate);
                    cmd.Parameters.AddWithValue("@nationality", nationality);
                    cmd.Parameters.AddWithValue("@nationalId",  nationalId);
                    cmd.Parameters.AddWithValue("@religion",    religion);
                    cmd.Parameters.AddWithValue("@entryMethod", entryMethod);
                    cmd.Parameters.AddWithValue("@programme",   programme);
                    cmd.Parameters.AddWithValue("@phone",       phone);
                    cmd.Parameters.AddWithValue("@email",       email);
                    cmd.Parameters.AddWithValue("@entryYear",   SafeInt(entryYear, DateTime.Now.Year));
                    cmd.Parameters.AddWithValue("@session",     session);
                    cmd.Parameters.AddWithValue("@district",    district);
                    cmd.Parameters.AddWithValue("@intake",      intake);
                    cmd.Parameters.AddWithValue("@specName",    specName);
                    cmd.Parameters.AddWithValue("@campus",      SafeInt(campus, 1));
                    cmd.Parameters.AddWithValue("@billingId",   SafeInt(billing, 1));
                    cmd.Parameters.AddWithValue("@regno",       regno);
                    cmd.ExecuteNonQuery();
                }

                // -- Get the student's entry number ---------------
                string entryNo = "";
                using (var cmd = new MySqlCommand(
                    "SELECT entryno FROM acad_student WHERE regno=@r LIMIT 1", conn))
                {
                    cmd.Parameters.AddWithValue("@r", regno);
                    object val = cmd.ExecuteScalar();
                    if (val != null && val != DBNull.Value)
                        entryNo = val.ToString();
                }

                // -- Update acad_applications (if record exists) --
                if (!string.IsNullOrEmpty(entryNo) && entryNo != "-")
                {
                    // Check if application record exists
                    bool appExists = false;
                    using (var cmd = new MySqlCommand(
                        "SELECT COUNT(*) FROM acad_applications WHERE stud_entry_no=@eno", conn))
                    {
                        cmd.Parameters.AddWithValue("@eno", entryNo);
                        appExists = Convert.ToInt32(cmd.ExecuteScalar()) > 0;
                    }

                    if (appExists)
                    {
                        const string updateAppSql = @"
                            UPDATE acad_applications SET
                                stud_name          = @name,
                                stud_sex           = @sex,
                                stud_nationality   = @nationality,
                                stud_religion      = @religion,
                                stud_entry_method  = @entryMethod,
                                stud_sponsor       = @sponsor,
                                sponsor_contact    = @sponsorContact,
                                stud_birthdate     = @dob,
                                stud_phone         = @phone,
                                next_kin           = @kinName,
                                stud_phy_address   = @address,
                                stud_email         = @email,
                                stud_mar_stat      = @marital,
                                stud_campus        = @campus,
                                residence_country  = @resCountry,
                                olevel_school      = @oLevelSchool,
                                alevel_school      = @aLevelSchool,
                                olevel_index       = @oLevelIndex,
                                alevel_index       = @aLevelIndex,
                                post_box           = @postBox,
                                home_district      = @district,
                                kin_contacts       = @kinContact,
                                kin_relationship   = @kinRelation,
                                stud_intake        = @intake,
                                title              = @title,
                                physicalDisability = @disability,
                                billingID          = @billingId,
                                national_id        = @nationalId
                            WHERE stud_entry_no = @eno";
                        using (var cmd = new MySqlCommand(updateAppSql, conn))
                        {
                            cmd.Parameters.AddWithValue("@name",           fullName);
                            cmd.Parameters.AddWithValue("@sex",            gender);
                            cmd.Parameters.AddWithValue("@nationality",    nationality);
                            cmd.Parameters.AddWithValue("@religion",       religion);
                            cmd.Parameters.AddWithValue("@entryMethod",    entryMethod);
                            cmd.Parameters.AddWithValue("@sponsor",        sponsor);
                            cmd.Parameters.AddWithValue("@sponsorContact", sponsorContact);
                            cmd.Parameters.AddWithValue("@dob",            birthDate);
                            cmd.Parameters.AddWithValue("@phone",          phone);
                            cmd.Parameters.AddWithValue("@kinName",        kinName);
                            cmd.Parameters.AddWithValue("@address",        address);
                            cmd.Parameters.AddWithValue("@email",          email);
                            cmd.Parameters.AddWithValue("@marital",        marital);
                            cmd.Parameters.AddWithValue("@campus",         campus);
                            cmd.Parameters.AddWithValue("@resCountry",     resCountry);
                            cmd.Parameters.AddWithValue("@oLevelSchool",   oLevelSchool);
                            cmd.Parameters.AddWithValue("@aLevelSchool",   aLevelSchool);
                            cmd.Parameters.AddWithValue("@oLevelIndex",    oLevelIndex);
                            cmd.Parameters.AddWithValue("@aLevelIndex",    aLevelIndex);
                            cmd.Parameters.AddWithValue("@postBox",        postBox);
                            cmd.Parameters.AddWithValue("@district",       district);
                            cmd.Parameters.AddWithValue("@kinContact",     kinContact);
                            cmd.Parameters.AddWithValue("@kinRelation",    kinRelation);
                            cmd.Parameters.AddWithValue("@intake",         intake);
                            cmd.Parameters.AddWithValue("@title",          title);
                            cmd.Parameters.AddWithValue("@disability",     disability);
                            cmd.Parameters.AddWithValue("@billingId",      SafeInt(billing, 1));
                            cmd.Parameters.AddWithValue("@nationalId",     nationalId);
                            cmd.Parameters.AddWithValue("@eno",            entryNo);
                            cmd.ExecuteNonQuery();
                        }
                    }

                    // -- Update acad_applicant_choices specialisation --
                    if (specId > 0)
                    {
                        using (var cmd = new MySqlCommand(
                            "UPDATE acad_applicant_choices SET sub_comb=@sid, prog_id=@prog WHERE stud_entry_no=@eno LIMIT 1", conn))
                        {
                            cmd.Parameters.AddWithValue("@sid",  specId);
                            cmd.Parameters.AddWithValue("@prog", programme);
                            cmd.Parameters.AddWithValue("@eno",  entryNo);
                            cmd.ExecuteNonQuery();
                        }
                    }
                }

                // -- Success - show result via JS -------------------
                ScriptManager.RegisterStartupScript(this, GetType(), "editSuccess",
                    string.Format("showSuccess('{0}','{1}',false);",
                        EscapeJs(entryNo), EscapeJs(regno)), true);
            }
        }
        catch (Exception ex)
        {
            ShowError("Failed to update student: " + ex.Message);
        }
    }

    // ===============================================================
    //  HELPERS
    // ===============================================================

    /// <summary>
    /// Read selected value from dropdown, falling back to hidden field
    /// if dropdown has no selection (ViewState disabled + client-side filtering).
    /// </summary>
    private string DdlOrHidden(DropDownList ddl, HiddenField hf)
    {
        string val = ddl.SelectedValue;
        if (!string.IsNullOrEmpty(val)) return val;
        // Fallback: JS copied the value into a hidden field before postback
        if (hf != null && !string.IsNullOrEmpty(hf.Value))
            return hf.Value;
        return "";
    }

    private void ShowError(string msg)
    {
        alertBox.Visible = true;
        alertBox.Attributes["class"] = "nsr-alert nsr-alert--err";
        litAlert.Text = Server.HtmlEncode(msg);
        // Restore dropdown selections from hidden fields so form keeps state
        RestoreDropdownSelections();
        ScriptManager.RegisterStartupScript(this, GetType(), "reEnable",
            "reEnableSubmit(); window.scrollTo({top:0,behavior:'smooth'});", true);
    }

    /// <summary>
    /// After postback with ViewState off, re-select the values the user
    /// chose (captured in hidden fields by JS before the postback).
    /// </summary>
    private void RestoreDropdownSelections()
    {
        TrySelect(ddlProgramme,   hfProgramme.Value);
        TrySelect(ddlSession,     hfSession.Value);
        TrySelect(ddlCampus,      hfCampus.Value);
        TrySelect(ddlEntryYear,   hfEntryYear.Value);
        TrySelect(ddlBilling,     hfBilling.Value);
        TrySelect(ddlFaculty,     hfFaculty.Value);
        TrySelect(ddlNationality, hfNationality.Value);
        TrySelect(ddlSpecialisation, hfSpecialisation.Value);
    }

    private static void TrySelect(DropDownList ddl, string val)
    {
        if (string.IsNullOrEmpty(val)) return;
        if (ddl.Items.FindByValue(val) != null)
            ddl.SelectedValue = val;
    }

    private int SafeInt(string val, int def)
    {
        int r;
        return int.TryParse(val, out r) ? r : def;
    }

    private int SafeInt(object val, int def)
    {
        if (val == null || val == DBNull.Value) return def;
        int r;
        return int.TryParse(val.ToString(), out r) ? r : def;
    }

    private string GetCurrentUser()
    {
        if (Session["username"] != null && Session["username"].ToString().Trim() != "")
            return Session["username"].ToString().Trim();
        if (HttpContext.Current.User.Identity.IsAuthenticated)
            return HttpContext.Current.User.Identity.Name;
        return "system";
    }
}