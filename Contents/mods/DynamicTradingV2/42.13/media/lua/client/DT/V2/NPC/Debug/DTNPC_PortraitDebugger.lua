-- ==============================================================================
-- DTNPC_PortraitDebugger.lua
-- Debug window for testing live 3D NPC portrait rendering via UI3DModel.
-- Supports mouse-drag rotation, scroll zoom, and direction/offset controls.
-- ==============================================================================
if not isDebugEnabled() then return end

require "ISUI/ISCollapsableWindow"
require "ISUI/ISButton"
require "ISUI/ISLabel"
require "ISUI/ISPanel"
require "ISUI/ISUI3DModel"

DTNPC_PortraitDebugger = ISCollapsableWindow:derive("DTNPC_PortraitDebugger")
DTNPC_PortraitDebugger.instance = nil

-- =============================================================================
-- CONSTANTS
-- =============================================================================

local MODEL_SIZE = 256
local PANEL_W = 320
local PANEL_H = 605
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

    -- Dedicated info panel for status text (prevents label clipping/overlap).
    local infoW = PANEL_W - (CTRL_X * 2)
    local infoH = 64
    self.infoPanel = ISPanel:new(CTRL_X, y, infoW, infoH)
    self.infoPanel:initialise()
    self.infoPanel:instantiate()
    self.infoPanel.backgroundColor = { r = 0.08, g = 0.08, b = 0.08, a = 0.65 }
    self.infoPanel.borderColor = { r = 0.35, g = 0.35, b = 0.35, a = 0.9 }
    self.infoPanel.prerender = function(panel)
        ISPanel.prerender(panel)
        local parent = panel.parent
        if not parent then return end

        local targetR, targetG, targetB = 0.7, 0.7, 0.7
        if parent.targetZombie then
            targetR, targetG, targetB = 0.4, 1.0, 0.4
        end

        panel:drawText("Target: " .. tostring(parent.targetName or "None"), 8, 6, targetR, targetG, targetB, 1.0, UIFont.Small)
        panel:drawText(string.format("Zoom: %.1f", tonumber(parent.currentZoom) or 0), 8, 24, 0.78, 0.78, 0.78, 1.0, UIFont.Small)
        panel:drawText(string.format("Offset: %.2f, %.2f", tonumber(parent.currentXOffset) or 0, tonumber(parent.currentYOffset) or 0), 120, 24, 0.78, 0.78, 0.78, 1.0, UIFont.Small)

        local dirEnum = DIRECTIONS[parent.currentDirIndex or 1]
        panel:drawText("Dir: " .. tostring(DIR_NAMES[dirEnum] or "?"), 8, 42, 0.78, 0.78, 0.78, 1.0, UIFont.Small)
    end
    self:addChild(self.infoPanel)
    y = y + infoH + 8

    -- =========================================================================
    -- CONTROLS ROW 1: Target Selection
    -- =========================================================================

    self.btnUsePlayer = ISButton:new(CTRL_X, y, 95, BTN_H, "Player", self, self.onUsePlayer)
    self.btnUsePlayer:initialise()
    self.btnUsePlayer.backgroundColor = {r=0.2, g=0.4, b=0.6, a=1}
    self:addChild(self.btnUsePlayer)

    self.btnUseNearestNPC = ISButton:new(CTRL_X + 100, y, 95, BTN_H, "Nearest", self, self.onUseNearestNPC)
    self.btnUseNearestNPC:initialise()
    self.btnUseNearestNPC.backgroundColor = {r=0.4, g=0.5, b=0.2, a=1}
    self:addChild(self.btnUseNearestNPC)

    self.btnUseDummy = ISButton:new(CTRL_X + 200, y, 95, BTN_H, "V1 Dummy", self, self.onUseDummy)
    self.btnUseDummy:initialise()
    self.btnUseDummy.backgroundColor = {r=0.4, g=0.3, b=0.6, a=1}
    self:addChild(self.btnUseDummy)
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

    -- Tip Panel
    y = y + BTN_H + 8
    local infoW = PANEL_W - (CTRL_X * 2)
    local footerH = 26
    self.footerPanel = ISPanel:new(CTRL_X, y, infoW, footerH)
    self.footerPanel:initialise()
    self.footerPanel:instantiate()
    self.footerPanel.backgroundColor = { r = 0.08, g = 0.08, b = 0.08, a = 0.65 }
    self.footerPanel.borderColor = { r = 0.35, g = 0.35, b = 0.35, a = 0.9 }
    self.footerPanel.prerender = function(panel)
        ISPanel.prerender(panel)
        panel:drawText("Drag model to pan. Scroll to zoom.", 8, 4, 0.55, 0.55, 0.55, 1.0, UIFont.Small)
    end
    self:addChild(self.footerPanel)
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
        self.targetZombie = nil
        self.targetName = "No NPCs nearby!"
        self:updateLabels()
    end
end

function DTNPC_PortraitDebugger:onClear()
    self.targetZombie = nil
    self.targetName = "None"
    if self.modelView then
        self.modelView:setCharacter(nil)
        self.modelView:setSurvivorDesc(nil)
        if self.modelView.javaObject then
            self.modelView.javaObject:clearVariables()
        end
        self.modelView:setOutfitName("Generic01", false, false)
    end
    self:updateLabels()
end

local function createPortraitItem(itemType)
    if not itemType or itemType == "" then
        return nil
    end

    if instanceItem then
        local ok, item = pcall(instanceItem, itemType)
        if ok and item then
            return item
        end
    end

    if InventoryItemFactory and InventoryItemFactory.CreateItem then
        local ok, item = pcall(InventoryItemFactory.CreateItem, itemType)
        if ok and item then
            return item
        end
    end

    return nil
end

local function createPortraitSurvivorDesc()
    if not SurvivorFactory or not SurvivorFactory.CreateSurvivor then
        return nil
    end

    if SurvivorType and SurvivorType.Neutral then
        local ok, desc = pcall(SurvivorFactory.CreateSurvivor, SurvivorType.Neutral, false)
        if ok and desc then
            return desc
        end
    end

    local ok, desc = pcall(SurvivorFactory.CreateSurvivor)
    if ok and desc then
        return desc
    end

    return nil
end

function DTNPC_PortraitDebugger:setDummyTarget(npcData)
    if not self.modelView then return end
    
    local isFemale = npcData.isFemale or false
    local desc = createPortraitSurvivorDesc()
    if not desc then
        self.targetZombie = nil
        self.targetName = "Dummy creation failed"
        self:updateLabels()
        return
    end
    desc:setFemale(isFemale)
    
    local humanVisual = desc:getHumanVisual()
    -- Skin
    local skinTexture = isFemale and "FemaleBody01" or "MaleBody01"
    humanVisual:setSkinTextureName(skinTexture)
    
    -- Hair
    local style = npcData.hairStyle or (DT_NPC_Wardrobe and DT_NPC_Wardrobe.GetHairStyleBySeed(npcData.archetypeID or "General", isFemale, npcData.identitySeed or 1))
    if style then humanVisual:setHairModel(style) end
    
    -- Beard
    local beard = npcData.beardStyle or (not isFemale and DT_NPC_Wardrobe and DT_NPC_Wardrobe.GetBeardStyleBySeed(npcData.archetypeID or "General", npcData.identitySeed or 1))
    if beard then humanVisual:setBeardModel(beard) elseif not isFemale then humanVisual:setBeardModel("") end
    
    -- Color
    local color = npcData.hairColor or (DT_NPC_Wardrobe and DT_NPC_Wardrobe.GetHairColorBySeed(npcData.archetypeID or "General", npcData.identitySeed or 1))
    if color and ImmutableColor then
        local immutableColor = ImmutableColor.new(color.r or 0.2, color.g or 0.1, color.b or 0.1, 1)
        humanVisual:setHairColor(immutableColor)
        humanVisual:setBeardColor(immutableColor)
    end
    
    -- Outfit
    desc:getWornItems():clear()
    
    local outfit = npcData.outfit or (DT_NPC_Wardrobe and DT_NPC_Wardrobe.GetOutfitBySeed(npcData.archetypeID or "General", isFemale, npcData.identitySeed or 1))
    if outfit and type(outfit) == "table" then
        local wornItems = desc:getWornItems()
        for _, itemType in ipairs(outfit) do
            if itemType and type(itemType) == "string" then
                local item = createPortraitItem(itemType)
                if item then
                    local loc = item:getBodyLocation()
                    if loc and loc ~= "" then
                        wornItems:setItem(loc, item)
                    end
                end
            end
        end
    end
    
    humanVisual:removeBlood()
    humanVisual:removeDirt()

    -- Keep descriptor clean for cross-version compatibility.
    if desc.resetModel then
        pcall(function()
            desc:resetModel()
        end)
    end

    self.targetZombie = nil
    self.targetName = (npcData.name or "V1 Trader") .. " (Dummy)"
    self.modelView:setCharacter(nil)
    self.modelView:setSurvivorDesc(desc)
    self:updateLabels()
end

function DTNPC_PortraitDebugger:onUseDummy()
    local archetypes = {"General", "Military", "Doctor", "Raider", "Mechanic"}
    local arch = archetypes[ZombRand(#archetypes) + 1]
    
    local npcData = {
        name = "V1 " .. arch,
        archetypeID = arch,
        isFemale = ZombRand(0, 2) == 1,
        identitySeed = ZombRand(1, 1000)
    }
    self:setDummyTarget(npcData)
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
end

-- =============================================================================
-- LABELS
-- =============================================================================

function DTNPC_PortraitDebugger:updateLabels()
    if self.infoPanel then
        self.infoPanel:setVisible(false)
        self.infoPanel:setVisible(true)
    end

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
