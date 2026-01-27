require "01_DynamicTrading_Config"
require "02b_DynamicTrading_Events"
require "03b_DynamicTrading_PortraitConfig"
require "02c_DT_NetworkLogs"
require "02d_DT_CooldownManager"

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
    local data = ModData.getOrCreate("DynamicTrading_Engine_v1.3")
    
    -- Initialize Sub-Tables
    if not data.Traders then data.Traders = {} end
    if not data.globalHeat then data.globalHeat = {} end
    -- [REMOVED] Legacy Cooldowns/Logs moved to isolated ModData
    -- if not data.scanCooldowns then data.scanCooldowns = {} end
    -- if not data.NetworkLogs then data.NetworkLogs = {} end

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
            -- [REMOVED] Cooldowns moved to DynamicTrading_Cooldowns_v1.0 (Server Only)
            -- cooldowns = {}, 
            lastEventDay = -10 
        }
    end


    -- [NEW] Global Deflation Tracker (Clear daily)
    if not data.deflatedGlobal then data.deflatedGlobal = {} end

    -- [NEW] Global Wealth Pool
    if not data.GlobalWealthPool then 
        local startWealth = SandboxVars.DynamicTrading.GlobalWealthStart or 10000
        data.GlobalWealthPool = startWealth
    end

    -- Legacy Migration (Fixes old saves missing the cooldown table)
    -- if not data.EventSystem.cooldowns then data.EventSystem.cooldowns = {} end
    if not data.EventSystem.activeEvents then data.EventSystem.activeEvents = {} end

    -- Rebuild Cache (Client Side Visuals)
    DynamicTrading.Manager.RebuildActiveCache(data)
    
    return data
end

-- =============================================================================
-- 2b. GLOBAL WEALTH API
-- =============================================================================
function DynamicTrading.Manager.GetGlobalWealth()
    local data = DynamicTrading.Manager.GetData()
    return data.GlobalWealthPool or 0
end

function DynamicTrading.Manager.AddToWealthPool(amount)
    local data = DynamicTrading.Manager.GetData()
    local current = data.GlobalWealthPool or 0
    data.GlobalWealthPool = current + amount
    
    -- Sync if this causes a significant change? 
    -- For now we rely on the caller to ModData.transmit or the periodic sync.
    -- But since this is often called during transactions, we should probably sync.
    if isServer() or not isClient() then ModData.transmit("DynamicTrading_Engine_v1.3") end
end

function DynamicTrading.Manager.TakeFromWealthPool(requestAmount)
    local data = DynamicTrading.Manager.GetData()
    local current = data.GlobalWealthPool or 0
    
    local withdrawn = 0
    if current >= requestAmount then
        withdrawn = requestAmount
        data.GlobalWealthPool = current - requestAmount
    else
        -- Pool is drained! Take what's left.
        withdrawn = current
        data.GlobalWealthPool = 0
    end
    
    if isServer() or not isClient() then ModData.transmit("DynamicTrading_Engine_v1.3") end
    return withdrawn
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

        -- 5. [NEW] Reset Global Deflation Checklist
        data.deflatedGlobal = {}

        -- 6. [NEW] Reset Local Trader Deflation
        if data.Traders then
            for _, trader in pairs(data.Traders) do
                trader.localDeflation = {}
            end
        end

        DynamicTrading.NetworkLogs.AddLog("Daily Cycle: Market Reset.", "info")
        print("[DynamicTrading] SERVER: Reset Complete. New Limit: " .. data.DailyCycle.dailyTraderLimit)

        -- 7. Force Sync to ALL Clients
        ModData.transmit("DynamicTrading_Engine_v1.3")
    end
end

-- =============================================================================
-- 4. DATA SYNC (CLIENT RECEPTION)
-- =============================================================================
local function OnReceiveGlobalModData(key, data)
    if key == "DynamicTrading_Engine_v1.3" then
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
    if isServer() or not isClient() then ModData.transmit("DynamicTrading_Engine_v1.3") end
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
            DynamicTrading.NetworkLogs.AddLog("Event Ended: " .. name, "info")
            
            -- [NEW] Set Cooldown: Current Day + 14 Days (prevents immediate repeat)
            -- If you have few events, you might want to lower 14 to 7.
            DynamicTrading.CooldownManager.SetEventCooldown(id, currentDay + 14)
            
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
                DynamicTrading.NetworkLogs.AddLog("WORLD ALERT: " .. def.name, "event")
                changed = true
            elseif not shouldBeActive and isActive then
                es.activeEvents[id] = nil
                DynamicTrading.NetworkLogs.AddLog("Condition Cleared: " .. def.name, "info")
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
                        local unlockDay = DynamicTrading.CooldownManager.GetEventCooldown(id)
                        
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
                        DynamicTrading.NetworkLogs.AddLog("BREAKING NEWS: " .. def.name, "event")
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
        ModData.transmit("DynamicTrading_Engine_v1.3")
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

-- [REFACTORED] Logging moved to DT_NetworkLogs.lua

-- =============================================================================
-- 7. TRADER & TRANSACTION FUNCTIONS
-- =============================================================================
function DynamicTrading.Manager.GenerateRandomContact(finder)
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
    -- [UPDATED] Wealth Pool Integration
    local minBudget = SandboxVars.DynamicTrading.TraderBudgetMin or 100
    local maxBudget = SandboxVars.DynamicTrading.TraderBudgetMax or 500
    local requestedBudget = ZombRand(minBudget, maxBudget + 1)
    
    local actualBudget = DynamicTrading.Manager.TakeFromWealthPool(requestedBudget)
    
    -- Fallback: If pool gave us 0 (or very little), invoke the Bailout Fund
    local fallback = SandboxVars.DynamicTrading.GlobalWealthFallback or 100
    if actualBudget < fallback then
        local missing = fallback - actualBudget
        actualBudget = actualBudget + missing
        -- We don't deduct this 'missing' amount from the pool because the pool is empty/insufficient.
        -- This is inflation/printing money to keep the game playable.
    end

    data.Traders[uniqueID] = {
        id = uniqueID,
        archetype = archetype,
        name = name,
        gender = gender,           -- [NEW]
        portraitID = portraitID,   -- [NEW]
        stocks = {},
        lastRestockDay = -1,
        expirationTime = expireTime,
        discoveredBy = {},          -- [PUBLIC NETWORK] Track which players discovered this trader
        budget = actualBudget,      -- [NEW] Derived from Pool
        localDeflation = {} -- [NEW] Per-item count
    }

    -- Auto-discover for the creating player (handled by server command)
    DynamicTrading.Manager.RestockTrader(uniqueID)
    DynamicTrading.Manager.IncrementDailyCounter()
    
    local finderName = "Unknown"
    
    if finder then
        -- Handle String (Generic Calls)
        if type(finder) == "string" then
            finderName = finder
        -- Handle IsoPlayer (Server Calls)
        elseif finder.getUsername then
            finderName = finder:getUsername()
        end
    end
    
    DynamicTrading.NetworkLogs.AddLog("Signal Acquired by " .. finderName .. ": " .. name, "good")

    if isServer() or not isClient() then ModData.transmit("DynamicTrading_Engine_v1.3") end

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
    if isServer() or not isClient() then ModData.transmit("DynamicTrading_Engine_v1.3") end
end

function DynamicTrading.Manager.OnBuyItem(traderID, itemKey, category, qty)
    local data = DynamicTrading.Manager.GetData()
    local trader = data.Traders[traderID]
    if not trader or not trader.stocks[itemKey] then return end
    trader.stocks[itemKey] = math.max(0, trader.stocks[itemKey] - qty)
    
    -- [NEW] Increase Trader Budget
    local itemData = DynamicTrading.Config.MasterList[itemKey]
    if itemData then
        local unitPrice = DynamicTrading.Economy.GetBuyPrice(itemKey, data.globalHeat)
        local totalGain = unitPrice * qty
        trader.budget = (trader.budget or 1000) + totalGain
        
        -- Buying means Player -> Trader.
        -- Money goes INTO the Trader's local budget.
        -- Eventually, when the trader leaves, this money returns to the Global Pool.
        -- So we don't need to touch the pool here.
    end

    local sensitivity = SandboxVars.DynamicTrading.CategoryInflation or 0.05
    local current = data.globalHeat[category] or 0
    data.globalHeat[category] = current + (sensitivity * qty)
    if data.globalHeat[category] > 2.0 then data.globalHeat[category] = 2.0 end
    if isServer() or not isClient() then ModData.transmit("DynamicTrading_Engine_v1.3") end
end

function DynamicTrading.Manager.OnSellItem(traderID, itemKey, category, qty)
    local data = DynamicTrading.Manager.GetData()
    local trader = data.Traders[traderID]
    if not trader then return end
    
    local current = data.globalHeat[category] or 0
    
    -- 1. [NEW] Decrement Trader Budget
    local localCount = (trader.localDeflation and trader.localDeflation[itemKey]) or 0
    local unitPrice = DynamicTrading.Economy.GetSellPrice(nil, itemKey, trader.archetype, data.globalHeat, localCount)
    trader.budget = math.max(0, (trader.budget or 1000) - (unitPrice * qty))

    -- 2. [NEW] Local Deflation (Trader specific saturation)
    if not trader.localDeflation then trader.localDeflation = {} end
    trader.localDeflation[itemKey] = (trader.localDeflation[itemKey] or 0) + qty

    -- 3. [UPDATED] Global Deflation (Configurable Roll, Once per item kind per day)
    if not data.deflatedGlobal[itemKey] then
        local roll = ZombRand(SandboxVars.DynamicTrading.SellDeflationChance or 30) + 1
        
        if roll == 1 then
            local sensitivity = SandboxVars.DynamicTrading.CategoryDeflation or 0.02
            data.globalHeat[category] = current - sensitivity
            
            -- Clamp deflation (Min -80% price)
            if data.globalHeat[category] < -0.8 then data.globalHeat[category] = -0.8 end
            
            data.deflatedGlobal[itemKey] = true
        end
    end
    
    if isServer() or not isClient() then ModData.transmit("DynamicTrading_Engine_v1.3") end
end

-- [REFACTORED] Scan Cooldown Logic moved to DT_CooldownManager.lua

-- =============================================================================
-- 8. PUBLIC NETWORK DISCOVERY SYSTEM
-- =============================================================================

-- Add a player to a trader's discoveredBy list
function DynamicTrading.Manager.DiscoverTrader(traderID, player)
    if not traderID or not player then return false end
    local data = DynamicTrading.Manager.GetData()
    local trader = data.Traders[traderID]
    if not trader then return false end
    
    local username = player:getUsername()
    if not trader.discoveredBy then trader.discoveredBy = {} end
    
    if not trader.discoveredBy[username] then
        trader.discoveredBy[username] = true
        if isServer() or not isClient() then ModData.transmit("DynamicTrading_Engine_v1.3") end
        return true
    end
    return false -- Already discovered
end

-- Check if a player has discovered a specific trader
function DynamicTrading.Manager.HasDiscovered(traderID, player)
    if not traderID or not player then return false end
    local data = DynamicTrading.Manager.GetData()
    local trader = data.Traders[traderID]
    if not trader then return false end
    
    -- If PublicNetwork is enabled (shared mode), everyone has discovered everyone
    if SandboxVars.DynamicTrading.PublicNetwork then return true end
    
    local username = player:getUsername()
    return trader.discoveredBy and trader.discoveredBy[username] == true
end

-- Get all traders this player has NOT discovered yet
function DynamicTrading.Manager.GetUndiscoveredTraders(player)
    if not player then return {} end
    local data = DynamicTrading.Manager.GetData()
    local undiscovered = {}
    local username = player:getUsername()
    
    for id, trader in pairs(data.Traders) do
        if not trader.discoveredBy or not trader.discoveredBy[username] then
            table.insert(undiscovered, trader)
        end
    end
    return undiscovered
end

-- Get count of traders discovered by this player
function DynamicTrading.Manager.GetDiscoveredCount(player)
    if not player then return 0 end
    local data = DynamicTrading.Manager.GetData()
    local count = 0
    local username = player:getUsername()
    
    for id, trader in pairs(data.Traders) do
        if trader.discoveredBy and trader.discoveredBy[username] then
            count = count + 1
        end
    end
    return count
end
