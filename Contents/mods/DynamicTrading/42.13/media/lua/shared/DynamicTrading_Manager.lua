require "DynamicTrading_Config"

DynamicTrading = DynamicTrading or {}
DynamicTrading.Manager = {}

-- =============================================================================
-- 1. DATA & LOGGING
-- =============================================================================
function DynamicTrading.Manager.GetData()
    local data = ModData.getOrCreate("DynamicTrading_Engine_v1")
    
    -- Initialize if missing
    if not data.init then
        data.globalHeat = {}
        data.Traders = {}
        data.scanCooldowns = {}
        data.NetworkLogs = {} 
        data.init = true
    end
    
    -- Safety check for tables
    if not data.NetworkLogs then data.NetworkLogs = {} end
    if not data.Traders then data.Traders = {} end
    if not data.globalHeat then data.globalHeat = {} end
    if not data.scanCooldowns then data.scanCooldowns = {} end

    -- [PRUNING] Immediately clean up old logs from previous saves
    -- This ensures the UI doesn't break if you load a save with 50 logs
    while #data.NetworkLogs > 12 do
        table.remove(data.NetworkLogs) 
    end
    
    return data
end

function DynamicTrading.Manager.AddLog(text, category)
    local data = DynamicTrading.Manager.GetData()
    local gt = GameTime:getInstance()
    
    -- [CALENDAR TIME]
    local day = gt:getDay() + 1
    local month = gt:getMonth() + 1
    local year = gt:getYear()
    local hour = gt:getHour()
    local min = gt:getMinutes()
    
    -- Format: 04/07 08:30 (Day/Month Hour:Min)
    local timeStr = string.format("%02d/%02d %02d:%02d", day, month, hour, min)
    
    -- Insert at Top
    table.insert(data.NetworkLogs, 1, {
        text = text,
        cat = category or "info",
        time = timeStr
    })
    
    -- [PRUNING] Keep only 12 items
    while #data.NetworkLogs > 12 do
        table.remove(data.NetworkLogs)
    end
    
    -- [MP] Transmit update to all clients
    if isServer() then 
        ModData.transmit("DynamicTrading_Engine_v1") 
    end
end

-- =============================================================================
-- 2. TRADER GENERATION
-- =============================================================================
function DynamicTrading.Manager.GenerateRandomContact()
    local data = DynamicTrading.Manager.GetData()
    
    -- A. Pick Archetype
    local archetypes = {}
    for id, _ in pairs(DynamicTrading.Archetypes) do table.insert(archetypes, id) end
    if #archetypes == 0 then return nil end
    local archetype = archetypes[ZombRand(#archetypes) + 1]
    
    -- B. Generate Name
    local name = "Unknown Survivor"
    local uniqueFound = false
    local attempts = 0
    
    -- Try to find a unique name
    while not uniqueFound and attempts < 15 do
        attempts = attempts + 1
        if SurvivorFactory then
            local desc = SurvivorFactory.CreateSurvivor()
            if desc then name = desc:getForename() .. " " .. desc:getSurname() end
        else
            name = "Trader " .. tostring(ZombRand(1000))
        end
        
        local duplicate = false
        for _, t in pairs(data.Traders) do
            if t.name == name then duplicate = true break end
        end
        if not duplicate then uniqueFound = true end
    end
    if not uniqueFound then name = name .. " (" .. archetype .. ")" end

    -- C. Calculate Expiration
    local gt = GameTime:getInstance()
    local currentDay = math.floor(gt:getDaysSurvived())
    local duration = SandboxVars.DynamicTrading.TraderStayDuration or 3
    
    local stayDays = duration + ZombRand(-1, 2)
    if stayDays < 1 then stayDays = 1 end
    
    local expireDay = currentDay + stayDays
    local expireHour = ZombRand(6, 23) -- Random hour between 06:00 and 23:00

    -- D. Create Trader Object
    local uniqueID = "Radio_" .. tostring(os.time()) .. "_" .. tostring(ZombRand(10000))
    data.Traders[uniqueID] = {
        id = uniqueID,
        archetype = archetype,
        name = name,
        stocks = {},
        lastRestockDay = -1,
        expirationDay = expireDay,
        expirationHour = expireHour
    }
    
    -- Populate initial stock
    DynamicTrading.Manager.RestockTrader(uniqueID, true)
    
    -- Log success
    DynamicTrading.Manager.AddLog("Signal Acquired: " .. name .. " (" .. archetype .. ")", "good")
    
    -- [MP] Save & Sync
    if isServer() then ModData.transmit("DynamicTrading_Engine_v1") end
    
    return data.Traders[uniqueID]
end

-- =============================================================================
-- 3. EXISTING TRADER MANAGEMENT
-- =============================================================================
function DynamicTrading.Manager.GetTrader(traderID, archetype)
    if not traderID then return nil end
    local data = DynamicTrading.Manager.GetData()
    
    -- Create placeholder if accessing a trader that doesn't exist (safety)
    if not data.Traders[traderID] and not string.find(traderID, "Radio_") then
        data.Traders[traderID] = {
            id = traderID,
            archetype = archetype or "General",
            stocks = {},
            lastRestockDay = -1,
            expirationDay = nil
        }
        DynamicTrading.Manager.RestockTrader(traderID, true)
    end
    return data.Traders[traderID]
end

function DynamicTrading.Manager.RestockTrader(traderID, force)
    local data = DynamicTrading.Manager.GetData()
    local trader = data.Traders[traderID]
    if not trader then return end
    
    local gt = GameTime:getInstance()
    local currentDay = math.floor(gt:getDaysSurvived())
    local interval = SandboxVars.DynamicTrading.RestockInterval or 1
    
    -- Check restock timer
    if force or (currentDay - (trader.lastRestockDay or 0) >= interval) then
        if DynamicTrading.Economy and DynamicTrading.Economy.GenerateStock then
            trader.stocks = DynamicTrading.Economy.GenerateStock(trader.archetype)
            trader.lastRestockDay = currentDay
        end
    end
end

-- =============================================================================
-- 4. ECONOMY & INFLATION
-- =============================================================================
function DynamicTrading.Manager.UpdateHeat(category, amount)
    if not category or category == "Misc" then return end
    local data = DynamicTrading.Manager.GetData()
    
    local current = data.globalHeat[category] or 0
    data.globalHeat[category] = current + amount
    
    -- Cap inflation/deflation (-50% to +200%)
    if data.globalHeat[category] > 2.0 then data.globalHeat[category] = 2.0 end
    if data.globalHeat[category] < -0.5 then data.globalHeat[category] = -0.5 end
    
    if isServer() then ModData.transmit("DynamicTrading_Engine_v1") end
end

function DynamicTrading.Manager.OnBuyItem(traderID, itemKey, category, qty)
    local data = DynamicTrading.Manager.GetData()
    local trader = data.Traders[traderID]
    if not trader or not trader.stocks[itemKey] then return end
    
    -- Reduce Stock
    trader.stocks[itemKey] = trader.stocks[itemKey] - qty
    if trader.stocks[itemKey] < 0 then trader.stocks[itemKey] = 0 end
    
    -- Increase Inflation
    local sensitivity = SandboxVars.DynamicTrading.CategoryInflation or 0.05
    DynamicTrading.Manager.UpdateHeat(category, sensitivity * qty)
    
    if isServer() then ModData.transmit("DynamicTrading_Engine_v1") end
end

function DynamicTrading.Manager.OnSellItem(traderID, itemKey, category, qty)
    -- Buying from player reduces inflation slightly
    DynamicTrading.Manager.UpdateHeat(category, -0.01 * qty)
end

-- =============================================================================
-- 5. COOLDOWN MANAGEMENT
-- =============================================================================
function DynamicTrading.Manager.CanScan(player)
    if not player then return false, 0 end
    local data = DynamicTrading.Manager.GetData()
    
    local username = player:getUsername()
    local lastTime = data.scanCooldowns[username] or 0
    local currentTime = GameTime:getInstance():getWorldAgeHours()
    
    local cooldownMinutes = SandboxVars.DynamicTrading.ScanCooldown or 30
    local cooldownHours = cooldownMinutes / 60.0
    
    if currentTime >= lastTime + cooldownHours then
        return true, 0
    else
        local diffHours = (lastTime + cooldownHours) - currentTime
        return false, diffHours * 60
    end
end

function DynamicTrading.Manager.SetScanTimestamp(player)
    if not player then return end
    local data = DynamicTrading.Manager.GetData()
    
    local username = player:getUsername()
    data.scanCooldowns[username] = GameTime:getInstance():getWorldAgeHours()
    
    if isServer() then ModData.transmit("DynamicTrading_Engine_v1") end
end

-- =============================================================================
-- 6. SERVER MAINTENANCE LOOP
-- =============================================================================
function DynamicTrading.Manager.OnHourlyTick()
    -- Only the Server should run this loop
    if not isServer() then return end

    local data = DynamicTrading.Manager.GetData()
    if not data or not data.init then return end
    
    local gt = GameTime:getInstance()
    local currentDay = math.floor(gt:getDaysSurvived())
    local currentHour = gt:getHour()
    
    local changesMade = false

    -- A. Remove Expired Traders
    if data.Traders then
        for id, trader in pairs(data.Traders) do
            if trader.expirationDay then
                local isExpired = false
                
                -- Check Day
                if currentDay > trader.expirationDay then
                    isExpired = true
                -- Check Hour on the final day
                elseif currentDay == trader.expirationDay then
                    local targetHour = trader.expirationHour or 12 
                    if currentHour >= targetHour then
                        isExpired = true
                    end
                end
                
                if isExpired then
                    DynamicTrading.Manager.AddLog("Signal Lost: " .. trader.name, "bad")
                    data.Traders[id] = nil
                    changesMade = true
                end
            end
        end
    end

    -- B. Daily Tasks (Run at Midnight 00:00)
    if currentHour == 0 then
        -- Decay Heat (Market stabilization)
        for cat, val in pairs(data.globalHeat) do
            if val ~= 0 then
                data.globalHeat[cat] = val * 0.90
                if math.abs(data.globalHeat[cat]) < 0.01 then data.globalHeat[cat] = 0 end
                changesMade = true
            end
        end
        
        -- Check for New Events (Winter, Harvest, etc.)
        if DynamicTrading.Events and DynamicTrading.Events.CheckEvents then
            local oldEvents = {}
            for _, ev in ipairs(DynamicTrading.Events.ActiveEvents) do oldEvents[ev.name] = true end
            
            DynamicTrading.Events.CheckEvents()
            
            for _, ev in ipairs(DynamicTrading.Events.ActiveEvents) do
                if not oldEvents[ev.name] then
                    DynamicTrading.Manager.AddLog("Event Started: " .. ev.name, "event")
                    changesMade = true
                end
            end
        end
    end
    
    -- [MP] Sync all changes to clients
    if changesMade then
        ModData.transmit("DynamicTrading_Engine_v1")
    end
end

-- Hook the Hourly Tick
Events.EveryHours.Add(DynamicTrading.Manager.OnHourlyTick)