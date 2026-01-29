-- ==============================================================================
-- DTNPC_GlobalListPanel.lua
-- Decoupled component for the "Global Database" view.
-- ==============================================================================

DTNPC_GlobalListPanel = ISPanel:derive("DTNPC_GlobalListPanel")

function DTNPC_GlobalListPanel:initialise()
    ISPanel.initialise(self)
end

function DTNPC_GlobalListPanel:createChildren()
    self.npcList = ISScrollingListBox:new(0, 0, self.width, self.height)
    self.npcList:initialise()
    self.npcList:instantiate()
    self.npcList.onmousedown = self.onSelectNPC
    self.npcList.target = self
    self.npcList.drawBorder = true
    self:addChild(self.npcList)
end

function DTNPC_GlobalListPanel:onSelectNPC(item)
    if self.parentWindow then
        self.parentWindow:onSelectNPC(item, self)
    end
end

function DTNPC_GlobalListPanel:refresh()
    self.npcList:clear()
    
    local globalCount = 0
    local globalAdded = {}
    
    -- 1. Cache (Multiplayer)
    if DTNPCClient and DTNPCClient.NPCCache then
        for id, entry in pairs(DTNPCClient.NPCCache) do
            local brain = entry.brain
            local name = brain.name or "Unknown"
            
            -- Distance calculation
            local player = getSpecificPlayer(0)
            local distText = ""
            if player and brain.lastX then
                local dx = brain.lastX - player:getX()
                local dy = brain.lastY - player:getY()
                local dist = math.sqrt(dx*dx + dy*dy)
                distText = string.format(" [%.0fm]", dist)
            end
            
            local stateText = " [" .. (brain.state or "??") .. "]"
            self.npcList:addItem(name .. stateText .. distText, {id = id, brain = brain})
            
            local item = self.npcList.items[#self.npcList.items]
            local color = {r=1, g=1, b=1, a=1}
            if brain.state == "Follow" then color = {r=0, g=0.8, b=1, a=1}
            elseif brain.state == "Stay" or brain.state == "Guard" then color = {r=1, g=1, b=0, a=1}
            elseif brain.isHostile then color = {r=1, g=0.2, b=0.2, a=1}
            end
            item.color = color
            
            globalAdded[id] = true
            globalCount = globalCount + 1
        end
    end

    -- 2. Manager Data (Singleplayer Fallback)
    if not isClient() and DTNPCManager and DTNPCManager.Data then
        for id, brain in pairs(DTNPCManager.Data) do
            if not globalAdded[id] then
                local name = brain.name or "Unknown"
                local player = getSpecificPlayer(0)
                local distText = ""
                if player and brain.lastX then
                    local dx = brain.lastX - player:getX()
                    local dy = brain.lastY - player:getY()
                    local dist = math.sqrt(dx*dx + dy*dy)
                    distText = string.format(" [%.0fm]", dist)
                end
                
                self.npcList:addItem(name .. " [DB]" .. distText, {id = id, brain = brain})
                globalCount = globalCount + 1
            end
        end
    end
    
    return globalCount
end

function DTNPC_GlobalListPanel:new(x, y, width, height, parentWindow)
    local o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.parentWindow = parentWindow
    return o
end
