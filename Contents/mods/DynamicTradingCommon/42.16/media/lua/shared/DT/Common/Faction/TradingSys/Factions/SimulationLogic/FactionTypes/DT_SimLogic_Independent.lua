-- ==============================================================================
-- SimulationLogic/FactionTypes/DT_SimLogic_Independent.lua
-- Logic: Wandering merchant faction - lightweight, non-colony daily updates.
-- ==============================================================================

local IndependentSim = {}

function IndependentSim.Process(faction, id, data)
    if not faction then return nil, false end

    -- Wandering merchants never die out, don't consume food, and their budget comes from their trader sessions
    faction.memberCount = math.max(faction.memberCount or 10, 10)
    faction.state = "Stable"
    faction.stockpile = faction.stockpile or {}
    faction.stockpile.food = math.max(faction.stockpile.food or 0, 500)
    
    return faction, true
end

return IndependentSim
