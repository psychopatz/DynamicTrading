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
function DT_FirearmSystem.FireShot(character, tx, ty, tz)
    if not character or isServer() then return end
    
    local x, y, z = DT_FirearmUtils.GetMuzzlePosition(character)
    if not x then return end

    -- 1. Spawn Light Burst (From Common DT_LightSystem)
    DT_LightSystem.SpawnBurst(x, y, z, 1.0, 0.9, 0.35, 12, 3)

    -- 2. Spawn Tracer (From Common DT_TracerSystem)
    if not isServer() and tx and ty then
        DT_TracerSystem.AddTracer(x, y, z, tx, ty, tz or z)
    end
end

--- V2 Specialized Muzzle Flash
--- @param character IsoGameCharacter
function DT_FirearmSystem.MuzzleFlash(character)
    DT_FirearmSystem.FireShot(character)
end

return DT_FirearmSystem
