<%@ Page Language="C#" AutoEventWireup="true" CodeFile="ApplicantDetails.aspx.cs" Inherits="COOPERP_Admissions_ApplicantDetails" %>
<%@ Register src="../../UserControls/Admissions/ApplicantChoices.ascx" tagname="ApplicantChoices" tagprefix="uc4" %>
<%@ Register src="../../UserControls/Admissions/ApplicantResults.ascx" tagname="ApplicantResults" tagprefix="uc5" %>
<%@ Register src="../../UserControls/Admissions/ApplicantQualifications.ascx" tagname="ApplicantQualifications" tagprefix="uc6" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
    <div>
    <dx:ASPxRoundPanel ID="ASPxRoundPanel2" runat="server" HeaderText="" 
                                            ShowHeader="False" Width="100%">
                                            <PanelCollection>
                                                <dx:PanelContent ID="PanelContent1" runat="server">
                                                    <table width="100%">
                                                        <tr>
                                                            <td align="center">
                                                                <dx:ASPxLabel ID="lblheader" runat="server" Font-Size="17px" ForeColor="Red">
                                                                </dx:ASPxLabel>
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td valign="top">
                                                                <asp:Image ID="Image3" runat="server" Height="1px" 
                                                                    ImageUrl="~/COOPERP/images/hor_line.png" Width="100%" />
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td>
                                                                <dx:ASPxPageControl ID="ASPxPageControl1" runat="server" ActiveTabIndex="0" 
                                                                    Width="100%">
                                                                    <TabPages>
                                                                        <dx:TabPage Text="Choices">
                                                                            <ContentCollection>
                                                                                <dx:ContentControl ID="ContentControl1" runat="server">
                                                                                    
                                                                                    <uc4:ApplicantChoices ID="ApplicantChoices2" runat="server" />
                                                                                    
                                                                                </dx:ContentControl>
                                                                            </ContentCollection>
                                                                        </dx:TabPage>
                                                                        <dx:TabPage Text="Applicant Results">
                                                                            <ContentCollection>
                                                                                <dx:ContentControl ID="ContentControl2" runat="server">
                                                                                    <uc5:ApplicantResults ID="ApplicantResults2" runat="server" />
                                                                                </dx:ContentControl>
                                                                            </ContentCollection>
                                                                        </dx:TabPage>
                                                                        <dx:TabPage Text="Other Qualifications">
                                                                            <ContentCollection>
                                                                                <dx:ContentControl ID="ContentControl3" runat="server">
                                                                                    <uc6:ApplicantQualifications ID="ApplicantQualifications2" runat="server" />
                                                                                </dx:ContentControl>
                                                                            </ContentCollection>
                                                                        </dx:TabPage>
                                                                    </TabPages>
                                                                </dx:ASPxPageControl>
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </dx:PanelContent>
                                            </PanelCollection>
                                        </dx:ASPxRoundPanel>
    </div>
    </form>
</body>
</html>
