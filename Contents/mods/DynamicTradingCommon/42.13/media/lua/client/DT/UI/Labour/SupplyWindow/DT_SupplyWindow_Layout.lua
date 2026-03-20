DT_SupplyWindow = DT_SupplyWindow or {}
DT_SupplyWindow.Internal = DT_SupplyWindow.Internal or {}

local Internal = DT_SupplyWindow.Internal

function DT_SupplyWindow:initialise()
    ISCollapsableWindow.initialise(self)
    self:setResizable(true)
    self.minimumWidth = 760
    self.minimumHeight = 460
end

function DT_SupplyWindow:createChildren()
    ISCollapsableWindow.createChildren(self)

    local th = self:titleBarHeight()
    local pad = 10
    local headerY = th + pad
    local listY = headerY + 36
    local footerH = 38
    local leftWidth = math.floor(self.width * 0.58)
    local contentHeight = self.height - listY - footerH - pad
    local rightX = leftWidth + (pad * 2)
    local rightWidth = self.width - rightX - pad

    self.btnRefresh = ISButton:new(10, headerY, 90, 28, "Refresh", self, self.onRefresh)
    self.btnRefresh:initialise()
    self:addChild(self.btnRefresh)

    self.btnDeposit = ISButton:new(110, headerY, 140, 28, "Deposit Selected", self, self.onDepositSelected)
    self.btnDeposit:initialise()
    self:addChild(self.btnDeposit)

    self.itemList = Internal.LabourSupplyList:new(10, listY, leftWidth, contentHeight)
    self.itemList:initialise()
    self.itemList:instantiate()
    self.itemList.target = self
    self.itemList.onmousedown = DT_SupplyWindow.onItemListMouseDown
    self.itemList:setAnchorBottom(true)
    self:addChild(self.itemList)

    self.detailText = ISRichTextPanel:new(rightX, listY, rightWidth, contentHeight)
    self.detailText:initialise()
    self.detailText.backgroundColor = { r = 0, g = 0, b = 0, a = 0.2 }
    self.detailText.borderColor = { r = 1, g = 1, b = 1, a = 0.1 }
    self.detailText:addScrollBars()
    self.detailText:setAnchorRight(true)
    self.detailText:setAnchorBottom(true)
    self:addChild(self.detailText)

    self.statusText = ISRichTextPanel:new(rightX, self.height - footerH - 4, rightWidth, 28)
    self.statusText:initialise()
    self.statusText.backgroundColor = { r = 0, g = 0, b = 0, a = 0 }
    self.statusText.borderColor = { r = 0, g = 0, b = 0, a = 0 }
    self.statusText:setAnchorRight(true)
    self.statusText:setAnchorBottom(true)
    self:addChild(self.statusText)

    self:updateStatus("Browse your inventory and deposit food or drinks into the selected worker.")
    self:updateItemDetail(nil)
end

function DT_SupplyWindow:updateStatus(text)
    if not self.statusText then
        return
    end
    self.statusText:setText(" <RGB:0.75,0.75,0.75> " .. tostring(text or "") .. " ")
    self.statusText:paginate()
end

function DT_SupplyWindow:updateItemDetail(entry)
    if not self.detailText then
        return
    end

    if not entry then
        self.detailText:setText(" <RGB:0.6,0.6,0.6> Select an inventory item to preview its labour upkeep value. Money is handled through the dedicated Give Money button. ")
        self.detailText:paginate()
        return
    end

    local text = ""
    text = text .. " <RGB:1,1,1> <SIZE:Large> " .. tostring(Internal.formatEntryLabel(entry)) .. " <LINE> <LINE> "
    text = text .. " <RGB:0.8,0.8,0.8> Full Type: <RGB:1,1,1> " .. tostring(entry.fullType or "Unknown") .. " <LINE> "
    text = text .. " <RGB:0.8,0.8,0.8> Adds Calories: <RGB:1,1,1> " .. string.format("%.0f", entry.calories or 0) .. " <LINE> "
    text = text .. " <RGB:0.8,0.8,0.8> Adds Hydration: <RGB:1,1,1> " .. string.format("%.0f", entry.hydration or 0) .. " <LINE> <LINE> "

    if entry.canDeposit then
        text = text .. " <RGB:0.7,1,0.7> This item can be deposited into worker upkeep. "
    else
        text = text .. " <RGB:1,0.6,0.6> This item is visible for future labour item transfer, but upkeep only reads food and water right now. "
    end

    self.detailText:setText(text)
    self.detailText:paginate()
end
