-- =============================================================================
-- DYNAMIC TRADING: CONTACTS CONVERSATION
-- =============================================================================
-- Dedicated radio-mode conversation flow for unlocked trader contacts.
-- =============================================================================

require "DT/Common/UI/ConversationUI/ConversationUI"
require "DT/Common/Contacts/DT_TraderContacts"

DT_ContactsConversation = DT_ContactsConversation or {}

local function getActiveRadioObject()
    if DT_RadioWindow and DT_RadioWindow.instance and DT_RadioWindow.instance.radioObj then
        return DT_RadioWindow.instance.radioObj
    end

    return nil
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

local function getContactsAPI()
    local api = DT_TraderContacts
    if type(api) == "table" then
        return api
    end

    pcall(require, "DT/Common/Contacts/DT_TraderContacts")
    api = DT_TraderContacts
    if type(api) == "table" then
        return api
    end

    return nil
end

local function buildIntro(contact)
    return string.format(
        "You tune into %s's frequency. Static rolls through before the line steadies.",
        tostring(contact and contact.name or "Unknown")
    )
end

local function buildStatusLine(contact)
    local contactsAPI = getContactsAPI()
    local rep = contactsAPI and contactsAPI.GetEffectiveReputation and contactsAPI.GetEffectiveReputation(contact) or 0
    local role = tostring(contact and (contact.archetype or contact.role) or "Survivor")
    local statusText = contactsAPI and contactsAPI.GetStatusText and contactsAPI.GetStatusText(contact) or "Status unknown"
    return string.format(
        "This is %s. Still working as a %s. Your standing with me sits at %d. %s.",
        tostring(contact and contact.name or "Unknown"),
        role,
        rep,
        tostring(statusText)
    )
end

local function buildAvailabilityLine(contact)
    local contactsAPI = getContactsAPI()
    local state = contactsAPI and contactsAPI.GetStatusText and contactsAPI.GetStatusText(contact) or "Status unknown"
    if not state or state == "" then
        return "Signal's good. I can talk, but I haven't put eyes on the road situation from here yet."
    end

    return state .. ". Keep that in mind before you ask me to move."
end

local function buildVisitResultLine(contact, context)
    local contactsAPI = getContactsAPI()
    if not contactsAPI then
        return "The contact network is unavailable right now. Try reopening the window."
    end

    context = context or {}

    local allowed, reason, hydrated = contactsAPI.CanRequestVisit(contact, {
        requestBackend = context.requestBackend,
        radioObj = context.radioObj,
    })
    if not allowed then
        if reason == "rep" then
            return string.format(
                "Not happening yet. I need at least %d reputation before I burn time and fuel for a personal stop.",
                contactsAPI.GetVisitRequiredReputation()
            )
        end
        if reason == "state" then
            return string.format(
                "Can't do that right now. %s.",
                string.lower(contactsAPI.GetStatusText(hydrated or contact))
            )
        end
        if reason == "unsupported" then
            return "This contact line is active, but the trader data needed to route the visit is not available right now."
        end
        return "The line is unstable. Try that request again in a moment."
    end

    local ok, updated, walkHours = contactsAPI.RequestVisit(hydrated, {
        requestBackend = context.requestBackend,
        radioObj = context.radioObj,
    })
    if not ok then
        return "I heard you, but the request didn't stick. Try again in a second."
    end

    local etaText = contactsAPI.GetArrivalCountdownText and contactsAPI.GetArrivalCountdownText(updated) or nil
    if not etaText and walkHours then
        local totalMinutes = math.max(1, math.floor(tonumber(walkHours) * 60))
        etaText = string.format("%dm", totalMinutes)
    end

    if etaText then
        return "Copy that. I am on the move now. Watch your radio for an arrival ETA of " .. tostring(etaText) .. "."
    end

    return "Copy that. I am on the move now. Keep your radio up and look for me nearby."
end

function DT_ContactsConversation.BuildOptions(ui, contact, context)
    context = context or {}
    local contactsAPI = getContactsAPI()
    local visitCost = contactsAPI and contactsAPI.GetVisitCost and contactsAPI.GetVisitCost() or 0
    local canVisit, reason, refreshedContact = contactsAPI and contactsAPI.CanRequestVisit and contactsAPI.CanRequestVisit(contact, {
        requestBackend = context.requestBackend,
        radioObj = context.radioObj,
    }) or false, nil, contact
    if contactsAPI and contactsAPI.CanRequestVisit then
        canVisit, reason, refreshedContact = contactsAPI.CanRequestVisit(contact, {
            requestBackend = context.requestBackend,
            radioObj = context.radioObj,
        })
    end

    local requestText = string.format("Request visit (-%d Rep)", visitCost)
    local requestStyle = {
        bgColor = { 0.18, 0.22, 0.18, 1.0 },
        borderColor = { 0.42, 0.56, 0.42, 1.0 },
        textColor = { 0.92, 0.98, 0.92, 1.0 },
    }

    if not canVisit then
        if reason == "rep" then
            requestStyle = {
                bgColor = { 0.24, 0.16, 0.16, 1.0 },
                borderColor = { 0.52, 0.26, 0.26, 1.0 },
                textColor = { 0.98, 0.86, 0.86, 1.0 },
            }
        else
            requestStyle = {
                bgColor = { 0.17, 0.17, 0.17, 1.0 },
                borderColor = { 0.32, 0.32, 0.32, 1.0 },
                textColor = { 0.72, 0.72, 0.72, 1.0 },
            }
        end

        local etaText = contactsAPI and contactsAPI.GetArrivalCountdownText and contactsAPI.GetArrivalCountdownText(refreshedContact or contact) or nil
        if etaText then
            requestText = string.format("Request visit unavailable (ETA %s)", etaText)
        elseif reason == "rep" and contactsAPI and contactsAPI.GetVisitRequiredReputation then
            requestText = string.format("Request visit locked (%d Rep needed)", contactsAPI.GetVisitRequiredReputation())
        elseif reason == "state" then
            requestText = "Request visit unavailable right now"
        elseif reason == "unsupported" then
            requestText = "Request visit unavailable on this contact"
        end
    end

    local options = {
        {
            text = requestText,
            message = "Can you come to my area and trade there instead?",
            style = requestStyle,
            onSelect = function(conversationUI)
                local refreshed = contactsAPI and contactsAPI.RefreshContactData and contactsAPI.RefreshContactData(contact) or contact
                local resultLine = buildVisitResultLine(refreshed, context)
                local activeContact = contactsAPI and contactsAPI.RefreshContactData and contactsAPI.RefreshContactData(refreshed) or refreshed
                if activeContact then
                    contact = activeContact
                    conversationUI.target = contactsAPI.BuildConversationTarget and contactsAPI.BuildConversationTarget(activeContact) or activeContact
                end
                conversationUI:speak(resultLine)
                if conversationUI.refreshFactionInfo then
                    conversationUI:refreshFactionInfo()
                end
                conversationUI:updateOptions(DT_ContactsConversation.BuildOptions(conversationUI, activeContact or refreshed, context))
            end
        },
        {
            text = "Status check",
            message = "How are things on your end?",
            onSelect = function(conversationUI)
                local refreshed = contactsAPI and contactsAPI.RefreshContactData and contactsAPI.RefreshContactData(contact) or contact
                if refreshed then
                    contact = refreshed
                    conversationUI.target = contactsAPI.BuildConversationTarget and contactsAPI.BuildConversationTarget(refreshed) or refreshed
                end
                conversationUI:speak(buildStatusLine(refreshed))
                conversationUI:updateOptions(DT_ContactsConversation.BuildOptions(conversationUI, refreshed, context))
            end
        },
        {
            text = "Availability",
            message = "Are you available on the line?",
            onSelect = function(conversationUI)
                local refreshed = contactsAPI and contactsAPI.RefreshContactData and contactsAPI.RefreshContactData(contact) or contact
                if refreshed then
                    contact = refreshed
                    conversationUI.target = contactsAPI.BuildConversationTarget and contactsAPI.BuildConversationTarget(refreshed) or refreshed
                end
                conversationUI:speak(buildAvailabilityLine(refreshed))
                conversationUI:updateOptions(DT_ContactsConversation.BuildOptions(conversationUI, refreshed, context))
            end
        }
    }

    options._dtFooterAction = buildLeaveFooterAction({
        title = "End transmission",
        message = "That's all for now.",
        suppressExitEmote = true,
        onSelect = function(conversationUI)
            if context.onClose then
                context.onClose(conversationUI, contact)
            end
        end
    })
    options._dtNavigationBlock = buildNavigationBlock(options._dtFooterAction, {
        debugLabel = "ContactsConversation",
        requireExplicitNavigation = true,
    })

    return options
end

function DT_ContactsConversation.Open(contact, context)
    context = context or {}

    if not context.requestBackend and context.radioObj then
        context.requestBackend = "DynamicTradingV1"
    end

    local contactsAPI = getContactsAPI()
    if not contactsAPI then
        return nil
    end

    local target = contactsAPI.BuildConversationTarget(contact)
    if not target then
        return nil
    end

    local interactionObj = context.radioObj or getActiveRadioObject()
    local ui = DT_ConversationUI.Open(target, nil, nil, true, interactionObj)
    ui.isContactConversation = true
    ui:speak(buildIntro(target))
    ui:updateOptions(DT_ContactsConversation.BuildOptions(ui, target, context))
    return ui
end

return DT_ContactsConversation
