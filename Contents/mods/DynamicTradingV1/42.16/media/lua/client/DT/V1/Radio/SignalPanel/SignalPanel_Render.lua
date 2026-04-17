-- =============================================================================
-- DYNAMIC TRADING V1: SIGNAL PANEL - RENDER
-- =============================================================================

V1_SignalPanel_Render_logic = {}

function DT_SignalPanel:render()
    ISPanel.render(self)

    if self.parent and self.parent.radioObj then
        local typeID = self:getRadioTypeID()
        local radioData = DynamicTrading.Config.GetRadioData(typeID)
        local power = radioData and radioData.power or 0.5
        if self.parent.isHam then
            power = power * (SandboxVars.DynamicTrading.HamRadioBonus or 2.0)
        end

        local r, g, b = 1, 1, 1
        if power < 1.0 then
            r, g, b = 1.0, 0.4, 0.4
        elseif power < 1.5 then
            r, g, b = 1.0, 0.9, 0.4
        else
            r, g, b = 0.4, 1.0, 0.4
        end

        local label = "Power: x" .. string.format("%.1f", power)
        local font = self.btnScan.font
        local textWidth = getTextManager():MeasureStringX(font, label)
        local centerX = self.btnX + (self.btnWidth / 2)
        local textX = centerX - (textWidth / 2)
        local textY = self.btnY - 20

        local iconSize = 16
        if font == UIFont.Medium then
            iconSize = 20
        end

        if typeID then
            local itemScript = ScriptManager.instance:getItem(typeID)
            local iconName = itemScript and itemScript:getIcon()
            local iconTex = iconName and getTexture("Item_" .. iconName)
            if iconTex then
                self:drawTextureScaled(iconTex, textX - iconSize - 5, textY - 2, iconSize, iconSize, 1, 1, 1, 1)
            end
        end

        self:drawText(label, textX, textY, r, g, b, 1.0, font)
    end
end
