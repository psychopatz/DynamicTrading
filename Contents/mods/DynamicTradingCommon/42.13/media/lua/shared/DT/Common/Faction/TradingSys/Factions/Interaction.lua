-- ==============================================================================
-- Factions/Interaction.lua
-- Logic: Faction Getters and Modifiers (Stockpile, Wealth, Reputation).
-- Build 42 Compatible.
-- ==============================================================================

local Interaction = {}
local MOD_DATA_KEY = "DynamicTrading_Factions"

-- ==========================================================
-- GETTERS
-- ==========================================================
function Interaction.GetFaction(factionID)
    local data = ModData.get(MOD_DATA_KEY)
    return data[factionID]
end

-- ==========================================================
-- STOCKPILE INTERACTION
-- ==========================================================
function Interaction.ModifyStockpile(factionID, resource, amount)
    local data = ModData.get(MOD_DATA_KEY)
    local faction = data[factionID]
    if faction and faction.stockpile[resource] then
        faction.stockpile[resource] = math.max(0, faction.stockpile[resource] + amount)
        ModData.transmit(MOD_DATA_KEY)
        return true
    end
    return false
end

function Interaction.ModifyWealth(factionID, amount)
    local data = ModData.get(MOD_DATA_KEY)
    local faction = data[factionID]
    if faction then
        faction.wealth = math.max(0, (faction.wealth or 0) + amount)
        ModData.transmit(MOD_DATA_KEY)
        return true
    end
    return false
end

function Interaction.ModifyReputation(factionID, username, amount)
    local data = ModData.get(MOD_DATA_KEY)
    local faction = data[factionID]
    if faction and username then
        if type(faction.reputation) ~= "table" then
             faction.reputation = {}
        end
        
        faction.reputation[username] = (faction.reputation[username] or 0) + (amount or 0)
        ModData.transmit(MOD_DATA_KEY)
        return true
    end
    return false
end

return Interaction
