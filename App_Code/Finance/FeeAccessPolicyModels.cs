using System;

public class FeeAccessPolicyConfig
{
    public int PolicyId;
    public string PolicyTitle;
    public string AcademicYear;
    public int Semester;
    public bool IsActive;
    public string RuleLogic;
    public string PolicyNotes;

    public bool RuleMinBalanceEnabled;
    public decimal RuleMinBalanceAmount;

    public bool RulePaymentWindowEnabled;
    public decimal RulePaymentMinAmount;
    public DateTime? RulePaymentWindowStart;
    public DateTime? RulePaymentWindowEnd;

    public bool RulePctPaidEnabled;
    public decimal RulePctPaidMinimum;

    public bool RuleBursaryExempt;
    public decimal RuleBursaryMinCoverage;

    public bool RuleRequireRegistration;

    public string CreatedBy;
    public DateTime? CreatedAt;
    public string UpdatedBy;
    public DateTime? UpdatedAt;

    public FeeAccessPolicyConfig()
    {
        PolicyTitle = "Fee Access Policy";
        AcademicYear = "";
        Semester = 0;
        RuleLogic = "ALL";
        PolicyNotes = "";
        CreatedBy = "";
        UpdatedBy = "";
    }
}

public class FeeAccessPreviewResult
{
    public bool Success;
    public string Message;
    public int TotalStudents;
    public int AllowedStudents;
    public int DeniedStudents;

    public FeeAccessPreviewResult()
    {
        Success = false;
        Message = "";
    }
}
