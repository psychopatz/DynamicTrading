-- =============================================================================
-- DYNAMIC TRADING: LOOT INJECTION SYSTEM
-- =============================================================================

require "Misc/DT_CorpseLootRuntime"

if isClient() and not isServer() then return end 
-- Note: In Build 42/MP, OnZombieDead runs on the client that killed the zombie 
-- (the authority). However, putting this in the /server/ folder ensures 
-- the file is distributed to clients but logic is managed correctly.

local function queueWalkieCorpseDrop(zombie)
    if not zombie or not DTCorpseLootRuntime or not DTCorpseLootRuntime.QueueCorpseMutation then
        return false
    end

    local x = math.floor(zombie:getX())
    local y = math.floor(zombie:getY())
    local z = math.floor(zombie:getZ())
    local token = DTCorpseLootRuntime.EnsureCorpseToken and DTCorpseLootRuntime.EnsureCorpseToken(zombie, "dt_walkie") or nil

    local _, applied = DTCorpseLootRuntime.QueueCorpseMutation({
        label = "dt_walkie",
        x = x,
        y = y,
        z = z,
        radius = 1,
        ttlTicks = 180,
        matcher = function(corpse, corpseModData, corpseX, corpseY, corpseZ)
            if token and DTCorpseLootRuntime.MatchCorpseByToken and DTCorpseLootRuntime.MatchCorpseByToken(token, corpseModData) then
                return true
            end
            return corpseX == x and corpseY == y and corpseZ == z
        end,
        apply = function(corpse, container)
            local item = DTCorpseLootRuntime.AddItemToContainer(container, "Base.WalkieTalkieMakeShift", function(createdItem)
                local maxCond = createdItem:getConditionMax()
                local rndCond = ZombRand(1, maxCond + 1)
                createdItem:setCondition(rndCond)

                local deviceData = createdItem:getDeviceData()
                if deviceData then
                    if ZombRand(2) == 0 then
                        deviceData:setPower(ZombRandFloat(0.0, 1.0))
                    else
                        deviceData:setPower(0.0)
                    end
                    deviceData:setIsTurnedOn(false)
                end
            end)
            return item ~= nil
        end,
    })

    return applied == true
end

local function OnZombieDead(zombie)
    -- 1. Safety Checks
    if not zombie then return end
    
    -- 2. Get Chance from Sandbox (Default to 2% if missing)
    local chance = SandboxVars.DynamicTrading.WalkieDropChance or 2.0
    
    -- If chance is 0, do nothing
    if chance <= 0 then return end

    -- 3. Roll the Dice (0 to 100)
    -- ZombRandFloat gives us a precise decimal roll (e.g., 1.5)
    if ZombRandFloat(0.0, 100.0) <= chance then
        
        -- 4. Add the Item
        queueWalkieCorpseDrop(zombie)
    end
end

-- Hook into the death event
Events.OnZombieDead.Add(OnZombieDead)

DynamicTrading.Log("DTCommons", "Init", "Loot", "Registered loot system")
