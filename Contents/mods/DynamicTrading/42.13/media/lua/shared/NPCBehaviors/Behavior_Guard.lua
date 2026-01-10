-- ==============================================================================
-- Behavior_Guard.lua
-- Handles the logic for the "Stay" or "Guard" command.
-- ==============================================================================

MyNPCLogic = MyNPCLogic or {}
MyNPCLogic.Behaviors = MyNPCLogic.Behaviors or {}

MyNPCLogic.Behaviors["Stay"] = function(zombie, brain, target, dist)
    
    -- 1. FREEZE LOGIC
    -- We want them to hold position.
    
    -- If AI is still active, shut it down immediately.
    if not zombie:isUseless() then
        zombie:setUseless(true)
        zombie:setPath2(nil) -- Cancel any walking path
        zombie:setRunning(false)
    end
    
    -- 2. IMMERSION: WATCH THE MASTER
    -- If the master is nearby, face them.
    if target and dist < 10 then
        -- This updates their rotation without moving their feet
        zombie:faceLocation(target:getX(), target:getY())
    end

    -- 3. SAFETY CHECKS
    -- Ensure they don't slide if pushed
    if zombie:isMoving() then
        -- Force stop if they somehow have momentum
        zombie:setX(zombie:getX())
        zombie:setY(zombie:getY())
    end
end