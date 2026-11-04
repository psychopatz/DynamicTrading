-- Shared Dynamic Trading trader conversation content/open path.
-- Provider modules authorize access and supply transport; this module owns the
-- trader-facing content and uses the Core conversation session shell.

DTCommon = DTCommon or {}
DTCommon.TraderConversation = DTCommon.TraderConversation or {}

local Conversation = DTCommon.TraderConversation
local CoreClient = require
    "PsychopatzCore/World/SurvivorWorld/PsychopatzSurvivorWorldClient"

local function recordFor(traderID)
    local service = DTCommon and DTCommon.TraderService or nil
    if not service or type(service.GetRecord) ~= "function" then
        return nil
    end
    return service.GetRecord(tostring(traderID or ""))
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

    return {
        namespace = "dynamictrading.trader",
        npcID = actorID,
        npcName = name,
        persistHistory = true,
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
