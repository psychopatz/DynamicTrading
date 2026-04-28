local HOOK_ID = "TraderNeeds.HelpEscort"

local TraderHelpEscortUI = {
    pendingRequest = nil,
    activeConversation = nil,
    pendingAction = nil,
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

local function rememberConversation(ui, npc, player, npcData, context)
    TraderHelpEscortUI.activeConversation = {
        ui = ui,
        npc = npc,
        player = player,
        npcData = npcData,
        context = context,
    }
end

local function countBandages(player)
    if DynamicObjectives and DynamicObjectives.MedicalItemUtils and DynamicObjectives.MedicalItemUtils.CountBandageItems then
        return tonumber(DynamicObjectives.MedicalItemUtils.CountBandageItems(player)) or 0
    end
    return 0
end

local function buildEscortStatusText(player, npcData, context, quest)
    local detail = quest and DynamicObjectives
        and DynamicObjectives.Quests
        and DynamicObjectives.Quests.GetQuestDetailData
        and DynamicObjectives.Quests.GetQuestDetailData(player, quest.id)
        or nil
    local summary = quest and DynamicObjectives
        and DynamicObjectives.Quests
        and DynamicObjectives.Quests.BuildSummaryText
        and DynamicObjectives.Quests.BuildSummaryText(quest, player)
        or "Stay close and keep the escort moving."

    local parts = { summary or "Stay close and keep the escort moving." }
    local npc = context and context.npcData or npcData or nil
    local current = tonumber(npc and (npc.combatHealthCurrent or (npc.combatHealth and npc.combatHealth.current)) or nil)
    local maxHealth = tonumber(npc and (npc.combatHealthMax or (npc.combatHealth and npc.combatHealth.max)) or nil)
    if current and maxHealth and maxHealth > 0 then
        parts[#parts + 1] = string.format("Health: %d/%d", math.floor(current + 0.5), math.floor(maxHealth + 0.5))
    end

    local state = tostring((npc and npc.state) or "")
    if state ~= "" then
        parts[#parts + 1] = "Order: " .. state
    end

    local hookState = quest and type(quest.hookState) == "table" and quest.hookState or nil
    local homeCoords = hookState and hookState.homeCoords or nil
    if player and type(homeCoords) == "table" and tonumber(homeCoords.x) and tonumber(homeCoords.y) then
        local dx = tonumber(homeCoords.x) - tonumber(player:getX())
        local dy = tonumber(homeCoords.y) - tonumber(player:getY())
        parts[#parts + 1] = string.format("Home: %.0fm", math.sqrt((dx * dx) + (dy * dy)))
    elseif detail and detail.targetLabel and tostring(detail.targetLabel) ~= "" then
        parts[#parts + 1] = "Destination: " .. tostring(detail.targetLabel)
    end

    return table.concat(parts, "\n")
end

local function sendEscortAction(player, context, action)
    if not player or not context or not context.traderId or not sendClientCommand then
        return false
    end

    sendClientCommand(player, "DynamicObjectives", "EscortObjectiveAction", {
        hookId = HOOK_ID,
        incidentId = context.incidentId,
        traderId = context.traderId,
        action = action,
    })
    return true
end

local function showEscortConversation(ui, npc, player, npcData, context, overrideSpeech)
    npcData = getNPCData(npc) or npcData
    local resolvedContext = getIncidentContext(player, npcData)
    if type(resolvedContext) == "table" and (resolvedContext.traderId or resolvedContext.incidentId) then
        context = resolvedContext
    else
        context = type(context) == "table" and context or {}
    end
    context.npcData = npcData
    rememberConversation(ui, npc, player, npcData, context)

    local quest = getActiveEscortQuest(player, context.traderId, context.incidentId)
    local summary = buildEscortStatusText(player, npcData, context, quest)
    local bandageCount = countBandages(player)

    ui:speak(overrideSpeech or "We're moving. Keep me alive and get me back to base.")
    ui:updateOptions({
        {
            text = "Status",
            message = "",
            onSelect = function(innerUI)
                showEscortConversation(
                    innerUI,
                    npc,
                    player,
                    getNPCData(npc) or npcData,
                    getIncidentContext(player, getNPCData(npc) or npcData),
                    summary or "Keep the trader alive and moving."
                )
            end,
        },
        {
            text = "Follow",
            message = "",
            onSelect = function(innerUI)
                TraderHelpEscortUI.pendingAction = {
                    ui = innerUI,
                    npc = npc,
                    player = player,
                }
                sendEscortAction(player, context, "follow")
                showEscortConversation(innerUI, npc, player, getNPCData(npc) or npcData, getIncidentContext(player, getNPCData(npc) or npcData), "Stay close. I'll follow your lead.")
            end,
        },
        {
            text = "Stay",
            message = "",
            onSelect = function(innerUI)
                TraderHelpEscortUI.pendingAction = {
                    ui = innerUI,
                    npc = npc,
                    player = player,
                }
                sendEscortAction(player, context, "stay")
                showEscortConversation(innerUI, npc, player, getNPCData(npc) or npcData, getIncidentContext(player, getNPCData(npc) or npcData), "I'll hold here until you move me again.")
            end,
        },
        {
            text = bandageCount > 0 and ("Heal Up (" .. tostring(bandageCount) .. ")") or "Heal Up (Need bandage)",
            message = "",
            onSelect = function(innerUI)
                if bandageCount <= 0 then
                    innerUI:speak("Bring me a bandage, adhesive bandage, or clean rag first.")
                    showEscortConversation(innerUI, npc, player, getNPCData(npc) or npcData, getIncidentContext(player, getNPCData(npc) or npcData))
                    return
                end

                TraderHelpEscortUI.pendingAction = {
                    ui = innerUI,
                    npc = npc,
                    player = player,
                }
                sendEscortAction(player, context, "patchup")
                showEscortConversation(innerUI, npc, player, getNPCData(npc) or npcData, getIncidentContext(player, getNPCData(npc) or npcData), "Hold still. Use the bandage and keep moving.")
            end,
        },
    }, {
        resetHistory = true,
    })
end

local function showUnavailable(ui, message)
    TraderHelpEscortUI.activeConversation = nil
    ui:speak(message or "This rescue call is no longer available.")
    ui:updateOptions({}, {
        resetHistory = true,
    })
end

local function showPendingConversation(ui, npc, player, npcData, context)
    rememberConversation(ui, npc, player, npcData, context)
    local offer = getOffer(player, context) or {}
    local incident = context.incident
    if not incident then
        showUnavailable(ui, offer.unavailable or "This rescue call is gone.")
        return
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
                }, {
                    resetHistory = true,
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
                innerUI:updateOptions({})
            end,
        },
        {
            text = (offer.choiceLabels and offer.choiceLabels.decline) or "Decline",
            message = "",
            onSelect = function(innerUI)
                innerUI:speak(offer.decline or "Then I keep hiding in here.")
                innerUI:updateOptions({}, {
                    resetHistory = true,
                })
            end,
        },
    }, {
        resetHistory = true,
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

    showEscortConversation(
        pending.ui,
        pending.npc,
        pending.player,
        getNPCData(pending.npc),
        getIncidentContext(pending.player, getNPCData(pending.npc)),
        (args and args.message) or "I'm with you. Get me home."
    )
end

function TraderHelpEscortUI.OnIncidentFailed(args)
    local pending = TraderHelpEscortUI.pendingRequest
    TraderHelpEscortUI.pendingRequest = nil
    if not pending or not pending.ui then
        return
    end

    showUnavailable(pending.ui, args and args.message or "This rescue is no longer available.")
end

function TraderHelpEscortUI.OnEscortActionResult(args)
    local pending = TraderHelpEscortUI.pendingAction
    TraderHelpEscortUI.pendingAction = nil
    if DTNPCClient and DTNPCClient.QueueNearbySync then
        DTNPCClient.QueueNearbySync("trader-help-escort-action")
    end
    if not pending or not pending.ui then
        return
    end

    local npcData = getNPCData(pending.npc)
    local context = getIncidentContext(pending.player, npcData)
    if (not context or (not context.traderId and not context.incidentId))
        and TraderHelpEscortUI.activeConversation
        and TraderHelpEscortUI.activeConversation.context
    then
        context = TraderHelpEscortUI.activeConversation.context
    end
    showEscortConversation(
        pending.ui,
        pending.npc,
        pending.player,
        npcData,
        context,
        args and args.message or "Escort order updated."
    )
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
