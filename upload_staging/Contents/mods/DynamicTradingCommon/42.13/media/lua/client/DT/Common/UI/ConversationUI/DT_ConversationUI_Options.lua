-- =============================================================================
-- DYNAMIC TRADING: CONVERSATION UI OPTIONS
-- =============================================================================
-- Option list population and click handling.
-- =============================================================================

require "DT/Common/UI/ConversationUI/DT_ConversationUI_Core"

function DT_ConversationUI:updateOptions(options)
    self.optionList:clear()
    if not options or #options == 0 then
        return
    end

    local btnWidth = self.optionList:getWidth() - 25

    for _, opt in ipairs(options) do
        local lines = DynamicTrading.Utils.WrapText(opt.text, btnWidth, self.optionList.font)
        local lineHeight = 20
        local totalHeight = (#lines * lineHeight) + 16
        if totalHeight < 35 then
            totalHeight = 35
        end

        local item = self.optionList:addItem(opt.text, opt)
        item.lines = lines
        item.height = totalHeight + 5
    end
end

function DT_ConversationUI:drawOptionItem(y, item, alt)
    local width = self:getWidth() - 15
    local height = item.height - 5

    local ui = DT_ConversationUI.instance
    local isLocked = ui and #ui.msgQueue > 0
    local isMouseOver = self.mouseoverselected == item.index and not isLocked

    local r, g, b, a = 0.2, 0.2, 0.2, 1.0
    local br, bg, bb, ba = 0.5, 0.5, 0.5, 1.0
    local tr, tg, tb, ta = 0.9, 0.9, 0.9, 1.0

    if isLocked then
        r, g, b, a = 0.15, 0.15, 0.15, 1.0
        br, bg, bb = 0.3, 0.3, 0.3
        tr, tg, tb = 0.5, 0.5, 0.5
    elseif isMouseOver then
        r, g, b, a = 0.3, 0.3, 0.3, 1.0
        br, bg, bb = 0.8, 0.8, 0.8
        tr, tg, tb = 1.0, 1.0, 1.0
    end

    self:drawRect(0, y, width, height, a, r, g, b)
    self:drawRectBorder(0, y, width, height, ba, br, bg, bb)

    local lineH = 20
    local textBlockH = #item.lines * lineH
    local startY = y + (height - textBlockH) / 2

    for i, line in ipairs(item.lines) do
        self:drawTextCentre(line, width / 2, startY + ((i - 1) * lineH), tr, tg, tb, ta, self.font)
    end

    return y + item.height
end

function DT_ConversationUI:onOptionListMouseDown(x, y)
    local row = self:rowAt(x, y)
    if row == -1 then
        return
    end

    local ui = DT_ConversationUI.instance
    if ui and #ui.msgQueue > 0 then
        return
    end

    local item = self.items[row]
    local data = item.item

    local chatText = data.text
    if data.message ~= nil then
        chatText = data.message
    end

    if chatText and chatText ~= "" then
        ui:queueMessage(chatText, "Me", true, 0, "DT_RadioRandom")
    end

    if data.onSelect then
        data.onSelect(ui, data.data)
    end
end
