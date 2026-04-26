-- ==============================================================================
-- DTNPC_Bandits_Server_Faction.lua
-- Bandit faction bootstrap and faction-state queries.
-- ==============================================================================

if isClient() and not isServer() then return end

local Bandits = DTNPCBandits
Bandits.Internal = Bandits.Internal or {}
local Internal = Bandits.Internal
Internal.Constants = Internal.Constants or {}
Internal.Shared = Internal.Shared or {}
local Constants = Internal.Constants
local Shared = Internal.Shared

Internal.Faction = Internal.Faction or {}

local Faction = Internal.Faction

function Faction.ensureFactionModData()
    if not ModData.exists("DynamicTrading_Factions") then
        ModData.add("DynamicTrading_Factions", {})
    end
    return ModData.get("DynamicTrading_Factions")
end

function Faction.ensureRosterModData()
    if DynamicTrading_Roster and DynamicTrading_Roster.Init then
        DynamicTrading_Roster.Init()
    elseif not ModData.exists("DynamicTrading_Roster") then
        ModData.add("DynamicTrading_Roster", {
            Traders = {},
            Souls = {},
            FactionMembers = {},
        })
    end

    local roster = ModData.get("DynamicTrading_Roster")
    roster.Souls = roster.Souls or {}
    roster.FactionMembers = roster.FactionMembers or {}
    roster.FactionMembers[Bandits.FACTION_ID] = roster.FactionMembers[Bandits.FACTION_ID] or {}
    return roster
end

function Faction.getFactionData(factionID)
    if not factionID then return nil end
    local factions = ModData.get("DynamicTrading_Factions")
    return factions and factions[factionID] or nil
end

function Faction.getFactionDisplayName(factionID)
    local faction = Faction.getFactionData(factionID)
    return faction and (faction.name or faction.displayName) or tostring(factionID or "Unknown")
end

function Faction.isFactionExcludedFromPopulationPool(factionID, faction)
    return factionID == "Independent"
        or factionID == "Factionless"
        or factionID == Bandits.FACTION_ID
        or (faction and (
            faction.excludeFromPopulationPool == true
            or faction.excludeFromFactionCap == true
            or faction.isSystemFaction == true
            or faction.systemFaction == true
        ))
end

function Faction.isFactionHostileToPlayer(factionID, faction, player)
    if not factionID or not faction or not player then return false end
    if faction.hostileToPlayers == true or faction.alwaysHostile == true then return true end

    local username = Shared.getUsername(player)
    if not username then return false end

    local rep = 0
    if type(faction.reputation) == "table" and faction.reputation[username] ~= nil then
        rep = tonumber(faction.reputation[username]) or 0
    elseif faction.reputationDefault ~= nil then
        rep = tonumber(faction.reputationDefault) or 0
    end

    local threshold = DTNPCProtect
        and DTNPCProtect.CONFIG
        and tonumber(DTNPCProtect.CONFIG.HostilePlayerRepThreshold)
        or Constants.HOSTILE_REP_THRESHOLD
    return rep <= threshold
end

function Faction.getHostileFactionIDsForPlayer(player)
    local factions = ModData.get("DynamicTrading_Factions")
    local hostile = {}
    if type(factions) ~= "table" then return hostile end

    for factionID, faction in pairs(factions) do
        if faction and Faction.isFactionHostileToPlayer(factionID, faction, player) then
            hostile[#hostile + 1] = factionID
        end
    end

    return hostile
end

function Bandits.EnsureBanditFaction(force)
    if not Shared.isCurrencyExpandedActive() then return false end

    local currentHour = Shared.worldHours()
    if force ~= true and currentHour - (Bandits.LastFactionEnsureHour or -99999) < Constants.BANDIT_FACTION_ENSURE_INTERVAL_HOURS then
        return true
    end
    Bandits.LastFactionEnsureHour = currentHour

    local factions = Faction.ensureFactionModData()
    local faction = factions[Bandits.FACTION_ID] or {}
    factions[Bandits.FACTION_ID] = faction

    faction.id = Bandits.FACTION_ID
    faction.name = faction.name or "Bandit Raiders"
    faction.town = faction.town or "Wilderness"
    faction.homeCoords = faction.homeCoords or {
        name = "Nomadic",
        town = "Wilderness",
        factionType = "bandit",
    }
    faction.stockpile = faction.stockpile or { food = 80, ammo = 80, meds = 25, fuel = 10, water = 80, materials = 20 }
    faction.state = "Hostile"
    faction.memberCount = math.max(tonumber(faction.memberCount) or 0, Constants.BANDIT_MIN_ROSTER)
    faction.ColonyWealth = math.max(tonumber(faction.ColonyWealth) or 0, 250)
    faction.factionType = "bandit"
    faction.isNomadic = true
    faction.isSystemFaction = true
    faction.systemFaction = true
    faction.excludeFromPopulationPool = true
    faction.excludeFromFactionCap = true
    faction.ignorePopulationCap = true
    faction.hostileToPlayers = true
    faction.alwaysHostile = true
    faction.reputationDefault = -100
    faction.trickleActiveCount = tonumber(faction.trickleActiveCount) or 1
    faction.reputation = type(faction.reputation) == "table" and faction.reputation or {}

    for _, player in ipairs(Shared.getActivePlayers()) do
        local username = Shared.getUsername(player)
        if username then
            faction.reputation[username] = -100
        end
    end

    local roster = Faction.ensureRosterModData()
    local members = roster.FactionMembers[Bandits.FACTION_ID]
    local existing = {}
    local aliveCount = 0
    for _, uuid in ipairs(members) do
        local soul = roster.Souls and roster.Souls[uuid] or nil
        if soul and soul.status ~= "Dead" then
            existing[uuid] = true
            aliveCount = aliveCount + 1
        end
    end

    while aliveCount < Constants.BANDIT_MIN_ROSTER and DynamicTrading_Roster and DynamicTrading_Roster.AddSoul do
        local uuid = DynamicTrading_Roster.AddSoul(Bandits.FACTION_ID, "Bandit", {
            name = "Nomadic",
            town = "Wilderness",
            z = 0,
        }, { forceFaction = true, suppressRecruitLog = true })
        if not uuid then break end

        local soul = DynamicTrading_Roster.GetSoul and DynamicTrading_Roster.GetSoul(uuid) or nil
        if soul then
            soul.factionID = Bandits.FACTION_ID
            soul.archetypeID = "Bandit"
            soul.isBandit = true
            soul.banditFactionHostile = true
            soul.homeCoords = {
                name = "Nomadic",
                town = "Wilderness",
                z = 0,
            }
            DynamicTrading_Roster.SaveSoul(uuid, soul)
        end

        if not existing[uuid] then
            aliveCount = aliveCount + 1
            existing[uuid] = true
        end
    end

    if ModData.transmit then
        ModData.transmit("DynamicTrading_Factions")
        ModData.transmit("DynamicTrading_Roster")
    end

    return true
end
