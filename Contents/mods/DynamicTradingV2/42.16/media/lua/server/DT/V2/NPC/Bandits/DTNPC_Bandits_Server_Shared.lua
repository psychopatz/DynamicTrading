-- ==============================================================================
-- DTNPC_Bandits_Server_Shared.lua
-- Server/shared state and low-level helpers for bandit encounters.
-- ==============================================================================

if isClient() and not isServer() then return end

require "DT/V2/NPC/Sys/DTNPC_Generator"
require "DT/V2/NPC/Sys/DTNPC_Protect"
require "DT/V2/NPC/Sys/Data/DTNPC_Data"
pcall(require, "DT/Common/ServerHelpers/ServerHelpers")

DTNPCBandits = DTNPCBandits or {}
DTNPCBandits.Internal = DTNPCBandits.Internal or {}

local Bandits = DTNPCBandits
local Internal = Bandits.Internal

Bandits.FACTION_ID = Bandits.FACTION_ID or "Bandits"
Bandits.Groups = Bandits.Groups or {}
Bandits.LastRandomCheckHour = Bandits.LastRandomCheckHour or 0
Bandits.LastRandomAmbushHour = Bandits.LastRandomAmbushHour or -99999
Bandits.LastFactionEnsureHour = Bandits.LastFactionEnsureHour or -99999
Bandits.TickCounter = Bandits.TickCounter or 0

Internal.Constants = Internal.Constants or {}
Internal.Shared = Internal.Shared or {}

local Constants = Internal.Constants
local Shared = Internal.Shared

Constants.DEMAND_TIMEOUT_MS = Constants.DEMAND_TIMEOUT_MS or 120000
Constants.PAID_CLEANUP_MS = Constants.PAID_CLEANUP_MS or 15000
Constants.RANDOM_CHECK_INTERVAL_HOURS = Constants.RANDOM_CHECK_INTERVAL_HOURS or 0.25
Constants.SPAWN_RADIUS_MIN = Constants.SPAWN_RADIUS_MIN or 12
Constants.SPAWN_RADIUS_MAX = Constants.SPAWN_RADIUS_MAX or 22
Constants.BANDIT_MIN_ROSTER = Constants.BANDIT_MIN_ROSTER or 6
Constants.BANDIT_FACTION_ENSURE_INTERVAL_HOURS = Constants.BANDIT_FACTION_ENSURE_INTERVAL_HOURS or 1
Constants.HOSTILE_REP_THRESHOLD = Constants.HOSTILE_REP_THRESHOLD or -40
Constants.TRADE_CYCLE_AGGRO_RADIUS = Constants.TRADE_CYCLE_AGGRO_RADIUS or 4.5
Constants.FACTION_MAINTENANCE_INTERVAL_HOURS = Constants.FACTION_MAINTENANCE_INTERVAL_HOURS or 24
Constants.HOSTILE_POOL_RECOVERY_DAYS = Constants.HOSTILE_POOL_RECOVERY_DAYS or 7

function Shared.isCurrencyExpandedActive()
    local activated = getActivatedMods and getActivatedMods() or nil
    return activated and activated.contains and activated:contains("CurrencyExpanded") or false
end

function Shared.nowMillis()
    return getTimeInMillis and getTimeInMillis() or math.floor((os.time() or 0) * 1000)
end

function Shared.worldHours()
    local gt = getGameTime and getGameTime() or nil
    return gt and gt:getWorldAgeHours() or 0
end

function Shared.clampDifficulty(value)
    local difficulty = math.floor(tonumber(value) or 2)
    if difficulty < 1 then difficulty = 1 end
    if difficulty > 5 then difficulty = 5 end
    return difficulty
end

function Shared.clampPercent(value, fallback)
    local percent = math.floor(tonumber(value) or fallback or 50)
    if percent < 1 then percent = 1 end
    if percent > 100 then percent = 100 end
    return percent
end

function Shared.getSandbox()
    return SandboxVars and SandboxVars.DynamicTrading or {}
end

function Shared.randomChancePercent(chance)
    chance = tonumber(chance) or 0
    if chance <= 0 then return false end
    if chance >= 100 then return true end
    return ZombRand(10000) < math.floor(chance * 100)
end

function Shared.getOnlineID(player)
    return player and player.getOnlineID and player:getOnlineID() or nil
end

function Shared.getUsername(player)
    return player and player.getUsername and player:getUsername() or nil
end

function Shared.matchesPlayer(npcData, player)
    if not npcData or not player then return false end
    local playerID = Shared.getOnlineID(player)
    local username = Shared.getUsername(player)
    if playerID ~= nil and npcData.banditTargetOnlineID ~= nil and tonumber(npcData.banditTargetOnlineID) == tonumber(playerID) then
        return true
    end
    if username and npcData.banditTargetUsername and tostring(npcData.banditTargetUsername) == tostring(username) then
        return true
    end
    return false
end

function Shared.matchesHostileNegotiationPlayer(npcData, player)
    if not npcData or not player then
        return false
    end

    if Shared.matchesPlayer(npcData, player) then
        return true
    end

    local playerID = Shared.getOnlineID(player)
    local username = Shared.getUsername(player)
    if playerID ~= nil and npcData.lastPlayerAttackerOnlineID ~= nil and tonumber(npcData.lastPlayerAttackerOnlineID) == tonumber(playerID) then
        return true
    end
    if username and npcData.lastPlayerAttackerUsername and tostring(npcData.lastPlayerAttackerUsername) == tostring(username) then
        return true
    end

    return false
end

function Shared.playerMatchesGroup(player, group)
    if not player or not group then return false end
    local playerID = Shared.getOnlineID(player)
    local username = Shared.getUsername(player)
    local hasIdentity = false

    if group.targetOnlineID ~= nil and playerID ~= nil then
        hasIdentity = true
        if tonumber(group.targetOnlineID) == tonumber(playerID) then
            return true
        end
    end
    if group.targetUsername and username then
        hasIdentity = true
        if tostring(group.targetUsername) == tostring(username) then
            return true
        end
    end

    return hasIdentity == false and group.targetOnlineID == nil and group.targetUsername == nil
end

function Shared.getActivePlayers()
    if DTNPCManager and DTNPCManager.GetActivePlayers then
        return DTNPCManager.GetActivePlayers()
    end

    local players = {}
    if getOnlinePlayers then
        local onlinePlayers = getOnlinePlayers()
        for i = 0, onlinePlayers:size() - 1 do
            local player = onlinePlayers:get(i)
            if player then players[#players + 1] = player end
        end
    else
        local player = getSpecificPlayer and getSpecificPlayer(0) or nil
        if player then players[#players + 1] = player end
    end
    return players
end

function Shared.findPlayerByIdentity(username, onlineID)
    for _, player in ipairs(Shared.getActivePlayers()) do
        if player and not player:isDead() then
            if onlineID ~= nil and player.getOnlineID and tonumber(player:getOnlineID()) == tonumber(onlineID) then
                return player
            end
            if username and player.getUsername and tostring(player:getUsername()) == tostring(username) then
                return player
            end
        end
    end
    return nil
end

function Shared.getFactionData(factionID)
    if not factionID then
        return nil
    end

    local factionAPI = Internal and Internal.Faction or nil
    if factionAPI and type(factionAPI.getFactionData) == "function" then
        local ok, result = pcall(factionAPI.getFactionData, factionID)
        if ok and type(result) == "table" then
            return result
        end
    end

    local factions = ModData and ModData.get and ModData.get("DynamicTrading_Factions") or nil
    return type(factions) == "table" and factions[factionID] or nil
end

function Shared.getFactionDisplayName(factionID)
    if not factionID then
        return nil
    end

    local factionAPI = Internal and Internal.Faction or nil
    if factionAPI and type(factionAPI.getFactionDisplayName) == "function" then
        local ok, result = pcall(factionAPI.getFactionDisplayName, factionID)
        if ok and result ~= nil and tostring(result) ~= "" then
            return tostring(result)
        end
    end

    local faction = Shared.getFactionData(factionID)
    if type(faction) == "table" then
        local displayName = faction.name or faction.displayName
        if displayName ~= nil and tostring(displayName) ~= "" then
            return tostring(displayName)
        end
    end

    return tostring(factionID or "Unknown")
end

function Shared.isSafeSquare(square)
    return square ~= nil and square:isFree(false) and not square:isSolid() and not square:isSolidTrans()
end

function Shared.findSafeAmbushSquare(player, index)
    if not player or not getCell then return nil end

    local cell = getCell()
    local px, py, pz = player:getX(), player:getY(), player:getZ()
    local baseAngle = ZombRandFloat and ZombRandFloat(0, math.pi * 2) or ((ZombRand(628) / 100) % (math.pi * 2))
    baseAngle = baseAngle + ((index or 1) - 1) * 0.75

    for radius = Constants.SPAWN_RADIUS_MIN, Constants.SPAWN_RADIUS_MAX do
        for attempt = 0, 11 do
            local angle = baseAngle + (attempt * ((math.pi * 2) / 12))
            local x = math.floor(px + math.cos(angle) * radius)
            local y = math.floor(py + math.sin(angle) * radius)
            local square = cell:getGridSquare(x, y, pz)
            if Shared.isSafeSquare(square) then
                return square
            end
        end
    end

    return nil
end

function Shared.getGroup(groupID)
    if not groupID then return nil end
    groupID = tostring(groupID)
    local group = Bandits.Groups[groupID]
    if group then
        group.id = group.id or groupID
        group.members = type(group.members) == "table" and group.members or {}
        if not group.factionName and group.factionID then
            group.factionName = Shared.getFactionDisplayName(group.factionID)
        end
        return group
    end

    local members = {}
    local targetUsername, targetOnlineID
    local factionID, leaderUUID, banditDifficulty
    local hostileNegotiationOnly = false
    local tradeCycleEncounter = false
    local robbery = false
    local banditRoamEncounter = false
    local isBanditMember = false
    local isRaidHostileFaction = false
    local isHostileBribeMode = false
    for uuid, npcData in pairs(DTNPCManager and DTNPCManager.Data or {}) do
        if npcData
            and (tostring(npcData.banditGroupID or "") == groupID
                or tostring(npcData.hostileNegotiationGroupID or "") == groupID)
            and (npcData.isBandit == true or npcData.raidHostileFaction == true or npcData.banditGroupID ~= nil or npcData.hostileNegotiationGroupID ~= nil) then
            members[#members + 1] = uuid
            targetUsername = targetUsername or npcData.banditTargetUsername or npcData.lastPlayerAttackerUsername
            targetOnlineID = targetOnlineID or npcData.banditTargetOnlineID or npcData.lastPlayerAttackerOnlineID
            factionID = factionID or npcData.factionID
            leaderUUID = leaderUUID or tostring(uuid)
            banditDifficulty = banditDifficulty or npcData.banditDifficulty
            isBanditMember = isBanditMember or npcData.isBandit == true
            isRaidHostileFaction = isRaidHostileFaction or npcData.raidHostileFaction == true
            banditRoamEncounter = banditRoamEncounter or npcData.banditRoamActive == true
            if tostring(npcData.hostileNegotiationGroupID or "") == groupID then
                hostileNegotiationOnly = true
                tradeCycleEncounter = true
            end
            if tostring(npcData.banditGroupID or "") == groupID and npcData.banditRoamActive == true then
                tradeCycleEncounter = true
            end
            if npcData.tradeCycleDemandEligible == true or npcData.tradeCycleMode ~= nil then
                tradeCycleEncounter = true
            end
            if tostring(npcData.tradeCycleMode or "") == "robbery" then
                robbery = true
            elseif tostring(npcData.tradeCycleMode or "") == "hostile_bribe" then
                isHostileBribeMode = true
            end
        end
    end

    if #members <= 0 then return nil end

    local resolveBehavior = nil
    if hostileNegotiationOnly then
        local isBanditFaction = Shared.isBanditFactionID(factionID) or isBanditMember == true
        resolveBehavior = (isBanditFaction or isRaidHostileFaction or isHostileBribeMode or robbery) and "leave" or "return_trading"
    elseif banditRoamEncounter then
        resolveBehavior = "leave"
    end

    if not factionID and isBanditMember then
        factionID = Bandits.FACTION_ID
    end

    group = {
        id = groupID,
        members = members,
        factionID = factionID,
        factionName = Shared.getFactionDisplayName(factionID),
        difficulty = Shared.clampDifficulty(banditDifficulty or 2),
        robbery = robbery,
        tradeCycleEncounter = tradeCycleEncounter,
        hostileNegotiationOnly = hostileNegotiationOnly,
        banditRoamEncounter = banditRoamEncounter,
        targetUsername = targetUsername,
        targetOnlineID = targetOnlineID,
        leaderUUID = leaderUUID,
        resolveBehavior = resolveBehavior,
        status = "active",
    }
    Bandits.Groups[groupID] = group
    return group
end

function Shared.getGroupMembers(group)
    local members = {}
    if not group then return members end
    local seen = {}

    for _, uuid in ipairs(group.members or {}) do
        if uuid and not seen[uuid] then
            local npcData = DTNPCManager and DTNPCManager.Data and DTNPCManager.Data[uuid] or nil
            if npcData then
                members[#members + 1] = { uuid = uuid, npcData = npcData }
                seen[uuid] = true
            end
        end
    end

    for uuid, npcData in pairs(DTNPCManager and DTNPCManager.Data or {}) do
        if npcData
            and (tostring(npcData.banditGroupID or "") == tostring(group.id or "")
                or tostring(npcData.hostileNegotiationGroupID or "") == tostring(group.id or ""))
            and (npcData.isBandit == true or npcData.raidHostileFaction == true or npcData.banditGroupID ~= nil or npcData.hostileNegotiationGroupID ~= nil)
            and not seen[uuid] then
            members[#members + 1] = { uuid = uuid, npcData = npcData }
            seen[uuid] = true
            group.members = group.members or {}
            group.members[#group.members + 1] = uuid
        end
    end

    return members
end

function Shared.syncNPC(uuid, npcData)
    if not uuid or not npcData or not DTNPCServerCore then return end
    local zombie = DTNPCServerCore.FindZombieByUUID and DTNPCServerCore.FindZombieByUUID(uuid) or nil
    if zombie and DTNPCServerCore.SyncToAllClients then
        DTNPC.AttachData(zombie, npcData)
        DTNPCServerCore.SyncToAllClients(zombie, npcData)
        DTNPCServerCore.BroadcastPosition(zombie, npcData)
    end
end

function Shared.sendBanditCommand(player, command, args)
    if not player then return end
    if DynamicTrading and DynamicTrading.ServerHelpers and DynamicTrading.ServerHelpers.SendResponse then
        DynamicTrading.ServerHelpers.SendResponse(player, "DTNPC", command, args or {})
    else
        local payload = args or {}
        if DTNPCServerCore and DTNPCServerCore.SanitizeNetworkData then
            payload = DTNPCServerCore.SanitizeNetworkData(payload)
        end
        sendServerCommand(player, "DTNPC", command, payload)
    end
end

function Shared.isBanditFactionID(factionID)
    return tostring(factionID or "") == tostring(Bandits.FACTION_ID or "Bandits")
end

function Shared.removeBandit(uuid, reason)
    if not uuid then return end

    local zombie = DTNPCServerCore and DTNPCServerCore.FindZombieByUUID and DTNPCServerCore.FindZombieByUUID(uuid) or nil
    if DTNPCManager and DTNPCManager.RemoveData then
        DTNPCManager.RemoveData(uuid, nil, nil, nil, { reason = reason or "BanditCleanup", ephemeral = true })
    end
    if zombie then
        zombie:removeFromWorld()
        zombie:removeFromSquare()
    end
end

function Bandits.IsBanditFaction(factionID)
    return Shared.isBanditFactionID(factionID)
end
