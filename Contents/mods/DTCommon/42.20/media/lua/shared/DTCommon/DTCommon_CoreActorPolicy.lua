-- Optional Core actor policy bridge. DynamicTrading owns this compact merchant
-- policy and its stock/budget; PsychopatzCore remains authoritative for actor
-- identity, social state, and personal inventory.

DTCommon = DTCommon or {}
local Policy = DTCommon.CoreActorPolicy or {}
DTCommon.CoreActorPolicy = Policy

Policy.SCHEMA_VERSION = 1
Policy.MAX_PRICE_MODIFIER = 0.25
Policy.MAX_RECENT_VISIT_IDS = 32
Policy.PROVIDERS = Policy.PROVIDERS or {}
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
    local canonical = nil
    if PsychopatzCore and PsychopatzCore.Actors and PsychopatzCore.Actors.PlayerIdentity
        and type(PsychopatzCore.Actors.PlayerIdentity.GetTargetKey) == "function"
    then
        canonical = PsychopatzCore.Actors.PlayerIdentity.GetTargetKey(player)
    end
    if canonical then
        return { canonical }
    end
    if player and type(player.getUsername) == "function" then
        local username = player:getUsername()
        if username ~= nil and tostring(username) ~= "" then
            return { "player:user:" .. tostring(username) }
        end
    end
    if player and type(player.getOnlineID) == "function" then
        local id = player:getOnlineID()
        if id ~= nil then
            return { "player:online:" .. tostring(id) }
        end
    end
    return {}
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
        actorID = text(spec.actorID or spec.actorId, nil),
        provider = text(spec.provider
            or providerLease.provider, nil),
        providerState = text(spec.providerState or providerLease.state, nil),
        providerLeaseID = text(spec.providerLeaseID or providerLease.leaseID,
            nil),
        providerBodyID = text(spec.providerBodyID or providerLease.bodyID,
            nil),
        returnProviderID = text(spec.returnProviderID, nil),
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
        -- Hoomans community identity for a resident trader. This is distinct
        -- from lastSettlementID, which records the last actual commercial
        -- visit and must not be fabricated during resident binding.
        homeSettlementID = text(spec.homeSettlementID
            or spec.homeCommunityID, nil),
        currentSettlementID = text(spec.currentSettlementID
            or spec.currentCommunityID, nil),
        lastSettlementID = text(spec.lastSettlementID
            or spec.settlementID or spec.communityID, nil),
        destinationSettlementID = text(spec.destinationSettlementID
            or spec.destinationCommunityID or spec.destination
            or spec.nextSettlementID, nil),
        originSettlementID = text(spec.originSettlementID
            or spec.originCommunityID or spec.origin, nil),
        worldManaged = spec.worldManaged == true,
        worldRole = text(spec.worldRole, nil),
        lifecycleState = text(spec.lifecycleState, "idle"),
        journeyID = text(spec.journeyID, nil),
        journeyState = text(spec.journeyState, nil),
        cooldownUntil = math.max(0, number(spec.cooldownUntil, 0)),
        worldRevision = math.max(0, math.floor(number(spec.worldRevision, 0))),
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
    local actorID = policy.actorID
    if actorID and actorID ~= "" then
        local actors = PsychopatzCore and PsychopatzCore.Actors or nil
        local reg = actors and actors.DefaultRegistry or nil
        if reg and type(reg.GetLifecycleState) == "function"
            and reg:GetLifecycleState(actorID) == "RETIRED"
        then
            return false, "actor_retired"
        end
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

-- Set the canonical home/current settlement context for a resident trader.
-- This is identity and pricing state only: it deliberately does not create a
-- visit, increment visitCount, alter lastVisitAt/lastVisitID, or exchange
-- stock. If a trader is already away, preserve its current destination while
-- still repairing/recording the exact home identity.
function Policy.SetHomeSettlement(record, settlementID)
    if type(record) ~= "table" then return nil, "trader_required" end
    settlementID = text(settlementID, nil)
    if not settlementID then return nil, "settlement_required" end
    local policy = Policy.Get(record)
    local previousHome = policy.homeSettlementID
    policy.homeSettlementID = settlementID
    if not policy.currentSettlementID
        or policy.currentSettlementID == previousHome
    then
        policy.currentSettlementID = settlementID
    end
    record.ca = policy
    return policy
end

-- Update only the current pricing/location context. Passing nil clears the
-- current location for an offscreen excursion; actual visit history remains
-- in lastSettlementID and recentVisitIDs.
function Policy.SetCurrentSettlement(record, settlementID)
    if type(record) ~= "table" then return nil, "trader_required" end
    if settlementID ~= nil then
        settlementID = text(settlementID, nil)
        if not settlementID then return nil, "settlement_required" end
    end
    local policy = Policy.Get(record)
    policy.currentSettlementID = settlementID
    record.ca = policy
    return policy
end

function Policy.SetDestinationSettlement(record, settlementID)
    if type(record) ~= "table" then return nil, "trader_required" end
    if settlementID ~= nil then
        settlementID = text(settlementID, nil)
        if not settlementID then return nil, "settlement_required" end
    end
    local policy = Policy.Get(record)
    policy.destinationSettlementID = settlementID
    record.ca = policy
    return policy
end

function Policy.SetOriginSettlement(record, settlementID)
    if type(record) ~= "table" then return nil, "trader_required" end
    if settlementID ~= nil then
        settlementID = text(settlementID, nil)
        if not settlementID then return nil, "settlement_required" end
    end
    local policy = Policy.Get(record)
    policy.originSettlementID = settlementID
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
    if lease.provider ~= nil then
        local providerID = tostring(lease.provider)
        local registry = DTCommon and DTCommon.TraderProviders or nil
        if registry and type(registry.IsKnown) == "function"
            and not registry.IsKnown(providerID)
        then
            return nil, "provider_invalid"
        end
    end
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

local function resolveCompiledSocialPolicy(eventType)
    if type(eventType) ~= "string" or eventType == "" then return nil end
    local dtReg = DTCommon and DTCommon.SocialPolicy and DTCommon.SocialPolicy.Registry
    if not dtReg and type(require) == "function" then
        local ok, loaded = pcall(require, "DTCommon/SocialPolicy/Registry")
        if ok and type(loaded) == "table" then dtReg = loaded end
    end
    if type(dtReg) == "table" and type(dtReg.Resolve) == "function" then
        local spec = dtReg.Resolve(eventType)
        if spec then return spec end
    end
    local corePolicy = PsychopatzCore and PsychopatzCore.SocialPolicy
    if corePolicy and type(corePolicy.Resolve) == "function" then
        return corePolicy.Resolve(eventType)
    end
    return nil
end

function Policy.ClassifyTradeEventType(record, player, tradeDetails)
    tradeDetails = type(tradeDetails) == "table" and tradeDetails or {}
    if type(tradeDetails.eventType) == "string" and tradeDetails.eventType ~= "" then
        return tradeDetails.eventType
    end
    if tradeDetails.scarceRelief == true then
        return "trade.help_scarce_supply"
    end
    if tradeDetails.giftOrFavor == true then
        return "trade.gift_or_favor"
    end
    if tradeDetails.grievance == true then
        return "trade.price_grievance"
    end
    if tradeDetails.betrayal == true then
        return "trade.betrayal_or_hostile"
    end
    if (tonumber(tradeDetails.totalValue) or 0) >= 250 then
        return "trade.fair_high_value"
    end
    return "commercial_trade"
end

function Policy.QuerySocialProjection(record, player, options)
    options = type(options) == "table" and options or {}
    local policy = Policy.Get(record)
    local actors = PsychopatzCore and PsychopatzCore.Actors or nil
    local reg = actors and actors.DefaultRegistry or nil
    local actorProj = (policy.actorID and policy.actorID ~= "" and reg
        and type(reg.ProjectIdentity) == "function")
        and reg:ProjectIdentity(policy.actorID) or nil
    local keys = playerKeys(player)
    local targetProj = (keys[1] and reg and type(reg.ProjectIdentity) == "function")
        and reg:ProjectIdentity(keys[1]) or nil

    local actor = Policy.ResolveActor(record)
    local social = actor and actor.social
    local Social = actors and actors.Social or nil
    if not social or not Social or type(Social.Get) ~= "function" then
        if options.allowHistorical == true and actorProj
            and actorProj.status ~= "LIVE"
        then
            return {
                schemaVersion = 1,
                exists = false,
                historical = true,
                actorID = policy.actorID,
                lifecycleStatus = actorProj.status,
                lifecycleRevision = actorProj.lifecycleRevision,
                targetLifecycleStatus = targetProj and targetProj.status or nil,
                targetLifecycleRevision = targetProj and targetProj.lifecycleRevision or nil,
                displayName = actorProj.status ~= "FORGOTTEN"
                    and (actorProj.displayName or (type(record) == "table" and record.n) or nil)
                    or nil,
                degradedLabel = actorProj.status == "FORGOTTEN"
                    and (options.degradedLabel or "old_trader") or nil,
                role = actorProj.role or (type(record) == "table" and record.r) or nil,
                retiredAt = actorProj.retiredAt,
                reason = actorProj.reason,
            }
        end
        return nil
    end

    local matchedKey = nil
    for _, key in ipairs(keys) do
        if Social.Get(social, key) then
            matchedKey = key
            break
        end
    end
    matchedKey = matchedKey or keys[1]
    if not matchedKey then return nil end

    local proj
    if type(Social.QueryCandidateProjection) == "function" then
        proj = Social.QueryCandidateProjection(social, matchedKey, {
            extensionID = "DynamicTrading",
            worldAgeHours = options.worldAgeHours,
            maxMemories = options.maxMemories or 6,
            registry = reg,
        })
    else
        local rel = Social.Get(social, matchedKey)
        if not rel then return nil end
        proj = {
            schemaVersion = 1,
            exists = true,
            targetKey = rel.targetKey or matchedKey,
            approval = tonumber(rel.approval) or 0,
            respect = tonumber(rel.respect) or 0,
            familiarity = tonumber(rel.familiarity) or 0,
            state = rel.state or "neutral",
            previousState = rel.previousState or "unknown",
            attitude = "neutral",
            revision = tonumber(rel.revision) or 0,
            socialRevision = tonumber(social.revision) or 0,
            grievanceScore = 0,
            assistanceScore = 0,
            memories = {},
            extension = rel.extensions and rel.extensions.DynamicTrading or nil,
        }
    end
    if not proj then return nil end

    proj.lifecycleStatus = (actorProj and actorProj.status) or "LIVE"
    proj.lifecycleRevision = (actorProj and actorProj.lifecycleRevision)
        or (tonumber(actor.lifecycleRevision) or 1)
    proj.targetLifecycleStatus = (targetProj and targetProj.status)
        or proj.targetLifecycleStatus
    proj.targetLifecycleRevision = (targetProj and targetProj.lifecycleRevision)
        or proj.targetLifecycleRevision

    local ext = type(proj.extension) == "table" and proj.extension or {}
    local reliability = tonumber(ext.commercialReliability) or 50
    local totalTrades = tonumber(ext.totalTrades) or 0
    local willingnessTier = "standard"
    if proj.state == "enemy" or proj.approval <= -15 or (proj.grievanceScore or 0) > 10 then
        willingnessTier = "guarded"
    elseif proj.approval >= 25 or (reliability >= 65 and totalTrades >= 3) then
        willingnessTier = "high"
    end

    proj.actorID = policy.actorID
    proj.commercial = {
        totalTrades = totalTrades,
        lastTradeValue = tonumber(ext.lastTradeValue) or 0,
        cumulativeTradeValue = tonumber(ext.cumulativeTradeValue) or 0,
        commercialReliability = reliability,
        lastTradeAt = ext.lastTradeAt,
    }
    proj.willingnessTier = willingnessTier
    if type(social.personality) == "table" then
        proj.personality = {
            greed = social.personality.greed,
            sociability = social.personality.sociability,
            forgiveness = social.personality.forgiveness,
            aggression = social.personality.aggression,
        }
    end
    return proj
end

function Policy.PriceContext(record, player)
    local policy = Policy.Get(record)
    local modifier = policy.priceBias
    local projection = policy.relationshipPricing
        and Policy.QuerySocialProjection(record, player) or nil
    if policy.relationshipPricing and projection and projection.exists then
        modifier = modifier
            + bounded(projection.approval, -100, 100) * 0.0015
            + bounded(projection.respect, -100, 100) * 0.00075
            + bounded(projection.familiarity, 0, 100) * 0.00025
    end
    modifier = bounded(modifier, -Policy.MAX_PRICE_MODIFIER,
        Policy.MAX_PRICE_MODIFIER)
    return {
        relationshipModifier = modifier,
        actorID = policy.actorID,
        policySchemaVersion = policy.schemaVersion,
        socialRevision = projection and projection.socialRevision or 0,
        relationshipRevision = projection and projection.revision or 0,
        relationshipState = projection and projection.state or "unknown",
        familiarity = projection and projection.familiarity or 0,
        commercialReliability = projection and projection.commercial
            and projection.commercial.commercialReliability or 50,
        totalTrades = projection and projection.commercial
            and projection.commercial.totalTrades or 0,
        willingnessTier = projection and projection.willingnessTier or "standard",
    }
end

function Policy.PlayerKeys(player)
    return playerKeys(player)
end

function Policy.RecordTradeEvent(record, player, tradeDetails)
    local policy = Policy.Get(record)
    local actorID = policy.actorID
    local actors = PsychopatzCore and PsychopatzCore.Actors or nil
    if not actorID or not actors or type(actors.Get) ~= "function" then
        return nil, "core_actor_unavailable"
    end
    local Social = actors.Social
    local Authority = actors.SocialAuthority
    if not Social or type(Social.GetExtension) ~= "function" then
        return nil, "core_social_unavailable"
    end
    if not Authority
        or type(Authority.Get) ~= "function"
        or type(Authority.RecordAuthorizedEvent) ~= "function"
        or type(Authority.SetExtension) ~= "function"
    then
        return nil, "core_social_authority_unavailable"
    end
    local keys = playerKeys(player)
    if #keys == 0 then return nil, "player_key_unavailable" end
    local primaryKey = keys[1]

    local actor, actorReason = Authority.Get(actorID, PsychopatzCore)
    if not actor or not actor.social then
        return nil, actorReason or "actor_social_unavailable"
    end

    tradeDetails = type(tradeDetails) == "table" and tradeDetails or {}
    local requestID = tradeDetails.requestID
    if requestID == nil then
        Policy.TradeEventSerial =
            (tonumber(Policy.TradeEventSerial) or 0) + 1
        local gameTime = getGameTime and getGameTime() or nil
        local worldAge = gameTime
            and gameTime.getWorldAgeHours
            and tonumber(gameTime:getWorldAgeHours())
            or 0
        requestID = "trade:"
            .. tostring(worldAge)
            .. ":"
            .. tostring(Policy.TradeEventSerial)
    end
    requestID = tostring(requestID)
    local eventID = "dt:trade:" .. requestID

    local eventType = Policy.ClassifyTradeEventType(record, player, tradeDetails)
    local compiled = resolveCompiledSocialPolicy(eventType)

    local approvalDelta = tradeDetails.approvalDelta ~= nil
        and tonumber(tradeDetails.approvalDelta)
        or (compiled and tonumber(compiled.approvalDelta)) or 1
    local respectDelta = tradeDetails.respectDelta ~= nil
        and tonumber(tradeDetails.respectDelta)
        or (compiled and tonumber(compiled.respectDelta)) or 0
    local familiarityDelta = tradeDetails.familiarityDelta ~= nil
        and tonumber(tradeDetails.familiarityDelta)
        or (compiled and tonumber(compiled.familiarityDelta)) or 1
    local createdAt = tradeDetails.createdAt
        or (getGameTime and getGameTime():getWorldAgeHours() or 0)

    local tags = { trade = true, dynamic_trading = true }
    if tradeDetails.scarceRelief == true then tags.scarce_relief = true end
    if eventType == "trade.fair_high_value" then tags.fair_deal = true end

    local event = {
        targetKey = primaryKey,
        eventID = eventID,
        type = eventType,
        approvalDelta = approvalDelta,
        respectDelta = respectDelta,
        familiarityDelta = familiarityDelta,
        authority = "server",
        authorized = true,
        createdAt = createdAt,
        worldAgeHours = createdAt,
        policy = compiled,
        retentionClass = tradeDetails.retentionClass
            or (compiled and compiled.retentionClass) or "LONG",
        salience = tradeDetails.salience or (compiled and compiled.salience),
        consolidationFamily = tradeDetails.consolidationFamily
            or (compiled and compiled.consolidationFamily),
        maxConsolidatedApproval = compiled and compiled.maxConsolidatedApproval,
        maxConsolidatedRespect = compiled and compiled.maxConsolidatedRespect,
        maxConsolidatedFamiliarity = compiled and compiled.maxConsolidatedFamiliarity,
        sourceMode = tradeDetails.sourceMode or "direct",
        tags = tags,
    }
    local updatedActor, reason = Authority.RecordAuthorizedEvent(
        actorID,
        event,
        PsychopatzCore,
        actor.revision
    )
    if not updatedActor then return nil, reason end
    local updatedSocial = updatedActor.social

    -- Update commercial metadata extension in relationship
    local ext = Social.GetExtension and Social.GetExtension(updatedSocial, primaryKey, "DynamicTrading") or {}
    local tradeVal = tonumber(tradeDetails.totalValue) or 0
    local relDelta = tonumber(tradeDetails.reliabilityDelta)
    if not relDelta then
        if eventType == "trade.price_grievance" then
            relDelta = -4
        elseif eventType == "trade.betrayal_or_hostile" then
            relDelta = -25
        elseif eventType == "trade.fair_high_value"
            or eventType == "trade.help_scarce_supply"
            or eventType == "trade.gift_or_favor"
        then
            relDelta = 5
        else
            relDelta = 2
        end
    end
    ext.totalTrades = (tonumber(ext.totalTrades) or 0) + 1
    ext.lastTradeValue = tradeVal
    ext.cumulativeTradeValue = (tonumber(ext.cumulativeTradeValue) or 0) + math.abs(tradeVal)
    ext.commercialReliability = bounded((tonumber(ext.commercialReliability) or 50) + relDelta, 0, 100)
    ext.lastTradeAt = createdAt
    local committedActor, extensionReason = Authority.SetExtension(
        actorID,
        primaryKey,
        "DynamicTrading",
        ext,
        PsychopatzCore,
        updatedActor.revision
    )
    if not committedActor then return nil, extensionReason end
    if actors.RuntimeStore and type(actors.RuntimeStore.MarkDirty) == "function" then
        actors.RuntimeStore.MarkDirty("dt_trade_social_event")
    end
    return committedActor.social
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
    policy.currentSettlementID = settlementID
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
