-- Query and stats operations for DTNPC_SpatialHash.

DTNPC_SpatialHash = DTNPC_SpatialHash or {}
DTNPC_SpatialHash._internal = DTNPC_SpatialHash._internal or {}

local I = DTNPC_SpatialHash._internal

function DTNPC_SpatialHash.GetNPCsInRadius(x, y, radius)
    local cells = I.getCellsInRadius(x, y, radius)
    local result = {}

    for _, gridKey in ipairs(cells) do
        local cell = DTNPC_SpatialHash.Grid[gridKey]
        if cell ~= nil then
            if not I.isTable(cell) then
                I.logCorruptCell("GetNPCsInRadius", gridKey, cell)
                DTNPC_SpatialHash.Grid[gridKey] = nil
                DTNPC_SpatialHash.DirtyFlags[gridKey] = nil
            else
                for uuid, npcData in pairs(cell) do
                    if not I.isTable(npcData) or type(npcData.x) ~= "number" or type(npcData.y) ~= "number" then
                        DynamicTrading.Log("DTV2", "NPC", "Warn", "[DTNPC_SpatialHash] Invalid NPC payload in " .. tostring(gridKey) .. " for " .. tostring(uuid) .. ", skipping")
                    else
                        local dx = npcData.x - x
                        local dy = npcData.y - y
                        local dist = math.sqrt(dx * dx + dy * dy)

                        if dist <= radius then
                            result[uuid] = npcData
                        end
                    end
                end
            end
        end
    end

    return result
end

function DTNPC_SpatialHash.GetNearestNPCs(x, y, radius, maxResults)
    local npcs = DTNPC_SpatialHash.GetNPCsInRadius(x, y, radius)

    if not maxResults or maxResults >= #npcs then
        return npcs
    end

    local sorted = {}
    for uuid, npcData in pairs(npcs) do
        local dx = npcData.x - x
        local dy = npcData.y - y
        local dist = math.sqrt(dx * dx + dy * dy)
        table.insert(sorted, { uuid = uuid, data = npcData, dist = dist })
    end

    table.sort(sorted, function(a, b) return a.dist < b.dist end)

    local limited = {}
    for i = 1, math.min(maxResults, #sorted) do
        limited[sorted[i].uuid] = sorted[i].data
    end

    return limited
end

function DTNPC_SpatialHash.GetGridStats()
    local cellCount = 0
    local totalNPCs = 0
    local toRemove = {}

    for gridKey, cell in pairs(DTNPC_SpatialHash.Grid) do
        if type(cell) ~= "table" then
            DynamicTrading.Log("DTV2", "NPC", "Error", "[SpatialHash] Corrupt cell in GetGridStats at " .. gridKey)
            table.insert(toRemove, gridKey)
        else
            local hasEntries = false
            for _ in pairs(cell) do
                hasEntries = true
                totalNPCs = totalNPCs + 1
            end

            if hasEntries then
                cellCount = cellCount + 1
            end
        end
    end

    for _, gridKey in ipairs(toRemove) do
        DTNPC_SpatialHash.Grid[gridKey] = nil
        DTNPC_SpatialHash.DirtyFlags[gridKey] = nil
    end

    return {
        cellCount = cellCount,
        totalNPCs = totalNPCs,
        gridSize = DTNPC_SpatialHash.CELL_SIZE
    }
end
