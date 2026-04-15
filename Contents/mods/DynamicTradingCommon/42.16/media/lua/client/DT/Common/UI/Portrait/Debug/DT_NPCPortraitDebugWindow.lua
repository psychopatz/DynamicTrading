-- =============================================================================
-- DYNAMIC TRADING: SHARED PORTRAIT DEBUG WINDOW
-- =============================================================================
-- Debug-only portrait inspection window backed by the shared portrait panel.
-- =============================================================================

if not isDebugEnabled() then
    return
end

require "ISUI/ISCollapsableWindow"
require "ISUI/ISPanel"
require "DT/Common/UI/Portrait/Portrait"
require "DT/Common/UI/Portrait/Debug/DT_NPCPortraitDebugControls"

DT_NPCPortraitDebugWindow = DT_NPCPortraitDebugWindow or ISCollapsableWindow:derive("DT_NPCPortraitDebugWindow")
DT_NPCPortraitDebugWindow.instance = nil

local MODEL_SIZE = 256
local PANEL_W = 320
local PANEL_H = 605
local CTRL_X = 10

local function resolveNPCData(zombie)
    if not zombie then
        return nil
    end

    if DTNPC and DTNPC.GetData then
        local npcData = DTNPC.GetData(zombie)
        if npcData then
            return npcData
        end
    end

    local modData = zombie:getModData()
    return modData and (modData.DTNPC_Data or modData.DTNPCBrain) or nil
end

function DT_NPCPortraitDebugWindow:initialise()
    ISCollapsableWindow.initialise(self)
    self.resizable = false
    self.pin = true
    self.targetZombie = nil
    self.targetName = "None"
    self.isOverlayOn = false
end

function DT_NPCPortraitDebugWindow:createChildren()
    ISCollapsableWindow.createChildren(self)

    local th = self:titleBarHeight()
    local y = th + 5
    local modelX = math.floor((PANEL_W - MODEL_SIZE) / 2)

    self.portraitPanel = DT_NPCPortraitPanel:new(modelX, y, MODEL_SIZE, MODEL_SIZE, {
        interactive = true,
        forceMode = "3d",
        overlayStyle = "none"
    })
    self.portraitPanel:initialise()
    self.portraitPanel:instantiate()
    self:addChild(self.portraitPanel)
    self.portraitPanel:setAnimationProfile("debug")
    self.portraitPanel:resetViewState()

    y = y + MODEL_SIZE + 10

    self.infoPanel = ISPanel:new(CTRL_X, y, PANEL_W - (CTRL_X * 2), 64)
    self.infoPanel:initialise()
    self.infoPanel:instantiate()
    self.infoPanel.backgroundColor = { r = 0.08, g = 0.08, b = 0.08, a = 0.65 }
    self.infoPanel.borderColor = { r = 0.35, g = 0.35, b = 0.35, a = 0.9 }
    self.infoPanel.prerender = function(panel)
        ISPanel.prerender(panel)
        local parent = panel.parent
        if not parent or not parent.portraitPanel then
            return
        end

        local targetR, targetG, targetB = 0.7, 0.7, 0.7
        if parent.targetZombie then
            targetR, targetG, targetB = 0.4, 1.0, 0.4
        end

        local portrait = parent.portraitPanel
        panel:drawText("Target: " .. tostring(parent.targetName or "None"), 8, 6, targetR, targetG, targetB, 1.0, UIFont.Small)
        panel:drawText(string.format("Zoom: %.1f", tonumber(portrait.currentZoom) or 0), 8, 24, 0.78, 0.78, 0.78, 1.0, UIFont.Small)
        panel:drawText(string.format("Offset: %.2f, %.2f", tonumber(portrait.currentXOffset) or 0, tonumber(portrait.currentYOffset) or 0), 120, 24, 0.78, 0.78, 0.78, 1.0, UIFont.Small)
        panel:drawText("Dir: " .. tostring(portrait:getDirectionName()), 8, 42, 0.78, 0.78, 0.78, 1.0, UIFont.Small)
    end
    self:addChild(self.infoPanel)

    DT_NPCPortraitDebugControls.Build(self, y + 72)
end

function DT_NPCPortraitDebugWindow:updateLabels()
    if self.infoPanel then
        self.infoPanel:setVisible(false)
        self.infoPanel:setVisible(true)
    end
end

function DT_NPCPortraitDebugWindow:setTarget(character, name, targetData)
    self.targetZombie = character
    self.targetName = name or "Unknown"
    self.portraitPanel:setTargetCharacter(character, targetData)
    self:updateLabels()
end

function DT_NPCPortraitDebugWindow:setDummyTarget(targetData)
    self.targetZombie = nil
    self.targetName = (targetData and targetData.name or "Dummy") .. " (Dummy)"
    self.portraitPanel:setTargetData(targetData)
    self:updateLabels()
end

function DT_NPCPortraitDebugWindow:onUsePlayer()
    local player = getSpecificPlayer(0)
    if not player then
        return
    end

    self:setTarget(player, "Player", {
        name = "Player",
        gender = player:isFemale() and "Female" or "Male",
        isFemale = player:isFemale()
    })
end

function DT_NPCPortraitDebugWindow:onUseNearestNPC()
    local player = getSpecificPlayer(0)
    local cell = getCell()
    if not player or not cell then
        return
    end

    local zombieList = cell:getZombieList()
    if not zombieList then
        return
    end

    local bestZombie = nil
    local bestDist = 9999
    local bestData = nil

    for i = 0, zombieList:size() - 1 do
        local zombie = zombieList:get(i)
        if zombie and not zombie:isDead() then
            local npcData = resolveNPCData(zombie)
            if npcData then
                local dx = player:getX() - zombie:getX()
                local dy = player:getY() - zombie:getY()
                local dist = math.sqrt((dx * dx) + (dy * dy))
                if dist < bestDist then
                    bestDist = dist
                    bestZombie = zombie
                    bestData = npcData
                end
            end
        end
    end

    if bestZombie then
        local name = (bestData and bestData.name or "NPC") .. " (" .. (bestData and (bestData.archetypeID or bestData.archetype) or "?") .. ")"
        self:setTarget(bestZombie, name, bestData)
    else
        self.targetZombie = nil
        self.targetName = "No NPCs nearby!"
        self.portraitPanel:setTargetData(nil)
        self:updateLabels()
    end
end

function DT_NPCPortraitDebugWindow:onClear()
    self.targetZombie = nil
    self.targetName = "None"
    self.portraitPanel:setTargetData(nil)
    self:updateLabels()
end

function DT_NPCPortraitDebugWindow:onUseDummy()
    local archetypes = { "General", "Doctor", "Mechanic", "Foreman", "Scavenger" }
    local archetype = archetypes[ZombRand(#archetypes) + 1]
    self:setDummyTarget({
        name = "V1 " .. archetype,
        archetype = archetype,
        archetypeID = archetype,
        isFemale = ZombRand(2) == 0,
        identitySeed = ZombRand(1000) + 1
    })
end

function DT_NPCPortraitDebugWindow:onDirPrev()
    self.portraitPanel:cycleDirection(-1)
    self:updateLabels()
end

function DT_NPCPortraitDebugWindow:onDirNext()
    self.portraitPanel:cycleDirection(1)
    self:updateLabels()
end

function DT_NPCPortraitDebugWindow:onZoomIn()
    self.portraitPanel:adjustZoom(0.5)
    self:updateLabels()
end

function DT_NPCPortraitDebugWindow:onZoomOut()
    self.portraitPanel:adjustZoom(-0.5)
    self:updateLabels()
end

function DT_NPCPortraitDebugWindow:onToggleAnim()
    self.portraitPanel:setAnimate(not self.portraitPanel.isAnimating)
    self.btnToggleAnim:setTitle(self.portraitPanel.isAnimating and "Anim: ON" or "Anim: OFF")
    self.btnToggleAnim.backgroundColor = self.portraitPanel.isAnimating
        and { r = 0.2, g = 0.5, b = 0.2, a = 1.0 }
        or { r = 0.5, g = 0.2, b = 0.2, a = 1.0 }
end

function DT_NPCPortraitDebugWindow:onToggleIso()
    self.portraitPanel:setIsometric(not self.portraitPanel.isIsometric)
    self.btnToggleIso:setTitle(self.portraitPanel.isIsometric and "Iso: ON" or "Iso: OFF")
    self.btnToggleIso.backgroundColor = self.portraitPanel.isIsometric
        and { r = 0.2, g = 0.5, b = 0.2, a = 1.0 }
        or { r = 0.5, g = 0.2, b = 0.2, a = 1.0 }
end

function DT_NPCPortraitDebugWindow:onToggleOverlay()
    self.isOverlayOn = not self.isOverlayOn
    self.portraitPanel:setOverlayMode(self.isOverlayOn and "debug" or "none")
    self.btnToggleOverlay:setTitle(self.isOverlayOn and "Overlay: ON" or "Overlay: OFF")
    self.btnToggleOverlay.backgroundColor = self.isOverlayOn
        and { r = 0.2, g = 0.5, b = 0.2, a = 1.0 }
        or { r = 0.5, g = 0.2, b = 0.2, a = 1.0 }
end

function DT_NPCPortraitDebugWindow:onReset()
    self.isOverlayOn = false
    self.portraitPanel:setOverlayMode("none")
    self.portraitPanel:resetViewState()

    self.btnToggleAnim:setTitle("Anim: ON")
    self.btnToggleAnim.backgroundColor = { r = 0.2, g = 0.5, b = 0.2, a = 1.0 }
    self.btnToggleIso:setTitle("Iso: OFF")
    self.btnToggleIso.backgroundColor = { r = 0.5, g = 0.2, b = 0.2, a = 1.0 }
    self.btnToggleOverlay:setTitle("Overlay: OFF")
    self.btnToggleOverlay.backgroundColor = { r = 0.5, g = 0.2, b = 0.2, a = 1.0 }
    self:updateLabels()
end

function DT_NPCPortraitDebugWindow:close()
    self:setVisible(false)
    self:removeFromUIManager()
    if DT_NPCPortraitDebugWindow.instance == self then
        DT_NPCPortraitDebugWindow.instance = nil
    end
end

function DT_NPCPortraitDebugWindow.Open(targetZombie, targetName, targetData)
    if DT_NPCPortraitDebugWindow.instance then
        local inst = DT_NPCPortraitDebugWindow.instance
        inst:setVisible(not inst:getIsVisible())
        if inst:getIsVisible() then
            if targetZombie then
                inst:setTarget(targetZombie, targetName or "NPC", targetData)
            elseif targetData then
                inst:setDummyTarget(targetData)
            elseif not inst.targetZombie then
                inst:onUsePlayer()
            end
        end
        return inst
    end

    local sw = getCore():getScreenWidth()
    local x = sw - PANEL_W - 50
    local window = DT_NPCPortraitDebugWindow:new(x, 100, PANEL_W, PANEL_H)
    window:initialise()
    window:addToUIManager()
    window:setVisible(true)
    window:setTitle("Portrait Debug [UI3DModel]")

    DT_NPCPortraitDebugWindow.instance = window

    if targetZombie then
        window:setTarget(targetZombie, targetName or "NPC", targetData)
    elseif targetData then
        window:setDummyTarget(targetData)
    else
        window:onUsePlayer()
    end

    return window
end

function DT_NPCPortraitDebugWindow.OpenForZombie(zombie)
    if not zombie then
        return
    end

    local npcData = resolveNPCData(zombie)
    local name = "Unknown"
    if npcData then
        name = (npcData.name or "NPC") .. " (" .. (npcData.archetypeID or npcData.archetype or "?") .. ")"
    end

    return DT_NPCPortraitDebugWindow.Open(zombie, name, npcData)
end

return DT_NPCPortraitDebugWindow
