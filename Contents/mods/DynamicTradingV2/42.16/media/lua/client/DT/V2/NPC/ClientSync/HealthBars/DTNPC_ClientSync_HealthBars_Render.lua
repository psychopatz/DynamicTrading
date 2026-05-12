-- ==============================================================================
-- DTNPC_ClientSync_HealthBars_Render.lua
-- Rendering logic for names, bars, and floating damage text.
-- ==============================================================================

DTNPC_ClientSync_HealthBars = DTNPC_ClientSync_HealthBars or {}

local HealthBars = DTNPC_ClientSync_HealthBars
local modules = HealthBars.Modules or {}

HealthBars.Modules = modules

if modules.Render then
    return
end

modules.Render = true

local Constants = HealthBars.Constants
local Helpers = HealthBars.Helpers
local State = HealthBars.State

function ISDTNPCHealthBarManager:render()
    if not self.active then
        self:clearStencilRect()
        return
    end

    local player = self.player
    if not player then
        self:clearStencilRect()
        return
    end

    local zoom = getCore():getZoom(self.playerIndex)
    if zoom <= 0 then
        zoom = 1
    end

    local scaleDivisor = zoom > 1 and (zoom * 1.15) or 1
    local barWidth = Constants.BAR_WIDTH / scaleDivisor
    local barHeight = Constants.BAR_HEIGHT / scaleDivisor
    local staminaBarHeight = Constants.STAMINA_BAR_HEIGHT / scaleDivisor
    local staminaBarGap = Constants.STAMINA_BAR_GAP / scaleDivisor
    local nameYOffset = Constants.NAME_Y_OFFSET / zoom
    local barYOffset = Constants.BAR_Y_OFFSET / zoom
    local damageTextOffset = barYOffset + 26
    local currentTime = getTimeInMillis()

    for uuid, barData in pairs(self.barList) do
        local zombie = barData.zombie
        if zombie
            and not zombie:isDead()
            and math.abs(player:getZ() - zombie:getZ()) <= Constants.FLOOR_TOLERANCE
            and Helpers.calculateDistance(player, zombie) <= Constants.MAX_DRAW_DISTANCE
        then
            local alpha = zombie:getAlpha(self.playerIndex)
            if alpha > 0 then
                local screenX = isoToScreenX(self.playerIndex, zombie:getX(), zombie:getY(), zombie:getZ()) - self.x
                local screenY = isoToScreenY(self.playerIndex, zombie:getX(), zombie:getY(), zombie:getZ()) - self.y
                local nameColor = Helpers.getNameColor(barData.npcData, barData.uuid or uuid)

                self:drawText(
                    barData.name,
                    screenX - (barData.nameWidth / 2),
                    screenY - nameYOffset,
                    nameColor.r,
                    nameColor.g,
                    nameColor.b,
                    nameColor.a * alpha,
                    Constants.FONT_NAME
                )

                if barData.visibleUntil and currentTime <= barData.visibleUntil then
                    local hpRatio = Helpers.getHealthRatio(barData.currentHp, barData.maxHp)
                    local hpColor = barData.isIncapacitated
                        and Helpers.getIncapacitatedBarColor(currentTime)
                        or (barData.isWeakened and Helpers.getWeakenedBarColor())
                        or Helpers.getColorForRatio(hpRatio)
                    local barLeft = screenX - (barWidth / 2)
                    local barTop = screenY - barYOffset
                    local staminaTop = barTop + barHeight + staminaBarGap
                    local hpText = barData.hpText or Helpers.formatHealthText(barData.currentHp, barData.maxHp)
                    local hpTextWidth = barData.hpTextWidth or State.textManager:MeasureStringX(Constants.FONT_HP, hpText)
                    local staminaRatio = Helpers.getStaminaRatio(barData.staminaCurrent, barData.staminaMax)
                    local drawStamina = (tonumber(barData.staminaMax) or 0) > 0

                    self:drawRect(
                        barLeft - Constants.PADDING,
                        barTop - Constants.PADDING,
                        barWidth + (Constants.PADDING * 2),
                        barHeight + (Constants.PADDING * 2),
                        0.55 * alpha,
                        0,
                        0,
                        0
                    )
                    self:drawRect(
                        barLeft,
                        barTop,
                        barWidth * hpRatio,
                        barHeight,
                        hpColor.a * alpha,
                        hpColor.r,
                        hpColor.g,
                        hpColor.b
                    )
                    self:drawRectBorder(
                        barLeft - Constants.PADDING,
                        barTop - Constants.PADDING,
                        barWidth + (Constants.PADDING * 2),
                        barHeight + (Constants.PADDING * 2),
                        alpha,
                        (barData.isIncapacitated or barData.isWeakened) and math.min(1, hpColor.r + 0.08) or 0.4,
                        (barData.isIncapacitated or barData.isWeakened) and hpColor.g or 0.4,
                        (barData.isIncapacitated or barData.isWeakened) and hpColor.b or 0.4
                    )

                    -- Calculate total width for [Heart Icon] + [Gap] + [HP Text]
                    local heartIconSize = Constants.HEART_ICON_SIZE / scaleDivisor
                    local heartGap = Constants.HEART_ICON_GAP / scaleDivisor
                    local totalCounterWidth = heartIconSize + heartGap + hpTextWidth
                    
                    -- Center coordinates for the counter group
                    local counterX = screenX - (totalCounterWidth / 2)
                    local counterY = barTop - (Constants.HP_TEXT_TOP_GAP / zoom)
                    local heartIcon = Helpers.getHeartTexture()

                    -- Draw Heart Icon
                    if heartIcon then
                        local iconY = counterY + (2 / zoom) -- Slight vertical adjustment for alignment
                        self:drawTextureScaled(
                            heartIcon,
                            counterX,
                            iconY,
                            heartIconSize,
                            heartIconSize,
                            alpha,
                            1, 1, 1
                        )
                    end

                    local hpR, hpG, hpB = 0.1, 0.8, 0.1
                    if hpRatio < 0.25 then
                        hpR, hpG, hpB = 0.8, 0.1, 0.1
                    elseif hpRatio < 0.6 then
                        hpR, hpG, hpB = 0.8, 0.8, 0.1
                    end

                    self:drawText(
                        hpText,
                        counterX + heartIconSize + heartGap,
                        counterY,
                        hpR,
                        hpG,
                        hpB,
                        alpha,
                        Constants.FONT_HP
                    )

                    if barData.hasActiveBandage and barData.bandageIconTexture then
                        local iconSize = Constants.BANDAGE_ICON_SIZE / scaleDivisor
                        local iconX = barLeft + barWidth + Constants.BANDAGE_ICON_GAP
                        local iconY = barTop + ((barHeight - iconSize) / 2)
                        self:drawTextureScaled(
                            barData.bandageIconTexture,
                            iconX,
                            iconY,
                            iconSize,
                            iconSize,
                            alpha,
                            1,
                            1,
                            1
                        )
                    end

                    if drawStamina then
                        self:drawRect(
                            barLeft - Constants.PADDING,
                            staminaTop - Constants.PADDING,
                            barWidth + (Constants.PADDING * 2),
                            staminaBarHeight + (Constants.PADDING * 2),
                            0.45 * alpha,
                            0,
                            0,
                            0
                        )
                        self:drawRect(
                            barLeft,
                            staminaTop,
                            barWidth * staminaRatio,
                            staminaBarHeight,
                            0.92 * alpha,
                            0.96,
                            0.96,
                            0.96
                        )
                        self:drawRectBorder(
                            barLeft - Constants.PADDING,
                            staminaTop - Constants.PADDING,
                            barWidth + (Constants.PADDING * 2),
                            staminaBarHeight + (Constants.PADDING * 2),
                            alpha,
                            0.72,
                            0.72,
                            0.72
                        )
                    end
                end
            end
        end
    end

    for uuid, damageList in pairs(self.damageTexts) do
        for i = #damageList, 1, -1 do
            local dmg = damageList[i]
            if currentTime > dmg.expireTime then
                table.remove(damageList, i)
            else
                local duration = Constants.DAMAGE_TEXT_TTL
                local progress = math.min(1, (currentTime - dmg.timestamp) / duration)
                
                local timeOffset = (currentTime - dmg.timestamp) / Constants.DAMAGE_TEXT_SPEED
                local screenX = isoToScreenX(self.playerIndex, dmg.x, dmg.y, dmg.z) - self.x
                local screenY = isoToScreenY(self.playerIndex, dmg.x, dmg.y, dmg.z) - self.y - damageTextOffset - timeOffset

                -- Define base alpha for the damage text
                local damageAlpha = dmg.color.a
                local barData = self.barList[uuid]
                if barData and barData.zombie then
                    damageAlpha = damageAlpha * barData.zombie:getAlpha(self.playerIndex)
                end

                -- Smoothly cross-fade between fonts to simulate gradual shrinkage
                local function drawAnimatedText(text, x, y, r, g, b, baseAlpha, p)
                    local a1, a2, a3 = 0, 0, 0
                    if p < 0.3 then
                        a1 = (0.3 - p) / 0.3
                        a2 = p / 0.3
                    elseif p < 0.6 then
                        a2 = (0.6 - p) / 0.3
                        a3 = (p - 0.3) / 0.3
                    else
                        a3 = 1
                    end
                    
                    local finalAlpha = baseAlpha * (p > 0.7 and (1 - (p - 0.7) / 0.3) or 1)
                    
                    if a1 > 0.05 then
                        local w = State.textManager:MeasureStringX(UIFont.Large, text)
                        self:drawText(text, x - (w/2), y, r, g, b, finalAlpha * a1, UIFont.Large)
                    end
                    if a2 > 0.05 then
                        local w = State.textManager:MeasureStringX(UIFont.Medium, text)
                        self:drawText(text, x - (w/2), y, r, g, b, finalAlpha * a2, UIFont.Medium)
                    end
                    if a3 > 0.05 then
                        local w = State.textManager:MeasureStringX(UIFont.Small, text)
                        self:drawText(text, x - (w/2), y, r, g, b, finalAlpha * a3, UIFont.Small)
                    end
                end

                drawAnimatedText(dmg.text, screenX, screenY, dmg.color.r, dmg.color.g, dmg.color.b, damageAlpha, progress)
            end
        end

        if #damageList == 0 then
            self.damageTexts[uuid] = nil
        end
    end

    self:clearStencilRect()
end
