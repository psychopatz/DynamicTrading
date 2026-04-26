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
    if not data then return nil end
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

function Interaction.ModifyColonyWealth(factionID, amount, senderUsername)
    local data = ModData.get(MOD_DATA_KEY)
    local faction = data[factionID]
    if faction then
        faction.ColonyWealth = math.max(0, (faction.ColonyWealth or 0) + amount)
        if amount and amount >= 500 and DynamicTrading.GameplayLogs and DynamicTrading.GameplayLogs.AddFactionEvent then
            DynamicTrading.GameplayLogs.AddFactionEvent(factionID, DynamicTrading.GameplayEvents.LARGE_DONATION, {senderUsername or "A wealthy benefactor"})
        end
        ModData.transmit(MOD_DATA_KEY)
        return true
    end
    return false
end

-- Backward compatibility alias
function Interaction.ModifyWealth(factionID, amount)
    return Interaction.ModifyColonyWealth(factionID, amount)
end

function Interaction.AllocateTraderBudget(factionID, amount)
    local data = ModData.get(MOD_DATA_KEY)
    local faction = data[factionID]
    if faction then
        faction.ColonyWealth = math.max(0, (faction.ColonyWealth or 0) - amount)
        ModData.transmit(MOD_DATA_KEY)
        return true
    end
    return false
end

function Interaction.ReturnTraderBudget(factionID, amount)
    local data = ModData.get(MOD_DATA_KEY)
    local faction = data[factionID]
    if faction then
        faction.ColonyWealth = math.max(0, (faction.ColonyWealth or 0) + amount)
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

        local delta = tonumber(amount) or 0

        if faction.hostileToPlayers == true and tostring(faction.factionType or "") == "bandit" then
            faction.reputation[username] = -100
            ModData.transmit(MOD_DATA_KEY)
            return true
        end

        faction.reputation[username] = (faction.reputation[username] or 0) + delta
        
        if DynamicTrading.GameplayLogs and DynamicTrading.GameplayLogs.AddFactionEvent then
            if delta > 0 then
                DynamicTrading.GameplayLogs.AddFactionEvent(factionID, DynamicTrading.GameplayEvents.REP_SIGNIFICANT_CHANGE, {username})
            elseif delta < 0 then
                DynamicTrading.GameplayLogs.AddFactionEvent(factionID, DynamicTrading.GameplayEvents.REP_SIGNIFICANT_LOSS, {username})
            end
        end

        ModData.transmit(MOD_DATA_KEY)
        return true
    end
    return false
end

return Interaction
