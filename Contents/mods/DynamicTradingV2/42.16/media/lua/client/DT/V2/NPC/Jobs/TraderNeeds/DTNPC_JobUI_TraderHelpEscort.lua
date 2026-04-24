local HOOK_ID = "TraderNeeds.HelpEscort"

local TraderHelpEscortUI = {
    pendingRequest = nil,
}

local function getHook()
    return DynamicObjectives and DynamicObjectives.GetObjectiveHook and DynamicObjectives.GetObjectiveHook(HOOK_ID) or nil
end

local function getNPCData(npc)
    return npc and DTNPC and DTNPC.GetData and DTNPC.GetData(npc) or nil
end

local function getIncidentContext(player, npcData)
    local incidentId = npcData and npcData.doObjectiveIncidentId or nil
    local store = DynamicObjectives
        and DynamicObjectives.Quests
        and DynamicObjectives.Quests.GetStore
        and DynamicObjectives.Quests.GetStore(player, false)
        or nil
    local hookState = store and store.hookState and store.hookState[HOOK_ID] or nil
    local incident = hookState and hookState.incidents and incidentId and hookState.incidents[tostring(incidentId)] or nil
    return {
        incident = incident,
        incidentId = incidentId and tostring(incidentId) or nil,
        traderId = npcData and npcData.uuid or nil,
        traderName = npcData and npcData.name or "Trader",
    }
end

local function getActiveEscortQuest(player, traderId, incidentId)
    local store = DynamicObjectives
        and DynamicObjectives.Quests
        and DynamicObjectives.Quests.GetStore
        and DynamicObjectives.Quests.GetStore(player, false)
        or nil
    if not store then
        return nil
    end

    for _, quest in ipairs(store.quests or {}) do
        if quest.status == "active" and tostring(quest.hookId or "") == HOOK_ID then
            local hookState = type(quest.hookState) == "table" and quest.hookState or nil
            if incidentId and tostring(quest.hookIncidentId or "") == tostring(incidentId) then
                return quest
            end
            if traderId and hookState and tostring(hookState.traderId or "") == tostring(traderId) then
                return quest
            end
        end
    end

    return nil
end

local function getOffer(player, context)
    if not DynamicObjectives or not DynamicObjectives.Quests or not DynamicObjectives.Quests.BuildObjectiveHookOffer then
        return nil
    end
    return DynamicObjectives.Quests.BuildObjectiveHookOffer(player, HOOK_ID, context)
end

local function closeConversation(ui)
    if ui and ui.close then
        ui:close()
    end
end

local function showEscortConversation(ui, npc, player, npcData, context)
    local quest = getActiveEscortQuest(player, context.traderId, context.incidentId)
    local summary = quest and DynamicObjectives
        and DynamicObjectives.Quests
        and DynamicObjectives.Quests.BuildSummaryText
        and DynamicObjectives.Quests.BuildSummaryText(quest, player)
        or "Stay close and keep the escort moving."

    ui:speak("We're moving. Keep me alive and get me back to base.")
    ui:updateOptions({
        {
            text = "Status",
            message = "",
            onSelect = function(innerUI)
                innerUI:speak(summary or "Keep the trader alive and moving.")
            end,
        },
        {
            text = "Leave",
            message = "",
            onSelect = function(innerUI)
                closeConversation(innerUI)
            end,
        },
    })
end

local function showUnavailable(ui, message)
    ui:speak(message or "This rescue call is no longer available.")
    ui:updateOptions({
        {
            text = "Leave",
            message = "",
            onSelect = function(innerUI)
                closeConversation(innerUI)
            end,
        },
    })
end

local function showPendingConversation(ui, npc, player, npcData, context)
    local offer = getOffer(player, context) or {}
    local incident = context.incident
    if not incident then
        showUnavailable(ui, offer.unavailable or "This rescue call is gone.")
        return
    end

    local function refresh()
        showPendingConversation(ui, npc, player, npcData, context)
    end

    ui:speak(offer.offer or "I need an escort back to base.")
    ui:updateOptions({
        {
            text = (offer.choiceLabels and offer.choiceLabels.accept) or "Accept",
            message = "",
            onSelect = function(innerUI)
                TraderHelpEscortUI.pendingRequest = {
                    ui = innerUI,
                    npc = npc,
                    player = player,
                    incidentId = context.incidentId,
                    traderId = context.traderId,
                }
                innerUI:speak("Stay with me. I'm ready when you are.")
                innerUI:updateOptions({
                    {
                        text = "Working...",
                        message = "",
                        onSelect = function() end,
                    },
                })
                sendClientCommand(player, "DynamicObjectives", "AcceptObjectiveHookIncident", {
                    hookId = HOOK_ID,
                    incidentId = context.incidentId,
                    traderId = context.traderId,
                })
            end,
        },
        {
            text = (offer.choiceLabels and offer.choiceLabels.details) or "Details",
            message = "",
            onSelect = function(innerUI)
                innerUI:speak(offer.details or "Guide the trader home and keep them alive.")
                innerUI:updateOptions({
                    {
                        text = "Back",
                        message = "",
                        onSelect = function(nextUI)
                            refresh()
                        end,
                    },
                })
            end,
        },
        {
            text = (offer.choiceLabels and offer.choiceLabels.decline) or "Decline",
            message = "",
            onSelect = function(innerUI)
                innerUI:speak(offer.decline or "Then I keep hiding in here.")
                innerUI:updateOptions({
                    {
                        text = "Leave",
                        message = "",
                        onSelect = function(nextUI)
                            closeConversation(nextUI)
                        end,
                    },
                })
            end,
        },
    })
end

function TraderHelpEscortUI.OnIncidentAccepted(args)
    local pending = TraderHelpEscortUI.pendingRequest
    TraderHelpEscortUI.pendingRequest = nil
    if not pending or not pending.ui then
        return
    end

    if DTNPCClient and DTNPCClient.QueueNearbySync then
        DTNPCClient.QueueNearbySync("trader-help-escort-accepted")
    end

    pending.ui:speak((args and args.message) or "I'm with you. Get me home.")
    pending.ui:updateOptions({
        {
            text = "Leave",
            message = "",
            onSelect = function(innerUI)
                closeConversation(innerUI)
            end,
        },
    })
end

function TraderHelpEscortUI.OnIncidentFailed(args)
    local pending = TraderHelpEscortUI.pendingRequest
    TraderHelpEscortUI.pendingRequest = nil
    if not pending or not pending.ui then
        return
    end

    showUnavailable(pending.ui, args and args.message or "This rescue is no longer available.")
end

_G.DOTraderHelpEscortJobUI = TraderHelpEscortUI

DTNPCJobUI.Register({
    id = "TraderNeeds.HelpEscort",
    priority = 250,
    matches = function(ui, npc, player, npcData)
        npcData = npcData or getNPCData(npc)
        if not npcData then
            return false
        end

        return tostring(npcData.doObjectiveHookId or "") == HOOK_ID
            or npcData.doObjectiveEscortActive == true
            or npcData.doObjectiveDistress == true
    end,
    getTalkLabel = function(ui, npc, player, npcData, defaultName)
        local name = tostring(defaultName or (npcData and npcData.name) or "Trader")
        if npcData and npcData.doObjectiveEscortActive == true then
            return "Talk to Escorted " .. name
        end
        return "Talk to Distressed " .. name
    end,
    getTraderProxyPatch = function(ui, npc, player, npcData)
        return {
            doObjectiveHookId = npcData and npcData.doObjectiveHookId or nil,
            doObjectiveIncidentId = npcData and npcData.doObjectiveIncidentId or nil,
            doObjectiveIncidentStatus = npcData and npcData.doObjectiveIncidentStatus or nil,
            doObjectiveDistress = npcData and npcData.doObjectiveDistress or nil,
            doObjectiveEscortActive = npcData and npcData.doObjectiveEscortActive or nil,
            suppressTrade = true,
        }
    end,
    generateOptions = function(ui, npc, player, npcData)
        npcData = npcData or getNPCData(npc)
        if not npcData then
            return false
        end

        local context = getIncidentContext(player, npcData)
        local activeQuest = getActiveEscortQuest(player, context.traderId, context.incidentId)
        if npcData.doObjectiveEscortActive == true or activeQuest then
            showEscortConversation(ui, npc, player, npcData, context)
            return true
        end

        if tostring(npcData.doObjectiveIncidentStatus or "") ~= "pending" then
            showUnavailable(ui, "This distress call has already been resolved.")
            return true
        end

        showPendingConversation(ui, npc, player, npcData, context)
        return true
    end,
})
