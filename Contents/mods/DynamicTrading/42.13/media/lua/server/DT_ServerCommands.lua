if isClient() then return end

require "DynamicTrading_Manager"
require "DynamicTrading_Events"

local Commands = {}
local lastProcessedDay = -1 

-- =============================================================================
-- 1. CLIENT COMMAND HANDLERS
-- =============================================================================

-- [[ NEW ]] HANDLES UI REQUESTS FOR INITIAL SYNC
function Commands.RequestFullState(player, args)
    -- Send the full current state of the engine to this specific player (or broadcast)
    -- ModData.transmit broadcasts to everyone, which is fine for keeping sync
    ModData.transmit("DynamicTrading_Engine_v1")
end

-- [[ NEW ]] HANDLES BUY/SELL TRANSACTIONS (Server Authority)
function Commands.TradeTransaction(player, args)
    local type = args.type -- "buy" or "sell"
    local traderID = args.traderID
    local key = args.key
    local category = args.category or "Misc"
    local qty = args.qty or 1

    if type == "buy" then
        -- 1. Server verifies stock exists (Anti-Cheat / Anti-Race Condition)
        local data = DynamicTrading.Manager.GetData()
        local trader = data.Traders[traderID]
        
        if trader and trader.stocks[key] and trader.stocks[key] >= qty then
            -- 2. Execute Logic
            -- The Manager functions (provided in previous step) already contain ModData.transmit()
            -- when run on the server, so calling them here triggers the update for everyone.
            DynamicTrading.Manager.OnBuyItem(traderID, key, category, qty)
            print("[Server] DynamicTrading: " .. player:getUsername() .. " bought " .. key)
        else
            -- Transaction Failed (Stock mismatch)
            -- We just transmit the current state so the client's UI corrects itself
            ModData.transmit("DynamicTrading_Engine_v1")
        end

    elseif type == "sell" then
        -- For selling, we just update the Heat (Deflation)
        DynamicTrading.Manager.OnSellItem(traderID, key, category, qty)
        print("[Server] DynamicTrading: " .. player:getUsername() .. " sold " .. key)
    end
end

-- HANDLES RADIO SCANNING
function Commands.AttemptScan(player, args)
    print("[Server] DynamicTrading: Scan requested by " .. player:getUsername())
    
    local targetUser = player:getUsername()

    -- 1. CHECK COOLDOWN (Server Side Enforcement to fix Double Trader Bug)
    local canScan, timeRem = DynamicTrading.Manager.CanScan(player)
    if not canScan then
        sendServerCommand("DynamicTrading", "ScanResult", { 
            status = "FAILED_RNG", -- Generic fail if cooldown active
            targetUser = targetUser 
        })
        return
    end

    -- 2. CHECK DAILY LIMIT
    local found, limit = DynamicTrading.Manager.GetDailyStatus()
    if found >= limit then
        sendServerCommand("DynamicTrading", "ScanResult", { 
            status = "LIMIT_REACHED", 
            targetUser = targetUser 
        })
        return
    end

    -- 3. APPLY TIMESTAMP IMMEDIATELY
    -- This prevents "Double Clicks" or lag from generating 2 traders. 
    -- Even if the RNG fails later, the cooldown is consumed.
    DynamicTrading.Manager.SetScanTimestamp(player)

    -- 4. CALCULATE LOGIC
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
    
    print(string.format("[DynamicTrading] Scan Roll: %d (Need <= %d) | User: %s", roll, finalChance, targetUser))
    
    if roll <= finalChance then
        -- SUCCESS: Generate Trader
        local trader = DynamicTrading.Manager.GenerateRandomContact()
        if trader then
            sendServerCommand("DynamicTrading", "ScanResult", { 
                status = "SUCCESS", 
                name = trader.name,
                archetype = trader.archetype,
                targetUser = targetUser
            })
        else
            sendServerCommand("DynamicTrading", "ScanResult", { 
                status = "FAILED_RNG", 
                targetUser = targetUser
            })
        end
    else
        -- FAILURE: Bad Roll
        sendServerCommand("DynamicTrading", "ScanResult", { 
            status = "FAILED_RNG", 
            targetUser = targetUser
        })
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

    -- A. TRADER EXPIRATION CHECK
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
                print("[Server] DynamicTrading: Removed expired trader " .. id)
                changesMade = true
            end
        end
    end
    
    if changesMade then 
        ModData.transmit("DynamicTrading_Engine_v1") 
    end

    -- B. DAILY EVENT TRIGGER (Runs at 8 AM)
    if currentHourOfDay == 8 and lastProcessedDay ~= currentDay then
        print("[Server] DynamicTrading: Running Daily Event Logic (Day " .. currentDay .. ")")
        
        if DynamicTrading.Manager.ProcessEvents then
            DynamicTrading.Manager.ProcessEvents()
            lastProcessedDay = currentDay
        else
            print("[Server] Error: DynamicTrading.Manager.ProcessEvents is missing!")
        end
    end
end

Events.EveryHours.Add(Server_OnHourlyTick)