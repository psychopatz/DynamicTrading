-- =============================================================================
-- DYNAMIC TRADING: CONVERSATION UI ACTIONS
-- =============================================================================
-- Public open and close API.
-- =============================================================================

require "DT/Common/UI/ConversationUI/DT_ConversationUI_Core"

local function clamp(value, minValue, maxValue)
    if value < minValue then
        return minValue
    end
    if value > maxValue then
        return maxValue
    end
    return value
end

function DT_ConversationUI.Open(traderObj, initialText, initialOptions, isRadio, interactionObj)
    if DT_ConversationUI.instance then
        DT_ConversationUI.instance.closeReason = DT_ConversationUI.instance.closeReason or "replaced_by_new_conversation"
        DT_ConversationUI.instance:close()
    end

    local screenW = getCore():getScreenWidth()
    local screenH = getCore():getScreenHeight()

    local minW = DT_ConversationUI.MIN_WIDTH or 760
    local minH = DT_ConversationUI.MIN_HEIGHT or 420
    local maxW = math.max(minW, screenW - 20)
    local maxH = math.max(minH, screenH - 70)

    local w = clamp(math.floor(screenW * 0.88), minW, math.min(1560, maxW))
    local h = clamp(math.floor(screenH * 0.44), minH, math.min(620, maxH))
    local x = math.floor((screenW - w) / 2)
    local y = math.floor(screenH - h - math.max(34, math.floor(screenH * 0.08)))

    if y < 30 then
        y = 30
    end

    if DT_ConfigManager and DT_ConfigManager.getWindowState then
        local state = DT_ConfigManager.getWindowState("ConversationUI")
        if state then
            w = clamp(tonumber(state.w) or w, minW, maxW)
            h = clamp(tonumber(state.h) or h, minH, maxH)
            x = tonumber(state.x) or x
            y = tonumber(state.y) or y
        end
    end

    if x < 0 then
        x = 0
    end
    if y < 0 then
        y = 0
    end
    if x > screenW - 50 then
        x = math.max(0, screenW - w)
    end
    if y > screenH - 50 then
        y = math.max(0, screenH - h)
    end

    local ui = DT_ConversationUI:new(x, y, w, h)
    ui:initialise()
    ui:addToUIManager()
    ui:relayout()

    if isRadio == false then
        ui.isRadio = false
    else
        ui.isRadio = true
    end

    ui.target = traderObj
    ui.interactionObj = interactionObj
    local name = traderObj.name or "Unknown"
    ui.headerNameText = name

    local role = "Survivor"
    if traderObj.archetype then
        role = traderObj.archetype
    elseif traderObj.role then
        role = traderObj.role
    end
    ui.headerRoleText = role
    ui:updateHeaderMetrics()
    if ui.refreshVisualTone then
        ui:refreshVisualTone()
    end

    if traderObj.factionID then
        ui:refreshFactionInfo()
    end

    if ui.refreshPortrait then
        ui:refreshPortrait(true)
    end

    if initialText then
        ui:speak(initialText)
    end

    if initialOptions then
        ui:updateOptions(initialOptions)
    end

    DT_ConversationUI.instance = ui
    DynamicTrading.Log(
        "DTCommons",
        "Dialog",
        "Open",
        "Opened conversation target=" .. tostring(traderObj and (traderObj.name or traderObj.uuid or traderObj.id) or "nil")
            .. " isRadio=" .. tostring(ui.isRadio)
            .. " isContact=" .. tostring(ui.isContactConversation == true or traderObj and traderObj.isContactConversation == true)
            .. " hasInteractionObj=" .. tostring(interactionObj ~= nil)
    )
    return ui
end

function DT_ConversationUI:close()
    DynamicTrading.Log(
        "DTCommons",
        "Dialog",
        "Close",
        "Closing conversation target=" .. tostring(self.target and (self.target.name or self.target.uuid or self.target.id) or "nil")
            .. " reason=" .. tostring(self.closeReason or "manual_or_callback")
            .. " isContact=" .. tostring(self.isContactConversation == true)
    )

    if DT_ConfigManager and DT_ConfigManager.setWindowState then
        DT_ConfigManager.setWindowState("ConversationUI", self:getX(), self:getY(), self:getWidth(), self:getHeight())
    end

    if self.onCloseCallback then
        local success, err = pcall(self.onCloseCallback, self)
        if not success and DynamicTrading and DynamicTrading.Log then
            DynamicTrading.Log("DTV2", "Dialog", "Error", "Conversation close callback failed: " .. tostring(err))
        end
    end

    self:setVisible(false)
    self:removeFromUIManager()
    DT_ConversationUI.instance = nil
end
