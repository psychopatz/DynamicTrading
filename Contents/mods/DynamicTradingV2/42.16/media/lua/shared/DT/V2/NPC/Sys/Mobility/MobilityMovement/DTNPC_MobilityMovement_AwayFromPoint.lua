-- ==============================================================================
-- DTNPC_MobilityMovement_AwayFromPoint.lua
-- Retreat-spacing helpers for NPC mobility.
-- ==============================================================================

DTNPCMobility = DTNPCMobility or {}

local Mobility = DTNPCMobility

function Mobility.MoveAwayFromPoint(zombie, npcData, options)
    if not zombie then
        return false, "invalid", 9999
    end

    options = type(options) == "table" and options or {}
    local fromX = tonumber(options.fromX)
    local fromY = tonumber(options.fromY)
    if fromX == nil or fromY == nil then
        local target = options.target
        if target and target.getX and target.getY then
            fromX = target:getX()
            fromY = target:getY()
        end
    end
    if fromX == nil or fromY == nil then
        Mobility.Stop(zombie, options.anim)
        return false, "invalid_target", 9999
    end

    local zx, zy = zombie:getX(), zombie:getY()
    local dx = zx - fromX
    local dy = zy - fromY
    local len = math.sqrt((dx * dx) + (dy * dy))
    local desiredDistance = math.max(0, tonumber(options.desiredDistance) or 0)

    if len >= desiredDistance then
        Mobility.Stop(zombie, options.anim)
        return true, "spaced", len
    end

    if len <= 0.001 then
        local cachedDirX = tonumber(npcData and npcData._dtLastMoveDirX) or 0
        local cachedDirY = tonumber(npcData and npcData._dtLastMoveDirY) or 0
        if math.abs(cachedDirX) > 0.001 or math.abs(cachedDirY) > 0.001 then
            dx = cachedDirX
            dy = cachedDirY
        else
            dx = ZombRandFloat(-1.0, 1.0)
            dy = ZombRandFloat(-1.0, 1.0)
        end
    end

    local step = math.min(math.max(0, tonumber(options.speed) or 0), math.max(0, desiredDistance - len))
    if step <= 0.001 then
        Mobility.Stop(zombie, options.anim)
        return true, "spaced", len
    end

    local forcedRetreat = nil
    if options.allowDamageRetreat ~= false then
        forcedRetreat = Mobility.GetForcedRetreat(zombie, npcData, options)
    end

    local moveDirX = forcedRetreat and forcedRetreat.dirX or dx
    local moveDirY = forcedRetreat and forcedRetreat.dirY or dy

    return Mobility.MoveByDirection(zombie, npcData, {
        dirX = moveDirX,
        dirY = moveDirY,
        speed = step,
        allowAxisSlide = options.allowAxisSlide ~= false,
        allowObstacleInteract = options.allowObstacleInteract ~= false,
        allowDamageRetreat = false,
        _forcedRetreatActive = forcedRetreat ~= nil,
        blockCounterKey = options.blockCounterKey,
        stuckTicks = options.stuckTicks,
        anim = options.anim,
        anchorX = options.anchorX,
        anchorY = options.anchorY,
        anchorZ = options.anchorZ,
        leashRadius = options.leashRadius,
        targetZ = options.targetZ,
        faceX = options.faceX,
        faceY = options.faceY,
        faceTargetWhileMoving = options.faceTargetWhileMoving,
        staminaMode = options.staminaMode or "retreat",
        desiredRun = false,
        goalX = zombie:getX() + (moveDirX * step),
        goalY = zombie:getY() + (moveDirY * step),
        steeringAngles = options.steeringAngles,
    })
end
