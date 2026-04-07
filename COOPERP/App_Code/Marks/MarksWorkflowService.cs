using System;
using System.Collections.Generic;
using System.Configuration;
using System.Text;
using System.Web;
using MySql.Data.MySqlClient;

/// <summary>
/// MarksWorkflowService — Unified workflow orchestrator for mark sheet lifecycle.
///
/// This service ties together the individual services (ResultsStatusService,
/// MarksLockService, MarksAuditService, MarksSheetService) into cohesive
/// workflow operations. It is the single entry point for:
///
///   - Submitting marks for review (pre-checks + status transition + audit)
///   - Dean approval/rejection (auth check + transition + notification hook)
///   - Publishing (registrar action + transition + audit)
///   - Reverting to draft (with full lock/status awareness)
///
/// Each workflow method validates preconditions, performs the action,
/// logs the audit trail, and returns a structured result with any
/// validation errors or warnings.
///
/// The status flow is:
///   DRAFT → SUBMITTED → DEAN_APPROVED → PROVISIONAL_PUBLISHED → FINAL_PUBLISHED
///
/// Status badge rendering helpers are also provided for UI consistency.
///
/// Design: C# 5 compatible (no ?. operator, no string interpolation).
/// Addresses: P19-P26 (workflow gaps, approval ambiguity)
/// Task: F-01
/// </summary>
public static class MarksWorkflowService
{
    // ─────────────────────── Connection String ──────────────────────────

    private static string ConnStr
    {
        get { return MarksConfiguration.ConnStr; }
    }

    // ═════════════════════════════════════════════════════════════════════
    // WORKFLOW: Submit for Dean Review
    // ═════════════════════════════════════════════════════════════════════

    /// <summary>
    /// Submit a mark sheet for Dean review. Performs pre-submission validations:
    ///   - Authorization check (must be assigned teacher or admin)
    ///   - Lock state check (must not be past submission deadline)
    ///   - Mark completeness check (warns if missing marks > threshold)
    ///   - Status must be DRAFT
    ///
    /// Returns a workflow result with validation warnings, submission summary,
    /// and success/failure status.
    /// </summary>
    public static WorkflowResult SubmitForReview(
        string courseId, string progId, string acadyear,
        int semester, int studyYear, int campusId, string studSession,
        bool forceSubmitWithMissingMarks)
    {
        WorkflowResult wr = new WorkflowResult();
        wr.Warnings = new List<string>();
        string user = MarksAuthorizationService.GetCurrentUser();

        // ── 1. Authorization ────────────────────────────────────────────
        string authError = MarksAuthorizationService.ValidateMarkEntryAuthorization(
            courseId, progId, acadyear, semester);
        if (authError != null)
        {
            wr.Error = authError;
            return wr;
        }

        // ── 2. Lock state check ─────────────────────────────────────────
        MarksLockService.LockState lockState = MarksLockService.GetLockState(
            courseId, progId, acadyear, semester, studyYear, campusId, studSession);
        if (!MarksLockService.CanSubmit(courseId, progId, acadyear, semester, studyYear, campusId, studSession))
        {
            // Collect all hard lock messages
            StringBuilder lockMsgs = new StringBuilder("Cannot submit: ");
            foreach (MarksLockService.LockReason lr in lockState.Locks)
            {
                if (!lr.IsSoft) lockMsgs.Append(lr.Message).Append(" ");
            }
            wr.Error = lockMsgs.ToString().Trim();
            return wr;
        }

        // ── 3. Mark completeness check ──────────────────────────────────
        MarksSheetService.SheetData sheet = MarksSheetService.LoadSheet(
            courseId, progId, acadyear, semester, studyYear, campusId, studSession, "");

        if (sheet.Error != null)
        {
            wr.Error = "Failed to load sheet data: " + sheet.Error;
            return wr;
        }

        int missing = sheet.TotalStudents - sheet.MarksEnteredCount;
        wr.TotalStudents = sheet.TotalStudents;
        wr.MarksEntered = sheet.MarksEnteredCount;
        wr.MissingMarks = missing;
        wr.ExpectedStudents = sheet.ExpectedStudentCount;

        // Compute average and pass rate
        if (sheet.Rows.Count > 0)
        {
            double totalSum = 0;
            int passCount = 0;
            int enteredCount = 0;
            foreach (MarksSheetService.MarkRow row in sheet.Rows)
            {
                if (row.CwEntered > 0 || row.TestEntered > 0 || row.ExamEntered > 0)
                {
                    totalSum += row.TotalMark;
                    enteredCount++;
                    if (row.TotalMark >= 50) passCount++;
                }
            }
            wr.AverageMark = enteredCount > 0 ? Math.Round(totalSum / enteredCount, 1) : 0;
            wr.PassRate = enteredCount > 0 ? Math.Round((double)passCount / enteredCount * 100, 1) : 0;
        }

        if (missing > 0 && !forceSubmitWithMissingMarks)
        {
            wr.RequiresConfirmation = true;
            wr.Warnings.Add(String.Format(
                "{0} of {1} student{2} ha{3} no marks entered. Missing marks will appear as 0.",
                missing, sheet.TotalStudents,
                missing == 1 ? "" : "s",
                missing == 1 ? "s" : "ve"));
            return wr;
        }

        if (missing > 0)
        {
            wr.Warnings.Add(String.Format(
                "Submitted with {0} missing mark{1}.",
                missing, missing == 1 ? "" : "s"));
        }

        // ── 4. Perform status transition ────────────────────────────────
        ResultsStatusService.TransitionResult tr = ResultsStatusService.Submit(
            courseId, progId, acadyear, semester, studyYear, campusId, studSession);

        if (!tr.Success)
        {
            wr.Error = tr.Error;
            return wr;
        }

        wr.Success = true;
        wr.NewStatus = tr.NewStatus;

        // Collect any soft warnings from lock state
        foreach (MarksLockService.LockReason lr in lockState.Locks)
        {
            if (lr.IsSoft)
            {
                wr.Warnings.Add(lr.Message);
            }
        }

        return wr;
    }

    // ═════════════════════════════════════════════════════════════════════
    // WORKFLOW: Dean Approval
    // ═════════════════════════════════════════════════════════════════════

    /// <summary>
    /// Approve a submitted mark sheet (Dean action).
    /// Validates preconditions and performs SUBMITTED → DEAN_APPROVED.
    /// </summary>
    public static WorkflowResult ApproveSheet(
        string courseId, string progId, string acadyear,
        int semester, int studyYear, int campusId, string studSession)
    {
        WorkflowResult wr = new WorkflowResult();
        wr.Warnings = new List<string>();

        if (!MarksAuthorizationService.CanApproveMarks())
        {
            wr.Error = "You do not have permission to approve marks.";
            return wr;
        }

        ResultsStatusService.TransitionResult tr = ResultsStatusService.Approve(
            courseId, progId, acadyear, semester, studyYear, campusId, studSession);

        if (!tr.Success)
        {
            wr.Error = tr.Error;
            return wr;
        }

        wr.Success = true;
        wr.NewStatus = tr.NewStatus;
        return wr;
    }

    /// <summary>
    /// Reject a submitted mark sheet back to DRAFT (Dean action).
    /// Requires a reason. Teacher is notified and can re-edit.
    /// </summary>
    public static WorkflowResult RejectSheet(
        string courseId, string progId, string acadyear,
        int semester, int studyYear, int campusId, string studSession,
        string reason)
    {
        WorkflowResult wr = new WorkflowResult();
        wr.Warnings = new List<string>();

        if (!MarksAuthorizationService.CanApproveMarks())
        {
            wr.Error = "You do not have permission to reject marks.";
            return wr;
        }

        if (string.IsNullOrEmpty(reason))
        {
            wr.Error = "A reason is required when rejecting marks.";
            return wr;
        }

        ResultsStatusService.TransitionResult tr = ResultsStatusService.Reject(
            courseId, progId, acadyear, semester, studyYear, campusId, studSession, reason);

        if (!tr.Success)
        {
            wr.Error = tr.Error;
            return wr;
        }

        wr.Success = true;
        wr.NewStatus = tr.NewStatus;
        wr.Warnings.Add(String.Format("Sheet rejected. Reason: {0}", reason));
        return wr;
    }

    // ═════════════════════════════════════════════════════════════════════
    // WORKFLOW: Publish Results
    // ═════════════════════════════════════════════════════════════════════

    /// <summary>
    /// Publish approved marks (Registrar action).
    /// DEAN_APPROVED → PROVISIONAL_PUBLISHED (or PROVISIONAL → FINAL).
    /// </summary>
    public static WorkflowResult PublishResults(
        string courseId, string progId, string acadyear,
        int semester, int studyYear, int campusId, string studSession,
        bool isFinal)
    {
        WorkflowResult wr = new WorkflowResult();
        wr.Warnings = new List<string>();

        ResultsStatusService.TransitionResult tr = ResultsStatusService.Publish(
            courseId, progId, acadyear, semester, studyYear, campusId, studSession, isFinal);

        if (!tr.Success)
        {
            wr.Error = tr.Error;
            return wr;
        }

        wr.Success = true;
        wr.NewStatus = tr.NewStatus;
        return wr;
    }

    // ═════════════════════════════════════════════════════════════════════
    // WORKFLOW: Revert to Draft (Admin)
    // ═════════════════════════════════════════════════════════════════════

    /// <summary>
    /// Revert any sheet back to DRAFT status (admin/registrar emergency action).
    /// Only allowed for Administrator/admin/registrar roles.
    /// Creates a full audit trail entry.
    /// </summary>
    public static WorkflowResult RevertToDraft(
        string courseId, string progId, string acadyear,
        int semester, int studyYear, int campusId, string studSession,
        string reason)
    {
        WorkflowResult wr = new WorkflowResult();
        wr.Warnings = new List<string>();
        string user = MarksAuthorizationService.GetCurrentUser();

        if (!MarksAuthorizationService.IsInAnyRole(new string[] { "Administrator", "admin", "registrar" }))
        {
            wr.Error = "Only administrators or registrar can revert sheets to draft.";
            return wr;
        }

        if (string.IsNullOrEmpty(reason))
        {
            wr.Error = "A reason is required for reverting to draft.";
            return wr;
        }

        try
        {
            using (MySqlConnection conn = new MySqlConnection(ConnStr))
            {
                conn.Open();

                string sql = @"UPDATE acad_results_status SET
                    status = 'DRAFT',
                    reject_reason = @reason,
                    submitted_by = NULL,
                    submitted_at = NULL,
                    approved_by = NULL,
                    approved_at = NULL,
                    published_by = NULL,
                    published_at = NULL
                WHERE course_id = @c AND progid = @p AND acadyear = @y
                  AND semester = @s AND study_year = @sy
                  AND campus_id = @campus AND stud_session = @sess";

                using (MySqlCommand cmd = new MySqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@reason", String.Format("Reverted by {0}: {1}", user, reason));
                    cmd.Parameters.AddWithValue("@c", courseId);
                    cmd.Parameters.AddWithValue("@p", progId);
                    cmd.Parameters.AddWithValue("@y", acadyear);
                    cmd.Parameters.AddWithValue("@s", semester);
                    cmd.Parameters.AddWithValue("@sy", studyYear);
                    cmd.Parameters.AddWithValue("@campus", campusId);
                    cmd.Parameters.AddWithValue("@sess", studSession);
                    wr.Success = cmd.ExecuteNonQuery() > 0;
                }
            }

            if (wr.Success)
            {
                wr.NewStatus = "DRAFT";
                MarksAuditService.LogApproval(
                    MarksAuditService.ACTION_REVERT,
                    courseId, progId, acadyear, semester,
                    String.Format("Reverted to DRAFT by {0}: {1}", user, reason));
            }
            else
            {
                wr.Error = "No matching status record found for this sheet context.";
            }
        }
        catch (Exception ex)
        {
            wr.Error = "Revert failed: " + ex.Message;
        }

        return wr;
    }

    // ═════════════════════════════════════════════════════════════════════
    // STATUS BADGE HELPERS (for consistent UI rendering)
    // ═════════════════════════════════════════════════════════════════════

    /// <summary>
    /// Returns the CSS class suffix for a given status.
    /// Used to render consistent status badges across pages.
    /// </summary>
    public static string GetStatusBadgeClass(string status)
    {
        if (status == ResultsStatusService.STATUS_DRAFT) return "draft";
        if (status == ResultsStatusService.STATUS_SUBMITTED) return "submitted";
        if (status == ResultsStatusService.STATUS_DEAN_APPROVED) return "approved";
        if (status == ResultsStatusService.STATUS_PROVISIONAL_PUBLISHED) return "provisional";
        if (status == ResultsStatusService.STATUS_FINAL_PUBLISHED) return "published";
        return "unknown";
    }

    /// <summary>
    /// Returns a human-readable display label for a status.
    /// </summary>
    public static string GetStatusLabel(string status)
    {
        if (status == ResultsStatusService.STATUS_DRAFT) return "Draft";
        if (status == ResultsStatusService.STATUS_SUBMITTED) return "Submitted";
        if (status == ResultsStatusService.STATUS_DEAN_APPROVED) return "Dean Approved";
        if (status == ResultsStatusService.STATUS_PROVISIONAL_PUBLISHED) return "Provisional";
        if (status == ResultsStatusService.STATUS_FINAL_PUBLISHED) return "Published";
        return "Unknown";
    }

    /// <summary>
    /// Returns the status icon character for the status.
    /// </summary>
    public static string GetStatusIcon(string status)
    {
        if (status == ResultsStatusService.STATUS_DRAFT) return "\u270F"; // pencil
        if (status == ResultsStatusService.STATUS_SUBMITTED) return "\u23F3"; // hourglass
        if (status == ResultsStatusService.STATUS_DEAN_APPROVED) return "\u2705"; // check
        if (status == ResultsStatusService.STATUS_PROVISIONAL_PUBLISHED) return "\uD83D\uDD12"; // lock
        if (status == ResultsStatusService.STATUS_FINAL_PUBLISHED) return "\uD83D\uDD12"; // lock
        return "\u2753"; // question
    }

    /// <summary>
    /// Returns the set of allowed next actions for the current user given a status.
    /// Used by UI to determine which buttons to show.
    /// </summary>
    public static List<string> GetAvailableActions(string status)
    {
        List<string> actions = new List<string>();

        if (status == ResultsStatusService.STATUS_DRAFT)
        {
            if (MarksAuthorizationService.CanEnterMarks())
            {
                actions.Add("EDIT");
                actions.Add("SUBMIT");
            }
        }
        else if (status == ResultsStatusService.STATUS_SUBMITTED)
        {
            if (MarksAuthorizationService.CanApproveMarks())
            {
                actions.Add("APPROVE");
                actions.Add("REJECT");
            }
        }
        else if (status == ResultsStatusService.STATUS_DEAN_APPROVED)
        {
            if (MarksAuthorizationService.IsInAnyRole(new string[] { "registrar", "Administrator", "admin" }))
            {
                actions.Add("PUBLISH_PROVISIONAL");
            }
        }
        else if (status == ResultsStatusService.STATUS_PROVISIONAL_PUBLISHED)
        {
            if (MarksAuthorizationService.IsInAnyRole(new string[] { "registrar", "Administrator", "admin" }))
            {
                actions.Add("PUBLISH_FINAL");
            }
        }

        // Admin revert available for any non-DRAFT status
        if (status != ResultsStatusService.STATUS_DRAFT &&
            MarksAuthorizationService.IsInAnyRole(new string[] { "Administrator", "admin", "registrar" }))
        {
            actions.Add("REVERT");
        }

        return actions;
    }

    // ═════════════════════════════════════════════════════════════════════
    // JSON HELPERS
    // ═════════════════════════════════════════════════════════════════════

    /// <summary>
    /// Serializes a WorkflowResult to JSON for AJAX responses.
    /// </summary>
    public static string ToJson(WorkflowResult wr)
    {
        StringBuilder sb = new StringBuilder();
        sb.Append("{");
        sb.Append("\"success\":");
        sb.Append(wr.Success ? "true" : "false");

        if (wr.Error != null)
        {
            sb.Append(",\"error\":\"");
            sb.Append(JsEsc(wr.Error));
            sb.Append("\"");
        }

        if (wr.NewStatus != null)
        {
            sb.Append(",\"newStatus\":\"");
            sb.Append(JsEsc(wr.NewStatus));
            sb.Append("\",\"statusLabel\":\"");
            sb.Append(JsEsc(GetStatusLabel(wr.NewStatus)));
            sb.Append("\",\"statusClass\":\"");
            sb.Append(JsEsc(GetStatusBadgeClass(wr.NewStatus)));
            sb.Append("\"");
        }

        if (wr.RequiresConfirmation)
        {
            sb.Append(",\"requiresConfirmation\":true");
        }

        if (wr.TotalStudents > 0)
        {
            sb.Append(",\"totalStudents\":");
            sb.Append(wr.TotalStudents);
            sb.Append(",\"marksEntered\":");
            sb.Append(wr.MarksEntered);
            sb.Append(",\"missingMarks\":");
            sb.Append(wr.MissingMarks);
            sb.Append(",\"expectedStudents\":");
            sb.Append(wr.ExpectedStudents);
            sb.Append(",\"averageMark\":");
            sb.Append(wr.AverageMark);
            sb.Append(",\"passRate\":");
            sb.Append(wr.PassRate);
        }

        if (wr.Warnings != null && wr.Warnings.Count > 0)
        {
            sb.Append(",\"warnings\":[");
            for (int i = 0; i < wr.Warnings.Count; i++)
            {
                if (i > 0) sb.Append(",");
                sb.Append("\"");
                sb.Append(JsEsc(wr.Warnings[i]));
                sb.Append("\"");
            }
            sb.Append("]");
        }

        sb.Append("}");
        return sb.ToString();
    }

    private static string JsEsc(string s)
    {
        if (string.IsNullOrEmpty(s)) return "";
        return s.Replace("\\", "\\\\").Replace("\"", "\\\"").Replace("\n", "\\n").Replace("\r", "");
    }

    // ═════════════════════════════════════════════════════════════════════
    // DTOs
    // ═════════════════════════════════════════════════════════════════════

    /// <summary>
    /// Result from a workflow operation. Contains success/error state,
    /// the new status after transition, submission summary stats,
    /// and any warnings or confirmation requirements.
    /// </summary>
    public class WorkflowResult
    {
        public bool Success { get; set; }
        public string Error { get; set; }
        public string NewStatus { get; set; }

        /// <summary>True if the operation needs user confirmation before proceeding.</summary>
        public bool RequiresConfirmation { get; set; }

        /// <summary>Validation warnings (non-blocking).</summary>
        public List<string> Warnings { get; set; }

        // ── Submission summary stats ──────────────────────────────────
        public int TotalStudents { get; set; }
        public int MarksEntered { get; set; }
        public int MissingMarks { get; set; }
        public int ExpectedStudents { get; set; }
        public double AverageMark { get; set; }
        public double PassRate { get; set; }
    }
}
