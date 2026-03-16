-- ==============================================================================
-- DTNPC_GlobalListPanel.lua
-- Decoupled component for the "Global Database" view.
-- ==============================================================================

DTNPC_DatabaseListPanel = ISPanel:derive("DTNPC_DatabaseListPanel")

function DTNPC_DatabaseListPanel:initialise()
    ISPanel.initialise(self)
end

function DTNPC_DatabaseListPanel:createChildren()
    self.npcList = ISScrollingListBox:new(0, 0, self.width, self.height)
    self.npcList:initialise()
    self.npcList:instantiate()
    self.npcList.onmousedown = self.onSelectNPC
    self.npcList.target = self
    self.npcList.drawBorder = true
    self:addChild(self.npcList)
end

function DTNPC_DatabaseListPanel:onSelectNPC(item)
    if self.parentWindow then
        self.parentWindow:onSelectNPC(item, self)
    end
end

function DTNPC_DatabaseListPanel:refresh()
    self.npcList:clear()
    
    local databaseCount = 0
    local globalAdded = {}
    
    -- 1. Cache (Multiplayer)
    if DTNPCClient and DTNPCClient.NPCCache then
        for id, entry in pairs(DTNPCClient.NPCCache) do
            local npcData = entry.npcData
            local name = npcData.name or "Unknown"
            
            -- Distance calculation
            local player = getSpecificPlayer(0)
            local distText = ""
            if player and npcData.lastX then
                local dx = npcData.lastX - player:getX()
                local dy = npcData.lastY - player:getY()
                local dist = math.sqrt(dx*dx + dy*dy)
                distText = string.format(" [%.0fm]", dist)
            end
            
            local stateText = " [" .. (npcData.state or "??") .. "]"
            
            -- Display remaining trading time
            if npcData.status == "Trading" and npcData.returnTime then
                local currentHours = getGameTime():getWorldAgeHours()
                local remaining = npcData.returnTime - currentHours
                if remaining > 0 then
                    stateText = stateText .. string.format(" (%.1fh)", remaining)
                end
            end

            self.npcList:addItem(name .. stateText .. distText, {id = id, npcData = npcData})
            
            local item = self.npcList.items[#self.npcList.items]
            local color = {r=1, g=1, b=1, a=1}
            if npcData.state == "Follow" then color = {r=0, g=0.8, b=1, a=1}
            elseif npcData.state == "Incapacitated" then color = {r=1, g=0.55, b=0.15, a=1}
            elseif npcData.state == "Stay" or npcData.state == "Guard" or npcData.status == "Trading" then color = {r=1, g=1, b=0, a=1}
            elseif npcData.isHostile then color = {r=1, g=0.2, b=0.2, a=1}
            end
            item.color = color
            
            globalAdded[id] = true
            databaseCount = databaseCount + 1
        end
    end

    -- 2. Metadata Cache (Discovered/Far NPCs)
    if DTNPCClient and DTNPCClient.MetadataCache then
        for id, npcData in pairs(DTNPCClient.MetadataCache) do
            if not globalAdded[id] then
                local name = npcData.name or "Unknown"
                
                -- Distance calculation
                local player = getSpecificPlayer(0)
                local distText = ""
                if player and npcData.lastX then
                    local dx = npcData.lastX - player:getX()
                    local dy = npcData.lastY - player:getY()
                    local dist = math.sqrt(dx*dx + dy*dy)
                    distText = string.format(" [%.0fm]", dist)
                end
                
                local stateText = " [DISCOVERED]"
                if npcData.status == "Trading" then
                    stateText = " [TRADER]"
                end

                self.npcList:addItem(name .. stateText .. distText, {id = id, npcData = npcData})
                
                local item = self.npcList.items[#self.npcList.items]
                item.color = {r=0.6, g=0.9, b=0.6, a=1} -- Light green for metadata
                
                globalAdded[id] = true
                databaseCount = databaseCount + 1
            end
        end
    end

    -- 3. Manager Data (Singleplayer Fallback)
    if not isClient() and DTNPCManager and DTNPCManager.Data then
        for id, npcData in pairs(DTNPCManager.Data) do
            if not globalAdded[id] then
                local name = npcData.name or "Unknown"
                local player = getSpecificPlayer(0)
                local distText = ""
                if player and npcData.lastX then
                    local dx = npcData.lastX - player:getX()
                    local dy = npcData.lastY - player:getY()
                    local dist = math.sqrt(dx*dx + dy*dy)
                    distText = string.format(" [%.0fm]", dist)
                end
                
                self.npcList:addItem(name .. " [DB]" .. distText, {id = id, npcData = npcData})
                databaseCount = databaseCount + 1
            end
        end
    end
    
    return databaseCount
end

function DTNPC_DatabaseListPanel:new(x, y, width, height, parentWindow)
    local o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.parentWindow = parentWindow
    return o
end
