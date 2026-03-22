local MOD_DATA_KEY = DynamicTrading_Roster.MOD_DATA_KEY

-- ==========================================================
-- 1. INITIALIZATION
-- ==========================================================
function DynamicTrading_Roster.Init()
    if not ModData.exists(MOD_DATA_KEY) then
        ModData.add(MOD_DATA_KEY, {
            Traders = {},       -- Existing physical traders/radio traders
            Souls = {},        -- Persistent identities: [uuid] = soulData
            FactionMembers = {} -- Index: [factionID] = { uuid1, uuid2, ... }
        })
        -- ModData.transmit(MOD_DATA_KEY) -- Disabled global broadcast
    end
    
    local data = ModData.get(MOD_DATA_KEY)
    if not data.FactionMembers then
        data.FactionMembers = {}
    end
end
