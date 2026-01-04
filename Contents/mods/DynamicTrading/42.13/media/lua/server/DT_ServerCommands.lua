if isClient() then return end

require "DynamicTrading_Manager"

local Commands = {}
local lastProcessedDay = -1 

-- =============================================================================
-- 1. CLIENT COMMAND HANDLER
-- =============================================================================
function Commands.AttemptScan(player, args)
    print("[Server] DynamicTrading: Scan requested by " .. player:getUsername())
    
    -- Identify the user so clients know who this message is for
    local targetUser = player:getUsername()

    local found, limit = DynamicTrading.Manager.GetDailyStatus()
    
    -- CHECK DAILY LIMIT
    if found >= limit then
        sendServerCommand("DynamicTrading", "ScanResult", { 
            status = "LIMIT_REACHED", 
            targetUser = targetUser 
        })
        return
    end

    -- CALCULATE CHANCE
    local penaltyPerTrader = SandboxVars.DynamicTrading.ScanPenaltyPerTrader or 0.2
    local penaltyFactor = 1.0 + (found * penaltyPerTrader) 
    
    local radioTier = args.radioTier or 0.5
    local baseChance = SandboxVars.DynamicTrading.ScanBaseChance or 30
    local skillBonus = args.skillBonus or 1.0

    local finalChance = (baseChance * radioTier * skillBonus) / penaltyFactor
    
    -- Clamp chances
    if finalChance < 1 then finalChance = 1 end
    if finalChance > 95 then finalChance = 95 end
    
    -- ROLL RNG
    local roll = ZombRand(100) + 1
    
    if roll <= finalChance then
        -- SUCCESS: Generate Trader
        local trader = DynamicTrading.Manager.GenerateRandomContact()
        if trader then
            -- Broadcast Success (Clients will filter based on Sandbox Settings)
            sendServerCommand("DynamicTrading", "ScanResult", { 
                status = "SUCCESS", 
                name = trader.name,
                archetype = trader.archetype,
                targetUser = targetUser
            })
        else
            -- Rare error fallback
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
    -- Safety Check: Ensure Manager is loaded
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

    -- B. DAILY EVENT TRIGGER
    if currentHourOfDay == 8 and lastProcessedDay ~= currentDay then
        print("[Server] DynamicTrading: Running Daily Event Logic (Day " .. currentDay .. ")")
        
        -- [FIX] Safety check for ProcessEvents existence
        if DynamicTrading.Manager.ProcessEvents then
            DynamicTrading.Manager.ProcessEvents()
            lastProcessedDay = currentDay
        else
            print("[Server] Error: DynamicTrading.Manager.ProcessEvents is missing! Please restart the server.")
        end
    end
end

Events.EveryHours.Add(Server_OnHourlyTick)