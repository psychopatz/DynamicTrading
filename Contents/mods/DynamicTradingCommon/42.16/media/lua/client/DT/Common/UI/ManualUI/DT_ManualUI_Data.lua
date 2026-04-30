require "DT/Common/UI/ManualUI/DT_ManualUI_Definition"
require "DT/Common/UI/ManualUI/DT_ManualUI_Utils"

local function applyDynamicNavHeight(ui, item, row)
    if not ui or not item or not row then
        return
    end

    if ui.getNavRowHeight and ui.navList then
        item.height = ui:getNavRowHeight(row, ui.navList:getWidth())
    end
end

local function getManualContentAPI()
    return DynamicTrading and DynamicTrading.Manuals or nil
end

local function ensureManualContent(manual)
    local manualsAPI = getManualContentAPI()
    if manualsAPI and manualsAPI.EnsureManualContent then
        return manualsAPI.EnsureManualContent(manual)
    end

    return {
        chapters = manual and manual.chapters or {},
        pages = manual and manual.pages or {},
    }
end

local function getManualContentPages(manual)
    local content = ensureManualContent(manual)
    return content and content.pages or {}
end

local function getManualContentPage(manual, pageId)
    for _, page in ipairs(getManualContentPages(manual)) do
        if tostring(page.id or "") == tostring(pageId or "") then
            return page
        end
    end

    return nil
end

function DT_ManualUI:loadManualData()
    local registry = DynamicTrading.Manuals and DynamicTrading.Manuals.Registry or {}

    self.manuals = {}
    self.allManuals = {}
    self.pageByManual = {}
    self.pageLookup = {}
    self.blockSectionIndex = {}

    if DynamicTrading.Manuals and self.viewMode == "updates" and DynamicTrading.Manuals.GetOrderedUpdateManuals then
        self.manuals = DynamicTrading.Manuals.GetOrderedUpdateManuals()
    elseif DynamicTrading.Manuals and DynamicTrading.Manuals.GetOrderedLibraryManuals then
        self.manuals = DynamicTrading.Manuals.GetOrderedLibraryManuals()
    else
        for _, manual in pairs(registry) do
            table.insert(self.manuals, manual)
        end
    end

    for _, manual in pairs(registry) do
        self.allManuals[manual.id] = manual
    end

    for _, manual in pairs(self.allManuals) do
        local pageMap = {}

        for _, page in ipairs(manual.pages or {}) do
            pageMap[page.id] = page
            self.pageLookup[manual.id .. "::" .. tostring(page.id)] = {
                manual = manual,
                page = page,
            }
        end

        self.pageByManual[manual.id] = pageMap
    end

    self:refreshSupportBannerState()
end

function DT_ManualUI:refreshSupportBannerState()
    local manual = DynamicTrading.Manuals and DynamicTrading.Manuals.GetLatestManualByType and DynamicTrading.Manuals.GetLatestManualByType("support") or nil
    local version = manual and tostring(manual.popupVersion or manual.releaseVersion or manual.id or "") or ""
    local donorManual = DynamicTrading.Manuals and DynamicTrading.Manuals.GetLatestManualByType and DynamicTrading.Manuals.GetLatestManualByType("donators") or nil
    local donorBlock = DT_ManualUI_Donators and DT_ManualUI_Donators.GetPrimaryCarouselBlock and DT_ManualUI_Donators.GetPrimaryCarouselBlock(donorManual) or nil
    local donorSupporters = DT_ManualUI_Donators and DT_ManualUI_Donators.GetActiveSupportersFromBlock and DT_ManualUI_Donators.GetActiveSupportersFromBlock(donorBlock) or {}

    self.supportBannerManual = manual
    self.supportBannerVersion = version
    self.hallOfFameManual = donorManual
    self.hallOfFameSupporters = donorSupporters
    self.hallOfFameAutoplayMs = donorBlock and tonumber(donorBlock.autoplayMs or donorBlock.autoplay_ms) or 4000
    self.hallOfFameCurrencySymbol = donorBlock and tostring(donorBlock.currencySymbol or donorBlock.currency_symbol or "$") or "$"

    local viewingSupport = manual ~= nil and self.currentManualId == manual.id
    local viewingDonators = donorManual ~= nil and self.currentManualId == donorManual.id

    self.showSupportBanner = manual ~= nil and version ~= "" and not viewingSupport and not viewingDonators
end

function DT_ManualUI:isManualExpanded(manualId)
    local key = tostring(manualId or "")
    if self.expandedManuals == nil then self.expandedManuals = {} end
    local state = self.expandedManuals[key]
    if state ~= nil then return state end
    return manualId == self.currentManualId
end

function DT_ManualUI:isChapterExpanded(manualId, chapterId)
    local key = tostring(manualId or "") .. "::" .. tostring(chapterId or "")
    if self.expandedChapters == nil then self.expandedChapters = {} end
    local state = self.expandedChapters[key]
    if state ~= nil then return state end
    return manualId == self.currentManualId
end

function DT_ManualUI:toggleManualExpanded(manualId)
    local key = tostring(manualId or "")
    if self.expandedManuals == nil then self.expandedManuals = {} end
    self.expandedManuals[key] = not self:isManualExpanded(manualId)
end

function DT_ManualUI:toggleChapterExpanded(manualId, chapterId)
    local key = tostring(manualId or "") .. "::" .. tostring(chapterId or "")
    if self.expandedChapters == nil then self.expandedChapters = {} end
    self.expandedChapters[key] = not self:isChapterExpanded(manualId, chapterId)
end

function DT_ManualUI:ensureExpandedPath(manualId, chapterId)
    if self.expandedManuals == nil then self.expandedManuals = {} end
    if self.expandedChapters == nil then self.expandedChapters = {} end

    if manualId then
        self.expandedManuals[tostring(manualId)] = true
    end

    if manualId and chapterId then
        self.expandedChapters[tostring(manualId) .. "::" .. tostring(chapterId)] = true
    end
end

function DT_ManualUI:resolvePage(manualId, pageId)
    local key = tostring(manualId or "") .. "::" .. tostring(pageId or "")
    local resolved = self.pageLookup[key]

    if resolved then
        return resolved.manual, resolved.page
    end

    return nil, nil
end

function DT_ManualUI:resolveLoadedPage(manualId, pageId)
    local manual = self.allManuals and self.allManuals[manualId] or nil
    if not manual then
        return nil, nil
    end

    local page = getManualContentPage(manual, pageId)
    if not page then
        return manual, nil
    end

    local key = tostring(manual.id or "") .. "::" .. tostring(page.id or "")
    if not self.blockSectionIndex[key] then
        local sectionMap = {}
        for index, block in ipairs(page.blocks or {}) do
            if block.type == "heading" and block.id then
                sectionMap[block.id] = index
            end
        end
        self.blockSectionIndex[key] = sectionMap
    end

    return manual, page
end

function DT_ManualUI:getStartPage(manual)
    if not manual then return nil end

    if manual.startPageId then
        local page = self.pageByManual[manual.id] and self.pageByManual[manual.id][manual.startPageId]
        if page then
            return page
        end
    end

    return manual.pages and manual.pages[1] or nil
end

function DT_ManualUI:openLocation(args)
    args = args or {}

    if self.viewMode ~= "updates" and not args.manualId and not args.pageId and not args.sectionId and args.library ~= true and not args.query then
        local saved = DT_ManualUI_Utils.getSavedLocation()
        if saved then
            args = saved
        end
    end

    local manual = nil
    local page = nil

    if args.library == true then
        local manualsAPI = getManualContentAPI()
        if manualsAPI and manualsAPI.ReleaseAllManualContent then
            manualsAPI.ReleaseAllManualContent(nil)
        end

        self.currentManualId = nil
        self.currentPageId = nil
        self.currentManualType = "manual"
        self.currentPopupVersion = ""
        self.highlightSectionId = nil
        self:refreshSupportBannerState()
        self:refreshNavigation()
        self:refreshContent()
        return
    end

    if args.manualId and args.pageId then
        manual, page = self:resolvePage(args.manualId, args.pageId)
    elseif args.manualId then
        local candidate = self.allManuals and self.allManuals[args.manualId] or nil
        if candidate then
            manual = candidate
            page = self:getStartPage(candidate)
        end
    elseif self.currentManualId and self.currentPageId then
        manual, page = self:resolvePage(self.currentManualId, self.currentPageId)
    end

    if not manual and #self.manuals > 0 then
        if DynamicTrading.Manuals and DynamicTrading.Manuals.GetDefaultManual then
            manual = DynamicTrading.Manuals.GetDefaultManual(self.manuals)
        end

        manual = manual or self.manuals[1]
        page = self:getStartPage(manual)
    end

    self.currentManualId = manual and manual.id or nil
    self.currentPageId = page and page.id or nil
    self.highlightSectionId = args.sectionId
    self.currentReleaseVersion = manual and manual.releaseVersion or nil
    self.currentManualType = manual and tostring(manual.manualType or "manual") or "manual"
    self.currentPopupVersion = manual and tostring(manual.popupVersion or manual.releaseVersion or "") or ""

    if manual and self.currentManualType == "whats_new" and self.currentPopupVersion ~= "" then
        if DT_ConfigManager and DT_ConfigManager.setLastSeenReleaseVersion then
            DT_ConfigManager.setLastSeenReleaseVersion(self.currentPopupVersion)
        end
    end

    if manual then
        local manualsAPI = getManualContentAPI()
        if manualsAPI and manualsAPI.ReleaseAllManualContent then
            manualsAPI.ReleaseAllManualContent(manual.id)
        end

        self:ensureExpandedPath(manual.id, page and page.chapterId or nil)
    end

    self:refreshSupportBannerState()
    self:refreshNavigation()
    self:refreshContent()

    if args.query and args.query ~= "" then
        if self.searchEntry then
            self.searchEntry:setText(tostring(args.query))
        end
        self:runSearch(args.query)
    end

    if manual and page and args.sectionId then
        self:resolveLoadedPage(manual.id, page.id)
        local blockIndex = self.blockSectionIndex[(manual.id .. "::" .. page.id)]
        blockIndex = blockIndex and blockIndex[args.sectionId] or nil
        if blockIndex and self.contentList then
            self.contentList.selected = blockIndex
            self.contentList:ensureVisible(blockIndex)
        end
    end
end

function DT_ManualUI:refreshNavigation()
    self.navList:clear()
    self.navRows = {}

    for _, manual in ipairs(self.manuals) do
        local manualExpanded = self:isManualExpanded(manual.id)
        local chapters = manual.chapters or {}

        local manualRow = {
            kind = "manual",
            manualId = manual.id,
            title = manual.title,
            subtitle = manual.description or "",
            depth = 0,
            selected = manual.id == self.currentManualId,
            expandable = (#chapters > 0),
            expanded = manualExpanded,
        }

        table.insert(self.navRows, manualRow)
        local manualItem = self.navList:addItem(manual.title, manualRow)
        applyDynamicNavHeight(self, manualItem, manualRow)

        if manualExpanded then
            for _, chapter in ipairs(chapters) do
                local chapterExpanded = self:isChapterExpanded(manual.id, chapter.id)
                local firstPageId = nil
                local pageCount = 0

                for _, page in ipairs(manual.pages or {}) do
                    if page.chapterId == chapter.id then
                        pageCount = pageCount + 1
                        if not firstPageId then
                            firstPageId = page.id
                        end
                    end
                end

                local chapterRow = {
                    kind = "chapter",
                    manualId = manual.id,
                    chapterId = chapter.id,
                    title = chapter.title,
                    subtitle = chapter.description or "",
                    depth = 1,
                    selected = false,
                    expandable = pageCount > 0,
                    expanded = chapterExpanded,
                    firstPageId = firstPageId,
                }

                table.insert(self.navRows, chapterRow)
                local chapterItem = self.navList:addItem(chapter.title, chapterRow)
                applyDynamicNavHeight(self, chapterItem, chapterRow)

                if chapterExpanded then
                    for _, page in ipairs(manual.pages or {}) do
                        if page.chapterId == chapter.id then
                            local pageRow = {
                                kind = "page",
                                manualId = manual.id,
                                pageId = page.id,
                                chapterId = page.chapterId,
                                title = page.title,
                                subtitle = table.concat(page.keywords or {}, ", "),
                                depth = 2,
                                selected = page.id == self.currentPageId and manual.id == self.currentManualId,
                            }

                            table.insert(self.navRows, pageRow)
                            local pageItem = self.navList:addItem(page.title, pageRow)
                            applyDynamicNavHeight(self, pageItem, pageRow)
                        end
                    end
                end
            end
        end
    end
end

function DT_ManualUI:refreshResults()
    self:refreshLayout()
    self.resultList:clear()

    if not DT_ManualUI_Utils.shouldShowResults(self) then
        self.resultsLabel:setName("Search Results")
        return
    end

    if not self.results or #self.results == 0 then
        self.resultsLabel:setName("Search Results (0)")
        return
    end

    self.resultsLabel:setName("Search Results (" .. tostring(#self.results) .. ")")

    for _, result in ipairs(self.results) do
        local item = self.resultList:addItem(result.label, result)
        local width = self.resultList:getWidth() - 20
        local labelLines = DT_ManualUI_Utils.WrapManualText(item.item.label or "", width, UIFont.Small)
        local pathLines = DT_ManualUI_Utils.WrapManualText(tostring(item.item.path or ""), width, UIFont.Small)
        local snippetLines = DT_ManualUI_Utils.WrapManualText(tostring(item.item.snippet or ""), width, UIFont.Small)
        local h = 4 + (#labelLines * 16) + (#pathLines * 16) + (#snippetLines * 16) + 8
        item.height = math.max(h, 44)
    end
end

function DT_ManualUI:refreshContent()
    self.contentList:clear()

    if not self.currentManualId or not self.currentPageId then
        self.currentReleaseVersion = nil
        self.pageTitle:setName(self.viewMode == "updates" and "Update History" or "Manual Library")
        self:refreshUpdateControls()

        for _, manual in ipairs(self.manuals) do
            local item = self.contentList:addItem(manual.title, {
                kind = "library",
                manualId = manual.id,
                title = manual.title,
                description = manual.description or "",
            })
            item.height = 70
        end

        return
    end

    local manual, pageMeta = self:resolvePage(self.currentManualId, self.currentPageId)

    if not manual or not pageMeta then
        self.currentReleaseVersion = nil
        self.pageTitle:setName(self.viewMode == "updates" and "Update" or "Manual")
        self:refreshUpdateControls()
        return
    end

    local _, page = self:resolveLoadedPage(self.currentManualId, self.currentPageId)
    if not page then
        self.currentReleaseVersion = nil
        self.pageTitle:setName(self.viewMode == "updates" and "Update" or "Manual")
        self:refreshUpdateControls()
        return
    end

    self.currentReleaseVersion = manual.releaseVersion or nil
    self.pageTitle:setName(manual.title .. " / " .. page.title)
    self:refreshUpdateControls()

    for _, block in ipairs(page.blocks or {}) do
        local prepared = self:prepareBlock(block)
        local item = self.contentList:addItem(prepared.label or "", prepared)
        item.height = prepared.height or 36
    end

    if self.contentList.items and #self.contentList.items > 0 then
        self.contentList:ensureVisible(1)
    end
end
