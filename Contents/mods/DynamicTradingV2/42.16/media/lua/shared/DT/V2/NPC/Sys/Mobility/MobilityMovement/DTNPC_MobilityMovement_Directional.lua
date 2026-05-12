-- ==============================================================================
-- DTNPC_MobilityMovement_Directional.lua
-- Directional movement execution for NPC mobility.
-- ==============================================================================

DTNPCMobility = DTNPCMobility or {}

local Mobility = DTNPCMobility
local Internal = Mobility.Internal or {}

Mobility.Internal = Internal

function Mobility.MoveByDirection(zombie, npcData, options)
    if not zombie then
        return false, "invalid"
    end

    options = type(options) == "table" and options or {}
    local progressGoalX = tonumber(options.progressGoalX)
    local progressGoalY = tonumber(options.progressGoalY)
    if progressGoalX == nil or progressGoalY == nil then
        progressGoalX = tonumber(options.goalX)
        progressGoalY = tonumber(options.goalY)
    end

    if npcData and Mobility.IsSpecialActionActive then
        local specialActive = Mobility.IsSpecialActionActive(npcData)
        if specialActive then
            if Mobility.UpdateSpecialAction then
                Mobility.UpdateSpecialAction(zombie, npcData)
            end
            Internal.recordMovementProgressSafe(npcData, zombie:getX(), zombie:getY(), progressGoalX, progressGoalY, {
                attemptedMove = true,
                exempt = true,
            })
            return true, "special_action"
        end
    end

    local dirX = tonumber(options.dirX) or 0
    local dirY = tonumber(options.dirY) or 0
    local len = math.sqrt((dirX * dirX) + (dirY * dirY))
    if len <= 0.001 then
        Mobility.Stop(zombie, options.anim)
        Internal.resetMovementProgressSafe(npcData)
        return false, "no_direction"
    end

    dirX = dirX / len
    dirY = dirY / len

    local movementProfile = DTNPCStamina and DTNPCStamina.BuildMovementProfile
        and DTNPCStamina.BuildMovementProfile(zombie, npcData, {
            speed = tonumber(options.speed) or 0,
            desiredRun = options.desiredRun == true,
            anim = options.anim,
            mode = options.staminaMode,
            profileKey = options.profileKey,
        })
        or nil
    local anim = Internal.buildAnimOverride(options.anim, movementProfile)

    if movementProfile and movementProfile.exhausted == true then
        Mobility.Stop(zombie, anim)
        Internal.resetMovementProgressSafe(npcData)
        if type(npcData) == "table" then
            npcData.isMovingState = false
        end
        return false, "exhausted"
    end

    local step = math.max(0, tonumber(movementProfile and movementProfile.speed or options.speed) or 0)
    if step <= 0.001 then
        Mobility.Stop(zombie, anim)
        Internal.resetMovementProgressSafe(npcData)
        return false, "stopped"
    end

    if options.allowDamageRetreat ~= false and options._forcedRetreatActive ~= true then
        local forcedRetreat = Mobility.GetForcedRetreat(zombie, npcData, options)
        if forcedRetreat then
            dirX = forcedRetreat.dirX
            dirY = forcedRetreat.dirY
        end
    end

    local zx, zy, zz = zombie:getX(), zombie:getY(), zombie:getZ()
    local chosenStep = Mobility.ChooseSteeredStep(zombie, npcData, dirX, dirY, step, options)
    local nextX = chosenStep and chosenStep.nextX or (zx + (dirX * step))
    local nextY = chosenStep and chosenStep.nextY or (zy + (dirY * step))
    local moveDirX = chosenStep and chosenStep.dirX or dirX
    local moveDirY = chosenStep and chosenStep.dirY or dirY
    local cell = getCell and getCell() or nil
    local fromSquare = Internal.getSquareAt and Internal.getSquareAt(cell, zx, zy, zz) or nil

    if options.allowObstacleInteract == true and Mobility.FindFenceAhead and Mobility.BeginFenceTraverse then
        local fenceAhead = Mobility.FindFenceAhead(zombie, npcData, {
            cell = cell,
            dirX = moveDirX,
            dirY = moveDirY,
            originX = zx,
            originY = zy,
            originZ = zz,
            fromSquare = fromSquare,
            midSquare = Internal.getSquareAt and Internal.getSquareAt(cell, nextX, nextY, zz) or nil,
        })
        if fenceAhead then
            local beganTraverse = false
            local traverseOptions = {}
            for key, value in pairs(options) do
                traverseOptions[key] = value
            end
            traverseOptions.dirX = moveDirX
            traverseOptions.dirY = moveDirY
            beganTraverse = Mobility.BeginFenceTraverse(zombie, npcData, fenceAhead, traverseOptions)
            if beganTraverse then
                Internal.clearBlockedCounter(npcData, options.blockCounterKey)
                Internal.recordMovementProgressSafe(npcData, zombie:getX(), zombie:getY(), progressGoalX, progressGoalY, {
                    attemptedMove = true,
                    exempt = true,
                })
                if DTNPCStamina and DTNPCStamina.ApplyMovementTick then
                    DTNPCStamina.ApplyMovementTick(zombie, npcData, movementProfile or {
                        requestedRun = false,
                        state = "steady",
                    }, {
                        moved = false,
                        specialAction = true,
                    })
                end
                Mobility.Stop(zombie, anim)
                return true, "special_action"
            end
        end
    end

    if not Internal.isWithinLeash(nextX, nextY, zz, options) then
        Mobility.Stop(zombie, options.anim)
        Internal.resetMovementProgressSafe(npcData)
        return false, "leash"
    end

    if options.allowObstacleInteract == true then
        local interacted = false
        local obstacleKind = nil
        if chosenStep and chosenStep.passage and chosenStep.canMove ~= true then
            local opened, openedKind = Mobility.TryOpenPassage(zombie, chosenStep.passage)
            if opened then
                Mobility.TrackOpenedPassage(npcData, chosenStep.passage)
                interacted = true
                obstacleKind = openedKind
            end
        else
            interacted, obstacleKind = Internal.tryInteractWithObstacle(zombie, npcData, zx, zy, zz, nextX, nextY, options)
        end

        if interacted then
            Internal.clearBlockedCounter(npcData, options.blockCounterKey)
            Mobility.Stop(zombie, anim)
            Internal.resetMovementProgressSafe(npcData)
            return false, "interacted_" .. tostring(obstacleKind or "obstacle")
        end
    end

    local canMove = chosenStep and chosenStep.canMove or Mobility.IsTileSafe(nextX, nextY, zz)
    if not canMove and options.allowObstacleInteract == true and Mobility.TryTraverseFence and Internal.getSquareAt then
        local nextSquare = Internal.getSquareAt(cell, nextX, nextY, zz)
        local traversed, traverseKind = Mobility.TryTraverseFence(zombie, npcData, fromSquare, nextSquare, options)
        if traversed then
            Internal.clearBlockedCounter(npcData, options.blockCounterKey)
            Internal.recordMovementProgressSafe(npcData, zombie:getX(), zombie:getY(), progressGoalX, progressGoalY, {
                attemptedMove = true,
                exempt = true,
            })
            if DTNPCStamina and DTNPCStamina.ApplyMovementTick then
                DTNPCStamina.ApplyMovementTick(zombie, npcData, movementProfile or {
                    requestedRun = false,
                    state = "steady",
                }, {
                    moved = false,
                    specialAction = true,
                })
            end
            return true, "special_action"
        end
    end

    if not canMove and options.allowAxisSlide ~= false then
        if Internal.isWithinLeash(nextX, zy, zz, options) and Mobility.IsTileSafe(nextX, zy, zz) then
            nextY = zy
            canMove = true
        elseif Internal.isWithinLeash(zx, nextY, zz, options) and Mobility.IsTileSafe(zx, nextY, zz) then
            nextX = zx
            canMove = true
        end
    end

    if canMove then
        Internal.clearBlockedCounter(npcData, options.blockCounterKey)
        zombie:setX(nextX)
        zombie:setY(nextY)
        if options.targetZ ~= nil then
            zombie:setZ(options.targetZ)
        end

        Internal.applyMovementState(zombie, anim)

        local faceX = tonumber(options.faceX)
        local faceY = tonumber(options.faceY)
        if options.faceTargetWhileMoving == true and faceX ~= nil and faceY ~= nil then
            zombie:faceLocation(faceX, faceY)
        else
            zombie:faceLocation(nextX + moveDirX, nextY + moveDirY)
        end

        Internal.rememberMotion(npcData, zx, zy, nextX, nextY, {
            speed = step,
            crawl = anim and anim.crawl == true or false,
            isRunning = anim and anim.isRunning == true or false,
        })
        if type(npcData) == "table" then
            npcData._dtLastMoveDirX = moveDirX
            npcData._dtLastMoveDirY = moveDirY
            npcData._dtLastSteerDirX = moveDirX
            npcData._dtLastSteerDirY = moveDirY
            npcData._dtBlockedHeading = nil
            npcData._dtBlockedHeadingUntil = 0
        end
        Internal.recordMovementProgressSafe(npcData, nextX, nextY, progressGoalX, progressGoalY, {
            attemptedMove = true,
        })
        if DTNPCStamina and DTNPCStamina.ApplyMovementTick then
            DTNPCStamina.ApplyMovementTick(zombie, npcData, movementProfile or {
                requestedRun = anim and anim.isRunning == true,
                state = anim and anim.isRunning == true and "steady" or "fresh",
                mode = options.staminaMode,
            }, {
                moved = true,
            })
        end
        Mobility.TryClosePassedDoor(zombie, npcData, {
            target = options.closeDoorTarget,
            safeRadius = options.closeDoorSafeRadius,
        })
        return true, "moving"
    end

    local blockedTicks = Internal.incrementBlockedCounter(npcData, options.blockCounterKey)
    Internal.setBlockedHeading(npcData, moveDirX, moveDirY)
    Internal.recordMovementProgressSafe(npcData, zx, zy, progressGoalX, progressGoalY, {
        attemptedMove = true,
    })
    local stuckTicks = math.max(0, tonumber(options.stuckTicks) or 0)
    local stalled, stallReason = Internal.shouldRecoverFromNoProgressSafe(npcData, options)
    if (blockedTicks >= stuckTicks and stuckTicks > 0) or stalled then
        local unstuck, unstuckX, unstuckY = Internal.tryUnstick(zombie, zz, moveDirX, moveDirY)
        if unstuck then
            Internal.clearBlockedCounter(npcData, options.blockCounterKey)
            Internal.applyMovementState(zombie, anim)
            zombie:faceLocation(unstuckX + moveDirX, unstuckY + moveDirY)
            Internal.rememberMotion(npcData, zx, zy, unstuckX, unstuckY, {
                speed = step,
                crawl = anim and anim.crawl == true or false,
                isRunning = anim and anim.isRunning == true or false,
            })
            if type(npcData) == "table" then
                npcData._dtLastMoveDirX = moveDirX
                npcData._dtLastMoveDirY = moveDirY
                npcData._dtLastSteerDirX = moveDirX
                npcData._dtLastSteerDirY = moveDirY
            end
            Internal.recordMovementProgressSafe(npcData, unstuckX, unstuckY, progressGoalX, progressGoalY, {
                attemptedMove = true,
            })
            if DTNPCStamina and DTNPCStamina.ApplyMovementTick then
                DTNPCStamina.ApplyMovementTick(zombie, npcData, movementProfile or {
                    requestedRun = anim and anim.isRunning == true,
                    state = anim and anim.isRunning == true and "steady" or "fresh",
                    mode = options.staminaMode,
                }, {
                    moved = true,
                })
            end
            return true, "unstuck"
        end
    end

    if DTNPCStamina and DTNPCStamina.ApplyMovementTick then
        DTNPCStamina.ApplyMovementTick(zombie, npcData, movementProfile or {
            requestedRun = anim and anim.isRunning == true,
            state = anim and anim.isRunning == true and "steady" or "fresh",
            mode = options.staminaMode,
        }, {
            moved = false,
            blocked = true,
        })
    end
    Mobility.Stop(zombie, anim)
    return false, "blocked"
end
