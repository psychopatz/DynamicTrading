-- ==============================================================================
-- DT_FactionInfoHeaderPanel.lua
-- Displays title and status info for the Faction Info Window.
-- ==============================================================================

require "ISUI/ISPanel"
require "ISUI/ISButton"

DT_FactionInfoHeaderPanel = ISPanel:derive("DT_FactionInfoHeaderPanel")

function DT_FactionInfoHeaderPanel:initialise()
    ISPanel.initialise(self)
end

function DT_FactionInfoHeaderPanel:createChildren()
    ISPanel.createChildren(self)

    -- Title
    self.labelTitle = ISLabel:new(self.width/2, 10, 25, "FACTION INTELLIGENCE", 1, 1, 1, 1, UIFont.Large, true)
    self.labelTitle:initialise()
    self:addChild(self.labelTitle)

    -- Subtitle / Status (Optional placeholder)
    self.lblStatus = ISLabel:new(self.width/2, 40, 18, "Global Faction Overview", 0.7, 0.7, 0.7, 1, UIFont.Medium, true)
    self.lblStatus:initialise()
    self:addChild(self.lblStatus)

    self.btnOwnedFaction = ISButton:new(self.width - 170, 10, 160, 24, "Open Labour", self, self.onOwnedFactionButton)
    self.btnOwnedFaction:initialise()
    self.btnOwnedFaction:instantiate()
    self:addChild(self.btnOwnedFaction)
end

function DT_FactionInfoHeaderPanel:onResizeFont(scale)
    if scale == "Large" then
        self.labelTitle.font = UIFont.ExtraLarge or UIFont.Large
        self.lblStatus.font = UIFont.Large
        self.lblStatus:setY(50)
    elseif scale == "Medium" then
        self.labelTitle.font = UIFont.Large
        self.lblStatus.font = UIFont.Medium
        self.lblStatus:setY(40)
    else
        self.labelTitle.font = UIFont.Medium
        self.lblStatus.font = UIFont.Small
        self.lblStatus:setY(35)
    end
end

function DT_FactionInfoHeaderPanel:updateOwnedFactionStatus(status, selectedFaction)
    self.ownedStatus = status or nil
    self.selectedFaction = selectedFaction or nil

    if self.selectedFaction and self.selectedFaction.playerOwned then
        local state = tostring(self.selectedFaction.leadershipState or "Active")
        self.lblStatus:setName("Leader: " .. tostring(self.selectedFaction.leaderUsername or "Unknown") .. " | Control: " .. state)
    elseif self.selectedFaction then
        self.lblStatus:setName("Viewing " .. tostring(self.selectedFaction.name or self.selectedFaction.id or "Faction"))
    elseif status and status.faction then
        self.lblStatus:setName("Your faction: " .. tostring(status.faction.name or status.faction.id) .. " | " .. tostring(status.faction.leadershipState or "Active"))
    elseif status and status.canCreate then
        self.lblStatus:setName("Eligible to create a player-owned faction")
    else
        self.lblStatus:setName("Global Faction Overview")
    end

    if self.btnOwnedFaction then
        if status and not status.faction and status.canCreate then
            self.btnOwnedFaction:setTitle("Create Faction")
            self.btnOwnedFaction:setEnable(true)
        else
            self.btnOwnedFaction:setTitle("Open Labour")
            self.btnOwnedFaction:setEnable(true)
        end
    end
end

function DT_FactionInfoHeaderPanel:onOwnedFactionButton()
    if self.ownedStatus and not self.ownedStatus.faction and self.ownedStatus.canCreate and DT_System and DT_System.PromptCreateFaction then
        DT_System.PromptCreateFaction()
        return
    end

    if DT_System and DT_System.OpenWindow then
        DT_System.OpenWindow()
    end
end

function DT_FactionInfoHeaderPanel:prerender()
    ISPanel.prerender(self)
    
    local function centerLabel(lbl, font)
        if not lbl then return end
        local text = lbl.name or ""
        local width = getTextManager():MeasureStringX(font, text)
        lbl:setX( (self.width / 2) - (width / 2) )
    end

    -- Keep labels centered
    centerLabel(self.labelTitle, self.labelTitle.font)
    centerLabel(self.lblStatus, self.lblStatus.font)
    if self.btnOwnedFaction then
        self.btnOwnedFaction:setX(self.width - self.btnOwnedFaction:getWidth() - 10)
    end
end

function DT_FactionInfoHeaderPanel:new(x, y, width, height)
    local o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.backgroundColor = {r=0, g=0, b=0, a=0} -- Transparent bg, window handles it
    return o
end
