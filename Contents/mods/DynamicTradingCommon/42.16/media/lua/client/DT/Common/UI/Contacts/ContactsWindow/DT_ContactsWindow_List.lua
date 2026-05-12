local Internal = DT_ContactsWindowInternal

function DT_ContactsWindow:populateContacts(selectTraderID)
    local contactsAPI = Internal.GetContactsAPI()
    local preservedTraderID = selectTraderID
    local selectedItem
    local contact
    local hydrated
    local item
    local selected

    if not preservedTraderID then
        preservedTraderID = self.selectedContact and self.selectedContact.id or nil
    end
    if not preservedTraderID and self.list and self.list.items and self.list.selected and self.list.selected > 0 then
        selectedItem = self.list.items[self.list.selected]
        preservedTraderID = selectedItem and selectedItem.item and selectedItem.item.id or nil
    end

    if not contactsAPI then
        self.contacts = {}
        self.selectedContact = nil
        if self.list then
            self.list:clear()
            self.list.selected = 0
        end
        self.statusPanelText = "Contacts module failed to load."
        self.headerStatusText = "Unable to open contacts right now. Try again after the UI reloads."
        return
    end

    contactsAPI.EnsureLoaded()
    self.contacts = contactsAPI.GetAllContacts()
    self.selectedContact = nil
    self.list:clear()
    self.list.selected = 0

    if DT_V2_RadarManager and DT_V2_RadarManager.RequestRoster then
        DT_V2_RadarManager.RequestRoster()
    end

    for _, contact in ipairs(self.contacts) do
        hydrated = contactsAPI.RefreshContactData(contact)
        item = self.list:addItem((hydrated and hydrated.name) or "Unknown", hydrated)
        item.height = self.list.itemheight
        if preservedTraderID and hydrated and tostring(hydrated.id) == tostring(preservedTraderID) then
            self.selectedContact = hydrated
            self.list.selected = #self.list.items
        end
    end

    if not self.selectedContact and #self.contacts > 0 then
        self.selectedContact = self.contacts[1]
        self.list.selected = 1
    end

    if self.deleteButton and self.deleteButton.setEnable then
        self.deleteButton:setEnable(self.selectedContact ~= nil)
    end

    if #self.contacts == 0 then
        self.statusPanelText = "No contacts unlocked yet. Ask a trader for their number through Chat."
        self.headerStatusText = "No saved contacts for this character yet."
    else
        selected = contactsAPI.RefreshContactData(self.selectedContact or self.contacts[1])
        if selected then
            self.selectedContact = selected
            self.statusPanelText = string.format(
                "%s | %s | %s",
                tostring(selected.name or "Unknown"),
                tostring(contactsAPI.GetFactionDisplayName and contactsAPI.GetFactionDisplayName(selected) or selected.factionName or selected.factionID or "Independent"),
                tostring(contactsAPI.GetStatusText and contactsAPI.GetStatusText(selected) or "Status unknown")
            )
        else
            self.statusPanelText = string.format("%d contact(s) available.", #self.contacts)
        end
        self.headerStatusText = "Select a frequency entry to inspect or call a trader."
    end
end

function DT_ContactsWindow:drawContactItem(y, item, alt)
    local contactsAPI = Internal.GetContactsAPI()
    local data = item and item.item or nil
    local width
    local height
    local isSelected
    local tex = nil
    local contentX = 75
    local role
    local factionName
    local rep
    local statusText
    local canVisit
    local isDead
    local fR, fG, fB = 1, 1, 1
    local sR, sG, sB = 0.75, 0.75, 0.75

    if not data then
        return y + item.height
    end

    width = self:getWidth()
    height = item.height
    isSelected = self.selected == item.index

    if isSelected then
        self:drawRect(0, y, width, height, 0.4, 0.05, 0.5, 0.05)
        self:drawRectBorder(0, y, width, height, 1.0, 0.1, 0.8, 0.1)
    elseif alt then
        self:drawRect(0, y, width, height, 0.1, 1, 1, 1)
    else
        self:drawRect(0, y, width, height, 0.1, 0, 0, 0)
    end

    if DynamicTrading and DynamicTrading.Portraits then
        local mappedID = DynamicTrading.Portraits.GetMappedID and DynamicTrading.Portraits.GetMappedID(data.archetype or "General", data.gender or "Male", data.identitySeed or 1) or 1
        local pathFolder = DynamicTrading.Portraits.GetPathFolder and DynamicTrading.Portraits.GetPathFolder(data.archetype or "General", data.gender or "Male") or nil
        if pathFolder then
            tex = getTexture(pathFolder .. tostring(mappedID) .. ".png")
        end
    end
    if not tex then
        tex = getTexture("Item_WalkieTalkie1")
    end
    if tex then
        self:drawTextureScaled(tex, 10, y + 5, 55, 55, 1, 1, 1, 1)
    end

    role = tostring(data.archetype or data.role or "Survivor")
    factionName = contactsAPI and contactsAPI.GetFactionDisplayName and contactsAPI.GetFactionDisplayName(data) or tostring(data.factionName or data.factionID or "Independent")
    rep = contactsAPI and contactsAPI.GetEffectiveReputation and contactsAPI.GetEffectiveReputation(data) or 0
    statusText = contactsAPI and contactsAPI.GetStatusText and contactsAPI.GetStatusText(data) or "Status unknown"
    canVisit = contactsAPI and contactsAPI.CanRequestVisit and contactsAPI.CanRequestVisit(data, {
        requestBackend = self.parent and self.parent.requestBackend or nil,
        radioObj = self.parent and self.parent.radioObj or nil
    }) or false
    isDead = tostring(data.status or "") == "Dead"

    self:drawText(tostring(data.name or "Unknown") .. " [" .. role .. "]", contentX, y + 5, 1, 1, 1, 1, UIFont.Small)

    if factionName == "Independent" then
        fR, fG, fB = 0.8, 0.8, 0.4
    end
    self:drawText("Faction: " .. factionName, contentX, y + 28, fR, fG, fB, 1, UIFont.Small)

    if isDead then
        sR, sG, sB = 0.88, 0.34, 0.34
    elseif canVisit then
        sR, sG, sB = 0.4, 1.0, 0.4
    end
    self:drawText(statusText, contentX, y + 47, sR, sG, sB, 1, UIFont.Small)
    self:drawTextRight("REP " .. tostring(rep), width - 14, y + 7, 0.85, 0.9, 1, 1, UIFont.Small)

    return y + item.height
end
