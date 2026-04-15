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
        for _, page in ipairs(manual.pages or {}) do
            local chapterTitle = DT_ManualUI_Utils.findChapterTitle(manual, page.chapterId)

            if DT_ManualUI_Utils.lowercase(manual.title):find(needle, 1, true) or DT_ManualUI_Utils.lowercase(page.title):find(needle, 1, true) then
                table.insert(self.results, {
                    manualId = manual.id,
                    pageId = page.id,
                    sectionId = nil,
                    label = page.title,
                    path = manual.title .. " / " .. chapterTitle,
                    snippet = manual.description or chapterTitle,
                })
            end

            for _, keyword in ipairs(page.keywords or {}) do
                if DT_ManualUI_Utils.lowercase(keyword):find(needle, 1, true) then
                    table.insert(self.results, {
                        manualId = manual.id,
                        pageId = page.id,
                        sectionId = nil,
                        label = page.title,
                        path = manual.title .. " / " .. chapterTitle,
                        snippet = "Keyword: " .. tostring(keyword),
                    })
                    break
                end
            end

            for _, block in ipairs(page.blocks or {}) do
                local text = ""
                if block.type == "heading" then
                    text = tostring(block.text or "")
                elseif block.type == "paragraph" then
                    text = tostring(block.text or "")
                elseif block.type == "callout" then
                    text = tostring(block.title or "") .. " " .. tostring(block.text or "")
                elseif block.type == "bullet_list" then
                    text = table.concat(block.items or {}, " ")
                elseif block.type == "image" then
                    text = tostring(block.caption or "")
                elseif block.type == "supporter_carousel" then
                    local names = {}
                    for _, supporter in ipairs(block.supporters or {}) do
                        if supporter.active ~= false then
                            table.insert(names, tostring(supporter.name or ""))
                        end
                    end
                    text = tostring(block.title or "") .. " " .. table.concat(names, " ") .. " " .. tostring(block.thankYouText or block.thank_you_text or "")
                end

                if DT_ManualUI_Utils.lowercase(text):find(needle, 1, true) then
                    table.insert(self.results, {
                        manualId = manual.id,
                        pageId = page.id,
                        sectionId = block.id,
                        label = page.title,
                        path = manual.title .. " / " .. chapterTitle,
                        snippet = text,
                    })
                end
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
