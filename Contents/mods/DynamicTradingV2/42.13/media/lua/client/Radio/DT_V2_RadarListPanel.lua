-- ==============================================================================
-- DT_V2_RadarListPanel.lua
-- Manages the scrolling list of traders and their portraits.
-- ==============================================================================

require "ISUI/ISPanel"
require "ISUI/ISScrollingListBox"
require "Faction/TradingSys/DynamicTrading_Roster"
require "Faction/TradingSys/DynamicTrading_Factions"

DT_V2_RadarListPanel = ISPanel:derive("DT_V2_RadarListPanel")

function DT_V2_RadarListPanel:initialise()
    ISPanel.initialise(self)
end

function DT_V2_RadarListPanel:createChildren()
    ISPanel.createChildren(self)

    self.listbox = ISScrollingListBox:new(0, 0, self.width, self.height)
    self.listbox:initialise()
    self.listbox:instantiate()
    self.listbox.itemheight = 65
    self.listbox.doDrawItem = self.doDrawItem
    self.listbox.onmousedown = self.onListMouseDown
    self.listbox.target = self
    self.listbox:setAnchorRight(true)
    self.listbox:setAnchorBottom(true)
    self:addChild(self.listbox)
end

function DT_V2_RadarListPanel:drawPortrait(ctx, y, itemData)
    local tex = nil
    if DynamicTrading and DynamicTrading.Portraits then
        local pathFolder = DynamicTrading.Portraits.GetPathFolder(itemData.archetype, itemData.gender)
        tex = getTexture(pathFolder .. tostring(itemData.portraitID) .. ".png")
    end
    
    if not tex then tex = getTexture("Item_WalkieTalkie1") end
    
    if tex then 
        ctx:drawTextureScaled(tex, 10, y + 5, 55, 55, 1, 1, 1, 1) 
    end
end

function DT_V2_RadarListPanel:doDrawItem(y, item, alt)
    local data = item.item
    if not data then return y end

    -- 'self' is the listbox here
    local target = self.target

    -- Use a more robust check for selection
    local isSelected = (item.selected == true)
    if not isSelected and self.selected ~= -1 then
        if self.items[self.selected] == item then
            isSelected = true
        end
    end

    if isSelected then
        -- Stronger selection highlight (Premium Green)
        self:drawRect(0, y, self.width, self.itemheight, 0.4, 0.05, 0.5, 0.05)
        self:drawRectBorder(0, y, self.width, self.itemheight, 1.0, 0.1, 0.8, 0.1)
    elseif alt then
        self:drawRect(0, y, self.width, self.itemheight, 0.1, 1, 1, 1)
    else
        self:drawRect(0, y, self.width, self.itemheight, 0.1, 0, 0, 0)
    end

    -- 1. Draw Portrait
    target:drawPortrait(self, y, data)

    -- 2. Draw Text Info
    local contentX = 75
    local color = data.isLive and {r=0.4, g=1, b=0.4} or {r=0.7, g=0.7, b=0.7}
    
    local archName = (DynamicTrading and DynamicTrading.Archetypes and DynamicTrading.Archetypes[data.archetype]) and DynamicTrading.Archetypes[data.archetype].name or data.archetype
    self:drawText(tostring(data.name) .. " [" .. tostring(archName) .. "]", contentX, y + 5, 1, 1, 1, 1, UIFont.Small)
    
    -- Faction Info (Color Coded)
    local fR, fG, fB = 1, 1, 1
    if data.faction == "Independent" then
        fR, fG, fB = 0.8, 0.8, 0.4 
    else
        if data.archetype and string.find(data.archetype, "Soldier") then fR, fG, fB = 1, 0.4, 0.4
        elseif data.archetype and string.find(data.archetype, "Doctor") then fR, fG, fB = 0.4, 0.8, 1
        end
    end
    self:drawText("Faction: " .. tostring(data.factionName), contentX, y + 25, fR, fG, fB, 1, UIFont.Small)

    -- Distance & Signal
    self:drawText(tostring(data.distText) .. (data.isLive and " [SIGNAL STRONG]" or " [SIGNAL WEAK]"), contentX, y + 45, color.r, color.g, color.b, 1, UIFont.Small)

    -- Expiration (Right Aligned - Bottom line to avoid name overlap)
    -- Moved to width - 65 to safely avoid Scrollbar overlay
    if data.expireText and data.expireText ~= "" then
        -- Yellowish color for visibility
        local expR, expG, expB = 1.0, 1.0, 0.6 
        self:drawTextRight(data.expireText, self.width - 65, y + 45, expR, expG, expB, 1, UIFont.Small)
    end

    return y + self.itemheight
end

function DT_V2_RadarListPanel:onListMouseDown(itemData)
    -- 'self' is the DT_V2_RadarListPanel panel here (set by listbox.target)
    if self.parent and self.parent.actionPanel then
        self.parent.actionPanel.btnLocate.enable = true
    end
end

function DT_V2_RadarListPanel:new(x, y, width, height)
    local o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.backgroundColor = {r=0, g=0, b=0, a=0}
    return o
end
