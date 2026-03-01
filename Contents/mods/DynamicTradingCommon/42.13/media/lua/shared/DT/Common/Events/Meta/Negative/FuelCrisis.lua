require "DT/Common/Events/DT_EventManager"

-- =============================================================================
-- META NEGATIVE: THE FUEL CRISIS
-- =============================================================================

DynamicTrading.Events.Register("FuelCrisis", {
    name = "The Fuel Crisis",
    sentiment = "Negative",
    type = "meta",
    description = "Gasoline reserves have degraded. Combustion engines are becoming obsolete.",
    condition = function() 
        return GameTime:getInstance():getNightsSurvived() > 365
    end,
    effects = {
        ["Fuel"] = { price = 5.0, vol = 0.1 },      -- Liquid Gold
        ["CarPart"] = { price = 0.5 },              -- Useless without gas
        ["Generator"] = { price = 0.5 },            -- Useless without gas
        ["Battery"] = { price = 2.5, vol = 1.5 },   -- Solar/Electric becomes king
        ["Electronics"] = { price = 1.5 }           -- For repairing batteries/solar
    },
    factionImpact = {
        stockpileAdd = { fuel = -1000 },
        wealthAdd = -500
    }
})
