require "ISUI/ISPanel"
require "ISUI/ISButton"

DT_FactionInfoFooterPanel = ISPanel:derive("DT_FactionInfoFooterPanel")

local function isDynamicColoniesActive()
    local activated = getActivatedMods and getActivatedMods() or nil
    return activated and activated.contains and activated:contains("DynamicColonies") or false
end

function DT_FactionInfoFooterPanel:initialise()
    ISPanel.initialise(self)
end

function DT_FactionInfoFooterPanel:prerender()
    ISPanel.prerender(self)
    
    -- Ensure buttons stay correctly positioned relative to their edges during window scaling
    if self.btnRadar then
        self.btnRadar:setX(10)
    end
    if self.btnFactionMembers then
        self.btnFactionMembers:setX(10 + self.btnRadar:getWidth() + 10)
    end
    if self.btnOwnedFaction then
        self.btnOwnedFaction:setX(self.width - self.btnOwnedFaction:getWidth() - 10)
    end
end

function DT_FactionInfoFooterPanel:createChildren()
    ISPanel.createChildren(self)

    local btnWidth = 160
    local btnHeight = 24
    
    -- 1. Trader Radar Button
    self.btnRadar = ISButton:new(10, 10, btnWidth, btnHeight, "Trader Radar", self, self.onRadarButton)
    self.btnRadar:initialise()
    self.btnRadar:instantiate()
    self.btnRadar:setAnchorLeft(true)
    self.btnRadar:setAnchorRight(false)
    self.btnRadar:setAnchorTop(false)
    self.btnRadar:setAnchorBottom(true)
    self:addChild(self.btnRadar)

    -- 2. Colony Members Button
    self.btnFactionMembers = ISButton:new(10 + btnWidth + 10, 10, btnWidth, btnHeight, "Colony Members", self, self.onFactionMembersButton)
    self.btnFactionMembers:initialise()
    self.btnFactionMembers:instantiate()
    self.btnFactionMembers:setAnchorLeft(true)
    self.btnFactionMembers:setAnchorRight(false)
    self.btnFactionMembers:setAnchorTop(false)
    self.btnFactionMembers:setAnchorBottom(true)
    self:addChild(self.btnFactionMembers)

    -- 3. Colony Management Button (Right aligned)
    self.btnOwnedFaction = ISButton:new(self.width - btnWidth - 10, 10, btnWidth, btnHeight, "Open Colony Management", self, self.onOwnedFactionButton)
    self.btnOwnedFaction:initialise()
    self.btnOwnedFaction:instantiate()
    self.btnOwnedFaction:setAnchorLeft(false)
    self.btnOwnedFaction:setAnchorRight(true)
    self.btnOwnedFaction:setAnchorTop(false)
    self.btnOwnedFaction:setAnchorBottom(true)
    self:addChild(self.btnOwnedFaction)

    -- Hide management if Dynamic Colonies is missing
    if not isDynamicColoniesActive() then
        self.btnOwnedFaction:setVisible(false)
    end
end

function DT_FactionInfoFooterPanel:updateOwnedFactionStatus(status)
    self.ownedStatus = status or nil

    if self.btnRadar then
        self.btnRadar:setVisible(true)
    end

    if self.btnOwnedFaction then
        if not isDynamicColoniesActive() then
            self.btnOwnedFaction:setVisible(false)
        elseif status and not status.faction and status.canCreate then
            self.btnOwnedFaction:setTitle("Create Faction")
            self.btnOwnedFaction:setEnable(true)
            self.btnOwnedFaction:setVisible(true)
        else
            self.btnOwnedFaction:setTitle("Open Colony Management")
            self.btnOwnedFaction:setEnable(true)
            self.btnOwnedFaction:setVisible(true)
        end
    end

    if self.btnFactionMembers then
        local pendingCount = status and status.pendingInvites and #status.pendingInvites or 0
        local hasFaction = status and status.faction ~= nil
        if not isDynamicColoniesActive() then
            self.btnFactionMembers:setVisible(false)
        elseif hasFaction or pendingCount > 0 then
            self.btnFactionMembers:setTitle(pendingCount > 0 and not hasFaction and "Faction Invites" or "Colony Members")
            self.btnFactionMembers:setEnable(true)
            self.btnFactionMembers:setVisible(true)
        else
            self.btnFactionMembers:setVisible(false)
        end
    end
end

function DT_FactionInfoFooterPanel:onRadarButton()
    if self.parent and self.parent.onRadarButton then
        self.parent:onRadarButton()
    end
end

function DT_FactionInfoFooterPanel:onFactionMembersButton()
    if self.parent and self.parent.onFactionMembersButton then
        self.parent:onFactionMembersButton(self.ownedStatus)
    end
end

function DT_FactionInfoFooterPanel:onOwnedFactionButton()
    if self.parent and self.parent.onOwnedFactionButton then
        self.parent:onOwnedFactionButton(self.ownedStatus)
    end
end

function DT_FactionInfoFooterPanel:new(x, y, width, height)
    local o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.backgroundColor = { r = 0, g = 0, b = 0, a = 0 }
    o.borderColor = { r = 0, g = 0, b = 0, a = 0 }
    return o
end
