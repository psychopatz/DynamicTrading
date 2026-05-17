-- ==============================================================================
-- DTNPC_MobilityLocomotion.lua
-- Locomotion state helpers for NPC mobility.
-- ==============================================================================

DTNPCMobility = DTNPCMobility or {}

local Mobility = DTNPCMobility
local Internal = Mobility.Internal or {}

Mobility.Internal = Internal

function Internal.getMovementAnimName(options, moving)
    if not moving then
        return ""
    end
    if options and options.crawl == true then
        return "Crawl"
    end
    if options and options.dtWalkType ~= nil and tostring(options.dtWalkType) ~= "" then
        return tostring(options.dtWalkType)
    end
    if options and options.isRunning == true then
        return "Run"
    end
    return "Walk"
end

function Internal.applyEngineWalkType(zombie, moveAnim, options)
    if not zombie then
        return
    end

    local resolved = nil
    if type(options) == "table" and options.engineWalkType ~= nil and tostring(options.engineWalkType) ~= "" then
        resolved = tostring(options.engineWalkType)
    elseif moveAnim and moveAnim ~= "" and moveAnim ~= "Crawl" then
        resolved = tostring(moveAnim)
    end

    if resolved and resolved ~= "" then
        Internal.safeCall(zombie, "setWalkType", resolved)
    end
end

function Mobility.IsTileSafe(x, y, z)
    local cell = getCell()
    local square = cell and cell:getGridSquare(x, y, z) or nil
    if not square then
        return true
    end
    if not square:isFree(false) then
        return false
    end
    if square:isSolid() or square:isSolidTrans() then
        return false
    end
    return true
end

function Mobility.SetLocomotionState(zombie, options)
    if not zombie then
        return
    end

    options = type(options) == "table" and options or {}
    if Mobility.ResolveLocomotionStateOptions then
        options = Mobility.ResolveLocomotionStateOptions(options)
    end
    local moving = options.moving == true
    local animSpeed = Internal.getAnimSpeed(options)
    local moveAnim = Internal.getMovementAnimName(options, moving)

    if options.idleState ~= nil then
        zombie:setVariable("DTIdleState", tostring(options.idleState))
    elseif moving then
        zombie:setVariable("DTIdleState", "0")
    end

    -- Fake crawl is driven by DTWalkType/DTNPCMoveAnim. Forcing vanilla crawler flags
    -- causes posture snaps with the teleported/interpolated NPC pipeline.
    if options.crawl ~= nil or moving ~= true then
        zombie:setVariable("bBecomeCrawler", false)
        zombie:setVariable("bCrawling", false)
        zombie:setVariable("FallOnFront", false)
    end

    zombie:setVariable("bMoving", moving)
    zombie:setVariable("isMoving", moving)
    zombie:setVariable("DTNPCMoveAnim", moveAnim)
    zombie:setVariable("DTNPCAnimSpeed", moving and animSpeed or 0.0)
    zombie:setVariable("MovementSpeed", moving and animSpeed or 0.0)
    zombie:setVariable("WalkSpeed", moving and math.max(0.1, animSpeed) or 0.0)
    zombie:setVariable("RunSpeed", moving and math.max(0.1, animSpeed) or 0.0)
    Internal.applyEngineWalkType(zombie, moveAnim, options)

    if options.walkType ~= nil then
        zombie:setVariable("WalkType", tostring(options.walkType))
    elseif options.crawl == true then
        zombie:setVariable("WalkType", "")
    elseif moving and options.crawl ~= true then
        zombie:setVariable("WalkType", "1")
    elseif moving ~= true then
        zombie:setVariable("WalkType", "")
    end
    if options.dtWalkType ~= nil then
        zombie:setVariable("DTWalkType", tostring(options.dtWalkType))
    elseif moving then
        zombie:setVariable("DTWalkType", moveAnim)
    else
        zombie:setVariable("DTWalkType", "")
    end

    zombie:setVariable("Speed", moving and animSpeed or 0.0)
    zombie:setRunning(moving and options.isRunning == true or false)
    Internal.safeCall(zombie, "setSpeedMod", 1)
end

function Mobility.Stop(zombie, options)
    options = type(options) == "table" and options or {}
    options.moving = false
    Mobility.SetLocomotionState(zombie, options)
end
