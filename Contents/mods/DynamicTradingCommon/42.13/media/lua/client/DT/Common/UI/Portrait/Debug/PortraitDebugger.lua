-- =============================================================================
-- DYNAMIC TRADING: SHARED PORTRAIT DEBUG ENTRYPOINT
-- =============================================================================
-- Common alias so V1 and V2 can open the shared portrait debugger through the
-- same require target/global name.
-- =============================================================================

if not isDebugEnabled() then
    return
end

require "DT/Common/UI/Portrait/Debug/DT_NPCPortraitDebugWindow"

DTNPC_PortraitDebugger = DTNPC_PortraitDebugger or DT_NPCPortraitDebugWindow

return DTNPC_PortraitDebugger
