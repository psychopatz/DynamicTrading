-- ==============================================================================
-- DTNPC_JobUI_TraderHelpEscort.lua
-- Entry point for the trader help escort job UI.
-- Loads submodules in explicit dependency order.
-- ==============================================================================

DTNPC_JobUI_TraderHelpEscort = DTNPC_JobUI_TraderHelpEscort or {}

local EscortUI = DTNPC_JobUI_TraderHelpEscort

if EscortUI.EntryLoaded then
    return
end

EscortUI.EntryLoaded = true
EscortUI.Modules = EscortUI.Modules or {}
EscortUI.Helpers = EscortUI.Helpers or {}
EscortUI.State = EscortUI.State or {}

require "DT/V2/NPC/Jobs/TraderNeeds/JobUITraderHelpEscort/DTNPC_JobUI_TraderHelpEscort_Core"
require "DT/V2/NPC/Jobs/TraderNeeds/JobUITraderHelpEscort/DTNPC_JobUI_TraderHelpEscort_Navigation"
require "DT/V2/NPC/Jobs/TraderNeeds/JobUITraderHelpEscort/DTNPC_JobUI_TraderHelpEscort_Context"
require "DT/V2/NPC/Jobs/TraderNeeds/JobUITraderHelpEscort/DTNPC_JobUI_TraderHelpEscort_Status"
require "DT/V2/NPC/Jobs/TraderNeeds/JobUITraderHelpEscort/DTNPC_JobUI_TraderHelpEscort_Active"
require "DT/V2/NPC/Jobs/TraderNeeds/JobUITraderHelpEscort/DTNPC_JobUI_TraderHelpEscort_Pending"
require "DT/V2/NPC/Jobs/TraderNeeds/JobUITraderHelpEscort/DTNPC_JobUI_TraderHelpEscort_Events"
require "DT/V2/NPC/Jobs/TraderNeeds/JobUITraderHelpEscort/DTNPC_JobUI_TraderHelpEscort_Registry"
