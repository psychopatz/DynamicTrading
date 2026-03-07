-- Debug helpers for DTNPC_SpatialHash.

DTNPC_SpatialHash = DTNPC_SpatialHash or {}
DTNPC_SpatialHash._internal = DTNPC_SpatialHash._internal or {}

local I = DTNPC_SpatialHash._internal

function DTNPC_SpatialHash.DebugCell(x, y)
    local gridKey = I.getGridKey(x, y)
    local cell = DTNPC_SpatialHash.Grid[gridKey]

    print("[DTNPC_SpatialHash] Cell at (" .. x .. ", " .. y .. ") = " .. gridKey)

    if not cell or type(cell) ~= "table" then
        print("  (empty or invalid)")
        return
    end

    local isEmpty = true
    for uuid, npcData in pairs(cell) do
        isEmpty = false
        print("  - " .. uuid .. " at (" .. npcData.x .. ", " .. npcData.y .. ")")
    end

    if isEmpty then
        print("  (empty)")
    end
end

function DTNPC_SpatialHash.DebugRadius(x, y, radius)
    local npcs = DTNPC_SpatialHash.GetNPCsInRadius(x, y, radius)

    print("[DTNPC_SpatialHash] NPCs within " .. radius .. " tiles of (" .. x .. ", " .. y .. "):")

    local isEmpty = true
    for uuid, npcData in pairs(npcs) do
        isEmpty = false
        local dx = npcData.x - x
        local dy = npcData.y - y
        local dist = math.sqrt(dx * dx + dy * dy)
        print("  - " .. uuid .. " at (" .. npcData.x .. ", " .. npcData.y .. "), dist=" .. string.format("%.1f", dist))
    end

    if isEmpty then
        print("  (none)")
    end
end
