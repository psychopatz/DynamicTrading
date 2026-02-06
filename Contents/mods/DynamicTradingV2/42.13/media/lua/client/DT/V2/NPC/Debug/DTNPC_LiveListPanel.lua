-- ==============================================================================
-- DTNPC_LiveListPanel.lua
-- Decoupled component for the "Live NPCs" view.
-- ==============================================================================

DTNPC_LiveListPanel = ISPanel:derive("DTNPC_LiveListPanel")

function DTNPC_LiveListPanel:initialise()
    ISPanel.initialise(self)
end

function DTNPC_LiveListPanel:createChildren()
    self.npcList = ISScrollingListBox:new(0, 0, self.width, self.height)
    self.npcList:initialise()
    self.npcList:instantiate()
    self.npcList.onmousedown = self.onSelectNPC
    self.npcList.target = self
    self.npcList.drawBorder = true
    self:addChild(self.npcList)
end

function DTNPC_LiveListPanel:onSelectNPC(item)
    if self.parentWindow then
        self.parentWindow:onSelectNPC(item, self)
    end
end

function DTNPC_LiveListPanel:refresh()
    self.npcList:clear()
    
    local cell = getCell()
    if not cell then return end
    
    local zombieList = cell:getZombieList()
    if not zombieList then return end
    
    local liveCount = 0
    for i = 0, zombieList:size() - 1 do
        local zombie = zombieList:get(i)
        if zombie then
            local modData = zombie:getModData()
            if modData and modData.IsDTNPC and modData.DTNPCBrain then
                local id = zombie:getPersistentOutfitID()
                local brain = modData.DTNPCBrain
                
                -- Distance check
                local player = getSpecificPlayer(0)
                local distText = ""
                if player then
                    local dx = zombie:getX() - player:getX()
                    local dy = zombie:getY() - player:getY()
                    local dist = math.sqrt(dx*dx + dy*dy)
                    distText = string.format(" [%.0fm]", dist)
                end
                
                local stateText = " [" .. (brain.state or "Idle") .. "]"
                self.npcList:addItem(brain.name .. stateText .. distText, {id = id, brain = brain, zombie = zombie})
                
                local item = self.npcList.items[#self.npcList.items]
                local color = {r=1, g=1, b=1, a=1}
                if brain.state == "Follow" then color = {r=0, g=0.8, b=1, a=1}
                elseif brain.state == "Stay" or brain.state == "Guard" then color = {r=1, g=1, b=0, a=1}
                elseif brain.isHostile then color = {r=1, g=0.2, b=0.2, a=1}
                end
                item.color = color
                
                liveCount = liveCount + 1
            end
        end
    end
    return liveCount
end

function DTNPC_LiveListPanel:new(x, y, width, height, parentWindow)
    local o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.parentWindow = parentWindow
    return o
end
