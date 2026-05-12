-- ==============================================================================
-- DTNPC_HealthRevive_Items.lua
-- Shared revive item counting and consumption helpers.
-- ==============================================================================

DTNPCHealth = DTNPCHealth or {}
DTNPCHealth.Internal = DTNPCHealth.Internal or {}

local internal = DTNPCHealth.Internal

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

function DTNPCHealth.CountReviveItems(playerObj)
    return eachReviveInventoryItem(playerObj, nil)
end

function DTNPCHealth.ConsumeReviveItems(playerObj, requiredCount)
    local needed = math.max(0, math.floor(tonumber(requiredCount) or 0))
    if needed <= 0 then
        return true, 0
    end

    if internal.isRemoteClient and internal.isRemoteClient() then
        return false, 0
    end

    local toRemove = {}
    eachReviveInventoryItem(playerObj, function(item)
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
