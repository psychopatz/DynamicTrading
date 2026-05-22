-- ==============================================================================
-- DTNPC_LootSearchShared_Movement.lua
-- Movement and approach-point helpers.
-- ==============================================================================

DTNPCLootSearch = DTNPCLootSearch or {}
DTNPCLootSearch.Internal = DTNPCLootSearch.Internal or {}
DTNPCLootSearch.Modules = DTNPCLootSearch.Modules or {}

if DTNPCLootSearch.Modules.Movement then
    return
end

DTNPCLootSearch.Modules.Movement = true

local Internal = DTNPCLootSearch.Internal
local Constants = Internal.Constants

function Internal.isLootTileSafe(x, y, z)
    if DTNPCMobility and DTNPCMobility.IsTileSafe then
        return DTNPCMobility.IsTileSafe(x, y, z)
    end

    local cell = getCell and getCell() or nil
    local square = cell and cell:getGridSquare(x, y, z or 0) or nil
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

function Internal.resolveApproachPoint(source, referenceX, referenceY)
    if type(source) ~= "table" then
        return nil
    end

    local targetX = tonumber(source.x)
    local targetY = tonumber(source.y)
    local targetZ = tonumber(source.z) or 0
    if targetX == nil or targetY == nil then
        return nil
    end

    if source.kind ~= "world" and source.kind ~= "vehicle" then
        local stopDistance = tonumber(source.stopDistance) or Constants.SEARCH_STOP_DISTANCE
        if source.kind == "corpse" then
            stopDistance = math.max(stopDistance, Constants.SEARCH_CORPSE_STOP_DISTANCE)
        elseif source.kind == "groundItem" or source.kind == "bag" then
            stopDistance = math.max(stopDistance, Constants.SEARCH_GROUND_STOP_DISTANCE)
        end
        return {
            x = targetX,
            y = targetY,
            z = targetZ,
            stopDistance = stopDistance,
        }
    end

    local candidates = {
        { x = targetX - 1, y = targetY, z = targetZ },
        { x = targetX + 1, y = targetY, z = targetZ },
        { x = targetX, y = targetY - 1, z = targetZ },
        { x = targetX, y = targetY + 1, z = targetZ },
        { x = targetX - 1, y = targetY - 1, z = targetZ },
        { x = targetX + 1, y = targetY - 1, z = targetZ },
        { x = targetX - 1, y = targetY + 1, z = targetZ },
        { x = targetX + 1, y = targetY + 1, z = targetZ },
        { x = targetX, y = targetY, z = targetZ },
    }

    local bestCandidate = nil
    local bestDistance = nil
    local originX = tonumber(referenceX) or targetX
    local originY = tonumber(referenceY) or targetY

    for _, candidate in ipairs(candidates) do
        if Internal.isLootTileSafe(candidate.x, candidate.y, candidate.z) then
            local candidateDistance = Internal.getDistance(originX, originY, candidate.x, candidate.y)
            if not bestCandidate or candidateDistance < bestDistance then
                bestCandidate = candidate
                bestDistance = candidateDistance
            end
        end
    end

    if bestCandidate then
        if source.kind == "vehicle" then
            bestCandidate.stopDistance = Constants.SEARCH_VEHICLE_STOP_DISTANCE
        else
            bestCandidate.stopDistance = Constants.SEARCH_WORLD_STOP_DISTANCE
        end
        return bestCandidate
    end

    return {
        x = targetX,
        y = targetY,
        z = targetZ,
        stopDistance = source.kind == "vehicle" and Constants.SEARCH_VEHICLE_STOP_DISTANCE or Constants.SEARCH_WORLD_STOP_DISTANCE,
    }
end

function DTNPCLootSearch.MoveTowardSource(zombie, npcData, source)
    if not zombie or not npcData or not source then
        return false, "invalid"
    end

    local approach = Internal.resolveApproachPoint(source, zombie:getX(), zombie:getY())
    source.approachX = approach and approach.x or source.approachX or source.x
    source.approachY = approach and approach.y or source.approachY or source.y
    source.approachZ = approach and approach.z or source.approachZ or source.z
    source.stopDistance = approach and approach.stopDistance or source.stopDistance or Constants.SEARCH_STOP_DISTANCE

    local target = {
        getX = function() return tonumber(source.approachX or source.x) or zombie:getX() end,
        getY = function() return tonumber(source.approachY or source.y) or zombie:getY() end,
        getZ = function() return tonumber(source.approachZ or source.z) or zombie:getZ() end,
    }

    return DTNPCMobility.MoveTowardTarget(zombie, npcData, {
        target = target,
        speed = DynamicTrading.GetNPCWalkSpeed and DynamicTrading.GetNPCWalkSpeed() or 0.035,
        navigationMode = "planned",
        plannerProfile = "colony",
        staminaMode = "travel",
        desiredRun = false,
        stopDistance = tonumber(source.stopDistance) or Constants.SEARCH_STOP_DISTANCE,
        allowObstacleInteract = true,
        allowDamageRetreat = true,
        blockCounterKey = "lootSearchBlockedTicks",
        stuckTicks = 14,
        targetZ = tonumber(source.approachZ or source.z) or zombie:getZ(),
        faceX = tonumber(source.x) or target:getX(),
        faceY = tonumber(source.y) or target:getY(),
        closeDoorSafeRadius = 3.0,
        anim = {
            animSpeed = 1.0,
            isRunning = false,
            dtWalkType = "Walk",
        },
    })
end
