-- Client-only development preview for the DTAbstract Radio OS texture pipeline.
-- This DOES NOT make a call, discover traders, authenticate devices or trade.
-- Enable via DTAbstract.EnableRadioOSPreview=true before loading the mod,
-- or explicitly call DTAbstract.RadioOS.OpenPreview(playerNum, fullType).
require "ISUI/ISPanel"
require "ISUI/ISButton"
-- PsychopatzCore owns the authoritative device-skin geometry. Keep the
-- DTAbstract manifest only as an offline/legacy fallback for preview tests.
local manifestLoaded, Assets = pcall(require,
    "PsychopatzCore/UI/Radio/OS/PsychopatzRadioManifest")
if not manifestLoaded or type(Assets) ~= "table" then
    Assets = require "DTAbstract/UI/DTA_Walkie_Manifest"
end

DTAbstract = DTAbstract or {}
DTAbstract.RadioOS = DTAbstract.RadioOS or {}
local RadioOS = DTAbstract.RadioOS
local cache = {}

local function textureFor(key)
    if cache[key] ~= nil then return cache[key] or nil end
    local data = Assets.sheets[key]
    local result = data and getTexture and getTexture(data.path) or nil
    cache[key] = result or false
    return result
end

local function drawSprite(self, id, x, y, w, h)
    local def = Assets.sprites[id]
    if not def then return false end
    local tex = textureFor(def.sheet)
    if not tex then return false end
    local r = def.rect
    self:drawSubTexture(tex, r.x, r.y, r.w, r.h, x, y, w, h, 1, 1, 1, 1)
    return true
end

local Preview = ISPanel:derive("DTA_RadioOSPreview")
RadioOS.Preview = Preview

-- Hardware softkeys are laid out per skin in the atlas manifest.
local function makeHotspot(self, name, bounds, fn)
    local s = self.scale
    local b = ISButton:new(math.floor(bounds.x*s), math.floor(bounds.y*s),
        math.floor(bounds.w*s), math.floor(bounds.h*s), "", self, fn)
    b:initialise()
    b:instantiate()
    b:setDisplayBackground(false)
    b.borderColor = {r=0,g=0,b=0,a=0}
    b.backgroundColor = {r=0,g=0,b=0,a=0}
    b.backgroundColorMouseOver = {r=0,g=0,b=0,a=0}
    b.tooltip = "Radio " .. name .. " softkey"
    self:addChild(b)
    return b
end

function Preview:new(x, y, scale, skin)
    local w = math.floor(256*scale)
    local h = math.floor(432*scale)
    local instance = ISPanel:new(x, y, w, h)
    setmetatable(instance, self)
    self.__index = self
    instance.scale = scale
    instance.skin = skin
    instance.page = "home"
    instance.cursor = 1
    instance.background = false
    instance.border = false
    instance.moveWithMouse = true
    return instance
end

function Preview:createChildren()
    ISPanel.createChildren(self)
    local controls = self.skin.controls
    self.leftHotspot = makeHotspot(self, "left", controls.left, self.onLeft)
    self.centerHotspot = makeHotspot(self, "select", controls.center, self.onSelect)
    self.rightHotspot = makeHotspot(self, "back", controls.right, self.onBack)
    -- Two transparent LCD hotspots make the home screen mouse-clickable,
    -- without baking app names or graphics into the shell texture.
    local r = self.skin.screen
    self.screenHotspots = {}
    for index = 1, 2 do
        local x = math.floor(r.x*self.scale) + 3
        local y = math.floor(r.y*self.scale) + 24 + (index-1)*23
        local w = math.floor(r.w*self.scale) - 6
        local btn = ISButton:new(x, y, w, 22, "", self, function()
            if self.page == "home" then
                self.cursor = index
                self:onSelect()
            end
        end)
        btn:initialise()
        btn:instantiate()
        btn:setDisplayBackground(false)
        self:addChild(btn)
        self.screenHotspots[index] = btn
    end
end

function Preview:onLeft()
    if self.page == "home" then
        self.cursor = self.cursor == 1 and 2 or 1
    else
        self.page = "home"
    end
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

local function text(self, str, x, y, c)
    c = c or {0.71,0.85,0.68}
    self:drawText(str, math.floor(x), math.floor(y),
        c[1], c[2], c[3], 1, UIFont.Small)
end

function Preview:prerender()
    -- Do not call ISPanel.prerender: it can paint an opaque window backing.
    local s = self.scale
    local r = self.skin.screen
    local sx,sy,sw,sh = r.x*s,r.y*s,r.w*s,r.h*s
    local theme = (Assets.themes[self.skin.theme] or Assets.themes.green).lcd
    if not drawSprite(self, theme, sx,sy,sw,sh) then
        self:drawRect(sx,sy,sw,sh,1,0.06,0.12,0.08)
    end
    local pad = 5
    local x, y = sx+pad,sy+pad
    text(self, self.page == "home" and "RADIO OS"
        or self.page == "contacts" and "CONTACTS" or "SCANNER", x,y)
    local top = y+20
    if self.page == "home" then
        local options = {"CONTACTS", "SCANNER"}
        for index, name in ipairs(options) do
            local ry = top+(index-1)*23
            local selected = index == self.cursor
            self:drawRect(x-2,ry-1,sw-pad*2,20,selected and 0.35 or 0.12,
                selected and 0.37 or 0.14,selected and 0.53 or 0.2,
                selected and 0.34 or 0.15)
            text(self, (selected and ">" or " ") .. name,x,ry,
                selected and {0.86,0.98,0.72} or nil)
        end
    else
        text(self, "NOT CONNECTED",x,top)
    end
    -- The shell is *above* the screen, using the alpha-zero window cutout.
    drawSprite(self, self.skin.sprite, 0,0,256*s,432*s)
    -- Highlight the current physical select control when pointer-over.
    local hot = self.centerHotspot
    if hot and hot.mouseOver then
        local b = self.skin.controls.center
        self:drawRectBorder(math.floor(b.x*s),math.floor(b.y*s),
            math.floor(b.w*s),math.floor(b.h*s),0.9,0.62,0.77,0.52)
    end
end

function RadioOS.OpenPreview(playerNum, fullType)
    if type(playerNum) ~= "number" then playerNum = 0 end
    local skin = Assets.GetSkin(fullType or "Base.WalkieTalkie5")
    if not skin then return nil, "unsupported walkie item" end
    if RadioOS._preview then RadioOS._preview:close() end
    local core = getCore and getCore() or nil
    local screenW = core and core.getScreenWidth and core:getScreenWidth() or 1280
    local screenH = core and core.getScreenHeight and core:getScreenHeight() or 900
    local scale = math.min(1.7, math.max(0.75, (screenH - 100) / 432))
    local w,h = math.floor(256*scale), math.floor(432*scale)
    local x = math.max(4, math.floor((screenW-w)*0.5))
    local y = math.max(4, math.floor((screenH-h)*0.5))
    local instance = Preview:new(x,y,scale,skin)
    instance:initialise()
    instance:instantiate()
    instance:addToUIManager()
    RadioOS._preview = instance
    return instance
end

return RadioOS
