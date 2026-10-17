-- Client-only DTAbstract preview adapter.
--
-- Artwork, dimensions, controls and hitboxes belong to PsychopatzCore's
-- generated DeviceManifest. DTAbstract keeps only this optional preview
-- surface; it does not carry a second radio atlas or device catalog.

require "ISUI/ISPanel"
require "ISUI/ISButton"

local Manifest = require
    "PsychopatzCore/UI/Radio/OS/PsychopatzRadioRuntimeManifest"

DTAbstract = DTAbstract or {}
DTAbstract.RadioOS = DTAbstract.RadioOS or {}
local RadioOS = DTAbstract.RadioOS
local cache = {}

local function number(value, fallback)
    value = tonumber(value)
    return value ~= nil and value or fallback
end

local function scaledRect(source, scale)
    source = source or {}
    scale = number(scale, 1)
    return {
        x = math.floor(number(source.x, 0) * scale + 0.5),
        y = math.floor(number(source.y, 0) * scale + 0.5),
        w = math.max(1, math.floor(number(source.w, 1) * scale + 0.5)),
        h = math.max(1, math.floor(number(source.h, 1) * scale + 0.5)),
    }
end

local function textureFor(path)
    if cache[path] ~= nil then return cache[path] or nil end
    local result = getTexture and getTexture(path) or nil
    cache[path] = result or false
    return result
end

local function drawAsset(self, entry, alpha)
    if type(entry) ~= "table" or type(entry.image) ~= "string" then
        return false
    end
    local texture = textureFor(entry.image)
    if not texture then return false end
    local scale = number(self.scale, 1)
    local canvas = self.skin.canvas or {}
    local sourceWidth = number(canvas.width, 1)
    local sourceHeight = number(canvas.height, 1)
    local textureWidth = texture.getWidth and texture:getWidth() or sourceWidth
    local textureHeight = texture.getHeight and texture:getHeight() or sourceHeight
    local x = math.floor(number(entry.x, 0) * scale + 0.5)
    local y = math.floor(number(entry.y, 0) * scale + 0.5)
    local width = math.max(1, math.floor(textureWidth * scale + 0.5))
    local height = math.max(1, math.floor(textureHeight * scale + 0.5))
    if textureWidth == sourceWidth and textureHeight == sourceHeight
        and x == 0 and y == 0
    then
        width = self.getWidth and self:getWidth() or self.width
        height = self.getHeight and self:getHeight() or self.height
    end
    alpha = number(alpha, 1)
    if self.drawTextureScaled then
        self:drawTextureScaled(texture, x, y, width, height,
            alpha, 1, 1, 1)
    elseif self.drawSubTexture then
        self:drawSubTexture(texture, 0, 0, textureWidth, textureHeight,
            x, y, width, height, alpha, 1, 1, 1)
    else
        return false
    end
    return true
end

local function drawIcon(self, id, x, y, size)
    local path, region = Manifest.GetIcon(id)
    if not path or not region then return false end
    local texture = textureFor(path)
    if not texture or not self.drawSubTexture then return false end
    size = math.max(1, math.floor(number(size, 1) + 0.5))
    self:drawSubTexture(texture, region.x, region.y, region.w, region.h,
        math.floor(x + 0.5), math.floor(y + 0.5), size, size,
        1, 1, 1, 1)
    return true
end

local Preview = ISPanel:derive("DTA_RadioOSPreview")
RadioOS.Preview = Preview

local function makeHotspot(self, name, bounds, callback)
    local rect = scaledRect(bounds, self.scale)
    local button = ISButton:new(rect.x, rect.y, rect.w, rect.h, "",
        self, callback)
    button:initialise()
    button:instantiate()
    button:setDisplayBackground(false)
    button.borderColor = { r = 0, g = 0, b = 0, a = 0 }
    button.backgroundColor = { r = 0, g = 0, b = 0, a = 0 }
    button.backgroundColorMouseOver = { r = 0, g = 0, b = 0, a = 0 }
    button.tooltip = "Radio " .. tostring(name) .. " control"
    self:addChild(button)
    return button
end

function Preview:new(x, y, scale, skin)
    local width = math.floor(number(skin.canvas.width, 1) * scale)
    local height = math.floor(number(skin.canvas.height, 1) * scale)
    local instance = ISPanel:new(x, y, width, height)
    setmetatable(instance, self)
    self.__index = self
    instance.scale = scale
    instance.skin = skin
    instance.page = "home"
    instance.cursor = 1
    instance.powered = false
    instance.background = false
    instance.border = false
    instance.moveWithMouse = true
    return instance
end

function Preview:screenRect()
    local lcd = self.skin.lcd or {}
    return scaledRect(lcd.content or lcd.backing or lcd.aperture, self.scale)
end

function Preview:createChildren()
    ISPanel.createChildren(self)
    local callbacks = {
        left = function() self:onLeft() end,
        right = function() self:onRight() end,
        up = function() self:onUp() end,
        down = function() self:onDown() end,
        ok = function() self:onSelect() end,
        back = function() self:onBack() end,
        home = function() self:onHome() end,
        power = function() self:onPower() end,
    }
    self.controlHotspots = {}
    for _, component in ipairs(self.skin.interactiveComponents or {}) do
        local callback = callbacks[component.id]
        if callback then
            self.controlHotspots[component.id] = makeHotspot(
                self, component.id, component.hitbox, callback)
        end
    end

    local screen = self:screenRect()
    self.screenHotspots = {}
    for index = 1, 2 do
        local y = screen.y + math.floor(screen.h * (0.22 + (index - 1) * 0.23))
        local button = ISButton:new(screen.x + 3, y,
            math.max(1, screen.w - 6), math.max(18, math.floor(screen.h * 0.16)),
            "", self, function()
                if self.page == "home" then
                    self.cursor = index
                    self:onSelect()
                end
            end)
        button:initialise()
        button:instantiate()
        button:setDisplayBackground(false)
        self:addChild(button)
        self.screenHotspots[index] = button
    end
end

function Preview:onPower()
    self.powered = not self.powered
end

function Preview:onLeft()
    if self.page == "home" then
        self.cursor = self.cursor == 1 and 2 or 1
    else
        self.page = "home"
    end
end

function Preview:onRight()
    if self.page == "home" then
        self.cursor = self.cursor == 2 and 1 or 2
    end
end

function Preview:onUp()
    self:onLeft()
end

function Preview:onDown()
    self:onRight()
end

function Preview:onHome()
    self.page = "home"
end

function Preview:onSelect()
    if self.page ~= "home" then return end
    self.page = self.cursor == 1 and "contacts" or "scanner"
end

function Preview:onBack()
    if self.page == "home" then
        self:close()
    else
        self.page = "home"
    end
end

function Preview:close()
    self:setVisible(false)
    self:removeFromUIManager()
    if RadioOS._preview == self then RadioOS._preview = nil end
end

local function text(self, value, x, y, color)
    color = color or { 0.71, 0.85, 0.68 }
    self:drawText(value, math.floor(x), math.floor(y),
        color[1], color[2], color[3], 1, UIFont.Small)
end

function Preview:prerender()
    local screen = self:screenRect()
    local contentColor = self.powered
        and { 0.06, 0.12, 0.08 } or { 0.02, 0.04, 0.025 }
    self:drawRect(screen.x, screen.y, screen.w, screen.h, 1,
        contentColor[1], contentColor[2], contentColor[3])
    drawAsset(self, self.skin.chassis.pristine, 1)
    drawAsset(self, self.skin.lcd_layers.matte, 1)
    -- The authored glass is opaque over most of the LCD.  Composite it
    -- before preview text, matching the Core renderer's LCD sandwich.
    drawAsset(self, self.skin.lcd_layers.glass, 1)
    drawAsset(self, self.skin.lcd_layers.bezel_overlay, 1)
    for _, component in ipairs(self.skin.components or {}) do
        if component.visible ~= false then
            local stateName = "idle"
            if component.kind == "led" then
                stateName = self.powered and "on" or "off"
            end
            local state = (component.states or {})[stateName]
            if not state then
                for _, candidate in pairs(component.states or {}) do
                    state = candidate
                    break
                end
            end
            drawAsset(self, state, 1)
        end
    end
    local x, y = screen.x + 5, screen.y + 5
    text(self, self.powered
        and (self.page == "home" and "RADIO OS"
            or self.page == "contacts" and "CONTACTS" or "SCANNER")
        or "POWER OFF", x, y)
    if self.powered and self.page == "home" then
        local options = { "CONTACTS", "SCANNER" }
        local icons = { "icon_contacts", "icon_scan" }
        for index, name in ipairs(options) do
            local rowY = y + 20 + (index - 1) * 23
            local selected = index == self.cursor
            self:drawRect(x - 2, rowY - 1, screen.w - 10, 20,
                selected and 0.35 or 0.12,
                selected and 0.37 or 0.14,
                selected and 0.53 or 0.20,
                selected and 0.34 or 0.15)
            local iconSize = math.min(16, math.max(8, screen.h * 0.08))
            drawIcon(self, icons[index], x, rowY + 1, iconSize)
            text(self, (selected and ">" or " ") .. name,
                x + iconSize + 3, rowY,
                selected and { 0.86, 0.98, 0.72 } or nil)
        end
    elseif not self.powered then
        text(self, "Press Power", x, y + 22)
    else
        text(self, "NOT CONNECTED", x, y + 22)
    end
end

function RadioOS.OpenPreview(playerNum, fullType)
    if type(playerNum) ~= "number" then playerNum = 0 end
    local skin = Manifest.GetDevice(fullType or "Base.WalkieTalkie5")
    if not skin then return nil, "unsupported walkie item" end
    if RadioOS._preview then RadioOS._preview:close() end
    local core = getCore and getCore() or nil
    local screenW = core and core.getScreenWidth and core:getScreenWidth() or 1280
    local screenH = core and core.getScreenHeight and core:getScreenHeight() or 900
    local canvasWidth = number(skin.canvas.width, 1)
    local canvasHeight = number(skin.canvas.height, 1)
    local scale = math.min(1.0, math.max(0.2,
        math.min((screenW - 100) / canvasWidth,
            (screenH - 100) / canvasHeight)))
    local width = math.floor(canvasWidth * scale)
    local height = math.floor(canvasHeight * scale)
    local x = math.max(4, math.floor((screenW - width) * 0.5))
    local y = math.max(4, math.floor((screenH - height) * 0.5))
    local instance = Preview:new(x, y, scale, skin)
    instance:initialise()
    instance:instantiate()
    instance:addToUIManager()
    RadioOS._preview = instance
    return instance
end

return RadioOS
