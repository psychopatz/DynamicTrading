require "ISUI/ISScrollingListBox"
require "ISUI/ISButton"
require "ISUI/ISLabel"
require "ISUI/ISPanel"
require "ISUI/ISTickBox"
require "ISUI/ISTextEntryBox"
require "DT/Common/UI/ManualUI/DT_ManualUI_Definition"
require "DT/Common/UI/ManualUI/DT_ManualUI_Utils"

function DT_ManualUI:createChildren()
    ISCollapsableWindow.createChildren(self)
    self:refreshWindowTitle()

    local metrics = DT_ManualUI_Utils.getLayoutMetrics(self)

    self.searchEntry = ISTextEntryBox:new("", metrics.rightX, metrics.titleBarHeight + metrics.pad, metrics.rightWidth - 170, metrics.toolbarHeight)
    self.searchEntry:initialise()
    self.searchEntry:instantiate()
    self:addChild(self.searchEntry)

    self.btnSearch = ISButton:new(metrics.rightX + metrics.rightWidth - 160, metrics.titleBarHeight + metrics.pad, 50, metrics.toolbarHeight, "Find", self, self.onSearchButton)
    self.btnSearch:initialise()
    self.btnSearch:instantiate()
    self:addChild(self.btnSearch)

    self.btnClear = ISButton:new(metrics.rightX + metrics.rightWidth - 105, metrics.titleBarHeight + metrics.pad, 50, metrics.toolbarHeight, "Clear", self, self.onClearSearchButton)
    self.btnClear:initialise()
    self.btnClear:instantiate()
    self:addChild(self.btnClear)

    self.btnHome = ISButton:new(metrics.rightX + metrics.rightWidth - 50, metrics.titleBarHeight + metrics.pad, 40, metrics.toolbarHeight, "All", self, self.onHomeButton)
    self.btnHome:initialise()
    self.btnHome:instantiate()
    self:addChild(self.btnHome)

    self.navList = ISScrollingListBox:new(metrics.pad, metrics.titleBarHeight + metrics.pad, metrics.leftWidth, self.height - metrics.titleBarHeight - (metrics.pad * 2))
    self.navList:initialise()
    self.navList:instantiate()
    self.navList.font = UIFont.NewSmall
    self.navList.itemheight = 26
    self.navList.drawBorder = true
    self.navList.onMouseDown = self.onNavMouseDown
    self.navList.doDrawItem = self.drawNavItem
    self.navList.doGetItemHeight = function(self, item)
        local row = item.item
        local width = self:getWidth() - 24 - ((row.depth or 0) * 18)
        local titleFont = UIFont.NewSmall
        if row.kind == "manual" then titleFont = UIFont.Medium end
        if row.kind == "chapter" then titleFont = UIFont.Small end
        local titleLines = DT_ManualUI_Utils.WrapManualText(row.title or "", width, titleFont)
        local subtitleLines = {}
        if row.kind == "manual" and row.subtitle and row.subtitle ~= "" then
            subtitleLines = DT_ManualUI_Utils.WrapManualText(row.subtitle, width, UIFont.Small)
        end
        local h = 8 + (#titleLines * 18) + (#subtitleLines * 16)
        if row.kind == "manual" then h = h + 6 end
        if row.kind == "chapter" then h = h + 5 end
        return math.max(h, 26)
    end
    self:addChild(self.navList)

    self.resultsLabel = ISLabel:new(metrics.rightX, metrics.titleBarHeight + metrics.pad + metrics.toolbarHeight + 4, 18, "Search Results", 0.9, 0.9, 0.9, 1, UIFont.Small, true)
    self.resultsLabel:initialise()
    self.resultsLabel:instantiate()
    self:addChild(self.resultsLabel)

    self.resultList = ISScrollingListBox:new(metrics.rightX, metrics.titleBarHeight + metrics.pad + metrics.toolbarHeight + metrics.pad, metrics.rightWidth, metrics.resultsHeight)
    self.resultList:initialise()
    self.resultList:instantiate()
    self.resultList.font = UIFont.NewSmall
    self.resultList.itemheight = 44
    self.resultList.drawBorder = true
    self.resultList.onMouseDown = self.onResultMouseDown
    self.resultList.doDrawItem = self.drawResultItem
    self:addChild(self.resultList)

    self.pageTitle = ISLabel:new(metrics.rightX, metrics.pageTitleY, 20, "Manual", 1, 1, 1, 1, UIFont.Medium, true)
    self.pageTitle:initialise()
    self.pageTitle:instantiate()
    self:addChild(self.pageTitle)

    self.updateAutoOpenTick = ISTickBox:new(metrics.rightX, metrics.updateToggleY, metrics.rightWidth, 20, "", self, self.onUpdateAutoOpenTick)
    self.updateAutoOpenTick:initialise()
    self.updateAutoOpenTick:instantiate()
    self.updateAutoOpenTick:addOption("Don't auto-open this update again")
    self.updateAutoOpenTick:setFont(UIFont.Small)
    self.updateAutoOpenTick:setVisible(false)
    self:addChild(self.updateAutoOpenTick)

    self.supportBannerPanel = ISPanel:new(metrics.rightX, metrics.supportBannerY, metrics.rightWidth, metrics.supportBannerHeight)
    self.supportBannerPanel:initialise()
    self.supportBannerPanel:instantiate()
    self.supportBannerPanel.backgroundColor = { r = 0.18, g = 0.12, b = 0.04, a = 0.92 }
    self.supportBannerPanel.borderColor = { r = 0.82, g = 0.62, b = 0.18, a = 0.85 }
    self.supportBannerPanel:setVisible(false)
    self:addChild(self.supportBannerPanel)

    self.supportBannerTitle = ISLabel:new(10, 8, 18, "Support Dynamic Trading", 0.96, 0.88, 0.46, 1, UIFont.Medium, true)
    self.supportBannerTitle:initialise()
    self.supportBannerTitle:instantiate()
    self.supportBannerPanel:addChild(self.supportBannerTitle)

    self.supportBannerTextLabels = {}
    self.supportBannerTextRaw = "If the mod is earning permanent slots in your load order, consider supporting its continued development."
    -- Labels will be created in refreshLayout

    self.btnSupportBanner = ISButton:new(10, 48, 110, 24, "View Support", self, self.onOpenSupportBanner)
    self.btnSupportBanner:initialise()
    self.btnSupportBanner:instantiate()
    self.supportBannerPanel:addChild(self.btnSupportBanner)

    self.btnWhatsNew = ISButton:new(130, 48, 110, 24, "What's New", self, self.onOpenWhatsNew)
    self.btnWhatsNew:initialise()
    self.btnWhatsNew:instantiate()
    self.supportBannerPanel:addChild(self.btnWhatsNew)

    self.contentList = ISScrollingListBox:new(metrics.rightX, metrics.contentY, metrics.rightWidth, metrics.contentHeight)
    self.contentList:initialise()
    self.contentList:instantiate()
    self.contentList.font = UIFont.NewSmall
    self.contentList.itemheight = 30
    self.contentList.drawBorder = true
    self.contentList.onMouseDown = self.onContentMouseDown
    self.contentList.doDrawItem = self.drawContentItem
    self:addChild(self.contentList)

    self:refreshLayout()
end

function DT_ManualUI:refreshLayout()
    if not self.navList or not self.searchEntry or not self.btnSearch or not self.btnClear or not self.btnHome or not self.resultsLabel or not self.resultList or not self.pageTitle or not self.contentList then
        return
    end

    local metrics = DT_ManualUI_Utils.getLayoutMetrics(self)

    self.navList:setHeight(self.height - metrics.titleBarHeight - (metrics.pad * 2))

    self.searchEntry:setX(metrics.rightX)
    self.searchEntry:setY(metrics.titleBarHeight + metrics.pad)
    self.searchEntry:setWidth(metrics.rightWidth - 170)

    self.btnSearch:setX(metrics.rightX + metrics.rightWidth - 160)
    self.btnSearch:setY(metrics.titleBarHeight + metrics.pad)
    self.btnClear:setX(metrics.rightX + metrics.rightWidth - 105)
    self.btnClear:setY(metrics.titleBarHeight + metrics.pad)
    self.btnHome:setX(metrics.rightX + metrics.rightWidth - 50)
    self.btnHome:setY(metrics.titleBarHeight + metrics.pad)

    self.resultsVisible = metrics.showResults == true

    self.resultsLabel:setX(metrics.rightX)
    self.resultsLabel:setY(metrics.searchBottom + 4)
    self.resultsLabel:setVisible(self.resultsVisible)

    self.resultList:setX(metrics.rightX)
    self.resultList:setY(metrics.resultsY)
    self.resultList:setWidth(metrics.rightWidth)
    self.resultList:setHeight(metrics.resultsHeight)
    self.resultList:setVisible(self.resultsVisible)

    self.pageTitle:setX(metrics.rightX)
    self.pageTitle:setY(metrics.pageTitleY)

    self.updateAutoOpenTick:setX(metrics.rightX)
    self.updateAutoOpenTick:setY(metrics.updateToggleY)
    self.updateAutoOpenTick:setWidth(metrics.rightWidth)
    self.updateAutoOpenTick:setVisible(self.showUpdateToggle == true)

    if self.supportBannerPanel then
        self.supportBannerPanel:setX(metrics.rightX)
        self.supportBannerPanel:setY(metrics.supportBannerY)
        self.supportBannerPanel:setWidth(metrics.rightWidth)
        -- Remove old text labels
        if self.supportBannerTextLabels then
            for _, lbl in ipairs(self.supportBannerTextLabels) do
                self.supportBannerPanel:removeChild(lbl)
            end
        end
        self.supportBannerTextLabels = {}

        self.supportBannerPanel:setVisible(self.showSupportBanner == true)
        if self.showSupportBanner == true then
            local manual = self.supportBannerManual or {}
            local title = manual.bannerTitle ~= "" and manual.bannerTitle or "Support Dynamic Trading"
            local text = manual.bannerText ~= "" and manual.bannerText or self.supportBannerTextRaw
            local actionLabel = manual.bannerActionLabel ~= "" and manual.bannerActionLabel or "View Support"

            self.supportBannerTitle:setName(title)
            self.btnSupportBanner:setTitle(actionLabel)
            self.btnSupportBanner:setX(10)
            self.btnSupportBanner:setY(0) -- Will be set after text
            self.btnWhatsNew:setX(130)
            self.btnWhatsNew:setY(0) -- Will be set after text

            -- Wrap text
            local wrapWidth = math.max(metrics.rightWidth - 20, 120)
            local lines = DynamicTrading.Utils.WrapText(text, wrapWidth, UIFont.Small)
            local y = 30
            for i, line in ipairs(lines) do
                local lbl = ISLabel:new(10, y, 16, line, 0.88, 0.88, 0.88, 1, UIFont.Small, true)
                lbl:initialise()
                lbl:instantiate()
                self.supportBannerPanel:addChild(lbl)
                table.insert(self.supportBannerTextLabels, lbl)
                y = y + 18
            end
            -- Place buttons below text
            self.btnSupportBanner:setY(y)
            self.btnWhatsNew:setY(y)
            -- Adjust banner height
            local bannerHeight = y + 28
            self.supportBannerPanel:setHeight(bannerHeight)
            metrics.supportBannerHeight = bannerHeight
        end
    end

    self.contentList:setX(metrics.rightX)
    self.contentList:setY(metrics.contentY)
    self.contentList:setWidth(metrics.rightWidth)
    self.contentList:setHeight(metrics.contentHeight)
end

function DT_ManualUI:refreshUpdateControls()
    if not self.updateAutoOpenTick then
        return
    end

    local shouldShow = self.currentManualType == "whats_new" and self.currentPopupVersion and self.currentPopupVersion ~= ""
    self.showUpdateToggle = shouldShow == true
    self._refreshingUpdateToggle = true
    if shouldShow then
        local disabledVersion = DT_ConfigManager and DT_ConfigManager.getDisabledAutoOpenReleaseVersion and DT_ConfigManager.getDisabledAutoOpenReleaseVersion() or ""
        self.updateAutoOpenTick:setSelected(1, disabledVersion == self.currentPopupVersion)
    else
        self.updateAutoOpenTick:setSelected(1, false)
    end
    self._refreshingUpdateToggle = false
    self:refreshLayout()
end

function DT_ManualUI:onResize()
    ISCollapsableWindow.onResize(self)

    if self.refreshLayout then
        self:refreshLayout()
    end

    if self.refreshResults then
        self:refreshResults()
    end
    if self.refreshContent then
        self:refreshContent()
    end
end
