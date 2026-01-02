if isClient() then return end

require "DynamicTrading_Manager"

local Commands = {}

-- =============================================================================
-- CLIENT COMMAND HANDLER
-- =============================================================================
function Commands.AttemptScan(player, args)
    print("[Server] DynamicTrading: Scan requested by " .. player:getUsername())
    
    local found, limit = DynamicTrading.Manager.GetDailyStatus()
    
    if found >= limit then
        sendServerCommand(player, "DynamicTrading", "ScanResult", { status = "LIMIT_REACHED" })
        return
    end

    local penaltyPerTrader = SandboxVars.DynamicTrading.ScanPenaltyPerTrader or 0.2
    local penaltyFactor = 1.0 + (found * penaltyPerTrader) 
    
    local radioTier = args.radioTier or 0.5
    local baseChance = SandboxVars.DynamicTrading.ScanBaseChance or 30
    local skillBonus = args.skillBonus or 1.0

    local finalChance = (baseChance * radioTier * skillBonus) / penaltyFactor
    if finalChance < 1 then finalChance = 1 end
    if finalChance > 95 then finalChance = 95 end
    
    local roll = ZombRand(100) + 1
    
    if roll <= finalChance then
        local trader = DynamicTrading.Manager.GenerateRandomContact()
        if trader then
            sendServerCommand(player, "DynamicTrading", "ScanResult", { 
                status = "SUCCESS", 
                name = trader.name,
                archetype = trader.archetype
            })
        else
            sendServerCommand(player, "DynamicTrading", "ScanResult", { status = "FAILED_RNG" })
        end
    else
        sendServerCommand(player, "DynamicTrading", "ScanResult", { status = "FAILED_RNG" })
    end
end

local function OnClientCommand(module, command, player, args)
    if module == "DynamicTrading" and Commands[command] then
        Commands[command](player, args)
    end
end

Events.OnClientCommand.Add(OnClientCommand)

-- =============================================================================
-- SERVER MAINTENANCE LOOP (The Fix)
-- =============================================================================
-- This runs on Dedicated Servers AND Singleplayer/Host instances.
-- It never runs on MP Clients.
local function Server_OnHourlyTick()
    local data = DynamicTrading.Manager.GetData()
    local gt = GameTime:getInstance()
    local currentHours = gt:getWorldAgeHours()
    local currentDay = math.floor(gt:getDaysSurvived())
    
    local changesMade = false

    if data.Traders then
        for id, trader in pairs(data.Traders) do
            local shouldRemove = false
            
            -- Check Precise Hours (New System)
            if trader.expirationTime then
                if currentHours > trader.expirationTime then
                    shouldRemove = true
                end
                
            -- Check Legacy Days (Old System compatibility)
            elseif trader.expirationDay then
                if currentDay > trader.expirationDay then
                    shouldRemove = true
                end
            end
            
            if shouldRemove then
                -- Add log locally (it syncs automatically via ModData)
                DynamicTrading.Manager.AddLog("Signal Lost: " .. trader.name, "bad")
                
                -- Actually remove the trader from the table
                data.Traders[id] = nil
                
                print("[Server] DynamicTrading: Removed expired trader " .. id)
                changesMade = true
            end
        end
    end
    
    -- Sync removal to all clients
    if changesMade then 
        ModData.transmit("DynamicTrading_Engine_v1") 
    end
end

Events.EveryHours.Add(Server_OnHourlyTick)