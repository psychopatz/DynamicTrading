-- ==============================================================================
-- media/lua/client/DT/V2/UI/DT_FactionInfoWindow.lua
-- Dedicated Info UI for Factions (Read-Only Version of Debug Window)
-- Build 42 Compatible
-- ==============================================================================

require "ISUI/ISPanel"
require "DT/V2/UI/DT_FactionList"

DT_FactionInfoWindow = ISPanel:derive("DT_FactionInfoWindow")

function DT_FactionInfoWindow:initialise()
    ISPanel.initialise(self)
    self:createChildren()
end

function DT_FactionInfoWindow:createChildren()
    -- 1. TITLE
    self.labelTitle = ISLabel:new(self.width/2, 10, 25, "FACTION INTELLIGENCE", 1, 1, 1, 1, UIFont.Large, true)
    self.labelTitle:initialise()
    self:addChild(self.labelTitle)

    -- 2. LIST BOX (Left Side) - Using our custom class
    local listWidth = 280
    self.listbox = DT_FactionList:new(10, 50, listWidth, self.height - 100)
    self.listbox:initialise()
    self.listbox:instantiate()
    self.listbox.onmousedown = DT_FactionInfoWindow.onListMouseDown
    self:addChild(self.listbox)
    
    -- List Header
    self:drawRectBorder(10, 50, listWidth, self.height - 100, 0.5, 1, 1, 1)

    -- 3. DETAIL PANEL (Middle)
    local detailsX = 10 + listWidth + 10
    local detailsWidth = 320
    self.details = ISRichTextPanel:new(detailsX, 50, detailsWidth, self.height - 100)
    self.details:initialise()
    self.details.backgroundColor = {r=0, g=0, b=0, a=0.5}
    self.details.borderColor = {r=1, g=1, b=1, a=0.5}
    self.details:addScrollBars()
    self:addChild(self.details)
    self.details:setText("Select a faction to view details.")

    -- 4. ROSTER LIST (Right Side)
    local rosterX = detailsX + detailsWidth + 10
    local rosterWidth = self.width - rosterX - 10
    self.rosterlist = ISScrollingListBox:new(rosterX, 50, rosterWidth, self.height - 100)
    self.rosterlist:initialise()
    self.rosterlist:instantiate()
    self.rosterlist.itemheight = 30 
    self.rosterlist.doDrawItem = DT_FactionInfoWindow.doDrawRosterItem
    self.rosterlist.backgroundColor = {r=0.1, g=0.1, b=0.1, a=0.5}
    self.rosterlist.drawBorder = true
    self:addChild(self.rosterlist)
    
    -- 5. CLOSE BUTTON
    local btnWidth = 100
    self.btnClose = ISButton:new((self.width - btnWidth) / 2, self.height - 40, btnWidth, 25, "CLOSE", self, function(self) self:removeFromUIManager() end)
    self.btnClose:initialise()
    self.btnClose.backgroundColor = {r=0.5, g=0.1, b=0.1, a=0.8}
    self:addChild(self.btnClose)

    self:refreshList()
end

function DT_FactionInfoWindow:refreshList()
    -- Request Data
    if isClient() and not isServer() then
        sendClientCommand(getPlayer(), "DynamicTrading_V2", "RequestFactionData", {})
        return
    end
    
    -- Singleplayer Direct Access
    local factionData = ModData.get("DynamicTrading_Factions") or {}
    self:populateList(factionData)
end

function DT_FactionInfoWindow:populateList(factionData)
    self.listbox:clear()
    
    local keys = {}
    for id in pairs(factionData) do table.insert(keys, id) end
    table.sort(keys)

    for _, id in ipairs(keys) do
        local f = factionData[id]
        self.listbox:addItem(f.name or id, f)
    end
end

-- =============================================================================
-- INTERACTION HANDLERS
-- =============================================================================
function DT_FactionInfoWindow:onListMouseDown(item)
    local f = item
    if not f then return end
    
    -- Update Details Text
    local text = " <RGB:1,0.8,0> NAME: " .. f.name .. " <LINE> "
    text = text .. " <RGB:0.6,0.6,0.6> ID: " .. f.id .. " <LINE> <LINE> "
    
    -- Location
    text = text .. " <RGB:1,1,1> LOCATION DATA: <LINE> "
    text = text .. " <RGB:0.8,0.8,0.8> Town: " .. tostring(f.town or "N/A") .. " <LINE> "
    if f.homeCoords then
        text = text .. " Base: " .. f.homeCoords.name .. " (" .. f.homeCoords.x .. "," .. f.homeCoords.y .. "," .. f.homeCoords.z .. ") <LINE> "
    else
        text = text .. " Base: NOMADIC (Roaming) <LINE> "
    end
    
    -- Economy
    text = text .. " <LINE> <RGB:1,1,1> ECONOMIC DATA: <LINE> "
    text = text .. " <RGB:0.2,1,0.2> Wealth: $" .. tostring(f.wealth or 0) .. " <LINE> "
    
    -- Reputation
    text = text .. " <LINE> <RGB:1,1,1> REPUTATION (Active Players): <LINE> "
    if f.reputation and type(f.reputation) == "table" then
        local found = false
        for user, rep in pairs(f.reputation) do
            local color = " <RGB:1,1,1> "
            if rep > 0 then color = " <RGB:0.2,1,0.2> "
            elseif rep < 0 then color = " <RGB:1,0.2,0.2> " end
            text = text .. " - " .. user .. ": " .. color .. rep .. " <LINE> "
            found = true
        end
        if not found then text = text .. " <RGB:0.6,0.6,0.6> No relations recorded. <LINE> " end
    else
        text = text .. " <RGB:0.6,0.6,0.6> No reputation data. <LINE> "
    end
    
    -- Events
    text = text .. " <LINE> <RGB:1,1,1> ACTIVE EVENTS: <LINE> "
    if f.ActiveFlashEvent and f.ActiveFlashEvent.id then
        local currentHours = getGameTime():getWorldAgeHours()
        local diff = math.max(0, f.ActiveFlashEvent.expires - currentHours)
        text = text .. " <RGB:0,1,1> EVENT: " .. f.ActiveFlashEvent.id .. " <LINE> "
        text = text .. " <RGB:0.8,0.8,0.8> Expires in: " .. string.format("%.1f", diff) .. " hours <LINE> "
    else
        text = text .. " <RGB:0.6,0.6,0.6> No active events. <LINE> "
    end
    
    -- Stockpile
    text = text .. " <LINE> <RGB:1,1,1> KNOWN STOCKPILES: <LINE> "
    if f.stockpile then
        for k, v in pairs(f.stockpile) do
            text = text .. " <RGB:0.8,0.8,0.8> - " .. k .. ": " .. v .. " <LINE> "
        end
    end

    DT_FactionInfoWindow.instance.details:setText(text)
    DT_FactionInfoWindow.instance.details:paginate()

    -- Repopulate Roster (Simplified)
    DT_FactionInfoWindow.instance.rosterlist:clear()
    
    -- Get roster data (Cached or Direct)
    local rosterData = DT_FactionInfoWindow.cachedRosterData or ModData.get("DynamicTrading_Roster")
    
    if rosterData then
        local members = rosterData.FactionMembers and rosterData.FactionMembers[f.id]
        if members and #members > 0 then
            for _, uuid in ipairs(members) do
                local soul = rosterData.Souls and rosterData.Souls[uuid]
                if soul then
                    local data = { soul = soul, uuid = uuid }
                    DT_FactionInfoWindow.instance.rosterlist:addItem(soul.name or uuid, data)
                end
            end
        else
            DT_FactionInfoWindow.instance.rosterlist:addItem("No Members", nil)
        end
    end
end

function DT_FactionInfoWindow:doDrawRosterItem(y, item, alt)
    local data = item.item
    if not data then -- "No Members" placeholder
        self:drawText(item.text, 10, y + 5, 0.7, 0.7, 0.7, 1, UIFont.Small)
        return y + self.itemheight
    end
    
    local soul = data.soul
    if not soul then return y end

    if item.selected then
        self:drawRect(0, y, self.width, self.itemheight, 0.2, 0.7, 0.7, 0.7)
    elseif alt then
        self:drawRect(0, y, self.width, self.itemheight, 0.05, 1, 1, 1)
    end
    
    -- Status Color
    local status = soul.status or "Active"
    local r, g, b = 0.8, 0.8, 0.8
    if status == "Dead" then r,g,b = 0.6, 0.2, 0.2
    elseif status == "Away" then r,g,b = 0.4, 0.4, 0.9
    elseif status == "Trading" then r,g,b = 0.9, 0.8, 0.2
    end
    
    self:drawText(soul.name, 10, y + 5, r, g, b, 1, UIFont.Small)
    self:drawText(status, self.width - 80, y + 5, r*0.8, g*0.8, b*0.8, 1, UIFont.Small)

    return y + self.itemheight
end

-- =============================================================================
-- NETWORKING & INSTANCE MANAGEMENT
-- =============================================================================

-- Handle server response
local function onServerCommand(module, command, args)
    if module ~= "DynamicTrading_V2" then return end
    
    if command == "SyncFactionDebugData" then
        if DT_FactionInfoWindow.instance and DT_FactionInfoWindow.instance:getIsVisible() then
            -- Cache data
            DT_FactionInfoWindow.cachedFactionData = args.factions
            DT_FactionInfoWindow.cachedRosterData = args.roster
            
            -- Populate
            DT_FactionInfoWindow.instance:populateList(args.factions)
        end
    end
end

-- Reactive Refresh for Multiplayer (Static/Singleton level)
if not DT_FactionInfoWindow.EventsAdded then
    Events.OnReceiveGlobalModData.Add(function(key, data)
        if (key == "DynamicTrading_Factions" or key == "DynamicTrading_Roster") and DT_FactionInfoWindow.instance then
            if DT_FactionInfoWindow.instance:getIsVisible() then
                DT_FactionInfoWindow.instance:refreshList()
            end
        end
    end)
    Events.OnServerCommand.Add(onServerCommand)
    DT_FactionInfoWindow.EventsAdded = true
end


function DT_FactionInfoWindow.Open()
    if DT_FactionInfoWindow.instance then
        DT_FactionInfoWindow.instance:setVisible(true)
        DT_FactionInfoWindow.instance:addToUIManager()
        DT_FactionInfoWindow.instance:refreshList()
        return
    end

    local width = 900
    local height = 600
    local x = (getCore():getScreenWidth() - width) / 2
    local y = (getCore():getScreenHeight() - height) / 2

    local window = DT_FactionInfoWindow:new(x, y, width, height)
    window:initialise()
    window:addToUIManager()
    DT_FactionInfoWindow.instance = window
end

function DT_FactionInfoWindow:new(x, y, width, height)
    local o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.backgroundColor = {r=0, g=0, b=0, a=0.9}
    o.borderColor = {r=0.6, g=0.6, b=0.6, a=1}
    o.moveWithMouse = true
    return o
end
