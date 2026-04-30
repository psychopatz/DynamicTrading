-- DynamicTrading_Stock.lua (Shared)

require "DT/Common/Faction/TradingSys/Economy/DynamicTrading_Economy"
require "DT/Common/Faction/TradingSys/DynamicTrading_Factions"
require "DT/Common/Faction/TradingSys/TraderSession/DT_TraderSession"

DynamicTrading_Stock = {}
local MOD_DATA_KEY = "DynamicTrading_Stock"

local function bumpVersion(stockData, reason)
    if type(stockData) ~= "table" then
        return
    end

    stockData.version = (tonumber(stockData.version) or 0) + 1
    stockData.versionReason = reason or stockData.versionReason
    stockData.versionUpdatedAt = getTimeInMillis and getTimeInMillis() or nil
end

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
            gender = (soul and soul.isFemale) and "Female" or "Male",
            version = 1
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

        bumpVersion(traderStock, "qty-update")

        -- ModData.transmit(MOD_DATA_KEY) -- Removed global transmit
        return true
    end
    return false
end

function DynamicTrading_Stock.BumpVersion(traderUUID, reason)
    local stockData = DynamicTrading_Stock.GetStock(traderUUID)
    if not stockData then
        return
    end

    bumpVersion(stockData, reason)
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
        DT_TraderSession.Close(traderUUID, "normal")
    end
end

function DynamicTrading_Stock.CheckAndGenerateStock(traderUUID)
    local soul = DynamicTrading_Roster.GetSoulRegistry(traderUUID)
    if not soul then return false, "Soul not found" end

    if soul.banditRoamActive == true then
        return false, "Trader is a bandit house roamer"
    end

    if soul.tradeCycleDemandEligible == true or tostring(soul.tradeCycleMode or "trade") ~= "trade" then
        return false, "Trader is using robbery/bribe flow"
    end
    
    if soul.status ~= "Trading" then
        return false, "Not in Trading state"
    end
    
    local data = ModData.get(MOD_DATA_KEY)
    if not data[traderUUID] then
        DynamicTrading.Log("DTCommons", "Trade", "Stock", "Generating fresh stock for " .. traderUUID)
        local newItems = DynamicTrading.Economy.V2.GenerateStock(traderUUID)
        DynamicTrading_Stock.InitializeInventory(traderUUID, newItems)
        
        if soul.factionID then
            DT_TraderSession.Create(traderUUID, soul.factionID)
        end
        return true, "Stock Generated"
    else
        if data[traderUUID].version == nil then
            data[traderUUID].version = 1
        end
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
