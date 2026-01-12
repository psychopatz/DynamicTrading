-- ==============================================================================
-- Behavior_AttackRange.lua
-- Handles "Ranged Combat" logic.
-- Build 42 Compatible.
-- ==============================================================================

DTNPCLogic = DTNPCLogic or {}
DTNPCLogic.Behaviors = DTNPCLogic.Behaviors or {}

local KITE_DIST_MIN = 3.5
local KITE_DIST_MAX = 8.0
local MAX_RANGE = 14.0

local MOVE_SPEED_FWD = 0.07
local MOVE_SPEED_BCK = 0.05

local REACTION_DELAY = 30
local FIRE_RATE = 90

local ACCURACY_STILL = 25
local ACCURACY_MOVE = 10

local DAMAGE_MIN = 10
local DAMAGE_MAX = 25

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

local function forceAnim(zombie, isMoving)
    if isMoving then
        zombie:setVariable("bMoving", true)
        zombie:setVariable("Speed", 1.0)
        zombie:setVariable("WalkType", "Run")
        zombie:setVariable("BanditWalkType", "Run")
    else
        zombie:setVariable("bMoving", false)
        zombie:setVariable("Speed", 0.0)
    end
end

DTNPCLogic.Behaviors["AttackRange"] = function(zombie, brain, target, dist)

    if not zombie:isUseless() then
        zombie:setUseless(true)
        zombie:setPath2(nil)
    end

    if not target or target:isDead() then
        brain.state = "Stay"
        print("[DTNPC] Target dead. Standing down.")
        return
    end

    local zx, zy, zz = zombie:getX(), zombie:getY(), zombie:getZ()
    local tx, ty = target:getX(), target:getY()
    
    local dx = tx - zx
    local dy = ty - zy
    local len = math.sqrt(dx * dx + dy * dy)
    
    if len > 0 then
        dx = dx / len
        dy = dy / len
    end

    if not brain.reactionTimer then brain.reactionTimer = 0 end

    local moveDir = 0
    local currentSpeed = 0
    
    if len < KITE_DIST_MIN then
        brain.reactionTimer = brain.reactionTimer + 1
        
        if brain.reactionTimer > REACTION_DELAY then
            moveDir = -1
            currentSpeed = MOVE_SPEED_BCK
        else
            moveDir = 0
        end
        
    elseif len > KITE_DIST_MAX then
        brain.reactionTimer = 0
        moveDir = 1
        currentSpeed = MOVE_SPEED_FWD
    else
        brain.reactionTimer = 0
        moveDir = 0
    end

    local isMoving = false
    if moveDir ~= 0 then
        local nextX = zx + (dx * currentSpeed * moveDir)
        local nextY = zy + (dy * currentSpeed * moveDir)
        
        if isTileSafe(nextX, nextY, zz) then
            zombie:setX(nextX)
            zombie:setY(nextY)
            isMoving = true
        end
    end
    
    forceAnim(zombie, isMoving)

    local fd = zombie:getForwardDirection()
    if fd then 
        fd:set(dx, dy)
        fd:normalize()
    end

    if len > MAX_RANGE then
        return 
    end

    if not brain.attackTimer then brain.attackTimer = 0 end
    brain.attackTimer = brain.attackTimer + 1

    if brain.attackTimer >= FIRE_RATE then
        brain.attackTimer = 0 
        
        pcall(function()
            zombie:getEmitter():playSound("M9Fire") 
            
            local hitChance = ACCURACY_STILL
            if isMoving then
                hitChance = ACCURACY_MOVE
            end

            if ZombRand(100) < hitChance then
                if instanceof(target, "IsoPlayer") then
                    local bodyDamage = target:getBodyDamage()
                    local bodyPart = bodyDamage:getBodyPart(BodyPartType.Torso_Upper)
                    
                    local dmg = ZombRand(DAMAGE_MIN, DAMAGE_MAX)
                    bodyPart:AddDamage(dmg)
                    
                    bodyPart:setHaveBullet(true, 0)
                    bodyPart:setBleedingTime(20)
                    bodyDamage:Update()
                    
                    target:getEmitter():playSound("ImpactFlesh")
                    target:setHitReaction("HitReaction")
                    
                elseif instanceof(target, "IsoZombie") then
                    target:setHealth(target:getHealth() - 0.4)
                    target:getEmitter():playSound("ZombieImpact")
                    
                    if target:getHealth() <= 0 then
                        target:Kill(zombie)
                    else
                        target:setHitReaction("HitReaction")
                    end
                end
            end
        end)
    end
end