require "ISUI/ISCollapsableWindow"
require "ISUI/ISScrollingListBox"
require "DynamicTrading_Manager"
require "DynamicTrading_Config"
require "DynamicTradingUI" 

DynamicTradingTraderListUI = ISCollapsableWindow:derive("DynamicTradingTraderListUI")
DynamicTradingTraderListUI.instance = nil

-- ==========================================================
-- ROBUST SIGNAL CHECK HELPER
-- ==========================================================
-- Scans Inventory and a 5x5 area around the player for ANY working radio.
local function CheckForSignal(player)
    if not player then return false end

    -- 1. CHECK INVENTORY (Walkie Talkies)
    local inv = player:getInventory()
    local items = inv:getItems()
    for i=0, items:size()-1 do
        local item = items:get(i)
        -- Must be a Radio, Turned ON, and have Power
        if item:IsRadio() then
            local data = item:getDeviceData()
            if data and data:getIsTurnedOn() then
                -- Check Power (0.0 to 1.0) safely
                if data:getPower() > 0.001 then 
                    return true 
                end
            end
        end
    end

    -- 2. CHECK NEARBY WORLD OBJECTS (Radius 3 squares)
    local pSq = player:getSquare()
    if not pSq then return false end
    
    local px, py, pz = pSq:getX(), pSq:getY(), pSq:getZ()
    local cell = getCell()
    local range = 3 -- Check 3 tiles in every direction
    
    for dx = -range, range do
        for dy = -range, range do
            local sq = cell:getGridSquare(px + dx, py + dy, pz)
            if sq then
                local objects = sq:getObjects()
                for i=0, objects:size()-1 do
                    local obj = objects:get(i)
                    -- IsoWaveSignal = Placed Radios/TVs
                    if instanceof(obj, "IsoWaveSignal") then
                        local data = obj:getDeviceData()
                        if data and data:getIsTurnedOn() then
                            -- Check Battery OR Grid Power
                            if data:getIsBatteryPowered() then
                                if data:getPower() > 0.001 then return true end
                            else
                                if sq:haveElectricity() then return true end
                            end
                        end
                    end
                end
            end
        end
    end

    return false
end

-- ==========================================================
-- UI DEFINITION
-- ==========================================================
function DynamicTradingTraderListUI:initialise()
    ISCollapsableWindow.initialise(self)
    self:setTitle("Frequency Manager")
    self:setResizable(true)
    self.clearStencil = false 
    self.hasSignal = false 
    self.lastTraderCount = -1 -- Force refresh on first load
end

function DynamicTradingTraderListUI:createChildren()
    ISCollapsableWindow.createChildren(self)

    self.listbox = ISScrollingListBox:new(10, 30, self.width - 20, self.height - 40)
    self.listbox:initialise()
    self.listbox:setAnchorRight(true)
    self.listbox:setAnchorBottom(true)
    self.listbox.font = UIFont.Small
    self.listbox.itemheight = 32 -- Taller rows for the button
    self.listbox.drawBorder = true
    self.listbox.borderColor = {r=0.4, g=0.4, b=0.4, a=1}
    
    self.listbox.doDrawItem = DynamicTradingTraderListUI.drawItem 
    self.listbox.onMouseDown = DynamicTradingTraderListUI.onListMouseDown
    
    self:addChild(self.listbox)
end

-- ==========================================================
-- LOGIC: RENDER LOOP (Signal & Auto-Refresh)
-- ==========================================================
function DynamicTradingTraderListUI:render()
    ISCollapsableWindow.render(self)
    
    local player = getSpecificPlayer(0)
    
    -- A. Update Signal Status
    self.hasSignal = CheckForSignal(player)
    
    -- B. Auto-Refresh List if Trader count changes (e.g. New scan result)
    local data = DynamicTrading.Manager.GetData()
    local currentCount = 0
    if data.Traders then
        for _ in pairs(data.Traders) do currentCount = currentCount + 1 end
    end
    
    if currentCount ~= self.lastTraderCount then
        self:populateList()
        self.lastTraderCount = currentCount
    end
end

-- ==========================================================
-- DRAWING THE LIST
-- ==========================================================
function DynamicTradingTraderListUI.drawItem(this, y, item, alt)
    local height = this.itemheight
    local width = this:getWidth()
    local win = this.parent
    local hasSignal = win.hasSignal
    
    -- Highlight
    if this.selected == item.index then
        this:drawRect(0, y, width, height, 0.3, 0.7, 0.35, 0.2)
    elseif alt then
        this:drawRect(0, y, width, height, 0.1, 0.2, 0.2, 0.2)
    end
    this:drawRectBorder(0, y, width, height, 0.1, 1, 1, 1)

    -- Empty List Message
    if not item.item.traderID then
        this:drawText(item.text, 10, y + (height/2) - 7, 0.7, 0.7, 0.7, 1, this.font)
        return y + height
    end

    -- Colors based on Signal
    local r, g, b = 0.9, 0.9, 0.9
    if not hasSignal then r, g, b = 0.5, 0.5, 0.5 end

    -- A. Draw "CALL" Button Area
    local btnSize = 24
    local btnX = 6
    local btnY = y + (height - btnSize)/2
    
    if hasSignal then
        -- Green/Active
        this:drawRect(btnX, btnY, btnSize, btnSize, 0.2, 0.8, 0.2, 0.3)
        this:drawRectBorder(btnX, btnY, btnSize, btnSize, 1.0, 0.2, 0.8, 0.2)
        
        local icon = getTexture("Item_WalkieTalkie1")
        if icon then this:drawTextureScaled(icon, btnX+2, btnY+2, 20, 20, 1, 1, 1, 1) end
    else
        -- Gray/Disabled
        this:drawRect(btnX, btnY, btnSize, btnSize, 0.3, 0.3, 0.3, 0.3)
        this:drawRectBorder(btnX, btnY, btnSize, btnSize, 0.5, 0.5, 0.5, 0.5)
        
        local icon = getTexture("Item_WalkieTalkie1")
        if icon then this:drawTextureScaled(icon, btnX+2, btnY+2, 20, 20, 0.4, 0.5, 0.5, 0.5) end
    end

    -- B. Draw Text
    local textX = btnX + btnSize + 10
    this:drawText(item.text, textX, y + 6, r, g, b, 1, this.font)
    
    -- C. Subtext (ID/Location/Status)
    local subtext = hasSignal and "Signal Strong" or "No Connection"
    local subColor = hasSignal and {0.2, 1.0, 0.2} or {0.8, 0.3, 0.3}
    this:drawText(subtext, textX, y + 18, subColor[1], subColor[2], subColor[3], 1, UIFont.Small)

    return y + height
end

function DynamicTradingTraderListUI:populateList()
    self.listbox:clear()
    local data = DynamicTrading.Manager.GetData()
    local count = 0
    
    if data.Traders then
        for id, trader in pairs(data.Traders) do
            count = count + 1
            local occupation = DynamicTrading.Archetypes[trader.archetype] and DynamicTrading.Archetypes[trader.archetype].name or trader.archetype
            
            -- FORMAT: "Name (Occupation)"
            local name = trader.name or "Unknown"
            local label = name .. " - " .. occupation
            
            self.listbox:addItem(label, { traderID = id, archetype = trader.archetype })
        end
    end
    
    if count == 0 then
        self.listbox:addItem("No frequencies found. Scan using a radio.", {})
    end
end

function DynamicTradingTraderListUI.onListMouseDown(target, x, y)
    local row = target:rowAt(x, y)
    if row == -1 then return end
    target.selected = row
    
    local item = target.items[row]
    if not item.item.traderID then return end -- Skip empty message
    
    local win = target.parent
    if not win.hasSignal then
        getSpecificPlayer(0):playSound("Click")
        HaloTextHelper.addTextWithArrow(getSpecificPlayer(0), "No Signal", false, HaloTextHelper.getColorRed())
        return
    end
    
    -- Open Trade UI
    local data = item.item
    if DynamicTradingUI and DynamicTradingUI.ToggleWindow then
        DynamicTradingUI.ToggleWindow(data.traderID, data.archetype)
    end
end

function DynamicTradingTraderListUI:close()
    self:setVisible(false)
    self:removeFromUIManager()
    DynamicTradingTraderListUI.instance = nil
end

function DynamicTradingTraderListUI.ToggleWindow()
    if DynamicTradingTraderListUI.instance then
        if DynamicTradingTraderListUI.instance:isVisible() then
            DynamicTradingTraderListUI.instance:close()
        else
            DynamicTradingTraderListUI.instance:setVisible(true)
            DynamicTradingTraderListUI.instance:addToUIManager()
            DynamicTradingTraderListUI.instance:populateList()
        end
        return
    end
    local ui = DynamicTradingTraderListUI:new(200, 200, 320, 400)
    ui:initialise()
    ui:addToUIManager()
    DynamicTradingTraderListUI.instance = ui
end

-- ==========================================================
-- CONTEXT MENU
-- ==========================================================
local function OnFillWorldObjectContextMenu(player, context, worldObjects, test)
    context:addOption("Manage Frequencies", nil, DynamicTradingTraderListUI.ToggleWindow)
end

Events.OnFillWorldObjectContextMenu.Add(OnFillWorldObjectContextMenu)