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
require "DT/Common/Faction/TradingSys/RosterLogic/DT_RosterLogic_TradeScheduler"

DynamicTrading = DynamicTrading or {}
DynamicTrading.Manager = {}

local V1_DATA_KEY = "DynamicTrading_V1_Radio" -- Deprecated, kept only for legacy saves
local V2_RADAR_KEY = "DT_V2_RadarFound"

local function GetSessionData()
    return ModData.getOrCreate(V1_DATA_KEY)
end

local function getFactionModData()
    return ModData.get("DynamicTrading_Factions") or {}
end

local function syncSharedTraderData()
    if isServer() or not isClient() then
        ModData.transmit("DynamicTrading_Roster")
        ModData.transmit("DynamicTrading_Factions")
        ModData.transmit("DynamicTrading_Stock")
    end
end

local function ensureFactionExists(factionID)
    local targetFactionID = tostring(factionID or "Independent")
    local factionData = getFactionModData()
    if factionData[targetFactionID] then
        return targetFactionID
    end

    if targetFactionID == "Independent"
        and DynamicTrading_Factions
        and DynamicTrading_Factions.CreateFaction then
        DynamicTrading_Factions.CreateFaction("Independent", {
            memberCount = 10,
            isNomadic = true
        })
        return "Independent"
    end

    return targetFactionID
end

local function resolveFactionForArchetype(archetypeID)
    local factionData = getFactionModData()
    local preferredFactionID = DynamicTrading.GetArchetypePreferredFaction
        and DynamicTrading.GetArchetypePreferredFaction(archetypeID) or nil

    if preferredFactionID and factionData[preferredFactionID] then
        return preferredFactionID
    end

    local eligibleFactionIDs = {}
    for id, _ in pairs(factionData) do
        if not DynamicTrading.IsArchetypeAllowedForFaction
            or DynamicTrading.IsArchetypeAllowedForFaction(archetypeID, id) then
            table.insert(eligibleFactionIDs, id)
        end
    end

    if #eligibleFactionIDs > 0 then
        return eligibleFactionIDs[ZombRand(#eligibleFactionIDs) + 1]
    end

    if preferredFactionID == "Independent"
        and DynamicTrading_Factions
        and DynamicTrading_Factions.CreateFaction
        and not factionData["Independent"] then
        DynamicTrading_Factions.CreateFaction("Independent", {
            memberCount = 10,
            isNomadic = true
        })
        return "Independent"
    end

    if factionData["Independent"] then
        return "Independent"
    end

    return preferredFactionID or "Independent"
end

local function applyArchetypeFactionWealthFloor(archetypeID, factionID)
    local minWealth = DynamicTrading.GetArchetypeFactionWealthFloor
        and DynamicTrading.GetArchetypeFactionWealthFloor(archetypeID) or 0

    if minWealth <= 0 or not factionID or not DynamicTrading_Factions or not DynamicTrading_Factions.GetFaction then
        return
    end

    local faction = DynamicTrading_Factions.GetFaction(factionID)
    if faction and (tonumber(faction.wealth) or 0) < minWealth then
        faction.wealth = minWealth
    end
end

local function syncFactionMemberCount(factionID)
    if not factionID or not DynamicTrading_Factions or not DynamicTrading_Factions.GetFaction then
        return
    end

    local faction = DynamicTrading_Factions.GetFaction(factionID)
    if not faction then
        return
    end

    local members = DynamicTrading_Roster and DynamicTrading_Roster.GetSouls
        and DynamicTrading_Roster.GetSouls(factionID) or nil
    if type(members) ~= "table" then
        return
    end

    faction.memberCount = #members
end

local function seedTradingCoordinates(uuid)
    if not uuid or not DynamicTrading_Roster then
        return false
    end

    local registry = DynamicTrading_Roster.GetSoulRegistry and DynamicTrading_Roster.GetSoulRegistry(uuid) or nil
    local npcData = DynamicTrading_Roster.GetSoul and DynamicTrading_Roster.GetSoul(uuid) or nil
    if not registry or not npcData then
        return false
    end

    if npcData.lastX and npcData.lastY then
        return true
    end

    local targetX = nil
    local targetY = nil
    local targetZ = 0

    if DTNPCManager and DTNPCManager.PlanTradingDestination then
        targetX, targetY, targetZ = DTNPCManager.PlanTradingDestination(uuid, registry)
    end

    if (not targetX or not targetY) and (npcData.homeCoords or registry.homeCoords) then
        local fallbackHome = npcData.homeCoords or registry.homeCoords
        targetX = fallbackHome and fallbackHome.x or nil
        targetY = fallbackHome and fallbackHome.y or nil
        targetZ = fallbackHome and (fallbackHome.z or 0) or 0
    end

    if not targetX or not targetY then
        return false
    end

    npcData.lastX = math.floor(targetX)
    npcData.lastY = math.floor(targetY)
    npcData.lastZ = math.floor(targetZ or 0)
    npcData.travelTarget = nil
    DynamicTrading_Roster.SaveSoul(uuid, npcData)
    return true
end

function DynamicTrading.Manager.EnsureTraderTradingCoordinates(uuid)
    return seedTradingCoordinates(uuid)
end

-- =============================================================================
-- 1. HELPER: CALCULATE "TRADING DAY" (5 AM START)
-- =============================================================================
function DynamicTrading.Manager.GetTradingDay()
    return DynamicTrading_TradeScheduler.GetTradingDay()
end

-- =============================================================================
-- 2. DISCOVERY CACHE INIT (V1/V2 Shared)
-- =============================================================================
-- We now use V2's exact ModData key for cross-parity so finding them on V2 Radar
-- makes them appear on V1 Radio, and vice versa.
local function GetRadarData()
    return ModData.getOrCreate(V2_RADAR_KEY)
end

local function GetSignalSoulSnapshot(traderID)
    if not traderID or not DynamicTrading_Roster then
        return nil
    end

    local soul = DynamicTrading_Roster.GetSoul and DynamicTrading_Roster.GetSoul(traderID) or nil
    if type(soul) == "table" then
        return soul
    end

    return DynamicTrading_Roster.GetSoulRegistry and DynamicTrading_Roster.GetSoulRegistry(traderID) or nil
end

local function IsRequestedV1ContactVisitForPlayer(soul, player)
    if type(soul) ~= "table" or not player then
        return false
    end

    if soul.contactVisitActive ~= true then
        return false
    end

    if tostring(soul.contactVisitBackend or "") ~= "V1" then
        return false
    end

    if tostring(soul.status or "") ~= "Trading" then
        return false
    end

    local username = player.getUsername and tostring(player:getUsername() or "") or ""
    local onlineID = player.getOnlineID and player:getOnlineID() or nil
    local requestedBy = tostring(soul.contactVisitRequestedBy or "")
    local requestedByID = soul.contactVisitRequestedByID

    if username ~= "" and requestedBy == username then
        return true
    end

    if onlineID ~= nil and requestedByID ~= nil and tostring(requestedByID) == tostring(onlineID) then
        return true
    end

    return false
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
function DynamicTrading.Manager.GetData()
    return GetSessionData()
end
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
    -- 1. Pick Archetype
    local archetype = targetArchetype
    if not archetype then
        local archetypes = {}
        for id, _ in pairs(DynamicTrading.Archetypes) do table.insert(archetypes, id) end
        if #archetypes == 0 then return nil end
        archetype = archetypes[ZombRand(#archetypes) + 1]
    end

    return DynamicTrading.Manager.SpawnTraderWithArchetype(archetype)
end

function DynamicTrading.Manager.ActivateTraderSoul(uuid, options)
    if not uuid then
        return nil
    end

    options = type(options) == "table" and options or {}

    DynamicTrading.Manager.EnsureTraderTradingCoordinates(uuid)

    if DynamicTrading_Roster.UpdateSoulStatus then
        DynamicTrading_Roster.UpdateSoulStatus(uuid, "Trading", nil, nil)
    end

    -- Generate stock via shared economy
    if DynamicTrading_Stock and DynamicTrading_Stock.CheckAndGenerateStock then
        local success, reason = DynamicTrading_Stock.CheckAndGenerateStock(uuid)
        DynamicTrading.Log("DTV1", "Radio", "Stock", "Stock for " .. uuid .. " => " .. tostring(reason))
    end

    -- Expiration (Radio specific — traders leave after X hours)
    local gt = GameTime:getInstance()
    local currentHours = gt:getWorldAgeHours()
    local fixedDuration = tonumber(options.durationHours)
    local minHours = fixedDuration or tonumber(options.minHours)
        or ((SandboxVars.DynamicTrading and SandboxVars.DynamicTrading.TraderStayHoursMin) or 6)
    local maxHours = fixedDuration or tonumber(options.maxHours)
        or ((SandboxVars.DynamicTrading and SandboxVars.DynamicTrading.TraderStayHoursMax) or 24)
    if minHours > maxHours then minHours = maxHours end
    local duration = ZombRand(minHours, maxHours + 1)
    local expireTime = currentHours + duration

    if DynamicTrading_Roster.UpdateSoulStatus then
        DynamicTrading_Roster.UpdateSoulStatus(uuid, "Trading", expireTime, options.returnStatus or "Away")
    end

    syncSharedTraderData()

    return DynamicTrading.Manager.GetTrader(uuid)
end

function DynamicTrading.Manager.SpawnTraderWithArchetype(archetypeID, options)
    options = type(options) == "table" and options or {}

    if type(archetypeID) ~= "string" or archetypeID == "" then
        return nil
    end

    if not (DynamicTrading.Archetypes and DynamicTrading.Archetypes[archetypeID]) then
        DynamicTrading.Log("DTV1", "Radio", "Error", "SpawnTraderWithArchetype: Unknown archetype [" .. tostring(archetypeID) .. "]")
        return nil
    end

    local factionID = options.factionID or resolveFactionForArchetype(archetypeID)
    factionID = ensureFactionExists(factionID)
    applyArchetypeFactionWealthFloor(archetypeID, factionID)

    local uuid = nil
    if DynamicTrading_Roster and DynamicTrading_Roster.AddSoul then
        uuid = DynamicTrading_Roster.AddSoul(factionID, archetypeID, options.homeCoords, {
            forceFaction = options.forceFaction == true
        })
    end

    if not uuid then
        DynamicTrading.Log("DTV1", "Radio", "Error", "Failed to create Soul in Roster!")
        return nil
    end

    syncFactionMemberCount(factionID)

    local trader = DynamicTrading.Manager.ActivateTraderSoul(uuid, options)

    if trader and options.discoverForPlayer and DynamicTrading.Manager.DiscoverTrader then
        DynamicTrading.Manager.DiscoverTrader(uuid, options.discoverForPlayer)
        trader = DynamicTrading.Manager.GetTrader(uuid)
    end

    return trader
end

-- =============================================================================
-- 7. GET TRADER (Builds V1-compatible object from Roster + Stock)
-- =============================================================================
function DynamicTrading.Manager.GetTrader(traderID, archetype)
    if not traderID then return nil end
    
    -- Fetch from shared systems
    local soul = GetSignalSoulSnapshot(traderID)
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
        DynamicTrading.Log("DTV1", "Radio", "Stock", "RestockTrader: " .. tostring(traderID) .. " => " .. tostring(reason))
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
    return DynamicTrading.Manager.RegisterRadioSignal(traderID, player, {
        onlyIfNew = true,
        logCategory = "good",
    })
end

function DynamicTrading.Manager.RegisterRadioSignal(traderID, player, options)
    if not traderID or not player then return false end

    options = type(options) == "table" and options or {}

    local username = player:getUsername()
    local radarData = GetRadarData()

    if options.onlyIfNew and radarData[traderID] then
        return false
    end

    local soul = GetSignalSoulSnapshot(traderID)
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

    if options.logMessage ~= false then
        local logText = options.logMessage
        if not logText then
            logText = "Signal Acquired by " .. username .. ": " .. (soul.name or "Trader") .. " (" .. factionName .. ")"
        end
        DynamicTrading.NetworkLogs.AddLog(logText, options.logCategory or "good")
    end

    DynamicTrading.Manager.BumpTradersVersion()

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

function DynamicTrading.Manager.GetUndiscoveredRequestedContactVisits(player)
    if not player then return {} end

    local isPublic = SandboxVars.DynamicTrading and SandboxVars.DynamicTrading.PublicNetwork
    local traders = {}

    if not ModData.exists("DynamicTrading_Roster") then
        return traders
    end

    local rosterData = GetRosterData()
    local gt = GameTime:getInstance()
    local currentHours = gt:getWorldAgeHours()

    if not rosterData or not rosterData.Souls then
        return traders
    end

    for uuid, registry in pairs(rosterData.Souls) do
        local soul = GetSignalSoulSnapshot(uuid) or registry
        local expired = soul and soul.returnTime and currentHours > soul.returnTime or false
        local discovered = isPublic or DynamicTrading.Manager.HasDiscovered(uuid, player)

        if soul and not expired and not discovered and IsRequestedV1ContactVisitForPlayer(soul, player) then
            local trader = DynamicTrading.Manager.GetTrader(uuid)
            if trader then
                table.insert(traders, trader)
            end
        end
    end

    table.sort(traders, function(a, b)
        local soulA = GetSignalSoulSnapshot(a and a.id)
        local soulB = GetSignalSoulSnapshot(b and b.id)
        local startedA = soulA and tonumber(soulA.contactVisitStartedAt) or math.huge
        local startedB = soulB and tonumber(soulB.contactVisitStartedAt) or math.huge
        if startedA == startedB then
            return tostring(a and a.id or "") < tostring(b and b.id or "")
        end
        return startedA < startedB
    end)

    return traders
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
        local soul = GetSignalSoulSnapshot(id)
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
    
    local sourceIDs = {}
    if isPublic then
        local rosterData = GetRosterData()
        if not rosterData or not rosterData.Souls then return traders end
        for id, _ in pairs(rosterData.Souls) do
            sourceIDs[tostring(id)] = true
        end
    else
        for id, _ in pairs(radarData) do
            sourceIDs[tostring(id)] = true
        end
    end

    for id, _ in pairs(sourceIDs) do
        local soul = GetSignalSoulSnapshot(id)
        if soul and soul.status == "Trading" and not (soul.returnTime and currentHours > soul.returnTime) then
            local trader = DynamicTrading.Manager.GetTrader(id)
            if trader and trader.status == "Trading" then
                table.insert(traders, trader)
            elseif not isPublic then
                radarData[id] = nil
            end
        elseif not isPublic then
            radarData[id] = nil
        end
    end
    return traders
end

DynamicTrading.Log("DTV1", "Radio", "Init", "Manager (Faction Parity) Loaded.")
