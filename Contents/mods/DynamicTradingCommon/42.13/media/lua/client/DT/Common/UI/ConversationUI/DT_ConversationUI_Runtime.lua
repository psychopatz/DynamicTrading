-- =============================================================================
-- DYNAMIC TRADING: CONVERSATION UI RUNTIME
-- =============================================================================
-- Update loop and message queue behavior.
-- =============================================================================

require "DT/Common/UI/ConversationUI/DT_ConversationUI_Core"

function DT_ConversationUI:update()
    ISCollapsableWindow.update(self)

    self.typingTick = self.typingTick + 1

    local isNPCTyping = false
    if #self.msgQueue > 0 then
        local nextMsg = self.msgQueue[1]
        isNPCTyping = nextMsg and (not nextMsg.isPlayer) and (nextMsg.delay or 0) > 0
    end
    if self.portraitPanel and self.portraitPanel.setSpeechActive then
        self.portraitPanel:setSpeechActive(isNPCTyping)
    end

    if self.target and self.target.factionID and self.typingTick % 30 == 0 then
        self:refreshFactionInfo()
    end

    if self.typingTick % 15 == 0 then
        if not DynamicTrading.Utils.IsInteractionValid(self.interactionObj, nil, self.target) then
            self:close()
            return
        end
    end

    if #self.msgQueue > 0 then
        local msg = self.msgQueue[1]

        if msg.delay > 0 then
            msg.delay = msg.delay - 1
        else
            self:addMessage(msg.text, msg.author, msg.isPlayer)

            if msg.sound then
                getSoundManager():PlaySound(msg.sound, false, 0.1)
            end

            table.remove(self.msgQueue, 1)
        end
    end
end

function DT_ConversationUI:queueMessage(text, author, isPlayer, delay, sound)
    table.insert(self.msgQueue, {
        text = text,
        author = author,
        isPlayer = isPlayer,
        delay = delay or 0,
        sound = sound
    })
end

function DT_ConversationUI:speak(text)
    local author = self.target and self.target.name or "NPC"
    local soundName = "DT_RadioRandom"
    self:queueMessage(text, author, false, DT_ConversationUI.TEXT_DELAY, soundName)
end

function DT_ConversationUI:addMessage(text, author, isPlayer)
    if not text then
        return
    end

    if (not isPlayer) and self.portraitPanel and self.portraitPanel.pulseSpeechAnimation then
        self.portraitPanel:pulseSpeechAnimation(90)
    end

    local maxBubbleW = (self.chatList:getWidth() - 25) * 0.85
    local lines = DynamicTrading.Utils.WrapText(text, maxBubbleW, self.chatList.font)

    local tm = getTextManager()
    local actualMaxWidth = 0
    for _, line in ipairs(lines) do
        local w = tm:MeasureStringX(self.chatList.font, line)
        if w > actualMaxWidth then
            actualMaxWidth = w
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

    local entry = {
        text = text,
        lines = lines,
        author = author,
        isPlayer = isPlayer,
        height = totalHeight,
        trueWidth = actualMaxWidth
    }

    local item = self.chatList:addItem(author, entry)
    item.height = totalHeight + 4
    self.chatList:ensureVisible(#self.chatList.items)
end
