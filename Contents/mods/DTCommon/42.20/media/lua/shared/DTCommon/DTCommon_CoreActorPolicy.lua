-- Optional Core actor policy bridge. DynamicTrading owns this compact merchant
-- policy and its stock/budget; PsychopatzCore remains authoritative for actor
-- identity, social state, and personal inventory.

DTCommon = DTCommon or {}
local Policy = DTCommon.CoreActorPolicy or {}
DTCommon.CoreActorPolicy = Policy

Policy.SCHEMA_VERSION = 1
Policy.MAX_PRICE_MODIFIER = 0.25
Policy.MAX_RECENT_VISIT_IDS = 32
Policy.PROVIDERS = {
    PsychopatzCore = true,
    DTAbstract = true,
    DTHoomans = true,
}
Policy.STATES = {
    abstract = true,
    materialized = true,
    released = true,
}

local function number(value, fallback)
    value = tonumber(value)
    if not value or value ~= value or value == math.huge
        or value == -math.huge
    then return fallback end
    return value
end

local function text(value, fallback)
    if type(value) ~= "string" or value == "" then return fallback end
    return value
end

local function bounded(value, low, high)
    return math.max(low, math.min(high, number(value, 0)))
end

local function playerKeys(player)
    local output = {}
    if player and type(player.getOnlineID) == "function" then
        local id = player:getOnlineID()
        if id ~= nil then output[#output + 1] = "player:online:" .. tostring(id) end
    end
    if player and type(player.getUsername) == "function" then
        local username = player:getUsername()
        if username ~= nil and tostring(username) ~= "" then
            output[#output + 1] = "player:user:" .. tostring(username)
        end
    end
    return output
end

function Policy.New(spec)
    spec = type(spec) == "table" and spec or {}
    local restockItems = {}
    local recentVisitIDs = {}
    local configuredItems = spec.restockItems
        or (spec.restock and spec.restock.items) or {}
    local configuredVisitIDs = type(spec.recentVisitIDs) == "table"
        and spec.recentVisitIDs or {}
    for index = 1, math.min(32, #configuredItems) do
        local item = configuredItems[index]
        if type(item) == "table" and text(item.fullType, nil) then
            restockItems[#restockItems + 1] = {
                fullType = text(item.fullType, ""),
                quantity = math.max(1, math.floor(number(item.quantity, 1))),
            }
        end
    end
    for index = 1, math.min(Policy.MAX_RECENT_VISIT_IDS,
        #configuredVisitIDs) do
        local visitID = text(configuredVisitIDs[index], nil)
        if visitID then recentVisitIDs[#recentVisitIDs + 1] = visitID end
    end
    local legacyVisitID = text(spec.lastVisitID, nil)
    if legacyVisitID and #recentVisitIDs == 0 then
        recentVisitIDs[1] = legacyVisitID
    end
    local providerLease = type(spec.providerLease) == "table"
        and spec.providerLease or {}
    return {
        schemaVersion = Policy.SCHEMA_VERSION,
        actorID = text(spec.actorID or spec.actorId
            or spec.coreActorID or spec.coreActorId, nil),
        provider = text(spec.provider or spec.coreProvider
            or providerLease.provider, nil),
        providerState = text(spec.providerState or providerLease.state, nil),
        providerLeaseID = text(spec.providerLeaseID or providerLease.leaseID,
            nil),
        providerBodyID = text(spec.providerBodyID or providerLease.bodyID,
            nil),
        providerRevision = math.max(0, math.floor(number(
            spec.providerRevision or providerLease.revision, 0))),
        available = spec.available ~= false,
        availabilityReason = text(spec.availabilityReason, nil),
        relationshipPricing = spec.relationshipPricing ~= false,
        priceBias = bounded(spec.priceBias, -Policy.MAX_PRICE_MODIFIER,
            Policy.MAX_PRICE_MODIFIER),
        restock = {
            intervalHours = math.max(0, number(spec.restockIntervalHours,
                number(spec.restock and spec.restock.intervalHours, 24))),
            nextAt = number(spec.restockNextAt,
                number(spec.restock and spec.restock.nextAt, 0)),
            earnedOnly = spec.restockEarnedOnly ~= false,
            items = restockItems,
            lastAt = number(spec.restockLastAt, 0),
            count = math.max(0, math.floor(number(spec.restockCount, 0))),
        },
        visitCount = math.max(0, math.floor(number(spec.visitCount, 0))),
        lastVisitAt = number(spec.lastVisitAt, 0),
        lastVisitID = legacyVisitID,
        recentVisitIDs = recentVisitIDs,
        lastSettlementID = text(spec.lastSettlementID
            or spec.settlementID or spec.communityID, nil),
    }
end

function Policy.Normalize(value)
    if type(value) ~= "table" then return Policy.New() end
    local normalized = Policy.New(value)
    normalized.schemaVersion = Policy.SCHEMA_VERSION
    return normalized
end

function Policy.Bind(record, actorID, definition)
    if type(record) ~= "table" then return nil, "trader_required" end
    definition = type(definition) == "table" and definition or {}
    definition.actorID = actorID or definition.actorID
    record.ca = Policy.New(definition)
    return record.ca
end

function Policy.Get(record)
    if type(record) ~= "table" then return Policy.New() end
    return Policy.Normalize(record.ca)
end

function Policy.IsAvailable(record)
    local policy = Policy.Get(record)
    if policy.available ~= true then
        return false, policy.availabilityReason or "actor_unavailable"
    end
    return true
end

function Policy.SetAvailable(record, available, reason)
    if type(record) ~= "table" then return nil, "trader_required" end
    local policy = Policy.Get(record)
    policy.available = available == true
    policy.availabilityReason = text(reason, nil)
    record.ca = policy
    return policy
end

function Policy.SetProviderLease(record, lease)
    if type(record) ~= "table" then return nil, "trader_required" end
    if type(lease) ~= "table" then return nil, "provider_lease_required" end
    local policy = Policy.Get(record)
    if lease.actorID ~= nil and policy.actorID ~= tostring(lease.actorID) then
        return nil, "core_actor_mismatch"
    end
    if lease.provider ~= nil and not Policy.PROVIDERS[tostring(lease.provider)]
    then return nil, "provider_invalid" end
    if lease.state ~= nil and not Policy.STATES[tostring(lease.state)] then
        return nil, "provider_state_invalid"
    end
    if tostring(lease.state or "") == "materialized"
        and text(lease.bodyID or lease.bodyId, nil) == nil
    then return nil, "body_id_required" end
    policy.provider = text(lease.provider, nil)
    policy.providerState = text(lease.state, nil)
    policy.providerLeaseID = text(lease.leaseID, nil)
    policy.providerBodyID = text(lease.bodyID, nil)
    policy.providerRevision = math.max(0, math.floor(number(lease.revision, 0)))
    record.ca = policy
    return policy
end

function Policy.ResolveActor(record)
    local actorID = Policy.Get(record).actorID
    local actors = PsychopatzCore and PsychopatzCore.Actors or nil
    if not actorID or not actors or type(actors.Get) ~= "function" then
        return nil, "core_actor_unavailable"
    end
    return actors.Get(actorID)
end

function Policy.PriceContext(record, player)
    local policy = Policy.Get(record)
    local modifier = policy.priceBias
    if policy.relationshipPricing then
        local actor = Policy.ResolveActor(record)
        local social = actor and actor.social
        local Social = PsychopatzCore and PsychopatzCore.Actors
            and PsychopatzCore.Actors.Social or nil
        if social and Social and type(Social.Get) == "function" then
            for _, key in ipairs(playerKeys(player)) do
                local relationship = Social.Get(social, key)
                if relationship then
                    modifier = modifier
                        + bounded(relationship.approval, -100, 100) * 0.0015
                        + bounded(relationship.respect, -100, 100) * 0.00075
                        + bounded(relationship.familiarity, 0, 100) * 0.00025
                    break
                end
            end
        end
    end
    modifier = bounded(modifier, -Policy.MAX_PRICE_MODIFIER,
        Policy.MAX_PRICE_MODIFIER)
    return {
        relationshipModifier = modifier,
        actorID = policy.actorID,
        policySchemaVersion = policy.schemaVersion,
    }
end

function Policy.MarkVisit(record, options)
    options = type(options) == "table" and options or {}
    if options.authority ~= "server" then
        return nil, "server_authority_required"
    end
    local settlementID = text(options.settlementID or options.communityID, nil)
    if options.atSettlement ~= true or not settlementID then
        return nil, "settlement_required"
    end
    local policy = Policy.Get(record)
    local visitID = text(options.visitID, nil)
    if visitID then
        for index = 1, #policy.recentVisitIDs do
            if policy.recentVisitIDs[index] == visitID then
                return nil, "duplicate_visit"
            end
        end
    end
    policy.available = options.available ~= false
    policy.availabilityReason = nil
    policy.visitCount = policy.visitCount + 1
    policy.lastVisitAt = number(options.now, policy.lastVisitAt)
    policy.lastVisitID = visitID
    if visitID then
        policy.recentVisitIDs[#policy.recentVisitIDs + 1] = visitID
        while #policy.recentVisitIDs > Policy.MAX_RECENT_VISIT_IDS do
            table.remove(policy.recentVisitIDs, 1)
        end
    end
    policy.lastSettlementID = settlementID
    record.ca = policy
    return policy
end

function Policy.Restock(record, stock, options)
    options = type(options) == "table" and options or {}
    if options.authority ~= "server" then
        return nil, "server_authority_required"
    end
    local settlementID = text(options.settlementID or options.communityID, nil)
    if options.atSettlement ~= true or not settlementID then
        return nil, "settlement_required"
    end
    if options.earned ~= true and Policy.Get(record).restock.earnedOnly then
        return nil, "restock_not_earned"
    end
    if not stock or type(stock.add) ~= "function" then
        return nil, "stock_unavailable"
    end
    local policy = Policy.Get(record)
    local now = number(options.now, 0)
    if now < policy.restock.nextAt then return nil, "restock_not_due" end
    local Stock = DTCommon.TraderStock
    local items = policy.restock.items
    if #items == 0 then items = DTCommon.DEFAULT_STOCK or {} end
    local added = 0
    for index = 1, math.min(32, #items) do
        local item = items[index]
        local encoded
        if Stock and type(Stock.EncodeItem) == "function" then
            encoded = Stock.EncodeItem(item.fullType, item.quantity)
        end
        if encoded then
            local ok = stock:add(encoded)
            if ok ~= false then added = added + item.quantity end
        end
    end
    if added <= 0 then return nil, "restock_empty" end
    policy.restock.lastAt = now
    policy.restock.nextAt = now + policy.restock.intervalHours
    policy.restock.count = policy.restock.count + 1
    record.ca = policy
    return { added = added, nextAt = policy.restock.nextAt,
        count = policy.restock.count }
end

return Policy
