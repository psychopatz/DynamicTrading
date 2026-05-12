local Internal = DT_NPCPortraitPanelInternal

DT_NPCPortraitPanel = DT_NPCPortraitPanel or ISPanel:derive("DT_NPCPortraitPanel")

DT_NPCPortraitPanel.DIRECTIONS = {
    IsoDirections.S,
    IsoDirections.SE,
    IsoDirections.E,
    IsoDirections.NE,
    IsoDirections.N,
    IsoDirections.NW,
    IsoDirections.W,
    IsoDirections.SW,
}

DT_NPCPortraitPanel.DIR_NAMES = {
    [IsoDirections.S] = "S (Front)",
    [IsoDirections.SE] = "SE",
    [IsoDirections.E] = "E (Right)",
    [IsoDirections.NE] = "NE",
    [IsoDirections.N] = "N (Back)",
    [IsoDirections.NW] = "NW",
    [IsoDirections.W] = "W (Left)",
    [IsoDirections.SW] = "SW",
}

DT_NPCPortraitPanel.ANIMATION_PROFILES = {
    ["default"] = {
        ambientStates = { 20, 21, 24 },
        speechStates = { 23 },
        transactionStates = { 25 },
        ambientMinTicks = 240,
        ambientMaxTicks = 540,
        speechPulseTicks = 42,
        transactionPulseTicks = 34,
    },
    radio = {
        ambientStates = { 20, 21, 24 },
        speechStates = { 23 },
        transactionStates = { 25 },
        ambientMinTicks = 200,
        ambientMaxTicks = 420,
        speechPulseTicks = 42,
        transactionPulseTicks = 34,
    },
    conversation = {
        ambientStates = { 20, 21, 24 },
        speechStates = { 23 },
        transactionStates = { 25 },
        ambientMinTicks = 240,
        ambientMaxTicks = 520,
        speechPulseTicks = 42,
        transactionPulseTicks = 34,
    },
    trading = {
        ambientStates = { 20, 21, 24 },
        speechStates = { 23 },
        transactionStates = { 25 },
        ambientMinTicks = 220,
        ambientMaxTicks = 480,
        speechPulseTicks = 42,
        transactionPulseTicks = 34,
    },
    debug = {
        ambientStates = { 20, 21, 24 },
        speechStates = { 23 },
        transactionStates = { 25 },
        ambientMinTicks = 120,
        ambientMaxTicks = 260,
        speechPulseTicks = 42,
        transactionPulseTicks = 34,
    }
}

function Internal.GetPortraitRandomRange(minValue, maxValue)
    if minValue >= maxValue then
        return minValue
    end

    return minValue + ZombRand((maxValue - minValue) + 1)
end

function Internal.DrawTextureFitted(target, texture, x, y, width, height, alpha, r, g, b)
    local texWidth
    local texHeight
    local scale
    local drawWidth
    local drawHeight
    local drawX
    local drawY

    if not texture then
        return
    end

    texWidth = texture.getWidthOrig and texture:getWidthOrig() or texture:getWidth()
    texHeight = texture.getHeightOrig and texture:getHeightOrig() or texture:getHeight()
    if not texWidth or not texHeight or texWidth <= 0 or texHeight <= 0 then
        target:drawTextureScaled(texture, x, y, width, height, alpha or 1.0, r or 1.0, g or 1.0, b or 1.0)
        return
    end

    scale = math.min(width / texWidth, height / texHeight)
    drawWidth = texWidth * scale
    drawHeight = texHeight * scale
    drawX = x + ((width - drawWidth) / 2)
    drawY = y + ((height - drawHeight) / 2)
    target:drawTextureScaled(texture, drawX, drawY, drawWidth, drawHeight, alpha or 1.0, r or 1.0, g or 1.0, b or 1.0)
end
