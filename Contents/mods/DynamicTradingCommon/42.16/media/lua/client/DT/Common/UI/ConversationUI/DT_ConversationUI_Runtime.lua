-- =============================================================================
-- DYNAMIC TRADING: CONVERSATION UI RUNTIME
-- =============================================================================
-- Update loop and message queue behavior.
-- =============================================================================

require "DT/Common/UI/ConversationUI/DT_ConversationUI_Core"

local function measureChatEntry(ui, entry)
    if not ui or not ui.chatList or not entry then
        return
    end

    local maxBubbleW = ui:getChatBubbleMaxWidth()
    local lines = DynamicTrading.Utils.WrapText(entry.text, maxBubbleW, ui.chatList.font)
    local tm = getTextManager()
    local actualMaxWidth = 0

    for _, line in ipairs(lines) do
        local width = tm:MeasureStringX(ui.chatList.font, line)
        if width > actualMaxWidth then
            actualMaxWidth = width
        end
    end

    local minW = DT_ConversationUI.MIN_BUBBLE_WIDTH or 100
    if actualMaxWidth < minW then
        actualMaxWidth = minW
    end

    local lineHeight = 18
    local totalHeight = (#lines * lineHeight) + 10
    if totalHeight < 30 then
        totalHeight = 30
    end

    entry.lines = lines
    entry.height = totalHeight
    entry.trueWidth = actualMaxWidth
end

function DT_ConversationUI:update()
    ISCollapsableWindow.update(self)

    local currentTime = getTimeInMillis and getTimeInMillis() or 0

    self.typingTick = self.typingTick + 1

    if type(self.onConversationUpdate) == "function" then
        self:onConversationUpdate(currentTime)
    end

    if self.target and self.target.factionID and self.typingTick % 30 == 0 then
        self:refreshFactionInfo()
    end

    if self.typingTick % 15 == 0 then
        local validationTarget = self.isContactConversation and nil or self.target
        local valid, invalidReason = true, nil
        if DynamicTrading and DynamicTrading.Utils and DynamicTrading.Utils.CheckInteractionValid then
            valid, invalidReason = DynamicTrading.Utils.CheckInteractionValid(self.interactionObj, nil, validationTarget)
        else
            valid = DynamicTrading.Utils.IsInteractionValid(self.interactionObj, nil, validationTarget)
        end

        if not valid then
            if self.isContactConversation then
                if self.lastValidationLogReason ~= invalidReason or self.typingTick % 120 == 0 then
                    DynamicTrading.Log(
                        "DTCommons",
                        "Dialog",
                        "Contact",
                        "Keeping contact conversation open despite invalid interaction. reason=" .. tostring(invalidReason)
                            .. " target=" .. tostring(self.target and (self.target.name or self.target.uuid or self.target.id) or "nil")
                            .. " hasInteractionObj=" .. tostring(self.interactionObj ~= nil)
                    )
                    self.lastValidationLogReason = invalidReason
                end
            else
                local keepOpen = self.keepOpenOnInvalidInteraction == true
                if not keepOpen and type(self.shouldKeepOpenOnInvalidInteraction) == "function" then
                    keepOpen = self:shouldKeepOpenOnInvalidInteraction(invalidReason) == true
                end

                if keepOpen then
                    if self.lastValidationLogReason ~= invalidReason or self.typingTick % 120 == 0 then
                        DynamicTrading.Log(
                            "DTCommons",
                            "Dialog",
                            "KeepOpen",
                            "Keeping conversation open despite invalid interaction. reason=" .. tostring(invalidReason)
                                .. " target=" .. tostring(self.target and (self.target.name or self.target.uuid or self.target.id) or "nil")
                                .. " hasInteractionObj=" .. tostring(self.interactionObj ~= nil)
                        )
                        self.lastValidationLogReason = invalidReason
                    end
                else
                    self.closeReason = invalidReason or "invalid_interaction"
                    DynamicTrading.Log(
                        "DTCommons",
                        "Dialog",
                        "Close",
                        "Closing conversation due to invalid interaction. reason=" .. tostring(self.closeReason)
                            .. " target=" .. tostring(self.target and (self.target.name or self.target.uuid or self.target.id) or "nil")
                            .. " hasInteractionObj=" .. tostring(self.interactionObj ~= nil)
                    )
                    self:close()
                    return
                end
            end
        else
            self.lastValidationLogReason = nil
        end
    end

    if self.pendingCloseAfterQueue == true and #self.msgQueue == 0 and self.pendingCloseDisplayTicks and self.pendingCloseDisplayTicks > 0 then
        self.pendingCloseDisplayTicks = self.pendingCloseDisplayTicks - 1
        if self.pendingCloseDisplayTicks <= 0 and self.performPendingClose then
            self:performPendingClose()
            return
        end
    end

    if #self.msgQueue > 0 then
        local msg = self.msgQueue[1]

        if msg.delay > 0 then
            msg.delay = msg.delay - 1
        else
            self:addMessage(msg.text, msg.author, msg.isPlayer, msg.style)

            if msg.sound then
                getSoundManager():PlaySound(msg.sound, false, 0.1)
            end

            table.remove(self.msgQueue, 1)
            if self.updateNavigationButtons then
                self:updateNavigationButtons()
            end

            if self.pendingCloseAfterQueue == true and #self.msgQueue == 0 then
                self.pendingCloseDisplayTicks = math.max(12, math.floor((DT_ConversationUI.TEXT_DELAY or 30) * 0.6))
            end
        end
    end
end

function DT_ConversationUI:queueMessage(text, author, isPlayer, delay, sound, style)
    table.insert(self.msgQueue, {
        text = text,
        author = author,
        isPlayer = isPlayer,
        delay = delay or 0,
        sound = sound,
        style = style,
    })

    if self.updateNavigationButtons then
        self:updateNavigationButtons()
    end
end

function DT_ConversationUI:speak(textOrPayload, style)
    local payload = nil
    if type(textOrPayload) == "table" then
        payload = textOrPayload
    else
        payload = {
            text = textOrPayload,
            style = style,
        }
    end

    local text = payload and payload.text or nil
    local author = payload and payload.author or self.target and self.target.name or "NPC"
    local soundName = "DT_RadioRandom"
    self:queueMessage(text, author, false, payload and payload.delay or DT_ConversationUI.TEXT_DELAY, soundName, payload and payload.style or nil)
end

function DT_ConversationUI:rebuildChatLayout()
    if not self.chatList or not self.chatList.items then
        return
    end

    for _, item in ipairs(self.chatList.items) do
        local entry = item and item.item or nil
        if entry then
            measureChatEntry(self, entry)
            item.height = (entry.height or 30) + 4
        end
    end

    if #self.chatList.items > 0 then
        self.chatList:ensureVisible(#self.chatList.items)
    end
end

function DT_ConversationUI:addMessage(text, author, isPlayer, style)
    if not text then
        return
    end

    if (not isPlayer) and self.portraitPanel and self.portraitPanel.pulseSpeechAnimation then
        self.portraitPanel:pulseSpeechAnimation()
    end

    local entry = {
        text = text,
        author = author,
        isPlayer = isPlayer,
        style = style,
    }
    measureChatEntry(self, entry)

    local item = self.chatList:addItem(author, entry)
    item.height = (entry.height or 30) + 4
    self.chatList:ensureVisible(#self.chatList.items)
end
