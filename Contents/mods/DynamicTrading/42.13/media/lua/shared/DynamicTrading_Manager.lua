require "DynamicTrading_Config"
require "DynamicTrading_Events"

DynamicTrading = DynamicTrading or {}
DynamicTrading.Manager = {}

-- =============================================================================
-- 1. HELPER: CALCULATE "TRADING DAY" (5 AM START)
-- =============================================================================
function DynamicTrading.Manager.GetTradingDay()
    local gt = GameTime:getInstance()
    -- Calculate total hours passed in the entire playthrough
    local totalHours = (gt:getDaysSurvived() * 24) + gt:getHour()
    
    -- Subtract 5 hours so the integer division flips exactly at 5 AM
    return math.floor((totalHours - 5) / 24)
end

-- =============================================================================
-- 2. DATA MANAGEMENT (WITH MIGRATION)
-- =============================================================================
function DynamicTrading.Manager.GetData()
    -- 1. Load the MAIN ModData table
    local data = ModData.getOrCreate("DynamicTrading_Engine_v1")
    
    -- 2. Initialize Sub-Tables if they don't exist
    if not data.Traders then
        data.Traders = {}
        data.globalHeat = {}
        data.scanCooldowns = {}
        data.NetworkLogs = {} 
        
        data.DailyCycle = {
            dailyTraderLimit = 5,
            currentTradersFound = 0,
            lastResetDay = -1
        }
    end

    -- 3. MIGRATION: Convert old "Single Event" system to "Stackable System"
    if not data.EventSystem then
        data.EventSystem = {
            activeEvents = {}, -- New Table Structure
            lastEventDay = -10 -- Set back in time so events can spawn immediately on new saves
        }
    elseif data.EventSystem.activeID ~= nil then
        -- DETECT OLD SAVE FORMAT: Migration Required
        local oldID = data.EventSystem.activeID
        local oldEnd = data.EventSystem.endDay or -1
        
        data.EventSystem.activeEvents = {}
        
        -- Move the currently running event to the new table
        if oldID and DynamicTrading.Events.Registry[oldID] then
            data.EventSystem.activeEvents[oldID] = { expires = oldEnd }
        end
        
        -- Clean up old keys
        data.EventSystem.activeID = nil
        data.EventSystem.endDay = nil
        
        print("[DynamicTrading] Save Data Migrated to Stackable Event System.")
    end

    -- Safety check to ensure the table exists after migration or load
    if not data.EventSystem.activeEvents then data.EventSystem.activeEvents = {} end

    -- 4. DAILY CYCLE RESET LOGIC (5 AM Check)
    local currentTradingDay = DynamicTrading.Manager.GetTradingDay()
    
    -- IMPORTANT: Only the Server performs the WRITE/RESET to avoid desync
    if (isServer() or not isClient()) and currentTradingDay > (data.DailyCycle.lastResetDay or -1) then
        
        data.DailyCycle.lastResetDay = currentTradingDay
        data.DailyCycle.currentTradersFound = 0
        
        -- Randomize the Limit based on Sandbox
        local min = SandboxVars.DynamicTrading.DailyTraderMin or 3
        local max = SandboxVars.DynamicTrading.DailyTraderMax or 8
        if min > max then min = max end 
        data.DailyCycle.dailyTraderLimit = ZombRand(min, max + 1)

        -- Handle Inflation Decay (Market cools down overnight)
        if data.globalHeat then
            for cat, val in pairs(data.globalHeat) do
                if val ~= 0 then
                    data.globalHeat[cat] = val * 0.90
                    if math.abs(data.globalHeat[cat]) < 0.01 then data.globalHeat[cat] = 0 end
                end
            end
        end

        DynamicTrading.Manager.AddLog("Daily Cycle: Market Reset (5 AM).", "info")
        
        -- Force Sync changes to all clients
        ModData.transmit("DynamicTrading_Engine_v1")
    end

    -- 5. Rebuild Cache Locally
    DynamicTrading.Manager.RebuildActiveCache(data)
    
    return data
end

-- =============================================================================
-- 3. UTILITIES
-- =============================================================================

function DynamicTrading.Manager.GetDailyStatus()
    local data = DynamicTrading.Manager.GetData()
    local currentFound = data.DailyCycle.currentTradersFound or 0
    local baseLimit = data.DailyCycle.dailyTraderLimit or 5
    
    -- [NEW] Apply System Modifiers from Events (e.g. Warzone = fewer traders)
    local eventMult = 1.0
    if DynamicTrading.Events and DynamicTrading.Events.GetSystemModifier then
        eventMult = DynamicTrading.Events.GetSystemModifier("traderLimit")
    end
    
    local finalLimit = math.floor(baseLimit * eventMult)
    if finalLimit < 1 then finalLimit = 1 end -- Minimum safety
    
    return currentFound, finalLimit
end

function DynamicTrading.Manager.IncrementDailyCounter()
    local data = DynamicTrading.Manager.GetData()
    data.DailyCycle.currentTradersFound = (data.DailyCycle.currentTradersFound or 0) + 1
    if isServer() or not isClient() then ModData.transmit("DynamicTrading_Engine_v1") end
end

-- =============================================================================
-- 4. EVENTS & LOGGING (STACKABLE LOGIC)
-- =============================================================================

function DynamicTrading.Manager.ProcessEvents()
    local data = DynamicTrading.Manager.GetData()
    -- Safety check
    if not data.EventSystem then return end
    
    local es = data.EventSystem
    local currentDay = math.floor(GameTime:getInstance():getDaysSurvived()) 
    local changed = false

    -- STEP A: CLEANUP EXPIRED EVENTS
    for id, eventData in pairs(es.activeEvents) do
        -- Only remove if it has an expiration date (-1 means permanent until removed by condition)
        if eventData.expires ~= -1 and currentDay >= eventData.expires then
            local def = DynamicTrading.Events.Registry[id]
            local name = def and def.name or id
            DynamicTrading.Manager.AddLog("Event Ended: " .. name, "info")
            es.activeEvents[id] = nil
            changed = true
        end
    end

    -- STEP B: PROCESS META EVENTS (Seasons, World State)
    -- These DO NOT count towards the limit. They are forced by the world state.
    for id, def in pairs(DynamicTrading.Events.Registry) do
        if def.type == "meta" and def.condition then
            local isActive = es.activeEvents[id] ~= nil
            local shouldBeActive = def.condition()
            
            if shouldBeActive and not isActive then
                -- START PERMANENT EVENT
                es.activeEvents[id] = { expires = -1 } -- -1 = Controlled by condition, not time
                DynamicTrading.Manager.AddLog("WORLD ALERT: " .. def.name, "event")
                changed = true
            elseif not shouldBeActive and isActive then
                -- END PERMANENT EVENT
                es.activeEvents[id] = nil
                DynamicTrading.Manager.AddLog("Condition Cleared: " .. def.name, "info")
                changed = true
            end
        end
    end

    -- STEP C: PROCESS FLASH EVENTS (RNG)
    -- These ARE limited by the Sandbox option.
    
    -- 1. Count current FLASH events
    local activeFlashCount = 0
    for id, _ in pairs(es.activeEvents) do
        local def = DynamicTrading.Events.Registry[id]
        if def and def.type == "flash" then
            activeFlashCount = activeFlashCount + 1
        end
    end

    local maxFlashEvents = SandboxVars.DynamicTrading.MaxEvents or 3

    -- 2. Try to spawn new event if under limit
    if activeFlashCount < maxFlashEvents then
        local daysSinceLast = currentDay - (es.lastEventDay or -10)
        local interval = SandboxVars.DynamicTrading.EventFrequency or 5
        
        if daysSinceLast >= interval then
            local chance = SandboxVars.DynamicTrading.EventChance or 50
            local roll = ZombRand(100) + 1
            
            -- Debug
            print("[DynamicTrading] Flash Event Roll: " .. roll .. " (Target: < " .. chance .. ")")

            if roll <= chance then
                -- Roll Success: Find a candidate
                local candidates = DynamicTrading.Events.GetFlashCandidates()
                
                -- Filter out events already running
                local validCandidates = {}
                for _, id in ipairs(candidates) do
                    if not es.activeEvents[id] then
                        table.insert(validCandidates, id)
                    end
                end

                if #validCandidates > 0 then
                    local pickID = validCandidates[ZombRand(#validCandidates) + 1]
                    local def = DynamicTrading.Events.Registry[pickID]
                    
                    if def then
                        local duration = SandboxVars.DynamicTrading.EventDuration or 3
                        es.activeEvents[pickID] = { expires = currentDay + duration }
                        es.lastEventDay = currentDay
                        
                        DynamicTrading.Manager.AddLog("BREAKING NEWS: " .. def.name, "event")
                        changed = true
                        print("[DynamicTrading] Flash Event Started: " .. pickID)
                    end
                else
                    print("[DynamicTrading] Flash Event Roll passed, but no valid candidates available.")
                end
            else
                -- Roll Failed: Reset counter slightly so we retry tomorrow
                es.lastEventDay = currentDay - (interval - 1)
                changed = true
            end
        end
    end

    if changed then
        ModData.transmit("DynamicTrading_Engine_v1")
        DynamicTrading.Manager.RebuildActiveCache(data)
    end
end

-- [UPDATED] Rebuilds memory cache from the new table structure
function DynamicTrading.Manager.RebuildActiveCache(data)
    DynamicTrading.Events.ActiveEvents = {}
    
    if not data or not data.EventSystem or not data.EventSystem.activeEvents then return end
    
    for id, _ in pairs(data.EventSystem.activeEvents) do
        local def = DynamicTrading.Events.Registry[id]
        if def then
            table.insert(DynamicTrading.Events.ActiveEvents, def)
        end
    end
end

local function OnReceiveGlobalModData(key, data)
    if key == "DynamicTrading_Engine_v1" then
        DynamicTrading.Manager.RebuildActiveCache(data)
    end
end
Events.OnReceiveGlobalModData.Add(OnReceiveGlobalModData)

function DynamicTrading.Manager.AddLog(text, category)
    local data = DynamicTrading.Manager.GetData()
    local gt = GameTime:getInstance()
    local timeStr = string.format("%02d/%02d %02d:%02d", gt:getDay()+1, gt:getMonth()+1, gt:getHour(), gt:getMinutes())
    table.insert(data.NetworkLogs, 1, { text = text, cat = category or "info", time = timeStr })
    while #data.NetworkLogs > 12 do table.remove(data.NetworkLogs) end
    if isServer() or not isClient() then ModData.transmit("DynamicTrading_Engine_v1") end
end

-- =============================================================================
-- 5. TRADER MANAGEMENT
-- =============================================================================

function DynamicTrading.Manager.GenerateRandomContact()
    local data = DynamicTrading.Manager.GetData()
    local archetypes = {}
    for id, _ in pairs(DynamicTrading.Archetypes) do table.insert(archetypes, id) end
    if #archetypes == 0 then return nil end
    local archetype = archetypes[ZombRand(#archetypes) + 1]
    
    local name = "Trader " .. tostring(ZombRand(1000))
    if SurvivorFactory then
        local desc = SurvivorFactory.CreateSurvivor()
        if desc then name = desc:getForename() .. " " .. desc:getSurname() end
    end
    name = name .. " (" .. archetype .. ")"

    local gt = GameTime:getInstance()
    local currentHours = gt:getWorldAgeHours()
    local minHours = SandboxVars.DynamicTrading.TraderStayHoursMin or 6
    local maxHours = SandboxVars.DynamicTrading.TraderStayHoursMax or 24
    if minHours > maxHours then minHours = maxHours end
    
    local duration = ZombRand(minHours, maxHours + 1)
    local expireTime = currentHours + duration
    local uniqueID = "Radio_" .. tostring(os.time()) .. "_" .. tostring(ZombRand(10000))
    
    data.Traders[uniqueID] = {
        id = uniqueID,
        archetype = archetype,
        name = name,
        stocks = {},
        lastRestockDay = -1,
        expirationTime = expireTime
    }
    
    DynamicTrading.Manager.RestockTrader(uniqueID)
    DynamicTrading.Manager.IncrementDailyCounter()
    DynamicTrading.Manager.AddLog("Signal Acquired: " .. name, "good")
    
    if isServer() or not isClient() then ModData.transmit("DynamicTrading_Engine_v1") end
    
    return data.Traders[uniqueID]
end

function DynamicTrading.Manager.RestockTrader(traderID)
    local data = DynamicTrading.Manager.GetData()
    local trader = data.Traders[traderID]
    if not trader then return end
    local currentDay = math.floor(GameTime:getInstance():getDaysSurvived())
    local interval = SandboxVars.DynamicTrading.RestockInterval or 1
    if (currentDay - (trader.lastRestockDay or 0) >= interval) then
        if DynamicTrading.Economy and DynamicTrading.Economy.GenerateStock then
            trader.stocks = DynamicTrading.Economy.GenerateStock(trader.archetype)
            trader.lastRestockDay = currentDay
        end
    end
end

function DynamicTrading.Manager.GetTrader(traderID, archetype)
    if not traderID then return nil end
    local data = DynamicTrading.Manager.GetData()
    if not data.Traders[traderID] and not string.find(traderID, "Radio_") then
        data.Traders[traderID] = {
            id = traderID,
            archetype = archetype or "General",
            stocks = {},
            lastRestockDay = -1,
            expirationTime = nil 
        }
        DynamicTrading.Manager.RestockTrader(traderID)
    end
    return data.Traders[traderID]
end

function DynamicTrading.Manager.UpdateHeat(category, amount)
    if not category or category == "Misc" then return end
    local data = DynamicTrading.Manager.GetData()
    local current = data.globalHeat[category] or 0
    data.globalHeat[category] = current + amount
    if data.globalHeat[category] > 2.0 then data.globalHeat[category] = 2.0 end
    if data.globalHeat[category] < -0.5 then data.globalHeat[category] = -0.5 end
    if isServer() or not isClient() then ModData.transmit("DynamicTrading_Engine_v1") end
end

function DynamicTrading.Manager.OnBuyItem(traderID, itemKey, category, qty)
    local data = DynamicTrading.Manager.GetData()
    local trader = data.Traders[traderID]
    if not trader or not trader.stocks[itemKey] then return end
    trader.stocks[itemKey] = math.max(0, trader.stocks[itemKey] - qty)
    local sensitivity = SandboxVars.DynamicTrading.CategoryInflation or 0.05
    DynamicTrading.Manager.UpdateHeat(category, sensitivity * qty)
    if isServer() or not isClient() then ModData.transmit("DynamicTrading_Engine_v1") end
end

function DynamicTrading.Manager.OnSellItem(traderID, itemKey, category, qty)
    DynamicTrading.Manager.UpdateHeat(category, -0.01 * qty)
end

function DynamicTrading.Manager.CanScan(player)
    if not player then return false, 0 end
    local data = DynamicTrading.Manager.GetData()
    local username = player:getUsername()
    local lastTime = data.scanCooldowns[username] or 0
    local currentTime = GameTime:getInstance():getWorldAgeHours()
    local cooldownHours = (SandboxVars.DynamicTrading.ScanCooldown or 30) / 60.0
    
    if currentTime >= lastTime + cooldownHours then
        return true, 0
    else
        return false, (lastTime + cooldownHours - currentTime) * 60
    end
end

function DynamicTrading.Manager.SetScanTimestamp(player)
    if not player then return end
    local data = DynamicTrading.Manager.GetData()
    data.scanCooldowns[player:getUsername()] = GameTime:getInstance():getWorldAgeHours()
    if isServer() or not isClient() then ModData.transmit("DynamicTrading_Engine_v1") end
end