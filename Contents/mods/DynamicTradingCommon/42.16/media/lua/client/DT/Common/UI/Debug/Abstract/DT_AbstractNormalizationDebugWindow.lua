require "ISUI/ISCollapsableWindow"
require "ISUI/ISPanel"
require "ISUI/ISScrollingListBox"
require "ISUI/ISButton"
require "ISUI/ISLabel"
require "ISUI/ISTextEntryBox"
require "ISUI/ISComboBox"
require "ISUI/ISRichTextPanel"

local DebugData = require "DT/Common/UI/Debug/Abstract/DT_AbstractNormalizationDebugData"
local Catalog = require "DT/Common/Abstract/Normalization/DT_AbstractCatalog"
local PaneUtils = require "DT/Common/UI/Debug/DT_DebugPaneUtils"

DT_AbstractNormalizationDebugWindow = ISCollapsableWindow:derive("DT_AbstractNormalizationDebugWindow")
DT_AbstractNormalizationDebugWindow.instance = nil

local CONTENT_PAD = 10
local PANEL_GAP = 10
local FILTER_PANEL_HEIGHT = 64
local PAGER_ROW_HEIGHT = 28
local PANEL_INNER_PAD = 8
local PANEL_HEADER_HEIGHT = 18
local MIN_LIST_WIDTH = 360
local MIN_DETAIL_WIDTH = 320
local MIN_BODY_HEIGHT = 240

local function clamp(value, minValue, maxValue)
    return math.max(minValue, math.min(maxValue, value))
end

local function setSelectedItemIndex(listbox, item)
    if not listbox or not listbox.items then
        return false
    end

    for index, row in ipairs(listbox.items) do
        if row and row.item == item then
            listbox.selected = index
            return true
        end
    end

    return false
end

function DT_AbstractNormalizationDebugWindow:new(x, y, width, height)
    local o = ISCollapsableWindow:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.title = "DT: Abstract Item Normalizer"
    o.backgroundColor = { r = 0.08, g = 0.08, b = 0.08, a = 0.94 }
    o.borderColor = { r = 0.3, g = 0.3, b = 0.3, a = 1 }
    o:setResizable(true)
    o.minimumWidth = 980
    o.minimumHeight = 620
    o.selectedFullType = nil
    o.lastSearchText = nil
    o.lastBucketIndex = nil
    o.hasInitializedFilters = false
    o.pageSize = 100
    o.currentPage = 1
    o.filteredRows = {}
    o.bucketOptions = DebugData.GetBucketOptions()
    return o
end

function DT_AbstractNormalizationDebugWindow:createChildren()
    ISCollapsableWindow.createChildren(self)

    self.filterPanel = ISPanel:new(0, 0, 100, 100)
    self.filterPanel:initialise()
    self.filterPanel.backgroundColor = { r = 0.04, g = 0.04, b = 0.04, a = 0.94 }
    self.filterPanel.borderColor = { r = 0.24, g = 0.24, b = 0.24, a = 1 }
    self:addChild(self.filterPanel)

    self.searchEntry = ISTextEntryBox:new("", 0, 0, 260, 24)
    self.searchEntry:initialise()
    self.filterPanel:addChild(self.searchEntry)

    self.bucketCombo = ISComboBox:new(0, 0, 180, 24, self, nil)
    self.bucketCombo:initialise()
    for _, option in ipairs(self.bucketOptions or {}) do
        self.bucketCombo:addOption(option.label)
    end
    self.bucketCombo.selected = 1
    self.filterPanel:addChild(self.bucketCombo)

    self.btnRebuild = ISButton:new(0, 0, 120, 24, "Rebuild Cache", self, self.onRebuildClicked)
    self.btnRebuild:initialise()
    self.filterPanel:addChild(self.btnRebuild)

    self.statusLabel = ISLabel:new(0, 0, 18, "", 0.82, 0.82, 0.82, 1, UIFont.Small, false)
    self.statusLabel:initialise()
    self.filterPanel:addChild(self.statusLabel)

    self.listPanel = ISPanel:new(0, 0, 100, 100)
    self.listPanel:initialise()
    self.listPanel.backgroundColor = { r = 0.04, g = 0.04, b = 0.04, a = 0.94 }
    self.listPanel.borderColor = { r = 0.24, g = 0.24, b = 0.24, a = 1 }
    self:addChild(self.listPanel)

    self.listTitleLabel = ISLabel:new(0, 0, 18, "NORMALIZED ITEMS", 0.92, 0.92, 0.92, 1, UIFont.Small, true)
    self.listTitleLabel:initialise()
    self.listPanel:addChild(self.listTitleLabel)

    self.btnPrevPage = ISButton:new(0, 0, 84, 22, "Previous", self, self.onPrevPageClicked)
    self.btnPrevPage:initialise()
    self.listPanel:addChild(self.btnPrevPage)

    self.pageLabel = ISLabel:new(0, 0, 18, "Page 1/1", 0.9, 0.9, 0.9, 1, UIFont.Small, true)
    self.pageLabel:initialise()
    self.listPanel:addChild(self.pageLabel)

    self.btnNextPage = ISButton:new(0, 0, 84, 22, "Next", self, self.onNextPageClicked)
    self.btnNextPage:initialise()
    self.listPanel:addChild(self.btnNextPage)

    self.listbox = ISScrollingListBox:new(0, 0, 100, 100)
    self.listbox:initialise()
    self.listbox:instantiate()
    self.listbox.itemheight = 24
    self.listbox.backgroundColor = { r = 0, g = 0, b = 0, a = 0.45 }
    self.listbox.drawBorder = true
    self.listbox.onMouseDown = function(target, x, y)
        local rowIndex = target:rowAt(x, y)
        if type(rowIndex) ~= "number" or rowIndex <= 0 then
            return false
        end

        local entry = target.items and target.items[rowIndex] or nil
        if not entry or not entry.item then
            return false
        end

        target.selected = rowIndex
        if DT_AbstractNormalizationDebugWindow.instance then
            DT_AbstractNormalizationDebugWindow.instance:onRowSelected(entry.item)
        end
        return true
    end
    self.listbox.onmousedown = function(target, item)
        if not DT_AbstractNormalizationDebugWindow.instance then
            return false
        end
        if setSelectedItemIndex(target, item) then
            DT_AbstractNormalizationDebugWindow.instance:onRowSelected(item)
            return true
        end
        return false
    end
    self.listPanel:addChild(self.listbox)

    self.detailPanel = ISPanel:new(0, 0, 100, 100)
    self.detailPanel:initialise()
    self.detailPanel.backgroundColor = { r = 0.04, g = 0.04, b = 0.04, a = 0.94 }
    self.detailPanel.borderColor = { r = 0.24, g = 0.24, b = 0.24, a = 1 }
    self:addChild(self.detailPanel)

    self.detailTitleLabel = ISLabel:new(0, 0, 18, "ABSTRACT DETAILS", 0.92, 0.92, 0.92, 1, UIFont.Small, true)
    self.detailTitleLabel:initialise()
    self.detailPanel:addChild(self.detailTitleLabel)

    self.details = ISRichTextPanel:new(0, 0, 100, 100)
    self.details:initialise()
    self.details.backgroundColor = { r = 0, g = 0, b = 0, a = 0.25 }
    self.details.borderColor = { r = 0.25, g = 0.25, b = 0.25, a = 1 }
    self.details:addScrollBars()
    self.detailPanel:addChild(self.details)

    self:layoutChildren()
    PaneUtils.RefreshRichText(self.details, DebugData.BuildDetailText(nil), true)
    self:refreshList(true)
    self.lastSearchText = self.searchEntry and self.searchEntry:getText() or ""
    self.lastBucketIndex = tonumber(self.bucketCombo and self.bucketCombo.selected) or 1
    self.hasInitializedFilters = true
end

function DT_AbstractNormalizationDebugWindow:layoutChildren()
    local th = self:titleBarHeight()
    local contentX = CONTENT_PAD
    local contentY = th + CONTENT_PAD
    local contentWidth = self.width - (CONTENT_PAD * 2)
    local contentHeight = self.height - th - (CONTENT_PAD * 2)
    local bodyY = contentY + FILTER_PANEL_HEIGHT + PANEL_GAP
    local bodyHeight = math.max(MIN_BODY_HEIGHT, contentHeight - FILTER_PANEL_HEIGHT - PANEL_GAP)
    local availableBodyWidth = contentWidth - PANEL_GAP
    local listWidth = math.max(MIN_LIST_WIDTH, math.floor(availableBodyWidth * 0.5))
    local maxListWidth = math.max(MIN_LIST_WIDTH, availableBodyWidth - MIN_DETAIL_WIDTH)
    listWidth = clamp(listWidth, MIN_LIST_WIDTH, maxListWidth)
    local detailWidth = math.max(MIN_DETAIL_WIDTH, availableBodyWidth - listWidth)

    self.filterPanel:setX(contentX)
    self.filterPanel:setY(contentY)
    self.filterPanel:setWidth(contentWidth)
    self.filterPanel:setHeight(FILTER_PANEL_HEIGHT)

    self.listPanel:setX(contentX)
    self.listPanel:setY(bodyY)
    self.listPanel:setWidth(listWidth)
    self.listPanel:setHeight(bodyHeight)

    self.detailPanel:setX(contentX + listWidth + PANEL_GAP)
    self.detailPanel:setY(bodyY)
    self.detailPanel:setWidth(detailWidth)
    self.detailPanel:setHeight(bodyHeight)

    self:layoutFilterPanel()
    self:layoutListPanel()
    self:layoutDetailPanel()
end

function DT_AbstractNormalizationDebugWindow:layoutFilterPanel()
    local pad = PANEL_INNER_PAD
    local width = self.filterPanel.width
    local searchWidth = clamp(math.floor(width * 0.3), 220, 340)
    local comboWidth = clamp(math.floor(width * 0.22), 160, 240)
    local buttonWidth = self.btnRebuild.width or 120
    local gap = 10
    local rebuildX = width - pad - buttonWidth
    local comboX = pad + searchWidth + gap

    self.searchEntry:setX(pad)
    self.searchEntry:setY(pad)
    self.searchEntry:setWidth(searchWidth)

    self.bucketCombo:setX(comboX)
    self.bucketCombo:setY(pad)
    self.bucketCombo:setWidth(math.max(120, math.min(comboWidth, rebuildX - comboX - gap)))

    self.btnRebuild:setX(rebuildX)
    self.btnRebuild:setY(pad)

    self.statusLabel:setX(pad)
    self.statusLabel:setY(pad + 30)
end

function DT_AbstractNormalizationDebugWindow:layoutListPanel()
    local pad = PANEL_INNER_PAD
    local width = self.listPanel.width
    local height = self.listPanel.height
    local headerY = pad
    local pagerY = headerY + PANEL_HEADER_HEIGHT + 8
    local listY = pagerY + PAGER_ROW_HEIGHT + 6
    local listHeight = math.max(120, height - listY - pad)
    local nextX = width - pad - self.btnNextPage.width
    local prevX = nextX - self.btnPrevPage.width - 92

    self.listTitleLabel:setX(pad)
    self.listTitleLabel:setY(headerY)

    self.btnPrevPage:setX(prevX)
    self.btnPrevPage:setY(pagerY)

    self.pageLabel:setX(prevX + self.btnPrevPage.width + 10)
    self.pageLabel:setY(pagerY + 3)

    self.btnNextPage:setX(nextX)
    self.btnNextPage:setY(pagerY)

    self.listbox:setX(pad)
    self.listbox:setY(listY)
    self.listbox:setWidth(width - (pad * 2))
    self.listbox:setHeight(listHeight)
    PaneUtils.RelayoutEmbeddedScrollbars(self.listbox)
end

function DT_AbstractNormalizationDebugWindow:layoutDetailPanel()
    local pad = PANEL_INNER_PAD
    local width = self.detailPanel.width
    local height = self.detailPanel.height
    local detailsY = pad + PANEL_HEADER_HEIGHT + 8
    local detailsHeight = math.max(120, height - detailsY - pad)

    self.detailTitleLabel:setX(pad)
    self.detailTitleLabel:setY(pad)

    self.details:setX(pad)
    self.details:setY(detailsY)
    self.details:setWidth(width - (pad * 2))
    self.details:setHeight(detailsHeight)
    PaneUtils.RelayoutEmbeddedScrollbars(self.details)
end

function DT_AbstractNormalizationDebugWindow:onResize()
    ISCollapsableWindow.onResize(self)
    self:layoutChildren()
    PaneUtils.RefreshRichText(self.details, nil, false)
end

function DT_AbstractNormalizationDebugWindow:getSelectedBucketID()
    local index = math.max(1, tonumber(self.bucketCombo and self.bucketCombo.selected) or 1)
    local option = self.bucketOptions and self.bucketOptions[index] or nil
    return option and option.id or ""
end

function DT_AbstractNormalizationDebugWindow:onRebuildClicked()
    Catalog.Invalidate("debug_window_rebuild")
    self.currentPage = 1
    self:refreshList(true)
end

function DT_AbstractNormalizationDebugWindow:onPrevPageClicked()
    if self.currentPage > 1 then
        self.currentPage = self.currentPage - 1
        self:renderCurrentPage()
    end
end

function DT_AbstractNormalizationDebugWindow:onNextPageClicked()
    local slice = DebugData.GetPageSlice(self.filteredRows, self.currentPage, self.pageSize)
    if self.currentPage < (slice.totalPages or 1) then
        self.currentPage = self.currentPage + 1
        self:renderCurrentPage()
    end
end

function DT_AbstractNormalizationDebugWindow:onRowSelected(rowData)
    local record = rowData and rowData.record or nil
    self.selectedFullType = record and record.fullType or nil
    self:updateDetails(record)
end

function DT_AbstractNormalizationDebugWindow:updateDetails(record)
    PaneUtils.RefreshRichText(self.details, DebugData.BuildDetailText(record), true)
end

function DT_AbstractNormalizationDebugWindow:restoreSelection()
    if not self.selectedFullType or not self.listbox or not self.listbox.items then
        self.listbox.selected = -1
        self:updateDetails(nil)
        return
    end

    for index, row in ipairs(self.listbox.items) do
        if row and row.item and row.item.record and row.item.record.fullType == self.selectedFullType then
            self.listbox.selected = index
            self:updateDetails(row.item.record)
            return
        end
    end

    self.listbox.selected = -1
    self:updateDetails(nil)
end

function DT_AbstractNormalizationDebugWindow:updatePagerState(slice)
    local totalPages = slice and slice.totalPages or 1
    local pageIndex = slice and slice.pageIndex or 1
    if self.pageLabel and self.pageLabel.setName then
        self.pageLabel:setName("Page " .. tostring(pageIndex) .. "/" .. tostring(totalPages))
    end

    local canGoPrev = pageIndex > 1
    local canGoNext = pageIndex < totalPages

    if self.btnPrevPage then
        if self.btnPrevPage.setEnable then
            self.btnPrevPage:setEnable(canGoPrev)
        end
        self.btnPrevPage.enable = canGoPrev
    end

    if self.btnNextPage then
        if self.btnNextPage.setEnable then
            self.btnNextPage:setEnable(canGoNext)
        end
        self.btnNextPage.enable = canGoNext
    end
end

function DT_AbstractNormalizationDebugWindow:renderCurrentPage()
    local searchText = self.searchEntry and self.searchEntry:getText() or ""
    local bucketFilter = self:getSelectedBucketID()
    local slice = DebugData.GetPageSlice(self.filteredRows, self.currentPage, self.pageSize)
    self.currentPage = slice.pageIndex or 1

    self.listbox:clear()
    for _, row in ipairs(slice.rows or {}) do
        self.listbox:addItem(row.listText or row.record.displayName or row.record.fullType, row)
    end

    if self.statusLabel and self.statusLabel.setName then
        self.statusLabel:setName(
            DebugData.GetStatusText(
                searchText,
                bucketFilter,
                #self.filteredRows,
                slice.pageIndex,
                slice.totalPages,
                slice.startIndex,
                slice.endIndex
            )
        )
    end

    self:updatePagerState(slice)
    PaneUtils.RelayoutEmbeddedScrollbars(self.listbox)
    self:restoreSelection()
end

function DT_AbstractNormalizationDebugWindow:refreshList(force)
    local searchText = self.searchEntry and self.searchEntry:getText() or ""
    local bucketFilter = self:getSelectedBucketID()

    if force then
        Catalog.WarmCache()
    end

    self.filteredRows = DebugData.GetRows(searchText, bucketFilter)
    self.currentPage = 1
    self:renderCurrentPage()
end

function DT_AbstractNormalizationDebugWindow:update()
    ISCollapsableWindow.update(self)

    if not self.hasInitializedFilters then
        return
    end

    local currentSearch = self.searchEntry and self.searchEntry:getText() or ""
    local currentBucketIndex = tonumber(self.bucketCombo and self.bucketCombo.selected) or 1

    if currentSearch ~= self.lastSearchText or currentBucketIndex ~= self.lastBucketIndex then
        self.lastSearchText = currentSearch
        self.lastBucketIndex = currentBucketIndex
        self:refreshList(false)
    end
end

function DT_AbstractNormalizationDebugWindow:close()
    ISCollapsableWindow.close(self)
    self:removeFromUIManager()
    DT_AbstractNormalizationDebugWindow.instance = nil
end

function DT_AbstractNormalizationDebugWindow.Open()
    if DT_AbstractNormalizationDebugWindow.instance then
        DT_AbstractNormalizationDebugWindow.instance:setVisible(true)
        DT_AbstractNormalizationDebugWindow.instance:bringToTop()
        DT_AbstractNormalizationDebugWindow.instance:refreshList(false)
        return
    end

    local sw = getCore():getScreenWidth()
    local sh = getCore():getScreenHeight()
    local width = 1120
    local height = 720
    local instance = DT_AbstractNormalizationDebugWindow:new((sw - width) / 2, (sh - height) / 2, width, height)
    instance:initialise()
    instance:addToUIManager()
    DT_AbstractNormalizationDebugWindow.instance = instance
end
