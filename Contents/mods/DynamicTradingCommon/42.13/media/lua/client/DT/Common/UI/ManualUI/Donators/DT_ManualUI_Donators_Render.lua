require "ISUI/ISPanel"
require "DT/Common/UI/ManualUI/DT_ManualUI_Utils"
require "DT/Common/UI/ManualUI/Donators/DT_ManualUI_Donators"

DT_ManualUI_Donators_Render = DT_ManualUI_Donators_Render or {}

local function wrapLines(text, width, font)
    if not text or tostring(text) == "" then
        return {}
    end

    if DynamicTrading and DynamicTrading.Utils and DynamicTrading.Utils.WrapText then
        return DynamicTrading.Utils.WrapText(tostring(text), width, font)
    end

    return { tostring(text) }
end

local function drawDonorCard(target, x, y, width, height, supporter, rank, currencySymbol, alpha, compact)
    target:drawRect(x, y, width, height, 0.26 * alpha, 0.08, 0.08, 0.08)
    target:drawRectBorder(x, y, width, height, 0.85 * alpha, 0.62, 0.48, 0.18)

    local padding = compact and 10 or 14
    local imageSize = compact and math.min(height - 20, 54) or math.min(math.floor(height * 0.58), math.min(width - (padding * 2), 210))
    local imageX = x + padding
    local imageY = y + padding

    if compact then
        imageY = y + math.max(8, math.floor((height - imageSize) / 2))
    else
        imageX = x + math.max(padding, math.floor((width - imageSize) / 2))
    end

    local texture = DT_ManualUI_Utils.resolveTexture(supporter and supporter.imagePath or "")
    if texture then
        target:drawTextureScaled(texture, imageX, imageY, imageSize, imageSize, alpha, 1, 1, 1)
    else
        target:drawRect(imageX, imageY, imageSize, imageSize, 0.22 * alpha, 0.18, 0.18, 0.18)
        target:drawTextCentre("No Image", imageX + (imageSize / 2), imageY + (imageSize / 2) - 8, 0.78, 0.72, 0.72, alpha, UIFont.Small)
    end
    target:drawRectBorder(imageX, imageY, imageSize, imageSize, 0.55 * alpha, 0.4, 0.4, 0.4)

    local badgeText = "Rank #" .. tostring(rank or 1)
    local badgeWidth = DT_ManualUI_Utils.safeMeasure(UIFont.Small, badgeText) + 12
    local badgeX = compact and (x + width - badgeWidth - 10) or (x + 10)
    local badgeY = compact and (y + 8) or (y + 10)
    target:drawRect(badgeX, badgeY, badgeWidth, 18, 0.68 * alpha, 0.46, 0.24, 0.08)
    target:drawText(badgeText, badgeX + 6, badgeY + 2, 0.98, 0.90, 0.68, alpha, UIFont.Small)

    local name = tostring(supporter and supporter.name or "Unnamed Supporter")
    local donation = DT_ManualUI_Donators.FormatDonation(supporter and supporter.totalDonation or 0, currencySymbol)

    if compact then
        local textX = imageX + imageSize + 14
        local textWidth = math.max(60, (x + width - 12) - textX)
        local nameLines = wrapLines(name, textWidth, UIFont.Medium)
        if #nameLines > 2 then
            nameLines = { nameLines[1], nameLines[2] }
        end
        local textHeight = (#nameLines * 18) + 18
        local textY = y + math.max(10, math.floor((height - textHeight) / 2))
        for _, line in ipairs(nameLines) do
            target:drawText(line, textX, textY, 0.98, 0.96, 0.92, alpha, UIFont.Medium)
            textY = textY + 18
        end
        target:drawText(donation, textX, textY + 2, 0.95, 0.74, 0.38, alpha, UIFont.Small)
        return
    end

    local nameLines = wrapLines(name, width - 48, UIFont.Medium)
    local textY = imageY + imageSize + 18
    for _, line in ipairs(nameLines) do
        target:drawTextCentre(line, x + (width / 2), textY, 0.98, 0.96, 0.92, alpha, UIFont.Medium)
        textY = textY + 20
    end
    target:drawTextCentre(donation, x + (width / 2), textY, 0.95, 0.74, 0.38, alpha, UIFont.Small)
end

local function drawPaginationDots(target, x, y, width, count, activeIndex)
    if count <= 1 then
        return
    end

    local totalWidth = (count * 10) + ((count - 1) * 6)
    local startX = x + math.floor((width - totalWidth) / 2)
    for index = 1, count do
        local alpha = index == activeIndex and 0.95 or 0.30
        local colorR = index == activeIndex and 0.96 or 0.85
        local colorG = index == activeIndex and 0.75 or 0.85
        local colorB = index == activeIndex and 0.34 or 0.85
        target:drawRect(startX + ((index - 1) * 16), y, 10, 10, alpha, colorR, colorG, colorB)
    end
end

function DT_ManualUI_Donators_Render.DrawContentCarousel(target, block, y, width, height)
    local x = 0
    target:drawRect(x, y, width, height - 1, 0.20, 0.06, 0.05, 0.04)
    target:drawText(block.title or "Hall of Fame Donators", 12, y + 8, 1, 0.90, 0.56, 1, UIFont.Medium)

    local supporters = block.supporters or {}
    local thankYouLines = wrapLines(block.thankYouText or "", width - 48, UIFont.Small)
    local thankYouHeight = #thankYouLines > 0 and ((#thankYouLines * 16) + 10) or 0
    local dotsHeight = #supporters > 1 and 18 or 0
    local cardX = 12
    local cardY = y + 34
    local cardW = width - 24
    local cardH = math.max(180, height - 54 - dotsHeight - thankYouHeight)

    if #supporters <= 0 then
        target:drawRect(cardX, cardY, cardW, cardH, 0.16, 0.10, 0.10, 0.10)
        target:drawTextCentre("No supporters have been added yet.", width / 2, cardY + math.floor(cardH / 2) - 12, 0.82, 0.82, 0.82, 1, UIFont.Small)
        local thankYouY = cardY + cardH + 10
        for _, line in ipairs(thankYouLines) do
            target:drawTextCentre(line, width / 2, thankYouY, 0.86, 0.84, 0.78, 1, UIFont.Small)
            thankYouY = thankYouY + 16
        end
        return
    end

    local currentIndex, nextIndex, blend = DT_ManualUI_Donators.GetCarouselFrame(supporters, block.autoplayMs, 300)

    if blend > 0 and supporters[nextIndex] then
        drawDonorCard(target, cardX, cardY, cardW, cardH, supporters[currentIndex], currentIndex, block.currencySymbol, 1 - blend, false)
        drawDonorCard(target, cardX, cardY, cardW, cardH, supporters[nextIndex], nextIndex, block.currencySymbol, blend, false)
        drawPaginationDots(target, cardX, cardY + cardH + 6, cardW, #supporters, nextIndex)
    else
        drawDonorCard(target, cardX, cardY, cardW, cardH, supporters[currentIndex], currentIndex, block.currencySymbol, 1, false)
        drawPaginationDots(target, cardX, cardY + cardH + 6, cardW, #supporters, currentIndex)
    end

    local thankYouY = cardY + cardH + dotsHeight + 8
    for _, line in ipairs(thankYouLines) do
        target:drawTextCentre(line, width / 2, thankYouY, 0.86, 0.84, 0.78, 1, UIFont.Small)
        thankYouY = thankYouY + 16
    end
end

function DT_ManualUI_Donators_Render.CreateBannerPreviewPanel(owner, x, y, width, height)
    local panel = ISPanel:new(x, y, width, height)
    panel:initialise()
    panel:instantiate()
    panel.noBackground = true
    panel.ownerWindow = owner

    function panel:prerender()
        self:drawRect(0, 0, self:getWidth(), self:getHeight(), 0.16, 0.08, 0.08, 0.08)
    end

    function panel:render()
        local window = self.ownerWindow
        local supporters = window and window.hallOfFameSupporters or {}
        local currencySymbol = window and window.hallOfFameCurrencySymbol or "$"
        local autoplayMs = window and window.hallOfFameAutoplayMs or 4000

        if not supporters or #supporters <= 0 then
            self:drawText("Hall of Fame", 8, 8, 1, 0.88, 0.52, 1, UIFont.Small)
            self:drawText("No supporters yet.", 8, 34, 0.84, 0.84, 0.84, 1, UIFont.Small)
            return
        end

        self:drawText("Hall of Fame", 8, 8, 1, 0.88, 0.52, 1, UIFont.Small)
        local currentIndex, nextIndex, blend = DT_ManualUI_Donators.GetCarouselFrame(supporters, autoplayMs, 300)
        local cardY = 24
        local cardH = self:getHeight() - 28

        if blend > 0 and supporters[nextIndex] then
            drawDonorCard(self, 8, cardY, self:getWidth() - 16, cardH, supporters[currentIndex], currentIndex, currencySymbol, 1 - blend, true)
            drawDonorCard(self, 8, cardY, self:getWidth() - 16, cardH, supporters[nextIndex], nextIndex, currencySymbol, blend, true)
        else
            drawDonorCard(self, 8, cardY, self:getWidth() - 16, cardH, supporters[currentIndex], currentIndex, currencySymbol, 1, true)
        end
    end

    return panel
end
