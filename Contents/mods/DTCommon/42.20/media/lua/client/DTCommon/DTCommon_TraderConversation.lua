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
        local matched = tostring(ca.actorID or "") == npcID
            or tostring(record.p or record.l or "") == npcID
        if not matched then
            for _, memberID in ipairs(record.m or {}) do
                if tostring(memberID) == npcID then
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

local function knowledgeKey(value)
    value = type(value) == "table" and value or {}
    return table.concat({
        tostring(value.state or ""),
        tostring(value.nameKnown == true),
        tostring(value.knownName or ""),
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
    return knowledge or {
        actorID = actorID,
        provider = provider,
        state = "known",
        nameKnown = true,
        knownName = displayName(projection, record),
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
    return "I haven't heard any news lately."
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
    options,
    knowledge
)
    local faction = factionContext(projection, record)
    local ca = record and record.ca or {}
    local role = roleFor(projection, options)
    local capabilities = {}
    if canTradeRole(role) then
        capabilities["dynamictrading.trade"] = true
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
    local projection = CoreClient.GetActor(actorID)
    if not projection then
        return nil, "core_actor_projection_unavailable"
    end
    local portrait = CoreClient.GetPortraitSpec(projection)
    if not portrait then
        return nil, "core_actor_portrait_unavailable"
    end
    local ca = record.ca or {}
    local knowledge = actorKnowledge(actorID, projection, options, record)
    local canonicalName = displayName(projection, record, options.displayName)
    local name = knowledge.nameKnown == false
        and "Unknown survivor"
        or knowledge.knownName or canonicalName
    local faction = factionContext(projection, record)
    if knowledge.factionKnown == true then
        faction.factionID = knowledge.factionID or faction.factionID
        faction.factionName = knowledge.factionName or faction.factionName
    end
    local roster, rosterIndex = rosterFor(
        record, actorID, options.roster)
    local role = roleFor(projection, options)
    local tradeAvailable = canTradeRole(role)

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

    local spec = {
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
            traderRole = role,
            capabilities = tradeAvailable
                and { ["dynamictrading.trade"] = true } or {},
            identityState = knowledge.state,
            identityNameKnown = knowledge.nameKnown ~= false,
            knownName = knowledge.knownName,
            factionKnown = knowledge.factionKnown ~= false,
            knowledgeRevision = knowledge.revision,
        },
        roster = roster,
        rosterIndex = rosterIndex,
        role = role,
        knowledge = knowledge,
        knowledgeKey = knowledgeKey(knowledge),
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
                        visible = tradeAvailable,
                        response = "Let's see what we can trade.",
                        action = function()
                            local client = DTCommon and DTCommon.Client
                            if client
                                and type(client.OpenTrader) == "function"
                            then
                                return client.OpenTrader(traderID, {
                                    mode = "trade",
                                    actorID = actorID,
                                    npcID = actorID,
                                    provider = projection.provider
                                        or ca.provider,
                                })
                            end
                            return false, "trade_unavailable"
                        end,
                        next = "root",
                    },
                    {
                        id = "identity",
                        text = "What's your name?",
                        response = function()
                            return identityResponse(knowledge, name)
                        end,
                        next = "root",
                    },
                    {
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
    if #roster <= 1 then
        -- Keep the single-actor contract compact and preserve the existing
        -- root choice order.  The roster switch is materialized only when
        -- there is another faction member to rotate to.
        table.remove(spec.nodes.root.choices, 3)
    end
    return spec
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
