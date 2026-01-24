require "DynamicTrading_Config"
require "DynamicTrading_Events"
require "DynamicTrading_PortraitConfig"

DynamicTrading = DynamicTrading or {}
DynamicTrading.Manager = {}

-- =============================================================================
-- 1. HELPER: CALCULATE "TRADING DAY" (5 AM START)
-- =============================================================================
function DynamicTrading.Manager.GetTradingDay()
    -- Using WorldAgeHours is the most robust way to track absolute server time.
    local gt = GameTime:getInstance()
    local hours = gt:getWorldAgeHours()
    
    -- Subtract 5 hours so the integer division flips exactly at 5 AM
    return math.floor((hours - 5) / 24)
end

-- =============================================================================
-- 2. DATA MANAGEMENT (PURE INITIALIZATION)
-- =============================================================================
function DynamicTrading.Manager.GetData()
    local data = ModData.getOrCreate("DynamicTrading_Engine_v2")
    
    -- Initialize Sub-Tables
    if not data.Traders then data.Traders = {} end
    if not data.globalHeat then data.globalHeat = {} end
    if not data.scanCooldowns then data.scanCooldowns = {} end
    if not data.NetworkLogs then data.NetworkLogs = {} end

    -- Daily Cycle Init
    if not data.DailyCycle then
        data.DailyCycle = {
            dailyTraderLimit = 5,
            currentTradersFound = 0,
            lastResetDay = -1
        }
    end

    -- Event System Init
    if not data.EventSystem then
        data.EventSystem = { 
            activeEvents = {}, 
            cooldowns = {}, -- [NEW] Tracks when events finished to prevent repetition
            lastEventDay = -10 
        }
    end

    -- Legacy Migration (Fixes old saves missing the cooldown table)
    if not data.EventSystem.cooldowns then data.EventSystem.cooldowns = {} end
    if not data.EventSystem.activeEvents then data.EventSystem.activeEvents = {} end

    -- Rebuild Cache (Client Side Visuals)
    DynamicTrading.Manager.RebuildActiveCache(data)
    
    return data
end

-- =============================================================================
-- 3. DAILY RESET LOGIC (SERVER AUTHORITATIVE)
-- =============================================================================
function DynamicTrading.Manager.CheckDailyReset()
    -- STRICT SAFETY: Clients should never run this logic.
    if isClient() then return end

    local data = DynamicTrading.Manager.GetData()
    local currentTradingDay = DynamicTrading.Manager.GetTradingDay()
    
    -- Safety Init for old saves
    if not data.DailyCycle.lastResetDay then data.DailyCycle.lastResetDay = -1 end

    -- THE TRIGGER
    if currentTradingDay > data.DailyCycle.lastResetDay then
        print("[DynamicTrading] SERVER: 5AM Reached. Performing Daily Reset (Day " .. currentTradingDay .. ").")
        
        -- 1. Update Tracker
        data.DailyCycle.lastResetDay = currentTradingDay
        
        -- 2. Reset Found Counter
        data.DailyCycle.currentTradersFound = 0
        
        -- 3. Randomize New Limit
        local min = SandboxVars.DynamicTrading.DailyTraderMin or 3
        local max = SandboxVars.DynamicTrading.DailyTraderMax or 8
        if min > max then min = max end 
        data.DailyCycle.dailyTraderLimit = ZombRand(min, max + 1)

        -- 4. Decay Heat / Inflation
        local decayRate = SandboxVars.DynamicTrading.InflationDecay or 0.01
        local retention = 1.0 - decayRate
        if retention < 0 then retention = 0 end

        if data.globalHeat then
            for cat, val in pairs(data.globalHeat) do
                if val ~= 0 then
                    data.globalHeat[cat] = val * retention
                    if math.abs(data.globalHeat[cat]) < 0.01 then data.globalHeat[cat] = 0 end
                end
            end
        end

        DynamicTrading.Manager.AddLog("Daily Cycle: Market Reset.", "info")
        print("[DynamicTrading] SERVER: Reset Complete. New Limit: " .. data.DailyCycle.dailyTraderLimit)

        -- 5. Force Sync to ALL Clients
        ModData.transmit("DynamicTrading_Engine_v2")
    end
end

-- =============================================================================
-- 4. DATA SYNC (CLIENT RECEPTION)
-- =============================================================================
local function OnReceiveGlobalModData(key, data)
    if key == "DynamicTrading_Engine_v2" then
        ModData.add(key, data)
        DynamicTrading.Manager.RebuildActiveCache(data)
    end
end
Events.OnReceiveGlobalModData.Add(OnReceiveGlobalModData)

-- =============================================================================
-- 5. UTILITIES
-- =============================================================================
function DynamicTrading.Manager.GetDailyStatus()
    local data = DynamicTrading.Manager.GetData()
    local currentFound = data.DailyCycle.currentTradersFound or 0
    local baseLimit = data.DailyCycle.dailyTraderLimit or 5
    
    local eventMult = 1.0
    if DynamicTrading.Events and DynamicTrading.Events.GetSystemModifier then
        eventMult = DynamicTrading.Events.GetSystemModifier("traderLimit")
    end
    
    local finalLimit = math.floor(baseLimit * eventMult)
    if finalLimit < 1 then finalLimit = 1 end 
    
    return currentFound, finalLimit
end

function DynamicTrading.Manager.IncrementDailyCounter()
    local data = DynamicTrading.Manager.GetData()
    data.DailyCycle.currentTradersFound = (data.DailyCycle.currentTradersFound or 0) + 1
    if isServer() or not isClient() then ModData.transmit("DynamicTrading_Engine_v2") end
end

-- =============================================================================
-- 6. EVENTS & LOGGING (IMPROVED VARIETY LOGIC)
-- =============================================================================
function DynamicTrading.Manager.ProcessEvents()
    local data = DynamicTrading.Manager.GetData()
    if not data.EventSystem then return end
    
    local es = data.EventSystem
    local currentDay = math.floor(GameTime:getInstance():getDaysSurvived()) 
    local changed = false

    -- A: CLEANUP & COOLDOWN SETTING
    for id, eventData in pairs(es.activeEvents) do
        if eventData.expires ~= -1 and currentDay >= eventData.expires then
            local def = DynamicTrading.Events.Registry[id]
            local name = def and def.name or id
            DynamicTrading.Manager.AddLog("Event Ended: " .. name, "info")
            
            -- [NEW] Set Cooldown: Current Day + 14 Days (prevents immediate repeat)
            -- If you have few events, you might want to lower 14 to 7.
            es.cooldowns[id] = currentDay + 14
            
            es.activeEvents[id] = nil
            changed = true
        end
    end

    -- B: META EVENTS (Always Active if Conditions Met)
    for id, def in pairs(DynamicTrading.Events.Registry) do
        if def.type == "meta" and def.condition then
            local isActive = es.activeEvents[id] ~= nil
            local shouldBeActive = def.condition()
            
            if shouldBeActive and not isActive then
                es.activeEvents[id] = { expires = -1 }
                DynamicTrading.Manager.AddLog("WORLD ALERT: " .. def.name, "event")
                changed = true
            elseif not shouldBeActive and isActive then
                es.activeEvents[id] = nil
                DynamicTrading.Manager.AddLog("Condition Cleared: " .. def.name, "info")
                changed = true
            end
        end
    end

    -- C: FLASH EVENTS (Random Lottery)
    local activeFlashCount = 0
    for id, _ in pairs(es.activeEvents) do
        local def = DynamicTrading.Events.Registry[id]
        if def and def.type == "flash" then activeFlashCount = activeFlashCount + 1 end
    end

    local maxFlashEvents = SandboxVars.DynamicTrading.MaxEvents or 3

    if activeFlashCount < maxFlashEvents then
        local daysSinceLast = currentDay - (es.lastEventDay or -10)
        local interval = SandboxVars.DynamicTrading.EventFrequency or 5
        
        if daysSinceLast >= interval then
            local chance = SandboxVars.DynamicTrading.EventChance or 50
            local roll = ZombRand(100) + 1
            
            if roll <= chance then
                local candidates = DynamicTrading.Events.GetFlashCandidates()
                
                -- [NEW] SMART FILTERING
                local validPool = {}    -- Fresh events ready to fire
                local cooldownPool = {} -- Events recently fired (Backup)

                for _, id in ipairs(candidates) do
                    -- 1. Must not be currently active
                    if not es.activeEvents[id] then
                        
                        -- 2. Check Cooldown
                        local unlockDay = es.cooldowns[id] or 0
                        
                        if currentDay >= unlockDay then
                            table.insert(validPool, id)
                        else
                            table.insert(cooldownPool, id)
                        end
                    end
                end

                -- [NEW] SELECTION LOGIC
                local finalPickID = nil

                if #validPool > 0 then
                    -- Priority: Pick a fresh event
                    finalPickID = validPool[ZombRand(#validPool) + 1]
                elseif #cooldownPool > 0 then
                    -- Fallback: If EVERYTHING is on cooldown, pick a random cooled one
                    -- so the game doesn't stall.
                    finalPickID = cooldownPool[ZombRand(#cooldownPool) + 1]
                end

                if finalPickID then
                    local def = DynamicTrading.Events.Registry[finalPickID]
                    if def then
                        local duration = SandboxVars.DynamicTrading.EventDuration or 3
                        es.activeEvents[finalPickID] = { expires = currentDay + duration }
                        es.lastEventDay = currentDay
                        DynamicTrading.Manager.AddLog("BREAKING NEWS: " .. def.name, "event")
                        changed = true
                    end
                else
                    -- No candidates found at all (Config empty?)
                    es.lastEventDay = currentDay
                end
            else
                -- Failed the % chance roll, wait 1 day before trying again?
                -- Or wait full interval? Let's just update lastEventDay to avoid spam.
                -- Setting this to (current - interval + 1) makes it check again tomorrow.
                es.lastEventDay = currentDay - (interval - 1)
                changed = true
            end
        end
    end

    if changed then
        ModData.transmit("DynamicTrading_Engine_v2")
        DynamicTrading.Manager.RebuildActiveCache(data)
    end
end

function DynamicTrading.Manager.RebuildActiveCache(data)
    DynamicTrading.Events.ActiveEvents = {}
    if not data or not data.EventSystem or not data.EventSystem.activeEvents then return end
    for id, _ in pairs(data.EventSystem.activeEvents) do
        local def = DynamicTrading.Events.Registry[id]
        if def then table.insert(DynamicTrading.Events.ActiveEvents, def) end
    end
end

function DynamicTrading.Manager.AddLog(text, category)
    local data = DynamicTrading.Manager.GetData()
    local gt = GameTime:getInstance()
    local timeStr = string.format("%02d/%02d %02d:%02d", gt:getDay()+1, gt:getMonth()+1, gt:getHour(), gt:getMinutes())
    table.insert(data.NetworkLogs, 1, { text = text, cat = category or "info", time = timeStr })
    while #data.NetworkLogs > 12 do table.remove(data.NetworkLogs) end
    if isServer() or not isClient() then ModData.transmit("DynamicTrading_Engine_v2") end
end

-- =============================================================================
-- 7. TRADER & TRANSACTION FUNCTIONS
-- =============================================================================
function DynamicTrading.Manager.GenerateRandomContact()
    local data = DynamicTrading.Manager.GetData()
    -- 1. Pick Archetype
local archetypes = {}
for id, _ in pairs(DynamicTrading.Archetypes) do table.insert(archetypes, id) end
if #archetypes == 0 then return nil end
local archetype = archetypes[ZombRand(#archetypes) + 1]

-- 2. Generate Identity (SurvivorFactory)
local name = "Trader " .. tostring(ZombRand(1000))
local gender = "Male"

if SurvivorFactory then
    local desc = SurvivorFactory.CreateSurvivor()
    if desc then 
        name = desc:getForename() .. " " .. desc:getSurname() 
        if desc:isFemale() then 
            gender = "Female" 
        end
    end
end

-- 3. Determine Portrait
local portraitID = 1
local maxPhotos = 5 -- Safe default

-- Check config for actual counts (e.g. Farmer might have 5, General might have 5)
if DynamicTrading.Portraits and DynamicTrading.Portraits.GetMaxCount then
    local count = DynamicTrading.Portraits.GetMaxCount(archetype, gender)
    if count > 0 then
        maxPhotos = count
    end
end

-- Roll ID
portraitID = ZombRand(maxPhotos) + 1

-- 4. Expiration
local gt = GameTime:getInstance()
local currentHours = gt:getWorldAgeHours()
local minHours = SandboxVars.DynamicTrading.TraderStayHoursMin or 6
local maxHours = SandboxVars.DynamicTrading.TraderStayHoursMax or 24
if minHours > maxHours then minHours = maxHours end

local duration = ZombRand(minHours, maxHours + 1)
local expireTime = currentHours + duration
local uniqueID = "Radio_" .. tostring(os.time()) .. "_" .. tostring(ZombRand(10000))

-- 5. Create Data Object
data.Traders[uniqueID] = {
    id = uniqueID,
    archetype = archetype,
    name = name,
    gender = gender,           -- [NEW]
    portraitID = portraitID,   -- [NEW]
    stocks = {},
    lastRestockDay = -1,
    expirationTime = expireTime
}

DynamicTrading.Manager.RestockTrader(uniqueID)
DynamicTrading.Manager.IncrementDailyCounter()
DynamicTrading.Manager.AddLog("Signal Acquired: " .. name, "good")

if isServer() or not isClient() then ModData.transmit("DynamicTrading_Engine_v2") end

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
    if isServer() or not isClient() then ModData.transmit("DynamicTrading_Engine_v2") end
end

function DynamicTrading.Manager.OnBuyItem(traderID, itemKey, category, qty)
    local data = DynamicTrading.Manager.GetData()
    local trader = data.Traders[traderID]
    if not trader or not trader.stocks[itemKey] then return end
    trader.stocks[itemKey] = math.max(0, trader.stocks[itemKey] - qty)
    local sensitivity = SandboxVars.DynamicTrading.CategoryInflation or 0.05
    local current = data.globalHeat[category] or 0
    data.globalHeat[category] = current + (sensitivity * qty)
    if data.globalHeat[category] > 2.0 then data.globalHeat[category] = 2.0 end
    if isServer() or not isClient() then ModData.transmit("DynamicTrading_Engine_v2") end
end

function DynamicTrading.Manager.OnSellItem(traderID, itemKey, category, qty)
    local data = DynamicTrading.Manager.GetData()
    local current = data.globalHeat[category] or 0
    data.globalHeat[category] = current - (0.01 * qty)
    if data.globalHeat[category] < -0.5 then data.globalHeat[category] = -0.5 end
    if isServer() or not isClient() then ModData.transmit("DynamicTrading_Engine_v2") end
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
    if isServer() or not isClient() then ModData.transmit("DynamicTrading_Engine_v2") end
end