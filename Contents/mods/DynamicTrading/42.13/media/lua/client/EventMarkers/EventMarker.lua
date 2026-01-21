require "ISUI/ISUIElement"

EventMarker = ISUIElement:derive("EventMarker")

EventMarker.iconSize = 96
EventMarker.clickableSize = 45
EventMarker.maxRange = 500

function EventMarker:initialise()
    ISUIElement.initialise(self)
    self:addToUIManager()
    self.moveWithMouse = true
    self:setVisible(false)
end

function EventMarker:onMouseDoubleClick(x, y)
    return self:setDuration(0)
end

function EventMarker:onMouseUp(x, y)
    if not self.moveWithMouse then return end
    if not self:getIsVisible() then return end

    self.moving = false
    if ISMouseDrag.tabPanel then
        ISMouseDrag.tabPanel:onMouseUp(x, y)
    end
    ISMouseDrag.dragView = nil
end

function EventMarker:onMouseUpOutside(x, y)
    if not self.moveWithMouse then return end
    if not self:getIsVisible() then return end

    self.moving = false
    ISMouseDrag.dragView = nil
end

function EventMarker:onMouseDown(x, y)
    if not self.moveWithMouse then return true end
    if not self:getIsVisible() then return end
    if not self:isMouseOver() then return end

    self.downX = x
    self.downY = y
    self.moving = true
    self:bringToTop()
end

function EventMarker:onMouseMoveOutside(dx, dy)
    if not self.moveWithMouse then return end
    self.mouseOver = false

    if self.moving then
        if self.parent then
            self.parent:setX(self.parent.x + dx)
            self.parent:setY(self.parent.y + dy)
        else
            self:setX(self.x + dx)
            self:setY(self.y + dy)
            self:bringToTop()
        end

        local p = self:getPlayer()
        if p then
            p:getModData()["EventMarkerPlacement"] = {self.x, self.y}
        end
    end
end

function EventMarker:onMouseMove(dx, dy)
    if not self.moveWithMouse then return end
    self.mouseOver = true
    
    if self.moving then
        if self.parent then
            self.parent:setX(self.parent.x + dx)
            self.parent:setY(self.parent.y + dy)
        else
            self:setX(self.x + dx)
            self:setY(self.y + dy)
            self:bringToTop()
        end
        
        local p = self:getPlayer()
        if p then
            p:getModData()["EventMarkerPlacement"] = {self.x, self.y}
        end
    end
end

function EventMarker:setDistance(dist)
    self.distanceToPoint = dist
end

function EventMarker:setAngleFromPoint(posX, posY)
    if posX and posY then
        local radians = math.atan2(posY - self.player:getY(), posX - self.player:getX()) + math.pi
        local degrees = ((radians * 180 / math.pi + 270) + 45) % 360
        self.angle = degrees
        self.posX = posX
        self.posY = posY
    end
end

function EventMarker:setAngle(value)
    self.angle = value
end

function EventMarker:setDuration(value)
    self.duration = value
    if value <= 0 then
        self:setVisible(false)
    end
end

function EventMarker:getDuration()
    return self.duration
end

function EventMarker:formatDistance(tiles)
    -- Convert tiles to meters (1 tile ≈ 3 meters in Project Zomboid)
    local meters = tiles * 3
    
    if meters < 1000 then
        return string.format("%.0fm", meters)
    elseif meters < 10000 then
        return string.format("%.1fkm", meters / 1000)
    else
        return string.format("%.0fkm", meters / 1000)
    end
end

local function colorBlend(color, underLayer, fade)
    local fadedColor = {r=color.r*fade, g=color.g*fade, b=color.b*fade, a=fade}
    local _color = {r=1, g=1, b=1, a=1}
    local alphaShift = 1 - (1 - fadedColor.a) * (1 - underLayer.a)

    _color.r = fadedColor.r * fadedColor.r / alphaShift + underLayer.r * underLayer.a * (1 - fadedColor.a) / alphaShift
    _color.g = fadedColor.g * fadedColor.g / alphaShift + underLayer.g * underLayer.a * (1 - fadedColor.a) / alphaShift
    _color.b = fadedColor.b * fadedColor.b / alphaShift + underLayer.b * underLayer.a * (1 - fadedColor.a) / alphaShift

    return _color
end

function EventMarker:render()
    if self.visible and self.duration > 0 then
        self:setAngleFromPoint(self.posX, self.posY)

        local centerX = self.width / 2
        local centerY = self.height / 2

        local aFromDist = 0.2 + (0.8 * (1 - (self.distanceToPoint / self.radius)))
        local mColor = {r=self.markerColor.r, g=self.markerColor.g, b=self.markerColor.b, a=1}
        local base = {r=0.22, g=0.22, b=0.22, a=1}

        local _color = colorBlend(mColor, base, aFromDist)

        self:drawTexture(self.textureBG, centerX - (EventMarker.iconSize / 2), centerY - (EventMarker.iconSize / 2), 1, _color.r, _color.g, _color.b)
        
        -- Display description
        if self.desc then
            self:drawTextCentre(self.desc, centerX, centerY + 25, 1, 1, 1, 1, UIFont.Small)
        end
        
        -- Display distance
        local distanceText = self:formatDistance(self.distanceToPoint)
        local yOffset = self.desc and centerY + 38 or centerY + 25
        self:drawTextCentre(distanceText, centerX, yOffset, 0.8, 0.8, 0.8, 1, UIFont.Small)

        local textureForPoint = self.texturePoint
        local distanceOverRadius = self.distanceToPoint / self.radius

        if distanceOverRadius <= (8 / EventMarker.maxRange) then
            textureForPoint = self.texturePointClose
        elseif distanceOverRadius <= (125 / EventMarker.maxRange) then
            -- no change
        elseif distanceOverRadius <= (375 / EventMarker.maxRange) then
            textureForPoint = self.texturePointMedium
        else
            textureForPoint = self.texturePointFar
        end

        self:DrawTextureAngle(textureForPoint, centerX, centerY, self.angle)
        self:drawTexture(self.textureIcon, centerX - (EventMarker.iconSize / 2), centerY - (EventMarker.iconSize / 2), 1, 1, 1, 1)

        ISUIElement.render(self)
    end
end

function EventMarker:setEnabled(value)
    self.enabled = value
end

function EventMarker:getEnabled()
    return self.enabled
end

function EventMarker:prerender()
end

function EventMarker:refresh()
    self.opacity = 0
    self.opacityGain = 2
end

function EventMarker:getPlayer()
    return self.player
end

function EventMarker:new(markerID, icon, duration, posX, posY, player, screenX, screenY, color, desc)
    local o = {}
    o = ISUIElement:new(screenX, screenY, 1, 1)
    setmetatable(o, self)
    self.__index = self
    
    o.markerID = markerID
    o.player = player
    o.x = screenX
    o.y = screenY
    o.markerColor = color or {r=1, g=0.5, b=0.5}
    o.posX = posX or 0
    o.posY = posY or 0
    o.width = EventMarker.clickableSize
    o.height = EventMarker.clickableSize
    o.angle = 0
    o.opacity = 255
    o.opacityGain = 2
    o.start = getGametimeTimestamp()
    o.duration = duration
    o.lastUpdateTime = -1
    o.enabled = true
    o.visible = true
    o.title = ""
    o.distanceToPoint = EventMarker.maxRange
    o.radius = nil
    o.mouseOver = false
    o.tooltip = nil
    o.center = false
    o.bConsumeMouseEvents = false
    o.joypadFocused = false
    o.translation = nil
    
    -- Load textures
    o.texturePoint = getTexture("media/ui/EventMarkers/eventMarker.png")
    o.texturePointClose = getTexture("media/ui/EventMarkers/eventMarker_close.png")
    o.texturePointMedium = getTexture("media/ui/EventMarkers/eventMarker_medium.png")
    o.texturePointFar = getTexture("media/ui/EventMarkers/eventMarker_far.png")
    o.textureBG = getTexture("media/ui/EventMarkers/eventMarkerBase.png")
    
    if icon then
        o.textureIcon = getTexture("media/ui/EventMarkers/" .. icon)
    end

    if desc then
        o.desc = desc
    end

    o:initialise()
    return o
end

function EventMarker:update(posX, posY)
    if not self.enabled then return end

    local timeStamp = getTimeInMillis()
    if self.lastUpdateTime + 5 >= timeStamp then
        return
    else
        self.lastUpdateTime = timeStamp
    end

    local dist
    posX = posX or self.posX
    posY = posY or self.posY

    if posX and posY and self.player then
        dist = IsoUtils.DistanceTo(posX, posY, self.player:getX(), self.player:getY())
    end

    if not self.radius then
        self.radius = EventMarker.maxRange
    end

    if self.duration > 0 then
        self.posX = posX
        self.posY = posY
        if dist and (dist <= self.radius) then
            self:setDistance(dist)
            self:setAngleFromPoint(self.posX, self.posY)
            self:setVisible(true)
        else
            self:setVisible(false)
        end
    else
        self:setVisible(false)
    end
end