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
    local nameYOffset = Constants.NAME_Y_OFFSET / zoom
    local barYOffset = Constants.BAR_Y_OFFSET / zoom
    local damageTextOffset = barYOffset + 26
    local currentTime = getTimeInMillis()

    for _, barData in pairs(self.barList) do
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

                self:drawText(
                    barData.name,
                    screenX - (barData.nameWidth / 2),
                    screenY - nameYOffset,
                    1,
                    1,
                    1,
                    alpha,
                    Constants.FONT_NAME
                )

                if barData.visibleUntil and currentTime <= barData.visibleUntil then
                    local hpRatio = Helpers.getHealthRatio(barData.currentHp, barData.maxHp)
                    local hpColor = barData.isIncapacitated
                        and Helpers.getIncapacitatedBarColor(currentTime)
                        or Helpers.getColorForRatio(hpRatio)
                    local barLeft = screenX - (barWidth / 2)
                    local barTop = screenY - barYOffset
                    local hpText = barData.hpText or Helpers.formatHealthText(barData.currentHp, barData.maxHp)
                    local hpTextWidth = barData.hpTextWidth or State.textManager:MeasureStringX(Constants.FONT_HP, hpText)

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
                        barData.isIncapacitated and math.min(1, hpColor.r + 0.08) or 0.4,
                        barData.isIncapacitated and hpColor.g or 0.4,
                        barData.isIncapacitated and hpColor.b or 0.4
                    )

                    self:drawText(
                        hpText,
                        barLeft - Constants.HP_TEXT_GAP - hpTextWidth,
                        barTop - 3,
                        0.92,
                        0.2,
                        0.2,
                        alpha,
                        Constants.FONT_HP
                    )
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
                local timeOffset = (currentTime - dmg.timestamp) / Constants.DAMAGE_TEXT_SPEED
                local screenX = isoToScreenX(self.playerIndex, dmg.x, dmg.y, dmg.z) - self.x
                local screenY = isoToScreenY(self.playerIndex, dmg.x, dmg.y, dmg.z) - self.y - damageTextOffset - timeOffset

                self:drawText(
                    dmg.text,
                    screenX - (dmg.width / 2),
                    screenY,
                    dmg.color.r,
                    dmg.color.g,
                    dmg.color.b,
                    dmg.color.a,
                    Constants.FONT_DAMAGE
                )
            end
        end

        if #damageList == 0 then
            self.damageTexts[uuid] = nil
        end
    end

    self:clearStencilRect()
end
