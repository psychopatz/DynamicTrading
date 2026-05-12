-- ==============================================================================
-- NetworkServer/DataHandlers/DataHandlers.lua
-- Logic: Entry point for data synchronization handlers
-- Build 42 Compatible.
-- ==============================================================================

local COMMAND_MODULE = "DynamicTrading_V2"

require "DT/Common/Faction/TradingSys/DynamicTrading_Factions"
require "DT/Common/Faction/TradingSys/RosterLogic/DT_RosterLogic"
require "DT/Common/Faction/TradingSys/DynamicTrading_Stock"
require "DT/Common/Faction/TradingSys/DynamicTrading_Engine"
require "DT/Common/ServerHelpers/ServerHelpers"
require "DT/Common/Pricing/PriceConfig/DT_PriceConfig"

local DataHandlers = {}
local Handlers = {}
local Helpers = {}

local context = {
    COMMAND_MODULE = COMMAND_MODULE,
    DataHandlers = DataHandlers,
    Handlers = Handlers,
    Helpers = Helpers
}

require "DT/Common/Faction/TradingSys/NetworkServer/DataHandlers/DataHandlers_Shared"(context)
require "DT/Common/Faction/TradingSys/NetworkServer/DataHandlers/DataHandlers_FactionData"(context)
require "DT/Common/Faction/TradingSys/NetworkServer/DataHandlers/DataHandlers_RosterData"(context)
require "DT/Common/Faction/TradingSys/NetworkServer/DataHandlers/DataHandlers_PriceConfig"(context)
require "DT/Common/Faction/TradingSys/NetworkServer/DataHandlers/DataHandlers_OwnedFaction"(context)
require "DT/Common/Faction/TradingSys/NetworkServer/DataHandlers/DataHandlers_Stock"(context)

DataHandlers.Handlers = Handlers
return DataHandlers
