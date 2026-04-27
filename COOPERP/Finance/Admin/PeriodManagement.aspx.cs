using System;
using System.Data;
using System.Web.UI.WebControls;
using MySql.Data.MySqlClient;

/// <summary>
/// Accounting Period Management — State Transition Console.
/// Supports the forward-only period lifecycle: Open → Frozen → Closed → Archived.
/// Each transition is validated (prerequisite checks) and permanently recorded with the
/// acting user's name, timestamp, and an optional lock reason.
/// Rules enforced:
///   Freeze  : Period must be Open, cannot be already frozen/closed/archived.
///   Close   : Period must be Frozen (month-end complete).
///   Archive : Period must be Closed for adjustment (final close complete).
/// </summary>
public partial class COOPERP_Finance_Admin_PeriodManagement : System.Web.UI.Page
{
    // ─── Page Load ───────────────────────────────────────────────────────────

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!FinanceSystemRealignmentHelper.EnsureFinanceAdminAccess(this, lblPeriodInfo))
        {
            gvPeriods.Visible = false;
            return;
        }

        if (!IsPostBack)
        {
            BindPeriods();
        }
    }

    // ─── GridView Binding ─────────────────────────────────────────────────────

    private void BindPeriods()
    {
        DataTable dt = CreatePeriodSchema();

        try
        {
            using (MySqlConnection conn = new MySqlConnection(FinanceSystemRealignmentHelper.GetFinanceConnectionString()))
            {
                conn.Open();

                if (!FinanceSystemRealignmentHelper.TableExists(conn, "fin_accounting_periods"))
                {
                    lblPeriodInfo.ForeColor = System.Drawing.Color.DarkOrange;
                    lblPeriodInfo.Text = "⚠ fin_accounting_periods table is not yet available. Apply roadmap Phase 1 schema scripts first.";
                    gvPeriods.DataSource = dt;
                    gvPeriods.DataBind();
                    return;
                }

                using (MySqlCommand cmd = new MySqlCommand(@"
                    SELECT
                        period_id                                                            AS PeriodId,
                        fiscal_year                                                          AS FiscalYear,
                        LPAD(period_number, 2, '0')                                         AS Period,
                        COALESCE(period_name, CONCAT('Period ', period_number))             AS PeriodName,
                        CASE WHEN is_open_for_posting    = 1 THEN 'Open'   ELSE 'Closed' END AS PostingStatus,
                        CASE WHEN is_frozen_for_month_end = 1 THEN 'Frozen' ELSE 'No'    END AS FreezeStatus,
                        CASE
                            WHEN is_archived              = 1 THEN 'Archived'
                            WHEN is_closed_for_adjustment = 1 THEN 'Closed'
                            ELSE 'Open/Active'
                        END                                                                  AS CloseStatus,
                        CASE WHEN trial_balance_balanced  = 1 THEN 'Yes'   ELSE 'No'     END AS TBBalanced,
                        CASE
                            WHEN is_archived              = 1 THEN 'Archived'
                            WHEN is_closed_for_adjustment = 1 THEN 'Closed'
                            WHEN is_frozen_for_month_end  = 1 THEN 'Frozen'
                            WHEN is_open_for_posting      = 1 THEN 'Open'
                            ELSE 'Not Started'
                        END                                                                  AS CurrentState
                    FROM fin_accounting_periods
                    ORDER BY fiscal_year DESC, period_number DESC
                    LIMIT 240;", conn))
                using (MySqlDataAdapter da = new MySqlDataAdapter(cmd))
                {
                    da.Fill(dt);
                }
            }

            gvPeriods.DataSource = dt;
            gvPeriods.DataBind();

            lblPeriodInfo.ForeColor = System.Drawing.Color.DarkGreen;
            lblPeriodInfo.Text = dt.Rows.Count == 0
                ? "No accounting periods defined yet. Run Phase 1.2 schema + migration scripts."
                : string.Format("Showing {0} accounting period(s). Use the action buttons to transition period states.", dt.Rows.Count);
        }
        catch (Exception ex)
        {
            gvPeriods.DataSource = dt;
            gvPeriods.DataBind();
            lblPeriodInfo.ForeColor = System.Drawing.Color.DarkRed;
            lblPeriodInfo.Text = "Error loading accounting periods: " + ex.Message;
        }
    }

    // ─── GridView Row Command (transition buttons) ────────────────────────────

    protected void gvPeriods_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        string[] validCommands = { "FreezePeriod", "ClosePeriod", "ArchivePeriod" };
        bool known = Array.IndexOf(validCommands, e.CommandName) >= 0;
        if (!known) return;

        string periodId = e.CommandArgument.ToString();
        string targetState;
        string label;

        switch (e.CommandName)
        {
            case "FreezePeriod":
                targetState = "Freeze";
                label = string.Format("Freezing Period #{0} for month-end. No new transactions will be allowed until the period is closed.", periodId);
                break;
            case "ClosePeriod":
                targetState = "Close";
                label = string.Format("Closing Period #{0}. This period will be finalised and no regular postings will be accepted.", periodId);
                break;
            default:
                targetState = "Archive";
                label = string.Format("Archiving Period #{0}. This period will become permanently read-only.", periodId);
                break;
        }

        hdnPeriodId.Value     = periodId;
        hdnTargetState.Value  = targetState;
        lblTransitionTitle.Text = label;
        txtLockReason.Text    = string.Empty;
        pnlTransitionPanel.Visible = true;
    }

    // ─── Confirm Transition ───────────────────────────────────────────────────

    protected void btnConfirmTransition_Click(object sender, EventArgs e)
    {
        string periodId     = hdnPeriodId.Value.Trim();
        string targetState  = hdnTargetState.Value.Trim();
        string lockReason   = txtLockReason.Text.Trim();
        string actingUser   = Session["username"] != null ? Session["username"].ToString() : "system";

        try
        {
            using (MySqlConnection conn = new MySqlConnection(FinanceSystemRealignmentHelper.GetFinanceConnectionString()))
            {
                conn.Open();

                // Load current state so we can validate the transition
                DataTable current = new DataTable();
                using (MySqlCommand sel = new MySqlCommand(@"
                    SELECT is_open_for_posting, is_frozen_for_month_end,
                           is_closed_for_adjustment, is_archived
                    FROM fin_accounting_periods WHERE period_id = @pid LIMIT 1;", conn))
                {
                    sel.Parameters.AddWithValue("@pid", periodId);
                    using (MySqlDataAdapter da = new MySqlDataAdapter(sel))
                        da.Fill(current);
                }

                if (current.Rows.Count == 0)
                {
                    ShowError("Period not found. It may have been deleted.");
                    return;
                }

                DataRow row        = current.Rows[0];
                bool isOpen        = ToBool(row["is_open_for_posting"]);
                bool isFrozen      = ToBool(row["is_frozen_for_month_end"]);
                bool isClosed      = ToBool(row["is_closed_for_adjustment"]);
                bool isArchived    = ToBool(row["is_archived"]);

                // ── Freeze: period must be Open and not yet frozen/closed/archived ──
                if (targetState == "Freeze")
                {
                    if (!isOpen || isFrozen || isClosed || isArchived)
                    {
                        ShowError("Cannot freeze this period. It must be Open and not already frozen or closed.");
                        return;
                    }

                    using (MySqlCommand upd = new MySqlCommand(@"
                        UPDATE fin_accounting_periods
                        SET is_frozen_for_month_end = 1,
                            is_open_for_posting     = 0,
                            posting_lock_reason     = @reason,
                            posted_by_user          = @user,
                            locked_at               = NOW(),
                            updated_at              = NOW()
                        WHERE period_id = @pid AND is_archived = 0;", conn))
                    {
                        upd.Parameters.AddWithValue("@reason", string.IsNullOrEmpty(lockReason) ? "Month-end freeze initiated." : lockReason);
                        upd.Parameters.AddWithValue("@user",   actingUser);
                        upd.Parameters.AddWithValue("@pid",    periodId);
                        upd.ExecuteNonQuery();
                    }
                }
                // ── Close: period must be Frozen ──
                else if (targetState == "Close")
                {
                    if (!isFrozen || isClosed || isArchived)
                    {
                        ShowError("Cannot close this period. It must be in Frozen (month-end) state first.");
                        return;
                    }

                    using (MySqlCommand upd = new MySqlCommand(@"
                        UPDATE fin_accounting_periods
                        SET is_frozen_for_month_end   = 0,
                            is_closed_for_adjustment  = 1,
                            posting_lock_reason       = @reason,
                            posted_by_user            = @user,
                            locked_at                 = NOW(),
                            updated_at                = NOW()
                        WHERE period_id = @pid AND is_archived = 0;", conn))
                    {
                        upd.Parameters.AddWithValue("@reason", string.IsNullOrEmpty(lockReason) ? "Period closed by " + actingUser : lockReason);
                        upd.Parameters.AddWithValue("@user",   actingUser);
                        upd.Parameters.AddWithValue("@pid",    periodId);
                        upd.ExecuteNonQuery();
                    }
                }
                // ── Archive: period must be Closed ──
                else if (targetState == "Archive")
                {
                    if (!isClosed || isArchived)
                    {
                        ShowError("Cannot archive this period. It must be Closed for adjustment first.");
                        return;
                    }

                    using (MySqlCommand upd = new MySqlCommand(@"
                        UPDATE fin_accounting_periods
                        SET is_archived              = 1,
                            is_closed_for_adjustment = 1,
                            posting_lock_reason      = @reason,
                            posted_by_user           = @user,
                            locked_at                = NOW(),
                            updated_at               = NOW()
                        WHERE period_id = @pid;", conn))
                    {
                        upd.Parameters.AddWithValue("@reason", string.IsNullOrEmpty(lockReason) ? "Period archived by " + actingUser : lockReason);
                        upd.Parameters.AddWithValue("@user",   actingUser);
                        upd.Parameters.AddWithValue("@pid",    periodId);
                        upd.ExecuteNonQuery();
                    }
                }
            }

            pnlTransitionPanel.Visible = false;
            lblPeriodInfo.ForeColor    = System.Drawing.Color.DarkGreen;
            lblPeriodInfo.Text = string.Format(
                "Period #{0} successfully transitioned to '{1}' state by {2}.",
                periodId, targetState, actingUser);

            BindPeriods();
        }
        catch (Exception ex)
        {
            lblPeriodInfo.ForeColor = System.Drawing.Color.DarkRed;
            lblPeriodInfo.Text = "Error applying period transition: " + ex.Message;
        }
    }

    // ─── Cancel Transition ────────────────────────────────────────────────────

    protected void btnCancelTransition_Click(object sender, EventArgs e)
    {
        pnlTransitionPanel.Visible = false;
        lblPeriodInfo.ForeColor    = System.Drawing.Color.Gray;
        lblPeriodInfo.Text         = "Transition cancelled. No changes made.";
        BindPeriods();
    }

    // ─── Helpers ──────────────────────────────────────────────────────────────

    private void ShowError(string message)
    {
        pnlTransitionPanel.Visible = false;
        lblPeriodInfo.ForeColor    = System.Drawing.Color.DarkRed;
        lblPeriodInfo.Text         = message;
        BindPeriods();
    }

    /// <summary>Safely converts MySQL tinyint/bool/string to C# bool.</summary>
    private static bool ToBool(object value)
    {
        if (value == null || value == DBNull.Value) return false;
        if (value is bool)  return (bool)value;
        if (value is int)   return (int)value == 1;
        if (value is long)  return (long)value == 1;
        if (value is sbyte) return (sbyte)value == 1;
        string s = value.ToString().Trim().ToLower();
        return s == "1" || s == "true" || s == "yes" || s == "y";
    }

    // ─── DataTable Schema ─────────────────────────────────────────────────────

    private static DataTable CreatePeriodSchema()
    {
        DataTable dt = new DataTable();
        dt.Columns.Add("PeriodId",     typeof(int));
        dt.Columns.Add("FiscalYear");
        dt.Columns.Add("Period");
        dt.Columns.Add("PeriodName");
        dt.Columns.Add("PostingStatus");
        dt.Columns.Add("FreezeStatus");
        dt.Columns.Add("CloseStatus");
        dt.Columns.Add("TBBalanced");
        dt.Columns.Add("CurrentState");
        return dt;
    }
}
