-- ==============================================================================
-- DT_FactionInfoHeaderPanel.lua
-- Displays title and status info for the Faction Info Window.
-- ==============================================================================

require "ISUI/ISPanel"
require "ISUI/ISButton"

DT_FactionInfoHeaderPanel = ISPanel:derive("DT_FactionInfoHeaderPanel")

local function isDynamicColoniesActive()
    local activated = getActivatedMods and getActivatedMods() or nil
    return activated and activated.contains and activated:contains("DynamicColonies") or false
end

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

    -- Settings Button (top-right for symmetry with Radar)
    local btnSize = 18
    self.btnOptions = ISButton:new(self.width - btnSize - 10, 10, btnSize, btnSize, "", self, function()
        if DT_RadioScannerOptionsManager then
            DT_RadioScannerOptionsManager.ToggleWindow()
        end
    end)
    self.btnOptions:initialise()
    self.btnOptions.borderColor = { r = 1, g = 1, b = 1, a = 0.2 }
    self.btnOptions.backgroundColor = { r = 0, g = 0, b = 0, a = 0 }
    self.btnOptions:setImage(getTexture("media/ui/inventoryPanes/Button_Settings.png"))
    self:addChild(self.btnOptions)
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
        if status.needsNamingPrompt == true then
            self.lblStatus:setName("Your colony is claimed as " .. tostring(status.faction.name or status.faction.id) .. ". Rename it to finalize the faction name.")
        else
            self.lblStatus:setName("Your faction: " .. tostring(status.faction.name or status.faction.id) .. " | " .. tostring(status.faction.leadershipState or "Active"))
        end
    elseif status and status.canCreate then
        self.lblStatus:setName("Headquarters ready. Colony claim is syncing.")
    elseif status and status.createBlockedReason == "headquarters_required" then
        self.lblStatus:setName("Finish your headquarters before founding a faction")
    else
        self.lblStatus:setName("Global Faction Overview")
    end
end

-- Logic moved to Footer/Window level

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
    if self.btnOptions then
        self.btnOptions:setX(self.width - self.btnOptions:getWidth() - 10)
    end
end

function DT_FactionInfoHeaderPanel:onRadarButton()
    if DT_RadioScannerWindow and DT_RadioScannerWindow.ToggleWindow then
        DT_RadioScannerWindow.ToggleWindow(self.parent.device)
    end
end

function DT_FactionInfoHeaderPanel:new(x, y, width, height)
    local o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.backgroundColor = {r=0, g=0, b=0, a=0} -- Transparent bg, window handles it
    return o
end
