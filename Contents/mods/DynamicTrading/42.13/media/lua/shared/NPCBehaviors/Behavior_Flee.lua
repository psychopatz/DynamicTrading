-- ==============================================================================
-- Behavior_Flee.lua
-- Handles "Fleeing" and "Merchant Leaving" logic.
-- UPDATED: Implements BANDIT-STYLE "Continuous Target Suppression".
-- ==============================================================================

MyNPCLogic = MyNPCLogic or {}
MyNPCLogic.Behaviors = MyNPCLogic.Behaviors or {}

local function getFleeVector(zombie, target)
    local dx = zombie:getX() - target:getX()
    local dy = zombie:getY() - target:getY()
    local length = math.sqrt(dx * dx + dy * dy)
    if length == 0 then return 1, 0 end 
    return dx / length, dy / length
end

local function getValidFleeDest(zombie, vx, vy)
    local cell = getCell()
    local startX, startY, z = zombie:getX(), zombie:getY(), zombie:getZ()
    -- Try distances: 30, 15, 5
    local tryDistances = {30, 15, 5}
    for _, dist in ipairs(tryDistances) do
        local tx = startX + (vx * dist)
        local ty = startY + (vy * dist)
        local sq = cell:getGridSquare(tx, ty, z)
        if sq and sq:isFree(false) then
            return tx, ty
        end
    end
    return startX + (vx * 2), startY + (vy * 2)
end

MyNPCLogic.Behaviors["Flee"] = function(zombie, brain, target, dist)
    
    -- 1. BANDIT TRICK: CONTINUOUS BLINDNESS
    -- We run this EVERY TICK. The zombie AI tries to re-target you every frame.
    -- We force it to nil immediately, effectively blinding the combat AI.
    zombie:setTarget(nil)
    zombie:setAttackedBy(nil)
    zombie:setEatBodyTarget(nil, false)
    
    -- 2. ENABLE AI (Required for walking)
    if zombie:isUseless() then zombie:setUseless(false) end

    -- 3. SPEED CONTROL
    -- Use variable speed. Walk if close (to avoid lunge), Run if far.
    if dist < 3.0 then
        zombie:setRunning(false) -- Walk to disengage safely
    else
        zombie:setRunning(true)  -- Sprint once clear
    end

    -- 4. EMERGENCY PUSH
    -- If they are practically hugging you, the Pathfinder fails. Push them slightly.
    if dist < 0.8 and target then
        local vx, vy = getFleeVector(zombie, target)
        zombie:setX(zombie:getX() + (vx * 0.2))
        zombie:setY(zombie:getY() + (vy * 0.2))
    end

    -- 5. DESTINATION LOGIC
    local needsUpdate = false
    if not brain.fleeDestX or not brain.fleeDestY then needsUpdate = true end
    if not zombie:isMoving() then needsUpdate = true end

    -- Re-calculate path if blocked or finished
    if needsUpdate and target then
        local vx, vy = getFleeVector(zombie, target)
        local tx, ty = getValidFleeDest(zombie, vx, vy)
        
        brain.fleeDestX = tx
        brain.fleeDestY = ty
        
        zombie:pathToLocation(tx, ty, zombie:getZ())
    end

    -- 6. MERCHANT DESPAWN
    if dist > 35 then
        if MyNPCManager then MyNPCManager.Unregister(zombie) end
        zombie:removeFromWorld()
        zombie:removeFromSquare()
        print("[MyNPC] Merchant has left the map.")
    end
end