require "DT/Common/UI/ConversationUI/ConversationUI"

DT_ConversationQuestOffer = DT_ConversationQuestOffer or {}

local QuestOffer = DT_ConversationQuestOffer

local function resolveTraderConversationState(npc, npcData)
    local state = npcData and (npcData.status or npcData.state) or nil
    if state and state ~= "" then
        return tostring(state)
    end

    local id = (npcData and npcData.uuid) or (npc and (npc:getPersistentOutfitID() or npc:getID())) or nil
    local rosterData = id and ModData and ModData.get and ModData.get("DynamicTrading_Roster") or nil
    local soul = rosterData and rosterData.Souls and rosterData.Souls[id] or nil
    if soul and (soul.status or soul.state) then
        return tostring(soul.status or soul.state)
    end

    return "Resting"
end

function QuestOffer.BuildTraderContext(ui, npc, npcData, overrides)
    local target = ui and ui.target or nil
    local context = {
        traderID = (npcData and npcData.uuid) or (target and (target.id or target.uuid)) or (npc and (npc:getPersistentOutfitID() or npc:getID())) or nil,
        id = (npcData and npcData.uuid) or (target and (target.id or target.uuid)) or nil,
        displayName = (npcData and npcData.name) or (target and target.name) or "Survivor",
        name = (npcData and npcData.name) or (target and target.name) or "Survivor",
        archetype = (npcData and (npcData.archetypeID or npcData.occupation)) or (target and target.archetype) or "General",
        factionID = (npcData and npcData.factionID) or (target and target.factionID) or nil,
        currentState = resolveTraderConversationState(npc, npcData),
        status = resolveTraderConversationState(npc, npcData),
    }

    if type(overrides) == "table" then
        for key, value in pairs(overrides) do
            context[key] = value
        end
    end

    return context
end

local function closeConversation(ui)
    if ui then
        ui.closeReason = ui.closeReason or "quest_offer_closed"
        ui:close()
    end
end

local function buildNavigationBlock(footerAction, overrides)
    if DT_ConversationUI and DT_ConversationUI.BuildNavigationBlock then
        return DT_ConversationUI.BuildNavigationBlock(footerAction, overrides)
    end

    local block = {
        explicitFooter = true,
        footerAction = footerAction,
        defaultFooterAction = footerAction,
    }
    for key, value in pairs(overrides or {}) do
        block[key] = value
    end
    return block
end

local function buildBackFooterAction(overrides)
    if DT_ConversationUI and DT_ConversationUI.BuildBackFooterAction then
        return DT_ConversationUI.BuildBackFooterAction(overrides)
    end

    local action = {
        kind = "back",
        title = "Back",
        closeAfter = false,
        exitAfter = false,
    }
    for key, value in pairs(overrides or {}) do
        action[key] = value
    end
    return action
end

local function buildLeaveFooterAction(overrides)
    if DT_ConversationUI and DT_ConversationUI.BuildLeaveFooterAction then
        return DT_ConversationUI.BuildLeaveFooterAction(overrides)
    end

    local action = {
        kind = "leave",
        title = "Leave",
    }
    for key, value in pairs(overrides or {}) do
        action[key] = value
    end
    return action
end

local function getOfferMenuLabel(offer)
    if type(offer) ~= "table" then
        return "Objective"
    end
    return tostring(
        offer.menuLabel
            or (offer.questSpec and (offer.questSpec.title or offer.questSpec.name))
            or (offer.activeQuest and (offer.activeQuest.title or offer.activeQuest.name))
            or (offer.blueprint and (offer.blueprint.name or offer.blueprint.id))
            or offer.blueprintId
            or "Objective"
    )
end

local function offerMatchesBlueprint(offer, blueprintID)
    blueprintID = tostring(blueprintID or "")
    if blueprintID == "" or type(offer) ~= "table" then
        return false
    end

    local candidates = {
        offer.blueprintId,
        offer.blueprintID,
        offer.id,
        offer.questSpec and offer.questSpec.blueprintId,
        offer.questSpec and offer.questSpec.blueprintID,
        offer.blueprint and offer.blueprint.id,
        offer.activeQuest and offer.activeQuest.blueprintId,
    }

    for _, value in ipairs(candidates) do
        if tostring(value or "") == blueprintID then
            return true
        end
    end
    return false
end

local function getQuestOfferList(player, traderContext)
    if not (DynamicObjectives and DynamicObjectives.Quests) then
        return {}
    end

    if DynamicObjectives.Quests.BuildTraderQuestOffers then
        return DynamicObjectives.Quests.BuildTraderQuestOffers(player, traderContext) or {}
    end

    local single = DynamicObjectives.Quests.BuildTraderQuestOffer and DynamicObjectives.Quests.BuildTraderQuestOffer(player, traderContext) or nil
    return single and { single } or {}
end

local function getOfferUnavailableLine(traderContext)
    local state = tostring(traderContext and traderContext.currentState or "")
    local canOfferWork = state == "Resting" or state == "Trading"
    return canOfferWork and "No work from me right now. Check back later." or "I only hand out work when I am settled down."
end

function QuestOffer.OpenQuestOffer(ui, npc, player, npcData, options)
    options = type(options) == "table" and options or {}

    if not ui or not player then
        return nil
    end

    local onBack = type(options.onBack) == "function" and options.onBack or function() end
    local onQuestAccepted = type(options.onQuestAccepted) == "function" and options.onQuestAccepted or nil
    local traderContext = QuestOffer.BuildTraderContext(ui, npc, npcData, options.overrideTraderContext)
    local preselectedBlueprintId = tostring(options.preselectedBlueprintId or "")

    if not (DynamicObjectives and DynamicObjectives.Quests and (DynamicObjectives.Quests.BuildTraderQuestOffers or DynamicObjectives.Quests.BuildTraderQuestOffer)) then
        ui:speak("I am not handing out jobs right now.")
        onBack(ui)
        return nil
    end

    local function showMainMenu(conversationUI)
        onBack(conversationUI)
    end

    local showOfferOptions

    local function showOfferList(conversationUI, fromBack)
        local offers = getQuestOfferList(player, traderContext)
        if #offers == 0 then
            conversationUI:speak(getOfferUnavailableLine(traderContext))
            showMainMenu(conversationUI)
            return nil
        end

        if preselectedBlueprintId ~= "" and fromBack ~= true then
            for _, offer in ipairs(offers) do
                if offerMatchesBlueprint(offer, preselectedBlueprintId) then
                    return offer
                end
            end
        end

        if #offers == 1 and fromBack ~= true then
            return offers[1]
        end

        conversationUI:speak(fromBack and "Anything else on the board?" or (#offers > 1 and "I've got a few jobs lined up. Pick the one you want to talk through." or "Here's the job."))

        local menu = {}
        for _, offer in ipairs(offers) do
            menu[#menu + 1] = {
                text = getOfferMenuLabel(offer),
                message = "",
                onSelect = function(nextUI)
                    showOfferOptions(nextUI, offer)
                end
            }
        end

        menu._dtFooterAction = buildBackFooterAction({
            title = "Back",
            onSelect = function(nextUI)
                showMainMenu(nextUI)
            end
        })
        menu._dtNavigationBlock = buildNavigationBlock(menu._dtFooterAction, {
            debugLabel = "QuestOfferList",
            requireExplicitNavigation = true,
        })

        if fromBack == true then
            conversationUI:replaceOptions(menu)
        else
            conversationUI:updateOptions(menu)
        end
        return nil
    end

    function showOfferOptions(conversationUI, currentOffer, replaceCurrent)
        local menu = {}

        if currentOffer.canStart == true then
            menu[#menu + 1] = {
                text = currentOffer.choiceLabels.accept,
                message = currentOffer.choiceLabels.accept,
                onSelect = function(nextUI)
                    local quest = DynamicObjectives.Quests.StartQuestFromResolvedOffer and DynamicObjectives.Quests.StartQuestFromResolvedOffer(player, currentOffer) or nil
                    if quest then
                        nextUI:speak(currentOffer.resolvedDialogue.accept)
                        if onQuestAccepted then
                            onQuestAccepted(nextUI, quest, currentOffer)
                        end
                    else
                        nextUI:speak(currentOffer.resolvedDialogue.active ~= "" and currentOffer.resolvedDialogue.active or currentOffer.resolvedDialogue.unavailable)
                    end
                    showOfferList(nextUI, true)
                end
            }
            menu[#menu + 1] = {
                text = currentOffer.choiceLabels.details,
                message = currentOffer.choiceLabels.details,
                onSelect = function(nextUI)
                    nextUI:speak(currentOffer.resolvedDialogue.details)
                    showOfferOptions(nextUI, currentOffer, true)
                end
            }
            menu[#menu + 1] = {
                text = currentOffer.choiceLabels.rewards,
                message = currentOffer.choiceLabels.rewards,
                onSelect = function(nextUI)
                    nextUI:speak(currentOffer.resolvedDialogue.rewards)
                    showOfferOptions(nextUI, currentOffer, true)
                end
            }
            menu[#menu + 1] = {
                text = currentOffer.choiceLabels.decline,
                message = currentOffer.choiceLabels.decline,
                onSelect = function(nextUI)
                    nextUI:speak(currentOffer.resolvedDialogue.decline)
                    showOfferList(nextUI, true)
                end
            }
        elseif currentOffer.activeQuest then
            menu[#menu + 1] = {
                text = "How's it going?",
                message = "Remind me where I am on that job.",
                onSelect = function(nextUI)
                    nextUI:speak(currentOffer.progressSummary or currentOffer.resolvedDialogue.active)
                    showOfferOptions(nextUI, currentOffer, true)
                end
            }
            menu[#menu + 1] = {
                text = currentOffer.choiceLabels.rewards,
                message = currentOffer.choiceLabels.rewards,
                onSelect = function(nextUI)
                    nextUI:speak(currentOffer.resolvedDialogue.rewards)
                    showOfferOptions(nextUI, currentOffer, true)
                end
            }
        end

        menu._dtFooterAction = buildBackFooterAction({
            title = currentOffer.choiceLabels.back,
            onSelect = function(nextUI)
                showOfferList(nextUI, true)
            end
        })
        menu._dtNavigationBlock = buildNavigationBlock(menu._dtFooterAction, {
            debugLabel = "QuestOfferDetails",
            requireExplicitNavigation = true,
        })

        if replaceCurrent == true then
            conversationUI:replaceOptions(menu)
        else
            conversationUI:updateOptions(menu)
        end
    end

    local initialOffer = showOfferList(ui, false)
    if not initialOffer then
        return nil
    end

    if initialOffer.canStart == true then
        ui:speak(initialOffer.resolvedDialogue.offer)
    elseif initialOffer.activeQuest then
        ui:speak(initialOffer.resolvedDialogue.active)
    else
        ui:speak(initialOffer.resolvedDialogue.unavailable)
    end

    showOfferOptions(ui, initialOffer)
    return initialOffer
end

local function buildDebugTraderProxy(traderContext)
    return {
        id = traderContext.traderID or traderContext.id or "debug_quest_trader",
        traderID = traderContext.traderID or traderContext.id or "debug_quest_trader",
        uuid = traderContext.traderID or traderContext.id or "debug_quest_trader",
        name = traderContext.displayName or traderContext.name or "Debug Trader",
        archetype = traderContext.archetype or "General",
        gender = traderContext.gender or "Male",
        identitySeed = traderContext.identitySeed or 1,
        factionID = traderContext.factionID,
    }
end

function QuestOffer.OpenDebugConversation(player, options)
    options = type(options) == "table" and options or {}
    if not player or not DT_ConversationUI or not DT_ConversationUI.Open then
        return nil
    end

    local traderContext = QuestOffer.BuildTraderContext(nil, nil, nil, options.overrideTraderContext or {
        traderID = "debug_quest_trader",
        id = "debug_quest_trader",
        displayName = "Debug Trader",
        name = "Debug Trader",
        archetype = "General",
        currentState = "Resting",
        status = "Resting",
    })

    local traderProxy = type(options.traderProxy) == "table" and options.traderProxy or buildDebugTraderProxy(traderContext)
    local ui = DT_ConversationUI.Open(traderProxy, nil, nil, false, nil)
    if not ui then
        return nil
    end

    if type(options.onCloseCallback) == "function" then
        ui.onCloseCallback = function(closedUI)
            options.onCloseCallback(closedUI)
        end
    end

    local function showRoot(conversationUI, fromBack)
        conversationUI:speak(fromBack and "Anything else?" or tostring(options.initialGreeting or "Hello. What can I do for you?"))
        local footerAction = buildLeaveFooterAction({
            title = "Leave",
            onSelect = function(nextUI)
                closeConversation(nextUI)
            end
        })
        conversationUI:updateOptions({
            {
                text = "Any work?",
                message = "Got any work for me?",
                onSelect = function(nextUI)
                    QuestOffer.OpenQuestOffer(nextUI, nil, player, nil, {
                        overrideTraderContext = traderContext,
                        preselectedBlueprintId = fromBack and nil or options.preselectedBlueprintId,
                        onBack = function(backUI)
                            showRoot(backUI, true)
                        end,
                        onQuestAccepted = options.onQuestAccepted,
                    })
                end
            }
        }, {
            resetHistory = true,
            footerAction = footerAction,
            navigationBlock = buildNavigationBlock(footerAction, {
                resetHistory = true,
                debugLabel = "QuestDebugRoot",
                requireExplicitNavigation = true,
            }),
        })
    end

    if options.preselectedBlueprintId then
        QuestOffer.OpenQuestOffer(ui, nil, player, nil, {
            overrideTraderContext = traderContext,
            preselectedBlueprintId = options.preselectedBlueprintId,
            onBack = function(backUI)
                showRoot(backUI, true)
            end,
            onQuestAccepted = options.onQuestAccepted,
        })
    else
        showRoot(ui, false)
    end
    return ui
end
