-- Query and stats operations for DTNPC_SpatialHash.

DTNPC_SpatialHash = DTNPC_SpatialHash or {}
DTNPC_SpatialHash._internal = DTNPC_SpatialHash._internal or {}

local SH = DTNPC_SpatialHash
local I = SH._internal

function SH.GetNPCsInRadius(x, y, radius)
    local cells = I.getCellsInRadius(x, y, radius)
    local result = {}

    for _, gridKey in ipairs(cells) do
        local cell = SH.Grid[gridKey]
        if cell ~= nil then
            if not I.isTable(cell) then
                I.logCorruptCell("GetNPCsInRadius", gridKey, cell)
                SH.Grid[gridKey] = nil
                SH.DirtyFlags[gridKey] = nil
            else
                for uuid, npcData in pairs(cell) do
                    if not I.isTable(npcData) or type(npcData.x) ~= "number" or type(npcData.y) ~= "number" then
                        print("[DTNPC_SpatialHash] Invalid NPC payload in " .. tostring(gridKey) .. " for " .. tostring(uuid) .. ", skipping")
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

function SH.GetNearestNPCs(x, y, radius, maxResults)
    local npcs = SH.GetNPCsInRadius(x, y, radius)

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

function SH.GetGridStats()
    local cellCount = 0
    local totalNPCs = 0
    local toRemove = {}

    for gridKey, cell in pairs(SH.Grid) do
        if type(cell) ~= "table" then
            print("[SpatialHash] Corrupt cell in GetGridStats at " .. gridKey)
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
        SH.Grid[gridKey] = nil
        SH.DirtyFlags[gridKey] = nil
    end

    return {
        cellCount = cellCount,
        totalNPCs = totalNPCs,
        gridSize = SH.CELL_SIZE
    }
end
