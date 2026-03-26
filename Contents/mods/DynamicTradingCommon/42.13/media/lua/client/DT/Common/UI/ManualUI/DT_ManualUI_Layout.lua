require "ISUI/ISScrollingListBox"
require "ISUI/ISButton"
require "ISUI/ISLabel"
require "ISUI/ISTextEntryBox"
require "DT/Common/UI/ManualUI/DT_ManualUI_Definition"
require "DT/Common/UI/ManualUI/DT_ManualUI_Utils"

function DT_ManualUI:createChildren()
    ISCollapsableWindow.createChildren(self)

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

    self.contentList:setX(metrics.rightX)
    self.contentList:setY(metrics.contentY)
    self.contentList:setWidth(metrics.rightWidth)
    self.contentList:setHeight(metrics.contentHeight)
end

function DT_ManualUI:onResize()
    ISCollapsableWindow.onResize(self)

    self:refreshLayout()

    self:refreshResults()
    self:refreshContent()
end
