-- =============================================================================
-- DYNAMIC TRADING V1: SIGNAL PANEL - LAYOUT
-- =============================================================================

V1_SignalPanel_Layout_logic = {}

function DT_SignalPanel:onResize()
    ISPanel.onResize(self)
    local w = self:getWidth()
    local h = self:getHeight()

    self.imgSize = h - 20
    if self.imgSize > w * 0.45 then
        self.imgSize = math.floor(w * 0.45)
    end
    if self.imgSize < 80 then
        self.imgSize = 80
    end

    self.imgX = 10
    self.imgY = (h - self.imgSize) / 2

    local startX = self.imgX + self.imgSize + 20
    local remWidth = w - startX - 10
    if remWidth < 120 then
        remWidth = 120
    end

    if self.btnOptions then
        local btnSize = 18
        self.btnOptions:setX(w - btnSize - 10)
        self.btnOptions:setY(10)
        self.btnOptions:setWidth(btnSize)
        self.btnOptions:setHeight(btnSize)
    end

    local headerSpace = 25
    local bottomSpace = 5
    local spacing = 6
    local availableH = h - headerSpace - bottomSpace
    local btnH = math.floor((availableH - spacing) / 2)

    if btnH < 22 then
        btnH = 22
    end
    if btnH > 35 then
        btnH = 35
    end

    local font = UIFont.Small
    if h > 220 then
        font = UIFont.Medium
    end

    local totalBlockH = (btnH * 2) + spacing
    local safeZoneCenterY = headerSpace + (availableH / 2)
    local currentY = safeZoneCenterY - (totalBlockH / 2)
    if currentY < headerSpace then
        currentY = headerSpace
    end

    local btns = { self.btnScan, self.btnInfo }
    for _, btn in ipairs(btns) do
        if btn then
            btn:setX(startX)
            btn:setWidth(remWidth)
            btn:setHeight(btnH)
            btn:setY(currentY)
            btn.font = font
            currentY = currentY + btnH + spacing
        end
    end

    self.btnX = startX
    self.btnWidth = remWidth
    self.btnY = self.btnScan and self.btnScan:getY() or headerSpace
end
