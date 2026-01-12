-- ==============================================================================
-- Behavior_Guard.lua
-- Handles the logic for the "Stay" or "Guard" command.
-- Build 42 Compatible.
-- ==============================================================================

DTNPCLogic = DTNPCLogic or {}
DTNPCLogic.Behaviors = DTNPCLogic.Behaviors or {}

DTNPCLogic.Behaviors["Stay"] = function(zombie, brain, target, dist)
    
    if not zombie:isUseless() then
        zombie:setUseless(true)
        zombie:setPath2(nil)
        zombie:setRunning(false)
    end
    
    -- Stop animation
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