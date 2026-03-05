-- =============================================================================
-- DYNAMIC TRADING: VEHICLE - PART
-- =============================================================================
-- Root Category: Vehicle
-- Sub Category: Part
-- =============================================================================

require "DT/Common/Config" 
if not DynamicTrading then return end

DynamicTrading.RegisterBatch({
    { item="Base.BigGasTank1",       tags={"Vehicle.Part.FuelTank", "Quality.Standard", "Rarity.Uncommon"},      basePrice=160, stockRange={min=0, max=1} },
    { item="Base.BigGasTank2",       tags={"Vehicle.Part.FuelTank", "Quality.Heavy", "Rarity.Rare"},             basePrice=250, stockRange={min=0, max=1} },
    { item="Base.BigGasTank3",       tags={"Vehicle.Part.FuelTank", "Quality.Sport", "Rarity.Rare"},             basePrice=300, stockRange={min=0, max=1} },
    { item="Base.CarBattery1",       tags={"Vehicle.Part.Battery", "Quality.Standard", "Rarity.Common"},   basePrice=350, stockRange={min=1, max=2} },
    { item="Base.CarBattery2",       tags={"Vehicle.Part.Battery", "Quality.Heavy", "Rarity.Uncommon"},    basePrice=500, stockRange={min=1, max=2} },
    { item="Base.CarBattery3",       tags={"Vehicle.Part.Battery", "Quality.Sport", "Rarity.Rare"},        basePrice=800, stockRange={min=0, max=1} },
    { item="Base.EngineParts",       tags={"Vehicle.Part.Engine", "Theme.Industrial", "Rarity.Common"}, basePrice=120, stockRange={min=5, max=15} },
    { item="Base.ModernBrake1",      tags={"Vehicle.Part.Brake", "Quality.Standard", "Rarity.Rare"},            basePrice=550, stockRange={min=0, max=1} },
    { item="Base.ModernBrake2",      tags={"Vehicle.Part.Brake", "Quality.Heavy", "Rarity.Legendary"},          basePrice=750, stockRange={min=0, max=1} },
    { item="Base.ModernBrake3",      tags={"Vehicle.Part.Brake", "Quality.Sport", "Rarity.Legendary"},          basePrice=850, stockRange={min=0, max=1} },
    { item="Base.ModernCarMuffler1", tags={"Vehicle.Part.Muffler", "Quality.Standard", "Rarity.Rare"},         basePrice=120, stockRange={min=0, max=2} },
    { item="Base.ModernCarMuffler2", tags={"Vehicle.Part.Muffler", "Quality.Heavy", "Rarity.Rare"},            basePrice=165, stockRange={min=0, max=1} },
    { item="Base.ModernCarMuffler3", tags={"Vehicle.Part.Muffler", "Quality.Sport", "Rarity.Rare"},            basePrice=230, stockRange={min=0, max=1} },
    { item="Base.ModernSuspension1", tags={"Vehicle.Part.Suspension", "Quality.Standard", "Rarity.Rare"},     basePrice=90,  stockRange={min=0, max=2} },
    { item="Base.ModernSuspension2", tags={"Vehicle.Part.Suspension", "Quality.Heavy", "Rarity.Rare"},        basePrice=125, stockRange={min=0, max=1} },
    { item="Base.ModernSuspension3", tags={"Vehicle.Part.Suspension", "Quality.Sport", "Rarity.Rare"},        basePrice=170, stockRange={min=0, max=1} },
    { item="Base.ModernTire1",       tags={"Vehicle.Part.Tire", "Quality.Standard", "Rarity.Rare"},           basePrice=120, stockRange={min=0, max=3} },
    { item="Base.ModernTire2",       tags={"Vehicle.Part.Tire", "Quality.Heavy", "Rarity.Rare"},              basePrice=165, stockRange={min=0, max=2} },
    { item="Base.ModernTire3",       tags={"Vehicle.Part.Tire", "Quality.Sport", "Rarity.Rare"},              basePrice=230, stockRange={min=0, max=2} },
    { item="Base.NormalBrake1",      tags={"Vehicle.Part.Brake", "Quality.Standard", "Rarity.Uncommon"},        basePrice=250, stockRange={min=1, max=2} },
    { item="Base.NormalBrake2",      tags={"Vehicle.Part.Brake", "Quality.Heavy", "Rarity.Rare"},               basePrice=350, stockRange={min=1, max=2} },
    { item="Base.NormalBrake3",      tags={"Vehicle.Part.Brake", "Quality.Sport", "Rarity.Rare"},               basePrice=450, stockRange={min=0, max=1} },
    { item="Base.NormalCarMuffler1", tags={"Vehicle.Part.Muffler", "Quality.Standard", "Rarity.Uncommon"},     basePrice=60,  stockRange={min=1, max=3} },
    { item="Base.NormalCarMuffler2", tags={"Vehicle.Part.Muffler", "Quality.Heavy", "Rarity.Uncommon"},        basePrice=80,  stockRange={min=1, max=2} },
    { item="Base.NormalCarMuffler3", tags={"Vehicle.Part.Muffler", "Quality.Sport", "Rarity.Rare"},            basePrice=110, stockRange={min=0, max=2} },
    { item="Base.NormalGasTank1",    tags={"Vehicle.Part.FuelTank", "Quality.Standard", "Rarity.Common"},        basePrice=100, stockRange={min=0, max=2} },
    { item="Base.NormalGasTank2",    tags={"Vehicle.Part.FuelTank", "Quality.Heavy", "Rarity.Uncommon"},       basePrice=135, stockRange={min=0, max=2} },
    { item="Base.NormalGasTank3",    tags={"Vehicle.Part.FuelTank", "Quality.Sport", "Rarity.Rare"},             basePrice=180, stockRange={min=0, max=1} },
    { item="Base.NormalSuspension1", tags={"Vehicle.Part.Suspension", "Quality.Standard", "Rarity.Common"},   basePrice=40,  stockRange={min=1, max=4} },
    { item="Base.NormalSuspension2", tags={"Vehicle.Part.Suspension", "Quality.Heavy", "Rarity.Uncommon"},    basePrice=55,  stockRange={min=1, max=3} },
    { item="Base.NormalSuspension3", tags={"Vehicle.Part.Suspension", "Quality.Sport", "Rarity.Rare"},        basePrice=75,  stockRange={min=0, max=2} },
    { item="Base.NormalTire1",       tags={"Vehicle.Part.Tire", "Quality.Standard", "Rarity.Uncommon"},       basePrice=60,  stockRange={min=2, max=5} },
    { item="Base.NormalTire2",       tags={"Vehicle.Part.Tire", "Quality.Heavy", "Rarity.Uncommon"},          basePrice=80,  stockRange={min=2, max=4} },
    { item="Base.NormalTire3",       tags={"Vehicle.Part.Tire", "Quality.Sport", "Rarity.Rare"},              basePrice=110, stockRange={min=0, max=3} },
    { item="Base.OldBrake1",         tags={"Vehicle.Part.Brake", "Quality.Standard", "Rarity.Common"},          basePrice=80, stockRange={min=1, max=3} },
    { item="Base.OldBrake2",         tags={"Vehicle.Part.Brake", "Quality.Heavy", "Rarity.Common"},             basePrice=120, stockRange={min=1, max=3} },
    { item="Base.OldBrake3",         tags={"Vehicle.Part.Brake", "Quality.Sport", "Rarity.Uncommon"},           basePrice=180, stockRange={min=0, max=2} },
    { item="Base.OldCarMuffler1",    tags={"Vehicle.Part.Muffler", "Quality.Standard", "Rarity.Common"},       basePrice=30,  stockRange={min=1, max=3} },
    { item="Base.OldCarMuffler2",    tags={"Vehicle.Part.Muffler", "Quality.Heavy", "Rarity.Common"},          basePrice=40,  stockRange={min=1, max=2} },
    { item="Base.OldCarMuffler3",    tags={"Vehicle.Part.Muffler", "Quality.Sport", "Rarity.Uncommon"},        basePrice=55,  stockRange={min=0, max=2} },
    { item="Base.OldTire1",          tags={"Vehicle.Part.Tire", "Quality.Standard", "Rarity.Common"},         basePrice=30,  stockRange={min=2, max=6} },
    { item="Base.OldTire2",          tags={"Vehicle.Part.Tire", "Quality.Heavy", "Rarity.Common"},            basePrice=40,  stockRange={min=2, max=4} },
    { item="Base.OldTire3",          tags={"Vehicle.Part.Tire", "Quality.Sport", "Rarity.Uncommon"},          basePrice=55,  stockRange={min=0, max=3} },
    { item="Base.SmallGasTank1",     tags={"Vehicle.Part.FuelTank", "Quality.Standard", "Rarity.Common"},        basePrice=60,  stockRange={min=0, max=2} },
    { item="Base.SmallGasTank2",     tags={"Vehicle.Part.FuelTank", "Quality.Heavy", "Rarity.Uncommon"},       basePrice=85,  stockRange={min=0, max=2} },
    { item="Base.SmallGasTank3",     tags={"Vehicle.Part.FuelTank", "Quality.Sport", "Rarity.Rare"},             basePrice=110, stockRange={min=0, max=1} },
})

print("[DynamicTrading] Vehicle/Part Registry Loaded.")
