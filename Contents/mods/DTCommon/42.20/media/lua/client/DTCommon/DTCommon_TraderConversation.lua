-- Shared Dynamic Trading trader conversation content/open path.
-- Provider modules authorize access and supply transport; this module owns the
-- trader-facing content and uses the Core conversation session shell.

DTCommon = DTCommon or {}
DTCommon.TraderConversation = DTCommon.TraderConversation or {}

local Conversation = DTCommon.TraderConversation
local CoreClient = require
    "PsychopatzCore/World/SurvivorWorld/PsychopatzSurvivorWorldClient"

Conversation.EXTERNAL_OPENER_ID = "dynamictrading.trader"
Conversation.ProviderTransports =
    Conversation.ProviderTransports or {}

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

local function traderForNPC(npcID)
    npcID = tostring(npcID or "")
    if npcID == "" then return nil, nil end
    local service = DTCommon and DTCommon.TraderService or nil
    if not service or type(service.ForEach) ~= "function" then
        return nil, nil
    end
    local foundID
    local foundRecord
    service.ForEach(function(traderID, record)
        if foundID or type(record) ~= "table" then return end
        local ca = type(record.ca) == "table" and record.ca or {}
        if tostring(ca.actorID or "") == npcID
            or tostring(record.p or record.l or "") == npcID
        then
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
    return tostring(
        fallback
            or projection and (
                projection.displayName
                    or projection.label
                    or projection.name
            )
            or record and record.n
            or "Trader"
    )
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
    return "I haven't heard any news lately."
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
            action = "dynamictrading.trade",
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
        then
            return {
                text = "I'm " .. tostring(context and context.npcName
                    or "the caravan trader") .. ".",
                branch = "IDENTITY_RECEIVED",
            }
        end
    end
    if intent == "GREETING" then
        return {
            text = "Good to see you. What can I trade for you today?",
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
                route = "dynamictrading.trader",
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
    return {
        actorId = actorID,
        id = actorID,
        identity = projection and projection.identity
            or { displayName = name },
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
    options
)
    local faction = factionContext(projection, record)
    local ca = record and record.ca or {}
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
        traderRole = "trader",
        capabilities = { ["dynamictrading.trade"] = true },
        factionID = faction.factionID,
        factionName = faction.factionName,
        factionArchetypeID = faction.factionArchetypeID,
        factionPresentation = faction.factionPresentation,
        communityID = faction.communityID,
        conversationMode = options.mode or "radio",
    }
end

local function createService(
    view,
    traderID,
    actorID,
    name,
    projection,
    record,
    options
)
    local Service = actorService()
    if not Service then return nil, "core_actor_service_unavailable" end
    local context = contextFor(
        traderID,
        actorID,
        name,
        projection,
        record,
        options
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
        if decision and decision.action == "dynamictrading.trade" then
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
            displayName = ca.n or entry and entry.name,
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

    local projection = CoreClient.GetActor(actorID)
    if not projection then
        return nil, "core_actor_projection_unavailable"
    end
    local portrait = CoreClient.GetPortraitSpec(projection)
    if not portrait then
        return nil, "core_actor_portrait_unavailable"
    end
    local record = recordFor(traderID)
    if not record then return nil, "trader_not_found" end
    local ca = record.ca or {}
    local name = displayName(projection, record, options.displayName)
    local faction = factionContext(projection, record)

    local semanticOptions = {
        provider = options.provider
            or projection.provider
            or ca.provider
            or "DynamicTrading",
        providerState = options.providerState
            or projection.providerState
            or ca.providerState,
        mode = options.mode or "radio",
    }

    return {
        namespace = "dynamictrading.trader",
        npcID = actorID,
        npcName = name,
        persistHistory = true,
        animateOpening = true,
        portrait = portrait,
        context = {
            actorID = actorID,
            traderID = traderID,
            npcName = name,
            provider = options.provider
                or projection.provider
                or ca.provider
                or "DynamicTrading",
            providerState = options.providerState
                or projection.providerState
                or ca.providerState,
            factionID = faction.factionID,
            factionName = faction.factionName,
            factionArchetypeID = faction.factionArchetypeID,
            factionPresentation = faction.factionPresentation,
            communityID = faction.communityID,
            conversationMode = options.mode or "radio",
        },
        actorConversation = {
            id = "dynamictrading.trader",
            createService = function(view)
                return createService(
                    view,
                    traderID,
                    actorID,
                    name,
                    projection,
                    recordFor(traderID) or record,
                    semanticOptions
                )
            end,
            buildContext = function()
                return contextFor(
                    traderID,
                    actorID,
                    name,
                    projection,
                    recordFor(traderID) or record,
                    semanticOptions
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
                    key = "UI_PsychopatzConversation_LLMInput",
                    fallback = "TYPE TO TALK",
                },
                factory = semanticInputFactory,
            },
        },
        start = "root",
        nodes = {
            root = {
                npc = { text = "What do you need?" },
                choices = {
                    {
                        id = "trade",
                        text = "Open trading",
                        response = "Let's see what we can trade.",
                        action = function()
                            local client = DTCommon and DTCommon.Client
                            if client
                                and type(client.OpenTrader) == "function"
                            then
                                return client.OpenTrader(traderID, {
                                    mode = "trade",
                                    actorID = actorID,
                                    provider = projection.provider
                                        or ca.provider,
                                })
                            end
                            return false, "trade_unavailable"
                        end,
                        next = "root",
                    },
                    {
                        id = "destination",
                        text = "Where are you heading?",
                        response = function()
                            return destinationResponse(recordFor(traderID))
                        end,
                        next = "root",
                    },
                    {
                        id = "origin",
                        text = "Where did you come from?",
                        response = function()
                            return originResponse(recordFor(traderID))
                        end,
                        next = "root",
                    },
                    {
                        id = "news",
                        text = "Any road news?",
                        response = function()
                            return newsResponse(traderID)
                        end,
                        next = "root",
                    },
                    {
                        id = "goodbye",
                        text = "Goodbye.",
                        response = "Stay safe.",
                        close = true,
                    },
                },
            },
        },
    }
end

function Conversation.Open(traderID, actorID, options)
    local spec, reason = Conversation.BuildSpec(
        traderID,
        actorID,
        options
    )
    if not spec then return nil, reason end

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
