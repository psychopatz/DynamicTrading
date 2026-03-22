-- =============================================================================
-- 1. UTILITIES
-- =============================================================================

local Common = DynamicTrading.Economy.Common

-- Helper to handle the Build 42 hunger/thirst normalization discrepancy.
-- Script values are often integers (e.g. -15) while instance values are floats (e.g. -0.15).
function Common.GetNormalizedHunger(scriptItem)
    if not scriptItem or not scriptItem.getHungerChange then return 0 end
    
    local val = scriptItem:getHungerChange()
    if math.abs(val) > 1.0 then return val / 100.0 end
    return val
end

-- Picks an item key from a pool based on 'weight' property.
-- pool = { {key="Base.Apple", weight=100}, {key="Base.Axe", weight=10} }
function Common.PickFromWeightedPool(pool)
    if not pool or #pool == 0 then return nil end
    
    -- 1. Calculate Total Weight
    local totalWeight = 0
    for _, entry in ipairs(pool) do
        totalWeight = totalWeight + entry.weight
    end
    
    -- Fallback if weights are busted
    if totalWeight <= 0 then return pool[ZombRand(#pool)+1].key end 
    
    -- 2. Roll the Dice
    local roll = ZombRandFloat(0, totalWeight)
    
    -- 3. Find the Winner
    local current = 0
    for _, entry in ipairs(pool) do
        current = current + entry.weight
        if roll <= current then
            return entry.key
        end
    end
    
    return pool[#pool].key
end
