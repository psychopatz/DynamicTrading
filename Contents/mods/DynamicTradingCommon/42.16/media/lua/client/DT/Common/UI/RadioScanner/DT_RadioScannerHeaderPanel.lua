require "ISUI/ISPanel"

DT_RadioScannerHeaderPanel = ISPanel:derive("DT_RadioScannerHeaderPanel")

function DT_RadioScannerHeaderPanel:shouldShowQuestTab()
    return DynamicObjectives
        and DynamicObjectives.UI
        and DynamicObjectives.UI.ShowScannerQuestTab == true
end

function DT_RadioScannerHeaderPanel:ensureQuestButton(showQuestTab)
    if showQuestTab and not self.btnQuest then
        local tabHeight = 20
        local tabY = self.height - tabHeight
        self.btnQuest = ISButton:new(0, tabY, 0, tabHeight, "Quest", self, function(panel)
            panel:onCategoryClick("Quest")
        end)
        self.btnQuest:initialise()
        self.btnQuest.borderColor = { r = 0.4, g = 0.4, b = 0.4, a = 1 }
        self.btnQuest:setAnchorTop(false)
        self.btnQuest:setAnchorBottom(true)
        self:addChild(self.btnQuest)
        return
    end

    if not showQuestTab and self.btnQuest then
        self:removeChild(self.btnQuest)
        self.btnQuest = nil
        if self.parent and self.parent.currentCategory == "Quest" and self.parent.setCategory then
            self.parent:setCategory("Discovered")
        end
    end
end

function DT_RadioScannerHeaderPanel:initialise()
    ISPanel.initialise(self)
end

function DT_RadioScannerHeaderPanel:createChildren()
    ISPanel.createChildren(self)

    self.lblDeviceName = ISLabel:new(self.width / 2, 8, 18, "Device: Unknown", 1, 1, 1, 1, UIFont.Medium, true)
    self.lblDeviceName:initialise()
    self:addChild(self.lblDeviceName)

    local btnSize = 18
    self.btnOptions = ISButton:new(self.width - btnSize - 5, 5, btnSize, btnSize, "", self, function()
        if DT_RadioScannerOptionsManager then
            DT_RadioScannerOptionsManager.ToggleWindow()
        end
    end)
    self.btnOptions:initialise()
    self.btnOptions.borderColor = { r = 1, g = 1, b = 1, a = 0.2 }
    self.btnOptions.backgroundColor = { r = 0, g = 0, b = 0, a = 0 }
    self.btnOptions:setImage(getTexture("media/ui/inventoryPanes/Button_Settings.png"))
    self:addChild(self.btnOptions)

    self.btnHelp = ISButton:new(self.width - (btnSize * 2) - 10, 5, btnSize, btnSize, "", self, function()
        if DynamicTrading and DynamicTrading.Manuals and DynamicTrading.Manuals.Open then
            DynamicTrading.Manuals.Open({ library = true })
        end
    end)
    self.btnHelp:initialise()
    self.btnHelp.borderColor = { r = 1, g = 1, b = 1, a = 0.2 }
    self.btnHelp.backgroundColor = { r = 0, g = 0, b = 0, a = 0 }
    self.btnHelp:setImage(getTexture("media/ui/Entity/BTN_Missing_Icon_48x48.png"))
    self.btnHelp.displayBackground = false
    self:addChild(self.btnHelp)

    self.lblRangeInfo = ISLabel:new(self.width / 2, 29, 18, "Broadcast Range: Unknown", 0.7, 0.7, 0.7, 1, UIFont.Small, true)
    self.lblRangeInfo:initialise()
    self:addChild(self.lblRangeInfo)

    self.scanStatsPanel = DT_RadioScannerScanStatsPanel:new(10, 46, math.max(120, self.width - 20), 38)
    self.scanStatsPanel:initialise()
    self.scanStatsPanel:instantiate()
    self.scanStatsPanel:setAnchorLeft(true)
    self.scanStatsPanel:setAnchorRight(true)
    self:addChild(self.scanStatsPanel)

    local tabHeight = 20
    local tabY = self.height - tabHeight
    local showQuestTab = self:shouldShowQuestTab()
    local tabCount = showQuestTab and 4 or 3
    local tabWidth = self.width / tabCount

    self.btnStat = ISButton:new(0, tabY, tabWidth, tabHeight, "Discovered Broadcast", self, function(panel)
        panel:onCategoryClick("Discovered")
    end)
    self.btnStat:initialise()
    self.btnStat.borderColor = { r = 0.4, g = 0.4, b = 0.4, a = 1 }
    self.btnStat:setAnchorTop(false)
    self.btnStat:setAnchorBottom(true)
    self:addChild(self.btnStat)

    self.btnCall = ISButton:new(tabWidth, tabY, tabWidth, tabHeight, "Linked Broadcast", self, function(panel)
        panel:onCategoryClick("Linked")
    end)
    self.btnCall:initialise()
    self.btnCall.borderColor = { r = 0.4, g = 0.4, b = 0.4, a = 1 }
    self.btnCall:setAnchorTop(false)
    self.btnCall:setAnchorBottom(true)
    self:addChild(self.btnCall)

    self:ensureQuestButton(showQuestTab)

    local infoIndex = showQuestTab and 3 or 2
    self.btnInfo = ISButton:new(tabWidth * infoIndex, tabY, tabWidth, tabHeight, "Info", self, function(panel)
        panel:onCategoryClick("Location")
    end)
    self.btnInfo:initialise()
    self.btnInfo.borderColor = { r = 0.4, g = 0.4, b = 0.4, a = 1 }
    self.btnInfo:setAnchorTop(false)
    self.btnInfo:setAnchorBottom(true)
    self:addChild(self.btnInfo)
end

function DT_RadioScannerHeaderPanel:updateScanStats(stats)
    if self.scanStatsPanel and self.scanStatsPanel.setStats then
        self.scanStatsPanel:setStats(stats)
    end
end

function DT_RadioScannerHeaderPanel:onCategoryClick(category)
    if self.parent and self.parent.setCategory then
        self.parent:setCategory(category)
    end
end

function DT_RadioScannerHeaderPanel:prerender()
    ISPanel.prerender(self)

    local function centerLabel(label, font)
        if not label then
            return
        end

        local text = label.name or ""
        local width = getTextManager():MeasureStringX(font, text)
        label:setX((self.width / 2) - (width / 2))
    end

    centerLabel(self.lblDeviceName, UIFont.Medium)
    centerLabel(self.lblRangeInfo, UIFont.Small)

    local showQuestTab = self:shouldShowQuestTab()
    self:ensureQuestButton(showQuestTab)
    local tabCount = showQuestTab and 4 or 3
    local tabWidth = self.width / tabCount
    local tabHeight = 20
    local tabY = self.height - tabHeight
    if self.btnStat then
        self.btnStat:setX(0)
        self.btnStat:setY(tabY)
        self.btnStat:setWidth(tabWidth)
        self.btnStat:setHeight(tabHeight)
    end
    if self.btnCall then
        self.btnCall:setX(tabWidth)
        self.btnCall:setY(tabY)
        self.btnCall:setWidth(tabWidth)
        self.btnCall:setHeight(tabHeight)
    end
    if self.btnQuest then
        self.btnQuest:setX(tabWidth * 2)
        self.btnQuest:setY(tabY)
        self.btnQuest:setWidth(tabWidth)
        self.btnQuest:setHeight(tabHeight)
    end
    if self.btnInfo then
        self.btnInfo:setX(showQuestTab and (tabWidth * 3) or (tabWidth * 2))
        self.btnInfo:setY(tabY)
        self.btnInfo:setWidth(tabWidth)
        self.btnInfo:setHeight(tabHeight)
    end

    if self.btnOptions then
        self.btnOptions:setX(self.width - self.btnOptions:getWidth() - 5)
    end

    if self.btnHelp then
        local offset = 0
        if self.btnOptions then
            offset = self.btnOptions:getWidth() + 5
        end
        self.btnHelp:setX(self.width - self.btnHelp:getWidth() - 5 - offset)
    end

    if self.scanStatsPanel then
        self.scanStatsPanel:setX(10)
        self.scanStatsPanel:setY(46)
        self.scanStatsPanel:setWidth(math.max(120, self.width - 20))
        self.scanStatsPanel:setHeight(math.max(34, tabY - 48))
    end

    local activeCategory = "Discovered"
    if self.parent and self.parent.currentCategory then
        activeCategory = self.parent.currentCategory
    end

    local activeColor = { r = 0.2, g = 0.2, b = 0.2, a = 1 }
    local inactiveColor = { r = 0, g = 0, b = 0, a = 0.5 }

    local function updateButton(button, categoryName)
        if not button then
            return
        end

        button.backgroundColor = (activeCategory == categoryName) and activeColor or inactiveColor
        button.textColor = (activeCategory == categoryName)
            and { r = 1, g = 1, b = 1, a = 1 }
            or { r = 0.7, g = 0.7, b = 0.7, a = 1 }
    end

    updateButton(self.btnStat, "Discovered")
    updateButton(self.btnCall, "Linked")
    if self.btnQuest then
        updateButton(self.btnQuest, "Quest")
    end
    updateButton(self.btnInfo, "Location")
end

function DT_RadioScannerHeaderPanel:updateSignalInfo(bestName, bestRange)
    if self.lblDeviceName then
        self.lblDeviceName:setName("[" .. tostring(bestName) .. "]")
        self.lblDeviceName:setColor(1, 1, 1)
    end

    if not self.lblRangeInfo then
        return
    end

    if bestRange > 0 then
        self.lblRangeInfo:setName("Broadcast Range: " .. tostring(bestRange) .. "m")

        local r, g, b = 1, 1, 1
        if bestRange < 500 then
            r, g, b = 1, 0.3, 0.3
        elseif bestRange < 1000 then
            r, g, b = 1, 0.8, 0.2
        elseif bestRange < 2000 then
            r, g, b = 0.4, 1.0, 0.4
        else
            r, g, b = 0.4, 0.9, 1.0
        end

        if self.lblDeviceName then
            self.lblDeviceName:setColor(r, g, b)
        end
        self.lblRangeInfo:setColor(0.7, 0.7, 0.7)
    else
        self.lblRangeInfo:setName("Broadcast Range: No Signal")
        if self.lblDeviceName then
            self.lblDeviceName:setColor(0.5, 0.5, 0.5)
        end
    end
end

function DT_RadioScannerHeaderPanel:new(x, y, width, height)
    local o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.backgroundColor = { r = 0, g = 0, b = 0, a = 0 }
    return o
end
