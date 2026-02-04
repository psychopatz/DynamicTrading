-- ==============================================================================
-- DT_V2_RadarWindow.lua
-- UI for displaying discovered traders via Radio Radar.
-- ==============================================================================

DT_V2_RadarWindow = ISPanel:derive("DT_V2_RadarWindow")
DT_V2_RadarWindow.instance = nil

function DT_V2_RadarWindow:initialise()
    ISPanel.initialise(self)
    self:createChildren()
end

function DT_V2_RadarWindow:createChildren()
    local x, y = 10, 10
    
    -- Title
    self.labelTitle = ISLabel:new(self.width/2, 10, 25, "TRADER RADAR", 1, 1, 1, 1, UIFont.Medium, true)
    self.labelTitle:initialise()
    self:addChild(self.labelTitle)

    -- List of Traders
    self.listbox = ISScrollingListBox:new(10, 40, self.width - 20, self.height - 100)
    self.listbox:initialise()
    self.listbox:instantiate()
    self.listbox.itemheight = 50
    self.listbox.doDrawItem = DT_V2_RadarWindow.doDrawItem
    self.listbox.onmousedown = DT_V2_RadarWindow.onListMouseDown
    self.listbox.target = self
    self:addChild(self.listbox)

    -- Action Buttons
    local btnWidth = 100
    local btnY = self.height - 40
    
    self.btnLocate = ISButton:new(10, btnY, btnWidth, 25, "LOCATE", self, DT_V2_RadarWindow.onLocate)
    self.btnLocate:initialise()
    self.btnLocate.backgroundColor = {r=0, g=0.5, b=0, a=1}
    self.btnLocate.enable = false
    self:addChild(self.btnLocate)

    self.btnRefresh = ISButton:new(10 + btnWidth + 10, btnY, btnWidth, 25, "REFRESH", self, self.refresh)
    self.btnRefresh:initialise()
    self:addChild(self.btnRefresh)

    self.btnClose = ISButton:new(self.width - btnWidth - 10, btnY, btnWidth, 25, "CLOSE", self, function(self) self:setVisible(false); self:removeFromUIManager() end)
    self.btnClose:initialise()
    self:addChild(self.btnClose)

    self:refresh()
end

function DT_V2_RadarWindow:refresh()
    self.listbox:clear()
    self.btnLocate.enable = false
    
    if not DT_V2_RadarManager then return end
    
    -- Cleanup any expired traders first
    DT_V2_RadarManager.Cleanup()
    
    local player = getSpecificPlayer(0)
    if not player then return end

    for uuid, data in pairs(DT_V2_RadarManager.FoundTraders) do
        local tx, ty, tz, isLive = DT_V2_RadarManager.GetTraderCoords(uuid)
        
        local distText = "Distance: Unknown"
        if tx and ty then
            local dx = tx - player:getX()
            local dy = ty - player:getY()
            local dist = math.sqrt(dx*dx + dy*dy)
            distText = string.format("Distance: %.0fm", dist)
        end

        local item = {
            uuid = uuid,
            name = data.name,
            faction = data.faction,
            distText = distText,
            isLive = isLive,
            x = tx,
            y = ty,
            z = tz
        }
        self.listbox:addItem(data.name, item)
    end
end

function DT_V2_RadarWindow:doDrawItem(y, item, alt)
    local data = item.item
    if not data then return y end

    if item.selected then
        self:drawRect(0, y, self.width, self.itemheight, 0.3, 0.7, 0.7, 0.7)
    elseif alt then
        self:drawRect(0, y, self.width, self.itemheight, 0.1, 1, 1, 1)
    else
        self:drawRect(0, y, self.width, self.itemheight, 0.1, 0, 0, 0)
    end

    local color = data.isLive and {r=0, g=1, b=0} or {r=0.7, g=0.7, b=0.7}
    self:drawText(data.name .. " (" .. data.faction .. ")", 10, y + 5, 1, 1, 1, 1, UIFont.Small)
    self:drawText(data.distText .. (data.isLive and " [SIGNAL STRONG]" or " [SIGNAL WEAK]"), 10, y + 25, color.r, color.g, color.b, 1, UIFont.Small)

    return y + self.itemheight
end

function DT_V2_RadarWindow:onListMouseDown(item)
    self.btnLocate.enable = true
end

function DT_V2_RadarWindow:onLocate()
    local item = self.listbox.items[self.listbox.selected]
    if not item or not item.item then return end
    
    local data = item.item
    if not data.x or not data.y then
        getSpecificPlayer(0):Say("Signal too weak to pinpoint.")
        return
    end

    if EventMarkerHandler then
        local color = {r=0, g=1, b=1}
        local description = "Trader: " .. data.name
        
        EventMarkerHandler.set(
            "radar_" .. data.uuid,
            "friend.png",
            600, -- 10 minutes
            data.x,
            data.y,
            color,
            description
        )
        getSpecificPlayer(0):Say("Location marked on map.")
    else
        getSpecificPlayer(0):Say("GPS System Error.")
    end
end

function DT_V2_RadarWindow.ToggleWindow()
    if DT_V2_RadarWindow.instance then
        if DT_V2_RadarWindow.instance:getIsVisible() then
            DT_V2_RadarWindow.instance:setVisible(false)
            DT_V2_RadarWindow.instance:removeFromUIManager()
        else
            DT_V2_RadarWindow.instance:setVisible(true)
            DT_V2_RadarWindow.instance:addToUIManager()
            DT_V2_RadarWindow.instance:refresh()
        end
        return
    end

    local window = DT_V2_RadarWindow:new(200, 200, 300, 400)
    window:initialise()
    window:addToUIManager()
    DT_V2_RadarWindow.instance = window
end

function DT_V2_RadarWindow:new(x, y, width, height)
    local o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.backgroundColor = {r=0, g=0, b=0, a=0.8}
    o.borderColor = {r=1, g=1, b=1, a=1}
    o.moveWithMouse = true
    return o
end
