-- ==============================================================================
-- DynamicTrading_Network_Server.lua
-- Logic: Server-side Network Orchestrator (Networking V2)
-- Loads handler sub-modules and registers the OnClientCommand event listener.
-- Build 42 Compatible.
-- ==============================================================================

-- NOTE: Loads on Server, Host, and Singleplayer.
-- In SP, isClient() and isServer() are both false.
if isClient() and not isServer() then return end

-- =============================================================================
-- 1. LOAD HANDLER SUB-MODULES
-- =============================================================================
local DataHandlers  = require "DT/Common/Faction/TradingSys/NetworkServer/DataHandlers"
local TradeHandlers = require "DT/Common/Faction/TradingSys/NetworkServer/TradeHandlers"
local DebugHandlers = require "DT/Common/Faction/TradingSys/NetworkServer/DebugHandlers"
local LabourNetwork = require "DT/Common/Labour/DT_Labour_Network"

-- =============================================================================
-- 2. MERGE HANDLERS INTO A SINGLE DISPATCH TABLE
-- =============================================================================
local Handlers = {}
for k, v in pairs(DataHandlers.Handlers)  do Handlers[k] = v end
for k, v in pairs(TradeHandlers.Handlers) do Handlers[k] = v end
for k, v in pairs(DebugHandlers.Handlers) do Handlers[k] = v end
for k, v in pairs((LabourNetwork and LabourNetwork.Handlers) or {}) do Handlers[k] = v end

-- =============================================================================
-- 3. MAIN EVENT LISTENER
-- =============================================================================
local COMMAND_MODULE = "DynamicTrading_V2"

-- This function listens for the 'sendClientCommand' from the UI
local function OnClientCommand(module, command, player, args)
    -- Handle V2-specific commands
    if module == COMMAND_MODULE and Handlers[command] then
        Handlers[command](player, args)
        return
    end
    
    -- Handle shared commands from TradingWindow (uses "DynamicTrading" module)
    if module == "DynamicTrading" and Handlers[command] then
        Handlers[command](player, args)
    end
end

Events.OnClientCommand.Add(OnClientCommand)

DynamicTrading = DynamicTrading or {}
DynamicTrading.NetworkServer = DynamicTrading.NetworkServer or {}
DynamicTrading.NetworkServer.HandlesSharedCommands = true

DynamicTrading.Log("DTCommons", "Init", "Network", "Server Network Layer Initialized")
