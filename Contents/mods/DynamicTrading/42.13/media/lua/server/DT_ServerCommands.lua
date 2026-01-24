-- =============================================================================
-- DYNAMIC TRADING: SERVER COMMAND HANDLER
-- =============================================================================
-- Compatible with Singleplayer, MP Hosted, and MP Dedicated.
-- Handles all secure logic: Money removal, Inventory management, Scanning RNG.

require "DynamicTrading_Manager"
require "DynamicTrading_Events"
require "DynamicTrading_Economy"

-- 1. GLOBAL TABLE REGISTRATION
-- We expose this table globally so Singleplayer Client scripts can call functions directly
-- if needed, though we primarily use the Command Bridge now.
DynamicTrading = DynamicTrading or {}
DynamicTrading.ServerCommands = {}

local Commands = DynamicTrading.ServerCommands
local lastProcessedDay = -1 

-- =============================================================================
-- 0. SINGLEPLAYER / MULTIPLAYER BRIDGE
-- =============================================================================

local function ShouldSendNetworkPackets()
    -- Only send container update packets if we are the Authority (MP Server/Host).
    return isServer()
end

-- [CRITICAL FIX]
-- Helper to handle the difference between SP and MP communication.
-- In SP, sendServerCommand doesn't fire 'OnServerCommand' on the client side automatically.
-- We must manually trigger the event to bridge the gap.
local function SendResponse(player, command, args)
    if isServer() then
        -- MULTIPLAYER: Send packet over network
        sendServerCommand(player, "DynamicTrading", command, args)
    else
        -- SINGLEPLAYER: Simulate packet arrival immediately
        -- This triggers 'OnServerCommand' in DT_ClientCommands.lua
        triggerEvent("OnServerCommand", "DynamicTrading", command, args)
    end
end

-- =============================================================================
-- 1. HELPERS (INVENTORY & MONEY)
-- =============================================================================

-- Helper to remove a specific item instance and sync it
local function ServerRemoveItem(item)
    if not item then return end
    local container = item:getContainer()
    if not container then return end
    
    -- Perform Action
    container:DoRemoveItem(item)
    
    -- Sync
    if ShouldSendNetworkPackets() then
        sendRemoveItemFromContainer(container, item)
    end
end

-- Helper to add items by type and sync them
local function ServerAddItem(container, fullType, count)
    if not container or not fullType then return end
    local qty = count or 1
    
    -- AddItems returns an ArrayList of the created items
    local items = container:AddItems(fullType, qty)
    
    -- Sync
    if ShouldSendNetworkPackets() and items then
        for i=0, items:size()-1 do
            local item = items:get(i)
            sendAddItemToContainer(container, item)
        end
    end
end

-- Calculate total wealth (Loose Cash + Bundles)
local function GetServerWealth(player)
    local inv = player:getInventory()
    local looseList = inv:getItemsFromType("Base.Money", true)
    local bundleList = inv:getItemsFromType("Base.MoneyBundle", true)
    
    local looseCount = looseList and looseList:size() or 0
    local bundleCount = bundleList and bundleList:size() or 0
    
    return looseCount + (bundleCount * 100)
end

-- Smart Money Removal (Handles change automatically)
local function ServerRemoveMoney(player, amount)
    local inv = player:getInventory()
    local currentWealth = GetServerWealth(player)
    
    if currentWealth < amount then return false end

    local remainingCost = amount
    local itemsToRemove = {}

    local looseList = inv:getItemsFromType("Base.Money", true)
    local bundleList = inv:getItemsFromType("Base.MoneyBundle", true)
    
    local looseTable = {}
    local bundleTable = {}
    
    -- Snapshot items
    if looseList then
        for i=0, looseList:size()-1 do table.insert(looseTable, looseList:get(i)) end
    end
    if bundleList then
        for i=0, bundleList:size()-1 do table.insert(bundleTable, bundleList:get(i)) end
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
        ServerRemoveItem(item)
    end

    -- Handle Change (if we took a bundle but only needed $20)
    if remainingCost < 0 then
        local changeDue = math.abs(remainingCost)
        local bundlesBack = math.floor(changeDue / 100)
        local looseBack = changeDue % 100
        
        if bundlesBack > 0 then ServerAddItem(inv, "Base.MoneyBundle", bundlesBack) end
        if looseBack > 0 then ServerAddItem(inv, "Base.Money", looseBack) end
    end
    
    return true
end

-- =============================================================================
-- 2. COMMAND HANDLERS
-- =============================================================================

-- COMMAND: RequestFullState
-- Description: Client asking for the latest Trader List / Events
function Commands.RequestFullState(player, args)
    local data = DynamicTrading.Manager.GetData()
    if data then
        ModData.transmit("DynamicTrading_Engine_v1.2")
    end
end

-- COMMAND: TradeTransaction
-- Description: Buying or Selling items
function Commands.TradeTransaction(player, args)
    local type = args.type
    local traderID = args.traderID
    local key = args.key
    local category = args.category or "Misc"
    local clientQty = tonumber(args.qty) or 1 

    local data = DynamicTrading.Manager.GetData()
    local trader = data.Traders[traderID]
    local itemData = DynamicTrading.Config.MasterList[key]

    if not trader or not itemData then return end
    local inv = player:getInventory()

    -- Cache Display Name from Script for logging
    local scriptItem = getScriptManager():getItem(itemData.item)
    local safeDisplayName = scriptItem and scriptItem:getDisplayName() or "Unknown Item"

    if type == "buy" then
        -- 1. Calculate Price
        local unitPrice = DynamicTrading.Economy.GetBuyPrice(key, data.globalHeat)
        local totalCost = unitPrice * clientQty
        
        -- 2. Check Stock
        local currentStock = trader.stocks[key] or 0
        if currentStock < clientQty then
            SendResponse(player, "TransactionResult", { success=false, msg="Sold Out!" })
            return
        end

        -- 3. Check Wealth
        if GetServerWealth(player) < totalCost then
            SendResponse(player, "TransactionResult", { success=false, msg="Not enough cash!" })
            return
        end

        -- 4. Execute Trade
        if ServerRemoveMoney(player, totalCost) then
            DynamicTrading.Manager.OnBuyItem(traderID, key, category, clientQty)
            ServerAddItem(inv, itemData.item, clientQty)
            
            SendResponse(player, "TransactionResult", { 
                success = true, 
                itemName = safeDisplayName,
                price = totalCost
            })
        else
            SendResponse(player, "TransactionResult", { success=false, msg="Transaction Error" })
        end

    elseif type == "sell" then
        -- 1. Locate specific physical item by ID
        -- [ROBUST FIX] We now find the item by the unique ID passed from the client
        local itemObj = inv:getItemById(args.itemID)
        
        -- [B42 ROBUST] If direct main-inv lookup fails, do a recursive search across carried and equipped bags
        if not itemObj then
            local mainItems = inv:getItems()
            for i = 0, mainItems:size() - 1 do
                local it = mainItems:get(i)
                if it:getID() == args.itemID then
                    itemObj = it
                    break
                end
                -- Check inside equipped containers
                if instanceof(it, "InventoryContainer") and (player:isEquipped(it) or player:getClothingItem_Back() == it) then
                    local bagInv = it:getItemContainer()
                    if bagInv then
                        local bagItems = bagInv:getItems()
                        for j = 0, bagItems:size() - 1 do
                            local bit = bagItems:get(j)
                            if bit:getID() == args.itemID then
                                itemObj = bit
                                break
                            end
                        end
                    end
                end
                if itemObj then break end
            end
        end
        
        if not itemObj then
            -- Fallback: If ID search fails, try traditional search (rare)
            local allItemsList = inv:getItemsFromType(itemData.item, true)
            if allItemsList and allItemsList:size() > 0 then
                itemObj = allItemsList:get(0)
            end
        end
        
        if not itemObj then
            SendResponse(player, "TransactionResult", { success=false, msg="Item missing!" })
            return
        end

        -- [NEW SAFETY LOCK] Double check it's not the active radio
        -- If the physical radio is turned on, the server blocks the sale as a safeguard.
        if itemObj.getDeviceData then
            local dev = itemObj:getDeviceData()
            if dev and dev:getIsTurnedOn() then
                SendResponse(player, "TransactionResult", { success=false, msg="Cannot sell an active radio!" })
                return
            end
        end

        -- Capture Price and Name BEFORE removing the item
        local unitPrice = DynamicTrading.Economy.GetSellPrice(itemObj, key, trader.archetype)
        local totalGain = unitPrice * clientQty
        local itemNameForLog = itemObj:getDisplayName()

        -- [FIX] Ensure item is unequipped before removal to prevent duplication (Ghost Item Glitch)
        if player:getPrimaryHandItem() == itemObj then
            player:setPrimaryHandItem(nil)
        end
        if player:getSecondaryHandItem() == itemObj then
            player:setSecondaryHandItem(nil)
        end

        -- 2. Execute Trade
        ServerRemoveItem(itemObj)
        
        local bundles = math.floor(totalGain / 100)
        local loose = totalGain % 100
        if bundles > 0 then ServerAddItem(inv, "Base.MoneyBundle", bundles) end
        if loose > 0 then ServerAddItem(inv, "Base.Money", loose) end
        
        DynamicTrading.Manager.OnSellItem(traderID, key, category, clientQty)
        
        -- Send exact keys client expects for Audit Log
        SendResponse(player, "TransactionResult", { 
            success = true, 
            itemName = itemNameForLog,
            price = totalGain
        })
    end
end


-- COMMAND: UnpackContainer
-- Description: Drops everything inside a bag to the player's feet
function Commands.UnpackContainer(player, args)
    if not player or not args.itemID then return end
    
    local inv = player:getInventory()
    local bag = inv:getItemById(args.itemID)
    
    if not bag or not instanceof(bag, "InventoryContainer") then return end
    
    local container = bag:getItemContainer()
    local items = container:getItems()
    local square = player:getSquare()
    
    if not square or not items or items:isEmpty() then return end
    
    -- We must iterate backwards because we are removing items
    for i = items:size()-1, 0, -1 do
        local item = items:get(i)
        if item then
            -- 1. Remove from bag
            container:DoRemoveItem(item)
            
            -- Sync Removal (MP)
            if ShouldSendNetworkPackets() then
                sendRemoveItemFromContainer(container, item)
            end
            
            -- 2. Add to world (at player's location)
            -- We use ZombRand small offsets to avoid perfect stacking
            local offX = (ZombRand(100) / 100) * 0.4 - 0.2
            local offY = (ZombRand(100) / 100) * 0.4 - 0.2
            
            square:AddWorldInventoryItem(item, 0.5 + offX, 0.5 + offY, 0)
        end
    end
    
    -- Notify Client to refresh UI
    SendResponse(player, "UnpackResult", { success = true })
end

-- COMMAND: AttemptScan
-- Description: The RNG roll for finding new traders
function Commands.AttemptScan(player, args)
    local targetUser = player:getUsername()

    -- 1. Cooldown Check
    local canScan, timeRem = DynamicTrading.Manager.CanScan(player)
    if not canScan then
        SendResponse(player, "ScanResult", { status = "FAILED_RNG", targetUser = targetUser })
        return
    end

    -- 2. Daily Limit Check
    local found, limit = DynamicTrading.Manager.GetDailyStatus()
    if found >= limit then
        SendResponse(player, "ScanResult", { status = "LIMIT_REACHED", targetUser = targetUser })
        return
    end

    -- 3. Apply Cooldown
    DynamicTrading.Manager.SetScanTimestamp(player)

    -- 4. Calculate Chances
    local penaltyPerTrader = SandboxVars.DynamicTrading.ScanPenaltyPerTrader or 0.2
    local penaltyFactor = 1.0 + (found * penaltyPerTrader) 
    
    local radioTier = args.radioTier or 0.5
    local baseChance = SandboxVars.DynamicTrading.ScanBaseChance or 30
    local skillBonus = args.skillBonus or 1.0
    
    local eventMult = 1.0
    if DynamicTrading.Events and DynamicTrading.Events.GetSystemModifier then
        eventMult = DynamicTrading.Events.GetSystemModifier("scanChance")
    end

    local finalChance = (baseChance * radioTier * skillBonus * eventMult) / penaltyFactor
    local roll = ZombRand(100) + 1
    
    -- 5. Roll Dice
    if roll <= finalChance then
        local trader = DynamicTrading.Manager.GenerateRandomContact()
        if trader then
            SendResponse(player, "ScanResult", { 
                status = "SUCCESS", 
                name = trader.name,
                archetype = trader.archetype,
                targetUser = targetUser
            })
        else
            SendResponse(player, "ScanResult", { status = "FAILED_RNG", targetUser = targetUser })
        end
    else
        SendResponse(player, "ScanResult", { status = "FAILED_RNG", targetUser = targetUser })
    end
end

-- =============================================================================
-- 3. EVENT LISTENER (MULTIPLAYER BRIDGE)
-- =============================================================================
local function OnClientCommand(module, command, player, args)
    if module == "DynamicTrading" and Commands[command] then
        Commands[command](player, args)
    end
end

Events.OnClientCommand.Add(OnClientCommand)

-- =============================================================================
-- 4. SERVER MAINTENANCE LOOP
-- =============================================================================
-- Runs every hour to check for Expired Traders, Daily Resets, and Events.
local function Server_OnHourlyTick()
    if not DynamicTrading or not DynamicTrading.Manager then return end

    local data = DynamicTrading.Manager.GetData()
    local gt = GameTime:getInstance()
    local currentHours = gt:getWorldAgeHours()
    local currentDay = math.floor(gt:getDaysSurvived())
    local currentHourOfDay = gt:getHour()
    local changesMade = false

    -- 1. Daily Reset Check (5 AM)
    DynamicTrading.Manager.CheckDailyReset()

    -- 2. Trader Expiration Check
    if data.Traders then
        for id, trader in pairs(data.Traders) do
            local shouldRemove = false
            if trader.expirationTime and currentHours > trader.expirationTime then 
                shouldRemove = true 
            end
            
            if shouldRemove then
                DynamicTrading.Manager.AddLog("Signal Lost: " .. (trader.name or "Unknown"), "bad")
                data.Traders[id] = nil
                changesMade = true
            end
        end
    end
    
    -- Sync if traders removed
    if changesMade then ModData.transmit("DynamicTrading_Engine_v1.2") end

    -- 3. Event System Check (8 AM)
    if currentHourOfDay == 8 and lastProcessedDay ~= currentDay then
        if DynamicTrading.Manager.ProcessEvents then
            DynamicTrading.Manager.ProcessEvents()
            lastProcessedDay = currentDay
        end
    end
end

Events.EveryHours.Add(Server_OnHourlyTick)