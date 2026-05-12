-- ==============================================================================
-- DTNPC_JobUI_IncapacitatedRevive.lua
-- Entry point for incapacitated revive job UI.
-- ==============================================================================

DTNPC_JobUI_IncapacitatedRevive = DTNPC_JobUI_IncapacitatedRevive or {}

local ReviveUI = DTNPC_JobUI_IncapacitatedRevive

if ReviveUI.EntryLoaded then
    return
end

ReviveUI.EntryLoaded = true
ReviveUI.Modules = ReviveUI.Modules or {}
ReviveUI.State = ReviveUI.State or {}

pcall(require, "DT/V2/NPC/UI/DTNPC_WaveHiInteraction")
require "DT/V2/NPC/Jobs/IncapacitatedRevive/DTNPC_JobUI_IncapacitatedRevive_Context"
require "DT/V2/NPC/Jobs/IncapacitatedRevive/DTNPC_JobUI_IncapacitatedRevive_TimedAction"
require "DT/V2/NPC/Jobs/IncapacitatedRevive/DTNPC_JobUI_IncapacitatedRevive_Conversation"
require "DT/V2/NPC/Jobs/IncapacitatedRevive/DTNPC_JobUI_IncapacitatedRevive_Events"
require "DT/V2/NPC/Jobs/IncapacitatedRevive/DTNPC_JobUI_IncapacitatedRevive_Registry"
