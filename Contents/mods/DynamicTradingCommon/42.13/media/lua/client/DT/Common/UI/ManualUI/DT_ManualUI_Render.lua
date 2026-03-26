require "DT/Common/UI/ManualUI/DT_ManualUI_Definition"
require "DT/Common/UI/ManualUI/DT_ManualUI_Utils"

function DT_ManualUI:prepareBlock(block)
    block = block or {}
    local kind = tostring(block.type or "paragraph")
    local width = math.max(self.contentList:getWidth() - 30, 180)
    local payload = {
        kind = kind,
        id = block.id,
        title = block.title,
        tone = block.tone or "info",
        caption = block.caption,
        path = block.path,
        width = tonumber(block.width) or 220,
        height = tonumber(block.height) or 140,
    }

    if kind == "heading" then
        payload.level = tonumber(block.level) or 1
        payload.font = DT_ManualUI_Utils.FONT_BY_LEVEL[payload.level] or UIFont.Medium
        payload.lines = DynamicTrading.Utils.WrapText(block.text or "", width - 10, payload.font)
        payload.height = (#payload.lines * 22) + 18
        payload.label = block.text or ""
        return payload
    end

    if kind == "bullet_list" then
        payload.lines = {}
        for _, item in ipairs(block.items or {}) do
            local wrapped = DynamicTrading.Utils.WrapText("• " .. tostring(item), width - 16, UIFont.NewSmall)
            for _, line in ipairs(wrapped) do
                table.insert(payload.lines, line)
            end
        end
        payload.height = math.max((#payload.lines * 18) + 16, 36)
        payload.label = table.concat(payload.lines, " ")
        return payload
    end

    if kind == "image" then
        payload.texture = DT_ManualUI_Utils.resolveTexture(block.path)
        payload.height = DT_ManualUI_Utils.clamp(payload.height, 80, 280) + (block.caption and 24 or 10)
        payload.label = block.caption or block.path or ""
        return payload
    end

    if kind == "callout" then
        payload.font = UIFont.NewSmall
        local text = ""
        if block.title and block.title ~= "" then
            text = tostring(block.title) .. ": "
        end
        text = text .. tostring(block.text or "")
        payload.lines = DynamicTrading.Utils.WrapText(text, width - 20, payload.font)
        payload.height = (#payload.lines * 18) + 20
        payload.label = text
        return payload
    end

    payload.font = UIFont.NewSmall
    payload.lines = DynamicTrading.Utils.WrapText(block.text or "", width - 10, payload.font)
    payload.height = (#payload.lines * 18) + 16
    payload.label = block.text or ""
    return payload
end

function DT_ManualUI:drawNavItem(y, item, alt)
    local row = item.item
    local width = self:getWidth() - 4
    local height = item.height or self.itemheight
    local indent = (row.depth or 0) * 18
    local isSelected = row.selected == true
    local isHovered = self.mouseoverselected == item.index

    local bgA, bgR, bgG, bgB = 0.25, 0.08, 0.08, 0.08
    if isSelected then
        bgA, bgR, bgG, bgB = 0.55, 0.15, 0.28, 0.42
    elseif isHovered then
        bgA, bgR, bgG, bgB = 0.4, 0.16, 0.16, 0.16
    end

    self:drawRect(0, y, width, height - 1, bgA, bgR, bgG, bgB)
    local titleFont = row.kind == "manual" and UIFont.Medium or self.font
    local titleY = row.kind == "manual" and (y + 6) or (y + 4)
    self:drawText(tostring(row.title or ""), 8 + indent, titleY, 0.95, 0.95, 0.95, 1, titleFont)

    if row.kind == "manual" and row.subtitle and row.subtitle ~= "" then
        self:drawText(DynamicTrading.Utils.TruncateString(row.subtitle, UIFont.Small, width - 24 - indent), 8 + indent, y + 28, 0.65, 0.65, 0.65, 1, UIFont.Small)
    end

    return y + height
end

function DT_ManualUI:drawResultItem(y, item, alt)
    local row = item.item
    local width = self:getWidth() - 4
    local height = item.height or self.itemheight
    local isHovered = self.mouseoverselected == item.index

    self:drawRect(0, y, width, height - 1, isHovered and 0.4 or 0.25, 0.12, 0.12, 0.12)
    self:drawText(tostring(row.label or ""), 8, y + 4, 0.95, 0.95, 0.95, 1, UIFont.Small)
    self:drawText(DynamicTrading.Utils.TruncateString(tostring(row.path or ""), UIFont.Small, width - 16), 8, y + 20, 0.70, 0.85, 0.95, 1, UIFont.Small)
    self:drawText(DynamicTrading.Utils.TruncateString(tostring(row.snippet or ""), UIFont.Small, width - 16), 8, y + 34, 0.70, 0.70, 0.70, 1, UIFont.Small)
    return y + height
end

function DT_ManualUI:drawContentItem(y, item, alt)
    local block = item.item
    local width = self:getWidth() - 6
    local height = item.height or self.itemheight
    local padding = 8

    if block.kind == "library" then
        self:drawRect(0, y, width, height - 1, 0.30, 0.10, 0.10, 0.10)
        self:drawText(tostring(block.title or ""), 10, y + 8, 1, 1, 1, 1, UIFont.Medium)
        self:drawText(DynamicTrading.Utils.TruncateString(tostring(block.description or ""), UIFont.Small, width - 20), 10, y + 34, 0.75, 0.75, 0.75, 1, UIFont.Small)
        return y + height
    end

    if block.kind == "heading" then
        local isHighlighted = block.id and block.id == DT_ManualUI.instance.highlightSectionId
        self:drawRect(0, y, width, height - 1, isHighlighted and 0.45 or 0.12, isHighlighted and 0.25 or 0.08, isHighlighted and 0.22 or 0.08, isHighlighted and 0.10 or 0.08)
        local font = block.font or UIFont.Medium
        local lineY = y + 8
        for _, line in ipairs(block.lines or {}) do
            self:drawText(line, padding, lineY, 1, 0.92, 0.70, 1, font)
            lineY = lineY + 22
        end
        if block.id then
            local anchorText = "#" .. tostring(block.id)
            local anchorW = DT_ManualUI_Utils.safeMeasure(UIFont.Small, anchorText)
            self:drawText(anchorText, width - anchorW - 8, y + 6, 0.55, 0.55, 0.55, 1, UIFont.Small)
        end
        return y + height
    end

    if block.kind == "image" then
        self:drawRect(0, y, width, height - 1, 0.20, 0.08, 0.08, 0.08)
        local drawW = DT_ManualUI_Utils.clamp(block.width or 220, 80, width - (padding * 2))
        local drawH = DT_ManualUI_Utils.clamp((block.height or 140), 80, height - 24)
        if block.caption and block.caption ~= "" then
            drawH = DT_ManualUI_Utils.clamp(drawH, 80, height - 34)
        end
        local drawX = padding
        local drawY = y + padding

        if block.texture then
            self:drawTextureScaled(block.texture, drawX, drawY, drawW, drawH, 1, 1, 1, 1)
        else
            self:drawRect(drawX, drawY, drawW, drawH, 0.35, 0.18, 0.18, 0.18)
            self:drawTextCentre("Missing Image", drawX + (drawW / 2), drawY + (drawH / 2) - 8, 0.8, 0.6, 0.6, 1, UIFont.Small)
        end

        self:drawRectBorder(drawX, drawY, drawW, drawH, 0.8, 0.5, 0.5, 0.5)
        if block.caption and block.caption ~= "" then
            self:drawText(block.caption, drawX, drawY + drawH + 6, 0.75, 0.75, 0.75, 1, UIFont.Small)
        end
        return y + height
    end

    if block.kind == "callout" then
        local tone = tostring(block.tone or "info")
        local r, g, b = 0.12, 0.19, 0.26
        if tone == "warn" then
            r, g, b = 0.28, 0.18, 0.08
        elseif tone == "success" then
            r, g, b = 0.10, 0.22, 0.13
        end
        self:drawRect(0, y, width, height - 1, 0.42, r, g, b)
        local lineY = y + 8
        for _, line in ipairs(block.lines or {}) do
            self:drawText(line, padding, lineY, 0.97, 0.97, 0.97, 1, UIFont.NewSmall)
            lineY = lineY + 18
        end
        return y + height
    end

    self:drawRect(0, y, width, height - 1, 0.10, 0.06, 0.06, 0.06)
    local lineY = y + 8
    for _, line in ipairs(block.lines or {}) do
        self:drawText(line, padding, lineY, 0.92, 0.92, 0.92, 1, UIFont.NewSmall)
        lineY = lineY + 18
    end

    return y + height
end
