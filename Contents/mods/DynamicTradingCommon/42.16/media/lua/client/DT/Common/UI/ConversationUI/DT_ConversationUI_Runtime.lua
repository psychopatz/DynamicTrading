-- =============================================================================
-- DYNAMIC TRADING: CONVERSATION UI RUNTIME
-- =============================================================================
-- Update loop and message queue behavior.
-- =============================================================================

require "DT/Common/UI/ConversationUI/DT_ConversationUI_Core"
require "DT/Common/Dialogue/DT_Dialogue_Vocals"

local DialogueVocals = DynamicTrading
    and DynamicTrading.Dialogue
    and DynamicTrading.Dialogue.Vocals

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

            local audio = msg.audio
            if not audio and msg.sound then
                audio = { uiSound = msg.sound, uiVolume = 0.1 }
            end

            if audio and DialogueVocals and DialogueVocals.PlaySpeechAudio then
                DialogueVocals.PlaySpeechAudio(self.interactionObj, self:getInteractionNPCData(), audio)
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

function DT_ConversationUI:getInteractionNPCData()
    if self.cachedInteractionObj == self.interactionObj and self.cachedInteractionNPCData then
        return self.cachedInteractionNPCData
    end

    local npcData = nil
    if self.interactionObj and DTNPC and DTNPC.GetData then
        npcData = DTNPC.GetData(self.interactionObj)
    end

    self.cachedInteractionObj = self.interactionObj
    self.cachedInteractionNPCData = npcData
    return npcData
end

function DT_ConversationUI:getDefaultPlayerMessageSound()
    if self.isRadio then
        return "DT_RadioRandom"
    end

    return nil
end

function DT_ConversationUI:getConversationTargetStatus()
    return self.target and (self.target.status or self.target.currentStatus) or nil
end

function DT_ConversationUI:getConversationTargetState()
    return self.target and (self.target.currentState or self.target.state) or nil
end

function DT_ConversationUI:getConversationDispositionHook()
    if not DialogueVocals or not DialogueVocals.ResolveDispositionHook then
        return nil
    end

    return DialogueVocals.ResolveDispositionHook(
        self:getInteractionNPCData(),
        self:getConversationTargetStatus(),
        self:getConversationTargetState(),
        self.target
    )
end

function DT_ConversationUI:getDefaultGreetingVocalHook()
    return self:getConversationDispositionHook() or "welcome"
end

function DT_ConversationUI:getDefaultFarewellVocalHook()
    return self:getConversationDispositionHook() or "bye"
end

function DT_ConversationUI:getDefaultNPCSpeechAudio(payload)
    if self.isRadio then
        return {
            uiSound = "DT_RadioRandom",
            uiVolume = 0.1,
        }
    end

    if not DialogueVocals or not DialogueVocals.BuildSpeechAudio then
        return {
            vocalType = payload and payload.vocalType or "Chat",
            channel = "conversation_ui",
            cooldownMs = 0,
        }
    end

    return DialogueVocals.BuildSpeechAudio(
        self:getInteractionNPCData(),
        {
            text = payload and payload.text or nil,
            sentiment = payload and payload.sentiment or nil,
            status = self:getConversationTargetStatus(),
            state = self:getConversationTargetState(),
            entry = payload,
            soundName = payload and payload.soundName or nil,
            vocalType = payload and payload.vocalType or nil,
            hook = payload and payload.vocalHook or self:getConversationDispositionHook(),
            channel = payload and payload.channel or "conversation_ui",
            cooldownMs = payload and payload.cooldownMs or 0,
        }
    )
end

function DT_ConversationUI:queuePlayerMessage(text, delay, style)
    if not text or text == "" then
        return false
    end

    self:queueMessage(text, "Me", true, delay or 0, self:getDefaultPlayerMessageSound(), style)
    return true
end

function DT_ConversationUI:queueMessage(text, author, isPlayer, delay, sound, style, audio)
    table.insert(self.msgQueue, {
        text = text,
        author = author,
        isPlayer = isPlayer,
        delay = delay or 0,
        sound = sound,
        style = style,
        audio = audio,
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
    local audio = nil
    if payload and type(payload.audio) == "table" then
        audio = payload.audio
    else
        audio = self:getDefaultNPCSpeechAudio(payload)
        if audio and payload and payload.soundName then
            audio.soundName = payload.soundName
        end
        if audio and payload and payload.vocalType then
            audio.vocalType = payload.vocalType
        end
    end

    local soundName = payload and (payload.sound or payload.uiSound) or nil
    self:queueMessage(
        text,
        author,
        false,
        payload and payload.delay or DT_ConversationUI.TEXT_DELAY,
        soundName,
        payload and payload.style or nil,
        audio
    )
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
