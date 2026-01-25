-- ==============================================================================
-- DTNPC_Debugger.lua
-- Main Window: Controls the decoupled NPC debug components.
-- ==============================================================================

-- if not isDebugEnabled() then return end

require "client/NPC/Debug/DTNPC_LiveListPanel"
require "client/NPC/Debug/DTNPC_GlobalListPanel"
require "client/NPC/Debug/DTNPC_DetailsPanel"

DTNPC_Debugger = ISCollapsableWindow:derive("DTNPC_Debugger")
DTNPC_Debugger.instance = nil

function DTNPC_Debugger:initialise()
    ISCollapsableWindow.initialise(self)
    self.resizable = false
    self.updateTick = 0
end

function DTNPC_Debugger:update()
    ISCollapsableWindow.update(self)
    
    if self:getIsVisible() then
        self.updateTick = self.updateTick + 1
        
        -- 1. Refresh Details (Fast)
        if self.selectedNPC and self.updateTick % 20 == 0 then
            self.detailsPanel:setData(self.selectedNPC)
        end
        
        -- 2. Refresh Lists (Slower)
        if self.updateTick >= 100 then
            self.updateTick = 0
            
            -- Preserve selection IDs
            local selectedID = self.selectedNPC and self.selectedNPC.id
            
            self.livePanel:refresh()
            self.globalPanel:refresh()
            
            -- Restore selection
            if selectedID then
                local list = self.livePanel.npcList
                for i, item in ipairs(list.items) do
                    if item.item.id == selectedID then
                        list.selected = i
                        self.selectedNPC = item.item
                        break
                    end
                end
                
                list = self.globalPanel.npcList
                for i, item in ipairs(list.items) do
                    if item.item.id == selectedID then
                        list.selected = i
                        self.selectedNPC = item.item
                        break
                    end
                end
            end
        end
    end
end

function DTNPC_Debugger:createChildren()
    ISCollapsableWindow.createChildren(self)

    local topH = 50 
    local footerH = 60 
    local listW = 280
    
    -- 0. LEFT TAB PANEL (NPC Lists)
    self.tabPanel = ISTabPanel:new(0, 20, listW, self.height - 20 - footerH)
    self.tabPanel:initialise()
    self.tabPanel.target = self
    self.tabPanel.onTabToggled = self.onTabToggled
    self:addChild(self.tabPanel)

    -- 1. LIVE NPCs TAB
    self.livePanel = DTNPC_LiveListPanel:new(0, 0, listW, self.tabPanel.height - self.tabPanel.tabHeight, self)
    self.livePanel:initialise()
    self.tabPanel:addView("Live", self.livePanel)

    -- 2. GLOBAL DATABASE TAB
    self.globalPanel = DTNPC_GlobalListPanel:new(0, 0, listW, self.tabPanel.height - self.tabPanel.tabHeight, self)
    self.globalPanel:initialise()
    self.tabPanel:addView("Global", self.globalPanel)

    -- 3. DETAILS PANEL (Right side)
    self.detailsPanel = DTNPC_DetailsPanel:new(listW, 20, self.width - listW, self.height - 20 - footerH)
    self.detailsPanel:initialise()
    self:addChild(self.detailsPanel)
    
    -- 4. BUTTONS (Shared Footer)
    local btnW = 120
    local btnH = 25
    local btnY = self.height - footerH + 15
    local btnSpacing = 10
    local totalBtnW = (btnW * 4) + (btnSpacing * 3)
    local startX = (self.width - totalBtnW) / 2
    
    self.refreshBtn = ISButton:new(startX, btnY, btnW, btnH, "Refresh", self, self.refresh)
    self.refreshBtn:initialise()
    self.refreshBtn.backgroundColor = {r=0.2, g=0.2, b=0.2, a=1}
    self:addChild(self.refreshBtn)

    self.teleportBtn = ISButton:new(startX + btnW + btnSpacing, btnY, btnW, btnH, "Goto NPC", self, self.onTeleport)
    self.teleportBtn:initialise()
    self.teleportBtn.backgroundColor = {r=0.2, g=0.2, b=0.5, a=1}
    self.teleportBtn.enable = false
    self:addChild(self.teleportBtn)
    
    self.markerBtn = ISButton:new(startX + (btnW + btnSpacing) * 2, btnY, btnW, btnH, "Mark NPC", self, self.onMarkNPC)
    self.markerBtn:initialise()
    self.markerBtn.backgroundColor = {r=0.2, g=0.5, b=0.2, a=1}
    self.markerBtn.enable = false
    self:addChild(self.markerBtn)
    
    self.clearMarkersBtn = ISButton:new(startX + (btnW + btnSpacing) * 3, btnY, btnW, btnH, "Clear Markers", self, self.onClearMarkers)
    self.clearMarkersBtn:initialise()
    self.clearMarkersBtn.backgroundColor = {r=0.5, g=0.2, b=0.2, a=1}
    self:addChild(self.clearMarkersBtn)

    self:refresh()
end

function DTNPC_Debugger:onTabToggled()
    self:refresh()
end

function DTNPC_Debugger:refresh()
    self.livePanel:refresh()
    self.globalPanel:refresh()
    self.detailsPanel.propertyList:clear()
    self.selectedNPC = nil
    self.teleportBtn.enable = false
    self.markerBtn.enable = false
end

function DTNPC_Debugger:onSelectNPC(item, sourcePanel)
    self.selectedNPC = item
    self.teleportBtn.enable = true
    self.markerBtn.enable = true
    
    -- Deselect other panel logic
    if sourcePanel == self.livePanel then
        self.globalPanel.npcList.selected = -1
    else
        self.livePanel.npcList.selected = -1
    end
    
    self.detailsPanel:setData(item)
end

function DTNPC_Debugger:onTeleport()
    if not self.selectedNPC then return end
    local brain = self.selectedNPC.brain
    if brain and (brain.lastX or self.selectedNPC.zombie) then
        local p = getPlayer()
        local tx = brain.lastX
        local ty = brain.lastY
        local tz = brain.lastZ or 0
        
        if self.selectedNPC.zombie then
            tx = self.selectedNPC.zombie:getX()
            ty = self.selectedNPC.zombie:getY()
            tz = self.selectedNPC.zombie:getZ()
        end
        
        p:setX(tx)
        p:setY(ty)
        p:setZ(tz)
    end
end

function DTNPC_Debugger:onMarkNPC()
    if not self.selectedNPC then return end
    
    local brain = self.selectedNPC.brain
    local id = self.selectedNPC.id
    local x = brain.lastX
    local y = brain.lastY
    
    if self.selectedNPC.zombie then
        x = self.selectedNPC.zombie:getX()
        y = self.selectedNPC.zombie:getY()
    end
    
    if not x or not y then return end
    if not EventMarkerHandler then return end
    
    local color = {r=0.2, g=1, b=0.2} 
    local icon = "friend.png"
    
    EventMarkerHandler.set("npc_" .. id, icon, 1800, x, y, color, brain.name)
    
    local player = getSpecificPlayer(0)
    if player then player:Say("Marked NPC: " .. brain.name) end
end

function DTNPC_Debugger:onClearMarkers()
    if EventMarkerHandler then
        for markerId, _ in pairs(EventMarkerHandler.markers) do
            if string.sub(markerId, 1, 4) == "npc_" then
                EventMarkerHandler.remove(markerId)
            end
        end
    end
end

function DTNPC_Debugger:render()
    ISCollapsableWindow.render(self)
    if not self.selectedNPC then
        self:drawText("Select an NPC to view details", 300, 40, 0.5, 0.5, 0.5, 1, UIFont.Small)
    end
end

function DTNPC_Debugger.OnOpenWindow()
    if DTNPC_Debugger.instance then
        DTNPC_Debugger.instance:setVisible(not DTNPC_Debugger.instance:getIsVisible())
        if DTNPC_Debugger.instance:getIsVisible() then
            DTNPC_Debugger.instance:refresh()
            if isClient() then sendClientCommand(getPlayer(), "DTNPC", "RequestFullSync", {}) end
        end
        return
    end

    local window = DTNPC_Debugger:new(100, 100, 850, 600) -- Slightly wider
    window:initialise()
    window:addToUIManager()
    window:setVisible(true)
    window.pin = true
    window:setTitle("DTNPC Global Debugger")
    
    if isClient() then sendClientCommand(getPlayer(), "DTNPC", "RequestFullSync", {}) end
    DTNPC_Debugger.instance = window
end

return DTNPC_Debugger