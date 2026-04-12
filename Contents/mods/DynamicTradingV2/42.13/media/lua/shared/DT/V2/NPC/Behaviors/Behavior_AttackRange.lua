-- ==============================================================================
-- Behavior_AttackRange.lua
-- Hostile ranged combat using the shared dynamic loadout/combat helpers.
-- ==============================================================================

DTNPCLogic = DTNPCLogic or {}
DTNPCLogic.Behaviors = DTNPCLogic.Behaviors or {}
require "DT/V2/NPC/Sys/DTNPC_Protect"

-- DISTANCE CONFIG
local KITE_DIST_MIN = 3.5
local KITE_DIST_MAX = 8.0
local MAX_RANGE = 14.0

-- SPEED CONFIG
local SPEED_FWD = 0.055
local SPEED_BCK = 0.035
local REACTION_DELAY = 30

-- ==============================================================================
-- 1. UTILITIES
-- ==============================================================================

local function isTileSafe(x, y, z)
    local cell = getCell()
    local sq = cell:getGridSquare(x, y, z)
    if not sq then return true end
    if not sq:isFree(false) then return false end
    if sq:isSolid() or sq:isSolidTrans() then return false end
    return true
end

local function stopMoveAnim(zombie)
    zombie:setVariable("bMoving", false)
    zombie:setVariable("isMoving", false)
    zombie:setVariable("Speed", 0.0)
    zombie:setRunning(false)
end

local function ensureManualControl(zombie)
    if not zombie:isUseless() then
        zombie:setUseless(true)
    end
    zombie:setPath2(nil)
    zombie:setTarget(nil)
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

DTNPCLogic.Behaviors["AttackRange"] = function(zombie, npcData, target, dist)
    if not npcData or npcData.state ~= "AttackRange" then
        return
    end

    if not target and zombie and zombie.getTarget then
        local currentTarget = zombie:getTarget()
        if currentTarget and instanceof and instanceof(currentTarget, "IsoPlayer") and not currentTarget:isDead() then
            target = currentTarget
            local dx = currentTarget:getX() - zombie:getX()
            local dy = currentTarget:getY() - zombie:getY()
            dist = math.sqrt((dx * dx) + (dy * dy))
        end
    end

    if not target or target:isDead() then
        npcData.attackTimer = 0
        if DTNPCProtect and DTNPCProtect.ResetCombatRhythm then
            DTNPCProtect.ResetCombatRhythm(npcData)
        end
        stopMoveAnim(zombie)
        zombie:setTarget(nil)
        return
    end

    local resolvedState = DTNPCProtect and DTNPCProtect.ResolveHostileCombatState
        and DTNPCProtect.ResolveHostileCombatState(npcData, "AttackRange", dist)
        or "Attack"
    npcData.combatTargetDistance = tonumber(dist)

    if resolvedState ~= "AttackRange" then
        if DTNPCLogic.Behaviors["Attack"] then
            npcData.state = "Attack"
            DTNPCLogic.Behaviors["Attack"](zombie, npcData, target, dist)
        end
        return
    end

    ensureManualControl(zombie)
    zombie:setTarget(target)

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

    if not npcData.reactionTimer then npcData.reactionTimer = 0 end

    local recovering, recovery = false, nil
    if DTNPCProtect and DTNPCProtect.GetCombatRecovery then
        recovering, recovery = DTNPCProtect.GetCombatRecovery(npcData, "ranged", target)
    end
    local desiredMin = recovering and math.max(KITE_DIST_MIN, recovery and recovery.distance or KITE_DIST_MIN) or KITE_DIST_MIN
    local desiredMax = recovering and math.max(KITE_DIST_MAX, desiredMin + 0.75) or KITE_DIST_MAX

    local moveDir = 0
    local currentSpeed = 0
    
    if len < desiredMin then
        npcData.reactionTimer = npcData.reactionTimer + 1
        if npcData.reactionTimer > REACTION_DELAY then
            moveDir = -1
            currentSpeed = SPEED_BCK
        else
            moveDir = 0
        end
        
    elseif len > desiredMax then
        npcData.reactionTimer = 0
        moveDir = 1
        currentSpeed = SPEED_FWD
    else
        npcData.reactionTimer = 0
        moveDir = 0
    end

    local isMoving = false
    if moveDir ~= 0 then
        zombie:setVariable("DTIdleState", "0")
        local nextX = zx + (dx * currentSpeed * moveDir)
        local nextY = zy + (dy * currentSpeed * moveDir)
        
        if isTileSafe(nextX, nextY, zz) then
            forceCombatAnim(zombie, true)
            zombie:setX(nextX)
            zombie:setY(nextY)
            isMoving = true
            zombie:faceLocation(nextX + (dx * moveDir), nextY + (dy * moveDir))
        else
            forceCombatAnim(zombie, false)
        end
    else
        forceCombatAnim(zombie, false)
        if DTNPC and DTNPC.SetRangedCombatIdleState then
            DTNPC.SetRangedCombatIdleState(zombie, npcData)
        end
    end

    if not isMoving and len > 0.001 then
        zombie:faceLocation(tx, ty)
    end

    if len > MAX_RANGE then
        return 
    end

    local stats = DTNPCProtect.GetRangedCombatStats(npcData)
    if recovering then
        npcData.attackTimer = 0
        return
    end

    npcData.attackTimer = (npcData.attackTimer or 0) + 1
    if npcData.attackTimer >= stats.fireRate then
        npcData.attackTimer = 0

        if DTNPC and DTNPC.TriggerRangedCombatAnim then
            DTNPC.TriggerRangedCombatAnim(zombie, npcData)
        end
        DTNPCProtect.ConsumeAmmo(npcData, 1)
        DTNPCProtect.ConsumeWeaponCondition(npcData, "ranged", 1)
        zombie:getEmitter():playSound("DT_GunRandom")

        local hitChance = isMoving and stats.hitMove or stats.hitStill
        if ZombRand(100) < hitChance then
            DTNPCProtect.ApplyCombatHit(zombie, npcData, target, {
                attackType = "ranged",
                damage = stats.damage,
            })
        end
        if DTNPCProtect and DTNPCProtect.RecordCombatAttack then
            DTNPCProtect.RecordCombatAttack(zombie, npcData, "ranged", target)
        end
    end
end
