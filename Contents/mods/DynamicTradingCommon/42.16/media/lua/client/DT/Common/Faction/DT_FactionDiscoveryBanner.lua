require "ISUI/ISPanel"
require "Utils/ConfigManager/DT_ConfigManager"

DynamicTrading = DynamicTrading or {}
DynamicTrading.FactionDiscoveryBanner = DynamicTrading.FactionDiscoveryBanner or {}

local Banner = DynamicTrading.FactionDiscoveryBanner

Banner.WINDOW_ID = "FactionDiscoveryBanner"
Banner.DEFAULT_WIDTH = 560
Banner.DEFAULT_HEIGHT = 86
Banner.DEFAULT_TOP_MARGIN = 42
Banner.ENTER_DURATION = 0.26
Banner.EXIT_DURATION = 0.34
Banner.MAX_HOLD_DURATION = 3.0
Banner.DEFAULT_HOLD_DURATION = 1.0

local BannerPanel = ISPanel:derive("DT_FactionDiscoveryBannerPanel")

local function clamp01(value)
    value = tonumber(value) or 0
    if value < 0 then
        return 0
    end
    if value > 1 then
        return 1
    end
    return value
end

local function lerp(a, b, t)
    return a + ((b - a) * t)
end

local function easeOutCubic(t)
    t = clamp01(t)
    return 1 - math.pow(1 - t, 3)
end

local function easeInOutQuad(t)
    t = clamp01(t)
    if t < 0.5 then
        return 2 * t * t
    end
    return 1 - math.pow(-2 * t + 2, 2) / 2
end

local function getPalette(variant)
    if tostring(variant or "") == "collapse" then
        return {
            border = { r = 0.95, g = 0.18, b = 0.14 },
            accent = { r = 0.95, g = 0.18, b = 0.14 },
            title = { r = 1.0, g = 0.42, b = 0.36 },
            subtitle = { r = 0.95, g = 0.88, b = 0.82 },
        }
    end

    return {
        border = { r = 0.95, g = 0.78, b = 0.28 },
        accent = { r = 0.95, g = 0.78, b = 0.28 },
        title = { r = 1.0, g = 0.92, b = 0.52 },
        subtitle = { r = 0.92, g = 0.92, b = 0.92 },
    }
end

local function getScreenRect()
    local core = getCore()
    return core:getScreenWidth(), core:getScreenHeight()
end

local function clampRect(x, y, w, h)
    local screenW, screenH = getScreenRect()

    w = math.max(220, math.floor(tonumber(w) or Banner.DEFAULT_WIDTH))
    h = math.max(56, math.floor(tonumber(h) or Banner.DEFAULT_HEIGHT))
    x = math.floor(tonumber(x) or 0)
    y = math.floor(tonumber(y) or 0)

    if x < 0 then
        x = 0
    end
    if y < 0 then
        y = 0
    end
    if x > screenW - w then
        x = math.max(0, screenW - w)
    end
    if y > screenH - h then
        y = math.max(0, screenH - h)
    end

    return x, y, w, h
end

function Banner.GetDefaultRect()
    local screenW = getCore():getScreenWidth()
    local width = Banner.DEFAULT_WIDTH
    local height = Banner.DEFAULT_HEIGHT
    local x = math.floor((screenW - width) / 2)
    local y = Banner.DEFAULT_TOP_MARGIN
    return clampRect(x, y, width, height)
end

function Banner.GetSavedRect()
    local state = DT_ConfigManager
        and DT_ConfigManager.getFactionDiscoveryBannerState
        and DT_ConfigManager.getFactionDiscoveryBannerState()
        or nil

    if state then
        return clampRect(state.x, state.y, state.w, state.h)
    end

    return Banner.GetDefaultRect()
end

function Banner.SaveRect(x, y, w, h)
    if DT_ConfigManager and DT_ConfigManager.setFactionDiscoveryBannerState then
        local px, py, pw, ph = clampRect(x, y, w, h)
        DT_ConfigManager.setFactionDiscoveryBannerState(px, py, pw, ph)
    end
end

function Banner.ClearSavedRect()
    if DT_ConfigManager and DT_ConfigManager.clearFactionDiscoveryBannerState then
        DT_ConfigManager.clearFactionDiscoveryBannerState()
    end
end

function BannerPanel:setMessage(title, subtitle, duration, options)
    options = type(options) == "table" and options or {}
    local requestedHold = tonumber(duration) or Banner.DEFAULT_HOLD_DURATION
    self.titleText = tostring(title or "")
    self.subtitleText = tostring(subtitle or "")
    self.variant = tostring(options.variant or "default")
    self.phase = "entering"
    self.phaseTime = 0
    self.holdDuration = math.min(Banner.MAX_HOLD_DURATION, math.max(0.2, requestedHold))
    self:setVisible(true)
    self:addToUIManager()
    self:bringToTop()
end

function BannerPanel:setPreviewMessage(title, subtitle)
    self.titleText = tostring(title or "")
    self.subtitleText = tostring(subtitle or "")
    self.variant = "default"
    self.phase = "preview"
    self.phaseTime = 0
    self.holdDuration = -1
    self:setVisible(true)
end

function BannerPanel:moveToClamped(x, y)
    local px, py = clampRect(x, y, self:getWidth(), self:getHeight())
    self:setX(px)
    self:setY(py)
end

function BannerPanel:moveToDefault()
    local x, y = Banner.GetDefaultRect()
    self:setX(x)
    self:setY(y)
end

function BannerPanel:getVisualState()
    local phase = tostring(self.phase or "idle")
    local bgProgress = 0
    local contentProgress = 0
    local exitProgress = 0

    if self.editorMode or phase == "preview" then
        return {
            rootAlpha = 1.0,
            bgAlpha = 0.82,
            titleAlpha = 1.0,
            subtitleAlpha = 1.0,
            panelOffsetY = 0,
            titleOffsetY = 0,
            subtitleOffsetY = 0,
            bgScale = 1.0,
            accentAlpha = 0.95,
        }
    end

    if phase == "entering" then
        bgProgress = easeOutCubic(self.phaseTime / Banner.ENTER_DURATION)
        contentProgress = easeOutCubic((self.phaseTime - 0.04) / (Banner.ENTER_DURATION - 0.04))
        return {
            rootAlpha = bgProgress,
            bgAlpha = lerp(0.0, 0.82, bgProgress),
            titleAlpha = contentProgress,
            subtitleAlpha = easeOutCubic((self.phaseTime - 0.09) / math.max(0.08, Banner.ENTER_DURATION - 0.09)),
            panelOffsetY = lerp(-20, 0, bgProgress),
            titleOffsetY = lerp(10, 0, contentProgress),
            subtitleOffsetY = lerp(16, 0, easeOutCubic((self.phaseTime - 0.09) / math.max(0.08, Banner.ENTER_DURATION - 0.09))),
            bgScale = lerp(0.965, 1.0, bgProgress),
            accentAlpha = lerp(0.0, 0.95, bgProgress),
        }
    end

    if phase == "exiting" then
        exitProgress = easeInOutQuad(self.phaseTime / Banner.EXIT_DURATION)
        return {
            rootAlpha = 1.0 - exitProgress,
            bgAlpha = lerp(0.82, 0.0, exitProgress),
            titleAlpha = lerp(1.0, 0.0, clamp01(exitProgress * 1.15)),
            subtitleAlpha = lerp(1.0, 0.0, clamp01(exitProgress * 1.25)),
            panelOffsetY = lerp(0, -16, exitProgress),
            titleOffsetY = lerp(0, -8, exitProgress),
            subtitleOffsetY = lerp(0, -12, exitProgress),
            bgScale = lerp(1.0, 0.985, exitProgress),
            accentAlpha = lerp(0.95, 0.0, exitProgress),
        }
    end

    return {
        rootAlpha = 1.0,
        bgAlpha = 0.82,
        titleAlpha = 1.0,
        subtitleAlpha = 1.0,
        panelOffsetY = 0,
        titleOffsetY = 0,
        subtitleOffsetY = 0,
        bgScale = 1.0,
        accentAlpha = 0.95,
    }
end

function BannerPanel:prerender()
    local state = self:getVisualState()
    local palette = getPalette(self.variant)
    local scaledW = math.floor(self.width * state.bgScale + 0.5)
    local scaledH = math.floor(self.height * state.bgScale + 0.5)
    local drawX = math.floor((self.width - scaledW) / 2)
    local drawY = math.floor((self.height - scaledH) / 2 + state.panelOffsetY)

    if state.rootAlpha <= 0 then
        return
    end

    self:drawRect(drawX, drawY, scaledW, scaledH, state.bgAlpha, 0.05, 0.05, 0.05)
    self:drawRectBorder(drawX, drawY, scaledW, scaledH, 0.92 * state.rootAlpha, palette.border.r, palette.border.g, palette.border.b)
    self:drawRect(drawX + 12, drawY + 12, math.max(16, scaledW - 24), 2, state.accentAlpha, palette.accent.r, palette.accent.g, palette.accent.b)

    if self.editorMode then
        self:drawTextCentre("Drag to reposition", self.width / 2, drawY + scaledH - 20, 0.78, 0.78, 0.78, 0.95, UIFont.Small)
    end
end

function BannerPanel:render()
    local state = self:getVisualState()
    local palette = getPalette(self.variant)
    local titleY = 18 + state.panelOffsetY + state.titleOffsetY
    local subtitleY = 50 + state.panelOffsetY + state.subtitleOffsetY

    if state.rootAlpha <= 0 then
        return
    end

    self:drawTextCentre(
        tostring(self.titleText or ""),
        self.width / 2,
        titleY,
        palette.title.r,
        palette.title.g,
        palette.title.b,
        state.titleAlpha,
        UIFont.Large
    )
    self:drawTextCentre(
        tostring(self.subtitleText or ""),
        self.width / 2,
        subtitleY,
        palette.subtitle.r,
        palette.subtitle.g,
        palette.subtitle.b,
        state.subtitleAlpha,
        UIFont.Small
    )
end

function BannerPanel:update()
    ISPanel.update(self)

    if self.editorMode or not self:getIsVisible() then
        return
    end

    local uiDt = UIManager.getMillisSinceLastRender() / 1000.0
    self.phaseTime = (tonumber(self.phaseTime) or 0) + uiDt

    if self.phase == "entering" then
        if self.phaseTime >= Banner.ENTER_DURATION then
            self.phase = "holding"
            self.phaseTime = 0
        end
        return
    end

    if self.phase == "holding" then
        if self.phaseTime >= (tonumber(self.holdDuration) or Banner.DEFAULT_HOLD_DURATION) then
            self.phase = "exiting"
            self.phaseTime = 0
        end
        return
    end

    if self.phase == "exiting" then
        if self.phaseTime >= Banner.EXIT_DURATION then
            self.phase = "idle"
            self.phaseTime = 0
            self:setVisible(false)
            self:removeFromUIManager()
        end
    end
end

function BannerPanel:onMouseDown(x, y)
    if not self.draggable then
        return ISPanel.onMouseDown(self, x, y)
    end

    self.dragging = true
    return true
end

function BannerPanel:onMouseMove(dx, dy)
    if self.dragging then
        self:moveToClamped(self:getX() + dx, self:getY() + dy)
        return true
    end
    return ISPanel.onMouseMove(self, dx, dy)
end

function BannerPanel:onMouseMoveOutside(dx, dy)
    if self.dragging then
        self:moveToClamped(self:getX() + dx, self:getY() + dy)
        return true
    end
    return ISPanel.onMouseMoveOutside(self, dx, dy)
end

function BannerPanel:onMouseUp(x, y)
    if self.dragging then
        self.dragging = false
        return true
    end
    return ISPanel.onMouseUp(self, x, y)
end

function BannerPanel:onMouseUpOutside(x, y)
    self.dragging = false
    return ISPanel.onMouseUpOutside(self, x, y)
end

function BannerPanel:new(x, y, width, height, options)
    local o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self

    options = options or {}
    o.titleText = ""
    o.subtitleText = ""
    o.variant = "default"
    o.phase = options.editorMode == true and "preview" or "idle"
    o.phaseTime = 0
    o.holdDuration = Banner.DEFAULT_HOLD_DURATION
    o.borderColor = { r = 0, g = 0, b = 0, a = 0 }
    o.backgroundColor = { r = 0, g = 0, b = 0, a = 0 }
    o.editorMode = options.editorMode == true
    o.draggable = options.draggable == true
    o.dragging = false
    o.moveWithMouse = false
    return o
end

Banner.PanelClass = BannerPanel

function Banner.EnsureInstance()
    if Banner.instance and Banner.instance.javaObject then
        return Banner.instance
    end

    local x, y, w, h = Banner.GetSavedRect()
    local panel = BannerPanel:new(x, y, w, h, {})
    panel:initialise()
    panel:instantiate()
    panel:setVisible(false)
    panel:addToUIManager()
    panel:removeFromUIManager()
    Banner.instance = panel
    return panel
end

function Banner.ApplySavedPosition()
    local panel = Banner.EnsureInstance()
    if not panel then
        return
    end

    local x, y, w, h = Banner.GetSavedRect()
    panel:setWidth(w)
    panel:setHeight(h)
    panel:moveToClamped(x, y)
end

function Banner.ShowMessage(title, subtitle, duration, options)
    local panel = Banner.EnsureInstance()
    if not panel then
        return
    end

    Banner.ApplySavedPosition()
    panel:setMessage(title, subtitle, duration or Banner.DEFAULT_HOLD_DURATION, options)
end

return Banner
