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
    self.currentManualType = "manual"
    self.currentPopupVersion = ""

    if self.refreshSupportBannerState then
        self:refreshSupportBannerState()
    end

    if self.refreshLayout then
        self:refreshLayout()
    end

    self:refreshNavigation()
    self:refreshContent()
end

function DT_ManualUI:onUpdateAutoOpenTick(index, selected)
    if self._refreshingUpdateToggle then
        return
    end

    if index ~= 1 then
        return
    end

    local autoOpen = DynamicTrading
        and DynamicTrading.Manuals
        and DynamicTrading.Manuals.AutoOpen
        or nil

    if not autoOpen then
        return
    end

    local manual = self.allManuals and self.currentManualId and self.allManuals[self.currentManualId] or nil
    if not manual then
        return
    end

    if tostring(manual.manualType or "") ~= "whats_new" then
        return
    end

    if selected == true then
        if autoOpen.MarkWhatsNewAcknowledged then
            autoOpen.MarkWhatsNewAcknowledged()
        end
    elseif autoOpen.SetAcknowledgedWhatsNewCount then
        autoOpen.SetAcknowledgedWhatsNewCount(0)
    end
end

function DT_ManualUI:onOpenSupportBanner()
    local manual = self.supportBannerManual
    if not manual then
        return
    end

    DynamicTrading.Manuals.OpenSupport({
        manualId = manual.id,
        pageId = manual.startPageId,
    })
end

function DT_ManualUI:onOpenWhatsNew()
    if not DynamicTrading or not DynamicTrading.Manuals or not DynamicTrading.Manuals.GetLatestWhatsNewManual then
        return
    end

    local manual = DynamicTrading.Manuals.GetLatestWhatsNewManual()
    if not manual then
        return
    end

    DynamicTrading.Manuals.OpenUpdates({
        manualId = manual.id,
        pageId = manual.startPageId,
    })
end

function DT_ManualUI:onOpenHallOfFame()
    if not DynamicTrading or not DynamicTrading.Manuals or not DynamicTrading.Manuals.OpenDonators then
        return
    end

    DynamicTrading.Manuals.OpenDonators()
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
        if DT_ManualUI.instance.currentManualId == entry.manualId then
            if entry.expandable then
                DT_ManualUI.instance:toggleManualExpanded(entry.manualId)
                DT_ManualUI.instance:refreshNavigation()
            end
            return
        end

        if entry.expandable then
            DT_ManualUI.instance:ensureExpandedPath(entry.manualId)
        end

        DT_ManualUI.instance:openLocation({ manualId = entry.manualId })
        return
    end

    if entry.kind == "chapter" then
        local isCurrentChapter = false

        if DT_ManualUI.instance.currentPageId then
            local _, cp = DT_ManualUI.instance:resolvePage(DT_ManualUI.instance.currentManualId, DT_ManualUI.instance.currentPageId)
            if cp and cp.chapterId == entry.chapterId then
                isCurrentChapter = true
            end
        end

        if isCurrentChapter then
            if entry.expandable then
                DT_ManualUI.instance:toggleChapterExpanded(entry.manualId, entry.chapterId)
                DT_ManualUI.instance:refreshNavigation()
            end
            return
        end

        if entry.expandable then
            DT_ManualUI.instance:ensureExpandedPath(entry.manualId, entry.chapterId)
        end

        if entry.firstPageId then
            DT_ManualUI.instance:openLocation({ manualId = entry.manualId, pageId = entry.firstPageId })
        else
            DT_ManualUI.instance:openLocation({ manualId = entry.manualId })
        end
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

    if entry.kind == "image" then
        if DT_ManualUI_ImageModal and DT_ManualUI_ImageModal.Open then
            DT_ManualUI_ImageModal.Open(entry)
        end
        return
    end

    if entry.kind == "library" then
        DT_ManualUI.instance:openLocation({ manualId = entry.manualId })
    end
end
