-- ==============================================================================
-- DTNPC_MobilityCommon_Progress.lua
-- Movement progress tracking helpers.
-- ==============================================================================

DTNPCMobility = DTNPCMobility or {}

local Mobility = DTNPCMobility
local Constants = Mobility.Constants or {}
local Internal = Mobility.Internal or {}

Mobility.Constants = Constants
Mobility.Internal = Internal

function Mobility.ResetMovementProgress(npcData)
    Internal.resetMovementProgress(npcData)
end

function Mobility.RecordMovementProgress(npcData, currentX, currentY, goalX, goalY, options)
    if type(npcData) ~= "table" then
        return nil
    end

    options = type(options) == "table" and options or {}
    if options.reset == true or options.attemptedMove ~= true then
        Internal.resetMovementProgress(npcData)
        return nil
    end

    local currentTime = Internal.getTimeMs()
    local progress = type(npcData._dtMoveProgress) == "table" and npcData._dtMoveProgress or {}
    local prevX = tonumber(progress.x)
    local prevY = tonumber(progress.y)
    local movedDist = nil
    if prevX ~= nil and prevY ~= nil then
        movedDist = Internal.getDistance(prevX, prevY, currentX, currentY)
    end

    local hasGoal = goalX ~= nil and goalY ~= nil
    local currentGoalDist = hasGoal and Internal.getDistance(currentX, currentY, goalX, goalY) or nil
    local bestGoalDist = tonumber(progress.bestGoalDist)
    local previousGoalX = tonumber(progress.goalX)
    local previousGoalY = tonumber(progress.goalY)
    local moveEpsilon = math.max(0.005, tonumber(options.moveEpsilon) or Constants.MOVE_PROGRESS_EPSILON)
    local goalEpsilon = math.max(0.01, tonumber(options.goalEpsilon) or Constants.MOVE_PROGRESS_GOAL_EPSILON)
    local targetShiftReset = math.max(0.2, tonumber(options.targetShiftResetDistance) or 0.75)
    local madeProgress = false

    if options.exempt == true then
        progress.noProgressTicks = 0
        progress.lastProgressAt = currentTime
        if currentGoalDist ~= nil then
            progress.bestGoalDist = currentGoalDist
            progress.goalDist = currentGoalDist
        end
    else
        local targetShift = nil
        if hasGoal and previousGoalX ~= nil and previousGoalY ~= nil then
            targetShift = Internal.getDistance(previousGoalX, previousGoalY, goalX, goalY)
        end
        if targetShift ~= nil and targetShift >= targetShiftReset then
            progress.noProgressTicks = 0
            progress.lastProgressAt = currentTime
            bestGoalDist = currentGoalDist
            progress.bestGoalDist = currentGoalDist
        end

        if movedDist ~= nil and movedDist > moveEpsilon then
            madeProgress = true
        elseif hasGoal and (bestGoalDist == nil or currentGoalDist < (bestGoalDist - goalEpsilon)) then
            madeProgress = true
            progress.bestGoalDist = currentGoalDist
        end

        if hasGoal then
            if progress.bestGoalDist == nil then
                progress.bestGoalDist = currentGoalDist
            end
            progress.goalDist = currentGoalDist
        end
    end

    if madeProgress then
        progress.noProgressTicks = 0
        progress.lastProgressAt = currentTime
    elseif options.exempt ~= true then
        progress.noProgressTicks = (tonumber(progress.noProgressTicks) or 0) + 1
    end

    progress.x = currentX
    progress.y = currentY
    progress.goalX = goalX
    progress.goalY = goalY
    progress.lastMoveAt = currentTime
    progress.moveDist = movedDist or 0
    npcData._dtMoveProgress = progress
    npcData._dtNoProgressTicks = tonumber(progress.noProgressTicks) or 0
    return progress
end

function Mobility.ShouldTriggerProgressRecovery(npcData, options)
    if type(npcData) ~= "table" then
        return false, nil
    end

    options = type(options) == "table" and options or {}
    local progress = type(npcData._dtMoveProgress) == "table" and npcData._dtMoveProgress or nil
    if not progress then
        return false, nil
    end

    local specialActive = Mobility.IsSpecialActionActive and Mobility.IsSpecialActionActive(npcData, "fence")
    if specialActive then
        return false, nil
    end

    local currentTime = Internal.getTimeMs()
    local noProgressTicks = math.max(0, tonumber(progress.noProgressTicks) or tonumber(npcData._dtNoProgressTicks) or 0)
    local lastProgressAt = tonumber(progress.lastProgressAt) or currentTime
    local stallTicks = math.max(0, tonumber(options.stallTicks) or Constants.MOVE_PROGRESS_STALL_TICKS)
    local stallMs = math.max(0, tonumber(options.stallMs) or Constants.MOVE_PROGRESS_STALL_MS)

    if stallTicks > 0 and noProgressTicks >= stallTicks then
        return true, "ticks"
    end
    if stallMs > 0 and (currentTime - lastProgressAt) >= stallMs then
        return true, "time"
    end

    return false, nil
end
