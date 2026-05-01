-- =============================================================================
-- DYNAMIC TRADING: SHARED TRADER CHAT MENUS
-- =============================================================================
-- Shared chat submenu builders for trader conversations across V1/V2.
-- =============================================================================

require "DT/Common/DT_DialogueManager"
require "DT/Common/Reputation/DT_Reputation"
require "DT/Common/Contacts/DT_TraderContacts"
pcall(require, "DC/UI/Colony/System/DC_System")

DT_ConversationChatMenus = DT_ConversationChatMenus or {}

local DAILY_CHAT_REP_CHANCE = 25
local DAILY_CHAT_REP_GAIN = 1
local DAILY_CHAT_MODDATA_KEY = "DT_DailyChatFriendship"

local function refreshTraderChatOptions(ui, context)
    ui:replaceOptions(DT_ConversationChatMenus.BuildTraderChatOptions(ui, context))
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

local function getContactUnlockLabel(ui)
    local target = ui and ui.target or nil
    local requiredRep = DT_TraderContacts.GetRequiredReputationForTrader
        and DT_TraderContacts.GetRequiredReputationForTrader(target)
        or DT_TraderContacts.GetRequiredReputation()
    if not target then
        return "Request contact number"
    end

    if DT_TraderContacts.HasContact(target) then
        return "Ask about your contact line"
    end

    local rep = DT_TraderContacts.GetEffectiveReputation(target)
    if rep >= requiredRep then
        return "Request contact number"
    end

    return string.format("Request contact number (%d/%d Rep)", rep, requiredRep)
end

local function handleContactUnlock(ui, ignoreReputation)
    local target = ui and ui.target or nil
    if not target then
        return "I don't know who I'm talking to anymore."
    end

    local resolvedTarget = target
    local traderID = DT_TraderContacts.GetTraderID and DT_TraderContacts.GetTraderID(target) or nil
    if traderID and DT_TraderContacts.GetRosterSoul then
        local liveSoul = DT_TraderContacts.GetRosterSoul(traderID)
        if liveSoul then
            resolvedTarget = liveSoul
        end
    end
    if traderID and ui and ui.isRadio and DynamicTrading and DynamicTrading.Manager and DynamicTrading.Manager.GetTrader then
        local liveTrader = DynamicTrading.Manager.GetTrader(traderID)
        if liveTrader and (resolvedTarget == target or resolvedTarget.status == nil or resolvedTarget.returnTime == nil) then
            resolvedTarget = liveTrader
        end
    end

    local requiredRep = DT_TraderContacts.GetRequiredReputationForTrader
        and DT_TraderContacts.GetRequiredReputationForTrader(resolvedTarget)
        or DT_TraderContacts.GetRequiredReputation()
    local currentRep = DT_TraderContacts.GetEffectiveReputation(resolvedTarget)
    local alreadyUnlocked = DT_TraderContacts.HasContact(resolvedTarget)
    local ok, saved, reason = DT_TraderContacts.UnlockContact(resolvedTarget, {
        ignoreReputation = ignoreReputation == true,
        debugGranted = ignoreReputation == true,
    })

    if ok and alreadyUnlocked then
        return "You already have my number. Keep the radio close and use the Contacts list when you need me."
    end

    if ok and saved then
        return string.format(
            "Fine. You earned it. Save this frequency and reach me through Contacts when you need to talk, %s.",
            tostring(saved.name or resolvedTarget.name or target.name or "survivor")
        )
    end

    if reason == "rep" then
        return string.format(
            "Not yet. Build a bit more trust first. I need at least %d reputation before I hand over my frequency. You're at %d.",
            requiredRep,
            currentRep
        )
    end

    return "The line's bad right now. Ask me again in a bit."
end

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

local function getFactionLogChannel()
    local logKey = DynamicTrading
        and DynamicTrading.GameplayLogs
        and DynamicTrading.GameplayLogs.GetStorageKey
        and DynamicTrading.GameplayLogs.GetStorageKey("Factions")
        or "DynamicTrading_GameplayLogs_Factions"
    return ModData.getOrCreate(logKey) or {}
end

local function getFactionDisplayName(factionID, factions)
    local faction = type(factions) == "table" and factions[factionID] or nil
    if type(faction) == "table" then
        return tostring(faction.name or faction.id or factionID or "Unknown")
    end
    if tostring(factionID or "") == "Bandits" then
        return "Bandit Raiders"
    end
    if tostring(factionID or "") == "Independent" then
        return "Independent Traders"
    end
    return tostring(factionID or "Unknown")
end

local function isRumorEligibleLogEntry(entry)
    if type(entry) ~= "table" then
        return false
    end

    local gameplayEvents = DynamicTrading and DynamicTrading.GameplayEvents or nil
    if gameplayEvents and tonumber(entry.e) == tonumber(gameplayEvents.TRADE_STARTED) then
        return false
    end

    return true
end

local function resolveRumorEntryText(entry)
    if DynamicTrading and DynamicTrading.GameplayLogs and DynamicTrading.GameplayLogs.ResolveText then
        local textStr = DynamicTrading.GameplayLogs.ResolveText(entry)
        return tostring(textStr or "")
    end
    return tostring(entry and entry.text or "")
end

local function collectFactionRumorPool(currentFactionID)
    local logs = getFactionLogChannel()
    local currentPool = {}
    local otherPool = {}

    for factionID, entries in pairs(logs) do
        if type(entries) == "table" then
            local addedForFaction = 0
            for index = 1, #entries do
                local entry = entries[index]
                if isRumorEligibleLogEntry(entry) then
                    local payload = {
                        factionID = tostring(factionID),
                        entry = entry,
                    }
                    if tostring(factionID) == tostring(currentFactionID or "") then
                        currentPool[#currentPool + 1] = payload
                    else
                        otherPool[#otherPool + 1] = payload
                    end
                    addedForFaction = addedForFaction + 1
                    if addedForFaction >= 4 then
                        break
                    end
                end
            end
        end
    end

    return currentPool, otherPool
end

local function pickRandomRumor(pool)
    if not pool or #pool == 0 then
        return nil
    end
    return pool[ZombRand(#pool) + 1]
end

local function buildRumorLine(rumor, factions, prefix)
    if not rumor or not rumor.entry then
        return nil
    end

    local text = resolveRumorEntryText(rumor.entry)
    if text == "" or text == "Unknown event" or text == "Invalid Entry" then
        return nil
    end

    local factionName = getFactionDisplayName(rumor.factionID, factions)
    return string.format("%s %s: %s.", tostring(prefix or "Recent word from"), factionName, text)
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
    local allFactions = getAllKnownFactions()
    local lines = {}

    local currentRumors, otherRumors = collectFactionRumorPool(trader.factionID)
    local primaryRumor = pickRandomRumor(currentRumors)
    local secondaryRumor = pickRandomRumor(otherRumors)
    local primaryLine = buildRumorLine(primaryRumor, allFactions, "Latest word from")
    local secondaryLine = buildRumorLine(secondaryRumor, allFactions, "Other chatter says")

    if primaryLine then
        lines[#lines + 1] = primaryLine
    end
    if secondaryLine and secondaryLine ~= primaryLine then
        lines[#lines + 1] = secondaryLine
    end
    if #lines > 0 then
        return table.concat(lines, " ")
    end

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
                refreshTraderChatOptions(conversationUI, context)
            end
        },
        {
            text = "Any news",
            message = "Any news?",
            onSelect = function(conversationUI)
                conversationUI:speak(buildNewsText(conversationUI))
                refreshTraderChatOptions(conversationUI, context)
            end
        },
        {
            text = "Do you want something?",
            message = "Do you want something?",
            onSelect = function(conversationUI)
                conversationUI:speak(buildWantsText(conversationUI))
                refreshTraderChatOptions(conversationUI, context)
            end
        },
        {
            text = getContactUnlockLabel(ui),
            message = "Can I get your contact number?",
            onSelect = function(conversationUI)
                conversationUI:speak(handleContactUnlock(conversationUI, false))
                refreshTraderChatOptions(conversationUI, context)
            end
        }
    }

    if isDebugEnabled and isDebugEnabled() then
        options[#options + 1] = {
            text = "[DEBUG] Force contact unlock",
            message = "Let's skip the trust exercise and test the contact pipeline.",
            onSelect = function(conversationUI)
                conversationUI:speak(handleContactUnlock(conversationUI, true))
                refreshTraderChatOptions(conversationUI, context)
            end,
            style = {
                bgColor = { 0.25, 0.18, 0.12, 1 },
                borderColor = { 0.7, 0.5, 0.2, 1 },
                textColor = { 1, 0.88, 0.65, 1 }
            }
        }
    end

    options._dtMenu = "chat"

    local colonySystem = getColonySystem()
    if colonySystem and colonySystem.BuildConversationChatOptions then
        options = colonySystem.BuildConversationChatOptions(ui, options)
    end

    options._dtFooterAction = buildBackFooterAction({
        title = context.backText or "Back",
        message = context.backMessage or "",
        onSelect = function(conversationUI)
            if context.onBack then
                context.onBack(conversationUI, context)
            end
        end
    })
    options._dtNavigationBlock = buildNavigationBlock(options._dtFooterAction, {
        debugLabel = "TraderChat",
        requireExplicitNavigation = true,
    })

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
