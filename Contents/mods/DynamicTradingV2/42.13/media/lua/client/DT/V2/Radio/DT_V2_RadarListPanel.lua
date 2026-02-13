-- ==============================================================================
-- DT_V2_RadarListPanel.lua
-- Manages the scrolling list of traders and their portraits.
-- ==============================================================================

require "ISUI/ISPanel"
require "ISUI/ISScrollingListBox"
require "DT/V2/Faction/TradingSys/DynamicTrading_Roster"
require "DT/V2/Faction/TradingSys/DynamicTrading_Factions"
require "DT/V2/UI/Faction/DT_FactionInfoWindow"

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
    self.listbox.onmousedblclick = self.onListDoubleClick
    self.listbox.target = self
    self.listbox:setAnchorRight(true)
    self.listbox:setAnchorBottom(true)
    self:addChild(self.listbox)

    -- FACTION INTEL BUTTON (Hidden by default)
    self.btnFaction = ISButton:new(0, 0, self.width, 30, "FACTION INTELLIGENCE", self, function()
        if DT_FactionInfoWindow then DT_FactionInfoWindow.Open() end
    end)
    self.btnFaction:initialise()
    self.btnFaction.backgroundColor = {r=0, g=0.2, b=0.5, a=1}
    self.btnFaction.borderColor = {r=0.4, g=0.4, b=1, a=1}
    self.btnFaction:setVisible(false)
    self:addChild(self.btnFaction)
end

function DT_V2_RadarListPanel:setLayoutMode(mode)
    if mode == "Location" then
        self.btnFaction:setVisible(true)
        self.listbox:setY(35)
        self.listbox:setHeight(self.height - 35)
    else
        self.btnFaction:setVisible(false)
        self.listbox:setY(0)
        self.listbox:setHeight(self.height)
    end
end

function DT_V2_RadarListPanel:drawPortrait(ctx, y, itemData)
    local tex = nil
    if DynamicTrading and DynamicTrading.Portraits then
        local seed = itemData.portraitID or 1
        local mappedID = 1
        if DynamicTrading.Portraits.GetMappedID then
            mappedID = DynamicTrading.Portraits.GetMappedID(itemData.archetype, itemData.gender, seed)
        end
        
        local pathFolder = DynamicTrading.Portraits.GetPathFolder(itemData.archetype, itemData.gender)
        tex = getTexture(pathFolder .. tostring(mappedID) .. ".png")
    end
    
    if not tex then tex = getTexture("Item_WalkieTalkie1") end
    
    if tex then 
        ctx:drawTextureScaled(tex, 10, y + 5, 55, 55, 1, 1, 1, 1) 
    end
end

function DT_V2_RadarListPanel:doDrawItem(y, item, alt)
    local data = item.item
    if not data then return y end

    local target = self.target

    -- SPECIAL CASE: Location Info
    if data.isLocationInfo then
        if alt then
             self:drawRect(0, y, self.width, self.itemheight, 0.1, 0.2, 0.2, 0.2)
        end
        
        local titleColor = {r=0.8, g=0.8, b=1.0}
        self:drawText(data.label, 15, y + 10, titleColor.r, titleColor.g, titleColor.b, 1, UIFont.Medium)
        self:drawText(tostring(data.value), 15, y + 35, 0.7, 0.7, 0.7, 1, UIFont.Small)
        
        return y + self.itemheight
    end

    local isSelected = (item.selected == true)
    if not isSelected and self.selected ~= -1 then
        if self.items[self.selected] == item then
            isSelected = true
        end
    end

    if isSelected then
        self:drawRect(0, y, self.width, self.itemheight, 0.4, 0.05, 0.5, 0.05)
        self:drawRectBorder(0, y, self.width, self.itemheight, 1.0, 0.1, 0.8, 0.1)
    elseif alt then
        self:drawRect(0, y, self.width, self.itemheight, 0.1, 1, 1, 1)
    else
        self:drawRect(0, y, self.width, self.itemheight, 0.1, 0, 0, 0)
    end

    target:drawPortrait(self, y, data)

    local contentX = 75
    local color = data.isLive and {r=0.4, g=1, b=0.4} or {r=0.7, g=0.7, b=0.7}
    
    local archName = (DynamicTrading and DynamicTrading.Archetypes and DynamicTrading.Archetypes[data.archetype]) and DynamicTrading.Archetypes[data.archetype].name or data.archetype
    self:drawText(tostring(data.name) .. " [" .. tostring(archName) .. "]", contentX, y + 5, 1, 1, 1, 1, UIFont.Small)
    
    local fR, fG, fB = 1, 1, 1
    if data.faction == "Independent" then
        fR, fG, fB = 0.8, 0.8, 0.4 
    else
        if data.archetype and string.find(data.archetype, "Soldier") then fR, fG, fB = 1, 0.4, 0.4
        elseif data.archetype and string.find(data.archetype, "Doctor") then fR, fG, fB = 0.4, 0.8, 1
        end
    end
    self:drawText("Faction: " .. tostring(data.factionName), contentX, y + 25, fR, fG, fB, 1, UIFont.Small)

    self:drawText(tostring(data.distText) .. (data.isLive and " [SIGNAL STRONG]" or " [SIGNAL WEAK]"), contentX, y + 45, color.r, color.g, color.b, 1, UIFont.Small)

    if data.expireText and data.expireText ~= "" then
        local expR, expG, expB = 1.0, 1.0, 0.6 
        self:drawTextRight(data.expireText, self.width - 65, y + 45, expR, expG, expB, 1, UIFont.Small)
    end

    return y + self.itemheight
end

function DT_V2_RadarListPanel:onListMouseDown(itemData)
    -- 'self' is the DT_V2_RadarListPanel here
    if self.parent and self.parent.actionPanel then
        if itemData and itemData.uuid then
            self.parent.actionPanel.btnLocate.enable = true
            -- [NEW] Update Button Label ("LOCATE" or "STOP")
            self.parent.actionPanel:updateButtonState(itemData.uuid)
        else
            self.parent.actionPanel.btnLocate.enable = false
        end
    end
end

function DT_V2_RadarListPanel:onListDoubleClick(itemData)
    if self.parent and self.parent.actionPanel then
        if itemData and itemData.uuid then
            self.parent.actionPanel.btnLocate.enable = true
            if self.parent.actionPanel.onLocate then
                self.parent.actionPanel:onLocate()
            end
        end
    end
end

function DT_V2_RadarListPanel:new(x, y, width, height)
    local o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.backgroundColor = {r=0, g=0, b=0, a=0}
    return o
end
