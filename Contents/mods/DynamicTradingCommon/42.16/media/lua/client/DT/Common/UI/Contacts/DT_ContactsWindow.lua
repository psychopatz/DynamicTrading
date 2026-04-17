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
require "DT/Common/Contacts/DT_TraderContacts"
require "DT/Common/UI/Contacts/DT_ContactsConversation"
require "DT/Common/UI/Portrait/Portrait"

DT_ContactsWindow = DT_ContactsWindow or ISCollapsableWindow:derive("DT_ContactsWindow")
DT_ContactsWindow.instance = nil

local DT_ContactsHeaderPanel = ISPanel:derive("DT_ContactsHeaderPanel")

function DT_ContactsHeaderPanel:render()
    ISPanel.render(self)

    local owner = self.owner
    if not owner then
        return
    end

    local titleText = owner.headerTitleText or "Known traders you can reach over the radio."
    local statusText = owner.headerStatusText or "Select a contact to open their frequency."
    local countText = string.format("%d SAVED", #(owner.contacts or {}))

    self:drawText(titleText, 12, 8, 1, 1, 1, 1, UIFont.Small)
    self:drawText(statusText, 12, 25, 0.78, 0.84, 0.9, 1, UIFont.Small)
    self:drawTextRight(countText, self.width - 12, 8, 0.75, 0.85, 1, 1, UIFont.Small)
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

function DT_ContactsWindow.Open(options)
    options = options or {}

    if DT_ContactsWindow.instance then
        DT_ContactsWindow.instance:close()
    end

    local ui = DT_ContactsWindow:new(180, 120, 720, 560)
    ui:initialise()
    ui:addToUIManager()
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

    self.headerPanel = DT_ContactsHeaderPanel:new(pad, th + pad, self.width - (pad * 2), 54)
    self.headerPanel:initialise()
    self.headerPanel.owner = self
    self.headerPanel.backgroundColor = { r = 0.03, g = 0.03, b = 0.03, a = 0.92 }
    self.headerPanel.borderColor = { r = 0.28, g = 0.28, b = 0.28, a = 1 }
    self.headerPanel:setAnchorLeft(true)
    self.headerPanel:setAnchorRight(true)
    self.headerPanel:setAnchorTop(true)
    self:addChild(self.headerPanel)

    self.listPanel = ISPanel:new(pad, self.headerPanel:getY() + self.headerPanel:getHeight() + 8, self.width - (pad * 2), self.height - th - 136)
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

    self.emptyLabel = ISLabel:new(20, self.listPanel:getY() + 14, 18, "", 0.85, 0.85, 0.85, 1, UIFont.Small, false)
    self.emptyLabel:initialise()
    self:addChild(self.emptyLabel)

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
    local headerHeight = 54
    local footerHeight = 40
    local footerY = self.height - footerHeight - 18
    local listY = th + pad + headerHeight + 8
    local listHeight = math.max(140, footerY - listY - 8)

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

    self.emptyLabel:setX(pad + 10)
    self.emptyLabel:setY(listY + listHeight + 8)

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

function DT_ContactsWindow:populateContacts(selectTraderID)
    local contactsAPI = getContactsAPI()
    if not contactsAPI then
        self.contacts = {}
        self.selectedContact = nil
        if self.list then
            self.list:clear()
        end
        if self.emptyLabel then
            self.emptyLabel:setName("Contacts module failed to load.")
        end
        self.headerStatusText = "Unable to open contacts right now. Try again after the UI reloads."
        return
    end

    contactsAPI.EnsureLoaded()
    self.contacts = contactsAPI.GetAllContacts()
    self.selectedContact = nil
    self.list:clear()

    if DT_V2_RadarManager and DT_V2_RadarManager.RequestRoster then
        DT_V2_RadarManager.RequestRoster()
    end

    for _, contact in ipairs(self.contacts) do
        local hydrated = contactsAPI.RefreshContactData(contact)
        local item = self.list:addItem((hydrated and hydrated.name) or "Unknown", hydrated)
        item.height = self.list.itemheight
        if selectTraderID and hydrated and tostring(hydrated.id) == tostring(selectTraderID) then
            self.selectedContact = hydrated
            self.list.selected = #self.list.items
        end
    end

    if not self.selectedContact and #self.contacts > 0 then
        self.selectedContact = self.contacts[1]
        self.list.selected = 1
    end

    if #self.contacts == 0 then
        self.emptyLabel:setName("No contacts unlocked yet. Ask a trader for their number through Chat.")
        self.headerStatusText = "No saved contacts for this character yet."
    else
        self.emptyLabel:setName(string.format("%d contact(s) available.", #self.contacts))
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
    local factionName = tostring(data.factionID or "Independent")
    local rep = contactsAPI and contactsAPI.GetEffectiveReputation and contactsAPI.GetEffectiveReputation(data) or 0
    local statusText = contactsAPI and contactsAPI.GetStatusText and contactsAPI.GetStatusText(data) or "Status unknown"
    local canVisit = contactsAPI and contactsAPI.CanRequestVisit and contactsAPI.CanRequestVisit(data) or false

    self:drawText(tostring(data.name or "Unknown") .. " [" .. role .. "]", contentX, y + 5, 1, 1, 1, 1, UIFont.Small)

    local fR, fG, fB = 1, 1, 1
    if factionName == "Independent" then
        fR, fG, fB = 0.8, 0.8, 0.4
    end
    self:drawText("Faction: " .. factionName, contentX, y + 28, fR, fG, fB, 1, UIFont.Small)

    local sR, sG, sB = 0.75, 0.75, 0.75
    if canVisit then
        sR, sG, sB = 0.4, 1.0, 0.4
    end
    self:drawText(statusText, contentX, y + 47, sR, sG, sB, 1, UIFont.Small)
    self:drawTextRight("REP " .. tostring(rep), width - 14, y + 7, 0.85, 0.9, 1, 1, UIFont.Small)

    return y + item.height
end

function DT_ContactsWindow:onListMouseDown(item)
    self.selectedContact = item and item.item or nil
    if self.selectedContact then
        local contactsAPI = getContactsAPI()
        local statusText = contactsAPI and contactsAPI.GetStatusText and contactsAPI.GetStatusText(self.selectedContact) or "Status unknown"
        self.headerStatusText = statusText
    end
end

function DT_ContactsWindow:onListDoubleClick(item)
    self.selectedContact = item and item.item or nil
    if self.selectedContact then
        self:onOpenFrequency()
    end
end

function DT_ContactsWindow:onRefresh()
    self:populateContacts(self.selectedContact and self.selectedContact.id or nil)
end

function DT_ContactsWindow:onOpenFrequency()
    if not self.selectedContact then
        self.emptyLabel:setName("Select a contact first.")
        return
    end

    DT_ContactsConversation.Open(self.selectedContact, {
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