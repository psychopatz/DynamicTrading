require "ISUI/ISPanel"
require "ISUI/ISScrollingListBox"
require "ISUI/ISLabel"
require "DynamicTrading_Manager"

DT_TraderListPanel = ISPanel:derive("DT_TraderListPanel")

function DT_TraderListPanel:initialise()
    ISPanel.initialise(self)
    self.lastDiscoveredCount = -1
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
    self.listbox.parentPanel = self -- reference back
    self:addChild(self.listbox)
end

function DT_TraderListPanel:prerender()
    ISPanel.prerender(self)
    
    -- Auto Refresh Logic
    local player = getSpecificPlayer(0)
    local currentDiscovered = DynamicTrading.Manager.GetDiscoveredCount(player)

    if currentDiscovered ~= self.lastDiscoveredCount then
        -- Notify parent to persist found state animation if relevant
        if currentDiscovered > self.lastDiscoveredCount and self.lastDiscoveredCount >= 0 then
            if self.parent and self.parent.signalPanel then
                self.parent.signalPanel.signalFoundPersist = true
            end
        end
        self:populateList()
        self.lastDiscoveredCount = currentDiscovered
    end
end

function DT_TraderListPanel:populateList()
    self.listbox:clear()
    local data = DynamicTrading.Manager.GetData()
    local player = getSpecificPlayer(0)
    
    if not data.Traders then 
        self.listbox:addItem("No signals. Try scanning.", {})
        return 
    end

    local sortedList = {}
    for id, trader in pairs(data.Traders) do
        if DynamicTrading.Manager.HasDiscovered(id, player) then
            table.insert(sortedList, { id = id, data = trader })
        end
    end
    table.sort(sortedList, function(a, b) return a.id > b.id end)

    for _, entry in ipairs(sortedList) do
        local trader = entry.data
        local occupation = DynamicTrading.Archetypes[trader.archetype] and DynamicTrading.Archetypes[trader.archetype].name or trader.archetype
        local txt = (trader.name or "Unknown") .. " - " .. occupation
        self.listbox:addItem(txt, { traderID = entry.id, archetype = trader.archetype })
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

    if not item.item.traderID then
        this:drawText(item.text, 10, y + 12, 0.7, 0.7, 0.7, 1, this.font)
        return y + height
    end

    -- Icon Logic
    local data = DynamicTrading.Manager.GetData()
    local trader = data.Traders and data.Traders[item.item.traderID]
    local tex = nil
    
    if trader and DynamicTrading.Portraits then
        local archetype = trader.archetype or "General"
        local gender = trader.gender or "Male"
        local portraitID = trader.portraitID or 1
        local pathFolder = DynamicTrading.Portraits.GetPathFolder(archetype, gender)
        tex = getTexture(pathFolder .. tostring(portraitID) .. ".png")
    end
    
    if not tex then tex = getTexture("Item_WalkieTalkie1") end
    
    if tex then this:drawTextureScaled(tex, 5, y + 5, 28, 28, 1, 1, 1, 1) end
    this:drawText(item.text, 38, y + 12, 1, 1, 1, 1, this.font)
    return y + height
end

function DT_TraderListPanel.onListMouseDown(target, x, y)
    local row = target:rowAt(x, y)
    if row == -1 then return end
    target.selected = row
    
    local item = target.items[row]
    -- Access Main Window via parent logic (target -> listbox, listbox.parentPanel -> TraderList, TraderList.parent -> RadioWindow)
    local mainWindow = target.parentPanel.parent
    
    if item.item and item.item.traderID and mainWindow and DynamicTradingUI then
        if mainWindow.radioObj then
             DynamicTradingUI.ToggleWindow(item.item.traderID, item.item.archetype, mainWindow.radioObj)
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
