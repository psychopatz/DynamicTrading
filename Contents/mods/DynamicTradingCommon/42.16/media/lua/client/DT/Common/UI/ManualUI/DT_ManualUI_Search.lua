require "DT/Common/UI/ManualUI/DT_ManualUI_Definition"
require "DT/Common/UI/ManualUI/DT_ManualUI_Utils"

function DT_ManualUI:runSearch(query)
    local needle = DT_ManualUI_Utils.lowercase(query)
    self.results = {}

    if needle == "" then
        self:refreshResults()
        return
    end

    for _, manual in ipairs(self.manuals) do
        local pageMap = self.pageByManual and self.pageByManual[manual.id] or {}
        local records = DynamicTrading
            and DynamicTrading.Manuals
            and DynamicTrading.Manuals.GetManualSearchRecords
            and DynamicTrading.Manuals.GetManualSearchRecords(manual)
            or {}

        for _, record in ipairs(records) do
            if tostring(record.haystack or ""):find(needle, 1, true) then
                local page = pageMap and pageMap[record.pageId] or nil
                local chapterTitle = DT_ManualUI_Utils.findChapterTitle(manual, page and page.chapterId or nil)

                table.insert(self.results, {
                    manualId = manual.id,
                    pageId = record.pageId,
                    sectionId = record.sectionId,
                    label = page and page.title or "",
                    path = manual.title .. " / " .. chapterTitle,
                    snippet = record.snippet,
                })
            end
        end
    end

    table.sort(self.results, function(a, b)
        if a.path == b.path then
            return DT_ManualUI_Utils.lowercase(a.label) < DT_ManualUI_Utils.lowercase(b.label)
        end
        return DT_ManualUI_Utils.lowercase(a.path) < DT_ManualUI_Utils.lowercase(b.path)
    end)

    if #self.results > 50 then
        local trimmed = {}
        for i = 1, 50 do
            trimmed[i] = self.results[i]
        end
        self.results = trimmed
    end

    self:refreshResults()
end
