-- ==============================================================================
-- DTNPC_JobUI_TravelCompanion_Registry.lua
-- Job UI registration for travel companion interactions.
-- ==============================================================================

DTNPC_JobUI_TravelCompanion = DTNPC_JobUI_TravelCompanion or {}

local CompanionUI = DTNPC_JobUI_TravelCompanion
local modules = CompanionUI.Modules or {}

CompanionUI.Modules = modules

if modules.Registry then
    return
end

modules.Registry = true

DTNPCJobUI.Register({
    id = "TravelCompanion",
    priority = 100,
    matches = function(ui, npc, player, npcData)
        npcData = npcData or CompanionUI.GetNPCData(npc)
        if not npcData then
            return false
        end

        if CompanionUI.GetCompanionWorker(ui, npc, npcData) then
            return true
        end

        return CompanionUI.IsLegacyTravelCompanion(player, npcData)
    end,
    getTalkLabel = function(ui, npc, player, npcData, defaultName)
        return "Talk to Companion " .. tostring(defaultName or (npcData and npcData.name) or "Survivor")
    end,
    getTraderProxyPatch = function(ui, npc, player, npcData)
        return {
            linkedWorkerID = npcData and npcData.linkedWorkerID or nil,
            master = npcData and npcData.master or nil,
            masterID = npcData and npcData.masterID or nil,
            isCompanion = true,
        }
    end,
    generateOptions = function(ui, npc, player, npcData)
        local worker = CompanionUI.GetCompanionWorker(ui, npc, npcData or CompanionUI.GetNPCData(npc))
        CompanionUI.GenerateRootOptions(ui, npc, player, worker)
        return true
    end,
    addContextMenuOptions = function(context, ui, npc, player, npcData)
        return CompanionUI.AddCompanionContextMenu(context, ui, npc, player, npcData or CompanionUI.GetNPCData(npc))
    end
})
