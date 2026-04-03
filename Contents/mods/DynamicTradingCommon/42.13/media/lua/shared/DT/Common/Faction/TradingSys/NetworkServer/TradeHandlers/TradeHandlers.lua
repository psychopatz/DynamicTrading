-- ==============================================================================
-- NetworkServer/TradeHandlers/TradeHandlers.lua
-- Logic: Entry point for buy/sell trade transaction handlers
-- Build 42 Compatible.
-- ==============================================================================

require "DT/Common/Faction/TradingSys/DynamicTrading_Factions"
require "DT/Common/Faction/TradingSys/RosterLogic/DT_RosterLogic"
require "DT/Common/Faction/TradingSys/DynamicTrading_Stock"
require "DT/Common/Faction/TradingSys/DynamicTrading_Engine"
require "DT/Common/Faction/TradingSys/Economy/DynamicTrading_Economy"
require "DT/Common/Config"
require "DT/Common/ServerHelpers/ServerHelpers"

local DataHandlers = require "DT/Common/Faction/TradingSys/NetworkServer/DataHandlers/DataHandlers"

local TradeHandlers = {}
local Handlers = {}
local Helpers = {}

local context = {
    TradeHandlers = TradeHandlers,
    Handlers = Handlers,
    Helpers = Helpers,
    DataHandlers = DataHandlers
}

require "DT/Common/Faction/TradingSys/NetworkServer/TradeHandlers/TradeHandlers_Context_logic"(context)
require "DT/Common/Faction/TradingSys/NetworkServer/TradeHandlers/TradeHandlers_TradeMode_logic"(context)
require "DT/Common/Faction/TradingSys/NetworkServer/TradeHandlers/TradeHandlers_SellResolution_logic"(context)
require "DT/Common/Faction/TradingSys/NetworkServer/TradeHandlers/TradeHandlers_Buy_logic"(context)
require "DT/Common/Faction/TradingSys/NetworkServer/TradeHandlers/TradeHandlers_Sell_logic"(context)
require "DT/Common/Faction/TradingSys/NetworkServer/TradeHandlers/TradeHandlers_Transaction_logic"(context)

TradeHandlers.Handlers = Handlers
return TradeHandlers
