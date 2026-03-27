-- =============================================================================
-- DYNAMIC TRADING COMMON: SERVER HELPERS - INVENTORY LOGIC
-- =============================================================================
local Helpers = DynamicTrading.ServerHelpers

local function normalizeFluidType(fluidType)
    if fluidType == nil then return nil end
    local value = tostring(fluidType)
    local colonPos = string.find(value, ":", 1, true)
    if colonPos then
        value = string.sub(value, 1, colonPos - 1)
    end
    value = value:gsub("^%s+", ""):gsub("%s+$", "")
    if value == "" or string.lower(value) == "true" then
        return nil
    end
    return value
end

local function resolveScriptFluid(fluidType)
    local normalized = normalizeFluidType(fluidType)
    if not normalized or not getScriptManager then
        return nil, normalized
    end

    local scriptManager = getScriptManager()
    if not scriptManager or not scriptManager.getFluid then
        return nil, normalized
    end

    local scriptFluid = scriptManager:getFluid(normalized)
    if not scriptFluid and string.sub(normalized, 1, 5) == "Base." then
        scriptFluid = scriptManager:getFluid(string.sub(normalized, 6))
    elseif not scriptFluid then
        scriptFluid = scriptManager:getFluid("Base." .. normalized)
    end

    return scriptFluid, normalized
end

local function applyFluidState(item, customData)
    if not item or not customData or not item.getFluidContainer or not item:getFluidContainer() then
        return
    end

    local fluidContainer = item:getFluidContainer()
    local fluidType = normalizeFluidType(customData.fluidType)
    local amount = customData.fluidAmount
    local scriptFluid = nil

    if fluidType then
        scriptFluid = select(1, resolveScriptFluid(fluidType))

        local applied = false
        local attempts = {
            function()
                if scriptFluid and fluidContainer.clear then
                    fluidContainer:clear()
                end
            end,
            function()
                if scriptFluid and fluidContainer.setPrimaryFluid then
                    fluidContainer:setPrimaryFluid(scriptFluid)
                    applied = true
                end
            end,
            function()
                if scriptFluid and amount ~= nil and fluidContainer.setPrimaryFluid then
                    fluidContainer:setPrimaryFluid(scriptFluid, amount)
                    applied = true
                end
            end,
            function()
                if scriptFluid and fluidContainer.setFluid then
                    fluidContainer:setFluid(scriptFluid)
                    applied = true
                end
            end,
            function()
                if scriptFluid and amount ~= nil and fluidContainer.setFluid then
                    fluidContainer:setFluid(scriptFluid, amount)
                    applied = true
                end
            end,
            function()
                if scriptFluid and amount ~= nil and fluidContainer.addFluid then
                    fluidContainer:addFluid(scriptFluid, amount)
                    applied = true
                end
            end,
            function()
                if fluidType and fluidContainer.setFluidType then
                    fluidContainer:setFluidType(fluidType)
                    applied = true
                end
            end,
            function()
                if fluidType and amount ~= nil and fluidContainer.setFluidType then
                    fluidContainer:setFluidType(fluidType, amount)
                    applied = true
                end
            end,
            function()
                if fluidType and amount ~= nil and fluidContainer.addFluid then
                    fluidContainer:addFluid(fluidType, amount)
                    applied = true
                end
            end,
            function()
                if fluidType and amount ~= nil and fluidContainer.insertFluid then
                    fluidContainer:insertFluid(fluidType, amount)
                    applied = true
                end
            end,
        }

        for _, attempt in ipairs(attempts) do
            pcall(attempt)
            if applied then
                break
            end
        end
    end

    if amount ~= nil and fluidContainer.setAmount then
        pcall(function()
            fluidContainer:setAmount(amount)
        end)
    end
end

-- =============================================================================
-- 2. INVENTORY MANAGEMENT (ADD / REMOVE / FIND)
-- =============================================================================

--- Removes a specific item instance from its container and syncs to clients.
-- This is the preferred way to remove items on the server side.
-- @param item InventoryItem The item instance to remove.
function Helpers.RemoveItem(item)
    if not item then return end
    local container = item:getContainer()
    if not container then return end
    -- if isDebugEnabled() then
    --     print("[DynamicTradingCommon] Removing item: " .. item:getFullType() .. " from container: " .. container:getType())
    -- end
    
    -- Perform Action
    container:DoRemoveItem(item)
    
    -- Sync to Clients (MP only)
    if Helpers.ShouldSendNetworkPackets() then
        -- if isDebugEnabled() then
        --     print("[DynamicTradingCommon] Sending MP: RemoveItemFromContainer")
        -- end
        sendRemoveItemFromContainer(container, item)
    end
end

--- Adds items by type to a container and syncs to clients.
-- @param container ItemContainer The target container.
-- @param fullType string The full item type (e.g., "Base.Axe").
-- @param count number (Optional) The quantity to add. Defaults to 1.
function Helpers.AddItem(container, fullType, count)
    if not container or not fullType then return end
    local qty = count or 1
    -- if isDebugEnabled() then
    --     print("[DynamicTradingCommon] Adding item: " .. fullType .. " to container: " .. container:getType())
    -- end
    
    -- AddItems returns an ArrayList of the created items
    local items = container:AddItems(fullType, qty)
    
    -- Sync to Clients (MP only)
    if Helpers.ShouldSendNetworkPackets() and items then
        for i = 0, items:size() - 1 do
            local item = items:get(i)
            sendAddItemToContainer(container, item)
        end
    end
    
    return items
end

--- Adds items with custom condition/fluid data.
-- @param container ItemContainer
-- @param fullType string
-- @param count number
-- @param customData table { usedDelta=..., fluidAmount=... }
function Helpers.AddItemWithCondition(container, fullType, count, customData)
    if not container or not fullType then return end
    local qty = count or 1
    
    -- 1. Add Items (Raw)
    -- We suppress the default sync in AddItem if we can, 
    -- but AddItem doesn't have a 'nosync' arg here.
    -- So we just use built-in AddItems directly to avoid double sync if we were to modify it.
    -- Or we use our own logic.
    
    local items = container:AddItems(fullType, qty)
    
    -- 2. Apply Custom Data
    if customData and items then
        for i = 0, items:size() - 1 do
            local item = items:get(i)

            if DC_Colony and DC_Colony.Registry and DC_Colony.Registry.Internal and DC_Colony.Registry.Internal.ApplyEquipmentEntryState then
                DC_Colony.Registry.Internal.ApplyEquipmentEntryState(item, customData)
            else
                -- Apply Used Delta
                if customData.usedDelta ~= nil and item:IsDrainable() then
                    item:setUsedDelta(customData.usedDelta)
                end

                -- Apply Condition (Durability)
                if customData.condition ~= nil then
                    item:setCondition(customData.condition)
                end

                if customData.headCondition ~= nil and item.setHeadCondition then
                    item:setHeadCondition(customData.headCondition)
                elseif customData.condition ~= nil and item.setHeadConditionFromCondition then
                    pcall(function()
                        item:setHeadConditionFromCondition(item)
                    end)
                end
            end

            applyFluidState(item, customData)

            if isServer() and item.syncItemFields then
                item:syncItemFields()
            end
        end
    end
    
    -- 3. Sync to Clients (MP)
    if Helpers.ShouldSendNetworkPackets() and items then
        for i = 0, items:size() - 1 do
            local item = items:get(i)
            sendAddItemToContainer(container, item)
        end
    end
    
    return items
end

--- Recursively searches a container (and nested bags) for an item by ID.
-- Useful for finding items in bags/backpacks during sell transactions.
-- @param container ItemContainer The starting container.
-- @param itemID number The unique item ID to find.
-- @return InventoryItem|nil The found item, or nil.
function Helpers.FindItemByIDRecursive(container, itemID)
    if not container or not itemID then return nil end
    
    local items = container:getItems()
    for i = 0, items:size() - 1 do
        local it = items:get(i)
        if it:getID() == itemID then
            -- if isDebugEnabled() then
            --     print("[DynamicTradingCommon] Found item: " .. it:getFullType() .. " in container: " .. container:getType())
            -- end
            return it
        end
        -- Check nested containers (bags inside bags)
        if instanceof(it, "InventoryContainer") then
            local sub = it:getItemContainer()
            if sub then
                local found = Helpers.FindItemByIDRecursive(sub, itemID)
                if found then 
                    -- if isDebugEnabled() then
                    --     print("[DynamicTradingCommon] Found item: " .. it:getFullType() .. " in container: " .. container:getType())
                    -- end
                    return found 
                end
            end
        end
    end
    return nil
end
