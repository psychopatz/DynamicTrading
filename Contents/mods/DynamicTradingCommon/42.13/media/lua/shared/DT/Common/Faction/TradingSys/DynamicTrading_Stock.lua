-- DynamicTrading_Stock.lua (Shared)

require "DT/Common/Faction/TradingSys/DynamicTrading_Economy"
require "DT/Common/Faction/TradingSys/DynamicTrading_Factions"

DynamicTrading_Stock = {}
local MOD_DATA_KEY = "DynamicTrading_Stock"

function DynamicTrading_Stock.Init()
    if not ModData.exists(MOD_DATA_KEY) then
        ModData.add(MOD_DATA_KEY, {})
        -- ModData.transmit(MOD_DATA_KEY) -- Removed global transmit
    end
end

function DynamicTrading_Stock.InitializeInventory(traderID, initialItems)
    local data = ModData.get(MOD_DATA_KEY)
    if not data[traderID] then
        -- Get soul data for factionID (persisted for client fallback)
        local soul = DynamicTrading_Roster.GetSoulRegistry(traderID)
        local factionID = soul and soul.factionID or nil
        
        data[traderID] = {
            items = initialItems or {}, -- [ItemFullType] = { qty, basePrice, dynamicMod }
            restock = {
                lastRestockTime = getGameTime():getWorldAgeHours(),
                nextRestockTime = getGameTime():getWorldAgeHours() + 24 -- 24 hours default
            },
            factionID = factionID,  -- Store factionID for client ModData fallback
            name = soul and soul.name or "Trader",
            archetype = soul and soul.archetypeID or "General",
            identitySeed = soul and soul.identitySeed or 1,
            gender = (soul and soul.isFemale) and "Female" or "Male"
        }
        -- ModData.transmit(MOD_DATA_KEY) -- Removed global transmit
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
            local pricePerUnit = DynamicTrading.Economy.V2.GetBuyPrice(traderUUID, itemFullType)
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
        
        -- ModData.transmit(MOD_DATA_KEY) -- Removed global transmit
        return true
    end
    return false
end

-- ==========================================================
-- 3. STATE HANDLER HOOKS
-- ==========================================================

function DynamicTrading_Stock.ClearStock(traderUUID)
    local data = ModData.get(MOD_DATA_KEY)
    if data[traderUUID] then
        DynamicTrading.Log("DTCommons", "Trade", "Stock", "Clearing stock for " .. traderUUID)
        data[traderUUID] = nil
        -- ModData.transmit(MOD_DATA_KEY) -- Removed global transmit
    end
end

function DynamicTrading_Stock.CheckAndGenerateStock(traderUUID)
    local soul = DynamicTrading_Roster.GetSoulRegistry(traderUUID)
    if not soul then return false, "Soul not found" end
    
    if soul.status ~= "Trading" then
        return false, "Not in Trading state"
    end
    
    local data = ModData.get(MOD_DATA_KEY)
    if not data[traderUUID] then
        DynamicTrading.Log("DTCommons", "Trade", "Stock", "Generating fresh stock for " .. traderUUID)
        local newItems = DynamicTrading.Economy.V2.GenerateStock(traderUUID)
        DynamicTrading_Stock.InitializeInventory(traderUUID, newItems)
        return true, "Stock Generated"
    else
        return true, "Stock Already Existed"
    end
end


function DynamicTrading_Stock.OnSoulStatusChanged(uuid, status)
    -- If LEAVING "Trading" state, clear the stock
    if status ~= "Trading" then
        local data = ModData.get(MOD_DATA_KEY)
        if data[uuid] then
            DynamicTrading.Log("DTCommons", "Trade", "Stock", "Soul " .. uuid .. " left Trading state (now: " .. tostring(status) .. "). Clearing stock.")
            DynamicTrading_Stock.ClearStock(uuid)
        end
    end
    
    -- We NO LONGER auto-generate on entering "Trading".
    -- This is now handled by explicit interaction (Client -> Server command).
end

-- ==========================================================
-- 4. MP SYNC LISTENER
-- ==========================================================
local function OnReceiveGlobalModData(key, data)
    if key == MOD_DATA_KEY and type(data) == "table" then
        ModData.add(key, data)
    end
end
Events.OnReceiveGlobalModData.Add(OnReceiveGlobalModData)

Events.OnInitGlobalModData.Add(DynamicTrading_Stock.Init)
