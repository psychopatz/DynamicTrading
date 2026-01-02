require "DynamicTrading_Config"

DynamicTrading = DynamicTrading or {}
DynamicTrading.Manager = {}

-- =============================================================================
-- 1. DATA MANAGEMENT & LAZY RESET
-- =============================================================================
function DynamicTrading.Manager.GetData()
    local data = ModData.getOrCreate("DynamicTrading_Engine_v1")
    
    if not data.Traders then
        data.Traders = {}
        data.globalHeat = {}
        data.scanCooldowns = {}
        data.NetworkLogs = {} 
        data.dailyLimit = 5 
        data.dailyTradersFound = 0 
        data.lastResetDay = -1
    end

    local currentDay = math.floor(GameTime:getInstance():getDaysSurvived())
    
    if currentDay > (data.lastResetDay or -1) then
        data.lastResetDay = currentDay
        data.dailyTradersFound = 0
        
        local min = SandboxVars.DynamicTrading.DailyTraderMin or 3
        local max = SandboxVars.DynamicTrading.DailyTraderMax or 8
        if min > max then min = max end 
        data.dailyLimit = ZombRand(min, max + 1)

        if data.globalHeat then
            for cat, val in pairs(data.globalHeat) do
                if val ~= 0 then
                    data.globalHeat[cat] = val * 0.90
                    if math.abs(data.globalHeat[cat]) < 0.01 then data.globalHeat[cat] = 0 end
                end
            end
        end

        DynamicTrading.Manager.AddLog("Daily Cycle: Market Reset.", "info")
        -- Only transmit if we are the authority (Server/Host) to prevent spam
        if isServer() or not isClient() then ModData.transmit("DynamicTrading_Engine_v1") end
    end
    
    return data
end

function DynamicTrading.Manager.GetDailyStatus()
    local data = DynamicTrading.Manager.GetData()
    return (data.dailyTradersFound or 0), (data.dailyLimit or 5)
end

function DynamicTrading.Manager.IncrementDailyCounter()
    local data = DynamicTrading.Manager.GetData()
    data.dailyTradersFound = (data.dailyTradersFound or 0) + 1
    -- Transmit handled by caller usually, but safe to keep here for consistency
    if isServer() or not isClient() then ModData.transmit("DynamicTrading_Engine_v1") end
end

-- =============================================================================
-- 2. TRADER GENERATION
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

-- =============================================================================
-- 3. UTILITIES & LOGS
-- =============================================================================
function DynamicTrading.Manager.AddLog(text, category)
    local data = DynamicTrading.Manager.GetData()
    local gt = GameTime:getInstance()
    local timeStr = string.format("%02d/%02d %02d:%02d", gt:getDay()+1, gt:getMonth()+1, gt:getHour(), gt:getMinutes())
    
    table.insert(data.NetworkLogs, 1, { text = text, cat = category or "info", time = timeStr })
    
    while #data.NetworkLogs > 12 do table.remove(data.NetworkLogs) end
    
    if isServer() or not isClient() then ModData.transmit("DynamicTrading_Engine_v1") end
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

-- =============================================================================
-- 4. ECONOMY
-- =============================================================================
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

-- =============================================================================
-- 5. COOLDOWNS
-- =============================================================================
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

-- [REMOVED OnHourlyTick] - Logic moved to DT_ServerCommands.lua