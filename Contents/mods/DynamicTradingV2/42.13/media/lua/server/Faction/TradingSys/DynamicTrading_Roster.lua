if isClient() then return end -- Server Side Only

DynamicTrading_Roster = {}
local MOD_DATA_KEY = "DynamicTrading_Roster"

function DynamicTrading_Roster.Init()
    if not ModData.exists(MOD_DATA_KEY) then
        ModData.add(MOD_DATA_KEY, {
            Traders = {},  -- Existing physical traders/radio traders
            Souls = {}     -- Faction members pool
        })
        ModData.transmit(MOD_DATA_KEY)
    end
end

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
        ModData.transmit(MOD_DATA_KEY)
        print("DynamicTrading: Registered Trader " .. traderID)
    end
end

function DynamicTrading_Roster.GetTrader(traderID)
    local data = ModData.get(MOD_DATA_KEY)
    return data.Traders[traderID]
end

function DynamicTrading_Roster.SetSpawnStatus(traderID, isSpawned)
    local data = ModData.get(MOD_DATA_KEY)
    if data.Traders[traderID] then
        data.Traders[traderID].isPhysicallySpawned = isSpawned
        ModData.transmit(MOD_DATA_KEY)
    end
end

function DynamicTrading_Roster.SetReturnTime(traderID, timestamp)
    local data = ModData.get(MOD_DATA_KEY)
    if data.Traders[traderID] then
        data.Traders[traderID].returnTime = timestamp
        ModData.transmit(MOD_DATA_KEY)
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
        ModData.transmit(MOD_DATA_KEY)
    end
end

-- ==========================================================
-- SOULS MANAGEMENT (Faction Members)
-- ==========================================================

function DynamicTrading_Roster.GetSouls(factionID)
    local data = ModData.get(MOD_DATA_KEY)
    if not data.Souls[factionID] then
        data.Souls[factionID] = {}
    end
    return data.Souls[factionID]
end

function DynamicTrading_Roster.AddSoul(factionID, archetypeID)
    local data = ModData.get(MOD_DATA_KEY)
    local souls = DynamicTrading_Roster.GetSouls(factionID)
    table.insert(souls, archetypeID)
    ModData.transmit(MOD_DATA_KEY)
end

function DynamicTrading_Roster.RemoveSoul(factionID, count)
    local data = ModData.get(MOD_DATA_KEY)
    local souls = data.Souls[factionID]
    if not souls or #souls == 0 then return end
    
    count = count or 1
    for i=1, count do
        if #souls > 0 then
            table.remove(souls, ZombRand(#souls) + 1)
        end
    end
    ModData.transmit(MOD_DATA_KEY)
end

function DynamicTrading_Roster.ClearSouls(factionID)
    local data = ModData.get(MOD_DATA_KEY)
    data.Souls[factionID] = nil
    ModData.transmit(MOD_DATA_KEY)
end

Events.OnInitGlobalModData.Add(DynamicTrading_Roster.Init)
