-- ==============================================================================
-- DTNPC_Bandits_Server.lua
-- No-base bandit ambush spawning, robbery demands, timeout, and group hostility.
-- ==============================================================================

DTNPCBandits = DTNPCBandits or {}

if isClient() and not isServer() then return end

require "DT/V2/NPC/Sys/DTNPC_Generator"
require "DT/V2/NPC/Sys/DTNPC_Protect"
require "DT/V2/NPC/Sys/Data/DTNPC_Data"
pcall(require, "DT/Common/ServerHelpers/ServerHelpers")

local Bandits = DTNPCBandits

Bandits.FACTION_ID = Bandits.FACTION_ID or "Bandits"
Bandits.Groups = Bandits.Groups or {}
Bandits.LastRandomCheckHour = Bandits.LastRandomCheckHour or 0
Bandits.LastRandomAmbushHour = Bandits.LastRandomAmbushHour or -99999
Bandits.LastFactionEnsureHour = Bandits.LastFactionEnsureHour or -99999
Bandits.TickCounter = Bandits.TickCounter or 0

local BANDIT_FACTION_ID = Bandits.FACTION_ID
local DEMAND_TIMEOUT_MS = 120000
local PAID_CLEANUP_MS = 15000
local RANDOM_CHECK_INTERVAL_HOURS = 0.25
local SPAWN_RADIUS_MIN = 12
local SPAWN_RADIUS_MAX = 22
local BANDIT_MIN_ROSTER = 6
local BANDIT_FACTION_ENSURE_INTERVAL_HOURS = 1

local function nowMillis()
    return getTimeInMillis and getTimeInMillis() or math.floor((os.time() or 0) * 1000)
end

local function worldHours()
    local gt = getGameTime and getGameTime() or nil
    return gt and gt:getWorldAgeHours() or 0
end

local function clampDifficulty(value)
    local difficulty = math.floor(tonumber(value) or 2)
    if difficulty < 1 then difficulty = 1 end
    if difficulty > 5 then difficulty = 5 end
    return difficulty
end

local function getSandbox()
    return SandboxVars and SandboxVars.DynamicTrading or {}
end

local function randomChancePercent(chance)
    chance = tonumber(chance) or 0
    if chance <= 0 then return false end
    if chance >= 100 then return true end
    return ZombRand(10000) < math.floor(chance * 100)
end

local function getOnlineID(player)
    return player and player.getOnlineID and player:getOnlineID() or nil
end

local function getUsername(player)
    return player and player.getUsername and player:getUsername() or nil
end

local function matchesPlayer(npcData, player)
    if not npcData or not player then return false end
    local playerID = getOnlineID(player)
    local username = getUsername(player)
    if playerID ~= nil and npcData.banditTargetOnlineID ~= nil and tonumber(npcData.banditTargetOnlineID) == tonumber(playerID) then
        return true
    end
    if username and npcData.banditTargetUsername and tostring(npcData.banditTargetUsername) == tostring(username) then
        return true
    end
    return false
end

local function playerMatchesGroup(player, group)
    if not player or not group then return false end
    local playerID = getOnlineID(player)
    local username = getUsername(player)
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

local function getActivePlayers()
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

local function findPlayerByIdentity(username, onlineID)
    for _, player in ipairs(getActivePlayers()) do
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

local function isSafeSquare(square)
    return square ~= nil and square:isFree(false) and not square:isSolid() and not square:isSolidTrans()
end

local function findSafeAmbushSquare(player, index)
    if not player or not getCell then return nil end

    local cell = getCell()
    local px, py, pz = player:getX(), player:getY(), player:getZ()
    local baseAngle = ZombRandFloat and ZombRandFloat(0, math.pi * 2) or ((ZombRand(628) / 100) % (math.pi * 2))
    baseAngle = baseAngle + ((index or 1) - 1) * 0.75

    for radius = SPAWN_RADIUS_MIN, SPAWN_RADIUS_MAX do
        for attempt = 0, 11 do
            local angle = baseAngle + (attempt * ((math.pi * 2) / 12))
            local x = math.floor(px + math.cos(angle) * radius)
            local y = math.floor(py + math.sin(angle) * radius)
            local square = cell:getGridSquare(x, y, pz)
            if isSafeSquare(square) then
                return square
            end
        end
    end

    return nil
end

local function getGroup(groupID)
    if not groupID then return nil end
    groupID = tostring(groupID)
    local group = Bandits.Groups[groupID]
    if group then return group end

    local members = {}
    local targetUsername, targetOnlineID
    for uuid, npcData in pairs(DTNPCManager and DTNPCManager.Data or {}) do
        if npcData and npcData.isBandit == true and tostring(npcData.banditGroupID or "") == groupID then
            members[#members + 1] = uuid
            targetUsername = targetUsername or npcData.banditTargetUsername
            targetOnlineID = targetOnlineID or npcData.banditTargetOnlineID
        end
    end

    if #members <= 0 then return nil end

    group = {
        id = groupID,
        members = members,
        targetUsername = targetUsername,
        targetOnlineID = targetOnlineID,
        status = "active",
    }
    Bandits.Groups[groupID] = group
    return group
end

local function getGroupMembers(group)
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
        if npcData and npcData.isBandit == true and tostring(npcData.banditGroupID or "") == tostring(group.id or "") and not seen[uuid] then
            members[#members + 1] = { uuid = uuid, npcData = npcData }
            seen[uuid] = true
            group.members = group.members or {}
            group.members[#group.members + 1] = uuid
        end
    end

    return members
end

local function syncNPC(uuid, npcData)
    if not uuid or not npcData or not DTNPCServerCore then return end
    local zombie = DTNPCServerCore.FindZombieByUUID and DTNPCServerCore.FindZombieByUUID(uuid) or nil
    if zombie and DTNPCServerCore.SyncToAllClients then
        DTNPC.AttachData(zombie, npcData)
        DTNPCServerCore.SyncToAllClients(zombie, npcData)
        DTNPCServerCore.BroadcastPosition(zombie, npcData)
    end
end

local function sendBanditCommand(player, command, args)
    if not player then return end
    if DynamicTrading and DynamicTrading.ServerHelpers and DynamicTrading.ServerHelpers.SendResponse then
        DynamicTrading.ServerHelpers.SendResponse(player, "DTNPC", command, args or {})
    else
        sendServerCommand(player, "DTNPC", command, args or {})
    end
end

local function isBanditFactionID(factionID)
    return tostring(factionID or "") == BANDIT_FACTION_ID
end

function Bandits.IsBanditFaction(factionID)
    return isBanditFactionID(factionID)
end

local function ensureFactionModData()
    if not ModData.exists("DynamicTrading_Factions") then
        ModData.add("DynamicTrading_Factions", {})
    end
    return ModData.get("DynamicTrading_Factions")
end

local function ensureRosterModData()
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
    roster.FactionMembers[BANDIT_FACTION_ID] = roster.FactionMembers[BANDIT_FACTION_ID] or {}
    return roster
end

local function removeBandit(uuid, reason)
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

local function finishGroupAsLeaving(group, player, result)
    if not group then return end
    group.status = result or "paid"
    group.cleanupAt = nowMillis() + PAID_CLEANUP_MS

    for _, member in ipairs(getGroupMembers(group)) do
        local npcData = member.npcData
        npcData.banditDemandResolved = true
        npcData.banditLeaving = true
        npcData.isHostile = false
        npcData.state = "Flee"
        npcData.master = getUsername(player) or npcData.banditTargetUsername
        npcData.masterID = getOnlineID(player) or npcData.banditTargetOnlineID
        npcData.tasks = {}
        syncNPC(member.uuid, npcData)
    end
end

local function makeNPCDataHostile(uuid, npcData, player, reason)
    if not uuid or not npcData then return false end

    local zombie = DTNPCServerCore and DTNPCServerCore.FindZombieByUUID and DTNPCServerCore.FindZombieByUUID(uuid) or nil
    local dist = 9999
    if zombie and player then
        local dx = player:getX() - zombie:getX()
        local dy = player:getY() - zombie:getY()
        dist = math.sqrt((dx * dx) + (dy * dy))
    end

    local nextState = "Attack"
    if DTNPCProtect and DTNPCProtect.EnsureDataDefaults then
        DTNPCProtect.EnsureDataDefaults(npcData)
        if DTNPCProtect.ResolveHostileCombatState then
            nextState = DTNPCProtect.ResolveHostileCombatState(npcData, npcData.state, dist)
        end
    end

    local targetUsername = getUsername(player) or npcData.banditTargetUsername or npcData.master
    local targetOnlineID = getOnlineID(player) or npcData.banditTargetOnlineID or npcData.masterID

    npcData.state = nextState
    npcData.isHostile = true
    npcData.isBandit = true
    npcData.factionID = npcData.factionID or BANDIT_FACTION_ID
    npcData.banditHostileReason = tostring(reason or "bandit")
    npcData.master = targetUsername
    npcData.masterID = targetOnlineID
    npcData.lastPlayerAttackerUsername = targetUsername
    npcData.lastPlayerAttackerOnlineID = targetOnlineID
    npcData.lastPlayerAttackedAt = nowMillis()
    npcData.tasks = {}
    syncNPC(uuid, npcData)
    return true
end

function Bandits.MakeGroupHostile(groupID, player, reason)
    local group = getGroup(groupID)
    if not group then return false end

    player = player or findPlayerByIdentity(group.targetUsername, group.targetOnlineID)
    group.status = "hostile"
    group.hostileReason = tostring(reason or "unknown")
    group.demand = group.demand or {}
    group.demand.resolved = true

    local targetUsername = getUsername(player) or group.targetUsername
    local targetOnlineID = getOnlineID(player) or group.targetOnlineID

    for _, member in ipairs(getGroupMembers(group)) do
        member.npcData.banditDemandResolved = true
        member.npcData.banditTargetUsername = targetUsername
        member.npcData.banditTargetOnlineID = targetOnlineID
        makeNPCDataHostile(member.uuid, member.npcData, player, group.hostileReason)
    end

    if player then
        sendBanditCommand(player, "BanditDemandResolved", {
            groupID = group.id,
            result = "hostile",
            reason = group.hostileReason,
        })
    end

    DynamicTrading.Log("DTV2", "Bandits", "Hostile", "Bandit group " .. tostring(group.id) .. " hostile: " .. tostring(reason))
    return true
end

function Bandits.OnBanditDamagedByPlayer(npcData, attacker)
    if not npcData or npcData.isBandit ~= true then
        return false
    end
    if npcData.banditGroupID ~= nil then
        return Bandits.MakeGroupHostile(npcData.banditGroupID, attacker, "attacked")
    end
    if isBanditFactionID(npcData.factionID) and npcData.uuid then
        return makeNPCDataHostile(npcData.uuid, npcData, attacker, "attacked")
    end
    return false
end

local function isWornOrEquipped(player, item)
    if not player or not item then return false end
    if player.getPrimaryHandItem and player:getPrimaryHandItem() == item then return true end
    if player.getSecondaryHandItem and player:getSecondaryHandItem() == item then return true end

    local wornItems = player.getWornItems and player:getWornItems() or nil
    if wornItems then
        for i = 0, wornItems:size() - 1 do
            local worn = wornItems:get(i)
            if worn and worn.getItem and worn:getItem() == item then
                return true
            end
        end
    end

    return false
end

local function isEligibleRobberyItem(player, item)
    if not item then return false end
    local fullType = item.getFullType and item:getFullType() or ""
    if fullType == "" or fullType == "Base.Money" or fullType == "Base.MoneyBundle" then return false end
    if isWornOrEquipped(player, item) then return false end
    if item.isFavorite and item:isFavorite() then return false end
    if instanceof and instanceof(item, "Key") then return false end
    if item.getKeyId then
        local keyID = tonumber(item:getKeyId())
        if keyID and keyID >= 0 then return false end
    end
    if string.find(string.lower(fullType), "key", 1, true) then return false end
    return true
end

local function collectEligibleItemsFromContainer(player, container, out)
    if not container then return end
    local items = container:getItems()
    for i = 0, items:size() - 1 do
        local item = items:get(i)
        if isEligibleRobberyItem(player, item) then
            out[#out + 1] = item
        end
        if instanceof and instanceof(item, "InventoryContainer") then
            collectEligibleItemsFromContainer(player, item:getItemContainer(), out)
        end
    end
end

local function findItemByID(player, itemID)
    if not player or not itemID then return nil end
    local helpers = DynamicTrading and DynamicTrading.ServerHelpers or nil
    if helpers and helpers.FindItemByIDRecursive then
        return helpers.FindItemByIDRecursive(player:getInventory(), itemID)
    end
    return nil
end

local function buildMoneyDemand(player, difficulty)
    local helpers = DynamicTrading and DynamicTrading.ServerHelpers or nil
    local wealth = helpers and helpers.GetWealth and helpers.GetWealth(player) or 0
    wealth = math.floor(tonumber(wealth) or 0)
    if wealth <= 0 then return nil end

    local pct = 0.08 + (difficulty * 0.04)
    local upper = math.min(wealth, math.max(5 * difficulty, math.floor(wealth * pct)))
    local lower = math.min(upper, math.max(1, math.floor(upper * 0.5)))
    local amount = lower
    if upper > lower then
        amount = lower + ZombRand((upper - lower) + 1)
    end

    return {
        kind = "money",
        amount = math.max(1, math.min(wealth, amount)),
        displayName = "$" .. tostring(math.max(1, math.min(wealth, amount))),
    }
end

local function buildItemDemand(player)
    local candidates = {}
    collectEligibleItemsFromContainer(player, player and player:getInventory() or nil, candidates)
    if #candidates <= 0 then return nil end

    local item = candidates[ZombRand(#candidates) + 1]
    return {
        kind = "item",
        itemID = item.getID and item:getID() or nil,
        fullType = item.getFullType and item:getFullType() or nil,
        displayName = item.getDisplayName and item:getDisplayName() or tostring(item:getFullType()),
    }
end

local function buildDemand(player, difficulty)
    return buildMoneyDemand(player, difficulty) or buildItemDemand(player) or {
        kind = "none",
        displayName = "nothing",
    }
end

function Bandits.EnsureBanditFaction(force)
    local currentHour = worldHours()
    if force ~= true and currentHour - (Bandits.LastFactionEnsureHour or -99999) < BANDIT_FACTION_ENSURE_INTERVAL_HOURS then
        return
    end
    Bandits.LastFactionEnsureHour = currentHour

    local factions = ensureFactionModData()
    local faction = factions[BANDIT_FACTION_ID] or {}
    factions[BANDIT_FACTION_ID] = faction

    faction.id = BANDIT_FACTION_ID
    faction.name = faction.name or "Bandit Raiders"
    faction.town = faction.town or "Wilderness"
    faction.homeCoords = faction.homeCoords or {
        name = "Nomadic",
        town = "Wilderness",
        factionType = "bandit",
    }
    faction.stockpile = faction.stockpile or { food = 80, ammo = 80, meds = 25, fuel = 10, water = 80, materials = 20 }
    faction.state = "Hostile"
    faction.memberCount = math.max(tonumber(faction.memberCount) or 0, BANDIT_MIN_ROSTER)
    faction.ColonyWealth = math.max(tonumber(faction.ColonyWealth) or 0, 250)
    faction.factionType = "bandit"
    faction.isNomadic = true
    faction.hostileToPlayers = true
    faction.alwaysHostile = true
    faction.reputationDefault = -100
    faction.trickleActiveCount = tonumber(faction.trickleActiveCount) or 1
    faction.reputation = type(faction.reputation) == "table" and faction.reputation or {}

    for _, player in ipairs(getActivePlayers()) do
        local username = getUsername(player)
        if username then
            faction.reputation[username] = -100
        end
    end

    local roster = ensureRosterModData()
    local members = roster.FactionMembers[BANDIT_FACTION_ID]
    local existing = {}
    local aliveCount = 0
    for _, uuid in ipairs(members) do
        local soul = roster.Souls and roster.Souls[uuid] or nil
        if soul and soul.status ~= "Dead" then
            existing[uuid] = true
            aliveCount = aliveCount + 1
        end
    end

    while aliveCount < BANDIT_MIN_ROSTER and DynamicTrading_Roster and DynamicTrading_Roster.AddSoul do
        local uuid = DynamicTrading_Roster.AddSoul(BANDIT_FACTION_ID, "Bandit", {
            name = "Nomadic",
            town = "Wilderness",
            z = 0,
        }, { forceFaction = true, suppressRecruitLog = true })
        if not uuid then break end

        local soul = DynamicTrading_Roster.GetSoul and DynamicTrading_Roster.GetSoul(uuid) or nil
        if soul then
            soul.factionID = BANDIT_FACTION_ID
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
end

function Bandits.StartDemand(player, args)
    if not player or type(args) ~= "table" then return end
    local uuid = args.uuid and tostring(args.uuid) or nil
    local groupID = args.groupID and tostring(args.groupID) or nil
    if not uuid or not groupID then return end

    local npcData = DTNPCManager and DTNPCManager.Data and DTNPCManager.Data[uuid] or nil
    if not npcData or npcData.isBandit ~= true or tostring(npcData.banditGroupID or "") ~= groupID then return end
    if not matchesPlayer(npcData, player) then return end

    local group = getGroup(groupID)
    if not group then return end
    group.targetUsername = group.targetUsername or getUsername(player)
    group.targetOnlineID = group.targetOnlineID or getOnlineID(player)
    group.leaderUUID = group.leaderUUID or uuid
    group.difficulty = clampDifficulty(group.difficulty or npcData.banditDifficulty)

    if not group.demand or group.demand.resolved == true then
        group.demand = buildDemand(player, group.difficulty)
        group.demand.startedAt = nowMillis()
        group.demand.resolved = false
        group.status = "demanding"
    elseif not group.demand.startedAt then
        group.demand.startedAt = nowMillis()
    end

    for _, member in ipairs(getGroupMembers(group)) do
        member.npcData.banditDemandStarted = true
        member.npcData.banditDemandStartedAt = group.demand.startedAt
        syncNPC(member.uuid, member.npcData)
    end

    sendBanditCommand(player, "BanditDemand", {
        groupID = group.id,
        leaderUUID = uuid,
        kind = group.demand.kind,
        amount = group.demand.amount,
        itemID = group.demand.itemID,
        fullType = group.demand.fullType,
        displayName = group.demand.displayName,
        timeoutSeconds = math.floor(DEMAND_TIMEOUT_MS / 1000),
    })
end

function Bandits.PayDemand(player, args)
    if not player or type(args) ~= "table" then return end
    local group = getGroup(args.groupID)
    if not group or not group.demand or group.demand.resolved == true then return end
    if not playerMatchesGroup(player, group) then return end

    local demand = group.demand
    local paid = false

    if demand.kind == "money" then
        local helpers = DynamicTrading and DynamicTrading.ServerHelpers or nil
        paid = helpers and helpers.RemoveMoney and helpers.RemoveMoney(player, tonumber(demand.amount) or 0) == true
    elseif demand.kind == "item" then
        local item = findItemByID(player, demand.itemID)
        if item and isEligibleRobberyItem(player, item) then
            local helpers = DynamicTrading and DynamicTrading.ServerHelpers or nil
            if helpers and helpers.RemoveItem then
                helpers.RemoveItem(item)
                paid = true
            end
        end
    elseif demand.kind == "none" then
        paid = true
    end

    if not paid then
        Bandits.MakeGroupHostile(group.id, player, "payment_failed")
        return
    end

    demand.resolved = true
    finishGroupAsLeaving(group, player, demand.kind == "none" and "empty" or "paid")
    sendBanditCommand(player, "BanditDemandResolved", {
        groupID = group.id,
        result = demand.kind == "none" and "empty" or "paid",
        kind = demand.kind,
        displayName = demand.displayName,
    })
end

function Bandits.RefuseDemand(player, args)
    if not player or type(args) ~= "table" then return end
    local group = getGroup(args.groupID)
    if not group then return end
    if not playerMatchesGroup(player, group) then return end
    if group.status == "paid" or group.status == "empty" or group.status == "hostile" then return end
    Bandits.MakeGroupHostile(group.id, player, args.reason or "refused")
end

local function generateGroupID(player)
    return "Bandit_" .. tostring(getUsername(player) or "Player") .. "_" .. tostring(math.floor(worldHours() * 100)) .. "_" .. tostring(ZombRand(1000000))
end

local function createBanditData(player, groupID, difficulty, index, square)
    local gen = DTNPCGenerator and DTNPCGenerator.CreateStandardData
        and DTNPCGenerator.CreateStandardData({
            occupation = "Bandit",
            masterName = getUsername(player),
            masterID = getOnlineID(player),
        })
        or DTNPCGenerator.Generate({
            occupation = "Bandit",
            masterName = getUsername(player),
            masterID = getOnlineID(player),
        })

    local name = gen.name or ("Bandit " .. tostring(index))
    gen.name = "Bandit " .. tostring(index) .. " - " .. name
    gen.uuid = DTNPCManager and DTNPCManager.GenerateSoulID and DTNPCManager.GenerateSoulID(gen.name) or (groupID .. "_" .. tostring(index))
    gen.archetypeID = "Bandit"
    gen.occupation = "Bandit"
    gen.factionID = BANDIT_FACTION_ID
    gen.homeCoords = nil
    gen.status = "Working"
    gen.state = "Follow"
    gen.master = getUsername(player)
    gen.masterID = getOnlineID(player)
    gen.tasks = {}
    gen.isBandit = true
    gen.isPlayerFactionTrader = false
    gen.banditFactionHostile = true
    gen.banditGroupID = groupID
    gen.banditRole = index == 1 and "leader" or "raider"
    gen.banditDifficulty = difficulty
    gen.banditTargetUsername = getUsername(player)
    gen.banditTargetOnlineID = getOnlineID(player)
    gen.banditSpawnedAt = nowMillis()
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
    if not player or player:isDead() then return false end
    Bandits.EnsureBanditFaction(true)
    options = type(options) == "table" and options or {}
    local difficulty = clampDifficulty(options.difficulty or getSandbox().BanditAmbushDifficulty)
    local groupID = generateGroupID(player)
    local group = {
        id = groupID,
        difficulty = difficulty,
        targetUsername = getUsername(player),
        targetOnlineID = getOnlineID(player),
        members = {},
        status = "active",
        spawnedAt = nowMillis(),
    }

    for i = 1, difficulty do
        local square = findSafeAmbushSquare(player, i)
        if not square then
            DynamicTrading.Log("DTV2", "Bandits", "Warn", "No safe bandit ambush square for " .. tostring(getUsername(player)))
            for _, uuid in ipairs(group.members) do
                removeBandit(uuid, "BanditSpawnRollback")
            end
            return false
        end

        local npcData = createBanditData(player, groupID, difficulty, i, square)
        local zombie = DTNPCServerCore and DTNPCServerCore.RespawnNPC and DTNPCServerCore.RespawnNPC(npcData, npcData.uuid) or nil
        if zombie then
            group.members[#group.members + 1] = npcData.uuid
        end
    end

    if #group.members <= 0 then return false end

    Bandits.Groups[groupID] = group
    Bandits.LastRandomAmbushHour = worldHours()
    DynamicTrading.Log("DTV2", "Bandits", "Spawn", "Spawned bandit ambush group " .. groupID .. " size=" .. tostring(#group.members))
    return true, groupID
end

local function playerAlreadyTargeted(player)
    local username = getUsername(player)
    local onlineID = getOnlineID(player)
    for _, npcData in pairs(DTNPCManager and DTNPCManager.Data or {}) do
        if npcData and npcData.isBandit == true and npcData.banditDemandResolved ~= true and npcData.status ~= "Dead" then
            if (onlineID ~= nil and tonumber(npcData.banditTargetOnlineID) == tonumber(onlineID))
                or (username and tostring(npcData.banditTargetUsername) == tostring(username)) then
                return true
            end
        end
    end
    return false
end

local function tryRandomAmbush()
    local sandbox = getSandbox()
    if sandbox.EnableBanditAmbushes == false then return end

    local currentHour = worldHours()
    if currentHour - Bandits.LastRandomCheckHour < RANDOM_CHECK_INTERVAL_HOURS then return end
    Bandits.LastRandomCheckHour = currentHour

    local cooldown = tonumber(sandbox.BanditAmbushCooldownHours) or 72
    if currentHour - Bandits.LastRandomAmbushHour < cooldown then return end

    local chance = tonumber(sandbox.BanditAmbushChance) or 3
    if not randomChancePercent(chance) then return end

    local candidates = {}
    for _, player in ipairs(getActivePlayers()) do
        if player and not player:isDead() and not playerAlreadyTargeted(player) then
            candidates[#candidates + 1] = player
        end
    end
    if #candidates <= 0 then return end

    local player = candidates[ZombRand(#candidates) + 1]
    Bandits.SpawnAmbushForPlayer(player, { difficulty = sandbox.BanditAmbushDifficulty })
end

local function processDemandTimeouts()
    local current = nowMillis()
    for groupID, group in pairs(Bandits.Groups or {}) do
        if group and group.status == "demanding" and group.demand and group.demand.resolved ~= true then
            local startedAt = tonumber(group.demand.startedAt) or 0
            if startedAt > 0 and current - startedAt >= DEMAND_TIMEOUT_MS then
                Bandits.MakeGroupHostile(groupID, nil, "timeout")
            end
        elseif group and (group.status == "paid" or group.status == "empty") then
            if tonumber(group.cleanupAt) and current >= tonumber(group.cleanupAt) then
                for _, member in ipairs(getGroupMembers(group)) do
                    removeBandit(member.uuid, "BanditPaidCleanup")
                end
                Bandits.Groups[groupID] = nil
            end
        end
    end
end

local function getNearestPlayerToNPC(npcData)
    local bestPlayer = nil
    local bestDist = nil
    local zombie = npcData and npcData.uuid and DTNPCServerCore and DTNPCServerCore.FindZombieByUUID
        and DTNPCServerCore.FindZombieByUUID(npcData.uuid) or nil

    for _, player in ipairs(getActivePlayers()) do
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

    return bestPlayer
end

local function processBanditFactionAggro()
    for uuid, npcData in pairs(DTNPCManager and DTNPCManager.Data or {}) do
        if npcData
            and isBanditFactionID(npcData.factionID)
            and npcData.status ~= "Dead"
            and npcData.incapState ~= "Active"
            and not (npcData.banditGroupID ~= nil and npcData.banditDemandResolved ~= true) then
            npcData.isBandit = true
            npcData.banditFactionHostile = true
            if npcData.isHostile ~= true and npcData.banditLeaving ~= true then
                local player = getNearestPlayerToNPC(npcData)
                if player then
                    makeNPCDataHostile(uuid, npcData, player, "bandit_faction")
                end
            end
        end
    end
end

local function onTick()
    Bandits.TickCounter = (Bandits.TickCounter or 0) + 1
    if Bandits.TickCounter % 60 ~= 0 then return end
    Bandits.EnsureBanditFaction(false)
    processDemandTimeouts()
    processBanditFactionAggro()
    tryRandomAmbush()
end

local function canUseDebugCommand(player)
    if isDebugEnabled and isDebugEnabled() then return true end
    if not player or not player.getAccessLevel then return false end
    local access = tostring(player:getAccessLevel() or "")
    return access ~= "" and access ~= "None"
end

local function onClientCommand(module, command, player, args)
    if module ~= "DTNPC" then return end

    if command == "BanditDemandStarted" then
        Bandits.StartDemand(player, args)
    elseif command == "BanditDemandPay" then
        Bandits.PayDemand(player, args)
    elseif command == "BanditDemandRefuse" then
        Bandits.RefuseDemand(player, args)
    elseif command == "SpawnBanditAmbush" then
        if canUseDebugCommand(player) then
            Bandits.EnsureBanditFaction(true)
            Bandits.SpawnAmbushForPlayer(player, {
                difficulty = args and args.difficulty or nil,
                debug = true,
            })
        end
    end
end

if not Bandits.EventsRegistered then
    Events.OnTick.Add(onTick)
    Events.OnClientCommand.Add(onClientCommand)
    Bandits.EventsRegistered = true
end

DynamicTrading.Log("DTV2", "Init", "Bandits", "Bandit ambush server subsystem loaded")
