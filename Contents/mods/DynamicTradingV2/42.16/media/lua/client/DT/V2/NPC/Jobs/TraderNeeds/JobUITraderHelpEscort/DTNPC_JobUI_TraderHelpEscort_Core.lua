-- ==============================================================================
-- DTNPC_JobUI_TraderHelpEscort_Core.lua
-- Shared state bootstrap for the trader help escort job UI.
-- ==============================================================================

require "DT/Common/Text/DT_Text"

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

function EscortUI.T(key, params, fallback)
    if DynamicTrading and DynamicTrading.Text and DynamicTrading.Text.Get then
        return DynamicTrading.Text.Get(key, params, fallback)
    end

    if fallback then
        return DynamicTrading.Text and DynamicTrading.Text.Format and DynamicTrading.Text.Format(fallback, params) or fallback
    end

    return tostring(key or "")
end

_G.DOTraderHelpEscortJobUI = EscortUI
