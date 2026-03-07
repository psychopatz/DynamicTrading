-- Insert and remove operations for DTNPC_SpatialHash.

DTNPC_SpatialHash = DTNPC_SpatialHash or {}
DTNPC_SpatialHash._internal = DTNPC_SpatialHash._internal or {}

local SH = DTNPC_SpatialHash
local I = SH._internal

function SH.InsertNPC(uuid, x, y, z, soul)
    if not uuid or not x or not y then return end

    local gridKey = I.getGridKey(x, y)

    local oldKey = SH.NPCToCell[uuid]
    if oldKey and oldKey ~= gridKey then
        local oldCell = SH.Grid[oldKey]
        if oldCell ~= nil then
            if not I.isTable(oldCell) then
                I.logCorruptCell("InsertNPC(old)", oldKey, oldCell)
                SH.Grid[oldKey] = nil
                SH.DirtyFlags[oldKey] = nil
            else
                oldCell[uuid] = nil
                SH.DirtyFlags[oldKey] = true
            end
        end
    end

    local targetCell = SH.Grid[gridKey]
    if targetCell ~= nil and not I.isTable(targetCell) then
        I.logCorruptCell("InsertNPC(new)", gridKey, targetCell)
        targetCell = nil
    end

    if not targetCell then
        SH.Grid[gridKey] = {}
        targetCell = SH.Grid[gridKey]
    end

    targetCell[uuid] = {
        x = x,
        y = y,
        z = z,
        soul = soul
    }

    SH.NPCToCell[uuid] = gridKey
    SH.DirtyFlags[gridKey] = true
end

function SH.RemoveNPC(uuid)
    if not uuid then return end

    local gridKey = SH.NPCToCell[uuid]
    if gridKey then
        local cell = SH.Grid[gridKey]
        if cell ~= nil then
            if not I.isTable(cell) then
                I.logCorruptCell("RemoveNPC", gridKey, cell)
                SH.Grid[gridKey] = nil
                SH.DirtyFlags[gridKey] = nil
            else
                cell[uuid] = nil
                SH.DirtyFlags[gridKey] = true
            end
        end
    end

    SH.NPCToCell[uuid] = nil
end
