using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using FinancialDataTableAdapters;

/// <summary>
/// Summary description for StudentBillsPaymentBLL
/// </summary>
[System.ComponentModel.DataObject]
public class StudentBillsPaymentBLL
{
    string userName = HttpContext.Current.User.Identity.Name;

    private student_billingTableAdapter _BillingAdapter = null;
    protected student_billingTableAdapter BillingAdapter
    {
        get
        {
            if (_BillingAdapter == null)
                _BillingAdapter = new student_billingTableAdapter();
            return _BillingAdapter;
        }
    }

    [System.ComponentModel.DataObjectMethodAttribute(System.ComponentModel.DataObjectMethodType.Select, true)]
    public FinancialData.student_billingDataTable GetBillsPerTerm(int cls, int trm, int yr)
    {
        return BillingAdapter.GetBillsPerClass(cls,trm,yr);
    }

    [System.ComponentModel.DataObjectMethodAttribute(System.ComponentModel.DataObjectMethodType.Delete, true)]
    public bool DeleteBill(int bill_id, int original_bill_id)
    {
        int rowsAffected = BillingAdapter.DeleteStudentBill(userName, original_bill_id);
        // Return true if precisely one row was deleted, otherwise false
        return rowsAffected == 1;
    }

    public static string DefaultTerm()
    {
        if (DateTime.Today.Month <= 4)
            return "1";
        else if (DateTime.Today.Month <= 8)
            return "2";
        else
        {
            return "3";
        }
    }
}