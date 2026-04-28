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

local function getAliveSoul(uuid, roster)
    if not uuid then return nil end
    if DynamicTrading_Roster and DynamicTrading_Roster.GetSoul then
        local soul = DynamicTrading_Roster.GetSoul(uuid)
        if soul then
            return soul.status ~= "Dead" and soul or nil
        end
    end

    local soul = roster and roster.Souls and roster.Souls[uuid] or nil
    if soul and soul.status ~= "Dead" then
        return soul
    end
    return nil
end

function Faction.getAliveFactionMemberUUIDs(factionID)
    local roster = Faction.ensureRosterModData()
    local members = roster and roster.FactionMembers and roster.FactionMembers[factionID] or nil
    local alive = {}
    local seen = {}

    if type(members) == "table" then
        for _, uuid in ipairs(members) do
            if not seen[uuid] and getAliveSoul(uuid, roster) then
                alive[#alive + 1] = uuid
                seen[uuid] = true
            end
        end
    end

    if roster and type(roster.Souls) == "table" then
        for uuid, soul in pairs(roster.Souls) do
            if soul and soul.factionID == factionID and soul.status ~= "Dead" and not seen[uuid] then
                alive[#alive + 1] = uuid
                seen[uuid] = true
            end
        end
    end

    return alive
end

function Faction.getAliveFactionMemberCount(factionID)
    return #Faction.getAliveFactionMemberUUIDs(factionID)
end

function Faction.getFactionMemberUUIDs(factionID)
    local roster = Faction.ensureRosterModData()
    local members = roster and roster.FactionMembers and roster.FactionMembers[factionID] or nil
    local uuids = {}
    local seen = {}

    if type(members) == "table" then
        for _, uuid in ipairs(members) do
            if uuid and not seen[uuid] then
                uuids[#uuids + 1] = uuid
                seen[uuid] = true
            end
        end
    end

    if roster and type(roster.Souls) == "table" then
        for uuid, soul in pairs(roster.Souls) do
            if soul and soul.factionID == factionID and not seen[uuid] then
                uuids[#uuids + 1] = uuid
                seen[uuid] = true
            end
        end
    end

    return uuids
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

function Faction.ensurePlayerDispositionState(faction)
    if type(faction) ~= "table" then
        return nil
    end

    if type(faction.playerDisposition) ~= "table" then
        faction.playerDisposition = {}
    end
    if faction.playerDispositionDefault == nil then
        if tostring(faction.factionType or "") == "bandit" then
            faction.playerDispositionDefault = -100
        end
    end

    return faction.playerDisposition
end

function Faction.getPlayerDisposition(faction, username)
    if type(faction) ~= "table" or not username or username == "" then
        return 0
    end

    local disposition = Faction.ensurePlayerDispositionState(faction)
    if type(disposition) == "table" and disposition[username] ~= nil then
        return tonumber(disposition[username]) or 0
    end

    return tonumber(faction.playerDispositionDefault) or 0
end

function Faction.setPlayerDisposition(factionID, username, value)
    local faction = Faction.getFactionData(factionID)
    if not faction or not username or username == "" then
        return false
    end

    local disposition = Faction.ensurePlayerDispositionState(faction)
    disposition[username] = math.max(-100, math.min(100, tonumber(value) or 0))
    if ModData.transmit then
        ModData.transmit("DynamicTrading_Factions")
    end
    return true
end

function Faction.adjustPlayerDisposition(factionID, username, delta)
    local faction = Faction.getFactionData(factionID)
    if not faction or not username or username == "" then
        return false
    end

    local current = Faction.getPlayerDisposition(faction, username)
    return Faction.setPlayerDisposition(factionID, username, current + (tonumber(delta) or 0))
end

function Faction.isFactionHostileToPlayer(factionID, faction, player)
    if not factionID or not faction or not player then return false end
    if faction.hostileToPlayers == true or faction.alwaysHostile == true then return true end

    local username = Shared.getUsername(player)
    if not username then return false end

    local rep = Faction.getPlayerDisposition(faction, username)

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
    faction.playerDispositionDefault = -100
    faction.trickleActiveCount = tonumber(faction.trickleActiveCount) or 1
    local disposition = Faction.ensurePlayerDispositionState(faction)

    for _, player in ipairs(Shared.getActivePlayers()) do
        local username = Shared.getUsername(player)
        if username and disposition[username] == nil then
            disposition[username] = -100
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

function Faction.PruneDeadNonPlayerSouls()
    local roster = Faction.ensureRosterModData()
    local factions = Faction.ensureFactionModData()
    local removed = 0
    local touchedFactions = {}
    local toRemove = {}

    for uuid, soul in pairs(roster and roster.Souls or {}) do
        local factionID = soul and soul.factionID or nil
        local faction = factionID and factions[factionID] or nil
        local isDead = soul and tostring(soul.status or "") == "Dead"
        local isTrackedLive = DTNPCManager and DTNPCManager.Data and DTNPCManager.Data[uuid] ~= nil

        if isDead and faction and faction.playerOwned ~= true and not isTrackedLive then
            toRemove[#toRemove + 1] = {
                uuid = uuid,
                factionID = factionID,
            }
        end
    end

    for _, entry in ipairs(toRemove) do
        if DynamicTrading_Roster and DynamicTrading_Roster.RemoveSpecificSoul
            and DynamicTrading_Roster.RemoveSpecificSoul(entry.uuid) then
            removed = removed + 1
            touchedFactions[entry.factionID] = true
        end
    end

    for factionID in pairs(touchedFactions) do
        local faction = factions[factionID]
        if faction and faction.playerOwned ~= true then
            faction.memberCount = Faction.getAliveFactionMemberCount(factionID)
        end
    end

    return removed, touchedFactions
end

function Faction.GetRecoveryTargetCount(factionID, faction)
    faction = faction or Faction.getFactionData(factionID)
    if not faction or faction.playerOwned == true then
        return 0
    end

    local baseline = math.max(
        tonumber(faction.raidRecoveryTargetCount) or 0,
        tonumber(faction.memberCount) or 0,
        Faction.getAliveFactionMemberCount(factionID)
    )

    if Shared.isBanditFactionID(factionID) then
        baseline = math.max(baseline, Constants.BANDIT_MIN_ROSTER)
    end

    faction.raidRecoveryTargetCount = baseline
    return baseline
end

function Faction.RefillHostileRaidPools()
    local factions = Faction.ensureFactionModData()
    local roster = Faction.ensureRosterModData()
    local refilled = 0

    for factionID, faction in pairs(factions) do
        local isEligibleHostileFaction = type(faction) == "table" and (
            Shared.isBanditFactionID(factionID)
            or faction.hostileToPlayers == true
            or faction.alwaysHostile == true
        ) or false
        if not isEligibleHostileFaction then
            for _, player in ipairs(Shared.getActivePlayers()) do
                if Faction.isFactionHostileToPlayer(factionID, faction, player) then
                    isEligibleHostileFaction = true
                    break
                end
            end
        end

        if type(faction) == "table"
            and faction.playerOwned ~= true
            and (Shared.isBanditFactionID(factionID) or not Faction.isFactionExcludedFromPopulationPool(factionID, faction))
            and isEligibleHostileFaction then
            local aliveCount = Faction.getAliveFactionMemberCount(factionID)
            local targetCount = Faction.GetRecoveryTargetCount(factionID, faction)
            local deficit = math.max(0, targetCount - aliveCount)

            if deficit > 0 then
                local replenish = math.max(1, math.ceil(deficit / math.max(1, Constants.HOSTILE_POOL_RECOVERY_DAYS)))
                replenish = math.min(deficit, replenish)
                local archetypePool = {}
                for uuid, soul in pairs(roster.Souls or {}) do
                    if soul and soul.factionID == factionID and tostring(soul.status or "") ~= "Dead" then
                        archetypePool[#archetypePool + 1] = soul.archetypeID or "General"
                    end
                end

                for _ = 1, replenish do
                    local archetypeID = Shared.isBanditFactionID(factionID)
                        and "Bandit"
                        or ((#archetypePool > 0 and archetypePool[ZombRand(#archetypePool) + 1]) or "General")
                    local added = DynamicTrading_Roster
                        and DynamicTrading_Roster.AddSoul
                        and DynamicTrading_Roster.AddSoul(factionID, archetypeID, nil, {
                            forceFaction = true,
                            suppressRecruitLog = true,
                        })
                    if added then
                        refilled = refilled + 1
                    end
                end
            end

            faction.memberCount = Faction.getAliveFactionMemberCount(factionID)
        end
    end

    return refilled
end
