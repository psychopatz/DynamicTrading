-- Rebuild/reset operations for DTNPC_SpatialHash.

DTNPC_SpatialHash = DTNPC_SpatialHash or {}

function DTNPC_SpatialHash.RebuildFromRoster(rosterData)
    DynamicTrading.Log("DTV2", "NPC", "SpatialHash", "RebuildFromRoster called")
    if not rosterData or not rosterData.Souls then
        DynamicTrading.Log("DTV2", "NPC", "SpatialHash", "No roster data available")
        return
    end

    DTNPC_SpatialHash.Grid = {}
    DTNPC_SpatialHash.NPCToCell = {}
    DTNPC_SpatialHash.DirtyFlags = {}
    DynamicTrading.Log("DTV2", "NPC", "SpatialHash", "Cleared existing grid")

    local inserted = 0
    for uuid, soul in pairs(rosterData.Souls) do
        local x = soul.lastX or (soul.homeCoords and soul.homeCoords.x) or 0
        local y = soul.lastY or (soul.homeCoords and soul.homeCoords.y) or 0
        local z = soul.lastZ or (soul.homeCoords and soul.homeCoords.z) or 0

        if x > 0 and y > 0 then
            DTNPC_SpatialHash.InsertNPC(uuid, x, y, z, soul)
            inserted = inserted + 1
        end
    end

    DTNPC_SpatialHash.IsInitialized = true
    DynamicTrading.Log("DTV2", "NPC", "SpatialHash", "Rebuilt grid with " .. inserted .. " NPCs")
end

function DTNPC_SpatialHash.Clear()
    DynamicTrading.Log("DTV2", "NPC", "SpatialHash", "Clear called")
    DTNPC_SpatialHash.Grid = {}
    DTNPC_SpatialHash.NPCToCell = {}
    DTNPC_SpatialHash.DirtyFlags = {}
    DTNPC_SpatialHash.NextCleanup = 0
    DTNPC_SpatialHash.IsInitialized = false
end
