-- [DYNAMIC TRADING] Server Command Handler
-- Compatible with Singleplayer, MP Hosted, and MP Dedicated.

require "DynamicTrading_Manager"
require "DynamicTrading_Events"
require "DynamicTrading_Economy"

-- 1. GLOBAL TABLE REGISTRATION
-- We expose this table globally so Singleplayer Client scripts can call functions directly,
-- bypassing the network layer which doesn't exist in SP.
DynamicTrading = DynamicTrading or {}
DynamicTrading.ServerCommands = {}

local Commands = DynamicTrading.ServerCommands
local lastProcessedDay = -1 

-- =============================================================================
-- 0. SINGLEPLAYER / MULTIPLAYER DETECTION
-- =============================================================================

local function ShouldSendNetworkPackets()
    -- Only send packets if we are the Authority (MP Server/Host).
    return isServer()
end

-- =============================================================================
-- 1. HELPERS
-- =============================================================================

local function ServerRemoveItem(item)
    if not item then return end
    local container = item:getContainer()
    if not container then return end
    
    container:DoRemoveItem(item)
    
    if ShouldSendNetworkPackets() then
        sendRemoveItemFromContainer(container, item)
    end
end

local function ServerAddItem(container, fullType, count)
    if not container or not fullType then return end
    local qty = count or 1
    
    local items = container:AddItems(fullType, qty)
    
    if ShouldSendNetworkPackets() and items then
        for i=0, items:size()-1 do
            local item = items:get(i)
            sendAddItemToContainer(container, item)
        end
    end
end

local function GetServerWealth(player)
    local inv = player:getInventory()
    local looseList = inv:getItemsFromType("Base.Money", true)
    local bundleList = inv:getItemsFromType("Base.MoneyBundle", true)
    
    local looseCount = looseList and looseList:size() or 0
    local bundleCount = bundleList and bundleList:size() or 0
    
    return looseCount + (bundleCount * 100)
end

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
    
    if looseList then
        for i=0, looseList:size()-1 do table.insert(looseTable, looseList:get(i)) end
    end
    if bundleList then
        for i=0, bundleList:size()-1 do table.insert(bundleTable, bundleList:get(i)) end
    end

    for _, item in ipairs(looseTable) do
        if remainingCost > 0 then
            table.insert(itemsToRemove, item)
            remainingCost = remainingCost - 1
        else break end
    end

    if remainingCost > 0 then
        for _, item in ipairs(bundleTable) do
            if remainingCost > 0 then
                table.insert(itemsToRemove, item)
                remainingCost = remainingCost - 100 
            else break end
        end
    end

    for _, item in ipairs(itemsToRemove) do
        ServerRemoveItem(item)
    end

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

function Commands.RequestFullState(player, args)
    local data = DynamicTrading.Manager.GetData()
    if data then
        ModData.transmit("DynamicTrading_Engine_v1.1")
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
        
        local currentStock = trader.stocks[key] or 0
        if currentStock < clientQty then
            sendServerCommand(player, "DynamicTrading", "TransactionResult", { success=false, msg="Sold Out!" })
            ModData.transmit("DynamicTrading_Engine_v1.1")
            return
        end

        local wealth = GetServerWealth(player)
        if wealth < totalCost then
            sendServerCommand(player, "DynamicTrading", "TransactionResult", { success=false, msg="Not enough cash! (Server: " .. wealth .. ")" })
            return
        end

        if ServerRemoveMoney(player, totalCost) then
            DynamicTrading.Manager.OnBuyItem(traderID, key, category, clientQty)
            ServerAddItem(inv, itemData.item, clientQty)
            sendServerCommand(player, "DynamicTrading", "TransactionResult", { success=true, msg="Purchased!" })
        else
            sendServerCommand(player, "DynamicTrading", "TransactionResult", { success=false, msg="Transaction Error" })
        end

    elseif type == "sell" then
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

        ServerRemoveItem(itemObj)
        
        local bundles = math.floor(price / 100)
        local loose = price % 100
        if bundles > 0 then ServerAddItem(inv, "Base.MoneyBundle", bundles) end
        if loose > 0 then ServerAddItem(inv, "Base.Money", loose) end
        
        DynamicTrading.Manager.OnSellItem(traderID, key, category, clientQty)
        sendServerCommand(player, "DynamicTrading", "TransactionResult", { success=true, msg="Sold!" })
    end
end

function Commands.AttemptScan(player, args)
    print("[DT-Debug] AttemptScan Called by: " .. tostring(player:getUsername()))

    local targetUser = player:getUsername()

    local canScan, timeRem = DynamicTrading.Manager.CanScan(player)
    if not canScan then
        print("[DT-Debug] Scan Blocked: Cooldown Active (" .. timeRem .. " mins)")
        sendServerCommand(player, "DynamicTrading", "ScanResult", { status = "FAILED_RNG", targetUser = targetUser })
        return
    end

    local found, limit = DynamicTrading.Manager.GetDailyStatus()
    if found >= limit then
        print("[DT-Debug] Scan Blocked: Daily Limit Reached (" .. found .. "/" .. limit .. ")")
        sendServerCommand(player, "DynamicTrading", "ScanResult", { status = "LIMIT_REACHED", targetUser = targetUser })
        return
    end

    DynamicTrading.Manager.SetScanTimestamp(player)

    -- MATH DEBUGGING
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

    print(string.format("[DT-Debug] MATH: Base(%d) * Radio(%.2f) * Skill(%.2f) * Event(%.2f) / Penalty(%.2f)", baseChance, radioTier, skillBonus, eventMult, penaltyFactor))
    print(string.format("[DT-Debug] FINAL CHANCE: %.2f%%  vs  ROLL: %d", finalChance, roll))
    
    if roll <= finalChance then
        local trader = DynamicTrading.Manager.GenerateRandomContact()
        if trader then
            print("[DT-Debug] RESULT: SUCCESS -> " .. trader.name)
            sendServerCommand(player, "DynamicTrading", "ScanResult", { 
                status = "SUCCESS", 
                name = trader.name,
                archetype = trader.archetype,
                targetUser = targetUser
            })
        else
            print("[DT-Debug] RESULT: SUCCESS (But Generation Failed?)")
            sendServerCommand(player, "DynamicTrading", "ScanResult", { status = "FAILED_RNG", targetUser = targetUser })
        end
    else
        print("[DT-Debug] RESULT: FAIL (RNG)")
        sendServerCommand(player, "DynamicTrading", "ScanResult", { status = "FAILED_RNG", targetUser = targetUser })
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
    
    if changesMade then ModData.transmit("DynamicTrading_Engine_v1.1") end

    if currentHourOfDay == 8 and lastProcessedDay ~= currentDay then
        if DynamicTrading.Manager.ProcessEvents then
            DynamicTrading.Manager.ProcessEvents()
            lastProcessedDay = currentDay
        end
    end
end

Events.EveryHours.Add(Server_OnHourlyTick)