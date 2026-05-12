local Internal = DT_ContactsWindowInternal
local DT_ContactsHeaderPanel = Internal.HeaderPanelClass
local DT_ContactsStatusPanel = Internal.StatusPanelClass

function DT_ContactsStatusPanel:render()
    local owner = self.owner
    local contactsAPI
    local text
    local refreshed
    local factionName
    local statusText
    local lines
    local index
    local line

    ISPanel.render(self)

    if not owner then
        return
    end

    contactsAPI = Internal.GetContactsAPI()
    text = owner.statusPanelText or ""
    if owner.selectedContact and contactsAPI and contactsAPI.RefreshContactData then
        refreshed = contactsAPI.RefreshContactData(owner.selectedContact)
        if refreshed then
            owner.selectedContact = refreshed
            factionName = contactsAPI.GetFactionDisplayName and contactsAPI.GetFactionDisplayName(refreshed)
                or tostring(refreshed.factionName or refreshed.factionID or "Independent")
            statusText = contactsAPI.GetStatusText and contactsAPI.GetStatusText(refreshed) or "Status unknown"
            text = string.format("%s | %s | %s", tostring(refreshed.name or "Unknown"), tostring(factionName), tostring(statusText))
        end
    end

    lines = Internal.WrapUIText(text, self.width - 24, UIFont.Small)
    for index, line in ipairs(lines) do
        self:drawText(tostring(line), 12, 6 + ((index - 1) * 16), 0.84, 0.84, 0.84, 1, UIFont.Small)
    end
end

function DT_ContactsHeaderPanel:render()
    local owner = self.owner
    local titleText
    local statusText
    local countText
    local contactsAPI
    local refreshed
    local titleLines
    local statusLines
    local index
    local line

    ISPanel.render(self)

    if not owner then
        return
    end

    titleText = owner.headerTitleText or "Known traders you can reach over the radio."
    statusText = owner.headerStatusText or "Select a contact to open their frequency."
    countText = string.format("%d SAVED", #(owner.contacts or {}))
    contactsAPI = Internal.GetContactsAPI()
    if owner.selectedContact and contactsAPI and contactsAPI.GetStatusText then
        refreshed = contactsAPI.RefreshContactData and contactsAPI.RefreshContactData(owner.selectedContact) or owner.selectedContact
        if refreshed then
            owner.selectedContact = refreshed
            statusText = contactsAPI.GetStatusText(refreshed) or statusText
        end
    end

    titleLines = Internal.WrapUIText(titleText, self.width - 140, UIFont.Small)
    statusLines = Internal.WrapUIText(statusText, self.width - 24, UIFont.Small)

    for index, line in ipairs(titleLines) do
        self:drawText(tostring(line), 12, 8 + ((index - 1) * 16), 1, 1, 1, 1, UIFont.Small)
    end
    for index, line in ipairs(statusLines) do
        self:drawText(tostring(line), 12, 24 + ((index - 1) * 16), 0.78, 0.84, 0.9, 1, UIFont.Small)
    end
    self:drawTextRight(countText, self.width - 12, 8, 0.75, 0.85, 1, 1, UIFont.Small)
end
