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

function QuestOffer.OpenQuestOffer(ui, npc, player, npcData, options)
    options = type(options) == "table" and options or {}

    if not ui or not player then
        return nil
    end

    local onBack = type(options.onBack) == "function" and options.onBack or function() end
    local onQuestAccepted = type(options.onQuestAccepted) == "function" and options.onQuestAccepted or nil
    local traderContext = QuestOffer.BuildTraderContext(ui, npc, npcData, options.overrideTraderContext)

    if not (DynamicObjectives and DynamicObjectives.Quests and DynamicObjectives.Quests.BuildTraderQuestOffer) then
        ui:speak("I am not handing out jobs right now.")
        onBack(ui)
        return nil
    end

    local offer = DynamicObjectives.Quests.BuildTraderQuestOffer(player, traderContext)
    if not offer then
        local resting = traderContext.currentState == "Resting"
        ui:speak(resting and "No work from me right now. Check back later." or "I only hand out work when I am settled down.")
        onBack(ui)
        return nil
    end

    local function showMainMenu(conversationUI)
        onBack(conversationUI)
    end

    local function showOfferOptions(conversationUI, currentOffer)
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
                    showMainMenu(nextUI)
                end
            }
            menu[#menu + 1] = {
                text = currentOffer.choiceLabels.details,
                message = currentOffer.choiceLabels.details,
                onSelect = function(nextUI)
                    nextUI:speak(currentOffer.resolvedDialogue.details)
                    showOfferOptions(nextUI, currentOffer)
                end
            }
            menu[#menu + 1] = {
                text = currentOffer.choiceLabels.rewards,
                message = currentOffer.choiceLabels.rewards,
                onSelect = function(nextUI)
                    nextUI:speak(currentOffer.resolvedDialogue.rewards)
                    showOfferOptions(nextUI, currentOffer)
                end
            }
            menu[#menu + 1] = {
                text = currentOffer.choiceLabels.decline,
                message = currentOffer.choiceLabels.decline,
                onSelect = function(nextUI)
                    nextUI:speak(currentOffer.resolvedDialogue.decline)
                    showMainMenu(nextUI)
                end
            }
        elseif currentOffer.activeQuest then
            menu[#menu + 1] = {
                text = "How's it going?",
                message = "Remind me where I am on that job.",
                onSelect = function(nextUI)
                    nextUI:speak(currentOffer.progressSummary or currentOffer.resolvedDialogue.active)
                    showOfferOptions(nextUI, currentOffer)
                end
            }
            menu[#menu + 1] = {
                text = currentOffer.choiceLabels.rewards,
                message = currentOffer.choiceLabels.rewards,
                onSelect = function(nextUI)
                    nextUI:speak(currentOffer.resolvedDialogue.rewards)
                    showOfferOptions(nextUI, currentOffer)
                end
            }
        end

        menu[#menu + 1] = {
            text = currentOffer.choiceLabels.back,
            message = "",
            onSelect = function(nextUI)
                showMainMenu(nextUI)
            end
        }

        conversationUI:updateOptions(menu)
    end

    if offer.canStart == true then
        ui:speak(offer.resolvedDialogue.offer)
    elseif offer.activeQuest then
        ui:speak(offer.resolvedDialogue.active)
    else
        ui:speak(offer.resolvedDialogue.unavailable)
    end

    showOfferOptions(ui, offer)
    return offer
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
        conversationUI:updateOptions({
            {
                text = "Any work?",
                message = "Got any work for me?",
                onSelect = function(nextUI)
                    QuestOffer.OpenQuestOffer(nextUI, nil, player, nil, {
                        overrideTraderContext = traderContext,
                        onBack = function(backUI)
                            showRoot(backUI, true)
                        end,
                        onQuestAccepted = options.onQuestAccepted,
                    })
                end
            },
            {
                text = "Close",
                message = "",
                onSelect = function(nextUI)
                    closeConversation(nextUI)
                end
            }
        })
    end

    showRoot(ui, false)
    return ui
end
