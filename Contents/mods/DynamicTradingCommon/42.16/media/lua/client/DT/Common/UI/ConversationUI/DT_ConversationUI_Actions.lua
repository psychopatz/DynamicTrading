-- =============================================================================
-- DYNAMIC TRADING: CONVERSATION UI ACTIONS
-- =============================================================================
-- Public open and close API.
-- =============================================================================

require "DT/Common/UI/ConversationUI/DT_ConversationUI_Core"

local CONVERSATION_EXIT_LINES = {
    "Goodbye, %s.",
    "See you around, %s.",
    "Take care, %s.",
    "Stay safe, %s.",
}

local function clamp(value, minValue, maxValue)
    if value < minValue then
        return minValue
    end
    if value > maxValue then
        return maxValue
    end
    return value
end

local function getLocalPlayer()
    if getSpecificPlayer then
        local player = getSpecificPlayer(0)
        if player then
            return player
        end
    end

    if getPlayer then
        return getPlayer()
    end

    return nil
end

local function getExitTargetName(ui)
    local target = ui and ui.target or nil
    local name = target and target.name or nil
    if name == nil or name == "" then
        return "there"
    end
    return tostring(name)
end

local function getDefaultExitLine(ui)
    local template = CONVERSATION_EXIT_LINES[(ZombRand(#CONVERSATION_EXIT_LINES) or 0) + 1]
    return string.format(template, getExitTargetName(ui))
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
        ui:speak({
            text = initialText,
            vocalHook = ui.getDefaultGreetingVocalHook and ui:getDefaultGreetingVocalHook() or "welcome",
        })
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

    self.pendingCloseAfterQueue = false
    self.pendingCloseDisplayTicks = nil
    self.pendingCloseCallback = nil
    self.pendingCloseFooterAction = nil

    self:setVisible(false)
    self:removeFromUIManager()
    DT_ConversationUI.instance = nil
end

function DT_ConversationUI:getExitConversationMessage(footerAction)
    if type(footerAction) == "table" then
        local overrideText = tostring(footerAction.playerMessage or footerAction.message or "")
        if overrideText ~= "" then
            return overrideText
        end

        if footerAction.silent == true or footerAction.suppressDefaultMessage == true then
            return nil
        end
    end

    return getDefaultExitLine(self)
end

function DT_ConversationUI:playExitConversationEmote(footerAction)
    if type(footerAction) == "table" and footerAction.suppressExitEmote == true then
        return false
    end

    local player = getLocalPlayer()
    if not player or not player.playEmote then
        return false
    end

    local emoteID = "wavehi"
    if type(footerAction) == "table" then
        local customEmote = tostring(footerAction.exitEmote or "")
        if customEmote ~= "" then
            emoteID = customEmote
        end
    end

    player:playEmote(emoteID)
    return true
end

function DT_ConversationUI:getFooterActionNPCDialogue(footerAction)
    if type(footerAction) ~= "table" or footerAction.silent == true then
        return nil
    end

    local npcDialogue = tostring(footerAction.npcDialogue or "")
    if npcDialogue == "" then
        return nil
    end

    return npcDialogue
end

function DT_ConversationUI:queueFooterActionDialogue(footerAction, isExitAction)
    if type(footerAction) == "table" and footerAction.silent == true then
        return false
    end

    local queuedAny = false
    local playerMessage = nil
    local playerStyle = type(footerAction) == "table" and footerAction.style or nil

    if isExitAction == true then
        playerMessage = self:getExitConversationMessage(footerAction)
    elseif type(footerAction) == "table" then
        playerMessage = tostring(footerAction.playerMessage or footerAction.message or "")
        if playerMessage == "" then
            playerMessage = nil
        end
    end

    if playerMessage and playerMessage ~= "" then
        self:queuePlayerMessage(playerMessage, 0, playerStyle)
        queuedAny = true
    end

    local npcDialogue = self:getFooterActionNPCDialogue(footerAction)
    if npcDialogue then
        self:speak({
            text = npcDialogue,
            delay = queuedAny and (DT_ConversationUI.TEXT_DELAY or 30) or 0,
            style = type(footerAction) == "table" and footerAction.npcStyle or nil,
            vocalHook = self.getDefaultFarewellVocalHook and self:getDefaultFarewellVocalHook() or "bye",
        })
        queuedAny = true
    end

    return queuedAny
end

function DT_ConversationUI:performPendingClose()
    if self.pendingCloseAfterQueue ~= true then
        return false
    end

    local callback = self.pendingCloseCallback
    local footerAction = self.pendingCloseFooterAction

    self.pendingCloseAfterQueue = false
    self.pendingCloseDisplayTicks = nil
    self.pendingCloseCallback = nil
    self.pendingCloseFooterAction = nil

    if type(callback) == "function" then
        callback(self, footerAction and footerAction.data, footerAction)
    end

    if DT_ConversationUI.instance == self then
        self.closeReason = self.closeReason or "footer_leave"
        self:close()
    end

    return true
end

function DT_ConversationUI:requestExitConversation(footerAction)
    if #self.msgQueue > 0 or self.pendingCloseAfterQueue == true then
        return false
    end

    local isBackAction = type(footerAction) == "table" and footerAction.kind == "back" or false
    local shouldCloseAfter = footerAction == nil
        or isBackAction ~= true
        or footerAction.exitAfter == true
        or footerAction.closeAfter == true

    if shouldCloseAfter ~= true then
        local queuedMessages = self:queueFooterActionDialogue(footerAction, false)
        local callback = type(footerAction) == "table" and footerAction.onSelect or nil
        if type(callback) == "function" then
            callback(self, footerAction.data, footerAction)
            return true
        end
        return queuedMessages
    end

    self.closeReason = self.closeReason or "footer_leave"
    self.pendingCloseAfterQueue = true
    self.pendingCloseDisplayTicks = nil
    self.pendingCloseCallback = type(footerAction) == "table" and footerAction.onSelect or nil
    self.pendingCloseFooterAction = footerAction

    self:playExitConversationEmote(footerAction)

    if self:queueFooterActionDialogue(footerAction, true) then
        return true
    end

    return self:performPendingClose()
end
