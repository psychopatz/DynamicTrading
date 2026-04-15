-- =============================================================================
-- DYNAMIC TRADING: SHARED PORTRAIT DEBUG CONTROLS
-- =============================================================================
-- Creates the reusable debug buttons around the shared portrait panel.
-- =============================================================================

require "ISUI/ISButton"
require "ISUI/ISPanel"

DT_NPCPortraitDebugControls = DT_NPCPortraitDebugControls or {}

local CTRL_X = 10
local CTRL_W_HALF = 145
local BTN_H = 25

local function addButton(window, x, y, w, title, callbackName, color)
    local btn = ISButton:new(x, y, w, BTN_H, title, window, window[callbackName])
    btn:initialise()
    btn.backgroundColor = color or { r = 0.3, g = 0.3, b = 0.3, a = 1.0 }
    window:addChild(btn)
    return btn
end

function DT_NPCPortraitDebugControls.Build(window, startY)
    local y = startY

    window.btnUsePlayer = addButton(window, CTRL_X, y, 95, "Player", "onUsePlayer", { r = 0.2, g = 0.4, b = 0.6, a = 1.0 })
    window.btnUseNearestNPC = addButton(window, CTRL_X + 100, y, 95, "Nearest", "onUseNearestNPC", { r = 0.4, g = 0.5, b = 0.2, a = 1.0 })
    window.btnUseDummy = addButton(window, CTRL_X + 200, y, 95, "V1 Dummy", "onUseDummy", { r = 0.4, g = 0.3, b = 0.6, a = 1.0 })
    y = y + BTN_H + 5

    window.btnDirPrev = addButton(window, CTRL_X, y, CTRL_W_HALF, "<< Direction", "onDirPrev")
    window.btnDirNext = addButton(window, CTRL_X + CTRL_W_HALF + 10, y, CTRL_W_HALF, "Direction >>", "onDirNext")
    y = y + BTN_H + 5

    window.btnZoomIn = addButton(window, CTRL_X, y, CTRL_W_HALF, "Zoom In (+)", "onZoomIn")
    window.btnZoomOut = addButton(window, CTRL_X + CTRL_W_HALF + 10, y, CTRL_W_HALF, "Zoom Out (-)", "onZoomOut")
    y = y + BTN_H + 5

    window.btnToggleAnim = addButton(window, CTRL_X, y, CTRL_W_HALF, "Anim: ON", "onToggleAnim", { r = 0.2, g = 0.5, b = 0.2, a = 1.0 })
    window.btnToggleIso = addButton(window, CTRL_X + CTRL_W_HALF + 10, y, CTRL_W_HALF, "Iso: OFF", "onToggleIso", { r = 0.5, g = 0.2, b = 0.2, a = 1.0 })
    y = y + BTN_H + 5

    window.btnToggleOverlay = addButton(window, CTRL_X, y, CTRL_W_HALF, "Overlay: OFF", "onToggleOverlay", { r = 0.5, g = 0.2, b = 0.2, a = 1.0 })
    y = y + BTN_H + 5

    window.btnReset = addButton(window, CTRL_X, y, CTRL_W_HALF, "Reset Values", "onReset", { r = 0.5, g = 0.4, b = 0.1, a = 1.0 })
    window.btnClear = addButton(window, CTRL_X + CTRL_W_HALF + 10, y, CTRL_W_HALF, "Clear Target", "onClear", { r = 0.5, g = 0.2, b = 0.2, a = 1.0 })
    y = y + BTN_H + 8

    local footerW = window:getWidth() - (CTRL_X * 2)
    window.footerPanel = ISPanel:new(CTRL_X, y, footerW, 26)
    window.footerPanel:initialise()
    window.footerPanel:instantiate()
    window.footerPanel.backgroundColor = { r = 0.08, g = 0.08, b = 0.08, a = 0.65 }
    window.footerPanel.borderColor = { r = 0.35, g = 0.35, b = 0.35, a = 0.9 }
    window.footerPanel.prerender = function(panel)
        ISPanel.prerender(panel)
        panel:drawText("Drag model to pan. Scroll to zoom.", 8, 4, 0.55, 0.55, 0.55, 1.0, UIFont.Small)
    end
    window:addChild(window.footerPanel)

    return y + 26
end

return DT_NPCPortraitDebugControls
