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

local function measureOptionItem(list, option)
    local availableWidth = math.max(140, list:getWidth() - 62)
    local lines = DynamicTrading.Utils.WrapText(option.text, availableWidth, list.font)
    local lineHeight = 18
    local totalHeight = (#lines * lineHeight) + 18
    if totalHeight < 38 then
        totalHeight = 38
    end

    return lines, totalHeight
end

local function resolveOptions(ui, options)
    local resolvedOptions = options or {}

    if DC_System and DC_System.BuildConversationOptions then
        resolvedOptions = DC_System.BuildConversationOptions(ui, resolvedOptions)
    end

    return resolvedOptions or {}
end

local function renderOptions(ui, options)
    ui.optionList:clear()

    local resolvedOptions = resolveOptions(ui, options)
    if not resolvedOptions or #resolvedOptions == 0 then
        return
    end

    for _, opt in ipairs(resolvedOptions) do
        local lines, totalHeight = measureOptionItem(ui.optionList, opt)
        local item = ui.optionList:addItem(opt.text, opt)
        item.lines = lines
        item.height = totalHeight + 6
    end
end

function DT_ConversationUI:canNavigateBack()
    return type(self.currentBackAction) == "function" or #self.history > 0
end

function DT_ConversationUI:updateNavigationButtons()
    if self.backButton and self.backButton.setEnable then
        self.backButton:setEnable(self:canNavigateBack() and #self.msgQueue == 0)
    end
    if self.exitButton and self.exitButton.setEnable then
        self.exitButton:setEnable(#self.msgQueue == 0)
    end
end

function DT_ConversationUI:navigateBack()
    if #self.msgQueue > 0 then
        return false
    end

    if type(self.currentBackAction) == "function" then
        self.currentBackAction(self)
        return true
    end

    local snapshot = table.remove(self.history)
    if not snapshot then
        self:updateNavigationButtons()
        return false
    end

    self.currentBackAction = type(snapshot.backAction) == "function" and snapshot.backAction or nil
    self.baseOptions = snapshot.options or {}
    renderOptions(self, self.baseOptions)
    self:updateNavigationButtons()
    return true
end

function DT_ConversationUI:exitConversation()
    if #self.msgQueue > 0 then
        return false
    end

    self.closeReason = self.closeReason or "footer_exit"
    self:close()
    return true
end

function DT_ConversationUI:updateOptions(options, navState)
    navState = type(navState) == "table" and navState or nil

    if navState and navState.resetHistory == true then
        self.history = {}
    end

    local previousOptions = self.baseOptions
    if navState and navState.suppressHistory ~= true and previousOptions and #previousOptions > 0 then
        self.history[#self.history + 1] = {
            options = previousOptions,
            backAction = self.currentBackAction,
        }
    end

    self.baseOptions = options or {}
    self.currentBackAction = navState and type(navState.backAction) == "function" and navState.backAction or nil

    renderOptions(self, self.baseOptions)
    self:updateNavigationButtons()
end

function DT_ConversationUI:setBackAction(backAction)
    self.currentBackAction = type(backAction) == "function" and backAction or nil
    self:updateNavigationButtons()
end

function DT_ConversationUI:clearBackAction()
    self.currentBackAction = nil
    self:updateNavigationButtons()
end

function DT_ConversationUI:resetNavigationHistory()
    self.history = {}
    self:updateNavigationButtons()
end

function DT_ConversationUI:replaceOptions(options, navState)
    navState = type(navState) == "table" and navState or {}
    navState.suppressHistory = true
    self:updateOptions(options, navState)
end

function DT_ConversationUI:refreshOptionLayout()
    if self.baseOptions then
        renderOptions(self, self.baseOptions)
        self:updateNavigationButtons()
    end
end

function DT_ConversationUI:drawOptionItem(y, item, alt)
    local scrollGap = (self.vscroll and self.vscroll:isVisible()) and 13 or 0
    local width = self:getWidth() - scrollGap - 2
    local height = item.height - 6

    local ui = DT_ConversationUI.instance
    local isLocked = ui and #ui.msgQueue > 0
    local isMouseOver = self.mouseoverselected == item.index and not isLocked

    local r, g, b, a = 0.18, 0.32, 0.14, 0.22
    local sr, sg, sb, sa = 0.78, 0.96, 0.34, 0.66
    local tr, tg, tb, ta = 0.94, 0.96, 0.90, 1.0

    if isLocked then
        r, g, b, a = 0.10, 0.10, 0.10, 0.18
        sr, sg, sb, sa = 0.34, 0.34, 0.34, 0.26
        tr, tg, tb = 0.56, 0.56, 0.56
    else
        local data = item and item.item or nil
        local style = type(data and data.style) == "table" and data.style or nil
        if style then
            r, g, b, a = applyColorOverride(style.bgColor, { r, g, b, a })
            sr, sg, sb, sa = applyColorOverride(style.borderColor, { sr, sg, sb, sa })
            tr, tg, tb, ta = applyColorOverride(style.textColor, { tr, tg, tb, ta })
        end
    end

    if not isLocked and isMouseOver then
        r = clamp01(r + 0.04, r)
        g = clamp01(g + 0.06, g)
        b = clamp01(b + 0.04, b)
        a = clamp01(a + 0.08, a)
        sr = clamp01(sr + 0.08, sr)
        sg = clamp01(sg + 0.06, sg)
        sb = clamp01(sb + 0.02, sb)
        tr = clamp01(tr + 0.06, tr)
        tg = clamp01(tg + 0.06, tg)
        tb = clamp01(tb + 0.06, tb)
    end

    local drawY = y + 2
    local bodyH = height - 2
    local stripeW = math.max(7, math.floor(width * 0.018))
    local topShineW = math.max(60, math.floor(width * 0.76))

    self:drawRect(0, drawY, width, bodyH, a, r, g, b)
    self:drawRect(0, drawY, stripeW, bodyH, sa, sr, sg, sb)
    self:drawRect(0, drawY, topShineW, 1, sa * 0.55, sr, sg, sb)
    self:drawRect(0, drawY + bodyH - 1, math.floor(width * 0.62), 1, sa * 0.18, sr, sg, sb)

    local lineH = 18
    local textBlockH = #item.lines * lineH
    local startY = drawY + math.max(4, (bodyH - textBlockH) / 2)
    local textX = stripeW + 14

    for i, line in ipairs(item.lines) do
        self:drawText(line, textX, startY + ((i - 1) * lineH), tr, tg, tb, ta, self.font)
    end

    local glyph = isLocked and "..." or ">"
    local glyphWidth = getTextManager():MeasureStringX(self.font, glyph)
    self:drawText(glyph, width - glyphWidth - 12, drawY + math.max(5, (bodyH - lineH) / 2), sr, sg, sb, math.max(ta * 0.9, 0.4), self.font)

    if isMouseOver and not isLocked then
        self:drawRect(math.floor(width * 0.18), drawY + bodyH - 2, math.floor(width * 0.68), 1, 0.24, sr, sg, sb)
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
