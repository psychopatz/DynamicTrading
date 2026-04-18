-- ==============================================================================
-- ColonyEconomy/Horde/DT_HordeDefs.lua
-- Defines the scaling formulas and defaults for zombie horde events.
-- ==============================================================================

local HordeDefs = {}

-- Safely retrieves the horde config, falling back to DT_Config_FactionSystem defaults
function HordeDefs.GetConfig()
    local c = DynamicTrading.Config.Horde or {}
    return {
        MinIntervalDays = c.MinIntervalDays or 3,
        MaxIntervalDays = c.MaxIntervalDays or 7,
        BaseHordeSize = c.BaseHordeSize or 5,
        WorldAgeScale = c.WorldAgeScale or 0.5,
        MaxHordeSize = c.MaxHordeSize or 100,
        BarricadeDamagePerZombie = c.BarricadeDamagePerZombie or 2,
        CasualtiesPerRemaining = c.CasualtiesPerRemaining or 5
    }
end

function HordeDefs.RollHordeSize()
    local config = HordeDefs.GetConfig()
    local worldAgeDays = getGameTime():getWorldAgeHours() / 24.0
    local scaledSpawn = config.BaseHordeSize + (worldAgeDays * config.WorldAgeScale)
    
    -- Fluctuation factor
    local variance = 0.8 + (ZombRand(41) / 100) -- 0.8 to 1.2
    
    local finalSize = math.floor(scaledSpawn * variance)
    return math.min(finalSize, config.MaxHordeSize)
end

function HordeDefs.RollNextAttackDays()
    local config = HordeDefs.GetConfig()
    return ZombRand(config.MinIntervalDays, config.MaxIntervalDays + 1)
end

return HordeDefs
