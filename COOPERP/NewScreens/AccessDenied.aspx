<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="AccessDenied.aspx.cs" Inherits="COOPERP_NewScreens_AccessDenied" Title="Access Denied - Campus Dynamics" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
<style>
.ad-wrap {
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    min-height: 60vh;
    text-align: center;
    padding: 48px 24px;
}
.ad-icon {
    width: 72px;
    height: 72px;
    background: #fef2f2;
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    margin: 0 auto 24px;
}
.ad-icon svg { color: #dc2626; }
.ad-code {
    font-size: 72px;
    font-weight: 700;
    color: #e0e5ed;
    line-height: 1;
    margin-bottom: 8px;
}
.ad-title {
    font-size: 22px;
    font-weight: 600;
    color: #1a1a2e;
    margin-bottom: 12px;
}
.ad-message {
    font-size: 13px;
    color: #64748b;
    max-width: 420px;
    line-height: 1.6;
    margin-bottom: 32px;
}
.ad-slug {
    display: inline-block;
    font-family: monospace;
    font-size: 11px;
    background: #f1f5f9;
    border: 1px solid #e0e5ed;
    border-radius: 4px;
    padding: 4px 10px;
    color: #64748b;
    margin-bottom: 32px;
}
.ad-actions { display: flex; gap: 12px; justify-content: center; flex-wrap: wrap; }
.ad-btn {
    display: inline-flex;
    align-items: center;
    gap: 6px;
    padding: 9px 20px;
    border-radius: 0;
    font-size: 12px;
    font-weight: 600;
    text-decoration: none;
    cursor: pointer;
    border: none;
}
.ad-btn--primary { background: #05275C; color: #fff; }
.ad-btn--primary:hover { background: #174DA4; color: #fff; }
.ad-btn--secondary { background: #f1f5f9; color: #374151; border: 1px solid #e0e5ed; }
.ad-btn--secondary:hover { background: #e0e5ed; color: #1a1a2e; }
</style>
</asp:Content>

<asp:Content ID="BodyContent" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
<div class="ad-wrap">

    <div class="ad-icon">
        <svg xmlns="http://www.w3.org/2000/svg" width="36" height="36" viewBox="0 0 24 24"
             fill="none" stroke="currentColor" stroke-width="2"
             stroke-linecap="round" stroke-linejoin="round">
            <rect x="3" y="11" width="18" height="11" rx="2" ry="2"/>
            <path d="M7 11V7a5 5 0 0 1 10 0v4"/>
        </svg>
    </div>

    <div class="ad-code">403</div>
    <div class="ad-title">Access Denied</div>
    <div class="ad-message">
        You don't have permission to view this page. If you believe this is an error,
        please contact your system administrator to request access.
    </div>

    <asp:Literal ID="litSlug" runat="server"></asp:Literal>

    <div class="ad-actions">
        <a href="~/COOPERP/NewScreens/NewDashboard.aspx" class="ad-btn ad-btn--primary">
            <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24"
                 fill="none" stroke="currentColor" stroke-width="2"
                 stroke-linecap="round" stroke-linejoin="round">
                <rect x="3" y="3" width="7" height="9"/><rect x="14" y="3" width="7" height="5"/>
                <rect x="14" y="12" width="7" height="9"/><rect x="3" y="16" width="7" height="5"/>
            </svg>
            Go to Dashboard
        </a>
        <a href="javascript:history.back()" class="ad-btn ad-btn--secondary">
            <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24"
                 fill="none" stroke="currentColor" stroke-width="2"
                 stroke-linecap="round" stroke-linejoin="round">
                <polyline points="15 18 9 12 15 6"/>
            </svg>
            Go Back
        </a>
    </div>

</div>
</asp:Content>
