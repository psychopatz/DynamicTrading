require "DynamicTrading_Config"

DynamicTrading = DynamicTrading or {}
DynamicTrading.Manager = {}

-- =============================================================================
-- 1. DATA & LOGGING
-- =============================================================================
function DynamicTrading.Manager.GetData()
    local data = ModData.getOrCreate("DynamicTrading_Engine_v1")
    if not data.init then
        data.globalHeat = {}
        data.Traders = {}
        data.scanCooldowns = {}
        data.NetworkLogs = {} 
        data.init = true
    end
    if not data.NetworkLogs then data.NetworkLogs = {} end
    return data
end

function DynamicTrading.Manager.AddLog(text, category)
    local data = DynamicTrading.Manager.GetData()
    local gt = GameTime:getInstance()
    local day = gt:getDay() + 1
    local hour = gt:getHour()
    local min = gt:getMinutes()
    local timeStr = string.format("Day %d %02d:%02d", day, hour, min)
    
    table.insert(data.NetworkLogs, 1, {
        text = text,
        cat = category or "info",
        time = timeStr
    })
    
    if #data.NetworkLogs > 50 then table.remove(data.NetworkLogs) end
    if isClient() then ModData.transmit("DynamicTrading_Engine_v1") end
end

-- =============================================================================
-- 2. TRADER GENERATION (With Realistic Schedules)
-- =============================================================================
function DynamicTrading.Manager.GenerateRandomContact()
    local data = DynamicTrading.Manager.GetData()
    
    -- A. Archetype & Name (Same as before)
    local archetypes = {}
    for id, _ in pairs(DynamicTrading.Archetypes) do table.insert(archetypes, id) end
    if #archetypes == 0 then return nil end
    local archetype = archetypes[ZombRand(#archetypes) + 1]
    
    local name = "Unknown Survivor"
    local uniqueFound = false
    local attempts = 0
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

    -- B. Calculate Precise Expiration (Day + Hour)
    local gt = GameTime:getInstance()
    local currentDay = math.floor(gt:getDaysSurvived())
    local duration = SandboxVars.DynamicTrading.TraderStayDuration or 3
    
    local stayDays = duration + ZombRand(-1, 2)
    if stayDays < 1 then stayDays = 1 end
    
    local expireDay = currentDay + stayDays
    
    -- [NEW] Randomize Departure Hour (06:00 to 22:00)
    -- This prevents them from leaving exactly at midnight.
    local expireHour = ZombRand(6, 23) 

    -- C. Create Instance
    local uniqueID = "Radio_" .. tostring(os.time()) .. "_" .. tostring(ZombRand(10000))
    data.Traders[uniqueID] = {
        id = uniqueID,
        archetype = archetype,
        name = name,
        stocks = {},
        lastRestockDay = -1,
        expirationDay = expireDay,
        expirationHour = expireHour -- Store the hour
    }
    
    DynamicTrading.Manager.RestockTrader(uniqueID, true)
    
    DynamicTrading.Manager.AddLog("New Signal: " .. name .. " (" .. archetype .. ")", "good")
    
    if isClient() then ModData.transmit("DynamicTrading_Engine_v1") end
    
    return data.Traders[uniqueID]
end

-- =============================================================================
-- 3. EXISTING TRADER MANAGEMENT
-- =============================================================================
function DynamicTrading.Manager.GetTrader(traderID, archetype)
    if not traderID then return nil end
    local data = DynamicTrading.Manager.GetData()
    
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
    
    if force or (currentDay - (trader.lastRestockDay or 0) >= interval) then
        if DynamicTrading.Economy and DynamicTrading.Economy.GenerateStock then
            trader.stocks = DynamicTrading.Economy.GenerateStock(trader.archetype)
            trader.lastRestockDay = currentDay
        end
    end
end

-- =============================================================================
-- 4. INFLATION & TRANSACTIONS
-- =============================================================================
function DynamicTrading.Manager.UpdateHeat(category, amount)
    if not category or category == "Misc" then return end
    local data = DynamicTrading.Manager.GetData()
    local current = data.globalHeat[category] or 0
    data.globalHeat[category] = current + amount
    if data.globalHeat[category] > 2.0 then data.globalHeat[category] = 2.0 end
    if data.globalHeat[category] < -0.5 then data.globalHeat[category] = -0.5 end
    if isClient() then ModData.transmit("DynamicTrading_Engine_v1") end
end

function DynamicTrading.Manager.OnBuyItem(traderID, itemKey, category, qty)
    local data = DynamicTrading.Manager.GetData()
    local trader = data.Traders[traderID]
    if not trader or not trader.stocks[itemKey] then return end
    
    trader.stocks[itemKey] = trader.stocks[itemKey] - qty
    if trader.stocks[itemKey] < 0 then trader.stocks[itemKey] = 0 end
    
    local sensitivity = SandboxVars.DynamicTrading.CategoryInflation or 0.05
    DynamicTrading.Manager.UpdateHeat(category, sensitivity * qty)
    
    if isClient() then ModData.transmit("DynamicTrading_Engine_v1") end
end

function DynamicTrading.Manager.OnSellItem(traderID, itemKey, category, qty)
    DynamicTrading.Manager.UpdateHeat(category, -0.01 * qty)
end

-- =============================================================================
-- 5. COOLDOWN MANAGEMENT
-- =============================================================================
function DynamicTrading.Manager.CanScan(player)
    if not player then return false, 0 end
    local data = DynamicTrading.Manager.GetData()
    if not data.scanCooldowns then data.scanCooldowns = {} end
    
    local username = player:getUsername()
    local lastTime = data.scanCooldowns[username] or 0
    local currentTime = GameTime:getInstance():getWorldAgeHours()
    
    local cooldownMinutes = 30
    if SandboxVars.DynamicTrading and SandboxVars.DynamicTrading.ScanCooldown then
         cooldownMinutes = SandboxVars.DynamicTrading.ScanCooldown
    end
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
    if not data.scanCooldowns then data.scanCooldowns = {} end
    local username = player:getUsername()
    data.scanCooldowns[username] = GameTime:getInstance():getWorldAgeHours()
    if isClient() then ModData.transmit("DynamicTrading_Engine_v1") end
end

-- =============================================================================
-- 6. HOURLY MAINTENANCE (Replaces Daily Tick)
-- =============================================================================
function DynamicTrading.Manager.OnHourlyTick()
    -- Only Server/Host handles this
    if isClient() and not isServer() then return end

    local data = DynamicTrading.Manager.GetData()
    if not data or not data.init then return end
    
    local gt = GameTime:getInstance()
    local currentDay = math.floor(gt:getDaysSurvived())
    local currentHour = gt:getHour()
    
    local changesMade = false

    -- A. Remove Expired Traders (Hourly Check)
    if data.Traders then
        for id, trader in pairs(data.Traders) do
            if trader.expirationDay then
                -- Check if Day has passed OR (Same Day AND Hour has passed)
                local isExpired = false
                
                if currentDay > trader.expirationDay then
                    isExpired = true
                elseif currentDay == trader.expirationDay then
                    -- Default to 12:00 if old save w/o hour data
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

    -- B. Daily Tasks (Run ONLY at 00:00)
    -- We still need to decay heat and check events, but only once a day
    if currentHour == 0 then
        -- Decay Heat
        for cat, val in pairs(data.globalHeat) do
            if val ~= 0 then
                data.globalHeat[cat] = val * 0.90
                if math.abs(data.globalHeat[cat]) < 0.01 then data.globalHeat[cat] = 0 end
                changesMade = true
            end
        end
        
        -- Event Check
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
    
    if changesMade then
        ModData.transmit("DynamicTrading_Engine_v1")
    end
end

-- Changed from EveryDays to EveryHours
Events.EveryHours.Add(DynamicTrading.Manager.OnHourlyTick)