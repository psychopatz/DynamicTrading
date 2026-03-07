-- Rebuild/reset operations for DTNPC_SpatialHash.

DTNPC_SpatialHash = DTNPC_SpatialHash or {}

local SH = DTNPC_SpatialHash

function SH.RebuildFromRoster(rosterData)
    print("[SpatialHash] RebuildFromRoster called")
    if not rosterData or not rosterData.Souls then
        print("[SpatialHash] No roster data available")
        return
    end

    SH.Grid = {}
    SH.NPCToCell = {}
    SH.DirtyFlags = {}
    print("[SpatialHash] Cleared existing grid")

    local inserted = 0
    for uuid, soul in pairs(rosterData.Souls) do
        local x = soul.lastX or (soul.homeCoords and soul.homeCoords.x) or 0
        local y = soul.lastY or (soul.homeCoords and soul.homeCoords.y) or 0
        local z = soul.lastZ or (soul.homeCoords and soul.homeCoords.z) or 0

        if x > 0 and y > 0 then
            SH.InsertNPC(uuid, x, y, z, soul)
            inserted = inserted + 1
        end
    end

    SH.IsInitialized = true
    print("[DTNPC_SpatialHash] Rebuilt grid with " .. inserted .. " NPCs")
end

function SH.Clear()
    print("[SpatialHash] Clear called")
    SH.Grid = {}
    SH.NPCToCell = {}
    SH.DirtyFlags = {}
    SH.NextCleanup = 0
    SH.IsInitialized = false
end
