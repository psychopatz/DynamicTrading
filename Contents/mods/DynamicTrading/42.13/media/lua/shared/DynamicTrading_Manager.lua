require "DynamicTrading_Config"

DynamicTrading = DynamicTrading or {}
DynamicTrading.Manager = {}

-- =============================================================================
-- 1. DATA RETRIEVAL
-- =============================================================================
function DynamicTrading.Manager.GetData()
    local data = ModData.getOrCreate("DynamicTrading_Engine_v1")
    if not data.init then
        data.globalHeat = {}
        data.Traders = {}
        data.scanCooldowns = {} -- Stores last scan time per player (username)
        data.init = true
    end
    -- Backward compatibility for saves created before cooldown update
    if not data.scanCooldowns then data.scanCooldowns = {} end
    
    return data
end

-- =============================================================================
-- 2. TRADER GENERATION (Unique Names & Expiration)
-- =============================================================================
function DynamicTrading.Manager.GenerateRandomContact()
    local data = DynamicTrading.Manager.GetData()
    
    -- A. Pick Random Archetype
    local archetypes = {}
    for id, _ in pairs(DynamicTrading.Archetypes) do
        table.insert(archetypes, id)
    end
    if #archetypes == 0 then return nil end
    local archetype = archetypes[ZombRand(#archetypes) + 1]
    
    -- B. Generate Unique Name
    local name = "Unknown Survivor"
    local uniqueFound = false
    local attempts = 0
    
    while not uniqueFound and attempts < 15 do
        attempts = attempts + 1
        
        -- Use PZ internal SurvivorFactory for lore-friendly names
        if SurvivorFactory then
            local desc = SurvivorFactory.CreateSurvivor()
            if desc then
                name = desc:getForename() .. " " .. desc:getSurname()
            end
        else
            -- Fallback
            name = "Trader " .. tostring(ZombRand(1000))
        end
        
        -- Check duplicates in existing traders
        local duplicate = false
        for _, t in pairs(data.Traders) do
            if t.name == name then 
                duplicate = true 
                break 
            end
        end
        
        if not duplicate then uniqueFound = true end
    end
    
    -- Fallback if super unlucky with names
    if not uniqueFound then
        name = name .. " (" .. archetype .. ")"
    end

    -- C. Calculate Expiration
    local gt = GameTime:getInstance()
    local currentDay = math.floor(gt:getDaysSurvived())
    local duration = SandboxVars.DynamicTrading.TraderStayDuration or 3
    
    -- Randomized Stay: Duration +/- 1 day
    local stay = duration + ZombRand(-1, 2)
    if stay < 1 then stay = 1 end
    
    local expireDay = currentDay + stay

    -- D. Create Unique ID and Instance
    -- Using os.time() ensures safety even if scanned simultaneously
    local uniqueID = "Radio_" .. tostring(os.time()) .. "_" .. tostring(ZombRand(10000))
    
    data.Traders[uniqueID] = {
        id = uniqueID,
        archetype = archetype,
        name = name,
        stocks = {},
        lastRestockDay = -1,
        expirationDay = expireDay
    }
    
    -- Generate initial stock
    DynamicTrading.Manager.RestockTrader(uniqueID, true)
    
    -- Transmit to other players
    if isClient() then ModData.transmit("DynamicTrading_Engine_v1") end
    
    return data.Traders[uniqueID]
end

-- =============================================================================
-- 3. EXISTING TRADER MANAGEMENT
-- =============================================================================
function DynamicTrading.Manager.GetTrader(traderID, archetype)
    if not traderID then return nil end
    local data = DynamicTrading.Manager.GetData()
    
    -- If it's a persistent/debug trader (not radio), create if missing
    if not data.Traders[traderID] and not string.find(traderID, "Radio_") then
        data.Traders[traderID] = {
            id = traderID,
            archetype = archetype or "General",
            stocks = {},
            lastRestockDay = -1,
            expirationDay = nil -- Permanent
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
            local newStock = DynamicTrading.Economy.GenerateStock(trader.archetype)
            trader.stocks = newStock
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
    
    -- Clamp Heat (-50% to +200%)
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
-- 5. COOLDOWN MANAGEMENT (Scanning)
-- =============================================================================
-- Returns: boolean (canScan), number (minutesRemaining)
function DynamicTrading.Manager.CanScan(player)
    if not player then return false, 0 end
    
    local data = DynamicTrading.Manager.GetData()
    if not data.scanCooldowns then data.scanCooldowns = {} end
    
    local username = player:getUsername()
    local lastTime = data.scanCooldowns[username] or 0
    local currentTime = GameTime:getInstance():getWorldAgeHours()
    
    -- Config: Cooldown in Minutes (Default 30 if undefined)
    local cooldownMinutes = 30
    if SandboxVars.DynamicTrading and SandboxVars.DynamicTrading.ScanCooldown then
         cooldownMinutes = SandboxVars.DynamicTrading.ScanCooldown
    end
    
    -- Convert minutes to game-hours (1 game hour = 1.0)
    -- Actually getWorldAgeHours returns exact hours float.
    local cooldownHours = cooldownMinutes / 60.0
    
    if currentTime >= lastTime + cooldownHours then
        return true, 0
    else
        local diffHours = (lastTime + cooldownHours) - currentTime
        local diffMins = diffHours * 60
        return false, diffMins
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
-- 6. DAILY MAINTENANCE (Multiplayer Safe)
-- =============================================================================
function DynamicTrading.Manager.OnDailyTick()
    -- [MP SAFETY]
    -- Only the Server (or Host in SP) processes decay/expiration
    if isClient() and not isServer() then return end

    local data = DynamicTrading.Manager.GetData()
    if not data or not data.init then return end
    
    local currentDay = math.floor(GameTime:getInstance():getDaysSurvived())
    local changesMade = false

    -- A. Remove Expired Radio Traders
    local removedCount = 0
    if data.Traders then
        for id, trader in pairs(data.Traders) do
            if trader.expirationDay and currentDay >= trader.expirationDay then
                data.Traders[id] = nil
                removedCount = removedCount + 1
                changesMade = true
            else
                -- Optional: Daily Restock logic could go here if enabled
            end
        end
    end
    
    if removedCount > 0 then
        print("[DynamicTrading] " .. removedCount .. " traders moved out of signal range.")
    end

    -- B. Decay Heat (Inflation)
    for cat, val in pairs(data.globalHeat) do
        if val ~= 0 then
            data.globalHeat[cat] = val * 0.90
            if math.abs(data.globalHeat[cat]) < 0.01 then data.globalHeat[cat] = 0 end
            changesMade = true
        end
    end
    
    -- C. Event Check
    if DynamicTrading.Events and DynamicTrading.Events.CheckEvents then
        DynamicTrading.Events.CheckEvents()
    end
    
    -- Transmit updates
    if changesMade then
        if isClient() then 
            ModData.transmit("DynamicTrading_Engine_v1") -- Host
        else
            ModData.transmit("DynamicTrading_Engine_v1") -- Dedicated
        end
    end
end

Events.EveryDays.Add(DynamicTrading.Manager.OnDailyTick)

print("[DynamicTrading] Manager Loaded.")