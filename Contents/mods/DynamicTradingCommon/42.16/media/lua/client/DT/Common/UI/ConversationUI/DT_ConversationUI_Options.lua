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

local function copyTable(source)
    local copy = {}
    if type(source) ~= "table" then
        return copy
    end

    for key, value in pairs(source) do
        copy[key] = value
    end

    return copy
end

function DT_ConversationUI.BuildFooterAction(spec)
    return copyTable(spec)
end

function DT_ConversationUI.BuildLeaveFooterAction(overrides)
    overrides = type(overrides) == "table" and overrides or nil
    local action = {
        kind = "leave",
        title = "Leave",
    }

    for key, value in pairs(overrides or {}) do
        action[key] = value
    end

    return action
end

function DT_ConversationUI.BuildExitFooterAction(overrides)
    overrides = type(overrides) == "table" and overrides or nil
    local action = DT_ConversationUI.BuildLeaveFooterAction(overrides)
    action.title = action.title or "Exit"
    if not overrides or overrides.title == nil then
        action.title = "Exit"
    end
    return action
end

function DT_ConversationUI.BuildBackFooterAction(overrides)
    overrides = type(overrides) == "table" and overrides or nil
    local action = {
        kind = "back",
        title = "Back",
        closeAfter = false,
        exitAfter = false,
    }

    for key, value in pairs(overrides or {}) do
        action[key] = value
    end

    return action
end

function DT_ConversationUI.BuildNavigationBlock(footerAction, overrides)
    overrides = type(overrides) == "table" and overrides or nil
    local block = {
        explicitFooter = true,
        footerAction = footerAction,
        defaultFooterAction = footerAction,
    }

    for key, value in pairs(overrides or {}) do
        block[key] = value
    end

    return block
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

local function normalizeFooterActionDefinition(footerAction)
    if type(footerAction) ~= "table" then
        return nil
    end

    local rawKind = tostring(footerAction.kind or footerAction.action or "")
    local rawTitle = footerAction.title or footerAction.text
    local kind = rawKind
    local callback = footerAction.onSelect

    if type(callback) ~= "function" then
        callback = footerAction.callback
    end

    if kind == "exit" then
        kind = "leave"
    end

    if kind ~= "back" and kind ~= "leave" then
        kind = tostring(rawTitle or "") == "Back" and "back" or "leave"
    end

    local playerMessage = footerAction.playerMessage
    if playerMessage == nil then
        playerMessage = footerAction.message
    end

    local closeAfter = footerAction.closeAfter == true or footerAction.exitAfter == true
    if kind ~= "back" then
        closeAfter = true
    end

    return {
        kind = kind,
        title = tostring(rawTitle or (kind == "back" and "Back" or "Leave")),
        message = playerMessage,
        playerMessage = playerMessage,
        npcDialogue = footerAction.npcDialogue or footerAction.dialogue or footerAction.npcMessage,
        onSelect = type(callback) == "function" and callback or nil,
        data = footerAction.data,
        style = type(footerAction.style) == "table" and footerAction.style or nil,
        npcStyle = type(footerAction.npcStyle) == "table" and footerAction.npcStyle or nil,
        closeAfter = closeAfter,
        exitAfter = closeAfter,
        silent = footerAction.silent == true,
        suppressDefaultMessage = footerAction.suppressDefaultMessage == true,
        suppressExitEmote = footerAction.suppressExitEmote == true,
        exitEmote = footerAction.exitEmote or footerAction.emote,
    }
end

local function prepareOptions(ui, options, footerActionOverride, resolvedOptionsOverride)
    local rawFooterAction = type(options) == "table" and (options._dtFooterAction or options._dtFooter) or nil
    local resolvedOptions = type(resolvedOptionsOverride) == "table" and resolvedOptionsOverride or resolveOptions(ui, options)
    local explicitFooterAction = footerActionOverride
    if explicitFooterAction == nil then
        explicitFooterAction = rawFooterAction or resolvedOptions._dtFooterAction or resolvedOptions._dtFooter
    end

    local footerAction = normalizeFooterActionDefinition(explicitFooterAction)

    return resolvedOptions, footerAction
end

local function getRawNavigationBlock(options)
    if type(options) ~= "table" then
        return nil
    end

    return options._dtNavigationBlock or options._dtNavBlock or options._dtNavigation
end

local function getRawFooterAction(options)
    if type(options) ~= "table" then
        return nil
    end

    return options._dtFooterAction or options._dtFooter
end

local function mergeNavigationBlock(target, source)
    if type(source) ~= "table" then
        return target
    end

    for key, value in pairs(source) do
        target[key] = value
    end

    return target
end

local function hasNavigationIntent(options, navState, resolvedOptions)
    if getRawNavigationBlock(options) ~= nil
        or getRawFooterAction(options) ~= nil
        or getRawNavigationBlock(resolvedOptions) ~= nil
        or getRawFooterAction(resolvedOptions) ~= nil then
        return true
    end

    if type(navState) ~= "table" then
        return false
    end

    return navState.footerAction ~= nil
        or navState.defaultFooterAction ~= nil
        or navState.navigationBlock ~= nil
        or navState.navBlock ~= nil
        or navState.navigation ~= nil
        or navState.backAction ~= nil
end

local function logMissingNavigationBlock(block)
    if not block or block.requireExplicitNavigation ~= true or block._dtHadNavigationIntent == true then
        return
    end
    if not (isDebugEnabled and isDebugEnabled()) then
        return
    end
    if DynamicTrading and DynamicTrading.Log then
        DynamicTrading.Log(
            "DTCommons",
            "ConversationUI",
            "Navigation",
            "Explicit navigation requested without footer/back block: " .. tostring(block.debugLabel or "unknown")
        )
    end
end

local function normalizeNavigationBlock(options, navState, resolvedOptions)
    local block = {}
    local rawFooterAction = getRawFooterAction(options)
    local rawBlock = getRawNavigationBlock(options)
    local resolvedFooterAction = getRawFooterAction(resolvedOptions)
    local resolvedBlock = getRawNavigationBlock(resolvedOptions)
    block._dtHadNavigationIntent = hasNavigationIntent(options, navState, resolvedOptions)

    mergeNavigationBlock(block, rawBlock)
    mergeNavigationBlock(block, resolvedBlock)

    if rawFooterAction ~= nil and block.footerAction == nil then
        block.footerAction = rawFooterAction
        block.defaultFooterAction = rawFooterAction
        block.explicitFooter = true
    end
    if resolvedFooterAction ~= nil and block.footerAction == nil then
        block.footerAction = resolvedFooterAction
        block.defaultFooterAction = resolvedFooterAction
        block.explicitFooter = true
    end

    if type(navState) == "table" then
        mergeNavigationBlock(block, navState.navigationBlock or navState.navBlock or navState.navigation)
        mergeNavigationBlock(block, navState)
    end

    if block.footerAction ~= nil and block.defaultFooterAction == nil then
        block.defaultFooterAction = block.footerAction
    end

    if block.footerAction ~= nil then
        block.explicitFooter = block.explicitFooter ~= false
    end

    if block.resetHistory == true and block.explicitFooter == nil and block.backAction == nil and block.footerAction == nil then
        block.explicitFooter = true
        block.footerAction = DT_ConversationUI.BuildLeaveFooterAction()
        block.defaultFooterAction = block.footerAction
    end

    if block.explicitFooter == true and block.defaultFooterAction == nil then
        block.defaultFooterAction = block.footerAction or DT_ConversationUI.BuildLeaveFooterAction()
    end

    return block
end

local function renderOptions(ui, options)
    ui.optionList:clear()

    if not options or #options == 0 then
        return
    end

    for _, opt in ipairs(options) do
        local lines, totalHeight = measureOptionItem(ui.optionList, opt)
        local item = ui.optionList:addItem(opt.text, opt)
        item.lines = lines
        item.height = totalHeight + 6
    end
end

local function getFooterNavigationState(ui)
    if not ui then
        return "Leave", nil, false
    end

    local footerOption = ui.footerNavigationOption
    if not footerOption and ui.explicitFooterRequired == true then
        footerOption = normalizeFooterActionDefinition(ui.defaultFooterAction or DT_ConversationUI.BuildLeaveFooterAction())
    end

    if footerOption then
        local isBackAction = footerOption.kind == "back" and footerOption.exitAfter ~= true
        local label = tostring(footerOption.title or (isBackAction and "Back" or "Leave"))
        return label, function()
            if isBackAction and type(footerOption.onSelect) ~= "function" then
                local fallbackAction = {}
                for key, value in pairs(footerOption) do
                    fallbackAction[key] = value
                end
                fallbackAction.onSelect = function(backUI)
                    return backUI:navigateBack()
                end
                return ui:requestExitConversation(fallbackAction)
            end
            return ui:requestExitConversation(footerOption)
        end, isBackAction
    end

    if ui.canNavigateBack and ui:canNavigateBack() then
        return "Back", function()
            ui:navigateBack()
        end, true
    end

    return "Leave", function()
        ui:requestExitConversation()
    end, false
end

local function setButtonTitle(button, title)
    if not button then
        return
    end

    if button.setTitle then
        button:setTitle(title)
    else
        button.title = title
    end
end

function DT_ConversationUI:canNavigateBack()
    return type(self.currentBackAction) == "function" or #self.history > 0
end

function DT_ConversationUI:updateNavigationButtons()
    if not self.navigationButton then
        return
    end

    local label, _, isBackAction = getFooterNavigationState(self)
    setButtonTitle(self.navigationButton, label)

    self.navigationButton.backgroundColor = isBackAction
        and { r = 0.16, g = 0.24, b = 0.14, a = 0.92 }
        or { r = 0.24, g = 0.14, b = 0.14, a = 0.92 }
    self.navigationButton.backgroundColorMouseOver = isBackAction
        and { r = 0.22, g = 0.32, b = 0.18, a = 0.96 }
        or { r = 0.32, g = 0.18, b = 0.18, a = 0.96 }
    self.navigationButton.borderColor = isBackAction
        and { r = 0.70, g = 0.82, b = 0.44, a = 0.72 }
        or { r = 0.88, g = 0.56, b = 0.44, a = 0.74 }

    if self.navigationButton.setEnable then
        self.navigationButton:setEnable(#self.msgQueue == 0 and self.pendingCloseAfterQueue ~= true)
    end
end

function DT_ConversationUI:activateFooterNavigation()
    if #self.msgQueue > 0 then
        return false
    end

    local _, action = getFooterNavigationState(self)
    if type(action) ~= "function" then
        return false
    end

    action()
    return true
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
    self.footerActionOverride = snapshot.footerActionOverride or nil
    self.explicitFooterRequired = snapshot.explicitFooterRequired == true
    self.defaultFooterAction = snapshot.defaultFooterAction
    self.rawOptions = snapshot.options or {}
    self.baseOptions, self.footerNavigationOption = prepareOptions(self, self.rawOptions, self.footerActionOverride)
    renderOptions(self, self.baseOptions)
    self:updateNavigationButtons()
    return true
end

function DT_ConversationUI:exitConversation()
    if #self.msgQueue > 0 then
        return false
    end

    return self:requestExitConversation()
end

function DT_ConversationUI:updateOptions(options, navState)
    navState = type(navState) == "table" and navState or nil
    local previousOptions = self.rawOptions
    local nextOptions = options or {}
    self.rawOptions = nextOptions
    local resolvedOptions = resolveOptions(self, nextOptions)
    local navigationBlock = normalizeNavigationBlock(nextOptions, navState, resolvedOptions)
    logMissingNavigationBlock(navigationBlock)

    if navigationBlock.resetHistory == true then
        self.history = {}
    end

    if navigationBlock.suppressHistory ~= true and navigationBlock.resetHistory ~= true and previousOptions and #previousOptions > 0 then
        self.history[#self.history + 1] = {
            options = previousOptions,
            backAction = self.currentBackAction,
            footerActionOverride = self.footerActionOverride,
            explicitFooterRequired = self.explicitFooterRequired == true,
            defaultFooterAction = self.defaultFooterAction,
        }
    end

    self.currentBackAction = type(navigationBlock.backAction) == "function" and navigationBlock.backAction or nil
    self.footerActionOverride = navigationBlock.footerAction
    self.explicitFooterRequired = navigationBlock.explicitFooter == true
    self.defaultFooterAction = navigationBlock.defaultFooterAction
    self.baseOptions, self.footerNavigationOption = prepareOptions(self, self.rawOptions, self.footerActionOverride, resolvedOptions)

    renderOptions(self, self.baseOptions)
    self:updateNavigationButtons()
end

function DT_ConversationUI:setFooterAction(footerAction)
    self.footerActionOverride = footerAction
    self.explicitFooterRequired = type(footerAction) == "table"
    self.defaultFooterAction = footerAction
    self.baseOptions, self.footerNavigationOption = prepareOptions(self, self.rawOptions, self.footerActionOverride)
    self:updateNavigationButtons()
end

function DT_ConversationUI:clearFooterAction()
    self.footerActionOverride = nil
    self.explicitFooterRequired = false
    self.defaultFooterAction = nil
    self.baseOptions, self.footerNavigationOption = prepareOptions(self, self.rawOptions, self.footerActionOverride)
    self:updateNavigationButtons()
end

function DT_ConversationUI:setNavigationBlock(navBlock)
    navBlock = normalizeNavigationBlock(self.rawOptions, type(navBlock) == "table" and navBlock or nil)
    self.currentBackAction = type(navBlock.backAction) == "function" and navBlock.backAction or nil
    self.footerActionOverride = navBlock.footerAction
    self.explicitFooterRequired = navBlock.explicitFooter == true
    self.defaultFooterAction = navBlock.defaultFooterAction
    self.baseOptions, self.footerNavigationOption = prepareOptions(self, self.rawOptions, self.footerActionOverride)
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
    if self.rawOptions then
        self.baseOptions, self.footerNavigationOption = prepareOptions(self, self.rawOptions, self.footerActionOverride)
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
        ui:queuePlayerMessage(chatText)
    end

    if data.onSelect then
        data.onSelect(ui, data.data)
    end
end
