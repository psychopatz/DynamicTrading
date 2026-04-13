-- ==============================================================================
-- DTNPC_MobilitySteering.lua
-- Steering, leash, and unstuck helpers for NPC mobility.
-- ==============================================================================

DTNPCMobility = DTNPCMobility or {}

local Mobility = DTNPCMobility
local Constants = Mobility.Constants or {}
local Internal = Mobility.Internal or {}

Mobility.Constants = Constants
Mobility.Internal = Internal

function Internal.isWithinLeash(nextX, nextY, currentZ, options)
    options = type(options) == "table" and options or {}
    local anchorX = tonumber(options.anchorX)
    local anchorY = tonumber(options.anchorY)
    local leashRadius = tonumber(options.leashRadius)

    if anchorX == nil or anchorY == nil or leashRadius == nil then
        return true
    end

    local anchorZ = tonumber(options.anchorZ)
    local leashFloor = anchorZ ~= nil and anchorZ or currentZ
    if math.abs((currentZ or 0) - leashFloor) > 1.1 then
        return false
    end

    local dx = nextX - anchorX
    local dy = nextY - anchorY
    return math.sqrt((dx * dx) + (dy * dy)) <= leashRadius
end

function Mobility.ChooseSteeredStep(zombie, npcData, desiredDirX, desiredDirY, step, options)
    if not zombie then
        return nil
    end

    options = type(options) == "table" and options or {}
    local len = math.sqrt((desiredDirX * desiredDirX) + (desiredDirY * desiredDirY))
    if len <= 0.001 or step <= 0.001 then
        return nil
    end

    desiredDirX = desiredDirX / len
    desiredDirY = desiredDirY / len

    local zx, zy, zz = zombie:getX(), zombie:getY(), zombie:getZ()
    local goalX = tonumber(options.goalX)
    local goalY = tonumber(options.goalY)
    local baseGoalDist = (goalX ~= nil and goalY ~= nil) and Internal.getDistance(zx, zy, goalX, goalY) or nil
    local angles = type(options.steeringAngles) == "table" and options.steeringAngles or Constants.DEFAULT_STEERING_ANGLES
    local bestCandidate = nil
    local bestFallback = nil
    local cell = getCell()

    for i = 1, #angles do
        local angle = tonumber(angles[i]) or 0
        local candidateDirX, candidateDirY = Internal.rotateDirection(desiredDirX, desiredDirY, angle)
        local nextX = zx + (candidateDirX * step)
        local nextY = zy + (candidateDirY * step)
        local inLeash = Internal.isWithinLeash(nextX, nextY, zz, options)
        if inLeash then
            local passage = nil
            if options.allowObstacleInteract == true then
                passage = Mobility.FindDirectionalPassage(
                    Internal.getSquareAt(cell, zx, zy, zz),
                    Internal.getSquareAt(cell, nextX, nextY, zz)
                )
            end

            local canMove = Mobility.IsTileSafe(nextX, nextY, zz)
            local candidateGoalDist = (goalX ~= nil and goalY ~= nil) and Internal.getDistance(nextX, nextY, goalX, goalY) or nil
            local exceedsGoalSlack = candidateGoalDist ~= nil
                and baseGoalDist ~= nil
                and (candidateGoalDist - baseGoalDist) > 0.35
            local progressScore = candidateGoalDist ~= nil and (baseGoalDist - candidateGoalDist)
                or ((candidateDirX * desiredDirX) + (candidateDirY * desiredDirY))
            local blockedPenalty = Internal.headingRepeatsBlocked(npcData, candidateDirX, candidateDirY) and 1.2 or 0
            local score = (progressScore * 4.0)
                - (math.abs(angle) * 0.01)
                - blockedPenalty
                + ((canMove or passage) and 0.15 or -2.0)

            if canMove or passage then
                local candidate = {
                    dirX = candidateDirX,
                    dirY = candidateDirY,
                    nextX = nextX,
                    nextY = nextY,
                    canMove = canMove,
                    passage = passage,
                    goalDist = candidateGoalDist,
                    score = score,
                    angle = angle,
                }

                if not exceedsGoalSlack then
                    if not bestCandidate or candidate.score > bestCandidate.score then
                        bestCandidate = candidate
                    end
                elseif not bestFallback or candidate.score > bestFallback.score then
                    bestFallback = candidate
                end
            end
        end
    end

    return bestCandidate or bestFallback
end

function Internal.tryUnstick(zombie, z, dirX, dirY)
    if not zombie then
        return false, nil, nil
    end

    local zx = zombie:getX()
    local zy = zombie:getY()
    local candidates = {
        { x = zx + (dirX * 1.5), y = zy + (dirY * 1.5) },
        { x = zx + (dirX * 1.5) - dirY, y = zy + (dirY * 1.5) + dirX },
        { x = zx + (dirX * 1.5) + dirY, y = zy + (dirY * 1.5) - dirX },
        { x = zx - dirY, y = zy + dirX },
        { x = zx + dirY, y = zy - dirX },
    }

    for i = 1, #candidates do
        local candidate = candidates[i]
        if Mobility.IsTileSafe(candidate.x, candidate.y, z) then
            zombie:setX(candidate.x)
            zombie:setY(candidate.y)
            zombie:setZ(z)
            return true, candidate.x, candidate.y
        end
    end

    return false, nil, nil
end
