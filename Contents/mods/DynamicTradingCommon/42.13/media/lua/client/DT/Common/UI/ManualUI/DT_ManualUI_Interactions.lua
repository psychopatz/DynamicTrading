require "DT/Common/UI/ManualUI/DT_ManualUI_Definition"

function DT_ManualUI:onSearchButton()
    local query = tostring(self.searchEntry and self.searchEntry:getText() or "")
    self:runSearch(query)
end

function DT_ManualUI:onClearSearchButton()
    if self.searchEntry then
        self.searchEntry:setText("")
    end
    self.results = {}
    self:refreshResults()
    self:refreshContent()
end

function DT_ManualUI:onHomeButton()
    if self.searchEntry then
        self.searchEntry:setText("")
    end
    self.results = {}
    self:refreshResults()
    self.currentManualId = nil
    self.currentPageId = nil
    self.highlightSectionId = nil
    self:refreshNavigation()
    self:refreshContent()
end

function DT_ManualUI:onNavMouseDown(x, y)
    local row = self:rowAt(x, y)
    if row == -1 then
        return
    end

    local entry = self.items[row] and self.items[row].item or nil
    if not entry then
        return
    end

    if entry.kind == "manual" then
        DT_ManualUI.instance:openLocation({ manualId = entry.manualId })
        return
    end

    if entry.kind == "page" then
        DT_ManualUI.instance:openLocation({ manualId = entry.manualId, pageId = entry.pageId })
        return
    end
end

function DT_ManualUI:onResultMouseDown(x, y)
    local row = self:rowAt(x, y)
    if row == -1 then
        return
    end

    local entry = self.items[row] and self.items[row].item or nil
    if not entry then
        return
    end

    DT_ManualUI.instance:openLocation({
        manualId = entry.manualId,
        pageId = entry.pageId,
        sectionId = entry.sectionId,
    })
end

function DT_ManualUI:onContentMouseDown(x, y)
    local row = self:rowAt(x, y)
    if row == -1 then
        return
    end

    local entry = self.items[row] and self.items[row].item or nil
    if not entry then
        return
    end

    if entry.kind == "library" then
        DT_ManualUI.instance:openLocation({ manualId = entry.manualId })
    end
end
