if isClient() then return end -- Server Side Only

DynamicTrading_Stock = {}
local MOD_DATA_KEY = "DynamicTrading_Stock"

function DynamicTrading_Stock.Init()
    if not ModData.exists(MOD_DATA_KEY) then
        ModData.add(MOD_DATA_KEY, {})
        ModData.transmit(MOD_DATA_KEY)
    end
end

function DynamicTrading_Stock.InitializeInventory(traderID, initialItems)
    local data = ModData.get(MOD_DATA_KEY)
    if not data[traderID] then
        data[traderID] = {
            items = initialItems or {}, -- [ItemFullType] = { qty, basePrice, dynamicMod }
            restock = {
                lastRestockTime = getGameTime():getWorldAgeHours(),
                nextRestockTime = getGameTime():getWorldAgeHours() + 24 -- 24 hours default
            }
        }
        ModData.transmit(MOD_DATA_KEY)
    end
end

function DynamicTrading_Stock.GetStock(traderID)
    local data = ModData.get(MOD_DATA_KEY)
    return data[traderID]
end

function DynamicTrading_Stock.UpdateItemQty(traderID, itemFullType, delta)
    local data = ModData.get(MOD_DATA_KEY)
    local traderStock = data[traderID]
    
    if traderStock and traderStock.items[itemFullType] then
        local itemEntry = traderStock.items[itemFullType]
        itemEntry.qty = math.max(0, itemEntry.qty + delta)
        
        -- Simple Dynamic Pricing based on Scarcity
        if itemEntry.qty == 0 then
            itemEntry.dynamicMod = 1.5 -- High demand/No stock
        elseif itemEntry.qty < 5 then
            itemEntry.dynamicMod = 1.2
        else
            itemEntry.dynamicMod = 1.0
        end
        
        ModData.transmit(MOD_DATA_KEY)
        return true
    end
    return false
end

Events.OnInitGlobalModData.Add(DynamicTrading_Stock.Init)
