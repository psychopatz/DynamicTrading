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
    
    -- Body instance IDs are not stable enough to rebuild global UUID mappings across loads.
    -- We only keep the last seen value as a startup hint so nearby live bodies can be
    -- reattached after a restart before the normal tracking loop refreshes them.
    DTNPCManager.BodyInstanceIDToUUID = {}
    for _, npcData in pairs(DTNPCManager.Data) do
        npcData.startupBodyInstanceHint = npcData.currentBodyInstanceID or npcData.startupBodyInstanceHint
        npcData.currentBodyInstanceID = nil
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
