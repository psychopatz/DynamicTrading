-- ==============================================================================
-- Behavior_AttackRange.lua
-- Handles "Ranged Combat" logic.
-- UPDATED: Removed Gun Visuals. Added "Human Error" (Reaction Time + Accuracy Nerf).
-- ==============================================================================

MyNPCLogic = MyNPCLogic or {}
MyNPCLogic.Behaviors = MyNPCLogic.Behaviors or {}

-- COMBAT SETTINGS
local KITE_DIST_MIN = 3.5   -- Back away if closer than this
local KITE_DIST_MAX = 8.0   -- Chase if further than this
local MAX_RANGE     = 14.0  -- Hard limit. Won't shoot if target is further than this.

local MOVE_SPEED_FWD = 0.07 -- Chase speed
local MOVE_SPEED_BCK = 0.05 -- Backpedal speed (Slower than chasing!)

local REACTION_DELAY = 30   -- Ticks (0.5s) to wait before backing up (Grace Period)
local FIRE_RATE      = 90   -- Ticks between shots (1.5s)

local ACCURACY_STILL = 25   -- % Chance to hit when standing still
local ACCURACY_MOVE  = 10   -- % Chance to hit when running (Run & Gun penalty)

-- DAMAGE SETTINGS (Surgery Wounds)
local DAMAGE_MIN = 10
local DAMAGE_MAX = 25

-- Helper: Get distance
local function getDist(x1, y1, x2, y2)
    local dx = x1 - x2
    local dy = y1 - y2
    return math.sqrt(dx * dx + dy * dy)
end

-- Helper: Collision Check
local function isTileSafe(x, y, z)
    local cell = getCell()
    local sq = cell:getGridSquare(x, y, z)
    if not sq then return true end 
    if not sq:isFree(false) then return false end
    if sq:isSolid() or sq:isSolidTrans() then return false end
    return true
end

-- Helper: Force Animation
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

MyNPCLogic.Behaviors["AttackRange"] = function(zombie, brain, target, dist)

    -- 1. FORCE SAFETY
    if not zombie:isUseless() then
        zombie:setUseless(true)
        zombie:setPath2(nil)
    end

    -- 2. TARGET VALIDATION
    if not target or target:isDead() then
        brain.state = "Stay"
        print("[MyNPC] Target dead. Standing down.")
        return
    end

    -- 3. MOVEMENT LOGIC (With Reaction Delay)
    local zx, zy, zz = zombie:getX(), zombie:getY(), zombie:getZ()
    local tx, ty = target:getX(), target:getY()
    
    local dx = tx - zx
    local dy = ty - zy
    local len = math.sqrt(dx * dx + dy * dy)
    
    if len > 0 then
        dx = dx / len
        dy = dy / len
    end

    -- Init Brain Timers
    if not brain.reactionTimer then brain.reactionTimer = 0 end

    local moveDir = 0
    local currentSpeed = 0
    
    -- LOGIC: Determine what the NPC *wants* to do
    if len < KITE_DIST_MIN then
        -- Too Close!
        -- "Grace Period": Don't react instantly. Simulate human realization time.
        brain.reactionTimer = brain.reactionTimer + 1
        
        if brain.reactionTimer > REACTION_DELAY then
            moveDir = -1 -- Move Backward
            currentSpeed = MOVE_SPEED_BCK
        else
            moveDir = 0 -- Stand still (Shock/Thinking phase)
        end
        
    elseif len > KITE_DIST_MAX then
        -- Too Far! Chase immediately (No reaction delay needed for chasing)
        brain.reactionTimer = 0
        moveDir = 1
        currentSpeed = MOVE_SPEED_FWD
    else
        -- Sweet Spot
        brain.reactionTimer = 0
        moveDir = 0
    end

    -- APPLY MOVEMENT
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

    -- 4. ROTATION (Face Target)
    local fd = zombie:getForwardDirection()
    if fd then 
        fd:set(dx, dy)
        fd:normalize()
    end

    -- 5. SHOOTING LOGIC (Dynamic Accuracy)
    
    -- Hard Range Cap: Don't shoot if player is too far (e.g., running away)
    if len > MAX_RANGE then
        return 
    end

    if not brain.attackTimer then brain.attackTimer = 0 end
    brain.attackTimer = brain.attackTimer + 1

    if brain.attackTimer >= FIRE_RATE then
        brain.attackTimer = 0 
        
        pcall(function()
            zombie:getEmitter():playSound("M9Fire") 
            
            -- Calculate Hit Chance
            local hitChance = ACCURACY_STILL
            if isMoving then
                hitChance = ACCURACY_MOVE -- Heavy penalty for Run & Gun
            end

            -- Roll Dice
            if ZombRand(100) < hitChance then
                if instanceof(target, "IsoPlayer") then
                    
                    -- PLAYER DAMAGE
                    local bodyDamage = target:getBodyDamage()
                    local bodyPart = bodyDamage:getBodyPart(BodyPartType.Torso_Upper)
                    
                    local dmg = ZombRand(DAMAGE_MIN, DAMAGE_MAX)
                    bodyPart:AddDamage(dmg)
                    
                    -- MEDICAL CONSEQUENCES
                    bodyPart:setHaveBullet(true, 0)
                    bodyPart:setBleedingTime(20)
                    bodyDamage:Update()
                    
                    -- Feedback
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
            else
                -- MISS FEEDBACK (Optional)
                -- If they miss, maybe play a bullet whizz sound at the target location?
                -- target:getEmitter():playSound("BulletWhizz") -- (If sound exists)
            end
        end)
    end
end