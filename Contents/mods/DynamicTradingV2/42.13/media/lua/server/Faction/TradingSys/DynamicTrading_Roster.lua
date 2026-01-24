if isClient() then return end -- Server Side Only

DynamicTrading_Roster = {}
local MOD_DATA_KEY = "DynamicTrading_Roster"

function DynamicTrading_Roster.Init()
    if not ModData.exists(MOD_DATA_KEY) then
        ModData.add(MOD_DATA_KEY, {})
        ModData.transmit(MOD_DATA_KEY)
    end
end

function DynamicTrading_Roster.CreateTrader(traderID, config)
    local data = ModData.get(MOD_DATA_KEY)
    if not data[traderID] then
        data[traderID] = {
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
    return data[traderID]
end

function DynamicTrading_Roster.SetSpawnStatus(traderID, isSpawned)
    local data = ModData.get(MOD_DATA_KEY)
    if data[traderID] then
        data[traderID].isPhysicallySpawned = isSpawned
        if not isSpawned then
            -- When despawning, set a lockout return time (e.g., must stay away for X hours)
            -- For now, we leave it as 0 unless logic dictates a lockout
        end
        ModData.transmit(MOD_DATA_KEY)
    end
end

function DynamicTrading_Roster.SetReturnTime(traderID, timestamp)
    local data = ModData.get(MOD_DATA_KEY)
    if data[traderID] then
        data[traderID].returnTime = timestamp
        ModData.transmit(MOD_DATA_KEY)
    end
end

function DynamicTrading_Roster.UpdateMemory(traderID, username, tradeValue)
    local data = ModData.get(MOD_DATA_KEY)
    local trader = data[traderID]
    if trader then
        if not trader.memory[username] then
            trader.memory[username] = { trust = 0, lastSeen = 0, tradeVolume = 0 }
        end
        local mem = trader.memory[username]
        mem.lastSeen = getGameTime():getWorldAgeHours()
        mem.tradeVolume = mem.tradeVolume + tradeValue
        -- Simple trust algo
        mem.trust = math.min(100, mem.trust + (tradeValue * 0.1))
        
        ModData.transmit(MOD_DATA_KEY)
    end
end

Events.OnInitGlobalModData.Add(DynamicTrading_Roster.Init)
