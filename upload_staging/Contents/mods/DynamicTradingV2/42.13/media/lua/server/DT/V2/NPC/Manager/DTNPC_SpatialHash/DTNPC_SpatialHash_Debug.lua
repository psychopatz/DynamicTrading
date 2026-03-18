-- Debug helpers for DTNPC_SpatialHash.

DTNPC_SpatialHash = DTNPC_SpatialHash or {}
DTNPC_SpatialHash._internal = DTNPC_SpatialHash._internal or {}

local I = DTNPC_SpatialHash._internal

function DTNPC_SpatialHash.DebugCell(x, y)
    local gridKey = I.getGridKey(x, y)
    local cell = DTNPC_SpatialHash.Grid[gridKey]

    DynamicTrading.Log("DTV2", "NPC", "Debug", "[DTNPC_SpatialHash] Cell at (" .. x .. ", " .. y .. ") = " .. gridKey)

    if not cell or type(cell) ~= "table" then
        DynamicTrading.Log("DTV2", "NPC", "Debug", "  (empty or invalid)")
        return
    end

    local isEmpty = true
    for uuid, npcData in pairs(cell) do
        isEmpty = false
        DynamicTrading.Log("DTV2", "NPC", "Debug", "  - " .. uuid .. " at (" .. npcData.x .. ", " .. npcData.y .. ")")
    end

    if isEmpty then
        DynamicTrading.Log("DTV2", "NPC", "Debug", "  (empty)")
    end
end

function DTNPC_SpatialHash.DebugRadius(x, y, radius)
    local npcs = DTNPC_SpatialHash.GetNPCsInRadius(x, y, radius)

    DynamicTrading.Log("DTV2", "NPC", "Debug", "[DTNPC_SpatialHash] NPCs within " .. radius .. " tiles of (" .. x .. ", " .. y .. "):")

    local isEmpty = true
    for uuid, npcData in pairs(npcs) do
        isEmpty = false
        local dx = npcData.x - x
        local dy = npcData.y - y
        local dist = math.sqrt(dx * dx + dy * dy)
        DynamicTrading.Log("DTV2", "NPC", "Debug", "  - " .. uuid .. " at (" .. npcData.x .. ", " .. npcData.y .. "), dist=" .. string.format("%.1f", dist))
    end

    if isEmpty then
        DynamicTrading.Log("DTV2", "NPC", "Debug", "  (none)")
    end
end
