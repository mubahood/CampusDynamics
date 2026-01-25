using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using CoopERPDataTableAdapters;

/// <summary>
/// Summary description for AccountsBLL
/// This class contains data components for Main Accounts, Ledgers and other details
/// </summary>
[System.ComponentModel.DataObject]
public class AccountsBLL
{
    string UserName = HttpContext.Current.User.Identity.Name;
    private fin_mainaccountsTableAdapter _MainAccountsAdapter = null;
    private fin_subaccountsTableAdapter _SubAccountsAdapter = null;
    string userName = HttpContext.Current.User.Identity.Name;
    fin_GetLedgerTypesByCategoryTableAdapter LegderTypeAdapter = new fin_GetLedgerTypesByCategoryTableAdapter();

    protected fin_mainaccountsTableAdapter MainAccountsAdapter
    {
        get
        {
            if (_MainAccountsAdapter == null)
                _MainAccountsAdapter = new fin_mainaccountsTableAdapter();
            return _MainAccountsAdapter;
        }
    }

    protected fin_subaccountsTableAdapter SubAccountsAdapter
    {
        get
        {
            if (_SubAccountsAdapter == null)
                _SubAccountsAdapter = new fin_subaccountsTableAdapter();
            return _SubAccountsAdapter;
        }
    }

    //Data Selection
    [System.ComponentModel.DataObjectMethodAttribute(System.ComponentModel.DataObjectMethodType.Select, true)]
    public CoopERPData.fin_mainaccountsDataTable GetMainAccounts()
    {
        return MainAccountsAdapter.GetData();
    }

    //Get SubAccounts
    [System.ComponentModel.DataObjectMethodAttribute(System.ComponentModel.DataObjectMethodType.Select, true)]
    public CoopERPData.fin_subaccountsDataTable GetAccountsByCategory(string CategoryCode)
    {
        return SubAccountsAdapter.GetAccountsbyCategory(CategoryCode);
    }

    //Data Selection
    [System.ComponentModel.DataObjectMethodAttribute(System.ComponentModel.DataObjectMethodType.Select, true)]
    public CoopERPData.fin_GetLedgerTypesByCategoryDataTable GetAllLedgerTypes()
    {
        return LegderTypeAdapter.GetAllLedgerCategories();
    }




    //New Data Components
    [System.ComponentModel.DataObjectMethodAttribute(System.ComponentModel.DataObjectMethodType.Insert, true)]
    public bool AddCategory(string AccountCode, string AccountName,  string GeneralCategory, string SubCategory)
    {
        try
        {
            MainAccountsAdapter.MainAccountEditor(UserName, AccountCode, AccountName, GeneralCategory, SubCategory);
            return true;
        }
        catch (Exception ex)
        {
            throw ex;
        }

    }

    //AccountCode, MainAccountCode, AccountName, Details, JournalCode

    [System.ComponentModel.DataObjectMethodAttribute(System.ComponentModel.DataObjectMethodType.Insert, true)]
    public bool AddAccount(string AccountCode, string MainAccountCode, string AccountName, string Details, string accounttype, string collectionLedgerType)
    {
        try
        {
            SubAccountsAdapter.AccountEditor(UserName, AccountCode, MainAccountCode, AccountName, Details, accounttype, collectionLedgerType);
            return true;
        }
        catch (Exception ex)
        {
            throw ex;
        }

    }

    //Data Editing
    [System.ComponentModel.DataObjectMethodAttribute(System.ComponentModel.DataObjectMethodType.Update, true)]
    public bool UpdateCategory(string AccountName, string GeneralCategory, string SubCategory, string AccountCode, string original_AccountCode)
    {
        try
        {
            MainAccountsAdapter.MainAccountEditor(UserName, original_AccountCode, AccountName, GeneralCategory, SubCategory);
            return true;
        }
        catch (Exception ex)
        {
            throw ex;
        }

    }
    [System.ComponentModel.DataObjectMethodAttribute(System.ComponentModel.DataObjectMethodType.Update, true)]
    public bool UpdateAccount(string MainAccountCode, string AccountName, string Details, string accounttype, string collectionLedgerType, string AccountCode, string original_AccountCode)
    {
        try
        {
            SubAccountsAdapter.AccountEditor(UserName, original_AccountCode, MainAccountCode, AccountName, Details, accounttype, collectionLedgerType);
            return true;
        }
        catch (Exception ex)
        {
            throw ex;
        }

    }


    //Data Deletion
    [System.ComponentModel.DataObjectMethodAttribute(System.ComponentModel.DataObjectMethodType.Delete, true)]
    public bool DeleteCategory(string AccountCode, string original_AccountCode)
    {
        int rowsAffected = MainAccountsAdapter.DeleteMainAccount(HttpContext.Current.User.Identity.Name, original_AccountCode);
        // Return true if precisely one row was deleted, otherwise false
        return rowsAffected == 1;
    }
    [System.ComponentModel.DataObjectMethodAttribute(System.ComponentModel.DataObjectMethodType.Delete, true)]
    public bool DeleteAccount(string AccountCode, string original_AccountCode)
    {
        int rowsAffected = SubAccountsAdapter.DeleteAccount(HttpContext.Current.User.Identity.Name, original_AccountCode);
        // Return true if precisely one row was deleted, otherwise false
        return rowsAffected == 1;
    }

    //New Ledger Category
    [System.ComponentModel.DataObjectMethodAttribute(System.ComponentModel.DataObjectMethodType.Insert, true)]
    public bool AddLedgerCategory(string LedgerTypeName, string LedgerTypeCategory)
    {
        try
        {
            LegderTypeAdapter.fin_LedgerCategoryEditor(null, LedgerTypeName, LedgerTypeCategory);
            return true;
        }
        catch (Exception ex)
        {
            throw ex;
        }

    }

    //New Ledger Category
    [System.ComponentModel.DataObjectMethodAttribute(System.ComponentModel.DataObjectMethodType.Update, true)]
    public bool EditLedgerCategory(string LedgerTypeName, string LedgerTypeCategory, int original_LedgerTypeID)
    {
        try
        {
            LegderTypeAdapter.fin_LedgerCategoryEditor(original_LedgerTypeID, LedgerTypeName, LedgerTypeCategory);
            return true;
        }
        catch (Exception ex)
        {
            throw ex;
        }

    }

    [System.ComponentModel.DataObjectMethodAttribute(System.ComponentModel.DataObjectMethodType.Delete, true)]
    public bool DeleteLedgerCategory(int original_LedgerTypeID)
    {
        try
        {
            LegderTypeAdapter.fin_DeleteLedgerCategory(original_LedgerTypeID);
            return true;
        }
        catch (Exception ex)
        {
            throw ex;
        }

    }

    public string CreateVoucher(string voucherType)
    {
        fin_vouchernumbersTableAdapter VNo = new fin_vouchernumbersTableAdapter();
        try
        {
            VNo.Insert(userName, "New", voucherType,DateTime.Today);
            return "Voucher Create Successfully";
        }
        catch (Exception ex)
        {
            return "Error! "+ex.Message;
        }
    }

    public string NewVoucherEntry(int vNo, string CRaccountcode, string CRaccountType, string CRParticulars,
    string DRaccountcode, string DRaccountType, string DRParticulars, long transaction_amount, int voucherNo, DateTime transactionDate)
    {
        try
        {
            fin_voucherTableAdapter Vouchers = new fin_voucherTableAdapter();
            Vouchers.fin_VoucherCreator(vNo, CRaccountcode, CRaccountType, CRParticulars, DRaccountcode, DRaccountType, DRParticulars, transaction_amount, voucherNo, transactionDate,
                userName);
            return "Voucher Create Successfully";
        }
        catch (Exception ex)
        {
            return "Error! " + ex.Message;
        }
    }

    
   
}