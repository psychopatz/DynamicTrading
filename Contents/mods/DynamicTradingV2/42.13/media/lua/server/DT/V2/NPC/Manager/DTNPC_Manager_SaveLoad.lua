-- ==============================================================================
-- DTNPC_Manager_SaveLoad.lua
-- Save / Load system for NPC persistence.
-- ==============================================================================

-- GUARD: Ensure DTNPCManager table exists
DTNPCManager = DTNPCManager or {}

-- GUARD: Prevent Remote MP Clients from running this, but allow SP and Host
if isClient() and not isServer() then return end

function DTNPCManager.Load()
    local globalData = ModData.getOrCreate("DTNPC_GlobalList")
    DTNPCManager.Data = globalData.NPCs or {}
    globalData.NPCs = DTNPCManager.Data
    
    -- Outfit IDs are transient engine instance handles, not persistent identity.
    -- Rebuilding stale mappings across loads can bind a recycled body to the wrong soul.
    DTNPCManager.OutfitIDToUUID = {}
    for _, npcData in pairs(DTNPCManager.Data) do
        npcData.currentOutfitID = nil
    end
    
    DynamicTrading.Log("DTV2", "NPC", "Save", "Manager Loaded. Tracking " .. tostring(DTNPCManager.GetTableSize(DTNPCManager.Data)) .. " NPCs.")
end

function DTNPCManager.Save()
    local globalData = ModData.getOrCreate("DTNPC_GlobalList")
    globalData.NPCs = DTNPCManager.Data
    
    if GlobalModData and GlobalModData.save then
        GlobalModData.save()
    end
end

Events.OnInitGlobalModData.Add(DTNPCManager.Load)

local function onSaveGame()
    DTNPCManager.Save()
end
Events.OnSave.Add(onSaveGame)
