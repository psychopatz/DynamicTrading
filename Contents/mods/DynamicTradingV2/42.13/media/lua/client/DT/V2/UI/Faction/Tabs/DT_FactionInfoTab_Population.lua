-- ==============================================================================
-- media/lua/client/DT/V2/UI/Faction/Tabs/DT_FactionInfoTab_Population.lua
-- Tab: Population & Roster
-- ==============================================================================

require "ISUI/ISPanel"
require "ISUI/ISScrollingListBox"

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
    self:createChildren()
end

function DT_FactionInfoTab_Population:createChildren()
    self.rosterlist = ISScrollingListBox:new(0, 0, self.width, self.height)
    self.rosterlist:initialise()
    self.rosterlist:instantiate()
    self.rosterlist.itemheight = 30 
    self.rosterlist.doDrawItem = DT_FactionInfoTab_Population.doDrawRosterItem
    self.rosterlist.backgroundColor = {r=0.1, g=0.1, b=0.1, a=0.5}
    self.rosterlist.drawBorder = true
    self:addChild(self.rosterlist)
end

function DT_FactionInfoTab_Population:updateData(f, rosterData)
    self.rosterlist:clear()
    
    if not f then return end
    
    -- Ensure rosterData is available (passed from parent)
    if rosterData then
        local members = rosterData.FactionMembers and rosterData.FactionMembers[f.id]
        if members and #members > 0 then
            for _, uuid in ipairs(members) do
                local soul = rosterData.Souls and rosterData.Souls[uuid]
                if soul then
                    local data = { soul = soul, uuid = uuid }
                    self.rosterlist:addItem(soul.name or uuid, data)
                end
            end
        else
            self.rosterlist:addItem("No Members", nil)
        end
    else
         self.rosterlist:addItem("Data Unavailable", nil)
    end
end

function DT_FactionInfoTab_Population:doDrawRosterItem(y, item, alt)
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
