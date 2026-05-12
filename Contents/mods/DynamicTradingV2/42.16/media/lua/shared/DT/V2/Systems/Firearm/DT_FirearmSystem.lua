-- =============================================================================
-- DT_FirearmSystem.lua (V2 VERSION)
-- Synchronizes light bursts and tracers for V2 combat events.
-- =============================================================================

DT_FirearmSystem = DT_FirearmSystem or {}

require "DT/V2/Utils/DT_FirearmUtils"
require "Misc/DT_LightSystem"

if not isServer() then
    require "Utils/DT_TracerSystem"
end

--- Unified helper for shooting effects (Muzzle Flash + Tracer)
--- @param character IsoGameCharacter
--- @param tx, ty, tz number (Optional, target world coordinates)
function DT_FirearmSystem.FireShot(character, tx, ty, tz, options)
    if not character or isServer() then
        return false
    end

    options = type(options) == "table" and options or {}

    local x, y, z = DT_FirearmUtils.GetMuzzlePosition(character)
    if not x then
        return false
    end

    local weaponItem = options.weaponItem
    local direction = tonumber(options.direction) or DT_FirearmUtils.GetShotDirectionDegrees(character)
    local projectileCount = tonumber(options.projectiles) or DT_FirearmUtils.GetProjectileCount(weaponItem)

    DT_LightSystem.MuzzleFlash(character, {
        x = x,
        y = y,
        z = z,
        squareZ = character:getZ(),
        r = tonumber(options.flashR) or 1.0,
        g = tonumber(options.flashG) or 0.46,
        b = tonumber(options.flashB) or 0.14,
        radius = tonumber(options.flashRadius) or 18,
        durationTicks = tonumber(options.flashDurationTicks) or 1,
    })

    if tx and ty and DT_TracerSystem and DT_TracerSystem.AddTracer then
        DT_TracerSystem.AddTracer({
            shooter = character,
            sx = x,
            sy = y,
            sz = z,
            tx = tx,
            ty = ty,
            tz = tz or z,
            direction = direction,
            projectiles = projectileCount,
            color = options.tracerColor,
            ttl = tonumber(options.tracerTicks) or 12,
            length = tonumber(options.tracerLength) or 600,
            altitude = tonumber(options.tracerAltitude) or 85,
        })
    end

    return true
end

--- V2 Specialized Muzzle Flash
--- @param character IsoGameCharacter
function DT_FirearmSystem.MuzzleFlash(character, options)
    if isServer() or not character then
        return false
    end

    options = type(options) == "table" and options or {}

    local x, y, z = DT_FirearmUtils.GetMuzzlePosition(character)
    if not x then
        return false
    end

    return DT_LightSystem.MuzzleFlash(character, {
        x = x,
        y = y,
        z = z,
        squareZ = character:getZ(),
        r = tonumber(options.flashR) or 1.0,
        g = tonumber(options.flashG) or 0.46,
        b = tonumber(options.flashB) or 0.14,
        radius = tonumber(options.flashRadius) or 18,
        durationTicks = tonumber(options.flashDurationTicks) or 1,
    })
end

return DT_FirearmSystem
