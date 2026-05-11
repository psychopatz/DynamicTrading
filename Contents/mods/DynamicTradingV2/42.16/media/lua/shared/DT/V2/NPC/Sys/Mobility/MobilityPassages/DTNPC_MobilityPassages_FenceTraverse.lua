-- ==============================================================================
-- DTNPC_MobilityPassages_FenceTraverse.lua
-- Fence traversal state and execution for NPC mobility.
-- ==============================================================================

DTNPCMobility = DTNPCMobility or {}

local Mobility = DTNPCMobility
local Internal = Mobility.Internal or {}

Mobility.Internal = Internal

function Mobility.ShouldEngageFenceTraverse(zombie, npcData, fence, options)
    if not zombie or type(npcData) ~= "table" or not fence then
        return false, "invalid"
    end

    options = type(options) == "table" and options or {}
    local currentTime = Internal.getTimeMs()
    local cooldownUntil = tonumber(npcData._dtFenceCooldownUntil) or 0
    if cooldownUntil > 0 and currentTime < cooldownUntil then
        return false, "cooldown"
    end

    local fenceKey = fence.fenceKey or Internal.getFencePendingKey(fence)
    if Internal.isFenceRejected(npcData, fenceKey) then
        return false, "rejected"
    end

    local landingSquare = fence.landingSquare
    if not landingSquare then
        Internal.setFenceReject(npcData, fenceKey, 320)
        return false, "no_landing"
    end

    local landingX, landingY, landingZ = Internal.getSquareCoords(landingSquare)
    local landingWorldX = landingX ~= nil and (landingX + 0.5) or nil
    local landingWorldY = landingY ~= nil and (landingY + 0.5) or nil
    if landingWorldX == nil or landingWorldY == nil or not Mobility.IsTileSafe(landingWorldX, landingWorldY, landingZ or zombie:getZ()) then
        Internal.setFenceReject(npcData, fenceKey, 320)
        return false, "unsafe_landing"
    end
    if not Internal.isWithinLeash(landingWorldX, landingWorldY, landingZ or zombie:getZ(), options) then
        Internal.setFenceReject(npcData, fenceKey, 260)
        return false, "leash"
    end

    local fenceX = tonumber(fence.x)
    local fenceY = tonumber(fence.y)
    local fenceCenterX = fenceX ~= nil and (fenceX + 0.5) or zombie:getX()
    local fenceCenterY = fenceY ~= nil and (fenceY + 0.5) or zombie:getY()
    local engageDistance = tonumber(options.fenceEngageDistance) or (fence.tall == true and 1.18 or 1.05)
    if Internal.getDistance(zombie:getX(), zombie:getY(), fenceCenterX, fenceCenterY) > engageDistance then
        return false, "too_far"
    end

    local dirX = tonumber(fence.dirX) or tonumber(options.dirX) or 0
    local dirY = tonumber(fence.dirY) or tonumber(options.dirY) or 0
    local toLandingX = landingWorldX - zombie:getX()
    local toLandingY = landingWorldY - zombie:getY()
    local landingLen = math.sqrt((toLandingX * toLandingX) + (toLandingY * toLandingY))
    if landingLen <= 0.001 then
        Internal.setFenceReject(npcData, fenceKey, 220)
        return false, "no_delta"
    end

    local dot = ((toLandingX / landingLen) * dirX) + ((toLandingY / landingLen) * dirY)
    if dot < 0.25 then
        Internal.setFenceReject(npcData, fenceKey, 220)
        return false, "wrong_side"
    end

    return true, "ok"
end

function Mobility.BeginFenceTraverse(zombie, npcData, fence, options)
    if not zombie or type(npcData) ~= "table" or not fence then
        return false, nil
    end

    local allowed, reason = Mobility.ShouldEngageFenceTraverse(zombie, npcData, fence, options)
    if not allowed then
        return false, reason
    end

    options = type(options) == "table" and options or {}
    local landingSquare = fence.landingSquare
    local landingX, landingY, landingZ = Internal.getSquareCoords(landingSquare)
    local worldX = (landingX or zombie:getX()) + 0.5
    local worldY = (landingY or zombie:getY()) + 0.5
    local worldZ = landingZ or zombie:getZ()
    local currentTime = Internal.getTimeMs()
    local animName = fence.tall and "DTNPCClimbFenceTall" or "DTNPCClimbFence"
    local travelDurationMs = fence.tall and 900 or 600
    local finishHoldMs = fence.tall and 420 or 320
    local actionDurationMs = travelDurationMs + finishHoldMs + 250

    npcData._dtFencePendingKey = fence.fenceKey or Internal.getFencePendingKey(fence)
    npcData._dtFencePendingAt = currentTime
    npcData._dtFenceRejectKey = nil
    npcData._dtFenceRejectUntil = nil

    if zombie.setTarget then
        zombie:setTarget(nil)
    end
    if zombie.setPath2 then
        zombie:setPath2(nil)
    end
    if not zombie:isUseless() then
        zombie:setUseless(true)
    end
    if zombie.setRunning then
        zombie:setRunning(false)
    end
    Internal.resetFenceAnimFinished(zombie)
    zombie:faceLocation((tonumber(fence.x) or zombie:getX()) + 0.5, (tonumber(fence.y) or zombie:getY()) + 0.5)
    if zombie.setBumpType then
        zombie:setBumpType(animName)
    end

    npcData._dtFenceTraverse = {
        startX = zombie:getX(),
        startY = zombie:getY(),
        startZ = zombie:getZ(),
        endX = worldX,
        endY = worldY,
        endZ = worldZ,
        startedAt = currentTime,
        durationMs = actionDurationMs,
        travelDurationMs = travelDurationMs,
        finishHoldMs = finishHoldMs,
        finishReadyAt = currentTime + travelDurationMs + finishHoldMs,
        bumpType = animName,
        tall = fence.tall == true,
        fenceKey = npcData._dtFencePendingKey,
    }

    npcData.isMovingState = false
    npcData.attackTimer = 0
    npcData.reactionTimer = 0
    Internal.rememberMotion(npcData, zombie:getX(), zombie:getY(), worldX, worldY, {
        speed = 0.085,
        isRunning = false,
        crawl = false,
        durationMs = travelDurationMs,
    })
    if Mobility.ResetMovementProgress then
        Mobility.ResetMovementProgress(npcData)
    end
    Mobility.StartSpecialAction(npcData, "fence", actionDurationMs, {
        mode = fence.tall and "tall" or "low",
        cooldownMs = fence.tall and 450 or 320,
    })
    return true, "fence"
end

function Mobility.TryTraverseFence(zombie, npcData, fromSquare, nextSquare, options)
    if not zombie or type(npcData) ~= "table" then
        return false, nil
    end

    local active = Mobility.IsSpecialActionActive and Mobility.IsSpecialActionActive(npcData)
    if active then
        return true, "special_action"
    end

    local collided = false
    if zombie.isCollidedWithDoor and zombie:isCollidedWithDoor() then
        collided = true
    elseif zombie.isCollidedThisFrame and zombie:isCollidedThisFrame() then
        collided = true
    elseif zombie.isCollided and zombie:isCollided() then
        collided = true
    end
    local blockedTicks = options and options.blockCounterKey and tonumber(npcData[options.blockCounterKey]) or 0
    if not collided and blockedTicks < 1 then
        return false, nil
    end

    local fence = Mobility.FindFenceAhead(zombie, npcData, {
        dirX = options and options.dirX,
        dirY = options and options.dirY,
        fromSquare = fromSquare,
        midSquare = nextSquare,
        originX = zombie:getX(),
        originY = zombie:getY(),
        originZ = zombie:getZ(),
    }) or Mobility.FindFenceBetween(fromSquare, nextSquare)

    if not fence then
        npcData._dtFencePendingKey = nil
        npcData._dtFencePendingAt = nil
        return false, nil
    end

    if not fence.fenceKey then
        fence.fenceKey = Internal.getFencePendingKey(fence)
    end
    if not fence.landingSquare then
        local cell = getCell and getCell() or nil
        fence.landingSquare = Internal.resolveFenceLandingSquare(
            cell,
            fence,
            zombie:getX(),
            zombie:getY(),
            zombie:getZ(),
            tonumber(options and options.dirX) or 0,
            tonumber(options and options.dirY) or 0
        )
    end
    fence.dirX = tonumber(options and options.dirX) or fence.dirX
    fence.dirY = tonumber(options and options.dirY) or fence.dirY
    return Mobility.BeginFenceTraverse(zombie, npcData, fence, options)
end

function Mobility.UpdateSpecialAction(zombie, npcData)
    if not zombie or type(npcData) ~= "table" then
        return false, nil
    end

    local kind = npcData._dtSpecialAction
    if kind ~= "fence" then
        return false, nil
    end

    local traverse = type(npcData._dtFenceTraverse) == "table" and npcData._dtFenceTraverse or nil
    if not traverse then
        Mobility.ClearSpecialAction(npcData, "fence")
        return false, nil
    end

    local currentTime = Internal.getTimeMs()
    local startedAt = tonumber(traverse.startedAt) or currentTime
    local durationMs = math.max(1, tonumber(traverse.durationMs) or 1)
    local travelDurationMs = math.max(1, tonumber(traverse.travelDurationMs) or durationMs)
    local progress = math.max(0, math.min(1, (currentTime - startedAt) / travelDurationMs))
    local eased = nil
    if progress < 0.5 then
        eased = 2 * progress * progress
    else
        local inverse = (-2 * progress) + 2
        eased = 1 - ((inverse * inverse) * 0.5)
    end
    local nextX = (tonumber(traverse.startX) or zombie:getX()) + (((tonumber(traverse.endX) or zombie:getX()) - (tonumber(traverse.startX) or zombie:getX())) * eased)
    local nextY = (tonumber(traverse.startY) or zombie:getY()) + (((tonumber(traverse.endY) or zombie:getY()) - (tonumber(traverse.startY) or zombie:getY())) * eased)
    local nextZ = tonumber(traverse.endZ) or zombie:getZ()

    if not zombie:isUseless() then
        zombie:setUseless(true)
    end
    if zombie.setPath2 then
        zombie:setPath2(nil)
    end
    if zombie.setTarget then
        zombie:setTarget(nil)
    end
    zombie:setX(nextX)
    zombie:setY(nextY)
    zombie:setZ(nextZ)
    zombie:faceLocation(tonumber(traverse.endX) or nextX, tonumber(traverse.endY) or nextY)
    Mobility.Stop(zombie, { idleState = "0" })

    if progress >= 1 then
        zombie:setX(tonumber(traverse.endX) or nextX)
        zombie:setY(tonumber(traverse.endY) or nextY)
        zombie:setZ(nextZ)
        local finishReadyAt = tonumber(traverse.finishReadyAt) or (startedAt + travelDurationMs)
        local finishHoldReached = currentTime >= finishReadyAt
        if (finishHoldReached and Internal.isFenceAnimFinished(zombie)) or (currentTime - startedAt) >= durationMs then
            npcData._dtFenceTraverse = nil
            npcData._dtFencePendingKey = nil
            npcData._dtFencePendingAt = nil
            Internal.resetFenceAnimFinished(zombie)
            if Mobility.ResetMovementProgress then
                Mobility.ResetMovementProgress(npcData)
            end
            Mobility.ClearSpecialAction(npcData, "fence")
            return false, "completed"
        end
        return true, "fence_finish"
    end

    return true, "fence"
end
