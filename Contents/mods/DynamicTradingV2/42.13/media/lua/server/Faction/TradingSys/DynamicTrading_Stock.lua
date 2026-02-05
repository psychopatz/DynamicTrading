if isClient() and not isServer() then return end -- Server Side Only (Allow SP & Host)

require "Faction/TradingSys/DynamicTrading_Economy"
require "Faction/TradingSys/DynamicTrading_Factions"

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

function DynamicTrading_Stock.UpdateItemQty(traderUUID, itemFullType, delta, playerObj)
    local data = ModData.get(MOD_DATA_KEY)
    local traderStock = data[traderUUID]
    
    if traderStock and traderStock.items[itemFullType] then
        local itemEntry = traderStock.items[itemFullType]
        local oldQty = itemEntry.qty
        itemEntry.qty = math.max(0, itemEntry.qty + delta)
        
        -- Simple Dynamic Pricing based on Scarcity
        if itemEntry.qty == 0 then
            itemEntry.dynamicMod = 1.5
        elseif itemEntry.qty < 5 then
            itemEntry.dynamicMod = 1.2
        else
            itemEntry.dynamicMod = 1.0
        end

        -- [NEW] Faction Interaction
        local soul = DynamicTrading_Roster.GetSoulRegistry(traderUUID)
        if soul and soul.factionID then
            local pricePerUnit = DynamicTrading.Economy.GetBuyPrice(traderUUID, itemFullType)
            -- delta is negative if player buys, positive if player sells
            local totalValue = math.abs(delta) * pricePerUnit
            
            if delta < 0 then -- Player BUYS from NPC
                DynamicTrading_Factions.ModifyWealth(soul.factionID, totalValue)
                -- Decrease Faction stockpile (Macro level)
                local resourceType = "misc"
                local itemData = DynamicTrading.Config.MasterList[itemFullType]
                if itemData and itemData.tags then
                    for _, tag in ipairs(itemData.tags) do
                        if DynamicTrading.V2.Config.ResourceMap[tag] then
                            resourceType = DynamicTrading.V2.Config.ResourceMap[tag]
                            break
                        end
                    end
                end
                DynamicTrading_Factions.ModifyStockpile(soul.factionID, resourceType, delta)
            elseif delta > 0 then -- Player SELLS to NPC
                DynamicTrading_Factions.ModifyWealth(soul.factionID, -totalValue)
                -- Increase Faction stockpile
                local resourceType = "misc"
                local itemData = DynamicTrading.Config.MasterList[itemFullType]
                if itemData and itemData.tags then
                    for _, tag in ipairs(itemData.tags) do
                        if DynamicTrading.V2.Config.ResourceMap[tag] then
                            resourceType = DynamicTrading.V2.Config.ResourceMap[tag]
                            break
                        end
                    end
                end
                DynamicTrading_Factions.ModifyStockpile(soul.factionID, resourceType, delta)
            end
        end
        
        ModData.transmit(MOD_DATA_KEY)
        return true
    end
    return false
end

-- ==========================================================
-- 3. STATE HANDLER HOOKS
-- ==========================================================

function DynamicTrading_Stock.OnSoulStatusChanged(uuid, status)
    if status == "Trading" then
        print("[DT-Stock] Soul " .. uuid .. " entered Trading state. Checking stock...")
        local stock = DynamicTrading_Stock.GetStock(uuid)
        
        -- If no stock or it expired, generate fresh
        if not stock or getGameTime():getWorldAgeHours() >= stock.restock.nextRestockTime then
            print("[DT-Stock] Generating fresh stock for " .. uuid)
            local newItems = DynamicTrading.Economy.GenerateStock(uuid)
            DynamicTrading_Stock.InitializeInventory(uuid, newItems)
        end
    end
end

Events.OnInitGlobalModData.Add(DynamicTrading_Stock.Init)
