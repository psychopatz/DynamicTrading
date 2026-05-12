local Internal = DT_ContactsWindowInternal
local DT_ContactsDeleteModal = Internal.DeleteModalClass

function DT_ContactsWindow:onListMouseDown(item)
    local contactsAPI
    local statusText
    local factionName

    self.selectedContact = Internal.ResolveSelectedContact(self.list, item)
    if self.selectedContact then
        contactsAPI = Internal.GetContactsAPI()
        statusText = contactsAPI and contactsAPI.GetStatusText and contactsAPI.GetStatusText(self.selectedContact) or "Status unknown"
        self.headerStatusText = statusText
        factionName = contactsAPI and contactsAPI.GetFactionDisplayName and contactsAPI.GetFactionDisplayName(self.selectedContact)
            or tostring(self.selectedContact.factionName or self.selectedContact.factionID or "Independent")
        self.statusPanelText = string.format("%s | %s | %s", tostring(self.selectedContact.name or "Unknown"), tostring(factionName), tostring(statusText))
    end
    if self.deleteButton and self.deleteButton.setEnable then
        self.deleteButton:setEnable(self.selectedContact ~= nil)
    end
end

function DT_ContactsWindow:onListDoubleClick(item)
    self.selectedContact = Internal.ResolveSelectedContact(self.list, item)
    if self.selectedContact then
        self:onOpenFrequency()
    end
end

function DT_ContactsWindow:onRefresh()
    self.autoRefreshTicks = 0
    self:populateContacts(self.selectedContact and self.selectedContact.id or nil)
end

function DT_ContactsWindow:onDeleteContactConfirmed(button)
    local contactsAPI
    local deleted

    if button and button.internal ~= "YES" then
        return
    end

    contactsAPI = Internal.GetContactsAPI()
    if not contactsAPI or not self.selectedContact then
        return
    end

    deleted = contactsAPI.DeleteContact and contactsAPI.DeleteContact(self.selectedContact) or false
    if deleted then
        self.headerStatusText = "Contact removed. You can ask for their number again later if you still meet the reputation requirement."
        self.statusPanelText = tostring(self.selectedContact.name or "Contact") .. " removed from saved frequencies."
    else
        self.headerStatusText = "Unable to remove that contact right now."
        self.statusPanelText = "Delete failed. Try refreshing and trying again."
    end

    self.selectedContact = nil
    self:onRefresh()
end

function DT_ContactsWindow:onDeleteContact()
    self.selectedContact = Internal.ResolveSelectedContact(self.list, self.selectedContact)
    if not self.selectedContact then
        self.statusPanelText = "Select a contact first."
        return
    end

    DT_ContactsDeleteModal.Show(self, self.selectedContact)
end

function DT_ContactsWindow:onOpenFrequency()
    local contactsAPI

    self.selectedContact = Internal.ResolveSelectedContact(self.list, self.selectedContact)
    if not self.selectedContact then
        self.statusPanelText = "Select a contact first."
        return
    end

    contactsAPI = Internal.GetContactsAPI()
    if contactsAPI and contactsAPI.RefreshContactData then
        self.selectedContact = contactsAPI.RefreshContactData(self.selectedContact) or self.selectedContact
    end

    if tostring(self.selectedContact.status or "") == "Dead" then
        self.statusPanelText = "This contact is deceased and can no longer answer the frequency."
        return
    end

    DT_ContactsConversation.Open(self.selectedContact, {
        radioObj = self.radioObj,
        requestBackend = self.requestBackend,
        onClose = function(ui)
            ui:close()
        end
    })
end
