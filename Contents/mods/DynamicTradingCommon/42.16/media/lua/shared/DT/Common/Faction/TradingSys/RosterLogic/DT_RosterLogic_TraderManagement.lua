local MOD_DATA_KEY = DynamicTrading_Roster.MOD_DATA_KEY

-- ==========================================================
-- 2. TRADER MANAGEMENT (Physical/Radio)
-- ==========================================================
function DynamicTrading_Roster.CreateTrader(traderID, config)
    local data = ModData.get(MOD_DATA_KEY)
    if not data.Traders[traderID] then
        data.Traders[traderID] = {
            factionID = config.factionID or "Independent",
            homeCoords = config.homeCoords or { x=0, y=0, z=0, zone="Unknown" },
            returnTime = 0.0, -- Timestamp for return
            isPhysicallySpawned = false,
            visuals = config.visuals or {}, -- model, outfitID, etc
            memory = {} -- [Username] = { trust, lastSeen, tradeVolume }
        }
        -- ModData.transmit(MOD_DATA_KEY) -- Disabled global broadcast
        DynamicTrading.Log("DTCommons", "Roster", "Init", "Registered Trader " .. traderID)
    end
end

function DynamicTrading_Roster.GetTrader(traderID)
    local data = ModData.get(MOD_DATA_KEY)
    return data.Traders[traderID]
end

function DynamicTrading_Roster.RemoveTrader(traderID)
    local data = ModData.get(MOD_DATA_KEY)
    if not data or not data.Traders or not data.Traders[traderID] then
        return false
    end

    data.Traders[traderID] = nil
    return true
end

function DynamicTrading_Roster.SetSpawnStatus(traderID, isSpawned)
    local data = ModData.get(MOD_DATA_KEY)
    if data.Traders[traderID] then
        data.Traders[traderID].isPhysicallySpawned = isSpawned
        -- ModData.transmit(MOD_DATA_KEY) -- Disabled global broadcast
    end
end

function DynamicTrading_Roster.SetReturnTime(traderID, timestamp)
    local data = ModData.get(MOD_DATA_KEY)
    if data.Traders[traderID] then
        data.Traders[traderID].returnTime = timestamp
        -- ModData.transmit(MOD_DATA_KEY) -- Disabled global broadcast
    end
end

function DynamicTrading_Roster.UpdateMemory(traderID, username, tradeValue)
    local data = ModData.get(MOD_DATA_KEY)
    local trader = data.Traders[traderID]
    if trader then
        if not trader.memory[username] then
            trader.memory[username] = { trust = 0, lastSeen = 0, tradeVolume = 0 }
        end
        local mem = trader.memory[username]
        mem.lastSeen = getGameTime():getWorldAgeHours()
        mem.tradeVolume = mem.tradeVolume + tradeValue
        mem.trust = math.min(100, mem.trust + (tradeValue * 0.1))
        -- ModData.transmit(MOD_DATA_KEY) -- Disabled global broadcast
    end
end
