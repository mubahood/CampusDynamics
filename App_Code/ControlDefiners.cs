using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI.WebControls;
using DevExpress.Web;

/// <summary>
/// Summary description for ControlDefiners
/// </summary>
public class ControlDefiners
{
    public ASPxComboBox ASPXComboDefiner(string fieldName, string controlName, ASPxGridView GV)
    {
        ASPxComboBox txtCombo = (ASPxComboBox)GV.FindEditRowCellTemplateControl((DevExpress.Web.GridViewDataColumn)GV.Columns[fieldName],
            controlName);
        return txtCombo;
    }

    public ASPxTextBox ASPXTextBoxDefiner(string fieldName, string controlName, ASPxGridView GV)
    {
        ASPxTextBox txtText = (ASPxTextBox)GV.FindEditRowCellTemplateControl((DevExpress.Web.GridViewDataColumn)GV.Columns[fieldName],
            controlName);
        return txtText;
    }

    public ASPxMemo ASPXMemoDefiner(string fieldName, string controlName, ASPxGridView GV)
    {
        ASPxMemo txtText = (ASPxMemo)GV.FindEditRowCellTemplateControl((DevExpress.Web.GridViewDataColumn)GV.Columns[fieldName],
            controlName);
        return txtText;
    }

    public ASPxLabel ASPXLabelDefiner(string fieldName, string controlName, ASPxGridView GV)
    {
        ASPxLabel txtText = (ASPxLabel)GV.FindEditRowCellTemplateControl((DevExpress.Web.GridViewDataColumn)GV.Columns[fieldName],
            controlName);
        return txtText;
    }

    public ASPxButton ASPXButtonDefiner(string fieldName, string controlName, ASPxGridView GV)
    {
        ASPxButton txtText = (ASPxButton)GV.FindEditRowCellTemplateControl((DevExpress.Web.GridViewDataColumn)GV.Columns[fieldName],
            controlName);
        return txtText;
    }

    public ASPxGridView ASPXGridDefiner(string fieldName, string controlName, ASPxGridView GV)
    {
        ASPxGridView txtGrid = (ASPxGridView)GV.FindEditRowCellTemplateControl((DevExpress.Web.GridViewDataColumn)GV.Columns[fieldName],
            controlName);
        return txtGrid;
    }



    public ASPxComboBox DataASPXComboDefiner(string fieldName, string controlName, ASPxGridView GV, int Index)
    {
        ASPxComboBox txtCombo = (ASPxComboBox)GV.FindRowCellTemplateControl(Index,
            (DevExpress.Web.GridViewDataColumn)GV.Columns[fieldName], controlName);
        return txtCombo;
    }

    public ASPxGridView DataASPXGridViewDefiner(string fieldName, string controlName, ASPxGridView GV, int Index)
    {
        ASPxGridView txtCombo = (ASPxGridView)GV.FindRowCellTemplateControl(Index,
            (DevExpress.Web.GridViewDataColumn)GV.Columns[fieldName], controlName);
        return txtCombo;
    }

    public ASPxCheckBox DataASPXCheckBoxDefiner(string fieldName, string controlName, ASPxGridView GV, int Index)
    {
        ASPxCheckBox txtCombo = (ASPxCheckBox)GV.FindRowCellTemplateControl(Index,
            (DevExpress.Web.GridViewDataColumn)GV.Columns[fieldName], controlName);
        return txtCombo;
    }
    public ImageButton DataImageButtonDefiner(string fieldName, string controlName, ASPxGridView GV, int Index)
    {
        ImageButton txtCombo = (ImageButton)GV.FindRowCellTemplateControl(Index,
            (DevExpress.Web.GridViewDataColumn)GV.Columns[fieldName], controlName);
        return txtCombo;
    }

    public ASPxTextBox DataASPXTextBoxDefiner(string fieldName, string controlName, ASPxGridView GV, int Index)
    {
        ASPxTextBox txtText = (ASPxTextBox)GV.FindRowCellTemplateControl(Index,
           (DevExpress.Web.GridViewDataColumn)GV.Columns[fieldName], controlName);
        return txtText;
    }

    public ASPxMemo DataASPXMemoDefiner(string fieldName, string controlName, ASPxGridView GV, int Index)
    {
        ASPxMemo txtText = (ASPxMemo)GV.FindRowCellTemplateControl(Index,
           (DevExpress.Web.GridViewDataColumn)GV.Columns[fieldName], controlName);
        return txtText;
    }
    public ASPxPopupControl DataASPXPopUpDefiner(string fieldName, string controlName, ASPxGridView GV, int Index)
    {
        ASPxPopupControl txtText = (ASPxPopupControl)GV.FindRowCellTemplateControl(Index,
           (DevExpress.Web.GridViewDataColumn)GV.Columns[fieldName], controlName);
        return txtText;
    }

    public HiddenField DataHiddenFieldDefiner(string fieldName, string controlName, ASPxGridView GV, int Index)
    {
        HiddenField txtText = (HiddenField)GV.FindRowCellTemplateControl(Index,
           (DevExpress.Web.GridViewDataColumn)GV.Columns[fieldName], controlName);
        return txtText;
    }

    public ASPxDateEdit DataDateEditDefiner(string fieldName, string controlName, ASPxGridView GV, int Index)
    {
        ASPxDateEdit txtText = (ASPxDateEdit)GV.FindRowCellTemplateControl(Index,
           (DevExpress.Web.GridViewDataColumn)GV.Columns[fieldName], controlName);
        return txtText;
    }
    //Preview Row Controls
    public ASPxTextBox PreviewASPXTextBoxDefiner(string controlName, ASPxGridView GV, int Index)
    {
        ASPxTextBox txtText = (ASPxTextBox)GV.FindPreviewRowTemplateControl(Index,controlName);
        return txtText;
    }

    public ASPxComboBox PreviewASPXComboDefiner(string controlName, ASPxGridView GV, int Index)
    {
        ASPxComboBox txtCombo = (ASPxComboBox)GV.FindPreviewRowTemplateControl(Index, controlName);
        return txtCombo;
    }

    public ASPxDateEdit PreviewASPXDateEditDefiner(string controlName, ASPxGridView GV, int Index)
    {
        ASPxDateEdit txtText = (ASPxDateEdit)GV.FindPreviewRowTemplateControl(Index, controlName);
        return txtText;
    }

    public ASPxLabel PreviewASPXLabelDefiner(string controlName, ASPxGridView GV, int Index)
    {
        ASPxLabel txtText = (ASPxLabel)GV.FindPreviewRowTemplateControl(Index, controlName);
        return txtText;
    }

    //Edit Form Controls
    public ASPxTextBox EditASPXTextBoxDefiner(string controlName,ASPxGridView GV)
    {
        ASPxTextBox txtText = (ASPxTextBox)GV.FindEditFormTemplateControl(controlName);
        return txtText;
    }
    public ASPxComboBox EditASPXComboBoxDefiner(string controlName, ASPxGridView GV)
    {
        ASPxComboBox txtText = (ASPxComboBox)GV.FindEditFormTemplateControl(controlName);
        return txtText;
    }
    public ASPxMemo EditASPXMemoDefiner(string controlName, ASPxGridView GV)
    {
        ASPxMemo txtText = (ASPxMemo)GV.FindEditFormTemplateControl(controlName);
        return txtText;
    }
    public ASPxLabel EditASPXLabelDefiner(string controlName, ASPxGridView GV)
    {
        ASPxLabel txtText = (ASPxLabel)GV.FindEditFormTemplateControl(controlName);
        return txtText;
    }
    public ASPxDateEdit EditASPXDateEditDefiner(string controlName, ASPxGridView GV)
    {
        ASPxDateEdit txtText = (ASPxDateEdit)GV.FindEditFormTemplateControl(controlName);
        return txtText;
    }
    public ASPxUploadControl EditASPXUploadDefiner(string controlName, ASPxGridView GV)
    {
        ASPxUploadControl txtText = (ASPxUploadControl)GV.FindEditFormTemplateControl(controlName);
        return txtText;
    }
    public HiddenField EditHidenFieldDefiner(string controlName, ASPxGridView GV)
    {
        HiddenField txtText = (HiddenField)GV.FindEditFormTemplateControl(controlName);
        return txtText;
    }

    //DataRow Controls
    public ASPxGridView DataRowASPXGridViewDefiner(string controlName, ASPxGridView GV, int index)
    {
        ASPxGridView control = (ASPxGridView)GV.FindRowTemplateControl(index, controlName);
        return control;
    }

    public static String TitleCaseString(String s)
    {
        if (s == null) return s;

        String[] words = s.Split(' ');
        for (int i = 0; i < words.Length; i++)
        {
            if (words[i].Length == 0) continue;

            Char firstChar = Char.ToUpper(words[i][0]);
            String rest = "";
            if (words[i].Length > 1)
            {
                rest = words[i].Substring(1).ToLower();
            }
            words[i] = firstChar + rest;
        }
        return String.Join(" ", words);
    }
    
}