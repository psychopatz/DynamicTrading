require "DT/Common/UI/ManualUI/DT_ManualUI_Definition"
require "DT/Common/UI/ManualUI/DT_ManualUI_Utils"

function DT_ManualUI:loadManualData()
    local registry = DynamicTrading.Manuals and DynamicTrading.Manuals.Registry or {}
    local orderedIds = DynamicTrading.Manuals and DynamicTrading.Manuals.Order or {}

    self.manuals = {}
    self.pageByManual = {}
    self.pageLookup = {}
    self.blockSectionIndex = {}

    for _, manualId in ipairs(orderedIds) do
        if registry[manualId] then
            table.insert(self.manuals, registry[manualId])
        end
    end

    for manualId, manual in pairs(registry) do
        local tracked = false
        for _, existing in ipairs(self.manuals) do
            if existing.id == manualId then
                tracked = true
                break
            end
        end
        if not tracked then
            table.insert(self.manuals, manual)
        end
    end

    table.sort(self.manuals, function(a, b)
        return DT_ManualUI_Utils.lowercase(a.title) < DT_ManualUI_Utils.lowercase(b.title)
    end)

    for _, manual in ipairs(self.manuals) do
        local pageMap = {}
        for _, page in ipairs(manual.pages or {}) do
            pageMap[page.id] = page
            self.pageLookup[manual.id .. "::" .. tostring(page.id)] = {
                manual = manual,
                page = page,
            }

            local sectionMap = {}
            for index, block in ipairs(page.blocks or {}) do
                if block.type == "heading" and block.id then
                    sectionMap[block.id] = index
                end
            end
            self.blockSectionIndex[manual.id .. "::" .. tostring(page.id)] = sectionMap
        end
        self.pageByManual[manual.id] = pageMap
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

    if not args.manualId and not args.pageId and not args.sectionId and args.library ~= true and not args.query then
        local saved = DT_ManualUI_Utils.getSavedLocation()
        if saved then
            args = saved
        end
    end

    local manual = nil
    local page = nil

    if args.library == true then
        self.currentManualId = nil
        self.currentPageId = nil
        self.highlightSectionId = nil
        self:refreshNavigation()
        self:refreshContent()
        return
    end

    if args.manualId and args.pageId then
        manual, page = self:resolvePage(args.manualId, args.pageId)
    elseif args.manualId then
        for _, candidate in ipairs(self.manuals) do
            if candidate.id == args.manualId then
                manual = candidate
                page = self:getStartPage(candidate)
                break
            end
        end
    elseif self.currentManualId and self.currentPageId then
        manual, page = self:resolvePage(self.currentManualId, self.currentPageId)
    end

    if not manual and #self.manuals > 0 then
        manual = self.manuals[1]
        page = self:getStartPage(manual)
    end

    self.currentManualId = manual and manual.id or nil
    self.currentPageId = page and page.id or nil
    self.highlightSectionId = args.sectionId

    self:refreshNavigation()
    self:refreshContent()

    if args.query and args.query ~= "" then
        if self.searchEntry then
            self.searchEntry:setText(tostring(args.query))
        end
        self:runSearch(args.query)
    end

    if manual and page and args.sectionId then
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
        local manualRow = {
            kind = "manual",
            manualId = manual.id,
            title = manual.title,
            subtitle = manual.description or "",
            depth = 0,
            selected = manual.id == self.currentManualId,
        }
        table.insert(self.navRows, manualRow)
        local manualItem = self.navList:addItem(manual.title, manualRow)
        manualItem.height = (manual.description and manual.description ~= "") and 54 or 30

        local chapters = manual.chapters or {}
        for _, chapter in ipairs(chapters) do
            local chapterRow = {
                kind = "chapter",
                manualId = manual.id,
                chapterId = chapter.id,
                title = chapter.title,
                subtitle = chapter.description or "",
                depth = 1,
                selected = false,
            }
            table.insert(self.navRows, chapterRow)
            local chapterItem = self.navList:addItem(chapter.title, chapterRow)
            chapterItem.height = 24

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
                    pageItem.height = 24
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
        item.height = 48
    end
end

function DT_ManualUI:refreshContent()
    self.contentList:clear()

    if not self.currentManualId or not self.currentPageId then
        self.pageTitle:setName("Manual Library")
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

    local manual, page = self:resolvePage(self.currentManualId, self.currentPageId)
    if not manual or not page then
        self.pageTitle:setName("Manual")
        return
    end

    self.pageTitle:setName(manual.title .. " / " .. page.title)

    for _, block in ipairs(page.blocks or {}) do
        local prepared = self:prepareBlock(block)
        local item = self.contentList:addItem(prepared.label or "", prepared)
        item.height = prepared.height or 36
    end

    if self.contentList.items and #self.contentList.items > 0 then
        self.contentList:ensureVisible(1)
    end
end
