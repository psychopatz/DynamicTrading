-- =============================================================================
-- DYNAMIC TRADING: CONTACTS WINDOW
-- =============================================================================
-- Lightweight window for browsing unlocked trader contacts and opening a
-- dedicated radio-mode conversation.
-- =============================================================================

require "ISUI/ISCollapsableWindow"
require "ISUI/ISPanel"
require "ISUI/ISScrollingListBox"
require "ISUI/ISButton"
require "ISUI/ISLabel"
require "ISUI/ISModalDialog"
require "Utils/DT_StringUtils"
require "DT/Common/Contacts/DT_TraderContacts"
require "DT/Common/UI/Contacts/DT_ContactsConversation"
require "DT/Common/UI/Portrait/Portrait"

DT_ContactsWindow = DT_ContactsWindow or ISCollapsableWindow:derive("DT_ContactsWindow")
DT_ContactsWindow.instance = nil

local DT_ContactsHeaderPanel = ISPanel:derive("DT_ContactsHeaderPanel")
local DT_ContactsStatusPanel = ISPanel:derive("DT_ContactsStatusPanel")
local DT_ContactsDeleteModal = ISCollapsableWindow:derive("DT_ContactsDeleteModal")
local getContactsAPI
local AUTO_REFRESH_TICKS = 180

local function resolveSelectedContact(list, itemOrContact)
    if type(itemOrContact) == "table" then
        if type(itemOrContact.item) == "table" then
            return itemOrContact.item
        end
        if itemOrContact.id or itemOrContact.uuid or itemOrContact.traderID then
            return itemOrContact
        end
    end

    local selectedIndex = list and list.selected or 0
    if list and list.items and selectedIndex and selectedIndex > 0 then
        local selectedItem = list.items[selectedIndex]
        if selectedItem and type(selectedItem.item) == "table" then
            return selectedItem.item
        end
    end

    return nil
end

local function wrapUIText(text, maxWidth, font)
    if DynamicTrading and DynamicTrading.Utils and DynamicTrading.Utils.WrapText then
        return DynamicTrading.Utils.WrapText(tostring(text or ""), maxWidth, font or UIFont.Small)
    end

    return { tostring(text or "") }
end

local function buildDeleteModalText(contact)
    local name = tostring(contact and contact.name or "this contact")
    local reason = tostring(contact and contact.deathReason or "")
    local flavor = tostring(contact and contact.deathFlavorText or "")

    if reason == "Starvation" then
        return string.format(
            "Delete saved contact for %s?\n\nThis trader was lost to starvation. Removing this entry only clears the saved frequency from your contacts list.",
            name
        )
    end

    if reason == "WipedOut" then
        return string.format(
            "Delete saved contact for %s?\n\nThis trader's faction was wiped out. Removing this entry only clears the saved frequency from your contacts list.",
            name
        )
    end

    if tostring(contact and contact.status or "") == "Dead" then
        if flavor ~= "" then
            return string.format(
                "Delete saved contact for %s?\n\nRecorded cause of death: %s. Removing this entry only clears the saved frequency from your contacts list.",
                name,
                flavor
            )
        end
        return string.format(
            "Delete saved contact for %s?\n\nThis trader is deceased. Removing this entry only clears the saved frequency from your contacts list.",
            name
        )
    end

    return string.format(
        "Delete saved contact for %s?\n\nThis only removes the saved number. If you still qualify, you can unlock it again through Chat.",
        name
    )
end

function DT_ContactsDeleteModal:initialise()
    ISCollapsableWindow.initialise(self)
    self:setResizable(false)
end

function DT_ContactsDeleteModal:createChildren()
    ISCollapsableWindow.createChildren(self)

    local btnW = 100
    local btnH = 24
    local btnGap = 12
    local btnY = self.height - 34
    local btnX = math.floor((self.width - ((btnW * 2) + btnGap)) / 2)

    self.btnYes = ISButton:new(btnX, btnY, btnW, btnH, "Yes", self, self.onConfirm)
    self.btnYes:initialise()
    self.btnYes.backgroundColor = { r = 0.15, g = 0.45, b = 0.15, a = 1.0 }
    self.btnYes.borderColor = { r = 1, g = 1, b = 1, a = 0.35 }
    self:addChild(self.btnYes)

    self.btnNo = ISButton:new(btnX + btnW + btnGap, btnY, btnW, btnH, "No", self, self.onCancel)
    self.btnNo:initialise()
    self.btnNo.backgroundColor = { r = 0.45, g = 0.1, b = 0.1, a = 1.0 }
    self.btnNo.borderColor = { r = 1, g = 1, b = 1, a = 0.35 }
    self:addChild(self.btnNo)
end

function DT_ContactsDeleteModal:render()
    ISCollapsableWindow.render(self)

    local text = tostring(self.modalText or "")
    local lines = wrapUIText(text, self.width - 36, UIFont.Small)
    local startY = self:titleBarHeight() + 24
    local lineH = getTextManager():getFontHeight(UIFont.Small)

    for index, line in ipairs(lines) do
        self:drawTextCentre(tostring(line), self.width / 2, startY + ((index - 1) * lineH), 0.94, 0.94, 0.94, 1, UIFont.Small)
    end
end

function DT_ContactsDeleteModal:onConfirm()
    if self.owner and self.owner.onDeleteContactConfirmed then
        self.owner:onDeleteContactConfirmed(nil, { internal = "YES" })
    end
    self:close()
end

function DT_ContactsDeleteModal:onCancel()
    self:close()
end

function DT_ContactsDeleteModal:close()
    self:setVisible(false)
    self:removeFromUIManager()
end

function DT_ContactsDeleteModal.Show(owner, contact)
    if not owner then
        return nil
    end

    local width = 420
    local height = 170
    local x = owner:getX() + math.max(20, math.floor((owner:getWidth() - width) / 2))
    local y = owner:getY() + math.max(30, math.floor((owner:getHeight() - height) / 2))

    local modal = DT_ContactsDeleteModal:new(x, y, width, height)
    modal:initialise()
    modal.title = "Confirm Contact Removal"
    modal.owner = owner
    modal.contact = contact
    modal.modalText = buildDeleteModalText(contact)
    modal:addToUIManager()
    return modal
end

function DT_ContactsStatusPanel:render()
    ISPanel.render(self)

    local owner = self.owner
    if not owner then
        return
    end

    local contactsAPI = getContactsAPI()
    local text = owner.statusPanelText or ""
    if owner.selectedContact and contactsAPI and contactsAPI.RefreshContactData then
        local refreshed = contactsAPI.RefreshContactData(owner.selectedContact)
        if refreshed then
            owner.selectedContact = refreshed
            local factionName = contactsAPI.GetFactionDisplayName and contactsAPI.GetFactionDisplayName(refreshed) or tostring(refreshed.factionName or refreshed.factionID or "Independent")
            local statusText = contactsAPI.GetStatusText and contactsAPI.GetStatusText(refreshed) or "Status unknown"
            text = string.format("%s | %s | %s", tostring(refreshed.name or "Unknown"), tostring(factionName), tostring(statusText))
        end
    end

    local lines = wrapUIText(text, self.width - 24, UIFont.Small)
    for index, line in ipairs(lines) do
        self:drawText(tostring(line), 12, 6 + ((index - 1) * 16), 0.84, 0.84, 0.84, 1, UIFont.Small)
    end
end

function DT_ContactsHeaderPanel:render()
    ISPanel.render(self)

    local owner = self.owner
    if not owner then
        return
    end

    local titleText = owner.headerTitleText or "Known traders you can reach over the radio."
    local statusText = owner.headerStatusText or "Select a contact to open their frequency."
    local countText = string.format("%d SAVED", #(owner.contacts or {}))
    local contactsAPI = getContactsAPI and getContactsAPI() or nil
    if owner.selectedContact and contactsAPI and contactsAPI.GetStatusText then
        local refreshed = contactsAPI.RefreshContactData and contactsAPI.RefreshContactData(owner.selectedContact) or owner.selectedContact
        if refreshed then
            owner.selectedContact = refreshed
            statusText = contactsAPI.GetStatusText(refreshed) or statusText
        end
    end
    local titleLines = wrapUIText(titleText, self.width - 140, UIFont.Small)
    local statusLines = wrapUIText(statusText, self.width - 24, UIFont.Small)

    for index, line in ipairs(titleLines) do
        self:drawText(tostring(line), 12, 8 + ((index - 1) * 16), 1, 1, 1, 1, UIFont.Small)
    end
    for index, line in ipairs(statusLines) do
        self:drawText(tostring(line), 12, 24 + ((index - 1) * 16), 0.78, 0.84, 0.9, 1, UIFont.Small)
    end
    self:drawTextRight(countText, self.width - 12, 8, 0.75, 0.85, 1, 1, UIFont.Small)
end

getContactsAPI = function()
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

function DT_ContactsWindow.Open(options)
    options = options or {}

    if DT_ContactsWindow.instance then
        DT_ContactsWindow.instance:close()
    end

    local ui = DT_ContactsWindow:new(180, 120, 720, 560)
    ui:initialise()
    ui:addToUIManager()
    ui.radioObj = options.radioObj
    ui.requestBackend = options.requestBackend
    ui:populateContacts(options.selectTraderID)
    DT_ContactsWindow.instance = ui
    return ui
end

function DT_ContactsWindow:initialise()
    ISCollapsableWindow.initialise(self)
    self:setResizable(true)
    self.title = "Contacts"
    self.contacts = {}
    self.selectedContact = nil
    self.minimumWidth = 620
    self.minimumHeight = 470
    self.headerTitleText = "Known traders you can reach over the radio."
    self.headerStatusText = "Select a contact to open their frequency."
    self.statusPanelText = "Select a frequency entry to inspect or call a trader."
    self.autoRefreshTicks = 0
end

function DT_ContactsWindow:createChildren()
    ISCollapsableWindow.createChildren(self)

    local th = self:titleBarHeight()
    local pad = 10

    self.closeButton = ISButton:new(self.width - 18, 2, 13, 13, "X", self, self.close)
    self.closeButton:initialise()
    self.closeButton.borderColor = { r = 0, g = 0, b = 0, a = 0 }
    self.closeButton.backgroundColor = { r = 0, g = 0, b = 0, a = 0 }
    self.closeButton.textColor = { r = 1, g = 1, b = 1, a = 1 }
    self:addChild(self.closeButton)

    self.headerPanel = DT_ContactsHeaderPanel:new(pad, th + pad, self.width - (pad * 2), 60)
    self.headerPanel:initialise()
    self.headerPanel.owner = self
    self.headerPanel.backgroundColor = { r = 0.03, g = 0.03, b = 0.03, a = 0.92 }
    self.headerPanel.borderColor = { r = 0.28, g = 0.28, b = 0.28, a = 1 }
    self.headerPanel:setAnchorLeft(true)
    self.headerPanel:setAnchorRight(true)
    self.headerPanel:setAnchorTop(true)
    self:addChild(self.headerPanel)

    self.listPanel = ISPanel:new(pad, self.headerPanel:getY() + self.headerPanel:getHeight() + 8, self.width - (pad * 2), self.height - th - 148)
    self.listPanel:initialise()
    self.listPanel.backgroundColor = { r = 0.01, g = 0.01, b = 0.01, a = 0.95 }
    self.listPanel.borderColor = { r = 0.3, g = 0.3, b = 0.3, a = 1 }
    self.listPanel:setAnchorLeft(true)
    self.listPanel:setAnchorRight(true)
    self.listPanel:setAnchorTop(true)
    self.listPanel:setAnchorBottom(true)
    self:addChild(self.listPanel)

    self.list = ISScrollingListBox:new(8, 8, self.listPanel.width - 16, self.listPanel.height - 16)
    self.list:initialise()
    self.list:instantiate()
    self.list.font = UIFont.Small
    self.list.itemheight = 74
    self.list.drawBorder = false
    self.list.borderColor = { r = 0, g = 0, b = 0, a = 0 }
    self.list.backgroundColor = { r = 0, g = 0, b = 0, a = 0 }
    self.list.doDrawItem = self.drawContactItem
    self.list.onmousedown = self.onListMouseDown
    self.list.onmousedblclick = self.onListDoubleClick
    self.list.target = self
    self.list:setAnchorLeft(true)
    self.list:setAnchorRight(true)
    self.list:setAnchorTop(true)
    self.list:setAnchorBottom(true)
    self.listPanel:addChild(self.list)

    self.statusPanel = DT_ContactsStatusPanel:new(pad, self.listPanel:getY() + self.listPanel:getHeight() + 8, self.width - (pad * 2), 42)
    self.statusPanel:initialise()
    self.statusPanel.owner = self
    self.statusPanel.backgroundColor = { r = 0.02, g = 0.02, b = 0.02, a = 0.9 }
    self.statusPanel.borderColor = { r = 0.24, g = 0.24, b = 0.24, a = 1 }
    self.statusPanel:setAnchorLeft(true)
    self.statusPanel:setAnchorRight(true)
    self.statusPanel:setAnchorBottom(true)
    self:addChild(self.statusPanel)

    self.footerPanel = ISPanel:new(pad, self.height - 58, self.width - (pad * 2), 40)
    self.footerPanel:initialise()
    self.footerPanel.backgroundColor = { r = 0.02, g = 0.02, b = 0.02, a = 0.9 }
    self.footerPanel.borderColor = { r = 0.25, g = 0.25, b = 0.25, a = 1 }
    self.footerPanel:setAnchorLeft(true)
    self.footerPanel:setAnchorRight(true)
    self.footerPanel:setAnchorBottom(true)
    self:addChild(self.footerPanel)

    self.openButton = ISButton:new(10, 8, 130, 24, "Open Frequency", self, self.onOpenFrequency)
    self.openButton:initialise()
    self.footerPanel:addChild(self.openButton)

    self.refreshButton = ISButton:new(150, 8, 95, 24, "Refresh", self, self.onRefresh)
    self.refreshButton:initialise()
    self.footerPanel:addChild(self.refreshButton)

    self.deleteButton = ISButton:new(255, 8, 110, 24, "Delete", self, self.onDeleteContact)
    self.deleteButton:initialise()
    self.footerPanel:addChild(self.deleteButton)

    self.cancelButton = ISButton:new(self.footerPanel.width - 100, 8, 90, 24, "Close", self, self.close)
    self.cancelButton:initialise()
    self.cancelButton:setAnchorLeft(false)
    self.cancelButton:setAnchorRight(true)
    self.footerPanel:addChild(self.cancelButton)

    self:layoutChildren()
end

function DT_ContactsWindow:layoutChildren()
    local th = self:titleBarHeight()
    local pad = 10
    local contentWidth = self.width - (pad * 2)
    local headerHeight = 60
    local statusHeight = 42
    local footerHeight = 40
    local footerY = self.height - footerHeight - 18
    local listY = th + pad + headerHeight + 8
    local statusY = footerY - statusHeight - 8
    local listHeight = math.max(140, statusY - listY - 8)

    self.headerPanel:setX(pad)
    self.headerPanel:setY(th + pad)
    self.headerPanel:setWidth(contentWidth)
    self.headerPanel:setHeight(headerHeight)

    self.listPanel:setX(pad)
    self.listPanel:setY(listY)
    self.listPanel:setWidth(contentWidth)
    self.listPanel:setHeight(listHeight)

    self.list:setX(8)
    self.list:setY(8)
    self.list:setWidth(self.listPanel.width - 16)
    self.list:setHeight(self.listPanel.height - 16)

    self.statusPanel:setX(pad)
    self.statusPanel:setY(statusY)
    self.statusPanel:setWidth(contentWidth)
    self.statusPanel:setHeight(statusHeight)

    self.footerPanel:setX(pad)
    self.footerPanel:setY(footerY)
    self.footerPanel:setWidth(contentWidth)
    self.footerPanel:setHeight(footerHeight)

    self.cancelButton:setX(self.footerPanel.width - self.cancelButton:getWidth() - 10)
end

function DT_ContactsWindow:onResize()
    ISCollapsableWindow.onResize(self)
    if self.width < self.minimumWidth then
        self:setWidth(self.minimumWidth)
    end
    if self.height < self.minimumHeight then
        self:setHeight(self.minimumHeight)
    end
    if self.closeButton then
        self.closeButton:setX(self.width - 18)
    end
    if self.footerPanel then
        self:layoutChildren()
    end
end

function DT_ContactsWindow:update()
    ISCollapsableWindow.update(self)

    self.autoRefreshTicks = (self.autoRefreshTicks or 0) + 1
    if self.autoRefreshTicks >= AUTO_REFRESH_TICKS then
        self.autoRefreshTicks = 0
        self:onRefresh()
    end
end

function DT_ContactsWindow:populateContacts(selectTraderID)
    local contactsAPI = getContactsAPI()
    local preservedTraderID = selectTraderID
    if not preservedTraderID then
        preservedTraderID = self.selectedContact and self.selectedContact.id or nil
    end
    if not preservedTraderID and self.list and self.list.items and self.list.selected and self.list.selected > 0 then
        local selectedItem = self.list.items[self.list.selected]
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
        local hydrated = contactsAPI.RefreshContactData(contact)
        local item = self.list:addItem((hydrated and hydrated.name) or "Unknown", hydrated)
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
        local selected = contactsAPI.RefreshContactData(self.selectedContact or self.contacts[1])
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
    local contactsAPI = getContactsAPI()
    local data = item and item.item or nil
    if not data then
        return y + item.height
    end

    local width = self:getWidth()
    local height = item.height
    local isSelected = self.selected == item.index

    if isSelected then
        self:drawRect(0, y, width, height, 0.4, 0.05, 0.5, 0.05)
        self:drawRectBorder(0, y, width, height, 1.0, 0.1, 0.8, 0.1)
    elseif alt then
        self:drawRect(0, y, width, height, 0.1, 1, 1, 1)
    else
        self:drawRect(0, y, width, height, 0.1, 0, 0, 0)
    end

    local tex = nil
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

    local contentX = 75
    local role = tostring(data.archetype or data.role or "Survivor")
    local factionName = contactsAPI and contactsAPI.GetFactionDisplayName and contactsAPI.GetFactionDisplayName(data) or tostring(data.factionName or data.factionID or "Independent")
    local rep = contactsAPI and contactsAPI.GetEffectiveReputation and contactsAPI.GetEffectiveReputation(data) or 0
    local statusText = contactsAPI and contactsAPI.GetStatusText and contactsAPI.GetStatusText(data) or "Status unknown"
    local canVisit = contactsAPI and contactsAPI.CanRequestVisit and contactsAPI.CanRequestVisit(data, {
        requestBackend = self.parent and self.parent.requestBackend or nil,
        radioObj = self.parent and self.parent.radioObj or nil,
    }) or false
    local isDead = tostring(data.status or "") == "Dead"

    self:drawText(tostring(data.name or "Unknown") .. " [" .. role .. "]", contentX, y + 5, 1, 1, 1, 1, UIFont.Small)

    local fR, fG, fB = 1, 1, 1
    if factionName == "Independent" then
        fR, fG, fB = 0.8, 0.8, 0.4
    end
    self:drawText("Faction: " .. factionName, contentX, y + 28, fR, fG, fB, 1, UIFont.Small)

    local sR, sG, sB = 0.75, 0.75, 0.75
    if isDead then
        sR, sG, sB = 0.88, 0.34, 0.34
    elseif canVisit then
        sR, sG, sB = 0.4, 1.0, 0.4
    end
    self:drawText(statusText, contentX, y + 47, sR, sG, sB, 1, UIFont.Small)
    self:drawTextRight("REP " .. tostring(rep), width - 14, y + 7, 0.85, 0.9, 1, 1, UIFont.Small)

    return y + item.height
end

function DT_ContactsWindow:onListMouseDown(item)
    self.selectedContact = resolveSelectedContact(self.list, item)
    if self.selectedContact then
        local contactsAPI = getContactsAPI()
        local statusText = contactsAPI and contactsAPI.GetStatusText and contactsAPI.GetStatusText(self.selectedContact) or "Status unknown"
        self.headerStatusText = statusText
        local factionName = contactsAPI and contactsAPI.GetFactionDisplayName and contactsAPI.GetFactionDisplayName(self.selectedContact) or tostring(self.selectedContact.factionName or self.selectedContact.factionID or "Independent")
        self.statusPanelText = string.format("%s | %s | %s", tostring(self.selectedContact.name or "Unknown"), tostring(factionName), tostring(statusText))
    end
    if self.deleteButton and self.deleteButton.setEnable then
        self.deleteButton:setEnable(self.selectedContact ~= nil)
    end
end

function DT_ContactsWindow:onListDoubleClick(item)
    self.selectedContact = resolveSelectedContact(self.list, item)
    if self.selectedContact then
        self:onOpenFrequency()
    end
end

function DT_ContactsWindow:onRefresh()
    self.autoRefreshTicks = 0
    self:populateContacts(self.selectedContact and self.selectedContact.id or nil)
end

function DT_ContactsWindow:onDeleteContactConfirmed(button)
    if button and button.internal ~= "YES" then
        return
    end

    local contactsAPI = getContactsAPI()
    if not contactsAPI or not self.selectedContact then
        return
    end

    local deleted = contactsAPI.DeleteContact and contactsAPI.DeleteContact(self.selectedContact) or false
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
    self.selectedContact = resolveSelectedContact(self.list, self.selectedContact)
    if not self.selectedContact then
        self.statusPanelText = "Select a contact first."
        return
    end

    DT_ContactsDeleteModal.Show(self, self.selectedContact)
end

function DT_ContactsWindow:onOpenFrequency()
    self.selectedContact = resolveSelectedContact(self.list, self.selectedContact)
    if not self.selectedContact then
        self.statusPanelText = "Select a contact first."
        return
    end

    local contactsAPI = getContactsAPI()
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

function DT_ContactsWindow:close()
    self:setVisible(false)
    self:removeFromUIManager()
    DT_ContactsWindow.instance = nil
end

return DT_ContactsWindow