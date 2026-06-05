require "ISUI/ISCollapsableWindow"
require "ISUI/ISButton"
require "ISUI/ISLabel"
require "ISUI/ISTextEntryBox"
require "ISUI/ISSliderPanel"

DT_Trading_QuantityModal = ISCollapsableWindow:derive("DT_Trading_QuantityModal")
DT_Trading_QuantityModal.instance = nil

local function T(key, params, fallback)
    if DynamicTrading and DynamicTrading.Text and DynamicTrading.Text.Get then
        return DynamicTrading.Text.Get(key, params, fallback)
    end
    return fallback or tostring(key or "")
end

function DT_Trading_QuantityModal:initialise()
    ISCollapsableWindow.initialise(self)
    self:setResizable(false)
end

function DT_Trading_QuantityModal:createChildren()
    ISCollapsableWindow.createChildren(self)

    local pad = 10
    local th = self:titleBarHeight()
    local contentY = th + pad
    self.currentQty = self.currentQty or 1
    self.lastQtyText = tostring(self.currentQty)
    self.ignoreSliderChange = false
    self.actionLabel = tostring(self.actionLabel or T("DTCommon_UI_Trading_SellAction", nil, "SELL"))
    self.rangeLabelPrefix = tostring(self.rangeLabelPrefix or T("DTCommon_UI_Trading_Available", nil, "Available"))

    self.promptLabel = ISLabel:new(pad, contentY, 20, tostring(self.promptText or T("DTCommon_UI_Trading_TradeIdenticalPrompt", nil, "Trade identical items in one transaction.")), 1, 1, 1, 1, UIFont.Small, true)
    self.promptLabel:initialise()
    self.promptLabel:instantiate()
    self:addChild(self.promptLabel)

    local itemText = T("DTCommon_UI_Trading_ItemEach", {
        name = tostring(self.itemName or T("DTCommon_UI_Trading_Item", nil, "Item")),
        price = tostring(self.unitPrice or 0),
    }, tostring(self.itemName or "Item") .. " | $" .. tostring(self.unitPrice or 0) .. " each")
    self.itemLabel = ISLabel:new(pad, contentY + 22, 20, itemText, 0.85, 0.85, 0.85, 1, UIFont.Small, true)
    self.itemLabel:initialise()
    self.itemLabel:instantiate()
    self:addChild(self.itemLabel)

    self.rangeLabel = ISLabel:new(pad, contentY + 44, 20, "", 0.65, 0.85, 0.65, 1, UIFont.Small, true)
    self.rangeLabel:initialise()
    self.rangeLabel:instantiate()
    self:addChild(self.rangeLabel)

    local sliderY = contentY + 68
    self.sliderLabel = ISLabel:new(pad, sliderY + 2, 20, T("DTCommon_UI_Trading_Qty", nil, "Qty"), 0.8, 0.8, 0.8, 1, UIFont.Small, true)
    self.sliderLabel:initialise()
    self.sliderLabel:instantiate()
    self:addChild(self.sliderLabel)

    self.qtySlider = ISSliderPanel:new(pad + 34, sliderY, self.width - 118, 20, self, function(_, value)
        if self.ignoreSliderChange then
            return
        end
        self:setQuantity(value or (self.qtySlider and self.qtySlider.currentValue) or self.currentQty)
    end)
    self.qtySlider:initialise()
    self:addChild(self.qtySlider)

    self.sliderValueLabel = ISLabel:new(self.width - 74, sliderY + 2, 20, "x1", 1, 1, 1, 1, UIFont.Small, true)
    self.sliderValueLabel:initialise()
    self.sliderValueLabel:instantiate()
    self:addChild(self.sliderValueLabel)

    local qtyY = sliderY + 34
    self.btnMinus = ISButton:new(pad, qtyY, 36, 24, "-", self, self.onDecrease)
    self.btnMinus:initialise()
    self.btnMinus:instantiate()
    self:addChild(self.btnMinus)

    self.qtyEntry = ISTextEntryBox:new("1", pad + 46, qtyY, 70, 24)
    self.qtyEntry:initialise()
    self.qtyEntry:instantiate()
    self.qtyEntry:setOnlyNumbers(true)
    self:addChild(self.qtyEntry)

    self.btnPlus = ISButton:new(pad + 126, qtyY, 36, 24, "+", self, self.onIncrease)
    self.btnPlus:initialise()
    self.btnPlus:instantiate()
    self:addChild(self.btnPlus)

    self.btnMax = ISButton:new(pad + 172, qtyY, 60, 24, T("DTCommon_UI_Trading_Max", nil, "MAX"), self, self.onMax)
    self.btnMax:initialise()
    self.btnMax:instantiate()
    self:addChild(self.btnMax)

    self.totalLabel = ISLabel:new(pad, qtyY + 34, 20, "", 1.0, 0.85, 0.2, 1, UIFont.Medium, true)
    self.totalLabel:initialise()
    self.totalLabel:instantiate()
    self:addChild(self.totalLabel)

    self.btnCancel = ISButton:new(pad, self.height - 38, 100, 24, T("DTCommon_UI_Trading_Cancel", nil, "CANCEL"), self, self.onCancel)
    self.btnCancel:initialise()
    self.btnCancel:instantiate()
    self:addChild(self.btnCancel)

    self.btnConfirm = ISButton:new(self.width - 110, self.height - 38, 100, 24, T("DTCommon_UI_Trading_SellAction", nil, "SELL"), self, self.onConfirm)
    self.btnConfirm:initialise()
    self.btnConfirm:instantiate()
    self:addChild(self.btnConfirm)

    self:refreshSlider()
    self:updateLabels()
end

function DT_Trading_QuantityModal:clampQuantity(qty)
    qty = tonumber(qty) or 1
    qty = math.floor(qty)
    if qty < 1 then qty = 1 end

    local maxQty = tonumber(self.maxQty) or 1
    if qty > maxQty then qty = maxQty end

    return qty
end

function DT_Trading_QuantityModal:getRequestedQuantity()
    if self.qtyEntry then
        return self:clampQuantity(self.qtyEntry:getText())
    end

    return self:clampQuantity(self.currentQty)
end

function DT_Trading_QuantityModal:setQuantity(qty)
    self.currentQty = self:clampQuantity(qty)
    if self.qtyEntry then
        self.qtyEntry:setText(tostring(self.currentQty))
    end
    self.lastQtyText = tostring(self.currentQty)
    self:updateLabels()
end

function DT_Trading_QuantityModal:refreshSlider()
    if not self.qtySlider then
        return
    end

    local maxQty = math.max(1, tonumber(self.maxQty) or 1)
    self.ignoreSliderChange = true
    if self.sliderMaxQty ~= maxQty then
        self.qtySlider:setValues(1, maxQty, 1, 1)
        self.sliderMaxQty = maxQty
    end
    self.qtySlider.currentValue = self.currentQty or 1
    self.ignoreSliderChange = false
end

function DT_Trading_QuantityModal:updateLabels()
    local currentQty = self.currentQty or 1
    local availableQty = tonumber(self.availableQty) or currentQty
    local maxQty = tonumber(self.maxQty) or currentQty
    local unitPrice = tonumber(self.unitPrice) or 0
    local total = unitPrice * currentQty

    if self.previewTarget and self.previewCallback then
        local preview = self.previewCallback(self.previewTarget, self.data, currentQty)
        if preview then
            if preview.totalPrice ~= nil then
                total = preview.totalPrice
            end
        end
    end

    if self.rangeLabel then
        local rangeText = T(
            "DTCommon_UI_Trading_RangeLabel",
            { label = self.rangeLabelPrefix, available = availableQty, max = maxQty },
            self.rangeLabelPrefix .. ": " .. tostring(availableQty) .. " | Max this trade: " .. tostring(maxQty)
        )
        self.rangeLabel:setName(rangeText)
    end

    if self.totalLabel then
        self.totalLabel:setName(T("DTCommon_UI_Trading_Total", { total = total }, "Total: $" .. tostring(total)))
    end

    if self.sliderValueLabel then
        self.sliderValueLabel:setName("x" .. tostring(currentQty))
    end

    if self.btnConfirm then
        self.btnConfirm:setTitle(self.actionLabel .. " x" .. tostring(currentQty))
        self.btnConfirm:setEnable(maxQty > 0)
    end

    self:refreshSlider()
end

function DT_Trading_QuantityModal:update()
    ISCollapsableWindow.update(self)

    if self.qtySlider then
        local sliderQty = self:clampQuantity(self.qtySlider.currentValue)
        if sliderQty ~= (self.currentQty or 1) then
            self.currentQty = sliderQty
            self.lastQtyText = tostring(self.currentQty)
            if self.qtyEntry then
                self.qtyEntry:setText(self.lastQtyText)
            end
            self:updateLabels()
            return
        end
    end

    if self.qtyEntry then
        local text = tostring(self.qtyEntry:getText() or "")
        if text ~= self.lastQtyText then
            self.currentQty = self:clampQuantity(text)
            self.lastQtyText = tostring(self.currentQty)
            self.qtyEntry:setText(self.lastQtyText)
            self:updateLabels()
        end
    end
end

function DT_Trading_QuantityModal:onDecrease()
    self:setQuantity((self.currentQty or 1) - 1)
end

function DT_Trading_QuantityModal:onIncrease()
    self:setQuantity((self.currentQty or 1) + 1)
end

function DT_Trading_QuantityModal:onMax()
    self:setQuantity(self.maxQty or 1)
end

function DT_Trading_QuantityModal:onConfirm()
    if self.callbackTarget and self.callbackFunc then
        self.callbackFunc(self.callbackTarget, self.data, self:getRequestedQuantity())
    end
    self:close()
end

function DT_Trading_QuantityModal:onCancel()
    self:close()
end

function DT_Trading_QuantityModal:close()
    self:setVisible(false)
    self:removeFromUIManager()
    if DT_Trading_QuantityModal.instance == self then
        DT_Trading_QuantityModal.instance = nil
    end
end

function DT_Trading_QuantityModal.Show(args)
    args = args or {}

    if DT_Trading_QuantityModal.instance then
        DT_Trading_QuantityModal.instance:close()
    end

    local width = 400
    local height = 220
    local x = (getCore():getScreenWidth() - width) / 2
    local y = (getCore():getScreenHeight() - height) / 2

    local modal = DT_Trading_QuantityModal:new(x, y, width, height)
    modal.title = tostring(args.title or T("DTCommon_UI_Trading_SellMultiple", nil, "Sell Multiple"))
    modal.promptText = tostring(args.promptText or T("DTCommon_UI_Trading_TradeIdenticalPrompt", nil, "Trade identical items in one transaction."))
    modal.itemName = tostring(args.itemName or T("DTCommon_UI_Trading_Item", nil, "Item"))
    modal.unitPrice = tonumber(args.unitPrice) or 0
    modal.availableQty = tonumber(args.availableQty) or 1
    modal.maxQty = math.max(1, tonumber(args.maxQty) or modal.availableQty)
    modal.actionLabel = tostring(args.actionLabel or T("DTCommon_UI_Trading_SellAction", nil, "SELL"))
    modal.rangeLabelPrefix = tostring(args.rangeLabelPrefix or T("DTCommon_UI_Trading_Available", nil, "Available"))
    modal.callbackTarget = args.target
    modal.callbackFunc = args.callback
    modal.previewTarget = args.previewTarget or args.target
    modal.previewCallback = args.previewCallback
    modal.data = args.data
    modal:initialise()
    modal:addToUIManager()
    modal:setQuantity(args.defaultQty or 1)

    if modal.qtyEntry and modal.qtyEntry.focus then
        modal.qtyEntry:focus()
    end

    DT_Trading_QuantityModal.instance = modal
    return modal
end
