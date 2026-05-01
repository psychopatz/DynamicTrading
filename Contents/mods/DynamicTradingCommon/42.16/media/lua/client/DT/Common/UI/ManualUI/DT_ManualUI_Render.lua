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
        width = tonumber(block.width) or 380,
        height = tonumber(block.height) or 220,
        _rawBlock = block,
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

        local tw = (payload.texture and payload.texture:getWidth() and payload.texture:getWidth() > 0) and payload.texture:getWidth() or (tonumber(block.width) or 380)
        local th = (payload.texture and payload.texture:getHeight() and payload.texture:getHeight() > 0) and payload.texture:getHeight() or (tonumber(block.height) or 220)

        local maxW = math.floor((width - 40) * 0.90)
        local drawW = math.min(maxW, math.max(tw, 380))
        local scale = drawW / tw
        local drawH = math.floor(th * scale)

        if drawH > 500 then
            drawH = 500
            scale = drawH / th
            drawW = math.floor(tw * scale)
        end

        payload.width = drawW
        payload.height = drawH + (block.caption and 34 or 24)
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

    if kind == "supporter_carousel" then
        payload.title = tostring(block.title or "Thank You")
        payload.autoplayMs = tonumber(block.autoplayMs or block.autoplay_ms) or 4000
        payload.currencySymbol = tostring(block.currencySymbol or block.currency_symbol or "$")
        payload.thankYouText = tostring(block.thankYouText or block.thank_you_text or "")
        payload.compact = (block.compact == true)
        payload.supporters = DT_ManualUI_Donators and DT_ManualUI_Donators.GetActiveSupportersFromBlock and DT_ManualUI_Donators.GetActiveSupportersFromBlock(block) or {}

        if payload.compact then
            payload.height = 170
        else
            local thankYouLines = {}
            local hasSupportMessages = false

            if payload.thankYouText ~= "" then
                thankYouLines = DynamicTrading.Utils.WrapText(payload.thankYouText, width - 30, UIFont.Small)
            end

            for _, supporter in ipairs(payload.supporters) do
                local supportMessage = tostring((supporter and supporter.supportMessage) or (supporter and supporter.support_message) or "")
                if supportMessage ~= "" then
                    hasSupportMessages = true
                    break
                end
            end

            payload.height = (hasSupportMessages and 420 or 350) + (#thankYouLines * 16)
        end

        payload.label = payload.title
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
    local isSelected = row.selected == true
    local isHovered = self.mouseoverselected == item.index

    local bgA, bgR, bgG, bgB = 0.22, 0.07, 0.07, 0.07
    local titleR, titleG, titleB = 0.92, 0.92, 0.92
    local subtitleR, subtitleG, subtitleB = 0.65, 0.65, 0.65

    if row.kind == "manual" then
        titleR, titleG, titleB = 0.96, 0.92, 0.76
        subtitleR, subtitleG, subtitleB = 0.62, 0.72, 0.86
        bgA, bgR, bgG, bgB = 0.34, 0.10, 0.12, 0.16
    elseif row.kind == "chapter" then
        titleR, titleG, titleB = 0.76, 0.86, 0.98
        bgA, bgR, bgG, bgB = 0.16, 0.08, 0.11, 0.15
    end

    if isSelected then
        bgA, bgR, bgG, bgB = 0.55, 0.15, 0.28, 0.42
    elseif isHovered then
        bgA, bgR, bgG, bgB = 0.35, 0.16, 0.16, 0.16
    end

    self:drawRect(0, y, width, height - 1, bgA, bgR, bgG, bgB)

    local ui = DT_ManualUI.instance
    local display = ui and ui.getNavRowDisplayData and ui:getNavRowDisplayData(row, self:getWidth()) or nil
    local indent = display and display.indent or ((row.depth or 0) * 18)
    local indicatorOffset = display and display.indicatorOffset or 0
    local titleFont = display and display.titleFont or UIFont.NewSmall
    local titleLines = display and display.titleLines or DT_ManualUI_Utils.WrapManualText(row.title or "", width - 24 - indent, titleFont)
    local subtitleLines = display and display.subtitleLines or {}

    local titleY = y + 6

    if row.expandable then
        local indicator = row.expanded and "v" or ">"
        self:drawText(indicator, 8 + indent, titleY, 0.70, 0.70, 0.70, 1, UIFont.Small)
    end

    local lineY = titleY
    local textX = 8 + indent + indicatorOffset

    for _, line in ipairs(titleLines or {}) do
        self:drawText(line, textX, lineY, titleR, titleG, titleB, 1, titleFont)
        lineY = lineY + 18
    end

    if row.kind == "manual" and subtitleLines and #subtitleLines > 0 then
        lineY = lineY + 1
        for _, line in ipairs(subtitleLines) do
            self:drawText(line, textX, lineY, subtitleR, subtitleG, subtitleB, 1, UIFont.Small)
            lineY = lineY + 16
        end
    elseif row.kind == "page" and subtitleLines and #subtitleLines > 0 then
        lineY = lineY + 1
        for _, line in ipairs(subtitleLines) do
            self:drawText(line, textX, lineY, 0.55, 0.55, 0.55, 1, UIFont.Small)
            lineY = lineY + 16
        end
    elseif row.kind == "chapter" then
        self:drawRect(
            textX,
            y + height - 4,
            math.max(34, math.min(width - textX - 8, DT_ManualUI_Utils.safeMeasure(UIFont.Small, tostring(row.title or "")) + 4)),
            1,
            0.55,
            0.30,
            0.52,
            0.78
        )
    end

    return y + height
end

function DT_ManualUI:drawResultItem(y, item, alt)
    local row = item.item
    local width = self:getWidth() - 4
    local height = item.height or self.itemheight
    local isHovered = self.mouseoverselected == item.index

    self:drawRect(0, y, width, height - 1, isHovered and 0.4 or 0.25, 0.12, 0.12, 0.12)

    local labelLines = DT_ManualUI_Utils.WrapManualText(row.label or "", width - 16, UIFont.Small)
    local lineY = y + 4

    for _, line in ipairs(labelLines) do
        self:drawText(line, 8, lineY, 0.95, 0.95, 0.95, 1, UIFont.Small)
        lineY = lineY + 16
    end

    local pathLines = DT_ManualUI_Utils.WrapManualText(tostring(row.path or ""), width - 16, UIFont.Small)
    for _, line in ipairs(pathLines) do
        self:drawText(line, 8, lineY, 0.70, 0.85, 0.95, 1, UIFont.Small)
        lineY = lineY + 16
    end

    local snippetLines = DT_ManualUI_Utils.WrapManualText(tostring(row.snippet or ""), width - 16, UIFont.Small)
    for _, line in ipairs(snippetLines) do
        self:drawText(line, 8, lineY, 0.70, 0.70, 0.70, 1, UIFont.Small)
        lineY = lineY + 16
    end

    return y + height
end

function DT_ManualUI:drawContentItem(y, item, alt)
    local block = item.item
    local width = self:getWidth() - 6
    local height = item.height or self.itemheight
    local padding = 8

    if block.kind == "library" then
        local titleLines = DT_ManualUI_Utils.WrapManualText(block.title or "", width - 20, UIFont.Medium)
        local descLines = DT_ManualUI_Utils.WrapManualText(tostring(block.description or ""), width - 20, UIFont.Small)
        local blockHeight = 8 + (#titleLines * 20) + (#descLines * 16) + 8

        self:drawRect(0, y, width, blockHeight - 1, 0.30, 0.10, 0.10, 0.10)

        local lineY = y + 8
        for _, line in ipairs(titleLines) do
            self:drawText(line, 10, lineY, 1, 1, 1, 1, UIFont.Medium)
            lineY = lineY + 20
        end

        for _, line in ipairs(descLines) do
            self:drawText(line, 10, lineY, 0.75, 0.75, 0.75, 1, UIFont.Small)
            lineY = lineY + 16
        end

        return y + blockHeight
    end

    if block.kind == "heading" then
        local isHighlighted = block.id and block.id == DT_ManualUI.instance.highlightSectionId

        self:drawRect(0, y, width, height - 1, isHighlighted and 0.48 or 0.18, isHighlighted and 0.27 or 0.09, isHighlighted and 0.22 or 0.10, isHighlighted and 0.09 or 0.10)
        self:drawRect(0, y, 4, height - 1, 0.85, isHighlighted and 0.90 or 0.74, isHighlighted and 0.73 or 0.58, isHighlighted and 0.22 or 0.16)

        local font = block.font or UIFont.Medium
        local lineY = y + 8
        lineY = DT_ManualUI_Utils.drawMarkdownLines(self, block.lines or {}, padding + 6, lineY, 1, 0.88, 0.52, 1, font, 22)

        if block.id then
            local anchorText = "#" .. tostring(block.id)
            local anchorW = DT_ManualUI_Utils.safeMeasure(UIFont.Small, anchorText)
            self:drawText(anchorText, width - anchorW - 8, y + 6, 0.55, 0.55, 0.55, 1, UIFont.Small)
        end

        self:drawRect(padding + 6, y + height - 5, math.max(42, math.min(width - (padding * 4), 120)), 1, 0.65, 0.74, 0.58, 0.16)
        return y + height
    end

    if block.kind == "image" then
        self:drawRect(0, y, width, height - 1, 0.20, 0.08, 0.08, 0.08)

        local drawW = tonumber(block.width) or 380
        local drawH = tonumber(block.height) or height

        if block.caption and block.caption ~= "" then
            drawH = drawH - 34
        else
            drawH = drawH - 24
        end

        local drawX = (width - drawW) / 2
        local drawY = y + padding

        if block.texture then
            self:drawTextureScaled(block.texture, drawX, drawY, drawW, drawH, 1, 1, 1, 1)
        else
            self:drawRect(drawX, drawY, drawW, drawH, 0.35, 0.18, 0.18, 0.18)
            self:drawTextCentre("Missing Image", drawX + (drawW / 2), drawY + (drawH / 2) - 8, 0.8, 0.6, 0.6, 1, UIFont.Small)
        end

        self:drawRectBorder(drawX, drawY, drawW, drawH, 0.8, 0.5, 0.5, 0.5)

        local hintText = "Click to expand"
        local hintFont = UIFont.Small
        local hintW = DT_ManualUI_Utils.safeMeasure(hintFont, hintText)
        self:drawText(hintText, drawX + drawW - hintW - 4, drawY + drawH - 18, 0.55, 0.65, 0.80, 0.85, hintFont)

        if block.caption and block.caption ~= "" then
            self:drawTextCentre(block.caption, width / 2, drawY + drawH + 6, 0.75, 0.75, 0.75, 1, UIFont.Small)
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
        lineY = DT_ManualUI_Utils.drawMarkdownLines(self, block.lines or {}, padding, lineY, 0.97, 0.97, 0.97, 1, UIFont.NewSmall, 18)
        return y + height
    end

    if block.kind == "supporter_carousel" then
        if block.compact then
            DT_ManualUI_Donators_Render.DrawContentCarouselCompact(self, block, y, width, height)
        else
            DT_ManualUI_Donators_Render.DrawContentCarousel(self, block, y, width, height)
        end
        return y + height
    end

    self:drawRect(0, y, width, height - 1, 0.10, 0.05, 0.05, 0.05)

    local lineY = y + 8
    lineY = DT_ManualUI_Utils.drawMarkdownLines(self, block.lines or {}, padding, lineY, 0.84, 0.86, 0.88, 1, UIFont.NewSmall, 18)

    return y + height
end
