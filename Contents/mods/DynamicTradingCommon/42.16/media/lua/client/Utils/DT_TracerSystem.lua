-- =============================================================================
-- DT_TracerSystem.lua
-- Manages and renders screen-space bullet tracers (flying bullets).
-- =============================================================================

DT_TracerSystem = DT_TracerSystem or {}
DT_TracerSystem.ActiveTracers = DT_TracerSystem.ActiveTracers or {}
DT_TracerSystem.Texture = DT_TracerSystem.Texture or getTexture("media/textures/mask_white.png")

local DEFAULT_TTL = 12
local DEFAULT_LENGTH = 600
local DEFAULT_ALTITUDE = 85
local DEFAULT_COLOR = { r = 1.0, g = 0.72, b = 0.14 }
local SHOTGUN_SPREAD = { -1.7, -1.3, 0.0, 1.4, 1.7 }

local function normalizeColor(color)
    if type(color) ~= "table" then
        return {
            r = DEFAULT_COLOR.r,
            g = DEFAULT_COLOR.g,
            b = DEFAULT_COLOR.b,
        }
    end

    return {
        r = tonumber(color.r) or DEFAULT_COLOR.r,
        g = tonumber(color.g) or DEFAULT_COLOR.g,
        b = tonumber(color.b) or DEFAULT_COLOR.b,
    }
end

local function getOwnerKey(shooter, sx, sy)
    if shooter then
        if shooter.getOnlineID then
            local onlineID = tonumber(shooter:getOnlineID())
            if onlineID and onlineID >= 0 then
                return "online:" .. tostring(onlineID)
            end
        end
        if shooter.getX and shooter.getY then
            return "world:" .. tostring(math.floor(shooter:getX() * 10)) .. ":" .. tostring(math.floor(shooter:getY() * 10))
        end
    end
    return "world:" .. tostring(math.floor((tonumber(sx) or 0) * 10)) .. ":" .. tostring(math.floor((tonumber(sy) or 0) * 10))
end

local function addProjectile(projectileList, ownerKey, screenX, screenY, direction, options)
    table.insert(projectileList, {
        ownerKey = ownerKey,
        x = screenX,
        y = screenY,
        dir = direction + ZombRandFloat(-0.15, 0.15),
        tick = 1,
        ttl = tonumber(options.ttl) or DEFAULT_TTL,
        length = tonumber(options.length) or DEFAULT_LENGTH,
        altitude = tonumber(options.altitude) or DEFAULT_ALTITUDE,
        altitudeVariation = tonumber(options.altitudeVariation) or ZombRandFloat(-10, 10),
        color = normalizeColor(options.color),
    })
end

local function getDirectionFromTarget(sx, sy, tx, ty)
    local dx = (tonumber(tx) or 0) - (tonumber(sx) or 0)
    local dy = (tonumber(ty) or 0) - (tonumber(sy) or 0)
    if math.abs(dx) < 0.0001 and math.abs(dy) < 0.0001 then
        return 0
    end

    if math.abs(dx) < 0.0001 then
        if dy >= 0 then
            return 90
        end
        return -90
    end

    local angle = math.deg(math.atan(dy / dx))
    if dx < 0 then
        angle = angle + 180
    elseif dy < 0 then
        angle = angle + 360
    end
    return angle
end

function DT_TracerSystem.Stop(ownerKey)
    if not ownerKey then
        return
    end

    local projectileList = DT_TracerSystem.ActiveTracers
    for i = #projectileList, 1, -1 do
        if projectileList[i].ownerKey == ownerKey then
            table.remove(projectileList, i)
        end
    end
end

--- Spawns a new bullet tracer.
--- Accepts either the legacy positional signature or an options table.
function DT_TracerSystem.AddTracer(arg1, sy, sz, tx, ty, tz, color)
    if isServer() then
        return false
    end

    local options = nil
    if type(arg1) == "table" then
        options = arg1
    else
        options = {
            sx = arg1,
            sy = sy,
            sz = sz,
            tx = tx,
            ty = ty,
            tz = tz,
            color = color,
        }
    end

    local sxValue = tonumber(options.sx)
    local syValue = tonumber(options.sy)
    local szValue = tonumber(options.sz) or 0
    if not sxValue or not syValue then
        return false
    end

    local screenX, screenY = ISCoordConversion.ToScreen(sxValue, syValue, szValue)
    if not screenX or not screenY then
        return false
    end

    local projectileCount = tonumber(options.projectiles) or 1
    local direction = tonumber(options.direction)
    if not direction then
        direction = getDirectionFromTarget(sxValue, syValue, options.tx, options.ty)
    end
    local projectileList = DT_TracerSystem.ActiveTracers
    local ownerKey = tostring(options.ownerKey or getOwnerKey(options.shooter, sxValue, syValue))

    if projectileCount <= 1 then
        addProjectile(projectileList, ownerKey, screenX, screenY, direction, options)
        return true
    end

    local spreadCount = math.min(#SHOTGUN_SPREAD, math.max(1, math.floor(projectileCount)))
    for i = 1, spreadCount do
        addProjectile(projectileList, ownerKey, screenX, screenY, direction + SHOTGUN_SPREAD[i], options)
    end
    return true
end

--- Render hook for OnPreUIDraw
function DT_TracerSystem.OnPreUIDraw()
    if not isIngameState() or isServer() then
        return
    end

    local tracers = DT_TracerSystem.ActiveTracers
    if #tracers == 0 then
        return
    end

    local renderer = getRenderer()
    if not renderer then
        return
    end

    local texture = DT_TracerSystem.Texture
    local zoom = getCore():getZoom(0)
    for i = #tracers, 1, -1 do
        local tracer = tracers[i]
        local theta = tracer.dir * math.pi / 180
        local stepLength = tracer.length / zoom
        local dx = math.cos(theta) - math.sin(theta)
        local dy = (math.cos(theta) + math.sin(theta)) * 0.5
        local altitude = tracer.altitude / zoom
        local x1 = tracer.x / zoom
        local y1 = tracer.y / zoom
        local x2 = x1 + math.floor(stepLength * dx)
        local y2 = y1 + math.floor(stepLength * dy)
        local alpha = 1.0 - ((tracer.tick - 1) / tracer.ttl)

        renderer:renderline(
            texture,
            x1,
            y1 - altitude,
            x2,
            y2 - (altitude + (tracer.altitudeVariation / zoom)),
            tracer.color.r,
            tracer.color.g,
            tracer.color.b,
            alpha
        )

        tracer.x = tracer.x + math.floor(stepLength * dx)
        tracer.y = tracer.y + math.floor(stepLength * dy)
        tracer.tick = tracer.tick + 1

        if tracer.tick > tracer.ttl then
            table.remove(tracers, i)
        end
    end
end

-- Initialize the system
if not DT_TracerSystem.Initialized and not isServer() then
    Events.OnPreUIDraw.Add(DT_TracerSystem.OnPreUIDraw)
    DT_TracerSystem.Initialized = true
    print("DT_TracerSystem: Bullet Renderer Initialized")
end

return DT_TracerSystem
