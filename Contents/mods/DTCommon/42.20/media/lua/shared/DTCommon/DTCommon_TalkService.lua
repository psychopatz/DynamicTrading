-- Server-authorized DynamicTrading bridge to Core's actor conversation
-- service.  DTCommon owns the trader binding and access gate; Core owns the
-- parser/router/state and actor identity.  No trade endpoint is reachable
-- from this service and no stock, budget, quote, or player inventory state is
-- copied into a talk session.
DTCommon = DTCommon or {}
local Service = DTCommon.TalkService or {}
DTCommon.TalkService = Service

local loaded, ActorService = pcall(require,
    "PsychopatzCore/Conversation/PsychopatzActorConversationService")
if not loaded or type(ActorService) ~= "table"
    or type(ActorService.New) ~= "function"
then
    ActorService = nil
end

local Policy = DTCommon.CoreActorPolicy
local TraderService = DTCommon.TraderService
local WorldKnowledge = DTCommon.WorldKnowledge
local MAX_SESSIONS = 64
local MAX_REQUESTS = 32
local MAX_TEXT = 4000

Service.VERSION = 1
Service.Sessions = Service.Sessions or {}
Service.SessionOrder = Service.SessionOrder or {}
Service.Serial = tonumber(Service.Serial) or 0

local PlacePresentation = DTCommon.PlacePresentation or {}
DTCommon.PlacePresentation = PlacePresentation

PlacePresentation.Resolvers = PlacePresentation.Resolvers or {}

function PlacePresentation.RegisterResolver(id, resolverFn, priority)
    if not id or type(resolverFn) ~= "function" then return false end
    PlacePresentation.Resolvers[id] = {
        fn = resolverFn,
        priority = tonumber(priority) or 50,
    }
    return true
end

function PlacePresentation.UnregisterResolver(id)
    if not id then return false end
    PlacePresentation.Resolvers[id] = nil
    return true
end

function PlacePresentation.IsMachineIdentifier(id)
    if type(id) ~= "string" or id == "" then return true end
    if string.find(id, "^community_")
        or string.find(id, "^settlement_[%d_]+")
        or string.find(id, "^loc_[%d_]+")
        or string.find(id, "^actor:")
        or string.find(id, "^id_[%d_]+")
    then
        return true
    end
    return false
end

function PlacePresentation.Resolve(placeID, context)
    if not placeID or placeID == "" then return nil end
    local str = tostring(placeID)

    -- 1. Try registered resolvers in priority order
    local list = {}
    for id, entry in pairs(PlacePresentation.Resolvers) do
        list[#list + 1] = { id = id, fn = entry.fn, priority = entry.priority }
    end
    table.sort(list, function(a, b) return a.priority > b.priority end)

    for _, entry in ipairs(list) do
        local ok, name = pcall(entry.fn, str, context)
        if ok and type(name) == "string" and name ~= "" and name ~= str and not PlacePresentation.IsMachineIdentifier(name) then
            return name
        end
    end

    -- 2. Try WorldKnowledge facts if present in context
    if context and context.worldKnowledge and type(context.worldKnowledge.candidates) == "table" then
        for _, cand in ipairs(context.worldKnowledge.candidates) do
            if cand.payload and (cand.payload.marketID == str or cand.payload.scopeID == str or cand.payload.communityID == str) then
                if cand.payload.marketName and not PlacePresentation.IsMachineIdentifier(cand.payload.marketName) then
                    return cand.payload.marketName
                end
                if cand.payload.name and not PlacePresentation.IsMachineIdentifier(cand.payload.name) then
                    return cand.payload.name
                end
            end
        end
    end

    -- 3. If translation exists (e.g. DTCommon.T)
    if DTCommon and type(DTCommon.T) == "function" then
        local translated = DTCommon.T("Place_" .. str, nil)
        if translated and translated ~= "" and translated ~= ("Place_" .. str) then
            return translated
        end
    end

    -- 4. If it is a machine identifier and was not resolved, do NOT expose it to player dialogue!
    if PlacePresentation.IsMachineIdentifier(str) then
        return nil, "unpresentable_machine_id"
    end

    -- 5. Otherwise, assume human-authored string (e.g. "Riverside", "West Point Outpost")
    return str
end

local function authority()
    return DTCommon.Storage
        and type(DTCommon.Storage.IsAuthority) == "function"
        and DTCommon.Storage.IsAuthority() == true
end

local function playerKey(player)
    if PsychopatzCore and PsychopatzCore.Actors and PsychopatzCore.Actors.PlayerIdentity
        and type(PsychopatzCore.Actors.PlayerIdentity.GetTargetKey) == "function"
    then
        local canonical = PsychopatzCore.Actors.PlayerIdentity.GetTargetKey(player)
        if canonical then return canonical end
    end
    if player and type(player.getUsername) == "function" then
        local value = player:getUsername()
        if value ~= nil and tostring(value) ~= "" then
            return "player:user:" .. tostring(value)
        end
    end
    if player and type(player.getOnlineID) == "function" then
        local value = player:getOnlineID()
        if value ~= nil then return "player:online:" .. tostring(value) end
    end
    return "player:object:" .. tostring(player)
end

local function boundedText(value, maximum)
    value = tostring(value or "")
    maximum = tonumber(maximum) or MAX_TEXT
    return #value > maximum and string.sub(value, 1, maximum) or value
end

local function now()
    local gameTime = getGameTime and getGameTime() or nil
    if gameTime and type(gameTime.getWorldAgeHours) == "function" then
        return tonumber(gameTime:getWorldAgeHours()) or 0
    end
    return 0
end

local function sessionKey(key, traderID, mode)
    return tostring(key) .. "\031" .. tostring(traderID)
        .. "\031" .. tostring(mode)
end

local function sessionID(key, traderID)
    Service.Serial = Service.Serial + 1
    return "dt-talk:" .. tostring(Service.Serial) .. ":"
        .. tostring(key) .. ":" .. tostring(traderID)
end

local function knowledgeFor(session)
    if not WorldKnowledge
        or type(WorldKnowledge.BuildConversationContext) ~= "function"
    then return nil end
    return WorldKnowledge.BuildConversationContext(session.traderID, {
        now = now(),
        max = 4,
        renderFact = session.renderFact,
    })
end

local function actorFor(record)
    if not Policy or type(Policy.ResolveActor) ~= "function" then
        return nil, "core_actor_policy_unavailable"
    end
    return Policy.ResolveActor(record)
end

local function remember(session)
    local key = session.key
    if not Service.Sessions[key] then
        Service.SessionOrder[#Service.SessionOrder + 1] = key
    end
    Service.Sessions[key] = session
    while #Service.SessionOrder > MAX_SESSIONS do
        local oldest = table.remove(Service.SessionOrder, 1)
        Service.Sessions[oldest] = nil
    end
end

local function snapshot(session, result)
    local state = session.service and session.service:Snapshot() or nil
    local knowledge = knowledgeFor(session)
    return {
        schemaVersion = Service.VERSION,
        accepted = true,
        sessionID = session.id,
        traderID = session.traderID,
        actorID = session.actorID,
        mode = session.mode,
        providerRevision = session.providerRevision,
        openedAt = session.openedAt,
        lastAt = session.lastAt,
        result = result,
        state = state,
        worldKnowledge = knowledge,
    }
end

local function access(player, traderID, mode)
    if not TraderService
        or type(TraderService.ValidateTalkAccess) ~= "function"
    then
        return nil, "trader_access_service_unavailable"
    end
    local record = TraderService.GetRecord(traderID)
    if not record then return nil, "trader_not_found" end
    local allowed, reason = TraderService.ValidateTalkAccess(
        player, traderID, mode)
    if not allowed then return nil, reason end
    return record
end

function Service.Open(player, traderID, mode, options)
    local providerRevision
    if not authority() then return nil, "server_authority_required" end
    if not ActorService then return nil, "core_conversation_unavailable" end
    traderID = boundedText(traderID, 128)
    mode = tostring(mode or "radio")
    if traderID == "" then return nil, "trader_required" end
    if mode ~= "radio" and mode ~= "physical" then
        return nil, "talk_mode_invalid"
    end
    local record, accessReason = access(player, traderID, mode)
    if not record then return nil, accessReason end
    local actor, actorReason = actorFor(record)
    if not actor then return nil, actorReason end
    providerRevision = tonumber(record.ca and record.ca.providerRevision) or 0
    local key = sessionKey(playerKey(player), traderID, mode)
    local existing = Service.Sessions[key]
    if existing and existing.actorID == actor.actorId
        and tonumber(existing.providerRevision) == providerRevision
    then
        return snapshot(existing)
    end
    if existing then Service.Sessions[key] = nil end

    local session = {
        key = key,
        id = sessionID(playerKey(player), traderID),
        traderID = traderID,
        actorID = tostring(actor.actorId or actor.id or ""),
        mode = mode,
        providerRevision = providerRevision,
        openedAt = now(),
        lastAt = now(),
        requests = {},
        requestOrder = {},
        renderFact = nil,
    }
    if session.actorID == "" then return nil, "core_actor_required" end
    local conversation, conversationReason = ActorService.New({
        actor = actor,
        authority = "server",
        conversationID = session.id,
        responsePlanner = function(_, result, _, context)
            local decision = result and result.decision or {}
            local gossip = context and context.npcGossip or nil
            local worldKnowledge = context and context.worldKnowledge or nil
            local policy = context and context.policy or nil
            local traderRecord = context and context.traderRecord or nil
            local intent = result and result.ir and result.ir.intent
            local topic = result and result.ir and (result.ir.topic or (result.ir.analysis and result.ir.analysis.topic))
            local act = result and result.ir and result.ir.speechAct
            local factClass = result and result.ir and result.ir.factClass
            local rawText = result and result.ir and string.lower(result.ir.rawText or "")
            local Semantics = PsychopatzCore and PsychopatzCore.Semantics

            if intent == "GREETING" and Semantics and Semantics.SelectDialogueBlock then
                local block = Semantics.SelectDialogueBlock("greeting", context, session.id)
                if block and block.nodes and block.nodes[block.entryNode] then
                    local node = block.nodes[block.entryNode]
                    return {
                        key = node.textKey,
                        fallback = node.fallback or node.text,
                    }
                end
                return { key = "DTCommon_Talk_Greeting", fallback = "Hello traveler." }
            end

            if intent == "FAREWELL" and Semantics and Semantics.SelectDialogueBlock then
                local block = Semantics.SelectDialogueBlock("farewell", context, session.id)
                if block and block.nodes and block.nodes[block.entryNode] then
                    local node = block.nodes[block.entryNode]
                    return {
                        key = node.textKey,
                        fallback = node.fallback or node.text,
                    }
                end
                return { key = "DTCommon_Talk_Farewell", fallback = "Safe travels out there." }
            end

            if intent == "TRADE" then
                return {
                    key = "DTCommon_Talk_Opening_Trade",
                    fallback = "Let's trade.",
                }
            end

            -- 1. Caravan story / storytelling (Authored non-factual flavor)
            if factClass == "caravan_story"
                or string.find(rawText, "caravan story", 1, true)
                or string.find(rawText, "tell me a story", 1, true)
            then
                return {
                    key = "DTCommon_Talk_Caravan_Story",
                    fallback = "I remember a run through Muldraugh back when the fog was thick... barely made it out with the wagon wheels intact.",
                }
            end

            -- 2. Trader location ("where is the trader")
            if factClass == "trader_location" or string.find(rawText, "where is the trader", 1, true) then
                local role = context and context.traderRole or "trader"
                if role ~= "guard" then
                    return {
                        key = "DTCommon_Talk_Trader_Here",
                        fallback = "I'm the caravan trader. I'm right here if you need supplies or goods.",
                    }
                else
                    local loc = (traderRecord and (traderRecord.location or traderRecord.x))
                        or (policy and policy.currentSettlementID)
                    if loc then
                        return {
                            key = "DTCommon_Talk_Trader_Located",
                            fallback = "The merchant is located at " .. tostring(loc) .. ".",
                            evidence = tostring(loc),
                        }
                    else
                        return {
                            key = "DTCommon_Talk_Trader_Unknown",
                            fallback = "I don't have the merchant's exact location right now.",
                        }
                    end
                end
            end

            -- 3. Destination ("where are you heading", "what settlement are you going to", "where are you going")
            if factClass == "destination"
                or string.find(rawText, "where are you heading", 1, true)
                or string.find(rawText, "where are you going", 1, true)
                or string.find(rawText, "settlement are you going", 1, true)
                or string.find(rawText, "destination", 1, true)
            then
                local destID = (context and context.destination)
                    or (policy and (policy.destinationSettlementID or policy.destination or policy.nextSettlementID))
                    or (traderRecord and (traderRecord.destination or traderRecord.destinationSettlementID))
                local destName = destID and PlacePresentation.Resolve(destID, context) or nil
                if not destName and gossip and gossip.statements and #gossip.statements > 0 then
                    for i, stmt in ipairs(gossip.statements) do
                        if string.find(string.lower(stmt), "heading", 1, true)
                            or string.find(string.lower(stmt), "destination", 1, true)
                        then
                            return {
                                key = "DTCommon_Talk_Destination_Gossip",
                                fallback = stmt,
                                evidence = gossip.factRefs and gossip.factRefs[i],
                            }
                        end
                    end
                end
                if destName then
                    return {
                        key = "DTCommon_Talk_Destination_Grounded",
                        fallback = "We are heading toward " .. tostring(destName) .. ".",
                        evidence = tostring(destID),
                    }
                else
                    return {
                        key = "DTCommon_Talk_Destination_Unknown",
                        fallback = "I cannot confirm where we are heading next; route orders haven't been finalized.",
                    }
                end
            end

            -- 4. Origin ("where did you come from", "where are you from")
            if factClass == "origin"
                or string.find(rawText, "where did you come from", 1, true)
                or string.find(rawText, "where are you from", 1, true)
            then
                local origID = (context and context.origin)
                    or (policy and (policy.originSettlementID or policy.lastSettlementID or policy.homeSettlementID or policy.origin))
                    or (traderRecord and (traderRecord.origin or traderRecord.originSettlementID or traderRecord.lastSettlementID))
                local origName = origID and PlacePresentation.Resolve(origID, context) or nil
                if origName then
                    return {
                        key = "DTCommon_Talk_Origin_Grounded",
                        fallback = "We came from " .. tostring(origName) .. ".",
                        evidence = tostring(origID),
                    }
                else
                    return {
                        key = "DTCommon_Talk_Origin_Unknown",
                        fallback = "I don't have confirmed departure records for this caravan.",
                    }
                end
            end

            -- 5. Settlement ("where is the settlement", "what settlement")
            if factClass == "settlement"
                or string.find(rawText, "where is the settlement", 1, true)
                or string.find(rawText, "what settlement", 1, true)
            then
                local settID = (context and context.settlement)
                    or (policy and (policy.currentSettlementID or policy.homeSettlementID or policy.settlementID))
                    or (traderRecord and (traderRecord.currentSettlementID or traderRecord.homeSettlementID or traderRecord.settlementID))
                local settName = settID and PlacePresentation.Resolve(settID, context) or nil
                if settName then
                    return {
                        key = "DTCommon_Talk_Settlement_Grounded",
                        fallback = "Our primary trading settlement is " .. tostring(settName) .. ".",
                        evidence = tostring(settID),
                    }
                else
                    return {
                        key = "DTCommon_Talk_Settlement_Unknown",
                        fallback = "I have no confirmed reports on nearby settlements right now.",
                    }
                end
            end

            -- 6. Road News / Gossip / Rumors
            if factClass == "road_news"
                or intent == "GOSSIP" or intent == "GOSSIP_RECEIVED"
                or act == "act.trade.ask_rumors"
                or string.find(rawText, "road news", 1, true)
                or string.find(rawText, "news", 1, true)
            then
                local statements = (gossip and type(gossip.statements) == "table" and gossip.statements)
                    or (worldKnowledge and type(worldKnowledge.statements) == "table" and worldKnowledge.statements)
                if statements and #statements > 0 then
                    return {
                        key = "DTCommon_WorldKnowledge_Gossip",
                        fallback = statements[1],
                        evidence = (gossip and gossip.factRefs and gossip.factRefs[1])
                            or (worldKnowledge and worldKnowledge.factRefs and worldKnowledge.factRefs[1]),
                    }
                else
                    return {
                        key = "DTCommon_WorldKnowledge_NoNews",
                        fallback = "I haven't heard any news lately.",
                    }
                end
            end

            -- 7. General whereabouts / routes
            if act == "act.trade.ask_whereabouts" or topic == "whereabouts" or intent == "WHEREABOUTS" then
                if gossip and type(gossip.statements) == "table" and #gossip.statements > 0 then
                    return {
                        key = "DTCommon_WorldKnowledge_Whereabouts",
                        fallback = gossip.statements[1],
                        evidence = gossip.factRefs and gossip.factRefs[1],
                    }
                end
                local locID = (context and (context.destination or context.settlement))
                    or (policy and (policy.destinationSettlementID or policy.currentSettlementID or policy.homeSettlementID))
                local locName = locID and PlacePresentation.Resolve(locID, context) or nil
                if locName then
                    return {
                        key = "DTCommon_Talk_Route_Grounded",
                        fallback = "We are currently operating around " .. tostring(locName) .. ".",
                        evidence = tostring(locID),
                    }
                end
                return {
                    key = "DTCommon_Talk_Whereabouts_Unknown",
                    fallback = "I have no confirmed route updates to share right now.",
                }
            end

            -- 8. Identity questions ("who are you", "who handles trading", "who is in charge")
            if (act == "act.trade.ask_who" or topic == "identity" or intent == "QUESTION") and Semantics and Semantics.SelectDialogueBlock then
                local block = Semantics.SelectDialogueBlock("identity", context, session.id)
                if block and block.nodes and block.nodes[block.entryNode] then
                    local node = block.nodes[block.entryNode]
                    return {
                        key = node.textKey,
                        fallback = node.fallback or node.text,
                    }
                end
            end

            if type(decision.response) == "table" then
                return decision.response
            end
            if intent == "QUESTION" then
                return {
                    key = "DTCommon_Talk_Uncertain",
                    fallback = "I can only share what I can confirm.",
                }
            end
            return {
                key = "DTCommon_Talk_Acknowledgement",
                fallback = "I hear you.",
            }
        end,
        localize = function(keyValue, _, _, fallback)
            if DTCommon and type(DTCommon.T) == "function" then
                return DTCommon.T(keyValue, fallback)
            end
            return fallback
        end,
    })
    if not conversation then
        return nil, conversationReason or "core_conversation_create_failed"
    end
    session.service = conversation
    remember(session)
    return snapshot(session)
end

function Service.Submit(player, traderID, talkSessionID, text, options)
    local providerRevision
    if not authority() then return nil, "server_authority_required" end
    options = type(options) == "table" and options or {}
    traderID = boundedText(traderID, 128)
    local mode = tostring(options.mode or "radio")
    local key = sessionKey(playerKey(player), traderID, mode)
    local session = Service.Sessions[key]
    if not session or session.id ~= tostring(talkSessionID or "") then
        return nil, "talk_session_invalid"
    end
    local record, accessReason = access(player, traderID, mode)
    if not record then return nil, accessReason end
    if tostring(record.ca and record.ca.actorID or "") ~= session.actorID then
        return nil, "actor_binding_changed"
    end
    providerRevision = tonumber(record.ca and record.ca.providerRevision) or 0
    if providerRevision ~= tonumber(session.providerRevision or 0) then
        return nil, "talk_provider_changed"
    end
    text = boundedText(text, MAX_TEXT)
    if text == "" then return nil, "utterance_required" end
    local requestID = boundedText(options.requestID, 128)
    if requestID ~= "" and session.requests[requestID] then
        return session.requests[requestID]
    end
    local knowledge = knowledgeFor(session)
    local policy = Policy and type(Policy.Get) == "function" and Policy.Get(record)
    local context = {
        source = "dynamictrading",
        mode = mode,
        traderID = traderID,
        playerKey = playerKey(player),
        traderRecord = record,
        policy = policy,
        destination = options.destination
            or (policy and (policy.destinationSettlementID or policy.destination or policy.nextSettlementID))
            or (record and (record.destination or record.destinationSettlementID)),
        origin = options.origin
            or (policy and (policy.originSettlementID or policy.lastSettlementID or policy.origin))
            or (record and (record.origin or record.originSettlementID or record.lastSettlementID)),
        settlement = options.settlement
            or (policy and (policy.currentSettlementID or policy.homeSettlementID or policy.settlementID))
            or (record and (record.currentSettlementID or record.homeSettlementID or record.settlementID)),
        traderRole = (record.ca and record.ca.role) or (policy and policy.role) or "trader",
        worldKnowledge = options.worldKnowledge or (knowledge and knowledge.worldKnowledge) or nil,
        npcGossip = options.npcGossip or (knowledge and knowledge.npcGossip) or nil,
        capabilities = {
            ["core.conversation"] = true,
            ["dynamictrading.trade"] = true,
            ["dynamictrading.radio"] = mode == "radio",
        },
    }
    local result, reason = session.service:Submit(text, context, {
        language = boundedText(options.language, 16),
        collectActions = true,
    })
    if not result then return nil, reason end
    session.lastAt = now()
    local output = snapshot(session, result)
    if requestID ~= "" then
        session.requests[requestID] = output
        session.requestOrder[#session.requestOrder + 1] = requestID
        while #session.requestOrder > MAX_REQUESTS do
            local oldest = table.remove(session.requestOrder, 1)
            session.requests[oldest] = nil
        end
    end
    return output
end

function Service.Close(player, traderID, talkSessionID, mode)
    if not authority() then return false, "server_authority_required" end
    local key = sessionKey(playerKey(player), boundedText(traderID, 128),
        tostring(mode or "radio"))
    local session = Service.Sessions[key]
    if not session or session.id ~= tostring(talkSessionID or "") then
        return false, "talk_session_invalid"
    end
    Service.Sessions[key] = nil
    return true
end

function Service.Count()
    local count = 0
    for _, _ in pairs(Service.Sessions) do count = count + 1 end
    return count
end

return Service
