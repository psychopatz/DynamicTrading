-- ==============================================================================
-- DTNPC_Hostility_ZombieTargeting.lua
-- Management of zombie targeting toward NPCs.
-- ==============================================================================

DTNPCHostility = DTNPCHostility or {}

local Hostility = DTNPCHostility
local Internal = Hostility.Internal or {}

Hostility.Internal = Internal

--- Updates a zombie's targeting to prioritize NPCs if they are closer than players.
function Hostility.UpdateZombieTargeting(zombie)
    if not zombie or zombie:isDead() or zombie:getVariableBoolean("Bandit") then
        return
    end

    local zombieModData = zombie:getModData()
    if zombieModData and (zombieModData.IsDTNPC == true or zombieModData.DTNPC_UUID ~= nil) then
        return
    end

    local zx, zy, zz = zombie:getX(), zombie:getY(), zombie:getZ()

    -- Skip if already targeting a player who is very close
    local target = zombie:getTarget()
    if target and instanceof(target, "IsoPlayer") and not target:getVariableBoolean("Bandit") then
        local tx, ty = target:getX(), target:getY()
        local dx, dy = tx - zx, ty - zy
        if (dx * dx + dy * dy) < 25.0 then -- within 5 tiles
            return
        end
    end

    -- Find the closest NPC
    local closestNPC = nil
    local minDistSq = 400.0 -- 20 tiles ^ 2

    local cell = getCell()
    local zombieList = cell:getZombieList()
    for i = 0, zombieList:size() - 1 do
        local candidate = zombieList:get(i)
        -- In DTV2, modData.IsDTNPC or Bandit variable usually identifies an NPC
        if candidate
            and candidate ~= zombie
            and not candidate:isDead()
            and (candidate:getVariableBoolean("Bandit") or candidate:getModData().IsDTNPC) then
            local cx, cy, cz = candidate:getX(), candidate:getY(), candidate:getZ()
            if math.abs(cz - zz) < 1.1 then
                local dx, dy = cx - zx, cy - zy
                local dSq = (dx * dx + dy * dy)
                if dSq < minDistSq then
                    minDistSq = dSq
                    closestNPC = candidate
                end
            end
        end
    end

    if closestNPC then
        -- Force pathing to NPC
        if zombie.pathToCharacter then
             zombie:pathToCharacter(closestNPC)
        end
        
        -- Set engine target
        zombie:setTarget(closestNPC)
        
        -- Aggro boost
        if zombie.addAggro then
            zombie:addAggro(closestNPC, 1.0)
        end
        
        -- If very close, lunge
        if minDistSq < 1.0 then
             zombie:changeState(LungeState.instance())
        end
    end
end
