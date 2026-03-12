-- ==============================================================================
-- Behavior_Trading.lua
-- Handles the live trading state while the NPC is available to interact with.
-- ==============================================================================

DTNPCLogic = DTNPCLogic or {}
DTNPCLogic.Behaviors = DTNPCLogic.Behaviors or {}

DTNPCLogic.Behaviors["Trading"] = function(zombie, npcData, target, dist)
    if not zombie:isUseless() then
        zombie:setUseless(true)
        zombie:setPath2(nil)
        zombie:setRunning(false)
    end

    zombie:setVariable("bMoving", false)
    zombie:setVariable("Speed", 0.0)

    if target and dist < 10 then
        zombie:faceLocation(target:getX(), target:getY())
    end

    if zombie:isMoving() then
        zombie:setX(zombie:getX())
        zombie:setY(zombie:getY())
    end
end
