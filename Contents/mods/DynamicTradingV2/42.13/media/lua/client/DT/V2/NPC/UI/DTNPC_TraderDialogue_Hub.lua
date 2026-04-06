-- =============================================================================
-- DYNAMIC TRADING V2: NPC TRADER DIALOGUE HUB
-- =============================================================================
require "DT/Common/UI/ConversationUI/ConversationUI"
require "DT/Common/UI/ConversationUI/DT_ConversationChatMenus"
require "DT/Common/Reputation/DT_Reputation"
require "DT/V2/NPC/DTNPC_TradingHandler"
require "DT/V2/NPC/DTNPC_InteractionPose"
require "DT/V2/UI/TradingWindowWrapper/TradingWindowWrapper"
require "DT/V2/Utils/DT_V2_OptionsManager"
pcall(require, "DT/V2/NPC/Jobs/DTNPC_JobUI")

DTNPC_TraderDialogue_Hub = {}

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


function DTNPC_TraderDialogue_Hub.Init(ui, npc, player)
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

            if DTNPCJobUI and DTNPCJobUI.ApplyTraderProxyPatch then
                traderProxy = (DTNPCJobUI.ApplyTraderProxyPatch(traderProxy, ui, npc, player, npcData))
            end

            if DT_Reputation then
                traderProxy.personalRep = DT_Reputation.GetPersonalRep(traderProxy.id)
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
                DynamicTrading.Log("DTV2", "Dialog", "Debug", "Trader Faction ID: nil")
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
    local greeting = "Hello. What can I do for you?"
    if DynamicTrading and DynamicTrading.DialogueManager and ui.target then
        greeting = DynamicTrading.DialogueManager.GenerateGreeting(ui.target)
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
        text = "Chat",
        message = "Got a minute to talk?",
        onSelect = function(conversationUI)
            DT_ConversationChatMenus.OpenTraderChat(conversationUI, {
                onBack = function(backUI)
                    DTNPC_TraderDialogue_Hub.GenerateOptions(backUI, npc, player)
                end
            })
        end
    })

    -- OPTION 2: TRADE (Always Visible)
    local isTrading = false
    
    if npcData and npcData.state ~= "Departure" and (npcData.status == "Trading" or npcData.state == "Trading") then
        isTrading = true
    else
        -- Fallback to Roster ModData if npcData is missing or unsynced
        local id = (npcData and npcData.uuid) or npc:getPersistentOutfitID() or npc:getID()
        local rosterData = ModData.get("DynamicTrading_Roster")
        if rosterData and rosterData.Souls and rosterData.Souls[id] then
            if rosterData.Souls[id].status == "Trading" or rosterData.Souls[id].state == "Trading" then
                isTrading = true
            end
        end
    end

    -- [CHANGE] We now insert the option regardless of isTrading status
    table.insert(options, {
        text = "Trade",
        message = "Let's see what you've got.",
        onSelect = function(ui)
            -- [CHANGE] Logic check happens here instead
            if isTrading then
                -- SUCCESS: Open Trade Window
                DynamicTrading.Log("DTV2", "Dialog", "Trade", "Trade option selected")
                
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
                    ui:speak("Let me check what I have in stock...")
                    
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
                    "I'm not open for business right now. Just resting.",
                    "Shop's closed. I need a break.",
                    "Can't you see I'm busy? Come back later.",
                    "I'm off the clock. Stop bothering me.",
                    "Not now. Check back in a bit.",
                    "I don't have my stock organized yet.",
                    "Stop bothering me, I'm resting.",
                    "I'm just holding onto this spot for now. No trading."
                }
                
                -- Pick a random refusal
                local msg = refusals[ZombRand(#refusals) + 1]
                ui:speak(msg)
                
                -- Regenerate options so player can choose something else
                DTNPC_TraderDialogue_Hub.GenerateOptions(ui, npc, player)
            end
        end
    })


    -- OPTION 4: SETTINGS (Common UI)
    table.insert(options, {
        text = "Settings",
        message = "Can I adjust some settings real quick?",
        onSelect = function(ui)
            if DT_V2_OptionsManager then
                DT_V2_OptionsManager.ToggleWindow()
                -- Keep Hub open in background
                DTNPC_TraderDialogue_Hub.GenerateOptions(ui, npc, player)
            end
        end
    })

    -- OPTION 5: LEAVE
    table.insert(options, {
        text = "Leave",
        message = "I'll be going now. Good luck.",
        onSelect = function(ui)
            ui:close()
        end
    })

    options._dtMenu = "root"
    ui:updateOptions(options)
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
        pending.ui:speak("Still looking for it, just a second...")
        pending.hasSpokenShortWait = true
    end

    if gt and elapsed > 0.08 then
        DynamicTrading.Log("DTV2", "Dialog", "Trade", "Stock request timed out")
        if uiValid then
            pending.ui:speak("Sorry, I'm having trouble with my inventory right now.")
        end
        clearInteractionPose(pending.npc)
        DTNPC_TraderDialogue_Hub.PendingTrade = nil
    end
end

-- Register tick handler
Events.OnTick.Remove(OnTick)
Events.OnTick.Add(OnTick)

DynamicTrading.Log("DTV2", "Init", "Dialog", "NPC Trader Dialogue Hub loaded")
