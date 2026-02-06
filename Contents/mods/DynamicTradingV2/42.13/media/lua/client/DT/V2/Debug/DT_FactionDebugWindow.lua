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
    local listWidth = 250
    self.listbox = ISScrollingListBox:new(10, 45, listWidth, self.height - 140)
    self.listbox:initialise()
    self.listbox:instantiate()
    self.listbox.itemheight = 40
    self.listbox.doDrawItem = DT_FactionDebugWindow.doDrawItem
    self.listbox.onmousedown = DT_FactionDebugWindow.onListMouseDown
    self:addChild(self.listbox)

    -- 3. DETAIL PANEL (Middle)
    local detailsX = 10 + listWidth + 10
    local detailsWidth = 300
    self.details = ISRichTextPanel:new(detailsX, 45, detailsWidth, self.height - 140)
    self.details:initialise()
    self.details.backgroundColor = {r=0, g=0, b=0, a=0.5}
    self.details:addScrollBars()
    self:addChild(self.details)
    self.details:setText("Select a faction.")

    -- 4. ROSTER LIST (Right Side)
    local rosterX = detailsX + detailsWidth + 10
    local rosterWidth = self.width - rosterX - 10
    self.rosterlist = ISScrollingListBox:new(rosterX, 45, rosterWidth, self.height - 180)
    self.rosterlist:initialise()
    self.rosterlist:instantiate()
    self.rosterlist.itemheight = 45 -- Slightly taller for status lines
    self.rosterlist.doDrawItem = DT_FactionDebugWindow.doDrawRosterItem
    self.rosterlist.onmousedown = DT_FactionDebugWindow.onRosterMouseDown
    self.rosterlist.backgroundColor = {r=0, g=0, b=0, a=0.5}
    self:addChild(self.rosterlist)

    -- 5. BUTTONS (Centered at bottom)
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

    -- 6. SELECTED FACTION CONTROLS
    local ctrlX = detailsX
    local ctrlY = self.height - 75
    local ctrlBtnWidth = 100

    self.btnWealthAdd = ISButton:new(ctrlX, ctrlY, ctrlBtnWidth, 20, "+ WEALTH", self, function()
        local f = self.listbox.items[self.listbox.selected]
        if f then
            sendClientCommand(getPlayer(), "DynamicTrading_V2", "DebugCommand", { action = "ModifyWealth", factionID = f.item.id, amount = 1000 })
        end
    end)
    self.btnWealthAdd:initialise()
    self:addChild(self.btnWealthAdd)

    self.btnWealthSub = ISButton:new(ctrlX + ctrlBtnWidth + 5, ctrlY, ctrlBtnWidth, 20, "- WEALTH", self, function()
        local f = self.listbox.items[self.listbox.selected]
        if f then
            sendClientCommand(getPlayer(), "DynamicTrading_V2", "DebugCommand", { action = "ModifyWealth", factionID = f.item.id, amount = -1000 })
        end
    end)
    self.btnWealthSub:initialise()
    self:addChild(self.btnWealthSub)

    self.btnRepAdd = ISButton:new(ctrlX + (ctrlBtnWidth + 5) * 2, ctrlY, ctrlBtnWidth, 20, "+ REP", self, function()
        local f = self.listbox.items[self.listbox.selected]
        if f then
            sendClientCommand(getPlayer(), "DynamicTrading_V2", "DebugCommand", { action = "ModifyReputation", factionID = f.item.id, amount = 10 })
        end
    end)
    self.btnRepAdd:initialise()
    self:addChild(self.btnRepAdd)

    self.btnRepSub = ISButton:new(ctrlX + (ctrlBtnWidth + 5) * 3, ctrlY, ctrlBtnWidth, 20, "- REP", self, function()
        local f = self.listbox.items[self.listbox.selected]
        if f then
            sendClientCommand(getPlayer(), "DynamicTrading_V2", "DebugCommand", { action = "ModifyReputation", factionID = f.item.id, amount = -10 })
        end
    end)
    self.btnRepSub:initialise()
    self:addChild(self.btnRepSub)

    -- 7. LOCATE NPC BUTTON (Under Roster)
    local locateX = rosterX
    local locateY = self.height - 130
    local locateWidth = 150

    self.btnLocate = ISButton:new(locateX, locateY, locateWidth, 25, "LOCATE NPC", self, DT_FactionDebugWindow.onLocateNPC)
    self.btnLocate:initialise()
    self.btnLocate.backgroundColor = {r=0.2, g=0.2, b=0.7, a=1}
    self.btnLocate.enable = false
    self:addChild(self.btnLocate)

    self.btnForceTrade = ISButton:new(locateX + locateWidth + 10, locateY, locateWidth, 25, "FORCE TRADE", self, DT_FactionDebugWindow.onForceTradeNPC)
    self.btnForceTrade:initialise()
    self.btnForceTrade.backgroundColor = {r=0.7, g=0.2, b=0.2, a=1}
    self.btnForceTrade.enable = false
    self:addChild(self.btnForceTrade)

    self:refreshList()
end

-- Reactive Refresh for Multiplayer (Static/Singleton level)
if not DT_FactionDebugWindow.EventsAdded then
    Events.OnReceiveGlobalModData.Add(function(key, data)
        if (key == "DynamicTrading_Factions" or key == "DynamicTrading_Roster") and DT_FactionDebugWindow.instance then
            if DT_FactionDebugWindow.instance:getIsVisible() then
                DT_FactionDebugWindow.instance:refreshList()
            end
        end
    end)
    DT_FactionDebugWindow.EventsAdded = true
end

function DT_FactionDebugWindow:refreshList()
    -- In multiplayer, request data from server
    if isClient() and not isServer() then
        sendClientCommand(getPlayer(), "DynamicTrading_V2", "RequestFactionData", {})
        -- Data will arrive via OnServerCommand and populate the list
        return
    end
    
    -- In singleplayer, access directly
    local factionData = ModData.get("DynamicTrading_Factions") or {}
    self:populateList(factionData)
end

function DT_FactionDebugWindow:populateList(factionData)
    self.listbox:clear()
    
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
    text = text .. " <LINE> <RGB:0.2,0.2,1> PLAYER REPUTATIONS: <LINE> "
    if f.reputation and type(f.reputation) == "table" then
        for user, rep in pairs(f.reputation) do
            text = text .. " <RGB:0.7,0.7,0.7> - " .. user .. ": <RGB:1,1,1> " .. rep .. " <LINE> "
        end
    else
        text = text .. " <RGB:0.7,0.7,0.7> - No reputation data. <LINE> "
    end
    
    text = text .. " <LINE> <RGB:0,1,0> STOCKPILE: <LINE> "
    if f.stockpile then
        for k, v in pairs(f.stockpile) do
            text = text .. " <RGB:0.7,0.7,0.7> - " .. k .. ": <RGB:1,1,1> " .. v .. " <LINE> "
        end
    end

    DT_FactionDebugWindow.instance.details:setText(text)
    DT_FactionDebugWindow.instance.details:paginate()

    -- Repopulate Roster List
    DT_FactionDebugWindow.instance.rosterlist:clear()
    DT_FactionDebugWindow.instance.btnLocate.enable = false
    
    -- Use cached roster data in multiplayer
    local rosterData = DT_FactionDebugWindow.cachedRosterData or ModData.get("DynamicTrading_Roster")
    
    if rosterData then
        local members = rosterData.FactionMembers and rosterData.FactionMembers[f.id]
        if members and #members > 0 then
            for _, uuid in ipairs(members) do
                local soul = rosterData.Souls and rosterData.Souls[uuid]
                local trader = rosterData.Traders and rosterData.Traders[uuid]
                if soul then
                    local data = {
                        soul = soul,
                        trader = trader,
                        uuid = uuid
                    }
                    DT_FactionDebugWindow.instance.rosterlist:addItem(soul.name or uuid, data)
                end
            end
        end
    end
end

function DT_FactionDebugWindow:onRosterMouseDown(item)
    DT_FactionDebugWindow.instance.btnLocate.enable = true
    DT_FactionDebugWindow.instance.btnForceTrade.enable = true
end

function DT_FactionDebugWindow:doDrawRosterItem(y, item, alt)
    local data = item.item
    local soul = data.soul
    local trader = data.trader

    if not soul then return y end

    if item.selected then
        self:drawRect(0, y, self.width, self.itemheight, 0.3, 0.7, 0.7, 0.7)
    elseif alt then
        self:drawRect(0, y, self.width, self.itemheight, 0.1, 1, 1, 1)
    else
        self:drawRect(0, y, self.width, self.itemheight, 0.1, 0, 0, 0)
    end

    local status = soul.status or "Active"
    local spawned = trader and trader.isPhysicallySpawned and "Spawned: YES" or "Spawned: NO"
    local r, g, b = 1, 1, 1
    if status == "Dead" then r,g,b = 1,0,0
    elseif status == "Away" then r,g,b = 0.5, 0.5, 1
    elseif status == "Home" then r,g,b = 0.5, 1, 0.5
    end

    self:drawText(soul.name .. " [" .. (soul.archetypeID or "N/A") .. "]", 10, y + 2, 1, 1, 1, 1, UIFont.Small)
    
    local returnInfo = ""
    local valRet = (soul.returnTime and soul.returnTime > 0) and soul.returnTime or (trader and trader.returnTime)
    if valRet and valRet > 0 then
        local currentHours = getGameTime():getWorldAgeHours()
        local diff = math.max(0, valRet - currentHours)
        
        if status == "Trading" then
            returnInfo = string.format(" | Trading Ends: %.1fh", diff)
        elseif status == "Away" then
            local dest = soul.returnStatus or "Destination"
            returnInfo = string.format(" | %s in: %.1fh", dest, diff)
        else
            returnInfo = string.format(" | Ret: %.2f", valRet)
            if soul.returnStatus and soul.returnStatus ~= "" then
                returnInfo = returnInfo .. " (" .. soul.returnStatus .. ")"
            end
        end
    end
    
    self:drawText("Status: " .. status .. " | " .. spawned .. returnInfo, 10, y + 20, r, g, b, 0.8, UIFont.Small)

    return y + self.itemheight
end

function DT_FactionDebugWindow:onLocateNPC()
    local item = self.rosterlist.items[self.rosterlist.selected]
    if not item or not item.item then return end
    
    local soul = item.item.soul
    local uuid = item.item.uuid
    
    local targetX, targetY
    local status = soul.status or "Resting"
    
    if status == "Resting" or status == "Away" then
        targetX = soul.homeCoords and soul.homeCoords.x
        targetY = soul.homeCoords and soul.homeCoords.y
    elseif status == "Trading" then
        targetX = soul.lastX
        targetY = soul.lastY
    elseif status == "Working" then
        targetX = soul.workCoords and soul.workCoords.x
        targetY = soul.workCoords and soul.workCoords.y
    end
    
    if not targetX or not targetY then
        local player = getPlayer()
        if player then player:Say("No coordinates found for NPC: " .. soul.name) end
        return
    end
    
    if EventMarkerHandler then
        local color = {r=0, g=1, b=1}
        local description = "Target: " .. soul.name .. " (" .. status .. ")"
        
        EventMarkerHandler.set(
            "locate_" .. uuid,
            "friend.png",
            600, -- 10 minutes
            targetX,
            targetY,
            color,
            description
        )
        
        local player = getPlayer()
        if player then player:Say("Marked NPC location on map: " .. soul.name) end
    end
end

function DT_FactionDebugWindow:onForceTradeNPC()
    local item = self.rosterlist.items[self.rosterlist.selected]
    if not item or not item.item then return end
    
    local soul = item.item.soul
    local uuid = item.item.uuid
    
    if soul.status ~= "Resting" then
        if getPlayer() then getPlayer():Say("Only 'Resting' NPCs can be forced to trade.") end
        return
    end
    
    sendClientCommand(getPlayer(), "DynamicTrading_V2", "ForceTradeMission", { uuid = uuid })
    if getPlayer() then getPlayer():Say("Forced trade mission for: " .. soul.name) end
end

-- Handle server response
local function onServerCommand(module, command, args)
    if module ~= "DynamicTrading_V2" then return end
    
    if command == "SyncFactionDebugData" then
        if DT_FactionDebugWindow.instance and DT_FactionDebugWindow.instance:getIsVisible() then
            -- Cache the data locally
            DT_FactionDebugWindow.cachedFactionData = args.factions
            DT_FactionDebugWindow.cachedRosterData = args.roster
            
            -- Populate the UI
            DT_FactionDebugWindow.instance:populateList(args.factions)
        end
    end
end

Events.OnServerCommand.Add(onServerCommand)

-- Singleton Access
function DT_FactionDebugWindow.Open()
    if DT_FactionDebugWindow.instance then
        DT_FactionDebugWindow.instance:setVisible(true)
        DT_FactionDebugWindow.instance:addToUIManager()
        DT_FactionDebugWindow.instance:refreshList()
        return
    end

    local window = DT_FactionDebugWindow:new(100, 100, 1000, 500)
    window:initialise()
    window:addToUIManager()
    DT_FactionDebugWindow.instance = window
    window:refreshList() -- This will trigger the server request in multiplayer
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
