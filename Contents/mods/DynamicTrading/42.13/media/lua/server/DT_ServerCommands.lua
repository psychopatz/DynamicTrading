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
-- Now handles items inside bags correctly by using item:getContainer()
local function ServerRemoveItem(item)
    if not item then return end
    local container = item:getContainer()
    if not container then return end
    
    -- 1. Remove from Server Memory
    container:DoRemoveItem(item)
    
    -- 2. Tell Client to remove it
    sendRemoveItemFromContainer(container, item)
end

-- Helper: Add items safely using native methods
local function ServerAddItem(container, fullType, count)
    if not container or not fullType then return end
    local qty = count or 1
    
    -- Native AddItems handles creation and placement logic automatically
    local items = container:AddItems(fullType, qty)
    
    -- Force sync the container to ensure client sees the new items
    if items then
        for i=0, items:size()-1 do
            local item = items:get(i)
            sendAddItemToContainer(container, item)
        end
    end
end

-- RECURSIVE WEALTH CHECK (Finds money in bags)
local function GetServerWealth(player)
    local inv = player:getInventory()
    -- getItemsFromType(type, recursive=true) finds items in all equipped bags
    local looseList = inv:getItemsFromType("Base.Money", true)
    local bundleList = inv:getItemsFromType("Base.MoneyBundle", true)
    
    local looseCount = looseList and looseList:size() or 0
    local bundleCount = bundleList and bundleList:size() or 0
    
    return looseCount + (bundleCount * 100)
end

-- SMART DEDUCT (Recursive & Container Aware)
local function ServerRemoveMoney(player, amount)
    local inv = player:getInventory()
    local currentWealth = GetServerWealth(player)
    
    if currentWealth < amount then 
        return false 
    end

    local remainingCost = amount
    local itemsToRemove = {}

    -- 1. GATHER ALL MONEY (Recursive)
    local looseList = inv:getItemsFromType("Base.Money", true)
    local bundleList = inv:getItemsFromType("Base.MoneyBundle", true)
    
    -- Convert Java Lists to Lua Tables for easier processing
    local looseTable = {}
    local bundleTable = {}
    
    if looseList then
        for i=0, looseList:size()-1 do table.insert(looseTable, looseList:get(i)) end
    end
    if bundleList then
        for i=0, bundleList:size()-1 do table.insert(bundleTable, bundleList:get(i)) end
    end

    -- 2. PAY WITH LOOSE CASH FIRST
    for _, item in ipairs(looseTable) do
        if remainingCost > 0 then
            table.insert(itemsToRemove, item)
            remainingCost = remainingCost - 1
        else
            break
        end
    end

    -- 3. PAY REMAINDER WITH BUNDLES
    if remainingCost > 0 then
        for _, item in ipairs(bundleTable) do
            if remainingCost > 0 then
                table.insert(itemsToRemove, item)
                remainingCost = remainingCost - 100 -- Bundle is worth 100
            else
                break
            end
        end
    end

    -- 4. EXECUTE REMOVALS
    for _, item in ipairs(itemsToRemove) do
        ServerRemoveItem(item)
    end

    -- 5. GIVE CHANGE (If we overpaid with a bundle)
    if remainingCost < 0 then
        local changeDue = math.abs(remainingCost)
        local bundlesBack = math.floor(changeDue / 100)
        local looseBack = changeDue % 100
        
        -- Add change to Main Inventory
        if bundlesBack > 0 then ServerAddItem(inv, "Base.MoneyBundle", bundlesBack) end
        if looseBack > 0 then ServerAddItem(inv, "Base.Money", looseBack) end
    end
    
    return true
end

-- =============================================================================
-- 1. CLIENT COMMAND HANDLERS
-- =============================================================================

function Commands.RequestFullState(player, args)
    -- Force load data to ensure validity
    local data = DynamicTrading.Manager.GetData()
    if data then
        ModData.transmit("DynamicTrading_Engine_v1")
    end
end

function Commands.TradeTransaction(player, args)
    local type = args.type
    local traderID = args.traderID
    local key = args.key
    local category = args.category or "Misc"
    local clientQty = args.qty or 1

    local data = DynamicTrading.Manager.GetData()
    local trader = data.Traders[traderID]
    local itemData = DynamicTrading.Config.MasterList[key]

    if not trader or not itemData then return end
    local inv = player:getInventory()

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

        -- Check Money (Recursive)
        local wealth = GetServerWealth(player)
        if wealth < totalCost then
            sendServerCommand(player, "DynamicTrading", "TransactionResult", { success=false, msg="Not enough cash! (Server: " .. wealth .. ")" })
            return
        end

        -- Execute
        if ServerRemoveMoney(player, totalCost) then
            DynamicTrading.Manager.OnBuyItem(traderID, key, category, clientQty)
            ServerAddItem(inv, itemData.item, clientQty)
            print("[Server] DynamicTrading: " .. player:getUsername() .. " bought " .. key)
            sendServerCommand(player, "DynamicTrading", "TransactionResult", { success=true, msg="Purchased!" })
        else
            sendServerCommand(player, "DynamicTrading", "TransactionResult", { success=false, msg="Transaction Error" })
        end

    elseif type == "sell" then
        -- Find specific item instance (Recursive search to find it in bags too)
        local itemObj = nil
        local allItems = inv:getItemsFromType(itemData.item, true)
        if allItems and allItems:size() > 0 then
            itemObj = allItems:get(0)
        end
        
        if not itemObj then
            sendServerCommand(player, "DynamicTrading", "TransactionResult", { success=false, msg="Item missing!" })
            return
        end

        local price = DynamicTrading.Economy.GetSellPrice(itemObj, key, trader.archetype)
        if price <= 0 then price = 0 end 

        -- Execute
        ServerRemoveItem(itemObj)
        
        -- Add money
        local bundles = math.floor(price / 100)
        local loose = price % 100
        if bundles > 0 then ServerAddItem(inv, "Base.MoneyBundle", bundles) end
        if loose > 0 then ServerAddItem(inv, "Base.Money", loose) end
        
        DynamicTrading.Manager.OnSellItem(traderID, key, category, clientQty)
        print("[Server] DynamicTrading: " .. player:getUsername() .. " sold " .. key)
        sendServerCommand(player, "DynamicTrading", "TransactionResult", { success=true, msg="Sold!" })
    end
end

function Commands.AttemptScan(player, args)
    local targetUser = player:getUsername()

    local canScan, timeRem = DynamicTrading.Manager.CanScan(player)
    if not canScan then
        sendServerCommand(player, "DynamicTrading", "ScanResult", { status = "FAILED_RNG", targetUser = targetUser })
        return
    end

    local found, limit = DynamicTrading.Manager.GetDailyStatus()
    if found >= limit then
        sendServerCommand(player, "DynamicTrading", "ScanResult", { status = "LIMIT_REACHED", targetUser = targetUser })
        return
    end

    DynamicTrading.Manager.SetScanTimestamp(player)

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