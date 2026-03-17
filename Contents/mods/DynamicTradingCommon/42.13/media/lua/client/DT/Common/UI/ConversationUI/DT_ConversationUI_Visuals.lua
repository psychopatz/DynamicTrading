-- =============================================================================
-- DYNAMIC TRADING: CONVERSATION UI VISUALS
-- =============================================================================
-- Portrait/background resolution and chat bubble rendering.
-- =============================================================================

require "DT/Common/UI/ConversationUI/DT_ConversationUI_Core"

function DT_ConversationUI:resolvePortrait(trader)
    if not trader then
        return nil
    end
    if trader.texture then
        return trader.texture
    end

    local arch = trader.archetype or trader.role or "General"
    local gender = trader.gender or "Male"
    local seed = trader.identitySeed or 1

    local mappedID = 1
    if DynamicTrading and DynamicTrading.Portraits and DynamicTrading.Portraits.GetMappedID then
        mappedID = DynamicTrading.Portraits.GetMappedID(arch, gender, seed)
    end

    local pathFolder = DynamicTrading.Portraits.GetPathFolder(arch, gender)
    local tex = getTexture(pathFolder .. tostring(mappedID) .. ".png")
    if tex then
        return tex
    end

    return getTexture("media/ui/Portraits/General/" .. gender .. "/1.png")
end

function DT_ConversationUI:getBackgroundTexture()
    local hour = GameTime:getInstance():getHour()
    local filename = "twilight"
    if hour >= 4 and hour < 6 then
        filename = "dawn"
    elseif hour >= 6 and hour < 9 then
        filename = "sunrise"
    elseif hour >= 9 and hour < 17 then
        local dayTex = getTexture("media/ui/Backgrounds/day.png")
        if dayTex then
            return dayTex
        end
        filename = "sunrise"
    elseif hour >= 17 and hour < 19 then
        filename = "sunset"
    elseif hour >= 19 and hour < 21 then
        filename = "dusk"
    elseif hour >= 21 or hour < 4 then
        filename = "twilight"
    end

    local path = "media/ui/Backgrounds/" .. filename .. ".png"
    local tex = getTexture(path)
    return tex or getTexture("media/ui/Backgrounds/twilight.png")
end

function DT_ConversationUI:render()
    ISCollapsableWindow.render(self)

    local x = 10
    local y = self.imageY
    local w = self.imageSize
    local h = self.imageSize

    local bgTex = self:getBackgroundTexture()
    if bgTex then
        self:drawTextureScaled(bgTex, x, y, w, h, 1.0, 1.0, 1.0, 1.0)
    else
        self:drawRect(x, y, w, h, 1, 0.1, 0.1, 0.1)
    end

    if self.targetTexture then
        self:drawTextureScaled(self.targetTexture, x, y, w, h, 1, 1, 1, 1)
    end

    if self.isRadio then
        local crtTex = getTexture("media/ui/Effects/crt.png")
        if crtTex then
            local alpha = 0.15 + ZombRandFloat(0.0, 0.05)
            if ZombRand(100) < 5 then
                alpha = alpha + ZombRandFloat(0.1, 0.25)
            end
            self:drawTextureScaled(crtTex, x, y, w, h, math.min(alpha, 0.9), 1, 1, 1)
        end
    end

    self:drawRectBorder(x, y, w, h, 1, 1.0, 1.0, 1.0)

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
