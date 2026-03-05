-- =============================================================================
-- DYNAMIC TRADING V1: MANAGER (RADIO-SPECIFIC)
-- =============================================================================
-- This module handles radio-specific concerns ONLY:
--   - Radio scanning daily limits & counters
--   - Trader discovery (per-player visibility)
--   - Radio trader lifecycle (creation → expiration)
--
-- ALL economy, pricing, stock, and faction logic is delegated to the shared
-- faction system in DynamicTradingCommon (Engine, Factions, Roster, Stock).
-- =============================================================================

require "DT/Common/Config"
require "DT/Common/Events/DT_EventManager"
require "DT/V1/NetworkLogs"
require "DT/V1/CooldownManager"
require "DT/Common/Faction/TradingSys/DynamicTrading_Factions"

DynamicTrading = DynamicTrading or {}
DynamicTrading.Manager = {}

local V1_DATA_KEY = "DynamicTrading_V1_Radio"

-- =============================================================================
-- 1. HELPER: CALCULATE "TRADING DAY" (5 AM START)
-- =============================================================================
function DynamicTrading.Manager.GetTradingDay()
    local gt = GameTime:getInstance()
    local hours = gt:getWorldAgeHours()
    return math.floor((hours - 5) / 24)
end

-- =============================================================================
-- 2. V1 RADIO DATA (Lightweight — scanning state + discovery only)
-- =============================================================================
function DynamicTrading.Manager.GetData()
    local data = ModData.getOrCreate(V1_DATA_KEY)
    
    -- Radio Traders Registry: maps traderID (Soul UUID) → radio-specific metadata
    if not data.RadioTraders then data.RadioTraders = {} end
    
    -- Global version for UI refreshes
    if not data.tradersVersion then data.tradersVersion = 0 end
    
    return data
end

-- =============================================================================
-- 3. DAILY STATUS (Radio scanning limits)
-- =============================================================================
-- DEPRECATED: Daily Status no longer exists (legacy cleanup)
function DynamicTrading.Manager.GetDailyStatus()
    return 0, 999 
end

-- DEPRECATED: IncrementDailyCounter no longer exists (legacy cleanup)
function DynamicTrading.Manager.IncrementDailyCounter()
    DynamicTrading.Manager.BumpTradersVersion()
end

-- =============================================================================
-- 4. DAILY RESET (Radio-specific — scanning limits only)
-- =============================================================================
function DynamicTrading.Manager.CheckDailyReset()
    -- Legacy logic removed.
end

-- =============================================================================
-- 5. DATA SYNC (CLIENT RECEPTION)
-- =============================================================================
local function OnReceiveGlobalModData(key, data)
    if key == V1_DATA_KEY then
        ModData.add(key, data)
    end
end
Events.OnReceiveGlobalModData.Add(OnReceiveGlobalModData)

-- =============================================================================
-- 6. TRADER CREATION (Creates Soul in shared Roster + Stock)
-- =============================================================================
function DynamicTrading.Manager.GenerateRandomContact(finder, targetArchetype)
    local data = DynamicTrading.Manager.GetData()
    
    -- 1. Pick Archetype
    local archetype = targetArchetype
    if not archetype then
        local archetypes = {}
        for id, _ in pairs(DynamicTrading.Archetypes) do table.insert(archetypes, id) end
        if #archetypes == 0 then return nil end
        archetype = archetypes[ZombRand(#archetypes) + 1]
    end

    -- 2. Pick a random faction to assign this radio trader to
    local factionID = "Independent"
    if DynamicTrading_Factions then
        local factionData = ModData.get("DynamicTrading_Factions")
        if factionData then
            local factionIDs = {}
            for id, _ in pairs(factionData) do
                table.insert(factionIDs, id)
            end
            if #factionIDs > 0 then
                factionID = factionIDs[ZombRand(#factionIDs) + 1]
            end
        end
    end

    -- 3. Create Soul in shared Roster
    local uuid = nil
    if DynamicTrading_Roster and DynamicTrading_Roster.AddSoul then
        uuid = DynamicTrading_Roster.AddSoul(factionID, archetype, nil)
    end
    
    if not uuid then
        print("[DynamicTrading] V1 Radio: Failed to create Soul in Roster!")
        return nil
    end

    -- 4. Set Soul to "Trading" status so stock can be generated
    if DynamicTrading_Roster.UpdateSoulStatus then
        DynamicTrading_Roster.UpdateSoulStatus(uuid, "Trading", nil, nil)
    end

    -- 5. Generate Stock via shared economy
    if DynamicTrading_Stock and DynamicTrading_Stock.CheckAndGenerateStock then
        local success, reason = DynamicTrading_Stock.CheckAndGenerateStock(uuid)
        print("[DynamicTrading] V1 Radio: Stock for " .. uuid .. " => " .. tostring(reason))
    end

    -- 6. Expiration (Radio specific — traders leave after X hours)
    local gt = GameTime:getInstance()
    local currentHours = gt:getWorldAgeHours()
    local minHours = (SandboxVars.DynamicTrading and SandboxVars.DynamicTrading.TraderStayHoursMin) or 6
    local maxHours = (SandboxVars.DynamicTrading and SandboxVars.DynamicTrading.TraderStayHoursMax) or 24
    if minHours > maxHours then minHours = maxHours end
    local duration = ZombRand(minHours, maxHours + 1)
    local expireTime = currentHours + duration

    -- 7. Store radio-specific metadata (keyed by Soul UUID)
    local soul = DynamicTrading_Roster.GetSoulRegistry(uuid)
    data.RadioTraders[uuid] = {
        id = uuid,
        returnTime = expireTime,
        discoveredBy = {},
        createdHour = currentHours
    }

    -- Auto-discover for the creating player
    DynamicTrading.Manager.IncrementDailyCounter()
    
    if isServer() or not isClient() then ModData.transmit(V1_DATA_KEY) end
    
    -- Return a V1-compatible trader object for the caller
    return DynamicTrading.Manager.GetTrader(uuid)
end

-- =============================================================================
-- 7. GET TRADER (Builds V1-compatible object from Roster + Stock)
-- =============================================================================
function DynamicTrading.Manager.GetTrader(traderID, archetype)
    if not traderID then return nil end
    
    -- Fetch from shared systems
    local soul = DynamicTrading_Roster and DynamicTrading_Roster.GetSoulRegistry(traderID)
    local stockData = DynamicTrading_Stock and DynamicTrading_Stock.GetStock(traderID)
    local radioData = DynamicTrading.Manager.GetData().RadioTraders[traderID]
    
    -- Require a valid soul in the roster
    if not soul then return nil end
    
    -- Get faction data for wealth (acts as "budget")
    local factionWealth = 0
    local factionID = soul and soul.factionID
    if factionID and DynamicTrading_Factions then
        local faction = DynamicTrading_Factions.GetFaction(factionID)
        if faction then
            factionWealth = faction.wealth or 0
        end
    end

    -- Build V1-compatible trader object
    local trader = {
        -- Identity
        id = traderID,
        traderID = traderID,
        name = (soul and soul.name) or "Unknown Trader",
        gender = (soul and soul.isFemale) and "Female" or "Male",
        portraitID = (soul and soul.portraitID) or 1,
        archetype = (soul and soul.archetypeID) or archetype or "General",
        
        -- Stock (from shared Stock system)
        stocks = (stockData and stockData.items) or {},
        
        -- Economy (from faction)
        budget = factionWealth,
        factionID = factionID,
        
        -- Radio-specific
        returnTime = (radioData and radioData.returnTime) or (soul and soul.returnTime),
        discoveredBy = radioData and radioData.discoveredBy or {},
        
        -- Deflation (from Stock system)
        localDeflation = (stockData and stockData.deflation) or {},
        
        -- Status (from Roster) [NEW]
        status = (soul and soul.status) or (radioData and "Trading") or "Away",
        
        -- Restock
        lastRestockDay = -1
    }
    
    return trader
end

-- =============================================================================
-- 8. RESTOCK (Delegates to shared Stock system)
-- =============================================================================
function DynamicTrading.Manager.RestockTrader(traderID)
    if DynamicTrading_Stock and DynamicTrading_Stock.CheckAndGenerateStock then
        local success, reason = DynamicTrading_Stock.CheckAndGenerateStock(traderID)
        print("[DynamicTrading] V1 RestockTrader: " .. tostring(traderID) .. " => " .. tostring(reason))
    end
end

-- =============================================================================
-- 9. RADIO TRADER EXPIRATION (Cleanup Soul + Stock)
-- =============================================================================
function DynamicTrading.Manager.ExpireRadioTrader(traderID)
    local data = DynamicTrading.Manager.GetData()
    local radioData = data.RadioTraders[traderID]
    if not radioData then return end
    
    local soul = DynamicTrading_Roster and DynamicTrading_Roster.GetSoulRegistry(traderID)
    local traderName = (soul and soul.name) or "Unknown"
    
    -- Clear stock
    if DynamicTrading_Stock and DynamicTrading_Stock.ClearStock then
        DynamicTrading_Stock.ClearStock(traderID)
    end
    
    -- Update soul status to "Away" (or remove)
    if DynamicTrading_Roster and DynamicTrading_Roster.UpdateSoulStatus then
        DynamicTrading_Roster.UpdateSoulStatus(traderID, "Away", nil, nil)
    end
    
    -- Remove from V1 radio registry
    data.RadioTraders[traderID] = nil
    
    DynamicTrading.NetworkLogs.AddLog("Signal Lost: " .. traderName, "bad")
    
    if isServer() or not isClient() then ModData.transmit(V1_DATA_KEY) end
end

-- =============================================================================
-- 10. DISCOVERY SYSTEM (Radio-specific per-player visibility)
-- =============================================================================
function DynamicTrading.Manager.DiscoverTrader(traderID, player)
    if not traderID or not player then return false end
    local data = DynamicTrading.Manager.GetData()
    
    -- If not in V1 registry, create entry (Discovery Bridge)
    if not data.RadioTraders[traderID] then
        local gt = GameTime:getInstance()
        local currentHours = gt:getWorldAgeHours()
        
        -- Give the bridged trader a standard V1 radio lifetime. 
        -- The first player to discover them sets this expiry for everyone.
        local minHours = (SandboxVars.DynamicTrading and SandboxVars.DynamicTrading.TraderStayHoursMin) or 6
        local maxHours = (SandboxVars.DynamicTrading and SandboxVars.DynamicTrading.TraderStayHoursMax) or 24
        if minHours > maxHours then minHours = maxHours end
        local duration = ZombRand(minHours, maxHours + 1)
        local expireTime = currentHours + duration

        data.RadioTraders[traderID] = {
            id = traderID,
            returnTime = expireTime,
            discoveredBy = {},
            createdHour = currentHours
        }
    end
    
    local radioData = data.RadioTraders[traderID]
    local username = player:getUsername()
    if not radioData.discoveredBy then radioData.discoveredBy = {} end
    
    if not radioData.discoveredBy[username] then
        radioData.discoveredBy[username] = true
        
        -- [FIX] Trigger Network Log on Discovery
        local soul = DynamicTrading_Roster.GetSoulRegistry(traderID)
        local traderName = (soul and soul.name) or ("Trader " .. tostring(ZombRand(1000)))
        local factionName = "Independent"
        local factionID = soul and soul.factionID
        if factionID and DynamicTrading_Factions then
            local faction = DynamicTrading_Factions.GetFaction(factionID)
            if faction then factionName = faction.name or factionID end
        end
        
        DynamicTrading.NetworkLogs.AddLog("Signal Acquired by " .. username .. ": " .. traderName .. " (" .. factionName .. ")", "good")
        
        DynamicTrading.Manager.BumpTradersVersion()
        return true
    end
    return false
end

function DynamicTrading.Manager.HasDiscovered(traderID, player)
    if not traderID or not player then return false end
    local data = DynamicTrading.Manager.GetData()
    local radioData = data.RadioTraders[traderID]
    if not radioData then return false end
    
    if SandboxVars.DynamicTrading and SandboxVars.DynamicTrading.PublicNetwork then return true end
    
    local username = player:getUsername()
    return radioData.discoveredBy and radioData.discoveredBy[username] == true
end

function DynamicTrading.Manager.GetUndiscoveredTraders(player)
    if not player then return {} end
    local username = player:getUsername()
    local isPublic = SandboxVars.DynamicTrading and SandboxVars.DynamicTrading.PublicNetwork
    
    local undiscovered = {}
    
    -- We search all Souls in the Roster that are in "Trading" state
    if DynamicTrading_Roster and ModData.exists("DynamicTrading_Roster") then
        local rosterData = ModData.get("DynamicTrading_Roster")
        local data = DynamicTrading.Manager.GetData()
        local gt = GameTime:getInstance()
        local currentHours = gt:getWorldAgeHours()

        if rosterData and rosterData.Souls then
            for uuid, registry in pairs(rosterData.Souls) do
                if registry.status == "Trading" then
                    local radioData = data.RadioTraders and data.RadioTraders[uuid]
                    local expired = false
                    if radioData and radioData.returnTime and currentHours > radioData.returnTime then
                        expired = true
                    end
                    
                    if not expired then
                        local discovered = isPublic or DynamicTrading.Manager.HasDiscovered(uuid, player)
                        if not discovered then
                            local trader = DynamicTrading.Manager.GetTrader(uuid)
                            if trader then
                                table.insert(undiscovered, trader)
                            end
                        end
                    end
                end
            end
        end
    end
    
    return undiscovered
end

function DynamicTrading.Manager.GetTotalTradingSignals()
    local count = 0
    if DynamicTrading_Roster and ModData.exists("DynamicTrading_Roster") then
        local rosterData = ModData.get("DynamicTrading_Roster")
        local data = DynamicTrading.Manager.GetData()
        local gt = GameTime:getInstance()
        local currentHours = gt:getWorldAgeHours()

        if rosterData and rosterData.Souls then
            for uuid, registry in pairs(rosterData.Souls) do
                if registry.status == "Trading" then
                    local radioData = data.RadioTraders and data.RadioTraders[uuid]
                    local expired = false
                    if radioData and radioData.returnTime and currentHours > radioData.returnTime then
                        expired = true
                    end
                    
                    if not expired then
                        count = count + 1
                    end
                end
            end
        end
    end
    return count
end

function DynamicTrading.Manager.GetFoundSignalsCount(player)
    return DynamicTrading.Manager.GetDiscoveredCount(player)
end

function DynamicTrading.Manager.GetDiscoveredCount(player)
    if not player then return 0 end
    local data = DynamicTrading.Manager.GetData()
    local gt = GameTime:getInstance()
    local currentHours = gt:getWorldAgeHours()
    
    local function isValidSignal(id, radioData)
        if radioData.returnTime and currentHours > radioData.returnTime then return false end
        local soul = DynamicTrading_Roster and DynamicTrading_Roster.GetSoulRegistry(id)
        if not soul or soul.status ~= "Trading" then return false end
        return true
    end
    
    if SandboxVars.DynamicTrading and SandboxVars.DynamicTrading.PublicNetwork then
        local count = 0
        for id, radioData in pairs(data.RadioTraders) do 
            if isValidSignal(id, radioData) then count = count + 1 end
        end
        return count
    end

    local count = 0
    local username = player:getUsername()
    
    for id, radioData in pairs(data.RadioTraders) do
        if radioData.discoveredBy and radioData.discoveredBy[username] then
            if isValidSignal(id, radioData) then
                count = count + 1
            end
        end
    end
    return count
end

-- =============================================================================
-- 11. VERSION BUMPING (Signals UI refreshes)
-- =============================================================================
function DynamicTrading.Manager.BumpTradersVersion()
    local data = DynamicTrading.Manager.GetData()
    data.tradersVersion = (data.tradersVersion or 0) + 1
    if isServer() or not isClient() then ModData.transmit(V1_DATA_KEY) end
end

-- =============================================================================
-- 12. ACTIVE RADIO TRADERS LIST (For UI)
-- =============================================================================
function DynamicTrading.Manager.GetActiveRadioTraders(player)
    local data = DynamicTrading.Manager.GetData()
    local traders = {}
    local username = player and player:getUsername()
    local isPublic = SandboxVars.DynamicTrading and SandboxVars.DynamicTrading.PublicNetwork
    
    local gt = GameTime:getInstance()
    local currentHours = gt:getWorldAgeHours()

    for id, radioData in pairs(data.RadioTraders) do
        local visible = isPublic or (radioData.discoveredBy and username and radioData.discoveredBy[username])
        if visible then
            -- [NEW] Local Expiration Filter
            local expired = radioData.returnTime and currentHours > radioData.returnTime
            if not expired then
                local trader = DynamicTrading.Manager.GetTrader(id)
                if trader and trader.status == "Trading" then
                    table.insert(traders, trader)
                end
            end
        end
    end
    return traders
end

print("[DynamicTrading] V1 Manager (Faction Parity) Loaded.")
