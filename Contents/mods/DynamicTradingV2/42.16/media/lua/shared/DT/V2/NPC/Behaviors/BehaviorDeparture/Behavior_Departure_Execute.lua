-- ==============================================================================
-- Behavior_Departure_Execute.lua
-- Departure behavior execution and movement loop.
-- ==============================================================================

DTNPCLogic = DTNPCLogic or {}
DTNPCLogic.Behaviors = DTNPCLogic.Behaviors or {}
DTNPCLogic.Internal = DTNPCLogic.Internal or {}
DTNPCLogic.Internal.Departure = DTNPCLogic.Internal.Departure or {}

local internal = DTNPCLogic.Internal.Departure

DTNPCLogic.Behaviors["Departure"] = function(zombie, npcData, target, dist)
    local isRecruitmentDeparture = internal.isColonyRecruitmentDeparture(npcData)
    local locomotionProfileKey = internal.getDepartureLocomotionProfileKey and internal.getDepartureLocomotionProfileKey(npcData) or "default"
    local locomotionProfile = DTNPCMobility and DTNPCMobility.GetLocomotionProfile and DTNPCMobility.GetLocomotionProfile(locomotionProfileKey) or nil
    local observer = nil
    local observerDist = 9999
    if isRecruitmentDeparture and target and instanceof and instanceof(target, "IsoPlayer") then
        observer = target
        observerDist = tonumber(dist) or internal.getDist(zombie:getX(), zombie:getY(), target:getX(), target:getY())
    else
        observer, observerDist = internal.getNearestPlayer(zombie)
    end

    local currentHours = getGameTime():getWorldAgeHours()

    if npcData.departureForceDespawnAt and currentHours >= npcData.departureForceDespawnAt then
        if (not observer) or observerDist > internal.DESPAWN_DIST then
            internal.completeDeparture(zombie, npcData, "force_timeout")
            return
        end

        if not npcData.departureTimeoutVisibleLogged
            and DTNPCManager
            and DTNPCManager.RespawnDebug
            and DTNPCManager.RespawnDebug.Log then
            DTNPCManager.RespawnDebug.Log(
                "departure_wait_visible_" .. tostring(npcData.uuid),
                "Process=departure_timeout_wait_visible uuid=" .. tostring(npcData.uuid) ..
                    " name=" .. tostring(npcData.name or npcData.uuid) ..
                    " observerDist=" .. string.format("%.2f", observerDist) ..
                    " despawnDist=" .. tostring(internal.DESPAWN_DIST),
                true
            )
            npcData.departureTimeoutVisibleLogged = true
        end
    end

    if observer and observerDist > internal.DESPAWN_DIST and observerDist < 1000 then
        internal.completeDeparture(zombie, npcData, "observer_distance")
        return
    end

    local hasDestination, dx, dy, destinationState = internal.resolveDepartureDirection(
        zombie,
        npcData,
        target,
        dist,
        observer,
        observerDist,
        isRecruitmentDeparture
    )

    if not hasDestination then
        if destinationState == "target_reached_visible_zero_dir" then
            internal.completeDeparture(zombie, npcData, destinationState)
            return
        end
        if destinationState == "target_reached_unseen" then
            internal.completeDeparture(zombie, npcData, destinationState)
            return
        end
        if not zombie:isUseless() then
            zombie:setUseless(true)
        end
        internal.stopDepartureAnimation(zombie, npcData)
        return
    end

    if not npcData.isMovingState then
        npcData.isMovingState = false
    end
    if not npcData.isMovingState then
        npcData.isMovingState = true
        if DTNPCLogic.Behaviors["Attack"] then
            DTNPCLogic.Behaviors["Attack"](zombie, npcData, target, dist)
        end
        return
    end

    if not zombie:isUseless() then
        zombie:setUseless(true)
        zombie:setPath2(nil)
        zombie:setRunning(false)
    end

    local speedMult = tonumber(locomotionProfile and locomotionProfile.speedMultiplier) or 1.0
    local moved, moveState = DTNPCMobility.MoveByDirection(zombie, npcData, {
        dirX = dx,
        dirY = dy,
        speed = DynamicTrading.GetNPCRunSpeed() * speedMult,
        staminaMode = "departure",
        desiredRun = locomotionProfileKey == "default",
        profileKey = locomotionProfileKey,
        allowObstacleInteract = not isRecruitmentDeparture,
        allowDamageRetreat = true,
        blockCounterKey = "departureBlockedTicks",
        stuckTicks = internal.STUCK_TICKS,
    })

    if moveState == "exhausted" then
        npcData.departureBlockedTicks = 0
        internal.stopDepartureAnimation(zombie, npcData)
    elseif moved or moveState == "damage_retreat" then
        npcData.departureStuckLastX = zombie:getX()
        npcData.departureStuckLastY = zombie:getY()
    elseif moveState and string.find(tostring(moveState), "interacted_", 1, true) then
        npcData.departureBlockedTicks = 0
    elseif DTNPCBehaviorAntiStuck and DTNPCBehaviorAntiStuck.TryRecover then
        local recoveryTargetX, recoveryTargetY, recoveryTargetZ = internal.getDepartureRecoveryTarget(zombie, npcData, dx, dy)
        local recovered = false
        if recoveryTargetX ~= nil and recoveryTargetY ~= nil then
            recovered = DTNPCBehaviorAntiStuck.TryRecover(zombie, npcData, {
                behaviorKey = "Departure",
                targetX = recoveryTargetX,
                targetY = recoveryTargetY,
                targetZ = recoveryTargetZ,
                currentDist = internal.getDist(zombie:getX(), zombie:getY(), recoveryTargetX, recoveryTargetY),
                moved = moved,
                moveState = moveState,
                blockCounterKey = "departureBlockedTicks",
                blockedTicks = npcData.departureBlockedTicks,
                blockedThreshold = internal.STUCK_TICKS + 6,
                hardBlockedThreshold = internal.STUCK_TICKS + 16,
                stallThreshold = internal.STUCK_TICKS + 8,
                minDistance = 1.5,
                cooldownTicks = 260,
                maxRecoveries = 1,
                arrivalRadius = 0.9,
                allowExactTarget = false,
                faceX = recoveryTargetX,
                faceY = recoveryTargetY,
                fallbackDirX = dx,
                fallbackDirY = dy,
            })
        end

        if recovered then
            npcData.departureBlockedTicks = 0
            npcData.departureStuckLastX = zombie:getX()
            npcData.departureStuckLastY = zombie:getY()
            npcData.departureLastDirX = dx
            npcData.departureLastDirY = dy
        elseif (npcData.departureBlockedTicks or 0) >= internal.STUCK_ABORT_TICKS then
            internal.completeDeparture(zombie, npcData, "stuck_abort_blocked")
            return
        else
            internal.stopDepartureAnimation(zombie, npcData)
        end
    else
        if (npcData.departureBlockedTicks or 0) >= internal.STUCK_ABORT_TICKS then
            internal.completeDeparture(zombie, npcData, "stuck_abort_blocked")
            return
        end
        internal.stopDepartureAnimation(zombie, npcData)
    end
end
