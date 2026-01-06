if isClient() then return end

require "DynamicTrading_Manager"
require "DynamicTrading_Events"
require "DynamicTrading_Economy"

local Commands = {}
local lastProcessedDay = -1 

-- =============================================================================
-- 0. SERVER-SIDE HELPERS (STRICT NETWORK COMPLIANCE)
-- =============================================================================

-- Helper: Remove specific items and SYNC them to client
local function ServerRemoveItem(container, item)
    if not container or not item then return end
    
    -- 1. Remove from Server Memory
    container:DoRemoveItem(item)
    
    -- 2. Tell Client to remove it
    sendRemoveItemFromContainer(container, item)
end

-- Helper: Create, Add, and SYNC new items
local function ServerAddItem(container, fullType)
    if not container or not fullType then return end
    
    -- 1. Create the Item Object
    local item = InventoryItemFactory.CreateItem(fullType)
    if not item then 
        print("Error: Could not create item " .. tostring(fullType))
        return 
    end
    
    -- 2. Add to Server Memory
    container:AddItem(item)
    
    -- 3. Tell Client to add it
    sendAddItemToContainer(container, item)
    
    return item
end

local function GetServerWealth(player)
    local inv = player:getInventory()
    return inv:getItemCount("Base.Money") + (inv:getItemCount("Base.MoneyBundle") * 100)
end

-- Robust Money Removal: "Nuke and Refund" strategy to ensure clean stacks
local function ServerRemoveMoney(player, amount)
    local inv = player:getInventory()
    local current = GetServerWealth(player)
    
    if current < amount then return false end
    
    local remaining = current - amount
    
    -- 1. Remove ALL money items (Iterate backwards to safely remove)
    local items = inv:getItems()
    for i = items:size()-1, 0, -1 do
        local item = items:get(i)
        if item:getFullType() == "Base.Money" or item:getFullType() == "Base.MoneyBundle" then
            ServerRemoveItem(inv, item)
        end
    end
    
    -- 2. Add back the change
    local bundles = math.floor(remaining / 100)
    local loose = remaining % 100
    
    for i=1, bundles do ServerAddItem(inv, "Base.MoneyBundle") end
    for i=1, loose do ServerAddItem(inv, "Base.Money") end
    
    return true
end

local function ServerAddMoney(player, amount)
    local inv = player:getInventory()
    local bundles = math.floor(amount / 100)
    local loose = amount % 100
    
    for i=1, bundles do ServerAddItem(inv, "Base.MoneyBundle") end
    for i=1, loose do ServerAddItem(inv, "Base.Money") end
end

-- =============================================================================
-- 1. CLIENT COMMAND HANDLERS
-- =============================================================================

-- SYNC REQUEST: Called when a player joins, re-logs, or forces a refresh
function Commands.RequestFullState(player, args)
    -- SAFETY FIX: Force data load from disk into memory before transmitting
    local data = DynamicTrading.Manager.GetData()
    
    if data then
        ModData.transmit("DynamicTrading_Engine_v1")
        print("[Server] DynamicTrading: Full state transmitted to " .. player:getUsername())
    else
        print("[Server] DynamicTrading: Critical Error - Could not load ModData for " .. player:getUsername())
    end
end

function Commands.TradeTransaction(player, args)
    local type = args.type -- "buy" or "sell"
    local traderID = args.traderID
    local key = args.key
    local category = args.category or "Misc"
    local clientQty = args.qty or 1

    local data = DynamicTrading.Manager.GetData()
    local trader = data.Traders[traderID]
    local itemData = DynamicTrading.Config.MasterList[key]

    if not trader or not itemData then return end
    local inv = player:getInventory()

    -- BUY LOGIC
    if type == "buy" then
        local price = DynamicTrading.Economy.GetBuyPrice(key, data.globalHeat)
        local totalCost = price * clientQty
        
        -- Check Stock
        local currentStock = trader.stocks[key] or 0
        if currentStock < clientQty then
            sendServerCommand(player, "DynamicTrading", "TransactionResult", { success=false, msg="Sold Out!" })
            ModData.transmit("DynamicTrading_Engine_v1")
            return
        end

        -- Check Money
        local wealth = GetServerWealth(player)
        if wealth < totalCost then
            sendServerCommand(player, "DynamicTrading", "TransactionResult", { success=false, msg="Not enough cash!" })
            return
        end

        -- Execute
        if ServerRemoveMoney(player, totalCost) then
            -- Deduct Stock
            DynamicTrading.Manager.OnBuyItem(traderID, key, category, clientQty)
            
            -- Give Items (Loop for quantity)
            for i=1, clientQty do
                ServerAddItem(inv, itemData.item)
            end
            
            print("[Server] DynamicTrading: " .. player:getUsername() .. " bought " .. key)
            sendServerCommand(player, "DynamicTrading", "TransactionResult", { success=true, msg="Purchased!" })
        end

    -- SELL LOGIC
    elseif type == "sell" then
        -- Find specific item instance
        local itemObj = inv:getFirstType(itemData.item)
        
        if not itemObj then
            sendServerCommand(player, "DynamicTrading", "TransactionResult", { success=false, msg="Item missing!" })
            return
        end

        local price = DynamicTrading.Economy.GetSellPrice(itemObj, key, trader.archetype)
        if price <= 0 then price = 0 end 

        -- Execute
        ServerRemoveItem(inv, itemObj)
        ServerAddMoney(player, price)
        
        DynamicTrading.Manager.OnSellItem(traderID, key, category, clientQty)

        print("[Server] DynamicTrading: " .. player:getUsername() .. " sold " .. key)
        sendServerCommand(player, "DynamicTrading", "TransactionResult", { success=true, msg="Sold!" })
    end
end

function Commands.AttemptScan(player, args)
    local targetUser = player:getUsername()

    -- Check Cooldown
    local canScan, timeRem = DynamicTrading.Manager.CanScan(player)
    if not canScan then
        sendServerCommand(player, "DynamicTrading", "ScanResult", { status = "FAILED_RNG", targetUser = targetUser })
        return
    end

    -- Check Limit
    local found, limit = DynamicTrading.Manager.GetDailyStatus()
    if found >= limit then
        sendServerCommand(player, "DynamicTrading", "ScanResult", { status = "LIMIT_REACHED", targetUser = targetUser })
        return
    end

    DynamicTrading.Manager.SetScanTimestamp(player)

    -- Calculate Chance
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
    if finalChance < 1 then finalChance = 1 end
    if finalChance > 95 then finalChance = 95 end
    
    local roll = ZombRand(100) + 1
    
    if roll <= finalChance then
        local trader = DynamicTrading.Manager.GenerateRandomContact()
        if trader then
            sendServerCommand(player, "DynamicTrading", "ScanResult", { 
                status = "SUCCESS", 
                name = trader.name,
                archetype = trader.archetype,
                targetUser = targetUser
            })
        else
            sendServerCommand(player, "DynamicTrading", "ScanResult", { status = "FAILED_RNG", targetUser = targetUser })
        end
    else
        sendServerCommand(player, "DynamicTrading", "ScanResult", { status = "FAILED_RNG", targetUser = targetUser })
    end
end

-- EVENT LISTENER
local function OnClientCommand(module, command, player, args)
    if module == "DynamicTrading" and Commands[command] then
        Commands[command](player, args)
    end
end

Events.OnClientCommand.Add(OnClientCommand)

-- =============================================================================
-- 2. SERVER MAINTENANCE LOOP
-- =============================================================================
local function Server_OnHourlyTick()
    if not DynamicTrading or not DynamicTrading.Manager then return end

    -- Load data to ensure safe operations
    local data = DynamicTrading.Manager.GetData()
    local gt = GameTime:getInstance()
    local currentHours = gt:getWorldAgeHours()
    local currentDay = math.floor(gt:getDaysSurvived())
    local currentHourOfDay = gt:getHour()
    local changesMade = false

    DynamicTrading.Manager.CheckDailyReset()

    if data.Traders then
        for id, trader in pairs(data.Traders) do
            local shouldRemove = false
            if trader.expirationTime then
                if currentHours > trader.expirationTime then shouldRemove = true end
            elseif trader.expirationDay then
                if currentDay > trader.expirationDay then shouldRemove = true end
            end
            
            if shouldRemove then
                DynamicTrading.Manager.AddLog("Signal Lost: " .. (trader.name or "Unknown"), "bad")
                data.Traders[id] = nil
                changesMade = true
            end
        end
    end
    
    if changesMade then ModData.transmit("DynamicTrading_Engine_v1") end

    if currentHourOfDay == 8 and lastProcessedDay ~= currentDay then
        if DynamicTrading.Manager.ProcessEvents then
            DynamicTrading.Manager.ProcessEvents()
            lastProcessedDay = currentDay
        end
    end
end

Events.EveryHours.Add(Server_OnHourlyTick)