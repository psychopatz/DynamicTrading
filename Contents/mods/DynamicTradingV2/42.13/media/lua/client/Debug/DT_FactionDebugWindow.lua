-- ==============================================================================
-- media/lua/client/Debug/DT_FactionDebugWindow.lua
-- Dedicated UI for Managing Factions
-- Build 42 Compatible
-- ==============================================================================

DT_FactionDebugWindow = ISPanel:derive("DT_FactionDebugWindow")

function DT_FactionDebugWindow:initialise()
    ISPanel.initialise(self)
    self:createChildren()
end

function DT_FactionDebugWindow:createChildren()
    local x, y = 10, 10
    
    -- 1. TITLE
    self.labelTitle = ISLabel:new(self.width/2, 10, 25, "FACTION MANAGEMENT", 1, 1, 1, 1, UIFont.Large, true)
    self.labelTitle:initialise()
    self:addChild(self.labelTitle)

    -- 2. LIST BOX (Left Side)
    local listWidth = 350
    self.listbox = ISScrollingListBox:new(10, 45, listWidth, self.height - 100)
    self.listbox:initialise()
    self.listbox:instantiate()
    self.listbox.itemheight = 40
    self.listbox.doDrawItem = DT_FactionDebugWindow.doDrawItem
    self.listbox.onmousedown = DT_FactionDebugWindow.onListMouseDown
    self:addChild(self.listbox)

    -- 3. DETAIL PANEL (Right Side)
    local detailsX = 10 + listWidth + 10
    local detailsWidth = self.width - detailsX - 10
    self.details = ISRichTextPanel:new(detailsX, 45, detailsWidth, self.height - 100)
    self.details:initialise()
    self.details.backgroundColor = {r=0, g=0, b=0, a=0.5}
    self:addChild(self.details)
    self.details:setText("Select a faction to see details.")

    -- 4. BUTTONS (Centered at bottom)
    local btnWidth = 120
    local totalBtnWidth = (btnWidth * 4) + 30
    local startBtnX = (self.width - totalBtnWidth) / 2
    local btnY = self.height - 40
    
    self.btnRefresh = ISButton:new(startBtnX, btnY, btnWidth, 25, "REFRESH", self, DT_FactionDebugWindow.refreshList)
    self.btnRefresh:initialise()
    self.btnRefresh.backgroundColor = {r=0.2, g=0.5, b=0.2, a=1}
    self:addChild(self.btnRefresh)

    self.btnSim = ISButton:new(startBtnX + btnWidth + 10, btnY, btnWidth, 25, "SIMULATE DAY", self, function()
        sendClientCommand(getPlayer(), "DynamicTrading_V2", "DebugCommand", { action = "SimulateDay" })
        if HaloTextHelper then
            HaloTextHelper.addText(getPlayer(), "Global Simulation Triggered")
        end
    end)
    self.btnSim:initialise()
    self.btnSim.backgroundColor = {r=0.2, g=0.2, b=0.5, a=1}
    self:addChild(self.btnSim)

    self.btnWipe = ISButton:new(startBtnX + (btnWidth + 10) * 2, btnY, btnWidth, 25, "WIPE ALL", self, function()
        sendClientCommand(getPlayer(), "DynamicTrading_V2", "DebugCommand", { action = "WipeFactions" })
    end)
    self.btnWipe:initialise()
    self.btnWipe.backgroundColor = {r=0.5, g=0.2, b=0.2, a=1}
    self:addChild(self.btnWipe)

    self.btnClose = ISButton:new(startBtnX + (btnWidth + 10) * 3, btnY, btnWidth, 25, "CLOSE", self, function(self) self:setVisible(false); self:removeFromUIManager() end)
    self.btnClose:initialise()
    self:addChild(self.btnClose)

    self:refreshList()
end

function DT_FactionDebugWindow:refreshList()
    self.listbox:clear()
    local factionData = ModData.get("DynamicTrading_Factions") or {}
    
    -- Sort keys
    local keys = {}
    for id in pairs(factionData) do table.insert(keys, id) end
    table.sort(keys)

    for _, id in ipairs(keys) do
        local f = factionData[id]
        self.listbox:addItem(f.name or id, f)
    end
end

function DT_FactionDebugWindow:doDrawItem(y, item, alt)
    local f = item.item
    if not f then return y end

    local r, g, b = 1, 1, 1
    if f.state == "Starving" then r, g, b = 1, 0, 0
    elseif f.state == "Vulnerable" then r, g, b = 1, 0.8, 0
    end

    if item.selected then
        self:drawRect(0, y, self.width, self.itemheight, 0.3, 0.7, 0.7, 0.7)
    elseif alt then
        self:drawRect(0, y, self.width, self.itemheight, 0.1, 1, 1, 1)
    else
        self:drawRect(0, y, self.width, self.itemheight, 0.1, 0, 0, 0)
    end
    
    self:drawText(item.text, 10, y + 2, r, g, b, 1, UIFont.Medium)
    self:drawText("State: " .. tostring(f.state) .. " | Pop: " .. tostring(f.memberCount), 10, y + 20, 0.7, 0.7, 0.7, 1, UIFont.Small)

    return y + self.itemheight
end

function DT_FactionDebugWindow:onListMouseDown(item)
    local f = item
    local text = " <RGB:1,1,0> TITLE: " .. f.name .. " <LINE> "
    text = text .. " <RGB:1,1,1> ID: " .. f.id .. " <LINE> "
    text = text .. "Town: " .. tostring(f.town or "N/A") .. " <LINE> "
    if f.homeCoords then
        text = text .. "Base: " .. f.homeCoords.name .. " <LINE> "
        text = text .. "Coords: " .. f.homeCoords.x .. "," .. f.homeCoords.y .. "," .. f.homeCoords.z .. " <LINE> "
    else
        text = text .. "Base: NOMADIC <LINE> "
    end
    
    text = text .. "Wealth: <RGB:0.2,1,0.2> " .. tostring(f.wealth or 0) .. " <LINE> "
    
    text = text .. " <LINE> <RGB:0,1,0> STOCKPILE: <LINE> "
    if f.stockpile then
        for k, v in pairs(f.stockpile) do
            text = text .. " <RGB:0.7,0.7,0.7> - " .. k .. ": <RGB:1,1,1> " .. v .. " <LINE> "
        end
    end

    DT_FactionDebugWindow.instance.details:setText(text)
    DT_FactionDebugWindow.instance.details:paginate()
end

-- Singleton Access
function DT_FactionDebugWindow.Open()
    if DT_FactionDebugWindow.instance then
        DT_FactionDebugWindow.instance:setVisible(true)
        DT_FactionDebugWindow.instance:addToUIManager()
        DT_FactionDebugWindow.instance:refreshList()
        return
    end

    local window = DT_FactionDebugWindow:new(100, 100, 800, 500)
    window:initialise()
    window:addToUIManager()
    DT_FactionDebugWindow.instance = window
end

function DT_FactionDebugWindow:new(x, y, width, height)
    local o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.backgroundColor = {r=0, g=0, b=0, a=0.8}
    o.borderColor = {r=1, g=1, b=1, a=1}
    o.moveWithMouse = true
    return o
end
