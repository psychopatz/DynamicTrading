-- =============================================================================
-- LOGGING & FEEDBACK (BUBBLE STYLE)
-- =============================================================================

--- Adds a message to the chat list.
function DT_TradingWindow:logLocal(text, isError, isPlayer)
    -- [ADJUSTED] Reduced padding from 25 to 13 to match scrollbar width exactly
    local padding = 13
    local fullWidth = self.chatList:getWidth() - padding
    if fullWidth <= 50 then fullWidth = 200 end

    local bubbleWidth = fullWidth * 0.85
    local font = self.chatList.font
    local lines = DynamicTrading.Utils.WrapText(text, bubbleWidth, font)

    local lineHeight = self.chatList.itemheight or 18
    local totalHeight = #lines * lineHeight
    totalHeight = totalHeight + 4
    if totalHeight < lineHeight then totalHeight = lineHeight end

    local entry = {
        text = text,
        error = isError or false,
        isPlayer = isPlayer or false,
        lines = lines,
        height = totalHeight
    }
    table.insert(self.localLogs, entry)

    self.chatList:clear()
    for _, log in ipairs(self.localLogs) do
        local addedItem = self.chatList:addItem(log.text, log)
        addedItem.height = log.height + 2
    end
    self.chatList:ensureVisible(#self.chatList.items)
end

function DT_TradingWindow:drawLogItem(y, item, alt)
    local data = item.item
    local height = data.height or self.itemheight
    local width = self:getWidth()
    local lineHeight = self.itemheight
    local tm = getTextManager()

    -- [ADJUSTED] Tighter padding to make bubbles stick to the scrollbar
    local padding = 13

    -- ==========================================================
    -- BACKGROUND BUBBLE LOGIC
    -- ==========================================================
    local bubbleWidth = (width - padding) * 0.85

    if data.isPlayer then
        -- PLAYER: Right side
        -- xPos is calculated so the bubble ends exactly at (width - padding)
        local xPos = (width - padding) - bubbleWidth

        self:drawRect(xPos, y, bubbleWidth, height, 0.1, 0.2, 0.35, 0.7)
        self:drawRectBorder(xPos, y, bubbleWidth, height, 0.2, 0.4, 0.6, 0.3)

    elseif data.error then
        -- ERROR: Left side
        self:drawRect(0, y, bubbleWidth, height, 0.3, 0.1, 0.1, 0.7)
        self:drawRectBorder(0, y, bubbleWidth, height, 0.5, 0.2, 0.2, 0.5)

    else
        -- TRADER / SYSTEM: Left side
        self:drawRect(0, y, bubbleWidth, height, 0.15, 0.15, 0.15, 0.7)
        self:drawRectBorder(0, y, bubbleWidth, height, 0.3, 0.3, 0.3, 0.3)
    end

    -- ==========================================================
    -- TEXT COLOR LOGIC
    -- ==========================================================
    local r, g, b = 0.9, 0.9, 0.9

    if data.isPlayer then
        r, g, b = 0.6, 0.9, 1.0
    elseif data.error then
        r, g, b = 1.0, 0.5, 0.5
    elseif string.find(data.text, "Purchased") then
        r, g, b = 0.4, 1.0, 0.4
    elseif string.find(data.text, "Sold") then
        r, g, b = 0.4, 0.8, 1.0
    end

    -- ==========================================================
    -- TEXT DRAWING LOGIC
    -- ==========================================================
    if data.lines and #data.lines > 0 then
        local currentY = y + 2
        for _, lineStr in ipairs(data.lines) do
            local xPos = 5

            if data.isPlayer then
                -- Right Align Logic:
                -- We align text relative to the right edge (width - padding)
                -- minus a small 5px margin for inside the bubble
                local textWid = tm:MeasureStringX(self.font, lineStr)
                xPos = (width - padding) - textWid - 5
            end

            self:drawText(lineStr, xPos, currentY, r, g, b, 1, self.font)
            currentY = currentY + lineHeight
        end
    else
        self:drawText(data.text, 5, y + 2, r, g, b, 1, self.font)
    end

    return y + height
end
