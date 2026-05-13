-- =============================================================================
-- DYNAMIC TRADING COMMON: SERVER HELPERS - NETWORK LOGIC
-- =============================================================================
local Helpers = DynamicTrading.ServerHelpers

if not Helpers.SanitizeNetworkArgs then
    local function sanitizeNetworkKey(key)
        local keyType = type(key)
        if keyType == "string" or keyType == "number" then
            return key
        end
        if keyType == "boolean" then
            return tostring(key)
        end
        return nil
    end

    local function sanitizeNetworkValue(value, seen, depth)
        local valueType = type(value)
        if valueType == "nil" then
            return nil
        end
        if valueType == "string" or valueType == "boolean" then
            return value
        end
        if valueType == "number" then
            if value ~= value then
                return 0
            end
            return value
        end
        if valueType == "userdata" then
            return tostring(value)
        end
        if valueType ~= "table" then
            return nil
        end

        local safeDepth = math.floor(tonumber(depth) or 0)
        if safeDepth > 32 then
            return nil
        end

        seen = seen or {}
        if seen[value] then
            return nil
        end
        seen[value] = true

        local copy = {}
        for key, child in pairs(value) do
            local safeKey = sanitizeNetworkKey(key)
            local safeChild = sanitizeNetworkValue(child, seen, safeDepth + 1)
            if safeKey ~= nil and safeChild ~= nil then
                copy[safeKey] = safeChild
            end
        end

        seen[value] = nil
        return copy
    end

    function Helpers.SanitizeNetworkArgs(args)
        local safeArgs = sanitizeNetworkValue(args or {}, nil, 0)
        if type(safeArgs) == "table" then
            return safeArgs
        end
        return {}
    end
end

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
    local safeArgs = Helpers.SanitizeNetworkArgs(args)
    if isServer() then
        -- MULTIPLAYER: Send packet over network
        if isDebugEnabled() then
            DynamicTrading.Log("DTCommons", "Network", "Server", "Sending MP: " .. module .. ":" .. command .. " to player: " .. player:getUsername())
        end
        sendServerCommand(player, module, command, safeArgs)
    else
        -- SINGLEPLAYER: Simulate packet arrival immediately
        -- if isDebugEnabled() then
        --     print("[DynamicTradingCommon] Sending SP: " .. module .. ":" .. command .. " to player: " .. player:getUsername())
        -- end
        triggerEvent("OnServerCommand", module, command, safeArgs)
    end
end

--- Broadcasts a response to every connected client in MP, or locally in SP.
-- @param module string The module name.
-- @param command string The command name.
-- @param args table The arguments table to send.
function Helpers.BroadcastResponse(module, command, args)
    local safeArgs = Helpers.SanitizeNetworkArgs(args)
    if isServer() then
        if isDebugEnabled() then
            DynamicTrading.Log("DTCommons", "Network", "Server", "Broadcasting MP: " .. tostring(module) .. ":" .. tostring(command))
        end
        sendServerCommand(module, command, safeArgs)
    else
        triggerEvent("OnServerCommand", module, command, safeArgs)
    end
end

function Helpers.SendReputationSync(player, payload)
    if not player or type(payload) ~= "table" then
        return false
    end

    Helpers.SendResponse(player, "DynamicTrading", "ReputationSync", payload)
    return true
end
