-- ==============================================================================
-- DTNPC_Logic_Anchor.lua
-- Anchor stabilization for stationary NPC states.
-- ==============================================================================

DTNPCLogic = DTNPCLogic or {}
DTNPCLogic.Internal = DTNPCLogic.Internal or {}

local Internal = DTNPCLogic.Internal

function DTNPCLogic.ApplyAnchorStabilization(zombie, npcData, state)
    local isActiveGuardState = state == "Guard"
        and npcData
        and (
            npcData.combatTargetID ~= nil
            or npcData.guardReturningToPost == true
            or npcData.isMovingState == true
            or npcData.companionCombatActive == true
        )

    local isStationaryState = state == "Stay"
        or state == "Idle"
        or state == "Trading"
        or state == "Bandage"
        or (state == "Guard" and not isActiveGuardState)

    if isStationaryState then
        zombie:setPath2(nil)
        zombie:setTarget(nil)

        if not npcData.anchorX then
            npcData.anchorX = zombie:getX()
            npcData.anchorY = zombie:getY()
            npcData.anchorZ = zombie:getZ()
            if DTNPC_DEBUG_ANCHOR then
                DynamicTrading.Log(
                    "DTV2",
                    "NPC",
                    "Anchor",
                    "Set anchor for "
                        .. (npcData.name or "NPC")
                        .. " at "
                        .. math.floor(npcData.anchorX)
                        .. ","
                        .. math.floor(npcData.anchorY)
                )
            end
        end

        local dx = math.abs(zombie:getX() - npcData.anchorX)
        local dy = math.abs(zombie:getY() - npcData.anchorY)
        local nowHours = getGameTime() and getGameTime():getWorldAgeHours() or 0
        local lastSnap = npcData.anchorLastSnapTime or 0

        if (dx > Internal.ANCHOR_DRIFT_TOLERANCE or dy > Internal.ANCHOR_DRIFT_TOLERANCE)
            and ((nowHours - lastSnap) >= Internal.ANCHOR_SNAP_COOLDOWN_HOURS) then
            if DTNPC_DEBUG_ANCHOR then
                DynamicTrading.Log(
                    "DTV2",
                    "NPC",
                    "Anchor",
                    "NPC " .. (npcData.name or "Unknown") .. " drifted from anchor. Snapping back."
                )
            end
            zombie:setX(npcData.anchorX)
            zombie:setY(npcData.anchorY)
            zombie:setZ(npcData.anchorZ)
            npcData.anchorLastSnapTime = nowHours
        end
        return
    end

    npcData.anchorX = nil
    npcData.anchorY = nil
    npcData.anchorZ = nil
    npcData.anchorLastSnapTime = nil
end
