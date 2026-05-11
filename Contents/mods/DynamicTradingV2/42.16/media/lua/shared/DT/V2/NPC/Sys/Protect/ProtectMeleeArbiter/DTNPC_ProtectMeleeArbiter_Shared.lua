-- ==============================================================================
-- DTNPC_ProtectMeleeArbiter_Shared.lua
-- Shared constants and target helpers for DTNPC melee arbiter.
-- ==============================================================================

DTNPCProtect = DTNPCProtect or {}
DTNPCProtect.Internal = DTNPCProtect.Internal or {}

local Internal = DTNPCProtect.Internal
local getZombieRuntimeID = Internal.getZombieRuntimeID
local getPlayerRuntimeID = Internal.getPlayerRuntimeID

Internal.MeleeArbiterDefaultSpeed = 0.05
Internal.MeleeArbiterEnterBuffer = 0.25
Internal.MeleeArbiterHoldBuffer = 0.45
Internal.MeleeArbiterStopBuffer = 0.16
Internal.MeleeArbiterRetreatLockMs = 450
Internal.MeleeArbiterPassageLockMs = 350

local function getTargetKey(target)
    if not target then
        return nil
    end
    if instanceof and instanceof(target, "IsoPlayer") then
        return getPlayerRuntimeID and getPlayerRuntimeID(target) or tostring(target)
    end
    return getZombieRuntimeID and getZombieRuntimeID(target) or tostring(target)
end

local function getTargetDistance(zombie, target)
    if not zombie or not target then
        return 9999
    end

    local dx = target:getX() - zombie:getX()
    local dy = target:getY() - zombie:getY()
    return math.sqrt((dx * dx) + (dy * dy))
end

local function isPlayerTarget(target)
    return target and instanceof and instanceof(target, "IsoPlayer")
end

Internal.GetMeleeArbiterTargetKey = getTargetKey
Internal.GetMeleeArbiterTargetDistance = getTargetDistance
Internal.IsMeleeArbiterPlayerTarget = isPlayerTarget
