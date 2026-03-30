-- =============================================================================
-- DYNAMIC TRADING V2: NPC TRADER DIALOGUE HUB
-- =============================================================================
require "DT/Common/UI/ConversationUI/ConversationUI"
require "DT/Common/Reputation/DT_Reputation"
require "DT/V2/NPC/DTNPC_TradingHandler"
require "DT/V2/NPC/DTNPC_InteractionPose"
require "DT/V2/UI/TradingWindowWrapper/TradingWindowWrapper"
require "DT/V2/Utils/DT_V2_OptionsManager"

local DEBUG_PREFIX = "[DT-V2-Hub]"
local DAILY_CHAT_REP_CHANCE = 25
local DAILY_CHAT_REP_GAIN = 1
local DAILY_CHAT_MODDATA_KEY = "DT_DailyChatFriendship"

DTNPC_TraderDialogue_Hub = {}

local function getColonySystem()
    local mods = getActivatedMods and getActivatedMods() or nil
    local colonyActive = mods and mods.contains and mods:contains("DynamicColonies") or false
    if colonyActive and rawget(_G, "DC_System") then
        return DC_System
    end
    return nil
end

local function getTraderRole(trader)
    return tostring((trader and (trader.archetype or trader.role)) or "Survivor")
end

local function collectFlashEvents(faction)
    local flashEvents = {}
    if not faction then
        return flashEvents
    end

    if type(faction.ActiveFlashEvents) == "table" then
        for _, eventData in ipairs(faction.ActiveFlashEvents) do
            flashEvents[#flashEvents + 1] = eventData
        end
    end

    if #flashEvents == 0 and faction.ActiveFlashEvent and faction.ActiveFlashEvent.id then
        flashEvents[#flashEvents + 1] = {
            id = faction.ActiveFlashEvent.id,
            expires = faction.ActiveFlashEvent.expires
        }
    end

    return flashEvents
end

local function getFlashEventName(eventID)
    local registry = DynamicTrading and DynamicTrading.Events and DynamicTrading.Events.Registry or nil
    local entry = registry and registry[eventID] or nil
    local name = (entry and entry.name) or tostring(eventID or "trouble")
    name = tostring(name):gsub("_", " ")
    return name
end

local function formatNaturalList(items)
    if not items or #items == 0 then
        return ""
    end
    if #items == 1 then
        return tostring(items[1])
    end

    local head = {}
    for i = 1, #items - 1 do
        head[#head + 1] = tostring(items[i])
    end
    return table.concat(head, ", ") .. " and " .. tostring(items[#items])
end

local function getFactionSources()
    return {
        DynamicTrading_Client and DynamicTrading_Client.Cache and DynamicTrading_Client.Cache.Factions,
        DT_V2_RadarManager and DT_V2_RadarManager.ClientFactions,
        ModData.get("DynamicTrading_Factions")
    }
end

local function getAllKnownFactions()
    for _, source in ipairs(getFactionSources()) do
        if type(source) == "table" then
            return source
        end
    end
    return {}
end

local function getLocalPlayer()
    if getSpecificPlayer then
        local player = getSpecificPlayer(0)
        if player then
            return player
        end
    end
    if getPlayer then
        return getPlayer()
    end
    return nil
end

local function getCurrentConversationDay()
    local gt = getGameTime and getGameTime() or nil
    local hours = gt and gt:getWorldAgeHours() or 0
    return math.floor((tonumber(hours) or 0) / 24)
end

local function getDailyChatStore(player)
    local modData = player and player:getModData() or nil
    if not modData then
        return nil
    end

    if type(modData[DAILY_CHAT_MODDATA_KEY]) ~= "table" then
        modData[DAILY_CHAT_MODDATA_KEY] = {}
    end

    return modData[DAILY_CHAT_MODDATA_KEY]
end

local function maybeAwardDailyChatReputation(ui)
    local player = getLocalPlayer()
    local target = ui and ui.target or nil
    if not player or not target then
        return nil
    end

    local traderID = target.uuid or target.traderID or target.id
    if not traderID then
        return nil
    end

    local store = getDailyChatStore(player)
    if not store then
        return nil
    end

    local key = tostring(traderID)
    local currentDay = getCurrentConversationDay()
    local entry = store[key]
    if type(entry) == "table" and tonumber(entry.day) == currentDay then
        return nil
    end

    local triggered = ZombRand(100) < DAILY_CHAT_REP_CHANCE
    store[key] = { day = currentDay, gained = triggered == true }
    if player.transmitModData then
        player:transmitModData()
    end

    if not triggered then
        return nil
    end

    if DT_Reputation and DT_Reputation.ModifyPersonalRep then
        DT_Reputation.ModifyPersonalRep(tostring(traderID), target.factionID, DAILY_CHAT_REP_GAIN, "conversation_friendship")
    end

    if ui.refreshFactionInfo then
        ui:refreshFactionInfo()
    end

    local lines = {
        "I like what you do out there. You keep your word, and that matters these days.",
        "You're easy to deal with. Fair, steady, and not looking to make life harder for people.",
        "I don't open up to many people, but you've earned some trust. You treat folks right.",
        "You carry yourself well. No nonsense, no cheap tricks. That's why I don't mind talking to you.",
        "I've taken a liking to you. You actually listen, and you don't bring trouble to my door."
    }

    return lines[ZombRand(#lines) + 1]
end

local function buildAboutYourselfText(ui)
    local trader = ui and ui.target or {}
    local role = getTraderRole(trader)
    local faction = ui and ui.getFactionData and ui:getFactionData(trader.factionID) or nil
    local factionName = ui and ui.getFactionName and ui:getFactionName(trader, faction) or nil

    if not trader.factionID or trader.factionID == "Independent" then
        return string.format(
            "I'm %s, a %s. No faction behind me. Just a lone trader trying to stay alive.",
            tostring(trader.name or "Unknown"),
            role
        )
    end

    return string.format(
        "I'm %s, a %s with %s.",
        tostring(trader.name or "Unknown"),
        role,
        tostring(factionName or trader.factionID or "an outfit")
    )
end

local function buildNewsText(ui)
    local trader = ui and ui.target or {}
    local faction = ui and ui.getFactionData and ui:getFactionData(trader.factionID) or nil
    local factionName = ui and ui.getFactionName and ui:getFactionName(trader, faction) or nil
    local lines = {}

    if trader.factionID and trader.factionID ~= "Independent" then
        local localEvents = collectFlashEvents(faction)
        if #localEvents > 0 then
            local eventNames = {}
            for _, eventData in ipairs(localEvents) do
                eventNames[#eventNames + 1] = getFlashEventName(eventData.id)
            end
            lines[#lines + 1] = string.format(
                "%s has %s on our hands right now.",
                tostring(factionName or trader.factionID),
                formatNaturalList(eventNames)
            )
        else
            local state = faction and faction.state or "Stable"
            lines[#lines + 1] = string.format(
                "%s is %s right now. Nothing too wild on our end.",
                tostring(factionName or trader.factionID),
                string.lower(tostring(state))
            )
        end
    else
        lines[#lines + 1] = "I'm independent, so most of my news comes from the road."
    end

    local allFactions = getAllKnownFactions()
    local otherFaction = nil
    for id, candidate in pairs(allFactions) do
        if id ~= trader.factionID and candidate then
            local candidateEvents = collectFlashEvents(candidate)
            if #candidateEvents > 0 or (candidate.state and candidate.state ~= "Stable") then
                otherFaction = candidate
                break
            end
        end
    end

    if otherFaction then
        local otherEvents = collectFlashEvents(otherFaction)
        if #otherEvents > 0 then
            local names = {}
            for _, eventData in ipairs(otherEvents) do
                names[#names + 1] = getFlashEventName(eventData.id)
            end
            lines[#lines + 1] = string.format(
                "Word is %s is dealing with %s.",
                tostring(otherFaction.name or otherFaction.id or "another faction"),
                formatNaturalList(names)
            )
        elseif otherFaction.state and otherFaction.state ~= "" then
            lines[#lines + 1] = string.format(
                "Heard %s has been %s lately.",
                tostring(otherFaction.name or otherFaction.id or "another faction"),
                string.lower(tostring(otherFaction.state))
            )
        end
    end

    return table.concat(lines, " ")
end

local function buildWantsText(ui)
    if DynamicTrading and DynamicTrading.DialogueManager and ui and ui.target then
        return DynamicTrading.DialogueManager.GenerateSellAskDialogue(ui.target)
    end
    return "Bring me something worth trading and I'll take a look."
end

local function buildChatOptions(ui, npc, player)
    local options = {
        {
            text = "Tell me about yourself",
            message = "Tell me about yourself.",
            onSelect = function(conversationUI)
                conversationUI:speak(buildAboutYourselfText(conversationUI))
                conversationUI:updateOptions(buildChatOptions(conversationUI, npc, player))
            end
        },
        {
            text = "Any news",
            message = "Any news?",
            onSelect = function(conversationUI)
                conversationUI:speak(buildNewsText(conversationUI))
                conversationUI:updateOptions(buildChatOptions(conversationUI, npc, player))
            end
        },
        {
            text = "Do you want something?",
            message = "Do you want something?",
            onSelect = function(conversationUI)
                conversationUI:speak(buildWantsText(conversationUI))
                conversationUI:updateOptions(buildChatOptions(conversationUI, npc, player))
            end
        }
    }

    options._dtMenu = "chat"

    local colonySystem = getColonySystem()
    if colonySystem and colonySystem.BuildConversationChatOptions then
        options = colonySystem.BuildConversationChatOptions(ui, options)
    end

    options[#options + 1] = {
        text = "Back",
        message = "",
        onSelect = function(conversationUI)
            DTNPC_TraderDialogue_Hub.GenerateOptions(conversationUI, npc, player)
        end
    }

    return options
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

    -- OPTION 1: CHAT (First implementation)
    table.insert(options, {
        text = "Chat",
        message = "Got a minute to talk?",
        onSelect = function(ui)
            local friendshipLine = maybeAwardDailyChatReputation(ui)
            ui:speak(friendshipLine or "Sure. What's on your mind?")
            ui:updateOptions(buildChatOptions(ui, npc, player))
        end
    })

    -- OPTION 2: TRADE (Always Visible)
    local npcData = DTNPC.GetData(npc)
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
