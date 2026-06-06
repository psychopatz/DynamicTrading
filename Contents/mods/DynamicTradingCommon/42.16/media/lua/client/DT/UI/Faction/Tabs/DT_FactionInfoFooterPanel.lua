require "ISUI/ISPanel"
require "ISUI/ISButton"

DT_FactionInfoFooterPanel = ISPanel:derive("DT_FactionInfoFooterPanel")

local function T(key, params, fallback)
    if DynamicTrading and DynamicTrading.Text and DynamicTrading.Text.Get then
        return DynamicTrading.Text.Get(key, params, fallback)
    end
    return fallback or tostring(key or "")
end

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
    if self.btnRenameFaction and self.btnRenameFaction:getIsVisible() then
        self.btnRenameFaction:setX(self.btnOwnedFaction:getX() - self.btnRenameFaction:getWidth() - 10)
    end
end

function DT_FactionInfoFooterPanel:createChildren()
    ISPanel.createChildren(self)

    local btnWidth = 160
    local btnHeight = 24
    
    -- 1. Trader Radar Button
    self.btnRadar = ISButton:new(10, 10, btnWidth, btnHeight, T("DTCommon_UI_Faction_TraderRadar", nil, "Trader Radar"), self, self.onRadarButton)
    self.btnRadar:initialise()
    self.btnRadar:instantiate()
    self.btnRadar:setAnchorLeft(true)
    self.btnRadar:setAnchorRight(false)
    self.btnRadar:setAnchorTop(false)
    self.btnRadar:setAnchorBottom(true)
    self:addChild(self.btnRadar)

    -- 2. Colony Members Button
    self.btnFactionMembers = ISButton:new(10 + btnWidth + 10, 10, btnWidth, btnHeight, T("DTCommon_UI_Faction_ColonyMembers", nil, "Colony Members"), self, self.onFactionMembersButton)
    self.btnFactionMembers:initialise()
    self.btnFactionMembers:instantiate()
    self.btnFactionMembers:setAnchorLeft(true)
    self.btnFactionMembers:setAnchorRight(false)
    self.btnFactionMembers:setAnchorTop(false)
    self.btnFactionMembers:setAnchorBottom(true)
    self:addChild(self.btnFactionMembers)

    -- 3. Colony Management Button (Right aligned)
    self.btnOwnedFaction = ISButton:new(self.width - btnWidth - 10, 10, btnWidth, btnHeight, T("DTCommon_UI_Faction_OpenManagement", nil, "Open Colony Management"), self, self.onOwnedFactionButton)
    self.btnOwnedFaction:initialise()
    self.btnOwnedFaction:instantiate()
    self.btnOwnedFaction:setAnchorLeft(false)
    self.btnOwnedFaction:setAnchorRight(true)
    self.btnOwnedFaction:setAnchorTop(false)
    self.btnOwnedFaction:setAnchorBottom(true)
    self:addChild(self.btnOwnedFaction)

    self.btnRenameFaction = ISButton:new(self.width - (btnWidth * 2) - 20, 10, btnWidth, btnHeight, T("DTCommon_UI_Faction_RenameFaction", nil, "Rename Faction"), self, self.onRenameFactionButton)
    self.btnRenameFaction:initialise()
    self.btnRenameFaction:instantiate()
    self.btnRenameFaction:setAnchorLeft(false)
    self.btnRenameFaction:setAnchorRight(true)
    self.btnRenameFaction:setAnchorTop(false)
    self.btnRenameFaction:setAnchorBottom(true)
    self.btnRenameFaction:setVisible(false)
    self:addChild(self.btnRenameFaction)

    -- Hide management if Dynamic Colonies is missing
    if not isDynamicColoniesActive() then
        self.btnOwnedFaction:setVisible(false)
        self.btnRenameFaction:setVisible(false)
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
            if self.btnRenameFaction then
                self.btnRenameFaction:setVisible(false)
            end
        elseif status and not status.faction and (status.canCreate or status.createBlockedReason == "syncing") then
            self.btnOwnedFaction:setTitle(T("DTCommon_UI_Faction_ClaimSyncing", nil, "Claim Syncing"))
            self.btnOwnedFaction:setEnable(true)
            self.btnOwnedFaction:setVisible(true)
            if self.btnRenameFaction then
                self.btnRenameFaction:setVisible(false)
            end
        else
            self.btnOwnedFaction:setTitle(status and status.needsNamingPrompt == true and T("DTCommon_UI_Faction_FinalizeFaction", nil, "Finalize Faction") or T("DTCommon_UI_Faction_OpenManagement", nil, "Open Colony Management"))
            self.btnOwnedFaction:setEnable(true)
            self.btnOwnedFaction:setVisible(true)
            if self.btnRenameFaction then
                local canRename = status and status.faction and status.permissions and status.permissions.canRenameFaction == true
                self.btnRenameFaction:setVisible(canRename == true)
                self.btnRenameFaction:setEnable(canRename == true)
            end
        end
    end

    if self.btnFactionMembers then
        local pendingCount = status and status.pendingInvites and #status.pendingInvites or 0
        local hasFaction = status and status.faction ~= nil
        if not isDynamicColoniesActive() then
            self.btnFactionMembers:setVisible(false)
        elseif hasFaction or pendingCount > 0 then
            self.btnFactionMembers:setTitle(pendingCount > 0 and not hasFaction and T("DTCommon_UI_Faction_Invites", nil, "Faction Invites") or T("DTCommon_UI_Faction_ColonyMembers", nil, "Colony Members"))
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

function DT_FactionInfoFooterPanel:onRenameFactionButton()
    if self.parent and self.parent.onRenameFactionButton then
        self.parent:onRenameFactionButton(self.ownedStatus)
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
