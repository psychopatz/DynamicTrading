-- ==============================================================================
-- ColonyEconomy/VirtualStore/DT_VirtualStore_Prices.lua
-- Logic: Weekly price recalculation based on base prices + global events.
-- ==============================================================================

local VirtualStorePrices = {}
local MOD_DATA_KEY = "DT_VirtualStore"

VirtualStorePrices.BasePrices = {
    food = 10,
    meds = 25,
    ammo = 20,
    water = 5,
    fuel = 15,
    materials = 30
}

function VirtualStorePrices.Init()
    if not ModData.exists(MOD_DATA_KEY) then
        ModData.add(MOD_DATA_KEY, {
            prices = {},
            lastRecalcHour = 0
        })
        VirtualStorePrices.RecalculatePrices()
    end
end

function VirtualStorePrices.RecalculatePrices(force)
    local data = ModData.get(MOD_DATA_KEY)
    if not data then return end

    local currentHour = math.floor(getGameTime():getWorldAgeHours())
    if not force and currentHour - (data.lastRecalcHour or 0) < 168 then
        return -- Only once a week (168 hours)
    end

    local prices = {}
    for res, basePrice in pairs(VirtualStorePrices.BasePrices) do
        -- Future expansion: global event modifiers could scale this basePrice
        prices[res] = basePrice
    end

    data.prices = prices
    data.lastRecalcHour = currentHour
    ModData.transmit(MOD_DATA_KEY)
    DynamicTrading.Log("Colony", "Economy", "VirtualStore", "Prices recalculated.")
end

function VirtualStorePrices.GetPrice(resource)
    local data = ModData.get(MOD_DATA_KEY)
    if data and data.prices and data.prices[resource] then
        return data.prices[resource]
    end
    return VirtualStorePrices.BasePrices[resource] or 10
end

if not isClient() or isServer() then
    Events.OnInitGlobalModData.Add(VirtualStorePrices.Init)
end

return VirtualStorePrices
