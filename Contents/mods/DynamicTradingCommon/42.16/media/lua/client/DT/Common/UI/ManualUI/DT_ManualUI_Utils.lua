DT_ManualUI_Utils = DT_ManualUI_Utils or {}

require "Utils/ConfigManager/DT_ConfigManager"

-- Reusable string wrapper for all manual UI text
function DT_ManualUI_Utils.WrapManualText(text, maxWidth, font)
    if not DynamicTrading or not DynamicTrading.Utils or not DynamicTrading.Utils.WrapText then
        return { tostring(text or "") }
    end
    return DynamicTrading.Utils.WrapText(tostring(text or ""), maxWidth, font or UIFont.Small)
end

DT_ManualUI_Utils.FONT_BY_LEVEL = {
    [1] = UIFont.Large,
    [2] = UIFont.Medium,
    [3] = UIFont.Small,
}

function DT_ManualUI_Utils.clamp(value, minValue, maxValue)
    if value < minValue then return minValue end
    if value > maxValue then return maxValue end
    return value
end

function DT_ManualUI_Utils.lowercase(value)
    return string.lower(tostring(value or ""))
end

function DT_ManualUI_Utils.safeMeasure(font, text)
    return getTextManager():MeasureStringX(font, tostring(text or ""))
end

function DT_ManualUI_Utils.truncateToWidth(text, width, font)
    local value = tostring(text or "")
    width = math.max(20, tonumber(width) or 20)
    font = font or UIFont.Small

    if value == "" or DT_ManualUI_Utils.safeMeasure(font, value) <= width then
        return value
    end

    local suffix = "..."
    local clipped = value

    while #clipped > 0 do
        clipped = string.sub(clipped, 1, #clipped - 1)
        local candidate = clipped .. suffix
        if DT_ManualUI_Utils.safeMeasure(font, candidate) <= width then
            return candidate
        end
    end

    return suffix
end

function DT_ManualUI_Utils.limitWrappedLines(text, width, font, maxLines)
    font = font or UIFont.Small
    width = math.max(20, tonumber(width) or 20)

    local wrapped = DT_ManualUI_Utils.WrapManualText(text, width, font)
    local normalized = {}

    for _, line in ipairs(wrapped or {}) do
        table.insert(normalized, DT_ManualUI_Utils.truncateToWidth(line, width, font))
    end

    if not maxLines or maxLines <= 0 or #normalized <= maxLines then
        return normalized
    end

    local limited = {}
    for index = 1, maxLines do
        limited[index] = normalized[index]
    end

    limited[maxLines] = DT_ManualUI_Utils.truncateToWidth(limited[maxLines], width, font)
    return limited
end

function DT_ManualUI_Utils.hasSearchQuery(ui)
    if not ui or not ui.searchEntry or not ui.searchEntry.getText then
        return false
    end
    return tostring(ui.searchEntry:getText() or "") ~= ""
end

function DT_ManualUI_Utils.shouldShowResults(ui)
    if DT_ManualUI_Utils.hasSearchQuery(ui) then
        return true
    end
    return ui and ui.results and #ui.results > 0
end

function DT_ManualUI_Utils.getLayoutMetrics(ui)
    local pad = 10
    local th = ui:titleBarHeight()
    local leftWidth = (ui and ui._currentNavWidth) and ui._currentNavWidth or 250
    leftWidth = math.floor(leftWidth)

    local toolbarHeight = 28
    local pageTitleHeight = 28
    local updateToggleHeight = (ui and ui.showUpdateToggle) and 28 or 0

    local navContextLineCount = math.max(1, math.min(3, math.floor(tonumber(ui and ui._navContextLineCount) or 1)))
    local navHeaderHeight = math.max(24, (navContextLineCount * 16) + 8)
    local navHeaderY = th + pad
    local navListY = navHeaderY + navHeaderHeight + 4
    local navListHeight = math.max(60, ui:getHeight() - navListY - pad)

    local supportBannerHeight = 0
    if ui and ui.showSupportBanner then
        if ui.supportBannerPanel and ui.supportBannerPanel:getHeight() > 0 then
            supportBannerHeight = ui.supportBannerPanel:getHeight()
        else
            supportBannerHeight = 78
        end
    end

    local showResults = DT_ManualUI_Utils.shouldShowResults(ui)
    local resultsHeight = showResults and math.max(120, math.min(300, ui:getHeight() * 0.4)) or 0

    local rightX = pad + leftWidth + pad
    local rightWidth = ui:getWidth() - rightX - pad

    local supportBannerY = th + pad
    local searchBarY = supportBannerY + supportBannerHeight
    if supportBannerHeight > 0 then
        searchBarY = searchBarY + pad
    end

    local searchBottom = searchBarY + toolbarHeight
    local resultsY = searchBottom + pad
    local pageTitleY = showResults and (resultsY + resultsHeight + pad) or (searchBottom + pad)
    local updateToggleY = pageTitleY + pageTitleHeight
    local contentY = updateToggleY + updateToggleHeight
    local contentHeight = ui:getHeight() - contentY - pad

    return {
        pad = pad,
        titleBarHeight = th,
        leftWidth = leftWidth,

        navContextLineCount = navContextLineCount,
        navHeaderHeight = navHeaderHeight,
        navHeaderY = navHeaderY,
        navListY = navListY,
        navListHeight = navListHeight,

        toolbarHeight = toolbarHeight,
        pageTitleHeight = pageTitleHeight,
        resultsHeight = resultsHeight,
        rightX = rightX,
        rightWidth = rightWidth,
        showResults = showResults,
        searchBarY = searchBarY,
        searchBottom = searchBottom,
        resultsY = resultsY,
        pageTitleY = pageTitleY,
        updateToggleHeight = updateToggleHeight,
        updateToggleY = updateToggleY,
        supportBannerHeight = supportBannerHeight,
        supportBannerY = supportBannerY,
        contentY = contentY,
        contentHeight = contentHeight,
    }
end

function DT_ManualUI_Utils.getSavedLocation()
    if not DT_ConfigManager or not DT_ConfigManager.getLastManualLocation then
        return nil
    end

    local saved = DT_ConfigManager.getLastManualLocation()
    if not saved then
        return nil
    end

    local hasAnyValue = tostring(saved.manualId or "") ~= "" or tostring(saved.pageId or "") ~= "" or tostring(saved.sectionId or "") ~= ""
    if not hasAnyValue then
        return nil
    end

    return {
        manualId = tostring(saved.manualId or "") ~= "" and saved.manualId or nil,
        pageId = tostring(saved.pageId or "") ~= "" and saved.pageId or nil,
        sectionId = tostring(saved.sectionId or "") ~= "" and saved.sectionId or nil,
    }
end

function DT_ManualUI_Utils.drawMarkdownLines(ui, lines, startX, startY, baseR, baseG, baseB, a, font, lineSpacing)
    if not lines then return startY end

    local state = { b=false, i=false, u=false }
    local lineHeight = getTextManager():getFontHeight(font)
    local currentY = startY

    for _, line in ipairs(lines) do
        local currentX = startX
        local currentStr = ""
        local i = 1

        local function drawSegment(str, st)
            if not str or str == "" then return end
            local r, g, b = baseR, baseG, baseB
            if st.b then r, g, b = 1, 0.90, 0.55 end
            if st.i then r, g, b = 0.55, 0.85, 0.95 end

            ui:drawText(str, currentX, currentY, r, g, b, a, font)

            local width = getTextManager():MeasureStringX(font, str)
            if st.u then
                ui:drawRect(currentX, currentY + lineHeight - 2, width, 1, a, r, g, b)
            end

            currentX = currentX + width
        end

        while i <= #line do
            local c = string.sub(line, i, i)
            local nextC = string.sub(line, i + 1, i + 1)

            if c == "*" and nextC == "*" then
                drawSegment(currentStr, state)
                currentStr = ""
                state.b = not state.b
                i = i + 2
            elseif c == "*" then
                drawSegment(currentStr, state)
                currentStr = ""
                state.i = not state.i
                i = i + 1
            elseif c == "_" and nextC == "_" then
                drawSegment(currentStr, state)
                currentStr = ""
                state.u = not state.u
                i = i + 2
            elseif c == "_" then
                drawSegment(currentStr, state)
                currentStr = ""
                state.u = not state.u
                i = i + 1
            else
                currentStr = currentStr .. c
                i = i + 1
            end
        end

        drawSegment(currentStr, state)
        currentY = currentY + lineSpacing
    end

    return currentY
end

function DT_ManualUI_Utils.findChapterTitle(manual, chapterId)
    for _, chapter in ipairs(manual.chapters or {}) do
        if chapter.id == chapterId then
            return chapter.title or ""
        end
    end
    return ""
end

function DT_ManualUI_Utils.resolveTexture(path)
    local normalized = tostring(path or ""):gsub("\\", "/")
    if normalized == "" then
        return nil
    end

    local texture = getTexture(normalized)
    if texture then
        return texture
    end

    if string.sub(normalized, 1, 1) == "/" then
        texture = getTexture(string.sub(normalized, 2))
        if texture then
            return texture
        end
    end

    if string.sub(normalized, 1, 6) ~= "media/" then
        texture = getTexture("media/" .. normalized)
        if texture then
            return texture
        end
    end

    return nil
end
