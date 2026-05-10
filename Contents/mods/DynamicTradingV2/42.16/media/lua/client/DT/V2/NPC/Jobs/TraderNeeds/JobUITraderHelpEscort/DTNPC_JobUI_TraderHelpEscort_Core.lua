-- ==============================================================================
-- DTNPC_JobUI_TraderHelpEscort_Core.lua
-- Shared state bootstrap for the trader help escort job UI.
-- ==============================================================================

DTNPC_JobUI_TraderHelpEscort = DTNPC_JobUI_TraderHelpEscort or {}

local EscortUI = DTNPC_JobUI_TraderHelpEscort
local modules = EscortUI.Modules or {}

EscortUI.Modules = modules

if modules.Core then
    return
end

modules.Core = true

EscortUI.Helpers = EscortUI.Helpers or {}
EscortUI.State = EscortUI.State or {}
EscortUI.HOOK_ID = EscortUI.HOOK_ID or "TraderNeeds.HelpEscort"

_G.DOTraderHelpEscortJobUI = EscortUI
