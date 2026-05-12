local Internal = DT_ContactsWindowInternal
local DT_ContactsHeaderPanel = Internal.HeaderPanelClass
local DT_ContactsStatusPanel = Internal.StatusPanelClass
local DT_ContactsDeleteModal = Internal.DeleteModalClass

function DT_ContactsWindow.Open(options)
    local ui

    options = options or {}

    if DT_ContactsWindow.instance then
        DT_ContactsWindow.instance:close()
    end

    ui = DT_ContactsWindow:new(180, 120, 720, 560)
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
    local th
    local pad = 10

    ISCollapsableWindow.createChildren(self)

    th = self:titleBarHeight()

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
    if self.autoRefreshTicks >= Internal.AUTO_REFRESH_TICKS then
        self.autoRefreshTicks = 0
        self:onRefresh()
    end
end

function DT_ContactsWindow:close()
    self:setVisible(false)
    self:removeFromUIManager()
    DT_ContactsWindow.instance = nil
end
