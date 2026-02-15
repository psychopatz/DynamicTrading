require "ISUI/ISPanel"
require "ISUI/ISScrollingListBox"
require "ISUI/ISButton"
require "ISUI/ISLabel"
require "DT/UI/Faction/DT_NPCProfilePanel"

DT_FactionInfoTab_Population = ISPanel:derive("DT_FactionInfoTab_Population")

function DT_FactionInfoTab_Population:new(x, y, width, height)
    local o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.backgroundColor = {r=0, g=0, b=0, a=0}
    o.borderColor = {r=0, g=0, b=0, a=0}
    return o
end

function DT_FactionInfoTab_Population:initialise()
    ISPanel.initialise(self)
end

function DT_FactionInfoTab_Population:createChildren()
    local topH = 130 -- Increased from 85 to fit larger portrait
    local padding = 5
    
    -- 1. PROFILE AREA (TOP) - Extracted Component
    self.profilePanel = DT_NPCProfilePanel:new(0, 0, self.width, topH)
    self.profilePanel:initialise()
    self.profilePanel:setAnchorRight(true)
    self:addChild(self.profilePanel)
    
    -- 2. ROSTER LIST
    local listY = topH + padding
    local listH = self.height - topH - padding -- Fill to bottom
    
    self.rosterlist = ISScrollingListBox:new(0, listY, self.width, listH)
    self.rosterlist:initialise()
    self.rosterlist:instantiate()
    self.rosterlist.itemheight = 40 
    self.rosterlist.doDrawItem = self.doDrawRosterItem
    self.rosterlist.backgroundColor = {r=0.05, g=0.05, b=0.05, a=0.5}
    self.rosterlist.drawBorder = true
    self.rosterlist:setAnchorRight(true)
    self.rosterlist:setAnchorBottom(true)
    
    self.rosterlist.target = self
    self.rosterlist.onmousedown = self.onRosterClick
    self:addChild(self.rosterlist)
end

function DT_FactionInfoTab_Population:onRosterClick(data)
    if not data or not data.soul then return end
    
    self.selectedSoul = data.soul
    self.selectedUUID = data.uuid
    
    -- Update Header UI via component
    if self.profilePanel then
        self.profilePanel:setNPC(data.soul, data.uuid)
    end
end

function DT_FactionInfoTab_Population:onOpenDetails()
    -- Reserved for future use or expanded view
    if self.selectedSoul then
        print("[DT] Opening details for " .. tostring(self.selectedSoul.name))
    end
end

function DT_FactionInfoTab_Population:onResize()
    ISPanel.onResize(self)
    -- Anchors should handle resizing of subpanels
end

function DT_FactionInfoTab_Population:updateData(f, rosterData)
    self.rosterlist:clear()
    
    -- Reset selection
    if self.profilePanel then
        self.profilePanel:setNPC(nil)
    end

    if not f then return end

    -- [V1 SUPPORT]
    if f.isV1 then
        if DynamicTrading and DynamicTrading.Manager and DynamicTrading.Manager.GetData then
            local data = DynamicTrading.Manager.GetData()
            if data and data.Traders then
                -- Sort by name for consistency
                local sorted = {}
                for id, trader in pairs(data.Traders) do table.insert(sorted, trader) end
                table.sort(sorted, function(a, b) return a.name < b.name end)

                for _, trader in ipairs(sorted) do
                    local soul = {
                        name = trader.name,
                        archetypeID = trader.archetype,
                        portraitID = trader.portraitID,
                        status = "Active",
                        isFemale = (trader.gender == "Female")
                    }
                    local dataEntry = { soul = soul, uuid = trader.id }
                    self.rosterlist:addItem(trader.name, dataEntry)
                end
            end
        end
        return
    end
    
    -- [V2 SUPPORT]
    if rosterData then
        local members = rosterData.FactionMembers and rosterData.FactionMembers[f.id]
        if members and #members > 0 then
            for _, uuid in ipairs(members) do
                local soul = rosterData.Souls and rosterData.Souls[uuid]
                if soul then
                    local dataEntry = { soul = soul, uuid = uuid }
                    self.rosterlist:addItem(soul.name or uuid, dataEntry)
                end
            end
        end
    end
end

function DT_FactionInfoTab_Population:doDrawRosterItem(y, item, alt)
    local data = item.item
    if not data then -- Placeholder for empty
        self:drawText(item.text, 10, y + 5, 0.7, 0.7, 0.7, 1, UIFont.Medium)
        return y + self.itemheight
    end
    
    local soul = data.soul
    if not soul then return y end

    local isMouseOver = self:isMouseOver() and self:getMouseY() >= y and self:getMouseY() < y + self.itemheight

    if item.selected then
        self:drawRect(0, y, self.width, self.itemheight, 0.4, 0.4, 0.9, 0.6)
    elseif isMouseOver then
        self:drawRect(0, y, self.width, self.itemheight, 0.2, 0.3, 0.5, 0.4)
    elseif alt then
        self:drawRect(0, y, self.width, self.itemheight, 0.05, 1, 1, 1)
    end
    
    local status = soul.status or "Active"
    local r, g, b = 0.8, 0.8, 0.8
    if status == "Dead" then r,g,b = 0.6, 0.2, 0.2
    elseif status == "Away" then r,g,b = 0.4, 0.4, 0.9
    elseif status == "Trading" then r,g,b = 0.9, 0.8, 0.2
    end
    
    local font = UIFont.Medium
    if self.parent and self.parent.parent and self.parent.parent.fontScale then
        local scale = self.parent.parent.fontScale
        if scale == "Large" then font = UIFont.Large
        elseif scale == "Small" then font = UIFont.Small end
    end
    
    self:drawText(soul.name, 10, y + 5, r, g, b, 1, font)
    self:drawText(status, self.width - 120, y + 5, r*0.8, g*0.8, b*0.8, 1, font)

    return y + self.itemheight
end
