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
        local worker = CompanionUI.GetCompanionWorker(ui, npc, npcData)
        local name = tostring(defaultName or (npcData and npcData.name) or "Survivor")
        if CompanionUI.IsPlayerZoneResident(npcData, worker) then
            return "Talk to Colony Resident " .. name
        end
        return "Talk to Companion " .. name
    end,
    getTraderProxyPatch = function(ui, npc, player, npcData)
        local worker = CompanionUI.GetCompanionWorker(ui, npc, npcData)
        local faction = CompanionUI.GetOwnedFactionForWorker(worker, npcData)
        return {
            factionID = faction and faction.id or (npcData and npcData.factionID) or nil,
            factionName = faction and faction.name or nil,
            linkedWorkerID = npcData and npcData.linkedWorkerID or nil,
            master = npcData and npcData.master or nil,
            masterID = npcData and npcData.masterID or nil,
            isCompanion = CompanionUI.IsPlayerZoneResident(npcData, worker) ~= true,
            isPlayerResident = CompanionUI.IsPlayerZoneResident(npcData, worker),
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
