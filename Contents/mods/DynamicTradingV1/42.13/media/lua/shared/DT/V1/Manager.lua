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

local V1_DATA_KEY = "DynamicTrading_V1_Radio" -- Deprecated, kept only for legacy saves
local V2_RADAR_KEY = "DT_V2_RadarFound"

-- =============================================================================
-- 1. HELPER: CALCULATE "TRADING DAY" (5 AM START)
-- =============================================================================
function DynamicTrading.Manager.GetTradingDay()
    local gt = GameTime:getInstance()
    local hours = gt:getWorldAgeHours()
    return math.floor((hours - 5) / 24)
end

-- =============================================================================
-- 2. DISCOVERY CACHE INIT (V1/V2 Shared)
-- =============================================================================
-- We now use V2's exact ModData key for cross-parity so finding them on V2 Radar
-- makes them appear on V1 Radio, and vice versa.
local function GetRadarData()
    return ModData.getOrCreate(V2_RADAR_KEY)
end

-- =============================================================================
-- 3. HELPER: GET FRESH ROSTER DATA
-- =============================================================================
local function GetRosterData()
    return ModData.getOrCreate("DynamicTrading_Roster")
end

-- =============================================================================
-- 3. LEGACY DATA CLEANUP
-- =============================================================================
-- Kept empty to catch old calls safely
function DynamicTrading.Manager.GetData() return {} end
function DynamicTrading.Manager.GetDailyStatus() return 0, 999 end
function DynamicTrading.Manager.IncrementDailyCounter() end
function DynamicTrading.Manager.CheckDailyReset() end

-- =============================================================================
-- 6. TRADER CREATION (Creates Soul in shared Roster + Stock)
-- =============================================================================
function DynamicTrading.Manager.GenerateRandomContact(finder, targetArchetype)
    if isClient() and not isServer() then
        -- Route to Server via Command in MP
        sendClientCommand(finder, "DynamicTrading_V1", "GenerateContact", { archetype = targetArchetype })
        return nil
    end
    return DynamicTrading.Manager.GenerateRandomContact_ServerCommand(targetArchetype, finder)
end

function DynamicTrading.Manager.GenerateRandomContact_ServerCommand(targetArchetype, finder)
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
    -- V1 now dictates returnTime instantly upon generation rather than relying on RadioTraders table
    local gt = GameTime:getInstance()
    local currentHours = gt:getWorldAgeHours()
    local minHours = (SandboxVars.DynamicTrading and SandboxVars.DynamicTrading.TraderStayHoursMin) or 6
    local maxHours = (SandboxVars.DynamicTrading and SandboxVars.DynamicTrading.TraderStayHoursMax) or 24
    if minHours > maxHours then minHours = maxHours end
    local duration = ZombRand(minHours, maxHours + 1)
    local expireTime = currentHours + duration

    -- Apply expiration to Common Roster
    if DynamicTrading_Roster.UpdateSoulStatus then
        DynamicTrading_Roster.UpdateSoulStatus(uuid, "Trading", expireTime, "Away")
    end

    -- Server syncs Common Faction/Roster instead of legacy Radio data
    if isServer() or not isClient() then 
        ModData.transmit("DynamicTrading_Roster") 
        ModData.transmit("DynamicTrading_Factions")
    end
    
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
    
    -- Resolve Faction Info for wealth/budget
    local factionID = soul and soul.factionID or "Independent"
    local factionName = "Independent Traders"
    local factionWealth = 0
    
    if DynamicTrading_Factions then
        local faction = DynamicTrading_Factions.GetFaction(factionID)
        if faction then
            factionName = faction.name or factionID
            factionWealth = faction.wealth or 0
        end
    end

    -- Build V1-compatible trader object directly from Common Data
    local trader = {
        -- Identity
        id = traderID,
        traderID = traderID,
        name = (soul and soul.name) or "Unknown Trader",
        gender = (soul and soul.isFemale) and "Female" or "Male",
        identitySeed = (soul and soul.identitySeed) or 1,
        archetype = (soul and soul.archetypeID) or archetype or "General",
        
        -- Stock (from shared Stock system)
        stocks = (stockData and stockData.items) or {},
        
        -- Economy (from faction)
        budget = factionWealth,
        factionID = factionID,
        factionName = factionName,
        
        -- Shared common
        returnTime = (soul and soul.returnTime),
        
        -- Deflation (from Stock system)
        localDeflation = (stockData and stockData.deflation) or {},
        
        -- Status (from Roster)
        status = (soul and soul.status) or "Away",
        
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
-- Handled by Common Lifecycle naturally, but preserved for explicit UI calls.
function DynamicTrading.Manager.ExpireRadioTrader(traderID)
    local soul = DynamicTrading_Roster and DynamicTrading_Roster.GetSoulRegistry(traderID)
    if not soul then return end
    
    local traderName = soul.name or "Unknown"
    
    -- Clear stock
    if DynamicTrading_Stock and DynamicTrading_Stock.ClearStock then
        DynamicTrading_Stock.ClearStock(traderID)
    end
    
    -- Update soul status to "Away"
    if DynamicTrading_Roster and DynamicTrading_Roster.UpdateSoulStatus then
        DynamicTrading_Roster.UpdateSoulStatus(traderID, "Away", nil, nil)
    end
    
    DynamicTrading.NetworkLogs.AddLog("Signal Lost: " .. traderName, "bad")
    
    if isServer() or not isClient() then ModData.transmit("DynamicTrading_Roster") end
end

-- =============================================================================
-- 10. DISCOVERY SYSTEM (V2 Client Cache Parity)
-- =============================================================================
function DynamicTrading.Manager.DiscoverTrader(traderID, player)
    -- V1 now mirrors V2 Radar exactly. Discovery is completely local-client side.
    if not traderID or not player then return false end
    
    local username = player:getUsername()
    local radarData = GetRadarData()
    
    -- Found in local Cache? Then we already know them.
    if radarData[traderID] then return false end
    
    local soul = DynamicTrading_Roster.GetSoulRegistry(traderID)
    if not soul then return false end
    
    -- Ensure trader has an expiration time if they are somehow missing one
    if not soul.returnTime or soul.returnTime == 0 then
        local gt = GameTime:getInstance()
        local currentHours = gt:getWorldAgeHours()
        local minHours = (SandboxVars.DynamicTrading and SandboxVars.DynamicTrading.TraderStayHoursMin) or 6
        local maxHours = (SandboxVars.DynamicTrading and SandboxVars.DynamicTrading.TraderStayHoursMax) or 24
        if minHours > maxHours then minHours = maxHours end
        local duration = ZombRand(minHours, maxHours + 1)
        
        if isClient() and not isServer() then
             -- (Ideally this doesn't happen, but if it does, server commands would be needed. 
             -- For now, just assume server handles generation correctly)
        else
            if DynamicTrading_Roster.UpdateSoulStatus then
                DynamicTrading_Roster.UpdateSoulStatus(traderID, "Trading", currentHours + duration, "Away")
                ModData.transmit("DynamicTrading_Roster")
            end
        end
    end
    
    local factionName = "Independent"
    local factionID = soul.factionID
    if factionID and DynamicTrading_Factions then
        local faction = DynamicTrading_Factions.GetFaction(factionID)
        if faction then factionName = faction.name or factionID end
    end
        
    -- Save to completely local Cache exactly like V2 does
    radarData[traderID] = {
        name = soul.name or "Unknown Trader",
        faction = factionName,
        discoveredAt = getGameTime():getWorldAgeHours()
    }
    
    DynamicTrading.NetworkLogs.AddLog("Signal Acquired by " .. username .. ": " .. (soul.name or "Trader") .. " (" .. factionName .. ")", "good")
    
    -- Trigger local UI update
    local triggerBump
    triggerBump = function()
        DynamicTrading.Manager.BumpTradersVersion()
        Events.OnTick.Remove(triggerBump)
    end
    Events.OnTick.Add(triggerBump)
    
    return true
end

function DynamicTrading.Manager.HasDiscovered(traderID, player)
    if not traderID or not player then return false end
    if SandboxVars.DynamicTrading and SandboxVars.DynamicTrading.PublicNetwork then return true end
    
    local radarData = GetRadarData()
    return radarData[traderID] ~= nil
end

function DynamicTrading.Manager.GetUndiscoveredTraders(player)
    if not player then return {} end
    local isPublic = SandboxVars.DynamicTrading and SandboxVars.DynamicTrading.PublicNetwork
    
    local undiscovered = {}
    
    -- We search all Souls in the Roster that are in "Trading" state
    if ModData.exists("DynamicTrading_Roster") then
        local rosterData = GetRosterData()
        local gt = GameTime:getInstance()
        local currentHours = gt:getWorldAgeHours()

        if rosterData and rosterData.Souls then
            for uuid, registry in pairs(rosterData.Souls) do
                if registry.status == "Trading" then
                    local expired = false
                    if registry.returnTime and currentHours > registry.returnTime then
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
    if ModData.exists("DynamicTrading_Roster") then
        local rosterData = GetRosterData()
        local gt = GameTime:getInstance()
        local currentHours = gt:getWorldAgeHours()

        if rosterData and rosterData.Souls then
            for uuid, registry in pairs(rosterData.Souls) do
                if registry.status == "Trading" then
                    local expired = false
                    if registry.returnTime and currentHours > registry.returnTime then
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
    local radarData = GetRadarData()
    local gt = GameTime:getInstance()
    local currentHours = gt:getWorldAgeHours()
    
    local function isValidSignal(id)
        local soul = DynamicTrading_Roster and DynamicTrading_Roster.GetSoulRegistry(id)
        if not soul or soul.status ~= "Trading" then return false end
        if soul.returnTime and currentHours > soul.returnTime then return false end
        return true
    end
    
    if SandboxVars.DynamicTrading and SandboxVars.DynamicTrading.PublicNetwork then
        local count = 0
        if ModData.exists("DynamicTrading_Roster") then
            local rosterData = GetRosterData()
            if rosterData and rosterData.Souls then
                for uuid, registry in pairs(rosterData.Souls) do
                    if registry.status == "Trading" and isValidSignal(uuid) then
                        count = count + 1
                    end
                end
            end
        end
        return count
    end

    local count = 0
    -- Map over the local client cache
    for id, _ in pairs(radarData) do
        if isValidSignal(id) then
            count = count + 1
        else
            -- Cleanup expired from local radar
            radarData[id] = nil
        end
    end
    return count
end

-- =============================================================================
-- 11. VERSION BUMPING (Signals UI refreshes)
-- =============================================================================
function DynamicTrading.Manager.BumpTradersVersion()
    -- Local UI refresh only needed now since data is purely local
    local data = DynamicTrading.Manager.GetData()
    data.tradersVersion = (data.tradersVersion or 0) + 1
end

function DynamicTrading.Manager.BumpTradersVersion_ServerCommand()
    -- Deprecated, unneeded
end

-- =============================================================================
-- 12. ACTIVE RADIO TRADERS LIST (For UI)
-- =============================================================================
function DynamicTrading.Manager.GetActiveRadioTraders(player)
    local radarData = GetRadarData()
    local traders = {}
    local isPublic = SandboxVars.DynamicTrading and SandboxVars.DynamicTrading.PublicNetwork
    
    local gt = GameTime:getInstance()
    local currentHours = gt:getWorldAgeHours()
    
    local rosterData = GetRosterData()
    if not rosterData or not rosterData.Souls then return traders end

    for id, registry in pairs(rosterData.Souls) do
        local visible = isPublic or radarData[id] ~= nil
        if visible and registry.status == "Trading" then
            local expired = registry.returnTime and currentHours > registry.returnTime
            if not expired then
                local trader = DynamicTrading.Manager.GetTrader(id)
                if trader and trader.status == "Trading" then
                    table.insert(traders, trader)
                else
                    radarData[id] = nil -- cleanup
                end
            else
                radarData[id] = nil -- cleanup
            end
        end
    end
    return traders
end

print("[DynamicTrading] V1 Manager (Faction Parity) Loaded.")
