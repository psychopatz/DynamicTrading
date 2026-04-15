-- =============================================================================
-- DTNPC_PortraitDebugger.lua (V2 Shim)
-- =============================================================================
-- Shared implementation now lives in DynamicTradingCommon.
-- =============================================================================

if not isDebugEnabled() then
    return
end

require "DT/Common/UI/Portrait/Debug/PortraitDebugger"

return DTNPC_PortraitDebugger
