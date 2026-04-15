local function debugLog(message)
    if DynamicTrading and DynamicTrading.Log then
        DynamicTrading.Log("DTCommon", "Compat", "Farming", tostring(message))
    end
end

local function isValidDigPlow(item)
    return item
        and item.isBroken
        and item.hasTag
        and item:isBroken() ~= true
        and item:hasTag(ItemTag.DIG_PLOW)
end

local function findDigPlowRecursive(container, visited)
    if not container or not container.getItems then
        return nil
    end

    visited = visited or {}
    if visited[container] then
        return nil
    end
    visited[container] = true

    local items = container:getItems()
    if not items or not items.size or not items.get then
        return nil
    end

    for i = 0, items:size() - 1 do
        local item = items:get(i)
        if isValidDigPlow(item) then
            return item
        end
    end

    for i = 0, items:size() - 1 do
        local item = items:get(i)
        local subContainer = item and item.getItemContainer and item:getItemContainer() or nil
        local found = findDigPlowRecursive(subContainer, visited)
        if found then
            return found
        end
    end

    return nil
end

local function patchFarmingMenu()
    if not ISFarmingMenu then
        return
    end
    if ISFarmingMenu._dtSafeGetShovelPatched == true then
        return
    end

    ISFarmingMenu.getShovel = function(player)
        if not player or not player.getInventory then
            return nil
        end

        local handItem = player.getPrimaryHandItem and player:getPrimaryHandItem() or nil
        if isValidDigPlow(handItem) then
            return handItem
        end

        local playerInv = player:getInventory()
        if not playerInv then
            return nil
        end

        return findDigPlowRecursive(playerInv)
    end

    ISFarmingMenu._dtSafeGetShovelPatched = true
    debugLog("Applied safe ISFarmingMenu.getShovel compatibility patch.")
end

local function tryPatch()
    local ok, err = pcall(patchFarmingMenu)
    if not ok then
        debugLog("Failed to patch ISFarmingMenu.getShovel: " .. tostring(err))
    end
end

Events.OnGameBoot.Add(tryPatch)
Events.OnGameStart.Add(tryPatch)
