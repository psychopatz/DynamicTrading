require "Utils/DT_ConfigManager"

DT_ManualUI_Utils = DT_ManualUI_Utils or {}

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
    local leftWidth = 250
    local toolbarHeight = 28
    local pageTitleHeight = 28
    local showResults = DT_ManualUI_Utils.shouldShowResults(ui)
    local resultsHeight = showResults and 120 or 0
    local rightX = pad + leftWidth + pad
    local rightWidth = ui.width - rightX - pad
    local searchBottom = th + pad + toolbarHeight
    local resultsY = searchBottom + pad
    local pageTitleY = showResults and (resultsY + resultsHeight + pad) or (searchBottom + pad)
    local contentY = pageTitleY + pageTitleHeight
    local contentHeight = ui.height - contentY - pad

    return {
        pad = pad,
        titleBarHeight = th,
        leftWidth = leftWidth,
        toolbarHeight = toolbarHeight,
        pageTitleHeight = pageTitleHeight,
        resultsHeight = resultsHeight,
        rightX = rightX,
        rightWidth = rightWidth,
        showResults = showResults,
        searchBottom = searchBottom,
        resultsY = resultsY,
        pageTitleY = pageTitleY,
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
