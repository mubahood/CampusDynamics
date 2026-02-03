<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="EnrollmentAnalysis.aspx.cs" Inherits="COOPERP_NewScreens_EnrollmentAnalysis" Title="Enrollment Analysis - Campus Dynamics" %>

<%@ Register Assembly="DevExpress.Web.v16.1, Version=16.1.4.0, Culture=neutral, PublicKeyToken=b88d1754d700e49a" Namespace="DevExpress.Web" TagPrefix="dx" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style type="text/css">
        /* Enrollment Stats - Compact Cards */
        .enroll-stats-row {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
            gap: 10px;
            margin-bottom: 15px;
        }
        .enroll-stat-card {
            background: #fff;
            border: 1px solid #e0e0e0;
            padding: 15px;
            text-align: center;
        }
        .enroll-stat-card__value {
            font-size: 28px;
            font-weight: 700;
            color: #174DA4;
            line-height: 1;
        }
        .enroll-stat-card__label {
            font-size: 11px;
            color: #666;
            margin-top: 5px;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }
        .enroll-stat-card--male .enroll-stat-card__value { color: #1976d2; }
        .enroll-stat-card--female .enroll-stat-card__value { color: #d81b60; }
        .enroll-stat-card--new .enroll-stat-card__value { color: #28a745; }
        .enroll-stat-card--continuing .enroll-stat-card__value { color: #17a2b8; }
        
        /* Filter Row */
        .enroll-filter-row {
            display: flex;
            gap: 8px;
            padding: 10px 12px;
            background: #f8f9fa;
            border: 1px solid #e0e0e0;
            margin-bottom: 15px;
            flex-wrap: wrap;
            align-items: center;
        }
        .enroll-filter-select {
            border: 1px solid #ddd;
            padding: 4px 6px;
            font-size: 11px;
            min-width: 120px;
            background: #fff;
        }
        .enroll-filter-select:focus {
            border-color: #174DA4;
            outline: none;
        }
        
        /* Chart Cards */
        .enroll-charts-row {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(400px, 1fr));
            gap: 15px;
            margin-bottom: 15px;
        }
        .enroll-chart-card {
            background: #fff;
            border: 1px solid #e0e0e0;
        }
        .enroll-chart-card__header {
            padding: 10px 15px;
            border-bottom: 1px solid #e0e0e0;
            font-size: 12px;
            font-weight: 600;
            color: #333;
        }
        .enroll-chart-card__body {
            padding: 15px;
            min-height: 250px;
        }
        
        /* Data Tables */
        .enroll-table-card {
            background: #fff;
            border: 1px solid #e0e0e0;
            margin-bottom: 15px;
        }
        .enroll-table-card__header {
            padding: 10px 15px;
            border-bottom: 1px solid #e0e0e0;
            font-size: 12px;
            font-weight: 600;
            color: #333;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .enroll-table-card__body {
            padding: 0;
        }
        
        /* Grid Styling */
        .enroll-grid .dxgvHeader td {
            background: #f8f9fa !important;
            font-size: 10px !important;
            font-weight: 600 !important;
            text-transform: uppercase !important;
            padding: 8px 6px !important;
            color: #495057 !important;
        }
        .enroll-grid .dxgvDataRow td {
            font-size: 11px !important;
            padding: 6px !important;
        }
        .enroll-grid .dxgvDataRow:hover td {
            background: #f8f9fa !important;
        }
        
        /* Trend Indicator */
        .enroll-trend {
            display: inline-flex;
            align-items: center;
            gap: 3px;
            font-size: 10px;
            font-weight: 600;
        }
        .enroll-trend--up { color: #28a745; }
        .enroll-trend--down { color: #dc3545; }
        .enroll-trend--neutral { color: #6c757d; }
        
        /* Summary Table */
        .enroll-summary-table {
            width: 100%;
            border-collapse: collapse;
        }
        .enroll-summary-table th,
        .enroll-summary-table td {
            padding: 8px 12px;
            text-align: left;
            border-bottom: 1px solid #e0e0e0;
            font-size: 11px;
        }
        .enroll-summary-table th {
            background: #f8f9fa;
            font-weight: 600;
            text-transform: uppercase;
            font-size: 10px;
            color: #495057;
        }
        .enroll-summary-table tr:hover td {
            background: #f8f9fa;
        }
        .enroll-summary-table td.value {
            text-align: right;
            font-weight: 600;
            color: #174DA4;
        }
        
        /* Print Styles */
        @media print {
            .enroll-filter-row { display: none; }
        }
    </style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <!-- Top Stats Cards -->
    <div class="enroll-stats-row">
        <div class="enroll-stat-card">
            <div class="enroll-stat-card__value"><asp:Literal ID="litTotalStudents" runat="server" Text="0" /></div>
            <div class="enroll-stat-card__label">Total Enrolled</div>
        </div>
        <div class="enroll-stat-card enroll-stat-card--male">
            <div class="enroll-stat-card__value"><asp:Literal ID="litMale" runat="server" Text="0" /></div>
            <div class="enroll-stat-card__label">Male Students</div>
        </div>
        <div class="enroll-stat-card enroll-stat-card--female">
            <div class="enroll-stat-card__value"><asp:Literal ID="litFemale" runat="server" Text="0" /></div>
            <div class="enroll-stat-card__label">Female Students</div>
        </div>
        <div class="enroll-stat-card enroll-stat-card--new">
            <div class="enroll-stat-card__value"><asp:Literal ID="litNewStudents" runat="server" Text="0" /></div>
            <div class="enroll-stat-card__label">New This Year</div>
        </div>
        <div class="enroll-stat-card enroll-stat-card--continuing">
            <div class="enroll-stat-card__value"><asp:Literal ID="litProgrammes" runat="server" Text="0" /></div>
            <div class="enroll-stat-card__label">Active Programmes</div>
        </div>
    </div>
    
    <!-- Filter Row -->
    <div class="enroll-filter-row">
        <span style="font-size: 11px; font-weight: 500; color: #666;">Filter by:</span>
        <asp:DropDownList ID="ddlEntryYear" runat="server" CssClass="enroll-filter-select" AutoPostBack="true" OnSelectedIndexChanged="ddlEntryYear_SelectedIndexChanged">
            <asp:ListItem Value="" Text="-- All Years --"></asp:ListItem>
        </asp:DropDownList>
        <asp:DropDownList ID="ddlFaculty" runat="server" CssClass="enroll-filter-select" AutoPostBack="true" OnSelectedIndexChanged="ddlFaculty_SelectedIndexChanged" style="min-width: 180px;">
            <asp:ListItem Value="" Text="-- All Faculties --"></asp:ListItem>
        </asp:DropDownList>
        <asp:DropDownList ID="ddlProgramme" runat="server" CssClass="enroll-filter-select" AutoPostBack="true" OnSelectedIndexChanged="ddlProgramme_SelectedIndexChanged" style="min-width: 200px;">
            <asp:ListItem Value="" Text="-- All Programmes --"></asp:ListItem>
        </asp:DropDownList>
        <asp:Button ID="btnExport" runat="server" Text="Export Report" CssClass="cd-btn cd-btn--primary cd-btn--sm" OnClick="btnExport_Click" style="margin-left: auto;" />
    </div>
    
    <!-- Charts Row -->
    <div class="enroll-charts-row">
        <div class="enroll-chart-card">
            <div class="enroll-chart-card__header">Enrollment Trend by Year</div>
            <div class="enroll-chart-card__body">
                <canvas id="chartEnrollmentTrend"></canvas>
            </div>
        </div>
        <div class="enroll-chart-card">
            <div class="enroll-chart-card__header">Gender Distribution</div>
            <div class="enroll-chart-card__body">
                <canvas id="chartGender"></canvas>
            </div>
        </div>
    </div>
    
    <!-- Enrollment by Year Table -->
    <div class="enroll-table-card">
        <div class="enroll-table-card__header">
            <span>Enrollment by Entry Year</span>
        </div>
        <div class="enroll-table-card__body">
            <table class="enroll-summary-table">
                <thead>
                    <tr>
                        <th>Entry Year</th>
                        <th style="text-align: right;">Male</th>
                        <th style="text-align: right;">Female</th>
                        <th style="text-align: right;">Total</th>
                        <th style="text-align: right;">% of Total</th>
                    </tr>
                </thead>
                <tbody>
                    <asp:Repeater ID="rptEnrollmentByYear" runat="server">
                        <ItemTemplate>
                            <tr>
                                <td><%# Eval("entryyear") %></td>
                                <td class="value"><%# Eval("male_count") %></td>
                                <td class="value"><%# Eval("female_count") %></td>
                                <td class="value"><%# Eval("total") %></td>
                                <td class="value"><%# Eval("percentage", "{0:F1}%") %></td>
                            </tr>
                        </ItemTemplate>
                    </asp:Repeater>
                </tbody>
            </table>
        </div>
    </div>
    
    <!-- Enrollment by Programme Table -->
    <div class="enroll-table-card">
        <div class="enroll-table-card__header">
            <span>Enrollment by Programme (Top 15)</span>
        </div>
        <div class="enroll-table-card__body">
            <dx:ASPxGridView ID="gvProgrammeEnrollment" runat="server" AutoGenerateColumns="False" 
                KeyFieldName="progid" Width="100%" CssClass="enroll-grid">
                <SettingsPager PageSize="15" AlwaysShowPager="true" Position="Bottom" />
                <Settings ShowFilterRow="false" ShowGroupPanel="false" />
                <Styles>
                    <Header Font-Size="10px" Font-Bold="true" BackColor="#f8f9fa" ForeColor="#495057" />
                    <Row Font-Size="11px" />
                    <AlternatingRow Enabled="true" BackColor="#fafbfc" />
                </Styles>
                <Columns>
                    <dx:GridViewDataTextColumn FieldName="progid" Caption="Code" Width="80px" />
                    <dx:GridViewDataTextColumn FieldName="progname" Caption="Programme Name" Width="250px" />
                    <dx:GridViewDataTextColumn FieldName="male_count" Caption="Male" Width="80px">
                        <HeaderStyle HorizontalAlign="Right" />
                        <CellStyle HorizontalAlign="Right" />
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="female_count" Caption="Female" Width="80px">
                        <HeaderStyle HorizontalAlign="Right" />
                        <CellStyle HorizontalAlign="Right" />
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="total" Caption="Total" Width="80px">
                        <HeaderStyle HorizontalAlign="Right" />
                        <CellStyle HorizontalAlign="Right" Font-Bold="true" />
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="percentage" Caption="%" Width="60px">
                        <HeaderStyle HorizontalAlign="Right" />
                        <CellStyle HorizontalAlign="Right" />
                        <DataItemTemplate>
                            <%# Eval("percentage", "{0:F1}%") %>
                        </DataItemTemplate>
                    </dx:GridViewDataTextColumn>
                </Columns>
            </dx:ASPxGridView>
            <dx:ASPxGridViewExporter ID="gveProgrammeEnrollment" runat="server" GridViewID="gvProgrammeEnrollment" ExportedRowType="All">
            </dx:ASPxGridViewExporter>
        </div>
    </div>
    
    <!-- Hidden fields for chart data -->
    <asp:HiddenField ID="hfYearLabels" runat="server" />
    <asp:HiddenField ID="hfYearData" runat="server" />
    <asp:HiddenField ID="hfMaleCount" runat="server" />
    <asp:HiddenField ID="hfFemaleCount" runat="server" />
    
    <script type="text/javascript">
        document.addEventListener('DOMContentLoaded', function() {
            // Enrollment Trend Chart
            var yearLabels = document.getElementById('<%= hfYearLabels.ClientID %>').value;
            var yearData = document.getElementById('<%= hfYearData.ClientID %>').value;
            
            if (yearLabels && yearData) {
                var labels = yearLabels.split(',');
                var data = yearData.split(',').map(Number);
                
                var ctxTrend = document.getElementById('chartEnrollmentTrend').getContext('2d');
                new Chart(ctxTrend, {
                    type: 'bar',
                    data: {
                        labels: labels,
                        datasets: [{
                            label: 'Students',
                            data: data,
                            backgroundColor: '#174DA4',
                            borderColor: '#174DA4',
                            borderWidth: 0
                        }]
                    },
                    options: {
                        responsive: true,
                        maintainAspectRatio: false,
                        plugins: {
                            legend: { display: false }
                        },
                        scales: {
                            y: { 
                                beginAtZero: true,
                                grid: { color: '#f0f0f0' }
                            },
                            x: {
                                grid: { display: false }
                            }
                        }
                    }
                });
            }
            
            // Gender Distribution Chart
            var maleCount = parseInt(document.getElementById('<%= hfMaleCount.ClientID %>').value) || 0;
            var femaleCount = parseInt(document.getElementById('<%= hfFemaleCount.ClientID %>').value) || 0;
            
            if (maleCount > 0 || femaleCount > 0) {
                var ctxGender = document.getElementById('chartGender').getContext('2d');
                new Chart(ctxGender, {
                    type: 'doughnut',
                    data: {
                        labels: ['Male', 'Female'],
                        datasets: [{
                            data: [maleCount, femaleCount],
                            backgroundColor: ['#1976d2', '#d81b60'],
                            borderWidth: 0
                        }]
                    },
                    options: {
                        responsive: true,
                        maintainAspectRatio: false,
                        plugins: {
                            legend: { 
                                position: 'bottom',
                                labels: { font: { size: 11 } }
                            }
                        },
                        cutout: '60%'
                    }
                });
            }
        });
    </script>
</asp:Content>
