-- =============================================================================
-- DYNAMIC TRADING: CONVERSATION UI ACTIONS
-- =============================================================================
-- Public open and close API.
-- =============================================================================

require "DT/Common/UI/ConversationUI/DT_ConversationUI_Core"

function DT_ConversationUI.Open(traderObj, initialText, initialOptions, isRadio, interactionObj)
    if DT_ConversationUI.instance then
        DT_ConversationUI.instance.closeReason = DT_ConversationUI.instance.closeReason or "replaced_by_new_conversation"
        DT_ConversationUI.instance:close()
    end

    local x, y = 150, 150
    local w, h = 600, 600

    if DT_ConfigManager and DT_ConfigManager.getWindowState then
        local state = DT_ConfigManager.getWindowState("ConversationUI")
        if state then
            x = state.x
            y = state.y
        end
    end

    local screenW = getCore():getScreenWidth()
    local screenH = getCore():getScreenHeight()
    if x < 0 then
        x = 0
    end
    if y < 0 then
        y = 0
    end
    if x > screenW - 50 then
        x = screenW - 600
    end
    if y > screenH - 50 then
        y = screenH - 600
    end

    local ui = DT_ConversationUI:new(x, y, w, h)
    ui:initialise()
    ui:addToUIManager()

    if isRadio == false then
        ui.isRadio = false
    else
        ui.isRadio = true
    end

    ui.target = traderObj
    ui.interactionObj = interactionObj
    local name = traderObj.name or "Unknown"
    ui.lblName:setName(name)

    local role = "Survivor"
    if traderObj.archetype then
        role = traderObj.archetype
    elseif traderObj.role then
        role = traderObj.role
    end
    ui.lblDesc:setName(role)

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
