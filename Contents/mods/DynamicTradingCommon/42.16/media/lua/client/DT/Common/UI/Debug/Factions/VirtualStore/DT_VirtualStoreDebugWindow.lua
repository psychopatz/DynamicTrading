-- ==============================================================================
-- UI/Debug/Factions/VirtualStore/DT_VirtualStoreDebugWindow.lua
-- Logic: Admin interface for abstract virtual store.
-- ==============================================================================

require "ISUI/ISPanel"
require "ISUI/ISCollapsableWindow"
require "ISUI/ISScrollingListBox"
require "DT/Common/ColonyEconomy/VirtualStore/DT_VirtualStore"
require "DT/Common/Faction/TradingSys/DynamicTrading_Factions"
require "DT/Common/Config"

DT_VirtualStoreDebugWindow = ISCollapsableWindow:derive("DT_VirtualStoreDebugWindow")
DT_VirtualStoreDebugWindow.instance = nil

function DT_VirtualStoreDebugWindow:new(x, y, width, height)
    local o = ISCollapsableWindow:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.title = "DT: Virtual Store (Abstract Market)"
    o.backgroundColor = {r=0.08, g=0.08, b=0.08, a=0.9}
    o.borderColor = {r=0.3, g=0.3, b=0.3, a=1}
    o:setResizable(true)
    return o
end

function DT_VirtualStoreDebugWindow:createChildren()
    ISCollapsableWindow.createChildren(self)

    local pad = 10
    local th = self:titleBarHeight()

    self.contentPanel = ISPanel:new(pad, th + pad, self.width - pad*2, self.height - th - pad*2)
    self.contentPanel:initialise()
    self.contentPanel.backgroundColor = {r=0, g=0, b=0, a=0}
    self.contentPanel.borderColor = {r=0, g=0, b=0, a=0}
    self.contentPanel:setAnchorRight(true)
    self.contentPanel:setAnchorBottom(true)
    self:addChild(self.contentPanel)

    self.btnForceRecalc = ISButton:new(0, 0, 150, 25, "Force Recalculate", self, self.onForceRecalc)
    self.btnForceRecalc:initialise()
    self.contentPanel:addChild(self.btnForceRecalc)

    self.listPrices = ISScrollingListBox:new(0, 35, self.contentPanel.width, self.contentPanel.height - 40)
    self.listPrices:initialise()
    self.listPrices:instantiate()
    self.listPrices.doDrawItem = self.doDrawItem
    self.listPrices.drawBorder = true
    self.listPrices:setAnchorBottom(true)
    self.listPrices:setAnchorRight(true)
    self.contentPanel:addChild(self.listPrices)
    
    self:refreshList()
end

function DT_VirtualStoreDebugWindow:onForceRecalc()
    DT_DebugNetworkAdapter.sendDebugAction("ForceRecalcVirtualStore", {})
end

function DT_VirtualStoreDebugWindow:refreshList()
    self.listPrices:clear()
    local data = ModData.get("DT_VirtualStore")
    if not data then return end
    
    local keys = {"food", "meds", "ammo", "water", "fuel", "parts"}
    for _, k in ipairs(keys) do
        local price = data.prices and data.prices[k] or 10
        self.listPrices:addItem(k, { price = price })
    end
end

function DT_VirtualStoreDebugWindow:update()
    ISCollapsableWindow.update(self)
    -- Just basic update
end

function DT_VirtualStoreDebugWindow:doDrawItem(y, item, alt)
    self:drawRect(0, y, self:getWidth(), item.height, alt and 0.1 or 0.05, 1, 1, 1)
    self:drawRectBorder(0, y, self:getWidth(), item.height, 0.2, 0.5, 0.5, 0.5)

    local resName = tostring(item.text):upper()
    local price = item.item.price
    self:drawText(resName, 15, y + 2, 1, 1, 1, 1, UIFont.Medium)
    self:drawText("$ " .. tostring(price), self:getWidth() - 100, y + 2, 0.2, 1, 0.2, 1, UIFont.Medium)
    
    return y + item.height
end

function DT_VirtualStoreDebugWindow:close()
    ISCollapsableWindow.close(self)
    self:removeFromUIManager()
    DT_VirtualStoreDebugWindow.instance = nil
end

function DT_VirtualStoreDebugWindow.Open()
    if DT_VirtualStoreDebugWindow.instance then
        DT_VirtualStoreDebugWindow.instance:setVisible(true)
        DT_VirtualStoreDebugWindow.instance:bringToTop()
        DT_VirtualStoreDebugWindow.instance:refreshList()
        return
    end

    local sw = getCore():getScreenWidth()
    local sh = getCore():getScreenHeight()
    local w, h = 400, 300
    local inst = DT_VirtualStoreDebugWindow:new((sw - w)/2, (sh - h)/2, w, h)
    inst:initialise()
    inst:addToUIManager()
    DT_VirtualStoreDebugWindow.instance = inst
end

Events.OnReceiveGlobalModData.Add(function(key, data)
    if key == "DT_VirtualStore" and DT_VirtualStoreDebugWindow.instance then
        DT_VirtualStoreDebugWindow.instance:refreshList()
    end
end)
