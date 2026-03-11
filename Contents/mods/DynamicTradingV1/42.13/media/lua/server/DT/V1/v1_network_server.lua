-- ==============================================================================
-- V1_Network_Server.lua
-- Server-side Network Handlers for V1 (Radio) commands.
-- Ensures strict server authority for V1 Radio Traders in Multiplayer.
-- ==============================================================================

if isClient() and not isServer() then return end

local COMMAND_MODULE = "DynamicTrading_V1"

local Handlers = {}

-- [GENERATE CONTACT]
Handlers.GenerateContact = function(player, args)
    local targetArchetype = args.archetype
    -- Rely on the existing Manager logic which is available in shared lua, but execute it strictly on Server context.
    if DynamicTrading and DynamicTrading.Manager and DynamicTrading.Manager.GenerateRandomContact_ServerCommand then
        -- Temporarily prevent recursive client sends if Manager is modified to send commands
        local trader = DynamicTrading.Manager.GenerateRandomContact_ServerCommand(targetArchetype, player)
        if trader then
            -- Note: ModData.transmit("DynamicTrading_Roster") is handled directly inside GenerateRandomContact_ServerCommand now.
            
            -- Send response to the starting player if they need immediate feedback (optional)
            if DynamicTrading.ServerHelpers and DynamicTrading.ServerHelpers.SendResponse then
                DynamicTrading.ServerHelpers.SendResponse(player, COMMAND_MODULE, "ContactGenerated", { success=true, uuid=trader.id })
            end
        end
    end
end

local function OnClientCommand(module, command, player, args)
    if module == COMMAND_MODULE and Handlers[command] then
        print("[DynamicTrading] V1 Server Command Received: " .. command .. " from " .. tostring(player:getUsername()))
        Handlers[command](player, args)
    end
end
Events.OnClientCommand.Add(OnClientCommand)

print("[DynamicTrading] V1 Server Network Layer Initialized.")
