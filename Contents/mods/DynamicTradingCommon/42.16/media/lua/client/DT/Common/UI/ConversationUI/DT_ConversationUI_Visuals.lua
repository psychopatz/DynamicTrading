-- =============================================================================
-- DYNAMIC TRADING: CONVERSATION UI VISUALS
-- =============================================================================
-- Shared portrait panel binding and chat bubble rendering.
-- =============================================================================

require "DT/Common/UI/ConversationUI/DT_ConversationUI_Core"

local function getPortraitKey(ui)
    local target = ui and ui.target or nil
    local interactionObj = ui and ui.interactionObj or nil
    local modeKey = DT_NPCPortraitRenderers.Use3DPortraits() and "3d" or "legacy"
    if not target then
        return modeKey .. ":none"
    end

    local targetID = target.uuid or target.traderID or target.id or target.name or "unknown"
    local liveRef = target.npcRef or interactionObj
    return table.concat({
        modeKey,
        tostring(targetID),
        tostring(target.identitySeed or 1),
        tostring(target.archetype or target.archetypeID or target.role or "General"),
        tostring(target.gender or (target.isFemale and "Female" or "Male") or "Male"),
        tostring(liveRef)
    }, ":")
end

function DT_ConversationUI:getBackgroundTexture()
    return DT_NPCPortraitRenderers.GetBackgroundTexture()
end

function DT_ConversationUI:refreshPortrait(force)
    if not self.portraitPanel then
        return
    end

    local nextKey = getPortraitKey(self)
    if (not force) and self._portraitKey == nextKey then
        return
    end

    self._portraitKey = nextKey

    self.portraitPanel:setOverlayMode(self.isRadio and "radio" or "none")
    self.portraitPanel:setRadioMode(self.isRadio == true)
    self.portraitPanel:setAnimationProfile(self.isRadio and "radio" or "conversation")
    self.portraitPanel:setLegacyProvider(nil)
    self.portraitPanel:setTargetCharacter(self.interactionObj, self.target)
end

function DT_ConversationUI:render()
    ISCollapsableWindow.render(self)

    if #self.msgQueue > 0 then
        local nextMsg = self.msgQueue[1]
        if (not nextMsg.isPlayer) and (nextMsg.delay > 0) then
            local frame = math.floor(self.typingTick / 10) % 4
            local dots = ""
            if frame == 1 then
                dots = "."
            elseif frame == 2 then
                dots = ".."
            elseif frame == 3 then
                dots = "..."
            end

            local bubbleX = self.chatList:getX() + 5
            local bubbleY = self.chatList:getY() + self.chatList:getHeight() - 25
            local bubbleW = 40
            local bubbleH = 20

            self:drawRect(bubbleX, bubbleY, bubbleW, bubbleH, 0.9, 0.2, 0.2, 0.2)
            self:drawRectBorder(bubbleX, bubbleY, bubbleW, bubbleH, 0.5, 0.5, 0.5, 0.5)
            self:drawText(dots, bubbleX + 12, bubbleY + 2, 0.8, 0.8, 0.8, 1, self.chatList.font)
        end
    end
end

function DT_ConversationUI:drawLogItem(y, item, alt)
    local data = item.item
    local width = self:getWidth()

    local bubbleW = data.trueWidth + 20
    local bubbleH = data.height
    local x = 0
    local r, g, b = 0.2, 0.2, 0.2

    if data.isPlayer then
        local scrollGap = (self.vscroll and self.vscroll:isVisible()) and 13 or 0
        local rightPadding = 2

        x = width - bubbleW - scrollGap - rightPadding
        r, g, b = 0.1, 0.2, 0.35
    else
        x = 5
        r, g, b = 0.15, 0.15, 0.15
    end

    self:drawRect(x, y, bubbleW, bubbleH, 0.8, r, g, b)
    self:drawRectBorder(x, y, bubbleW, bubbleH, 0.5, 0.6, 0.6, 0.6)

    local ly = y + 5
    local font = self.font
    local textR, textG, textB = 0.9, 0.9, 0.9

    for _, line in ipairs(data.lines) do
        self:drawText(line, x + 10, ly, textR, textG, textB, 1, font)
        ly = ly + 18
    end

    return y + item.height
end
