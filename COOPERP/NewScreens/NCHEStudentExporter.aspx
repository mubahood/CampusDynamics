<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="NCHEStudentExporter.aspx.cs" Inherits="COOPERP_NewScreens_NCHEStudentExporter" Title="NCHE Student Data Exporter" %>

<%@ Register Assembly="DevExpress.Web.v16.1, Version=16.1.4.0, Culture=neutral, PublicKeyToken=b88d1754d700e49a" Namespace="DevExpress.Web" TagPrefix="dx" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <style type="text/css">
        * {
            box-sizing: border-box;
        }

        .nche-exporter-container {
            max-width: 1400px;
            margin: 0 auto;
            padding: 20px 15px;
            width: 100%;
        }
        
        .nche-header {
            background: linear-gradient(135deg, #1f4e79 0%, #2d5fa3 50%, #1a3f63 100%);
            color: white;
            padding: 25px 25px;
            margin-bottom: 20px;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.12);
            position: relative;
            overflow: hidden;
        }
        
        .nche-header::before {
            content: '';
            position: absolute;
            top: -50%;
            right: -10%;
            width: 300px;
            height: 300px;
            background: rgba(255, 255, 255, 0.03);
            border-radius: 50%;
        }
        
        .nche-header h1 {
            margin: 0;
            font-size: 28px;
            font-weight: 700;
            letter-spacing: -0.3px;
            position: relative;
            z-index: 1;
        }
        
        .nche-header .subtitle {
            font-size: 13px;
            opacity: 0.92;
            margin-top: 6px;
            position: relative;
            z-index: 1;
            line-height: 1.4;
        }
        
        .nche-criteria {
            background: #fff;
            border: 1px solid #ddd;
            padding: 20px;
            margin-bottom: 20px;
            box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);
        }
        
        .nche-criteria > div:first-of-type {
            font-size: 15px;
            font-weight: 600;
            color: #1f4e79;
            margin-bottom: 15px;
        }
        
        .criteria-row {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 15px;
            margin-bottom: 12px;
        }
        
        .criteria-field {
            display: flex;
            flex-direction: column;
        }
        
        .criteria-field label {
            display: block;
            font-weight: 600;
            margin-bottom: 5px;
            color: #2c3e50;
            font-size: 13px;
        }
        
        .criteria-field input,
        .criteria-field select {
            padding: 8px 10px;
            border: 1px solid #ccc;
            font-size: 13px;
            transition: all 0.2s ease;
        }
        
        .criteria-field input:focus,
        .criteria-field select:focus {
            outline: none;
            border-color: #1f4e79;
            box-shadow: 0 0 0 2px rgba(31, 78, 121, 0.08);
        }
        
        .nche-actions {
            display: flex;
            flex-wrap: wrap;
            gap: 8px;
            margin-top: 15px;
            padding-top: 15px;
            border-top: 1px solid #ddd;
            align-items: center;
        }
        
        .preview-section {
            background: #fff;
            border: 1px solid #ddd;
            padding: 20px;
            margin-bottom: 20px;
            box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);
        }
        
        .preview-title {
            font-size: 16px;
            font-weight: 600;
            color: #1f4e79;
            margin-bottom: 15px;
        }
        
        .preview-grid {
            border: 1px solid #ddd;
            overflow: hidden;
        }
        
        .summary-box {
            background: #f0f7ff;
            border-left: 4px solid #1f4e79;
            padding: 14px 16px;
            margin-bottom: 15px;
        }
        
        .summary-box div {
            font-size: 14px;
            color: #2c3e50;
            font-weight: 500;
        }
        
        .summary-box .count {
            font-size: 22px;
            font-weight: 700;
            color: #1f4e79;
            display: inline-block;
            margin: 0 8px;
        }
        
        .nche-info {
            background: #fffaf0;
            border-left: 4px solid #ffc107;
            padding: 12px 14px;
            margin-bottom: 18px;
            font-size: 12px;
            color: #7d6608;
            box-shadow: 0 1px 2px rgba(0, 0, 0, 0.03);
        }
        
        .nche-info strong {
            display: block;
            margin-bottom: 4px;
            font-weight: 600;
            color: #d48806;
        }
        
        /* Button Styling */
        .dx-btn {
            padding: 8px 16px !important;
            font-weight: 600 !important;
            font-size: 13px !important;
            transition: all 0.2s ease !important;
            border: none !important;
        }
        
        /* Grid Styling */
        .dx-grid {
            font-size: 13px !important;
        }
        
        .dx-grid-header {
            background: #f5f5f5 !important;
            font-weight: 600 !important;
        }
        
        /* Responsive Design */
        @media (max-width: 768px) {
            .nche-exporter-container {
                padding: 15px 12px;
            }
            
            .nche-header {
                padding: 20px 18px;
            }
            
            .nche-header h1 {
                font-size: 24px;
            }
            
            .nche-criteria {
                padding: 16px;
            }
            
            .preview-section {
                padding: 16px;
            }
            
            .criteria-row {
                grid-template-columns: 1fr;
                gap: 10px;
            }
            
            .nche-actions {
                flex-direction: column;
                gap: 6px;
            }
            
            .nche-actions .dx-btn {
                width: 100%;
            }
        }
        
        @media (max-width: 480px) {
            .nche-exporter-container {
                padding: 12px 10px;
            }
            
            .nche-header {
                padding: 16px 14px;
            }
            
            .nche-header h1 {
                font-size: 20px;
            }
            
            .nche-header .subtitle {
                font-size: 12px;
            }
            
            .preview-title {
                font-size: 14px;
            }
            
            .summary-box .count {
                font-size: 20px;
            }
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
            <div>Filter Criteria</div>
            
            <div class="criteria-row">
                <div class="criteria-field">
                    <label>Entry Year:</label>
                    <dx:ASPxComboBox ID="ddlAcademicYear" runat="server" Width="100%" 
                        NullText="-- All Years --"
                        ValueType="System.String">
                    </dx:ASPxComboBox>
                </div>
                
                <div class="criteria-field">
                    <label>Programme:</label>
                    <dx:ASPxComboBox ID="ddlProgramme" runat="server" Width="100%"
                        NullText="-- All Programmes --"
                        ValueType="System.String">
                    </dx:ASPxComboBox>
                </div>
                
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
                    CausesValidation="false">
                </dx:ASPxButton>
                
                <dx:ASPxButton ID="btnExportCSV" runat="server" Text="Export as CSV" 
                    OnClick="BtnExportCSV_Click"
                    CausesValidation="false">
                </dx:ASPxButton>
                
                <dx:ASPxButton ID="btnExportExcel" runat="server" Text="Export as Excel" 
                    OnClick="BtnExportExcel_Click"
                    CausesValidation="false">
                </dx:ASPxButton>
                
                <dx:ASPxButton ID="btnClear" runat="server" Text="Clear Filters" 
                    OnClick="BtnClear_Click"
                    CausesValidation="false"
                    Style="margin-left: auto;">
                </dx:ASPxButton>
            </div>
        </div>
        
        <!-- Preview Section -->
        <div class="preview-section" id="previewSection" runat="server" style="display: none;">
            <div class="preview-title">Data Preview</div>
            
            <div class="summary-box">
                <div>Total Records to Export: <span class="count" id="totalCount" runat="server">0</span> students</div>
            </div>
            
            <div class="preview-grid">
                <dx:ASPxGridView ID="gvPreview" runat="server" Width="100%" 
                    AutoGenerateColumns="False"
                    KeyFieldName="reg_no"
                    Settings-ShowFooter="true"
                    SettingsPager-PageSize="15">
                    <Columns>
                        <dx:GridViewDataTextColumn FieldName="sn" Caption="S/N" Width="50" />
                        <dx:GridViewDataTextColumn FieldName="names" Caption="Full Names" MinWidth="180" />
                        <dx:GridViewDataTextColumn FieldName="gender" Caption="Sex" Width="60" />
                        <dx:GridViewDataTextColumn FieldName="national_id" Caption="National ID" MinWidth="130" />
                        <dx:GridViewDataTextColumn FieldName="reg_no" Caption="Reg. NO" MinWidth="130" />
                        <dx:GridViewDataTextColumn FieldName="progcode" Caption="Prog. Code" Width="90" />
                        <dx:GridViewDataTextColumn FieldName="progname" Caption="Programme" MinWidth="150" />
                        <dx:GridViewDataTextColumn FieldName="award_level" Caption="Award" Width="80" />
                        <dx:GridViewDataTextColumn FieldName="year_study" Caption="Year" Width="60" />
                        <dx:GridViewDataTextColumn FieldName="study_centre" Caption="Campus" MinWidth="120" />
                    </Columns>
                    <Settings HorizontalScrollBarMode="Auto" />
                </dx:ASPxGridView>
            </div>
        </div>
        
    </div>

</asp:Content>
