-- =============================================================================
-- DYNAMIC TRADING: LOOT INJECTION SYSTEM
-- =============================================================================

if isClient() and not isServer() then return end 
-- Note: In Build 42/MP, OnZombieDead runs on the client that killed the zombie 
-- (the authority). However, putting this in the /server/ folder ensures 
-- the file is distributed to clients but logic is managed correctly.

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
        local inv = zombie:getInventory()
        if inv then
            local item = inv:AddItem("Base.WalkieTalkieMakeShift")
            
            -- 5. Build 42 Condition Logic (Optional but recommended)
            -- Spawns items with random condition/battery so they aren't perfect
            if item then
                -- Randomize Condition (0 to Max)
                local maxCond = item:getConditionMax()
                local rndCond = ZombRand(1, maxCond + 1)
                item:setCondition(rndCond)
                
                -- Randomize Battery Power (if applicable)
                local deviceData = item:getDeviceData()
                if deviceData then
                    -- 50% chance to have some battery life, 50% dead
                    if ZombRand(2) == 0 then
                        deviceData:setPower(ZombRandFloat(0.0, 1.0))
                    else
                        deviceData:setPower(0.0)
                    end
                    
                    -- Turn it off so it doesn't annoy the player immediately
                    deviceData:setIsTurnedOn(false)
                end
            end
        end
    end
end

-- Hook into the death event
Events.OnZombieDead.Add(OnZombieDead)

print("[DynamicTrading] Loot System Loaded.")