-- Shared Dynamic Trading trader conversation content/open path.
-- Provider modules authorize access and supply transport; this module owns the
-- trader-facing content and uses the Core conversation session shell.

DTCommon = DTCommon or {}
DTCommon.TraderConversation = DTCommon.TraderConversation or {}

local Conversation = DTCommon.TraderConversation
local CoreClient = require
    "PsychopatzCore/World/SurvivorWorld/PsychopatzSurvivorWorldClient"
local SemanticFoundation = require
    "PsychopatzCore/ConvoEngine/Foundation"
local ActorNames = require
    "PsychopatzCore/Actors/PsychopatzActorNames"
local Landing = require
    "PsychopatzCore/Conversation/PsychopatzActorConversationLanding"
local TextCatalog = require
    "PsychopatzCore/Conversation/PsychopatzConversationTextCatalog"
local Text = require "PsychopatzCore/UI/Conversation/PsychopatzConversationText"
local SemanticPack = require "DTCommon/DTCommon_SemanticPack"

if SemanticPack and type(SemanticPack.Init) == "function" then
    SemanticPack.Init()
end

local TRADE_TEXT_SOURCE = TextCatalog.Source({
    modID = "DTCommon",
    target = "dynamic_trading/trade/opening",
    domain = "dtcommon.conversation.dynamic_trading.trade.opening",
})
local REFERRAL_TEXT_SOURCE = TextCatalog.Source({
    modID = "DTCommon",
    target = "dynamic_trading/caravan/referral/guard",
    domain = "dthoomans.conversation.dynamic_trading.caravan.referral.guard",
})
local SMALL_TALK_TEXT_SOURCE = TextCatalog.Source({
    modID = "PsychopatzCore",
    target = "social/small_talk/neutral",
    domain = "pnc.social.small_talk.neutral",
})
local GOODBYE_TEXT_SOURCE = TextCatalog.Source({
    modID = "PsychopatzCore",
    target = "social/goodbye/closing",
    domain = "pnc.social.goodbye.closing",
})

local function localizedText(source, key, fallback)
    if not source then return fallback end
    TextCatalog.EnsureSource(source, { key })
    return Text.Resolve(TextCatalog.Payload(source, key), fallback)
end

local function foundationResponse(poolID, seed, fallback)
    if SemanticFoundation
        and type(SemanticFoundation.GetResponse) == "function"
    then
        local variant = SemanticFoundation.GetResponse(poolID, { seed = seed })
        if type(variant) == "table" then
            local translations = variant.translations
            local text = type(translations) == "table"
                and (translations.EN or translations.TL)
                or variant.fallback
            if text and tostring(text) ~= "" then return tostring(text) end
        end
    end
    return fallback
end

local function foundationPhrase(templateID, style, seed, fallback)
    if SemanticFoundation
        and type(SemanticFoundation.GetPhrase) == "function"
    then
        local phrase = SemanticFoundation.GetPhrase(
            templateID,
            style,
            { seed = seed }
        )
        if type(phrase) == "table" then
            local translations = phrase.translations
            local text = type(translations) == "table"
                and (translations.EN or translations.TL)
                or phrase.fallback
            text = text and tostring(text) or ""
            if text ~= "" and not string.find(text, "%%s", 1, true) then
                return text
            end
        end
    end
    return fallback
end

Conversation.EXTERNAL_OPENER_ID = DTCommon.TRADER_NAMESPACE
    or "DT.trader"
Conversation.ProviderTransports =
    Conversation.ProviderTransports or {}
Conversation.PendingOpens = Conversation.PendingOpens or {}

local PENDING_OPEN_MAX_ATTEMPTS = 120
local PENDING_OPEN_TICK_HOOK = false

local function copyOptions(options)
    local copy = {}
    for key, value in pairs(type(options) == "table" and options or {}) do
        copy[key] = value
    end
    return copy
end

local function processPendingOpens()
    for key, pending in pairs(Conversation.PendingOpens) do
        pending.attempts = (tonumber(pending.attempts) or 0) + 1
        if pending.attempts > PENDING_OPEN_MAX_ATTEMPTS then
            Conversation.PendingOpens[key] = nil
        else
            local options = copyOptions(pending.options)
            options._pendingRetry = true
            local opened, reason = Conversation.Open(
                pending.traderID,
                pending.actorID,
                options
            )
            if opened ~= nil or reason ~= "core_actor_projection_pending" then
                Conversation.PendingOpens[key] = nil
            end
        end
    end
end

local function queuePendingOpen(traderID, actorID, options)
    local key = tostring(traderID) .. "|" .. tostring(actorID)
    Conversation.PendingOpens[key] = {
        traderID = tostring(traderID),
        actorID = tostring(actorID),
        options = copyOptions(options),
        attempts = 0,
    }
    if not PENDING_OPEN_TICK_HOOK
        and Events and Events.OnTick
        and type(Events.OnTick.Add) == "function"
    then
        Events.OnTick.Add(processPendingOpens)
        PENDING_OPEN_TICK_HOOK = true
    end
end

function Conversation.RegisterProviderTransport(providerID, transport)
    providerID = tostring(providerID or "")
    if providerID == "" or type(transport) ~= "function" then
        return false, "conversation_transport_invalid"
    end
    Conversation.ProviderTransports[providerID] = transport
    return true, providerID
end

local function recordFor(traderID)
    local service = DTCommon and DTCommon.TraderService or nil
    if not service or type(service.GetRecord) ~= "function" then
        return nil
    end
    return service.GetRecord(tostring(traderID or ""))
end

local function resolveActorReference(reference)
    if CoreClient and type(CoreClient.Resolve) == "function" then
        return CoreClient.Resolve(reference)
    end
    local actor = CoreClient and type(CoreClient.GetActor) == "function"
        and CoreClient.GetActor(reference) or nil
    if actor then
        return actor, {
            canonicalActorID = actor.actorID,
            aliasKind = "canonical",
            sourceReference = tostring(reference or ""),
        }
    end
    return nil, "actor_not_found"
end

local function sameActorReference(left, right, canonical)
    if tostring(left or "") == tostring(right or "") then return true end
    if not canonical then return false end
    local resolved = resolveActorReference(left)
    return resolved ~= nil
        and tostring(resolved.actorID or "") == tostring(canonical)
end

local function traderForNPC(npcID)
    npcID = tostring(npcID or "")
    if npcID == "" then return nil, nil end
    local service = DTCommon and DTCommon.TraderService or nil
    if not service or type(service.ForEach) ~= "function" then
        return nil, nil
    end
    local foundID
    local foundRecord
    local selected = resolveActorReference(npcID)
    local canonical = selected and selected.actorID or nil
    service.ForEach(function(traderID, record)
        if foundID or type(record) ~= "table" then return end
        local ca = type(record.ca) == "table" and record.ca or {}
        local matched = sameActorReference(ca.actorID, npcID, canonical)
            or sameActorReference(record.p or record.l, npcID, canonical)
        if not matched then
            for _, memberID in ipairs(record.m or {}) do
                if sameActorReference(memberID, npcID, canonical) then
                    matched = true
                    break
                end
            end
        end
        if matched then
            foundID = tostring(traderID)
            foundRecord = record
        end
    end)
    return foundID, foundRecord
end

local function placeName(id)
    if id == nil then return nil end
    local places = DTCommon and DTCommon.PlacePresentation or nil
    if places and type(places.Resolve) == "function" then
        local resolved = places.Resolve(id)
        if resolved then return resolved end
    end
    return nil
end

local function displayName(projection, record, fallback)
    local source = {
        identity = projection and projection.identity
            or record and record.identity,
        displayName = projection and (
            projection.displayName or projection.label or projection.name
        ) or record and record.n,
        identitySeed = projection and projection.identitySeed
            or record and record.identitySeed,
    }
    local parts = ActorNames.ResolveParts(source, {
        resolveNickname = true,
    })
    return tostring(
        fallback
            or parts.displayName
            or projection and (
                projection.displayName
                    or projection.label
                    or projection.name
            )
            or record and record.n
            or "Trader"
    )
end

local function identityParts(projection, record, fallback)
    local source = {
        identity = projection and projection.identity
            or record and record.identity,
        displayName = projection and (
            projection.displayName or projection.label or projection.name
        ) or record and record.n or fallback,
        identitySeed = projection and projection.identitySeed
            or record and record.identitySeed,
    }
    return ActorNames.ResolveParts(source, {
        resolveNickname = true,
    })
end

local function knowledgeKey(value)
    value = type(value) == "table" and value or {}
    return table.concat({
        tostring(value.state or ""),
        tostring(value.nameKnown == true),
        tostring(value.knownName or ""),
        tostring(value.knownNickname or ""),
        tostring(value.knownSurname or ""),
        tostring(value.factionKnown == true),
        tostring(value.factionID or ""),
        tostring(value.factionName or ""),
        tostring(value.revision or 0),
    }, "|")
end

local function actorKnowledge(actorID, projection, options, record)
    local provider = options.provider
        or projection and projection.provider
        or record and record.ca and record.ca.provider
        or "Core"
    if CoreClient.RequestActorKnowledge then
        pcall(CoreClient.RequestActorKnowledge, actorID, {
            provider = provider,
        })
    end
    local knowledge
    if CoreClient.GetActorKnowledge then
        local ok, value = pcall(
            CoreClient.GetActorKnowledge,
            actorID,
            { provider = provider }
        )
        if ok and type(value) == "table" then knowledge = value end
    end
    if knowledge then
        local parts = knowledge.identity
        if not parts and knowledge.state ~= "unknown"
            and knowledge.nameKnown ~= false
        then
            parts = identityParts(projection, record, knowledge.knownName)
        end
        if parts then
            knowledge.identity = parts
            knowledge.knownIdentity = parts
            knowledge.nicknameKnown = knowledge.nicknameKnown == true
                or knowledge.knownNickname ~= nil
            knowledge.surnameKnown = knowledge.surnameKnown == true
                or knowledge.knownSurname ~= nil
        end
        return knowledge
    end
    local parts = identityParts(projection, record)
    return {
        actorID = actorID,
        provider = provider,
        state = "known",
        identity = parts,
        knownIdentity = parts,
        nameKnown = parts.displayName ~= nil,
        knownName = parts.displayName or displayName(projection, record),
        nicknameKnown = false,
        knownNickname = nil,
        surnameKnown = false,
        knownSurname = nil,
        factionKnown = projection and projection.factionID ~= nil,
        factionID = projection and projection.factionID,
        factionName = projection and projection.factionName,
        revision = projection and projection.revision or 0,
    }
end

local function destinationResponse(record)
    local ca = record and record.ca or {}
    local name = placeName(ca.destinationSettlementID)
    if name then return "I'm heading toward " .. name .. "." end
    return "I can't confirm where I'm heading next yet."
end

local function originResponse(record)
    local ca = record and record.ca or {}
    local name = placeName(
        ca.originSettlementID
            or ca.currentSettlementID
            or ca.homeSettlementID
    )
    if name then return "I came from " .. name .. "." end
    return "I can't confirm where I came from."
end

local function newsResponse(traderID)
    local knowledge = DTCommon and DTCommon.WorldKnowledge or nil
    if knowledge and type(knowledge.BuildConversationContext) == "function" then
        local ok, context = pcall(
            knowledge.BuildConversationContext,
            traderID,
            {}
        )
        local statements = ok and context
            and context.npcGossip
            and context.npcGossip.statements or nil
        if type(statements) == "table" and statements[1] then
            return tostring(statements[1])
        end
    end
    return foundationPhrase(
        "semantic.gossip.unknown",
        "neutral",
        traderID,
        "I haven't heard any news lately."
    )
end

local function identityResponse(knowledge, fallbackName)
    knowledge = type(knowledge) == "table" and knowledge or {}
    if knowledge.nameKnown == false then
        return "I haven't told you my name yet."
    end
    return "I'm " .. tostring(
        knowledge.knownName or fallbackName or "the caravan trader"
    ) .. "."
end

local function identityFacetResponse(knowledge, subject, fallbackName)
    knowledge = type(knowledge) == "table" and knowledge or {}
    local identity = knowledge.identity or {}
    local value
    if subject == "IDENTITY_NICKNAME" then
        value = knowledge.knownNickname
        if value then
            return "Most people call me " .. tostring(value) .. "."
        end
        return "I don't really use a nickname."
    elseif subject == "IDENTITY_SURNAME" then
        value = knowledge.knownSurname
        if value then
            return "My surname is " .. tostring(value) .. "."
        end
        return identityResponse(knowledge, fallbackName)
    elseif subject == "IDENTITY_FACTION" then
        value = knowledge.factionName or identity.factionName
        if value then
            return "I'm with " .. tostring(value) .. "."
        end
        return "I don't belong to any group I can name."
    end
    return identityResponse(knowledge, fallbackName)
end

local function foundationIdentityChoices(context, knowledge, fallbackName)
    local choices = {}
    local definitions = SemanticFoundation.GetStaticSuggestions(context)
    local supported = {
        IDENTITY = true,
        IDENTITY_NICKNAME = true,
        IDENTITY_SURNAME = true,
        IDENTITY_FACTION = true,
    }
    for _, definition in ipairs(definitions or {}) do
        local subject = tostring(definition.subject or "")
        if supported[subject] then
            choices[#choices + 1] = {
                id = "core." .. tostring(definition.id),
                text = definition.labelFallback or definition.id,
                response = function()
                    return identityFacetResponse(knowledge, subject, fallbackName)
                end,
                order = tonumber(definition.order) or 60,
            }
        end
    end
    return choices
end

local function factionContext(projection, record)
    local ca = record and record.ca or {}
    return {
        factionID = projection and projection.factionID or ca.factionID,
        factionName = projection and projection.factionName
            or ca.factionName,
        factionArchetypeID = projection
            and projection.factionArchetypeID
            or ca.factionArchetypeID,
        factionPresentation = projection
            and projection.factionPresentation
            or ca.factionPresentation,
        communityID = projection and projection.communityID
            or ca.communityID,
    }
end

local function appendRosterID(roster, seen, value)
    value = tostring(value or "")
    if value == "" or seen[value] then return end
    seen[value] = true
    roster[#roster + 1] = value
end

local function rosterFor(record, activeActorID, supplied)
    local roster = {}
    local seen = {}
    local source = type(supplied) == "table" and supplied
        or record and record.m
    for _, memberID in ipairs(type(source) == "table" and source or {}) do
        appendRosterID(roster, seen, memberID)
    end
    local ca = record and record.ca or {}
    appendRosterID(roster, seen, record and record.l)
    appendRosterID(roster, seen, ca.actorID)
    if #roster == 0 then appendRosterID(roster, seen, activeActorID) end

    local index = 1
    for i, memberID in ipairs(roster) do
        if tostring(memberID) == tostring(activeActorID) then
            index = i
            break
        end
    end
    if not seen[tostring(activeActorID or "")] then
        table.insert(roster, 1, tostring(activeActorID))
        index = 1
    end
    return roster, index
end

local function roleFor(projection, options)
    local role = options and options.role
        or projection and projection.role
        or "trader"
    role = string.lower(tostring(role))
    return role ~= "" and role or "trader"
end

local function canTradeRole(role)
    return role == "trader"
        or role == "merchant"
        or role == "merchant_trader"
end

local function canTrade(projection, role)
    local capabilities = projection and projection.capabilities
    return type(capabilities) == "table"
        and capabilities[DTCommon.TRADE_CAPABILITY or "DT.trade"] == true
        or canTradeRole(role)
end

local function actorService()
    local loaded, service = pcall(
        require,
        "PsychopatzCore/Conversation/PsychopatzActorConversationService"
    )
    if not loaded or type(service) ~= "table"
        or type(service.New) ~= "function"
    then
        return nil
    end
    return service
end

local function patternID(ir)
    return tostring(ir and ir.provenance
        and ir.provenance.pattern or "")
end

local function hasPattern(ir, value)
    return string.find(patternID(ir), value, 1, true) ~= nil
end

local function responseFor(traderID, ir, context)
    local intent = tostring(ir and ir.intent or "")
    local pattern = patternID(ir)
    local record = recordFor(traderID)
    if intent == "TRADE" then
        return {
            text = "Opening our trade ledger.",
            branch = "TRADE_REQUESTED",
            action = DTCommon.TRADE_ACTION_ID or "DT.trade",
        }
    end
    if intent == "GOSSIP" then
        if string.find(pattern, "story", 1, true) then
            return {
                text = "The road has been long, but the caravan keeps moving.",
                branch = "STORY_RECEIVED",
            }
        end
        return {
            text = newsResponse(traderID),
            branch = "RUMORS_RECEIVED",
        }
    end
    if intent == "QUESTION" then
        if hasPattern(ir, "destination") then
            return {
                text = destinationResponse(record),
                branch = "DESTINATION_RECEIVED",
            }
        end
        if hasPattern(ir, "origin") then
            return {
                text = originResponse(record),
                branch = "ORIGIN_RECEIVED",
            }
        end
        if hasPattern(ir, "whereabouts")
            or hasPattern(ir, "settlement")
        then
            return {
                text = destinationResponse(record),
                branch = "WHEREABOUTS_RECEIVED",
            }
        end
        if hasPattern(ir, "who")
            or hasPattern(ir, "trader_location")
            or tostring(ir and ir.topic or "") == "identity"
        then
            return {
                text = identityResponse(
                    context and context.knowledge,
                    context and context.npcName
                ),
                branch = "IDENTITY_RECEIVED",
            }
        end
    end
    if intent == "GREETING" then
        return {
            text = foundationResponse(
                "semantic.greeting",
                traderID,
                "Good to see you. What can I trade for you today."
            ),
            branch = "GREETING_RECEIVED",
        }
    end
    if intent == "FAREWELL" then
        return {
            text = "Safe travels.",
            branch = "FAREWELL_RECEIVED",
        }
    end
    return {
        text = "Tell me what you need from the road.",
        branch = "TRADER_UNHANDLED",
    }
end

local function policyFor(traderID)
    return {
        Decide = function(ir, state, context)
            local response = responseFor(traderID, ir, context)
            return {
                schemaVersion = 1,
                kind = "dynamictrading_trader_decision",
                route = DTCommon.TRADER_NAMESPACE or "DT.trader",
                branch = response.branch,
                confidence = tonumber(ir and ir.confidence) or 0,
                intent = ir and ir.intent,
                speechAct = ir and ir.speechAct,
                action = response.action,
                response = { text = response.text },
                diagnostics = {
                    pattern = patternID(ir),
                    stateSequence = state and state.sequence,
                },
            }
        end,
    }
end

local function actorFor(projection, actorID, name)
    local social = projection and projection.social or {}
    local identity = projection and projection.identity
        or identityParts(projection, nil, name)
    return {
        actorId = actorID,
        id = actorID,
        identity = identity,
        persona = projection and projection.persona,
        social = {
            personality = projection and projection.personality
                or social.personality,
            relationships = projection and projection.relationships
                or social.relationships,
        },
        knowledge = projection and projection.knowledge,
    }
end

local function contextFor(
    traderID,
    actorID,
    name,
    projection,
    record,
    options,
    knowledge
)
    local faction = factionContext(projection, record)
    local identity = knowledge and knowledge.identity
    if not identity and (not knowledge or knowledge.nameKnown ~= false) then
        identity = identityParts(projection, record, name)
    end
    local ca = record and record.ca or {}
    local role = roleFor(projection, options)
    local capabilities = {}
    if canTrade(projection, role) then
        capabilities[DTCommon.TRADE_CAPABILITY or "DT.trade"] = true
    end
    return {
        actorID = actorID,
        traderID = traderID,
        npcID = actorID,
        npcName = name,
        provider = options.provider
            or projection and projection.provider
            or ca.provider
            or "DynamicTrading",
        providerState = options.providerState
            or projection and projection.providerState
            or ca.providerState,
        traderRole = role,
        capabilities = capabilities,
        factionID = faction.factionID,
        factionName = faction.factionName,
        factionArchetypeID = faction.factionArchetypeID,
        factionPresentation = faction.factionPresentation,
        communityID = faction.communityID,
        conversationMode = options.mode or "radio",
        identity = identity,
        knownNickname = knowledge and knowledge.knownNickname,
        knownSurname = knowledge and knowledge.knownSurname,
        knowledge = knowledge,
    }
end

local function createService(
    view,
    traderID,
    actorID,
    name,
    projection,
    record,
    options,
    knowledge
)
    local Service = actorService()
    if not Service then return nil, "core_actor_service_unavailable" end
    local context = contextFor(
        traderID,
        actorID,
        name,
        projection,
        record,
        options,
        knowledge
    )
    local session = view and view.session
    local service, reason = Service.New({
        actor = actorFor(projection, actorID, name),
        policy = policyFor(traderID),
        context = context,
        authority = "client",
        conversationID = session and session.conversationID,
        responsePlanner = function(_, result)
            return result and result.decision
                and result.decision.response or nil
        end,
    })
    if not service then
        return nil, reason or "core_actor_service_create_failed"
    end
    return service
end

local function semanticResult(
    view,
    traderID,
    actorID,
    name,
    projection,
    record,
    value,
    result
)
    for _, part in ipairs(result and result.parts or {}) do
        local decision = part and part.decision or nil
        if decision and decision.action
            == (DTCommon.TRADE_ACTION_ID or "DT.trade")
        then
            local client = DTCommon and DTCommon.Client or nil
            if client and type(client.OpenTrader) == "function" then
                local opened, reason = client.OpenTrader(traderID, {
                    mode = "trade",
                    actorID = actorID,
                    npcID = actorID,
                    provider = projection and projection.provider
                        or record and record.ca
                        and record.ca.provider,
                })
                if opened ~= true then
                    return false, reason or "trade_unavailable"
                end
            else
                return false, "trade_unavailable"
            end
        end
    end
    return true
end

local function semanticInputFactory(bounds, partOptions)
    local loaded, input = pcall(
        require,
        "PsychopatzCore/UI/Conversation/PsychopatzActorConversationInput"
    )
    if not loaded or type(input) ~= "table"
        or type(input.CreatePart) ~= "function"
    then
        return nil
    end
    partOptions = type(partOptions) == "table" and partOptions or {}
    return input.CreatePart(bounds, {
        owner = partOptions.owner,
        definition = partOptions.definition,
        spec = partOptions.spec,
    })
end

function Conversation.OpenForNPC(entry, player)
    local npcID = tostring(entry and entry.id or "")
    local traderID, record = traderForNPC(npcID)
    if not traderID then return false, "trader_not_found" end

    local ca = record and record.ca or {}
    local provider = tostring(ca.provider or "")
    local transport = Conversation.ProviderTransports[provider]
    if type(transport) ~= "function" then
        return false, "physical_trader_transport_unavailable"
    end
    return transport(
        traderID,
        entry,
        player,
        {
            mode = "physical",
            npcID = npcID,
            actorID = npcID,
            displayName = entry and entry.name,
        }
    )
end

function Conversation.CanOpenNPC(entry)
    local npcID = tostring(entry and entry.id or "")
    local traderID, record = traderForNPC(npcID)
    if not traderID then return false end
    local ca = record and record.ca or {}
    local provider = tostring(ca.provider or "")
    return type(Conversation.ProviderTransports[provider]) == "function"
end

function Conversation.RegisterExternalOpener(openers)
    if not openers or type(openers.Register) ~= "function" then
        return false, "conversation_opener_registry_unavailable"
    end
    return openers.Register({
        id = Conversation.EXTERNAL_OPENER_ID,
        priority = 100,
        canOpen = Conversation.CanOpenNPC,
        open = function(entry, player)
            return Conversation.OpenForNPC(entry, player)
        end,
    })
end

function Conversation.BuildSpec(traderID, actorID, options)
    traderID = tostring(traderID or "")
    actorID = tostring(actorID or "")
    options = type(options) == "table" and options or {}
    if traderID == "" then return nil, "trader_required" end
    if actorID == "" then return nil, "core_actor_required" end

    local record = recordFor(traderID)
    if not record then return nil, "trader_not_found" end
    local sourceActorID = actorID
    local projection, resolution = resolveActorReference(actorID)
    if not projection then
        if CoreClient
            and type(CoreClient.RequestActorsIfDue) == "function"
        then
            CoreClient.RequestActorsIfDue(1000)
            return nil, "core_actor_projection_pending"
        elseif CoreClient
            and type(CoreClient.RequestActors) == "function"
        then
            CoreClient.RequestActors()
            return nil, "core_actor_projection_pending"
        end
        return nil, "actor_identity_unresolved"
    end
    actorID = tostring(
        resolution and resolution.canonicalActorID
            or projection.actorID
            or actorID
    )
    local portrait = CoreClient.GetPortraitSpec(projection)
    if not portrait then
        return nil, "core_actor_portrait_unavailable"
    end
    local ca = record.ca or {}
    local knowledge = actorKnowledge(actorID, projection, options, record)
    local canonicalName = displayName(projection, record, options.displayName)
    local identity = knowledge.identity
    if not identity and knowledge.nameKnown ~= false then
        identity = identityParts(projection, record, canonicalName)
    end
    local name = knowledge.nameKnown == false
        and "Stranger"
        or knowledge.knownName or canonicalName
    local faction = factionContext(projection, record)
    if knowledge.factionKnown == true then
        faction.factionID = knowledge.factionID or faction.factionID
        faction.factionName = knowledge.factionName or faction.factionName
    end
    local roster, rosterIndex = rosterFor(
        record, actorID, options.roster)
    local role = roleFor(projection, options)
    local tradeAvailable = canTrade(projection, role)

    local semanticOptions = {
        provider = options.provider
            or projection.provider
            or ca.provider
            or "DynamicTrading",
        providerState = options.providerState
            or projection.providerState
            or ca.providerState,
        mode = options.mode or "radio",
        role = role,
    }

    local relationship = projection.relationship
        or projection.social and projection.social.relationship
    if type(relationship) ~= "table" then
        relationship = { approval = 0 }
    elseif relationship.approval == nil then
        local relationshipCopy = {}
        for key, value in pairs(relationship) do
            relationshipCopy[key] = value
        end
        relationshipCopy.approval = 0
        relationship = relationshipCopy
    end

    local conversationContext = {
        actorID = actorID,
        sourceActorID = sourceActorID,
        traderID = traderID,
        npcID = actorID,
        npcName = name,
        provider = semanticOptions.provider,
        providerState = semanticOptions.providerState,
        factionID = faction.factionID,
        factionName = faction.factionName,
        factionArchetypeID = faction.factionArchetypeID,
        factionPresentation = faction.factionPresentation,
        communityID = faction.communityID,
        conversationMode = semanticOptions.mode,
        traderRole = role,
        capabilities = tradeAvailable
            and { [DTCommon.TRADE_CAPABILITY or "DT.trade"] = true }
            or {},
        strictCapabilities = true,
        relationship = relationship,
        identityState = knowledge.state,
        identityNameKnown = knowledge.nameKnown ~= false,
        knownName = knowledge.knownName,
        identity = identity,
        knownNickname = knowledge.knownNickname,
        knownSurname = knowledge.knownSurname,
        nicknameKnown = knowledge.nicknameKnown == true,
        surnameKnown = knowledge.surnameKnown == true,
        factionKnown = knowledge.factionKnown ~= false,
        knowledgeRevision = knowledge.revision,
        knowledge = knowledge,
    }

    local landing = Landing.Build({
        context = conversationContext,
        landingID = "landing",
        greetingCategory = "greeting",
        greetingFallback = localizedText(
            TRADE_TEXT_SOURCE,
            "opening.trade",
            "What do you need?"
        ),
        seed = actorID,
        actionFilter = function(action)
            return action.sourceKind == "dynamic_trading"
                or string.find(
                    tostring(action.id or ""),
                    "^DT%."
                ) ~= nil
        end,
        actionChoice = function(action)
            if action.id == (DTCommon.TRADE_ACTION_ID or "DT.trade") then
                return {
                    id = action.id,
                    text = localizedText(
                        TRADE_TEXT_SOURCE,
                        "choice.trade",
                        "Open trading"
                    ),
                    response = localizedText(
                        TRADE_TEXT_SOURCE,
                        "response.trade",
                        "Let's see what we can trade."
                    ),
                    action = function()
                        local client = DTCommon and DTCommon.Client
                        if client
                            and type(client.OpenTrader) == "function"
                        then
                            return client.OpenTrader(traderID, {
                                mode = "trade",
                                actorID = actorID,
                                npcID = actorID,
                                provider = semanticOptions.provider,
                            })
                        end
                        return false, "trade_unavailable"
                    end,
                }
            end
            if action.id == (DTCommon.REFERRAL_ACTION_ID or "DT.referral") then
                return {
                    id = action.id,
                    text = localizedText(
                        REFERRAL_TEXT_SOURCE,
                        "choice.trader_referral",
                        "Ask who handles trades"
                    ),
                    response = localizedText(
                        REFERRAL_TEXT_SOURCE,
                        "response.trader_referral",
                        "The caravan's merchant handles the deals."
                    ),
                }
            end
            if action.id == (DTCommon.RUMORS_ACTION_ID or "DT.rumors") then
                return {
                    id = action.id,
                    text = "Any road news?",
                    response = function()
                        return newsResponse(traderID)
                    end,
                }
            end
            return {
                id = action.id,
                text = action.fallbackText or action.label or action.id,
                response = "I can help with that part of the caravan's work.",
            }
        end,
        choices = function()
            local choices = foundationIdentityChoices(
                conversationContext,
                knowledge,
                name
            )
            choices[#choices + 1] = {
                id = "core.small_talk.weather",
                text = localizedText(
                    SMALL_TALK_TEXT_SOURCE,
                    "choice.weather",
                    "Some weather we're having."
                ),
                response = localizedText(
                    SMALL_TALK_TEXT_SOURCE,
                    "response.weather",
                    "At least rain covers our footsteps."
                ),
                order = 60,
            }
            choices[#choices + 1] = {
                    id = "next_person",
                    text = "Talk to the next person.",
                    visible = #roster > 1,
                    response = "Let's see who else is with us.",
                    action = function(_, _, session)
                        local nextIndex = rosterIndex + 1
                        if nextIndex > #roster then nextIndex = 1 end
                        local nextActorID = roster[nextIndex]
                        local nextSpec, nextReason =
                            Conversation.BuildSpec(
                                traderID,
                                nextActorID,
                                {
                                    mode = options.mode,
                                    provider = semanticOptions.provider,
                                    providerState = semanticOptions.providerState,
                                    roster = roster,
                                    rosterIndex = nextIndex,
                                }
                            )
                        if not nextSpec then
                            return false, nextReason
                        end
                        local view = session and session.view
                        if not view
                            or type(view.refreshConversationSpec)
                                ~= "function"
                        then
                            return false, "conversation_view_unavailable"
                        end
                        view:refreshConversationSpec(nextSpec)
                        return true
                    end,
                    order = 70,
                }
            choices[#choices + 1] = {
                    id = "destination",
                    text = "Where are you heading?",
                    response = function()
                        return destinationResponse(recordFor(traderID))
                    end,
                    order = 80,
                }
            choices[#choices + 1] = {
                    id = "origin",
                    text = "Where did you come from?",
                    response = function()
                        return originResponse(recordFor(traderID))
                    end,
                    order = 90,
                }
            choices[#choices + 1] = {
                    id = "goodbye",
                text = localizedText(
                    GOODBYE_TEXT_SOURCE,
                    "choice.goodbye",
                    "That's all. Stay safe."
                ),
                response = localizedText(
                    GOODBYE_TEXT_SOURCE,
                    "response.goodbye",
                    "You too."
                ),
                    close = true,
                    order = 100,
                }
            return choices
        end,
    })

    local spec = {
        namespace = DTCommon.TRADER_NAMESPACE or "DT.trader",
        npcID = actorID,
        sourceActorID = sourceActorID,
        npcName = name,
        persistHistory = true,
        animateOpening = true,
        portrait = portrait,
        context = conversationContext,
        roster = roster,
        rosterIndex = rosterIndex,
        role = role,
        knowledge = knowledge,
        knowledgeKey = knowledgeKey(knowledge),
        actorConversation = {
            id = DTCommon.TRADER_NAMESPACE or "DT.trader",
            createService = function(view)
                return createService(
                    view,
                    traderID,
                    actorID,
                    name,
                    projection,
                    recordFor(traderID) or record,
                    semanticOptions,
                    knowledge
                )
            end,
            buildContext = function()
                return contextFor(
                    traderID,
                    actorID,
                    name,
                    projection,
                    recordFor(traderID) or record,
                    semanticOptions,
                    knowledge
                )
            end,
            onResult = function(view, value, result)
                return semanticResult(
                    view,
                    traderID,
                    actorID,
                    name,
                    projection,
                    recordFor(traderID) or record,
                    value,
                    result
                )
            end,
        },
        extensionParts = {
            {
                partID = "llmInput",
                title = {
                    key = "UI_PsychopatzConversation_Panel_LLMInput",
                    fallback = "TYPE TO TALK",
                },
                factory = semanticInputFactory,
            },
        },
        start = landing.start,
        nodes = landing.nodes,
        semanticActions = landing.actions,
        greetingBlock = landing.greetingBlock,
    }
    spec.refreshPresentation = function()
        local refreshOptions = {}
        for key, value in pairs(options) do refreshOptions[key] = value end
        refreshOptions.roster = roster
        refreshOptions.rosterIndex = rosterIndex
        local refreshed = Conversation.BuildSpec(
            traderID,
            actorID,
            refreshOptions
        )
        if refreshed and refreshed.knowledgeKey ~= spec.knowledgeKey then
            return refreshed
        end
        return nil
    end
    return spec
end

function Conversation.Open(traderID, actorID, options)
    options = type(options) == "table" and options or {}
    local spec, reason = Conversation.BuildSpec(
        traderID,
        actorID,
        options
    )
    if not spec then
        if reason == "core_actor_projection_pending"
            and options._pendingRetry ~= true
        then
            queuePendingOpen(traderID, actorID, options)
        end
        return nil, reason
    end

    local core = PsychopatzCore and PsychopatzCore.Conversation or nil
    if not core or type(core.Open) ~= "function" then
        local ok, loaded = pcall(
            require,
            "PsychopatzCore/UI/Conversation/PsychopatzConversation"
        )
        core = ok and loaded
            or PsychopatzCore and PsychopatzCore.Conversation
            or nil
    end
    if not core or type(core.Open) ~= "function" then
        return nil, "core_conversation_unavailable"
    end
    return core.Open(spec)
end

return Conversation
