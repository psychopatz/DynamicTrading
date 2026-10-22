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

local function authority()
    return DTCommon.Storage
        and type(DTCommon.Storage.IsAuthority) == "function"
        and DTCommon.Storage.IsAuthority() == true
end

local function playerKey(player)
    if player and type(player.getOnlineID) == "function" then
        local value = player:getOnlineID()
        if value ~= nil then return "online:" .. tostring(value) end
    end
    if player and type(player.getUsername) == "function" then
        local value = player:getUsername()
        if value ~= nil and tostring(value) ~= "" then
            return "user:" .. tostring(value)
        end
    end
    return "object:" .. tostring(player)
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
            local intent = result and result.ir and result.ir.intent
            if (intent == "GOSSIP" or intent == "GOSSIP_RECEIVED"
                or intent == "QUESTION") and gossip
                and type(gossip.statements) == "table"
                and type(gossip.statements[1]) == "string"
            then
                return {
                    key = "DTCommon_WorldKnowledge_Gossip",
                    fallback = gossip.statements[1],
                }
            end
            if (intent == "GOSSIP" or intent == "GOSSIP_RECEIVED")
                and gossip
            then
                return {
                    key = "DTCommon_WorldKnowledge_NoNews",
                    fallback = "I haven't heard any news lately.",
                }
            end
            if type(decision.response) == "table" then
                return decision.response
            end
            local intent = result and result.ir and result.ir.intent
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
    local context = knowledge and {
        worldKnowledge = knowledge.worldKnowledge,
        npcGossip = knowledge.npcGossip,
    } or nil
    local result, reason = session.service:Submit(text, context, {
        source = "dynamictrading",
        mode = mode,
        traderID = traderID,
        playerKey = playerKey(player),
    }, {
        language = boundedText(options.language, 16),
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
