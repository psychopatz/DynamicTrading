-- =============================================================================
-- DYNAMIC TRADING V2: NPC TRADER DIALOGUE HUB
-- =============================================================================
require "DT/Common/UI/ConversationUI/ConversationUI"
require "DT/Common/UI/ConversationUI/DT_ConversationQuestOffer"
require "DT/Common/UI/ConversationUI/DT_ConversationChatMenus"
require "DT/Common/UI/Contacts/DT_ContactsWindow"
require "DT/Common/Reputation/DT_Reputation"
require "DT/V2/NPC/DTNPC_TradingHandler"
require "DT/V2/NPC/DTNPC_InteractionPose"
require "DT/V2/UI/TradingWindowWrapper/TradingWindowWrapper"
require "DT/V2/Utils/DT_V2_OptionsManager"
pcall(require, "DT/V2/NPC/Jobs/DTNPC_JobUI")

DTNPC_TraderDialogue_Hub = {}

local function T(key, params, fallback)
    return DynamicTrading and DynamicTrading.Text and DynamicTrading.Text.Get
        and DynamicTrading.Text.Get(key, params, fallback)
        or fallback
        or tostring(key or "")
end

local function normalizeFollowSpacingMode(mode)
    local text = string.lower(tostring(mode or ""))
    if text == "far" then
        return "far"
    end
    if text == "near" then
        return "near"
    end
    return nil
end

local function getFollowSpacingMode(npcData)
    local mode = normalizeFollowSpacingMode(npcData and npcData.followSpacingMode or nil)
    if mode then
        return mode
    end
    if npcData and npcData.doObjectiveEscortActive == true then
        return "far"
    end
    return "near"
end

local function isPlayerFollowingOwner(player, npcData)
    if not player or not npcData then
        return false
    end

    if tostring(npcData.state or "") ~= "Follow" then
        return false
    end

    local playerID = player.getOnlineID and player:getOnlineID() or nil
    if playerID ~= nil and npcData.masterID ~= nil and tonumber(npcData.masterID) == tonumber(playerID) then
        return true
    end

    local username = player.getUsername and player:getUsername() or nil
    if not username or username == "" then
        return false
    end

    return tostring(npcData.master or "") == username
end

local function issueFollowSpacingOrder(player, npc, npcData, followSpacingMode)
    if not player or not npc or not npcData or not npcData.uuid or not sendClientCommand then
        return false
    end

    local mode = normalizeFollowSpacingMode(followSpacingMode)
    if not mode then
        return false
    end

    sendClientCommand(player, "DTNPC", "Order", {
        uuid = npcData.uuid,
        state = "Follow",
        followSpacingMode = mode,
        returnStatus = npcData.requestedReturnStatus or "Resting",
    })

    npcData.followSpacingMode = mode
    if DTNPC and DTNPC.AttachData then
        DTNPC.AttachData(npc, npcData)
    end
    return true
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

local function clearInteractionPose(npc)
    if DTNPC_InteractionPose and DTNPC_InteractionPose.Deactivate then
        DTNPC_InteractionPose.Deactivate(npc)
    end
end

local function applyInteractionPose(npc, player)
    if DTNPC_InteractionPose and DTNPC_InteractionPose.Activate then
        DTNPC_InteractionPose.Activate(
            npc,
            DTNPCLogic and DTNPCLogic.Stationary and DTNPCLogic.Stationary.INTERACTION_IDLE_STATE or "3",
            player
        )
    end
end

local function requestCalledTraderTrading(player, npc, npcData)
    if not player or not npc or type(npcData) ~= "table" or not npcData.uuid then
        return
    end
    
    if npcData.contactVisitActive ~= true then
        return
    end
    
    local requester = tostring(npcData.contactVisitRequestedBy or "")
    local username = player.getUsername and player:getUsername() or nil
    if requester ~= "" and username and requester ~= username then
        return
    end
    
    if npcData.state ~= "Trading" then
        sendClientCommand(player, "DTNPC", "Order", {
            uuid = npcData.uuid,
            state = "Trading",
        })
    end
    
    npcData.state = "Trading"
    npcData.contactVisitMode = "Trading"
    npcData.master = nil
    npcData.masterID = nil
    npcData.tasks = {}
    npcData.combatOrder = nil
    npcData.guardCombatOrder = nil
    npcData.guardAttackMode = nil
    npcData.stationaryPostX = nil
    npcData.stationaryPostY = nil
    npcData.stationaryPostZ = nil
    npcData.stationaryPostState = nil
    npcData.anchorX = nil
    npcData.anchorY = nil
    npcData.anchorZ = nil
    npcData.guardReturningToPost = nil
    
    if DTNPC and DTNPC.AttachData then
        DTNPC.AttachData(npc, npcData)
    end
end

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

local function buildTraderQuestContext(ui, npc, npcData)
    local target = ui and ui.target or nil
    return {
        traderID = (npcData and npcData.uuid) or (target and (target.id or target.uuid)) or (npc and (npc:getPersistentOutfitID() or npc:getID())) or nil,
        id = (npcData and npcData.uuid) or (target and (target.id or target.uuid)) or nil,
        displayName = (npcData and npcData.name) or (target and target.name) or "Survivor",
        name = (npcData and npcData.name) or (target and target.name) or "Survivor",
        archetype = (npcData and (npcData.archetypeID or npcData.occupation)) or (target and target.archetype) or "General",
        factionID = (npcData and npcData.factionID) or (target and target.factionID) or nil,
        currentState = resolveTraderConversationState(npc, npcData),
        status = resolveTraderConversationState(npc, npcData),
    }
end

local function reopenTraderDialogueOptions(ui, npc, player)
    DTNPC_TraderDialogue_Hub.GenerateOptions(ui, npc, player)
end

local function openTraderQuestOffer(ui, npc, player, npcData)
    if DT_ConversationQuestOffer and DT_ConversationQuestOffer.OpenQuestOffer then
        return DT_ConversationQuestOffer.OpenQuestOffer(ui, npc, player, npcData, {
            onBack = function(backUI)
                reopenTraderDialogueOptions(backUI, npc, player)
            end
        })
    end
    
    if not (DynamicObjectives and DynamicObjectives.Quests and DynamicObjectives.Quests.BuildTraderQuestOffer) then
        ui:speak(T("DTNPC_Dialogue_NotHandingOutJobs", nil, "I am not handing out jobs right now."))
        reopenTraderDialogueOptions(ui, npc, player)
        return
    end
    
    local traderContext = buildTraderQuestContext(ui, npc, npcData)
    local offer = DynamicObjectives.Quests.BuildTraderQuestOffer(player, traderContext)
    if not offer then
        local resting = traderContext.currentState == "Resting"
        ui:speak(resting
            and T("DTNPC_Dialogue_NoWorkRightNow", nil, "No work from me right now. Check back later.")
            or T("DTNPC_Dialogue_WorkOnlyWhenSettled", nil, "I only hand out work when I am settled down."))
        reopenTraderDialogueOptions(ui, npc, player)
        return
    end
    
    local function showMainMenu(conversationUI)
        reopenTraderDialogueOptions(conversationUI, npc, player)
    end
    
    local function showOfferOptions(conversationUI, currentOffer)
        local options = {}
        
        if currentOffer.canStart == true then
            options[#options + 1] = {
                text = currentOffer.choiceLabels.accept,
                message = currentOffer.choiceLabels.accept,
                onSelect = function(nextUI)
                    local quest = DynamicObjectives.Quests.StartQuestFromResolvedOffer and DynamicObjectives.Quests.StartQuestFromResolvedOffer(player, currentOffer) or nil
                    if quest then
                        nextUI:speak(currentOffer.resolvedDialogue.accept)
                    else
                        nextUI:speak(currentOffer.resolvedDialogue.active ~= "" and currentOffer.resolvedDialogue.active or currentOffer.resolvedDialogue.unavailable)
                    end
                    showMainMenu(nextUI)
                end
            }
            options[#options + 1] = {
                text = currentOffer.choiceLabels.details,
                message = currentOffer.choiceLabels.details,
                onSelect = function(nextUI)
                    nextUI:speak(currentOffer.resolvedDialogue.details)
                    showOfferOptions(nextUI, currentOffer)
                end
            }
            options[#options + 1] = {
                text = currentOffer.choiceLabels.rewards,
                message = currentOffer.choiceLabels.rewards,
                onSelect = function(nextUI)
                    nextUI:speak(currentOffer.resolvedDialogue.rewards)
                    showOfferOptions(nextUI, currentOffer)
                end
            }
            options[#options + 1] = {
                text = currentOffer.choiceLabels.decline,
                message = currentOffer.choiceLabels.decline,
                onSelect = function(nextUI)
                    nextUI:speak(currentOffer.resolvedDialogue.decline)
                    showMainMenu(nextUI)
                end
            }
        elseif currentOffer.activeQuest then
            options[#options + 1] = {
                text = T("DTNPC_Dialogue_HowsItGoing", nil, "How's it going?"),
                message = T("DTNPC_Dialogue_RemindJob", nil, "Remind me where I am on that job."),
                onSelect = function(nextUI)
                    nextUI:speak(currentOffer.progressSummary or currentOffer.resolvedDialogue.active)
                    showOfferOptions(nextUI, currentOffer)
                end
            }
            options[#options + 1] = {
                text = currentOffer.choiceLabels.rewards,
                message = currentOffer.choiceLabels.rewards,
                onSelect = function(nextUI)
                    nextUI:speak(currentOffer.resolvedDialogue.rewards)
                    showOfferOptions(nextUI, currentOffer)
                end
            }
        end
        
        options._dtFooterAction = buildBackFooterAction({
            title = currentOffer.choiceLabels.back,
            onSelect = function(nextUI)
                showMainMenu(nextUI)
            end
        })
        options._dtNavigationBlock = buildNavigationBlock(options._dtFooterAction, {
            debugLabel = "TraderHubQuestFallback",
            requireExplicitNavigation = true,
        })
        
        conversationUI:updateOptions(options)
    end
    
    if offer.canStart == true then
        ui:speak(offer.resolvedDialogue.offer)
    elseif offer.activeQuest then
        ui:speak(offer.resolvedDialogue.active)
    else
        ui:speak(offer.resolvedDialogue.unavailable)
    end
    
    showOfferOptions(ui, offer)
end

local function cloneMessagePayload(payload)
    if type(payload) ~= "table" then
        return payload
    end
    
    local copy = {}
    for key, value in pairs(payload) do
        copy[key] = value
    end
    return copy
end


function DTNPC_TraderDialogue_Hub.Init(ui, npc, player, initOptions)
    if not ui then
        -- Open if not already open
        if DT_ConversationUI then
            -- We create a "fake" trader object from the NPC for the UI
            local npcData = DTNPC.GetData(npc)
            local traderProxy = {
                id = (npcData and npcData.uuid) or npc:getPersistentOutfitID() or npc:getID(),
                name = npcData and npcData.name or "Survivor",
                archetype = npcData and npcData.archetypeID or npcData.occupation or "Survivor",
                gender = npc:isFemale() and "Female" or "Male",
                identitySeed = npcData and npcData.identitySeed or 1,
                factionID = npcData and npcData.factionID,
                returnTime = npcData and npcData.returnTime
            }
            
            -- Get trader budget from roster session data
            local rosterData = ModData.get("DynamicTrading_Roster")
            local traderID = traderProxy.id
            local session = rosterData and rosterData.Sessions and rosterData.Sessions[traderID] or nil
            traderProxy.budget = session and session.budget or 0
            
            if DTNPCJobUI and DTNPCJobUI.ApplyTraderProxyPatch then
                traderProxy = (DTNPCJobUI.ApplyTraderProxyPatch(traderProxy, ui, npc, player, npcData))
            end
            
            if DynamicTrading and DynamicTrading.IsArchetypeNeverRecruitable and DynamicTrading.IsArchetypeNeverRecruitable(npcData or traderProxy) then
                traderProxy.canRecruit = false
                traderProxy.allowRecruit = false
                traderProxy.neverRecruitable = true
            end
            
            if DT_Reputation then
                traderProxy.personalRep = DT_Reputation.GetPersonalRep(traderProxy.id, traderProxy.factionID)
                traderProxy.factionRep = DT_Reputation.GetFactionRep(traderProxy.factionID)
                traderProxy.reputation = DT_Reputation.GetEffectiveRep(traderProxy.id, traderProxy.factionID)
                traderProxy.reputationStage = DT_Reputation.GetStageData(traderProxy.reputation).label
            end
            
            -- [FIX] Safety checks for debug prints to prevent "concatenation with nil" crashes
            DynamicTrading.Log("DTV2", "Dialog", "Debug", "Trader ID: " .. tostring(traderProxy.id))
            DynamicTrading.Log("DTV2", "Dialog", "Debug", "Trader Name: " .. tostring(traderProxy.name))
            DynamicTrading.Log("DTV2", "Dialog", "Debug", "Trader Archetype: " .. tostring(traderProxy.archetype))
            DynamicTrading.Log("DTV2", "Dialog", "Debug", "Trader Gender: " .. tostring(traderProxy.gender))
            DynamicTrading.Log("DTV2", "Dialog", "Debug", "Trader Identity Seed: " .. tostring(traderProxy.identitySeed))
            
            if traderProxy.factionID then
                DynamicTrading.Log("DTV2", "Dialogue", "Admin", "Trader Faction ID: " .. traderProxy.factionID)
                
                -- [NEW] Request roster if faction data is not in cache
                local factionData = (DynamicTrading_Client and DynamicTrading_Client.Cache and DynamicTrading_Client.Cache.Factions) 
                                    or (DT_V2_RadarManager and DT_V2_RadarManager.ClientFactions)
                
                if not factionData or not factionData[traderProxy.factionID] then
                    if DT_V2_RadarManager and DT_V2_RadarManager.RequestRoster then
                        DynamicTrading.Log("DTV2", "Dialog", "Sync", "Faction data missing in cache, requesting Roster sync...")
                        DT_V2_RadarManager.RequestRoster()
                    end
                end
            else
                DynamicTrading.Log("DTV2", "Dialogue", "Debug", "Trader Faction ID: nil")
            end
            
            if traderProxy.returnTime then
                DynamicTrading.Log("DTV2", "Dialog", "Debug", "Trader Return Time: " .. traderProxy.returnTime)
            else
                DynamicTrading.Log("DTV2", "Dialog", "Debug", "Trader Return Time: nil")
            end
            
            ui = DT_ConversationUI.Open(traderProxy, nil, nil, false, npc) -- isRadio = false
        else
            return
        end
    end
    
    if not npc or not player then return end
    
    applyInteractionPose(npc, player)
    ui.onCloseCallback = function()
        clearInteractionPose(npc)
    end
    
    -- 1. Intro Speech
    local initialPlayerMessage = initOptions and initOptions.initialPlayerMessage or nil
    if initialPlayerMessage and initialPlayerMessage.text then
        ui:queueMessage(
            initialPlayerMessage.text,
            initialPlayerMessage.author or "Me",
            true,
            tonumber(initialPlayerMessage.delay) or 0,
            initialPlayerMessage.sound or "DT_RadioRandom",
            initialPlayerMessage.style
        )
    end
    
    local greeting = initOptions and initOptions.initialGreeting or nil
    if not greeting and DynamicTrading and DynamicTrading.DialogueManager and ui.target then
        greeting = DynamicTrading.DialogueManager.GenerateGreeting(ui.target)
    end
    if not greeting then
        greeting = T("DTNPC_Dialogue_DefaultGreeting", nil, "Hello. What can I do for you?")
    end
    if initialPlayerMessage and initialPlayerMessage.text and type(greeting) == "table" and greeting.delay == nil then
        greeting = cloneMessagePayload(greeting)
        greeting.delay = DT_ConversationUI.TEXT_DELAY
    elseif initialPlayerMessage and initialPlayerMessage.text and type(greeting) ~= "table" then
        greeting = {
            text = greeting,
            delay = DT_ConversationUI.TEXT_DELAY,
        }
    end
    ui:speak(greeting)
    
    -- 2. Generate Options
    DTNPC_TraderDialogue_Hub.GenerateOptions(ui, npc, player)
end

function DTNPC_TraderDialogue_Hub.GenerateOptions(ui, npc, player)
    local options = {}
    local npcData = DTNPC.GetData(npc)
    
    if DTNPCJobUI and DTNPCJobUI.TryGenerateOptions then
        local handled = DTNPCJobUI.TryGenerateOptions(ui, npc, player, npcData)
        if handled then
            return
        end
    end
    
    ui.isCompanionConversation = false
    
    -- OPTION 1: CHAT (First implementation)
    table.insert(options, {
        text = T("DTNPC_UI_Chat", nil, "Chat"),
        message = T("DTNPC_Dialogue_GotMinuteToTalk", nil, "Got a minute to talk?"),
        onSelect = function(conversationUI)
            DT_ConversationChatMenus.OpenTraderChat(conversationUI, {
                onBack = function(backUI)
                    DTNPC_TraderDialogue_Hub.GenerateOptions(backUI, npc, player)
                end
            })
        end
    })
    
    table.insert(options, {
        text = T("DTNPC_UI_AnyWork", nil, "Any work?"),
        message = T("DTNPC_Dialogue_GotWorkForMe", nil, "Got any work for me?"),
        onSelect = function(conversationUI)
            openTraderQuestOffer(conversationUI, npc, player, npcData)
        end
    })

    if isPlayerFollowingOwner(player, npcData) then
        table.insert(options, {
            text = T("DTNPC_UI_FollowMethod", nil, "Follow Method"),
            message = T("DTNPC_Dialogue_AdjustTrailDistance", nil, "Adjust how closely you trail me."),
            onSelect = function(conversationUI)
                local liveData = DTNPC.GetData(npc) or npcData
                local currentMode = getFollowSpacingMode(liveData)
                conversationUI:speak(T("DTNPC_Dialogue_CurrentFollowMethod", {
                    mode = currentMode == "far" and T("DTNPC_UI_Far", nil, "Far") or T("DTNPC_UI_Near", nil, "Near"),
                }, "Current follow method: {mode}."))
                local followOptions = {
                    {
                        text = currentMode == "near"
                            and T("DTNPC_UI_ModeActive", { label = T("DTNPC_UI_Near", nil, "Near") }, "{label} [ACTIVE]")
                            or T("DTNPC_UI_Near", nil, "Near"),
                        message = T("DTNPC_Dialogue_StayTighter", nil, "Stay tighter on my position."),
                        onSelect = function(nextUI)
                            local latestData = DTNPC.GetData(npc) or liveData
                            if issueFollowSpacingOrder(player, npc, latestData, "near") then
                                nextUI:speak(T("DTNPC_Dialogue_NearSpacingSet", nil, "Near spacing set."))
                            else
                                nextUI:speak(T("DTNPC_Dialogue_CouldNotChangeFollowMethod", nil, "I couldn't change follow method right now."))
                            end
                            DTNPC_TraderDialogue_Hub.GenerateOptions(nextUI, npc, player)
                        end
                    },
                    {
                        text = currentMode == "far"
                            and T("DTNPC_UI_ModeActive", { label = T("DTNPC_UI_Far", nil, "Far") }, "{label} [ACTIVE]")
                            or T("DTNPC_UI_Far", nil, "Far"),
                        message = T("DTNPC_Dialogue_GiveMeRoomDuringFights", nil, "Give me more room during fights."),
                        onSelect = function(nextUI)
                            local latestData = DTNPC.GetData(npc) or liveData
                            if issueFollowSpacingOrder(player, npc, latestData, "far") then
                                nextUI:speak(T("DTNPC_Dialogue_FarSpacingSet", nil, "Far spacing set."))
                            else
                                nextUI:speak(T("DTNPC_Dialogue_CouldNotChangeFollowMethod", nil, "I couldn't change follow method right now."))
                            end
                            DTNPC_TraderDialogue_Hub.GenerateOptions(nextUI, npc, player)
                        end
                    },
                }

                local footerAction = buildBackFooterAction({
                    onSelect = function(nextUI)
                        DTNPC_TraderDialogue_Hub.GenerateOptions(nextUI, npc, player)
                    end
                })
                local navBlock = buildNavigationBlock(footerAction, {
                    debugLabel = "TraderHubFollowMethod",
                    requireExplicitNavigation = true,
                })
                followOptions._dtFooterAction = footerAction
                followOptions._dtNavigationBlock = navBlock
                conversationUI:updateOptions(followOptions, {
                    navigationBlock = navBlock,
                })
            end
        })
    end
    
    -- OPTION 2: TRADE (Always Visible)
    local isTrading = false
    
    if npcData
        and npcData.banditRoamActive ~= true
        and npcData.state ~= "Departure"
        and (npcData.status == "Trading" or npcData.state == "Trading") then
        isTrading = true
    else
        -- Fallback to Roster ModData if npcData is missing or unsynced
        local id = (npcData and npcData.uuid) or npc:getPersistentOutfitID() or npc:getID()
        local rosterData = ModData.get("DynamicTrading_Roster")
        if rosterData and rosterData.Souls and rosterData.Souls[id] then
            if rosterData.Souls[id].banditRoamActive ~= true
                and (rosterData.Souls[id].status == "Trading" or rosterData.Souls[id].state == "Trading") then
                isTrading = true
            end
        end
    end
    
    -- [CHANGE] We now insert the option regardless of isTrading status
    table.insert(options, {
        text = T("DTNPC_UI_Trade", nil, "Trade"),
        message = T("DTNPC_Dialogue_LetsSeeWhatYouGot", nil, "Let's see what you've got."),
        style = isTrading and { bgColor = {0.8, 0.7, 0.1, 0.4} } or nil,
        onSelect = function(ui)
            -- [CHANGE] Logic check happens here instead
            if isTrading then
                -- SUCCESS: Open Trade Window
                DynamicTrading.Log("DTV2", "Dialog", "Trade", "Trade option selected")
                requestCalledTraderTrading(player, npc, npcData)
                
                local traderID = (npcData and npcData.uuid) or npc:getPersistentOutfitID() or npc:getID()
                local archetype = npcData and npcData.archetypeID or "General"
                
                -- Check if stock is already cached
                local stockData = (DynamicTrading_Client and DynamicTrading_Client.Cache and DynamicTrading_Client.Cache.Stocks) 
                                  or ModData.get("DynamicTrading_Stock")
                
                if stockData and stockData[traderID] then
                    -- Stock ready - close conversation UI and open trading window
                    DynamicTrading.Log("DTV2", "Dialog", "Trade", "Stock cached, opening TradingWindow")
                    ui:close()
                    DT_TradingWindow.ToggleWindowV2(traderID, archetype, npc)
                else
                    -- [FIX] Guard against double-clicking if we already have a pending request
                    if DTNPC_TraderDialogue_Hub.PendingTrade and DTNPC_TraderDialogue_Hub.PendingTrade.traderID == traderID then
                        DynamicTrading.Log("DTV2", "Dialog", "Trade", "Ignoring redundant trade request - already pending for " .. traderID)
                        return
                    end
                    
                    -- Request stock generation, then open window
                    DynamicTrading.Log("DTV2", "Dialog", "Trade", "Requesting stock generation...")
                    ui:speak(T("DTNPC_Dialogue_CheckingStock", nil, "Let me check what I have in stock..."))
                    
                    -- Request stock from server
                    local args = { traderID = traderID }
                    sendClientCommand(player, "DynamicTrading_V2", "GenerateStock", args)
                    
                    -- Store pending trade context
                    DTNPC_TraderDialogue_Hub.PendingTrade = {
                        traderID = traderID,
                        archetype = archetype,
                        npc = npc,
                        ui = ui,
                        startTime = getGameTime():getWorldAgeHours()
                    }
                end
            else
                -- FAILURE: Refusal Dialogue
                local refusals = {
                    T("DTNPC_Dialogue_RefusalResting", nil, "I'm not open for business right now. Just resting."),
                    T("DTNPC_Dialogue_RefusalClosed", nil, "Shop's closed. I need a break."),
                    T("DTNPC_Dialogue_RefusalBusy", nil, "Can't you see I'm busy? Come back later."),
                    T("DTNPC_Dialogue_RefusalOffClock", nil, "I'm off the clock. Stop bothering me."),
                    T("DTNPC_Dialogue_RefusalCheckBack", nil, "Not now. Check back in a bit."),
                    T("DTNPC_Dialogue_RefusalStockNotReady", nil, "I don't have my stock organized yet."),
                    T("DTNPC_Dialogue_RefusalStopBothering", nil, "Stop bothering me, I'm resting."),
                    T("DTNPC_Dialogue_RefusalHoldingSpot", nil, "I'm just holding onto this spot for now. No trading.")
                }
                
                -- Pick a random refusal
                local msg = refusals[ZombRand(#refusals) + 1]
                ui:speak(msg)
                
                -- Regenerate options so player can choose something else
                DTNPC_TraderDialogue_Hub.GenerateOptions(ui, npc, player)
            end
        end
    })
    
    table.insert(options, {
        text = T("DTNPC_UI_Contacts", nil, "Contacts"),
        message = T("DTNPC_Dialogue_CheckContacts", nil, "Let me check my contacts."),
        onSelect = function(conversationUI)
            local selectTraderID = conversationUI and conversationUI.target and (conversationUI.target.uuid or conversationUI.target.traderID or conversationUI.target.id) or nil
            DT_ContactsWindow.Open({ selectTraderID = selectTraderID })
            DTNPC_TraderDialogue_Hub.GenerateOptions(conversationUI, npc, player)
        end
    })
    
    local footerAction = buildLeaveFooterAction()
    options._dtMenu = "root"
    options._dtFooterAction = footerAction
    options._dtNavigationBlock = buildNavigationBlock(footerAction, {
        resetHistory = true,
        debugLabel = "TraderHubRoot",
        requireExplicitNavigation = true,
    })
    ui:updateOptions(options, {
        resetHistory = true,
        navigationBlock = options._dtNavigationBlock,
    })
end

-- =============================================================================
-- PENDING TRADE POLLING
-- =============================================================================
DTNPC_TraderDialogue_Hub.PendingTrade = nil

local function OnTick()
    if not DTNPC_TraderDialogue_Hub.PendingTrade then return end
    
    local pending = DTNPC_TraderDialogue_Hub.PendingTrade
    
    -- Check if UI is still valid
    local uiValid = pending.ui and pending.ui:getIsVisible()
    if not uiValid then
        DynamicTrading.Log("DTV2", "Dialog", "Trade", "Pending trade cancelled - UI closed")
        clearInteractionPose(pending.npc)
        DTNPC_TraderDialogue_Hub.PendingTrade = nil
        return
    end
    
    -- Check for stock arrival
    local stockData = (DynamicTrading_Client and DynamicTrading_Client.Cache and DynamicTrading_Client.Cache.Stocks) 
                      or ModData.get("DynamicTrading_Stock")
    
    if stockData and stockData[pending.traderID] then
        DynamicTrading.Log("DTV2", "Dialog", "Trade", "Stock arrived! Opening TradingWindow")
        
        -- Close conversation UI
        pending.ui:close()
        
        -- Open trading window
        DT_TradingWindow.ToggleWindowV2(pending.traderID, pending.archetype, pending.npc)
        
        -- Clear pending
        DTNPC_TraderDialogue_Hub.PendingTrade = nil
        return
    end
    
    -- Timeout check (increased for multiplayer latency)
    local gt = getGameTime()
    local elapsed = gt:getWorldAgeHours() - pending.startTime
    
    -- Provide status update to player every few seconds
    if elapsed > 0.005 and not pending.hasSpokenShortWait then
        pending.ui:speak(T("DTNPC_Dialogue_StillLooking", nil, "Still looking for it, just a second..."))
        pending.hasSpokenShortWait = true
    end
    
    if gt and elapsed > 0.08 then
        DynamicTrading.Log("DTV2", "Dialog", "Trade", "Stock request timed out")
        if uiValid then
            pending.ui:speak(T("DTNPC_Dialogue_InventoryTrouble", nil, "Sorry, I'm having trouble with my inventory right now."))
        end
        clearInteractionPose(pending.npc)
        DTNPC_TraderDialogue_Hub.PendingTrade = nil
    end
end

-- Register tick handler
Events.OnTick.Remove(OnTick)
Events.OnTick.Add(OnTick)

DynamicTrading.Log("DTV2", "Init", "Dialog", "NPC Trader Dialogue Hub loaded")
