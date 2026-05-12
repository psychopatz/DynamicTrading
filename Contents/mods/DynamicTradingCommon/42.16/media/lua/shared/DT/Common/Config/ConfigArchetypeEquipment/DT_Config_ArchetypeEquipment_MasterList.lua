-- =============================================================================
-- ARCHETYPE EQUIPMENT: MASTER LIST
-- =============================================================================

DynamicTrading = DynamicTrading or {}
DynamicTrading.ArchetypeEquipmentInternal = DynamicTrading.ArchetypeEquipmentInternal or {}

local internal = DynamicTrading.ArchetypeEquipmentInternal

function internal.getMasterList()
    return DynamicTrading
        and DynamicTrading.Config
        and type(DynamicTrading.Config.MasterList) == "table"
        and DynamicTrading.Config.MasterList
        or {}
end

function internal.getMasterListCount()
    local count = 0
    for _ in pairs(internal.getMasterList()) do
        count = count + 1
    end
    return count
end

function internal.getScriptItem(fullType)
    if not fullType or fullType == "" or not getScriptManager then
        return nil
    end

    local manager = getScriptManager()
    if not manager then
        return nil
    end
    if manager.FindItem then
        return manager:FindItem(fullType)
    end
    if manager.getItem then
        return manager:getItem(fullType)
    end

    return nil
end

function internal.getSortedMasterListKeys()
    local keys = {}
    for key, itemData in pairs(internal.getMasterList()) do
        local item = type(itemData) == "table" and itemData.item or key
        if item and item ~= "" then
            keys[#keys + 1] = key
        end
    end

    table.sort(keys, function(left, right)
        local masterList = internal.getMasterList()
        local leftItem = type(masterList[left]) == "table" and masterList[left].item or left
        local rightItem = type(masterList[right]) == "table" and masterList[right].item or right
        return tostring(leftItem) < tostring(rightItem)
    end)

    return keys
end
