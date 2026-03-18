if not DT_TradingItemUtils then DT_TradingItemUtils = {} end

--- Recursively finds an item by ID in a container and its sub-containers.
function DT_TradingItemUtils.findItemRecursively(container, itemID)
    if not container or not itemID then return nil end

    local items = container:getItems()
    for i = 0, items:size() - 1 do
        local it = items:get(i)
        if it:getID() == itemID then return it end
        if instanceof(it, "InventoryContainer") then
            local found = DT_TradingItemUtils.findItemRecursively(it:getItemContainer(), itemID)
            if found then return found end
        end
    end

    return nil
end
