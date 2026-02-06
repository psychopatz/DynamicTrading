-- ==============================================================================
-- Behavior_Attack.lua
-- Handles the logic when the NPC turns hostile (Betrayal).
-- Build 42 Compatible.
-- ==============================================================================

DTNPCLogic = DTNPCLogic or {}
DTNPCLogic.Behaviors = DTNPCLogic.Behaviors or {}

DTNPCLogic.Behaviors["Attack"] = function(zombie, brain, target, dist)
    
    if zombie:isUseless() then
        zombie:setUseless(false)
        zombie:setSpeedMod(1.1) 
        zombie:DoZombieStats()
        zombie:setSitAgainstWall(false)
    end

    if target then
        zombie:setTarget(target)
        
        local shouldRun = (dist > 3.0) or target:isRunning() or target:isSprinting()
        zombie:setRunning(shouldRun)
        
        if not zombie:isMoving() and dist > 1.5 then
             zombie:pathToLocation(target:getX(), target:getY(), target:getZ())
        end
        
    else
        if not zombie:isMoving() then
            zombie:setRunning(true)
        end
    end
end