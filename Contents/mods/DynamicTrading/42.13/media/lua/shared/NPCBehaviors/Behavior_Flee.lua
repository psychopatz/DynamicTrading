-- ==============================================================================
-- Behavior_Flee.lua
-- Handles "Fleeing" and "Merchant Leaving" logic.
-- Build 42 Compatible.
-- ==============================================================================

DTNPCLogic = DTNPCLogic or {}
DTNPCLogic.Behaviors = DTNPCLogic.Behaviors or {}

local DESPAWN_DIST = 35

local function getDist(x1, y1, x2, y2)
    local dx = x1 - x2
    local dy = y1 - y2
    return math.sqrt(dx * dx + dy * dy)
end

local function isTileSafe(x, y, z)
    local cell = getCell()
    local sq = cell:getGridSquare(x, y, z)
    if not sq then return true end
    if not sq:isFree(false) then return false end
    if sq:isSolid() or sq:isSolidTrans() then return false end
    return true
end

local function forceRunAnimation(zombie)
    zombie:setVariable("bMoving", true)
    zombie:setVariable("Speed", 1.0)
    zombie:setVariable("WalkType", "Run")
    zombie:setVariable("isMoving", true)
    zombie:setVariable("BanditWalkType", "Run")
end

DTNPCLogic.Behaviors["Flee"] = function(zombie, brain, target, dist)
    
    if not zombie:isUseless() then
        zombie:setUseless(true)
        zombie:setPath2(nil)
        zombie:setRunning(false)
    end

    if dist > DESPAWN_DIST then
        if isClient() then
            -- Send command to server to unregister/delete
             local id = zombie:getPersistentOutfitID()
             sendClientCommand(getPlayer(), "DTNPC", "RemoveNPC", { id = id })
             
             -- Remove locally immediately
             zombie:removeFromWorld()
             zombie:removeFromSquare()
        elseif DTNPCManager then 
             DTNPCManager.Unregister(zombie)
             zombie:removeFromWorld()
             zombie:removeFromSquare()
        end
        print("[DTNPC] " .. (brain.name or "NPC") .. " has escaped safely.")
        return
    end

    local dx, dy = 0, 0
    local zx, zy = zombie:getX(), zombie:getY()

    if target then
        dx = zx - target:getX()
        dy = zy - target:getY()
        
        local len = math.sqrt(dx * dx + dy * dy)
        if len > 0 then
            dx = dx / len
            dy = dy / len
        end
        
        brain.lastFleeX = dx
        brain.lastFleeY = dy
    elseif brain.lastFleeX then
        dx = brain.lastFleeX
        dy = brain.lastFleeY
    else
        zombie:setVariable("bMoving", false)
        zombie:setVariable("Speed", 0.0)
        return
    end

    local speed = brain.runSpeed or DTNPC.DefaultRunSpeed
    local nextX = zx + (dx * speed)
    local nextY = zy + (dy * speed)
    local z = zombie:getZ()

    local canMove = isTileSafe(nextX, nextY, z)
    
    if not canMove then
        if isTileSafe(nextX, zy, z) then
            nextY = zy
            canMove = true
        elseif isTileSafe(zx, nextY, z) then
            nextX = zx
            canMove = true
        end
    end

    if canMove then
        zombie:setX(nextX)
        zombie:setY(nextY)
        forceRunAnimation(zombie)
    else
        zombie:setVariable("bMoving", false)
        zombie:setVariable("Speed", 0.0)
    end

    local dirVector = zombie:getForwardDirection()
    if dirVector then
        dirVector:set(dx, dy)
        dirVector:normalize()
    end
end