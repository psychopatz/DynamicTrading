-- if isClient() and not isServer() then return end

require "DT/Common/Faction/TradingSys/DynamicTrading_Factions"
require "DT/Common/Faction/TradingSys/RosterLogic/DT_RosterLogic"
require "DT/Common/Faction/TradingSys/Factions/SimulationLogic/DT_SimulationLogic_Config"
require "DT/Common/Faction/TradingSys/DynamicTrading_Engine"
require "DT/Common/Trading/EconomyCommon/DT_EconomyCommon"

DynamicTrading = DynamicTrading or {}
DynamicTrading.Economy = DynamicTrading.Economy or {}
DynamicTrading.Economy.V2 = DynamicTrading.Economy.V2 or {}
DynamicTrading.Economy.V2._Internal = DynamicTrading.Economy.V2._Internal or {}

DynamicTrading.Log("DTCommons", "Init", "Economy", "V2 Economy Module (Shared Wrapper) loaded")

-- Load submodules in dependency order.
require "DT/Common/Faction/TradingSys/Economy/DynamicTrading_Economy_Core"
require "DT/Common/Faction/TradingSys/Economy/DynamicTrading_Economy_StockGenerator"
require "DT/Common/Faction/TradingSys/Economy/DynamicTrading_Economy_BuyPricing"
require "DT/Common/Faction/TradingSys/Economy/DynamicTrading_Economy_BulkPricing"
require "DT/Common/Faction/TradingSys/Economy/DynamicTrading_Economy_SellPricing"
