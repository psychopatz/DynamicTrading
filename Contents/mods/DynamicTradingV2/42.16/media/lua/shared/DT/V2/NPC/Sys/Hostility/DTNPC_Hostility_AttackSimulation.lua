-- ==============================================================================
-- DTNPC_Hostility_AttackSimulation.lua
-- Simulation of zombie attacks on NPCs (bites, damage, sounds).
-- ==============================================================================

DTNPCHostility = DTNPCHostility or {}

local Hostility = DTNPCHostility
local Internal = Hostility.Internal or {}

Hostility.Internal = Internal

local biteTab = {}

--- Simulates combat interactions between zombies and NPCs.
function Hostility.UpdateAttackSimulation(zombie)
    if not zombie or zombie:isDead() or zombie:getVariableBoolean("Bandit") then
        return
    end

    local zombieModData = zombie:getModData()
    if zombieModData and (zombieModData.IsDTNPC == true or zombieModData.DTNPC_UUID ~= nil) then
        return
    end

    local target = zombie:getTarget()
    if not target
        or target == zombie
        or not (target:getVariableBoolean("Bandit") or target:getModData().IsDTNPC) then
        return
    end
    
    -- Handle eaten animation if target died
    if target:isDead() then
        if zombie.setEatBodyTarget then
            zombie:setEatBodyTarget(target, true)
        end
        return
    end

    local zx, zy, zz = zombie:getX(), zombie:getY(), zombie:getZ()
    local tx, ty, tz = target:getX(), target:getY(), target:getZ()
    local dx, dy = tx - zx, ty - zy
    local distSq = (dx * dx) + (dy * dy)

    -- Close range attack simulation
    if distSq < 0.65 and math.abs(zz - tz) < 0.5 then
        if zombie:isFacingObject(target, 0.35) then
             -- Force engine into a lunge/bite state visually
             if zombie.changeState then
                 zombie:changeState(LungeState.instance())
             end
             
             -- Handle discrete hit events
             local zid = zombie:getOnlineID() or (math.floor(zx) .. "_" .. math.floor(zy))
             local currentTime = (getTimeInMillis and getTimeInMillis()) or 0
             
             if not biteTab[zid] or (currentTime - biteTab[zid].lastHitAt) > 2000 then
                 biteTab[zid] = { lastHitAt = currentTime }
                 
                 zombie:setBumpType("Bite")
                 
                 -- Play immersive sounds
                 local sound = ZombRand(2) == 0 and "ZombieBite" or "ZombieScratch"
                 getSoundManager():PlayWorldSound(sound, zombie:getSquare(), 0, 5, 1.0, false)
                 
                 -- Damage is handled by the server-side zombie aggro lease system
                 -- so evasion, mitigation, and combat-state scaling stay in one place.
                 if target.setAttackedBy then
                     target:setAttackedBy(zombie)
                 end
                 if target.setHitReaction then
                     target:setHitReaction("HitReaction")
                 end
	             end
	        end
	    end
    
    -- Periodic cleanup of tracking table
    local currentTime = (getTimeInMillis and getTimeInMillis()) or 0
    if not Hostility._lastBiteCleanup or (currentTime - Hostility._lastBiteCleanup) > 10000 then
        Hostility._lastBiteCleanup = currentTime
        for id, data in pairs(biteTab) do
            if (currentTime - data.lastHitAt) > 5000 then
                biteTab[id] = nil
            end
        end
    end
end
