-- =============================================================================
-- DYNAMIC TRADING COMMON: SERVER HELPERS
-- =============================================================================
-- Centralized utility functions for server-side inventory, money, and world
-- interactions. Compatible with Singleplayer, MP Hosted, and MP Dedicated.
--
-- USAGE: require "DT/Common/ServerHelpers"--        DynamicTrading.ServerHelpers.RemoveItem(item)
-- =============================================================================

DynamicTrading = DynamicTrading or {}
DynamicTrading.ServerHelpers = {}

local Helpers = DynamicTrading.ServerHelpers

-- =============================================================================
-- 1. NETWORK / BRIDGE UTILITIES
-- =============================================================================

--- Determines if we should send network sync packets.
-- In SP, isServer() returns false; no packets needed.
-- In MP, isServer() returns true on host/dedicated; sync required.
-- @return boolean True if running on a multiplayer server.
function Helpers.ShouldSendNetworkPackets()
    return isServer()
end

--- Sends a response to both SP and MP clients correctly.
-- In MP, uses sendServerCommand. In SP, triggers the event manually
-- because sendServerCommand doesn't fire OnServerCommand locally.
-- @param player IsoPlayer The target player.
-- @param module string The module name (e.g., "DynamicTrading").
-- @param command string The command name (e.g., "TransactionResult").
-- @param args table The arguments table to send.
function Helpers.SendResponse(player, module, command, args)
    if isServer() then
        -- MULTIPLAYER: Send packet over network
        if isDebugEnabled() then
            print("[DynamicTradingCommon] Sending MP: " .. module .. ":" .. command .. " to player: " .. player:getUsername())
        end
        sendServerCommand(player, module, command, args)
    else
        -- SINGLEPLAYER: Simulate packet arrival immediately
        if isDebugEnabled() then
            print("[DynamicTradingCommon] Sending SP: " .. module .. ":" .. command .. " to player: " .. player:getUsername())
        end
        triggerEvent("OnServerCommand", module, command, args)
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
    if isDebugEnabled() then
        print("[DynamicTradingCommon] Removing item: " .. item:getFullType() .. " from container: " .. container:getType())
    end
    
    -- Perform Action
    container:DoRemoveItem(item)
    
    -- Sync to Clients (MP only)
    if Helpers.ShouldSendNetworkPackets() then
        if isDebugEnabled() then
            print("[DynamicTradingCommon] Sending MP: RemoveItemFromContainer")
        end
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
    if isDebugEnabled() then
        print("[DynamicTradingCommon] Adding item: " .. fullType .. " to container: " .. container:getType())
    end
    
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
            
            -- Apply Used Delta
            if customData.usedDelta and item:IsDrainable() then
                item:setUsedDelta(customData.usedDelta)
            end
            
            -- Apply Fluid Amount
            if customData.fluidAmount and item:getFluidContainer() then
                item:getFluidContainer():setAmount(customData.fluidAmount)
            end
            
            -- Apply Condition (Durability)
            if customData.condition then
                item:setCondition(customData.condition)
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
            if isDebugEnabled() then
                print("[DynamicTradingCommon] Found item: " .. it:getFullType() .. " in container: " .. container:getType())
            end
            return it
        end
        -- Check nested containers (bags inside bags)
        if instanceof(it, "InventoryContainer") then
            local sub = it:getItemContainer()
            if sub then
                local found = Helpers.FindItemByIDRecursive(sub, itemID)
                if found then 
                    if isDebugEnabled() then
                        print("[DynamicTradingCommon] Found item: " .. it:getFullType() .. " in container: " .. container:getType())
                    end
                    return found 
                end
            end
        end
    end
    return nil
end

-- =============================================================================
-- 3. WORLD INTERACTION (UNPACK TO GROUND)
-- =============================================================================

--- Drops all items from a container to the ground at the player's feet.
-- Used for "Unpack Bag" type actions.
-- @param player IsoPlayer The player.
-- @param bag InventoryContainer The bag item to unpack.
function Helpers.DropContainerToGround(player, bag)
    if not player or not bag then return end
    if not instanceof(bag, "InventoryContainer") then return end
    
    local container = bag:getItemContainer()
    local items = container:getItems()
    local square = player:getSquare()
    
    if not square or not items or items:isEmpty() then return end
    
    -- Iterate backwards because we are removing items
    for i = items:size() - 1, 0, -1 do
        local item = items:get(i)
        if item then
            -- 1. Remove from bag
            container:DoRemoveItem(item)
            
            -- Sync Removal (MP)
            if Helpers.ShouldSendNetworkPackets() then
                sendRemoveItemFromContainer(container, item)
            end
            
            -- 2. Add to world (at player's location with slight offset)
            local offX = (ZombRand(100) / 100) * 0.4 - 0.2
            local offY = (ZombRand(100) / 100) * 0.4 - 0.2
            
            square:AddWorldInventoryItem(item, 0.5 + offX, 0.5 + offY, 0)
        end
    end
end

-- =============================================================================
-- 4. WEALTH / MONEY MANAGEMENT
-- =============================================================================

--- Calculates the total wealth of a player (Loose Cash + Bundles).
-- @param player IsoPlayer The player to check.
-- @return number The total wealth in dollars.
function Helpers.GetWealth(player)
    local inv = player:getInventory()
    local looseList = inv:getItemsFromType("Base.Money", true)
    local bundleList = inv:getItemsFromType("Base.MoneyBundle", true)
    
    local looseCount = looseList and looseList:size() or 0
    local bundleCount = bundleList and bundleList:size() or 0
    
    return looseCount + (bundleCount * 100)
end

--- Removes a specific amount of money from the player (handles change).
-- Prioritizes loose cash first, then breaks bundles as needed.
-- @param player IsoPlayer The player.
-- @param amount number The amount to remove.
-- @return boolean True if successful, false if insufficient funds.
function Helpers.RemoveMoney(player, amount)
    local inv = player:getInventory()
    local currentWealth = Helpers.GetWealth(player)
    
    if currentWealth < amount then return false end

    local remainingCost = amount
    local itemsToRemove = {}

    local looseList = inv:getItemsFromType("Base.Money", true)
    local bundleList = inv:getItemsFromType("Base.MoneyBundle", true)
    
    local looseTable = {}
    local bundleTable = {}
    
    -- Snapshot items (avoids modification errors during iteration)
    if looseList then
        for i = 0, looseList:size() - 1 do table.insert(looseTable, looseList:get(i)) end
    end
    if bundleList then
        for i = 0, bundleList:size() - 1 do table.insert(bundleTable, bundleList:get(i)) end
    end

    -- Prioritize Loose Cash first
    for _, item in ipairs(looseTable) do
        if remainingCost > 0 then
            table.insert(itemsToRemove, item)
            remainingCost = remainingCost - 1
        else break end
    end

    -- Then Bundles
    if remainingCost > 0 then
        for _, item in ipairs(bundleTable) do
            if remainingCost > 0 then
                table.insert(itemsToRemove, item)
                remainingCost = remainingCost - 100 
            else break end
        end
    end

    -- Execute Removal
    for _, item in ipairs(itemsToRemove) do
        Helpers.RemoveItem(item)
    end

    -- Handle Change (if we took a bundle but only needed $20)
    if remainingCost < 0 then
        local changeDue = math.abs(remainingCost)
        local bundlesBack = math.floor(changeDue / 100)
        local looseBack = changeDue % 100
        
        if bundlesBack > 0 then Helpers.AddItem(inv, "Base.MoneyBundle", bundlesBack) end
        if looseBack > 0 then Helpers.AddItem(inv, "Base.Money", looseBack) end
    end
    
    return true
end

--- Removes money without any reward (Scam/Theft mechanics).
-- @param player IsoPlayer The player to burn money from.
-- @param amount number The amount to remove.
function Helpers.BurnMoney(player, amount)
    if amount and amount > 0 then
        if isDebugEnabled() then
            print("[DynamicTradingCommon] Burning money: " .. amount .. " from player: " .. player:getUsername())
        end
        Helpers.RemoveMoney(player, amount)
    end
end

print("[DynamicTradingCommon] DT/Common/ServerHelpers loaded.")
