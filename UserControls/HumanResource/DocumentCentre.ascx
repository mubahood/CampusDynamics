<%@ Control Language="C#" AutoEventWireup="true" CodeFile="DocumentCentre.ascx.cs" Inherits="UserControls_HumanResource_DocumentCentre" %>
<style type="text/css">
    .style1_docs
    {
        width: 50px;
    }
    .style2
    {
        width: 120px;
    }



*
{ 
    /*padding: 0;*/
    margin-left: 0;
    margin-top: 0;
    margin-bottom: 0;
    
}


    </style>

<dx:ASPxRoundPanel ID="ASPxRoundPanel1" runat="server" 
    HeaderText="Payroll Document Centre" ShowCollapseButton="true" 
    ShowHeader="False" Width="100%">
    <PanelCollection>
<dx:PanelContent runat="server">
    <table width="100%">
        <tr>
            <td class="style1_docs">
                &nbsp;</td>
            <td class="style2">
                &nbsp;</td>
            <td>
                &nbsp;</td>
        </tr>
        <tr>
            <td class="style1_docs">
                &nbsp;</td>
            <td class="style2">
                Document Name:</td>
            <td>
                <dx:ASPxComboBox ID="txtDoc" runat="server" SelectedIndex="0">
                    <Items>
                        <dx:ListEditItem Selected="True" Text="Main Payroll" Value="MainPayroll" />
                        <dx:ListEditItem Text="Main Payroll By Branch" Value="MainPayrollBranch" />
                        <dx:ListEditItem Text="PAYE Schedule" Value="PAYE" />
                        <dx:ListEditItem Text="NSSF Schedule" Value="NSSF" />
                        <dx:ListEditItem Text="Bank Schedule" Value="BankSchedule" />
                        <dx:ListEditItem Text="Allowance &amp; Deductions" Value="AllDed" />
                    </Items>
                </dx:ASPxComboBox>
            </td>
        </tr>
        <tr>
            <td class="style1_docs">
                &nbsp;</td>
            <td class="style2">
                &nbsp;</td>
            <td>
                <dx:ASPxButton ID="cmdPrint" runat="server" OnClick="cmdPrint_Click" 
                    Text="Print" Width="170px">
                    <Image Url="~/COOPERP/images/printer.png">
                    </Image>
                </dx:ASPxButton>
            </td>
        </tr>
        <tr>
            <td class="style1_docs">
                &nbsp;</td>
            <td class="style2">
                &nbsp;</td>
            <td>
                &nbsp;</td>
        </tr>
    </table>
        </dx:PanelContent>
</PanelCollection>
</dx:ASPxRoundPanel>
                <dx:ASPxPopupControl runat="server" 
    PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter" 
    Modal="True" HeaderText="" ID="pop_details">
<ClientSideEvents CloseUp="function(s, e) {
	gvPayroll.Refresh();
}"></ClientSideEvents>
<ContentCollection>
<dx:PopupControlContentControl runat="server">
                        </dx:PopupControlContentControl>
</ContentCollection>
</dx:ASPxPopupControl>

            
