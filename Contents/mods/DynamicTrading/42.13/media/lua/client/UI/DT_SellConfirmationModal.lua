require "ISUI/ISCollapsableWindow"
require "ISUI/ISButton"
require "ISUI/ISLabel"
require "ISUI/ISScrollingListBox"
require "ISUI/ISImage"

DT_SellConfirmationModal = ISCollapsableWindow:derive("DT_SellConfirmationModal")

function DT_SellConfirmationModal:initialise()
    ISCollapsableWindow.initialise(self)
    self:setResizable(false)
end

function DT_SellConfirmationModal:createChildren()
    ISCollapsableWindow.createChildren(self)

    -- 1. TITLE / WARNING
    local text = "This container has items inside:"
    self.lblWarning = ISLabel:new(self.width / 2, 25, 20, text, 1, 0.5, 0.5, 1, UIFont.Medium, true)
    self.lblWarning.center = true
    self:addChild(self.lblWarning)

    -- 2. CONTENT LIST
    local listY = 55
    local listH = self.height - 110
    
    self.listbox = ISScrollingListBox:new(10, listY, self.width - 20, listH)
    self.listbox:initialise()
    self.listbox:setAnchorBottom(true)
    self.listbox.font = UIFont.NewSmall
    self.listbox.itemheight = 24
    self.listbox.drawBorder = true
    self.listbox.borderColor = {r=0.4, g=0.4, b=0.4, a=1}
    self.listbox.backgroundColor = {r=0.1, g=0.1, b=0.1, a=0.8}
    self.listbox.doDrawItem = self.drawItem
    self:addChild(self.listbox)
    
    -- 3. BUTTONS
    local btnW = 100
    local btnH = 25
    local btnY = self.height - 35
    
    -- CONFIRM
    self.btnConfirm = ISButton:new(self.width - btnW - 10, btnY, btnW, btnH, "CONFIRM SELL", self, self.onConfirm)
    self.btnConfirm:initialise()
    self.btnConfirm.backgroundColor = {r=0.6, g=0.2, b=0.2, a=1.0}
    self.btnConfirm.borderColor = {r=1, g=1, b=1, a=0.4}
    self:addChild(self.btnConfirm)
    
    -- UNPACK [MP-SAFE]
    self.btnUnpack = ISButton:new(self.width / 2 - btnW / 2, btnY, btnW, btnH, "UNPACK", self, self.onUnpack)
    self.btnUnpack:initialise()
    self.btnUnpack.backgroundColor = {r=0.2, g=0.4, b=0.6, a=1.0}
    self.btnUnpack.borderColor = {r=1, g=1, b=1, a=0.4}
    self.btnUnpack:setTooltip("Dumps items to the floor safely (Server Synced)")
    self:addChild(self.btnUnpack)
    
    -- CANCEL
    self.btnCancel = ISButton:new(10, btnY, btnW, btnH, "CANCEL", self, self.close)
    self.btnCancel:initialise()
    self.btnCancel.backgroundColor = {r=0.3, g=0.3, b=0.3, a=1.0}
    self.btnCancel.borderColor = {r=1, g=1, b=1, a=0.4}
    self:addChild(self.btnCancel)
    
    self:populateList()
end

function DT_SellConfirmationModal:populateList()
    self.listbox:clear()
    
    if not self.item then return end
    local inv = self.item:getItemContainer()
    if not inv then return end
    
    local items = inv:getItems()
    for i=0, items:size()-1 do
        local item = items:get(i)
        self.listbox:addItem(item:getDisplayName(), item)
    end
end

function DT_SellConfirmationModal.drawItem(list, y, item, alt)
    local height = list.itemheight
    local width = list:getWidth()
    local it = item.item
    
    if alt then
        list:drawRect(0, y, width, height, 0.1, 0.2, 0.2, 0.2)
    end
    
    -- Icon
    if it then
        local tex = DynamicTradingUI.GetItemTexture(it:getFullType(), it)
        if tex then
            list:drawTextureScaled(tex, 4, y + 2, 20, 20, 1, 1, 1, 1)
        end
    end

    list:drawText(item.text, 30, y + 2, 0.9, 0.9, 0.9, 1, list.font)
    
    return y + height
end

function DT_SellConfirmationModal:onConfirm()
    if self.callbackTarget and self.callbackFunc then
        -- Execute the sale logic
        self.callbackFunc(self.callbackTarget, self.item, self.data)
    end
    self:close()
end

function DT_SellConfirmationModal:onUnpack()
    if self.callbackTarget and self.callbackUnpackFunc then
        -- Execute the unpack logic
        self.callbackUnpackFunc(self.callbackTarget, self.item)
    end
    self:close()
end

function DT_SellConfirmationModal:close()
    self:setVisible(false)
    self:removeFromUIManager()
end

-- STATIC SHOW HELPER
function DT_SellConfirmationModal.Show(item, target, func, data, unpackFunc)
    local modal = DT_SellConfirmationModal:new(0, 0, 360, 300) -- Wider for 3 buttons
    modal:initialise()
    modal.item = item
    modal.callbackTarget = target
    modal.callbackFunc = func
    modal.callbackUnpackFunc = unpackFunc
    modal.data = data
    modal:addToUIManager()
    modal:setX((getCore():getScreenWidth() / 2) - 180)
    modal:setY((getCore():getScreenHeight() / 2) - 150)
end
