<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="NCHEStudentExporter.aspx.cs" Inherits="COOPERP_NewScreens_NCHEStudentExporter" Title="NCHE Student Data Exporter" %>

<%@ Register Assembly="DevExpress.Web.v16.1, Version=16.1.4.0, Culture=neutral, PublicKeyToken=b88d1754d700e49a" Namespace="DevExpress.Web" TagPrefix="dx" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <style type="text/css">
        .nche-exporter-container {
            max-width: 900px;
            margin: 0 auto;
            padding: 20px;
        }
        
        .nche-header {
            background: linear-gradient(135deg, #1f4e79 0%, #285a8f 100%);
            color: white;
            padding: 20px;
            border-radius: 4px;
            margin-bottom: 20px;
        }
        
        .nche-header h1 {
            margin: 0;
            font-size: 28px;
        }
        
        .nche-header .subtitle {
            font-size: 13px;
            opacity: 0.9;
            margin-top: 5px;
        }
        
        .nche-criteria {
            background: #f8f9fa;
            border: 1px solid #dee2e6;
            border-radius: 4px;
            padding: 20px;
            margin-bottom: 20px;
        }
        
        .criteria-row {
            display: flex;
            gap: 20px;
            margin-bottom: 15px;
            align-items: flex-end;
        }
        
        .criteria-field {
            flex: 1;
            min-width: 200px;
        }
        
        .criteria-field label {
            display: block;
            font-weight: 600;
            margin-bottom: 5px;
            color: #333;
            font-size: 13px;
        }
        
        .nche-actions {
            display: flex;
            gap: 10px;
            margin-top: 20px;
            padding-top: 15px;
            border-top: 1px solid #dee2e6;
        }
        
        .preview-section {
            background: white;
            border: 1px solid #dee2e6;
            border-radius: 4px;
            padding: 20px;
            margin-bottom: 20px;
        }
        
        .preview-title {
            font-size: 16px;
            font-weight: 600;
            color: #333;
            margin-bottom: 10px;
        }
        
        .preview-grid {
            border: 1px solid #dee2e6;
            border-radius: 4px;
        }
        
        .summary-box {
            background: #e7f3ff;
            border-left: 4px solid #1f4e79;
            padding: 15px;
            border-radius: 3px;
            margin-top: 15px;
        }
        
        .summary-box .count {
            font-size: 18px;
            font-weight: bold;
            color: #1f4e79;
        }
        
        .export-format {
            display: flex;
            gap: 10px;
            align-items: center;
            margin: 10px 0;
        }
        
        .nche-info {
            background: #fff3cd;
            border: 1px solid #ffc107;
            border-radius: 4px;
            padding: 12px;
            margin-bottom: 15px;
            font-size: 12px;
            color: #856404;
        }
        
        .nche-info strong {
            display: block;
            margin-bottom: 5px;
        }
    </style>
</asp:Content>

<asp:Content ID="BodyContent" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    
    <div class="nche-exporter-container">
        
        <div class="nche-header">
            <h1>NCHE Student Data Exporter</h1>
            <div class="subtitle">Export student information in the format required by the National Council for Higher Education (NCHE)</div>
        </div>
        
        <div class="nche-info">
            <strong>NCHE Requirement:</strong>
            Ref: NCHE/GR/U/78 (9th February 2026) - Please ensure compliance and accurate data entry. Deadline: 25th February 2026.
        </div>
        
        <!-- Filtering Criteria -->
        <div class="nche-criteria">
            <div style="font-size: 16px; font-weight: 600; margin-bottom: 15px; color: #333;">Filter Criteria</div>
            
            <div class="criteria-row">
                <div class="criteria-field">
                    <label>Entry Year:</label>
                    <dx:ASPxComboBox ID="ddlAcademicYear" runat="server" Width="100%" 
                        NullText="-- All Years --"
                        ValueType="System.String">
                    </dx:ASPxComboBox>
                </div>
                
                <div class="criteria-field">
                    <label>Status:</label>
                    <dx:ASPxComboBox ID="ddlStatus" runat="server" Width="100%"
                        NullText="-- All Statuses --"
                        ValueType="System.String">
                        <Items>
                            <dx:ListEditItem Text="Active" Value="ACTIVE" />
                            <dx:ListEditItem Text="Admitted" Value="ADMITTED" />
                            <dx:ListEditItem Text="Graduated" Value="GRADUATED" />
                            <dx:ListEditItem Text="Alumni" Value="ALUMNI" />
                        </Items>
                    </dx:ASPxComboBox>
                </div>
            </div>
            
            <div class="criteria-row">
                <div class="criteria-field">
                    <label>Programme:</label>
                    <dx:ASPxComboBox ID="ddlProgramme" runat="server" Width="100%"
                        NullText="-- All Programmes --"
                        ValueType="System.String">
                    </dx:ASPxComboBox>
                </div>
                
            </div>
            
            <div class="criteria-row">
                <div class="criteria-field">
                    <label>Study Centre/Campus:</label>
                    <dx:ASPxComboBox ID="ddlStudyCentre" runat="server" Width="100%"
                        NullText="-- All Centres --"
                        ValueType="System.String">
                    </dx:ASPxComboBox>
                </div>
                
                <div class="criteria-field">
                    <label>Year of Study:</label>
                    <dx:ASPxComboBox ID="ddlYearOfStudy" runat="server" Width="100%"
                        NullText="-- All Years --"
                        ValueType="System.String">
                        <Items>
                            <dx:ListEditItem Text="Year 1" Value="1" />
                            <dx:ListEditItem Text="Year 2" Value="2" />
                            <dx:ListEditItem Text="Year 3" Value="3" />
                            <dx:ListEditItem Text="Year 4" Value="4" />
                            <dx:ListEditItem Text="Year 5" Value="5" />
                        </Items>
                    </dx:ASPxComboBox>
                </div>
            </div>
            
            <div class="nche-actions">
                <dx:ASPxButton ID="btnPreview" runat="server" Text="Preview Data" 
                    OnClick="BtnPreview_Click"
                    Image-IconID="preview_16x16"
                    CausesValidation="false">
                </dx:ASPxButton>
                
                <dx:ASPxButton ID="btnExportCSV" runat="server" Text="Export as CSV" 
                    OnClick="BtnExportCSV_Click"
                    Image-IconID="export_16x16"
                    CausesValidation="false">
                </dx:ASPxButton>
                
                <dx:ASPxButton ID="btnExportExcel" runat="server" Text="Export as Excel" 
                    OnClick="BtnExportExcel_Click"
                    Image-IconID="export_16x16"
                    CausesValidation="false">
                </dx:ASPxButton>
                
                <dx:ASPxButton ID="btnClear" runat="server" Text="Clear Filters" 
                    OnClick="BtnClear_Click"
                    Image-IconID="delete_16x16"
                    CausesValidation="false"
                    Style="margin-left: auto;">
                </dx:ASPxButton>
            </div>
        </div>
        
        <!-- Preview Section -->
        <div class="preview-section" id="previewSection" runat="server" style="display: none;">
            <div class="preview-title">Data Preview</div>
            
            <div class="summary-box">
                <div>Total Records to Export:  <span class="count" id="totalCount" runat="server">0</span></div>
            </div>
            
            <dx:ASPxGridView ID="gvPreview" runat="server" Width="100%" 
                AutoGenerateColumns="False"
                KeyFieldName="id"
                Settings-ShowFooter="true"
                SettingsPager-PageSize="10">
                <Columns>
                    <dx:GridViewDataTextColumn FieldName="sn" Caption="S/N" Width="40" />
                    <dx:GridViewDataTextColumn FieldName="names" Caption="Full Names" MinWidth="150" />
                    <dx:GridViewDataTextColumn FieldName="sex" Caption="Sex" Width="50" />
                    <dx:GridViewDataTextColumn FieldName="national_id" Caption="National ID No." Width="120" />
                    <dx:GridViewDataTextColumn FieldName="reg_no" Caption="Institutional Reg. NO" Width="120" />
                    <dx:GridViewDataTextColumn FieldName="prog_code" Caption="Prog. Code" Width="80" />
                    <dx:GridViewDataTextColumn FieldName="prog_name" Caption="Programme Name" MinWidth="150" />
                    <dx:GridViewDataTextColumn FieldName="award_level" Caption="Award Level" Width="100" />
                    <dx:GridViewDataTextColumn FieldName="year_study" Caption="Year of Study" Width="100" />
                    <dx:GridViewDataTextColumn FieldName="study_centre" Caption="Study Centre" Width="100" />
                </Columns>
                <Settings HorizontalScrollBarMode="Auto" />
            </dx:ASPxGridView>
        </div>
        
    </div>

</asp:Content>
