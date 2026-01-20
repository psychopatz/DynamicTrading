-- ==============================================================================
-- Behavior_AttackRange.lua
-- Handles "Ranged Combat" logic.
-- REWRITTEN: Animation Fixes, Slower Kiting speeds, and Rotation Alignment.
-- Build 42 Compatible.
-- ==============================================================================

DTNPCLogic = DTNPCLogic or {}
DTNPCLogic.Behaviors = DTNPCLogic.Behaviors or {}

-- DISTANCE CONFIG
local KITE_DIST_MIN = 3.5
local KITE_DIST_MAX = 8.0
local MAX_RANGE = 14.0

-- SPEED CONFIG
-- Slower speeds to prevent sliding/jittering during combat
local SPEED_FWD = 0.055 -- Advancing
local SPEED_BCK = 0.035 -- Backpedaling (Kiting)

-- COMBAT CONFIG
local REACTION_DELAY = 30
local FIRE_RATE = 90

local ACCURACY_STILL = 25
local ACCURACY_MOVE = 10

local DAMAGE_MIN = 10
local DAMAGE_MAX = 25

-- ==============================================================================
-- 1. UTILITIES
-- ==============================================================================

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

-- ==============================================================================
-- 2. ANIMATION HANDLERS
-- ==============================================================================

local function forceCombatAnim(zombie, isMoving)
    if isMoving then
        zombie:setVariable("bMoving", true)
        zombie:setVariable("isMoving", true)
        
        -- Force standard shamble "1". 
        -- Note: If moving backwards, this will look like a "Moonwalk" because 
        -- zombies lack a backward-walk anim, but it keeps the legs moving.
        zombie:setVariable("WalkType", "1") 
        
        -- Force speed to ensure legs cycle
        zombie:setVariable("Speed", 1.0)
        zombie:setRunning(false)
    else
        -- Aiming Stance (Idle)
        zombie:setVariable("bMoving", false)
        zombie:setVariable("isMoving", false)
        zombie:setVariable("Speed", 0.0)
        zombie:setRunning(false)
    end
end

-- ==============================================================================
-- 3. BEHAVIOR LOGIC
-- ==============================================================================

DTNPCLogic.Behaviors["AttackRange"] = function(zombie, brain, target, dist)

    -- 1. Force safety
    if not zombie:isUseless() then
        zombie:setUseless(true)
        zombie:setPath2(nil)
    end

    if not target or target:isDead() then
        brain.state = "Stay"
        print("[DTNPC] Target dead. Standing down.")
        -- Reset anim
        zombie:setVariable("bMoving", false)
        return
    end

    local zx, zy, zz = zombie:getX(), zombie:getY(), zombie:getZ()
    local tx, ty = target:getX(), target:getY()
    
    -- 2. Calculate Direction to Target
    local dx = tx - zx
    local dy = ty - zy
    local len = math.sqrt(dx * dx + dy * dy)
    
    if len > 0 then
        dx = dx / len
        dy = dy / len
    end

    -- 3. ROTATION (Apply FIRST)
    -- In combat, we ALWAYS face the target, even if backing up.
    local dirVector = zombie:getForwardDirection()
    if dirVector then
        dirVector:set(dx, dy)
        dirVector:normalize()
    end

    -- 4. Kiting Logic (Movement Decision)
    if not brain.reactionTimer then brain.reactionTimer = 0 end

    local moveDir = 0 -- 0=Stop, 1=Forward, -1=Backward
    local currentSpeed = 0
    
    if len < KITE_DIST_MIN then
        -- Too close! Back up.
        brain.reactionTimer = brain.reactionTimer + 1
        if brain.reactionTimer > REACTION_DELAY then
            moveDir = -1
            currentSpeed = SPEED_BCK
        else
            moveDir = 0 -- Pausing before reacting
        end
        
    elseif len > KITE_DIST_MAX then
        -- Too far! Advance.
        brain.reactionTimer = 0
        moveDir = 1
        currentSpeed = SPEED_FWD
    else
        -- Sweet spot. Stand ground and aim.
        brain.reactionTimer = 0
        moveDir = 0
    end

    -- 5. Calculate Next Position
    local isMoving = false
    if moveDir ~= 0 then
        local nextX = zx + (dx * currentSpeed * moveDir)
        local nextY = zy + (dy * currentSpeed * moveDir)
        
        if isTileSafe(nextX, nextY, zz) then
            -- Apply Movement
            forceCombatAnim(zombie, true)
            zombie:setX(nextX)
            zombie:setY(nextY)
            isMoving = true
        else
            -- Blocked (Wall behind or in front)
            forceCombatAnim(zombie, false)
        end
    else
        forceCombatAnim(zombie, false)
    end

    -- 6. Range Check for Firing
    if len > MAX_RANGE then
        return 
    end

    -- 7. Firing Logic
    if not brain.attackTimer then brain.attackTimer = 0 end
    brain.attackTimer = brain.attackTimer + 1

    if brain.attackTimer >= FIRE_RATE then
        brain.attackTimer = 0 
        
        -- Use pcall to prevent crashes during combat calcs
        pcall(function()
            zombie:getEmitter():playSound("DT_GunRandom") 
            
            local hitChance = ACCURACY_STILL
            if isMoving then
                hitChance = ACCURACY_MOVE
            end

            -- Simple RNG Hit calculation
            if ZombRand(100) < hitChance then
                if instanceof(target, "IsoPlayer") then
                    -- PVP / Betrayal Damage
                    local bodyDamage = target:getBodyDamage()
                    local bodyPart = bodyDamage:getBodyPart(BodyPartType.Torso_Upper)
                    
                    local dmg = ZombRand(DAMAGE_MIN, DAMAGE_MAX)
                    bodyPart:AddDamage(dmg)
                    
                    -- Add bullet hole/bleeding
                    bodyPart:setHaveBullet(true, 0)
                    bodyPart:setBleedingTime(20)
                    bodyDamage:Update()
                    
                    target:getEmitter():playSound("ImpactFlesh")
                    target:setHitReaction("HitReaction")
                    
                elseif instanceof(target, "IsoZombie") then
                    -- Zombie vs Zombie Damage
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