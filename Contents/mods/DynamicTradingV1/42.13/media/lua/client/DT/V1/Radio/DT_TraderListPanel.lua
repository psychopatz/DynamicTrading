require "ISUI/ISPanel"
require "ISUI/ISScrollingListBox"
require "ISUI/ISLabel"
require "DT/V1/Manager"

DT_TraderListPanel = ISPanel:derive("DT_TraderListPanel")

function DT_TraderListPanel:initialise()
    ISPanel.initialise(self)
    self.lastDiscoveredCount = -1
    self.lastTradersVersion = -1
end

function DT_TraderListPanel:createChildren()
    ISPanel.createChildren(self)
    
    self.lblTraders = ISLabel:new(10, 0, 16, "Active Signals:", 0.8, 0.8, 1, 1, UIFont.Small, true)
    self:addChild(self.lblTraders)

    self.listbox = ISScrollingListBox:new(10, 20, self.width - 20, self.height - 25)
    self.listbox:initialise()
    self.listbox:setAnchorRight(true)
    self.listbox.font = UIFont.Small
    self.listbox.itemheight = 38
    self.listbox.drawBorder = true
    self.listbox.borderColor = {r=0.4, g=0.4, b=0.4, a=1}
    self.listbox.backgroundColor = {r=0.0, g=0.0, b=0.0, a=0.9}
    self.listbox.doDrawItem = self.drawItem
    self.listbox.onMouseDown = self.onListMouseDown
    self.listbox.parentPanel = self 
    self:addChild(self.listbox)
end

-- [UPDATED] Scale List Item Height & Font
function DT_TraderListPanel:onResize()
    ISPanel.onResize(self)
    local w = self:getWidth()
    
    -- Dynamic Item Height based on width
    -- Base: 38px at ~380w. Scale up from there.
    local newHeight = math.floor(w * 0.12)
    
    -- Clamps
    if newHeight < 38 then newHeight = 38 end
    if newHeight > 80 then newHeight = 80 end
    
    if self.listbox then
        self.listbox:setWidth(w - 20)
        self.listbox:setHeight(self:getHeight() - 25)
        self.listbox.itemheight = newHeight
        
        -- Scale Font
        if newHeight >= 65 then self.listbox.font = UIFont.Large
        elseif newHeight >= 50 then self.listbox.font = UIFont.Medium
        else self.listbox.font = UIFont.Small end
        
        if self.listbox.vscroll then
             self.listbox.vscroll:setHeight(self.listbox:getHeight())
        end
    end
end

function DT_TraderListPanel:prerender()
    ISPanel.prerender(self)
    
    local player = getSpecificPlayer(0)
    local data = DynamicTrading.Manager.GetData()
    local currentVersion = (data.DailyCycle and data.DailyCycle.tradersVersion) or 0
    local currentDiscovered = DynamicTrading.Manager.GetDiscoveredCount(player)

    if currentVersion ~= self.lastTradersVersion or currentDiscovered ~= self.lastDiscoveredCount then
        if currentDiscovered > self.lastDiscoveredCount and self.lastDiscoveredCount >= 0 then
            if self.parent and self.parent.signalPanel then
                self.parent.signalPanel.signalFoundPersist = true
            end
        end
        self:populateList()
        self.lastDiscoveredCount = currentDiscovered
        self.lastTradersVersion = currentVersion
    end
end

function DT_TraderListPanel:populateList()
    self.listbox:clear()
    local player = getSpecificPlayer(0)
    
    local traders = DynamicTrading.Manager.GetActiveRadioTraders(player)
    
    local sortedList = {}
    for _, trader in ipairs(traders) do
        table.insert(sortedList, trader)
    end
    table.sort(sortedList, function(a, b) return a.id > b.id end)

    for _, trader in ipairs(sortedList) do
        local archetypeData = DynamicTrading.Archetypes[trader.archetype]
        local occupation = archetypeData and archetypeData.name or trader.archetype
        local txt = (trader.name or "Unknown") .. " - " .. occupation
        self.listbox:addItem(txt, { traderID = trader.id, archetype = trader.archetype })
    end
    
    if #sortedList == 0 then
        self.listbox:addItem("No signals. Try scanning.", {})
    end
end

function DT_TraderListPanel.drawItem(this, y, item, alt)
    local height = this.itemheight
    local width = this:getWidth()
    
    if this.selected == item.index then
        this:drawRect(0, y, width, height, 0.3, 0.7, 0.35, 0.2)
    elseif alt then
        this:drawRect(0, y, width, height, 0.05, 0.05, 0.05, 0.5) 
    end
    this:drawRectBorder(0, y, width, height, 0.1, 1, 1, 1)

    -- [UPDATED] Vertical Alignment Logic
    local fontH = getTextManager():getFontHeight(this.font)
    local textY = y + (height - fontH) / 2

    if not item.item.traderID then
        this:drawText(item.text, 10, textY, 0.7, 0.7, 0.7, 1, this.font)
        return y + height
    end

    -- Icon Logic
    local trader = DynamicTrading.Manager.GetTrader(item.item.traderID)
    local tex = nil
    
    if trader and DynamicTrading.Portraits then
        local archetype = trader.archetype or "General"
        local gender = trader.gender or "Male"
        local seed = trader.portraitID or 1
        
        local mappedID = 1
        if DynamicTrading.Portraits.GetMappedID then
            mappedID = DynamicTrading.Portraits.GetMappedID(archetype, gender, seed)
        end

        if DynamicTrading.Portraits.GetPathFolder then
            local pathFolder = DynamicTrading.Portraits.GetPathFolder(archetype, gender)
            tex = getTexture(pathFolder .. tostring(mappedID) .. ".png")
        end
    end
    
    if not tex then tex = getTexture("Item_WalkieTalkie1") end
    
    -- [STRICT 1:1 SCALING]
    -- Icon size scales with row height, minus padding (e.g. 5px top/bottom)
    local iconSize = height - 10
    local iconX = 5
    local iconY = y + 5
    
    if tex then 
        this:drawTextureScaled(tex, iconX, iconY, iconSize, iconSize, 1, 1, 1, 1) 
    end
    
    -- Text positioned after icon
    local textX = iconX + iconSize + 10
    this:drawText(item.text, textX, textY, 1, 1, 1, 1, this.font)
    
    return y + height
end

function DT_TraderListPanel.onListMouseDown(target, x, y)
    local row = target:rowAt(x, y)
    if row == -1 then return end
    target.selected = row
    
    local item = target.items[row]
    local mainWindow = target.parentPanel.parent
    
    if item.item and item.item.traderID and mainWindow and DT_TradingWindow then
        if mainWindow.radioObj then
             DT_TradingWindow.ToggleWindow(item.item.traderID, item.item.archetype, mainWindow.radioObj, mainWindow.dataProvider)
        end
    end
end

function DT_TraderListPanel:new(x, y, width, height)
    local o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.backgroundColor = {r=0, g=0, b=0, a=0}
    return o
end
