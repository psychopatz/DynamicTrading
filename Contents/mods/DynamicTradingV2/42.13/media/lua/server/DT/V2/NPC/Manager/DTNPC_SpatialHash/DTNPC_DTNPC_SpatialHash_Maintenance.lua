-- Cleanup and dirty-flag operations for DTNPC_SpatialHash.

DTNPC_SpatialHash = DTNPC_SpatialHash or {}

local SH = DTNPC_SpatialHash

function SH.CleanupEmptyCells()
    local currentTime = getGameTime():getWorldAgeHours()

    if currentTime < SH.NextCleanup then
        return
    end

    local cleaned = 0
    local toRemove = {}

    for gridKey, cell in pairs(SH.Grid) do
        if type(cell) ~= "table" then
            print("[SpatialHash] Corrupt cell detected at " .. gridKey .. ", type: " .. type(cell))
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
        SH.Grid[gridKey] = nil
        SH.DirtyFlags[gridKey] = nil
    end

    SH.NextCleanup = currentTime + SH.CLEANUP_INTERVAL

    if cleaned > 0 then
        print("[DTNPC_SpatialHash] Cleaned up " .. cleaned .. " empty cells")
    end
end

function SH.ClearDirtyFlags()
    SH.DirtyFlags = {}
end

function SH.GetDirtyCells()
    local result = {}
    for gridKey, _ in pairs(SH.DirtyFlags) do
        table.insert(result, gridKey)
    end
    return result
end
