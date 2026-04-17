-- ==============================================================================
-- ColonyEconomy/VirtualStore/DT_VirtualStore_AutoBuy.lua
-- Logic: Safely auto-buys resources for colonies.
-- ==============================================================================

local VirtualStorePrices = require "DT/Common/ColonyEconomy/VirtualStore/DT_VirtualStore_Prices"
local VirtualStoreAutoBuy = {}

function VirtualStoreAutoBuy.AutoBuy(faction, resource, amount)
    if not faction or not resource or amount <= 0 then return 0, 0 end
    
    local costPerUnit = VirtualStorePrices.GetPrice(resource)
    
    local eventCostMult = 1.0
    if DynamicTrading.Events and DynamicTrading.Events.getAutoBuyPriceModifier then
        eventCostMult = DynamicTrading.Events.getAutoBuyPriceModifier(faction)
    end
    
    local autoCost = costPerUnit * eventCostMult
    local affordable = math.floor((faction.ColonyWealth or 0) / autoCost)
    local bought = math.min(amount, affordable)
    
    local spent = 0
    if bought > 0 then
        spent = math.floor(bought * autoCost)
        faction.ColonyWealth = math.floor(faction.ColonyWealth - spent)
        
        faction.stockpile = faction.stockpile or {}
        faction.stockpile[resource] = math.floor((faction.stockpile[resource] or 0) + bought)
        
        DynamicTrading.Log("Colony", "Economy", "VirtualStore", "Colony " .. (faction.name or "Unknown") .. " auto-bought " .. bought .. " " .. resource .. " for $" .. spent)
    end
    
    return bought, spent
end

return VirtualStoreAutoBuy
