-- ==============================================================================
-- DTNPC_JobUI_TravelCompanion.lua
-- Entry point for the travel companion job UI.
-- Loads submodules in explicit dependency order.
-- ==============================================================================

pcall(require, "DC/UI/Colony/System/DC_System")
pcall(require, "DC/UI/Colony/SupplyWindow/DC_SupplyWindow")
pcall(require, "DT/V2/NPC/LootSearch/DTNPC_LootSearch_Client")
pcall(require, "DT/V2/NPC/UI/DTNPC_CommandEmotes")
pcall(require, "DT/V2/NPC/UI/DTNPC_TraderDialogue_Hub")

DTNPC_JobUI_TravelCompanion = DTNPC_JobUI_TravelCompanion or {}

local CompanionUI = DTNPC_JobUI_TravelCompanion

if CompanionUI.EntryLoaded then
    return
end

CompanionUI.EntryLoaded = true
CompanionUI.Modules = CompanionUI.Modules or {}
CompanionUI.Constants = CompanionUI.Constants or {}
CompanionUI.State = CompanionUI.State or {}

require "DT/V2/NPC/Jobs/TravelCompanion/JobUITravelCompanion/DTNPC_JobUI_TravelCompanion_Core"
require "DT/V2/NPC/Jobs/TravelCompanion/JobUITravelCompanion/DTNPC_JobUI_TravelCompanion_Navigation"
require "DT/V2/NPC/Jobs/TravelCompanion/JobUITravelCompanion/DTNPC_JobUI_TravelCompanion_Authority"
require "DT/V2/NPC/Jobs/TravelCompanion/JobUITravelCompanion/DTNPC_JobUI_TravelCompanion_Medical"
require "DT/V2/NPC/Jobs/TravelCompanion/JobUITravelCompanion/DTNPC_JobUI_TravelCompanion_Worker"
require "DT/V2/NPC/Jobs/TravelCompanion/JobUITravelCompanion/DTNPC_JobUI_TravelCompanion_Inventory"
require "DT/V2/NPC/Jobs/TravelCompanion/JobUITravelCompanion/DTNPC_JobUI_TravelCompanion_Orders"
require "DT/V2/NPC/Jobs/TravelCompanion/JobUITravelCompanion/DTNPC_JobUI_TravelCompanion_Modes"
require "DT/V2/NPC/Jobs/TravelCompanion/JobUITravelCompanion/DTNPC_JobUI_TravelCompanion_Dialogue"
require "DT/V2/NPC/Jobs/TravelCompanion/JobUITravelCompanion/DTNPC_JobUI_TravelCompanion_ContextMenu"
require "DT/V2/NPC/Jobs/TravelCompanion/JobUITravelCompanion/DTNPC_JobUI_TravelCompanion_Registry"
