-- =============================================================================
-- DYNAMIC TRADING COMMON: SERVER HELPERS - NETWORK LOGIC
-- =============================================================================
local Helpers = DynamicTrading.ServerHelpers

-- =============================================================================
-- 1. NETWORK / BRIDGE UTILITIES
-- =============================================================================

--- Determines if we should send network sync packets.
-- In SP, isServer() returns false; no packets needed.
-- In MP, isServer() returns true on host/dedicated; sync required.
-- @return boolean True if running on a multiplayer server.
function Helpers.ShouldSendNetworkPackets()
    return isServer()
end

--- Sends a response to both SP and MP clients correctly.
-- In MP, uses sendServerCommand. In SP, triggers the event manually
-- because sendServerCommand doesn't fire OnServerCommand locally.
-- @param player IsoPlayer The target player.
-- @param module string The module name (e.g., "DynamicTrading").
-- @param command string The command name (e.g., "TransactionResult").
-- @param args table The arguments table to send.
function Helpers.SendResponse(player, module, command, args)
    if isServer() then
        -- MULTIPLAYER: Send packet over network
        if isDebugEnabled() then
            DynamicTrading.Log("DTCommons", "Network", "Server", "Sending MP: " .. module .. ":" .. command .. " to player: " .. player:getUsername())
        end
        sendServerCommand(player, module, command, args)
    else
        -- SINGLEPLAYER: Simulate packet arrival immediately
        -- if isDebugEnabled() then
        --     print("[DynamicTradingCommon] Sending SP: " .. module .. ":" .. command .. " to player: " .. player:getUsername())
        -- end
        triggerEvent("OnServerCommand", module, command, args)
    end
end

--- Broadcasts a response to every connected client in MP, or locally in SP.
-- @param module string The module name.
-- @param command string The command name.
-- @param args table The arguments table to send.
function Helpers.BroadcastResponse(module, command, args)
    if isServer() then
        if isDebugEnabled() then
            DynamicTrading.Log("DTCommons", "Network", "Server", "Broadcasting MP: " .. tostring(module) .. ":" .. tostring(command))
        end
        sendServerCommand(module, command, args)
    else
        triggerEvent("OnServerCommand", module, command, args)
    end
end

function Helpers.SendReputationSync(player, payload)
    if not player or type(payload) ~= "table" then
        return false
    end

    Helpers.SendResponse(player, "DynamicTrading", "ReputationSync", payload)
    return true
end
