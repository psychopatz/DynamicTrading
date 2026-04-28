-- ==============================================================================
-- media/lua/client/DT/UI/Faction/DT_NPCProfilePanel.lua
-- Dedicated panel for displaying selected NPC identity/profile.
-- ==============================================================================

require "ISUI/ISPanel"
require "DT/UI/Shared/DT_UIUtils"

DT_NPCProfilePanel = ISPanel:derive("DT_NPCProfilePanel")

function DT_NPCProfilePanel:new(x, y, width, height)
    local o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.backgroundColor = {r=0, g=0, b=0, a=0.5}
    o.borderColor = {r=1, g=1, b=1, a=0.1}
    return o
end

function DT_NPCProfilePanel:initialise()
    ISPanel.initialise(self)
end

function DT_NPCProfilePanel:createChildren()
    -- We will handle rendering manually in prerender for better control and visibility logic
end

function DT_NPCProfilePanel:setNPC(soul, uuid)
    self.soul = soul
    self.uuid = uuid
    
    if not soul then
        self.portraitTex = nil
        return
    end
    
    -- Archetype Lookup
    local archID = soul.archetypeID or "General"
    self.archName = archID
    if DynamicTrading and DynamicTrading.Archetypes and DynamicTrading.Archetypes[archID] then
        self.archName = DynamicTrading.Archetypes[archID].name or archID
    end
    
    -- ID Truncation
    self.displayID = uuid or "N/A"
    if #self.displayID > 24 then
        self.displayID = string.sub(self.displayID, 1, 12) .. "..." .. string.sub(self.displayID, -8)
    end
    
    -- Portrait Logic
    self.portraitTex = nil
    if DynamicTrading and DynamicTrading.Portraits then
        local seed = soul.identitySeed or 1
        local gender = soul.isFemale and "Female" or "Male"
        local mappedID = DynamicTrading.Portraits.GetMappedID(archID, gender, seed)
        local pathFolder = DynamicTrading.Portraits.GetPathFolder(archID, gender)
        self.portraitTex = getTexture(pathFolder .. tostring(mappedID) .. ".png")
    end
    if not self.portraitTex then self.portraitTex = getTexture("Item_WalkieTalkie1") end
end

function DT_NPCProfilePanel:prerender()
    ISPanel.prerender(self)
    
    -- Draw placeholder if nothing selected
    if not self.soul then
        local text = "<< SELECT AN INDIVIDUAL TO VIEW PROFILE >>"
        self:drawTextCentre(text, self.width/2, self.height/2 - 10, 0.5, 0.5, 0.5, 0.6, UIFont.Medium)
        return
    end

    local padding = 15
    local portraitSize = 100
    local textX = padding + portraitSize + 25
    local currY = 20

    -- Draw Portrait
    if self.portraitTex then
        self:drawTextureScaled(self.portraitTex, padding, padding, portraitSize, portraitSize, 1, 1, 1, 1)
        self:drawRectBorder(padding, padding, portraitSize, portraitSize, 1, 1, 1, 0.2)
    end

    -- Draw Info
    self:drawText("NPC PROFILE", textX, currY, 1, 0.8, 0, 1, UIFont.Large)
    currY = currY + 30
    
    local nameColor = DT_UIUtils.GetTraderReputationColor
        and DT_UIUtils.GetTraderReputationColor(self.uuid, self.soul and self.soul.factionID, { alpha = 1 })
        or { r = 0.9, g = 0.9, b = 0.9, a = 1 }
    self:drawText("Name:", textX, currY, 0.75, 0.75, 0.75, 1, UIFont.Medium)
    self:drawText(self.soul.name or "Unknown", textX + 52, currY, nameColor.r, nameColor.g, nameColor.b, nameColor.a or 1, UIFont.Medium)
    currY = currY + 25

    self:drawText("Archetype: " .. (self.archName or "Unknown"), textX, currY, 0.9, 0.9, 0.9, 1, UIFont.Medium)
    
    -- Draw ID at bottom right
    if self.displayID then
        local idW = getTextManager():MeasureStringX(UIFont.Small, "ID: " .. self.displayID)
        self:drawText("ID: " .. self.displayID, self.width - idW - 10, self.height - 25, 0.5, 0.5, 0.5, 0.8, UIFont.Small)
    end
end
