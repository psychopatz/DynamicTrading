-- ==============================================================================
-- DTNPC_Debugger.lua
-- UI Tool: Displays a list of all NPCs and their internal brain data.
-- Build 42 Compatible.
-- ADDED: EventMarker integration to locate NPCs
-- ==============================================================================

if not isDebugEnabled() then return end

DTNPC_Debugger = ISCollapsableWindow:derive("DTNPC_Debugger")
DTNPC_Debugger.instance = nil

print("[DTNPC] Debugger Script Loaded")

function DTNPC_Debugger:initialise()
    ISCollapsableWindow.initialise(self)
end

function DTNPC_Debugger:createChildren()
    ISCollapsableWindow.createChildren(self)

    local topH = 20
    local listW = 200
    
    -- 1. NPC LIST
    self.npcList = ISScrollingListBox:new(0, topH, listW, self.height - topH - 80)
    self.npcList:initialise()
    self.npcList:instantiate()
    self.npcList.onmousedown = self.onSelectNPC
    self.npcList.target = self
    self.npcList.drawBorder = true
    self:addChild(self.npcList)

    -- 2. DETAILS PANEL
    self.detailsPanel = ISPanel:new(listW, topH, self.width - listW, self.height - topH - 80)
    self.detailsPanel:initialise()
    self.detailsPanel.drawBackground = false
    self:addChild(self.detailsPanel)
    
    -- 3. BUTTONS
    local btnW = 100
    local btnH = 25
    local btnY = self.height - 75
    local btnSpacing = 5
    
    -- Row 1
    self.refreshBtn = ISButton:new(10, btnY, btnW, btnH, "Refresh", self, self.refresh)
    self.refreshBtn:initialise()
    self.refreshBtn.backgroundColor = {r=0.2, g=0.2, b=0.2, a=1}
    self:addChild(self.refreshBtn)

    self.teleportBtn = ISButton:new(10 + btnW + btnSpacing, btnY, btnW, btnH, "Goto NPC", self, self.onTeleport)
    self.teleportBtn:initialise()
    self.teleportBtn.backgroundColor = {r=0.2, g=0.2, b=0.5, a=1}
    self.teleportBtn.enable = false
    self:addChild(self.teleportBtn)
    
    -- NEW: Marker button
    self.markerBtn = ISButton:new(10 + (btnW + btnSpacing) * 2, btnY, btnW, btnH, "Mark NPC", self, self.onMarkNPC)
    self.markerBtn:initialise()
    self.markerBtn.backgroundColor = {r=0.2, g=0.5, b=0.2, a=1}
    self.markerBtn.enable = false
    self:addChild(self.markerBtn)
    
    -- Row 2
    btnY = btnY + btnH + btnSpacing
    
    self.clearMarkersBtn = ISButton:new(10, btnY, btnW * 2 + btnSpacing, btnH, "Clear All Markers", self, self.onClearMarkers)
    self.clearMarkersBtn:initialise()
    self.clearMarkersBtn.backgroundColor = {r=0.5, g=0.2, b=0.2, a=1}
    self:addChild(self.clearMarkersBtn)

    self:refresh()
end

function DTNPC_Debugger:refresh()
    self.npcList:clear()
    
    -- 1. Check NPCCache (Multiplayer Sync)
    local count = 0
    if DTNPCClient and DTNPCClient.NPCCache then
        for id, entry in pairs(DTNPCClient.NPCCache) do
            local brain = entry.brain
            local name = brain.name or "Unknown"
            local state = brain.state or "Idle"
            local distance = self:calculateDistanceToPlayer(brain.lastX, brain.lastY)
            local distText = distance and string.format(" [%.0fm]", distance) or ""
            self.npcList:addItem(name .. " (" .. state .. ")" .. distText, {id = id, brain = brain})
            count = count + 1
        end
    end
    print("[DTNPC] Debugger Refresh: Cache count = " .. count)

    -- 2. Fallback: Scan World (Singleplayer / Local sync)
    local cell = getCell()
    local worldCount = 0
    if cell then
        local zombieList = cell:getZombieList()
        for i = 0, zombieList:size() - 1 do
            local zombie = zombieList:get(i)
            if zombie then
                local modData = zombie:getModData()
                if modData and modData.IsDTNPC and modData.DTNPCBrain then
                    local id = zombie:getPersistentOutfitID()
                    -- Only add if not already in list from cache
                    local exists = false
                    for _, item in ipairs(self.npcList.items) do
                        if item.item.id == id then exists = true; break end
                    end
                    if not exists then
                        local brain = modData.DTNPCBrain
                        local distance = self:calculateDistanceToPlayer(brain.lastX, brain.lastY)
                        local distText = distance and string.format(" [%.0fm]", distance) or ""
                        self.npcList:addItem(brain.name .. " (Local)" .. distText, {id = id, brain = brain})
                        worldCount = worldCount + 1
                    end
                end
            end
        end
    end
    print("[DTNPC] Debugger Refresh: World count = " .. worldCount)
end

function DTNPC_Debugger:calculateDistanceToPlayer(x, y)
    if not x or not y then return nil end
    
    local player = getSpecificPlayer(0)
    if not player then return nil end
    
    local px = player:getX()
    local py = player:getY()
    
    local dx = x - px
    local dy = y - py
    
    return math.sqrt(dx * dx + dy * dy)
end

function DTNPC_Debugger:onSelectNPC(item)
    self.selectedNPC = item
    self.teleportBtn.enable = true
    self.markerBtn.enable = true
end

function DTNPC_Debugger:onTeleport()
    if not self.selectedNPC then return end
    local brain = self.selectedNPC.brain
    if brain and brain.lastX then
        getPlayer():setX(brain.lastX)
        getPlayer():setY(brain.lastY)
        getPlayer():setZ(brain.lastZ or 0)
    end
end

function DTNPC_Debugger:onMarkNPC()
    if not self.selectedNPC then return end
    
    local brain = self.selectedNPC.brain
    local id = self.selectedNPC.id
    
    if not brain or not brain.lastX or not brain.lastY then
        local player = getSpecificPlayer(0)
        if player then
            player:Say("Cannot mark NPC: No location data")
        end
        return
    end
    
    -- Check if EventMarkerHandler is available
    if not EventMarkerHandler then
        local player = getSpecificPlayer(0)
        if player then
            player:Say("EventMarkerHandler not available!")
        end
        return
    end
    
    -- Determine marker color based on NPC state
    local color = {r=0.2, g=1, b=0.2} -- Default green
    local icon = "friend.png"
    
    if brain.state == "Follow" then
        color = {r=0.2, g=0.8, b=1} -- Cyan
        icon = "crew.png"
    elseif brain.state == "Stay" or brain.state == "Guard" then
        color = {r=1, g=1, b=0.2} -- Yellow
        icon = "defend.png"
    elseif brain.state == "GoTo" then
        color = {r=1, g=0.5, b=0.2} -- Orange
        icon = "loot.png"
    elseif brain.isHostile then
        color = {r=1, g=0.2, b=0.2} -- Red
        icon = "raid.png"
    end
    
    -- Calculate distance for description
    local distance = self:calculateDistanceToPlayer(brain.lastX, brain.lastY)
    local distText = distance and string.format("%.0fm away", distance) or "Unknown distance"
    
    local description = brain.name .. " - " .. (brain.state or "Idle") .. " - " .. distText
    
    -- Create marker (30 minute duration)
    EventMarkerHandler.set(
        "npc_" .. id,
        icon,
        1800, -- 30 minutes
        brain.lastX,
        brain.lastY,
        color,
        description
    )
    
    local player = getSpecificPlayer(0)
    if player then
        player:Say("Marked NPC: " .. brain.name)
    end
end

function DTNPC_Debugger:onClearMarkers()
    if EventMarkerHandler then
        -- Only remove NPC markers, not all markers
        for markerId, _ in pairs(EventMarkerHandler.markers) do
            if string.sub(markerId, 1, 4) == "npc_" then
                EventMarkerHandler.remove(markerId)
            end
        end
        
        local player = getSpecificPlayer(0)
        if player then
            player:Say("Cleared all NPC markers")
        end
    end
end

function DTNPC_Debugger:render()
    ISCollapsableWindow.render(self)
    
    if self.selectedNPC then
        local brain = self.selectedNPC.brain
        local id = self.selectedNPC.id
        local x = 210
        local y = 40
        local lineH = 15
        
        self:drawText("NAME: " .. tostring(brain.name), x, y, 1, 1, 1, 1, UIFont.Small) y = y + lineH
        self:drawText("ID: " .. tostring(id), x, y, 0.7, 0.7, 0.7, 1, UIFont.Small) y = y + lineH
        self:drawText("STATE: " .. tostring(brain.state), x, y, 1, 1, 0, 1, UIFont.Small) y = y + lineH
        self:drawText("HEALTH: " .. tostring(brain.health), x, y, 1, 0, 0, 1, UIFont.Small) y = y + lineH
        self:drawText("HOSTILE: " .. tostring(brain.isHostile), x, y, 1, 0.5, 0.5, 1, UIFont.Small) y = y + lineH
        self:drawText("POS: " .. tostring(brain.lastX) .. ", " .. tostring(brain.lastY) .. ", " .. tostring(brain.lastZ), x, y, 0.8, 0.8, 1, 1, UIFont.Small) y = y + lineH
        
        -- Show distance to player
        local distance = self:calculateDistanceToPlayer(brain.lastX, brain.lastY)
        if distance then
            self:drawText("DISTANCE: " .. string.format("%.1f tiles (%.0fm)", distance, distance), x, y, 0.5, 1, 1, 1, UIFont.Small) y = y + lineH
        end
        
        self:drawText("VISUAL ID: " .. tostring(brain.visualID), x, y, 0.5, 1, 0.5, 1, UIFont.Small) y = y + lineH
        self:drawText("HAIR: " .. tostring(brain.hairStyle), x, y, 0.7, 0.7, 1, 1, UIFont.Small) y = y + lineH
        if not brain.isFemale then
            self:drawText("BEARD: " .. tostring(brain.beardStyle), x, y, 0.7, 0.7, 1, 1, UIFont.Small) y = y + lineH
        end
        self:drawText("MASTER: " .. tostring(brain.master), x, y, 0.5, 0.5, 1, 1, UIFont.Small) y = y + lineH
        
        if brain.outfit and #brain.outfit > 0 then
            y = y + 5
            self:drawText("CLOTHES:", x, y, 1, 0.8, 0.4, 1, UIFont.Small) y = y + lineH
            for _, item in ipairs(brain.outfit) do
                self:drawText("  - " .. tostring(item), x, y, 0.8, 0.8, 0.8, 1, UIFont.Small) y = y + lineH
            end
        end

        if brain.tasks and #brain.tasks > 0 then
            y = y + 5
            self:drawText("TASKS: " .. #brain.tasks, x, y, 1, 1, 1, 1, UIFont.Small) y = y + lineH
            for i, task in ipairs(brain.tasks) do
                self:drawText("  [" .. i .. "] -> " .. task.x .. "," .. task.y, x, y, 0.6, 0.6, 0.6, 1, UIFont.Small) y = y + lineH
            end
        end
    else
        self:drawText("Select an NPC from the list", 210, 40, 0.5, 0.5, 0.5, 1, UIFont.Small)
    end
end

function DTNPC_Debugger.OnOpenWindow()
    if DTNPC_Debugger.instance then
        DTNPC_Debugger.instance:setVisible(not DTNPC_Debugger.instance:getIsVisible())
        if DTNPC_Debugger.instance:getIsVisible() then
            DTNPC_Debugger.instance:refresh()
        end
        return
    end

    local window = DTNPC_Debugger:new(100, 100, 500, 600)
    window:initialise()
    window:addToUIManager()
    window:setVisible(true)
    window.pin = true
    window:setTitle("DTNPC Global Debugger")
    DTNPC_Debugger.instance = window
end

return DTNPC_Debugger