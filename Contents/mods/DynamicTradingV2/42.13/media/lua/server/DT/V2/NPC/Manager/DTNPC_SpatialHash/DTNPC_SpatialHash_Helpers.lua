-- Shared helpers for DTNPC_SpatialHash modules.

DTNPC_SpatialHash = DTNPC_SpatialHash or {}
DTNPC_SpatialHash._internal = DTNPC_SpatialHash._internal or {}

local I = DTNPC_SpatialHash._internal

function I.getGridKey(x, y)
    local gridX = math.floor(x / DTNPC_SpatialHash.CELL_SIZE)
    local gridY = math.floor(y / DTNPC_SpatialHash.CELL_SIZE)
    return gridX .. "_" .. gridY
end

function I.getCellsInRadius(x, y, radius)
    local cellRadius = math.ceil(radius / DTNPC_SpatialHash.CELL_SIZE)
    local centerGridX = math.floor(x / DTNPC_SpatialHash.CELL_SIZE)
    local centerGridY = math.floor(y / DTNPC_SpatialHash.CELL_SIZE)

    local cells = {}
    for gx = centerGridX - cellRadius, centerGridX + cellRadius do
        for gy = centerGridY - cellRadius, centerGridY + cellRadius do
            table.insert(cells, gx .. "_" .. gy)
        end
    end

    return cells
end

function I.isTable(value)
    return type(value) == "table"
end

function I.logCorruptCell(context, gridKey, value)
    DynamicTrading.Log("DTV2", "NPC", "Error", "[DTNPC_SpatialHash] Corrupt cell detected in " .. context .. " at " .. tostring(gridKey) .. " (type=" .. type(value) .. "), removing")
end
