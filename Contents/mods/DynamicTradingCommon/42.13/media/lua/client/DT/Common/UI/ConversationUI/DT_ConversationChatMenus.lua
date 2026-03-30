-- =============================================================================
-- DYNAMIC TRADING: SHARED TRADER CHAT MENUS
-- =============================================================================
-- Shared chat submenu builders for trader conversations across V1/V2.
-- =============================================================================

require "DT/Common/DT_DialogueManager"
require "DT/Common/Reputation/DT_Reputation"
pcall(require, "DC/UI/Colony/System/DC_System")

DT_ConversationChatMenus = DT_ConversationChatMenus or {}

local DAILY_CHAT_REP_CHANCE = 25
local DAILY_CHAT_REP_GAIN = 1
local DAILY_CHAT_MODDATA_KEY = "DT_DailyChatFriendship"

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
    return tostring(name):gsub("_", " ")
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

function DT_ConversationChatMenus.BuildTraderChatOptions(ui, context)
    context = context or {}

    local options = {
        {
            text = "Tell me about yourself",
            message = "Tell me about yourself.",
            onSelect = function(conversationUI)
                conversationUI:speak(buildAboutYourselfText(conversationUI))
                conversationUI:updateOptions(DT_ConversationChatMenus.BuildTraderChatOptions(conversationUI, context))
            end
        },
        {
            text = "Any news",
            message = "Any news?",
            onSelect = function(conversationUI)
                conversationUI:speak(buildNewsText(conversationUI))
                conversationUI:updateOptions(DT_ConversationChatMenus.BuildTraderChatOptions(conversationUI, context))
            end
        },
        {
            text = "Do you want something?",
            message = "Do you want something?",
            onSelect = function(conversationUI)
                conversationUI:speak(buildWantsText(conversationUI))
                conversationUI:updateOptions(DT_ConversationChatMenus.BuildTraderChatOptions(conversationUI, context))
            end
        }
    }

    options._dtMenu = "chat"

    local colonySystem = getColonySystem()
    if colonySystem and colonySystem.BuildConversationChatOptions then
        options = colonySystem.BuildConversationChatOptions(ui, options)
    end

    options[#options + 1] = {
        text = context.backText or "Back",
        message = "",
        onSelect = function(conversationUI)
            if context.onBack then
                context.onBack(conversationUI, context)
            end
        end
    }

    return options
end

function DT_ConversationChatMenus.OpenTraderChat(ui, context)
    if not ui then
        return
    end

    local friendshipLine = maybeAwardDailyChatReputation(ui)
    ui:speak(friendshipLine or (context and context.introText) or "Sure. What's on your mind?")
    ui:updateOptions(DT_ConversationChatMenus.BuildTraderChatOptions(ui, context))
end

return DT_ConversationChatMenus
