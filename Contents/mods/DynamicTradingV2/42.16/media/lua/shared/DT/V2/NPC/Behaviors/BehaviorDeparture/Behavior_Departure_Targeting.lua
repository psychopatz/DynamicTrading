-- ==============================================================================
-- Behavior_Departure_Targeting.lua
-- Direction and recovery target resolution for NPC departure behavior.
-- ==============================================================================

DTNPCLogic = DTNPCLogic or {}
DTNPCLogic.Behaviors = DTNPCLogic.Behaviors or {}
DTNPCLogic.Internal = DTNPCLogic.Internal or {}
DTNPCLogic.Internal.Departure = DTNPCLogic.Internal.Departure or {}

local internal = DTNPCLogic.Internal.Departure

function internal.getDepartureRecoveryTarget(zombie, npcData, dirX, dirY)
    local zx = zombie and zombie:getX() or 0
    local zy = zombie and zombie:getY() or 0
    local targetX = tonumber(npcData and npcData.departureTargetX)
    local targetY = tonumber(npcData and npcData.departureTargetY)
    local targetZ = tonumber(npcData and npcData.departureTargetZ) or (zombie and zombie:getZ() or 0)

    if targetX ~= nil and targetY ~= nil then
        local distToGoal = internal.getDist(zx, zy, targetX, targetY)
        if distToGoal <= (internal.RECOVERY_STEP_DIST + 2.0) then
            return targetX, targetY, targetZ
        end
    end

    local moveX = tonumber(dirX) or 0
    local moveY = tonumber(dirY) or 0
    local len = math.sqrt((moveX * moveX) + (moveY * moveY))
    if len > 0.001 then
        moveX = moveX / len
        moveY = moveY / len
        return zx + (moveX * internal.RECOVERY_STEP_DIST), zy + (moveY * internal.RECOVERY_STEP_DIST), targetZ
    end

    return targetX, targetY, targetZ
end

function internal.resolveDepartureDirection(zombie, npcData, target, dist, observer, observerDist, isRecruitmentDeparture)
    local zx = zombie:getX()
    local zy = zombie:getY()
    local dx = 0
    local dy = 0
    local hasDestination = false

    if isRecruitmentDeparture then
        if not npcData.departureRecruitModeLogged then
            npcData.departureRecruitModeLogged = true
            internal.logDepartureTrace(
                npcData,
                "colony_mode",
                "Process=departure_colony_mode uuid=" .. tostring(npcData.uuid) ..
                    " name=" .. tostring(npcData.name or npcData.uuid) ..
                    " observerDist=" .. tostring(observerDist) ..
                    " hasObserver=" .. tostring(observer ~= nil) ..
                    " targetType=" .. tostring(
                        (target and target.getObjectName and target:getObjectName())
                            or (target and target.getType and target:getType())
                            or type(target)
                    ) ..
                    " target=" .. tostring(npcData.departureTargetX) .. "," .. tostring(npcData.departureTargetY) .. "," .. tostring(npcData.departureTargetZ),
                true
            )
        end

        if observer then
            local len = math.sqrt(((zx - observer:getX()) ^ 2) + ((zy - observer:getY()) ^ 2))
            if len > 0.001 then
                dx = (zx - observer:getX()) / len
                dy = (zy - observer:getY()) / len
                npcData.departureLastDirX = dx
                npcData.departureLastDirY = dy
                hasDestination = true
            elseif npcData.departureLastDirX and npcData.departureLastDirY then
                dx = npcData.departureLastDirX
                dy = npcData.departureLastDirY
                hasDestination = true
            end
        elseif npcData.departureLastDirX and npcData.departureLastDirY then
            dx = npcData.departureLastDirX
            dy = npcData.departureLastDirY
            hasDestination = true

            if not npcData.departureRecruitObserverLostLogged then
                npcData.departureRecruitObserverLostLogged = true
                internal.logDepartureTrace(
                    npcData,
                    "colony_no_observer",
                    "Process=departure_colony_no_observer uuid=" .. tostring(npcData.uuid) ..
                        " name=" .. tostring(npcData.name or npcData.uuid) ..
                        " usingLastDir=true",
                    true
                )
            end
        elseif npcData.departureTargetX and npcData.departureTargetY then
            dx = npcData.departureTargetX - zx
            dy = npcData.departureTargetY - zy
            local len = math.sqrt(dx * dx + dy * dy)
            if len > 0.001 then
                dx = dx / len
                dy = dy / len
                npcData.departureLastDirX = dx
                npcData.departureLastDirY = dy
                hasDestination = true
            end

            if hasDestination and not npcData.departureRecruitFallbackLogged then
                npcData.departureRecruitFallbackLogged = true
                internal.logDepartureTrace(
                    npcData,
                    "colony_target_fallback",
                    "Process=departure_colony_target_fallback uuid=" .. tostring(npcData.uuid) ..
                        " name=" .. tostring(npcData.name or npcData.uuid) ..
                        " target=" .. tostring(npcData.departureTargetX) .. "," .. tostring(npcData.departureTargetY) .. "," .. tostring(npcData.departureTargetZ),
                    true
                )
            end
        end
    elseif npcData.departureTargetX and npcData.departureTargetY then
        dx = npcData.departureTargetX - zx
        dy = npcData.departureTargetY - zy
        local len = math.sqrt(dx * dx + dy * dy)
        if len > internal.TARGET_REACHED_DIST then
            dx = dx / len
            dy = dy / len
            npcData.departureLastDirX = dx
            npcData.departureLastDirY = dy
            hasDestination = true
        elseif npcData.departureLastDirX and npcData.departureLastDirY then
            dx = npcData.departureLastDirX
            dy = npcData.departureLastDirY
            hasDestination = true
        elseif observer then
            dx = zx - observer:getX()
            dy = zy - observer:getY()
            len = math.sqrt(dx * dx + dy * dy)
            if len > 0 then
                dx = dx / len
                dy = dy / len
                npcData.departureLastDirX = dx
                npcData.departureLastDirY = dy
                hasDestination = true
            else
                return false, 0, 0, "target_reached_visible_zero_dir"
            end
        else
            return false, 0, 0, "target_reached_unseen"
        end
    elseif npcData.departureLastDirX then
        dx = npcData.departureLastDirX
        dy = npcData.departureLastDirY
        hasDestination = true
    elseif observer then
        dx = zx - observer:getX()
        dy = zy - observer:getY()
        local len = math.sqrt(dx * dx + dy * dy)
        if len > 0 then
            dx = dx / len
            dy = dy / len
            npcData.departureLastDirX = dx
            npcData.departureLastDirY = dy
            hasDestination = true
        end
    end

    if not hasDestination then
        if isRecruitmentDeparture and not npcData.departureRecruitNoDirectionLogged then
            npcData.departureRecruitNoDirectionLogged = true
            internal.logDepartureTrace(
                npcData,
                "colony_no_direction",
                "Process=departure_colony_no_direction uuid=" .. tostring(npcData.uuid) ..
                    " name=" .. tostring(npcData.name or npcData.uuid) ..
                    " observer=" .. tostring(observer ~= nil) ..
                    " target=" .. tostring(npcData.departureTargetX) .. "," .. tostring(npcData.departureTargetY) ..
                    "," .. tostring(npcData.departureTargetZ),
                true
            )
        end
        return false, 0, 0, "no_direction"
    end

    return true, dx, dy, nil
end
