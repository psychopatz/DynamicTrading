-- ==============================================================================
-- Behavior_Follow.lua
-- Handles the logic for following the Master.
-- ==============================================================================

MyNPCLogic = MyNPCLogic or {}
MyNPCLogic.Behaviors = MyNPCLogic.Behaviors or {}

MyNPCLogic.Behaviors["Follow"] = function(zombie, brain, target, dist)
    
    -- If we have no master to follow, do nothing
    if not target then return end

    -- 1. TELEPORT CATCH-UP (Anti-Despawn)
    -- If the player drove away or ran too fast, warp the NPC to them.
    if dist > 50 then
        zombie:setX(target:getX())
        zombie:setY(target:getY())
        zombie:setZ(target:getZ())
        zombie:setPath2(nil)
        return
    end

    local stopDistance = 2.5
    
    -- 2. MOVEMENT LOGIC
    if dist > stopDistance then
        
        -- A. Activate AI
        -- We need the AI active ('useless' = false) so the pathfinder works.
        if zombie:isUseless() then zombie:setUseless(false) end
        
        -- B. Pacify
        -- Prevent them from getting distracted by corpses or other zombies while following.
        zombie:setTarget(nil)
        zombie:setAttackedBy(nil)
        zombie:setEatBodyTarget(nil, false)
        
        -- C. Calculate Path
        local tx = target:getX()
        local ty = target:getY()
        local tz = target:getZ()
        
        -- Run if far away OR if the player is hurrying
        local isRunning = (dist > 6.0) or target:isRunning() or target:isSprinting()
        
        -- D. Optimization
        -- Only recalculate the path if the target moved significantly (> 2 tiles) 
        -- or if the NPC has stopped moving for some reason.
        if not zombie:isMoving() or not brain.lastTargetX or 
           math.abs(brain.lastTargetX - tx) > 2.0 or 
           math.abs(brain.lastTargetY - ty) > 2.0 then
           
            zombie:setRunning(isRunning)
            zombie:pathToLocation(tx, ty, tz)
            
            -- Save where we last told them to go
            brain.lastTargetX = tx
            brain.lastTargetY = ty
        end
        
    else
        -- 3. STOPPING LOGIC
        -- We are close enough (<= 2.5 tiles).
        
        -- Freeze them ('useless' = true) so they don't wander.
        if not zombie:isUseless() then
            zombie:setPath2(nil) -- Clear current path
            zombie:setUseless(true)
            zombie:setRunning(false)
        end
        
        -- Manually face the player to look attentive
        zombie:faceLocation(target:getX(), target:getY())
    end
    
    -- 4. HOUSEKEEPING
    -- If we are following, we shouldn't have any manual "Go To" tasks queued.
    brain.tasks = {} 
end