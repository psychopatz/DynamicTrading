-- =============================================================================
-- DYNAMIC TRADING COMMON: SERVER HELPERS - WEALTH LOGIC
-- =============================================================================
local Helpers = DynamicTrading.ServerHelpers

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
        -- if isDebugEnabled() then
        --     print("[DynamicTradingCommon] Burning money: " .. amount .. " from player: " .. player:getUsername())
        -- end
        Helpers.RemoveMoney(player, amount)
    end
end
