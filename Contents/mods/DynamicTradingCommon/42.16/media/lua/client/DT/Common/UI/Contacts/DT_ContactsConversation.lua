-- =============================================================================
-- DYNAMIC TRADING: CONTACTS CONVERSATION
-- =============================================================================
-- Dedicated radio-mode conversation flow for unlocked trader contacts.
-- =============================================================================

require "DT/Common/UI/ConversationUI/ConversationUI"
require "DT/Common/Contacts/DT_TraderContacts"

DT_ContactsConversation = DT_ContactsConversation or {}

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
    return string.format(
        "This is %s. Still working as a %s. Your standing with me sits at %d.",
        tostring(contact and contact.name or "Unknown"),
        role,
        rep
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

local function buildVisitResultLine(contact)
    local contactsAPI = getContactsAPI()
    if not contactsAPI then
        return "The contact network is unavailable right now. Try reopening the window."
    end

    local allowed, reason, hydrated = contactsAPI.CanRequestVisit(contact)
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
            return "This contact line is active, but the call-to-you travel behavior is only wired for V2 roster traders right now."
        end
        return "The line is unstable. Try that request again in a moment."
    end

    local ok = contactsAPI.RequestVisit(hydrated)
    if not ok then
        return "I heard you, but the request didn't stick. Try again in a second."
    end

    return "Copy that. I'll link up with you, follow your lead, and hold position once you start trading. Keep your radio up and look for me nearby."
end

function DT_ContactsConversation.BuildOptions(ui, contact, context)
    context = context or {}
    local contactsAPI = getContactsAPI()
    local visitCost = contactsAPI and contactsAPI.GetVisitCost and contactsAPI.GetVisitCost() or 0

    return {
        {
            text = string.format("Request visit (-%d Rep)", visitCost),
            message = "Can you come to my area and trade there instead?",
            onSelect = function(conversationUI)
                local refreshed = contactsAPI and contactsAPI.RefreshContactData and contactsAPI.RefreshContactData(contact) or contact
                conversationUI:speak(buildVisitResultLine(refreshed))
                if conversationUI.refreshFactionInfo then
                    conversationUI:refreshFactionInfo()
                end
                conversationUI:updateOptions(DT_ContactsConversation.BuildOptions(conversationUI, refreshed, context))
            end
        },
        {
            text = "Status check",
            message = "How are things on your end?",
            onSelect = function(conversationUI)
                local refreshed = contactsAPI and contactsAPI.RefreshContactData and contactsAPI.RefreshContactData(contact) or contact
                conversationUI:speak(buildStatusLine(refreshed))
                conversationUI:updateOptions(DT_ContactsConversation.BuildOptions(conversationUI, refreshed, context))
            end
        },
        {
            text = "Availability",
            message = "Are you available on the line?",
            onSelect = function(conversationUI)
                local refreshed = contactsAPI and contactsAPI.RefreshContactData and contactsAPI.RefreshContactData(contact) or contact
                conversationUI:speak(buildAvailabilityLine(refreshed))
                conversationUI:updateOptions(DT_ContactsConversation.BuildOptions(conversationUI, refreshed, context))
            end
        },
        {
            text = "End transmission",
            message = "That's all for now.",
            onSelect = function(conversationUI)
                if context.onClose then
                    context.onClose(conversationUI, contact)
                    return
                end
                conversationUI:close()
            end
        }
    }
end

function DT_ContactsConversation.Open(contact, context)
    local contactsAPI = getContactsAPI()
    if not contactsAPI then
        return nil
    end

    local target = contactsAPI.BuildConversationTarget(contact)
    if not target then
        return nil
    end

    local ui = DT_ConversationUI.Open(target, nil, nil, true, nil)
    ui.isContactConversation = true
    ui:speak(buildIntro(target))
    ui:updateOptions(DT_ContactsConversation.BuildOptions(ui, target, context))
    return ui
end

return DT_ContactsConversation