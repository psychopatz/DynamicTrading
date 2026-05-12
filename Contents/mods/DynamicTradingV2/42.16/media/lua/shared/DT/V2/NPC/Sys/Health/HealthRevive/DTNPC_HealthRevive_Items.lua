-- ==============================================================================
-- DTNPC_HealthRevive_Items.lua
-- Shared revive item counting and consumption helpers.
-- ==============================================================================

DTNPCHealth = DTNPCHealth or {}
DTNPCHealth.Internal = DTNPCHealth.Internal or {}

local internal = DTNPCHealth.Internal

local function isValidReviveItemType(fullType)
    local wanted = tostring(fullType or "")
    if wanted == "" then
        return false
    end

    local itemTypes = DTNPCHealth.REVIVE_VALID_ITEM_TYPES or {}
    for i = 1, #itemTypes do
        if tostring(itemTypes[i]) == wanted then
            return true
        end
    end

    return false
end

internal.isValidReviveItemType = isValidReviveItemType

local function eachReviveInventoryItem(playerObj, callback)
    if not playerObj or not playerObj.getInventory then
        return 0
    end

    local inventory = playerObj:getInventory()
    if not inventory or not inventory.getItemsFromType then
        return 0
    end

    local total = 0
    local itemTypes = DTNPCHealth.REVIVE_VALID_ITEM_TYPES or {}
    for i = 1, #itemTypes do
        local items = inventory:getItemsFromType(itemTypes[i], true)
        if items then
            for index = 0, items:size() - 1 do
                local item = items:get(index)
                if item then
                    total = total + 1
                    if callback and callback(item, itemTypes[i], total) == false then
                        return total
                    end
                end
            end
        end
    end

    return total
end

internal.eachReviveInventoryItem = eachReviveInventoryItem

function DTNPCHealth.CountReviveItems(playerObj, fullType)
    local requestedType = fullType ~= nil and tostring(fullType) or nil
    if requestedType and requestedType ~= "" and not isValidReviveItemType(requestedType) then
        return 0
    end

    if not requestedType or requestedType == "" then
        return eachReviveInventoryItem(playerObj, nil)
    end

    local count = 0
    eachReviveInventoryItem(playerObj, function(item)
        if item and tostring(item:getFullType() or "") == requestedType then
            count = count + 1
        end
    end)
    return count
end

function DTNPCHealth.GetReviveItemEntries(playerObj)
    local entries = {}
    local byType = {}

    eachReviveInventoryItem(playerObj, function(item)
        local fullType = tostring(item:getFullType() or "")
        local entry = byType[fullType]
        if not entry then
            entry = {
                fullType = fullType,
                count = 0,
                displayName = item.getDisplayName and item:getDisplayName() or fullType,
                sampleItem = item,
            }
            byType[fullType] = entry
            entries[#entries + 1] = entry
        end
        entry.count = tonumber(entry.count or 0) + 1
    end)

    table.sort(entries, function(left, right)
        local leftCount = tonumber(left and left.count) or 0
        local rightCount = tonumber(right and right.count) or 0
        if leftCount == rightCount then
            return tostring(left and left.displayName or left and left.fullType or "")
                < tostring(right and right.displayName or right and right.fullType or "")
        end
        return leftCount > rightCount
    end)

    return entries
end

function DTNPCHealth.ConsumeReviveItems(playerObj, requiredCount, fullType)
    local needed = math.max(0, math.floor(tonumber(requiredCount) or 0))
    if needed <= 0 then
        return true, 0
    end

    if internal.isRemoteClient and internal.isRemoteClient() then
        return false, 0
    end

    local toRemove = {}
    local requestedType = fullType ~= nil and tostring(fullType) or nil
    if requestedType and requestedType ~= "" and not isValidReviveItemType(requestedType) then
        return false, 0
    end

    eachReviveInventoryItem(playerObj, function(item)
        if requestedType and requestedType ~= "" and tostring(item:getFullType() or "") ~= requestedType then
            return true
        end
        toRemove[#toRemove + 1] = item
        return #toRemove < needed
    end)

    if #toRemove < needed then
        return false, #toRemove
    end

    for i = 1, needed do
        local item = toRemove[i]
        if item then
            if DynamicTrading and DynamicTrading.ServerHelpers and DynamicTrading.ServerHelpers.RemoveItem then
                DynamicTrading.ServerHelpers.RemoveItem(item)
            else
                local container = item:getContainer()
                if container then
                    container:DoRemoveItem(item)
                end
            end
        end
    end

    return true, needed
end
