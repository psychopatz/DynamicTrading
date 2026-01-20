if isClient() then return end -- Server Side Only

DynamicTrading_Factions = {}
local MOD_DATA_KEY = "DynamicTrading_Factions"

function DynamicTrading_Factions.Init()
    if not ModData.exists(MOD_DATA_KEY) then
        ModData.add(MOD_DATA_KEY, {})
        ModData.transmit(MOD_DATA_KEY)
    end
end

function DynamicTrading_Factions.CreateFaction(factionID, initialData)
    local data = ModData.get(MOD_DATA_KEY)
    if not data[factionID] then
        data[factionID] = {
            stockpile = initialData.stockpile or { food = 100, ammo = 50, meds = 20, fuel = 10 },
            state = initialData.state or "Stable", -- Stable, Starving, Vulnerable, Booming
            memberCount = initialData.memberCount or 5,
            reputation = initialData.reputation or {} -- [Username] = Integer
        }
        ModData.transmit(MOD_DATA_KEY)
        print("DynamicTrading: Created Faction " .. factionID)
    end
end

function DynamicTrading_Factions.GetFaction(factionID)
    local data = ModData.get(MOD_DATA_KEY)
    return data[factionID]
end

function DynamicTrading_Factions.UpdateDaily()
    local data = ModData.get(MOD_DATA_KEY)
    local engineData = DynamicTrading_Engine.GetEngineData()
    local consumption = engineData and engineData.WorldEconomy.consumptionMods or { food=1, ammo=1 }

    for id, faction in pairs(data) do
        -- Simple consumption logic based on O(F) complexity constraint
        local foodConsumed = faction.memberCount * 2.0 * (consumption.food or 1.0)
        faction.stockpile.food = math.max(0, faction.stockpile.food - foodConsumed)

        -- Determine State
        if faction.stockpile.food <= 0 then
            faction.state = "Starving"
        elseif faction.stockpile.food < (faction.memberCount * 5) then
            faction.state = "Vulnerable"
        else
            faction.state = "Stable"
        end
    end
    
    ModData.transmit(MOD_DATA_KEY)
end

function DynamicTrading_Factions.ModifyStockpile(factionID, resource, amount)
    local data = ModData.get(MOD_DATA_KEY)
    local faction = data[factionID]
    if faction and faction.stockpile[resource] then
        faction.stockpile[resource] = faction.stockpile[resource] + amount
        ModData.transmit(MOD_DATA_KEY)
        return true
    end
    return false
end

Events.OnInitGlobalModData.Add(DynamicTrading_Factions.Init)
