-- ==============================================================================
-- DTNPC_Bandits_Server_Demand.lua
-- Demand construction and hostile-conversion flow for bandit groups.
-- ==============================================================================

if isClient() and not isServer() then return end

local Bandits = DTNPCBandits
Bandits.Internal = Bandits.Internal or {}
local Internal = Bandits.Internal
Internal.Constants = Internal.Constants or {}
Internal.Shared = Internal.Shared or {}
Internal.Faction = Internal.Faction or {}
local Constants = Internal.Constants
local Shared = Internal.Shared
local Faction = Internal.Faction

Internal.Demand = Internal.Demand or {}

local Demand = Internal.Demand

local function finishGroupAsLeaving(group, player, result)
    if not group then return end
    group.status = result or "paid"
    group.cleanupAt = Shared.nowMillis() + Constants.PAID_CLEANUP_MS

    for _, member in ipairs(Shared.getGroupMembers(group)) do
        local npcData = member.npcData
        npcData.banditDemandResolved = true
        npcData.banditLeaving = true
        npcData.isHostile = false
        npcData.state = "Flee"
        npcData.master = Shared.getUsername(player) or npcData.banditTargetUsername
        npcData.masterID = Shared.getOnlineID(player) or npcData.banditTargetOnlineID
        npcData.tasks = {}
        Shared.syncNPC(member.uuid, npcData)
    end
end

function Demand.makeNPCDataHostile(uuid, npcData, player, reason)
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

    local targetUsername = Shared.getUsername(player) or npcData.banditTargetUsername or npcData.master
    local targetOnlineID = Shared.getOnlineID(player) or npcData.banditTargetOnlineID or npcData.masterID

    npcData.state = nextState
    npcData.isHostile = true
    npcData.isBandit = npcData.isBandit == true
        or Shared.isBanditFactionID(npcData.factionID)
        or npcData.archetypeID == "Bandit"
    npcData.factionID = npcData.factionID or Bandits.FACTION_ID
    npcData.banditHostileReason = tostring(reason or "bandit")
    npcData.master = targetUsername
    npcData.masterID = targetOnlineID
    npcData.lastPlayerAttackerUsername = targetUsername
    npcData.lastPlayerAttackerOnlineID = targetOnlineID
    npcData.lastPlayerAttackedAt = Shared.nowMillis()
    npcData.tasks = {}
    Shared.syncNPC(uuid, npcData)
    return true
end

function Bandits.MakeGroupHostile(groupID, player, reason)
    local group = Shared.getGroup(groupID)
    if not group then return false end

    player = player or Shared.findPlayerByIdentity(group.targetUsername, group.targetOnlineID)
    group.status = "hostile"
    group.hostileReason = tostring(reason or "unknown")
    group.demand = group.demand or {}
    group.demand.resolved = true

    local targetUsername = Shared.getUsername(player) or group.targetUsername
    local targetOnlineID = Shared.getOnlineID(player) or group.targetOnlineID

    for _, member in ipairs(Shared.getGroupMembers(group)) do
        member.npcData.banditDemandResolved = true
        member.npcData.banditTargetUsername = targetUsername
        member.npcData.banditTargetOnlineID = targetOnlineID
        Demand.makeNPCDataHostile(member.uuid, member.npcData, player, group.hostileReason)
    end

    if player then
        Shared.sendBanditCommand(player, "BanditDemandResolved", {
            groupID = group.id,
            result = "hostile",
            reason = group.hostileReason,
        })
    end

    DynamicTrading.Log("DTV2", "Bandits", "Hostile", "Bandit group " .. tostring(group.id) .. " hostile: " .. tostring(reason))
    return true
end

function Bandits.OnBanditDamagedByPlayer(npcData, attacker)
    if not Shared.isCurrencyExpandedActive() then return false end
    if not npcData or (npcData.isBandit ~= true and npcData.banditGroupID == nil and npcData.raidHostileFaction ~= true) then
        return false
    end
    if npcData.banditGroupID ~= nil then
        return Bandits.MakeGroupHostile(npcData.banditGroupID, attacker, "attacked")
    end
    if Shared.isBanditFactionID(npcData.factionID) and npcData.uuid then
        return Demand.makeNPCDataHostile(npcData.uuid, npcData, attacker, "attacked")
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

function Demand.isEligibleRobberyItem(player, item)
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
        if Demand.isEligibleRobberyItem(player, item) then
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

local function getPlayerWealth(player)
    local helpers = DynamicTrading and DynamicTrading.ServerHelpers or nil
    local wealth = helpers and helpers.GetWealth and helpers.GetWealth(player) or 0
    return math.max(0, math.floor(tonumber(wealth) or 0))
end

local function buildTributeTier(amount, tier, repPerMember, rewardScope)
    amount = math.max(1, math.floor(tonumber(amount) or 0))
    return {
        tier = tostring(tier or "low"),
        amount = amount,
        displayName = "$" .. tostring(amount),
        repPerMember = math.max(0, math.floor(tonumber(repPerMember) or 0)),
        rewardScope = tostring(rewardScope or "none"),
    }
end

local function buildTributeDemand(player, difficulty, factionID)
    local wealth = getPlayerWealth(player)
    local baseWealth = math.max(wealth, 80)
    local lowAmount = math.max(10 * difficulty, math.floor(baseWealth * 0.06))
    local mediumAmount = math.max(lowAmount + (8 * difficulty), math.floor(baseWealth * 0.13))
    local highAmount = math.max(mediumAmount + (12 * difficulty), math.floor(baseWealth * 0.24))

    return {
        kind = "tribute",
        factionName = Faction.getFactionDisplayName(factionID),
        tiers = {
            buildTributeTier(lowAmount, "low", 0, "none"),
            buildTributeTier(mediumAmount, "medium", 5, "delegate"),
            buildTributeTier(highAmount, "high", 5, "party"),
        },
    }
end

local function buildMoneyDemand(player, difficulty)
    local wealth = getPlayerWealth(player)
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

local function findTributeTier(demand, tierName)
    local targetTier = tostring(tierName or "low")
    for _, tier in ipairs(demand and demand.tiers or {}) do
        if tostring(tier.tier or "") == targetTier then
            return tier
        end
    end
    return nil
end

local function collectTributeRecipientUUIDs(group, selectedTier)
    local recipients = {}
    local seen = {}
    if not group or not selectedTier then
        return recipients
    end

    local rewardScope = tostring(selectedTier.rewardScope or "none")
    if rewardScope == "delegate" then
        local leaderUUID = group.leaderUUID and tostring(group.leaderUUID) or nil
        if leaderUUID then
            recipients[#recipients + 1] = leaderUUID
        end
        return recipients
    end

    if rewardScope == "party" then
        for _, member in ipairs(Shared.getGroupMembers(group)) do
            local uuid = member and member.uuid and tostring(member.uuid) or nil
            if uuid and not seen[uuid] then
                recipients[#recipients + 1] = uuid
                seen[uuid] = true
            end
        end
    end

    return recipients
end

local function applyTributeReputationChange(group, player, selectedTier)
    if not group or not player or not selectedTier or Shared.isBanditFactionID(group.factionID) then
        return 0, 0
    end

    local repPerMember = math.max(0, math.floor(tonumber(selectedTier.repPerMember) or 0))
    if repPerMember <= 0 then
        return 0, 0
    end

    local recipientUUIDs = collectTributeRecipientUUIDs(group, selectedTier)
    local recipientCount = #recipientUUIDs
    if recipientCount <= 0 then
        return repPerMember, 0
    end

    local aliveFactionCount = Faction.getAliveFactionMemberCount and Faction.getAliveFactionMemberCount(group.factionID) or 0
    local username = Shared.getUsername(player)
    if aliveFactionCount > 0
        and username
        and DynamicTrading_Factions
        and DynamicTrading_Factions.ModifyReputation then
        local scalarDelta = (recipientCount * repPerMember) / aliveFactionCount
        DynamicTrading_Factions.ModifyReputation(group.factionID, username, scalarDelta)
    end

    Shared.sendBanditCommand(player, "BanditRepSync", {
        factionID = group.factionID,
        mode = "add",
        value = repPerMember,
        memberUUIDs = recipientUUIDs,
        source = "tribute_" .. tostring(selectedTier.tier or "low"),
    })

    return repPerMember, recipientCount
end

function Demand.buildDemand(player, difficulty, group)
    if group and group.robbery ~= true then
        return buildTributeDemand(player, difficulty, group.factionID)
    end

    return buildMoneyDemand(player, difficulty) or buildItemDemand(player) or {
        kind = "none",
        displayName = "nothing",
    }
end

function Bandits.StartDemand(player, args)
    if not Shared.isCurrencyExpandedActive() then return end
    if not player or type(args) ~= "table" then return end
    local uuid = args.uuid and tostring(args.uuid) or nil
    local groupID = args.groupID and tostring(args.groupID) or nil
    if not uuid or not groupID then return end

    local npcData = DTNPCManager and DTNPCManager.Data and DTNPCManager.Data[uuid] or nil
    if not npcData or tostring(npcData.banditGroupID or "") ~= groupID then return end
    if not Shared.matchesPlayer(npcData, player) then return end

    local group = Shared.getGroup(groupID)
    if not group then return end
    group.targetUsername = group.targetUsername or Shared.getUsername(player)
    group.targetOnlineID = group.targetOnlineID or Shared.getOnlineID(player)
    group.leaderUUID = group.leaderUUID or uuid
    group.difficulty = Shared.clampDifficulty(group.difficulty or npcData.banditDifficulty)

    if not group.demand or group.demand.resolved == true then
        group.demand = Demand.buildDemand(player, group.difficulty, group)
        group.demand.startedAt = Shared.nowMillis()
        group.demand.resolved = false
        group.status = "demanding"
    elseif not group.demand.startedAt then
        group.demand.startedAt = Shared.nowMillis()
    end

    for _, member in ipairs(Shared.getGroupMembers(group)) do
        member.npcData.banditDemandStarted = true
        member.npcData.banditDemandStartedAt = group.demand.startedAt
        Shared.syncNPC(member.uuid, member.npcData)
    end

    Shared.sendBanditCommand(player, "BanditDemand", {
        groupID = group.id,
        leaderUUID = uuid,
        kind = group.demand.kind,
        amount = group.demand.amount,
        itemID = group.demand.itemID,
        fullType = group.demand.fullType,
        displayName = group.demand.displayName,
        tiers = group.demand.tiers,
        factionName = group.demand.factionName,
        timeoutSeconds = math.floor(Constants.DEMAND_TIMEOUT_MS / 1000),
    })
end

function Bandits.PayDemand(player, args)
    if not Shared.isCurrencyExpandedActive() then return end
    if not player or type(args) ~= "table" then return end
    local group = Shared.getGroup(args.groupID)
    if not group or not group.demand or group.demand.resolved == true then return end
    if not Shared.playerMatchesGroup(player, group) then return end

    local demand = group.demand
    local paid = false
    local repDelta = 0
    local repPerMember = 0
    local repAwardedCount = 0
    local selectedTier = nil

    if demand.kind == "money" then
        local helpers = DynamicTrading and DynamicTrading.ServerHelpers or nil
        paid = helpers and helpers.RemoveMoney and helpers.RemoveMoney(player, tonumber(demand.amount) or 0) == true
    elseif demand.kind == "item" then
        local item = findItemByID(player, demand.itemID)
        if item and Demand.isEligibleRobberyItem(player, item) then
            local helpers = DynamicTrading and DynamicTrading.ServerHelpers or nil
            if helpers and helpers.RemoveItem then
                helpers.RemoveItem(item)
                paid = true
            end
        end
    elseif demand.kind == "tribute" then
        selectedTier = findTributeTier(demand, args.tier)
        if selectedTier then
            local helpers = DynamicTrading and DynamicTrading.ServerHelpers or nil
            paid = helpers and helpers.RemoveMoney and helpers.RemoveMoney(player, tonumber(selectedTier.amount) or 0) == true
        end
    elseif demand.kind == "none" then
        paid = true
    end

    if not paid then
        Bandits.MakeGroupHostile(group.id, player, "payment_failed")
        return
    end

    if demand.kind == "tribute" and selectedTier then
        repPerMember, repAwardedCount = applyTributeReputationChange(group, player, selectedTier)
        repDelta = repPerMember * repAwardedCount
    end

    demand.resolved = true
    demand.repDelta = repDelta
    demand.repPerMember = repPerMember
    demand.repAwardedCount = repAwardedCount
    demand.selectedTier = selectedTier and selectedTier.tier or nil
    finishGroupAsLeaving(group, player, demand.kind == "none" and "empty" or "paid")
    Shared.sendBanditCommand(player, "BanditDemandResolved", {
        groupID = group.id,
        result = demand.kind == "none" and "empty" or "paid",
        kind = demand.kind,
        displayName = demand.displayName,
        factionName = demand.factionName,
        repDelta = repDelta,
        repPerMember = repPerMember,
        repAwardedCount = repAwardedCount,
        selectedTier = demand.selectedTier,
    })
end

function Bandits.RefuseDemand(player, args)
    if not Shared.isCurrencyExpandedActive() then return end
    if not player or type(args) ~= "table" then return end
    local group = Shared.getGroup(args.groupID)
    if not group then return end
    if not Shared.playerMatchesGroup(player, group) then return end
    if group.status == "paid" or group.status == "empty" or group.status == "hostile" then return end
    Bandits.MakeGroupHostile(group.id, player, args.reason or "refused")
end
