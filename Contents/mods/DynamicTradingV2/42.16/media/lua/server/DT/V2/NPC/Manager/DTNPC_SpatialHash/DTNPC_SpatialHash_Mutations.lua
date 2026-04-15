-- Insert and remove operations for DTNPC_SpatialHash.

DTNPC_SpatialHash = DTNPC_SpatialHash or {}
DTNPC_SpatialHash._internal = DTNPC_SpatialHash._internal or {}

local I = DTNPC_SpatialHash._internal

function DTNPC_SpatialHash.InsertNPC(uuid, x, y, z, soul)
    if not uuid or not x or not y then return end

    local gridKey = I.getGridKey(x, y)

    local oldKey = DTNPC_SpatialHash.NPCToCell[uuid]
    if oldKey and oldKey ~= gridKey then
        local oldCell = DTNPC_SpatialHash.Grid[oldKey]
        if oldCell ~= nil then
            if not I.isTable(oldCell) then
                I.logCorruptCell("InsertNPC(old)", oldKey, oldCell)
                DTNPC_SpatialHash.Grid[oldKey] = nil
                DTNPC_SpatialHash.DirtyFlags[oldKey] = nil
            else
                oldCell[uuid] = nil
                DTNPC_SpatialHash.DirtyFlags[oldKey] = true
            end
        end
    end

    local targetCell = DTNPC_SpatialHash.Grid[gridKey]
    if targetCell ~= nil and not I.isTable(targetCell) then
        I.logCorruptCell("InsertNPC(new)", gridKey, targetCell)
        targetCell = nil
    end

    if not targetCell then
        DTNPC_SpatialHash.Grid[gridKey] = {}
        targetCell = DTNPC_SpatialHash.Grid[gridKey]
    end

    targetCell[uuid] = {
        x = x,
        y = y,
        z = z,
        soul = soul
    }

    DTNPC_SpatialHash.NPCToCell[uuid] = gridKey
    DTNPC_SpatialHash.DirtyFlags[gridKey] = true
end

function DTNPC_SpatialHash.RemoveNPC(uuid)
    if not uuid then return end

    local gridKey = DTNPC_SpatialHash.NPCToCell[uuid]
    if gridKey then
        local cell = DTNPC_SpatialHash.Grid[gridKey]
        if cell ~= nil then
            if not I.isTable(cell) then
                I.logCorruptCell("RemoveNPC", gridKey, cell)
                DTNPC_SpatialHash.Grid[gridKey] = nil
                DTNPC_SpatialHash.DirtyFlags[gridKey] = nil
            else
                cell[uuid] = nil
                DTNPC_SpatialHash.DirtyFlags[gridKey] = true
            end
        end
    end

    DTNPC_SpatialHash.NPCToCell[uuid] = nil
end
