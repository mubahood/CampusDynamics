<%@ Control Language="C#" AutoEventWireup="true" CodeFile="BatchOperations.ascx.cs" Inherits="COOPERP_NewScreens_UserControls_BatchOperations" EnableViewState="true" %>
<%@ Register assembly="DevExpress.Web.v16.1, Version=16.1.4.0, Culture=neutral, PublicKeyToken=b88d1754d700e49a" namespace="DevExpress.Web" tagprefix="dx" %>

<!-- Batch Operations Button & Dropdown Menu -->
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
        <a href="javascript:void(0);" class="cd-batch-menu__item" onclick="openSpecValidatorModal()">
            <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 20h9"></path><path d="M16.5 3.5a2.121 2.121 0 0 1 3 3L7 19l-4 1 1-4L16.5 3.5z"></path></svg>
            Specialization Validator
        </a>
    </div>
</div>

<!-- ========== BATCH STATUS CHANGE MODAL ========== -->
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
                <asp:DropDownList ID="ddlBatchEntryYear" runat="server" CssClass="cd-form-select">
                    <asp:ListItem Value="" Text="-- Select Entry Year --"></asp:ListItem>
                </asp:DropDownList>
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
                <asp:DropDownList ID="ddlValidationEntryYear" runat="server" CssClass="cd-form-select">
                    <asp:ListItem Value="" Text="-- All Entry Years --"></asp:ListItem>
                </asp:DropDownList>
                <small style="color: #888; margin-top: 4px; display: block; font-size: 10px;">Leave blank to validate all entry years.</small>
            </div>
            
            <hr style="margin: 15px 0; border: none; border-top: 1px solid #e0e0e0;" />
            
            <!-- Specific Entry Numbers -->
            <div class="cd-form-group">
                <label class="cd-form-label">Or Validate Specific Students by Entry Number</label>
                <textarea id="txtValidationEntryNumbers" class="cd-form-input" rows="3" placeholder="Enter entry numbers separated by commas, e.g.:
24/U/BSCS/0001/K/DAY, 24/U/BSCS/0002/K/DAY" style="font-size: 11px; resize: vertical;"></textarea>
                <small style="color: #888; margin-top: 4px; display: block; font-size: 10px;">If entry numbers are provided, the programme and entry year filters above will be ignored.</small>
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

<!-- ========== SPECIALIZATION VALIDATOR MODAL ========== -->
<div id="specValidatorModal" class="cd-modal-overlay">
    <div class="cd-modal" style="max-width: 700px;">
        <div class="cd-modal__header">
            <h3 class="cd-modal__title">
                <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="margin-right: 6px;"><path d="M12 20h9"></path><path d="M16.5 3.5a2.121 2.121 0 0 1 3 3L7 19l-4 1 1-4L16.5 3.5z"></path></svg>
                Specialization Validator
            </h3>
            <button type="button" class="cd-modal__close" onclick="closeSpecValidatorModal()">&times;</button>
        </div>
        <div class="cd-modal__body">
            <p style="margin-bottom: 12px; color: #666; font-size: 11px;">
                Validate all specializations to ensure they have the correct number of courses configured per study year.
            </p>
            
            <!-- Validation Rules Info -->
            <div style="background: #fff3cd; border: 1px solid #ffc107; border-radius: 4px; padding: 12px; margin-bottom: 16px;">
                <h4 style="margin: 0 0 8px 0; font-size: 12px; color: #856404; font-weight: 600;">Validation Rules:</h4>
                <ul style="margin: 0; padding-left: 18px; font-size: 11px; color: #856404; line-height: 1.6;">
                    <li><strong>Year 1 & Year 2:</strong> Must have at least 5 courses each (otherwise marked "Not Fully Set")</li>
                    <li><strong>Year 1, Year 2 & Year 3:</strong> Must not exceed 12 courses each (otherwise marked "Not Fully Set")</li>
                    <li>Specializations meeting all criteria will be marked "Fully Set"</li>
                </ul>
            </div>
            
            <!-- Load Summary Button -->
            <div class="cd-form-group">
                <button type="button" class="cd-btn cd-btn--secondary" onclick="loadSpecSummary()" id="btnLoadSpecSummary">
                    <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="margin-right: 4px;"><circle cx="11" cy="11" r="8"></circle><line x1="21" y1="21" x2="16.65" y2="16.65"></line></svg>
                    Load Specialization Summary
                </button>
            </div>
            
            <!-- Summary Table -->
            <div id="specSummarySection" style="display: none;">
                <div style="margin-bottom: 12px; padding: 10px; background: #f8f9fa; border: 1px solid #e0e0e0; border-radius: 4px;">
                    <div style="display: flex; justify-content: space-between; align-items: center;">
                        <div>
                            <span style="font-size: 11px; color: #666;">Total Specializations: </span>
                            <strong id="specTotalCount" style="font-size: 13px; color: #333;">0</strong>
                        </div>
                        <div>
                            <span style="font-size: 11px; color: #28a745;">Fully Set: </span>
                            <strong id="specFullySetCount" style="font-size: 13px; color: #28a745;">0</strong>
                        </div>
                        <div>
                            <span style="font-size: 11px; color: #dc3545;">Not Fully Set: </span>
                            <strong id="specNotFullySetCount" style="font-size: 13px; color: #dc3545;">0</strong>
                        </div>
                    </div>
                </div>
                
                <div style="max-height: 300px; overflow-y: auto; border: 1px solid #e0e0e0;">
                    <table class="cd-spec-table" style="width: 100%; border-collapse: collapse; font-size: 11px;">
                        <thead style="background: #f8f9fa; position: sticky; top: 0;">
                            <tr>
                                <th style="padding: 8px; text-align: left; border-bottom: 2px solid #ddd;">Specialization</th>
                                <th style="padding: 8px; text-align: left; border-bottom: 2px solid #ddd;">Programme</th>
                                <th style="padding: 8px; text-align: center; border-bottom: 2px solid #ddd;">Y1</th>
                                <th style="padding: 8px; text-align: center; border-bottom: 2px solid #ddd;">Y2</th>
                                <th style="padding: 8px; text-align: center; border-bottom: 2px solid #ddd;">Y3</th>
                                <th style="padding: 8px; text-align: center; border-bottom: 2px solid #ddd;">Y4</th>
                                <th style="padding: 8px; text-align: center; border-bottom: 2px solid #ddd;">Students</th>
                                <th style="padding: 8px; text-align: center; border-bottom: 2px solid #ddd;">Status</th>
                            </tr>
                        </thead>
                        <tbody id="specSummaryTableBody">
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
        <div class="cd-modal__footer">
            <button type="button" class="cd-btn cd-btn--outline" onclick="closeSpecValidatorModal()">Cancel</button>
            <button type="button" id="btnApplySpecValidation" class="cd-btn cd-btn--primary" onclick="applySpecValidation()" disabled>
                <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="margin-right: 4px;"><polyline points="20 6 9 17 4 12"></polyline></svg>
                Apply Validation
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
    
    .cd-batch-menu.show { display: block; }
    
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
    
    .cd-batch-menu__item:hover svg { color: #174DA4; }
    
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
    
    .cd-modal__close:hover { opacity: 1; }
    
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
    .cd-form-group { margin-bottom: 12px; }
    
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
        padding: 8px 10px;
        border: 1px solid #ddd;
        border-radius: 0;
        font-size: 12px;
        color: #333;
        background: #fff;
        transition: border-color 0.1s;
        height: auto;
        min-height: 34px;
        display: block;
        box-sizing: border-box;
        -webkit-appearance: none;
        -moz-appearance: none;
        appearance: none;
    }
    
    .cd-form-select {
        background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='12' height='12' viewBox='0 0 24 24' fill='none' stroke='%23666' stroke-width='2'%3E%3Cpolyline points='6 9 12 15 18 9'/%3E%3C/svg%3E");
        background-repeat: no-repeat;
        background-position: right 10px center;
        padding-right: 30px;
        cursor: pointer;
    }
    
    .cd-form-select:focus, .cd-form-input:focus {
        outline: none;
        border-color: #174DA4;
        box-shadow: 0 0 0 2px rgba(23, 77, 164, 0.15);
    }
    
    .cd-form-select option {
        padding: 8px;
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
    
    .cd-radio input[type="radio"] { display: none; }
    
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
    
    .cd-radio input[type="radio"]:checked + .cd-radio__mark { border-color: #174DA4; }
    .cd-radio input[type="radio"]:checked + .cd-radio__mark::after { display: block; }
    .cd-radio input[type="radio"]:checked ~ .cd-radio__text { color: #174DA4; font-weight: 600; }
    .cd-radio__text { color: #333; }
    
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
    
    .cd-toggle:last-child { border-right: none; }
    .cd-toggle input[type="radio"] { display: none; }
    
    .cd-toggle__text {
        color: #666;
        display: flex;
        align-items: center;
        gap: 6px;
    }
    
    .cd-toggle__text svg { vertical-align: middle; flex-shrink: 0; }
    
    .cd-toggle--include input[type="radio"]:checked ~ .cd-toggle__text { color: #fff; }
    .cd-toggle--include input[type="radio"]:checked ~ .cd-toggle__text svg { stroke: #fff; }
    .cd-toggle--include:has(input:checked) { background: #28a745; }
    
    .cd-toggle--exclude input[type="radio"]:checked ~ .cd-toggle__text { color: #fff; }
    .cd-toggle--exclude input[type="radio"]:checked ~ .cd-toggle__text svg { stroke: #fff; }
    .cd-toggle--exclude:has(input:checked) { background: #dc3545; }
    
    .cd-toggle:hover { background: #f5f5f5; }
    .cd-toggle--include:has(input:checked):hover { background: #218838; }
    .cd-toggle--exclude:has(input:checked):hover { background: #c82333; }
    
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
    
    .cd-preview-box__content { display: flex; flex-direction: column; }
    
    .cd-preview-box__count {
        font-size: 22px;
        font-weight: 700;
        color: #174DA4;
        line-height: 1.1;
    }
    
    .cd-preview-box__label { font-size: 11px; color: #666; }
    
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
    
    .cd-btn--sm { padding: 5px 10px; font-size: 11px; }
    .cd-btn--primary { background: #174DA4; color: #fff; }
    .cd-btn--primary:hover { background: #0d3a7d; }
    .cd-btn--primary:disabled { background: #9eb9dc; cursor: not-allowed; }
    
    .cd-btn--secondary {
        background: #e8f0fe;
        color: #174DA4;
        border: 1px solid #c4d9f8;
    }
    .cd-btn--secondary:hover { background: #d4e4fc; }
    
    .cd-btn--outline {
        background: #fff;
        color: #666;
        border: 1px solid #ddd;
    }
    .cd-btn--outline:hover { background: #f5f5f5; border-color: #ccc; }
    
    @keyframes spin {
        from { transform: rotate(0deg); }
        to { transform: rotate(360deg); }
    }
</style>

<!-- Batch Operations JavaScript -->
<script type="text/javascript">
    // ========== BATCH MENU ==========
    function toggleBatchMenu(event) {
        event.stopPropagation();
        document.getElementById('batchMenu').classList.toggle('show');
    }
    
    document.addEventListener('click', function(e) {
        var menu = document.getElementById('batchMenu');
        if (menu && !e.target.closest('.cd-batch-ops')) {
            menu.classList.remove('show');
        }
    });
    
    // ========== BATCH STATUS FUNCTIONS ==========
    function openBatchStatusModal() {
        document.getElementById('batchMenu').classList.remove('show');
        document.getElementById('batchStatusModal').style.display = 'flex';
        resetBatchStatusForm();
    }
    
    function closeBatchStatusModal() {
        document.getElementById('batchStatusModal').style.display = 'none';
    }
    
    function resetBatchStatusForm() {
        var radios = document.querySelectorAll('input[name="batchCondition"]');
        radios.forEach(function(r) { r.checked = false; });
        document.querySelector('input[name="conditionNegate"][value="include"]').checked = true;
        document.getElementById('batchTargetStatus').value = '';
        document.getElementById('conditionPaymentDays').style.display = 'none';
        document.getElementById('conditionEntryYear').style.display = 'none';
        document.getElementById('conditionProgramme').style.display = 'none';
        document.getElementById('conditionCurrentStatus').style.display = 'none';
        document.getElementById('batchPreviewSection').style.display = 'none';
        document.getElementById('batchPreviewCount').innerText = '0';
        document.getElementById('btnApplyBatchStatus').disabled = true;
        // Reset dropdowns
        document.getElementById('<%= ddlBatchProgramme.ClientID %>').value = '';
        document.getElementById('<%= ddlBatchEntryYear.ClientID %>').value = '';
    }
    
    function getSelectedCondition() {
        var selected = document.querySelector('input[name="batchCondition"]:checked');
        return selected ? selected.value : '';
    }
    
    function isConditionNegated() {
        var selected = document.querySelector('input[name="conditionNegate"]:checked');
        return selected ? (selected.value === 'exclude') : false;
    }
    
    function onConditionTypeChange(condType) {
        document.getElementById('conditionPaymentDays').style.display = 'none';
        document.getElementById('conditionEntryYear').style.display = 'none';
        document.getElementById('conditionProgramme').style.display = 'none';
        document.getElementById('conditionCurrentStatus').style.display = 'none';
        
        if (condType === 'payment') document.getElementById('conditionPaymentDays').style.display = 'block';
        else if (condType === 'entry_year') document.getElementById('conditionEntryYear').style.display = 'block';
        else if (condType === 'programme') document.getElementById('conditionProgramme').style.display = 'block';
        else if (condType === 'current_status') document.getElementById('conditionCurrentStatus').style.display = 'block';
        
        document.getElementById('batchPreviewSection').style.display = 'none';
        document.getElementById('btnApplyBatchStatus').disabled = true;
    }
    
    function previewBatchStatusChange() {
        var condType = getSelectedCondition();
        var targetStatus = document.getElementById('batchTargetStatus').value;
        var negate = isConditionNegated();
        
        if (!condType) { alert('Please select a condition.'); return; }
        if (!targetStatus) { alert('Please select target status.'); return; }
        
        var params = { conditionType: condType, targetStatus: targetStatus, negate: negate };
        
        if (condType === 'payment') {
            var days = document.getElementById('txtPaymentDays').value;
            if (!days || days < 1) { alert('Please enter a valid number of days.'); return; }
            params.paymentDays = days;
        } else if (condType === 'entry_year') {
            var year = document.getElementById('<%= ddlBatchEntryYear.ClientID %>').value;
            if (!year) { alert('Please select an entry year.'); return; }
            params.entryYear = year;
        } else if (condType === 'programme') {
            var prog = document.getElementById('<%= ddlBatchProgramme.ClientID %>').value;
            if (!prog) { alert('Please select a programme.'); return; }
            params.programme = prog;
        } else if (condType === 'current_status') {
            var status = document.getElementById('ddlBatchCurrentStatus').value;
            if (!status) { alert('Please select a current status.'); return; }
            params.currentStatus = status;
        }
        
        document.getElementById('batchPreviewCount').innerText = 'Loading...';
        document.getElementById('batchPreviewSection').style.display = 'block';
        
        var xhr = new XMLHttpRequest();
        xhr.open('POST', window.location.pathname + '?action=PreviewBatchStatus', true);
        xhr.setRequestHeader('Content-Type', 'application/json');
        xhr.onreadystatechange = function() {
            if (xhr.readyState === 4) {
                if (xhr.status === 200) {
                    var response = JSON.parse(xhr.responseText);
                    document.getElementById('batchPreviewCount').innerText = response.count;
                    document.getElementById('btnApplyBatchStatus').disabled = (response.count === 0);
                } else {
                    document.getElementById('batchPreviewCount').innerText = 'Error';
                }
            }
        };
        xhr.send(JSON.stringify(params));
    }
    
    function applyBatchStatusChange() {
        var condType = getSelectedCondition();
        var targetStatus = document.getElementById('batchTargetStatus').value;
        var negate = isConditionNegated();
        var count = document.getElementById('batchPreviewCount').innerText;
        
        if (!confirm('Are you sure you want to change status of ' + count + ' students to "' + targetStatus + '"?')) return;
        
        var params = { conditionType: condType, targetStatus: targetStatus, negate: negate };
        
        if (condType === 'payment') params.paymentDays = document.getElementById('txtPaymentDays').value;
        else if (condType === 'entry_year') params.entryYear = document.getElementById('<%= ddlBatchEntryYear.ClientID %>').value;
        else if (condType === 'programme') params.programme = document.getElementById('<%= ddlBatchProgramme.ClientID %>').value;
        else if (condType === 'current_status') params.currentStatus = document.getElementById('ddlBatchCurrentStatus').value;
        
        document.getElementById('btnApplyBatchStatus').disabled = true;
        document.getElementById('btnApplyBatchStatus').innerHTML = 'Applying...';
        
        var xhr = new XMLHttpRequest();
        xhr.open('POST', window.location.pathname + '?action=ApplyBatchStatus', true);
        xhr.setRequestHeader('Content-Type', 'application/json');
        xhr.onreadystatechange = function() {
            if (xhr.readyState === 4) {
                document.getElementById('btnApplyBatchStatus').innerHTML = '<svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="margin-right: 4px;"><polyline points="20 6 9 17 4 12"></polyline></svg> Apply Changes';
                if (xhr.status === 200) {
                    var response = JSON.parse(xhr.responseText);
                    if (response.success) {
                        alert('Successfully updated ' + response.updated + ' students.');
                        closeBatchStatusModal();
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
    function openBatchValidationModal() {
        document.getElementById('batchMenu').classList.remove('show');
        document.getElementById('batchValidationModal').style.display = 'flex';
        resetBatchValidationForm();
    }
    
    function closeBatchValidationModal() {
        document.getElementById('batchValidationModal').style.display = 'none';
    }
    
    function resetBatchValidationForm() {
        document.getElementById('<%= ddlValidationProgramme.ClientID %>').value = '';
        document.getElementById('<%= ddlValidationEntryYear.ClientID %>').value = '';
        document.getElementById('txtValidationEntryNumbers').value = '';
        document.getElementById('validationPreviewSection').style.display = 'none';
        document.getElementById('validationPreviewCount').innerText = '0';
        document.getElementById('btnApplyBatchValidation').disabled = true;
    }
    
    function previewBatchValidation() {
        var programme = document.getElementById('<%= ddlValidationProgramme.ClientID %>').value;
        var entryYear = document.getElementById('<%= ddlValidationEntryYear.ClientID %>').value;
        var entryNumbers = document.getElementById('txtValidationEntryNumbers').value.trim();
        
        document.getElementById('validationPreviewCount').innerText = 'Loading...';
        document.getElementById('validationPreviewSection').style.display = 'block';
        
        var queryParams = '?action=PreviewBatchValidation';
        if (entryNumbers) {
            queryParams += '&entryNumbers=' + encodeURIComponent(entryNumbers);
        } else {
            if (programme) queryParams += '&programme=' + encodeURIComponent(programme);
            if (entryYear) queryParams += '&entryYear=' + encodeURIComponent(entryYear);
        }
        
        var xhr = new XMLHttpRequest();
        xhr.open('GET', window.location.pathname + queryParams, true);
        xhr.onreadystatechange = function() {
            if (xhr.readyState === 4) {
                if (xhr.status === 200) {
                    var response = JSON.parse(xhr.responseText);
                    document.getElementById('validationPreviewCount').innerText = response.count;
                    document.getElementById('btnApplyBatchValidation').disabled = (response.count === 0);
                    if (response.error) alert('Error: ' + response.error);
                } else {
                    document.getElementById('validationPreviewCount').innerText = 'Error';
                }
            }
        };
        xhr.send();
    }
    
    function applyBatchValidation() {
        var programme = document.getElementById('<%= ddlValidationProgramme.ClientID %>').value;
        var entryYear = document.getElementById('<%= ddlValidationEntryYear.ClientID %>').value;
        var entryNumbers = document.getElementById('txtValidationEntryNumbers').value.trim();
        var count = document.getElementById('validationPreviewCount').innerText;
        
        var filterDesc = entryNumbers ? ' (specific entry numbers)' : '';
        if (!entryNumbers && (programme || entryYear)) {
            filterDesc = ' (filtered';
            if (programme) filterDesc += ' by programme';
            if (entryYear) filterDesc += (programme ? ' and' : '') + ' by entry year ' + entryYear;
            filterDesc += ')';
        }
        
        if (!confirm('Are you sure you want to validate ' + count + ' students' + filterDesc + '?\n\nThis will update their has_passed, is_curriculum_fully_set, and fail_reason fields based on their curriculum.')) return;
        
        var params = {
            programme: entryNumbers ? '' : programme,
            entryYear: entryNumbers ? '' : entryYear,
            entryNumbers: entryNumbers
        };
        
        document.getElementById('btnApplyBatchValidation').disabled = true;
        document.getElementById('btnApplyBatchValidation').innerHTML = 'Validating...';
        
        var xhr = new XMLHttpRequest();
        xhr.open('POST', window.location.pathname + '?action=ApplyBatchValidation', true);
        xhr.setRequestHeader('Content-Type', 'application/json');
        xhr.onreadystatechange = function() {
            if (xhr.readyState === 4) {
                document.getElementById('btnApplyBatchValidation').innerHTML = '<svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="margin-right: 4px;"><polyline points="20 6 9 17 4 12"></polyline></svg> Validate Students';
                if (xhr.status === 200) {
                    var response = JSON.parse(xhr.responseText);
                    if (response.success) {
                        alert('Successfully validated ' + response.validated + ' students.\n\nThe page will now refresh.');
                        closeBatchValidationModal();
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
    
    // ========== SPECIALIZATION VALIDATOR FUNCTIONS ==========
    function openSpecValidatorModal() {
        document.getElementById('batchMenu').classList.remove('show');
        document.getElementById('specValidatorModal').style.display = 'flex';
        resetSpecValidatorForm();
    }
    
    function closeSpecValidatorModal() {
        document.getElementById('specValidatorModal').style.display = 'none';
    }
    
    function resetSpecValidatorForm() {
        document.getElementById('specSummarySection').style.display = 'none';
        document.getElementById('specSummaryTableBody').innerHTML = '';
        document.getElementById('specTotalCount').innerText = '0';
        document.getElementById('specFullySetCount').innerText = '0';
        document.getElementById('specNotFullySetCount').innerText = '0';
        document.getElementById('btnApplySpecValidation').disabled = true;
        document.getElementById('btnLoadSpecSummary').disabled = false;
        document.getElementById('btnLoadSpecSummary').innerHTML = '<svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="margin-right: 4px;"><circle cx="11" cy="11" r="8"></circle><line x1="21" y1="21" x2="16.65" y2="16.65"></line></svg> Load Specialization Summary';
    }
    
    function loadSpecSummary() {
        document.getElementById('btnLoadSpecSummary').disabled = true;
        document.getElementById('btnLoadSpecSummary').innerHTML = 'Loading...';
        
        var xhr = new XMLHttpRequest();
        xhr.open('GET', window.location.pathname + '?action=GetSpecSummary', true);
        xhr.onreadystatechange = function() {
            if (xhr.readyState === 4) {
                document.getElementById('btnLoadSpecSummary').disabled = false;
                document.getElementById('btnLoadSpecSummary').innerHTML = '<svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="margin-right: 4px;"><circle cx="11" cy="11" r="8"></circle><line x1="21" y1="21" x2="16.65" y2="16.65"></line></svg> Refresh Summary';
                
                if (xhr.status === 200) {
                    var response = JSON.parse(xhr.responseText);
                    if (response.success) {
                        renderSpecSummary(response.data);
                        document.getElementById('specSummarySection').style.display = 'block';
                        document.getElementById('btnApplySpecValidation').disabled = false;
                    } else {
                        alert('Error: ' + response.message);
                    }
                } else {
                    alert('An error occurred loading the summary.');
                }
            }
        };
        xhr.send();
    }
    
    function renderSpecSummary(data) {
        var tbody = document.getElementById('specSummaryTableBody');
        tbody.innerHTML = '';
        
        var totalCount = data.length;
        var fullySetCount = 0;
        var notFullySetCount = 0;
        
        data.forEach(function(spec) {
            var row = document.createElement('tr');
            
            // Determine validation issues
            var issues = [];
            if (spec.y1Courses < 5) issues.push('Y1 < 5');
            if (spec.y2Courses < 5) issues.push('Y2 < 5');
            if (spec.y1Courses > 12) issues.push('Y1 > 12');
            if (spec.y2Courses > 12) issues.push('Y2 > 12');
            if (spec.y3Courses > 12) issues.push('Y3 > 12');
            
            var shouldBeFullySet = issues.length === 0 && (spec.y1Courses >= 5 && spec.y2Courses >= 5);
            var currentStatus = spec.isFullySet;
            var newStatus = shouldBeFullySet ? 'Yes' : 'No';
            
            if (newStatus === 'Yes') fullySetCount++;
            else notFullySetCount++;
            
            var statusClass = newStatus === 'Yes' ? 'color: #28a745;' : 'color: #dc3545;';
            var statusText = newStatus === 'Yes' ? 'Fully Set' : 'Not Fully Set';
            if (issues.length > 0) statusText += ' (' + issues.join(', ') + ')';
            
            // Highlight cells with issues
            var y1Style = (spec.y1Courses < 5 || spec.y1Courses > 12) ? 'background: #fff3cd; font-weight: bold;' : '';
            var y2Style = (spec.y2Courses < 5 || spec.y2Courses > 12) ? 'background: #fff3cd; font-weight: bold;' : '';
            var y3Style = spec.y3Courses > 12 ? 'background: #fff3cd; font-weight: bold;' : '';
            
            row.innerHTML = '<td style="padding: 6px 8px; border-bottom: 1px solid #eee;">' + spec.specName + '</td>' +
                '<td style="padding: 6px 8px; border-bottom: 1px solid #eee; font-size: 10px; color: #666;">' + spec.progName + '</td>' +
                '<td style="padding: 6px 8px; border-bottom: 1px solid #eee; text-align: center; ' + y1Style + '">' + spec.y1Courses + '</td>' +
                '<td style="padding: 6px 8px; border-bottom: 1px solid #eee; text-align: center; ' + y2Style + '">' + spec.y2Courses + '</td>' +
                '<td style="padding: 6px 8px; border-bottom: 1px solid #eee; text-align: center; ' + y3Style + '">' + spec.y3Courses + '</td>' +
                '<td style="padding: 6px 8px; border-bottom: 1px solid #eee; text-align: center;">' + spec.y4Courses + '</td>' +
                '<td style="padding: 6px 8px; border-bottom: 1px solid #eee; text-align: center;">' + spec.studentCount + '</td>' +
                '<td style="padding: 6px 8px; border-bottom: 1px solid #eee; text-align: center; ' + statusClass + ' font-size: 10px;">' + statusText + '</td>';
            
            tbody.appendChild(row);
        });
        
        document.getElementById('specTotalCount').innerText = totalCount;
        document.getElementById('specFullySetCount').innerText = fullySetCount;
        document.getElementById('specNotFullySetCount').innerText = notFullySetCount;
    }
    
    function applySpecValidation() {
        if (!confirm('Are you sure you want to apply specialization validation?\n\nThis will update the is_fully_set status for all specializations based on the validation rules.')) return;
        
        document.getElementById('btnApplySpecValidation').disabled = true;
        document.getElementById('btnApplySpecValidation').innerHTML = 'Applying...';
        
        var xhr = new XMLHttpRequest();
        xhr.open('POST', window.location.pathname + '?action=ApplySpecValidation', true);
        xhr.setRequestHeader('Content-Type', 'application/json');
        xhr.onreadystatechange = function() {
            if (xhr.readyState === 4) {
                document.getElementById('btnApplySpecValidation').innerHTML = '<svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="margin-right: 4px;"><polyline points="20 6 9 17 4 12"></polyline></svg> Apply Validation';
                
                if (xhr.status === 200) {
                    var response = JSON.parse(xhr.responseText);
                    if (response.success) {
                        alert('Validation applied successfully!\n\n' + response.updatedToYes + ' specializations marked as Fully Set\n' + response.updatedToNo + ' specializations marked as Not Fully Set');
                        // Refresh the summary
                        loadSpecSummary();
                    } else {
                        alert('Error: ' + response.message);
                        document.getElementById('btnApplySpecValidation').disabled = false;
                    }
                } else {
                    alert('An error occurred. Please try again.');
                    document.getElementById('btnApplySpecValidation').disabled = false;
                }
            }
        };
        xhr.send('{}');
    }
</script>
