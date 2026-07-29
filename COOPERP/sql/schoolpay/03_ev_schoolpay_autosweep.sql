-- ============================================================================
-- ev_schoolpay_autosweep (campus_dynamics_accounts)   deployed 2026-06-30
-- ----------------------------------------------------------------------------
-- Self-healing safety net: every 10 minutes, auto-post any SchoolPay payment the
-- real-time webhook failed to capture (the webhook always INSERTs the row first,
-- so nothing is ever lost — it just sits captureStatus='Pending' until swept).
-- Requires the global event scheduler to be ON:  SET GLOBAL event_scheduler = ON;
-- ============================================================================
CREATE EVENT IF NOT EXISTS ev_schoolpay_autosweep
ON SCHEDULE EVERY 10 MINUTE
COMMENT 'Auto-post bounced/Pending SchoolPay payments (self-healing)'
DO CALL fin_SchoolPayRecaptureAllPending();

-- To pause:   ALTER EVENT ev_schoolpay_autosweep DISABLE;
-- To resume:  ALTER EVENT ev_schoolpay_autosweep ENABLE;
-- To remove:  DROP EVENT ev_schoolpay_autosweep;
