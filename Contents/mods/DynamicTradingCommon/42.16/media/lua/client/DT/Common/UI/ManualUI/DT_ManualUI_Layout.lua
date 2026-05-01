require "ISUI/ISScrollingListBox"
require "ISUI/ISButton"
require "ISUI/ISLabel"
require "ISUI/ISPanel"
require "ISUI/ISTickBox"
require "ISUI/ISTextEntryBox"
require "DT/Common/UI/ManualUI/DT_ManualUI_Definition"
require "DT/Common/UI/ManualUI/DT_ManualUI_Utils"
require "DT/Common/UI/ManualUI/Donators/DT_ManualUI_Donators_Render"

local function getManualViewerTypeLabel(ui)
    if not ui then
        return "Manual Library"
    end

    if tostring(ui.viewMode or "") == "updates" then
        return "What's New / Updates"
    end

    local manualType = string.lower(tostring(ui.currentManualType or ""))

    if manualType == "support" then
        return "Support Manuals"
    end

    if manualType == "donators" then
        return "Supporters"
    end

    if manualType == "whats_new" then
        return "What's New / Updates"
    end

    return "Manual Library"
end

local function getManualViewerFilterLabel(ui)
    if not ui then
        return "All Mods"
    end

    local key = tostring(ui.manualFilterKey or "scope:all")

    for _, option in ipairs(ui.manualFilterOptions or {}) do
        if tostring(option.key or "") == key then
            return tostring(option.label or "All Mods")
        end
    end

    return "All Mods"
end

local function buildManualViewerContextText(ui)
    local typeLabel = getManualViewerTypeLabel(ui)
    local filterLabel = getManualViewerFilterLabel(ui)

    if filterLabel == "" then
        filterLabel = "All Mods"
    end

    return typeLabel .. " - " .. filterLabel
end

local function getNavTitleFont(row)
    local titleFont = UIFont.NewSmall

    if row and row.kind == "manual" then
        titleFont = UIFont.Medium
    elseif row and row.kind == "chapter" then
        titleFont = UIFont.Small
    end

    return titleFont
end

function DT_ManualUI:getNavRowDisplayData(row, listWidth)
    row = row or {}
    listWidth = math.max(80, tonumber(listWidth) or 250)

    local indent = (tonumber(row.depth) or 0) * 18
    local indicatorOffset = row.expandable and 14 or 0
    local contentWidth = math.max(42, listWidth - 24 - indent - indicatorOffset)
    local titleFont = getNavTitleFont(row)

    local maxTitleLines = 2
    local maxSubtitleLines = 0

    if row.kind == "manual" then
        maxTitleLines = 2
        maxSubtitleLines = 5
    elseif row.kind == "chapter" then
        maxTitleLines = 2
        maxSubtitleLines = 0
    elseif row.kind == "page" then
        maxTitleLines = 2
        maxSubtitleLines = 1
    end

    local titleLines = DT_ManualUI_Utils.limitWrappedLines(row.title or "", contentWidth, titleFont, maxTitleLines)
    local subtitleLines = {}

    if row.subtitle and tostring(row.subtitle or "") ~= "" and maxSubtitleLines > 0 then
        subtitleLines = DT_ManualUI_Utils.limitWrappedLines(row.subtitle, contentWidth, UIFont.Small, maxSubtitleLines)
    end

    return {
        contentWidth = contentWidth,
        indent = indent,
        indicatorOffset = indicatorOffset,
        titleFont = titleFont,
        titleLines = titleLines,
        subtitleLines = subtitleLines,
    }
end

function DT_ManualUI:getNavRowHeight(row, listWidth)
    local data = self:getNavRowDisplayData(row, listWidth)
    local h = 8 + (#data.titleLines * 18) + (#data.subtitleLines * 16)

    if row and row.kind == "manual" then
        h = h + 8
    elseif row and row.kind == "chapter" then
        h = h + 8
    elseif row and row.kind == "page" then
        h = h + 4
    end

    return math.max(h, 30)
end

local function updateNavItemHeights(ui)
    if not ui or not ui.navList or not ui.navList.items or not ui.getNavRowHeight then
        return
    end

    local listWidth = ui.navList:getWidth()

    for _, item in ipairs(ui.navList.items) do
        if item and item.item then
            item.height = ui:getNavRowHeight(item.item, listWidth)
        end
    end
end

local function refreshNavContextLabels(ui, metrics)
    if not ui or not metrics or not ui.navContextLabels then
        return metrics
    end

    local width = math.max(60, metrics.leftWidth - 12)
    local lines = DT_ManualUI_Utils.limitWrappedLines(buildManualViewerContextText(ui), width, UIFont.Small, 3)

    if #lines <= 0 then
        lines = { "Manual Library - All Mods" }
    end

    local lineCount = math.max(1, math.min(3, #lines))
    if ui._navContextLineCount ~= lineCount then
        ui._navContextLineCount = lineCount
        metrics = DT_ManualUI_Utils.getLayoutMetrics(ui)
    end

    for index = 1, 3 do
        local label = ui.navContextLabels[index]
        if label then
            if index <= lineCount then
                label:setName(lines[index] or "")
                label:setX(metrics.pad)
                label:setY(metrics.navHeaderY + 3 + ((index - 1) * 16))
                label:setVisible(true)
            else
                label:setVisible(false)
            end
        end
    end

    return metrics
end

local function getCurrentManual(ui)
    return ui and ui.allManuals and ui.currentManualId and ui.allManuals[ui.currentManualId] or nil
end

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

    self.navContextLabels = {}
    for index = 1, 3 do
        local label = ISLabel:new(
            metrics.pad,
            metrics.navHeaderY + 3 + ((index - 1) * 16),
            16,
            "",
            0.92,
            0.86,
            0.62,
            1,
            UIFont.Small,
            true
        )
        label:initialise()
        label:instantiate()
        label:setVisible(index == 1)
        self:addChild(label)
        self.navContextLabels[index] = label
    end

    local ownerWindow = self
    self.navList = ISScrollingListBox:new(metrics.pad, metrics.navListY, metrics.leftWidth, metrics.navListHeight)
    self.navList:initialise()
    self.navList:instantiate()
    self.navList.font = UIFont.NewSmall
    self.navList.itemheight = 30
    self.navList.drawBorder = true
    self.navList.onMouseDown = self.onNavMouseDown
    self.navList.doDrawItem = self.drawNavItem
    self.navList.doGetItemHeight = function(listBox, item)
        return ownerWindow:getNavRowHeight(item and item.item or {}, listBox:getWidth())
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
    self.resultList.doGetItemHeight = function(listBox, item)
        local row = item.item
        local width = listBox:getWidth() - 20
        local labelLines = DT_ManualUI_Utils.WrapManualText(row.label or "", width, UIFont.Small)
        local pathLines = DT_ManualUI_Utils.WrapManualText(tostring(row.path or ""), width, UIFont.Small)
        local snippetLines = DT_ManualUI_Utils.WrapManualText(tostring(row.snippet or ""), width, UIFont.Small)
        local h = 4 + (#labelLines * 16) + (#pathLines * 16) + (#snippetLines * 16) + 8
        return math.max(h, 44)
    end
    self:addChild(self.resultList)

    self.pageTitle = ISLabel:new(metrics.rightX, metrics.pageTitleY, 20, "Manual", 1, 1, 1, 1, UIFont.Medium, true)
    self.pageTitle:initialise()
    self.pageTitle:instantiate()
    self:addChild(self.pageTitle)

    self.updateAutoOpenTick = ISTickBox:new(metrics.rightX, metrics.updateToggleY, metrics.rightWidth, 20, "", self, self.onUpdateAutoOpenTick)
    self.updateAutoOpenTick:initialise()
    self.updateAutoOpenTick:instantiate()
    self.updateAutoOpenTick:addOption("Don't show this What's New again until a new update arrives")
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

    self.supportBannerPreviewPanel = DT_ManualUI_Donators_Render.CreateBannerPreviewPanel(self, 10, 34, math.max(metrics.rightWidth - 20, 160), 96)
    self.supportBannerPanel:addChild(self.supportBannerPreviewPanel)

    self.btnSupportBanner = ISButton:new(10, 48, 110, 24, "View Support", self, self.onOpenSupportBanner)
    self.btnSupportBanner:initialise()
    self.btnSupportBanner:instantiate()
    self.supportBannerPanel:addChild(self.btnSupportBanner)

    self.btnHallOfFame = ISButton:new(130, 48, 110, 24, "Supporters", self, self.onOpenHallOfFame)
    self.btnHallOfFame:initialise()
    self.btnHallOfFame:instantiate()
    self.supportBannerPanel:addChild(self.btnHallOfFame)

    self.btnWhatsNew = ISButton:new(250, 48, 110, 24, "What's New", self, self.onOpenWhatsNew)
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
    metrics = refreshNavContextLabels(self, metrics)

    self.navList:setX(metrics.pad)
    self.navList:setY(metrics.navListY)
    self.navList:setWidth(metrics.leftWidth)
    self.navList:setHeight(metrics.navListHeight)
    updateNavItemHeights(self)

    self.searchEntry:setX(metrics.rightX)
    self.searchEntry:setY(metrics.searchBarY)
    self.searchEntry:setWidth(metrics.rightWidth - 170)

    self.btnSearch:setX(metrics.rightX + metrics.rightWidth - 160)
    self.btnSearch:setY(metrics.searchBarY)

    self.btnClear:setX(metrics.rightX + metrics.rightWidth - 105)
    self.btnClear:setY(metrics.searchBarY)

    self.btnHome:setX(metrics.rightX + metrics.rightWidth - 50)
    self.btnHome:setY(metrics.searchBarY)

    self.resultsVisible = metrics.showResults == true

    self.resultsLabel:setX(metrics.rightX)
    self.resultsLabel:setY(metrics.searchBottom + 4)
    self.resultsLabel:setVisible(self.resultsVisible)

    self.resultList:setX(metrics.rightX)
    self.resultList:setY(metrics.resultsY)
    self.resultList:setWidth(metrics.rightWidth)
    self.resultList:setHeight(metrics.resultsHeight)

    if self.resultList.items then
        local rw = self.resultList:getWidth() - 20
        for _, item in ipairs(self.resultList.items) do
            local row = item.item
            local labelLines = DT_ManualUI_Utils.WrapManualText(row.label or "", rw, UIFont.Small)
            local pathLines = DT_ManualUI_Utils.WrapManualText(tostring(row.path or ""), rw, UIFont.Small)
            local snippetLines = DT_ManualUI_Utils.WrapManualText(tostring(row.snippet or ""), rw, UIFont.Small)
            local h = 4 + (#labelLines * 16) + (#pathLines * 16) + (#snippetLines * 16) + 8
            item.height = math.max(h, 44)
        end
    end

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
            self.btnSupportBanner:setY(0)

            self.btnHallOfFame:setX(130)
            self.btnHallOfFame:setVisible(self.hallOfFameManual ~= nil)
            self.btnHallOfFame.enable = self.hallOfFameManual ~= nil

            self.btnWhatsNew:setX((self.hallOfFameManual ~= nil) and 250 or 130)
            self.btnWhatsNew:setY(0)
            self.btnHallOfFame:setY(0)

            if self.supportBannerPreviewPanel then
                self.supportBannerPreviewPanel:setX(10)
                self.supportBannerPreviewPanel:setY(34)
                self.supportBannerPreviewPanel:setWidth(math.max(metrics.rightWidth - 20, 160))
                self.supportBannerPreviewPanel:setVisible(self.hallOfFameManual ~= nil)
            end

            local wrapWidth = math.max(metrics.rightWidth - 20, 120)
            local lines = DynamicTrading.Utils.WrapText(text, wrapWidth, UIFont.Small)
            local y = (self.hallOfFameManual ~= nil) and 138 or 30

            for _, line in ipairs(lines) do
                local lbl = ISLabel:new(10, y, 16, line, 0.88, 0.88, 0.88, 1, UIFont.Small, true)
                lbl:initialise()
                lbl:instantiate()
                self.supportBannerPanel:addChild(lbl)
                table.insert(self.supportBannerTextLabels, lbl)
                y = y + 18
            end

            self.btnSupportBanner:setY(y)
            self.btnHallOfFame:setY(y)
            self.btnWhatsNew:setY(y)

            local bannerHeight = y + 28
            self.supportBannerPanel:setHeight(bannerHeight)
            metrics.supportBannerHeight = bannerHeight
        elseif self.supportBannerPreviewPanel then
            self.supportBannerPreviewPanel:setVisible(false)
        end
    end

    self.contentList:setX(metrics.rightX)
    self.contentList:setY(metrics.contentY)
    self.contentList:setWidth(metrics.rightWidth)
    self.contentList:setHeight(metrics.contentHeight)

    if self.contentList and self.contentList.items then
        for _, item in ipairs(self.contentList.items) do
            if item.item and item.item._rawBlock then
                local newPayload = self:prepareBlock(item.item._rawBlock)
                item.item = newPayload
                item.height = newPayload.height
            end
        end
    end
end

function DT_ManualUI:refreshUpdateControls()
    if not self.updateAutoOpenTick then
        return
    end

    local autoOpen = DynamicTrading
        and DynamicTrading.Manuals
        and DynamicTrading.Manuals.AutoOpen
        or nil

    local manual = getCurrentManual(self)
    local shouldShow = false
    local selected = false

    self.currentAutoOpenKey = nil

    if autoOpen and manual and tostring(manual.manualType or "") == "whats_new" then
        shouldShow = true

        if autoOpen.GetAcknowledgedWhatsNewCount and autoOpen.GetCurrentWhatsNewCount then
            selected = autoOpen.GetAcknowledgedWhatsNewCount() == autoOpen.GetCurrentWhatsNewCount()
        end
    end

    self.showUpdateToggle = shouldShow == true
    self._refreshingUpdateToggle = true
    self.updateAutoOpenTick:setSelected(1, selected)
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

function DT_ManualUI:prerender()
    ISCollapsableWindow.prerender(self)

    if self.navList then
        local targetWidth = 250
        if self.navList:isMouseOver() or self.navList.mouseoverselected ~= -1 then
            targetWidth = math.min(self.width - 40, 420)
        end

        self._currentNavWidth = self._currentNavWidth or 250

        if self._currentNavWidth ~= targetWidth then
            local diff = targetWidth - self._currentNavWidth
            if math.abs(diff) < 2 then
                self._currentNavWidth = targetWidth
            else
                self._currentNavWidth = self._currentNavWidth + (diff * 0.15)
            end
            self:refreshLayout()
        end
    end
end
