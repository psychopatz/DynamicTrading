-- ==============================================================================
-- DTNPC_Manager_SaveLoad.lua
-- Save / Load system for NPC persistence.
-- ==============================================================================

-- GUARD: Prevent Remote MP Clients from running this, but allow SP and Host
if isClient() and not isServer() then return end

function DTNPCManager.Load()
    local globalData = ModData.getOrCreate("DTNPC_GlobalList")
    DTNPCManager.Data = globalData.NPCs or {}
    globalData.NPCs = DTNPCManager.Data
    
    -- Rebuild outfit ID mapping
    DTNPCManager.OutfitIDToUUID = {}
    for uuid, brain in pairs(DTNPCManager.Data) do
        if brain.currentOutfitID then
            DTNPCManager.OutfitIDToUUID[brain.currentOutfitID] = uuid
        end
    end
    
    print("[DTNPC] Manager Loaded. Tracking " .. tostring(DTNPCManager.GetTableSize(DTNPCManager.Data)) .. " NPCs.")
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
