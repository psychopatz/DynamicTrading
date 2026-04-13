-- ==============================================================================
-- DTNPC_PortraitDebugger.lua
-- Debug window for testing live 3D NPC portrait rendering via UI3DModel.
-- Supports mouse-drag rotation, scroll zoom, and direction/offset controls.
-- ==============================================================================
if not isDebugEnabled() then return end

require "ISUI/ISCollapsableWindow"
require "ISUI/ISButton"
require "ISUI/ISLabel"
require "ISUI/ISUI3DModel"

DTNPC_PortraitDebugger = ISCollapsableWindow:derive("DTNPC_PortraitDebugger")
DTNPC_PortraitDebugger.instance = nil

-- =============================================================================
-- CONSTANTS
-- =============================================================================

local MODEL_SIZE = 256
local PANEL_W = 320
local PANEL_H = 550
local CTRL_X = 10
local CTRL_W_HALF = 145
local BTN_H = 25

-- Direction order for cycling
local DIRECTIONS = {
    IsoDirections.S,
    IsoDirections.SE,
    IsoDirections.E,
    IsoDirections.NE,
    IsoDirections.N,
    IsoDirections.NW,
    IsoDirections.W,
    IsoDirections.SW,
}

local DIR_NAMES = {
    [IsoDirections.S]  = "S (Front)",
    [IsoDirections.SE] = "SE",
    [IsoDirections.E]  = "E (Right)",
    [IsoDirections.NE] = "NE",
    [IsoDirections.N]  = "N (Back)",
    [IsoDirections.NW] = "NW",
    [IsoDirections.W]  = "W (Left)",
    [IsoDirections.SW] = "SW",
}

-- =============================================================================
-- INITIALISE
-- =============================================================================

function DTNPC_PortraitDebugger:initialise()
    ISCollapsableWindow.initialise(self)
    self.resizable = false

    -- State
    self.currentZoom = 14.0
    self.currentXOffset = 0.0
    self.currentYOffset = -0.85
    self.currentDirIndex = 1
    self.isAnimating = true
    self.isIsometric = false
    self.isOverlayOn = false
    self.targetZombie = nil
    self.targetName = "None"

    -- Drag state
    self.isDragging = false
    self.dragStartX = 0
    self.dragStartY = 0
    self.dragStartXOffset = 0
    self.dragStartYOffset = 0
end

-- =============================================================================
-- CREATE UI
-- =============================================================================

function DTNPC_PortraitDebugger:createChildren()
    ISCollapsableWindow.createChildren(self)

    local th = self:titleBarHeight()
    local y = th + 5

    -- 3D Model Element (using ISUI3DModel — the ISUIElement Lua wrapper for UI3DModel)
    local modelX = (PANEL_W - MODEL_SIZE) / 2
    self.modelView = ISUI3DModel:new(modelX, y, MODEL_SIZE, MODEL_SIZE)
    self.modelView.backgroundColor = {r=0, g=0, b=0, a=0}
    self.modelView.borderColor = {r=0.4, g=0.4, b=0.4, a=1}
    self.modelView:initialise()
    self.modelView:instantiate()
    self:addChild(self.modelView)

    -- Configure after instantiate() so javaObject exists
    if self.modelView.javaObject then
        self.modelView:setState("idle")
        self.modelView:setDirection(IsoDirections.S)
        self.modelView:setIsometric(false)
        self.modelView:setDoRandomExtAnimations(false)
        self.modelView:setZoom(self.currentZoom)
        self.modelView:setXOffset(self.currentXOffset)
        self.modelView:setYOffset(self.currentYOffset)
    end

    y = y + MODEL_SIZE + 10

    -- Info Label
    self.lblTarget = ISLabel:new(CTRL_X, y, 20, "Target: None", 0.8, 1.0, 0.8, 1, UIFont.Small, false)
    self:addChild(self.lblTarget)
    y = y + 22

    self.lblZoom = ISLabel:new(CTRL_X, y, 20, "Zoom: 3.0", 0.7, 0.7, 0.7, 1, UIFont.Small, false)
    self:addChild(self.lblZoom)

    self.lblOffset = ISLabel:new(CTRL_X + 160, y, 20, "Offset: 0.0, 0.3", 0.7, 0.7, 0.7, 1, UIFont.Small, false)
    self:addChild(self.lblOffset)
    y = y + 22

    self.lblDir = ISLabel:new(CTRL_X, y, 20, "Dir: S (Front)", 0.7, 0.7, 0.7, 1, UIFont.Small, false)
    self:addChild(self.lblDir)
    y = y + 28

    -- =========================================================================
    -- CONTROLS ROW 1: Target Selection
    -- =========================================================================

    self.btnUsePlayer = ISButton:new(CTRL_X, y, CTRL_W_HALF, BTN_H, "Use Player", self, self.onUsePlayer)
    self.btnUsePlayer:initialise()
    self.btnUsePlayer.backgroundColor = {r=0.2, g=0.4, b=0.6, a=1}
    self:addChild(self.btnUsePlayer)

    self.btnUseNearestNPC = ISButton:new(CTRL_X + CTRL_W_HALF + 10, y, CTRL_W_HALF, BTN_H, "Use Nearest NPC", self, self.onUseNearestNPC)
    self.btnUseNearestNPC:initialise()
    self.btnUseNearestNPC.backgroundColor = {r=0.4, g=0.5, b=0.2, a=1}
    self:addChild(self.btnUseNearestNPC)
    y = y + BTN_H + 5

    -- =========================================================================
    -- CONTROLS ROW 2: Direction
    -- =========================================================================

    self.btnDirPrev = ISButton:new(CTRL_X, y, CTRL_W_HALF, BTN_H, "<< Direction", self, self.onDirPrev)
    self.btnDirPrev:initialise()
    self.btnDirPrev.backgroundColor = {r=0.3, g=0.3, b=0.3, a=1}
    self:addChild(self.btnDirPrev)

    self.btnDirNext = ISButton:new(CTRL_X + CTRL_W_HALF + 10, y, CTRL_W_HALF, BTN_H, "Direction >>", self, self.onDirNext)
    self.btnDirNext:initialise()
    self.btnDirNext.backgroundColor = {r=0.3, g=0.3, b=0.3, a=1}
    self:addChild(self.btnDirNext)
    y = y + BTN_H + 5

    -- =========================================================================
    -- CONTROLS ROW 3: Zoom
    -- =========================================================================

    self.btnZoomIn = ISButton:new(CTRL_X, y, CTRL_W_HALF, BTN_H, "Zoom In (+)", self, self.onZoomIn)
    self.btnZoomIn:initialise()
    self.btnZoomIn.backgroundColor = {r=0.3, g=0.3, b=0.3, a=1}
    self:addChild(self.btnZoomIn)

    self.btnZoomOut = ISButton:new(CTRL_X + CTRL_W_HALF + 10, y, CTRL_W_HALF, BTN_H, "Zoom Out (-)", self, self.onZoomOut)
    self.btnZoomOut:initialise()
    self.btnZoomOut.backgroundColor = {r=0.3, g=0.3, b=0.3, a=1}
    self:addChild(self.btnZoomOut)
    y = y + BTN_H + 5

    -- =========================================================================
    -- CONTROLS ROW 4: Toggles
    -- =========================================================================

    self.btnToggleAnim = ISButton:new(CTRL_X, y, CTRL_W_HALF, BTN_H, "Anim: ON", self, self.onToggleAnim)
    self.btnToggleAnim:initialise()
    self.btnToggleAnim.backgroundColor = {r=0.2, g=0.5, b=0.2, a=1}
    self:addChild(self.btnToggleAnim)

    self.btnToggleIso = ISButton:new(CTRL_X + CTRL_W_HALF + 10, y, CTRL_W_HALF, BTN_H, "Iso: OFF", self, self.onToggleIso)
    self.btnToggleIso:initialise()
    self.btnToggleIso.backgroundColor = {r=0.5, g=0.2, b=0.2, a=1}
    self:addChild(self.btnToggleIso)
    y = y + BTN_H + 5

    -- =========================================================================
    -- CONTROLS ROW 5: Extra Toggles
    -- =========================================================================

    self.btnToggleOverlay = ISButton:new(CTRL_X, y, CTRL_W_HALF, BTN_H, "Overlay: OFF", self, self.onToggleOverlay)
    self.btnToggleOverlay:initialise()
    self.btnToggleOverlay.backgroundColor = {r=0.5, g=0.2, b=0.2, a=1}
    self:addChild(self.btnToggleOverlay)
    y = y + BTN_H + 5

    -- =========================================================================
    -- CONTROLS ROW 6: Reset & Clear
    -- =========================================================================

    self.btnReset = ISButton:new(CTRL_X, y, CTRL_W_HALF, BTN_H, "Reset Values", self, self.onReset)
    self.btnReset:initialise()
    self.btnReset.backgroundColor = {r=0.5, g=0.4, b=0.1, a=1}
    self:addChild(self.btnReset)

    self.btnClear = ISButton:new(CTRL_X + CTRL_W_HALF + 10, y, CTRL_W_HALF, BTN_H, "Clear Target", self, self.onClear)
    self.btnClear:initialise()
    self.btnClear.backgroundColor = {r=0.5, g=0.2, b=0.2, a=1}
    self:addChild(self.btnClear)

    -- Tip
    y = y + BTN_H + 10
    self.lblTip = ISLabel:new(CTRL_X, y, 16, "Drag model to adjust offset. Scroll to zoom.", 0.5, 0.5, 0.5, 1, UIFont.Small, false)
    self:addChild(self.lblTip)
end

-- =============================================================================
-- TARGET FUNCTIONS
-- =============================================================================

function DTNPC_PortraitDebugger:setTarget(character, name)
    if not self.modelView then return end
    self.targetZombie = character
    self.targetName = name or "Unknown"
    self.modelView:setCharacter(character)
    self:updateLabels()
end

function DTNPC_PortraitDebugger:onUsePlayer()
    local player = getSpecificPlayer(0)
    if player then
        self:setTarget(player, "Player")
    end
end

function DTNPC_PortraitDebugger:onUseNearestNPC()
    local player = getSpecificPlayer(0)
    if not player then return end

    local cell = getCell()
    if not cell then return end

    local zombieList = cell:getZombieList()
    if not zombieList then return end

    local bestZombie = nil
    local bestDist = 9999
    local bestName = "Unknown NPC"

    for i = 0, zombieList:size() - 1 do
        local zombie = zombieList:get(i)
        if zombie and not zombie:isDead() then
            local modData = zombie:getModData()
            if modData and modData.IsDTNPC then
                local dx = player:getX() - zombie:getX()
                local dy = player:getY() - zombie:getY()
                local dist = math.sqrt(dx * dx + dy * dy)
                if dist < bestDist then
                    bestDist = dist
                    bestZombie = zombie

                    local npcData = modData.DTNPC_Data or modData.DTNPCBrain
                    if npcData and npcData.name then
                        bestName = npcData.name .. " (" .. (npcData.archetypeID or "?") .. ")"
                    end
                end
            end
        end
    end

    if bestZombie then
        self:setTarget(bestZombie, bestName)
    else
        self.lblTarget:setName("Target: No NPCs nearby!")
        self.lblTarget:setColor(1.0, 0.4, 0.4, 1.0)
    end
end

function DTNPC_PortraitDebugger:onClear()
    self.targetZombie = nil
    self.targetName = "None"
    if self.modelView then
        self.modelView:setCharacter(nil)
    end
    self:updateLabels()
end

-- =============================================================================
-- CONTROLS
-- =============================================================================

function DTNPC_PortraitDebugger:onDirPrev()
    self.currentDirIndex = self.currentDirIndex - 1
    if self.currentDirIndex < 1 then self.currentDirIndex = #DIRECTIONS end
    if self.modelView then
        self.modelView:setDirection(DIRECTIONS[self.currentDirIndex])
    end
    self:updateLabels()
end

function DTNPC_PortraitDebugger:onDirNext()
    self.currentDirIndex = self.currentDirIndex + 1
    if self.currentDirIndex > #DIRECTIONS then self.currentDirIndex = 1 end
    if self.modelView then
        self.modelView:setDirection(DIRECTIONS[self.currentDirIndex])
    end
    self:updateLabels()
end

function DTNPC_PortraitDebugger:onZoomIn()
    self.currentZoom = self.currentZoom + 0.5
    if self.currentZoom > 20.0 then self.currentZoom = 20.0 end
    if self.modelView then self.modelView:setZoom(self.currentZoom) end
    self:updateLabels()
end

function DTNPC_PortraitDebugger:onZoomOut()
    self.currentZoom = self.currentZoom - 0.5
    if self.currentZoom < 0.5 then self.currentZoom = 0.5 end
    if self.modelView then self.modelView:setZoom(self.currentZoom) end
    self:updateLabels()
end

function DTNPC_PortraitDebugger:onToggleAnim()
    self.isAnimating = not self.isAnimating
    if self.modelView and self.modelView.javaObject then self.modelView.javaObject:setAnimate(self.isAnimating) end
    self.btnToggleAnim:setTitle(self.isAnimating and "Anim: ON" or "Anim: OFF")
    self.btnToggleAnim.backgroundColor = self.isAnimating
        and {r=0.2, g=0.5, b=0.2, a=1}
        or  {r=0.5, g=0.2, b=0.2, a=1}
end

function DTNPC_PortraitDebugger:onToggleIso()
    self.isIsometric = not self.isIsometric
    if self.modelView then self.modelView:setIsometric(self.isIsometric) end
    self.btnToggleIso:setTitle(self.isIsometric and "Iso: ON" or "Iso: OFF")
    self.btnToggleIso.backgroundColor = self.isIsometric
        and {r=0.2, g=0.5, b=0.2, a=1}
        or  {r=0.5, g=0.2, b=0.2, a=1}
end

function DTNPC_PortraitDebugger:onToggleOverlay()
    self.isOverlayOn = not self.isOverlayOn
    self.btnToggleOverlay:setTitle(self.isOverlayOn and "Overlay: ON" or "Overlay: OFF")
    self.btnToggleOverlay.backgroundColor = self.isOverlayOn
        and {r=0.2, g=0.5, b=0.2, a=1}
        or  {r=0.5, g=0.2, b=0.2, a=1}
end

function DTNPC_PortraitDebugger:onReset()
    self.currentZoom = 14.0
    self.currentXOffset = 0.0
    self.currentYOffset = -0.85
    self.currentDirIndex = 1
    self.isAnimating = true
    self.isIsometric = false

    if self.modelView then
        self.modelView:setZoom(self.currentZoom)
        self.modelView:setXOffset(self.currentXOffset)
        self.modelView:setYOffset(self.currentYOffset)
        self.modelView:setDirection(DIRECTIONS[1])
        if self.modelView.javaObject then
            self.modelView.javaObject:setAnimate(true)
        end
        self.modelView:setIsometric(false)
    end

    self.btnToggleAnim:setTitle("Anim: ON")
    self.btnToggleAnim.backgroundColor = {r=0.2, g=0.5, b=0.2, a=1}
    self.btnToggleIso:setTitle("Iso: OFF")
    self.btnToggleIso.backgroundColor = {r=0.5, g=0.2, b=0.2, a=1}

    self:updateLabels()
end

-- =============================================================================
-- MOUSE INTERACTION (Drag to pan, Scroll to zoom)
-- =============================================================================

function DTNPC_PortraitDebugger:onMouseDown(x, y)
    -- Check if click is within the model area
    local modelX = self.modelView:getX()
    local modelY = self.modelView:getY()
    local modelW = self.modelView:getWidth()
    local modelH = self.modelView:getHeight()

    if x >= modelX and x <= modelX + modelW and y >= modelY and y <= modelY + modelH then
        self.isDragging = true
        self.dragStartX = x
        self.dragStartY = y
        self.dragStartXOffset = self.currentXOffset
        self.dragStartYOffset = self.currentYOffset
        return true
    end

    return ISCollapsableWindow.onMouseDown(self, x, y)
end

function DTNPC_PortraitDebugger:onMouseMove(dx, dy)
    if self.isDragging then
        -- Scale drag sensitivity relative to zoom (more zoomed = finer control)
        local sensitivity = 0.005 / math.max(self.currentZoom * 0.3, 0.5)
        self.currentXOffset = self.dragStartXOffset + (getMouseX() - self:getAbsoluteX() - self.dragStartX) * sensitivity
        self.currentYOffset = self.dragStartYOffset - (getMouseY() - self:getAbsoluteY() - self.dragStartY) * sensitivity

        if self.modelView then
            self.modelView:setXOffset(self.currentXOffset)
            self.modelView:setYOffset(self.currentYOffset)
        end
        self:updateLabels()
        return true
    end

    return ISCollapsableWindow.onMouseMove(self, dx, dy)
end

function DTNPC_PortraitDebugger:onMouseUp(x, y)
    if self.isDragging then
        self.isDragging = false
        return true
    end
    return ISCollapsableWindow.onMouseUp(self, x, y)
end

function DTNPC_PortraitDebugger:onMouseUpOutside(x, y)
    self.isDragging = false
    return ISCollapsableWindow.onMouseUpOutside(self, x, y)
end

function DTNPC_PortraitDebugger:onMouseWheel(del)
    -- Check if mouse is over the model area
    local mx = self:getMouseX()
    local my = self:getMouseY()
    local modelX = self.modelView:getX()
    local modelY = self.modelView:getY()
    local modelW = self.modelView:getWidth()
    local modelH = self.modelView:getHeight()

    if mx >= modelX and mx <= modelX + modelW and my >= modelY and my <= modelY + modelH then
        self.currentZoom = self.currentZoom - (del * 0.3)
        if self.currentZoom < 0.5 then self.currentZoom = 0.5 end
        if self.currentZoom > 20.0 then self.currentZoom = 20.0 end
        if self.modelView then self.modelView:setZoom(self.currentZoom) end
        self:updateLabels()
        return true
    end

    return false
end

function DTNPC_PortraitDebugger:prerender()
    ISCollapsableWindow.prerender(self)

    if not self.modelView then return end

    local mx = self.modelView:getX()
    local my = self.modelView:getY()
    local mw = self.modelView:getWidth()
    local mh = self.modelView:getHeight()

    -- Use the same dynamic time-of-day background from the Trading Window
    local bgTex = self:getBackgroundTexture()
    if bgTex then
        self:drawTextureScaled(bgTex, mx, my, mw, mh, 1.0, 1.0, 1.0, 1.0)
    else
        self:drawRect(mx, my, mw, mh, 1.0, 0.15, 0.15, 0.15)
    end
end

function DTNPC_PortraitDebugger:getBackgroundTexture()
    -- Copy logic from DT_TradingHelpers_Visuals to match exactly
    local hour = GameTime:getInstance():getHour()
    local filename = "twilight"
    if hour >= 4 and hour < 6 then filename = "dawn"
    elseif hour >= 6 and hour < 9 then filename = "sunrise"
    elseif hour >= 9 and hour < 17 then
        local dayTex = getTexture("media/ui/Backgrounds/day.png")
        if dayTex then return dayTex else filename = "sunrise" end
    elseif hour >= 17 and hour < 19 then filename = "sunset"
    elseif hour >= 19 and hour < 21 then filename = "dusk"
    elseif hour >= 21 or hour < 4 then filename = "twilight"
    end
    local path = "media/ui/Backgrounds/" .. filename .. ".png"
    local tex = getTexture(path)
    return tex or getTexture("media/ui/Backgrounds/twilight.png")
end

function DTNPC_PortraitDebugger:render()
    ISCollapsableWindow.render(self)

    if not self.modelView then return end

    local mx = self.modelView:getX()
    local my = self.modelView:getY()
    local mw = self.modelView:getWidth()
    local mh = self.modelView:getHeight()

    -- CRT Overlay (Matches Trading UI logic)
    if self.isOverlayOn then
        if not self.overlayTex then
            self.overlayTex = getTexture("media/ui/Effects/crt.png")
        end
        if self.overlayTex then
            -- Simple static chaotic transparency value to mimic the effect without the trader loop overhead
            local gt = GameTime:getInstance()
            local chaosFactor = 1.0
            local alpha = (0.15 + (chaosFactor * 0.3)) + ZombRandFloat(0.0, 0.05 + (chaosFactor * 0.4))
            self:drawTextureScaled(self.overlayTex, mx, my, mw, mh, math.min(alpha, 0.9), 1, 1, 1)
        end
    end

    self:drawRectBorder(mx - 1, my - 1, mw + 2, mh + 2, 1.0, 0.4, 0.4, 0.4)

    -- Crosshair guides (center marker) ON TOP of the model
    local cx = mx + mw / 2
    local cy = my + mh / 2
    self:drawRect(cx - 1, cy - 8, 2, 16, 0.3, 0.5, 1.0, 0.5)
    self:drawRect(cx - 8, cy - 1, 16, 2, 0.3, 0.5, 1.0, 0.5)
end

-- =============================================================================
-- LABELS
-- =============================================================================

function DTNPC_PortraitDebugger:updateLabels()
    if self.lblTarget then
        self.lblTarget:setName("Target: " .. self.targetName)
        if self.targetZombie then
            self.lblTarget:setColor(0.4, 1.0, 0.4, 1.0)
        else
            self.lblTarget:setColor(0.7, 0.7, 0.7, 1.0)
        end
    end

    if self.lblZoom then
        self.lblZoom:setName(string.format("Zoom: %.1f", self.currentZoom))
    end

    if self.lblOffset then
        self.lblOffset:setName(string.format("Offset: %.2f, %.2f", self.currentXOffset, self.currentYOffset))
    end

    if self.lblDir then
        local dirEnum = DIRECTIONS[self.currentDirIndex]
        self.lblDir:setName("Dir: " .. (DIR_NAMES[dirEnum] or "?"))
    end
end

-- =============================================================================
-- STATIC: Open / Toggle
-- =============================================================================

function DTNPC_PortraitDebugger.Open(targetZombie, targetName)
    if DTNPC_PortraitDebugger.instance then
        local inst = DTNPC_PortraitDebugger.instance
        inst:setVisible(not inst:getIsVisible())
        if inst:getIsVisible() then
            if targetZombie then
                inst:setTarget(targetZombie, targetName or "NPC")
            elseif not inst.targetZombie then
                -- Fallback: Use the player as an immediate placeholder
                local player = getSpecificPlayer(0)
                if player then
                    inst:setTarget(player, "Player")
                end
            end
        end
        return
    end

    local sw = getCore():getScreenWidth()
    local x = sw - PANEL_W - 50
    local window = DTNPC_PortraitDebugger:new(x, 100, PANEL_W, PANEL_H)
    window:initialise()
    window:addToUIManager()
    window:setVisible(true)
    window.pin = true
    window:setTitle("Portrait Debug [UI3DModel]")

    DTNPC_PortraitDebugger.instance = window

    if targetZombie then
        window:setTarget(targetZombie, targetName or "NPC")
    else
        -- Fallback: Use the player as an immediate placeholder
        local player = getSpecificPlayer(0)
        if player then
            window:setTarget(player, "Player")
        end
    end
end

-- =============================================================================
-- STATIC: Open targeting a specific NPC zombie (for context menu integration)
-- =============================================================================

function DTNPC_PortraitDebugger.OpenForZombie(zombie)
    if not zombie then return end
    local npcData = nil
    local name = "Unknown"

    if DTNPC and DTNPC.GetData then
        npcData = DTNPC.GetData(zombie)
    end
    if not npcData then
        local modData = zombie:getModData()
        npcData = modData and (modData.DTNPC_Data or modData.DTNPCBrain) or nil
    end

    if npcData then
        name = (npcData.name or "NPC") .. " (" .. (npcData.archetypeID or "?") .. ")"
    end

    DTNPC_PortraitDebugger.Open(zombie, name)
end

return DTNPC_PortraitDebugger
