-- ==============================================================================
-- DTNPC_Bandits_Server_Raid.lua
-- Raid selection, spawning, lifecycle, and periodic processing for bandits.
-- ==============================================================================

if isClient() and not isServer() then return end

local Bandits = DTNPCBandits
Bandits.Internal = Bandits.Internal or {}
local Internal = Bandits.Internal
Internal.Constants = Internal.Constants or {}
Internal.Shared = Internal.Shared or {}
Internal.Faction = Internal.Faction or {}
Internal.Demand = Internal.Demand or {}
local Constants = Internal.Constants
local Shared = Internal.Shared
local Faction = Internal.Faction
local Demand = Internal.Demand

Internal.Raid = Internal.Raid or {}

local Raid = Internal.Raid

local function getFactionDisplayName(factionID)
    if Shared and type(Shared.getFactionDisplayName) == "function" then
        return Shared.getFactionDisplayName(factionID)
    end
    if Faction and type(Faction.getFactionDisplayName) == "function" then
        return Faction.getFactionDisplayName(factionID)
    end
    return tostring(factionID or "Unknown")
end

local function generateGroupID(player, factionID)
    return "Raid_" .. tostring(factionID or "Faction") .. "_" .. tostring(Shared.getUsername(player) or "Player") .. "_" .. tostring(math.floor(Shared.worldHours() * 100)) .. "_" .. tostring(ZombRand(1000000))
end

local function getSoulData(uuid)
    if not uuid or not DynamicTrading_Roster then return nil end
    if DynamicTrading_Roster.GetSoul then
        local soul = DynamicTrading_Roster.GetSoul(uuid)
        if soul then return soul end
    end

    local roster = ModData.get("DynamicTrading_Roster")
    return roster and roster.Souls and roster.Souls[uuid] or nil
end

function Raid.getRestingFactionMembers(factionID)
    local roster = Faction.ensureRosterModData()
    local members = roster.FactionMembers and roster.FactionMembers[factionID] or nil
    local resting = {}
    if type(members) ~= "table" then return resting end

    for _, uuid in ipairs(members) do
        local registry = roster.Souls and roster.Souls[uuid] or nil
        local soul = getSoulData(uuid) or registry
        if soul
            and soul.status == "Resting"
            and soul.status ~= "Dead"
            and not tonumber(soul.deathFinalizedAt) then
            resting[#resting + 1] = {
                uuid = uuid,
                soul = soul,
            }
        end
    end

    return resting
end

local function pickRaidMembers(factionID, maxCap, percent)
    local resting = Raid.getRestingFactionMembers(factionID)
    if #resting <= 0 then return {} end

    for i = #resting, 2, -1 do
        local j = ZombRand(i) + 1
        resting[i], resting[j] = resting[j], resting[i]
    end

    local count = math.ceil(#resting * (Shared.clampPercent(percent, 50) / 100))
    count = math.max(1, math.min(#resting, Shared.clampDifficulty(maxCap), count))

    local selected = {}
    for i = 1, count do
        selected[#selected + 1] = resting[i]
    end
    return selected
end

local function markSoulForRaid(uuid, npcData)
    if not uuid or not npcData or not DynamicTrading_Roster then return end
    if tostring(npcData.status or "") == "Dead" or tonumber(npcData.deathFinalizedAt) then
        return
    end
    if DynamicTrading_Roster.UpdateSoulStatus then
        DynamicTrading_Roster.UpdateSoulStatus(uuid, "Working", 0, nil)
    end
    if DynamicTrading_Roster.SaveSoul then
        DynamicTrading_Roster.SaveSoul(uuid, npcData)
    end
end

local function restoreSoulAfterFailedRaid(uuid, npcData)
    if not uuid or not npcData or not DynamicTrading_Roster then return end
    if tostring(npcData.status or "") == "Dead" or tonumber(npcData.deathFinalizedAt) then
        return
    end
    npcData.status = "Resting"
    npcData.state = "Idle"
    npcData.isHostile = false
    npcData.isBandit = Shared.isBanditFactionID(npcData.factionID) and npcData.isBandit or nil
    npcData.banditGroupID = nil
    npcData.banditRole = nil
    npcData.banditTargetUsername = nil
    npcData.banditTargetOnlineID = nil
    npcData.banditDemandResolved = nil
    npcData.master = nil
    npcData.masterID = nil
    npcData.tasks = {}
    DynamicTrading_Roster.SaveSoul(uuid, npcData)
end

function Raid.returnRaidSoulToResting(uuid, npcData)
    if not uuid or not npcData or not DynamicTrading_Roster then return end
    if tostring(npcData.status or "") == "Dead" or tonumber(npcData.deathFinalizedAt) then
        return
    end
    npcData.status = "Resting"
    npcData.state = "Idle"
    npcData.returnTime = 0
    npcData.returnStatus = nil
    npcData.requestedReturnStatus = nil
    npcData.master = nil
    npcData.masterID = nil
    npcData.tasks = {}
    npcData.isHostile = false
    npcData.banditGroupID = nil
    npcData.banditRole = nil
    npcData.banditTargetUsername = nil
    npcData.banditTargetOnlineID = nil
    npcData.banditDemandStarted = nil
    npcData.banditDemandStartedAt = nil
    npcData.banditDemandResolved = nil
    npcData.banditLeaving = nil
    npcData.raidHostileFaction = nil
    if DynamicTrading_Roster.UpdateSoulStatus then
        DynamicTrading_Roster.UpdateSoulStatus(uuid, "Resting", 0, nil)
    end
    DynamicTrading_Roster.SaveSoul(uuid, npcData)
end

local function createRaidDataFromSoul(player, groupID, factionID, raidMember, difficulty, index, square, robbery)
    local uuid = raidMember and raidMember.uuid or nil
    local gen = raidMember and raidMember.soul or nil
    if not uuid or not gen then return nil end
    if tostring(gen.status or "") == "Dead" or tonumber(gen.deathFinalizedAt) then
        return nil
    end

    gen.uuid = uuid
    gen.factionID = factionID
    gen.archetypeID = gen.archetypeID or (robbery and "Bandit" or "General")
    gen.occupation = gen.occupation or gen.archetypeID
    gen.status = "Working"
    gen.state = "Follow"
    gen.master = Shared.getUsername(player)
    gen.masterID = Shared.getOnlineID(player)
    gen.tasks = {}
    gen.isPlayerFactionTrader = false
    gen.isBandit = robbery == true or gen.archetypeID == "Bandit" or Shared.isBanditFactionID(factionID)
    gen.banditFactionHostile = Shared.isBanditFactionID(factionID)
    gen.banditGroupID = groupID
    gen.banditRole = index == 1 and "leader" or "raider"
    gen.banditDifficulty = difficulty
    gen.banditTargetUsername = Shared.getUsername(player)
    gen.banditTargetOnlineID = Shared.getOnlineID(player)
    gen.banditSpawnedAt = Shared.nowMillis()
    gen.banditDemandResolved = false
    gen.raidFactionID = factionID
    gen.raidFactionName = getFactionDisplayName(factionID)
    gen.raidHostileFaction = true
    gen.lastX = square:getX()
    gen.lastY = square:getY()
    gen.lastZ = square:getZ()
    gen.returnTime = 0
    gen.returnStatus = nil
    gen.requestedReturnStatus = nil
    gen.isHostile = false

    return gen
end

local function createGeneratedBanditData(player, groupID, difficulty, index, square)
    local gen = DTNPCGenerator and DTNPCGenerator.CreateStandardData
        and DTNPCGenerator.CreateStandardData({
            occupation = "Bandit",
            masterName = Shared.getUsername(player),
            masterID = Shared.getOnlineID(player),
        })
        or DTNPCGenerator.Generate({
            occupation = "Bandit",
            masterName = Shared.getUsername(player),
            masterID = Shared.getOnlineID(player),
        })

    local name = gen.name or ("Bandit " .. tostring(index))
    gen.name = "Bandit " .. tostring(index) .. " - " .. name
    gen.uuid = DTNPCManager and DTNPCManager.GenerateSoulID and DTNPCManager.GenerateSoulID(gen.name) or (groupID .. "_" .. tostring(index))
    gen.archetypeID = "Bandit"
    gen.occupation = "Bandit"
    gen.factionID = Bandits.FACTION_ID
    gen.homeCoords = nil
    gen.status = "Working"
    gen.state = "Follow"
    gen.master = Shared.getUsername(player)
    gen.masterID = Shared.getOnlineID(player)
    gen.tasks = {}
    gen.isBandit = true
    gen.isPlayerFactionTrader = false
    gen.banditFactionHostile = true
    gen.banditGroupID = groupID
    gen.banditRole = index == 1 and "leader" or "raider"
    gen.banditDifficulty = difficulty
    gen.banditTargetUsername = Shared.getUsername(player)
    gen.banditTargetOnlineID = Shared.getOnlineID(player)
    gen.banditSpawnedAt = Shared.nowMillis()
    gen.lastX = square:getX()
    gen.lastY = square:getY()
    gen.lastZ = square:getZ()
    gen.returnTime = 0
    gen.returnStatus = nil
    gen.requestedReturnStatus = nil
    gen.isHostile = false
    return gen
end

function Bandits.SpawnAmbushForPlayer(player, options)
    if not Shared.isCurrencyExpandedActive() then
        if options and options.debug == true then
            Shared.sendBanditCommand(player, "BanditDebugNotice", {
                message = "Bandit raids require CurrencyExpanded.",
            })
        end
        return false
    end
    if not player or player:isDead() then return false end
    options = type(options) == "table" and options or {}
    local sandbox = Shared.getSandbox()
    local difficulty = Shared.clampDifficulty(options.difficulty or sandbox.BanditAmbushDifficulty)
    local partyPercent = Shared.clampPercent(options.partyPercent or sandbox.BanditRaidPartyPercent, 50)
    local factionID = options.factionID and tostring(options.factionID) or Bandits.FACTION_ID
    local robbery = Shared.isBanditFactionID(factionID)
    local faction = Faction.getFactionData(factionID)

    if robbery then
        Bandits.EnsureBanditFaction(true)
    elseif not Faction.isFactionHostileToPlayer(factionID, faction, player) then
        if options.debug == true then
            Shared.sendBanditCommand(player, "BanditDebugNotice", {
                message = tostring(getFactionDisplayName(factionID)) .. " is not angry enough to raid you.",
            })
        end
        return false
    end

    local selectedMembers = pickRaidMembers(factionID, difficulty, partyPercent)

    if #selectedMembers <= 0 then
        DynamicTrading.Log(
            "DTV2",
            "Bandits",
            "Raid",
            "No resting raid members available for faction " .. tostring(factionID)
        )
        return false
    end

    local groupID = generateGroupID(player, factionID)
    local group = {
        id = groupID,
        factionID = factionID,
        factionName = getFactionDisplayName(factionID),
        difficulty = difficulty,
        partyPercent = partyPercent,
        robbery = robbery,
        targetUsername = Shared.getUsername(player),
        targetOnlineID = Shared.getOnlineID(player),
        members = {},
        status = "active",
        spawnedAt = Shared.nowMillis(),
    }

    for i, raidMember in ipairs(selectedMembers) do
        local square = Shared.findSafeAmbushSquare(player, i)
        if not square then
            DynamicTrading.Log("DTV2", "Bandits", "Warn", "No safe bandit ambush square for " .. tostring(Shared.getUsername(player)))
            for _, uuid in ipairs(group.members) do
                Shared.removeBandit(uuid, "BanditSpawnRollback")
                local failedSoul = getSoulData(uuid)
                if failedSoul then restoreSoulAfterFailedRaid(uuid, failedSoul) end
            end
            return false
        end

        local npcData = createRaidDataFromSoul(player, groupID, factionID, raidMember, difficulty, i, square, robbery)
        if not npcData and robbery then
            npcData = createGeneratedBanditData(player, groupID, difficulty, i, square)
        end
        if not npcData then
            for _, uuid in ipairs(group.members) do
                Shared.removeBandit(uuid, "RaidSpawnRollback")
                local failedSoul = getSoulData(uuid)
                if failedSoul then restoreSoulAfterFailedRaid(uuid, failedSoul) end
            end
            return false
        end

        markSoulForRaid(npcData.uuid, npcData)
        local spawned = false
        if DTNPCServerCore and DTNPCServerCore.ActivateArrivalByUUID then
            spawned = DTNPCServerCore.ActivateArrivalByUUID(npcData.uuid, {
                controller = player,
                targetPlayer = player,
                targetUsername = Shared.getUsername(player),
                targetOnlineID = Shared.getOnlineID(player),
                targetX = square:getX(),
                targetY = square:getY(),
                targetZ = square:getZ(),
                spawnPolicy = "site_anchor",
                activationMode = "bandit_demand",
                state = npcData.state or "Follow",
                status = npcData.status or "Working",
                returnTime = 0,
                returnStatus = nil,
                requestedReturnStatus = nil,
            })
        else
            spawned = DTNPCServerCore and DTNPCServerCore.RespawnNPC and DTNPCServerCore.RespawnNPC(npcData, npcData.uuid) ~= nil or false
        end
        if spawned then
            group.members[#group.members + 1] = npcData.uuid
        else
            restoreSoulAfterFailedRaid(npcData.uuid, npcData)
        end
    end

    if #group.members <= 0 then return false end

    Bandits.Groups[groupID] = group
    Bandits.LastRandomAmbushHour = Shared.worldHours()
    DynamicTrading.Log("DTV2", "Bandits", "Spawn", "Spawned bandit ambush group " .. groupID .. " size=" .. tostring(#group.members))
    return true, groupID
end

local function playerAlreadyTargeted(player)
    local username = Shared.getUsername(player)
    local onlineID = Shared.getOnlineID(player)
    for _, npcData in pairs(DTNPCManager and DTNPCManager.Data or {}) do
        if npcData
            and (npcData.isBandit == true or npcData.raidHostileFaction == true or npcData.banditGroupID ~= nil)
            and (npcData.banditDemandResolved ~= true or npcData.raidHostileFaction == true or npcData.isHostile == true)
            and npcData.status ~= "Dead" then
            if (onlineID ~= nil and tonumber(npcData.banditTargetOnlineID) == tonumber(onlineID))
                or (username and tostring(npcData.banditTargetUsername) == tostring(username)) then
                return true
            end
        end
    end
    return false
end

function Raid.pickHostileRaidFactionForPlayer(player, maxCap, partyPercent, includeBandits)
    if not Shared.isCurrencyExpandedActive() then return nil end
    Bandits.EnsureBanditFaction(false)
    local candidates = {}
    for _, factionID in ipairs(Faction.getHostileFactionIDsForPlayer(player)) do
        local resting = Raid.getRestingFactionMembers(factionID)
        if #resting > 0 and (includeBandits ~= false or not Shared.isBanditFactionID(factionID)) then
            candidates[#candidates + 1] = factionID
        end
    end

    if #candidates <= 0 then return nil end
    return candidates[ZombRand(#candidates) + 1]
end

local function tryRandomAmbush()
    if not Shared.isCurrencyExpandedActive() then return end
    local sandbox = Shared.getSandbox()
    if sandbox.EnableBanditAmbushes == false then return end

    local currentHour = Shared.worldHours()
    if currentHour - Bandits.LastRandomCheckHour < Constants.RANDOM_CHECK_INTERVAL_HOURS then return end
    Bandits.LastRandomCheckHour = currentHour

    local cooldown = tonumber(sandbox.BanditAmbushCooldownHours) or 72
    if currentHour - Bandits.LastRandomAmbushHour < cooldown then return end

    local chance = tonumber(sandbox.BanditAmbushChance) or 3
    if not Shared.randomChancePercent(chance) then return end

    local candidates = {}
    for _, player in ipairs(Shared.getActivePlayers()) do
        if player and not player:isDead() and not playerAlreadyTargeted(player) then
            candidates[#candidates + 1] = player
        end
    end
    if #candidates <= 0 then return end

    local player = candidates[ZombRand(#candidates) + 1]
    local difficulty = Shared.clampDifficulty(sandbox.BanditAmbushDifficulty)
    local partyPercent = Shared.clampPercent(sandbox.BanditRaidPartyPercent, 50)
    local factionID = Raid.pickHostileRaidFactionForPlayer(player, difficulty, partyPercent, true)
    if not factionID then return end

    Bandits.SpawnAmbushForPlayer(player, {
        difficulty = difficulty,
        partyPercent = partyPercent,
        factionID = factionID,
    })
end

local function processDemandTimeouts()
    if not Shared.isCurrencyExpandedActive() then return end
    local current = Shared.nowMillis()
    for groupID, group in pairs(Bandits.Groups or {}) do
        if group and group.status == "demanding" and group.demand and group.demand.resolved ~= true then
            local startedAt = tonumber(group.demand.startedAt) or 0
            if startedAt > 0 and current - startedAt >= Constants.DEMAND_TIMEOUT_MS then
                Bandits.MakeGroupHostile(groupID, nil, "timeout")
            end
        elseif group and (group.status == "paid" or group.status == "empty") then
            if tonumber(group.cleanupAt) and current >= tonumber(group.cleanupAt) then
                if group.tradeCycleEncounter == true then
                    Bandits.Groups[groupID] = nil
                else
                    for _, member in ipairs(Shared.getGroupMembers(group)) do
                        Raid.returnRaidSoulToResting(member.uuid, member.npcData)
                        Shared.removeBandit(member.uuid, "BanditPaidCleanup")
                    end
                    Bandits.Groups[groupID] = nil
                end
            end
        elseif group and group.tradeCycleEncounter == true then
            local members = Shared.getGroupMembers(group)
            if #members <= 0 then
                Bandits.Groups[groupID] = nil
            else
                local allDeparted = true
                for _, member in ipairs(members) do
                    local npcData = member.npcData
                    if npcData
                        and tostring(npcData.status or "") ~= "Dead"
                        and npcData.banditLeaving ~= true
                        and tostring(npcData.state or "") ~= "Flee"
                        and tostring(npcData.status or "") ~= "Away" then
                        allDeparted = false
                        break
                    end
                end
                if allDeparted then
                    Bandits.Groups[groupID] = nil
                end
            end
        end
    end
end

local function getNearestPlayerToNPC(npcData)
    local bestPlayer = nil
    local bestDist = nil
    local zombie = npcData and npcData.uuid and DTNPCServerCore and DTNPCServerCore.FindZombieByUUID
        and DTNPCServerCore.FindZombieByUUID(npcData.uuid) or nil

    for _, player in ipairs(Shared.getActivePlayers()) do
        if player and not player:isDead() then
            local dx = 0
            local dy = 0
            if zombie then
                dx = player:getX() - zombie:getX()
                dy = player:getY() - zombie:getY()
            elseif npcData.lastX and npcData.lastY then
                dx = player:getX() - npcData.lastX
                dy = player:getY() - npcData.lastY
            end
            local dist = (dx * dx) + (dy * dy)
            if not bestDist or dist < bestDist then
                bestDist = dist
                bestPlayer = player
            end
        end
    end

    return bestPlayer, bestDist
end

local function processHostileFactionAggro()
    if not Shared.isCurrencyExpandedActive() then return end
    for uuid, npcData in pairs(DTNPCManager and DTNPCManager.Data or {}) do
        local player, bestDist = getNearestPlayerToNPC(npcData)
        local faction = npcData and Faction.getFactionData(npcData.factionID) or nil
        if npcData and npcData.banditRoamActive == true then
            if npcData.status ~= "Dead"
                and npcData.incapState ~= "Active"
                and npcData.banditLeaving ~= true
                and player then
                local radius = tonumber(npcData.banditRoamAggroRadius) or Constants.TRADE_CYCLE_AGGRO_RADIUS
                local shouldAggro = bestDist ~= nil and bestDist <= (radius * radius)
                if shouldAggro then
                    local group = Bandits.EnsureBanditHouseRoamEncounterGroup
                        and Bandits.EnsureBanditHouseRoamEncounterGroup(player, uuid, npcData, {
                            difficulty = npcData.banditDifficulty,
                        })
                        or nil
                    if group and npcData.isHostile ~= true then
                        Bandits.MakeGroupHostile(group.id, player, "bandit_roam_proximity")
                    end
                end
            end
        elseif npcData and npcData.tradeCycleMode ~= nil then
            if npcData.status ~= "Dead"
                and npcData.incapState ~= "Active"
                and npcData.banditLeaving ~= true
                and player then
                local radius = tonumber(npcData.tradeCycleAggroRadius) or Constants.TRADE_CYCLE_AGGRO_RADIUS
                local shouldAggro = bestDist ~= nil and bestDist <= (radius * radius)
                if shouldAggro and DTNPCManager and DTNPCManager.ResolveScheduledTradeCycleMode then
                    local mode = DTNPCManager.ResolveScheduledTradeCycleMode(npcData, player)
                    if mode == "robbery" or mode == "hostile_bribe" then
                        local group = Bandits.EnsureTradeCycleEncounterGroup(player, uuid, npcData, {
                            mode = mode,
                            difficulty = npcData.banditDifficulty,
                        })
                        if group and npcData.isHostile ~= true then
                            Bandits.MakeGroupHostile(group.id, player, mode == "robbery" and "robbery_proximity" or "hostile_faction")
                        end
                    end
                end
            end
        elseif npcData
            and faction
            and Faction.isFactionHostileToPlayer(npcData.factionID, faction, player)
            and npcData.status ~= "Dead"
            and npcData.incapState ~= "Active"
            and not (npcData.banditGroupID ~= nil and npcData.banditDemandResolved ~= true) then
            npcData.isBandit = npcData.isBandit == true or Shared.isBanditFactionID(npcData.factionID) or npcData.archetypeID == "Bandit"
            npcData.banditFactionHostile = Shared.isBanditFactionID(npcData.factionID)
            npcData.raidHostileFaction = true
            if npcData.isHostile ~= true and npcData.banditLeaving ~= true and player then
                Demand.makeNPCDataHostile(uuid, npcData, player, "hostile_faction")
            end
        end
    end
end

local function processFactionMaintenance()
    if not Shared.isCurrencyExpandedActive() then return end
    local currentHour = Shared.worldHours()
    if currentHour - (Bandits.LastFactionMaintenanceHour or -99999) < Constants.FACTION_MAINTENANCE_INTERVAL_HOURS then
        return
    end

    Bandits.LastFactionMaintenanceHour = currentHour
    Bandits.EnsureBanditFaction(true)

    local removed = 0
    local refilled = 0
    if Faction.PruneDeadNonPlayerSouls then
        removed = Faction.PruneDeadNonPlayerSouls() or 0
    end
    if Faction.RefillHostileRaidPools then
        refilled = Faction.RefillHostileRaidPools() or 0
    end

    if removed > 0 or refilled > 0 then
        if ModData.transmit then
            ModData.transmit("DynamicTrading_Roster")
            ModData.transmit("DynamicTrading_Factions")
        end
        DynamicTrading.Log(
            "DTV2",
            "Bandits",
            "Maintenance",
            "Hostile faction maintenance complete removed=" .. tostring(removed) .. " refilled=" .. tostring(refilled)
        )
    end
end

function Raid.onTick()
    Bandits.TickCounter = (Bandits.TickCounter or 0) + 1
    if Bandits.TickCounter % 60 ~= 0 then return end
    if not Shared.isCurrencyExpandedActive() then return end
    Bandits.EnsureBanditFaction(false)
    processFactionMaintenance()
    processDemandTimeouts()
    processHostileFactionAggro()
    tryRandomAmbush()
end
