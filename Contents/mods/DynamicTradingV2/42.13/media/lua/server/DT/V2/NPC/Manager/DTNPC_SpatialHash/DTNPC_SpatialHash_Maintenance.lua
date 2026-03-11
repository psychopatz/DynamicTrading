-- Cleanup and dirty-flag operations for DTNPC_SpatialHash.

DTNPC_SpatialHash = DTNPC_SpatialHash or {}

function DTNPC_SpatialHash.CleanupEmptyCells()
    local currentTime = getGameTime():getWorldAgeHours()

    if currentTime < DTNPC_SpatialHash.NextCleanup then
        return
    end

    local cleaned = 0
    local toRemove = {}

    for gridKey, cell in pairs(DTNPC_SpatialHash.Grid) do
        if type(cell) ~= "table" then
            DynamicTrading.Log("DTV2", "NPC", "Error", "[SpatialHash] Corrupt cell detected at " .. gridKey .. ", type: " .. type(cell))
            table.insert(toRemove, gridKey)
            cleaned = cleaned + 1
        else
            local isEmpty = true
            for _ in pairs(cell) do
                isEmpty = false
                break
            end

            if isEmpty then
                table.insert(toRemove, gridKey)
                cleaned = cleaned + 1
            end
        end
    end

    for _, gridKey in ipairs(toRemove) do
        DTNPC_SpatialHash.Grid[gridKey] = nil
        DTNPC_SpatialHash.DirtyFlags[gridKey] = nil
    end

    DTNPC_SpatialHash.NextCleanup = currentTime + DTNPC_SpatialHash.CLEANUP_INTERVAL

    if cleaned > 0 then
        DynamicTrading.Log("DTV2", "NPC", "SpatialHash", "Cleaned up " .. cleaned .. " empty cells")
    end
end

function DTNPC_SpatialHash.ClearDirtyFlags()
    DTNPC_SpatialHash.DirtyFlags = {}
end

function DTNPC_SpatialHash.GetDirtyCells()
    local result = {}
    for gridKey, _ in pairs(DTNPC_SpatialHash.DirtyFlags) do
        table.insert(result, gridKey)
    end
    return result
end
