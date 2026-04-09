<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="NewStudentInfo.aspx.cs" Inherits="COOPERP_NewScreens_NewStudentInfo" Title="Student Records - Campus Dynamics" %>

<%@ Register Assembly="DevExpress.Web.v16.1, Version=16.1.4.0, Culture=neutral, PublicKeyToken=b88d1754d700e49a" Namespace="DevExpress.Web" TagPrefix="dx" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <style type="text/css">
        /* Student thumbnail in grid */
        .cd-student-thumb {
            width: 32px;
            height: 32px;
            object-fit: cover;
            border: 1px solid #ddd;
            background: #f5f5f5;
            cursor: pointer;
            transition: transform 0.15s ease, box-shadow 0.15s ease;
        }
        .cd-student-thumb:hover {
            transform: scale(1.1);
            box-shadow: 0 2px 8px rgba(0,0,0,0.2);
        }
        
        /* Photo Lightbox */
        .cd-lightbox-overlay {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: rgba(0,0,0,0.85);
            z-index: 99999;
            justify-content: center;
            align-items: center;
        }
        .cd-lightbox-overlay.show {
            display: flex;
        }
        .cd-lightbox {
            position: relative;
            max-width: 90%;
            max-height: 90%;
        }
        .cd-lightbox__img {
            max-width: 100%;
            max-height: 85vh;
            border: 4px solid #fff;
            box-shadow: 0 4px 30px rgba(0,0,0,0.5);
            background: #fff;
        }
        .cd-lightbox__close {
            position: absolute;
            top: -40px;
            right: 0;
            background: none;
            border: none;
            color: #fff;
            font-size: 32px;
            cursor: pointer;
            padding: 0;
            line-height: 1;
            opacity: 0.8;
        }
        .cd-lightbox__close:hover {
            opacity: 1;
        }
        .cd-lightbox__caption {
            color: #fff;
            text-align: center;
            padding: 12px 0;
            font-size: 14px;
        }
        .cd-lightbox__name {
            font-weight: 600;
            font-size: 16px;
        }
        .cd-lightbox__regno {
            opacity: 0.8;
            font-size: 13px;
        }
        
        /* ===== Filter Bar ===== */
        .cd-filters {
            background: #f8f9fa;
            border-bottom: 1px solid #e0e0e0;
            padding: 8px 12px;
        }
        .cd-filters__top {
            display: flex;
            align-items: center;
            gap: 8px;
            margin-bottom: 6px;
        }
        .cd-search-wrap {
            position: relative;
            flex: 1;
            max-width: 360px;
        }
        .cd-search-wrap__icon {
            position: absolute;
            left: 9px;
            top: 50%;
            transform: translateY(-50%);
            color: #999;
            pointer-events: none;
        }
        .cd-search-input {
            width: 100%;
            border: 1px solid #ddd;
            border-radius: 6px;
            padding: 6px 10px 6px 30px;
            font-size: 12px;
            background: #fff;
            transition: border-color 0.15s, box-shadow 0.15s;
        }
        .cd-search-input:focus {
            border-color: #174DA4;
            box-shadow: 0 0 0 2px rgba(23,77,164,0.10);
            outline: none;
        }
        .cd-search-input::placeholder { color: #aaa; }
        .cd-btn-search {
            border: none;
            background: #174DA4;
            color: #fff;
            border-radius: 6px;
            padding: 6px 14px;
            font-size: 11px;
            font-weight: 600;
            cursor: pointer;
            white-space: nowrap;
            transition: background 0.15s;
        }
        .cd-btn-search:hover { background: #12397a; }
        .cd-btn-reset {
            border: 1px solid #ddd;
            background: #fff;
            color: #666;
            border-radius: 6px;
            padding: 6px 12px;
            font-size: 11px;
            cursor: pointer;
            white-space: nowrap;
            transition: all 0.15s;
        }
        .cd-btn-reset:hover { background: #f0f0f0; color: #333; border-color: #bbb; }
        .cd-filters__count {
            font-size: 11px;
            color: #174DA4;
            font-weight: 600;
            margin-left: auto;
            white-space: nowrap;
            background: rgba(23,77,164,0.07);
            padding: 4px 10px;
            border-radius: 10px;
        }
        .cd-filters__row {
            display: flex;
            gap: 6px;
            flex-wrap: wrap;
            align-items: center;
        }
        .cd-filter-grp {
            display: flex;
            align-items: center;
            gap: 3px;
        }
        .cd-filter-grp__label {
            font-size: 10px;
            color: #888;
            text-transform: uppercase;
            letter-spacing: 0.3px;
            font-weight: 600;
        }
        .cd-filter-select {
            border: 1px solid #ddd;
            border-radius: 4px;
            padding: 4px 6px;
            font-size: 11px;
            min-width: 120px;
            background: #fff;
            color: #333;
            transition: border-color 0.15s;
            cursor: pointer;
        }
        .cd-filter-select:focus {
            border-color: #174DA4;
            outline: none;
        }
        .cd-filter-sep {
            width: 1px;
            height: 20px;
            background: #ddd;
            margin: 0 2px;
        }
        
        /* Student Profile Popup Scrolling Fix */
        .sp-popup .dxpc-content {
            overflow: hidden !important;
            display: flex;
            flex-direction: column;
            height: 100%;
        }
        .sp-popup .dxpc-contentWrapper {
            overflow: hidden !important;
            height: 100%;
            display: flex;
            flex-direction: column;
        }
        .sp-profile-container {
            display: flex;
            flex-direction: column;
            height: 100%;
            max-height: calc(650px - 45px); /* Subtract header height */
            overflow: hidden;
        }
        .sp-profile-header {
            flex-shrink: 0;
        }
        .sp-profile-tabs-wrapper {
            flex: 1;
            overflow: hidden;
            min-height: 0;
            display: flex;
            flex-direction: column;
        }
        .sp-profile-tabs-wrapper > .dxpc-mainDiv,
        .sp-profile-tabs-wrapper > div {
            height: 100%;
            display: flex;
            flex-direction: column;
            flex: 1;
        }
        .sp-profile-tabs-wrapper .dxtc-content {
            flex: 1;
            overflow-y: auto !important;
            min-height: 0;
        }
        
        /* Compact Tab Switcher Styles */
        .sp-profile-tabs-wrapper .dxtc-stripContainer {
            background: #f5f7fa !important;
            border-bottom: 1px solid #e0e0e0 !important;
            padding: 0 4px !important;
        }
        .sp-profile-tabs-wrapper .dxtc-tab {
            padding: 4px 8px !important;
            font-size: 10px !important;
            font-weight: 500 !important;
            border-radius: 3px 3px 0 0 !important;
            margin: 2px 1px 0 1px !important;
            border: 1px solid transparent !important;
            border-bottom: none !important;
            background: transparent !important;
            color: #666 !important;
            transition: all 0.15s ease !important;
        }
        .sp-profile-tabs-wrapper .dxtc-tab:hover {
            background: #e9ecef !important;
            color: #333 !important;
        }
        .sp-profile-tabs-wrapper .dxtc-activeTab {
            background: #fff !important;
            color: #174DA4 !important;
            font-weight: 600 !important;
            border-color: #e0e0e0 !important;
            border-bottom-color: #fff !important;
            margin-bottom: -1px !important;
            position: relative !important;
            z-index: 1 !important;
        }
        .sp-profile-tabs-wrapper .dxtc-spacer {
            display: none !important;
        }
        .sp-profile-tabs-wrapper .dxtc-tabRow {
            margin: 0 !important;
            padding: 0 !important;
        }
        .sp-profile-tabs-wrapper .dxtc-strip {
            height: auto !important;
            min-height: 26px !important;
        }
        
        .sp-tab-content {
            padding: 12px;
        }
        
        /* Profile Header Section - Compact */
        .sp-profile-header {
            display: flex;
            gap: 12px;
            padding: 10px 12px;
            background: linear-gradient(135deg, #f8f9fa 0%, #fff 100%);
            border-bottom: 1px solid #e0e0e0;
        }
        .sp-profile-photo-wrap {
            flex-shrink: 0;
            text-align: center;
        }
        .sp-profile-photo {
            width: 70px;
            height: 85px;
            object-fit: cover;
            border: 2px solid #174DA4;
            background: #f5f5f5;
        }
        .sp-profile-signature {
            width: 60px;
            height: 22px;
            margin-top: 4px;
            border: 1px solid #ddd;
            background: #fff;
        }
        .sp-profile-info {
            flex: 1;
            min-width: 0;
        }
        .sp-profile-name {
            font-size: 15px;
            font-weight: 700;
            color: #333;
            margin: 0 0 1px 0;
            line-height: 1.2;
        }
        .sp-profile-regno {
            font-size: 12px;
            color: #174DA4;
            font-weight: 600;
            margin-bottom: 4px;
        }
        .sp-profile-programme {
            font-size: 11px;
            color: #555;
            margin-bottom: 2px;
        }
        .sp-profile-specialisation {
            font-size: 10px;
            color: #777;
        }
        .sp-profile-quick-stats {
            display: flex;
            gap: 8px;
            margin-top: 6px;
            flex-wrap: wrap;
        }
        .sp-quick-stat {
            display: flex;
            flex-direction: column;
            padding: 3px 8px;
            background: #fff;
            border: 1px solid #e0e0e0;
            border-radius: 3px;
        }
        .sp-quick-stat__label {
            font-size: 8px;
            color: #888;
            text-transform: uppercase;
            letter-spacing: 0.3px;
        }
        .sp-quick-stat__value {
            font-size: 10px;
            font-weight: 600;
            color: #333;
        }
        
        /* Bio Data Section */
        .sp-bio-section {
            margin-bottom: 12px;
        }
        .sp-bio-section:last-child {
            margin-bottom: 0;
        }
        .sp-bio-section__title {
            font-size: 10px;
            font-weight: 600;
            color: #174DA4;
            text-transform: uppercase;
            letter-spacing: 0.3px;
            margin-bottom: 6px;
            padding-bottom: 3px;
            border-bottom: 1px solid #e0e0e0;
        }
        .sp-bio-grid {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 6px 10px;
        }
        .sp-bio-field {
            display: flex;
            flex-direction: column;
        }
        .sp-bio-field__label {
            font-size: 8px;
            color: #888;
            text-transform: uppercase;
            margin-bottom: 1px;
        }
        .sp-bio-field__value {
            font-size: 11px;
            color: #333;
            font-weight: 500;
        }
        
        /* Data Tables in Tabs */
        .sp-data-table {
            width: 100%;
            border-collapse: collapse;
            font-size: 10px;
        }
        .sp-data-table th {
            background: #f5f5f5;
            padding: 4px 6px;
            text-align: left;
            font-weight: 600;
            color: #555;
            border-bottom: 1px solid #ddd;
            font-size: 9px;
            text-transform: uppercase;
        }
        .sp-data-table td {
            padding: 6px 8px;
            border-bottom: 1px solid #eee;
            color: #333;
        }
        .sp-data-table tr:hover td {
            background: #f9f9f9;
        }
        .sp-data-table--results td.grade {
            font-weight: 600;
            text-align: center;
        }
        .sp-data-table--results td.grade-A { color: #28a745; }
        .sp-data-table--results td.grade-B { color: #17a2b8; }
        .sp-data-table--results td.grade-C { color: #ffc107; }
        .sp-data-table--results td.grade-D { color: #fd7e14; }
        .sp-data-table--results td.grade-F { color: #dc3545; }
        
        /* Summary Stats */
        .sp-summary-row {
            display: flex;
            gap: 12px;
            margin-bottom: 12px;
            flex-wrap: wrap;
        }
        .sp-summary-card {
            flex: 1;
            min-width: 120px;
            padding: 10px;
            background: #f8f9fa;
            border-left: 3px solid #174DA4;
        }
        .sp-summary-card__label {
            font-size: 9px;
            color: #666;
            text-transform: uppercase;
        }
        .sp-summary-card__value {
            font-size: 16px;
            font-weight: 700;
            color: #174DA4;
        }
        
        /* Semester Groups */
        .sp-semester-group {
            margin-bottom: 16px;
        }
        .sp-semester-group__header {
            font-size: 11px;
            font-weight: 600;
            color: #333;
            padding: 6px 10px;
            background: #e9ecef;
            margin-bottom: 0;
        }
        
        /* Empty State */
        .sp-empty {
            text-align: center;
            padding: 30px;
            color: #888;
            font-size: 12px;
        }
        .sp-empty svg {
            width: 40px;
            height: 40px;
            margin-bottom: 10px;
            opacity: 0.5;
            display: block;
            margin-left: auto;
            margin-right: auto;
            stroke: currentColor;
        }
        
        /* Fix icons in popup - ensure proper display */
        .sp-popup svg {
            display: inline-block;
            vertical-align: middle;
            flex-shrink: 0;
        }
        
        /* Curriculum Tab Styles */
        .sp-curriculum-header {
            display: flex;
            gap: 8px;
            padding: 8px;
            background: linear-gradient(135deg, #f0f7ff 0%, #e6f0fa 100%);
            border-bottom: 1px solid #dce8f4;
            align-items: stretch;
            flex-wrap: wrap;
        }
        .sp-curriculum-info-card {
            flex: 1;
            min-width: 140px;
            padding: 6px 8px;
            background: #fff;
            border: 1px solid #e0e0e0;
            border-radius: 3px;
        }
        .sp-curriculum-info-card__label {
            font-size: 8px;
            color: #666;
            text-transform: uppercase;
            letter-spacing: 0.3px;
            margin-bottom: 2px;
        }
        .sp-curriculum-info-card__value {
            font-size: 11px;
            font-weight: 600;
            color: #174DA4;
        }
        .sp-curriculum-info-card__sub {
            font-size: 9px;
            color: #888;
            margin-top: 1px;
        }
        .sp-curriculum-stats {
            display: flex;
            gap: 4px;
            flex-wrap: wrap;
            align-items: stretch;
        }
        .sp-curriculum-stat {
            padding: 4px 8px;
            background: #fff;
            border: 1px solid #e0e0e0;
            border-radius: 3px;
            text-align: center;
            min-width: 50px;
        }
        .sp-curriculum-stat__value {
            font-size: 13px;
            font-weight: 700;
            color: #174DA4;
            line-height: 1.2;
        }
        .sp-curriculum-stat__label {
            font-size: 8px;
            color: #666;
            text-transform: uppercase;
        }
        .sp-curriculum-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
            gap: 8px;
            padding: 8px;
        }
        .sp-curriculum-year {
            background: #fff;
            border: 1px solid #e0e0e0;
            border-radius: 3px;
            overflow: hidden;
        }
        .sp-curriculum-year__header {
            padding: 5px 8px;
            background: #174DA4;
            color: #fff;
            font-weight: 600;
            font-size: 10px;
        }
        .sp-curriculum-semester {
            border-bottom: 1px solid #eee;
        }
        .sp-curriculum-semester:last-child {
            border-bottom: none;
        }
        .sp-curriculum-semester__header {
            padding: 4px 8px;
            background: #f5f5f5;
            font-weight: 600;
            font-size: 10px;
            color: #555;
            display: flex;
            justify-content: space-between;
        }
        .sp-curriculum-semester__credits {
            color: #174DA4;
        }
        .sp-curriculum-course {
            display: flex;
            padding: 3px 8px;
            border-bottom: 1px solid #f0f0f0;
            font-size: 10px;
            align-items: center;
        }
        .sp-curriculum-course:last-child {
            border-bottom: none;
        }
        .sp-curriculum-course:hover {
            background: #fafafa;
        }
        .sp-curriculum-course__code {
            font-weight: 600;
            color: #174DA4;
            min-width: 90px;
        }
        .sp-curriculum-course__name {
            flex: 1;
            color: #333;
        }
        .sp-curriculum-course__credits {
            min-width: 50px;
            text-align: center;
            color: #666;
        }
        .sp-curriculum-course__type {
            min-width: 60px;
            text-align: center;
        }
        .sp-curriculum-course__type--core {
            color: #28a745;
            font-weight: 500;
        }
        .sp-curriculum-course__type--elective {
            color: #fd7e14;
            font-weight: 500;
        }
        .sp-curriculum-empty {
            padding: 8px 12px;
            color: #999;
            font-style: italic;
            font-size: 10px;
        }
        .sp-curriculum-badge {
            display: inline-block;
            padding: 2px 8px;
            border-radius: 10px;
            font-size: 9px;
            font-weight: 600;
            text-transform: uppercase;
        }
        .sp-curriculum-badge--default {
            background: #fff3cd;
            color: #856404;
        }
        .sp-curriculum-badge--assigned {
            background: #d4edda;
            color: #155724;
        }
        
        /* Validation Tab Styles */
        .sp-validation-header {
            display: flex;
            gap: 10px;
            padding: 8px 10px;
            background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%);
            border-bottom: 1px solid #dee2e6;
            align-items: center;
            flex-wrap: wrap;
        }
        .sp-validation-summary {
            display: flex;
            gap: 8px;
            flex-wrap: wrap;
        }
        .sp-validation-stat {
            padding: 4px 10px;
            background: #fff;
            border: 1px solid #e0e0e0;
            border-radius: 3px;
            text-align: center;
            min-width: 70px;
        }
        .sp-validation-stat__value {
            font-size: 14px;
            font-weight: 700;
            line-height: 1.2;
        }
        .sp-validation-stat__value--pass { color: #28a745; }
        .sp-validation-stat__value--fail { color: #dc3545; }
        .sp-validation-stat__value--pending { color: #ffc107; }
        .sp-validation-stat__label {
            font-size: 8px;
            color: #666;
            text-transform: uppercase;
        }
        .sp-validation-overall {
            margin-left: auto;
            padding: 6px 12px;
            border-radius: 4px;
            font-weight: 600;
            font-size: 11px;
            text-transform: uppercase;
        }
        .sp-validation-overall--pass {
            background: #d4edda;
            color: #155724;
            border: 1px solid #c3e6cb;
        }
        .sp-validation-overall--fail {
            background: #f8d7da;
            color: #721c24;
            border: 1px solid #f5c6cb;
        }
        .sp-validation-overall--pending {
            background: #fff3cd;
            color: #856404;
            border: 1px solid #ffeeba;
        }
        .sp-validation-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(260px, 1fr));
            gap: 8px;
            padding: 8px;
        }
        .sp-validation-card {
            background: #fff;
            border: 1px solid #e0e0e0;
            border-radius: 4px;
            overflow: hidden;
            transition: box-shadow 0.2s;
        }
        .sp-validation-card:hover {
            box-shadow: 0 2px 6px rgba(0,0,0,0.08);
        }
        .sp-validation-card--pass {
            border-left: 3px solid #28a745;
        }
        .sp-validation-card--fail {
            border-left: 3px solid #dc3545;
        }
        .sp-validation-card--pending {
            border-left: 3px solid #ffc107;
        }
        .sp-validation-card__header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 6px 10px;
            background: #f8f9fa;
            border-bottom: 1px solid #eee;
        }
        .sp-validation-card__title {
            font-weight: 600;
            font-size: 11px;
            color: #333;
        }
        .sp-validation-card__status {
            font-size: 9px;
            font-weight: 600;
            padding: 2px 8px;
            border-radius: 10px;
            text-transform: uppercase;
        }
        .sp-validation-card__status--pass {
            background: #d4edda;
            color: #155724;
        }
        .sp-validation-card__status--fail {
            background: #f8d7da;
            color: #721c24;
        }
        .sp-validation-card__status--pending {
            background: #fff3cd;
            color: #856404;
        }
        .sp-validation-card__body {
            padding: 8px 10px;
        }
        .sp-validation-row {
            display: flex;
            justify-content: space-between;
            font-size: 10px;
            padding: 3px 0;
            border-bottom: 1px solid #f0f0f0;
        }
        .sp-validation-row:last-child {
            border-bottom: none;
        }
        .sp-validation-row__label {
            color: #666;
        }
        .sp-validation-row__value {
            font-weight: 600;
            color: #333;
        }
        .sp-validation-row__value--pass { color: #28a745; }
        .sp-validation-row__value--fail { color: #dc3545; }
        .sp-validation-row__value--warning { color: #ffc107; }
        .sp-validation-progress {
            margin-top: 6px;
            height: 4px;
            background: #e9ecef;
            border-radius: 2px;
            overflow: hidden;
        }
        .sp-validation-progress__bar {
            height: 100%;
            transition: width 0.3s;
        }
        .sp-validation-progress__bar--pass { background: #28a745; }
        .sp-validation-progress__bar--fail { background: #dc3545; }
        .sp-validation-progress__bar--partial { background: #ffc107; }
        .sp-validation-empty {
            text-align: center;
            padding: 20px;
            color: #888;
            font-size: 11px;
        }
        .sp-validation-empty svg {
            width: 36px;
            height: 36px;
            margin-bottom: 8px;
            opacity: 0.4;
        }
        
        /* Thesis & Supervisor Tab Styles */
        .sp-thesis-form {
            padding: 12px;
        }
        .sp-thesis-status-bar {
            display: flex;
            gap: 10px;
            padding: 8px 12px;
            background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%);
            border-bottom: 1px solid #dee2e6;
            align-items: center;
            flex-wrap: wrap;
        }
        .sp-thesis-status-badge {
            display: inline-block;
            padding: 3px 10px;
            border-radius: 10px;
            font-size: 10px;
            font-weight: 600;
            text-transform: uppercase;
        }
        .sp-thesis-status-badge--progress {
            background: #fff3cd;
            color: #856404;
            border: 1px solid #ffeeba;
        }
        .sp-thesis-status-badge--completed {
            background: #d4edda;
            color: #155724;
            border: 1px solid #c3e6cb;
        }
        .sp-thesis-status-badge--none {
            background: #f8f9fa;
            color: #6c757d;
            border: 1px solid #dee2e6;
        }
        .sp-thesis-field {
            margin-bottom: 14px;
        }
        .sp-thesis-field label {
            display: block;
            font-size: 10px;
            font-weight: 600;
            color: #555;
            text-transform: uppercase;
            margin-bottom: 4px;
            letter-spacing: 0.3px;
        }
        .sp-thesis-field textarea,
        .sp-thesis-field select,
        .sp-thesis-field input[type="text"] {
            width: 100%;
            padding: 6px 10px;
            border: 1px solid #ccc;
            border-radius: 4px;
            font-size: 12px;
            font-family: inherit;
            transition: border-color 0.2s;
            box-sizing: border-box;
        }
        .sp-thesis-field textarea:focus,
        .sp-thesis-field select:focus,
        .sp-thesis-field input[type="text"]:focus {
            border-color: #174DA4;
            outline: none;
            box-shadow: 0 0 0 2px rgba(23, 77, 164, 0.1);
        }
        .sp-thesis-field textarea {
            min-height: 80px;
            resize: vertical;
        }
        .sp-thesis-supervisor-info {
            display: flex;
            gap: 10px;
            margin-top: 6px;
            font-size: 10px;
            color: #666;
        }
        .sp-thesis-supervisor-info span {
            padding: 2px 8px;
            background: #f0f0f0;
            border-radius: 3px;
        }
        .sp-thesis-actions {
            display: flex;
            gap: 8px;
            margin-top: 16px;
            padding-top: 12px;
            border-top: 1px solid #eee;
        }
        .sp-thesis-btn {
            padding: 6px 16px;
            border: none;
            border-radius: 4px;
            font-size: 11px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.2s;
        }
        .sp-thesis-btn--save {
            background: #174DA4;
            color: #fff;
        }
        .sp-thesis-btn--save:hover {
            background: #12397a;
        }
        .sp-thesis-msg {
            padding: 6px 10px;
            border-radius: 4px;
            font-size: 11px;
            margin-top: 8px;
        }
        .sp-thesis-msg--success {
            background: #d4edda;
            color: #155724;
            border: 1px solid #c3e6cb;
        }
        .sp-thesis-msg--error {
            background: #f8d7da;
            color: #721c24;
            border: 1px solid #f5c6cb;
        }
        .sp-thesis-current {
            padding: 10px 12px;
            background: #f8f9fa;
            border: 1px solid #e9ecef;
            border-radius: 4px;
            margin-bottom: 14px;
        }
        .sp-thesis-current__label {
            font-size: 9px;
            color: #888;
            text-transform: uppercase;
            margin-bottom: 2px;
        }
        .sp-thesis-current__value {
            font-size: 12px;
            color: #333;
            font-weight: 500;
        }
        .sp-thesis-current__value--empty {
            font-style: italic;
            color: #aaa;
        }
        
        /* Responsive */
        @media (max-width: 768px) {
            .sp-profile-header {
                flex-direction: column;
                align-items: center;
                text-align: center;
            }
            .sp-bio-grid {
                grid-template-columns: repeat(2, 1fr);
            }
            .sp-profile-quick-stats {
                justify-content: center;
            }
        }
    </style>
</asp:Content>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    
    <div class="cd-card">
        <!-- Page Header with Title and Batch Operations -->
        <div style="padding: 10px 12px; border-bottom: 1px solid #e0e0e0; background: #fff; display: flex; justify-content: space-between; align-items: center;">
            <h2 style="margin: 0; font-size: 16px; font-weight: 600; color: #174DA4;">
                <asp:Literal ID="litPageTitle" runat="server" Text="Student Records"></asp:Literal>
            </h2>
            
            <!-- Batch Operations Button -->
            <div style="display:flex;gap:8px;align-items:center;">
                <a href="NewStudentRegistration.aspx?returnUrl=NewStudentInfo.aspx%3Fstatus%3DALL" class="cd-btn cd-btn--primary cd-btn--sm" style="text-decoration:none;background:#00695c;border-color:#00695c;display:inline-flex;align-items:center;gap:5px;">
                    <svg xmlns="http://www.w3.org/2000/svg" width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M16 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path><circle cx="8.5" cy="7" r="4"></circle><line x1="20" y1="8" x2="20" y2="14"></line><line x1="23" y1="11" x2="17" y2="11"></line></svg>
                    Register New Student
                </a>
                <div class="cd-batch-ops">
                <button type="button" class="cd-btn cd-btn--primary cd-btn--sm" onclick="toggleBatchMenu(event)">
                    <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="margin-right: 4px;"><rect x="3" y="3" width="7" height="7"></rect><rect x="14" y="3" width="7" height="7"></rect><rect x="14" y="14" width="7" height="7"></rect><rect x="3" y="14" width="7" height="7"></rect></svg>
                    Batch Operations
                    <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="margin-left: 4px;"><polyline points="6 9 12 15 18 9"></polyline></svg>
                </button>
                <div class="cd-batch-menu" id="batchMenu">
                    <a href="javascript:void(0);" class="cd-batch-menu__item" onclick="openBatchStatusModal()">
                        <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M16 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path><circle cx="8.5" cy="7" r="4"></circle><line x1="18" y1="8" x2="23" y2="13"></line><line x1="23" y1="8" x2="18" y2="13"></line></svg>
                        Change Students Status
                    </a>
                    <a href="javascript:void(0);" class="cd-batch-menu__item" onclick="openBatchValidationModal()">
                        <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"></path><polyline points="22 4 12 14.01 9 11.01"></polyline></svg>
                        Validate Student Results
                    </a>
                    <a href="javascript:void(0);" class="cd-batch-menu__item" onclick="openSummaryReportModal()">
                        <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path><polyline points="14 2 14 8 20 8"></polyline><line x1="16" y1="13" x2="8" y2="13"></line><line x1="16" y1="17" x2="8" y2="17"></line><polyline points="10 9 9 9 8 9"></polyline></svg>
                        Export Summary Report
                    </a>
                    <a href="javascript:void(0);" class="cd-batch-menu__item" onclick="openBatchPromotionModal()">
                        <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="17 1 21 5 17 9"></polyline><path d="M3 11V9a4 4 0 0 1 4-4h14"></path><polyline points="7 23 3 19 7 15"></polyline><path d="M21 13v2a4 4 0 0 1-4 4H3"></path></svg>
                        Promote Students
                    </a>
                    <a href="javascript:void(0);" class="cd-batch-menu__item" onclick="openBatchExportModal()">
                        <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"></path><polyline points="7 10 12 15 17 10"></polyline><line x1="12" y1="15" x2="12" y2="3"></line></svg>
                        Export Students Data
                    </a>
                    <a href="javascript:void(0);" class="cd-batch-menu__item" onclick="openBatchEmailModal()">
                        <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"></path><polyline points="22,6 12,13 2,6"></polyline></svg>
                        Send Bulk Email/SMS
                    </a>
                    <a href="NCHEStudentExporter.aspx" class="cd-batch-menu__item">
                        <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"></path><polyline points="7 10 12 15 17 10"></polyline><line x1="12" y1="15" x2="12" y2="3"></line></svg>
                        Export NCHE Student Data
                    </a>
                </div>
            </div>
            </div>
        </div>
        
        <!-- ===== Filter Bar ===== -->
        <div class="cd-filters">
            <!-- Row 1: Search + Reset + Count -->
            <div class="cd-filters__top">
                <div class="cd-search-wrap">
                    <svg class="cd-search-wrap__icon" xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
                    <asp:TextBox ID="txtSearch" runat="server" CssClass="cd-search-input" placeholder="Search by name, reg no, entry no, phone or email..." />
                </div>
                <asp:Button ID="btnSearch" runat="server" Text="Search" CssClass="cd-btn-search" OnClick="btnSearch_Click" />
                <asp:Button ID="btnResetFilters" runat="server" Text="✕ Reset All" CssClass="cd-btn-reset" OnClick="btnResetFilters_Click" />
                <asp:Literal ID="litStudentCount" runat="server" />
            </div>
            <!-- Row 2: Dropdown filters -->
            <div class="cd-filters__row">
                <div class="cd-filter-grp">
                    <span class="cd-filter-grp__label">Status</span>
                    <asp:DropDownList ID="ddlFilterStatus" runat="server" CssClass="cd-filter-select" AutoPostBack="true" OnSelectedIndexChanged="ddlFilterStatus_SelectedIndexChanged" style="min-width: 110px;">
                        <asp:ListItem Value="" Text="All"></asp:ListItem>
                        <asp:ListItem Value="ADMITTED" Text="Admitted"></asp:ListItem>
                        <asp:ListItem Value="ACTIVE" Text="Active"></asp:ListItem>
                        <asp:ListItem Value="ALUMNI" Text="Alumni"></asp:ListItem>
                        <asp:ListItem Value="SUSPENDED" Text="Suspended"></asp:ListItem>
                        <asp:ListItem Value="DEFERRED" Text="Deferred"></asp:ListItem>
                    </asp:DropDownList>
                </div>
                <div class="cd-filter-sep"></div>
                <div class="cd-filter-grp">
                    <span class="cd-filter-grp__label">Faculty</span>
                    <asp:DropDownList ID="ddlFilterFaculty" runat="server" CssClass="cd-filter-select" AutoPostBack="true" OnSelectedIndexChanged="ddlFilterFaculty_SelectedIndexChanged">
                        <asp:ListItem Value="" Text="All"></asp:ListItem>
                    </asp:DropDownList>
                </div>
                <div class="cd-filter-sep"></div>
                <div class="cd-filter-grp">
                    <span class="cd-filter-grp__label">Programme</span>
                    <dx:ASPxComboBox ID="ddlFilterProgramme" runat="server" 
                        ValueType="System.String" TextField="progname" ValueField="progcode"
                        IncrementalFilteringMode="Contains" EnableCallbackMode="false"
                        DropDownStyle="DropDownList" Width="200px"
                        AutoPostBack="true" OnSelectedIndexChanged="ddlFilterProgramme_SelectedIndexChanged"
                        NullText="All">
                        <ClearButton DisplayMode="Always" />
                    </dx:ASPxComboBox>
                </div>
                <div class="cd-filter-sep"></div>
                <div class="cd-filter-grp">
                    <span class="cd-filter-grp__label">Year</span>
                    <asp:DropDownList ID="ddlFilterEntryYear" runat="server" CssClass="cd-filter-select" AutoPostBack="true" OnSelectedIndexChanged="ddlFilterEntryYear_SelectedIndexChanged" style="min-width: 70px;">
                        <asp:ListItem Value="" Text="All"></asp:ListItem>
                    </asp:DropDownList>
                </div>
                <div class="cd-filter-sep"></div>
                <div class="cd-filter-grp">
                    <span class="cd-filter-grp__label">Session</span>
                    <asp:DropDownList ID="ddlFilterSession" runat="server" CssClass="cd-filter-select" AutoPostBack="true" OnSelectedIndexChanged="ddlFilterSession_SelectedIndexChanged" style="min-width: 80px;">
                        <asp:ListItem Value="" Text="All"></asp:ListItem>
                    </asp:DropDownList>
                </div>
                <div class="cd-filter-sep"></div>
                <div class="cd-filter-grp">
                    <span class="cd-filter-grp__label">Campus</span>
                    <asp:DropDownList ID="ddlFilterCampus" runat="server" CssClass="cd-filter-select" AutoPostBack="true" OnSelectedIndexChanged="ddlFilterCampus_SelectedIndexChanged" style="min-width: 90px;">
                        <asp:ListItem Value="" Text="All"></asp:ListItem>
                    </asp:DropDownList>
                </div>
            </div>
        </div>
        
        <div class="cd-card__body cd-p-0">
            <dx:ASPxGridView ID="gvStudents" runat="server" AutoGenerateColumns="False" 
                KeyFieldName="regno" Width="100%" ClientInstanceName="gvStudents"
                OnRowUpdating="gvStudents_RowUpdating" OnRowDeleting="gvStudents_RowDeleting"
                EnableTheming="True" Theme="Glass" EnableCallBacks="false">
                
                <SettingsPager PageSize="20" AlwaysShowPager="true" Position="Bottom">
                    <Summary Text="Page {0} of {1} ({2} students)" />
                </SettingsPager>
                
                <Settings ShowFilterRow="True" ShowFilterRowMenu="True" HorizontalScrollBarMode="Auto" />
                <SettingsBehavior AllowFocusedRow="True" ConfirmDelete="True" />
                <SettingsEditing Mode="PopupEditForm" />
                <SettingsDataSecurity AllowDelete="False" />
                
                <SettingsPopup>
                    <EditForm Width="600px" Height="450px" HorizontalAlign="WindowCenter" VerticalAlign="WindowCenter" Modal="True" />
                </SettingsPopup>
                
                <EditFormLayoutProperties ColCount="2">
                    <Items>
                        <dx:GridViewLayoutGroup Caption="Personal Information" ColCount="2" ColSpan="2">
                            <Items>
                                <dx:GridViewColumnLayoutItem ColumnName="entryno"></dx:GridViewColumnLayoutItem>
                                <dx:GridViewColumnLayoutItem ColumnName="regno"></dx:GridViewColumnLayoutItem>
                                <dx:GridViewColumnLayoutItem ColumnName="firstname"></dx:GridViewColumnLayoutItem>
                                <dx:GridViewColumnLayoutItem ColumnName="othername"></dx:GridViewColumnLayoutItem>
                                <dx:GridViewColumnLayoutItem ColumnName="gender"></dx:GridViewColumnLayoutItem>
                                <dx:GridViewColumnLayoutItem ColumnName="dob"></dx:GridViewColumnLayoutItem>
                                <dx:GridViewColumnLayoutItem ColumnName="nationality"></dx:GridViewColumnLayoutItem>
                                <dx:GridViewColumnLayoutItem ColumnName="religion"></dx:GridViewColumnLayoutItem>
                                <dx:GridViewColumnLayoutItem ColumnName="studPhone"></dx:GridViewColumnLayoutItem>
                                <dx:GridViewColumnLayoutItem ColumnName="email"></dx:GridViewColumnLayoutItem>
                                <dx:GridViewColumnLayoutItem ColumnName="home_dist"></dx:GridViewColumnLayoutItem>
                                <dx:GridViewColumnLayoutItem ColumnName="national_id"></dx:GridViewColumnLayoutItem>
                            </Items>
                        </dx:GridViewLayoutGroup>
                        <dx:GridViewLayoutGroup Caption="Academic Information" ColCount="2" ColSpan="2">
                            <Items>
                                <dx:GridViewColumnLayoutItem ColumnName="entryyear"></dx:GridViewColumnLayoutItem>
                                <dx:GridViewColumnLayoutItem ColumnName="intake"></dx:GridViewColumnLayoutItem>
                                <dx:GridViewColumnLayoutItem ColumnName="studsesion"></dx:GridViewColumnLayoutItem>
                                <dx:GridViewColumnLayoutItem ColumnName="studCampus"></dx:GridViewColumnLayoutItem>
                                <dx:GridViewColumnLayoutItem ColumnName="gradSystemID"></dx:GridViewColumnLayoutItem>
                            </Items>
                        </dx:GridViewLayoutGroup>
                        <dx:EditModeCommandLayoutItem ColSpan="2" HorizontalAlign="Right"></dx:EditModeCommandLayoutItem>
                    </Items>
                </EditFormLayoutProperties>
                
                <Columns>
                    <dx:GridViewDataTextColumn Caption="" VisibleIndex="0" Width="45px" Settings-AllowSort="False" Settings-AllowAutoFilter="False">
                        <DataItemTemplate>
                            <img class="cd-student-thumb" 
                                 src='<%# (!String.IsNullOrEmpty(Eval("photofile") as string) && (Eval("photofile").ToString().Trim() != "-") && (Eval("photofile").ToString().Trim().Length > 1)) ? ResolveUrl("~/COOPERP/StudentInfo/photos/") + Eval("photofile").ToString().Trim() : ResolveUrl("~/COOPERP/StudentInfo/photos/default.png") %>' 
                                 alt="" 
                                 data-default-src='<%# ResolveUrl("~/COOPERP/StudentInfo/photos/default.png") %>' 
                                 onerror="this.src=this.getAttribute('data-default-src')" 
                                 data-name='<%# HttpUtility.HtmlAttributeEncode((Eval("firstname") ?? "").ToString() + " " + (Eval("othername") ?? "").ToString()) %>' 
                                 data-regno='<%# HttpUtility.HtmlAttributeEncode((Eval("entryno") ?? "").ToString()) %>' 
                                 onclick="openLightbox(this.src, this.getAttribute('data-name'), this.getAttribute('data-regno'))" />
                        </DataItemTemplate>
                        <HeaderStyle HorizontalAlign="Center" />
                        <CellStyle HorizontalAlign="Center" Paddings-Padding="2px" />
                    </dx:GridViewDataTextColumn>
                    
                    <dx:GridViewDataTextColumn Caption="Reg No" FieldName="entryno" VisibleIndex="1" Width="120px">
                        <CellStyle Font-Bold="True"></CellStyle>
                        <HeaderStyle Font-Size="11px" />
                    </dx:GridViewDataTextColumn>
                    
                    <dx:GridViewDataTextColumn Caption="Entry No" FieldName="regno" VisibleIndex="2" Width="85px">
                        <HeaderStyle Font-Size="11px" />
                        <EditFormSettings Visible="True" />
                    </dx:GridViewDataTextColumn>
                    
                    <dx:GridViewDataTextColumn Caption="Year" FieldName="entryyear" VisibleIndex="3" Width="45px">
                        <HeaderStyle Font-Size="11px" HorizontalAlign="Center" />
                        <CellStyle HorizontalAlign="Center" />
                    </dx:GridViewDataTextColumn>
                    
                    <dx:GridViewDataTextColumn Caption="Student Name" VisibleIndex="4" Width="160px">
                        <DataItemTemplate>
                            <%# Eval("firstname") %> <%# Eval("othername") %>
                        </DataItemTemplate>
                        <HeaderStyle Font-Size="11px" />
                    </dx:GridViewDataTextColumn>
                    
                    <dx:GridViewDataTextColumn Caption="First Name" FieldName="firstname" VisibleIndex="5" Visible="False">
                        <EditFormSettings Visible="True" />
                    </dx:GridViewDataTextColumn>
                    
                    <dx:GridViewDataTextColumn Caption="Other Names" FieldName="othername" VisibleIndex="6" Visible="False">
                        <EditFormSettings Visible="True" />
                    </dx:GridViewDataTextColumn>
                    
                    <dx:GridViewDataComboBoxColumn Caption="Gender" FieldName="gender" VisibleIndex="7" Width="55px">
                        <PropertiesComboBox>
                            <Items>
                                <dx:ListEditItem Text="MALE" Value="MALE" />
                                <dx:ListEditItem Text="FEMALE" Value="FEMALE" />
                            </Items>
                        </PropertiesComboBox>
                        <HeaderStyle Font-Size="11px" HorizontalAlign="Center" />
                        <CellStyle HorizontalAlign="Center" />
                    </dx:GridViewDataComboBoxColumn>
                    
                    <dx:GridViewDataDateColumn Caption="DOB" FieldName="dob" VisibleIndex="8" Width="90px" Visible="False">
                        <EditFormSettings Visible="True" />
                    </dx:GridViewDataDateColumn>
                    
                    <dx:GridViewDataTextColumn Caption="Nationality" FieldName="nationality" VisibleIndex="9" Width="100px" Visible="False">
                        <EditFormSettings Visible="True" />
                    </dx:GridViewDataTextColumn>
                    
                    <dx:GridViewDataComboBoxColumn Caption="Religion" FieldName="religion" VisibleIndex="10" Visible="False">
                        <PropertiesComboBox>
                            <Items>
                                <dx:ListEditItem Text="MUSLIM" Value="MUSLIM" />
                                <dx:ListEditItem Text="CHRISTIAN" Value="CHRISTIAN" />
                                <dx:ListEditItem Text="CATHOLIC" Value="CATHOLIC" />
                                <dx:ListEditItem Text="PROTESTANT" Value="PROTESTANT" />
                                <dx:ListEditItem Text="ADVENTIST" Value="ADVENTIST" />
                                <dx:ListEditItem Text="ANGLICAN" Value="ANGLICAN" />
                                <dx:ListEditItem Text="ORTHODOX" Value="ORTHODOX" />
                                <dx:ListEditItem Text="PENTACOSTAL" Value="PENTACOSTAL" />
                                <dx:ListEditItem Text="SDA" Value="SDA" />
                                <dx:ListEditItem Text="OTHERS" Value="OTHERS" />
                            </Items>
                        </PropertiesComboBox>
                        <EditFormSettings Visible="True" />
                    </dx:GridViewDataComboBoxColumn>
                    
                    <dx:GridViewDataTextColumn Caption="Phone" FieldName="studPhone" VisibleIndex="11" Width="95px" Visible="False">
                        <HeaderStyle Font-Size="11px" />
                        <EditFormSettings Visible="True" />
                    </dx:GridViewDataTextColumn>
                    
                    <dx:GridViewDataTextColumn Caption="Email" FieldName="email" VisibleIndex="12" Width="150px" Visible="False">
                        <EditFormSettings Visible="True" />
                    </dx:GridViewDataTextColumn>
                    
                    <dx:GridViewDataTextColumn Caption="Home District" FieldName="home_dist" VisibleIndex="13" Visible="False">
                        <EditFormSettings Visible="True" />
                    </dx:GridViewDataTextColumn>
                    
                    <dx:GridViewDataTextColumn Caption="Prog" FieldName="progcode" VisibleIndex="14" Width="65px" ReadOnly="True">
                        <EditFormSettings Visible="False" />
                        <HeaderStyle Font-Size="11px" />
                    </dx:GridViewDataTextColumn>
                    
                    <dx:GridViewDataTextColumn Caption="Specialisation" FieldName="spec_name" VisibleIndex="15" Width="100px" ReadOnly="True">
                        <EditFormSettings Visible="False" />
                        <HeaderStyle Font-Size="11px" />
                    </dx:GridViewDataTextColumn>
                    
                    <%-- Validation Status Columns --%>
                    <dx:GridViewDataTextColumn Caption="Passed" FieldName="has_passed" VisibleIndex="16" Width="60px" ReadOnly="True">
                        <EditFormSettings Visible="False" />
                        <HeaderStyle Font-Size="11px" HorizontalAlign="Center" />
                        <CellStyle HorizontalAlign="Center" />
                        <DataItemTemplate>
                            <%# Eval("has_passed").ToString() == "Yes" 
                                ? "<span style='color:#28a745;font-weight:bold;'>&#10004; Yes</span>" 
                                : "<span style='color:#dc3545;'>&#10008; No</span>" %>
                        </DataItemTemplate>
                    </dx:GridViewDataTextColumn>
                    
                    <dx:GridViewDataTextColumn Caption="Curriculum Set" FieldName="is_curriculum_fully_set" VisibleIndex="17" Width="80px" ReadOnly="True">
                        <EditFormSettings Visible="False" />
                        <HeaderStyle Font-Size="11px" HorizontalAlign="Center" />
                        <CellStyle HorizontalAlign="Center" />
                        <DataItemTemplate>
                            <%# Eval("is_curriculum_fully_set").ToString() == "Yes" 
                                ? "<span style='color:#28a745;font-weight:bold;'>&#10004;</span>" 
                                : "<span style='color:#dc3545;'>&#10008;</span>" %>
                        </DataItemTemplate>
                    </dx:GridViewDataTextColumn>
                    
                    <dx:GridViewDataTextColumn Caption="Fail Reason" FieldName="fail_reason" VisibleIndex="18" Width="150px" ReadOnly="True">
                        <EditFormSettings Visible="False" />
                        <HeaderStyle Font-Size="11px" />
                        <CellStyle Font-Size="10px" />
                    </dx:GridViewDataTextColumn>
                    
                    <dx:GridViewDataTextColumn Caption="Registered" FieldName="is_registered" VisibleIndex="19" Width="70px" ReadOnly="True">
                        <EditFormSettings Visible="False" />
                        <HeaderStyle Font-Size="11px" HorizontalAlign="Center" />
                        <CellStyle HorizontalAlign="Center" />
                        <DataItemTemplate>
                            <%# Eval("is_registered").ToString() == "Yes" 
                                ? "<span style='color:#28a745;font-weight:bold;'>&#10004; Yes</span>" 
                                : "<span style='color:#dc3545;'>&#10008; No</span>" %>
                        </DataItemTemplate>
                    </dx:GridViewDataTextColumn>
                    
                    <dx:GridViewDataTextColumn Caption="Programme" FieldName="progname" VisibleIndex="50" Visible="False" ReadOnly="True">
                        <EditFormSettings Visible="False" />
                    </dx:GridViewDataTextColumn>
                    
                    <dx:GridViewDataComboBoxColumn Caption="Programme" FieldName="progid" VisibleIndex="51" Visible="False">
                        <EditFormSettings Visible="False" />
                    </dx:GridViewDataComboBoxColumn>
                    
                    <dx:GridViewDataTextColumn Caption="Specialisation" FieldName="specialisation" VisibleIndex="52" Width="100px" Visible="False">
                        <EditFormSettings Visible="False" />
                    </dx:GridViewDataTextColumn>
                    
                    <dx:GridViewDataTextColumn Caption="NIN" FieldName="national_id" VisibleIndex="52" Visible="False">
                        <EditFormSettings Visible="True" />
                    </dx:GridViewDataTextColumn>
                    
                    <dx:GridViewDataTextColumn Caption="Entry Year" FieldName="entryyear" VisibleIndex="53" Visible="False">
                        <EditFormSettings Visible="True" />
                    </dx:GridViewDataTextColumn>
                    
                    <dx:GridViewDataComboBoxColumn Caption="Intake" FieldName="intake" VisibleIndex="54" Width="80px" Visible="False">
                        <PropertiesComboBox>
                            <Items>
                                <dx:ListEditItem Text="JANUARY" Value="JANUARY" />
                                <dx:ListEditItem Text="FEBRUARY" Value="FEBRUARY" />
                                <dx:ListEditItem Text="MARCH" Value="MARCH" />
                                <dx:ListEditItem Text="APRIL" Value="APRIL" />
                                <dx:ListEditItem Text="MAY" Value="MAY" />
                                <dx:ListEditItem Text="JUNE" Value="JUNE" />
                                <dx:ListEditItem Text="JULY" Value="JULY" />
                                <dx:ListEditItem Text="AUGUST" Value="AUGUST" />
                                <dx:ListEditItem Text="SEPTEMBER" Value="SEPTEMBER" />
                                <dx:ListEditItem Text="OCTOBER" Value="OCTOBER" />
                                <dx:ListEditItem Text="NOVEMBER" Value="NOVEMBER" />
                                <dx:ListEditItem Text="DECEMBER" Value="DECEMBER" />
                            </Items>
                        </PropertiesComboBox>
                        <EditFormSettings Visible="True" />
                    </dx:GridViewDataComboBoxColumn>
                    
                    <dx:GridViewDataTextColumn Caption="Session" FieldName="studsesion" VisibleIndex="20" Width="55px">
                        <HeaderStyle Font-Size="11px" HorizontalAlign="Center" />
                        <CellStyle HorizontalAlign="Center" />
                    </dx:GridViewDataTextColumn>
                    
                    <dx:GridViewDataTextColumn Caption="Campus" FieldName="campus_name" VisibleIndex="21" Width="80px">
                        <HeaderStyle Font-Size="11px" />
                    </dx:GridViewDataTextColumn>
                    
                    <dx:GridViewDataTextColumn Caption="Old Status" FieldName="stud_status" VisibleIndex="22" Width="70px" ReadOnly="True">
                        <HeaderStyle Font-Size="11px" HorizontalAlign="Center" />
                        <CellStyle HorizontalAlign="Center" ForeColor="#999999" />
                        <EditFormSettings Visible="False" />
                    </dx:GridViewDataTextColumn>
                    
                    <dx:GridViewDataComboBoxColumn Caption="Status" FieldName="new_status" VisibleIndex="23" Width="75px">
                        <PropertiesComboBox>
                            <Items>
                                <dx:ListEditItem Text="ADMITTED" Value="ADMITTED" />
                                <dx:ListEditItem Text="ACTIVE" Value="ACTIVE" />
                                <dx:ListEditItem Text="ALUMNI" Value="ALUMNI" />
                                <dx:ListEditItem Text="SUSPENDED" Value="SUSPENDED" />
                                <dx:ListEditItem Text="DEFERRED" Value="DEFERRED" />
                            </Items>
                        </PropertiesComboBox>
                        <HeaderStyle Font-Size="11px" HorizontalAlign="Center" />
                        <CellStyle HorizontalAlign="Center" />
                        <EditFormSettings Visible="True" />
                    </dx:GridViewDataComboBoxColumn>
                    
                    <dx:GridViewDataTextColumn Caption="Campus Code" FieldName="studCampus" VisibleIndex="25" Visible="False">
                        <EditFormSettings Visible="True" />
                    </dx:GridViewDataTextColumn>
                    
                    <dx:GridViewDataTextColumn Caption="Grading System" FieldName="gradSystemID" VisibleIndex="26" Visible="False">
                        <EditFormSettings Visible="True" />
                    </dx:GridViewDataTextColumn>
                    
                    <dx:GridViewDataTextColumn FieldName="photofile" Visible="False" VisibleIndex="27">
                        <EditFormSettings Visible="False" />
                    </dx:GridViewDataTextColumn>
                    
                    <dx:GridViewDataTextColumn VisibleIndex="28" Caption=" " Width="40px" 
                        Settings-AllowSort="False" Settings-AllowAutoFilter="False">
                        <DataItemTemplate>
                            <div class="cd-action-wrapper">
                                <button type="button" class="cd-action-trigger" onclick="toggleActionPopover(this, event)">
                                    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="1"></circle><circle cx="12" cy="5" r="1"></circle><circle cx="12" cy="19" r="1"></circle></svg>
                                </button>
                                <div class="cd-action-popover">
                                    <ul class="cd-action-popover__menu">
                                        <li class="cd-action-popover__item">
                                            <a href="javascript:void(0);" class="cd-action-popover__btn cd-action-popover__btn--view" 
                                               data-regno='<%# Eval("regno") %>' onclick="openStudentProfile(this.getAttribute('data-regno'))">
                                                <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"></path><circle cx="12" cy="12" r="3"></circle></svg>
                                                View Profile
                                            </a>
                                        </li>
                                        <li class="cd-action-popover__item">
                                            <button type="button" class="cd-action-popover__btn cd-action-popover__btn--edit" data-key='<%# Container.KeyValue %>' onclick="gridEditRow('gvStudents', this.getAttribute('data-key'))">
                                                <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"></path><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"></path></svg>
                                                Edit
                                            </button>
                                        </li>
                                        <li class="cd-action-popover__item">
                                            <a class="cd-action-popover__btn" style="color:#e65100;font-weight:600;" 
                                               href='<%# "NewStudentRegistration.aspx?edit=" + HttpUtility.UrlEncode((Eval("regno") ?? "").ToString()) + "&returnUrl=" + HttpUtility.UrlEncode("NewStudentInfo.aspx?status=ALL&search=" + HttpUtility.UrlEncode((Eval("regno") ?? "").ToString())) %>'
                                               data-regno='<%# Eval("regno") %>'>
                                                <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#e65100" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"></path><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"></path></svg>
                                                Full Edit
                                            </a>
                                        </li>
                                        <li class="cd-action-popover__divider"></li>
                                        <li class="cd-action-popover__item">
                                            <button type="button" class="cd-action-popover__btn cd-action-popover__btn--password" 
                                                data-regno='<%# Eval("regno") %>'
                                                data-name='<%# HttpUtility.HtmlAttributeEncode((Eval("firstname") ?? "").ToString().Trim() + " " + (Eval("othername") ?? "").ToString().Trim()) %>'
                                                onclick="openSetPasswordModal(this.getAttribute('data-regno'), this.getAttribute('data-name'))">
                                                <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="11" width="18" height="11" rx="2" ry="2"></rect><path d="M7 11V7a5 5 0 0 1 10 0v4"></path></svg>
                                                Set Password
                                            </button>
                                        </li>
                                    </ul>
                                </div>
                            </div>
                        </DataItemTemplate>
                        <HeaderStyle HorizontalAlign="Center" />
                        <CellStyle HorizontalAlign="Center" CssClass="cd-action-cell" />
                    </dx:GridViewDataTextColumn>
                </Columns>
                
                <SettingsCommandButton>
                    <EditButton>
                        <Image IconID="edit_edit_16x16"></Image>
                    </EditButton>
                    <UpdateButton RenderMode="Link"></UpdateButton>
                    <CancelButton RenderMode="Link"></CancelButton>
                </SettingsCommandButton>
                
                <Styles>
                    <Header Font-Size="11px" />
                    <Cell Font-Size="11px" Paddings-Padding="4px" />
                    <FilterRow Font-Size="10px" />
                </Styles>
                
            </dx:ASPxGridView>
        </div>
    </div>
    
    <!-- Hidden fields and button for loading profile -->
    <asp:HiddenField ID="hdnSelectedRegno" runat="server" />
    <dx:ASPxButton ID="btnLoadProfile" runat="server" ClientInstanceName="btnLoadProfile" 
        OnClick="btnLoadProfile_Click" AutoPostBack="true" 
        ClientVisible="false" Text="Load" />
    
    <!-- Student Profile Modal (Server-loaded) -->
    <dx:ASPxPopupControl ID="popStudentProfile" runat="server" 
        ClientInstanceName="popStudentProfile"
        Width="950px" Height="780px"
        PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter"
        Modal="True" CloseAction="CloseButton"
        HeaderText="Student Profile" CssClass="sp-popup"
        AllowDragging="true" ShowCloseButton="true"
        EnableCallbackAnimation="false" LoadContentViaCallback="None">
        <HeaderStyle BackColor="#174DA4" ForeColor="White" Font-Size="13px" Font-Bold="True" Paddings-Padding="10px" />
        <ContentStyle Paddings-Padding="0px" />
        <ContentCollection>
            <dx:PopupControlContentControl runat="server">
                <asp:Panel ID="pnlProfileContent" runat="server" CssClass="sp-profile-container">
                    <!-- Profile Header -->
                    <div class="sp-profile-header" style="display:flex;align-items:flex-start;">
                        <div class="sp-profile-photo-wrap">
                            <asp:Image ID="imgProfilePhoto" runat="server" CssClass="sp-profile-photo" />
                            <asp:Image ID="imgProfileSignature" runat="server" CssClass="sp-profile-signature" Visible="false" />
                        </div>
                        <div class="sp-profile-info">
                            <h2 class="sp-profile-name"><asp:Literal ID="litStudentName" runat="server" /></h2>
                            <div class="sp-profile-regno"><asp:Literal ID="litRegNo" runat="server" /></div>
                            <div class="sp-profile-programme"><asp:Literal ID="litProgramme" runat="server" /></div>
                            <div class="sp-profile-specialisation"><asp:Literal ID="litSpecialisation" runat="server" /></div>
                            <div class="sp-profile-quick-stats">
                                <div class="sp-quick-stat">
                                    <span class="sp-quick-stat__label">Entry Year</span>
                                    <span class="sp-quick-stat__value"><asp:Literal ID="litEntryYear" runat="server" /></span>
                                </div>
                                <div class="sp-quick-stat">
                                    <span class="sp-quick-stat__label">Session</span>
                                    <span class="sp-quick-stat__value"><asp:Literal ID="litSession" runat="server" /></span>
                                </div>
                                <div class="sp-quick-stat">
                                    <span class="sp-quick-stat__label">Campus</span>
                                    <span class="sp-quick-stat__value"><asp:Literal ID="litCampus" runat="server" /></span>
                                </div>
                                <div class="sp-quick-stat">
                                    <span class="sp-quick-stat__label">Intake</span>
                                    <span class="sp-quick-stat__value"><asp:Literal ID="litIntake" runat="server" /></span>
                                </div>
                            </div>
                            <!-- Full Edit Button -->
                        </div>
                        <div style="margin-left:auto;flex-shrink:0;padding-top:4px;">
                            <a id="lnkFullEdit" runat="server" class="nsr-btn" style="display:inline-flex;align-items:center;gap:6px;padding:7px 16px;background:#e65100;color:#fff;border-radius:6px;font-size:12px;font-weight:600;text-decoration:none;cursor:pointer;border:none;white-space:nowrap;"
                               title="Open full edit form for this student">
                                <svg xmlns="http://www.w3.org/2000/svg" width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"></path><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"></path></svg>
                                Full Edit
                            </a>
                        </div>
                    </div>
                    
                    <!-- Tabs (Wrapped for scrolling) -->
                    <div class="sp-profile-tabs-wrapper">
                        <dx:ASPxPageControl ID="tabStudentProfile" runat="server" ActiveTabIndex="0" Width="100%" EnableTabScrolling="True">
                            <TabStyle Font-Size="10px" Paddings-PaddingLeft="8px" Paddings-PaddingRight="8px" Paddings-PaddingTop="4px" Paddings-PaddingBottom="4px" />
                            <ActiveTabStyle BackColor="#fff" ForeColor="#174DA4" Font-Bold="true" />
                            <TabPages>
                                <dx:TabPage Text="Bio Data">
                                    <ContentCollection>
                                        <dx:ContentControl runat="server">
                                            <div class="sp-tab-content">
                                                <div class="sp-bio-section">
                                                    <h4 class="sp-bio-section__title">Personal Information</h4>
                                                    <div class="sp-bio-grid">
                                                        <div class="sp-bio-field">
                                                            <span class="sp-bio-field__label">Registration Number</span>
                                                            <span class="sp-bio-field__value"><asp:Literal ID="litBioRegNo" runat="server" /></span>
                                                        </div>
                                                        <div class="sp-bio-field">
                                                            <span class="sp-bio-field__label">Entry Number</span>
                                                            <span class="sp-bio-field__value"><asp:Literal ID="litBioEntryNo" runat="server" /></span>
                                                        </div>
                                                        <div class="sp-bio-field">
                                                            <span class="sp-bio-field__label">Full Name</span>
                                                            <span class="sp-bio-field__value"><asp:Literal ID="litBioFullName" runat="server" /></span>
                                                        </div>
                                                        <div class="sp-bio-field">
                                                            <span class="sp-bio-field__label">Gender</span>
                                                            <span class="sp-bio-field__value"><asp:Literal ID="litBioGender" runat="server" /></span>
                                                        </div>
                                                        <div class="sp-bio-field">
                                                            <span class="sp-bio-field__label">Date of Birth</span>
                                                            <span class="sp-bio-field__value"><asp:Literal ID="litBioDOB" runat="server" /></span>
                                                        </div>
                                                        <div class="sp-bio-field">
                                                            <span class="sp-bio-field__label">Nationality</span>
                                                            <span class="sp-bio-field__value"><asp:Literal ID="litBioNationality" runat="server" /></span>
                                                        </div>
                                                        <div class="sp-bio-field">
                                                            <span class="sp-bio-field__label">Religion</span>
                                                            <span class="sp-bio-field__value"><asp:Literal ID="litBioReligion" runat="server" /></span>
                                                        </div>
                                                        <div class="sp-bio-field">
                                                            <span class="sp-bio-field__label">Home District</span>
                                                            <span class="sp-bio-field__value"><asp:Literal ID="litBioDistrict" runat="server" /></span>
                                                        </div>
                                                    <div class="sp-bio-field">
                                                        <span class="sp-bio-field__label">Entry Method</span>
                                                        <span class="sp-bio-field__value"><asp:Literal ID="litBioEntryMethod" runat="server" /></span>
                                                    </div>
                                                </div>
                                            </div>
                                            
                                            <div class="sp-bio-section">
                                                <h4 class="sp-bio-section__title">Contact Information</h4>
                                                <div class="sp-bio-grid">
                                                    <div class="sp-bio-field">
                                                        <span class="sp-bio-field__label">Phone Number</span>
                                                        <span class="sp-bio-field__value"><asp:Literal ID="litBioPhone" runat="server" /></span>
                                                    </div>
                                                    <div class="sp-bio-field">
                                                        <span class="sp-bio-field__label">Email Address</span>
                                                        <span class="sp-bio-field__value"><asp:Literal ID="litBioEmail" runat="server" /></span>
                                                    </div>
                                                </div>
                                            </div>
                                            
                                            <div class="sp-bio-section">
                                                <h4 class="sp-bio-section__title">Academic Information</h4>
                                                <div class="sp-bio-grid">
                                                    <div class="sp-bio-field">
                                                        <span class="sp-bio-field__label">Programme</span>
                                                        <span class="sp-bio-field__value"><asp:Literal ID="litBioProgramme" runat="server" /></span>
                                                    </div>
                                                    <div class="sp-bio-field">
                                                        <span class="sp-bio-field__label">Specialisation</span>
                                                        <span class="sp-bio-field__value"><asp:Literal ID="litBioSpecialisation" runat="server" /></span>
                                                    </div>
                                                    <div class="sp-bio-field">
                                                        <span class="sp-bio-field__label">Entry Year</span>
                                                        <span class="sp-bio-field__value"><asp:Literal ID="litBioEntryYear" runat="server" /></span>
                                                    </div>
                                                    <div class="sp-bio-field">
                                                        <span class="sp-bio-field__label">Intake</span>
                                                        <span class="sp-bio-field__value"><asp:Literal ID="litBioIntake" runat="server" /></span>
                                                    </div>
                                                    <div class="sp-bio-field">
                                                        <span class="sp-bio-field__label">Study Session</span>
                                                        <span class="sp-bio-field__value"><asp:Literal ID="litBioSession" runat="server" /></span>
                                                    </div>
                                                    <div class="sp-bio-field">
                                                        <span class="sp-bio-field__label">Campus</span>
                                                        <span class="sp-bio-field__value"><asp:Literal ID="litBioCampus" runat="server" /></span>
                                                    </div>
                                                    <div class="sp-bio-field">
                                                        <span class="sp-bio-field__label">Grading System</span>
                                                        <span class="sp-bio-field__value"><asp:Literal ID="litBioGradingSystem" runat="server" /></span>
                                                    </div>
                                                    <div class="sp-bio-field">
                                                        <span class="sp-bio-field__label">Course Duration</span>
                                                        <span class="sp-bio-field__value"><asp:Literal ID="litBioDuration" runat="server" /></span>
                                                    </div>
                                                    <div class="sp-bio-field">
                                                        <span class="sp-bio-field__label">Student Hall</span>
                                                        <span class="sp-bio-field__value"><asp:Literal ID="litBioHall" runat="server" /></span>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    </dx:ContentControl>
                                </ContentCollection>
                            </dx:TabPage>
                                
                                <dx:TabPage Text="Curriculum">
                                    <ContentCollection>
                                        <dx:ContentControl runat="server">
                                            <div class="sp-tab-content" style="padding: 0;">
                                                <div class="sp-curriculum-header">
                                                    <div class="sp-curriculum-info-card">
                                                        <div class="sp-curriculum-info-card__label">Programme</div>
                                                        <div class="sp-curriculum-info-card__value"><asp:Literal ID="litCurrProgramme" runat="server" /></div>
                                                        <div class="sp-curriculum-info-card__sub"><asp:Literal ID="litCurrProgCode" runat="server" /></div>
                                                    </div>
                                                    <div class="sp-curriculum-info-card">
                                                        <div class="sp-curriculum-info-card__label">Specialisation</div>
                                                        <div class="sp-curriculum-info-card__value">
                                                            <asp:Literal ID="litCurrSpecialisation" runat="server" />
                                                            <asp:Literal ID="litCurrSpecBadge" runat="server" />
                                                        </div>
                                                        <div class="sp-curriculum-info-card__sub"><asp:Literal ID="litCurrSpecNote" runat="server" /></div>
                                                    </div>
                                                    <div class="sp-curriculum-stats">
                                                        <div class="sp-curriculum-stat">
                                                            <div class="sp-curriculum-stat__value"><asp:Literal ID="litCurrTotalCourses" runat="server">0</asp:Literal></div>
                                                            <div class="sp-curriculum-stat__label">Courses</div>
                                                        </div>
                                                        <div class="sp-curriculum-stat">
                                                            <div class="sp-curriculum-stat__value"><asp:Literal ID="litCurrTotalCredits" runat="server">0</asp:Literal></div>
                                                            <div class="sp-curriculum-stat__label">Credits</div>
                                                        </div>
                                                        <div class="sp-curriculum-stat">
                                                            <div class="sp-curriculum-stat__value"><asp:Literal ID="litCurrCoreCourses" runat="server">0</asp:Literal></div>
                                                            <div class="sp-curriculum-stat__label">Core</div>
                                                        </div>
                                                        <div class="sp-curriculum-stat">
                                                            <div class="sp-curriculum-stat__value"><asp:Literal ID="litCurrElectives" runat="server">0</asp:Literal></div>
                                                            <div class="sp-curriculum-stat__label">Elective</div>
                                                        </div>
                                                    </div>
                                                </div>
                                                
                                                <div class="sp-curriculum-grid">
                                                    <asp:Literal ID="litCurriculumContent" runat="server" />
                                                </div>
                                                
                                                <asp:Panel ID="pnlNoCurriculum" runat="server" Visible="false" CssClass="sp-empty">
                                                    <svg xmlns="http://www.w3.org/2000/svg" width="40" height="40" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"></path><path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z"></path></svg>
                                                    <div>No curriculum defined for this specialisation</div>
                                                </asp:Panel>
                                            </div>
                                        </dx:ContentControl>
                                    </ContentCollection>
                                </dx:TabPage>
                            
                            <dx:TabPage Text="Academic Results">
                                <ContentCollection>
                                    <dx:ContentControl runat="server">
                                        <div style="padding: 12px;">
                                            <div class="sp-results-summary" style="display:flex;align-items:center;gap:24px;padding:8px 12px;background:#f8f9fa;border:1px solid #e9ecef;margin-bottom:12px;">
                                                <div style="display:flex;align-items:center;gap:6px;">
                                                    <span style="font-weight:600;color:#666;font-size:11px;">GPA:</span>
                                                    <span style="font-weight:700;color:#174DA4;font-size:13px;"><asp:Literal ID="litGPA" runat="server" Text="0.00" /></span>
                                                </div>
                                                <div style="display:flex;align-items:center;gap:6px;">
                                                    <span style="font-weight:600;color:#666;font-size:11px;">CGPA:</span>
                                                    <span style="font-weight:700;color:#174DA4;font-size:13px;"><asp:Literal ID="litCGPA" runat="server" Text="0.00" /></span>
                                                </div>
                                                <div style="display:flex;align-items:center;gap:6px;">
                                                    <span style="font-weight:600;color:#666;font-size:11px;">CURRENT CLASS:</span>
                                                    <span style="font-weight:700;color:#dc3545;font-size:13px;"><asp:Literal ID="litAwardClass" runat="server" Text="-" /></span>
                                                </div>
                                                <div style="margin-left:auto;display:flex;gap:16px;">
                                                    <span style="font-size:11px;color:#666;">Credits: <strong style="color:#333;"><asp:Literal ID="litTotalCredits" runat="server" Text="0" /></strong></span>
                                                    <span style="font-size:11px;color:#28a745;">Passed: <strong><asp:Literal ID="litCoursesPassed" runat="server" Text="0" /></strong></span>
                                                    <span style="font-size:11px;color:#dc3545;">Failed: <strong><asp:Literal ID="litCoursesFailed" runat="server" Text="0" /></strong></span>
                                                </div>
                                            </div>
                                            <asp:Repeater ID="rptResultsSemesters" runat="server">
                                                <ItemTemplate>
                                                    <div class="sp-semester-group">
                                                        <div class="sp-semester-group__header">
                                                            Year <%# Eval("year") %> - Semester <%# Eval("semester") %> 
                                                            <span style="float:right;font-weight:normal;">GPA: <%# Eval("gpa", "{0:F2}") %></span>
                                                        </div>
                                                        <table class="sp-data-table sp-data-table--results">
                                                            <thead>
                                                                <tr>
                                                                    <th style="width:100px;">Code</th>
                                                                    <th>Course Title</th>
                                                                    <th style="width:50px;text-align:center;">CU</th>
                                                                    <th style="width:50px;text-align:center;">Mark</th>
                                                                    <th style="width:50px;text-align:center;">Grade</th>
                                                                    <th style="width:50px;text-align:center;">GP</th>
                                                                </tr>
                                                            </thead>
                                                            <tbody>
                                                                <asp:Repeater ID="rptCourses" runat="server" DataSource='<%# Eval("courses") %>'>
                                                                    <ItemTemplate>
                                                                        <tr>
                                                                            <td><%# Eval("course_code") %></td>
                                                                            <td><%# Eval("course_title") %></td>
                                                                            <td style="text-align:center;"><%# Eval("credits") %></td>
                                                                            <td style="text-align:center;"><%# Eval("mark") %></td>
                                                                            <td class="grade grade-<%# Eval("grade") %>"><%# Eval("grade") %></td>
                                                                            <td style="text-align:center;"><%# Eval("gp", "{0:F1}") %></td>
                                                                        </tr>
                                                                    </ItemTemplate>
                                                                </asp:Repeater>
                                                            </tbody>
                                                        </table>
                                                    </div>
                                                </ItemTemplate>
                                            </asp:Repeater>
                                            <asp:Panel ID="pnlNoResults" runat="server" Visible="false" CssClass="sp-empty">
                                                <svg xmlns="http://www.w3.org/2000/svg" width="40" height="40" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path><polyline points="14 2 14 8 20 8"></polyline><line x1="16" y1="13" x2="8" y2="13"></line><line x1="16" y1="17" x2="8" y2="17"></line></svg>
                                                <div>No results found for this student</div>
                                            </asp:Panel>
                                        </div>
                                    </dx:ContentControl>
                                </ContentCollection>
                            </dx:TabPage>
                            
                            <dx:TabPage Text="All Results (Direct)">
                                <ContentCollection>
                                    <dx:ContentControl runat="server">
                                        <div style="padding: 12px;">
                                            <!-- Action Bar with Print Button -->
                                            <div style="display:flex;align-items:center;justify-content:space-between;margin-bottom:12px;padding:10px 12px;background:linear-gradient(135deg, #174DA4 0%, #2980b9 100%);border-radius:6px;">
                                                <div style="display:flex;align-items:center;gap:16px;">
                                                    <span style="color:#fff;font-weight:600;font-size:13px;">
                                                        <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="vertical-align:middle;margin-right:6px;"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path><polyline points="14 2 14 8 20 8"></polyline><line x1="16" y1="13" x2="8" y2="13"></line><line x1="16" y1="17" x2="8" y2="17"></line></svg>
                                                        Direct Results View
                                                    </span>
                                                    <span style="color:rgba(255,255,255,0.8);font-size:11px;">
                                                        All results from Faculty Results table - No filters applied
                                                    </span>
                                                </div>
                                                <div style="display:flex;gap:8px;">
                                                    <asp:Button ID="btnPrintProvisional" runat="server" Text="📄 Print Provisional Results" 
                                                        OnClick="btnPrintProvisional_Click"
                                                        style="background:#28a745;border:none;color:#fff;padding:8px 16px;border-radius:4px;cursor:pointer;font-size:12px;font-weight:500;" />
                                                    <asp:Button ID="btnPrintTranscript" runat="server" Text="📋 Print Transcript" 
                                                        OnClick="btnPrintTranscript_Click"
                                                        style="background:#fff;border:none;color:#174DA4;padding:8px 16px;border-radius:4px;cursor:pointer;font-size:12px;font-weight:500;" />
                                                </div>
                                            </div>
                                            
                                            <!-- Summary Statistics -->
                                            <div class="sp-results-summary" style="display:flex;align-items:center;gap:24px;padding:10px 14px;background:#f8f9fa;border:1px solid #e9ecef;margin-bottom:12px;border-radius:4px;">
                                                <div style="display:flex;align-items:center;gap:6px;">
                                                    <span style="font-weight:600;color:#666;font-size:11px;">TOTAL COURSES:</span>
                                                    <span style="font-weight:700;color:#174DA4;font-size:14px;"><asp:Literal ID="litDirectTotalCourses" runat="server" Text="0" /></span>
                                                </div>
                                                <div style="display:flex;align-items:center;gap:6px;">
                                                    <span style="font-weight:600;color:#666;font-size:11px;">AVG. MARK:</span>
                                                    <span style="font-weight:700;color:#174DA4;font-size:14px;"><asp:Literal ID="litDirectAvgMark" runat="server" Text="0.0" /></span>
                                                </div>
                                                <div style="display:flex;align-items:center;gap:6px;">
                                                    <span style="font-weight:600;color:#666;font-size:11px;">EST. GPA:</span>
                                                    <span style="font-weight:700;color:#174DA4;font-size:14px;"><asp:Literal ID="litDirectGPA" runat="server" Text="0.00" /></span>
                                                </div>
                                                <div style="margin-left:auto;display:flex;gap:20px;">
                                                    <span style="font-size:11px;color:#28a745;">✓ Passed: <strong><asp:Literal ID="litDirectPassed" runat="server" Text="0" /></strong></span>
                                                    <span style="font-size:11px;color:#dc3545;">✗ Failed: <strong><asp:Literal ID="litDirectFailed" runat="server" Text="0" /></strong></span>
                                                    <span style="font-size:11px;color:#6c757d;">⏳ Pending: <strong><asp:Literal ID="litDirectPending" runat="server" Text="0" /></strong></span>
                                                </div>
                                            </div>
                                            
                                            <!-- Results Table - Grouped by Academic Year/Semester -->
                                            <asp:Repeater ID="rptDirectResultsSemesters" runat="server">
                                                <ItemTemplate>
                                                    <div class="sp-semester-group" style="margin-bottom:16px;">
                                                        <div class="sp-semester-group__header" style="background:#174DA4;color:#fff;padding:8px 12px;font-weight:600;font-size:12px;display:flex;justify-content:space-between;align-items:center;">
                                                            <span><%# Eval("acad_year") %> - Semester <%# Eval("semester") %></span>
                                                            <span style="font-weight:normal;font-size:11px;">
                                                                <%# Eval("course_count") %> course(s) | GPA: <%# Eval("gpa", "{0:F2}") %>
                                                            </span>
                                                        </div>
                                                        <table class="sp-data-table sp-data-table--results" style="border:1px solid #dee2e6;">
                                                            <thead>
                                                                <tr style="background:#e9ecef;">
                                                                    <th style="width:100px;">Code</th>
                                                                    <th>Course Title</th>
                                                                    <th style="width:50px;text-align:center;">CU</th>
                                                                    <th style="width:50px;text-align:center;">CA</th>
                                                                    <th style="width:50px;text-align:center;">Exam</th>
                                                                    <th style="width:50px;text-align:center;">Final</th>
                                                                    <th style="width:50px;text-align:center;">Grade</th>
                                                                    <th style="width:50px;text-align:center;">GP</th>
                                                                    <th style="width:80px;text-align:center;">Status</th>
                                                                </tr>
                                                            </thead>
                                                            <tbody>
                                                                <asp:Repeater ID="rptDirectCourses" runat="server" DataSource='<%# Eval("courses") %>'>
                                                                    <ItemTemplate>
                                                                        <tr>
                                                                            <td style="font-weight:500;color:#174DA4;"><%# Eval("course_code") %></td>
                                                                            <td><%# Eval("course_title") %></td>
                                                                            <td style="text-align:center;"><%# Eval("credits") %></td>
                                                                            <td style="text-align:center;"><%# Eval("ca_mark") %></td>
                                                                            <td style="text-align:center;"><%# Eval("exam_mark") %></td>
                                                                            <td style="text-align:center;font-weight:600;"><%# Eval("final_mark") %></td>
                                                                            <td class="grade grade-<%# Eval("grade") %>" style="text-align:center;font-weight:700;"><%# Eval("grade") %></td>
                                                                            <td style="text-align:center;"><%# Eval("gp", "{0:F1}") %></td>
                                                                            <td style="text-align:center;"><%# GetDirectStatusBadge(Eval("approved_by")) %></td>
                                                                        </tr>
                                                                    </ItemTemplate>
                                                                </asp:Repeater>
                                                            </tbody>
                                                        </table>
                                                    </div>
                                                </ItemTemplate>
                                            </asp:Repeater>
                                            
                                            <asp:Panel ID="pnlNoDirectResults" runat="server" Visible="false" CssClass="sp-empty">
                                                <svg xmlns="http://www.w3.org/2000/svg" width="40" height="40" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"></circle><line x1="12" y1="8" x2="12" y2="12"></line><line x1="12" y1="16" x2="12.01" y2="16"></line></svg>
                                                <div style="margin-top:12px;font-weight:500;">No results found in Faculty Results table</div>
                                                <div style="color:#6c757d;font-size:11px;margin-top:4px;">This student may not have any exam results recorded yet.</div>
                                            </asp:Panel>
                                        </div>
                                    </dx:ContentControl>
                                </ContentCollection>
                            </dx:TabPage>
                                
                                <dx:TabPage Text="Validation">
                                    <ContentCollection>
                                        <dx:ContentControl runat="server">
                                            <div class="sp-tab-content" style="padding: 0;">
                                                <div class="sp-curriculum-header">
                                                    <div class="sp-curriculum-info-card">
                                                        <div class="sp-curriculum-info-card__label">Programme</div>
                                                        <div class="sp-curriculum-info-card__value"><asp:Literal ID="litChkProgramme" runat="server" /></div>
                                                        <div class="sp-curriculum-info-card__sub"><asp:Literal ID="litChkProgCode" runat="server" /></div>
                                                    </div>
                                                    <div class="sp-curriculum-info-card">
                                                        <div class="sp-curriculum-info-card__label">Specialisation</div>
                                                        <div class="sp-curriculum-info-card__value">
                                                            <asp:Literal ID="litChkSpecialisation" runat="server" />
                                                            <asp:Literal ID="litChkSpecBadge" runat="server" />
                                                        </div>
                                                        <div class="sp-curriculum-info-card__sub"><asp:Literal ID="litChkSpecNote" runat="server" /></div>
                                                    </div>
                                                    <div class="sp-curriculum-stats">
                                                        <div class="sp-curriculum-stat">
                                                            <div class="sp-curriculum-stat__value"><asp:Literal ID="litChkTotalCourses" runat="server">0</asp:Literal></div>
                                                            <div class="sp-curriculum-stat__label">Courses</div>
                                                        </div>
                                                        <div class="sp-curriculum-stat">
                                                            <div class="sp-curriculum-stat__value"><asp:Literal ID="litChkTotalCredits" runat="server">0</asp:Literal></div>
                                                            <div class="sp-curriculum-stat__label">Credits</div>
                                                        </div>
                                                        <div class="sp-curriculum-stat">
                                                            <div class="sp-curriculum-stat__value"><asp:Literal ID="litChkCoreCourses" runat="server">0</asp:Literal></div>
                                                            <div class="sp-curriculum-stat__label">Core</div>
                                                        </div>
                                                        <div class="sp-curriculum-stat">
                                                            <div class="sp-curriculum-stat__value"><asp:Literal ID="litChkElectives" runat="server">0</asp:Literal></div>
                                                            <div class="sp-curriculum-stat__label">Elective</div>
                                                        </div>
                                                    </div>
                                                </div>
                                                
                                                <div class="sp-curriculum-grid">
                                                    <asp:Literal ID="litCheckerContent" runat="server" />
                                                </div>
                                                
                                                <asp:Panel ID="pnlNoChecker" runat="server" Visible="false" CssClass="sp-empty">
                                                    <svg xmlns="http://www.w3.org/2000/svg" width="40" height="40" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"></path><path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z"></path></svg>
                                                    <div>No curriculum defined for this specialisation</div>
                                                </asp:Panel>
                                            </div>
                                        </dx:ContentControl>
                                    </ContentCollection>
                                </dx:TabPage>
                            
                            <dx:TabPage Text="Faculty Registration">
                                <ContentCollection>
                                    <dx:ContentControl runat="server">
                                        <div class="sp-tab-content">
                                            <table class="sp-data-table">
                                                <thead>
                                                    <tr>
                                                        <th style="width:80px;">Acad Year</th>
                                                        <th style="width:50px;">Sem</th>
                                                        <th style="width:50px;">Year</th>
                                                        <th>Remarks</th>
                                                        <th style="width:80px;">Reg Date</th>
                                                        <th style="width:80px;text-align:center;">Exam Clear</th>
                                                        <th style="width:80px;text-align:center;">Reg Clear</th>
                                                    </tr>
                                                </thead>
                                                <tbody>
                                                    <asp:Repeater ID="rptRegistrations" runat="server">
                                                        <ItemTemplate>
                                                            <tr>
                                                                <td><%# Eval("academic_year") %></td>
                                                                <td><%# Eval("semester") %></td>
                                                                <td><%# Eval("study_year") %></td>
                                                                <td><%# Eval("remarks") %></td>
                                                                <td><%# Eval("reg_date", "{0:dd/MM/yyyy}") %></td>
                                                                <td style="text-align:center;">
                                                                    <%# Convert.ToBoolean(Eval("exam_clearance")) ? "<span style='color:#28a745;'>✓</span>" : "<span style='color:#dc3545;'>✗</span>" %>
                                                                </td>
                                                                <td style="text-align:center;">
                                                                    <%# Convert.ToBoolean(Eval("reg_clearance")) ? "<span style='color:#28a745;'>✓</span>" : "<span style='color:#dc3545;'>✗</span>" %>
                                                                </td>
                                                            </tr>
                                                        </ItemTemplate>
                                                    </asp:Repeater>
                                                </tbody>
                                            </table>
                                            <asp:Panel ID="pnlNoRegistrations" runat="server" Visible="false" CssClass="sp-empty">
                                                <svg xmlns="http://www.w3.org/2000/svg" width="40" height="40" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"></rect><line x1="16" y1="2" x2="16" y2="6"></line><line x1="8" y1="2" x2="8" y2="6"></line><line x1="3" y1="10" x2="21" y2="10"></line></svg>
                                                <div>No faculty registration records found</div>
                                            </asp:Panel>
                                        </div>
                                    </dx:ContentControl>
                                </ContentCollection>
                            </dx:TabPage>
                            
                            <dx:TabPage Text="Course Registration">
                                <ContentCollection>
                                    <dx:ContentControl runat="server">
                                        <div class="sp-tab-content">
                                            <asp:Repeater ID="rptCourseRegSemesters" runat="server">
                                                <ItemTemplate>
                                                    <div class="sp-semester-group">
                                                        <div class="sp-semester-group__header">
                                                            <%# Eval("academic_year") %> - Semester <%# Eval("semester") %>
                                                            <span style="float:right;font-weight:normal;"><%# Eval("course_count") %> courses</span>
                                                        </div>
                                                        <table class="sp-data-table">
                                                            <thead>
                                                                <tr>
                                                                    <th style="width:100px;">Code</th>
                                                                    <th>Course Title</th>
                                                                    <th style="width:50px;text-align:center;">CU</th>
                                                                    <th style="width:80px;">Type</th>
                                                                    <th style="width:100px;">Reg Date</th>
                                                                </tr>
                                                            </thead>
                                                            <tbody>
                                                                <asp:Repeater ID="rptRegCourses" runat="server" DataSource='<%# Eval("courses") %>'>
                                                                    <ItemTemplate>
                                                                        <tr>
                                                                            <td><%# Eval("course_code") %></td>
                                                                            <td><%# Eval("course_title") %></td>
                                                                            <td style="text-align:center;"><%# Eval("credits") %></td>
                                                                            <td><%# Eval("course_type") %></td>
                                                                            <td><%# Eval("reg_date", "{0:dd/MM/yyyy}") %></td>
                                                                        </tr>
                                                                    </ItemTemplate>
                                                                </asp:Repeater>
                                                            </tbody>
                                                        </table>
                                                    </div>
                                                </ItemTemplate>
                                            </asp:Repeater>
                                            <asp:Panel ID="pnlNoCourseReg" runat="server" Visible="false" CssClass="sp-empty">
                                                <svg xmlns="http://www.w3.org/2000/svg" width="40" height="40" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"></path><path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z"></path></svg>
                                                <div>No course registration records found</div>
                                            </asp:Panel>
                                        </div>
                                    </dx:ContentControl>
                                </ContentCollection>
                            </dx:TabPage>
                            
                            <dx:TabPage Text="Fees Ledger">
                                <ContentCollection>
                                    <dx:ContentControl runat="server">
                                        <div class="sp-tab-content">
                                            <div class="sp-summary-row">
                                                <div class="sp-summary-card">
                                                    <div class="sp-summary-card__label">Total Invoiced</div>
                                                    <div class="sp-summary-card__value"><asp:Literal ID="litTotalInvoiced" runat="server" Text="0" /></div>
                                                </div>
                                                <div class="sp-summary-card">
                                                    <div class="sp-summary-card__label">Total Paid</div>
                                                    <div class="sp-summary-card__value"><asp:Literal ID="litTotalPaid" runat="server" Text="0" /></div>
                                                </div>
                                                <div class="sp-summary-card" style="border-left-color: #dc3545;">
                                                    <div class="sp-summary-card__label">Balance Due</div>
                                                    <div class="sp-summary-card__value" style="color: #dc3545;"><asp:Literal ID="litBalance" runat="server" Text="0" /></div>
                                                </div>
                                            </div>
                                            <table class="sp-data-table">
                                                <thead>
                                                    <tr>
                                                        <th style="width:90px;">Date</th>
                                                        <th style="width:100px;">Reference</th>
                                                        <th>Description</th>
                                                        <th style="width:100px;text-align:right;">Debit</th>
                                                        <th style="width:100px;text-align:right;">Credit</th>
                                                        <th style="width:100px;text-align:right;">Balance</th>
                                                    </tr>
                                                </thead>
                                                <tbody>
                                                    <asp:Repeater ID="rptFeesLedger" runat="server">
                                                        <ItemTemplate>
                                                            <tr>
                                                                <td><%# Eval("trans_date") %></td>
                                                                <td><%# Eval("reference") %></td>
                                                                <td><%# Eval("description") %></td>
                                                                <td style="text-align:right;"><%# FormatAmount(Eval("debit")) %></td>
                                                                <td style="text-align:right;"><%# FormatAmount(Eval("credit")) %></td>
                                                                <td style="text-align:right;font-weight:600;"><%# FormatBalance(Eval("running_balance")) %></td>
                                                            </tr>
                                                        </ItemTemplate>
                                                    </asp:Repeater>
                                                </tbody>
                                            </table>
                                            <asp:Panel ID="pnlNoFees" runat="server" Visible="false" CssClass="sp-empty">
                                                <svg xmlns="http://www.w3.org/2000/svg" width="40" height="40" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="1" x2="12" y2="23"></line><path d="M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6"></path></svg>
                                                <div>No fees ledger records found</div>
                                            </asp:Panel>
                                        </div>
                                    </dx:ContentControl>
                                </ContentCollection>
                            </dx:TabPage>
                            
                            <dx:TabPage Text="Thesis &amp; Supervisor">
                                <ContentCollection>
                                    <dx:ContentControl runat="server">
                                        <div class="sp-tab-content">
                                            <!-- Status Bar -->
                                            <div class="sp-thesis-status-bar">
                                                <span style="font-size:10px;font-weight:600;color:#555;">RESEARCH STATUS:</span>
                                                <asp:Literal ID="litThesisStatusBadge" runat="server" />
                                                <span style="margin-left:auto;font-size:10px;color:#888;">
                                                    Supervisor: <asp:Literal ID="litCurrentSupervisorName" runat="server" Text="Not Assigned" />
                                                </span>
                                            </div>
                                            
                                            <div class="sp-thesis-form">
                                                <!-- Current Thesis Display -->
                                                <div class="sp-thesis-current">
                                                    <div class="sp-thesis-current__label">Current Thesis Title</div>
                                                    <div>
                                                        <asp:Literal ID="litCurrentThesisTitle" runat="server" />
                                                    </div>
                                                </div>
                                                
                                                <!-- Edit Form -->
                                                <div class="sp-thesis-field">
                                                    <label>Thesis / Dissertation Title</label>
                                                    <asp:TextBox ID="txtThesisTitleEdit" runat="server" TextMode="MultiLine" 
                                                        Rows="3" CssClass="sp-thesis-field-input"
                                                        placeholder="Enter the thesis or dissertation title..." />
                                                </div>
                                                
                                                <div class="sp-thesis-field">
                                                    <label>Supervisor</label>
                                                    <asp:TextBox ID="txtSupervisorEdit" runat="server" 
                                                        placeholder="Enter supervisor name..." />
                                                </div>
                                                
                                                <div class="sp-thesis-field">
                                                    <label>Research Status</label>
                                                    <asp:DropDownList ID="ddlResearchStatus" runat="server">
                                                        <asp:ListItem Text="-- Select Status --" Value="" />
                                                        <asp:ListItem Text="In Progress" Value="In Progress" />
                                                        <asp:ListItem Text="Completed" Value="Completed" />
                                                        <asp:ListItem Text="Submitted" Value="Submitted" />
                                                        <asp:ListItem Text="Defended" Value="Defended" />
                                                        <asp:ListItem Text="Revisions Required" Value="Revisions Required" />
                                                    </asp:DropDownList>
                                                </div>
                                                
                                                <div class="sp-thesis-actions">
                                                    <asp:Button ID="btnSaveThesis" runat="server" Text="Save Thesis Info" 
                                                        CssClass="sp-thesis-btn sp-thesis-btn--save" 
                                                        OnClick="btnSaveThesis_Click" />
                                                </div>
                                                
                                                <asp:Panel ID="pnlThesisMessage" runat="server" Visible="false">
                                                    <asp:Literal ID="litThesisMessage" runat="server" />
                                                </asp:Panel>
                                            </div>
                                            
                                            <!-- No thesis record state -->
                                            <asp:Panel ID="pnlNoThesis" runat="server" Visible="false" CssClass="sp-empty">
                                                <svg xmlns="http://www.w3.org/2000/svg" width="40" height="40" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M2 3h6a4 4 0 0 1 4 4v14a3 3 0 0 0-3-3H2z"></path><path d="M22 3h-6a4 4 0 0 0-4 4v14a3 3 0 0 1 3-3h7z"></path></svg>
                                                <div>No thesis/research record found for this student.<br/>Use the form above to add thesis information.</div>
                                            </asp:Panel>
                                        </div>
                                    </dx:ContentControl>
                                </ContentCollection>
                            </dx:TabPage>
                        </TabPages>
                    </dx:ASPxPageControl>
                    </div><!-- End of .sp-profile-tabs-wrapper -->
                </asp:Panel>
            </dx:PopupControlContentControl>
        </ContentCollection>
    </dx:ASPxPopupControl>
    
    <!-- Photo Lightbox -->
    <asp:HiddenField ID="hdnDefaultPhotoUrl" runat="server" />
    <div id="photoLightbox" class="cd-lightbox-overlay">
        <div class="cd-lightbox">
            <button type="button" class="cd-lightbox__close" onclick="closeLightbox()">&times;</button>
            <img id="lightboxImg" class="cd-lightbox__img" src="" alt="Student Photo" />
            <div class="cd-lightbox__caption">
                <div id="lightboxName" class="cd-lightbox__name"></div>
                <div id="lightboxRegno" class="cd-lightbox__regno"></div>
            </div>
        </div>
    </div>
    
    <!-- Set Password Modal -->
    <div id="setPasswordOverlay" class="cd-modal-overlay">
        <div class="cd-modal" style="max-width: 420px;">
            <div class="cd-modal__header">
                <h3 class="cd-modal__title">
                    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="margin-right: 6px;"><rect x="3" y="11" width="18" height="11" rx="2" ry="2"></rect><path d="M7 11V7a5 5 0 0 1 10 0v4"></path></svg>
                    Set Password
                </h3>
                <button type="button" class="cd-modal__close" onclick="closeSetPasswordModal()">&times;</button>
            </div>
            <div class="cd-modal__body">
                <!-- Student Info -->
                <div style="background: #f0f4ff; border: 1px solid #c4d9f8; padding: 10px 12px; margin-bottom: 14px;">
                    <div style="font-size: 10px; color: #666; text-transform: uppercase; font-weight: 600; margin-bottom: 2px;">Student</div>
                    <div id="spStudentName" style="font-size: 13px; font-weight: 600; color: #333;"></div>
                    <div id="spStudentRegno" style="font-size: 11px; color: #174DA4; font-weight: 500;"></div>
                </div>
                
                <!-- Password Fields -->
                <div class="cd-form-group">
                    <label class="cd-form-label">New Password</label>
                    <div style="position: relative;">
                        <input type="password" id="spNewPassword" class="cd-form-input" placeholder="Enter new password" autocomplete="new-password" />
                        <button type="button" class="cd-pwd-toggle" onclick="togglePasswordVisibility('spNewPassword', this)" title="Show/Hide password">
                            <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"></path><circle cx="12" cy="12" r="3"></circle></svg>
                        </button>
                    </div>
                </div>
                <div class="cd-form-group">
                    <label class="cd-form-label">Confirm Password</label>
                    <div style="position: relative;">
                        <input type="password" id="spConfirmPassword" class="cd-form-input" placeholder="Confirm new password" autocomplete="new-password" />
                        <button type="button" class="cd-pwd-toggle" onclick="togglePasswordVisibility('spConfirmPassword', this)" title="Show/Hide password">
                            <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"></path><circle cx="12" cy="12" r="3"></circle></svg>
                        </button>
                    </div>
                </div>
                
                <!-- Status Message -->
                <div id="spStatusMsg" style="display: none; padding: 8px 10px; font-size: 11px; margin-top: 8px;"></div>
            </div>
            <div class="cd-modal__footer">
                <button type="button" class="cd-btn cd-btn--outline" onclick="closeSetPasswordModal()">Cancel</button>
                <button type="button" id="btnSetPassword" class="cd-btn cd-btn--primary" onclick="submitSetPassword()">
                    <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="margin-right: 4px;"><path d="M19 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11l5 5v11a2 2 0 0 1-2 2z"></path><polyline points="17 21 17 13 7 13 7 21"></polyline><polyline points="7 3 7 8 15 8"></polyline></svg>
                    Set Password
                </button>
            </div>
        </div>
    </div>
    
    <script type="text/javascript">
        function toggleActionPopover(btn, e) {
            if (e) {
                e.preventDefault();
                e.stopPropagation();
            }
            
            var wrapper = btn.parentElement;
            var popover = wrapper.querySelector('.cd-action-popover');
            
            if (!popover) return;
            
            // Close all other popovers first
            document.querySelectorAll('.cd-action-popover.show').forEach(function(p) {
                if (p !== popover) p.classList.remove('show');
            });
            
            // Toggle this popover
            popover.classList.toggle('show');
            
            // Position check
            if (popover.classList.contains('show')) {
                var rect = popover.getBoundingClientRect();
                if (rect.bottom > window.innerHeight) {
                    popover.classList.add('cd-action-popover--top');
                } else {
                    popover.classList.remove('cd-action-popover--top');
                }
            }
        }
        
        function gridEditRow(gridName, keyValue) {
            var grid = ASPxClientControl.GetControlCollection().GetByName(gridName);
            if (grid) {
                grid.StartEditRowByKey(keyValue);
            }
            closeAllPopovers();
        }
        
        function closeAllPopovers() {
            document.querySelectorAll('.cd-action-popover.show').forEach(function(p) {
                p.classList.remove('show');
            });
        }
        
        // Close popovers when clicking outside
        document.addEventListener('click', function(e) {
            if (!e.target.closest('.cd-action-wrapper')) {
                closeAllPopovers();
            }
        });
        
        // ===== Set Password Modal Functions =====
        var _spRegno = '';
        
        function openSetPasswordModal(regno, studentName) {
            closeAllPopovers();
            if (!regno) {
                alert('No registration number provided');
                return;
            }
            _spRegno = regno;
            document.getElementById('spStudentName').innerText = studentName || '';
            document.getElementById('spStudentRegno').innerText = regno;
            document.getElementById('spNewPassword').value = '';
            document.getElementById('spConfirmPassword').value = '';
            hideSpStatus();
            document.getElementById('btnSetPassword').disabled = false;
            
            var overlay = document.getElementById('setPasswordOverlay');
            overlay.style.display = 'flex';
            
            // Focus the password field after a brief delay
            setTimeout(function() {
                document.getElementById('spNewPassword').focus();
            }, 100);
        }
        
        function closeSetPasswordModal() {
            document.getElementById('setPasswordOverlay').style.display = 'none';
            _spRegno = '';
            document.getElementById('spNewPassword').value = '';
            document.getElementById('spConfirmPassword').value = '';
            hideSpStatus();
        }
        
        function togglePasswordVisibility(inputId, btn) {
            var input = document.getElementById(inputId);
            if (input.type === 'password') {
                input.type = 'text';
                btn.innerHTML = '<svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M17.94 17.94A10.07 10.07 0 0 1 12 20c-7 0-11-8-11-8a18.45 18.45 0 0 1 5.06-5.94M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8a18.5 18.5 0 0 1-2.16 3.19m-6.72-1.07a3 3 0 1 1-4.24-4.24"></path><line x1="1" y1="1" x2="23" y2="23"></line></svg>';
            } else {
                input.type = 'password';
                btn.innerHTML = '<svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"></path><circle cx="12" cy="12" r="3"></circle></svg>';
            }
        }
        
        function showSpStatus(message, isError) {
            var el = document.getElementById('spStatusMsg');
            el.style.display = 'block';
            el.innerText = message;
            if (isError) {
                el.style.background = '#f8d7da';
                el.style.color = '#721c24';
                el.style.border = '1px solid #f5c6cb';
            } else {
                el.style.background = '#d4edda';
                el.style.color = '#155724';
                el.style.border = '1px solid #c3e6cb';
            }
        }
        
        function hideSpStatus() {
            var el = document.getElementById('spStatusMsg');
            el.style.display = 'none';
            el.innerText = '';
        }
        
        function submitSetPassword() {
            var newPwd = document.getElementById('spNewPassword').value;
            var confirmPwd = document.getElementById('spConfirmPassword').value;
            
            // Validation
            if (!newPwd) {
                showSpStatus('Please enter a new password.', true);
                document.getElementById('spNewPassword').focus();
                return;
            }
            if (newPwd.length < 1) {
                showSpStatus('Password must be at least 1 character long.', true);
                document.getElementById('spNewPassword').focus();
                return;
            }
            if (newPwd !== confirmPwd) {
                showSpStatus('Passwords do not match. Please re-enter.', true);
                document.getElementById('spConfirmPassword').focus();
                return;
            }
            if (!_spRegno) {
                showSpStatus('No student selected. Please try again.', true);
                return;
            }
            
            // Disable button and show loading
            var btn = document.getElementById('btnSetPassword');
            btn.disabled = true;
            btn.innerHTML = '<span style="margin-right:4px;">&#9203;</span> Setting Password...';
            hideSpStatus();
            
            // AJAX call to server
            var xhr = new XMLHttpRequest();
            var url = window.location.pathname + '?action=SetPassword';
            xhr.open('POST', url, true);
            xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
            xhr.onreadystatechange = function() {
                if (xhr.readyState === 4) {
                    btn.disabled = false;
                    btn.innerHTML = '<svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="margin-right: 4px;"><path d="M19 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11l5 5v11a2 2 0 0 1-2 2z"></path><polyline points="17 21 17 13 7 13 7 21"></polyline><polyline points="7 3 7 8 15 8"></polyline></svg> Set Password';
                    
                    if (xhr.status === 200) {
                        try {
                            var result = JSON.parse(xhr.responseText);
                            if (result.success) {
                                showSpStatus(result.message, false);
                                // Clear password fields on success
                                document.getElementById('spNewPassword').value = '';
                                document.getElementById('spConfirmPassword').value = '';
                            } else {
                                showSpStatus(result.message || 'Failed to set password.', true);
                            }
                        } catch (ex) {
                            showSpStatus('Unexpected response from server.', true);
                        }
                    } else {
                        showSpStatus('Server error. Please try again.', true);
                    }
                }
            };
            xhr.send('regno=' + encodeURIComponent(_spRegno) + '&newPassword=' + encodeURIComponent(newPwd));
        }
        
        // Close Set Password modal on overlay click
        document.getElementById('setPasswordOverlay').addEventListener('click', function(e) {
            if (e.target === this) {
                closeSetPasswordModal();
            }
        });
        
        // Handle Enter key in password fields
        document.getElementById('spNewPassword').addEventListener('keydown', function(e) {
            if (e.keyCode === 13) {
                e.preventDefault();
                document.getElementById('spConfirmPassword').focus();
            }
        });
        document.getElementById('spConfirmPassword').addEventListener('keydown', function(e) {
            if (e.keyCode === 13) {
                e.preventDefault();
                submitSetPassword();
            }
        });
        
        // Open Student Profile - triggers server-side load
        function openStudentProfile(regno) {
            closeAllPopovers();
            if (!regno) {
                alert('No registration number provided');
                return;
            }
            document.getElementById('<%= hdnSelectedRegno.ClientID %>').value = regno;
            // Use DevExpress button click
            if (typeof btnLoadProfile !== 'undefined') {
                btnLoadProfile.DoClick();
            } else {
                // Fallback - direct postback
                __doPostBack('<%= btnLoadProfile.UniqueID %>', '');
            }
        }
        
        // Photo Lightbox Functions
        function openLightbox(imgSrc, studentName, regNo) {
            var lightbox = document.getElementById('photoLightbox');
            var lightboxImg = document.getElementById('lightboxImg');
            var lightboxName = document.getElementById('lightboxName');
            var lightboxRegno = document.getElementById('lightboxRegno');
            var defaultUrl = document.getElementById('<%= hdnDefaultPhotoUrl.ClientID %>').value;
            
            lightboxImg.onerror = function() {
                this.onerror = null;
                this.src = defaultUrl;
            };
            lightboxImg.src = imgSrc;
            lightboxName.innerText = studentName || '';
            lightboxRegno.innerText = regNo || '';
            
            lightbox.classList.add('show');
        }
        
        function closeLightbox() {
            document.getElementById('photoLightbox').classList.remove('show');
        }
        
        // Close lightbox on overlay click
        document.addEventListener('DOMContentLoaded', function() {
            var lightbox = document.getElementById('photoLightbox');
            if (lightbox) {
                lightbox.addEventListener('click', function(e) {
                    if (e.target === lightbox) {
                        closeLightbox();
                    }
                });
            }
        });
        
        // Close on Escape key
        document.addEventListener('keydown', function(e) {
            if (e.key === 'Escape') {
                closeLightbox();
                closeBatchStatusModal();
            }
        });
        
        // ========== SEARCH BOX: Enter key triggers Search button ==========
        document.addEventListener('DOMContentLoaded', function() {
            var searchBox = document.getElementById('<%= txtSearch.ClientID %>');
            if (searchBox) {
                searchBox.addEventListener('keydown', function(e) {
                    if (e.key === 'Enter') {
                        e.preventDefault();
                        document.getElementById('<%= btnSearch.ClientID %>').click();
                    }
                });
            }
        });
        
        // ========== BATCH OPERATIONS ==========
        
        // Toggle batch operations menu
        function toggleBatchMenu(event) {
            event.stopPropagation();
            var menu = document.getElementById('batchMenu');
            menu.classList.toggle('show');
        }
        
        // Close batch menu when clicking outside
        document.addEventListener('click', function(e) {
            var menu = document.getElementById('batchMenu');
            if (menu && !e.target.closest('.cd-batch-ops')) {
                menu.classList.remove('show');
            }
        });
        
        // Open batch status change modal
        function openBatchStatusModal() {
            document.getElementById('batchMenu').classList.remove('show');
            document.getElementById('batchStatusModal').style.display = 'flex';
            resetBatchStatusForm();
        }
        
        // Close batch status modal
        function closeBatchStatusModal() {
            document.getElementById('batchStatusModal').style.display = 'none';
        }
        
        // Reset the batch status form
        function resetBatchStatusForm() {
            // Uncheck all condition radio buttons
            var radios = document.querySelectorAll('input[name="batchCondition"]');
            radios.forEach(function(r) { r.checked = false; });
            
            // Reset negate to "include" (default)
            document.querySelector('input[name="conditionNegate"][value="include"]').checked = true;
            
            document.getElementById('batchTargetStatus').value = '';
            document.getElementById('conditionPaymentDays').style.display = 'none';
            document.getElementById('conditionEntryYear').style.display = 'none';
            document.getElementById('conditionProgramme').style.display = 'none';
            document.getElementById('conditionCurrentStatus').style.display = 'none';
            document.getElementById('batchPreviewSection').style.display = 'none';
            document.getElementById('batchPreviewCount').innerText = '0';
            document.getElementById('btnApplyBatchStatus').disabled = true;
        }
        
        // Get selected condition type from radio buttons
        function getSelectedCondition() {
            var selected = document.querySelector('input[name="batchCondition"]:checked');
            return selected ? selected.value : '';
        }
        
        // Get whether condition should be negated
        function isConditionNegated() {
            var selected = document.querySelector('input[name="conditionNegate"]:checked');
            return selected ? (selected.value === 'exclude') : false;
        }
        
        // Handle condition type change (from radio button)
        function onConditionTypeChange(condType) {
            // Hide all condition panels
            document.getElementById('conditionPaymentDays').style.display = 'none';
            document.getElementById('conditionEntryYear').style.display = 'none';
            document.getElementById('conditionProgramme').style.display = 'none';
            document.getElementById('conditionCurrentStatus').style.display = 'none';
            
            // Show relevant panel
            if (condType === 'payment') {
                document.getElementById('conditionPaymentDays').style.display = 'block';
            } else if (condType === 'entry_year') {
                document.getElementById('conditionEntryYear').style.display = 'block';
            } else if (condType === 'programme') {
                document.getElementById('conditionProgramme').style.display = 'block';
            } else if (condType === 'current_status') {
                document.getElementById('conditionCurrentStatus').style.display = 'block';
            }
            
            // Reset preview
            document.getElementById('batchPreviewSection').style.display = 'none';
            document.getElementById('btnApplyBatchStatus').disabled = true;
        }
        
        // Preview affected students
        function previewBatchStatusChange() {
            var condType = getSelectedCondition();
            var targetStatus = document.getElementById('batchTargetStatus').value;
            var negate = isConditionNegated();
            
            if (!condType) {
                alert('Please select a condition.');
                return;
            }
            if (!targetStatus) {
                alert('Please select target status.');
                return;
            }
            
            var params = {
                conditionType: condType,
                targetStatus: targetStatus,
                negate: negate
            };
            
            // Get condition-specific values and validate
            if (condType === 'payment') {
                var days = document.getElementById('txtPaymentDays').value;
                if (!days || days < 1) {
                    alert('Please enter a valid number of days.');
                    return;
                }
                params.paymentDays = days;
            } else if (condType === 'entry_year') {
                var year = document.getElementById('ddlBatchEntryYear').value;
                if (!year) {
                    alert('Please select an entry year.');
                    return;
                }
                params.entryYear = year;
            } else if (condType === 'programme') {
                var prog = document.getElementById('<%= ddlBatchProgramme.ClientID %>').value;
                if (!prog) {
                    alert('Please select a programme.');
                    return;
                }
                params.programme = prog;
            } else if (condType === 'current_status') {
                var status = document.getElementById('ddlBatchCurrentStatus').value;
                if (!status) {
                    alert('Please select a current status.');
                    return;
                }
                params.currentStatus = status;
            }
            
            // Show loading
            document.getElementById('batchPreviewCount').innerText = 'Loading...';
            document.getElementById('batchPreviewSection').style.display = 'block';
            
            // Make AJAX call to get preview count
            var xhr = new XMLHttpRequest();
            xhr.open('POST', window.location.pathname + '?action=PreviewBatchStatus', true);
            xhr.setRequestHeader('Content-Type', 'application/json');
            xhr.onreadystatechange = function() {
                if (xhr.readyState === 4) {
                    if (xhr.status === 200) {
                        var response = JSON.parse(xhr.responseText);
                        document.getElementById('batchPreviewCount').innerText = response.count;
                        document.getElementById('btnApplyBatchStatus').disabled = (response.count === 0);
                        if (response.error) {
                            alert('Error: ' + response.error);
                        }
                    } else {
                        document.getElementById('batchPreviewCount').innerText = 'Error';
                    }
                }
            };
            xhr.send(JSON.stringify(params));
        }
        
        // Apply batch status change
        function applyBatchStatusChange() {
            var condType = getSelectedCondition();
            var targetStatus = document.getElementById('batchTargetStatus').value;
            var negate = isConditionNegated();
            var count = document.getElementById('batchPreviewCount').innerText;
            
            var matchText = negate ? 'DO NOT meet' : 'meet';
            if (!confirm('Are you sure you want to change the status of ' + count + ' students (who ' + matchText + ' the condition) to ' + targetStatus + '?\n\nThis action cannot be undone.')) {
                return;
            }
            
            var params = {
                conditionType: condType,
                targetStatus: targetStatus,
                negate: negate,
                apply: true
            };
            
            // Get condition-specific values
            if (condType === 'payment') {
                params.paymentDays = document.getElementById('txtPaymentDays').value;
            } else if (condType === 'entry_year') {
                params.entryYear = document.getElementById('ddlBatchEntryYear').value;
            } else if (condType === 'programme') {
                params.programme = document.getElementById('<%= ddlBatchProgramme.ClientID %>').value;
            } else if (condType === 'current_status') {
                params.currentStatus = document.getElementById('ddlBatchCurrentStatus').value;
            }
            
            // Show loading
            document.getElementById('btnApplyBatchStatus').disabled = true;
            document.getElementById('btnApplyBatchStatus').innerText = 'Applying...';
            
            // Make AJAX call to apply changes
            var xhr = new XMLHttpRequest();
            xhr.open('POST', window.location.pathname + '?action=ApplyBatchStatus', true);
            xhr.setRequestHeader('Content-Type', 'application/json');
            xhr.onreadystatechange = function() {
                if (xhr.readyState === 4) {
                    document.getElementById('btnApplyBatchStatus').innerText = 'Apply Changes';
                    if (xhr.status === 200) {
                        var response = JSON.parse(xhr.responseText);
                        if (response.success) {
                            alert('Successfully updated ' + response.updated + ' students.');
                            closeBatchStatusModal();
                            // Refresh the grid
                            window.location.reload();
                        } else {
                            alert('Error: ' + response.message);
                            document.getElementById('btnApplyBatchStatus').disabled = false;
                        }
                    } else {
                        alert('An error occurred. Please try again.');
                        document.getElementById('btnApplyBatchStatus').disabled = false;
                    }
                }
            };
            xhr.send(JSON.stringify(params));
        }
        
        // ========== BATCH VALIDATION FUNCTIONS ==========
        
        // Open batch validation modal
        function openBatchValidationModal() {
            document.getElementById('batchMenu').classList.remove('show');
            document.getElementById('batchValidationModal').style.display = 'flex';
            resetBatchValidationForm();
        }
        
        // Close batch validation modal
        function closeBatchValidationModal() {
            document.getElementById('batchValidationModal').style.display = 'none';
        }
        
        // Reset the batch validation form
        function resetBatchValidationForm() {
            document.getElementById('<%= ddlValidationProgramme.ClientID %>').value = '';
            document.getElementById('ddlValidationEntryYear').value = '';
            document.getElementById('txtValidationEntryNumbers').value = '';
            document.getElementById('validationPreviewSection').style.display = 'none';
            document.getElementById('validationPreviewCount').innerText = '0';
            document.getElementById('btnApplyBatchValidation').disabled = true;
        }
        
        // Preview students to validate
        function previewBatchValidation() {
            var programme = document.getElementById('<%= ddlValidationProgramme.ClientID %>').value;
            var entryYear = document.getElementById('ddlValidationEntryYear').value;
            var entryNumbers = document.getElementById('txtValidationEntryNumbers').value.trim();
            
            // Show loading
            document.getElementById('validationPreviewCount').innerText = 'Loading...';
            document.getElementById('validationPreviewSection').style.display = 'block';
            
            // Build query string
            var queryParams = '?action=PreviewBatchValidation';
            if (entryNumbers) {
                // If entry numbers specified, use them (ignore other filters)
                queryParams += '&entryNumbers=' + encodeURIComponent(entryNumbers);
            } else {
                if (programme) queryParams += '&programme=' + encodeURIComponent(programme);
                if (entryYear) queryParams += '&entryYear=' + encodeURIComponent(entryYear);
            }
            
            // Make AJAX call to get preview count
            var xhr = new XMLHttpRequest();
            xhr.open('GET', window.location.pathname + queryParams, true);
            xhr.onreadystatechange = function() {
                if (xhr.readyState === 4) {
                    if (xhr.status === 200) {
                        var response = JSON.parse(xhr.responseText);
                        document.getElementById('validationPreviewCount').innerText = response.count;
                        document.getElementById('btnApplyBatchValidation').disabled = (response.count === 0);
                        if (response.error) {
                            alert('Error: ' + response.error);
                        }
                    } else {
                        document.getElementById('validationPreviewCount').innerText = 'Error';
                    }
                }
            };
            xhr.send();
        }
        
        // Apply batch validation
        function applyBatchValidation() {
            var programme = document.getElementById('<%= ddlValidationProgramme.ClientID %>').value;
            var entryYear = document.getElementById('ddlValidationEntryYear').value;
            var entryNumbers = document.getElementById('txtValidationEntryNumbers').value.trim();
            var count = document.getElementById('validationPreviewCount').innerText;
            
            var filterDesc = '';
            if (entryNumbers) {
                filterDesc = ' (specific registration numbers)';
            } else if (programme || entryYear) {
                filterDesc = ' (filtered';
                if (programme) filterDesc += ' by programme';
                if (entryYear) filterDesc += (programme ? ' and' : '') + ' by entry year ' + entryYear;
                filterDesc += ')';
            }
            
            if (!confirm('Are you sure you want to validate ' + count + ' students' + filterDesc + '?\n\nThis will update their has_passed, is_curriculum_fully_set, and fail_reason fields based on their curriculum.')) {
                return;
            }
            
            var params = {
                programme: entryNumbers ? '' : programme,
                entryYear: entryNumbers ? '' : entryYear,
                entryNumbers: entryNumbers
            };
            
            // Show loading
            document.getElementById('btnApplyBatchValidation').disabled = true;
            document.getElementById('btnApplyBatchValidation').innerHTML = '<svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="margin-right: 4px; animation: spin 1s linear infinite;"><circle cx="12" cy="12" r="10"></circle><path d="M14.31 8l5.74 9.94"></path></svg> Validating...';
            
            // Make AJAX call to apply validation
            var xhr = new XMLHttpRequest();
            xhr.open('POST', window.location.pathname + '?action=ApplyBatchValidation', true);
            xhr.setRequestHeader('Content-Type', 'application/json');
            xhr.onreadystatechange = function() {
                if (xhr.readyState === 4) {
                    document.getElementById('btnApplyBatchValidation').innerHTML = '<svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="margin-right: 4px;"><polyline points="20 6 9 17 4 12"></polyline></svg> Validate Students';
                    if (xhr.status === 200) {
                        var response = JSON.parse(xhr.responseText);
                        if (response.success) {
                            alert('Successfully validated ' + response.validated + ' students.\n\nThe grid will now refresh to show updated validation results.');
                            closeBatchValidationModal();
                            // Refresh the grid
                            window.location.reload();
                        } else {
                            alert('Error: ' + response.message);
                            document.getElementById('btnApplyBatchValidation').disabled = false;
                        }
                    } else {
                        alert('An error occurred. Please try again.');
                        document.getElementById('btnApplyBatchValidation').disabled = false;
                    }
                }
            };
            xhr.send(JSON.stringify(params));
        }
        
        // ========== SUMMARY REPORT EXPORT FUNCTIONS ==========
        
        // Programme list for searchable dropdown
        var programmeList = [];
        
        // Initialize programme list from dropdown
        function initProgrammeList() {
            programmeList = [];
            var ddl = document.getElementById('<%= ddlReportProgramme.ClientID %>');
            for (var i = 0; i < ddl.options.length; i++) {
                if (ddl.options[i].value) {
                    programmeList.push({ value: ddl.options[i].value, text: ddl.options[i].text });
                }
            }
        }
        
        // Show programme dropdown
        function showProgrammeDropdown() {
            if (programmeList.length === 0) initProgrammeList();
            var container = document.getElementById('programmeDropdownList');
            renderProgrammeList('');
            container.style.display = 'block';
        }
        
        // Hide programme dropdown
        function hideProgrammeDropdown() {
            setTimeout(function() {
                document.getElementById('programmeDropdownList').style.display = 'none';
            }, 200);
        }
        
        // Filter programme dropdown
        function filterProgrammeDropdown(searchText) {
            if (programmeList.length === 0) initProgrammeList();
            renderProgrammeList(searchText.toLowerCase());
            document.getElementById('programmeDropdownList').style.display = 'block';
        }
        
        // Render filtered programme list
        function renderProgrammeList(filter) {
            var container = document.getElementById('programmeDropdownList');
            var html = '';
            var filtered = programmeList.filter(function(p) {
                return !filter || p.text.toLowerCase().indexOf(filter) > -1 || p.value.toLowerCase().indexOf(filter) > -1;
            });
            
            if (filtered.length === 0) {
                html = '<div style="padding:8px 12px; color:#888; font-size:11px;">No programmes found</div>';
            } else {
                filtered.forEach(function(p) {
                    html += '<div class="prog-item" style="padding:8px 12px; cursor:pointer; font-size:11px; border-bottom:1px solid #eee;" '
                         + 'onmouseover="this.style.backgroundColor=\'#f0f7ff\'" '
                         + 'onmouseout="this.style.backgroundColor=\'#fff\'" '
                         + 'onclick="selectProgramme(\'' + p.value.replace(/'/g, "\\'") + '\', \'' + p.text.replace(/'/g, "\\'") + '\')">' 
                         + p.text + '</div>';
                });
            }
            container.innerHTML = html;
        }
        
        // Select a programme
        function selectProgramme(value, text) {
            document.getElementById('txtSearchProgramme').value = text;
            document.getElementById('hdnSelectedProgramme').value = value;
            document.getElementById('<%= ddlReportProgramme.ClientID %>').value = value;
            document.getElementById('programmeDropdownList').style.display = 'none';
        }
        
        // ========== ENTRY YEAR SEARCHABLE DROPDOWN ==========
        var entryYearList = [];
        
        // Initialize entry year list
        function initEntryYearList() {
            entryYearList = [];
            var currentYear = new Date().getFullYear();
            for (var year = currentYear; year >= 2000; year--) {
                entryYearList.push({ value: year.toString(), text: year.toString() });
            }
        }
        
        // Show entry year dropdown
        function showEntryYearDropdown() {
            if (entryYearList.length === 0) initEntryYearList();
            var container = document.getElementById('entryYearDropdownList');
            renderEntryYearList('');
            container.style.display = 'block';
        }
        
        // Hide entry year dropdown
        function hideEntryYearDropdown() {
            setTimeout(function() {
                document.getElementById('entryYearDropdownList').style.display = 'none';
            }, 200);
        }
        
        // Filter entry year dropdown
        function filterEntryYearDropdown(searchText) {
            if (entryYearList.length === 0) initEntryYearList();
            renderEntryYearList(searchText.toLowerCase());
            document.getElementById('entryYearDropdownList').style.display = 'block';
        }
        
        // Render filtered entry year list
        function renderEntryYearList(filter) {
            var container = document.getElementById('entryYearDropdownList');
            var html = '';
            var filtered = entryYearList.filter(function(y) {
                return !filter || y.text.indexOf(filter) > -1;
            });
            
            if (filtered.length === 0) {
                html = '<div style="padding:8px 12px; color:#888; font-size:11px;">No years found</div>';
            } else {
                filtered.forEach(function(y) {
                    html += '<div class="year-item" style="padding:8px 12px; cursor:pointer; font-size:11px; border-bottom:1px solid #eee;" '
                         + 'onmouseover="this.style.backgroundColor=\'#f0f7ff\'" '
                         + 'onmouseout="this.style.backgroundColor=\'#fff\'" '
                         + 'onclick="selectEntryYear(\'' + y.value + '\', \'' + y.text + '\')">' 
                         + y.text + '</div>';
                });
            }
            container.innerHTML = html;
        }
        
        // Select an entry year
        function selectEntryYear(value, text) {
            document.getElementById('txtSearchEntryYear').value = text;
            document.getElementById('hdnSelectedEntryYear').value = value;
            document.getElementById('entryYearDropdownList').style.display = 'none';
        }
        
        // ========== END ENTRY YEAR SEARCHABLE DROPDOWN ==========
        
        // Open summary report modal
        function openSummaryReportModal() {
            document.getElementById('batchMenu').classList.remove('show');
            document.getElementById('summaryReportModal').style.display = 'flex';
            initProgrammeList();
            initEntryYearList();
            resetSummaryReportForm();
        }
        
        // Close summary report modal
        function closeSummaryReportModal() {
            document.getElementById('summaryReportModal').style.display = 'none';
        }
        
        // Reset the summary report form
        function resetSummaryReportForm() {
            document.getElementById('txtSearchProgramme').value = '';
            document.getElementById('hdnSelectedProgramme').value = '';
            document.getElementById('<%= ddlReportProgramme.ClientID %>').value = '';
            document.getElementById('txtSearchEntryYear').value = '';
            document.getElementById('hdnSelectedEntryYear').value = '';
            document.getElementById('ddlReportStudyYear').value = '';
            document.getElementById('ddlReportSemester').value = '';
            document.getElementById('txtReportEntryNumbers').value = '';
            document.getElementById('reportPreviewSection').style.display = 'none';
            document.getElementById('reportPreviewCount').innerText = '0';
            document.getElementById('btnExportSummaryReport').disabled = true;
            document.getElementById('btnExportPerformanceReport').disabled = true;
        }
        
        // Preview students for summary report
        function previewSummaryReport() {
            var programme = document.getElementById('hdnSelectedProgramme').value || document.getElementById('<%= ddlReportProgramme.ClientID %>').value;
            var entryYear = document.getElementById('hdnSelectedEntryYear').value;
            var studyYear = document.getElementById('ddlReportStudyYear').value;
            var semester = document.getElementById('ddlReportSemester').value;
            var entryNumbers = document.getElementById('txtReportEntryNumbers').value.trim();
            
            // Validate required fields
            if (!programme) {
                alert('Please select a Programme. This field is required.');
                document.getElementById('txtSearchProgramme').focus();
                return;
            }
            if (!entryYear) {
                alert('Please select an Entry Year. This field is required.');
                document.getElementById('txtSearchEntryYear').focus();
                return;
            }
            if (!studyYear) {
                alert('Please select a Year of Study. This field is required.');
                document.getElementById('ddlReportStudyYear').focus();
                return;
            }
            if (!semester) {
                alert('Please select a Semester. This field is required.');
                document.getElementById('ddlReportSemester').focus();
                return;
            }
            
            // Show loading
            document.getElementById('reportPreviewCount').innerText = 'Loading...';
            document.getElementById('reportPreviewSection').style.display = 'block';
            
            // Build query string
            var queryParams = '?action=PreviewSummaryReport';
            queryParams += '&programme=' + encodeURIComponent(programme);
            queryParams += '&entryYear=' + encodeURIComponent(entryYear);
            queryParams += '&studyYear=' + encodeURIComponent(studyYear);
            queryParams += '&semester=' + encodeURIComponent(semester);
            if (entryNumbers) {
                queryParams += '&entryNumbers=' + encodeURIComponent(entryNumbers);
            }
            
            // Make AJAX call to get preview count
            var xhr = new XMLHttpRequest();
            xhr.open('GET', window.location.pathname + queryParams, true);
            xhr.onreadystatechange = function() {
                if (xhr.readyState === 4) {
                    if (xhr.status === 200) {
                        var response = JSON.parse(xhr.responseText);
                        document.getElementById('reportPreviewCount').innerText = response.count;
                        document.getElementById('btnExportSummaryReport').disabled = (response.count === 0);
                        document.getElementById('btnExportPerformanceReport').disabled = (response.count === 0);
                        if (response.error) {
                            alert('Error: ' + response.error);
                        }
                    } else {
                        document.getElementById('reportPreviewCount').innerText = 'Error';
                    }
                }
            };
            xhr.send();
        }
        
        // Export summary report to PDF
        function exportSummaryReport() {
            var programme = document.getElementById('hdnSelectedProgramme').value || document.getElementById('<%= ddlReportProgramme.ClientID %>').value;
            var entryYear = document.getElementById('hdnSelectedEntryYear').value;
            var studyYear = document.getElementById('ddlReportStudyYear').value;
            var semester = document.getElementById('ddlReportSemester').value;
            var entryNumbers = document.getElementById('txtReportEntryNumbers').value.trim();
            var count = document.getElementById('reportPreviewCount').innerText;
            
            // Validate required fields
            if (!programme) {
                alert('Please select a Programme. This field is required.');
                return;
            }
            if (!entryYear) {
                alert('Please select an Entry Year. This field is required.');
                return;
            }
            if (!studyYear) {
                alert('Please select a Year of Study. This field is required.');
                return;
            }
            if (!semester) {
                alert('Please select a Semester. This field is required.');
                return;
            }
            
            if (count === '0' || count === 'Loading...' || count === 'Error') {
                alert('Please preview students first before exporting.');
                return;
            }
            
            // Show loading state on button
            var btn = document.getElementById('btnExportSummaryReport');
            var originalText = btn.innerHTML;
            btn.disabled = true;
            btn.innerHTML = '<svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="margin-right: 4px; animation: spin 1s linear infinite;"><circle cx="12" cy="12" r="10"></circle></svg> Generating PDF...';
            
            // Build query string for PDF generation
            var queryParams = '?action=ExportSummaryReport';
            queryParams += '&programme=' + encodeURIComponent(programme);
            queryParams += '&entryYear=' + encodeURIComponent(entryYear);
            queryParams += '&studyYear=' + encodeURIComponent(studyYear);
            queryParams += '&semester=' + encodeURIComponent(semester);
            if (entryNumbers) {
                queryParams += '&entryNumbers=' + encodeURIComponent(entryNumbers);
            }
            
            // Open PDF in new window for download
            window.open(window.location.pathname + queryParams, '_blank');
            
            // Reset button after a short delay
            setTimeout(function() {
                btn.innerHTML = originalText;
                btn.disabled = false;
            }, 2000);
        }
        
        // Export Performance Summary Report (CGPA-based categorization)
        function exportPerformanceReport() {
            var programme = document.getElementById('hdnSelectedProgramme').value || document.getElementById('<%= ddlReportProgramme.ClientID %>').value;
            var entryYear = document.getElementById('hdnSelectedEntryYear').value;
            var studyYear = document.getElementById('ddlReportStudyYear').value;
            var semester = document.getElementById('ddlReportSemester').value;
            var entryNumbers = document.getElementById('txtReportEntryNumbers').value.trim();
            var count = document.getElementById('reportPreviewCount').innerText;
            
            // Validate required fields
            if (!programme) {
                alert('Please select a Programme. This field is required.');
                return;
            }
            if (!entryYear) {
                alert('Please select an Entry Year. This field is required.');
                return;
            }
            if (!studyYear) {
                alert('Please select a Year of Study. This field is required.');
                return;
            }
            if (!semester) {
                alert('Please select a Semester. This field is required.');
                return;
            }
            
            if (count === '0' || count === 'Loading...' || count === 'Error') {
                alert('Please preview students first before exporting.');
                return;
            }
            
            // Show loading state on button
            var btn = document.getElementById('btnExportPerformanceReport');
            var originalText = btn.innerHTML;
            btn.disabled = true;
            btn.innerHTML = '<svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="margin-right: 4px; animation: spin 1s linear infinite;"><circle cx="12" cy="12" r="10"></circle></svg> Generating...';
            
            // Build query string for Performance Report PDF generation
            var queryParams = '?action=ExportPerformanceReport';
            queryParams += '&programme=' + encodeURIComponent(programme);
            queryParams += '&entryYear=' + encodeURIComponent(entryYear);
            queryParams += '&studyYear=' + encodeURIComponent(studyYear);
            queryParams += '&semester=' + encodeURIComponent(semester);
            if (entryNumbers) {
                queryParams += '&entryNumbers=' + encodeURIComponent(entryNumbers);
            }
            
            // Open PDF in new window for download
            window.open(window.location.pathname + queryParams, '_blank');
            
            // Reset button after a short delay
            setTimeout(function() {
                btn.innerHTML = originalText;
                btn.disabled = false;
            }, 2000);
        }
        
        // ========== END SUMMARY REPORT FUNCTIONS ==========
        
        // Placeholder functions for other batch operations
        function openBatchPromotionModal() {
            document.getElementById('batchMenu').classList.remove('show');
            alert('Batch Promotion feature coming soon!');
        }
        
        function openBatchExportModal() {
            document.getElementById('batchMenu').classList.remove('show');
            alert('Export feature coming soon!');
        }
        
        function openBatchEmailModal() {
            document.getElementById('batchMenu').classList.remove('show');
            alert('Bulk Email/SMS feature coming soon!');
        }
    </script>
    
    <!-- Batch Status Change Modal -->
    <div id="batchStatusModal" class="cd-modal-overlay">
        <div class="cd-modal">
            <div class="cd-modal__header">
                <h3 class="cd-modal__title">
                    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="margin-right: 6px;"><path d="M16 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path><circle cx="8.5" cy="7" r="4"></circle><line x1="18" y1="8" x2="23" y2="13"></line><line x1="23" y1="8" x2="18" y2="13"></line></svg>
                    Batch Change Student Status
                </h3>
                <button type="button" class="cd-modal__close" onclick="closeBatchStatusModal()">&times;</button>
            </div>
            <div class="cd-modal__body">
                <p style="margin-bottom: 12px; color: #666; font-size: 11px;">
                    Select students based on a condition and change their status in bulk.
                </p>
                
                <!-- Condition Selection - Radio Buttons -->
                <div class="cd-form-group">
                    <label class="cd-form-label">Select Condition</label>
                    <div class="cd-radio-group">
                        <label class="cd-radio">
                            <input type="radio" name="batchCondition" value="payment" onchange="onConditionTypeChange(this.value)" />
                            <span class="cd-radio__mark"></span>
                            <span class="cd-radio__text">Students who paid in last X days</span>
                        </label>
                        <label class="cd-radio">
                            <input type="radio" name="batchCondition" value="entry_year" onchange="onConditionTypeChange(this.value)" />
                            <span class="cd-radio__mark"></span>
                            <span class="cd-radio__text">Students by Entry Year</span>
                        </label>
                        <label class="cd-radio">
                            <input type="radio" name="batchCondition" value="programme" onchange="onConditionTypeChange(this.value)" />
                            <span class="cd-radio__mark"></span>
                            <span class="cd-radio__text">Students by Programme</span>
                        </label>
                        <label class="cd-radio">
                            <input type="radio" name="batchCondition" value="current_status" onchange="onConditionTypeChange(this.value)" />
                            <span class="cd-radio__mark"></span>
                            <span class="cd-radio__text">Students by Current Status</span>
                        </label>
                    </div>
                </div>
                
                <!-- Condition Match Type (Include/Exclude) -->
                <div class="cd-form-group">
                    <label class="cd-form-label">Match Type</label>
                    <div class="cd-toggle-group">
                        <label class="cd-toggle cd-toggle--include">
                            <input type="radio" name="conditionNegate" value="include" checked />
                            <span class="cd-toggle__text"><svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"></path><polyline points="22 4 12 14.01 9 11.01"></polyline></svg> Meets condition</span>
                        </label>
                        <label class="cd-toggle cd-toggle--exclude">
                            <input type="radio" name="conditionNegate" value="exclude" />
                            <span class="cd-toggle__text"><svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"></circle><line x1="15" y1="9" x2="9" y2="15"></line><line x1="9" y1="9" x2="15" y2="15"></line></svg> Does NOT meet condition</span>
                        </label>
                    </div>
                    <small style="color: #888; margin-top: 4px; display: block; font-size: 10px;">Choose whether to target students who match or don't match the condition.</small>
                </div>
                
                <!-- Condition: Payment Days -->
                <div id="conditionPaymentDays" class="cd-form-group cd-condition-panel" style="display: none;">
                    <label class="cd-form-label">Students who paid within last</label>
                    <div style="display: flex; align-items: center; gap: 8px;">
                        <input type="number" id="txtPaymentDays" class="cd-form-input" style="width: 80px;" value="10" min="1" max="365" />
                        <span style="color: #666; font-size: 11px;">days</span>
                    </div>
                    <small style="color: #888; margin-top: 4px; display: block; font-size: 10px;">Students who made a payment (CR transaction) in the accounts ledger.</small>
                </div>
                
                <!-- Condition: Entry Year -->
                <div id="conditionEntryYear" class="cd-form-group cd-condition-panel" style="display: none;">
                    <label class="cd-form-label">Entry Year</label>
                    <select id="ddlBatchEntryYear" class="cd-form-select">
                        <option value="">-- Select Entry Year --</option>
                        <% for (int year = DateTime.Now.Year; year >= 2000; year--) { %>
                        <option value="<%= year %>"><%= year %></option>
                        <% } %>
                    </select>
                </div>
                
                <!-- Condition: Programme -->
                <div id="conditionProgramme" class="cd-form-group cd-condition-panel" style="display: none;">
                    <label class="cd-form-label">Programme</label>
                    <asp:DropDownList ID="ddlBatchProgramme" runat="server" CssClass="cd-form-select">
                        <asp:ListItem Value="" Text="-- Select Programme --"></asp:ListItem>
                    </asp:DropDownList>
                </div>
                
                <!-- Condition: Current Status -->
                <div id="conditionCurrentStatus" class="cd-form-group cd-condition-panel" style="display: none;">
                    <label class="cd-form-label">Current Status</label>
                    <select id="ddlBatchCurrentStatus" class="cd-form-select">
                        <option value="">-- Select Current Status --</option>
                        <option value="ADMITTED">ADMITTED</option>
                        <option value="ACTIVE">ACTIVE</option>
                        <option value="ALUMNI">ALUMNI</option>
                        <option value="SUSPENDED">SUSPENDED</option>
                        <option value="DEFERRED">DEFERRED</option>
                    </select>
                </div>
                
                <hr style="margin: 20px 0; border: none; border-top: 1px solid #e0e0e0;" />
                
                <!-- Target Status -->
                <div class="cd-form-group">
                    <label class="cd-form-label">Change Status To</label>
                    <select id="batchTargetStatus" class="cd-form-select">
                        <option value="">-- Select Target Status --</option>
                        <option value="ADMITTED">ADMITTED</option>
                        <option value="ACTIVE">ACTIVE</option>
                        <option value="ALUMNI">ALUMNI</option>
                        <option value="SUSPENDED">SUSPENDED</option>
                        <option value="DEFERRED">DEFERRED</option>
                    </select>
                </div>
                
                <!-- Preview Button -->
                <div class="cd-form-group" style="margin-top: 20px;">
                    <button type="button" class="cd-btn cd-btn--secondary" onclick="previewBatchStatusChange()">
                        <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="margin-right: 4px;"><circle cx="11" cy="11" r="8"></circle><line x1="21" y1="21" x2="16.65" y2="16.65"></line></svg>
                        Preview Affected Students
                    </button>
                </div>
                
                <!-- Preview Results -->
                <div id="batchPreviewSection" class="cd-preview-box" style="display: none;">
                    <div class="cd-preview-box__icon">
                        <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path><circle cx="9" cy="7" r="4"></circle><path d="M23 21v-2a4 4 0 0 0-3-3.87"></path><path d="M16 3.13a4 4 0 0 1 0 7.75"></path></svg>
                    </div>
                    <div class="cd-preview-box__content">
                        <span class="cd-preview-box__count" id="batchPreviewCount">0</span>
                        <span class="cd-preview-box__label">students will be affected</span>
                    </div>
                </div>
            </div>
            <div class="cd-modal__footer">
                <button type="button" class="cd-btn cd-btn--outline" onclick="closeBatchStatusModal()">Cancel</button>
                <button type="button" id="btnApplyBatchStatus" class="cd-btn cd-btn--primary" onclick="applyBatchStatusChange()" disabled>
                    <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="margin-right: 4px;"><polyline points="20 6 9 17 4 12"></polyline></svg>
                    Apply Changes
                </button>
            </div>
        </div>
    </div>
    
    <!-- ========== BATCH VALIDATION MODAL ========== -->
    <!-- Modal for validating student results against their curriculum in bulk -->
    <div id="batchValidationModal" class="cd-modal-overlay">
        <div class="cd-modal">
            <div class="cd-modal__header">
                <h3 class="cd-modal__title">
                    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="margin-right: 6px;"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"></path><polyline points="22 4 12 14.01 9 11.01"></polyline></svg>
                    Validate Student Results
                </h3>
                <button type="button" class="cd-modal__close" onclick="closeBatchValidationModal()">&times;</button>
            </div>
            <div class="cd-modal__body">
                <p style="margin-bottom: 12px; color: #666; font-size: 11px;">
                    Validate students' results against their curriculum. This will check if each student has passed all required courses per semester and update their validation status.
                </p>
                
                <!-- Filter: Programme -->
                <div class="cd-form-group">
                    <label class="cd-form-label">Filter by Programme (Optional)</label>
                    <asp:DropDownList ID="ddlValidationProgramme" runat="server" CssClass="cd-form-select">
                        <asp:ListItem Value="" Text="-- All Programmes --"></asp:ListItem>
                    </asp:DropDownList>
                    <small style="color: #888; margin-top: 4px; display: block; font-size: 10px;">Leave blank to validate all students.</small>
                </div>
                
                <!-- Filter: Entry Year -->
                <div class="cd-form-group">
                    <label class="cd-form-label">Filter by Entry Year (Optional)</label>
                    <select id="ddlValidationEntryYear" class="cd-form-select">
                        <option value="">-- All Entry Years --</option>
                        <% for (int year = DateTime.Now.Year; year >= 2000; year--) { %>
                        <option value="<%= year %>"><%= year %></option>
                        <% } %>
                    </select>
                    <small style="color: #888; margin-top: 4px; display: block; font-size: 10px;">Leave blank to validate all entry years.</small>
                </div>
                
                <hr style="margin: 15px 0; border: none; border-top: 1px solid #e0e0e0;" />
                
                <!-- Specific Registration Numbers -->
                <div class="cd-form-group">
                    <label class="cd-form-label">Or Validate Specific Students by Registration Number</label>
                    <textarea id="txtValidationEntryNumbers" class="cd-form-input" rows="3" placeholder="Enter registration numbers separated by commas, e.g.:
24/U/BSCS/0001/K/DAY, 24/U/BSCS/0002/K/DAY" style="font-size: 11px; resize: vertical;"></textarea>
                    <small style="color: #888; margin-top: 4px; display: block; font-size: 10px;">If registration numbers are provided, the programme and entry year filters above will be ignored.</small>
                </div>
                
                <hr style="margin: 15px 0; border: none; border-top: 1px solid #e0e0e0;" />
                
                <!-- Validation Info -->
                <div style="background: #f8f9fa; border: 1px solid #e0e0e0; border-radius: 4px; padding: 12px; margin-bottom: 16px;">
                    <h4 style="margin: 0 0 8px 0; font-size: 12px; color: #333; font-weight: 600;">What this validation does:</h4>
                    <ul style="margin: 0; padding-left: 18px; font-size: 11px; color: #666; line-height: 1.6;">
                        <li>Gets each student's curriculum (their specialisation or programme default)</li>
                        <li>Checks if curriculum is marked as "fully set"</li>
                        <li>Compares passed courses per semester against curriculum requirements</li>
                        <li>Updates: <strong>has_passed</strong>, <strong>is_curriculum_fully_set</strong>, <strong>fail_reason</strong></li>
                    </ul>
                </div>
                
                <!-- Preview Button -->
                <div class="cd-form-group" style="margin-top: 20px;">
                    <button type="button" class="cd-btn cd-btn--secondary" onclick="previewBatchValidation()">
                        <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="margin-right: 4px;"><circle cx="11" cy="11" r="8"></circle><line x1="21" y1="21" x2="16.65" y2="16.65"></line></svg>
                        Preview Students to Validate
                    </button>
                </div>
                
                <!-- Preview Results -->
                <div id="validationPreviewSection" class="cd-preview-box" style="display: none;">
                    <div class="cd-preview-box__icon">
                        <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path><circle cx="9" cy="7" r="4"></circle><path d="M23 21v-2a4 4 0 0 0-3-3.87"></path><path d="M16 3.13a4 4 0 0 1 0 7.75"></path></svg>
                    </div>
                    <div class="cd-preview-box__content">
                        <span class="cd-preview-box__count" id="validationPreviewCount">0</span>
                        <span class="cd-preview-box__label">students will be validated</span>
                    </div>
                </div>
            </div>
            <div class="cd-modal__footer">
                <button type="button" class="cd-btn cd-btn--outline" onclick="closeBatchValidationModal()">Cancel</button>
                <button type="button" id="btnApplyBatchValidation" class="cd-btn cd-btn--primary" onclick="applyBatchValidation()" disabled>
                    <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="margin-right: 4px;"><polyline points="20 6 9 17 4 12"></polyline></svg>
                    Validate Students
                </button>
            </div>
        </div>
    </div>
    
    <!-- ========== SUMMARY REPORT EXPORT MODAL ========== -->
    <!-- Modal for exporting student results/marksheets in PDF format -->
    <div id="summaryReportModal" class="cd-modal-overlay">
        <div class="cd-modal" style="max-width: 550px;">
            <div class="cd-modal__header">
                <h3 class="cd-modal__title">
                    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="margin-right: 6px;"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path><polyline points="14 2 14 8 20 8"></polyline><line x1="16" y1="13" x2="8" y2="13"></line><line x1="16" y1="17" x2="8" y2="17"></line><polyline points="10 9 9 9 8 9"></polyline></svg>
                    Export Summary Report
                </h3>
                <button type="button" class="cd-modal__close" onclick="closeSummaryReportModal()">&times;</button>
            </div>
            <div class="cd-modal__body">
                <p style="margin-bottom: 12px; color: #666; font-size: 11px;">
                    Export student results/marksheets as a PDF summary report. <span style="color: #c0392b;">* Required fields</span>
                </p>
                
                <!-- Filter: Programme (Required) -->
                <div class="cd-form-group">
                    <label class="cd-form-label">Filter by Programme <span style="color: #c0392b;">*</span></label>
                    <div style="position: relative;">
                        <input type="text" id="txtSearchProgramme" class="cd-form-input" placeholder="Type to search programme..." 
                               onkeyup="filterProgrammeDropdown(this.value)" onclick="showProgrammeDropdown()" onblur="hideProgrammeDropdown()" autocomplete="off" />
                        <asp:DropDownList ID="ddlReportProgramme" runat="server" CssClass="cd-form-select" style="display:none;">
                            <asp:ListItem Value="" Text="-- Select Programme --"></asp:ListItem>
                        </asp:DropDownList>
                        <div id="programmeDropdownList" class="cd-searchable-dropdown" style="display:none; position:absolute; top:100%; left:0; right:0; max-height:200px; overflow-y:auto; background:#fff; border:1px solid #ccc; border-radius:4px; z-index:1000; box-shadow:0 4px 6px rgba(0,0,0,0.1);">
                        </div>
                    </div>
                    <input type="hidden" id="hdnSelectedProgramme" value="" />
                </div>
                
                <!-- Filter: Entry Year (Required) -->
                <div class="cd-form-group">
                    <label class="cd-form-label">Entry Year <span style="color: #c0392b;">*</span></label>
                    <div style="position: relative;">
                        <input type="text" id="txtSearchEntryYear" class="cd-form-input" placeholder="Type to search entry year..." 
                               onkeyup="filterEntryYearDropdown(this.value)" onclick="showEntryYearDropdown()" onblur="hideEntryYearDropdown()" autocomplete="off" />
                        <div id="entryYearDropdownList" class="cd-searchable-dropdown" style="display:none; position:absolute; top:100%; left:0; right:0; max-height:200px; overflow-y:auto; background:#fff; border:1px solid #ccc; border-radius:4px; z-index:1000; box-shadow:0 4px 6px rgba(0,0,0,0.1);">
                        </div>
                    </div>
                    <input type="hidden" id="hdnSelectedEntryYear" value="" />
                </div>
                
                <!-- Filter: Year of Study (Required) -->
                <div class="cd-form-group">
                    <label class="cd-form-label">Year of Study <span style="color: #c0392b;">*</span></label>
                    <select id="ddlReportStudyYear" class="cd-form-select">
                        <option value="">-- Select Year of Study --</option>
                        <option value="1">Year 1</option>
                        <option value="2">Year 2</option>
                        <option value="3">Year 3</option>
                        <option value="4">Year 4</option>
                        <option value="5">Year 5</option>
                    </select>
                </div>
                
                <!-- Filter: Semester (Required) -->
                <div class="cd-form-group">
                    <label class="cd-form-label">Semester <span style="color: #c0392b;">*</span></label>
                    <select id="ddlReportSemester" class="cd-form-select">
                        <option value="">-- Select Semester --</option>
                        <option value="1">Semester 1</option>
                        <option value="2">Semester 2</option>
                        <option value="3">Semester 3</option>
                    </select>
                </div>
                
                <hr style="margin: 15px 0; border: none; border-top: 1px solid #e0e0e0;" />
                
                <!-- Specific Registration Numbers -->
                <div class="cd-form-group">
                    <label class="cd-form-label">Or Export for Specific Students by Registration Number</label>
                    <textarea id="txtReportEntryNumbers" class="cd-form-input" rows="3" placeholder="Enter registration numbers separated by commas, e.g.:
24/U/BSCS/0001/K/DAY, 24/U/BSCS/0002/K/DAY" style="font-size: 11px; resize: vertical;"></textarea>
                    <small style="color: #888; margin-top: 4px; display: block; font-size: 10px;">If registration numbers are provided, Programme and Entry Year are still required.</small>
                </div>
                
                <!-- Preview Button -->
                <div class="cd-form-group" style="margin-top: 20px;">
                    <button type="button" class="cd-btn cd-btn--secondary" onclick="previewSummaryReport()">
                        <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="margin-right: 4px;"><circle cx="11" cy="11" r="8"></circle><line x1="21" y1="21" x2="16.65" y2="16.65"></line></svg>
                        Preview Students
                    </button>
                </div>
                
                <!-- Preview Results -->
                <div id="reportPreviewSection" class="cd-preview-box" style="display: none;">
                    <div class="cd-preview-box__icon">
                        <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path><circle cx="9" cy="7" r="4"></circle><path d="M23 21v-2a4 4 0 0 0-3-3.87"></path><path d="M16 3.13a4 4 0 0 1 0 7.75"></path></svg>
                    </div>
                    <div class="cd-preview-box__content">
                        <span class="cd-preview-box__count" id="reportPreviewCount">0</span>
                        <span class="cd-preview-box__label">students will be included in the report</span>
                    </div>
                </div>
            </div>
            <div class="cd-modal__footer">
                <button type="button" class="cd-btn cd-btn--outline" onclick="closeSummaryReportModal()">Cancel</button>
                <button type="button" id="btnExportSummaryReport" class="cd-btn cd-btn--primary" onclick="exportSummaryReport()" disabled>
                    <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="margin-right: 4px;"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"></path><polyline points="7 10 12 15 17 10"></polyline><line x1="12" y1="15" x2="12" y2="3"></line></svg>
                    Export Results
                </button>
                <button type="button" id="btnExportPerformanceReport" class="cd-btn cd-btn--success" onclick="exportPerformanceReport()" disabled style="background:#198754; border-color:#198754;">
                    <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="margin-right: 4px;"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path><polyline points="14 2 14 8 20 8"></polyline><line x1="16" y1="13" x2="8" y2="13"></line><line x1="16" y1="17" x2="8" y2="17"></line></svg>
                    Summary Report
                </button>
            </div>
        </div>
    </div>
    
    <!-- Batch Operations Styles -->
    <style>
        /* Batch Operations Button & Menu */
        .cd-batch-ops {
            position: relative;
        }
        
        .cd-batch-menu {
            position: absolute;
            top: 100%;
            right: 0;
            background: #fff;
            border: 1px solid #ddd;
            border-radius: 0;
            box-shadow: 0 2px 8px rgba(0,0,0,0.12);
            min-width: 200px;
            z-index: 1000;
            display: none;
            padding: 4px 0;
        }
        
        .cd-batch-menu.show {
            display: block;
        }
        
        .cd-batch-menu__item {
            display: flex;
            align-items: center;
            gap: 8px;
            padding: 8px 12px;
            color: #333;
            text-decoration: none;
            font-size: 12px;
            transition: background 0.1s;
        }
        
        .cd-batch-menu__item:hover {
            background: #f0f4ff;
            color: #174DA4;
        }
        
        .cd-batch-menu__item svg {
            flex-shrink: 0;
            color: #666;
        }
        
        .cd-batch-menu__item:hover svg {
            color: #174DA4;
        }
        
        /* Modal Overlay */
        .cd-modal-overlay {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0,0,0,0.5);
            z-index: 10000;
            justify-content: center;
            align-items: center;
        }
        
        /* Modal */
        .cd-modal {
            background: #fff;
            border-radius: 0;
            width: 100%;
            max-width: 480px;
            max-height: 90vh;
            overflow: hidden;
            display: flex;
            flex-direction: column;
            box-shadow: 0 4px 20px rgba(0,0,0,0.2);
        }
        
        .cd-modal__header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 10px 14px;
            background: #174DA4;
            color: #fff;
        }
        
        .cd-modal__title {
            margin: 0;
            font-size: 13px;
            font-weight: 600;
            display: flex;
            align-items: center;
        }
        
        .cd-modal__close {
            background: none;
            border: none;
            color: #fff;
            font-size: 20px;
            cursor: pointer;
            line-height: 1;
            opacity: 0.8;
            transition: opacity 0.1s;
            padding: 0;
            width: 24px;
            height: 24px;
        }
        
        .cd-modal__close:hover {
            opacity: 1;
        }
        
        .cd-modal__body {
            padding: 14px;
            overflow-y: auto;
            flex: 1;
        }
        
        .cd-modal__footer {
            padding: 10px 14px;
            background: #f8f9fa;
            border-top: 1px solid #e0e0e0;
            display: flex;
            justify-content: flex-end;
            gap: 8px;
        }
        
        /* Form Elements */
        .cd-form-group {
            margin-bottom: 12px;
        }
        
        .cd-form-label {
            display: block;
            font-size: 11px;
            font-weight: 600;
            color: #333;
            margin-bottom: 4px;
            text-transform: uppercase;
        }
        
        .cd-form-select, .cd-form-input {
            width: 100%;
            padding: 6px 8px;
            border: 1px solid #ddd;
            border-radius: 0;
            font-size: 12px;
            color: #333;
            background: #fff;
            transition: border-color 0.1s;
        }
        
        .cd-form-select:focus, .cd-form-input:focus {
            outline: none;
            border-color: #174DA4;
        }
        
        .cd-condition-panel {
            background: #f8f9fa;
            padding: 12px;
            border-radius: 0;
            border: 1px solid #e0e0e0;
        }
        
        /* Radio Button Group */
        .cd-radio-group {
            display: flex;
            flex-direction: column;
            gap: 6px;
        }
        
        .cd-radio {
            display: flex;
            align-items: center;
            gap: 8px;
            cursor: pointer;
            padding: 6px 8px;
            border: 1px solid #e0e0e0;
            background: #fff;
            transition: all 0.1s;
            font-size: 11px;
        }
        
        .cd-radio:hover {
            border-color: #174DA4;
            background: #f8faff;
        }
        
        .cd-radio input[type="radio"] {
            display: none;
        }
        
        .cd-radio__mark {
            width: 14px;
            height: 14px;
            border: 2px solid #ccc;
            border-radius: 0;
            display: flex;
            align-items: center;
            justify-content: center;
            flex-shrink: 0;
            transition: all 0.1s;
        }
        
        .cd-radio__mark::after {
            content: '';
            width: 6px;
            height: 6px;
            background: #174DA4;
            display: none;
        }
        
        .cd-radio input[type="radio"]:checked + .cd-radio__mark {
            border-color: #174DA4;
        }
        
        .cd-radio input[type="radio"]:checked + .cd-radio__mark::after {
            display: block;
        }
        
        .cd-radio input[type="radio"]:checked ~ .cd-radio__text {
            color: #174DA4;
            font-weight: 600;
        }
        
        .cd-radio__text {
            color: #333;
        }
        
        /* Toggle Group (Include/Exclude) */
        .cd-toggle-group {
            display: flex;
            gap: 0;
            border: 1px solid #ddd;
        }
        
        .cd-toggle {
            flex: 1;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 8px 12px;
            cursor: pointer;
            font-size: 11px;
            background: #fff;
            transition: all 0.1s;
            border-right: 1px solid #ddd;
        }
        
        .cd-toggle:last-child {
            border-right: none;
        }
        
        .cd-toggle input[type="radio"] {
            display: none;
        }
        
        .cd-toggle__text {
            color: #666;
            display: flex;
            align-items: center;
            gap: 6px;
        }
        
        .cd-toggle__text svg {
            vertical-align: middle;
            flex-shrink: 0;
        }
        
        .cd-toggle--include input[type="radio"]:checked ~ .cd-toggle__text {
            color: #fff;
        }
        
        .cd-toggle--include input[type="radio"]:checked ~ .cd-toggle__text svg {
            stroke: #fff;
        }
        
        .cd-toggle--include:has(input:checked) {
            background: #28a745;
        }
        
        .cd-toggle--exclude input[type="radio"]:checked ~ .cd-toggle__text {
            color: #fff;
        }
        
        .cd-toggle--exclude input[type="radio"]:checked ~ .cd-toggle__text svg {
            stroke: #fff;
        }
        
        .cd-toggle--exclude:has(input:checked) {
            background: #dc3545;
        }
        
        .cd-toggle:hover {
            background: #f5f5f5;
        }
        
        .cd-toggle--include:has(input:checked):hover {
            background: #218838;
        }
        
        .cd-toggle--exclude:has(input:checked):hover {
            background: #c82333;
        }
        
        /* Preview Box */
        .cd-preview-box {
            background: #f0f4ff;
            border: 1px solid #c4d9f8;
            border-radius: 0;
            padding: 14px;
            display: flex;
            align-items: center;
            gap: 12px;
            margin-top: 12px;
        }
        
        .cd-preview-box__icon {
            width: 40px;
            height: 40px;
            background: #174DA4;
            border-radius: 0;
            display: flex;
            align-items: center;
            justify-content: center;
            color: #fff;
            flex-shrink: 0;
        }
        
        .cd-preview-box__content {
            display: flex;
            flex-direction: column;
        }
        
        .cd-preview-box__count {
            font-size: 22px;
            font-weight: 700;
            color: #174DA4;
            line-height: 1.1;
        }
        
        .cd-preview-box__label {
            font-size: 11px;
            color: #666;
        }
        
        /* Buttons */
        .cd-btn {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            padding: 6px 12px;
            border: none;
            border-radius: 0;
            font-size: 11px;
            font-weight: 500;
            cursor: pointer;
            transition: all 0.1s;
        }
        
        .cd-btn--sm {
            padding: 5px 10px;
            font-size: 11px;
        }
        
        .cd-btn--primary {
            background: #174DA4;
            color: #fff;
        }
        
        .cd-btn--primary:hover {
            background: #0d3a7d;
        }
        
        .cd-btn--primary:disabled {
            background: #9eb9dc;
            cursor: not-allowed;
        }
        
        .cd-btn--secondary {
            background: #e8f0fe;
            color: #174DA4;
            border: 1px solid #c4d9f8;
        }
        
        .cd-btn--secondary:hover {
            background: #d4e4fc;
        }
        
        .cd-btn--outline {
            background: #fff;
            color: #666;
            border: 1px solid #ddd;
        }
        
        .cd-btn--outline:hover {
            background: #f5f5f5;
            border-color: #ccc;
        }
        
        /* Password Toggle Button */
        .cd-pwd-toggle {
            position: absolute;
            right: 6px;
            top: 50%;
            transform: translateY(-50%);
            background: none;
            border: none;
            cursor: pointer;
            color: #999;
            padding: 2px;
            line-height: 1;
            transition: color 0.15s;
        }
        .cd-pwd-toggle:hover {
            color: #174DA4;
        }
    </style>
    
</asp:Content>
