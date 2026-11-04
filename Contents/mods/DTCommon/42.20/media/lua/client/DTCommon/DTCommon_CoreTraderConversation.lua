DTCommon = DTCommon or {}
DTCommon.CoreTraderConversation =
    DTCommon.CoreTraderConversation or {}

local CoreConversation = DTCommon.CoreTraderConversation
local CoreClient = require
    "PsychopatzCore/World/SurvivorWorld/PsychopatzSurvivorWorldClient"

local function recordFor(traderID)
    local service = DTCommon and DTCommon.TraderService or nil
    return service and type(service.GetRecord) == "function"
        and service.GetRecord(tostring(traderID or "")) or nil
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
    if name then
        return "I'm heading toward " .. name .. "."
    end
    return "I can't confirm where I'm heading next yet."
end

local function originResponse(record)
    local ca = record and record.ca or {}
    local name = placeName(
        ca.originSettlementID
        or ca.currentSettlementID
        or ca.homeSettlementID
    )
    if name then
        return "I came from " .. name .. "."
    end
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

function CoreConversation.BuildSpec(
    traderID,
    actorID,
    options
)
    options = type(options) == "table" and options or {}
    traderID = tostring(traderID or "")
    actorID = tostring(actorID or "")
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
    local name = displayName(
        projection,
        record,
        options.displayName
    )

    return {
        namespace = "dynamictrading.abstract",
        npcID = actorID,
        npcName = name,
        persistHistory = true,
        portrait = portrait,
        context = {
            actorID = actorID,
            traderID = traderID,
            npcName = name,
            provider = "DTAbstract",
            providerState = "abstract",
            abstractOnly = true,
        },
        start = "root",
        nodes = {
            root = {
                npc = {
                    text = "What do you need?",
                },
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
                                client.OpenTrader(traderID, {
                                    mode = "trade",
                                    actorID = actorID,
                                })
                            end
                        end,
                        next = "root",
                    },
                    {
                        id = "destination",
                        text = "Where are you heading?",
                        response = function()
                            return destinationResponse(
                                recordFor(traderID)
                            )
                        end,
                        next = "root",
                    },
                    {
                        id = "origin",
                        text = "Where did you come from?",
                        response = function()
                            return originResponse(
                                recordFor(traderID)
                            )
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

function CoreConversation.Open(
    traderID,
    actorID,
    options
)
    local spec, reason = CoreConversation.BuildSpec(
        traderID,
        actorID,
        options
    )
    if not spec then return nil, reason end
    local conversation = PsychopatzCore
        and PsychopatzCore.Conversation or nil
    if not conversation or type(conversation.Open) ~= "function" then
        local ok, loaded = pcall(
            require,
            "PsychopatzCore/UI/Conversation/PsychopatzConversation"
        )
        conversation = ok and loaded
            or PsychopatzCore and PsychopatzCore.Conversation
            or nil
    end
    if not conversation or type(conversation.Open) ~= "function" then
        return nil, "core_conversation_unavailable"
    end
    return conversation.Open(spec)
end

return CoreConversation
