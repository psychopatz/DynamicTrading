-- =============================================================================
-- DYNAMIC TRADING: CONVERSATION UI OPTIONS
-- =============================================================================
-- Option list population and click handling.
-- =============================================================================

require "DT/Common/UI/ConversationUI/DT_ConversationUI_Core"
pcall(require, "DC/UI/Colony/System/DC_System")

local function clamp01(value, fallback)
    local numeric = tonumber(value)
    if numeric == nil then
        return fallback
    end
    if numeric < 0 then
        return 0
    end
    if numeric > 1 then
        return 1
    end
    return numeric
end

local function applyColorOverride(optionColor, defaults)
    if type(optionColor) ~= "table" then
        return defaults[1], defaults[2], defaults[3], defaults[4]
    end

    return clamp01(optionColor[1], defaults[1]),
        clamp01(optionColor[2], defaults[2]),
        clamp01(optionColor[3], defaults[3]),
        clamp01(optionColor[4], defaults[4])
end

function DT_ConversationUI:updateOptions(options)
    self.baseOptions = options or {}
    self.optionList:clear()
    local resolvedOptions = self.baseOptions

    if DC_System and DC_System.BuildConversationOptions then
        resolvedOptions = DC_System.BuildConversationOptions(self, self.baseOptions)
    end

    if not resolvedOptions or #resolvedOptions == 0 then
        return
    end

    local btnWidth = self.optionList:getWidth() - 25

    for _, opt in ipairs(resolvedOptions) do
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
    else
        local data = item and item.item or nil
        local style = type(data and data.style) == "table" and data.style or nil
        if style then
            r, g, b, a = applyColorOverride(style.bgColor, { r, g, b, a })
            br, bg, bb, ba = applyColorOverride(style.borderColor, { br, bg, bb, ba })
            tr, tg, tb, ta = applyColorOverride(style.textColor, { tr, tg, tb, ta })
        end
    end

    if not isLocked and isMouseOver then
        r = clamp01(r + 0.08, r)
        g = clamp01(g + 0.08, g)
        b = clamp01(b + 0.08, b)
        br = clamp01(br + 0.10, br)
        bg = clamp01(bg + 0.10, bg)
        bb = clamp01(bb + 0.10, bb)
        tr = clamp01(tr + 0.06, tr)
        tg = clamp01(tg + 0.06, tg)
        tb = clamp01(tb + 0.06, tb)
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
