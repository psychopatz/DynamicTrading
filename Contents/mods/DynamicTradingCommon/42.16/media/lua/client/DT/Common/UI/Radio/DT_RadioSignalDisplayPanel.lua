require "ISUI/ISPanel"

DT_RadioSignalDisplayPanel = ISPanel:derive("DT_RadioSignalDisplayPanel")

DT_RadioSignalDisplayPanel.FRAME_COUNTS = {
    search = 5,
    found = 3,
    none = 3,
}

DT_RadioSignalDisplayPanel.DISPLAY_STATE_OVERRIDES = {
    -- Keep the logical waiting/off state intact, but show the scan animation.
    none = "search",
    off = "search",
    waiting = "search",
    ["waiting 1"] = "search",
    waiting1 = "search",
    waiting_1 = "search",
    scan = "search",
}

local function ensureTextures()
    if DT_RadioSignalDisplayPanel.TEXTURES then
        return
    end

    local textures = {
        search = {},
        found = {},
        none = {},
    }

    for i = 1, 5 do
        textures.search[i] = getTexture("media/ui/Radio/Signal_search/" .. i .. ".png")
    end

    for i = 1, 3 do
        textures.found[i] = getTexture("media/ui/Radio/Signal_found/" .. i .. ".png")
        textures.none[i] = getTexture("media/ui/Radio/Signal_none/" .. i .. ".png")
    end

    DT_RadioSignalDisplayPanel.TEXTURES = textures
end

local function isKnownSignalState(state)
    return DT_RadioSignalDisplayPanel.FRAME_COUNTS[state]
        or DT_RadioSignalDisplayPanel.DISPLAY_STATE_OVERRIDES[state]
end

function DT_RadioSignalDisplayPanel:getDisplaySignalState()
    return DT_RadioSignalDisplayPanel.DISPLAY_STATE_OVERRIDES[self.signalState] or self.signalState
end

function DT_RadioSignalDisplayPanel:initialise()
    ISPanel.initialise(self)
    ensureTextures()

    self.signalState = self.signalState or "none"
    self.signalFrame = self.signalFrame or 1
    self.signalAnimTimer = 0
    self.signalFrameDuration = self.signalFrameDuration or 200
    self.clickAnimTimer = 0
    self.padding = self.padding or 0
end

function DT_RadioSignalDisplayPanel:setSignalState(state)
    local nextState = isKnownSignalState(state) and state or "none"

    if self.signalState == nextState then
        return
    end

    self.signalState = nextState
    self.signalFrame = 1
    self.signalAnimTimer = 0
end

function DT_RadioSignalDisplayPanel:pulseStatic(durationMs)
    self.clickAnimTimer = math.max(self.clickAnimTimer or 0, durationMs or 300)
end

function DT_RadioSignalDisplayPanel:updateAnimation()
    local deltaTime = UIManager.getMillisSinceLastRender()

    if deltaTime <= 0 then
        return
    end

    if self.clickAnimTimer > 0 then
        self.clickAnimTimer = math.max(0, self.clickAnimTimer - deltaTime)
    end

    self.signalAnimTimer = self.signalAnimTimer + deltaTime

    while self.signalAnimTimer >= self.signalFrameDuration do
        self.signalAnimTimer = self.signalAnimTimer - self.signalFrameDuration
        self.signalFrame = self.signalFrame + 1

        local displayState = self:getDisplaySignalState()
        local maxFrames = DT_RadioSignalDisplayPanel.FRAME_COUNTS[displayState] or 3

        if self.signalFrame > maxFrames then
            self.signalFrame = 1
        end
    end
end

function DT_RadioSignalDisplayPanel:getCurrentTexture()
    local textures = DT_RadioSignalDisplayPanel.TEXTURES

    if not textures then
        return nil
    end

    if self.clickAnimTimer > 0 and textures.none and textures.none[2] then
        return textures.none[2]
    end

    local displayState = self:getDisplaySignalState()
    local stateTextures = textures[displayState]

    return stateTextures and stateTextures[self.signalFrame] or nil
end

function DT_RadioSignalDisplayPanel:prerender()
    ISPanel.prerender(self)
    self:updateAnimation()
end

function DT_RadioSignalDisplayPanel:render()
    ISPanel.render(self)

    local tex = self:getCurrentTexture()

    if not tex then
        return
    end

    local padding = self.padding or 0
    local availableWidth = math.max(0, self.width - (padding * 2))
    local availableHeight = math.max(0, self.height - (padding * 2))

    if availableWidth <= 0 or availableHeight <= 0 then
        return
    end

    local drawWidth = availableWidth
    local drawHeight = availableHeight

    if not self.stretchToBounds then
        local size = math.min(availableWidth, availableHeight)
        drawWidth = size
        drawHeight = size
    end

    local drawX = math.floor((self.width - drawWidth) / 2)
    local drawY = math.floor((self.height - drawHeight) / 2)

    self:drawTextureScaled(tex, drawX, drawY, drawWidth, drawHeight, 1, 1, 1, 1)
end

function DT_RadioSignalDisplayPanel:new(x, y, width, height, options)
    options = options or {}

    local o = ISPanel:new(x, y, width, height)

    setmetatable(o, self)
    self.__index = self

    o.backgroundColor = options.backgroundColor or { r = 0, g = 0, b = 0, a = 0 }
    o.borderColor = { r = 0, g = 0, b = 0, a = 0 }

    o.signalState = options.signalState or "none"
    o.signalFrameDuration = options.frameDuration or 200
    o.padding = options.padding or 12
    o.stretchToBounds = options.stretchToBounds == true

    return o
end