-- =============================================================================
-- DYNAMIC TRADING: CONVERSATION UI VISUALS
-- =============================================================================
-- Shared portrait panel binding and chat bubble rendering.
-- =============================================================================

require "DT/Common/UI/ConversationUI/DT_ConversationUI_Core"

local function clamp01(value)
    local numeric = tonumber(value)
    if numeric == nil then
        return nil
    end
    if numeric < 0 then
        return 0
    end
    if numeric > 1 then
        return 1
    end
    return numeric
end

local function readColorChannel(source, key, index, fallback)
    if type(source) ~= "table" then
        return fallback
    end

    local value = source[key]
    if value == nil and index ~= nil then
        value = source[index]
    end

    local normalized = clamp01(value)
    if normalized == nil then
        return fallback
    end
    return normalized
end

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

local function drawGlassBlock(target, x, y, width, height, alpha, r, g, b, accent)
    if width <= 0 or height <= 0 then
        return
    end

    local accentColor = accent or { 0.82, 0.88, 0.74, 1.0 }
    target:drawRect(x, y, width, height, alpha, r, g, b)
    target:drawRect(x, y, math.max(60, math.floor(width * 0.54)), 1, alpha * 0.95, accentColor[1], accentColor[2], accentColor[3])
    target:drawRect(x, y + height - 1, math.max(40, math.floor(width * 0.38)), 1, alpha * 0.30, accentColor[1], accentColor[2], accentColor[3])
end

local function drawFrameBorder(target, x, y, width, height, color)
    local r = color and color.r or 0.52
    local g = color and color.g or 0.58
    local b = color and color.b or 0.52
    local a = color and color.a or 0.62
    target:drawRect(x, y, width, 1, a, r, g, b)
    target:drawRect(x, y + height - 1, width, 1, a * 0.70, r, g, b)
    target:drawRect(x, y, 1, height, a, r, g, b)
    target:drawRect(x + width - 1, y, 1, height, a * 0.70, r, g, b)
end

local function drawRectGradient(target, x, y, width, height, startAlpha, endAlpha, r, g, b, steps)
    local strips = math.max(6, steps or 24)
    local stripWidth = width / strips
    for index = 0, strips - 1 do
        local t = index / math.max(1, strips - 1)
        local eased = (t * t) * (3 - (2 * t))
        local alpha = startAlpha + ((endAlpha - startAlpha) * eased)
        local drawX = x + math.floor(index * stripWidth)
        local nextX = x + math.floor((index + 1) * stripWidth)
        local drawW = math.max(1, nextX - drawX)
        target:drawRect(drawX, y, drawW, height, alpha, r, g, b)
    end
end

local function drawFallbackEdgeFade(target, x, y, width, height)
    local sideW = math.max(18, math.floor(width * 0.09))
    target:drawRect(x, y, sideW, height, 0.09, 0, 0, 0)
    target:drawRect(x + width - sideW, y, sideW, height, 0.09, 0, 0, 0)
end

local function getAbsoluteRect(root, panel, child)
    local x = 0
    local y = 0

    if root then
        x = x + root:getX()
        y = y + root:getY()
    end
    if panel then
        x = x + panel:getX()
        y = y + panel:getY()
    end
    if child then
        x = x + child:getX()
        y = y + child:getY()
    end

    return x, y
end

local function getOverlayOpacity()
    if DT_ConfigManager and DT_ConfigManager.getConversationOverlayOpacity then
        return DT_ConfigManager.getConversationOverlayOpacity()
    end
    if DT_ConfigManager and DT_ConfigManager.settings then
        local value = tonumber(DT_ConfigManager.settings.conversationOverlayOpacity)
        if value then
            if value < 0 then value = 0 end
            if value > 1 then value = 1 end
            return value
        end
    end
    return 1.0
end

local function isTransparencyDisabled()
    if DT_ConfigManager and DT_ConfigManager.isConversationTransparencyDisabled then
        return DT_ConfigManager.isConversationTransparencyDisabled()
    end
    if DT_ConfigManager and DT_ConfigManager.settings then
        return DT_ConfigManager.settings.disableConversationTransparency == true
    end
    return false
end

local function getOverlayVisualState()
    local opacity = getOverlayOpacity()
    local solid = isTransparencyDisabled()

    if solid then
        return {
            opacity = opacity,
            solid = true,
            frameAlpha = 0.86 + (opacity * 0.10),
            rootAlpha = 0.78 + (opacity * 0.18),
            leftShadeAlpha = 0.70 + (opacity * 0.18),
            gradientStartAlpha = 0.76 + (opacity * 0.18),
            gradientEndAlpha = 0.54 + (opacity * 0.16),
            panelAlpha = 0.74 + (opacity * 0.20),
        }
    end

    return {
        opacity = opacity,
        solid = false,
        frameAlpha = 0.24 + (opacity * 0.46),
        rootAlpha = opacity * 0.72,
        leftShadeAlpha = opacity * 0.36,
        gradientStartAlpha = opacity * 0.52,
        gradientEndAlpha = opacity * 0.18,
        panelAlpha = opacity * 0.68,
    }
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

    self.portraitPanel:setBackgroundStyle("none")
    self.portraitPanel:setViewportMode("fill")
    self.portraitPanel:setOverlayMode(self.isRadio and "radio" or "none")
    self.portraitPanel:setRadioMode(self.isRadio == true)
    self.portraitPanel:setAnimationProfile(self.isRadio and "radio" or "conversation")
    self.portraitPanel:setLegacyProvider(nil)
    self.portraitPanel:setTargetCharacter(self.interactionObj, self.target)
end

function DT_ConversationUI:prerender()
    ISPanel.prerender(self)

    if not self.rootContent then
        return
    end

    local contentX = self.rootContent:getX()
    local contentY = self.rootContent:getY()
    local contentW = self.rootContent:getWidth()
    local contentH = self.rootContent:getHeight()
    local overlayState = getOverlayVisualState()
    local accent = self.visualAccentColor or { r = 0.80, g = 0.88, b = 0.76, a = 0.95 }
    drawGlassBlock(self, contentX, contentY, contentW, contentH, overlayState.rootAlpha, 0.02, 0.04, 0.03, { accent.r, accent.g, accent.b, 1.0 })

    local borderColor = {
        r = (self.visualBorderColor and self.visualBorderColor.r) or 0.52,
        g = (self.visualBorderColor and self.visualBorderColor.g) or 0.58,
        b = (self.visualBorderColor and self.visualBorderColor.b) or 0.52,
        a = overlayState.frameAlpha,
    }
    drawFrameBorder(self, 0, 0, self.width, self.height, borderColor)

    if self.layoutMetrics then
        local leftColumnW = math.min(contentW, self.layoutMetrics.leftW + math.floor(self.layoutMetrics.columnGap * 0.5))
        local gradientW = math.min(contentW, self.layoutMetrics.leftW + math.floor(self.layoutMetrics.portraitW * 0.22))
        self:drawRect(contentX, contentY, leftColumnW, contentH, overlayState.leftShadeAlpha, 0.01, 0.01, 0.01)
        drawRectGradient(self, contentX, contentY, gradientW, contentH, overlayState.gradientStartAlpha, overlayState.gradientEndAlpha, 0.01, 0.01, 0.01, 28)
    end

    if self.infoPanel then
        local infoX = contentX + self.infoPanel:getX()
        local infoY = contentY + self.infoPanel:getY()

        drawGlassBlock(
            self,
            infoX,
            infoY,
            self.infoPanel:getWidth(),
            self.infoPanel:getHeight(),
            overlayState.panelAlpha,
            0.02,
            0.02,
            0.02,
            { accent.r, accent.g, accent.b, 1.0 }
        )
    end

    if self.messagePanel then
        drawGlassBlock(
            self,
            contentX + self.messagePanel:getX(),
            contentY + self.messagePanel:getY(),
            self.messagePanel:getWidth(),
            self.messagePanel:getHeight(),
            overlayState.panelAlpha,
            0.02,
            0.02,
            0.02,
            { accent.r, accent.g, accent.b, 1.0 }
        )
    end

    if self.optionPanel then
        drawGlassBlock(
            self,
            contentX + self.optionPanel:getX(),
            contentY + self.optionPanel:getY(),
            self.optionPanel:getWidth(),
            self.optionPanel:getHeight(),
            overlayState.panelAlpha,
            0.03,
            0.03,
            0.02,
            { accent.r, accent.g, accent.b, 1.0 }
        )
    end

    if self.portraitContainer then
        local portraitX = contentX + self.portraitContainer:getX()
        local portraitY = contentY + self.portraitContainer:getY()
        local portraitW = self.portraitContainer:getWidth()
        local portraitH = self.portraitContainer:getHeight()

        local radialTex = DT_NPCPortraitRenderers.GetRadialFadeTexture and DT_NPCPortraitRenderers.GetRadialFadeTexture() or nil
        if radialTex then
            self:drawTextureScaled(radialTex, portraitX, portraitY, portraitW, portraitH, 0.24, 1.0, 1.0, 1.0)
        else
            drawFallbackEdgeFade(self, portraitX, portraitY, portraitW, portraitH)
        end
    end

    if self.infoPanel and self.layoutMetrics then
        local infoX = contentX + self.infoPanel:getX()
        local infoY = contentY + self.infoPanel:getY()
        local inset = self.headerInset or math.max(20, math.floor(self.layoutMetrics.leftW * 0.06))
        local headerTop = self.headerTopPad or 16
        local roleGap = self.headerRoleGap or 6
        local nameFont = self.headerNameFont or UIFont.Medium
        local roleFont = self.headerRoleFont or UIFont.Small
        local nameText = tostring(self.headerNameText or "Unknown")
        local roleText = tostring(self.headerRoleText or "Survivor")
        local nameColor = self.visualNameColor or { r = 0.98, g = 0.98, b = 0.96, a = 1.0 }
        local roleColor = self.visualRoleColor or { r = 0.88, g = 0.90, b = 0.84, a = 1.0 }

        self:drawText(nameText, infoX + inset, infoY + headerTop, nameColor.r, nameColor.g, nameColor.b, nameColor.a or 1.0, nameFont)
        self:drawText(roleText, infoX + inset, infoY + headerTop + (self.headerNameHeight or 24) + roleGap, roleColor.r, roleColor.g, roleColor.b, roleColor.a or 1.0, roleFont)
    end
end

function DT_ConversationUI:render()
    ISPanel.render(self)

    if #self.msgQueue > 0 and self.rootContent and self.messagePanel and self.chatList then
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

            local bubbleX, bubbleY = getAbsoluteRect(self.rootContent, self.messagePanel, self.chatList)
            bubbleX = bubbleX + 6
            bubbleY = bubbleY + self.chatList:getHeight() - 26

            self:drawRect(bubbleX, bubbleY, 46, 20, 0.24, 0.08, 0.11, 0.08)
            self:drawRect(0 + bubbleX, bubbleY, 18, 20, 0.38, 0.72, 0.92, 0.34)
            self:drawRect(bubbleX, bubbleY, 32, 1, 0.26, 0.88, 0.94, 0.84)
            self:drawText(dots, bubbleX + 18, bubbleY + 2, 0.88, 0.92, 0.88, 1, self.chatList.font)
        end
    end
end

function DT_ConversationUI:drawLogItem(y, item, alt)
    local data = item.item
    local width = self:getWidth()
    local scrollGap = (self.vscroll and self.vscroll:isVisible()) and 13 or 0
    local bubbleW = (data.trueWidth or 100) + 26
    local bubbleH = data.height or self.itemheight
    local x = 0
    local accentR, accentG, accentB = 0.80, 0.88, 0.76
    local bodyR, bodyG, bodyB = 0.08, 0.10, 0.08
    local bodyA = 0.20

    if data.isPlayer then
        x = width - bubbleW - scrollGap - 4
        accentR, accentG, accentB = 0.56, 0.84, 1.0
        bodyR, bodyG, bodyB = 0.05, 0.10, 0.15
        bodyA = 0.26
    else
        x = 4
        accentR, accentG, accentB = 0.78, 0.92, 0.54
        bodyR, bodyG, bodyB = 0.07, 0.10, 0.07
        bodyA = 0.20
    end

    local textR, textG, textB, textA = 0.92, 0.94, 0.90, 1
    local style = type(data.style) == "table" and data.style or nil
    if style then
        accentR = readColorChannel(style.accentColor, "r", 1, accentR)
        accentG = readColorChannel(style.accentColor, "g", 2, accentG)
        accentB = readColorChannel(style.accentColor, "b", 3, accentB)
        bodyR = readColorChannel(style.bodyColor, "r", 1, bodyR)
        bodyG = readColorChannel(style.bodyColor, "g", 2, bodyG)
        bodyB = readColorChannel(style.bodyColor, "b", 3, bodyB)
        bodyA = readColorChannel(style.bodyColor, "a", 4, bodyA)
        textR = readColorChannel(style.textColor, "r", 1, textR)
        textG = readColorChannel(style.textColor, "g", 2, textG)
        textB = readColorChannel(style.textColor, "b", 3, textB)
        textA = readColorChannel(style.textColor, "a", 4, textA)
    end

    self:drawRect(x, y + 1, bubbleW, bubbleH, bodyA, bodyR, bodyG, bodyB)
    self:drawRect(x, y + 1, 7, bubbleH, 0.46, accentR, accentG, accentB)
    self:drawRect(x, y + 1, math.max(32, math.floor(bubbleW * 0.40)), 1, 0.22, accentR, accentG, accentB)

    local ly = y + 6
    local font = self.font

    for _, line in ipairs(data.lines or {}) do
        self:drawText(line, x + 13, ly, textR, textG, textB, textA, font)
        ly = ly + 18
    end

    if data.isPlayer then
        self:drawRect(x + bubbleW - 32, y + bubbleH - 2, 28, 1, 0.20, accentR, accentG, accentB)
    else
        self:drawRect(x + 8, y + bubbleH - 2, 22, 1, 0.14, accentR, accentG, accentB)
    end

    return y + item.height
end
