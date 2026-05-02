require "DT/UI/Shared/DT_UIUtils"
local DebugData = require "DT/Common/UI/Debug/Abstract/DT_AbstractNormalizationDebugData"

DT_AbstractNormalizationDebugRenderers = DT_AbstractNormalizationDebugRenderers or {}

function DT_AbstractNormalizationDebugRenderers.drawRecordRow(listbox, y, item, alt)
    local ok, nextY = pcall(function()
        local row = item and item.item or nil
        local record = row and row.record or nil
        if not record then
            return y + (listbox and listbox.itemheight or 44)
        end

        DT_UIUtils.drawSelectionHighlight(listbox, y, item, alt)

        local padding = 8
        local swatchX = padding
        local swatchY = y + 7
        local swatchSize = 12
        local textX = swatchX + swatchSize + 8
        local bucketColor = row.bucketColor or { r = 0.85, g = 0.85, b = 0.85 }
        local headerText = tostring(record.displayName or record.fullType or item.text or "Unknown")
        local detailText = tostring(record.fullType or "")
            .. " | "
            .. "Category: " .. tostring(row.categoryLabel or row.bucketLabel or record.primaryBucket or "")
            .. " | "
            .. "Units: " .. tostring(record.normalizedUnits or 0)
            .. " | "
            .. "Confidence: " .. tostring(record.confidence or 0) .. "%"

        listbox:drawRect(swatchX, swatchY, swatchSize, swatchSize, 1, bucketColor.r or 0.9, bucketColor.g or 0.9, bucketColor.b or 0.9)
        listbox:drawText(headerText, textX, y + 3, 1, 1, 1, 1, UIFont.Small)
        listbox:drawText(detailText, textX, y + 20, 0.72, 0.78, 0.86, 1, UIFont.Small)

        return y + listbox.itemheight
    end)

    if ok then
        return nextY
    end

    if DynamicTrading and DynamicTrading.Log then
        DynamicTrading.Log("DTCommons", "Debug", "UI", "drawRecordRow failed: " .. tostring(nextY))
    end
    return y + (listbox and listbox.itemheight or 44)
end
