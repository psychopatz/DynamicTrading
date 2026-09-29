require "ISUI/ISPanel"
require "ISUI/ISButton"

DTCommon = DTCommon or {}
DTCommon.TradeWindow = DTCommon.TradeWindow or {}

local Window = ISPanel:derive("DTCommonTradeWindow")

function Window:new(traderID, snapshot)
    local object = ISPanel:new(0, 0, 440, 250)
    setmetatable(object, self)
    self.__index = self
    object.traderID = traderID
    object.snapshot = snapshot or {}
    object.statusText = ""
    return object
end

function Window:initialise()
    ISPanel.initialise(self)
    self.closeButton = ISButton:new(320, 205, 100, 25,
        DTCommon.T("DTCommon_Trade_Close", "Close"), self, Window.onClose)
    self.closeButton:initialise()
    self.closeButton:instantiate()
    self:addChild(self.closeButton)
    self.buyButton = ISButton:new(20, 150, 120, 25,
        DTCommon.T("DTCommon_Trade_BuyOne", "Buy 1"), self, Window.onBuy)
    self.buyButton:initialise()
    self.buyButton:instantiate()
    self:addChild(self.buyButton)
    self.sellButton = ISButton:new(160, 150, 120, 25,
        DTCommon.T("DTCommon_Trade_SellOne", "Sell 1"), self, Window.onSell)
    self.sellButton:initialise()
    self.sellButton:instantiate()
    self:addChild(self.sellButton)
end

function Window:item()
    local items = self.snapshot and self.snapshot.items or {}
    return items[1]
end

function Window:prerender()
    ISPanel.prerender(self)
    local item = self:item()
    local title = tostring(self.snapshot.displayName or "Trader")
    self:drawText(title, 20, 20, 1, 1, 1, 1, UIFont.Medium)
    self:drawText(DTCommon.T("DTCommon_Trade_Budget", "Budget: $%s")
        :format(tostring(self.snapshot.budget or 0)),
        20, 55, 1, 1, 1, 1, UIFont.Small)
    if item then
        self:drawText(
            tostring(item.fullType) .. " x" .. tostring(item.quantity)
                .. "  ($" .. tostring(item.unitPrice or 0) .. ")",
            20, 90, 1, 1, 1, 1, UIFont.Small
        )
        self.buyButton:setEnable((tonumber(item.quantity) or 0) > 0)
    else
        self:drawText(DTCommon.T("DTCommon_Trade_NoStock", "No stock available"),
            20, 90, 1, 0.7, 0.7, 1, UIFont.Small)
        self.buyButton:setEnable(false)
    end
    if self.statusText ~= "" then
        self:drawText(self.statusText, 20, 185, 1, 0.9, 0.8, 1, UIFont.Small)
    end
end

function Window:onBuy()
    local item = self:item()
    if item and DTCommon.Client then
        DTCommon.Client.SubmitTrade(self.traderID, DTCommon.OP_BUY, item.fullType, 1)
        self.statusText = DTCommon.T("DTCommon_Trade_Buying", "Buying...")
    end
end

function Window:onSell()
    local item = self:item()
    local fullType = item and item.fullType or "Base.Bandage"
    if DTCommon.Client then
        DTCommon.Client.SubmitTrade(self.traderID, DTCommon.OP_SELL, fullType, 1)
        self.statusText = DTCommon.T("DTCommon_Trade_Selling", "Selling...")
    end
end

function Window:onClose()
    self:setVisible(false)
    self:removeFromUIManager()
    DTCommon.TradeWindow.Active = nil
end

function Window:SetSnapshot(snapshot)
    self.snapshot = snapshot or {}
    self.statusText = ""
end

function Window:SetResult(result)
    if result and result.accepted == true then
        self.statusText = DTCommon.T("DTCommon_Trade_Complete", "Trade complete.")
    else
        self.statusText = DTCommon.T("DTCommon_Trade_Rejected", "Trade rejected.")
    end
end

function DTCommon.TradeWindow.Open(traderID, snapshot)
    if DTCommon.TradeWindow.Active then
        DTCommon.TradeWindow.Active:onClose()
    end
    local core = getCore and getCore() or nil
    local window = Window:new(traderID, snapshot)
    window:initialise()
    if core then
        window:setX(math.floor((core:getScreenWidth() - window.width) / 2))
        window:setY(math.floor((core:getScreenHeight() - window.height) / 2))
    end
    window:addToUIManager()
    window:setVisible(true)
    DTCommon.TradeWindow.Active = window
    return window
end

return DTCommon.TradeWindow
