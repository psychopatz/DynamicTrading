-- ==============================================================================
-- Behavior_Attack_Legacy.lua
-- Legacy wake-up handling for non-manual hostile movement states.
-- ==============================================================================

DTNPCLogic = DTNPCLogic or {}
DTNPCLogic.BehaviorAttack = DTNPCLogic.BehaviorAttack or {}

local BehaviorAttack = DTNPCLogic.BehaviorAttack
local modules = BehaviorAttack.Modules or {}

BehaviorAttack.Modules = modules

if modules.Legacy then
    return
end

modules.Legacy = true

function BehaviorAttack.RunLegacyWakeup(zombie, target, dist)
    if BehaviorAttack.IsPlayerTarget(target) then
        zombie:setTarget(nil)
        if target and target.getX and target.getY then
            zombie:faceLocation(target:getX(), target:getY())
        end
        if DTNPC and DTNPC.ApplySafetyFlags then
            DTNPC.ApplySafetyFlags(zombie, DTNPC.GetData and DTNPC.GetData(zombie) or nil, { clearPlayerTarget = true })
        end
        return
    end

    if zombie:isUseless() then
        zombie:setUseless(false)
        zombie:setSpeedMod(1.1)
        zombie:DoZombieStats()
        zombie:setSitAgainstWall(false)
    end

    if target then
        zombie:setTarget(nil)

        local shouldRun = (tonumber(dist) or 9999) > 3.0 or target:isRunning() or target:isSprinting()
        zombie:setRunning(shouldRun)

        if not zombie:isMoving() and (tonumber(dist) or 9999) > 1.5 then
            zombie:pathToLocation(target:getX(), target:getY(), target:getZ())
        end
    elseif not zombie:isMoving() then
        zombie:setRunning(true)
    end
end
