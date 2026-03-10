-- ==============================================================================
-- Behavior_Trade.lua
-- Handles the logic for the "Trading" state.
-- NPC stays at the trading location and faces potential customers.
-- ==============================================================================

DTNPCLogic = DTNPCLogic or {}
DTNPCLogic.Behaviors = DTNPCLogic.Behaviors or {}

DTNPCLogic.Behaviors["Trading"] = function(zombie, npcData, target, dist)
    
    if not zombie:isUseless() then
        zombie:setUseless(true)
        zombie:setPath2(nil)
        zombie:setRunning(false)
    end
    
    -- Stop animation
    zombie:setVariable("bMoving", false)
    zombie:setVariable("Speed", 0.0)
    
    -- Face player if they are close
    if target and dist < 10 then
        zombie:faceLocation(target:getX(), target:getY())
    end

    -- Force stop if moving
    if zombie:isMoving() then
        zombie:setX(zombie:getX())
        zombie:setY(zombie:getY())
    end
end
