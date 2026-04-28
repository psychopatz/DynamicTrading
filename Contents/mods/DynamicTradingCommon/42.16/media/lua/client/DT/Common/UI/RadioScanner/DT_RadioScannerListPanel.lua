require "ISUI/ISPanel"
require "ISUI/ISScrollingListBox"
require "DT/Common/Faction/TradingSys/RosterLogic/DT_RosterLogic"
require "DT/Common/Faction/TradingSys/DynamicTrading_Factions"
require "DT/UI/Faction/FactionInfoWindow/DT_FactionInfoWindow"
require "DT/UI/Shared/DT_UIUtils"
pcall(require, "DO/UI/DO_MissionViewerWindow")

DT_RadioScannerListPanel = ISPanel:derive("DT_RadioScannerListPanel")

local function resolveScannerListItem(listbox, itemOrData)
    if type(itemOrData) == "table" then
        if type(itemOrData.item) == "table" then
            return itemOrData.item
        end
        if itemOrData.uuid or itemOrData.isLocationInfo then
            return itemOrData
        end
    end

    local selectedIndex = listbox and listbox.selected or -1
    if listbox and listbox.items and selectedIndex and selectedIndex >= 0 then
        local selectedItem = listbox.items[selectedIndex]
        if selectedItem and type(selectedItem.item) == "table" then
            return selectedItem.item
        end
    end

    return nil
end

function DT_RadioScannerListPanel:initialise()
    ISPanel.initialise(self)
    self.clip = true
end

function DT_RadioScannerListPanel:createChildren()
    ISPanel.createChildren(self)

    self.listContainer = ISPanel:new(0, 0, self.width, self.height)
    self.listContainer:initialise()
    self.listContainer:instantiate()
    self.listContainer.clip = true
    self.listContainer.backgroundColor = { r = 0, g = 0, b = 0, a = 0 }
    self.listContainer.borderColor = { r = 0, g = 0, b = 0, a = 0 }
    self:addChild(self.listContainer)

    function self.listContainer:prerender()
        if self.clip then
            self:setStencilRect(0, 0, self:getWidth(), self:getHeight())
        end
        ISPanel.prerender(self)
    end
    function self.listContainer:render()
        ISPanel.render(self)
        if self.clip then
            self:clearStencilRect()
        end
    end

    self.listbox = ISScrollingListBox:new(0, 0, self.listContainer.width, self.listContainer.height)
    self.listbox:initialise()
    self.listbox:instantiate()
    self.listbox.itemheight = 72
    self.listbox.doDrawItem = self.doDrawItem
    self.listbox.onmousedown = self.onListMouseDown
    self.listbox.onmousedblclick = self.onListDoubleClick
    self.listbox.target = self
    self.listbox.backgroundColor = { r = 0, g = 0, b = 0, a = 0 }
    self.listbox.drawBorder = false
    self.listbox:setAnchorRight(true)
    self.listbox:setAnchorBottom(true)
    self.listContainer:addChild(self.listbox)

    self.btnFaction = ISButton:new(0, 0, self.width, 30, "FACTION INTELLIGENCE", self, function(self)
        if DT_FactionInfoWindow then
            local device = (DT_RadioScannerWindow and DT_RadioScannerWindow.instance) and DT_RadioScannerWindow.instance.device or nil
            DT_FactionInfoWindow.Open(device)
        end
    end)
    self.btnFaction:initialise()
    self.btnFaction.backgroundColor = { r = 0, g = 0.2, b = 0.5, a = 1 }
    self.btnFaction.borderColor = { r = 0.4, g = 0.4, b = 1, a = 1 }
    self.btnFaction:setVisible(false)
    self:addChild(self.btnFaction)

    self.btnMissions = ISButton:new(0, 0, self.width, 30, "MISSIONS", self, function()
        if DO_MissionViewerWindow and DO_MissionViewerWindow.OnOpen then
            DO_MissionViewerWindow.OnOpen()
        end
    end)
    self.btnMissions:initialise()
    self.btnMissions.backgroundColor = { r = 0.16, g = 0.34, b = 0.2, a = 1 }
    self.btnMissions.borderColor = { r = 0.55, g = 0.85, b = 0.6, a = 1 }
    self.btnMissions:setVisible(false)
    self:addChild(self.btnMissions)
end

function DT_RadioScannerListPanel:setLayoutMode(mode)
    if mode == "Location" then
        self.layoutMode = "Location"
    elseif mode == "Quest" then
        self.layoutMode = "Quest"
    else
        self.layoutMode = "Standard"
    end
    local panelWidth = self:getWidth()
    local panelHeight = self:getHeight()
    local topButtonHeight = 35

    if mode == "Location" then
        self.btnFaction:setVisible(true)
        self.btnMissions:setVisible(false)
        self.listContainer:setX(0)
        self.listContainer:setY(topButtonHeight)
        self.listContainer:setWidth(panelWidth)
        self.listContainer:setHeight(panelHeight - topButtonHeight)
        self.listbox.itemheight = 84
    elseif mode == "Quest" then
        self.btnFaction:setVisible(false)
        self.btnMissions:setVisible(true)
        self.listContainer:setX(0)
        self.listContainer:setY(topButtonHeight)
        self.listContainer:setWidth(panelWidth)
        self.listContainer:setHeight(panelHeight - topButtonHeight)
        self.listbox.itemheight = 96
    else
        self.btnFaction:setVisible(false)
        self.btnMissions:setVisible(false)
        self.listContainer:setX(0)
        self.listContainer:setY(0)
        self.listContainer:setWidth(panelWidth)
        self.listContainer:setHeight(panelHeight)
        self.listbox.itemheight = 72
    end

    self.listbox:setX(0)
    self.listbox:setY(0)
    self.listbox:setWidth(self.listContainer:getWidth())
    self.listbox:setHeight(self.listContainer:getHeight())

    if self.listbox and self.listbox.vscroll then
        self.listbox.vscroll:setHeight(self.listbox:getHeight())
        self.listbox.vscroll:setX(self.listbox:getWidth() - 13)
    end
end

function DT_RadioScannerListPanel:onResize()
    ISPanel.onResize(self)

    local panelWidth = self:getWidth()

    if self.btnFaction then
        self.btnFaction:setWidth(panelWidth)
    end
    if self.btnMissions then
        self.btnMissions:setWidth(panelWidth)
    end

    if self.listbox then
        self.listbox:setWidth(panelWidth)
    end

    self:setLayoutMode(self.layoutMode or "Standard")
end

function DT_RadioScannerListPanel:drawPortrait(context, y, itemData)
    local tex = nil
    if DynamicTrading and DynamicTrading.Portraits then
        local seed = itemData.identitySeed or 1
        local mappedID = 1
        if DynamicTrading.Portraits.GetMappedID then
            mappedID = DynamicTrading.Portraits.GetMappedID(itemData.archetype, itemData.gender, seed)
        end

        local pathFolder = DynamicTrading.Portraits.GetPathFolder(itemData.archetype, itemData.gender)
        tex = getTexture(pathFolder .. tostring(mappedID) .. ".png")
    end

    if not tex then
        tex = getTexture("Item_WalkieTalkie1")
    end

    if tex then
        context:drawTextureScaled(tex, 10, y + 5, 55, 55, 1, 1, 1, 1)
    end
end

function DT_RadioScannerListPanel:doDrawItem(y, item, alt)
    local data = item.item
    if not data then
        return y
    end

    local target = self.target

    if data.isLocationInfo then
        local width = self:getWidth()
        if alt then
            self:drawRect(0, y, width, self.itemheight, 0.1, 0.2, 0.2, 0.2)
        end

        local titleColor = { r = 0.8, g = 0.8, b = 1.0 }
        self:drawText(data.label, 15, y + 10, titleColor.r, titleColor.g, titleColor.b, 1, UIFont.Medium)
        self:drawText(tostring(data.value), 15, y + 44, 0.7, 0.7, 0.7, 1, UIFont.Small)
        return y + self.itemheight
    end

    -- Selection / Background (Unified Utility)
    DT_UIUtils.drawSelectionHighlight(self, y, item, alt)

    target:drawPortrait(self, y, data)

    local contentX = 75
    local color = data.isLive and { r = 0.4, g = 1, b = 0.4 } or { r = 0.7, g = 0.7, b = 0.7 }
    local archName = (DynamicTrading and DynamicTrading.Archetypes and DynamicTrading.Archetypes[data.archetype])
        and DynamicTrading.Archetypes[data.archetype].name
        or data.archetype
    local isQuestRow = target and target.layoutMode == "Quest"
    local expireText = tostring(data.expireText or "")
    local rightReserve = isQuestRow and 150 or 130
    local textRight = math.max(contentX + 80, self.width - rightReserve)
    local laneWidth = math.max(80, textRight - contentX - 8)

    DT_UIUtils.drawMarqueeText(
        self,
        tostring(data.name) .. " [" .. tostring(archName) .. "]",
        contentX,
        y + 5,
        laneWidth,
        UIFont.Small,
        1,
        1,
        1,
        1,
        { speedMs = 38, gap = 56 }
    )

    if data.locked == true then
        self:drawTextRight("LOCKED", self.width - 12, y + 6, 1.0, 0.82, 0.35, 1, UIFont.Small)
    elseif expireText ~= "" then
        self:drawTextRight(expireText, self.width - 14, y + 6, 1.0, 1.0, 0.6, 1, UIFont.Small)
    end

    local fR, fG, fB = 1, 1, 1
    if data.faction == "Independent" then
        fR, fG, fB = 0.8, 0.8, 0.4
    else
        if data.archetype and string.find(data.archetype, "Soldier") then
            fR, fG, fB = 1, 0.4, 0.4
        elseif data.archetype and string.find(data.archetype, "Doctor") then
            fR, fG, fB = 0.4, 0.8, 1
        end
    end
    DT_UIUtils.drawMarqueeText(self, "Faction: " .. tostring(data.factionName), contentX, y + 25, laneWidth, UIFont.Small, fR, fG, fB, 1, { speedMs = 42, gap = 48 })

    local signalText = tostring(data.distText) .. (data.isLive and " [SIGNAL STRONG]" or " [SIGNAL WEAK]")
    if isQuestRow then
        local rewardText = tostring(data.rewardText or "")
        local detailText = tostring(data.detailText or "")
        if detailText ~= "" then
            DT_UIUtils.drawMarqueeText(self, detailText, contentX, y + 46, laneWidth, UIFont.Small, 1.0, 1.0, 0.6, 1, { speedMs = 35, gap = 60 })
        elseif rewardText ~= "" then
            DT_UIUtils.drawMarqueeText(self, "Reward: " .. rewardText, contentX, y + 46, laneWidth, UIFont.Small, 1.0, 1.0, 0.6, 1, { speedMs = 35, gap = 60 })
        end
        DT_UIUtils.drawMarqueeText(self, signalText, contentX, y + 68, laneWidth, UIFont.Small, color.r, color.g, color.b, 1, { speedMs = 42, gap = 48 })
    else
        DT_UIUtils.drawMarqueeText(self, signalText, contentX, y + 46, laneWidth, UIFont.Small, color.r, color.g, color.b, 1, { speedMs = 42, gap = 48 })
    end

    return y + self.itemheight
end

function DT_RadioScannerListPanel:onListMouseDown(itemData)
    if self.parent and self.parent.actionPanel then
        local resolved = resolveScannerListItem(self.listbox, itemData)
        if self.parent.actionPanel.updateSelectionState then
            self.parent.actionPanel:updateSelectionState(resolved)
        end
    end
end

function DT_RadioScannerListPanel:onListDoubleClick(itemData)
    if self.parent and self.parent.actionPanel then
        local resolved = resolveScannerListItem(self.listbox, itemData)
        if resolved and resolved.uuid then
            if self.parent.actionPanel.updateSelectionState then
                self.parent.actionPanel:updateSelectionState(resolved)
            end
            if self.parent.actionPanel.onLocate then
                self.parent.actionPanel:onLocate()
            end
        end
    end
end

function DT_RadioScannerListPanel:prerender()
    if self.clip then
        self:setStencilRect(0, 0, self:getWidth(), self:getHeight())
    end
    ISPanel.prerender(self)
end

function DT_RadioScannerListPanel:render()
    ISPanel.render(self)

    if self.listbox and #self.listbox.items == 0 then
        local category = self.parent and self.parent.currentCategory or "Discovered"
        if category ~= "Location" then
            local font = UIFont.Medium
            local smallFont = UIFont.Small
            local text1 = "NO ACTIVE SIGNALS"
            local text2 = "Traders may be resting or in transit."
            local text3 = "Please wait for a new broadcast window."
            local h1 = getTextManager():getFontHeight(font)
            local h2 = getTextManager():getFontHeight(smallFont)
            local totalH = h1 + (h2 * 2) + 10
            local y = (self.height / 2) - (totalH / 2)

            local tw1 = getTextManager():MeasureStringX(font, text1)
            self:drawText(text1, (self.width - tw1) / 2, y, 0.8, 0.8, 0.8, 0.8, font)

            local tw2 = getTextManager():MeasureStringX(smallFont, text2)
            self:drawText(text2, (self.width - tw2) / 2, y + h1 + 5, 0.6, 0.6, 0.6, 0.7, smallFont)

            local tw3 = getTextManager():MeasureStringX(smallFont, text3)
            self:drawText(text3, (self.width - tw3) / 2, y + h1 + h2 + 8, 0.5, 0.5, 0.5, 0.6, smallFont)
        end
    end

    if self.clip then
        self:clearStencilRect()
    end
end

function DT_RadioScannerListPanel:new(x, y, width, height)
    local o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.clip = true
    o.backgroundColor = { r = 0, g = 0, b = 0, a = 0.6 }
    o.borderColor = { r = 0.4, g = 0.4, b = 0.4, a = 0.5 }
    return o
end
