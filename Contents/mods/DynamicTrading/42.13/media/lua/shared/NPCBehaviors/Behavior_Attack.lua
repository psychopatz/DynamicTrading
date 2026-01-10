-- ==============================================================================
-- Behavior_Attack.lua
-- Handles the logic when the NPC turns hostile (Betrayal).
-- ==============================================================================

MyNPCLogic = MyNPCLogic or {}
MyNPCLogic.Behaviors = MyNPCLogic.Behaviors or {}

MyNPCLogic.Behaviors["Attack"] = function(zombie, brain, target, dist)
    
    -- 1. ENABLE ZOMBIE AI (Release the Beast)
    -- When 'isUseless' is true, the NPC is a puppet we control.
    -- When 'isUseless' is false, it acts like a normal Zombie (Bites/Attacks).
    if zombie:isUseless() then
        zombie:setUseless(false)
        
        -- Optional: Buff stats slightly when angry
        zombie:setSpeedMod(1.1) 
        zombie:DoZombieStats() -- Refresh stats
        
        -- Play a sound effect or text overhead (Client side only usually, but safe here)
        zombie:setSitAgainstWall(false) -- Force them up if sitting
    end

    -- 2. TARGET LOCKING
    if target then
        -- Force the engine to recognize the player as the priority target
        zombie:setTarget(target)
        
        -- 3. CHASE LOGIC
        -- If the player is running away, make the NPC sprint.
        local shouldRun = (dist > 3.0) or target:isRunning() or target:isSprinting()
        zombie:setRunning(shouldRun)
        
        -- 4. ANTI-STUCK
        -- If the NPC loses path, point them at the player
        if not zombie:isMoving() and dist > 1.5 then
             zombie:pathToLocation(target:getX(), target:getY(), target:getZ())
        end
        
    else
        -- If target is lost (dead or disconnected), wander aggressively
        -- The base zombie AI will usually hunt for fresh meat automatically if Useless is false.
        if not zombie:isMoving() then
            zombie:setRunning(true)
        end
    end
end